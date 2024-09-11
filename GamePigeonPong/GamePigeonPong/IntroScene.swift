//
//  IntroScene.swift
//  GamePigeonPong
//
//  Created by kore omodara on 4/23/24.
//
import Foundation
import SpriteKit

class IntroScene: SKScene {
    
    override func didMove(to view: SKView) {
        backgroundColor = .white
        
        // Title Label
        let titleLabel = SKLabelNode(text: "PONG!")
        titleLabel.fontName = "HelveticaNeue-Bold"
        titleLabel.fontSize = 64
        titleLabel.fontColor = .black
        titleLabel.position = CGPoint(x: frame.midX, y: frame.midY + 100)
        addChild(titleLabel)
        
        // Play Button
        let playButtonSize = CGSize(width: 150, height: 60)
        let cornerRadius: CGFloat = 10 // Adjust the corner radius as needed

        //rounded rectangle shape node
        let playButton = SKShapeNode(rectOf: playButtonSize, cornerRadius: cornerRadius)
        playButton.fillColor = .systemGreen 
        playButton.position = CGPoint(x: frame.midX, y: frame.midY)
        playButton.name = "playButton"
        addChild(playButton)

        
        // Button Label
        let playLabel = SKLabelNode(text: "Play")
        playLabel.fontName = "HelveticaNeue-Bold"
        playLabel.fontSize = 36
        playLabel.fontColor = .white
        playLabel.position = CGPoint(x: 0, y: -10)
        playButton.addChild(playLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = self.nodes(at: location)
        print("playpressed")
        for node in nodes {
            if node.name == "playButton" {
                let scene = Game(size: size)
                scene.scaleMode = .aspectFill
                //print("playpressed")
                // get the SKView from the scene's view
                if let skView = self.view {
                    skView.presentScene(scene)
                    print("gameloaded")
                }
                
            }
        }
    }

}

 
    

