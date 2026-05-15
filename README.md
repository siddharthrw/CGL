# Life Lab - Conway's Game of Life

![Life Lab Demo](lib/assets/gif_readme.gif)

**Life Lab** is a premium, highly interactive implementation of Conway's Game of Life built with Flutter. It combines the fascinating mathematical beauty of cellular automata with a modern, glassmorphic design and a robust professional test suite.

## 🧬 Features

- **Interactive Life Lab**: Tap or pan on the grid to bring cells to life. Watch patterns emerge and evolve in real-time.
- **Dynamic Rule System**: Don't just play by the standard rules. Use the "Rule Lab" to adjust the neighbors required for birth and survival to discover entirely new universes.
- **Educational Suite**: 
  - **Learn Screen**: Explore the history and mechanics of the game through a detailed FAQ and guide.
  - **Interactive Tutorial**: A step-by-step onboarding experience to get you started.
- **Win/Loss Mechanics**: The game detects when your colony has stabilized, entered an endless loop, or completely vanished, providing a sense of achievement and feedback.
- **Premium Aesthetics**: Designed with a sleek dark theme, neon green accents, and smooth micro-animations.
- **Optimized Performance**: Uses background isolates for heavy simulation calculations on the Welcome Screen to ensure a buttery-smooth 60fps experience.

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.3.0)
- Dart SDK

### Installation
1. Clone the repository.
2. Run `flutter pub get` to fetch dependencies.
3. Run `flutter run` on your preferred device.

## 🧪 Testing

Life Lab comes with a professional-grade test suite consisting of **28 deterministic tests** covering Unit, Integration, System, and Regression testing.

To run the full suite:
```bash
flutter test test/all_tests.dart
```

This suite validates:
- **Core Engine**: Birth, survival, and neighbor counting logic.
- **UI & Navigation**: Tab switching, slider updates, and tutorial flows.
- **End-to-End Simulation**: Accurate detection of stable states, endless loops, and total extinction.
- **Performance & Cleanup**: Proper timer and animation controller disposal.

## 🛠️ Technical Details
- **UI Framework**: Flutter (Material 3)
- **State Management**: StatefulWidgets with optimized `setState` for high-performance grid rendering.
- **Packages**: `tutorial_coach_mark`, `share_plus`, `url_launcher`, `shared_preferences`.
- **Custom Viewport Logic**: Uses fixed physical size testing strategies to ensure UI consistency across all devices.

---
Built with ❤️ by Randomwalk.ai
