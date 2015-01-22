//
//  ControllerButton.swift
//  SpriteKitSimpleGame
//
//  Created by Zach Ribera on 1/18/15.
//  Copyright (c) 2015 Zetch. All rights reserved.
//

import SpriteKit

class ControllerButton: SKSpriteNode {
    var hitbox: (CGPoint -> Bool)?
    
    //    func hitboxContainsPoint(location: CGPoint) -> Bool {
    //        return containsPoint(location)
    //    }
    
    convenience init(imageNamed: String, position: CGPoint) {
        self.init(imageNamed: imageNamed)
        self.texture?.filteringMode = .Nearest
        self.setScale(2.0)
        self.alpha = 0.2
        self.position = position
        
        hitbox = { (location: CGPoint) -> Bool in
            return self.containsPoint(location)
        }
    }
    
    func hitboxContainsPoint(location: CGPoint) -> Bool {
        return hitbox!(location)
    }
}


