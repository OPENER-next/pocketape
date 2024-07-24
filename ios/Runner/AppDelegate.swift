import UIKit
import SwiftUI
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    private var methodChannel: FlutterMethodChannel?
    private var arKitManager: ARKitManager?
    private var eventHandler: MyStreamHandler?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
        ) -> Bool {
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        arKitManager = ARKitManager()
            
        methodChannel = FlutterMethodChannel(name: "arkit_channel", binaryMessenger: controller.binaryMessenger)
        methodChannel?.setMethodCallHandler { [weak self] (call, result) in self?.handleMethodCall(call: call, result: result)}
        
        eventHandler = MyStreamHandler()
        let eventChannel = FlutterEventChannel(name: "arkit_events", binaryMessenger: controller.binaryMessenger)
        eventChannel.setStreamHandler(eventHandler)
            
            GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
        
    }

    private func handleMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
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
