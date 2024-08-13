import Flutter
import UIKit

public class PocketapePlugin: NSObject, FlutterPlugin, FlutterStreamHandler {

    static var shared: PocketapePlugin?
    private var arKitManager: ARKitManager?
    private var flutterEventSink: FlutterEventSink?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = PocketapePlugin()
        shared = instance
        instance.arKitManager = ARKitManager()
        let messenger = registrar.messenger()
        // The _DefaultBinaryMessenger does buffer 1 event, even when no listener is registered.
        // This causes the problem of a race condition when an event was or is added to the buffer while the stream is being canceled:
        // eventBuffer = [EventX];
        // myStream.cancel();
        // myStream.listen(...); -> returns EventX
        //
        // Therefore we disable buffering by setting it to 0
        // https://api.flutter.dev/flutter/dart-ui/ChannelBuffers-class.html
        let bufferChannel = FlutterMethodChannel(name: "ar_events", binaryMessenger: messenger)
        bufferChannel.resizeBuffer(0)

        let eventChannel = FlutterEventChannel(name: "ar_events", binaryMessenger: messenger)
        eventChannel.setStreamHandler(instance)
        instance.arKitManager?.setupSceneView()
    }
  
  func sendEventToFlutter(value: Any) {
    flutterEventSink?(value)
  }

  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    flutterEventSink = events
    arKitManager?.startSession()
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    arKitManager?.stopSession()
    flutterEventSink = nil
    return nil
  }
}