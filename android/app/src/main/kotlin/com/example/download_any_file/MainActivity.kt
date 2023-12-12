package com.example.download_any_file

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "your_channel_id"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "openFile") {
                    val filePath = call.argument<String>("filePath")
                    if (filePath != null) {
                        OpenFilePlugin.openFile(this@MainActivity, filePath)
                    } else {
                        result.error("FILE_PATH_NULL", "File path is null", null)
                    }
                } else {
                    result.notImplemented()
                }
            }
    }
}
