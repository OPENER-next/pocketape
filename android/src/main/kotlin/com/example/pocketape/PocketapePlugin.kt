package com.example.pocketape

import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.*
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class PocketapePlugin : FlutterPlugin, MethodCallHandler, StreamHandler {

    private lateinit var channel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private var arCoreManager: ARCoreManager? = null
    private var eventSink: EventSink? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        val messenger = flutterPluginBinding.binaryMessenger
        channel = MethodChannel(messenger, "ar_channel")
        eventChannel = EventChannel(messenger, "ar_events")

        channel.setMethodCallHandler(this)

        arCoreManager = ARCoreManager(flutterPluginBinding.applicationContext, this)
        eventChannel.setStreamHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        val arCoreManager = arCoreManager ?: run {
            result.error("UNAVAILABLE", "ARCoreManager not available", null)
            return
        }

        when (call.method) {
            "startMeasure" -> {
                arCoreManager.startSession()
                result.success(null)
            }
            "stopMeasure" -> {
                eventSink = null
                eventSink?.endOfStream()
                arCoreManager.stopSession()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding)  {
        channel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        arCoreManager?.onDestroy()
    }

    fun sendEventToFlutter(value: Any) {
        eventSink?.success(value)
    }

    override fun onListen(arguments: Any?, events: EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }
}