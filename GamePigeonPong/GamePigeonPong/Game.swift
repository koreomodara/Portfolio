//
//  Game.swift
//  GamePigeonPong
//
//  Created by kore omodara on 4/16/24.
//

import Foundation
import SpriteKit
import SwiftUI
import UIKit


class Game: SKScene, SKPhysicsContactDelegate {
    
    var ball: SKShapeNode!
    var AIPaddle: SKSpriteNode!
    var playerPaddle: SKSpriteNode!
    var tScoreBox: SKSpriteNode!
    var bScoreBox: SKSpriteNode!
    var edgeBox: SKShapeNode!
    var ballVelocity = CGVector(dx: 200, dy: 200)
    var paddleSpeed: CGFloat = 10.0
    var score: Score = Score()
    //var menuPopup: Menu?
    var menuButton: SKShapeNode?
    
    //wall stuff LAWD
    let wallThickness: CGFloat = 0
    let edgeBoxWidth: CGFloat = 0
    
    
    let ballCategory: UInt32 = 0x1 << 0
    let topWallCategory: UInt32 = 0x1 << 1
    let bottomWallCategory: UInt32 = 0x1 << 2

    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        
        setupScene()
        setupMenuButton()
        createBall()
        updateScoreDisplay()
        
        ball.physicsBody?.categoryBitMask = ballCategory
        
    }
    
    func setupScene() {
        backgroundColor = .black
        //TODO
        let edgeBoxWidth = frame.width - 50
        let edgeBoxHeight = frame.height - 150
        let edgeBoxOriginX = (frame.width - edgeBoxWidth) / 2
        let edgeBoxOriginY = (frame.height - edgeBoxHeight) / 2
        
        edgeBox = SKShapeNode(rect: CGRect(x: edgeBoxOriginX, y: edgeBoxOriginY, width: edgeBoxWidth, height: edgeBoxHeight), cornerRadius: 7)
        //edgeBox.fillColor = .gray -> change to a dif color event
        addChild(edgeBox)
        //make them out of view ? aesthetic decison
        //make them thicker
        let wallThickness = 20.0
        let bottomWall = wall(point: CGPoint(x: edgeBox.frame.midX, y: edgeBox.frame.minY + wallThickness/2), size: CGSize(width: edgeBoxWidth, height: wallThickness))
        bottomWall.physicsBody?.categoryBitMask = bottomWallCategory
        bottomWall.physicsBody?.contactTestBitMask = ballCategory
        let upperWall = wall(point: CGPoint(x: edgeBox.frame.midX, y: edgeBox.frame.maxY - wallThickness/2), size: CGSize(width: edgeBoxWidth, height: wallThickness))
        upperWall.physicsBody?.categoryBitMask = topWallCategory
        upperWall.physicsBody?.contactTestBitMask = ballCategory
        wall(point: CGPoint(x: edgeBox.frame.minX + wallThickness/2, y: edgeBox.frame.midY), size: CGSize(width: wallThickness, height: edgeBoxHeight))
        wall(point: CGPoint(x: edgeBox.frame.maxX - wallThickness/2, y: edgeBox.frame.midY), size: CGSize(width: wallThickness, height: edgeBoxHeight))
        
        //paddles and positions
        playerPaddle = SKSpriteNode(color: .blue, size: CGSize(width: 100, height: 10))
        playerPaddle.position = CGPoint(x: frame.width/2 , y: frame.height * 0.13 )
        let playerBody = SKPhysicsBody(rectangleOf: playerPaddle.size)
        playerBody.isDynamic = false
        playerPaddle.physicsBody = playerBody
        addChild(playerPaddle)
        
        AIPaddle = SKSpriteNode(color: .red, size: CGSize(width: 100, height: 10))
        AIPaddle.position = CGPoint(x: frame.width/2 , y: frame.height * 0.87 )
        let AIBody = SKPhysicsBody(rectangleOf: AIPaddle.size)
        AIBody.isDynamic = false
        AIPaddle.physicsBody = AIBody
        addChild(AIPaddle)
        
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        //scoreBoxes
        tScoreBox = SKSpriteNode(color: .white, size: CGSize(width: 40, height: 20))
        tScoreBox.position = CGPoint(x: frame.width * 0.13 , y: (frame.height * 0.93) - 0)
        addChild(tScoreBox)
        bScoreBox = SKSpriteNode(color: .white, size: CGSize(width: 40, height: 20))
        bScoreBox.position = CGPoint(x: frame.width * 0.87 , y: (frame.height * 0.07) - 0)
        addChild(bScoreBox)
    }
    
    func updateScoreDisplay() {
        // text in the score boxes
        // remove existing score label nodes?
        bScoreBox.enumerateChildNodes(withName: "playerScoreLabel") { node, _ in
            node.removeFromParent()
        }
        tScoreBox.enumerateChildNodes(withName: "AIscoreLabel") { node, _ in
            node.removeFromParent()
        }

        // Add new score label nodes
        
        let playerScoreLabel = SKLabelNode(text: "\(score.playerScore)")
        playerScoreLabel.name = "playerScoreLabel"
        playerScoreLabel.fontName = "HelveticaNeue-Bold"
        playerScoreLabel.fontColor = .black
        playerScoreLabel.fontSize = 20
        playerScoreLabel.position = CGPoint(x: (bScoreBox.size.width / 2) - 10, y: (bScoreBox.size.height / 2) - 10)
        playerScoreLabel.verticalAlignmentMode = .center
        playerScoreLabel.horizontalAlignmentMode = .center
        bScoreBox.addChild(playerScoreLabel)
            
        let AIScoreLabel = SKLabelNode(text: "\(score.AIScore)")
        AIScoreLabel.name = "AIscoreLabel"
        AIScoreLabel.fontName = "HelveticaNeue-Bold"
        AIScoreLabel.fontColor = .black
        AIScoreLabel.fontSize = 20
        AIScoreLabel.position = CGPoint(x: (tScoreBox.size.width / 2) - 10 , y: (tScoreBox.size.height / 2) - 10 )
        AIScoreLabel.verticalAlignmentMode = .center
        AIScoreLabel.horizontalAlignmentMode = .center
        tScoreBox.addChild(AIScoreLabel)

    }
    
    
    
    func createBall() {
        //createnew ball
        ball = SKShapeNode(circleOfRadius: 10)
        ball.fillColor = .white
        ball.position = CGPoint(x: frame.midX, y: frame.midY) // Start position at the center of the screen
        addChild(ball)
        
        
        // physics props for the ball
        let ballBody = SKPhysicsBody(circleOfRadius: 10)
        ballBody.affectedByGravity = false
        ballBody.allowsRotation = false
        ballBody.restitution = 1.0
        ballBody.friction = 0.0 // No friction
        ballBody.linearDamping = 0.0
        ballBody.angularDamping = 0.0
        ball.physicsBody = ballBody
        
        // initial impulse to the ball towards one of the paddles
        let initialDirection = CGFloat.random(in: -CGFloat.pi / 4 ... CGFloat.pi / 4) // angle range towards the paddles
        let impulseMagnitude: CGFloat = 10 // adjust
        let impulseX = cos(initialDirection) * impulseMagnitude
        let impulseY = sin(initialDirection) * impulseMagnitude
        let impulseVector = CGVector(dx: impulseX, dy: impulseY)
        ball.physicsBody?.applyImpulse(impulseVector)
    }
    
//    func checkBallPosition() {
//        //change to contact delegate & bit masks 
//        guard let ball = ball else { return }
//        // If the ball passes the bottom wall beneath the player paddle
//        if ball.position.y <= edgeBox.frame.minY + ball.frame.size.height / 2 {
//            print("opponent scored")
//            print("\(score.AIScore)")
//            score.incrementOpponentScore()
//            updateScoreDisplay()
//            
//            if score.AIScore >= 10 {
//                //score.isGameOver()
//                print("game over")
//                // Handle game over
//                //put a nav into a new scene
//                // Reset scores
//                score.resetScores()
//                
//                let scene = YouLose(size: size)
//                scene.scaleMode = .aspectFill
//                if let skView = self.view {
//                    skView.presentScene(scene)
//                    print("scene loaded")
//                }
//                print("YouLose")
//            } 
//            else {
////                ball.removeAllChildren()
////                createBall()
//                print("Error: View is nil")
//                
//            }
//            // Update the score display after a point is scored
//            print("score will be updated now ")
//            updateScoreDisplay()
//            print("score updated")
//        }
//        // If ball passes the top wall above the AI paddle
//        else if ball.position.y >= edgeBox.frame.maxY - ball.frame.size.height / 2 {
//            print("Player scored")
//            score.incrementPlayerScore()
//            updateScoreDisplay()
//            if score.playerScore >= 10 {
//                // Handle game over
//                // Reset scores
//                //score.isGameOver()
//                let scene2 = YouWin(size: size)
//                scene2.scaleMode = .aspectFill
//                if let skView = self.view {
//                    skView.presentScene(scene2)
//                    print("scene loaded")
//                }
//                print("YouWin")
//                score.resetScores()
//                
//            } else {
//                // make new ball in scene
////                ball.removeAllChildren()
////                createBall()
//                print("Error: View is nil")
//                
//            }
//            updateScoreDisplay()
//        }
//    }
//    
    
    func setupMenuButton() {
        //circular shape node as the menu button in the top right corner
        let buttonRadius: CGFloat = 15
        let button = SKShapeNode(circleOfRadius: buttonRadius)
        button.fillColor = .white
        button.position = CGPoint(x: frame.maxX - 50, y: frame.maxY - 50)
        addChild(button)
        
        // three horizontally aligned lines
        let lineWidth: CGFloat = 25
        let lineHeight: CGFloat = 4
        let lineSpacing: CGFloat = 5
        
        let startX = button.position.x - lineWidth / 2
        let startY = button.position.y - lineHeight  //center the lines vertically
        
        for i in 0..<3 {
            let line = SKShapeNode(rectOf: CGSize(width: lineWidth, height: lineHeight))
            line.fillColor = .black
            line.position = CGPoint(x: startX + 12 , y: (startY - 6) + CGFloat(i) * (lineHeight + lineSpacing))
            addChild(line)
        }
        
        menuButton = button
    }
    
    
    func moveAI() {
        guard let ball = ball else { return }
        let speed: CGFloat = 2.0
        let targetX = ball.position.x
        let dx = targetX - AIPaddle.position.x
        let direction = dx > 0 ? 1.0 : -1.0 // Move towards the ball
        let distance = abs(dx)
        let actualSpeed = min(distance, speed)
        AIPaddle.position.x += direction * actualSpeed
        
    }
    
    func wall(point: CGPoint, size: CGSize)-> SKSpriteNode {
        let customColor = UIColor(
                red: CGFloat(28.0 / 255.0),
                green: CGFloat(133.0 / 255.0),
                blue: CGFloat(71.0 / 255.0),
                alpha: 1.0
            )
        let wall = SKSpriteNode(color: customColor, size: size)//make dark green
        wall.position = point
        let body = SKPhysicsBody(rectangleOf: wall.size)
        body.isDynamic = false
        wall.physicsBody = body
        addChild(wall)
        return wall
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        //print("Collision detected")
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        // Check if the collision is between the ball and the walls
        if collision == ballCategory | bottomWallCategory {
            run(SKAction.playSoundFileNamed("BallPing.mp3", waitForCompletion: false))
            // Collision with bottom wall (AI scores)
            print("Opponent scored")
            score.incrementOpponentScore()
        } else if collision == ballCategory | topWallCategory {
            // Collision with top wall (player scores)
            run(SKAction.playSoundFileNamed("BallPing.mp3", waitForCompletion: false))
            print("Player scored")
            score.incrementPlayerScore()
        }

        // Update score display
        updateScoreDisplay()
        
        if score.AIScore >= 10 {
            //score.isGameOver()
            run(SKAction.playSoundFileNamed("YouLose.mp3", waitForCompletion: false))
            print("game over")
            // Handle game over
            //put a nav into a new scene
            // Reset scores
            score.resetScores()
            
            let scene = YouLose(size: size)
            scene.scaleMode = .aspectFill
            if let skView = self.view {
                skView.presentScene(scene)
                print("scene loaded")
            }
            print("YouLose")
        }
        else {
//            ball.removeAllChildren()
//            createBall()
            //print("Error: View is nil")
            
        }
        
        if score.playerScore >= 10 {
            // Handle game over
            // Reset scores
            //score.isGameOver()
//            run(SKAction.playSoundFileNamed("YouWin.mp3", waitForCompletion: false))
            let scene2 = YouWin(size: size)
            scene2.scaleMode = .aspectFill
            if let skView = self.view {
                skView.presentScene(scene2)
                print("scene loaded")
            }
            print("YouWin")
            score.resetScores()
            
        }
        // create a new ball or handle game over
        if score.isGameOver() {
            // game over
            score.resetScores()
        } else {
            
        }
    }


    override func update(_ currentTime: TimeInterval) {
        // move ball, check collisions
        moveAI()
        //checkBallPosition()
        updateScoreDisplay()
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        // Get the location of the touch in the scene
        var touchLocation = touch.location(in: self)
        
        // minX and maxX positions within the edge box
        //add this into the AI paddle code 4/24
        let innerEdgeMargin: CGFloat = 20 // Adjust as needed
        let innerMinX = edgeBox.frame.minX + innerEdgeMargin + playerPaddle.size.width / 2
        let innerMaxX = edgeBox.frame.maxX - innerEdgeMargin - playerPaddle.size.width / 2
        
        // Ensure the touch location is within the inner edge box bounds
        touchLocation.x = max(innerMinX, min(innerMaxX, touchLocation.x))
       // AIPaddle.x = max(innerMaxX), min(innerMaxX, AIPaddle.y))
        
        
        // Move the bottom paddle horizontally to follow the touch
        playerPaddle.position.x = touchLocation.x
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        // Get the location of the touch in the scene
        let touchLocation = touch.location(in: self)
        print("touch: \(touchLocation)")
        
        //menu scene
        if let button = menuButton, button.contains(touchLocation) {
            print("menu pressed")
            //nav to new scene
            let scene = Menu(size: size)
            scene.scaleMode = .aspectFill
            // get the SKView from the scene's view
            if let skView = self.view {
                skView.presentScene(scene)
                print("menuloaded")
            }
        }
    }
}
