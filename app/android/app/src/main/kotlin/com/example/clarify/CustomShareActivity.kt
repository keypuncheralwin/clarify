package com.example.clarify

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.widget.TextView
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
    private lateinit var clickbaitTextView: TextView
    private lateinit var summaryTextView: TextView

    private val apiService by lazy { ApiService(applicationContext) }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d("CustomShareActivity", "onCreate called")
        setupBottomSheetDialog()
        handleIntent(intent)
    }

    private fun setupBottomSheetDialog() {
        val bottomSheetView = LayoutInflater.from(this).inflate(R.layout.bottom_sheet_layout, null)
        bottomSheetDialog = BottomSheetDialog(this, R.style.RoundedBottomSheetDialog)
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
        clickbaitTextView = bottomSheetView.findViewById(R.id.clickbaitTextView)
        summaryTextView = bottomSheetView.findViewById(R.id.summaryTextView)
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

        titleTextView.visibility = View.VISIBLE
        clickbaitTextView.visibility = if (result.answer.isNullOrBlank()) View.GONE else View.VISIBLE
        summaryTextView.visibility = View.VISIBLE

        titleTextView.text = result.title
        clickbaitTextView.text = result.answer
        summaryTextView.text = result.summary
    }

    private fun displayError() {
        shimmerTitle.stopShimmer()
        shimmerTitle.visibility = View.GONE
        shimmerContent.stopShimmer()
        shimmerContent.visibility = View.GONE

        titleTextView.visibility = View.VISIBLE
        titleTextView.text = "Failed to analyze link"
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d("CustomShareActivity", "onDestroy called")
        coroutineScope.cancel()
    }
}
