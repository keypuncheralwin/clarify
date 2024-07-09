package com.example.clarify

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Bundle
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*
import android.util.Log
import com.google.firebase.auth.FirebaseAuth
import kotlin.coroutines.resume
import kotlin.coroutines.suspendCoroutine

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.clarify.app/api"
    private val coroutineScope = CoroutineScope(Dispatchers.Main + SupervisorJob())
    private lateinit var auth: FirebaseAuth

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        auth = FirebaseAuth.getInstance()  // Initialize Firebase Auth

        // Register broadcast receiver
        val filter = IntentFilter("com.clarify.app.ACTION_HISTORY_UPDATED")
        registerReceiver(historyUpdateReceiver, filter, Context.RECEIVER_EXPORTED)
    }

    private val historyUpdateReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
                MethodChannel(messenger, CHANNEL).invokeMethod("historyUpdated", null)
            }
        }
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "analyzeLink") {
                val url = call.argument<String>("url")
                Log.d("MainActivity", "analyzeLink called with url: $url")
                if (url != null) {
                    coroutineScope.launch {
                        try {
                            val idToken = getIdToken()
                            val response = ApiService(applicationContext).analyzeLink(url, idToken)
                            result.success(mapOf(
                                "title" to response.title,
                                "isClickBait" to response.isClickBait,
                                "clarityScore" to response.clarityScore,
                                "answer" to response.answer,
                                "explanation" to response.explanation,
                                "summary" to response.summary,
                                "url" to response.url,
                                "isVideo" to response.isVideo,
                                "lastAnalysed" to response.lastAnalysed.toDate().toString()
                            ))
                        } catch (e: Exception) {
                            Log.e("MainActivity", "Error analyzing link", e)
                            result.error("UNAVAILABLE", "Link analysis failed.", null)
                        }
                    }
                } else {
                    result.error("INVALID_ARGUMENT", "URL is required", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private suspend fun getIdToken(): String? = suspendCoroutine { cont ->
        val user = auth.currentUser
        if (user != null) {
            user.getIdToken(false).addOnCompleteListener { task ->
                if (task.isSuccessful) {
                    val idToken = task.result?.token
                    cont.resume(idToken)
                } else {
                    cont.resumeWith(Result.failure(task.exception ?: Exception("Failed to get ID token")))
                }
            }
        } else {
            cont.resume(null)  // User is not signed in
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        coroutineScope.cancel()
        unregisterReceiver(historyUpdateReceiver) // Unregister receiver to avoid memory leaks
    }
}
