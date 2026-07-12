package com.mohammed_fawaz_cp.render_kit_flutter

import android.content.Context
import android.content.Intent
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.Serializable

class RenderKitFlutterPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    companion object {
        private var channel: MethodChannel? = null

        fun emit(actionName: String, args: Map<String, Any>) {
            channel?.invokeMethod("emitEvent", mapOf("name" to actionName, "args" to args))
        }
    }

    private lateinit var context: Context

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "render_kit_flutter")
        channel?.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "navigateTo" -> {
                val screenName = call.argument<String>("screen") ?: ""
                val state = call.argument<Map<String, Any>>("state") ?: emptyMap()
                
                val intent = Intent(context, RenderKitActivity::class.java).apply {
                    putExtra("screen_name", screenName)
                    putExtra("state", HashMap(state))
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                context.startActivity(intent)
                result.success(null)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        channel = null
    }
}
