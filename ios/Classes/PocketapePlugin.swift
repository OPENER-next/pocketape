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

        let channel = FlutterMethodChannel(name: "ar_channel", binaryMessenger: registrar.messenger())
        let eventChannel = FlutterEventChannel(name: "ar_events", binaryMessenger: registrar.messenger())

        eventChannel.setStreamHandler(instance)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arKitManager = arKitManager else {
            result(FlutterError(code: "UNAVAILABLE", message: "ARKitManager not available", details: nil))
            return
        }

        switch call.method {
            case "startMeasure":
                arKitManager.startSession()
                result(nil)
            case "stopMeasure":
                flutterEventSink = nil
                flutterEventSink?(FlutterEndOfEventStream) 
                arKitManager.stopSession()
                result(nil)
            default:
            result(FlutterMethodNotImplemented)
        }
    }
  
  func sendEventToFlutter(value: Any) {
    flutterEventSink?(value)
  }

  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    flutterEventSink = events
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    flutterEventSink = nil
    return nil
  }
}