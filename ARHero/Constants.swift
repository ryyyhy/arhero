//
//  Constants.swift
//  ARHero
//
//  Created by 新井崚平 on 2018/02/23.
//  Copyright © 2018年 RyoheiArai. All rights reserved.
//

import Foundation


struct Constants {
    static let maxMeterorNums = 15
}


struct CollisionTypes : OptionSet {
    let rawValue: Int
    static let earthPhysics  = CollisionTypes(rawValue: 1 << 0)
    static let otherPhysics = CollisionTypes(rawValue: 1 << 1)
    static let bulletPhysics = CollisionTypes(rawValue: 1 << 2)
}

enum SoundEffect: String {
    case explosion = "explosion"
    case collision = "collision"
    case missile = "missile"
    case thruster = "thruster"
    case alert = "alert"
}
