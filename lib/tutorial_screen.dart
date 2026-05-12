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
                    icon: Icons.info_outline,
                    title: "About the Game",
                    description:
                        "Conway's Game of Life isn't a typical game. It's a 'zero-player game'. You create the initial setup, and the world evolves entirely by itself based on simple mathematical rules.",
                  ),
                  _buildSlide(
                    icon: Icons.grid_on,
                    title: "The Grid",
                    description:
                        "The simulation takes place on a grid of cells. Tap any dark square to bring a cell to life. Once you've drawn your pattern, press 'Let's Go!' to watch the evolution.",
                  ),
                  _buildSlide(
                    icon: Icons.rule,
                    title: "The Rules",
                    description:
                        "Cells die if they get too lonely or too crowded. They survive if they have just the right amount of neighbors, and empty spaces can even birth new cells in perfect conditions!",
                  ),
                  _buildFinalSlide(),
                ],
              ),
            ),
            // Bottom Navigation Indicators
            if (_currentPage != 3)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => _controller.jumpToPage(3),
                      child: const Text(
                        "SKIP",
                        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Row(
                      children: List.generate(4, (index) => _buildDot(index)),
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

  Widget _buildSlide({required IconData icon, required String title, required String description}) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 100, color: green),
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
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
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