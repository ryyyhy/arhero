//
//  SKOverlay.swift
//  ARHero
//
//  Created by 新井崚平 on 2018/02/25.
//  Copyright © 2018年 RyoheiArai. All rights reserved.
//

import Foundation
import SpriteKit

class SKOverlay : SKScene {
    
    var progressBar: ProgressBar!
    
    override public init(size: CGSize) {
        super.init(size: size)
        
        self.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        self.scaleMode = .resizeFill
        
        progressBar = ProgressBar(color: #colorLiteral(red: 0.4743471742, green: 0.6504351497, blue: 1, alpha: 1), size: CGSize(width: size.width, height: 20))
        self.addChild(progressBar)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
