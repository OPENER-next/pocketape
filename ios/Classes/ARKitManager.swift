import UIKit
import ARKit

class ARKitManager: NSObject, ARSessionDelegate, ARSCNViewDelegate {
    private var arSession: ARSession!
    private var sessionPaused = false
    
    var trackingStateOK: Bool = false
    var lastFrame: ARFrame!
    var currentPosition: SIMD4<Float>!
    
    override init() {
        super.init()
        setupSceneView()
    }

    
    func setupSceneView() {
        arSession = ARSession()
        let configuration = ARWorldTrackingConfiguration()
        arSession.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        arSession.delegate = self
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        if let frame = session.currentFrame {
            currentPosition = frame.camera.transform.columns.3
            sendMeasure()
        }
    }
    
    @objc func startSession() {
        if sessionPaused {
            let configuration = ARWorldTrackingConfiguration()
            arSession.run(configuration, options: [.resetTracking, .removeExistingAnchors])
            sessionPaused = false
        }
    }
    
    @objc func stopSession() {
        arSession.pause()
        sessionPaused = true
    }
    
    @objc func sendMeasure() {
        let vectorArray: [Float] = [currentPosition.x, currentPosition.y, currentPosition.z]
        guard let pluginInstance = PocketapePlugin.shared else {
            print("PocketapePlugin is not available")
            return
        }
        pluginInstance.sendEventToFlutter(value: vectorArray)
    }
}
