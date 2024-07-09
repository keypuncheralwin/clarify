package com.example.clarify

import android.content.Context
import android.provider.Settings
import com.google.firebase.Timestamp
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

    suspend fun analyzeLink(link: String, idToken: String?): AnalysedLinkResponse = withContext(Dispatchers.IO) {
        val url = readConfig()
        val deviceId = getDeviceId() ?: "NO_DEVICE_ID"
        val json = JSONObject().apply {
            put("url", link)
            put("device_id", deviceId)
        }
        val requestBody = json.toString().toRequestBody("application/json; charset=utf-8".toMediaTypeOrNull())
        val requestBuilder = Request.Builder()
            .url(url)
            .post(requestBody)

        idToken?.let {
            requestBuilder.addHeader("Authorization", "Bearer $it")
        }

        val request = requestBuilder.build()
        Log.d("ApiService", "Request: $requestBody")

        val response = client.newCall(request).execute()
        if (!response.isSuccessful) throw Exception("Unexpected code $response")

        val responseBody = response.body?.string() ?: throw Exception("Response body is null")
        Log.d("ApiService", "Response: $responseBody")

        val jsonResponse = JSONObject(responseBody).getJSONObject("response")
        AnalysedLinkResponse(
            title = jsonResponse.getString("title"),
            isClickBait = jsonResponse.getBoolean("isClickBait"),
            explanation = jsonResponse.getString("explanation"),
            summary = jsonResponse.getString("summary"),
            clarityScore = jsonResponse.getInt("clarityScore"),
            answer = jsonResponse.optString("answer"),
            url = jsonResponse.getString("url"),
            isVideo = jsonResponse.getBoolean("isVideo"),
            lastAnalysed = jsonResponse.get("lastAnalysed") as? Timestamp ?: Timestamp.now()
        )
    }

    private fun readConfig(): String {
        val assetManager = context.assets
        val inputStream = assetManager.open("config.yaml")
        val yaml = Yaml()
        val config = yaml.load<Map<String, Any>>(inputStream)
        return config["backend_url"] as String
    }

    private fun getDeviceId(): String? {
        return try {
            Settings.Secure.getString(context.contentResolver, Settings.Secure.ANDROID_ID)
        } catch (e: Exception) {
            Log.e("ApiService", "Error retrieving device ID", e)
            null
        }
    }
}

data class AnalysedLinkResponse(
    val title: String,
    val isClickBait: Boolean,
    val explanation: String,
    val summary: String,
    val clarityScore: Int,
    val url: String,
    val isVideo: Boolean,
    val answer: String? = null,
    val lastAnalysed: Timestamp
)
