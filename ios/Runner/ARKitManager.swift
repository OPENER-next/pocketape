import UIKit
import ARKit

class ARKitManager: NSObject, ARSessionDelegate, ARSCNViewDelegate {
    private var arSession: ARSession!
    private var sessionPaused = false
    
    var trackingStateOK: Bool = false
    var lastFrame: ARFrame!
    var currentPosition: SIMD4<Float>!
    var distance:Float = 0.00;
    var start = 0;
    var initialPosition: simd_float4?
    
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
            if (start == 0) {
                start+=1
                initialPosition = lastFrame?.camera.transform.columns.3
            }
        }
    }
    
    @objc func startSession() {
        if sessionPaused {
            let configuration = ARWorldTrackingConfiguration()
            start = 0;
            arSession.run(configuration, options: [.resetTracking, .removeExistingAnchors])
            sessionPaused = false
        }
    }

    func calculateDistance(from: simd_float4, to: simd_float4) -> Float {
        let deltaX = to.x - from.x
        let deltaY = to.y - from.y
        let deltaZ = to.z - from.z
        
        return sqrt(deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ)
    }
        
    @objc func stopSession() {
        print("Stop")
        arSession.pause()
        sessionPaused = true
        guard let initialPosition = initialPosition, let currentPosition = currentPosition else {
            print("Positions are not set")
            return
        }
        
        let distance = calculateDistance(from: initialPosition, to: currentPosition)
        let initialPositionFormatted = String(format: "(%.2f, %.2f, %.2f)", initialPosition.x, initialPosition.y, initialPosition.z)
        let currentPositionFormatted = String(format: "(%.2f, %.2f, %.2f)", currentPosition.x, currentPosition.y, currentPosition.z)
        
        print("initialPosition: \(initialPositionFormatted) to currentPosition \(currentPositionFormatted) = \(String(format: "%.2f", distance))")
    
    }
    
    @objc func sendMeasure() {
        let vectorArray: [Float] = [currentPosition.x, currentPosition.y, currentPosition.z]
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.sendEventToFlutter(value: vectorArray)
        }
    }
}
