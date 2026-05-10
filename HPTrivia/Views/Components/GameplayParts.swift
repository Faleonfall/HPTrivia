import SwiftUI

struct GameplayHeader: View {
    let score: Int
    let endGame: () -> Void

    var body: some View {
        HStack {
            Button("End Game", action: endGame)
                .buttonStyle(.borderedProminent)
                .tint(.red.opacity(0.5))
            Spacer()
            Text("Score: \(score)")
        }
        .padding()
        .padding(.vertical, 30)
    }
}

struct HintBar: View {
    let question: Question
    let animateViewsIn: Bool
    let revealHint: Bool
    let revealBook: Bool
    let width: CGFloat
    let revealHintAction: () -> Void
    let revealBookAction: () -> Void

    var body: some View {
        HStack {
            hintTile
            Spacer()
            bookTile
        }
        .padding(.bottom)
    }

    private var hintTile: some View {
        VStack {
            if animateViewsIn {
                HintTile(
                    symbol: "questionmark.app.fill",
                    reveal: revealHint,
                    spin: 1440,
                    offset: width / 2,
                    back: Text(question.hint)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.5),
                    action: revealHintAction
                )
                .transition(.offset(x: -width / 2))
                .phaseAnimator([false, true]) { content, phase in
                    content.rotationEffect(.degrees(phase ? -13 : -17))
                } animation: { _ in
                    .easeInOut(duration: 0.7)
                }
            }
        }
        .padding(.leading, 24)
        .animation(.easeOut(duration: animateViewsIn ? 1.5 : 0)
            .delay(animateViewsIn ? 2 : 0), value: animateViewsIn)
    }

    private var bookTile: some View {
        VStack {
            if animateViewsIn {
                HintTile(
                    symbol: "book.closed",
                    reveal: revealBook,
                    spin: -1440,
                    offset: -width / 2,
                    back: Image("hp\(question.book)")
                        .resizable()
                        .scaledToFit(),
                    action: revealBookAction
                )
                .transition(.offset(x: width / 2))
                .phaseAnimator([false, true]) { content, phase in
                    content.rotationEffect(.degrees(phase ? 13 : 17))
                } animation: { _ in
                    .easeInOut(duration: 0.7)
                }
            }
        }
        .padding(.trailing, 24)
        .animation(.easeOut(duration: animateViewsIn ? 1.5 : 0)
            .delay(animateViewsIn ? 2 : 0), value: animateViewsIn)
    }
}

private struct HintTile<Back: View>: View {
    let symbol: String
    let reveal: Bool
    let spin: Double
    let offset: CGFloat
    let back: Back
    let action: () -> Void

    var body: some View {
        ZStack {
            front
            back
                .frame(width: 100, height: 100)
                .background(Color.cyan)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .opacity(reveal ? 1 : 0)
                .scaleEffect(reveal ? 1.2 : 0.9)
        }
    }

    private var front: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.cyan)
            .frame(width: 100, height: 100)
            .overlay {
                Image(systemName: symbol)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundStyle(.black)
            }
            .rotation3DEffect(.degrees(reveal ? spin : 0), axis: (x: 0, y: 1, z: 0))
            .scaleEffect(reveal ? 5 : 1)
            .offset(x: reveal ? offset : 0)
            .opacity(reveal ? 0 : 1)
            .onTapGesture {
                withAnimation(.easeOut(duration: 1), action)
            }
    }
}

struct CelebrationView: View {
    let show: Bool
    let score: Int
    let answer: String
    @Binding var movePointsToScore: Bool
    let width: CGFloat
    let height: CGFloat
    let namespace: Namespace.ID
    let nextLevel: () -> Void

    var body: some View {
        VStack {
            Spacer()
            points
            Spacer()
            title
            Spacer()
            answerCard
            Spacer()
            Spacer()
            nextButton
            Spacer()
            Spacer()
        }
        .foregroundStyle(.white)
    }

    private var points: some View {
        VStack {
            if show {
                Text("\(score)")
                    .font(.largeTitle)
                    .padding(.top, 50)
                    .transition(.offset(y: -height / 4))
                    .offset(x: movePointsToScore ? width / 2.3 : 0, y: movePointsToScore ? -height / 13 : 0)
                    .opacity(movePointsToScore ? 0 : 1)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1).delay(3)) {
                            movePointsToScore = true
                        }
                    }
            }
        }
        .animation(.easeInOut(duration: 1).delay(2), value: show)
    }

    private var title: some View {
        VStack {
            if show {
                Text("Brilliant!")
                    .font(.custom(Theme.hpFont, size: 100))
                    .transition(.scale.combined(with: .offset(y: -height / 2)))
            }
        }
        .animation(.easeInOut(duration: show ? 1 : 0).delay(show ? 1 : 0), value: show)
    }

    @ViewBuilder
    private var answerCard: some View {
        if show {
            Text(answer)
                .minimumScaleFactor(0.5)
                .multilineTextAlignment(.center)
                .padding(10)
                .frame(width: width / 2.15, height: 80)
                .background(.green.opacity(0.5))
                .clipShape(.rect(cornerRadius: 25))
                .scaleEffect(2)
                .matchedGeometryEffect(id: 1, in: namespace)
        }
    }

    private var nextButton: some View {
        VStack {
            if show {
                Button("Next Level>", action: nextLevel)
                    .font(.largeTitle)
                    .buttonStyle(.borderedProminent)
                    .tint(.blue.opacity(0.5))
                    .transition(.offset(y: height / 3))
                    .phaseAnimator([false, true]) { content, phase in
                        content.scaleEffect(phase ? 1.2 : 1)
                    } animation: { _ in
                        .easeInOut(duration: 1.3)
                    }
            }
        }
        .animation(.easeInOut(duration: show ? 2.7 : 0).delay(show ? 2.7 : 0), value: show)
    }
}
