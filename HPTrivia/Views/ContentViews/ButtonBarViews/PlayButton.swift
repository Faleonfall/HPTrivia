//
//  PlayButton.swift
//  HPTrivia
//
//  Created by Volodymyr Kryvytskyi on 08.11.25.
//

import SwiftUI
import AVFAudio

struct PlayButton: View {
    @EnvironmentObject private var store: Store
    @Environment(Game.self) private var game

    @State private var scalePlayButton = false
    @State private var audioPlayer: AVAudioPlayer!
    
    @Binding var playGame: Bool
    @Binding var animateViewsIn: Bool
    
    let geo: GeometryProxy
    
    var body: some View {
        VStack {
            if animateViewsIn {
                Button {
                    game.startGame()
                    playGame.toggle()
                } label: {
                    Text("Play")
                        .font(.largeTitle)
                        .foregroundStyle(.white)
                        .padding(.vertical, 7)
                        .padding(.horizontal, 50)
                        .background(store.books.contains(.active) ? .brown : .gray)
                        .clipShape(.rect(cornerRadius: 7))
                        .shadow(radius: 5)
                        .scaleEffect(scalePlayButton ? 1.2 : 1)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1.3).repeatForever()) {
                                scalePlayButton.toggle()
                            }
                        }
                }
                .transition(.offset(y: geo.size.height / 3))
                .disabled(store.books.contains(.active) ? false : true)
            }
        }
        .animation(.easeOut(duration: 0.7).delay(2), value: animateViewsIn)
    }
}

#Preview {
    GeometryReader { geo in
        PlayButton(playGame: .constant(false), animateViewsIn: .constant(true), geo: geo)
            .environmentObject(Store())
            .environment(Game())
            .frame(width: geo.size.width, height: geo.size.height)
    }
}
