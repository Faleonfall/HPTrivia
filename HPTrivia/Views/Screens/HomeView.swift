import SwiftUI
import AVFAudio

struct HomeView: View {
    @Environment(Store.self) private var store
    @Environment(Game.self) private var game
    @State private var musicPlayer: AVAudioPlayer?
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
            playMusic()
        }
        .fullScreenCover(isPresented: $playGame) {
            Gameplay()
                .environment(store)
                .environment(game)
                .onAppear {
                    musicPlayer?.setVolume(0, fadeDuration: 2)
                }
                .onDisappear {
                    musicPlayer?.setVolume(0.2, fadeDuration: 2)
                }
        }
    }

    // MARK: - Audio

    private func playMusic() {
        guard musicPlayer == nil,
              let url = Bundle.main.url(forResource: "magic-in-the-air", withExtension: "mp3"),
              let player = try? AVAudioPlayer(contentsOf: url)
        else { return }

        player.volume = 0.2
        player.numberOfLoops = -1
        player.play()
        musicPlayer = player
    }
}

#Preview {
    HomeView()
        .environment(Store())
        .environment(Game())
}
