//
//  SettingsButton.swift
//  HPTrivia
//
//  Created by Volodymyr Kryvytskyi on 08.11.25.
//

import SwiftUI

struct SettingsButton: View {
    @EnvironmentObject private var store: Store
    @State private var showSettings = false

    @Binding var animateViewsIn: Bool
    
    let geo: GeometryProxy

    var body: some View {
        VStack {
            if animateViewsIn {
                Button {
                    showSettings.toggle()
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.white)
                        .shadow(radius: 5)
                }
                .transition(.offset(x: geo.size.width / 4))
                .sheet(isPresented: $showSettings) {
                    SelectBooks()
                        .environmentObject(store)
                }
            }
        }
        .animation(.easeOut(duration: 0.7).delay(2.7), value: animateViewsIn)
        .sheet(isPresented: $showSettings) {
            SelectBooks()
        }
    }
}

#Preview {
    GeometryReader { geo in
        SettingsButton(animateViewsIn: .constant(true), geo: geo)
            .environmentObject(Store())
            .environment(Game())
            .frame(width: geo.size.width, height: geo.size.height)
    }
}
