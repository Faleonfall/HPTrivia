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

// MARK: - Buttons

private struct InstructionsButton: View {
    @State private var showInstructions = false
    @Binding var animateViewsIn: Bool
    let geo: GeometryProxy

    var body: some View {
        VStack {
            if animateViewsIn {
                Button {
                    showInstructions.toggle()
                } label: {
                    Image(systemName: "info.circle.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.white)
                        .shadow(radius: 5)
                }
                .transition(.offset(x: -geo.size.width / 4))
            }
        }
        .animation(.easeOut(duration: 0.7).delay(2.7), value: animateViewsIn)
        .sheet(isPresented: $showInstructions) {
            Instructions()
        }
    }
}

private struct PlayButton: View {
    @Environment(Game.self) private var game
    @Binding var playGame: Bool
    @Binding var animateViewsIn: Bool
    let geo: GeometryProxy

    private var hasActiveBooks: Bool {
        game.questionBank.books.contains { $0.status == .active }
    }

    var body: some View {
        VStack {
            if animateViewsIn {
                Button {
                    playGame.toggle()
                } label: {
                    Label("Play", systemImage: "play.fill")
                        .font(.title.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 34)
                        .background(hasActiveBooks ? .brown : .gray, in: Capsule())
                        .shadow(color: .black.opacity(hasActiveBooks ? 0.35 : 0.15), radius: 8, y: 4)
                        .phaseAnimator([false, true]) { content, phase in
                            content
                                .scaleEffect(hasActiveBooks && phase ? 1.04 : 1)
                                .shadow(color: .yellow.opacity(hasActiveBooks && phase ? 0.35 : 0), radius: phase ? 10 : 0)
                        } animation: { _ in
                            .easeInOut(duration: 1.8)
                        }
                }
                .sensoryFeedback(.start, trigger: playGame)
                .transition(.offset(y: geo.size.height / 3))
                .disabled(!hasActiveBooks)
            }
        }
        .animation(.easeOut(duration: 0.7).delay(2), value: animateViewsIn)
    }
}

private struct SettingsButton: View {
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
        ButtonBar(playGame: .constant(false), animateViewsIn: .constant(true), geo: geo)
            .environment(Store())
            .environment(Game())
            .frame(width: geo.size.width, height: 120)
            .background(Color.black.opacity(0.2))
    }
}
