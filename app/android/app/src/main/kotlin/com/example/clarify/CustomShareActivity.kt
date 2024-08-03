package com.example.clarify

import android.app.Activity
import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.net.Uri
import android.os.Bundle
import android.util.Log
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.widget.Button
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.PopupWindow
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatDelegate
import com.clarify.app.R
import com.facebook.shimmer.ShimmerFrameLayout
import com.google.android.material.bottomsheet.BottomSheetBehavior
import com.google.android.material.bottomsheet.BottomSheetDialog
import com.google.firebase.auth.FirebaseAuth
import kotlinx.coroutines.*
import kotlinx.coroutines.tasks.await

class CustomShareActivity : Activity() {

    private val coroutineScope = CoroutineScope(Dispatchers.Main + SupervisorJob())
    private lateinit var bottomSheetDialog: BottomSheetDialog
    private lateinit var shimmerTitle: ShimmerFrameLayout
    private lateinit var shimmerContent: ShimmerFrameLayout
    private lateinit var titleTextView: TextView
    private lateinit var clarityScoreTextView: TextView
    private lateinit var helpIcon: ImageView
    private lateinit var copyIcon: ImageView
    private lateinit var clickbaitTextView: TextView
    private lateinit var summaryTextView: TextView
    private lateinit var button1: Button
    private lateinit var button2: Button
    private lateinit var buttonLayout: LinearLayout
    private var tooltipWindow: PopupWindow? = null
    private var currentExplanation: String? = null
    private var analysedLinkResponse: AnalysedLinkResponse? = null

    private val apiService by lazy { ApiService(applicationContext) }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d("CustomShareActivity", "onCreate called")
        setupBottomSheetDialog()
        handleIntent(intent)
    }

    private fun setupBottomSheetDialog() {
        Log.d("CustomShareActivity", "Setting up bottom sheet dialog")

        val sharedPrefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val isDarkMode = sharedPrefs.getBoolean("flutter.isDarkMode", true)
        Log.d("CustomShareActivity", "setupBottomSheetDialog isDarkMode: $isDarkMode")

        val (themeMode, layoutRes, themeResId) = if (isDarkMode) {
            Triple(AppCompatDelegate.MODE_NIGHT_YES, R.layout.bottom_sheet_layout_night, R.style.DarkBottomSheetDialog)
        } else {
            Triple(AppCompatDelegate.MODE_NIGHT_NO, R.layout.bottom_sheet_layout, R.style.LightBottomSheetDialog)
        }

        AppCompatDelegate.setDefaultNightMode(themeMode)
        Log.d("CustomShareActivity", "AppCompatDelegate.setDefaultNightMode applied")

        val bottomSheetView = LayoutInflater.from(this).inflate(layoutRes, null)
        bottomSheetDialog = BottomSheetDialog(this, themeResId)
        bottomSheetDialog.setContentView(bottomSheetView)

        val bottomSheetBehavior = BottomSheetBehavior.from(bottomSheetView.parent as View)
        bottomSheetBehavior.state = BottomSheetBehavior.STATE_EXPANDED
        bottomSheetBehavior.peekHeight = BottomSheetBehavior.PEEK_HEIGHT_AUTO

        bottomSheetDialog.setOnDismissListener {
            Log.d("CustomShareActivity", "Bottom sheet dismissed")
            finish()
        }

        shimmerTitle = bottomSheetView.findViewById(R.id.shimmerTitle)
        shimmerContent = bottomSheetView.findViewById(R.id.shimmerContent)
        titleTextView = bottomSheetView.findViewById(R.id.titleTextView)
        clarityScoreTextView = bottomSheetView.findViewById(R.id.clarityScoreTextView)
        helpIcon = bottomSheetView.findViewById(R.id.helpIcon)
        copyIcon = bottomSheetView.findViewById(R.id.copyIcon)
        clickbaitTextView = bottomSheetView.findViewById(R.id.clickbaitTextView)
        summaryTextView = bottomSheetView.findViewById(R.id.summaryTextView)
        button1 = bottomSheetView.findViewById(R.id.button1)
        button2 = bottomSheetView.findViewById(R.id.button2)
        buttonLayout = bottomSheetView.findViewById(R.id.buttonLayout)

        // Set initial visibility to GONE
        buttonLayout.visibility = View.GONE
        button1.visibility = View.GONE
        button2.visibility = View.GONE
        helpIcon.visibility = View.GONE
        copyIcon.visibility = View.GONE 
        Log.d("CustomShareActivity", "Buttons initialized and set to GONE")

        bottomSheetView.setOnClickListener {
            hideTooltip()
        }

        clarityScoreTextView.setOnClickListener {
            currentExplanation?.let { explanation -> showTooltip(explanation, it) }
        }

        helpIcon.setOnClickListener {
            val clarityScoreDefinition = "The clarity score is a measure from 0 to 10 indicating how clear and accurate the title is, with higher scores indicating greater clarity and accuracy. Click on the clarity score to see the reason behind the score."
            showTooltip(clarityScoreDefinition, clarityScoreTextView)
        }

        copyIcon.setOnClickListener {
            analysedLinkResponse?.let { result ->
                val textToCopy = "Title: ${result.title}\nClarity Score: ${result.clarityScore}\nMain Point: ${result.answer}\nSummary: ${result.summary}"
                copyToClipboard(textToCopy)
            }
        }

        button1.setOnClickListener {
            analysedLinkResponse?.let { result ->
                val intent = Intent(Intent.ACTION_VIEW, Uri.parse("clarify://open"))
                startActivity(intent)
            }
        }

        button2.setOnClickListener {
            // Handle "Visit Link" button click
            analysedLinkResponse?.let { result ->
                val url = result.url
                val isVideo = result.isVideo
                val intent = Intent(Intent.ACTION_VIEW, Uri.parse("clarify://open?url=$url&isVideo=$isVideo"))
                startActivity(intent)
            }
        }
    }

    private fun handleIntent(intent: Intent?) {
        intent?.let {
            if (it.action == Intent.ACTION_SEND) {
                handleSendText(it)
            }
        }
    }

    private fun handleSendText(intent: Intent) {
        intent.getStringExtra(Intent.EXTRA_TEXT)?.let { sharedText ->
            Log.d("CustomShareActivity", "handleSendText: $sharedText")
            bottomSheetDialog.show()
            coroutineScope.launch {
                try {
                    val idToken = getIdToken()
                    val result = apiService.analyseLink(sharedText, idToken)
                    when (result) {
                        is AnalysisResult.Success -> {
                            analysedLinkResponse = result.data
                            currentExplanation = result.data.explanation
                            if (result.data.isAlreadyInHistory != true) {
                                sendBroadcast(Intent("com.clarify.app.ACTION_HISTORY_UPDATED"))  // Send broadcast
                            }
                            runOnUiThread { displayResult(result.data) }
                        }
                        is AnalysisResult.Error -> {
                            runOnUiThread { displayError(result.errorMessage) }
                        }
                    }
                } catch (e: Exception) {
                    Log.e("CustomShareActivity", "Error analysing link", e)
                    runOnUiThread { displayError("We're having trouble clarifying that, please try again later.") }
                }
            }
        }
    }

    private suspend fun getIdToken(): String? = withContext(Dispatchers.IO) {
        val user = FirebaseAuth.getInstance().currentUser
        user?.getIdToken(false)?.await()?.token
    }

    private fun displayResult(result: AnalysedLinkResponse) {
        shimmerTitle.stopShimmer()
        shimmerTitle.visibility = View.GONE
        shimmerContent.stopShimmer()
        shimmerContent.visibility = View.GONE

        clarityScoreTextView.visibility = View.VISIBLE
        titleTextView.visibility = View.VISIBLE
        helpIcon.visibility = View.VISIBLE
        copyIcon.visibility = View.VISIBLE
        clickbaitTextView.visibility = if (result.answer.isBlank()) View.GONE else View.VISIBLE
        summaryTextView.visibility = View.VISIBLE

        clarityScoreTextView.text = "Clarity Score: ${result.clarityScore}"
        val background = clarityScoreTextView.background as GradientDrawable
        background.setColor(getClarityScoreColor(result.clarityScore))
        titleTextView.text = result.title
        clickbaitTextView.text = result.answer
        summaryTextView.text = result.summary

        // Post visibility changes to ensure they are applied
        buttonLayout.post {
            buttonLayout.visibility = View.VISIBLE
            button1.visibility = View.VISIBLE
            button2.visibility = View.VISIBLE
            Log.d("CustomShareActivity", "Buttons set to VISIBLE")
        }
    }

    private fun getClarityScoreColor(score: Int): Int {
        return when (score) {
            in 0..4 -> Color.parseColor("#fe2712")
            in 5..6 -> Color.parseColor("#fb9902")
            in 7..10 -> Color.parseColor("#66b032")
            else -> Color.GRAY
        }
    }

    private fun displayError(message: String) {
        shimmerTitle.stopShimmer()
        shimmerTitle.visibility = View.GONE
        shimmerContent.stopShimmer()
        shimmerContent.visibility = View.GONE

        titleTextView.visibility = View.VISIBLE
        titleTextView.text = message

        // Hide buttons if there is an error
        buttonLayout.visibility = View.GONE
        button1.visibility = View.GONE
        button2.visibility = View.GONE
        Log.d("CustomShareActivity", "Buttons set to GONE due to error")
    }

    private fun showTooltip(explanation: String, anchor: View) {
        val tooltipView = LayoutInflater.from(this).inflate(R.layout.tooltip_layout, null)
        val explanationTextView = tooltipView.findViewById<TextView>(R.id.explanationTextView)
        val closeTooltipButton = tooltipView.findViewById<ImageView>(R.id.closeTooltipButton)
        explanationTextView.text = explanation

        tooltipWindow = PopupWindow(tooltipView, LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.WRAP_CONTENT, true)
        tooltipWindow?.showAsDropDown(anchor, 0, 20, Gravity.TOP or Gravity.START)

        closeTooltipButton.setOnClickListener {
            hideTooltip()
        }
    }

    private fun hideTooltip() {
        tooltipWindow?.dismiss()
        tooltipWindow = null
    }

    private fun copyToClipboard(text: String) {
        val clipboard = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        val clip = ClipData.newPlainText("Clarity Score Details", text)
        clipboard.setPrimaryClip(clip)
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d("CustomShareActivity", "onDestroy called")
        coroutineScope.cancel()
    }
}
