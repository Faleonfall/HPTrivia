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
}
