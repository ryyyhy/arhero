//
//  OnBoardShipViewController.swift
//  ARHero
//
//  Created by 新井崚平 on 2018/02/26.
//  Copyright © 2018年 RyoheiArai. All rights reserved.
//

import UIKit
import ARKit

class OnBoardShipViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let scene = SCNScene()
        scene.rootNode.name = "RootNode"
        sceneView.delegate = self
        
        prepareShipInARSpace()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureSession()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    
    // MARK: - Game Functionality
    func configureSession() {
        if ARWorldTrackingConfiguration.isSupported {
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = ARWorldTrackingConfiguration.PlaneDetection.horizontal
            sceneView.session.run(configuration)
        } else {
            let configuration = AROrientationTrackingConfiguration()
            sceneView.session.run(configuration)
        }
    }
    
 
    func prepareShipInARSpace() {
        if let node = SCNScene(named: "art.scnassets/ship.scn") {
            if let ship = node.rootNode.childNode(withName: "ship", recursively: false) {
                ship.name = "ship"
                ship.position = SCNVector3(0,0, -1.2)
                ship.scale.x = 2.5
                ship.scale.y = 2.0
                self.sceneView.scene.rootNode.addChildNode(ship)
            }
        }
    }
    
    
    func boardOnShip() {
        let alert = UIAlertController(title: "宇宙に行く", message: "隕石を壊して地球を救え！", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: { ( _ ) in
            let sb = UIStoryboard(name: "Main", bundle: nil)
            if let view = sb.instantiateViewController(withIdentifier: "game") as? ViewController {
                self.present(view, animated: true, completion: nil)
            }
        })
        let no = UIAlertAction(title: "No", style: .default, handler: nil)
        alert.addAction(ok)
        alert.addAction(no)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func getUserVector() -> (SCNVector3, SCNVector3) { // (direction, position)
        if let frame = self.sceneView.session.currentFrame {
            let mat = SCNMatrix4(frame.camera.transform)
            // 4x4 transform matrix describing camera in world space
            let dir = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33)
            // orientation of camera in world space
            let pos = SCNVector3(mat.m41, mat.m42, mat.m43)
            // location of camera in world space
            return (dir, pos)
        }
        return (SCNVector3(0, 0, -1), SCNVector3(0, 0, -0.2))
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        print("Session failed with error: \(error.localizedDescription)")
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let camera = self.getUserVector().1
        if let touch = touches.first?.location(in: self.sceneView) {
            let hitResults = self.sceneView.hitTest(touch, options: [:])
            guard !hitResults.isEmpty else { return }
            guard let node = hitResults.first?.node else { return }
            let location = camera.distance(from: node.position)
            print("LOCATION", location)
            if node.name == "ship" {
                self.boardOnShip()
                print(location)
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        
        let camera = self.getUserVector().1
        let center = sceneView.center
        let hitResults = self.sceneView.hitTest(center, options: [:])
        guard !hitResults.isEmpty else { return }
        guard let node = hitResults.first?.node else { return }
        let location = camera.distance(from: node.position)
        print("LOCATION", location)
        if location <= 0.1 {
            self.boardOnShip()
            print(location)
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
