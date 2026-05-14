import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme.dart';

class PlayScreen extends StatefulWidget {
  final int birthRule;
  final int surviveMin;
  final int surviveMax;
  final GlobalKey gridKey;
  final GlobalKey playBtnKey;
  final GlobalKey ruleLabBtnKey;
  final VoidCallback onHelpTap;
  final VoidCallback onRuleLabTap;

  const PlayScreen({
    super.key,
    required this.birthRule,
    required this.surviveMin,
    required this.surviveMax,
    required this.gridKey,
    required this.playBtnKey,
    required this.ruleLabBtnKey,
    required this.onHelpTap,
    required this.onRuleLabTap,
  });

  @override
  State<PlayScreen> createState() => PlayScreenState();
}

class PlayScreenState extends State<PlayScreen> {
  final size = 20;
  late List<List<int>> grid;
  Timer? timer;
  int generation = 0;

  String? gameEndTitle;
  String? gameEndMessage;
  bool isWin = false;
  bool _showOverlay = false;
  List<String> history = [];

  bool _isSpeedToggled = false; // For tapping
  bool _isSpeedHeld = false; // For holding
  int _winCount = 0;
  bool _showLevelPopup = false;
  int _initialCellsCount = 0;

  int _highScore = 0;

  @override
  void initState() {
    super.initState();
    grid = List.generate(
      size,
      (_) => List.filled(size, 0),
    );
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('highScore', 0); // Force reset to 0 for testing
    setState(() {
      _highScore = 0;
    });
  }

  void _triggerOverlay() {
    setState(() {
      _showOverlay = true;
    });
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        setState(() => _showOverlay = false);
      }
    });
  }

  void _handleWin() {
    _winCount++;
    if (_winCount == 2) {
      _showLevelPopup = true;
      Future.delayed(const Duration(seconds: 6), () {
        if (mounted) setState(() => _showLevelPopup = false);
      });
    }
  }

  void start() {
    timer?.cancel();

    setState(() {
      gameEndTitle = null;
      gameEndMessage = null;
      isWin = false;
      _showOverlay = false;
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
        gameEndMessage = "Draw some Live cells before starting!";
        isWin = false;
      });
      return;
    }
    _initialCellsCount = aliveInit;

    history.clear();
    history.add(_gridToString(grid));

    _setTimer();
  }

  void _setTimer() {
    timer?.cancel();
    // Speed is 2x if either toggled on or currently held down
    bool isFast = _isSpeedToggled || _isSpeedHeld;
    int speed = isFast ? 200 : 500;
    timer = Timer.periodic(
      Duration(milliseconds: speed),
      (_) => _doTick(),
    );
  }

  void _updateSpeed() {
    if (timer != null && timer!.isActive) {
      _setTimer();
    }
  }

  void _doTick() {
    List<List<int>> nextGrid = nextGeneration();

    bool isSame = true;
    int aliveCount = 0;
    for (int x = 0; x < size; x++) {
      for (int y = 0; y < size; y++) {
        if (grid[x][y] != nextGrid[x][y]) isSame = false;
        if (nextGrid[x][y] == 1) aliveCount++;
      }
    }

    bool wasEnded = gameEndTitle != null;
    setState(() {
      if (!wasEnded) {
        generation++;
      }
      grid = nextGrid;
    });

    String nextStr = _gridToString(nextGrid);
    bool isOscillating = !isSame && history.contains(nextStr);

    if (aliveCount == 0) {
      bool isNew = gameEndTitle == null;
      if (isNew) {
        pause();
        setState(() {
          gameEndTitle = "Your pattern failed";
          gameEndMessage = "Started with $_initialCellsCount cells, but all died after $generation generations.";
          isWin = false;
        });
        _triggerOverlay();
      }
    } else if (isSame) {
      bool isNew = gameEndTitle == null;
      if (isNew) {
        pause();
        setState(() {
          // High Score Logic: Only update on win condition
          if (aliveCount > _highScore) {
            _highScore = aliveCount;
            SharedPreferences.getInstance().then((prefs) {
              prefs.setInt('highScore', _highScore);
            });
          }
          gameEndTitle = "Your pattern survived with $aliveCount live cells";
          gameEndMessage = "Started with $_initialCellsCount cells. Stabilized after $generation generations.";
          isWin = true;
        });
        _triggerOverlay();
        _handleWin();
      }
    } else {
      if (isOscillating) {
        bool isNew = gameEndTitle == null;
        if (isNew) {
          // Intentionally NOT pausing here so the loop continues animating!
          setState(() {
            // High Score Logic: Also update on loop condition
            if (aliveCount > _highScore) {
              _highScore = aliveCount;
              SharedPreferences.getInstance().then((prefs) {
                prefs.setInt('highScore', _highScore);
              });
            }
            gameEndTitle = "Your pattern is looping with $aliveCount live cells";
            gameEndMessage = "Started with $_initialCellsCount cells. Entered a loop after $generation generations.";
            isWin = true;
          });
          _triggerOverlay();
          _handleWin();
        }
      }
      history.add(nextStr);
      if (history.length > 25) {
        history.removeAt(0);
      }
    }
  }

  void pause() {
    timer?.cancel();
  }

  void clear({bool andResetHighScore = false}) {
    timer?.cancel();

    if (andResetHighScore) {
      _resetHighScore();
    }

    setState(() {
      generation = 0;
      gameEndTitle = null;
      gameEndMessage = null;
      isWin = false;
      _showOverlay = false;
      history.clear();
      _initialCellsCount = 0;

      grid = List.generate(
        size,
        (_) => List.filled(size, 0),
      );
    });
  }

  Future<void> _resetHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('highScore', 0);
    if (mounted) {
      setState(() => _highScore = 0);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("High Score Reset!"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  String _gridToString(List<List<int>> g) {
    return g.expand((row) => row).join('');
  }

  List<List<int>> nextGeneration() {
    List<List<int>> newGrid = List.generate(
      size,
      (_) => List.filled(size, 0),
    );

    for (int x = 0; x < size; x++) {
      for (int y = 0; y < size; y++) {
        int n = countNeighbors(x, y);
        if (grid[x][y] == 1) {
          if (n >= widget.surviveMin && n <= widget.surviveMax) {
            newGrid[x][y] = 1;
          }
        } else {
          if (n == widget.birthRule) {
            newGrid[x][y] = 1;
          }
        }
      }
    }

    return newGrid;
  }

  int countNeighbors(int x, int y) {
    int count = 0;
    for (int dx = -1; dx <= 1; dx++) {
      for (int dy = -1; dy <= 1; dy++) {
        if (dx == 0 && dy == 0) continue;
        int nx = x + dx;
        int ny = y + dy;
        if (nx >= 0 && ny >= 0 && nx < size && ny < size) {
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
    String status = aliveCount == 0 ? "All cells empty" : "Active";

    double growthMultiplier = _initialCellsCount > 0 ? (aliveCount / _initialCellsCount) : 0.0;
    Color growthColor = growthMultiplier >= 2.0 ? Colors.amber : (growthMultiplier >= 1.0 ? green : Colors.redAccent);
    IconData growthIcon = growthMultiplier >= 2.0 ? Icons.local_fire_department : (growthMultiplier >= 1.0 ? Icons.trending_up : Icons.trending_down);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
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
                          const Icon(Icons.military_tech, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            "$_highScore",
                            style: const TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            key: widget.ruleLabBtnKey,
                                icon: const Icon(Icons.filter_list, color: green),
                            onPressed: widget.onRuleLabTap,
                            tooltip: "Experiment with Rules",
                          ),
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
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 76,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              generation == 0 
                                  ? "Live cells drawn: $aliveCount"
                                  : "Started: $_initialCellsCount   •   Current: $aliveCount",
                              style: const TextStyle(
                                  color: green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14),
                            ),
                            if (generation > 0 && _initialCellsCount > 0) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: growthColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: growthColor.withOpacity(0.5)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(growthIcon, color: growthColor, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      "${growthMultiplier.toStringAsFixed(1)}x",
                                      style: TextStyle(color: growthColor, fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (gameEndMessage != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            gameEndMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double gridSize = constraints.maxWidth < constraints.maxHeight
                            ? constraints.maxWidth
                            : constraints.maxHeight;
                        double cellWidth = gridSize / size;
                        return Center(
                          child: SizedBox(
                            width: gridSize,
                            height: gridSize,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                GestureDetector(
                                  onPanUpdate: (details) {
                                    int col = (details.localPosition.dx / cellWidth).floor();
                                    int row = (details.localPosition.dy / cellWidth).floor();
                                    if (row >= 0 && row < size && col >= 0 && col < size) {
                                      if (grid[row][col] == 0) {
                                        setState(() {
                                          grid[row][col] = 1;
                                          gameEndTitle = null;
                                          gameEndMessage = null;
                                          isWin = false;
                                          _showOverlay = false;
                                          history.clear();
                                        });
                                      }
                                    }
                                  },
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
                                            _showOverlay = false;
                                            history.clear();
                                          });
                                        },
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 250),
                                          margin: const EdgeInsets.all(1.5),
                                          decoration: BoxDecoration(
                                            color: alive ? green : Colors.white.withOpacity(0.05),
                                            border: Border.all(color: alive ? green : Colors.white.withOpacity(0.1)),
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
                                IgnorePointer(
                                  ignoring: true,
                                  child: AnimatedOpacity(
                                    opacity: _showOverlay ? 1.0 : 0.0,
                                    duration: const Duration(milliseconds: 400),
                                    child: AnimatedScale(
                                      scale: _showOverlay ? 1.0 : 0.9,
                                      duration: const Duration(milliseconds: 600),
                                      curve: Curves.easeOutExpo,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(30),
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.02), // Extremely subtle tint
                                              borderRadius: BorderRadius.circular(30),
                                              border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  isWin ? "WIN" : "LOSE",
                                                  style: TextStyle(color: isWin ? green : Colors.redAccent, fontSize: 40, fontWeight: FontWeight.w200, letterSpacing: 10),
                                                ),
                                                const SizedBox(height: 16),
                                                Text(
                                                  isWin && growthMultiplier >= 2.0
                                                      ? "Excellent!"
                                                      : isWin && growthMultiplier >= 1.0
                                                          ? "Great Job! Keep Going!"
                                                          : "Try to keep more cells alive\nto get a better highscore!",
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(color: Colors.white70, fontSize: 14, fontStyle: FontStyle.italic, height: 1.4),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 56,
                    child: Center(
                      child: gameEndTitle != null
                          ? Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                color: isWin
                                    ? green.withOpacity(0.1)
                                    : Colors.redAccent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isWin
                                      ? green.withOpacity(0.3)
                                      : Colors.redAccent.withOpacity(0.3),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  gameEndTitle!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isWin ? green : Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                              ),
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Draw your starting cells & press Play!",
                                  style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.egg_alt, color: green, size: 14),
                                    SizedBox(width: 4),
                                    Text("Start Small", style: TextStyle(color: green, fontSize: 12, fontWeight: FontWeight.bold)),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward, color: Colors.grey, size: 12),
                                    SizedBox(width: 8),
                                    Icon(Icons.all_out, color: Colors.amber, size: 14),
                                    SizedBox(width: 4),
                                    Text("Grow Huge", style: TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: actionButton(
                          "Play",
                          Icons.play_arrow,
                          start,
                          isPrimary: true,
                          key: widget.playBtnKey,
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          setState(() => _isSpeedToggled = !_isSpeedToggled);
                          _updateSpeed();
                        },
                        onLongPressStart: (_) {
                          setState(() => _isSpeedHeld = true);
                          _updateSpeed();
                        },
                        onLongPressEnd: (_) {
                          setState(() => _isSpeedHeld = false);
                          _updateSpeed();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          height: 52,
                          width: 52,
                          // Button is active if toggled on OR held down
                          decoration: BoxDecoration(
                            color: (_isSpeedToggled || _isSpeedHeld) ? green : card,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: (_isSpeedToggled || _isSpeedHeld) ? green : Colors.white.withOpacity(0.1)),
                          ),
                          child: Center(
                            child: Text((_isSpeedToggled || _isSpeedHeld) ? "2x" : "1x", style: TextStyle(
                              color: (_isSpeedToggled || _isSpeedHeld) ? bg : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            )),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        height: 52,
                        width: 52,
                        child: ElevatedButton(
                          onPressed: () => clear(),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: card,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: Colors.white.withOpacity(0.1)),
                            ),
                          ),
                          child: const Icon(Icons.refresh, size: 24),
                          onLongPress: () {
                            clear(andResetHighScore: true);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        if (_showLevelPopup)
          Positioned(
            top: 45,
            right: 0,
            child: Material(
              color: Colors.transparent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: 78),
                    child: Icon(Icons.arrow_drop_up, color: green, size: 30),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: green.withOpacity(0.5)),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("Change the difficulty ?", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () => setState(() => _showLevelPopup = false),
                            child: const Icon(Icons.close, color: Colors.grey, size: 18),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  ),
);
  }

  Widget actionButton(String text, IconData icon, VoidCallback? onTap,
      {bool isPrimary = false, Key? key}) {
    return SizedBox(
      key: key,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(
          icon,
          size: 20,
        ),
        label: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            style: const TextStyle(
                fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          backgroundColor: isPrimary ? green : card,
          foregroundColor: isPrimary ? bg : Colors.white,
          elevation: isPrimary ? 8 : 0,
          shadowColor: green.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isPrimary
                ? BorderSide.none
                : BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
        ),
      ),
    );
  }
}