import SwiftUI

@Observable
class Game {
    private let savePath = FileManager.documentsDirectory.appending(path: "RecentScore")

    var questionBank = QuestionBank()

    var gameScore = 0
    var questionScore = 5
    var recentScores = [0, 0, 0]

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
        guard !activeQuestions.isEmpty else { return }
        if answeredQuestions.count == activeQuestions.count {
            answeredQuestions.removeAll()
        }
        let unansweredQuestions = activeQuestions.filter { !answeredQuestions.contains($0.id) }
        currentQuestion = unansweredQuestions.randomElement() ?? activeQuestions[0]
        answers = ([currentQuestion.answer] + currentQuestion.wrong).shuffled()
        questionScore = 5
    }

    // MARK: - Score

    func correct() {
        answeredQuestions.insert(currentQuestion.id)
        withAnimation {
            gameScore += questionScore
        }
    }

    func endGame() {
        recentScores[2] = recentScores[1]
        recentScores[1] = recentScores[0]
        recentScores[0] = gameScore
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
            recentScores = try JSONDecoder().decode([Int].self, from: data)
        } catch {
            recentScores = [0, 0, 0]
        }
    }
}
