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

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Object Detection
        configuration.detectionObjects = ARReferenceObject.referenceObjects(inGroupNamed: "TeddyBearObjects", bundle: Bundle.main)!

        // Run the view's session
        sceneView.session.run(configuration)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    

    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()

        if let objectAnchor = anchor as? ARObjectAnchor {
//            let plane = SCNPlane(width: CGFloat(objectAnchor.referenceObject.extent.x * 0.8), height: CGFloat(objectAnchor.referenceObject.extent.y * 0.5))
//
//            plane.cornerRadius = plane.width / 8
//
//            let spriteKitScene = SKScene(fileNamed: "ProductInfo")
//
//            plane.firstMaterial?.diffuse.contents = spriteKitScene
//            plane.firstMaterial?.isDoubleSided = true
//            plane.firstMaterial?.diffuse.contentsTransform = SCNMatrix4Translate(SCNMatrix4MakeScale(1, -1, 1), 0, 1, 0)
//
//            let planeNode = SCNNode(geometry: plane)
//            planeNode.position = SCNVector3Make(objectAnchor.referenceObject.center.x, objectAnchor.referenceObject.center.y, objectAnchor.referenceObject.center.z)
            
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
