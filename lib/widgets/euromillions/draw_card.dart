import 'package:flutter/material.dart';

import '../../utils/euromillions_utils.dart';
import 'draw_normal_layout.dart';
import 'draw_stats_layout.dart';

class DrawCard extends StatelessWidget {
  final dynamic draw;
  final bool statsMode;
  final Map<String, dynamic>? stats;
  final VoidCallback onTap;

  const DrawCard({
    super.key,
    required this.draw,
    required this.statsMode,
    required this.stats,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final numbers = [
      draw['n1'],
      draw['n2'],
      draw['n3'],
      draw['n4'],
      draw['n5'],
    ];

    return Card(
      color: getCardColor(draw['winners']),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: statsMode
            ? DrawStatsLayout(
                drawDate: draw['draw_date'],
                numbers: numbers,
                star1: draw['e1'],
                star2: draw['e2'],
                stats: stats,
              )
            : DrawNormalLayout(
                drawDate: draw['draw_date'],
                numbers: numbers,
                star1: draw['e1'],
                star2: draw['e2'],
                jackpot: draw['jackpot'],
                winners: draw['winners'],
              ),
      ),
    );
  }
}