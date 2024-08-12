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
        let eventChannel = FlutterEventChannel(name: "ar_events", binaryMessenger: registrar.messenger())
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