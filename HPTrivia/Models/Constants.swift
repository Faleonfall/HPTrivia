//
//  Constants.swift
//  HPTrivia
//
//  Created by Volodymyr Kryvytskyi on 01.12.2024.
//

import SwiftUI

enum Constants {
    static let hpFont = "PartyLetPlain"
}

struct InfoBackgroundImage: View {
    var body: some View {
        Image(.parchment)
            .resizable()
            .ignoresSafeArea()
            .background(.brown)
    }
}

extension Button {
    @MainActor func doneButton() -> some View {
        self
            .font(.largeTitle)
            .padding()
            .buttonStyle(.borderedProminent)
            .tint(.brown.mix(with: .brown, by: 0.2))
            .foregroundStyle(.white)
    }
}

extension FileManager {
    static var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        return paths[0]
    }
}
