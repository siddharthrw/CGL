import 'dart:async';
import 'dart:ui';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
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

class PlayScreenState extends State<PlayScreen> with SingleTickerProviderStateMixin {
  final size = 20;
  late List<List<int>> grid;
  late List<List<int>> _initialGridSnapshot;
  Timer? timer;
  int generation = 0;

  String? gameEndTitle;
  String? gameEndMessage;
  bool isWin = false;
  bool _showOverlay = false;
  List<String> history = [];

  bool _isSpeedToggled = false; // For tapping
  bool _isSpeedHeld = false; // For holding
  int _initialCellsCount = 0;

  int _highScore = 0;

  final GlobalKey _speedBtnKey = GlobalKey();
  final GlobalKey _refreshBtnKey = GlobalKey();
  final GlobalKey _statusAreaKey = GlobalKey();
  int _tutorialStep = -1;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    grid = List.generate(
      size,
      (_) => List.filled(size, 0),
    );
    _initialGridSnapshot = List.generate(size, (_) => List.filled(size, 0));
    _loadHighScore();
    _checkPlayTutorial();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    timer?.cancel();
    super.dispose();
  }

  Future<void> _checkPlayTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Force the tutorial to reset and show again so you can see the full walkthrough!
    await prefs.setBool('playScreenTutorialShown', false);

    bool shown = prefs.getBool('playScreenTutorialShown') ?? false;
    if (!shown) {
      setState(() {
        _tutorialStep = 0;
      });
    }
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

  void start() {
    timer?.cancel();

    if (_tutorialStep == 1) {
      setState(() => _tutorialStep = 2);
    }

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
    _initialGridSnapshot = List.generate(size, (x) => List.from(grid[x]));

    history.clear();
    history.add(_gridToString(grid));

    _setTimer();
  }

  void tryAgain() {
    // Completely reset everything and bring back the "Play" button
    clear();
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

  Future<void> _shareStats(int aliveCount, double growthMultiplier) async {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    const width = 800.0;
    const height = 900.0;
    
    // Background
    final bgPaint = Paint()..color = bg;
    canvas.drawRect(const Rect.fromLTWH(0, 0, width, height), bgPaint);

    // Card Background
    final cardPaint = Paint()..color = card;
    final rrect = RRect.fromLTRBR(40, 40, width - 40, height - 40, const Radius.circular(30));
    canvas.drawRRect(rrect, cardPaint);
    
    // Border for Card
    final cardBorderPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(rrect, cardBorderPaint);

    // Title
    const titleSpan = TextSpan(
      text: "LIFE LAB",
      style: TextStyle(color: green, fontSize: 50, fontWeight: FontWeight.bold, letterSpacing: 4),
    );
    final titlePainter = TextPainter(text: titleSpan, textDirection: TextDirection.ltr)..layout();
    titlePainter.paint(canvas, Offset((width - titlePainter.width) / 2, 80));

    // Result Title
    final resultSpan = TextSpan(
      text: isWin ? "SURVIVED" : "FAILED",
      style: TextStyle(color: isWin ? green : Colors.redAccent, fontSize: 32, fontWeight: FontWeight.w200, letterSpacing: 8),
    );
    final resultPainter = TextPainter(text: resultSpan, textDirection: TextDirection.ltr)..layout();
    resultPainter.paint(canvas, Offset((width - resultPainter.width) / 2, 140));

    // Draw Grids Function
    void drawGrid(Canvas c, Offset offset, double gridSize, List<List<int>> gridData, String label) {
       final labelSpan = TextSpan(text: label, style: const TextStyle(color: Colors.white70, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2));
       final labelPainter = TextPainter(text: labelSpan, textDirection: TextDirection.ltr)..layout();
       labelPainter.paint(c, Offset(offset.dx + (gridSize - labelPainter.width) / 2, offset.dy - 35));

       final cellSize = gridSize / size;
       final cellPaintAlive = Paint()..color = green;
       final cellPaintDead = Paint()..color = Colors.white.withOpacity(0.05);
       
       final borderPaintDead = Paint()..color = Colors.white.withOpacity(0.15)..style = PaintingStyle.stroke..strokeWidth = 1.0;
       final borderPaintAlive = Paint()..color = green..style = PaintingStyle.stroke..strokeWidth = 1.0;

       for (int x = 0; x < size; x++) {
         for (int y = 0; y < size; y++) {
           // Adding a small gap to separate the cells and reveal the dark background as grid lines
           final gap = 1.5;
           final rect = RRect.fromRectAndRadius(
             Rect.fromLTWH(
               offset.dx + y * cellSize + gap, 
               offset.dy + x * cellSize + gap, 
               cellSize - gap * 2, 
               cellSize - gap * 2
             ),
             const Radius.circular(2), // Matches the slightly rounded corners in the app
           );
           final isAlive = gridData[x][y] == 1;
           c.drawRRect(rect, isAlive ? cellPaintAlive : cellPaintDead);
           c.drawRRect(rect, isAlive ? borderPaintAlive : borderPaintDead);
         }
       }
    }

    // Grids side by side
    const gridRenderSize = 260.0;
    drawGrid(canvas, const Offset(80, 240), gridRenderSize, _initialGridSnapshot, "INITIAL");
    drawGrid(canvas, const Offset(width - 80 - gridRenderSize, 240), gridRenderSize, grid, "FINAL");

    // Stats Box
    String badge = growthMultiplier >= 2.0 ? "Excellent" : (growthMultiplier >= 1.0 ? "Great" : "Survived");
    if (!isWin) badge = "Extinct";

    final statsText = "Start Cells: $_initialCellsCount\n"
                      "Final Cells: $aliveCount\n"
                      "Generations: $generation\n"
                      "Growth: ${growthMultiplier.toStringAsFixed(1)}x\n"
                      "Badge: $badge";
    
    final statsSpan = TextSpan(
      text: statsText,
      style: const TextStyle(color: Colors.white, fontSize: 28, height: 1.6, fontWeight: FontWeight.w500),
    );
    final statsPainter = TextPainter(text: statsSpan, textDirection: TextDirection.ltr, textAlign: TextAlign.center)..layout();
    statsPainter.paint(canvas, Offset((width - statsPainter.width) / 2, 560));

    // Footer
    const footerSpan = TextSpan(
      text: "randomwalk.ai/lifelab",
      style: TextStyle(color: Colors.grey, fontSize: 18, letterSpacing: 1.2),
    );
    final footerPainter = TextPainter(text: footerSpan, textDirection: TextDirection.ltr)..layout();
    footerPainter.paint(canvas, Offset((width - footerPainter.width) / 2, height - 100));

    final picture = recorder.endRecording();
    final img = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await img.toByteData(format: ImageByteFormat.png);
    if (byteData == null) return;

    final bytes = byteData.buffer.asUint8List();

    await Share.shareXFiles(
      [XFile.fromData(bytes, mimeType: 'image/png', name: 'life_lab_stats.png')],
      text: 'I reached generation $generation in Life Lab with $aliveCount cells! Can you beat my pattern?',
    );
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
      _initialGridSnapshot = List.generate(size, (_) => List.filled(size, 0));
    });
  }

  Future<void> _resetHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('highScore', 0);
    await prefs.setBool('playScreenTutorialShown', false);
    if (mounted) {
      setState(() => _highScore = 0);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("High Score & Tutorial Reset!"),
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
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        key: _statusAreaKey,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _tutorialStep == 3 ? green : Colors.transparent, width: 2),
                          boxShadow: _tutorialStep == 3 ? [BoxShadow(color: green.withOpacity(0.2), blurRadius: 15, spreadRadius: 5)] : [],
                        ),
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
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: _tutorialStep == 5 ? [BoxShadow(color: green.withOpacity(0.6), blurRadius: 15)] : [],
                                      ),
                                      child: IconButton(
                                        key: widget.ruleLabBtnKey,
                                        icon: const Icon(Icons.tune, color: green),
                                        onPressed: widget.onRuleLabTap,
                                        tooltip: "Experiment with Rules",
                                      ),
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
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: gridSize,
                            height: gridSize,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _tutorialStep == 0 ? green : Colors.transparent, width: 2),
                              boxShadow: _tutorialStep == 0 ? [BoxShadow(color: green.withOpacity(0.2), blurRadius: 20, spreadRadius: 5)] : [],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                GestureDetector(
                                  onPanUpdate: (details) {
                                    if (timer != null && timer!.isActive) return;
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
                                      bool isTutorialTarget = _tutorialStep == 0 && !alive && (
                                        (row == 2 && col == 3) ||
                                        (row == 3 && col == 4) ||
                                        (row == 4 && col >= 2 && col <= 4)
                                      );

                                      return GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () {
                                          if (timer != null && timer!.isActive) return;
                                          setState(() {
                                            grid[row][col] = 1 - grid[row][col];
                                            gameEndTitle = null;
                                            gameEndMessage = null;
                                            isWin = false;
                                            _showOverlay = false;
                                            history.clear();
                                          });
                                        },
                                        child: isTutorialTarget
                                            ? AnimatedBuilder(
                                                animation: _pulseController,
                                                builder: (context, child) {
                                                  double val = _pulseController.value;
                                                  return Transform.scale(
                                                    scale: 1.0 + (val * 0.25),
                                                    child: Container(
                                                      margin: const EdgeInsets.all(1.5),
                                                      decoration: BoxDecoration(
                                                        color: green.withOpacity(0.2 + val * 0.6),
                                                        border: Border.all(
                                                          color: green.withOpacity(0.5 + val * 0.5),
                                                          width: 1.5 + val * 1.5,
                                                        ),
                                                        borderRadius: BorderRadius.circular(4),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: green.withOpacity(0.4 + val * 0.6),
                                                            blurRadius: 8 + val * 15,
                                                            spreadRadius: val * 6,
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              )
                                            : AnimatedContainer(
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
                          ? Row(
                              children: [
                                Expanded(
                                  child: Container(
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
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          gameEndTitle!,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: isWin ? green : Colors.redAccent,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            letterSpacing: 1.1,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                if (isWin) ...[
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    height: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () => _shareStats(aliveCount, growthMultiplier),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: green.withOpacity(0.1),
                                        foregroundColor: green,
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          side: BorderSide(color: green.withOpacity(0.3)),
                                        ),
                                      ),
                                      child: const Icon(Icons.share),
                                    ),
                                  ),
                                ],
                              ],
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
                          gameEndTitle != null ? "Play Again" : "Play",
                          gameEndTitle != null ? Icons.replay : Icons.play_arrow,
                          gameEndTitle != null ? tryAgain : ((timer != null && timer!.isActive) ? null : start),
                          isPrimary: true,
                          isTutorialGlow: _tutorialStep == 1,
                          key: widget.playBtnKey,
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isSpeedToggled = !_isSpeedToggled;
                            if (_tutorialStep == 2) _tutorialStep = 3;
                          });
                          _updateSpeed();
                        },
                        onLongPressStart: (_) {
                          setState(() {
                            _isSpeedHeld = true;
                            if (_tutorialStep == 2) _tutorialStep = 3;
                          });
                          _updateSpeed();
                        },
                        onLongPressEnd: (_) {
                          setState(() => _isSpeedHeld = false);
                          _updateSpeed();
                        },
                        child: AnimatedContainer(
                          key: _speedBtnKey,
                          duration: const Duration(milliseconds: 150),
                          height: 52,
                          width: 52,
                          // Button is active if toggled on OR held down
                          decoration: BoxDecoration(
                            color: (_isSpeedToggled || _isSpeedHeld) ? green : card,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: (_isSpeedToggled || _isSpeedHeld) ? green : Colors.white.withOpacity(0.1)),
                            boxShadow: _tutorialStep == 2 ? [BoxShadow(color: green.withOpacity(0.6), blurRadius: 15, spreadRadius: 2)] : [],
                          ),
                          child: Center(
                            child: Icon(
                              Icons.bolt,
                              color: (_isSpeedToggled || _isSpeedHeld) ? bg : Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        key: _refreshBtnKey,
                        height: 52,
                        width: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: _tutorialStep == 4 ? [BoxShadow(color: green.withOpacity(0.6), blurRadius: 15, spreadRadius: 2)] : [],
                        ),
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
                  _buildInlineTutorial(),
      ],
    ),
  ),
);
  }

  Widget _buildInlineTutorial() {
    if (_tutorialStep < 0) return const SizedBox.shrink();

    String title = "";
    String desc = "";
    bool showNext = false;
    bool nextEnabled = true;
    String nextText = "NEXT";
    VoidCallback? onNext = () => setState(() => _tutorialStep++);
    bool isTop = true;

    switch (_tutorialStep) {
      case 0:
        title = "1. Draw Life";
        desc = "Tap the 5 blinking cells to draw a 'Glider'. This pattern will fly across the grid!";
        showNext = true;
        bool targetsHit = grid[2][3] == 1 && grid[3][4] == 1 && grid[4][2] == 1 && grid[4][3] == 1 && grid[4][4] == 1;
        int alive = grid.expand((e) => e).where((c) => c == 1).length;
        nextEnabled = targetsHit && alive == 5;
        if (!nextEnabled && alive > 0) {
          desc = "Tap ONLY the 5 blinking cells. Use the refresh button below to clear if you made a mistake!";
        }
        isTop = true;
        break;
      case 1:
        title = "2. Evolve";
        desc = "Great! Now press the glowing 'Play' button below to watch your cells evolve.";
        showNext = false; // Auto advances on play
        isTop = true;
        break;
      case 2:
        title = "3. Speed Control";
        desc = "Simulation running too slow? Tap the glowing lightning button to toggle 2x speed, or hold it down for a boost!";
        showNext = true; // They can tap next if they don't want to change speed
        isTop = true;
        break;
      case 3:
        title = "4. How to Win";
        desc = "To win, your pattern must stabilize into a loop or stop changing. If all cells die, you lose! The more your cells multiply, the better your Badge:\n\n• Survived (Red): < 1.0x growth\n• Great (Green): 1.0x - 1.9x growth\n• Excellent (Amber): 2.0x+ growth";
        showNext = true;
        isTop = false; // Status area is at top, put dialog at bottom
        break;
      case 4:
        title = "5. Clear & Reset";
        desc = "Want a clean slate? Tap the glowing refresh button to wipe the grid. Long-press it to reset your High Score!";
        showNext = true;
        isTop = true;
        break;
      case 5:
        title = "6. Rule Lab";
        desc = "Play God! Tap the tune icon at the top right to change the rules of physics.";
        showNext = true;
        nextText = "LET'S PLAY!";
        onNext = () {
          setState(() => _tutorialStep = -1);
          SharedPreferences.getInstance().then((p) => p.setBool('playScreenTutorialShown', true));
        };
        isTop = false;
        break;
    }

    return Positioned(
      top: isTop ? 20 : null,
      bottom: isTop ? null : 20,
      left: 10,
      right: 10,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: card.withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: green, width: 2),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.8), blurRadius: 30, spreadRadius: 10)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: green, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(desc, style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4)),
              if (showNext) ...[
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: nextEnabled ? onNext : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: green,
                      foregroundColor: bg,
                      disabledBackgroundColor: Colors.grey.withOpacity(0.3),
                      disabledForegroundColor: Colors.white54,
                    ),
                    child: Text(nextText, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget actionButton(String text, IconData icon, VoidCallback? onTap,
      {bool isPrimary = false, bool isTutorialGlow = false, Key? key}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      key: key,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: isTutorialGlow ? [BoxShadow(color: green.withOpacity(0.6), blurRadius: 15, spreadRadius: 2)] : [],
      ),
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
          disabledBackgroundColor: isPrimary ? green.withOpacity(0.3) : card.withOpacity(0.5),
          disabledForegroundColor: isPrimary ? bg.withOpacity(0.5) : Colors.white54,
          elevation: isPrimary && onTap != null ? 8 : 0,
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