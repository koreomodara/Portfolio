//
//  You Won:You Lose .swift
//  GamePigeonPong
//
//  Created by kore omodara on 4/28/24.
//

import Foundation
import SpriteKit

class YouLose: SKScene {

    override func didMove(to view: SKView) {
            setupMenu()
    }
        
        func setupMenu() {
            backgroundColor = .white
            run(SKAction.playSoundFileNamed("YouLose.mp3", waitForCompletion: false))
            
            // Title Label
            let titleLabel = SKLabelNode(text: "YOU LOSE!")
            titleLabel.fontName = "HelveticaNeue-Bold"
            titleLabel.fontSize = 50
            titleLabel.fontColor = .black
            titleLabel.position = CGPoint(x: frame.midX, y: frame.midY + 150)
            addChild(titleLabel)
            
            //add in crown sprite
            let exImage = SKSpriteNode(imageNamed: "YouLose.PNG")
            exImage.position = CGPoint(x: frame.midX, y: frame.midY)
            addChild(exImage)
        
            let newGameButtonSize = CGSize(width: 150, height: 60)
            let cornerRadius: CGFloat = 10 // Adjust the corner radius as needed
            let newGameButton = SKShapeNode(rectOf: newGameButtonSize, cornerRadius: cornerRadius)
            newGameButton.fillColor = .systemGreen
            newGameButton.position = CGPoint(x: frame.midX, y: frame.midY - 150)
            newGameButton.name = "newGameButton"
            addChild(newGameButton)

            // play again Button
            let newGameButtonLabel = SKLabelNode(text: "Try Again?")
            newGameButtonLabel.fontName = "HelveticaNeue-Bold"
            newGameButtonLabel.fontSize = 25
            newGameButtonLabel.fontColor = .white
            newGameButtonLabel.position = CGPoint(x: newGameButton.frame.midX, y: newGameButton.frame.midY)
            newGameButtonLabel.name = "newGameButton"
            addChild(newGameButtonLabel)
            
    
        }
        
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = self.nodes(at: location)
        print("playagainpressed")
            for node in nodes {
                if node.name == "newGameButton" {
                    let scene = IntroScene(size: size)
                    scene.scaleMode = .aspectFill
                    print("newGamepressed")
                    // get the SKView from the scene's view
                    
                    if let skView = self.view {
                    skView.presentScene(scene)
                    print("game loaded from Menu")
                }
                
            }
    
        }
    }

}
