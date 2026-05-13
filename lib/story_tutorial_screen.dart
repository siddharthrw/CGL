import 'package:flutter/material.dart';
import 'theme.dart';
import 'home_screen.dart';

class StoryTutorialScreen extends StatefulWidget {
  const StoryTutorialScreen({super.key});

  @override
  State<StoryTutorialScreen> createState() => _StoryTutorialScreenState();
}

class _StoryTutorialScreenState extends State<StoryTutorialScreen> {
  final int size = 10;
  int step = 1;
  String title = "";
  String subtitle = "";
  
  Set<int> targets = {};
  Set<int> filled = {};
  Map<int, Color> overrides = {};
  bool allowTap = false;

  @override
  void initState() {
    super.initState();
    _startDeathSequence();
  }

  void _finish() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen(initialTab: 0)),
    );
  }

  void _onCellTap(int index) {
    if (!allowTap || !targets.contains(index)) return;
    
    setState(() {
      filled.add(index);
    });

    if (filled.length == targets.length) {
      allowTap = false;
      if (step == 1) _playDeathAnimation();
      else if (step == 2) _playSurvivalAnimation();
      else if (step == 3) _playOverpopAnimation();
      else if (step == 4) _playBirthAnimation();
    }
  }

  // --- STEP 1: DEATH ---
  void _startDeathSequence() {
    setState(() {
      step = 1;
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
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    _startSurvivalSequence();
  }

  // --- STEP 2: SURVIVAL ---
  void _startSurvivalSequence() {
    setState(() {
      step = 2;
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
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    _startOverpopSequence();
  }

  // --- STEP 3: OVERPOPULATION ---
  void _startOverpopSequence() {
    setState(() {
      step = 3;
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
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    _startBirthSequence();
  }

  // --- STEP 4: BIRTH ---
  void _startBirthSequence() {
    setState(() {
      step = 4;
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
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    
    setState(() {
      step = 5;
      title = "You're Ready!";
      subtitle = "You now know the laws of the universe. Go create life!";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(color: green, fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 60,
                child: Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
                ),
              ),
              const Spacer(),
              Center(
                child: SizedBox(
                  width: 300,
                  height: 300,
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
              ),
              const Spacer(),
              if (step == 5)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _finish,
                    icon: const Icon(Icons.rocket_launch),
                    label: const Text("PLAY GAME", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: green,
                      foregroundColor: bg,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                )
              else
                TextButton(
                  onPressed: _finish,
                  child: const Text("SKIP TUTORIAL", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                )
            ],
          ),
        ),
      ),
    );
  }
}