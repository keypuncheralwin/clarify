package com.example.clarify

import android.content.Context
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONObject
import android.util.Log
import org.yaml.snakeyaml.Yaml
import java.util.concurrent.TimeUnit

class ApiService(private val context: Context) {
    private val client = OkHttpClient.Builder()
        .connectTimeout(30, TimeUnit.SECONDS)
        .readTimeout(30, TimeUnit.SECONDS)
        .writeTimeout(30, TimeUnit.SECONDS)
        .build()
    
    private val url = readConfig()

    suspend fun analyzeLink(link: String): ClickbaitResponse = withContext(Dispatchers.IO) {
        val json = JSONObject().apply { put("url", link) }
        val requestBody = json.toString().toRequestBody("application/json; charset=utf-8".toMediaTypeOrNull())
        val request = Request.Builder()
            .url(url)
            .post(requestBody)
            .build()
        Log.d("ApiService", "Request: $requestBody")
    
        val response = client.newCall(request).execute()
        if (!response.isSuccessful) throw Exception("Unexpected code $response")
    
        val responseBody = response.body?.string() ?: throw Exception("Response body is null")
        Log.d("ApiService", "Response: $responseBody")
    
        val jsonResponse = JSONObject(responseBody).getJSONObject("response")
        ClickbaitResponse(
            title = jsonResponse.getString("title"),
            isClickBait = jsonResponse.getBoolean("isClickBait"),
            explanation = jsonResponse.getString("explanation"),
            summary = jsonResponse.getString("summary"),
            clarityScore = jsonResponse.getInt("clarityScore"), 
            answer = jsonResponse.optString("answer"),
            url = jsonResponse.getString("url"),
            isVideo = jsonResponse.getBoolean("isVideo")
        )
    }  
    

    private fun readConfig(): String {
        val assetManager = context.assets
        val inputStream = assetManager.open("config.yaml")
        val yaml = Yaml()
        val config = yaml.load<Map<String, Any>>(inputStream)
        return config["backend_url"] as String
    }
}

data class ClickbaitResponse(
    val title: String,
    val isClickBait: Boolean,
    val explanation: String,
    val summary: String,
    val clarityScore: Int,
    val url: String,
    val isVideo: Boolean,
    val answer: String? = null
)

