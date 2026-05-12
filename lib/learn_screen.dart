import 'package:flutter/material.dart';
import 'theme.dart';

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