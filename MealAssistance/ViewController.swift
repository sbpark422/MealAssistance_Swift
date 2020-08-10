//
//  ViewController.swift
//  MealAssistance
//
//  Created by 박수빈 on 2020/08/10.
//  Copyright © 2020 Soo Bin Park (Soobin Park). All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import RealityKit
import Vision
import AVFoundation

typealias VisionVNRecognizedPointKey = Vision.VNRecognizedPointKey

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    private let videoDataOutputQueue = DispatchQueue(label: "CameraFeedDataOutput", qos: .userInteractive)
    private var gestureProcessor = HandGestureProcessor()
    private var handPoseRequest = VNDetectHumanHandPoseRequest()
    private var lastObservationTimestamp = Date()
    
    var redBoxThumb = UIView()
    var redBoxIndex = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the view's delegate
        sceneView.delegate = self
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        // Create a new scene
        //let scene = SCNScene(named: "art.scnassets/ship.scn")!
        let scene = SCNScene(named: "art.scnassets/GameScene.scn")!
        // Set the scene to the view
        sceneView.scene = scene
        
        // This sample app detects one hand only.
        handPoseRequest.maximumHandCount = 1
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Object Detection
        configuration.detectionObjects = ARReferenceObject.referenceObjects(inGroupNamed: "TeddyBearObjects", bundle: Bundle.main)!

        // Run the view's session
        sceneView.session.run(configuration)
        
        // Begin Loop to Update Hand
        loopHandUpdate()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - ARSCNViewDelegate
    
    
    func loopHandUpdate() {

        videoDataOutputQueue.async {
            // 1. Run Update.
            self.updateHand()
            // 2. Loop this function.
            self.loopHandUpdate()
        }
        
    }

    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        


        if let objectAnchor = anchor as? ARObjectAnchor {
            
            let sphere = SCNNode(geometry: SCNSphere(radius: 0.005))
            sphere.geometry?.firstMaterial?.diffuse.contents = UIColor.yellow
            sphere.position = SCNVector3Make(objectAnchor.referenceObject.center.x, objectAnchor.referenceObject.center.y, objectAnchor.referenceObject.center.z)

            print("powerrrrrr")

            node.addChildNode(sphere)

        }
        
        return node
    }
    
//    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
//        guard let cameraPos = sceneView.pointOfView?.simdWorldPosition else { return }
//        let sphere = SCNNode(geometry: SCNSphere(radius: 0.005))
//        sphere.geometry?.firstMaterial?.diffuse.contents = UIColor.yellow
//
//        if let objectAnchor = anchor as? ARObjectAnchor {
//
//        }
//
//    }

    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}


extension ViewController {
    func updateHand() {
        guard let pixbuff = sceneView.session.currentFrame?.capturedImage else { return }
        
        var thumbTip: CGPoint?
        var indexTip: CGPoint?
        
        defer {
            DispatchQueue.main.sync {
                self.processPoints(thumbTip: thumbTip, indexTip: indexTip)
            }
        }

        let handler = VNImageRequestHandler(cvPixelBuffer: pixbuff, options: [:])
        do {
            // Perform VNDetectHumanHandPoseRequest
            try handler.perform([handPoseRequest])
            // Continue only when a hand was detected in the frame.
            // Since we set the maximumHandCount property of the request to 1, there will be at most one observation.
            guard let observation = handPoseRequest.results?.first as? VNRecognizedPointsObservation else {
                return
            }
            // Get points for thumb and index finger.
            let thumbPoints: [VisionVNRecognizedPointKey : VNRecognizedPoint] = try observation.recognizedPoints(forGroupKey: .handLandmarkRegionKeyThumb)
            let indexFingerPoints: [VisionVNRecognizedPointKey : VNRecognizedPoint] = try observation.recognizedPoints(forGroupKey: .handLandmarkRegionKeyIndexFinger)
//            // Look for tip points.
            guard let thumbTipPoint = thumbPoints[VisionVNRecognizedPointKey(string: "VNHLKTTIP")], let indexTipPoint = indexFingerPoints[VisionVNRecognizedPointKey(string: "VNHLKITIP")] else {
                return
            }
            // Ignore low confidence points.
            guard thumbTipPoint.confidence > 0.3 && indexTipPoint.confidence > 0.3 else {
                return
            }
            // Convert points from Vision coordinates to AVFoundation coordinates.
            thumbTip = CGPoint(x: thumbTipPoint.location.x, y: thumbTipPoint.location.y)
            indexTip = CGPoint(x: indexTipPoint.location.x, y: indexTipPoint.location.y)
            
            
        } catch {
//            cameraFeedSession?.stopRunning()
//            let error = AppError.visionError(error: error)
//            DispatchQueue.main.async {
//                error.displayInViewController(self)
        }
    }
    
    func processPoints(thumbTip: CGPoint?, indexTip: CGPoint?) {
        // Check that we have both points.
        guard let thumbPoint = thumbTip, let indexPoint = indexTip else {
            // If there were no observations for more than 2 seconds reset gesture processor.
            if Date().timeIntervalSince(lastObservationTimestamp) > 2 {
                gestureProcessor.reset()
            }
            //cameraView.showPoints([], color: .clear)
            return
        }
        
        redBoxThumb.removeFromSuperview()
        redBoxIndex.removeFromSuperview()
        
        redBoxThumb = UIView(frame: CGRect(x: thumbPoint.y * sceneView.frame.width, y: thumbPoint.x * sceneView.frame.height, width: 5, height: 5))
        redBoxThumb.backgroundColor = .red
        sceneView.addSubview(redBoxThumb)
        
        redBoxIndex = UIView(frame: CGRect(x: indexPoint.y * sceneView.frame.width, y: indexPoint.x * sceneView.frame.height, width: 5, height: 5))
        
        redBoxIndex.backgroundColor = .red
        sceneView.addSubview(redBoxIndex)
        
        //currentBallCoordinate = sceneView.projectPoint(motherBallNode.position)
        
        let indexX = indexPoint.y * sceneView.frame.width
        let indexY = indexPoint.x * sceneView.frame.height
//        let deltaX = CGFloat(currentBallCoordinate.x) - indexX
//        let deltaY = CGFloat(currentBallCoordinate.y) - indexY
//
//        print(currentBallCoordinate)
        print("\(indexX) \(indexY)")
        print("---")
        
//        if abs(deltaX) < 80.0 && abs(deltaY) < 80.0 {
//            print("touch!!!")
//            let direction = SCNVector3(deltaX, deltaY, 0).normalized
//
//            guard let currentTranform = sceneView.session.currentFrame?.camera.transform else { return }
//
//            let directionShit = SIMD4<Float>.init(x: direction.x, y: direction.y, z: 0, w: 0)
//            let directionTransformed = currentTranform * directionShit
            
//            motherBallNode.runAction(SCNAction.moveBy(x: CGFloat(directionTransformed.x * 0.1),
//                                                      y: CGFloat(directionTransformed.y * 0.1),
//                                                      z: CGFloat(directionTransformed.z * 0.1),
//                                                      duration: 0.1))
//            currentBallCoordinate = SCNVector3(currentBallCoordinate.x + directionTransformed.x * 0.1,
//                                               currentBallCoordinate.y + directionTransformed.y * 0.1,
//                                               0)
//        }
    }
}
