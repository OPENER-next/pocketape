import Flutter
import UIKit

public class PocketapePlugin: NSObject, FlutterPlugin {

    static var shared: PocketapePlugin?
    private var arKitManager: ARKitManager?
    private var eventHandler: MyStreamHandler?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = PocketapePlugin()
        shared = instance
        instance.arKitManager = ARKitManager()

        let channel = FlutterMethodChannel(name: "ar_channel", binaryMessenger: registrar.messenger())
        let eventChannel = FlutterEventChannel(name: "ar_events", binaryMessenger: registrar.messenger())

        instance.eventHandler = MyStreamHandler()
        eventChannel.setStreamHandler(instance.eventHandler)
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
                arKitManager.stopSession()
                result(nil)
            default:
            result(FlutterMethodNotImplemented)
        }
    }
  
  func sendEventToFlutter(value: Any) {
    eventHandler?.sendEvent(event: value)
  }

}

class MyStreamHandler: NSObject, FlutterStreamHandler {
    
    func sendEvent(event: Any) {
        flutterEventSink?(event)
    }
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        flutterEventSink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        flutterEventSink = nil
        return nil
    }
    
    private var flutterEventSink: FlutterEventSink?
}
