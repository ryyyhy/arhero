//
//  AlertMessage.swift
//  ARHero
//
//  Created by 新井崚平 on 2018/02/25.
//  Copyright © 2018年 RyoheiArai. All rights reserved.
//

import Foundation
import UIKit

struct AlertMessage {
    static let help: (message: String, size: Int, color: UIColor) = (" 大量の隕石が地球に向かってくる！爆撃準備に入れ ", 16, .black)
    static let hopeless: (message: String, size: Int, color: UIColor) = (" このままでは地球が崩壊する！ ", 16, .yellow)
    static let die: (message: String, size: Int, color: UIColor) = (" まだ諦めてはならない！ ", 20, .red)
    
    static let savedEarth: (message: String, size: Int, color: UIColor) = (" よくやった！君は地球のヒーローだ！ ", 20, .white)
}


