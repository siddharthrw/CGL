import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {

    final pages = [

      PlayScreen(
        birthRule: birthRule,
        surviveMin: surviveMin,
        surviveMax: surviveMax,
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
                "Rules"),

            navItem(
                2,
                Icons.school,
                "Learn"),
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
      String label) {

    bool active =
        currentTab == index;

    return GestureDetector(

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

  const PlayScreen({

    super.key,

    required this.birthRule,
    required this.surviveMin,
    required this.surviveMax,
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

    timer = Timer.periodic(

      const Duration(
          milliseconds: 250),

          (_) {

        setState(() {

          generation++;

          grid =
              nextGeneration();
        });
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

      grid = List.generate(
        size,
            (_) =>
            List.filled(size, 0),
      );
    });
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

        padding:
        const EdgeInsets.all(16),

        child: Column(

          children: [

            Row(

              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,

              children: [

                const Text(

                  "LIFE LAB",

                  style: TextStyle(

                    color: green,

                    fontSize: 24,

                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                Text(

                  "GEN $generation",

                  style:
                  const TextStyle(
                    color:
                    Colors.grey,
                  ),
                )
              ],
            ),

            const SizedBox(
                height: 20),

            Expanded(

              child:
              GridView.builder(

                physics:
                const NeverScrollableScrollPhysics(),

                itemCount:
                size * size,

                gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                  size,
                ),

                itemBuilder:
                    (
                    context,
                    index) {

                  int row =
                      index ~/ size;

                  int col =
                      index % size;

                  bool alive =
                      grid[row][col] ==
                          1;

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,

                    onTap: () {

                      setState(() {

                        grid[row][col] =
                        1 -
                            grid[row]
                            [col];
                      });
                    },

                    child:
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),

                      margin:
                      const EdgeInsets
                          .all(1.5),

                      decoration:
                      BoxDecoration(

                        color:

                        alive

                            ? green

                            : card,

                        borderRadius:
                        BorderRadius
                            .circular(
                            4),

                        boxShadow:

                        alive

                            ? [

                          BoxShadow(

                            color: green
                                .withOpacity(
                                .5),

                            blurRadius:
                            8,
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
            
            const Text(
              "Press grid and click Let's Go to run simulation",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            
            const SizedBox(height: 6),
            
            Text(
              "Status: $status   •   Alive: $aliveCount",
              style: const TextStyle(color: green, fontWeight: FontWeight.bold, fontSize: 14),
            ),

            const SizedBox(height: 16),

            Row(

              children: [

                Expanded(
                  child:
                  actionButton(
                    "Let's Go!",
                    Icons.play_arrow,
                    start,
                    isPrimary: true,
                  ),
                ),

                const SizedBox(
                    width: 12),

                Expanded(
                  child:
                  actionButton(
                    "Pause",
                    Icons.pause,
                    pause,
                    isPrimary: false,
                  ),
                ),

                const SizedBox(
                    width: 12),

                Expanded(
                  child:
                  actionButton(
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
      {bool isPrimary = false}) {

    return SizedBox(

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

          infoCard(
            "🧬 STANDARD LIFE",
            "Birth with 3 neighbors.\nSurvive with 2 or 3.",
          ),

          const SizedBox(
              height: 20),

          sliderCard(
            "👶 Birth Rule",
            birthRule,
            onBirthChanged,
          ),

          sliderCard(
            "🌱 Survive Min",
            surviveMin,
            onSurviveMinChanged,
          ),

          sliderCard(
            "🌳 Survive Max",
            surviveMax,
            onSurviveMaxChanged,
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
      Function(int) onChanged) {

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

              Text(title),

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
            "A quick guide for kids (and adults too!)",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 30),
          learnCard(
            "1. Living Squares",
            "Every green square on the grid is 'alive'. The dark squares are empty space.",
            Icons.check_box,
          ),
          learnCard(
            "2. Making Friends",
            "Just like us, these squares need neighbors! If a square has 2 or 3 friends touching it, it stays alive.",
            Icons.people,
          ),
          learnCard(
            "3. Too Crowded or Lonely",
            "If a square has less than 2 friends, it gets too lonely and disappears. If it has more than 3, it gets too crowded and disappears too!",
            Icons.warning_rounded,
          ),
          learnCard(
            "4. A New Baby Square!",
            "If an empty space has exactly 3 living friends next to it, a brand new baby square is born right there!",
            Icons.child_care,
          ),
          learnCard(
            "5. You Are In Control",
            "Go to the 'Play' tab, tap the grid to draw some living squares, and press 'Let's Go!' to watch them move and grow.",
            Icons.videogame_asset,
          ),
        ],
      ),
    );
  }

  Widget learnCard(String title, String body, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: green, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: green,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
    );
  }
}