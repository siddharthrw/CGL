import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
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

  bool _isSpeedUp = false;
  int _hardWinCount = 0;
  bool _showLevelPopup = false;

  @override
  void initState() {
    super.initState();
    grid = List.generate(
      size,
      (_) => List.filled(size, 0),
    );
  }

  void _triggerOverlay() {
    setState(() {
      _showOverlay = true;
    });
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() => _showOverlay = false);
      }
    });
  }

  void _handleWin() {
    // Check if the current settings match the 'Hard' level
    if (widget.birthRule == 4 && widget.surviveMin == 4 && widget.surviveMax == 4) {
      _hardWinCount++;
      if (_hardWinCount == 2) {
        _showLevelPopup = true;
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) setState(() => _showLevelPopup = false);
        });
      }
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

    history.clear();
    history.add(_gridToString(grid));

    _setTimer();
  }

  void _setTimer() {
    timer?.cancel();
    // Reduced overall speed (500ms), but runs twice as fast (200ms) when held
    int speed = _isSpeedUp ? 200 : 500;
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

    setState(() {
      generation++;
      grid = nextGrid;
    });

    String nextStr = _gridToString(nextGrid);
    bool isOscillating = !isSame && history.contains(nextStr);

    if (aliveCount == 0) {
      pause();
      bool isNew = gameEndTitle == null;
      setState(() {
        gameEndTitle = "THE END";
        gameEndMessage = "All cells are empty. The pattern faded away.";
        isWin = false;
      });
      if (isNew) _triggerOverlay();
    } else if (isSame) {
      pause();
      bool isNew = gameEndTitle == null;
      setState(() {
        gameEndTitle = "STABILIZED!";
        gameEndMessage = "The cells have found a stable balance.";
        isWin = true;
      });
      if (isNew) { _triggerOverlay(); _handleWin(); }
    } else {
      if (isOscillating) {
        bool isNew = gameEndTitle == null;
        setState(() {
          gameEndTitle = "ENDLESS LOOP!";
          gameEndMessage = "The cells are trapped in a repeating pattern!";
          isWin = true;
        });
        if (isNew) { _triggerOverlay(); _handleWin(); }
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

  void clear() {
    timer?.cancel();

    setState(() {
      generation = 0;
      gameEndTitle = null;
      gameEndMessage = null;
      isWin = false;
      _showOverlay = false;
      history.clear();

      grid = List.generate(
        size,
        (_) => List.filled(size, 0),
      );
    });
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
                          IconButton(
                            key: widget.ruleLabBtnKey,
                                icon: const Icon(Icons.filter_list, color: green),
                            onPressed: widget.onRuleLabTap,
                            tooltip: "Rule Lab",
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
                  const SizedBox(height: 20),
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
                                            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 40),
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
                    height: 116,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (gameEndTitle != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            margin: const EdgeInsets.only(bottom: 12),
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
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 13),
                                ),
                              ],
                            ),
                          )
                        else
                          const Padding(
                            padding: EdgeInsets.only(bottom: 12, left: 16, right: 16),
                            child: Text(
                              "Draw cells on the grid and press Play!",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
                            ),
                          ),
                        Text(
                          "Status: $status   •   Live cells: $aliveCount",
                          style: const TextStyle(
                              color: green,
                              fontWeight: FontWeight.bold,
                              fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
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
                  onTapDown: (_) {
                    setState(() => _isSpeedUp = true);
                    _updateSpeed();
                  },
                  onTapUp: (_) {
                    setState(() => _isSpeedUp = false);
                    _updateSpeed();
                  },
                  onTapCancel: () {
                    setState(() => _isSpeedUp = false);
                    _updateSpeed();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    height: 52,
                    width: 52,
                    decoration: BoxDecoration(
                      color: _isSpeedUp ? green : card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _isSpeedUp ? green : Colors.white.withOpacity(0.1)),
                    ),
                    child: Center(
                      child: Text("2x", style: TextStyle(
                        color: _isSpeedUp ? bg : Colors.white,
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
                    onPressed: clear,
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
                  ),
                ),
              ],
            ),
          ],
        ),
        if (_showLevelPopup)
          Positioned(
            top: 45,
            right: 16,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: green,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: green.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Want to try changing the level?", style: TextStyle(color: bg, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => setState(() => _showLevelPopup = false),
                      child: const Icon(Icons.close, color: bg, size: 18),
                    )
                  ],
                ),
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