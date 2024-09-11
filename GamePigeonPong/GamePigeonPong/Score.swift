//
//  Score.swift
//  GamePigeonPong
//
//  Created by kore omodara on 4/22/24.
//

import Foundation

class Score {
    var playerScore: Int = 0
    var AIScore: Int = 0
    
    func incrementPlayerScore() {
        playerScore += 1
    }
    
    func incrementOpponentScore() {
        AIScore += 1
    }
    
    func isGameOver() -> Bool {
        
        return playerScore >= 10 || AIScore >= 10
    }
    
//    func youWin() {
//        let scene = YouWin(size: size)
//        scene.scaleMode = .aspectFill
//        print("YouWin")
//    }
    
    func resetScores() {
        playerScore = 0
        AIScore = 0
    }
}
