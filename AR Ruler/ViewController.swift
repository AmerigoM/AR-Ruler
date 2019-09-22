//
//  ViewController.swift
//  AR Ruler
//
//  Created by Amerigo Mancino on 22/09/2019.
//  Copyright © 2019 Amerigo Mancino. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    // array to keep track of all the dots in the scene
    var dotNodes = [SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // enable debug option
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNVIEW DELEGATE METHODS
    
    
    // a touch was detected on screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // grab the location of the 2D tap...
        if let touchLocation = touches.first?.location(in: sceneView) {
            //  ...and turn it into a 3D location of a continuous surface
            let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint)
            
            if let hitResult = hitTestResults.first {
                addDot(at: hitResult)
            }
            
        }
    }
    
    
    // MARK: - HELPER METHODS
    
    func addDot(at hitResult: ARHitTestResult) {
        // create a sphere dot 3D object with a material
        let dotGeometry = SCNSphere(radius: 0.005)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        dotGeometry.materials = [material]
        
        // create a node and attach to the geometry
        let dotNode = SCNNode(geometry: dotGeometry)
        
        // specify the node position in the scene
        dotNode.position = SCNVector3(
            hitResult.worldTransform.columns.3.x,
            hitResult.worldTransform.columns.3.y,
            hitResult.worldTransform.columns.3.z
        )
        
        // add it to the scene
        sceneView.scene.rootNode.addChildNode(dotNode)
        
        // append new node to the array
        dotNodes.append(dotNode)
        
        if dotNodes.count >= 2 {
            calculate()
        }
    }
    
    // calculate the distance between two points
    func calculate() {
        let start = dotNodes[0]
        let end = dotNodes[1]
        
        // distance = √ ((x2-x1)^2 + (y2-y1)^2 + (z2-z1)^2)
        let distance = sqrt(
            pow(end.position.x - start.position.x, 2) +
            pow(end.position.y - start.position.y, 2) +
            pow(end.position.z - start.position.z, 2)
        )
        
        // update the 3D text
        updateText(text: "\(distance)", atPosition: end.position)
        
    }
    
    // update the 3D text on the scene
    func updateText(text: String, atPosition position: SCNVector3) {
        // create a text geometry
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        
        let textNode = SCNNode(geometry: textGeometry)
        textNode.position = SCNVector3(position.x, position.y + 0.01, position.z)
        textNode.scale = SCNVector3(0.01, 0.01, 0.01)
        
        sceneView.scene.rootNode.addChildNode(textNode)
        
    }

}
