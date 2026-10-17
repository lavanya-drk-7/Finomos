package com.example.finomos

import android.content.ContentValues
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.finomos/download"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
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
