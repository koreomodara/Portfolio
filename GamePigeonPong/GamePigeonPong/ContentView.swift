//
//  ContentView.swift
//  GamePigeonPong
//
//  Created by kore omodara on 4/16/24.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    
    @State var game = Game(size: UIScreen.main.bounds.size)
    @State var intro = IntroScene(size: UIScreen.main.bounds.size)
    @State var menu = Menu(size: UIScreen.main.bounds.size)
    @State var win = YouWin(size: UIScreen.main.bounds.size)
    @State var lose = YouLose(size: UIScreen.main.bounds.size)
    
    var body: some View {
        SpriteView(scene: intro)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            .statusBarHidden(true)
    }
}


#Preview {
    ContentView()
}
