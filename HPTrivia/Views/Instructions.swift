//
//  Instructions.swift
//  HPTrivia
//
//  Created by Volodymyr Kryvytskyi on 01.12.2024.
//

import SwiftUI

struct Instructions: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            InfoBackgroundImage()
            
            VStack {
                Image(.appiconwithradius)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150)
                    .padding(.top)
                
                ScrollView {
                    Text("How to play")
                        .font(.largeTitle)
                        .padding()
                    
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Welcome to HP Trivia! In this game, you will be asked random questions from the HP books and you must guess the right answer or you will lose points! 😱")
                        
                        Text("Each question is worth 5 points. But if you guess a wrong answer, you loose 1 point.")
                        
                        Text("There are hints in this game. You may press a hint or a book button. It will help you. But these buttons reduces your points too.")
                        
                        Text("When you select the correct answer, you will be awarded all the points left for that question.")
                    }
                    .font(.title3)
                    .padding(.horizontal)
                    
                    Text("Good Luck!")
                        .font(.title)
                }
                .foregroundStyle(.black)
                
                Button("Done") {
                    dismiss()
                }
                .doneButton()
            }
        }
    }
}

#Preview {
    Instructions()
}
