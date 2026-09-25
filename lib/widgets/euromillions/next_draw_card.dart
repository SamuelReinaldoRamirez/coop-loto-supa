import 'package:flutter/material.dart';

import 'number_ball.dart';
import 'stats_widget.dart';

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
    return SizedBox(
      height: 100,
      child: Card(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          title: Row(
            children: [
              for (int i = 0; i < 5; i++)
                const Padding(
                  padding: EdgeInsets.only(right: 3),
                  child: NumberBall(
                    number: 'X',
                    color: Colors.blue,
                  ),
                ),

              const SizedBox(width: 5),

              const NumberBall(
                number: 'X',
                color: Colors.orange,
              ),

              const SizedBox(width: 3),

              const NumberBall(
                number: 'X',
                color: Colors.orange,
              ),
            ],
          ),
          subtitle: statsMode
              ? currentStats == null
                    ? const Text(
                        'Chargement des statistiques...',
                        style: TextStyle(fontSize: 11),
                      )
                    : StatsWidget(
                        stats: currentStats!,
                      )
              : const Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'X',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('Jackpot : X'),
                    Text(
                      'Gagnants : X',
                      style: TextStyle(height: 1),
                    ),
                  ],
                ),
          isThreeLine: !statsMode,
        ),
      ),
    );
  }
}