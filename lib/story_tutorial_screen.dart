import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme.dart';
import 'home_screen.dart';

class StoryTutorialScreen extends StatefulWidget {
  const StoryTutorialScreen({super.key});

  @override
  State<StoryTutorialScreen> createState() => _StoryTutorialScreenState();
}

class _StoryTutorialScreenState extends State<StoryTutorialScreen> with SingleTickerProviderStateMixin {
  final int size = 10;
  int step = 1;
  String title = "";
  String subtitle = "";
  
  Set<int> targets = {};
  Set<int> filled = {};
  Map<int, Color> overrides = {};
  bool allowTap = false;
  bool _showNextButton = false;
  bool _showSwipePrompt = false;
  late AnimationController _swipeController;

  @override
  void initState() {
    super.initState();
    _swipeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _startNeighborsSequence();
  }

  @override
  void dispose() {
    // It's important to dispose of controllers to free up resources.
    _swipeController.dispose();
    super.dispose();
  }

  void _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen(initialTab: 0)),
    );
  }

  void _onCellTap(int index) {
    if (!allowTap || !targets.contains(index)) return;
    if (filled.contains(index)) return; // Prevents double-triggering during drag
    
    setState(() {
      filled.add(index);
    });

    if (filled.length == targets.length) {
      allowTap = false;
      if (step == 1) _playNeighborsAnimation();
      else if (step == 2) _playDeathAnimation();
      else if (step == 3) _playSurvivalAnimation();
      else if (step == 4) _playOverpopAnimation();
      else if (step == 5) _playBirthAnimation();
      else if (step == 6) _playWinLoseAnimation();
    }
  }

  void _startSequence(int s) {
    if (s == 1) _startNeighborsSequence();
    else if (s == 2) _startDeathSequence();
    else if (s == 3) _startSurvivalSequence();
    else if (s == 4) _startOverpopSequence();
    else if (s == 5) _startBirthSequence();
    else if (s == 6) _startWinLoseSequence();
  }

  void _onNextPressed() {
    if (!_showNextButton) return;
    if (step == 6) {
      _finish();
      return;
    }
    setState(() {
      _showNextButton = false;
    });
    _startSequence(step + 1);
  }

  void _onBackPressed() {
    if (step > 1) {
      setState(() {
        _showNextButton = false;
      });
      _startSequence(step - 1);
    }
  }

  // --- STEP 1: NEIGHBORS ---
  void _startNeighborsSequence() {
    setState(() {
      step = 1;
      title = "The Grid";
      subtitle = "Every cell has up to 8 neighbors. Tap the glowing cell to see them.";
      targets = {44};
      filled.clear();
      overrides.clear();
      allowTap = true;
    });
  }

  Future<void> _playNeighborsAnimation() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => subtitle = "These 8 surrounding cells determine if it lives or dies.");

    List<int> neighbors = [33, 34, 35, 43, 45, 53, 54, 55];

    // Pulse the 8 neighbors in yellow
    for (int i = 0; i < 2; i++) {
      setState(() {
        for (var n in neighbors) overrides[n] = Colors.yellowAccent.withOpacity(0.6);
      });
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      setState(() => overrides.clear());
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
    }

    // Keep them highlighted for a moment
    setState(() {
      for (var n in neighbors) overrides[n] = Colors.yellowAccent.withOpacity(0.6);
    });
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    setState(() => _showNextButton = true);
  }

  // --- STEP 2: DEATH ---
  void _startDeathSequence() {
    setState(() {
      step = 2;
      title = "Rule 1: Isolation";
      subtitle = "Tap the 2 glowing cells to give them life.";
      targets = {44, 45};
      filled.clear();
      overrides.clear();
      allowTap = true;
    });
  }

  Future<void> _playDeathAnimation() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => subtitle = "With only 1 neighbor, they are too lonely to survive...");

    // Blink red twice
    for (int i = 0; i < 2; i++) {
      setState(() { overrides[44] = Colors.redAccent; overrides[45] = Colors.redAccent; });
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      setState(() { overrides[44] = green; overrides[45] = green; });
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
    }

    setState(() { filled.clear(); overrides.clear(); });
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _showNextButton = true);
  }

  // --- STEP 3: SURVIVAL ---
  void _startSurvivalSequence() {
    setState(() {
      step = 3;
      title = "Rule 2: Balance";
      subtitle = "Tap 4 glowing cells to form a stable community.";
      targets = {44, 45, 54, 55};
      filled.clear();
      allowTap = true;
    });
  }

  Future<void> _playSurvivalAnimation() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => subtitle = "Perfect balance! With exactly 2 or 3 neighbors, they survive happily.");

    // Pulse bright green
    for (int i = 0; i < 2; i++) {
      setState(() { for (var t in targets) overrides[t] = Colors.white; });
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      setState(() { for (var t in targets) overrides[t] = green; });
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
    }
    
    setState(() => overrides.clear());
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _showNextButton = true);
  }

  // --- STEP 4: OVERPOPULATION ---
  void _startOverpopSequence() {
    setState(() {
      step = 4;
      title = "Rule 3: Crowding";
      subtitle = "Tap 5 cells to form a crowded plus (+) shape.";
      targets = {34, 43, 44, 45, 54};
      filled.clear();
      allowTap = true;
    });
  }

  Future<void> _playOverpopAnimation() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => subtitle = "Too crowded! The center cell has 4 neighbors and perishes.");

    // Center blinks red
    for (int i = 0; i < 2; i++) {
      setState(() => overrides[44] = Colors.redAccent);
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      setState(() => overrides[44] = green);
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
    }

    setState(() { filled.remove(44); overrides.clear(); });
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _showNextButton = true);
  }

  // --- STEP 5: BIRTH ---
  void _startBirthSequence() {
    setState(() {
      step = 5;
      title = "Rule 4: Reproduction";
      subtitle = "Tap 3 cells to form an 'L' shape.";
      targets = {44, 45, 54};
      filled.clear();
      allowTap = true;
    });
  }

  Future<void> _playBirthAnimation() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => subtitle = "Life finds a way! The empty corner has exactly 3 neighbors.");

    // 4th corner blinks green and spawns
    for (int i = 0; i < 2; i++) {
      setState(() => overrides[55] = green.withOpacity(0.5));
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      setState(() => overrides[55] = Colors.transparent);
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
    }

    setState(() { filled.add(55); overrides.clear(); });
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _showNextButton = true);
  }

  // --- STEP 6: WIN & LOSE ---
  void _startWinLoseSequence() {
    setState(() {
      step = 6;
      title = "Winning & Losing";
      subtitle = "Tap 3 cells in a row.";
      targets = {44, 45, 46};
      filled.clear();
      allowTap = true;
    });
  }

  Future<void> _playWinLoseAnimation() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => subtitle = "If cells stabilize or loop endlessly, you WIN!");

    // Blinker animation
    for (int i = 0; i < 3; i++) {
      setState(() {
        filled.clear();
        overrides[44] = Colors.transparent; overrides[46] = Colors.transparent;
        overrides[35] = green; overrides[45] = green; overrides[55] = green;
      });
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      setState(() {
        overrides.clear();
        filled.addAll({44, 45, 46});
      });
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
    }

    setState(() {
      filled.clear(); 
      overrides.clear();
      targets.clear(); // Removes the glowing hints so the grid is truly empty
      subtitle = "But if all cells die and the grid becomes completely empty, you LOSE.";
    });
    
    // Blink the empty grid twice to draw attention to it
    for (int i = 0; i < 2; i++) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      setState(() {
        for (int j = 0; j < size * size; j++) {
          overrides[j] = Colors.redAccent.withOpacity(0.15); // Soft red flash
        }
      });
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      setState(() => overrides.clear());
    }

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    setState(() => _showNextButton = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: _finish,
                    child: const Text("SKIP", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  ),
                ),
                const Spacer(),
                Center(
                  child: SizedBox(
                    width: 300,
                    height: 300,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        GestureDetector(
                          onPanUpdate: (details) {
                            if (!allowTap) return;
                            double cellWidth = 300 / size;
                            int col = (details.localPosition.dx / cellWidth).floor();
                            int row = (details.localPosition.dy / cellWidth).floor();
                            if (row >= 0 && row < size && col >= 0 && col < size) {
                              int index = row * size + col;
                              _onCellTap(index);
                            }
                          },
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: size),
                            itemCount: size * size,
                            itemBuilder: (context, index) {
                              bool isTarget = targets.contains(index);
                              bool isFilled = filled.contains(index);
                              Color? overrideColor = overrides[index];
  
                              Color cellColor;
                              if (overrideColor != null) {
                                cellColor = overrideColor;
                              } else if (isFilled) {
                                cellColor = green;
                              } else if (isTarget && !isFilled) {
                                cellColor = green.withOpacity(0.2); // Hint color
                              } else {
                                cellColor = Colors.white.withOpacity(0.05); // Empty
                              }
  
                              return GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => _onCellTap(index),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: const EdgeInsets.all(1.5),
                                  decoration: BoxDecoration(
                                    color: cellColor,
                                    border: Border.all(color: cellColor == green.withOpacity(0.2) ? green.withOpacity(0.5) : Colors.white.withOpacity(0.1)),
                                    borderRadius: BorderRadius.circular(4),
                                    boxShadow: isFilled ? [BoxShadow(color: green.withOpacity(0.6), blurRadius: 8)] : [],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        if (allowTap)
                          Positioned(
                            child: IgnorePointer(
                              child: (step == 2 || step == 6)
                                  ? SlideTransition(
                                      position: Tween<Offset>(begin: const Offset(-0.6, 0), end: const Offset(0.6, 0)).animate(
                                        CurvedAnimation(parent: _swipeController, curve: Curves.easeInOut),
                                      ),
                                      child: Icon(Icons.touch_app, size: 60, color: Colors.white.withOpacity(0.8)),
                                    )
                                  : ScaleTransition(
                                      scale: Tween<double>(begin: 1.0, end: 0.8).animate(
                                        CurvedAnimation(parent: _swipeController, curve: Curves.easeInOut),
                                      ),
                                      child: Icon(Icons.touch_app, size: 60, color: Colors.white.withOpacity(0.8)),
                                    ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: green, fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 80,
                  child: Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  height: 56,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: step > 1 ? _onBackPressed : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: step > 1 ? Colors.white.withOpacity(0.1) : Colors.transparent,
                          foregroundColor: step > 1 ? Colors.white70 : Colors.transparent,
                          disabledBackgroundColor: Colors.transparent,
                          disabledForegroundColor: Colors.transparent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.arrow_back, size: 20, color: step > 1 ? Colors.white70 : Colors.transparent),
                            const SizedBox(width: 8),
                            Text("BACK", style: TextStyle(fontWeight: FontWeight.bold, color: step > 1 ? Colors.white70 : Colors.transparent)),
                          ],
                        ),
                      ),
                      IgnorePointer(
                        ignoring: !_showNextButton,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 800),
                          opacity: _showNextButton ? 1.0 : 0.3,
                          child: ElevatedButton(
                            onPressed: _onNextPressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: green,
                              foregroundColor: bg,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(step == 6 ? "PLAY GAME" : "NEXT", style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                                const SizedBox(width: 8),
                                Icon(step == 6 ? Icons.rocket_launch : Icons.arrow_forward, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }
}