# HP Trivia

A SwiftUI trivia game inspired by the Wizarding World. Test your HP knowledge with animated questions, scoring, hints, book reveals, sound effects, and StoreKit-backed unlocks.

## Features

- HP-themed trivia questions grouped by book
- Animated home screen, gameplay transitions, and answer feedback
- Hint and book reveal mechanics that affect score
- Recent score tracking
- Sound effects and menu music using AVFAudio
- StoreKit configuration for simulated in-app purchases
- Generated launch screen, no storyboard

## Tech

- Swift 6
- SwiftUI
- iOS 18+
- AVFAudio
- StoreKit

## Structure

```text
HPTrivia/
  Controllers/   Game state, question bank, StoreKit
  Models/        Book, Question, theme helpers
  Views/         Screens and reusable components
  Resources/     Assets, audio, StoreKit config, trivia data
```
