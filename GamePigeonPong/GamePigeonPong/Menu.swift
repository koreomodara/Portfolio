//
//  Menu.swift
//  GamePigeonPong
//
//  Created by kore omodara on 4/24/24.
//

import Foundation
import SpriteKit

class Menu: SKScene {

    var score: Score = Score()
    
    override func didMove(to view: SKView) {
            setupMenu()
    }
        
        func setupMenu() {
            backgroundColor = .white
            
            // Title Label
            let titleLabel = SKLabelNode(text: "PAUSED!")
            titleLabel.fontName = "HelveticaNeue-Bold"
            titleLabel.fontSize = 50
            titleLabel.fontColor = .black
            titleLabel.position = CGPoint(x: frame.midX, y: frame.midY + 150)
            addChild(titleLabel)
            
            let resumeButtonSize = CGSize(width: 150, height: 60)
            let cornerRadius: CGFloat = 10 // Adjust the corner radius as needed
            let resumeButton = SKShapeNode(rectOf: resumeButtonSize, cornerRadius: cornerRadius)
            resumeButton.fillColor = .systemGreen
            resumeButton.position = CGPoint(x: frame.midX, y: frame.midY + 50)
            resumeButton.name = "resumeButton"
            addChild(resumeButton)

            // Resume Button
            let resumeButtonLabel = SKLabelNode(text: "Resume")
            resumeButtonLabel.fontName = "HelveticaNeue-Bold"
            resumeButtonLabel.fontSize = 24
            resumeButtonLabel.fontColor = .white
            resumeButtonLabel.position = CGPoint(x: resumeButton.frame.midX, y: resumeButton.frame.midY)
            resumeButtonLabel.name = "resumeButton"
            addChild(resumeButtonLabel)
            
    
            
            // Restart Button
            let restartButton = SKShapeNode(rectOf: resumeButtonSize, cornerRadius: cornerRadius)
            restartButton.fillColor = .systemGreen
            restartButton.position = CGPoint(x: frame.midX, y: frame.midY - 50)
            restartButton.name = "restartButton"
            addChild(restartButton)
            
            let restartLabel = SKLabelNode(text: "Restart")
            restartLabel.fontName = "HelveticaNeue-Bold"
            restartLabel.fontSize = 24
            restartLabel.fontColor = .white
            restartLabel.position = CGPoint(x: restartButton.frame.midX, y: restartButton.frame.midY )
            restartLabel.name = "restartButton"
            addChild(restartLabel)
        }
        
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = self.nodes(at: location)
        print("playpressed")
            for node in nodes {
                if node.name == "resumeButton" {
                    let scene = Game(size: size)
                    scene.scaleMode = .aspectFill
                    print("resumepressed")
                    // get the SKView from the scene's view
                    
                    if let skView = self.view {
                    skView.presentScene(scene)
                    print("game loaded from Menu")
                }
                
            }
                if node.name == "restartButton" {
                    let scene = IntroScene(size: size)
                    scene.scaleMode = .aspectFill
                    print("restartpressed")
                    score.resetScores()
                    if let skView = self.view{
                        skView.presentScene(scene)
                        print("intro scene loaded")
                    }
                }
            }
        }

    }
