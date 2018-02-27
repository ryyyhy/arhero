//
//  ProgressBar.swift
//  ARHero
//
//  Created by 新井崚平 on 2018/02/25.
//  Copyright © 2018年 RyoheiArai. All rights reserved.
//

import Foundation
import SpriteKit
import SceneKit
import ARKit

class ProgressBar : SKNode {
    
    var background: SKSpriteNode?
    var bar: SKSpriteNode?
    var progress: CGFloat = 0
    
    enum StateColor {
        case notHurt
        case kindaDamaged
        case seriouslyDamaged
    }
    
    var stateColor : StateColor = .notHurt
    
    var currentProgress : CGFloat {
        get {
            return progress
        }
        set {
            let value = max(min(newValue, 1.0), 0.0)
            if let bar = bar {
                bar.xScale = value
                progress = value
            }
        }
    }
    
    func reset() {
        currentProgress = 1.0
        stateColor = .notHurt
        updateCurrentEarthHP()
    }
    
    func updateCurrentEarthHP() {
        switch stateColor {
        case .notHurt:
            bar?.color = #colorLiteral(red: 0.476498127, green: 0.6231735945, blue: 1, alpha: 1)
        case .kindaDamaged:
            bar?.color = .yellow
        case .seriouslyDamaged:
            bar?.color = .red
        }
    }
    
    convenience init(color: SKColor, size: CGSize) {
        self.init()
        background = SKSpriteNode(color: SKColor.black, size: size)
        bar = SKSpriteNode(color: color, size: size)
        if let bar = bar, let bg = background {
            bar.xScale = 0.0
            bar.zPosition = 1.0
            bar.position = CGPoint(x: -size.width/2, y: 0)
            bar.anchorPoint = CGPoint(x: 0.0, y: 0.5)
            addChild(bg)
            addChild(bar)
        }
    }
    
}

