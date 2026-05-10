import Foundation

struct Question: Codable {
    let id: Int
    let question: String
    var answer: String
    var wrong: [String]
    let book: Int
    let hint: String

    static let placeholder = Question(
        id: 0,
        question: "",
        answer: "",
        wrong: [],
        book: 0,
        hint: ""
    )
}
