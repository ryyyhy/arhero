//
//  Extension.swift
//  ARHero
//
//  Created by 新井崚平 on 2018/02/23.
//  Copyright © 2018年 RyoheiArai. All rights reserved.
//

import Foundation
import ARKit

extension Array {
    
    func random() -> Int {
        return self[0] as! Int
    }
}


extension Int {
    
    var degreesToRadians: Double {
        return Double(self) * .pi / 180
    }
    
}

extension SCNVector3 {
    
    func distance(from vector: SCNVector3) -> Float {
        let x = self.x - vector.x
        let y = self.y - vector.y
        let z = self.z - vector.z
        return sqrtf((x * x) + (y + y) + (z + z))
    }
}



extension SCNNode {
    
    func moveUpDown() {
        let moveUp = SCNAction.moveBy(x: 0, y: 1, z: 0, duration: 10)
        moveUp.timingMode = .easeInEaseOut
        let moveDown = SCNAction.moveBy(x: 0, y: -1, z: 0, duration: 10)
        moveDown.timingMode = .easeInEaseOut
        let moveSequence = SCNAction.sequence([moveUp, moveDown])
        let moveLoop = SCNAction.repeatForever(moveSequence)
        self.runAction(moveLoop)
    }
    
}
extension UIView {
    
    func blink() {
        UIView.animate(withDuration: 0.5, //Time duration you want,
            delay: 0.0,
            options: [.curveEaseInOut, .autoreverse, .repeat],
            animations: { [weak self] in self?.alpha = 0.0 },
            completion: { [weak self] _ in self?.alpha = 1.0 })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: { [weak self] in
            self?.layer.removeAllAnimations()
        })
    }
    
    // OUTPUT 2
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    func fadeIn(_ duration: TimeInterval = 1.0, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0
        }, completion: completion)  }
    
    func fadeOut(_ duration: TimeInterval = 1.0, delay: TimeInterval = 0.0, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.alpha = 0.0
        }, completion: completion)
    }
}
