# Life Lab: Conway's Game of Life

A beautiful, interactive, and fully-featured Flutter implementation of Conway's Game of Life. 

This project explores cellular automata through a modern, responsive UI. It goes beyond the classic rules, allowing users to tweak birth and survival conditions to discover alternate universes (like HighLife), all while providing an intuitive onboarding experience for newcomers.

## 🧠 How It Works

Conway's Game of Life is a "zero-player game" and cellular automaton devised by mathematician John Horton Conway. It takes place on an infinite two-dimensional orthogonal grid of square cells, each of which is in one of two possible states, *alive* or *dead*.

In **Life Lab**, you are the "creator". You set up the initial configuration (the *seed*) by tapping cells on the grid to bring them to life. Once you press **"Let's Go!"**, the simulation takes over, and the grid evolves generation by generation without any further input.

### The Rules of Life (Classic Conway)
Every cell interacts with its eight horizontal, vertical, and diagonal neighbors. At each step in time (a *generation*), the following transitions occur:
1. **Underpopulation:** Any live cell with fewer than two live neighbors dies.
2. **Survival:** Any live cell with two or three live neighbors lives on to the next generation.
3. **Overpopulation:** Any live cell with more than three live neighbors dies.
4. **Reproduction:** Any dead cell with exactly three live neighbors becomes a live cell.

The beauty of the Game of Life is that complex, emergent behaviors arise from these incredibly simple rules. You'll see static "blocks", oscillating "blinkers", and moving "gliders" emerge naturally!

## 🌟 Features

- **Interactive Grid (Play Screen)**: A dynamic 20x20 (or larger) interactive grid. Tap cells to toggle their lifecycle state, then hit "Let's Go!" to watch the simulation unfold.
- **Customizable Rules (Rules Screen)**: Don't just stick to Conway's classic B3/S23 rules. Use sliders to adjust the exact number of neighbors required for cell birth and survival.
- **Learn & Discover (Learn Screen)**: A built-in FAQ and guide explaining what Conway's Game of Life is, what "Gliders" and "Blinkers" are, and how cellular automata work.
- **Tutorial Onboarding**: Integrated `TutorialCoachMark` walkthrough to guide first-time users through the core mechanics.
- **Robust Test Architecture**: A production-grade testing suite that covers unit logic, integration interactions, regression bug-catching, and end-to-end system lifecycles.

## 🚀 Getting Started

### Prerequisites
Before you begin, ensure you have the following installed:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version 3.3.0 or higher)
- [Dart SDK](https://dart.dev/get-dart)
- An IDE (like VS Code or Android Studio) with Flutter extensions.

### Installation
1. **Clone the repository:**
   ```bash
   git clone <your-repo-url>
   cd CGL
   ```
2. **Fetch dependencies:**
   ```bash
   flutter pub get
   ```

### Running the App
To launch the application on an emulator or a connected physical device, run:
```bash
flutter run
```

## 🧪 Testing

This project boasts a comprehensive, custom-built test suite specifically engineered to avoid common Flutter testing pitfalls (like lazy rendering bugs and dangling timers). 

All tests are aggregated into a master runner for clean CI/CD execution.

To run the entire test suite and view the consolidated summary:
```bash
flutter test test/all_tests.dart
```

### Test Suite Structure
The `test/` directory mirrors the `lib/` directory precisely:
- **Unit Tests**: Validates private simulation math (`countNeighbors`, `nextGeneration`) via dynamic state dispatch without relying on UI overhead.
- **Integration Tests**: Ensures UI components (buttons, sliders, grid cells) react and bind correctly.
- **System Tests**: End-to-end user flows, testing scenarios like `EMPTY GRID`, `STABILIZED`, and `ENDLESS LOOP` lifecycle detections.
- **Regression Tests**: Confirms timers are aggressively cancelled upon disposal and state leaks are prevented.

## 🛠️ Built With

- **Flutter & Dart** - Core framework and language.
- **shared_preferences** - For persisting the first-time user tutorial state.
- **tutorial_coach_mark** - For creating the interactive user onboarding overlay.
- **flutter_launcher_icons** - For custom app iconography.


