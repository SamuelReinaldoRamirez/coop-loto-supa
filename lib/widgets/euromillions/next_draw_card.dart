import 'package:flutter/material.dart';

import 'draw_normal_layout.dart';
import 'draw_stats_layout.dart';

class NextDrawCard extends StatelessWidget {
  final bool statsMode;
  final Map<String, dynamic>? currentStats;

  const NextDrawCard({
    super.key,
    required this.statsMode,
    required this.currentStats,
  });

  @override
  Widget build(BuildContext context) {
    const numbers = [
      'X',
      'X',
      'X',
      'X',
      'X',
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: statsMode
            ? DrawStatsLayout(
                drawDate: 'X',
                numbers: numbers,
                star1: 'X',
                star2: 'X',
                stats: currentStats,
              )
            : const DrawNormalLayout(
                drawDate: 'X',
                numbers: numbers,
                star1: 'X',
                star2: 'X',
                jackpot: 'X',
                winners: 'X',
              ),
      ),
    );
  }
}