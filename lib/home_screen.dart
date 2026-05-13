import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme.dart';
import 'play_screen.dart';
import 'learn_screen.dart';

class HomeScreen extends StatefulWidget {
  final int initialTab;
  const HomeScreen({super.key, this.initialTab = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int currentTab;

  int birthRule = 3;
  int surviveMin = 2;
  int surviveMax = 3;

  final GlobalKey<PlayScreenState> playScreenKey = GlobalKey<PlayScreenState>();
  final GlobalKey gridKey = GlobalKey();
  final GlobalKey playBtnKey = GlobalKey();
  final GlobalKey ruleLabBtnKey = GlobalKey();
  final GlobalKey learnTabKey = GlobalKey();
  late TutorialCoachMark tutorialCoachMark;

  DateTime _lastTutorialTap = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    currentTab = widget.initialTab;
  }

  void _showRuleLab() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _RuleLabSheet(
          initialBirth: birthRule,
          initialSMin: surviveMin,
          initialSMax: surviveMax,
          onSaveAndPlay: (b, sMin, sMax) {
            setState(() { birthRule = b; surviveMin = sMin; surviveMax = sMax; });
            Navigator.pop(context);
            playScreenKey.currentState?.start(); // Automatically presses play for them!
          },
        );
      }
    );
  }

  void showTutorial() {
    if (currentTab != 0) {
      setState(() => currentTab = 0);
      Future.delayed(const Duration(milliseconds: 300), _initTutorial);
    } else {
      _initTutorial();
    }
  }

  void _advanceTutorial() {
    final now = DateTime.now();
    // 800ms cooldown physically prevents double-jumping while the 600ms animation plays
    if (now.difference(_lastTutorialTap).inMilliseconds < 800) return;
    _lastTutorialTap = now;
    tutorialCoachMark.next();
  }

  void _initTutorial() {
    tutorialCoachMark = TutorialCoachMark(
      targets: _createTargets(),
      colorShadow: Colors.black, // Pure black for better contrast
      paddingFocus: 15,
      opacityShadow: 0.96, // Much darker to hide background text entirely
      focusAnimationDuration: const Duration(milliseconds: 600), // Smooth slide
      unFocusAnimationDuration: const Duration(milliseconds: 600),
      pulseAnimationDuration: const Duration(milliseconds: 1000), // Softer pulse
      hideSkip: true, 
      onClickOverlay: (target) {
        _advanceTutorial();
      },
      onClickTarget: (target) {
        // The package automatically advances 1 step when the target is tapped.
        // Update the timestamp so overlay taps don't double-jump right after.
        _lastTutorialTap = DateTime.now();
      },
    )..show(context: context);
  }

  // A custom widget to make the tutorial text look like a stylized tooltip card
  Widget _buildTutorialContent(String title, String body) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _advanceTutorial,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: card, // Solid background so text doesn't merge with the app
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: green.withOpacity(0.5), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.8),
              blurRadius: 30,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                        color: green, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _lastTutorialTap = DateTime.now();
                    tutorialCoachMark.skip();
                  },
                  child: const Text(
                    "SKIP",
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              body,
              style: const TextStyle(
                  color: Colors.white, fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 16),
            const Text(
              "Tap here to continue",
              style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
            )
          ],
        ),
      ),
    );
  }

  List<TargetFocus> _createTargets() {
    return [
      TargetFocus(
        identify: "gridKey",
        keyTarget: gridKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.RRect,
        radius: 12,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _buildTutorialContent(
                "1. The Grid",
                "Tap these squares to create Live cells (green). Unlit squares are Empty cells.",
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "playBtnKey",
        keyTarget: playBtnKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.RRect,
        radius: 16,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildTutorialContent(
                "2. Start Simulation",
                "Once you've drawn your pattern, tap here to watch the cells evolve!",
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "ruleLabBtnKey",
        keyTarget: ruleLabBtnKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.Circle, // Highlights the tab with a perfect circle
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _buildTutorialContent(
                "3. Change the Laws",
                "Go to the Rule Lab to tweak the rules of life (easy, medium, hard, or custom!).",
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "learnTabKey",
        keyTarget: learnTabKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.Circle, // Highlights the tab with a perfect circle
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildTutorialContent(
                "4. Learn More",
                "Check out this tab to learn how Conway's Game of Life works and what to look out for!",
              );
            },
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      PlayScreen(
        key: playScreenKey,
        birthRule: birthRule,
        surviveMin: surviveMin,
        surviveMax: surviveMax,
        gridKey: gridKey,
        playBtnKey: playBtnKey,
        ruleLabBtnKey: ruleLabBtnKey,
        onHelpTap: showTutorial,
        onRuleLabTap: _showRuleLab,
      ),
      const LearnScreen(),
    ];

    return Scaffold(
      body: pages[currentTab],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 30),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              decoration: BoxDecoration(
                color: card.withOpacity(0.85),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  navItem(0, Icons.grid_view, "Play"),
                  navItem(1, Icons.school, "Learn", key: learnTabKey),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget navItem(int index, IconData icon, String label, {Key? key}) {
    bool active = currentTab == index;

    return GestureDetector(
      key: key,
      onTap: () {
        setState(() {
          currentTab = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 50,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: active ? green.withOpacity(.15) : Colors.transparent,
          border: Border.all(
            color: active ? green.withOpacity(0.3) : Colors.transparent,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: active ? green : Colors.grey,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: active ? green : Colors.grey,
              ),
            )
          ],
        ),
      ),
    );
  }
}

enum RuleMode { easy, medium, hard, custom }

class _RuleLabSheet extends StatefulWidget {
  final int initialBirth;
  final int initialSMin;
  final int initialSMax;
  final Function(int, int, int) onSaveAndPlay;

  const _RuleLabSheet({
    required this.initialBirth,
    required this.initialSMin,
    required this.initialSMax,
    required this.onSaveAndPlay,
  });

  @override
  State<_RuleLabSheet> createState() => _RuleLabSheetState();
}

class _RuleLabSheetState extends State<_RuleLabSheet> {
  late RuleMode _mode;
  late int _b;
  late int _sMin;
  late int _sMax;

  @override
  void initState() {
    super.initState();
    _b = widget.initialBirth;
    _sMin = widget.initialSMin;
    _sMax = widget.initialSMax;
    _determineMode();
  }

  void _determineMode() {
    if (_b == 3 && _sMin == 2 && _sMax == 3) {
      _mode = RuleMode.easy;
    } else if (_b == 3 && _sMin == 3 && _sMax == 3) {
      _mode = RuleMode.medium;
    } else if (_b == 4 && _sMin == 4 && _sMax == 4) {
      _mode = RuleMode.hard;
    } else {
      _mode = RuleMode.custom;
    }
  }

  void _setMode(RuleMode m) {
    setState(() {
      _mode = m;
      if (m == RuleMode.easy) {
        _b = 3; _sMin = 2; _sMax = 3;
      } else if (m == RuleMode.medium) {
        _b = 3; _sMin = 3; _sMax = 3;
      } else if (m == RuleMode.hard) {
        _b = 4; _sMin = 4; _sMax = 4;
      }
    });
  }

  Widget _buildModeCard(RuleMode m, String title, String subtitle) {
    bool active = _mode == m;
    return GestureDetector(
      onTap: () => _setMode(m),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: active ? green.withOpacity(0.15) : card,
          border: Border.all(color: active ? green : Colors.white12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              active ? Icons.radio_button_checked : Icons.radio_button_off,
              color: active ? green : Colors.grey,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: active ? green : Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.4)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 24, left: 24, right: 24,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("RULE LAB", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildModeCard(RuleMode.easy, "Easy (Standard)", "Birth: 3 cells | Survive: 2-3 cells\nPerfect balance. You can easily reach a stable state."),
            _buildModeCard(RuleMode.medium, "Medium", "Birth: 3 cells | Survive: 3 cells\nCells become empty easily. You will lose about 60% of the time."),
            _buildModeCard(RuleMode.hard, "Hard", "Birth: 4 cells | Survive: 4 cells\nHarsh environment. You will lose almost every time."),
            _buildModeCard(RuleMode.custom, "Custom", "Set your own laws of physics."),
            
            if (_mode == RuleMode.custom) ...[
              const SizedBox(height: 16),
              const Text("Neighbors required for BIRTH", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text("These many live neighbor cells are required for an Empty cell to become a Live cell.", style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.3)),
              Slider(
                value: _b.toDouble(),
                min: 0, max: 8, divisions: 8,
                label: _b.toString(),
                onChanged: (v) => setState(() => _b = v.toInt()),
              ),
              const SizedBox(height: 8),
              const Text("Neighbors required for SURVIVAL", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text("These many live neighbor cells are required for a Live cell to stay a Live cell.", style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.3)),
              RangeSlider(
                values: RangeValues(_sMin.toDouble(), _sMax.toDouble()),
                min: 0, max: 8, divisions: 8,
                labels: RangeLabels(_sMin.toString(), _sMax.toString()),
                onChanged: (v) => setState(() {
                  _sMin = v.start.toInt();
                  _sMax = v.end.toInt();
                }),
              ),
            ],
            
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: green,
                  foregroundColor: bg,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => widget.onSaveAndPlay(_b, _sMin, _sMax),
                child: const Text("SAVE AND PLAY", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              ),
            )
          ],
        ),
      ),
    );
  }
}