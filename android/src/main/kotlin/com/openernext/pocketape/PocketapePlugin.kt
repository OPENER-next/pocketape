package com.openernext.pocketape

import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.*

class PocketapePlugin : FlutterPlugin, StreamHandler {

    private lateinit var eventChannel: EventChannel
    private var arCoreManager: ARCoreManager? = null
    private var eventSink: EventSink? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        val messenger = flutterPluginBinding.binaryMessenger

        // The _DefaultBinaryMessenger does buffer 1 event, even when no listener is registered.
        // This causes the problem of a race condition when an event was or is added to the buffer while the stream is being canceled:
        // eventBuffer = [EventX];
        // myStream.cancel();
        // myStream.listen(...); -> returns EventX
        //
        // Therefore we disable buffering by setting it to 0
        // https://api.flutter.dev/flutter/dart-ui/ChannelBuffers-class.html
        MethodChannel(messenger, "ar_events").resizeChannelBuffer(0);

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
    }
}