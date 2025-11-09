//
//  HPTriviaApp.swift
//  HPTrivia
//
//  Created by Volodymyr Kryvytskyi on 30.11.2024.
//

import SwiftUI

@main
struct HPTriviaApp: App {
    private var store = Store()
    private var game = Game()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
                .environment(game)
        }
    }
}
