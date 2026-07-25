import Foundation

// Pure game rules. No UI and no persistence, so they stay testable.

// MARK: - Questions

enum Questions {
    // Seven books plus the unused zero slot.
    static let bucketCount = 8

    // Buckets decoded questions by book number. Index 0 stays empty because
    // book numbering starts at 1.
    static func byBook(_ questions: [Question]) -> [[Question]] {
        var grouped = Array(repeating: [Question](), count: bucketCount)
        for question in questions where grouped.indices.contains(question.book) {
            grouped[question.book].append(question)
        }
        return grouped
    }

    // Answered questions drop out until the pool runs dry, then the whole pool
    // comes back so a game never stalls.
    static func remaining(in questions: [Question], answered: Set<Int>) -> [Question] {
        let unanswered = questions.filter { !answered.contains($0.id) }
        return unanswered.isEmpty ? questions : unanswered
    }

    static func next(from questions: [Question], answered: Set<Int>) -> Question? {
        remaining(in: questions, answered: answered).randomElement()
    }
}

// MARK: - Scores

enum Scores {
    static let slots = 3
    static let empty = Array(repeating: 0, count: slots)

    // Newest score first.
    static func recording(_ score: Int, in recent: [Int]) -> [Int] {
        normalized([score] + recent)
    }

    // Pads short histories and trims long ones, so a truncated or hand-edited
    // save file cannot crash the score list.
    static func normalized(_ scores: [Int]) -> [Int] {
        Array((scores + empty).prefix(slots))
    }
}
