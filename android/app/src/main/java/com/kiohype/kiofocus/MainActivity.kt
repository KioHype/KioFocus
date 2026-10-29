package com.kiohype.kiofocus

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.kiohype.kiofocus/accessibility"
    private var channel: MethodChannel? = null
    private var pendingBlock: HashMap<String, Any>? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        channel?.setMethodCallHandler { call, result ->
            when (call.method) {
                // O Flutter pergunta se chegou algum bloqueio enquanto ainda estava abrindo
                "getPending" -> {
                    result.success(pendingBlock)
                    pendingBlock = null
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent?) {
        if (intent?.action != "com.kiohype.kiofocus.CHECK_APP") return

        val packageName = intent.getStringExtra("package_name") ?: return
        val appName = intent.getStringExtra("app_name") ?: return

        val args = hashMapOf<String, Any>(
            "packageName" to packageName,
            "appName" to appName,
            "totalSeconds" to intent.getIntExtra("total_seconds", 180),
            "endTimeMs" to intent.getLongExtra("end_time_ms", 0L)
        )

        // Guarda caso o Flutter ainda não esteja pronto para receber
        pendingBlock = args

        channel?.invokeMethod("blockApp", args, object : MethodChannel.Result {
            override fun success(result: Any?) {
                pendingBlock = null
            }
            override fun error(code: String, message: String?, details: Any?) {}
            override fun notImplemented() {}
        })
    }
}