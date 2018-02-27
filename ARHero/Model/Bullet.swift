//
//  Bullet.swift
//  ARViewer
//
//  Created by Faris Sbahi on 6/6/17.
//  Copyright © 2017 Faris Sbahi. All rights reserved.
//

import UIKit
import SceneKit

// Spheres that are shot at the "ships"
class Bullet: SCNNode {
    
    override init () {
        super.init()
        
        let sphere = SCNSphere(radius: 0.01)
        self.geometry = sphere
        let shape = SCNPhysicsShape(geometry: sphere, options: nil)
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        self.physicsBody?.isAffectedByGravity = false
        self.physicsBody?.categoryBitMask = CollisionTypes.bulletPhysics.rawValue
        self.physicsBody?.contactTestBitMask = CollisionTypes.otherPhysics.rawValue
        self.physicsBody?.collisionBitMask = CollisionTypes.otherPhysics.rawValue
        // add texture
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.darkGray
        self.geometry?.materials  = [material]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
