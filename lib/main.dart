import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const LifeLab());
}

const bg = Color(0xff030303);
const card = Color(0xff111111);
const green = Color(0xff00ff88);

class LifeLab extends StatelessWidget {
  const LifeLab({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: bg,
        brightness: Brightness.dark,
        sliderTheme: SliderThemeData(
          activeTrackColor: green,
          inactiveTrackColor: green.withOpacity(0.1),
          thumbColor: green,
          overlayColor: green.withOpacity(0.2),
          trackHeight: 6,
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() =>
      _WelcomeScreenState();
}

class _WelcomeScreenState
    extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController glow;
  late Timer bgTimer;
  
  final int bgRows = 40;
  final int bgCols = 15;
  late List<List<int>> bgGrid;

  @override
  void initState() {
    super.initState();

    glow = AnimationController(
      vsync: this,
      duration:
      const Duration(seconds: 2),
    )..repeat(reverse: true);

    final random = Random();
    bgGrid = List.generate(
      bgRows,
      (_) => List.generate(bgCols, (_) => random.nextDouble() < 0.25 ? 1 : 0),
    );

    bgTimer = Timer.periodic(const Duration(milliseconds: 600), (_) {
      if (mounted) {
        setState(() {
          bgGrid = _nextGen(bgGrid);
        });
      }
    });
  }

  List<List<int>> _nextGen(List<List<int>> currentGrid) {
    List<List<int>> next = List.generate(bgRows, (_) => List.filled(bgCols, 0));
    for (int r = 0; r < bgRows; r++) {
      for (int c = 0; c < bgCols; c++) {
        int neighbors = 0;
        for (int dr = -1; dr <= 1; dr++) {
          for (int dc = -1; dc <= 1; dc++) {
            if (dr == 0 && dc == 0) continue;
            int nr = r + dr;
            int nc = c + dc;
            if (nr >= 0 && nr < bgRows && nc >= 0 && nc < bgCols) {
              neighbors += currentGrid[nr][nc];
            }
          }
        }
        if (currentGrid[r][c] == 1) {
          next[r][c] = (neighbors == 2 || neighbors == 3) ? 1 : 0;
        } else {
          next[r][c] = (neighbors == 3) ? 1 : 0;
        }
      }
    }
    return next;
  }

  @override
  void dispose() {
    bgTimer.cancel();
    glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.2,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: bgCols,
                  ),
                  itemCount: bgRows * bgCols,
                  itemBuilder: (context, index) {
                    int r = index ~/ bgCols;
                    int c = index % bgCols;
                    bool alive = bgGrid[r][c] == 1;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      margin: const EdgeInsets.all(1.5),
                      decoration: BoxDecoration(
                        color: alive ? green : Colors.transparent,
                        border: Border.all(
                          color: alive ? green : green.withOpacity(0.2), 
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: alive
                            ? [
                                BoxShadow(
                                  color: green.withOpacity(0.5),
                                  blurRadius: 5,
                                )
                              ]
                            : [],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: glow,
                  builder: (_, __) {
                    return Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: green.withOpacity(.08),
                        boxShadow: [
                          BoxShadow(
                            color: green.withOpacity(.2 + glow.value * .3),
                            blurRadius: 20 + glow.value * 30,
                          )
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                          color: green,
                        size: 50,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
                const Text(
                  "WELCOME TO",
                  style: TextStyle(
                    color: Colors.grey,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "CONWAY'S\nGAME OF LIFE",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Touch • Create • Evolve",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 50),
                SizedBox(
                  width: 200,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 800),
                          pageBuilder: (_, __, ___) => const HomeScreen(),
                          transitionsBuilder: (_, animation, __, child) {
                            return FadeTransition(
                              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                                CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeInOut,
                                ),
                              ),
                              child: ScaleTransition(
                                scale: Tween<double>(
                                  begin: 0.85,
                                  end: 1.0,
                                ).animate(
                                  CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOutCubic,
                                  ),
                                ),
                                child: child,
                              ),
                            );
                          },
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: green,
                      foregroundColor: bg,
                      elevation: 10,
                      shadowColor: green.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "ENTER THE GRID",
                      style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen> {

  int currentTab = 0;

  int birthRule = 3;
  int surviveMin = 2;
  int surviveMax = 3;

  final GlobalKey gridKey = GlobalKey();
  final GlobalKey playBtnKey = GlobalKey();
  final GlobalKey rulesTabKey = GlobalKey();
  final GlobalKey learnTabKey = GlobalKey();
  late TutorialCoachMark tutorialCoachMark;

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    bool hasSeenTutorial = prefs.getBool('hasSeenTutorial') ?? false;
    
    if (!hasSeenTutorial) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted && currentTab == 0) {
          showTutorial();
          prefs.setBool('hasSeenTutorial', true);
        }
      });
    }
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
            style: const TextStyle(color: green, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.5),
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

        onBirthChanged:
            (v) =>
            setState(() =>
            birthRule = v),

        onSurviveMinChanged:
            (v) =>
            setState(() =>
            surviveMin = v),

        onSurviveMaxChanged:
            (v) =>
            setState(() =>
            surviveMax = v),
      ),

      const LearnScreen(),
    ];

    return Scaffold(

      body: pages[currentTab],

      bottomNavigationBar:
      Container(
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

          mainAxisAlignment:
          MainAxisAlignment.spaceAround,

          children: [

            navItem(
                0,
                Icons.grid_view,
                "Play"),

            navItem(
                1,
                Icons.tune,
                "Rules", key: rulesTabKey),

            navItem(
                2,
                Icons.school,
                "Learn", key: learnTabKey),
          ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget navItem(
      int index,
      IconData icon,
      String label,
      {Key? key}) {

    bool active =
        currentTab == index;

    return GestureDetector(
      key: key,
      onTap: () {

        setState(() {

          currentTab = index;
        });
      },

      child:
      AnimatedContainer(

        duration:
        const Duration(
            milliseconds: 250),

        padding:
        const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 10,
        ),

        decoration:
        BoxDecoration(

          borderRadius:
          BorderRadius.circular(20),

          color:

          active

                  ? green.withOpacity(.15)

              : Colors.transparent,
          border: Border.all(
            color: active ? green.withOpacity(0.3) : Colors.transparent,
          ),
        ),

        child: Column(

          mainAxisSize:
          MainAxisSize.min,

          children: [

            Icon(

              icon,

              color:

              active

                  ? green

                  : Colors.grey,
            ),

            const SizedBox(
                height: 4),

            Text(

              label,

              style:
              TextStyle(

                fontSize: 11,

                color:

                active

                    ? green

                    : Colors.grey,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class PlayScreen extends StatefulWidget {

  final int birthRule;
  final int surviveMin;
  final int surviveMax;
  final GlobalKey gridKey;
  final GlobalKey playBtnKey;
  final VoidCallback onHelpTap;

  const PlayScreen({

    super.key,

    required this.birthRule,
    required this.surviveMin,
    required this.surviveMax,
    required this.gridKey,
    required this.playBtnKey,
    required this.onHelpTap,
  });

  @override
  State<PlayScreen> createState() =>
      _PlayScreenState();
}

class _PlayScreenState
    extends State<PlayScreen> {

  final size = 20;

  late List<List<int>> grid;

  Timer? timer;

  int generation = 0;

  String? gameEndTitle;
  String? gameEndMessage;
  bool isWin = false;
  List<String> history = [];

  @override
  void initState() {

    super.initState();

    grid = List.generate(
      size,
          (_) => List.filled(size, 0),
    );
  }

  void start() {

    timer?.cancel();

    setState(() {
      gameEndTitle = null;
      gameEndMessage = null;
      isWin = false;
    });

    int aliveInit = 0;
    for (int x = 0; x < size; x++) {
      for (int y = 0; y < size; y++) {
        if (grid[x][y] == 1) aliveInit++;
      }
    }
    if (aliveInit == 0) {
      setState(() {
        gameEndTitle = "EMPTY GRID";
        gameEndMessage = "Draw some living cells before starting!";
        isWin = false;
      });
      return;
    }

    history.clear();
    history.add(_gridToString(grid));

    timer = Timer.periodic(
      const Duration(
          milliseconds: 250),
          (_) {
        List<List<int>> nextGrid = nextGeneration();
        
        bool isSame = true;
        int aliveCount = 0;
        for (int x = 0; x < size; x++) {
          for (int y = 0; y < size; y++) {
            if (grid[x][y] != nextGrid[x][y]) isSame = false;
            if (nextGrid[x][y] == 1) aliveCount++;
          }
        }
        
        setState(() {
          generation++;
          grid = nextGrid;
        });
        
        String nextStr = _gridToString(nextGrid);
        bool isOscillating = !isSame && history.contains(nextStr);

        if (aliveCount == 0) {
          pause();
          setState(() {
            gameEndTitle = "THE END";
            gameEndMessage = "All cells have died. Life faded away... You Lose!";
            isWin = false;
          });
        } else if (isSame) {
          pause();
          setState(() {
            gameEndTitle = "STABILIZED!";
            gameEndMessage = "Life has found a stable balance. You Win!";
            isWin = true;
          });
        } else {
          if (isOscillating) {
            setState(() {
              gameEndTitle = "ENDLESS LOOP!";
              gameEndMessage = "The cells are trapped in a repeating pattern!";
              isWin = true;
            });
          }
          history.add(nextStr);
          if (history.length > 25) {
            history.removeAt(0);
          }
        }
      },
    );
  }

  void pause() {
    timer?.cancel();
  }

  void clear() {

    timer?.cancel();

    setState(() {

      generation = 0;
      gameEndTitle = null;
      gameEndMessage = null;
      isWin = false;
      history.clear();

      grid = List.generate(
        size,
            (_) =>
            List.filled(size, 0),
      );
    });
  }

  String _gridToString(List<List<int>> g) {
    return g.expand((row) => row).join('');
  }

  List<List<int>>
  nextGeneration() {

    List<List<int>> newGrid =
    List.generate(
      size,
          (_) => List.filled(size, 0),
    );

    for (int x = 0; x < size; x++) {

      for (int y = 0; y < size; y++) {

        int n = countNeighbors(
            x,
            y);

        if (grid[x][y] == 1) {

          if (n >=
              widget.surviveMin &&
              n <=
                  widget.surviveMax) {

            newGrid[x][y] = 1;
          }

        } else {

          if (n ==
              widget.birthRule) {

            newGrid[x][y] = 1;
          }
        }
      }
    }

    return newGrid;
  }

  int countNeighbors(
      int x,
      int y) {

    int count = 0;

    for (int dx = -1;
    dx <= 1;
    dx++) {

      for (int dy = -1;
      dy <= 1;
      dy++) {

        if (dx == 0 &&
            dy == 0) continue;

        int nx = x + dx;
        int ny = y + dy;

        if (nx >= 0 &&
            ny >= 0 &&
            nx < size &&
            ny < size) {

          count += grid[nx][ny];
        }
      }
    }

    return count;
  }

  @override
  Widget build(BuildContext context) {

    int aliveCount = 0;
    for (int x = 0; x < size; x++) {
      for (int y = 0; y < size; y++) {
        if (grid[x][y] == 1) aliveCount++;
      }
    }
    String status = aliveCount == 0 ? "All cells dead" : "Active";

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "LIFE LAB",
                        style: TextStyle(
                          color: green,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.help_outline, color: green),
                            onPressed: widget.onHelpTap,
                            tooltip: "Tutorial",
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "GEN $generation",
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: GridView.builder(
                      key: widget.gridKey,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: size * size,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: size,
                      ),
                      itemBuilder: (context, index) {
                        int row = index ~/ size;
                        int col = index % size;
                        bool alive = grid[row][col] == 1;
                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            setState(() {
                              grid[row][col] = 1 - grid[row][col];
                              gameEndTitle = null;
                              gameEndMessage = null;
                              isWin = false;
                              history.clear();
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.all(1.5),
                            decoration: BoxDecoration(
                              color: alive ? green : card,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: alive
                                  ? [
                                      BoxShadow(
                                        color: green.withOpacity(.5),
                                        blurRadius: 8,
                                      )
                                    ]
                                  : [],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (gameEndTitle != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isWin ? green.withOpacity(0.1) : Colors.redAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isWin ? green.withOpacity(0.3) : Colors.redAccent.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            gameEndTitle!,
                            style: TextStyle(
                              color: isWin ? green : Colors.redAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            gameEndMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Text(
                        "Press grid and click Let's Go to run simulation",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ),
                  Text(
                    "Status: $status   •   Alive: $aliveCount",
                    style: const TextStyle(color: green, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: actionButton(
                    "Let's Go!",
                    Icons.play_arrow,
                    start,
                    isPrimary: true,
                    key: widget.playBtnKey,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: actionButton(
                    "Pause",
                    Icons.pause,
                    pause,
                    isPrimary: false,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: actionButton(
                    "Clear",
                    Icons.refresh,
                    clear,
                    isPrimary: false,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget actionButton(
      String text,
      IconData icon,
      VoidCallback onTap,
      {bool isPrimary = false, Key? key}) {

    return SizedBox(
      key: key,
      height: 52,

      child:
      ElevatedButton.icon(

        onPressed: onTap,

        icon: Icon(
          icon,
          size: 20,
        ),

        label: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
        ),

        style:
        ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          backgroundColor: isPrimary ? green : card,
          foregroundColor: isPrimary ? bg : Colors.white,
          elevation: isPrimary ? 8 : 0,
          shadowColor: green.withOpacity(0.5),

          shape:
          RoundedRectangleBorder(

            borderRadius:
            BorderRadius.circular(
                16),
            side: isPrimary ? BorderSide.none : BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
        ),
      ),
    );
  }
}

class RulesScreen extends StatelessWidget {

  final int birthRule;
  final int surviveMin;
  final int surviveMax;

  final Function(int) onBirthChanged;
  final Function(int) onSurviveMinChanged;
  final Function(int) onSurviveMaxChanged;

  const RulesScreen({
    super.key,
    required this.birthRule,
    required this.surviveMin,
    required this.surviveMax,
    required this.onBirthChanged,
    required this.onSurviveMinChanged,
    required this.onSurviveMaxChanged,
  });

  @override
  Widget build(BuildContext context) {

    return SafeArea(

      child: ListView(

        padding:
        const EdgeInsets.all(20),

        children: [

          const Text(
            "RULES LAB",
            style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
            ),
          ),

          const SizedBox(
              height: 8),

          const Text(
            "Experiment with life.",
            style: TextStyle(
              color: Colors.grey,
            ),
          ),

          const SizedBox(
              height: 30),

          sliderCard(
            "👶 Birth Rule",
            birthRule,
            onBirthChanged,
            "Standard: 3\nA dead cell needs exactly this many neighbors to come to life.",
          ),

          sliderCard(
            "🌱 Survive Min",
            surviveMin,
            onSurviveMinChanged,
            "Standard: 2\nA living cell needs at least this many neighbors to survive.",
          ),

          sliderCard(
            "🌳 Survive Max",
            surviveMax,
            onSurviveMaxChanged,
            "Standard: 3\nA living cell needs no more than this many neighbors to survive.",
          ),

          infoCard(
            "🧪 TRY THIS",
            "Change the rules and watch life evolve differently.",
          ),
        ],
      ),
    );
  }

  Widget infoCard(
      String title,
      String body) {

    return Container(

      padding:
      const EdgeInsets.all(18),

      child: Column(

        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          Text(
            title,
            style:
            const TextStyle(
              color: green,
              fontWeight:
              FontWeight.bold,
            ),
          ),

          const SizedBox(
              height: 8),

          Text(
            body,
            style:
            const TextStyle(
              color:
              Colors.grey,
            ),
          )
        ],
      ),
    );
  }

  Widget sliderCard(
      String title,
      int value,
      Function(int) onChanged,
      String tooltipText) {

    return Container(

      margin:
      const EdgeInsets.only(
          bottom: 16),

      padding:
      const EdgeInsets.all(16),

      decoration:
      BoxDecoration(

        color: card,

        borderRadius:
        BorderRadius.circular(
            20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),

      child: Column(

        children: [

          Row(

            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,

            children: [

              Row(
                children: [
                  Text(title),
                  const SizedBox(width: 8),
                  Tooltip(
                    message: tooltipText,
                    triggerMode: TooltipTriggerMode.tap,
                    showDuration: const Duration(seconds: 4),
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: green.withOpacity(0.3)),
                    ),
                    textStyle: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                    child: const Icon(Icons.info_outline, color: Colors.grey, size: 18),
                  ),
                ],
              ),

              Text(
                "$value",
                style:
                const TextStyle(
                  color: green,
                ),
              )
            ],
          ),

          Slider(

            activeColor:
            green,

            value:
            value.toDouble(),

            min: 1,
            max: 8,

            divisions: 7,

            onChanged:
                (v) {

              onChanged(
                  v.toInt());
            },
          )
        ],
      ),
    );
  }
}

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "HOW IT WORKS",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "The fascinating rules of Conway's Game of Life.",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 30),
          learnSection(
            "The Grid & Cells",
            "The game takes place on a grid of squares called 'cells'. A cell can be either 'alive' (green) or 'dead' (dark empty space). Every cell has 8 neighbors surrounding it: up, down, left, right, and diagonals.",
            Icons.grid_on,
          ),
          learnSection(
            "1. Underpopulation",
            "If a living cell has fewer than 2 living neighbors, it dies of loneliness. It needs a community to survive!",
            Icons.person_off,
          ),
          learnSection(
            "2. Survival",
            "If a living cell has exactly 2 or 3 living neighbors, it is happy and survives into the next generation. The balance is just right.",
            Icons.favorite,
          ),
          learnSection(
            "3. Overpopulation",
            "If a living cell has more than 3 living neighbors, it dies because it's too crowded and there aren't enough resources.",
            Icons.groups,
          ),
          learnSection(
            "4. Reproduction",
            "If a dead (empty) cell has exactly 3 living neighbors, a brand new cell is born in that space! Life finds a way.",
            Icons.child_care,
          ),
          learnSection(
            "The End (You Lose)",
            "If every single cell dies and the grid becomes completely empty, life has faded away and you lose. Try drawing a larger or closer community of cells to start!",
            Icons.close_rounded,
          ),
          learnSection(
            "Stabilized (You Win!)",
            "If your cells reach a perfect, unchanging balance where they survive endlessly without anyone dying or being born, you win the game!",
            Icons.emoji_events,
          ),
          learnSection(
            "Endless Loops",
            "Sometimes the cells get trapped in a repeating pattern, oscillating back and forth forever (like a blinker). If you find one, sit back and enjoy the endless dance!",
            Icons.loop,
          ),
          learnSection(
            "Emergent Beauty",
            "From these 4 simple rules, incredible and complex patterns emerge. Go to the 'Play' tab, draw a shape, and see what happens when you press 'Let's Go!'",
            Icons.auto_awesome,
          ),
          const SizedBox(height: 10),
          const Divider(color: Colors.white10),
          const SizedBox(height: 20),
          const Text(
            "FAQ",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          faqItem("Is this a game you play?", "It's known as a 'zero-player game'. You set up the initial configuration and watch how it evolves based on the rules without further input!"),
          faqItem("Why is it called the 'Game of Life'?", "Created by mathematician John Conway in 1970, it perfectly simulates the life, death, and reproduction of biological cells using simple math."),
          faqItem("What are Gliders?", "Gliders are special patterns of cells that move across the grid infinitely. They 'fly' diagonally across the board. Try drawing a small asymmetrical shape and see if it moves!"),
          faqItem("Can I change the rules?", "Absolutely! Go to the 'Rules' tab to experiment. Changing the required neighbors for birth or survival creates entirely new and bizarre universes."),
          const SizedBox(height: 40),
          const Center(
            child: Text(
              "Built by Randomwalk.ai",
              style: TextStyle(
                color: Colors.white30,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget learnSection(String title, String body, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: green, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: green,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  body,
                  style: const TextStyle(
                    color: Colors.white70,
                    height: 1.6,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget faqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ExpansionTile(
        shape: const Border(), // Removes the default ExpansionTile borders
        collapsedShape: const Border(),
        iconColor: green,
        collapsedIconColor: Colors.grey,
        title: Text(
          question,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                answer,
                style: const TextStyle(color: Colors.white70, height: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}