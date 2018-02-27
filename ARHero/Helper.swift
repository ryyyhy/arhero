//
//  Helper.swift
//  ARHero
//
//  Created by 新井崚平 on 2018/02/23.
//  Copyright © 2018年 RyoheiArai. All rights reserved.
//

import Foundation


func floatBetween(_ first: Float,  and second: Float) -> Float {
    return (Float(arc4random()) / Float(UInt32.max)) * (first - second) + second
}
