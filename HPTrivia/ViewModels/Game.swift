//
//  Game.swift
//  HPTrivia
//
//  Created by Volodymyr Kryvytskyi on 03.12.2024.
//

import SwiftUI

@Observable
class Game {
    private let savePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appending(path: "RecentScore")
    
    var bookQuestions = BookQuestions()
    
    var gameScore = 0
    var questionScore = 5
    var recentScores = [0, 0, 0]
    
    var activeQuestion: [Question] = []
    var answeredQuestions: [Int] = []
    var currentQuestion = try! JSONDecoder().decode([Question].self, from: Data(contentsOf: Bundle.main.url(forResource: "trivia", withExtension: "json")!))[0]
    var answers: [String] = []
    
    init() {
        loadScores()
    }
    
    func startGame() {
        for book in bookQuestions.books {
            if book.status == .active {
                for question in book.questions {
                    activeQuestion.append(question)
                }
            }
        }
        
        newQuestion()
    }
    
    func newQuestion() {
        if answeredQuestions.count == activeQuestion.count {
            answeredQuestions = []
        }
        
        currentQuestion = activeQuestion.randomElement()!
        
        while answeredQuestions.contains(currentQuestion.id) {
            currentQuestion = activeQuestion.randomElement()!
        }
        
        answers = []
        
        answers.append(currentQuestion.answer)
        
        for answer in currentQuestion.wrong {
            answers.append(answer)
        }
        
        answers.shuffle()
        
        questionScore = 5
    }
    
    func correct() {
        answeredQuestions.append(currentQuestion.id)
        
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
        activeQuestion = []
        answeredQuestions = []
    }
    
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
