import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme.dart';
import 'play_screen.dart';
import 'rules_screen.dart';
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
  final GlobalKey rulesTabKey = GlobalKey();
  final GlobalKey learnTabKey = GlobalKey();
  late TutorialCoachMark tutorialCoachMark;

  @override
  void initState() {
    super.initState();
    currentTab = widget.initialTab;
  }

  void showTutorial() {
    if (currentTab != 0) {
      setState(() => currentTab = 0);
      Future.delayed(const Duration(milliseconds: 300), _initTutorial);
    } else {
      _initTutorial();
    }
  }

  void _initTutorial() {
    tutorialCoachMark = TutorialCoachMark(
      targets: _createTargets(),
      colorShadow: Colors.black, // Pure black for better contrast
      textSkip: "SKIP",
      paddingFocus: 15,
      opacityShadow: 0.96, // Much darker to hide background text entirely
      focusAnimationDuration: const Duration(milliseconds: 600), // Smooth slide
      unFocusAnimationDuration: const Duration(milliseconds: 600),
      pulseAnimationDuration: const Duration(milliseconds: 1000), // Softer pulse
    )..show(context: context);
  }

  // A custom widget to make the tutorial text look like a stylized tooltip card
  Widget _buildTutorialContent(String title, String body) {
    return Container(
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
          Text(
            title,
            style: const TextStyle(
                color: green, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: const TextStyle(
                color: Colors.white, fontSize: 15, height: 1.5),
          ),
        ],
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
                "Tap these squares to bring cells to life (green). Empty squares are dead space.",
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
        identify: "rulesTabKey",
        keyTarget: rulesTabKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.Circle, // Highlights the tab with a perfect circle
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildTutorialContent(
                "3. Change the Laws",
                "Go here to tweak the rules of life (how many neighbors are needed for birth and survival).",
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
        onHelpTap: showTutorial,
      ),
      RulesScreen(
        birthRule: birthRule,
        surviveMin: surviveMin,
        surviveMax: surviveMax,
        onBirthChanged: (v) => setState(() => birthRule = v),
        onSurviveMinChanged: (v) => setState(() => surviveMin = v),
        onSurviveMaxChanged: (v) => setState(() => surviveMax = v),
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
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  navItem(0, Icons.grid_view, "Play"),
                  navItem(1, Icons.tune, "Rules", key: rulesTabKey),
                  navItem(2, Icons.school, "Learn", key: learnTabKey),
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
          horizontal: 18,
          vertical: 10,
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