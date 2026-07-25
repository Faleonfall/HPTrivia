import Foundation

// The seven books and their questions. Statuses persist to the documents
// directory, so a fresh install falls back to the bundled starter set.
@Observable
final class QuestionBank {
    // Books 1 and 2 ship on, 3 ships off, 4 to 7 are purchases.
    private static let starterStatuses: [BookStatus] = [
        .active, .active, .inactive, .locked, .locked, .locked, .locked,
    ]

    private let savePath = FileManager.documentsDirectory.appending(path: "BookStatuses")

    var books: [Book] = []

    init() {
        loadStatus()
    }

    // MARK: - Questions

    private func decodeQuestions() -> [Question] {
        guard let url = Bundle.main.url(forResource: "trivia", withExtension: "json") else {
            return []
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([Question].self, from: data)
        } catch {
            print("Error decoding JSON data: \(error)")
            return []
        }
    }

    private func populateBooks(with questions: [[Question]]) {
        books = Self.starterStatuses.enumerated().map { index, status in
            let id = index + 1
            return Book(id: id, image: "hp\(id)", questions: questions[id], status: status)
        }
    }

    // MARK: - Status

    func changeStatus(of id: Int, to status: BookStatus) {
        guard let index = books.firstIndex(where: { $0.id == id }) else { return }
        books[index].status = status
    }

    func saveStatus() {
        do {
            let data = try JSONEncoder().encode(books)
            try data.write(to: savePath)
        } catch {
            print("Unable to save data: \(error)")
        }
    }

    func loadStatus() {
        do {
            let data = try Data(contentsOf: savePath)
            books = try JSONDecoder().decode([Book].self, from: data)
        } catch {
            populateBooks(with: Questions.byBook(decodeQuestions()))
        }
    }
}
