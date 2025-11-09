//
//  ButtonBar.swift
//  HPTrivia
//
//  Created by Volodymyr Kryvytskyi on 08.11.25.
//

import SwiftUI

struct ButtonBar: View {
    @Binding var playGame: Bool
    @Binding var animateViewsIn: Bool
    let geo: GeometryProxy

    var body: some View {
        HStack {
            Spacer()
            
            InstructionsButton(animateViewsIn: $animateViewsIn, geo: geo)
            
            Spacer()
            
            PlayButton(playGame: $playGame, animateViewsIn: $animateViewsIn, geo: geo)
            
            Spacer()
            
            SettingsButton(animateViewsIn: $animateViewsIn, geo: geo)
            
            Spacer()
        }
        .frame(width: geo.size.width)
        .padding(.vertical)
    }
}

#Preview {
    GeometryReader { geo in
        ButtonBar(playGame: .constant(false), animateViewsIn: .constant(true), geo: geo)
            .environment(Store())
            .environment(Game())
            .frame(width: geo.size.width, height: 120)
            .background(Color.black.opacity(0.2))
    }
}

