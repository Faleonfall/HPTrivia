import Testing

@testable import HPTrivia

// Fixtures. Ids are unique across books so a pool can mix them freely.
private func sample(id: Int, book: Int) -> Question {
    Question(
        id: id,
        question: "Question \(id)",
        answer: "Answer \(id)",
        wrong: ["Wrong A", "Wrong B", "Wrong C"],
        book: book,
        hint: "Hint \(id)"
    )
}

// Two questions in book 1, one in book 2, one in an out of range book.
private let mixed = [
    sample(id: 1, book: 1),
    sample(id: 2, book: 1),
    sample(id: 3, book: 2),
    sample(id: 4, book: 99),
]

private let pool = [
    sample(id: 1, book: 1),
    sample(id: 2, book: 1),
    sample(id: 3, book: 1),
]

struct QuestionGroupingTests {

    @Test func groupsQuestionsByBookNumber() {
        let grouped = Questions.byBook(mixed)
        #expect(grouped[1].map(\.id) == [1, 2])
        #expect(grouped[2].map(\.id) == [3])
    }

    @Test func slotZeroStaysEmpty() {
        #expect(Questions.byBook(mixed)[0].isEmpty)
    }

    @Test func outOfRangeBookIsDropped() {
        let all = Questions.byBook(mixed).flatMap { $0 }
        #expect(all.contains { $0.id == 4 } == false)
    }

    @Test func alwaysReturnsOneBucketPerBook() {
        #expect(Questions.byBook([]).count == Questions.bucketCount)
        #expect(Questions.byBook(mixed).count == Questions.bucketCount)
    }
}

struct QuestionPickerTests {

    @Test func answeredQuestionsDropOut() {
        #expect(Questions.remaining(in: pool, answered: [1, 2]).map(\.id) == [3])
    }

    @Test func exhaustedPoolComesBackWhole() {
        #expect(Questions.remaining(in: pool, answered: [1, 2, 3]).count == pool.count)
    }

    @Test func nextNeverReturnsAnAnsweredQuestion() {
        for _ in 0..<50 {
            #expect(Questions.next(from: pool, answered: [1, 3])?.id == 2)
        }
    }

    @Test func emptyPoolReturnsNil() {
        #expect(Questions.next(from: [], answered: []) == nil)
    }
}

struct ScoreTests {

    @Test func newestScoreLandsFirst() {
        #expect(Scores.recording(42, in: [10, 20, 30]) == [42, 10, 20])
    }

    @Test func oldestScoreFallsOff() {
        var scores = Scores.empty
        for score in [1, 2, 3, 4] {
            scores = Scores.recording(score, in: scores)
        }
        #expect(scores == [4, 3, 2])
    }

    @Test func shortHistoryIsPadded() {
        #expect(Scores.normalized([7]) == [7, 0, 0])
    }

    @Test func longHistoryIsTrimmed() {
        #expect(Scores.normalized([1, 2, 3, 4, 5]) == [1, 2, 3])
    }

    @Test func emptyHasOneSlotPerRecentGame() {
        #expect(Scores.empty == [0, 0, 0])
        #expect(Scores.empty.count == Scores.slots)
    }
}
