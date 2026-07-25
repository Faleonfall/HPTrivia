import SwiftUI

struct Gameplay: View {
    @Environment(Game.self) private var game
    @Environment(\.dismiss) private var dismiss
    @Namespace private var namespace

    @State private var sfx = AudioPlayer()

    @State private var animateViewsIn = false
    @State private var revealHint = false
    @State private var revealBook = false
    @State private var tappedCorrectAnswer = false
    @State private var wrongAnswersTapped: [String] = []
    @State private var movePointsToScore = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image(.hogwarts)
                    .resizable()
                    .frame(width: geo.size.width * 3, height: geo.size.height * 1.05)
                    .overlay(Rectangle().foregroundStyle(.black.opacity(0.8)))
                VStack {
                    GameplayHeader(score: game.gameScore) {
                        game.endGame()
                        dismiss()
                    }

                    VStack {
                        // MARK: - Question
                        VStack {
                            if animateViewsIn {
                                Text(game.currentQuestion.question)
                                    .font(.custom(Theme.hpFont, size: 50))
                                    .multilineTextAlignment(.center)
                                    .padding()
                                    .transition(.scale)
                            }
                        }
                        .animation(
                            .easeInOut(duration: animateViewsIn ? 2 : 0), value: animateViewsIn)
                        Spacer()
                        HintBar(
                            question: game.currentQuestion,
                            animateViewsIn: animateViewsIn,
                            revealHint: revealHint,
                            revealBook: revealBook,
                            width: geo.size.width,
                            revealHintAction: {
                                revealHint = true
                                sfx.play(Sound.flip)
                                game.questionScore -= 1
                            },
                            revealBookAction: {
                                revealBook = true
                                sfx.play(Sound.flip)
                                game.questionScore -= 1
                            }
                        )
                        // MARK: - Answers
                        LazyVGrid(columns: [GridItem(), GridItem()]) {
                            ForEach(game.answers, id: \.self) { answer in
                                if answer == game.currentQuestion.answer {
                                    VStack {
                                        if animateViewsIn {
                                            if !tappedCorrectAnswer {
                                                Button {
                                                    withAnimation(.easeOut(duration: 1)) {
                                                        tappedCorrectAnswer = true
                                                    }
                                                    sfx.play(Sound.correct)
                                                    DispatchQueue.main.asyncAfter(
                                                        deadline: .now() + 3.5
                                                    ) {
                                                        game.correct()
                                                    }
                                                } label: {
                                                    Text(answer)
                                                        .minimumScaleFactor(0.5)
                                                        .multilineTextAlignment(.center)
                                                        .padding(10)
                                                        .frame(
                                                            width: geo.size.width / 2.15, height: 80
                                                        )
                                                        .background(.green.opacity(0.5))
                                                        .clipShape(.rect(cornerRadius: 25))
                                                        .matchedGeometryEffect(id: 1, in: namespace)
                                                }
                                                .transition(
                                                    .asymmetric(
                                                        insertion: .scale,
                                                        removal: .scale(scale: 15).combined(
                                                            with: .opacity)))
                                            }
                                        }
                                    }
                                    .animation(
                                        .easeOut(duration: animateViewsIn ? 1 : 0).delay(
                                            animateViewsIn ? 1.5 : 0), value: animateViewsIn)
                                } else {
                                    VStack {
                                        if animateViewsIn {
                                            Button {
                                                withAnimation(.easeOut(duration: 1)) {
                                                    wrongAnswersTapped.append(answer)
                                                }
                                                sfx.play(Sound.wrong)
                                                game.questionScore -= 1
                                            } label: {
                                                Text(answer)
                                                    .minimumScaleFactor(0.5)
                                                    .multilineTextAlignment(.center)
                                                    .padding(10)
                                                    .frame(width: geo.size.width / 2.15, height: 80)
                                                    .background(
                                                        wrongAnswersTapped.contains(answer)
                                                            ? .red.opacity(0.5)
                                                            : .green.opacity(0.5)
                                                    )
                                                    .clipShape(.rect(cornerRadius: 25))
                                                    .scaleEffect(
                                                        wrongAnswersTapped.contains(answer)
                                                            ? 0.8 : 1)
                                            }
                                            .transition(.scale)
                                            .sensoryFeedback(.error, trigger: wrongAnswersTapped)
                                            .disabled(wrongAnswersTapped.contains(answer))
                                        }
                                    }
                                    .animation(
                                        .easeOut(duration: animateViewsIn ? 1 : 0).delay(
                                            animateViewsIn ? 1.5 : 0), value: animateViewsIn)
                                }
                            }
                        }
                        Spacer()
                    }
                    .disabled(tappedCorrectAnswer)
                    .opacity(tappedCorrectAnswer ? 0.1 : 1)
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .foregroundStyle(.white)
                CelebrationView(
                    show: tappedCorrectAnswer,
                    score: game.questionScore,
                    answer: game.currentQuestion.answer,
                    movePointsToScore: $movePointsToScore,
                    width: geo.size.width,
                    height: geo.size.height,
                    namespace: namespace
                ) {
                    animateViewsIn = false
                    revealBook = false
                    revealHint = false
                    tappedCorrectAnswer = false
                    wrongAnswersTapped = []
                    movePointsToScore = false
                    game.newQuestion()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        animateViewsIn = true
                    }
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .ignoresSafeArea()
        .onAppear {
            game.startGame()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                animateViewsIn = true
            }
        }
    }
}

#Preview {
    Gameplay()
        .environment(Game())
}
