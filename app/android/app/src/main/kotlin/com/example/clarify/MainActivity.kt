package com.example.clarify

import android.os.Bundle
import android.util.Log
import com.google.firebase.auth.FirebaseAuth
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import kotlin.coroutines.resume
import kotlin.coroutines.suspendCoroutine

class MainActivity : FlutterActivity() {
    private val channel = "com.clarify.app/api"
    private val coroutineScope = CoroutineScope(Dispatchers.Main + SupervisorJob())
    private lateinit var auth: FirebaseAuth

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        auth = FirebaseAuth.getInstance()  
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->
            if (call.method == "analyseLink") {
                val url = call.argument<String>("url")
                Log.d("MainActivity", "analyseLink called with url: $url")
                if (url != null) {
                    coroutineScope.launch {
                        try {
                            val idToken = getIdToken()
                            val response = ApiService(applicationContext).analyseLink(url, idToken)
                            result.success(mapOf(
                                "title" to response.title,
                                "isClickBait" to response.isClickBait,
                                "clarityScore" to response.clarityScore,
                                "answer" to response.answer,
                                "explanation" to response.explanation,
                                "summary" to response.summary,
                                "url" to response.url,
                                "isVideo" to response.isVideo,
                                "hashedUrl" to response.hashedUrl,
                                "analysedAt" to response.analysedAt,
                                "isAlreadyInHistory" to response.isAlreadyInHistory
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
            cont.resume(null)
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        coroutineScope.cancel()
    }
}
