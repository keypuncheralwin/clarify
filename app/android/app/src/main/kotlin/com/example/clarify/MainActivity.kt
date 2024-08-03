package com.example.clarify

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*
import android.util.Log
import com.google.firebase.auth.FirebaseAuth
import kotlin.coroutines.resume
import kotlin.coroutines.suspendCoroutine

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example/device_id"
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
                MethodChannel(messenger, "com.clarify.app/api").invokeMethod("historyUpdated", null)
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getDeviceId") {
                val deviceId = ApiService(applicationContext).getDeviceId()
                if (deviceId != null) {
                    result.success(deviceId)
                } else {
                    result.error("UNAVAILABLE", "Device ID not available.", null)
                }
            } else {
                result.notImplemented()
            }
        }

        // Existing method channel for analyzeLink
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.clarify.app/api").setMethodCallHandler { call, result ->
            if (call.method == "analyseLink") {
                val url = call.argument<String>("url")
                Log.d("MainActivity", "analyseLink called with url: $url")
                if (url != null) {
                    coroutineScope.launch {
                        try {
                            val idToken = getIdToken()
                            val response = ApiService(applicationContext).analyseLink(url, idToken)
                            when (response) {
                                is AnalysisResult.Success -> {
                                    result.success(mapOf(
                                        "status" to "success",
                                        "data" to mapOf(
                                            "title" to response.data.title,
                                            "isClickBait" to response.data.isClickBait,
                                            "clarityScore" to response.data.clarityScore,
                                            "answer" to response.data.answer,
                                            "explanation" to response.data.explanation,
                                            "summary" to response.data.summary,
                                            "url" to response.data.url,
                                            "isVideo" to response.data.isVideo,
                                            "hashedUrl" to response.data.hashedUrl,
                                            "analysedAt" to response.data.analysedAt,
                                            "isAlreadyInHistory" to response.data.isAlreadyInHistory
                                        )
                                    ))
                                }
                                is AnalysisResult.Error -> {
                                    result.success(mapOf(
                                        "status" to "error",
                                        "error" to mapOf(
                                            "errorCode" to response.errorCode,
                                            "errorMessage" to response.errorMessage
                                        )
                                    ))
                                }
                            }
                        } catch (e: Exception) {
                            Log.e("MainActivity", "Error analysing link", e)
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
