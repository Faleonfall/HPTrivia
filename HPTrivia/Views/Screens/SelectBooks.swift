import SwiftUI

struct SelectBooks: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(Store.self) private var store
    @Environment(Game.self) private var game

    var activeBooks: Bool {
        game.questionBank.books.contains { $0.status == .active }
    }

    var body: some View {
        ZStack {
            InfoBackgroundImage()
            VStack {
                Text("Which books would you like to see questions from?")
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding()
                ScrollView {
                    LazyVGrid(columns: [GridItem(), GridItem()]) {
                        ForEach(game.questionBank.books) { book in
                            if book.status == .active
                                || (book.status == .locked && store.purchased.contains(book.image))
                            {
                                BookCover(book: book, state: .active)
                                    .onTapGesture {
                                        game.questionBank.changeStatus(of: book.id, to: .inactive)
                                    }
                                    .task {
                                        game.questionBank.changeStatus(of: book.id, to: .active)
                                    }
                            } else if book.status == .inactive {
                                BookCover(book: book, state: .inactive)
                                    .onTapGesture {
                                        game.questionBank.changeStatus(of: book.id, to: .active)
                                    }
                            } else {
                                BookCover(book: book, state: .locked)
                                    .onTapGesture {
                                        Task {
                                            let purchased = await store.purchase(book.image)
                                            if purchased {
                                                game.questionBank.changeStatus(
                                                    of: book.id, to: .active)
                                            }
                                        }
                                    }
                            }
                        }
                    }
                    .padding()
                }
                if !activeBooks {
                    Text("You must select at least one book to play.")
                        .multilineTextAlignment(.center)
                }
                Button("Done") {
                    game.questionBank.saveStatus()
                    dismiss()
                }
                .doneButton()
                .disabled(!activeBooks)
            }
            .foregroundStyle(.black)
        }
        .interactiveDismissDisabled()
        .task {
            await store.loadProducts()
        }
    }
}

// MARK: - Cover

private struct BookCover: View {
    let book: Book
    let state: State

    enum State {
        case active, inactive, locked
    }

    var body: some View {
        ZStack(alignment: state == .locked ? .center : .bottomTrailing) {
            Image(book.image)
                .resizable()
                .scaledToFit()
                .shadow(radius: 7)
                .overlay(overlay)
            statusIcon
        }
    }

    @ViewBuilder
    private var overlay: some View {
        switch state {
        case .active:
            EmptyView()
        case .inactive:
            Rectangle().opacity(0.33)
        case .locked:
            Rectangle().opacity(0.75)
        }
    }

    @ViewBuilder
    private var statusIcon: some View {
        switch state {
        case .active:
            Image(systemName: "checkmark.circle.fill")
                .font(.largeTitle)
                .imageScale(.large)
                .foregroundColor(.green)
                .shadow(radius: 1)
                .padding(3)
        case .inactive:
            Image(systemName: "circle")
                .font(.largeTitle)
                .imageScale(.large)
                .foregroundStyle(.green.opacity(0.5))
                .shadow(radius: 1)
                .padding(3)
        case .locked:
            Image(systemName: "lock.fill")
                .font(.largeTitle)
                .imageScale(.large)
                .shadow(color: .white, radius: 2)
        }
    }
}

#Preview {
    SelectBooks()
        .environment(Store())
        .environment(Game())
}
