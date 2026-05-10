import SwiftUI

@main
struct HPTriviaApp: App {
    @State private var store = Store()
    @State private var game = Game()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(store)
                .environment(game)
        }
    }
}
