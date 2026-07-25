import SwiftUI

// Round state: the pool of active questions, the current question, and the
// score. Persists the recent score history to the documents directory.
@Observable
final class Game {
    static let startingQuestionScore = 5

    private let savePath = FileManager.documentsDirectory.appending(path: "RecentScore")

    var questionBank = QuestionBank()

    var gameScore = 0
    var questionScore = Game.startingQuestionScore
    var recentScores = Scores.empty

    var activeQuestions: [Question] = []
    var answeredQuestions = Set<Int>()
    var currentQuestion = Question.placeholder
    var answers: [String] = []

    init() {
        loadScores()
    }

    // MARK: - Questions

    func startGame() {
        activeQuestions = questionBank.books
            .filter { $0.status == .active }
            .flatMap(\.questions)
        answeredQuestions.removeAll()
        newQuestion()
    }

    func newQuestion() {
        if answeredQuestions.count >= activeQuestions.count {
            answeredQuestions.removeAll()
        }
        guard let question = Questions.next(from: activeQuestions, answered: answeredQuestions)
        else { return }

        currentQuestion = question
        answers = ([question.answer] + question.wrong).shuffled()
        questionScore = Self.startingQuestionScore
    }

    // MARK: - Score

    func correct() {
        answeredQuestions.insert(currentQuestion.id)
        withAnimation {
            gameScore += questionScore
        }
    }

    func endGame() {
        recentScores = Scores.recording(gameScore, in: recentScores)
        saveScores()
        gameScore = 0
        activeQuestions = []
        answeredQuestions.removeAll()
    }

    // MARK: - Persistence

    private func saveScores() {
        do {
            let data = try JSONEncoder().encode(recentScores)
            try data.write(to: savePath)
        } catch {
            print("Unable to save data: \(error)")
        }
    }

    func loadScores() {
        do {
            let data = try Data(contentsOf: savePath)
            recentScores = Scores.normalized(try JSONDecoder().decode([Int].self, from: data))
        } catch {
            recentScores = Scores.empty
        }
    }
}
