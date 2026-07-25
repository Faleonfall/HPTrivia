import SwiftUI

struct HomeView: View {
    // Menu music volume. Fades to silence while a round is on screen.
    private static let musicVolume: Float = 0.2

    @Environment(Store.self) private var store
    @Environment(Game.self) private var game
    @State private var music = AudioPlayer()
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
            music.loop(Sound.menuMusic, volume: Self.musicVolume)
        }
        .fullScreenCover(isPresented: $playGame) {
            Gameplay()
                .environment(store)
                .environment(game)
                .onAppear {
                    music.fade(to: 0, over: 2)
                }
                .onDisappear {
                    music.fade(to: Self.musicVolume, over: 2)
                }
        }
    }
}

#Preview {
    HomeView()
        .environment(Store())
        .environment(Game())
}
