//
//  GameScene.swift
//  SpriteKitSimpleGame
//
//  Created by Zach Ribera on 1/16/15.
//  Copyright (c) 2015 Zetch. All rights reserved.
//

import SpriteKit
//import AVFoundation
//
//var backgroundMusicPlayer: AVAudioPlayer!
//
//func playBackgroundMusic(filename: String) {
//    let url = NSBundle.mainBundle().URLForResource(
//        filename, withExtension: nil)
//    if (url == nil) {
//        println("Could not find file: \(filename)")
//        return
//    }
//    
//    var error: NSError? = nil
//    backgroundMusicPlayer =
//        AVAudioPlayer(contentsOfURL: url, error: &error)
//    if backgroundMusicPlayer == nil {
//        println("Could not create audio player: \(error!)")
//        return
//    }
//    
//    backgroundMusicPlayer.numberOfLoops = -1
//    backgroundMusicPlayer.prepareToPlay()
//    backgroundMusicPlayer.play()
//}

struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Monster   : UInt32 = 0b1       // 1
    static let Projectile: UInt32 = 0b10      // 2
    static let Player    : UInt32 = 0b100
}




func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CGFloat) -> CGFloat {
    return CGFloat(sqrtf(Float(a)))
    }
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let buttonDirUp = ControllerButton(imageNamed: "button_dir_up", position: CGPoint(x: 100, y: 150) )
    let buttonDirDown = ControllerButton(imageNamed: "button_dir_down", position: CGPoint(x: 100, y: 50))
    let buttonDirLeft = ControllerButton(imageNamed: "button_dir_left", position: CGPoint(x: 50, y: 100))
    let buttonDirRight = ControllerButton(imageNamed: "button_dir_right", position:CGPoint(x: 150, y: 100))
    var pressedButtons = [ControllerButton]()
    
    let background1 = SKSpriteNode(imageNamed: "starsOrig")
    let background2 = SKSpriteNode(imageNamed: "starsOrig")
    
    let player = SKSpriteNode(imageNamed: "Spaceship")
    
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    
    var monstersDestroyed = 0
    
    let kScoreHudName = "scoreHud"
    let kHealthHudName = "healthHud"
    
    var score = 0
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
//        playBackgroundMusic("background-music-aac.caf")
        
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        backgroundColor = SKColor.blueColor()
        player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
        player.setScale(0.15)
        
        
        player.physicsBody = SKPhysicsBody(rectangleOfSize: player.size) // 1
        player.physicsBody?.dynamic = true
        player.physicsBody?.categoryBitMask = PhysicsCategory.Player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
        player.physicsBody?.collisionBitMask = PhysicsCategory.None
        player.physicsBody?.usesPreciseCollisionDetection = true
        
        let constraint = SKConstraint.zRotation(SKRange(constantValue: CGFloat(-M_PI/2)))
        player.constraints = [constraint]
        
        
        addChild(player)
        setupHud()
        
        
        self.addChild(buttonDirUp)
        self.addChild(buttonDirLeft)
        self.addChild(buttonDirDown)
        self.addChild(buttonDirRight)
        
        /* background #1 */
        background1.anchorPoint = CGPointZero
        background1.position = CGPointMake(0, 0)
        background1.zPosition = -15
        background1.size = CGSizeMake(screenWidth,screenHeight)
        self.addChild(background1)
        
        /* background #2 */
        background2.anchorPoint = CGPointZero
        background2.position = CGPointMake(background1.size.width - 1, 0)
        background2.zPosition = -15
        background2.size = CGSizeMake(screenWidth,screenHeight)
        self.addChild(background2)
        
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        
//        physicsBody = SKPhysicsBody(edgeLoopFromRect: frame)
        
        // l = 94.0 is ambiguous because 94.0 can be both a Double and a CGFloat
        // So we need to state clearly that we want to assign a CGFloat
        // l is the radius of the circle
        let l = 94.0 as CGFloat
        let x0 = 90.0 as CGFloat
        let y0 = 100.0 as CGFloat
        // tangent of 60 degrees angle
        let angle = CGFloat(tan(M_PI / 3))
        
        // hitboxes are within a range of 0~4.0 pixels and angles of -60~60 degrees
        buttonDirUp.hitbox = {
            (location: CGPoint) -> Bool in
            return location.y - y0 > 0 && (abs(location.x - x0) <= abs(location.y - y0) * angle) && (pow((location.x - x0),2) + pow((location.y - y0),2) <= pow(l,2))
        }
        buttonDirLeft.hitbox = {
            (location: CGPoint) -> Bool in
            return location.x - x0 < 0 && (abs(location.x - x0) * angle >= abs(location.y - y0)) && (pow((location.x - x0),2) + pow((location.y - y0),2) <= pow(l,2))
        }
        buttonDirDown.hitbox = {
            (location: CGPoint) -> Bool in
            return location.y - y0 < 0 && (abs(location.x - x0) <= abs(location.y - y0) * angle) && (pow((location.x - x0),2) + pow((location.y - y0),2) <= pow(l,2))
        }
        buttonDirRight.hitbox = {
            (location: CGPoint) -> Bool in
            return location.x - x0 > 0 && (abs(location.x - x0) * angle >= abs(location.y - y0)) && (pow((location.x - x0),2) + pow((location.y - y0),2) <= pow(l,2))
        }
        
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.runBlock(addMonster),
                SKAction.waitForDuration(0.75)
                ])
            ))
        
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(#min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    func addMonster() {
        
        // Create sprite
//        var monster = SKSpriteNode(imageNamed: "monster")
        
        let x = Int(random(min: 0,max: 3))

        var monster:SKSpriteNode
        switch x {
        case 0:
            monster = SKSpriteNode(imageNamed: "asteroid1")
//            break
        case 1:
            monster = SKSpriteNode(imageNamed: "asteroids2")
//            break
        default:
            monster = SKSpriteNode(imageNamed: "asteroids3")
//            break
        }
        monster.size = CGSizeMake(40,40)
//        monster.physicsBody = SKPhysicsBody(rectangleOfSize: monster.size) // 1
        monster.physicsBody = SKPhysicsBody(circleOfRadius: monster.size.height/2)
        monster.physicsBody?.dynamic = true // 2
        monster.physicsBody?.categoryBitMask = PhysicsCategory.Monster // 3
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile // 4
        monster.physicsBody?.collisionBitMask = PhysicsCategory.None // 5
        monster.physicsBody?.restitution = 1.0 // 5
        monster.physicsBody?.friction = 0.0 // 5
        monster.physicsBody?.usesPreciseCollisionDetection = true
        
    
        // Determine where to spawn the monster along the Y axis
        let actualY = random(min: monster.size.height/2, max: size.height - monster.size.height/2)
        
        // Position the monster slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        monster.position = CGPoint(x: size.width + monster.size.width/2, y: actualY)
        
        // Add the monster to the scene
        addChild(monster)
        
        // Determine speed of the monster
        let actualDuration = random(min: CGFloat(2.0), max: CGFloat(8.0))
        
        // Create the actions
        let actionMove = SKAction.moveTo(CGPoint(x: -monster.size.width/2, y: actualY), duration: NSTimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
                monster.runAction(SKAction.sequence([actionMove, actionMoveDone]))
//        let loseAction = SKAction.runBlock() {
//            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
//            let gameOverScene = GameOverScene(size: self.size, won: false)
//            self.view?.presentScene(gameOverScene, transition: reveal)
//        }
//        monster.runAction(SKAction.sequence([actionMove, loseAction, actionMoveDone]))
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        touchesEndedOrCancelled(touches, withEvent: event)
//        runAction(SKAction.playSoundFileNamed("pew-pew-lei.caf", waitForCompletion: false))
        
        // 1 - Choose one of the touches to work with
        let touch = touches.first as! UITouch
        let touchLocation = touch.locationInNode(self)
        
        // 2 - Set up initial location of projectile
        let projectile = SKSpriteNode(imageNamed: "laser")
        projectile.size = CGSizeMake(40,5)
        projectile.position = player.position
        
        var deltaY = touchLocation.y - player.position.y
        var deltaX = touchLocation.x - player.position.x
        
        var angle = atan2(deltaY,deltaX)
        
//        ocation.x - player.position.x
        
//        angle = angle * (180/Math.PI);
        
        let constraint = SKConstraint.zRotation(SKRange(constantValue: CGFloat(angle)))
        projectile.constraints = [constraint]
        
        projectile.physicsBody = SKPhysicsBody(rectangleOfSize: projectile.size)
        projectile.physicsBody?.dynamic = true
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
        projectile.physicsBody?.usesPreciseCollisionDetection = true
        
        // 3 - Determine offset of location to projectile
        let offset = touchLocation - projectile.position
        
        // 4 - Bail out if you are shooting down or backwards
        if (offset.x < 0) { return }
        
        // 5 - OK to add now - you've double checked position
        addChild(projectile)
        
        // 6 - Get the direction of where to shoot
        let direction = offset.normalized()
        
        // 7 - Make it shoot far enough to be guaranteed off screen
        let shootAmount = direction * 1000
        
        // 8 - Add the shoot amount to the current position
        let realDest = shootAmount + projectile.position
        
        // 9 - Create the actions
        let actionMove = SKAction.moveTo(realDest, duration: 2.0)
        let actionMoveDone = SKAction.removeFromParent()
        projectile.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        
    }
    
    func projectileDidCollideWithMonster(projectile:SKSpriteNode, monster:SKSpriteNode) {
        let actionTexture = SKAction.setTexture(SKTexture(imageNamed: "explosion!"))
        let actionMove = SKAction.scaleTo(2.5, duration: 0.75)
        let actionMoveDone = SKAction.removeFromParent()
        let actionFadeOut = SKAction.fadeOutWithDuration(NSTimeInterval(0.25))
        
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.None
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.None
        
        projectile.runAction(
            SKAction.sequence([actionTexture,
                actionMove,
                actionFadeOut,
                actionMoveDone
                ]))
        println("Hit")
//        projectile.texture = SKTexture(imageNamed: "explosion!")
//        projectile.removeFromParent()
        monster.removeFromParent()
        
//        runAction(
//            SKAction.sequence([
//                actionMove,
//                actionMoveDone
//                ]))
        
        monstersDestroyed++
        if (monstersDestroyed > 10) {
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            let gameOverScene = GameOverScene(size: self.size, won: true)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
    }
    
    func shipDidCollideWithMonster(projectile:SKSpriteNode, monster:SKSpriteNode) {
        println("swag Hit")
        
        let actionTexture = SKAction.setTexture(SKTexture(imageNamed: "explosion!"))
        let actionMove = SKAction.scaleTo(2.5, duration: 0.75)
        let actionMoveDone = SKAction.removeFromParent()
        let actionFadeOut = SKAction.fadeOutWithDuration(NSTimeInterval(0.25))
        let actionWait = SKAction.waitForDuration(NSTimeInterval(4.0))
        let actionFadeIn = SKAction.fadeInWithDuration(NSTimeInterval(0.25))
        
        monster.runAction(
            SKAction.sequence([
                actionTexture,
                actionMove,
                actionFadeOut,
                actionMoveDone,
//                actionWait,
//                actionFadeIn,
//                SKAction.runBlock(gameOver)
                ]))
//        monster.removeFromParent()
        
        let actionTexture1 = SKAction.setTexture(SKTexture(imageNamed: "explosion!"))
        let actionMove1 = SKAction.scaleTo(2.5, duration: 0.75)
        let actionMoveDone1 = SKAction.removeFromParent()
        let actionFadeOut1 = SKAction.fadeOutWithDuration(NSTimeInterval(0.25))
        
        projectile.runAction(
            SKAction.sequence([actionTexture1,
                actionMove1,
                actionFadeOut1,
                actionMoveDone1
                ]))
        
        runAction(SKAction.sequence([
            SKAction.waitForDuration(1.0),
            SKAction.runBlock() {
                // 5
                let reveal = SKTransition.flipHorizontalWithDuration(0.5)
                let scene = GameOverScene(size: self.size, won: false)
                self.view?.presentScene(scene, transition:reveal)
            }
            ]))
        
        
        
        
//        projectile.removeFromParent()
//        monster.removeFromParent()
//        monstersDestroyed++
//        if (monstersDestroyed > 10) {
//            sleep(600)=
//            let reveal = SKTransition.flipHorizontalWithDuration(1.5)
//            let gameOverScene = GameOverScene(size: self.size, won: false)
//            self.view?.presentScene(gameOverScene, transition: reveal)
//        }
    }

//    func gameOver() {
//        let reveal = SKTransition.flipHorizontalWithDuration(1.5)
//        let gameOverScene = GameOverScene(size: screenSize, won: false)
//        self.view?.presentScene(gameOverScene, transition: reveal)
//    }


    func didBeginContact(contact: SKPhysicsContact) {
        
        // 1
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // 2
        if ((firstBody.categoryBitMask & PhysicsCategory.Monster != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Projectile != 0)) {
                projectileDidCollideWithMonster(firstBody.node as! SKSpriteNode, monster: secondBody.node as! SKSpriteNode)
        }
        
        if ((firstBody.categoryBitMask & PhysicsCategory.Monster != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Player != 0)) {
                shipDidCollideWithMonster(firstBody.node as! SKSpriteNode, monster: secondBody.node as! SKSpriteNode)
        }
        
    }
    
override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        // if I press a button, I want to add it to the pressed buttons list
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            
            // for all 4 buttons
            for button in [buttonDirUp, buttonDirLeft, buttonDirDown, buttonDirRight] {
                // I check if they are already registered in the list
                if button.hitboxContainsPoint(location) && find(pressedButtons, button) == nil {
                    pressedButtons.append(button)
                }
            }
        }
        // then I check all the 4 buttons and set the transparency according if they are in the list or not
        for button in [buttonDirUp, buttonDirLeft, buttonDirDown, buttonDirRight] {
            if find(pressedButtons, button) == nil {
                button.alpha = 0.2
            }
            else {
                button.alpha = 0.8
            }
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        var walkingSpeed: CGFloat = 5.0
        var backgroundSpeed: CGFloat = 4.0
        var objectSpeed: CGFloat = 6.0
        
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        
        let playerWidth = player.size.width
        let playerHeight = player.size.width
        background1.position = CGPointMake(background1.position.x - backgroundSpeed, background1.position.y)
        background2.position = CGPointMake(background2.position.x - backgroundSpeed, background2.position.y)
        
//        score = score + 1
//        setupHud()

        if(background1.position.x < -background1.size.width) {
            background1.position = CGPointMake(background2.position.x + background1.size.width, background1.position.y)
        }

        if(background2.position.x < -background2.size.width) {
            background2.position = CGPointMake(background1.position.x + background2.size.width, background2.position.y)
        }
        
        if pressedButtons.count == 2 {
            walkingSpeed = walkingSpeed / sqrt(2.0)
        }
        
        if find(pressedButtons, buttonDirUp) != nil {
            player.position.y += walkingSpeed
        }
        if find(pressedButtons, buttonDirDown) != nil {
            player.position.y -= walkingSpeed
        }
        if find(pressedButtons, buttonDirLeft) != nil {
            player.position.x -= walkingSpeed  * 1.5
        }
        if find(pressedButtons, buttonDirRight) != nil {
            player.position.x += walkingSpeed
        }
        
        if player.position.x < 0 {
            player.position.x = 0
        }
        else if player.position.x > screenWidth {
            player.position.x = screenWidth
        }
        
        if player.position.y < 0 {
            player.position.y = 0
        }
        else if player.position.y > screenHeight {
            player.position.y = screenHeight
        }
        
    }
    
    override func touchesCancelled(touches: Set<NSObject>, withEvent event: UIEvent) {
        touchesEndedOrCancelled(touches, withEvent: event)
    }
    
    func touchesEndedOrCancelled(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            let previousLocation = touch.previousLocationInNode(self)
            
            for button in [buttonDirUp, buttonDirLeft, buttonDirDown, buttonDirRight] {
                if button.hitboxContainsPoint(location) {
                    let index = find(pressedButtons, button)
                    if index != nil {
                        pressedButtons.removeAtIndex(index!)
                    }
                }
                else if (button.hitboxContainsPoint(previousLocation)) {
                    let index = find(pressedButtons, button)
                    if index != nil {
                        pressedButtons.removeAtIndex(index!)
                    }
                }
            }
        }
        for button in [buttonDirUp, buttonDirLeft, buttonDirDown, buttonDirRight] {
            if find(pressedButtons, button) == nil {
                button.alpha = 0.2
            }
            else {
                button.alpha = 0.8
            }
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        // if I move off a button, I remove it from the list, if I move on a button, I add it to the list
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            let previousLocation = touch.previousLocationInNode(self)
            
            for button in [buttonDirUp, buttonDirLeft, buttonDirDown, buttonDirRight] {
                // if I get off the button where my finger was before
                if button.hitboxContainsPoint(previousLocation) && !button.hitboxContainsPoint(location) {
                    // I remove it from the list
                    let index = find(pressedButtons, button)
                    if index != nil {
                        pressedButtons.removeAtIndex(index!)
                    }
                }
                    // if I get on the button where I wasn't previously
                else if !button.hitboxContainsPoint(previousLocation) && button.hitboxContainsPoint(location) && find(pressedButtons, button) == nil {
                    // I add it to the list
                    pressedButtons.append(button)
                }
            }
        }
        // update transparency for all 4 buttons
        for button in [buttonDirUp, buttonDirLeft, buttonDirDown, buttonDirRight] {
            if find(pressedButtons, button) == nil {
                button.alpha = 0.2
            }
            else {
                button.alpha = 0.8
            }
        }
    }

    func setupHud() {
        // 1
        let scoreLabel = SKLabelNode(fontNamed: "Courier")
        scoreLabel.name = kScoreHudName
        scoreLabel.fontSize = 25
        
        // 2
        scoreLabel.fontColor = SKColor.greenColor()
        scoreLabel.text = NSString(format: "Score: %04u", score) as String
        
         3
        println(size.height)
        scoreLabel.position = CGPoint(x: frame.size.width / 2, y: size.height - (40 + scoreLabel.frame.size.height/2))
        addChild(scoreLabel)
        
        // 4
        let healthLabel = SKLabelNode(fontNamed: "Courier")
        healthLabel.name = kHealthHudName
        healthLabel.fontSize = 25
        
        // 5
        healthLabel.fontColor = SKColor.redColor()
        healthLabel.text = NSString(format: "Health: %.1f%%", 100.0) as String
        
        // 6
        healthLabel.position = CGPoint(x: frame.size.width / 2, y: size.height - (80 + healthLabel.frame.size.height/2))
        addChild(healthLabel)
    }


}