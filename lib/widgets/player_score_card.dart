// widgets/player_score_card.dart (FIXED VERSION)
import 'package:flutter/material.dart';

import 'score_button.dart';

class PlayerScoreCard extends StatelessWidget {
  final String playerName;
  final int score;
  final int rank;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final bool isAnimating;

  const PlayerScoreCard({
    super.key,
    required this.playerName,
    required this.score,
    required this.rank,
    required this.onIncrement,
    required this.onDecrement,
    this.isAnimating = false,
  });

  @override
  Widget build(BuildContext context) {
    final isLeader = rank == 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: isLeader ? 12 : 4,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: isLeader
                ? LinearGradient(
                    colors: [
                      const Color(0xFFFFD700).withOpacity(0.1),
                      const Color(0xFFFFA000).withOpacity(0.05),
                    ],
                  )
                : null,
            border: isLeader
                ? Border.all(
                    color: const Color(0xFFFFD700).withOpacity(0.5),
                    width: 2,
                  )
                : null,
          ),
          child: Padding(
            padding:
                const EdgeInsets.all(16), // Reduced padding to prevent overflow
            child: Column(
              // FIX: Change to Column layout to prevent Row overflow
              children: [
                // Top Row: Avatar and Player Info
                Row(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: isLeader
                                  ? [
                                      const Color(0xFFFFD700),
                                      const Color(0xFFFFA000)
                                    ]
                                  : [
                                      Theme.of(context).primaryColor,
                                      Theme.of(context).colorScheme.secondary,
                                    ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isLeader
                                    ? const Color(0xFFFFD700).withOpacity(0.4)
                                    : Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.3),
                                blurRadius: isLeader ? 12 : 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              playerName[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        if (rank <= 3)
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: rank == 1
                                    ? const Color(0xFFFFD700)
                                    : rank == 2
                                        ? const Color(0xFFC0C0C0)
                                        : const Color(0xFFCD7F32),
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                              child: Center(
                                child: Text(
                                  '$rank',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                // FIX: Use Flexible to prevent text overflow
                                child: Text(
                                  playerName,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isLeader) ...[
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.emoji_events,
                                  color: Color(0xFFFFD700),
                                  size: 24,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 300),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isLeader
                                  ? const Color(0xFFFFD700)
                                  : Theme.of(context).primaryColor,
                            ),
                            child: Text('$score points'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Bottom Row: Score Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScoreButton(
                      icon: Icons.remove,
                      color: Theme.of(context).colorScheme.error,
                      onPressed: onDecrement,
                      tooltip: 'Remove point',
                    ),
                    const SizedBox(width: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[800]
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.3),
                        ),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          '$score',
                          key: ValueKey(score),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    ScoreButton(
                      icon: Icons.add,
                      color: const Color(0xFF00E676),
                      onPressed: onIncrement,
                      tooltip: 'Add point',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
