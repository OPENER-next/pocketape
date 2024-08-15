import UIKit
import ARKit

class ARKitManager: NSObject, ARSessionDelegate, ARSCNViewDelegate {
    private var arSession: ARSession!
    private var sessionPaused = true
    
    @objc func setupSceneView() {
        arSession = ARSession()
        arSession.delegate = self
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        if let frame = session.currentFrame {
            sendMeasure(currentPosition: frame.camera.transform.columns.3)
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
    
    func sendMeasure(currentPosition: SIMD4<Float>) {
        let vectorArray: [Float] = [currentPosition.x, currentPosition.y, currentPosition.z]
        guard let pluginInstance = PocketapePlugin.shared else {
            print("PocketapePlugin is not available")
            return
        }
        pluginInstance.sendEventToFlutter(value: vectorArray)
    } 
}
