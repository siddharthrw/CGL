import 'dart:async';
import 'package:flutter/material.dart';
import 'theme.dart';
import 'home_screen.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _finishTutorial(int targetTab) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen(initialTab: targetTab)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildSlide(
                    visual: const _MiniDemo(frames: _toad, crossAxisCount: 6),
                    title: "About the Game",
                    description:
                        "Conway's Game of Life is a fascinating 'zero-player game'. As the creator, you populate the grid with an initial pattern of cells. Once you start the simulation, the world evolves entirely on its own based on pure mathematics.",
                  ),
                  _buildSlide(
                    visual: const _MiniDemo(frames: _drawing, crossAxisCount: 5),
                    title: "The Grid & Cells",
                    description:
                        "The universe is an infinite 2D grid. Each square is a 'cell' that can either be Alive (bright green) or Dead (dark space).\n\nBefore running the simulation, simply tap the squares to draw your starting community.",
                  ),
                  _buildSlide(
                    visual: const _MiniDemo(frames: _blinker, crossAxisCount: 5),
                    title: "The Rules of Life",
                    description:
                        "Every generation, cells check their 8 surrounding neighbors to see what happens next:\n\n• Survival: 2 or 3 neighbors (Perfect)\n• Death: < 2 (Lonely) or > 3 (Crowded)\n• Birth: Exactly 3 neighbors creates a new cell!",
                  ),
                  _buildSlide(
                    visual: const _MiniDemo(frames: _glider, crossAxisCount: 5),
                    title: "Endless Possibilities",
                    description:
                        "From these simple rules, magical behaviors emerge. You will discover shapes that sit still, patterns that oscillate forever, and 'spaceships' that glide across the board.\n\nDraw, experiment, and see what you can create!",
                  ),
                  _buildFinalSlide(),
                ],
              ),
            ),
            // Bottom Navigation Indicators
            if (_currentPage != 4)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => _controller.jumpToPage(4),
                      child: const Text(
                        "SKIP",
                        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Row(
                      children: List.generate(5, (index) => _buildDot(index)),
                    ),
                    TextButton(
                      onPressed: () {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                      },
                      child: const Text(
                        "NEXT",
                        style: TextStyle(color: green, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              )
            else
              const SizedBox(height: 108), // To keep the layout balanced on the final slide
          ],
        ),
      ),
    );
  }

  Widget _buildSlide({required Widget visual, required String title, required String description}) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          visual,
          const SizedBox(height: 40),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            description,
            textAlign: TextAlign.left,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalSlide() {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.rocket_launch, size: 100, color: green),
          const SizedBox(height: 40),
          const Text(
            "Ready to Evolve?",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "You now know everything you need to begin creating complex patterns.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 50),
          ElevatedButton(
            onPressed: () => _finishTutorial(0), // Tab 0 = Play
            style: ElevatedButton.styleFrom(
              backgroundColor: green,
              foregroundColor: bg,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text("PLAY GAME", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => _finishTutorial(2), // Tab 2 = Learn Lab
            style: OutlinedButton.styleFrom(
              foregroundColor: green,
              side: const BorderSide(color: green, width: 2),
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text("LEARN MORE", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    bool isActive = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? green : Colors.grey.withOpacity(0.5),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _MiniDemo extends StatefulWidget {
  final List<List<int>> frames;
  final int crossAxisCount;

  const _MiniDemo({required this.frames, this.crossAxisCount = 5});

  @override
  State<_MiniDemo> createState() => _MiniDemoState();
}

class _MiniDemoState extends State<_MiniDemo> {
  int _currentIndex = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      if (mounted && widget.frames.length > 1) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % widget.frames.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final frame = widget.frames[_currentIndex];
    return SizedBox(
      width: 140,
      height: 140,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.crossAxisCount,
        ),
        itemCount: frame.length,
        itemBuilder: (context, index) {
          bool alive = frame[index] == 1;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.all(2.0),
            decoration: BoxDecoration(
              color: alive ? green : card,
              borderRadius: BorderRadius.circular(4),
              boxShadow: alive ? [BoxShadow(color: green.withOpacity(0.6), blurRadius: 8)] : [],
            ),
          );
        },
      ),
    );
  }
}

// Demo Patterns
const _toad = [
  [0,0,0,0,0,0, 0,0,0,0,0,0, 0,0,1,1,1,0, 0,1,1,1,0,0, 0,0,0,0,0,0, 0,0,0,0,0,0],
  [0,0,0,0,0,0, 0,0,0,1,0,0, 0,1,0,0,1,0, 0,1,0,0,1,0, 0,0,1,0,0,0, 0,0,0,0,0,0],
];

const _drawing = [
  [0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0],
  [0,0,0,0,0, 0,0,1,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0],
  [0,0,0,0,0, 0,0,1,0,0, 0,0,0,1,0, 0,0,0,0,0, 0,0,0,0,0],
  [0,0,0,0,0, 0,0,1,0,0, 0,0,0,1,0, 0,1,1,1,0, 0,0,0,0,0],
];

const _blinker = [
  [0,0,0,0,0, 0,0,1,0,0, 0,0,1,0,0, 0,0,1,0,0, 0,0,0,0,0],
  [0,0,0,0,0, 0,0,0,0,0, 0,1,1,1,0, 0,0,0,0,0, 0,0,0,0,0],
];

const _glider = [
  [0,0,1,0,0, 1,0,1,0,0, 0,1,1,0,0, 0,0,0,0,0, 0,0,0,0,0],
  [0,1,0,0,0, 0,1,1,0,0, 1,0,1,0,0, 0,0,0,0,0, 0,0,0,0,0],
  [0,0,1,0,0, 0,0,1,0,0, 0,1,1,1,0, 0,0,0,0,0, 0,0,0,0,0],
  [0,0,0,0,0, 0,1,0,1,0, 0,0,1,1,0, 0,0,1,0,0, 0,0,0,0,0],
];