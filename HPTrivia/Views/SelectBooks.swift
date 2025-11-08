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
    
    @EnvironmentObject private var store: Store
    
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
                            if book.status == .active || (book.status == .locked && store.purchaseIDs.contains("hp\(book.id)")) {
                                ActiveBook(book: book)
                                    .onTapGesture {
                                        game.bookQuestions.changeStatus(of: book.id, to: .inactive)
                                        store.saveStatus()
                                    }
                                    .task {
                                        // Ensure active on appear if purchased
                                        game.bookQuestions.changeStatus(of: book.id, to: .active)
                                        store.saveStatus()
                                    }
                            } else if book.status == .inactive {
                                InactiveBook(book: book)
                                    .onTapGesture {
                                        // Toggle to active
                                        game.bookQuestions.changeStatus(of: book.id, to: .active)
                                        store.saveStatus()
                                    }
                            } else {
                                LockedBook(book: book)
                                    .onTapGesture {
                                        // Books 4...7 are purchasable; align to Store.products index 0...3
                                        let productIndex = book.id - 4
                                        guard productIndex >= 0, productIndex < store.products.count else { return }
                                        let product = store.products[productIndex]
                                        
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
                    dismiss()
                }
                .doneButton()
                .disabled(!activeBooks)
            }
            .foregroundStyle(.black)
        }
        .interactiveDismissDisabled(!activeBooks)
    }
}

#Preview {
    SelectBooks()
        .environmentObject(Store())
        .environment(Game())
}
