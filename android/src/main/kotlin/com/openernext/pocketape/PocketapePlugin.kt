package com.openernext.pocketape

import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.*

class PocketapePlugin : FlutterPlugin, StreamHandler {

    private lateinit var eventChannel: EventChannel
    private var arCoreManager: ARCoreManager? = null
    private var eventSink: EventSink? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        val messenger = flutterPluginBinding.binaryMessenger
        eventChannel = EventChannel(messenger, "ar_events")
        arCoreManager = ARCoreManager(flutterPluginBinding.applicationContext, this)
        eventChannel.setStreamHandler(this)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding)  {
        eventChannel.setStreamHandler(null)
        arCoreManager?.stopSession()
    }

    fun sendEventToFlutter(value: Any) {
        eventSink?.success(value)
    }

    override fun onListen(arguments: Any?, events: EventSink?) {
        eventSink = events
        arCoreManager?.startSession()
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
        arCoreManager?.stopSession()
        eventSink?.endOfStream()
    }
}