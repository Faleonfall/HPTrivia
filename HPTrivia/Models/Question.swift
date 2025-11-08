//
//  Question.swift
//  HPTrivia
//
//  Created by Volodymyr Kryvytskyi on 03.12.2024.
//

import Foundation

struct Question: Codable {
    let id: Int
    let question: String
    var answer: String
    var wrong: [String]
    let book: Int
    let hint: String
    
    // Built from decoded fields; not stored in JSON.
    var answers: [String: Bool] {
        var map: [String: Bool] = [answer: true]
        for w in wrong {
            map[w] = false
        }
        return map
    }
}
