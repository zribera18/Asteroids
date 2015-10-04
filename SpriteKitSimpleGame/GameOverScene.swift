//
//  GameOverScene.swift
//  SpriteKitSimpleGame
//
//  Created by Zach Ribera on 1/16/15.
//  Copyright (c) 2015 Zetch. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
    
    var restart:SKSpriteNode
    var screenSize: CGSize = CGSizeMake(0, 0)

    
    init(size: CGSize, won:Bool) {
        screenSize = size
        restart = SKSpriteNode(imageNamed: "restart")

        super.init(size: size)

        

//        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        // 1
        backgroundColor = SKColor.whiteColor()
        
        // 2
        var message = won ? "You Won!" : "You Lose :["
        
        // 3
        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = message
        label.fontSize = 40
        label.fontColor = SKColor.blackColor()
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(label)
        
        restart = SKSpriteNode(imageNamed: "restart")
        restart.position = CGPointMake(screenWidth/2,screenHeight/2)
        addChild(restart)
        
        // 4
//        runAction(SKAction.sequence([
//            SKAction.waitForDuration(3.0),
//            SKAction.runBlock() {
//                // 5
//                let reveal = SKTransition.flipHorizontalWithDuration(0.5)
//                let scene = GameScene(size: size)
//                self.view?.presentScene(scene, transition:reveal)
//            }
//            ]))
        
        
        
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
//        // if I press a button, I want to add it to the pressed buttons list
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            
            if restart.containsPoint(location) {
                print("hi")
                    let reveal = SKTransition.flipHorizontalWithDuration(0.5)
                    let scene = GameScene(size: self.screenSize)
                    self.view?.presentScene(scene, transition:reveal)
            }
//
//            // for all 4 buttons
//            for button in [buttonDirUp, buttonDirLeft, buttonDirDown, buttonDirRight] {
//                // I check if they are already registered in the list
//                if button.hitboxContainsPoint(location) && find(pressedButtons, button) == nil {
//                    pressedButtons.append(button)
//                }
//            }
//        }
//        // then I check all the 4 buttons and set the transparency according if they are in the list or not
//        for button in [buttonDirUp, buttonDirLeft, buttonDirDown, buttonDirRight] {
//            if find(pressedButtons, button) == nil {
//                button.alpha = 0.2
//            }
//            else {
//                button.alpha = 0.8
//            }
        }
    }
    
    // 6
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
