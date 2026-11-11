package com.finomos

import android.Manifest
import android.content.ContentValues
import android.content.pm.PackageManager
import android.database.Cursor
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream

class MainActivity : FlutterActivity() {
    private val DOWNLOAD_CHANNEL = "com.finomos/download"
    private val SMS_CHANNEL = "com.finomos/sms"
    private val SMS_PERMISSION_REQ_CODE = 2001
    private var pendingPermissionResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 1. Download file channel handler
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, DOWNLOAD_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "downloadFile") {
                val fileName = call.argument<String>("fileName") ?: "document_${System.currentTimeMillis()}.pdf"
                val sourcePath = call.argument<String>("sourcePath")
                val bytes = call.argument<ByteArray>("bytes")

                try {
                    val savedPath = saveToDownloads(fileName, sourcePath, bytes)
                    result.success(savedPath)
                } catch (e: Exception) {
                    result.error("DOWNLOAD_ERROR", e.message, null)
                }
            } else {
                result.notImplemented()
            }
        }

        // 2. Native SMS reader channel handler (reads SMS from Messages app)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SMS_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "hasSmsPermission" -> {
                    // HIDE FOR GOOGLE PLAY POLICY COMPLIANCE:
                    // Return false directly so runtime SMS permissions are not requested.
                    // Original code preserved:
                    // val granted = ContextCompat.checkSelfPermission(this, Manifest.permission.READ_SMS) == PackageManager.PERMISSION_GRANTED
                    // result.success(granted)
                    result.success(false)
                }
                "requestSmsPermission" -> {
                    // HIDE FOR GOOGLE PLAY POLICY COMPLIANCE:
                    // Return false directly without requesting runtime SMS permissions.
                    // Original code preserved:
                    // val granted = ContextCompat.checkSelfPermission(this, Manifest.permission.READ_SMS) == PackageManager.PERMISSION_GRANTED
                    // if (granted) { result.success(true) } else { pendingPermissionResult = result
                    //   ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.READ_SMS, Manifest.permission.RECEIVE_SMS), SMS_PERMISSION_REQ_CODE) }
                    result.success(false)
                }
                "readInboxSms" -> {
                    // HIDE FOR GOOGLE PLAY POLICY COMPLIANCE:
                    // Return empty list safely.
                    // Original code preserved:
                    // val granted = ContextCompat.checkSelfPermission(this, Manifest.permission.READ_SMS) == PackageManager.PERMISSION_GRANTED
                    // if (!granted) { result.error("PERMISSION_DENIED", "SMS read permission not granted", null); return@setMethodCallHandler }
                    // val limit = call.argument<Int>("limit") ?: 50
                    // try { val messages = fetchInboxSms(limit); result.success(messages) } catch (e: Exception) { result.error("SMS_READ_ERROR", e.message, null) }
                    result.success(emptyList<Map<String, Any>>())
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == SMS_PERMISSION_REQ_CODE) {
            val granted = grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED
            pendingPermissionResult?.success(granted)
            pendingPermissionResult = null
        }
    }

    private fun fetchInboxSms(limit: Int): List<Map<String, Any>> {
        val smsList = mutableListOf<Map<String, Any>>()
        val projection = arrayOf("address", "body", "date")

        // Try inbox URI first, then generic sms URI as fallback
        val uris = listOf(
            Uri.parse("content://sms/inbox"),
            Uri.parse("content://sms")
        )

        for (uri in uris) {
            if (smsList.size >= limit) break
            try {
                // Use "date DESC" without LIMIT string which breaks on some Android ContentProviders
                val cursor: Cursor? = contentResolver.query(
                    uri,
                    projection,
                    null,
                    null,
                    "date DESC"
                )

                cursor?.use {
                    val addressIdx = it.getColumnIndex("address")
                    val bodyIdx = it.getColumnIndex("body")
                    val dateIdx = it.getColumnIndex("date")

                    while (it.moveToNext() && smsList.size < limit) {
                        val address = if (addressIdx != -1) it.getString(addressIdx) ?: "" else ""
                        val body = if (bodyIdx != -1) it.getString(bodyIdx) ?: "" else ""
                        val date = if (dateIdx != -1) it.getLong(dateIdx) else 0L

                        if (address.isNotEmpty() && body.isNotEmpty()) {
                            val item = mapOf<String, Any>(
                                "sender" to address,
                                "body" to body,
                                "timestamp" to date
                            )
                            // Avoid duplicates in the returned list
                            if (!smsList.any { m -> m["sender"] == address && m["body"] == body }) {
                                smsList.add(item)
                            }
                        }
                    }
                }
            } catch (e: Exception) {
                // Continue to fallback URI
            }
            if (smsList.isNotEmpty()) break
        }
        return smsList
    }

    private fun saveToDownloads(fileName: String, sourcePath: String?, bytes: ByteArray?): String {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val mimeType = when {
                fileName.endsWith(".pdf", true) -> "application/pdf"
                fileName.endsWith(".jpg", true) || fileName.endsWith(".jpeg", true) -> "image/jpeg"
                fileName.endsWith(".png", true) -> "image/png"
                fileName.endsWith(".webp", true) -> "image/webp"
                else -> "application/octet-stream"
            }

            val values = ContentValues().apply {
                put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
                put(MediaStore.MediaColumns.MIME_TYPE, mimeType)
                put(MediaStore.MediaColumns.RELATIVE_PATH, Environment.DIRECTORY_DOWNLOADS)
            }

            val uri = contentResolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values)
                ?: throw Exception("Failed to create MediaStore entry")

            contentResolver.openOutputStream(uri)?.use { output ->
                if (sourcePath != null && File(sourcePath).exists()) {
                    FileInputStream(File(sourcePath)).use { input ->
                        input.copyTo(output)
                    }
                } else if (bytes != null) {
                    output.write(bytes)
                } else {
                    output.write("Finomos Document: $fileName".toByteArray())
                }
            }
            return Environment.DIRECTORY_DOWNLOADS + "/" + fileName
        } else {
            val downloadsDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
            if (!downloadsDir.exists()) downloadsDir.mkdirs()
            val targetFile = File(downloadsDir, fileName)
            if (sourcePath != null && File(sourcePath).exists()) {
                File(sourcePath).copyTo(targetFile, overwrite = true)
            } else if (bytes != null) {
                targetFile.writeBytes(bytes)
            } else {
                targetFile.writeText("Finomos Document: $fileName")
            }
            return targetFile.absolutePath
        }
    }
}

