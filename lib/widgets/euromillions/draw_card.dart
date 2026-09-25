import 'package:flutter/material.dart';

import '../../utils/euromillions_utils.dart';
import 'number_ball.dart';
import 'stats_widget.dart';

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
    final drawNumbers = [
      int.parse(draw['n1'].toString()),
      int.parse(draw['n2'].toString()),
      int.parse(draw['n3'].toString()),
      int.parse(draw['n4'].toString()),
      int.parse(draw['n5'].toString()),
    ];

    return SizedBox(
      height: 100,
      child: Card(
        color: getCardColor(draw['winners']),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),

          title: Row(
            children: [
              for (final n in [
                draw['n1'],
                draw['n2'],
                draw['n3'],
                draw['n4'],
                draw['n5'],
              ])
                Padding(
                  padding: const EdgeInsets.only(right: 3),
                  child: NumberBall(
                    number: n,
                    color: Colors.blue,

                    // ---------------------------------
                    // COULEUR DU NUMÉRO
                    //
                    // Hot   -> rouge
                    // Cold  -> bleu
                    // Normal/retard -> blanc
                    // ---------------------------------

                    numberColor:
                        statsMode && stats != null
                            ? getNumberColor(
                                n,
                                stats!,
                              )
                            : Colors.white,

                    // ---------------------------------
                    // BORDURE
                    //
                    // Retard -> jaune
                    // Sinon -> aucune
                    //
                    // Cette information est indépendante
                    // de la couleur du numéro.
                    // ---------------------------------

                    borderColor:
                        statsMode &&
                                stats != null &&
                                isNumberOverdue(
                                  n,
                                  stats!,
                                )
                            ? Colors.yellow
                            : null,
                  ),
                ),

              const SizedBox(width: 5),

              NumberBall(
                number: draw['e1'],
                color: Colors.orange,
              ),

              const SizedBox(width: 3),

              NumberBall(
                number: draw['e2'],
                color: Colors.orange,
              ),
            ],
          ),

          subtitle: statsMode
              ? stats == null
                    ? const Text(
                        'Chargement des statistiques...',
                        style: TextStyle(
                          fontSize: 11,
                        ),
                      )
                    : StatsWidget(
                        stats: stats!,
                        drawNumbers: drawNumbers,
                      )
              : Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${draw['draw_date']} — ${getDrawDay(draw['draw_date'])}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Jackpot : ${formatJackpot(draw['jackpot'])} €',
                    ),
                    Text(
                      'Gagnants : ${draw['winners']}',
                      style: const TextStyle(
                        height: 1,
                      ),
                    ),
                  ],
                ),

          isThreeLine: !statsMode,

          onTap: onTap,
        ),
      ),
    );
  }
}