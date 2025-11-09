//
//  ContentView.swift
//  HPTrivia
//
//  Created by Volodymyr Kryvytskyi on 30.11.2024.
//

import SwiftUI
import AVKit

struct ContentView: View {
    @EnvironmentObject private var store: Store
    @Environment(Game.self) private var game
    @State private var audioPlayer: AVAudioPlayer!
    @State private var animateViewsIn = false
    @State private var playGame = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                AnimatedBackground(geo: geo)
                
                VStack {
                    GameTitle(animateViewsIn: $animateViewsIn)
                    
                    Spacer()
                    
                    RecentScores(animateViewsIn: $animateViewsIn)
                    
                    Spacer()
                    
                    ButtonBar(playGame: $playGame, animateViewsIn: $animateViewsIn, geo: geo)
                    
                    Spacer()
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .ignoresSafeArea()
        .onAppear {
            animateViewsIn = true
            playAudio()
        }
        .fullScreenCover(isPresented: $playGame) {
            Gameplay()
                .onAppear() {
                    audioPlayer.setVolume(0, fadeDuration: 2)
                }
                .onDisappear() {
                    audioPlayer.setVolume(1, fadeDuration: 3)
                }
        }
    }
    
    private func playAudio() {
        let sound = Bundle.main.path(forResource: "magic-in-the-air", ofType: "mp3")
        audioPlayer = try! AVAudioPlayer(contentsOf: URL(filePath: sound!))
        audioPlayer.numberOfLoops = -1
        //audioPlayer.play()
    }
}

#Preview {
    ContentView()
        .environmentObject(Store())
        .environment(Game())
}
