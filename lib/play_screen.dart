import 'dart:async';
import 'package:flutter/material.dart';
import 'theme.dart';

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
      const Duration(milliseconds: 250),
      (_) {
        _doTick();
      },
    );
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
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double cellWidth = constraints.maxWidth / size;
                        return GestureDetector(
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
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
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
                      padding: EdgeInsets.only(bottom: 12),
                      child: Text(
                        "Press grid and click Let's Go to run simulation",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ),
                  Text(
                    "Status: $status   •   Alive: $aliveCount",
                    style: const TextStyle(
                        color: green,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
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
                const SizedBox(width: 8),
                Expanded(
                  child: actionButton(
                    "Pause",
                    Icons.pause,
                    pause,
                    isPrimary: false,
                  ),
                ),
                const SizedBox(width: 8),
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