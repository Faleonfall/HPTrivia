//
//  SelectBooks.swift
//  HPTrivia
//
//  Created by Volodymyr Kryvytskyi on 01.12.2024.
//

import SwiftUI

struct SelectBooks: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(Game.self) private var game
    
    private var store = Store()
    
    var activeBooks: Bool {
        for book in game.bookQuestions.books {
            if book.status == .active {
                return true
            }
        }
        
        return false
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
                        ForEach(game.bookQuestions.books) { book in
                            if book.status == .active || (book.status == .locked && store.purchased.contains(book.image)) {
                                ActiveBook(book: book)
                                    .onTapGesture {
                                        game.bookQuestions.changeStatus(of: book.id, to: .inactive)
                                    }
                                    .task {
                                        game.bookQuestions.changeStatus(of: book.id, to: .active)
                                    }
                            } else if book.status == .inactive {
                                InactiveBook(book: book)
                                    .onTapGesture {
                                        game.bookQuestions.changeStatus(of: book.id, to: .active)
                                    }
                            } else {
                                LockedBook(book: book)
                                    .onTapGesture {
                                        let product = store.products[book.id - 4]
                                        
                                        Task {
                                            await store.purchase(product)
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
                    game.bookQuestions.saveStatus()
                    
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

#Preview {
    SelectBooks()
        .environment(Store())
        .environment(Game())
}
