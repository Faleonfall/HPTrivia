import SwiftUI

struct RecentScores: View {
    @Environment(Game.self) private var game
    @Binding var animateViewsIn: Bool

    var body: some View {
        VStack {
            if animateViewsIn {
                VStack {
                    Text("Recent scores")
                        .font(.title2)

                    Text("\(game.recentScores[0])")
                    Text("\(game.recentScores[1])")
                    Text("\(game.recentScores[2])")
                }
                .font(.title3)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .foregroundStyle(.white)
                .background(.black.opacity(0.5))
                .clipShape(.rect(cornerRadius: 15))
                .transition(.opacity)
            }
        }
        .animation(.linear(duration: 1).delay(3.5), value: animateViewsIn)
    }
}

#Preview {
    RecentScores(animateViewsIn: .constant(true))
        .environment(Game())
}
