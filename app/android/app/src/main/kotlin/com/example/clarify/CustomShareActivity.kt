package com.example.clarify

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.os.Bundle
import android.util.Log
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.PopupWindow
import android.widget.TextView
import androidx.appcompat.app.AppCompatDelegate
import com.facebook.shimmer.ShimmerFrameLayout
import com.google.android.material.bottomsheet.BottomSheetBehavior
import com.google.android.material.bottomsheet.BottomSheetDialog
import kotlinx.coroutines.*

class CustomShareActivity : Activity() {

    private val coroutineScope = CoroutineScope(Dispatchers.Main + SupervisorJob())
    private lateinit var bottomSheetDialog: BottomSheetDialog
    private lateinit var shimmerTitle: ShimmerFrameLayout
    private lateinit var shimmerContent: ShimmerFrameLayout
    private lateinit var titleTextView: TextView
    private lateinit var clarityScoreTextView: TextView
    private lateinit var clickbaitTextView: TextView
    private lateinit var summaryTextView: TextView
    private var tooltipWindow: PopupWindow? = null
    private var currentExplanation: String? = null

    private val apiService by lazy { ApiService(applicationContext) }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d("CustomShareActivity", "onCreate called")
        setAppTheme()
        setupBottomSheetDialog()
        handleIntent(intent)
    }

    private fun setAppTheme() {
        val sharedPrefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val isDarkMode = sharedPrefs.getBoolean("flutter.isDarkMode", true)
        Log.d("CustomShareActivity", "setAppTheme isDarkMode: $isDarkMode")
        
        if (isDarkMode) {
            AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_YES)
            Log.d("CustomShareActivity", "AppCompatDelegate.MODE_NIGHT_YES applied")
        } else {
            AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_NO)
            Log.d("CustomShareActivity", "AppCompatDelegate.MODE_NIGHT_NO applied")
        }
    }

    private fun setupBottomSheetDialog() {
        Log.d("CustomShareActivity", "Setting up bottom sheet dialog")

        val sharedPrefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val isDarkMode = sharedPrefs.getBoolean("flutter.isDarkMode", false)
        Log.d("CustomShareActivity", "setupBottomSheetDialog isDarkMode: $isDarkMode")

        val layoutRes = if (isDarkMode) {
            R.layout.bottom_sheet_layout_night
        } else {
            R.layout.bottom_sheet_layout
        }

        val bottomSheetView = LayoutInflater.from(this).inflate(layoutRes, null)
        val themeResId = if (isDarkMode) R.style.DarkBottomSheetDialog else R.style.LightBottomSheetDialog
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
        clickbaitTextView = bottomSheetView.findViewById(R.id.clickbaitTextView)
        summaryTextView = bottomSheetView.findViewById(R.id.summaryTextView)

        bottomSheetView.setOnClickListener {
            hideTooltip()
        }

        clarityScoreTextView.setOnClickListener {
            currentExplanation?.let { explanation -> showTooltip(explanation, it) }
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
                    val result = apiService.analyzeLink(sharedText)
                    currentExplanation = result.explanation
                    runOnUiThread { displayResult(result) }
                } catch (e: Exception) {
                    Log.e("CustomShareActivity", "Error analyzing link", e)
                    runOnUiThread { displayError() }
                }
            }
        }
    }

    private fun displayResult(result: ClickbaitResponse) {
        shimmerTitle.stopShimmer()
        shimmerTitle.visibility = View.GONE
        shimmerContent.stopShimmer()
        shimmerContent.visibility = View.GONE

        clarityScoreTextView.visibility = View.VISIBLE
        titleTextView.visibility = View.VISIBLE
        clickbaitTextView.visibility = if (result.answer.isNullOrBlank()) View.GONE else View.VISIBLE
        summaryTextView.visibility = View.VISIBLE

        clarityScoreTextView.text = "Clarity Score: ${result.clarityScore}"
        val background = clarityScoreTextView.background as GradientDrawable
        background.setColor(getClarityScoreColor(result.clarityScore))
        titleTextView.text = result.title
        clickbaitTextView.text = result.answer
        summaryTextView.text = result.summary
    }

    private fun getClarityScoreColor(score: Int): Int {
        return when (score) {
            in 0..4 -> Color.parseColor("#fe2712")
            in 5..6 -> Color.parseColor("#fb9902")
            in 7..10 -> Color.parseColor("#66b032")
            else -> Color.GRAY
        }
    }

    private fun displayError() {
        shimmerTitle.stopShimmer()
        shimmerTitle.visibility = View.GONE
        shimmerContent.stopShimmer()
        shimmerContent.visibility = View.GONE

        titleTextView.visibility = View.VISIBLE
        titleTextView.text = "Failed to analyze link"
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

    override fun onDestroy() {
        super.onDestroy()
        Log.d("CustomShareActivity", "onDestroy called")
        coroutineScope.cancel()
    }
}
