package com.example.clarify

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*
import android.util.Log 

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.clarify/api"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "analyzeLink") {
                val url = call.argument<String>("url")
                Log.d("MainActivity", "analyzeLink called with url: $url")
                if (url != null) {
                    CoroutineScope(Dispatchers.Main).launch {
                        try {
                            val response = ApiService(applicationContext).analyzeLink(url)
                            result.success(mapOf(
                                "title" to response.title,
                                "isClickBait" to response.isClickBait,
                                "explanation" to response.explanation,
                                "summary" to response.summary
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
}
