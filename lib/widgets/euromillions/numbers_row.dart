import 'package:flutter/material.dart';

import '../../utils/euromillions_utils.dart';
import 'number_ball.dart';

class NumbersRow extends StatelessWidget {
  final List<dynamic> numbers;
  final dynamic star1;
  final dynamic star2;
  final bool statsMode;
  final Map<String, dynamic>? stats;
  final MainAxisAlignment alignment;

  const NumbersRow({
    super.key,
    required this.numbers,
    required this.star1,
    required this.star2,
    required this.statsMode,
    required this.stats,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignment,
      children: [
        for (final n in numbers)
          Padding(
            padding: const EdgeInsets.only(right: 3),
            child: NumberBall(
              number: n,
              color: Colors.blue,
              numberColor:
                  statsMode && stats != null
                      ? getNumberColor(n, stats!)
                      : Colors.white,
              borderColor:
                  statsMode &&
                          stats != null &&
                          isNumberOverdue(n, stats!)
                      ? Colors.yellow
                      : null,
            ),
          ),

        const SizedBox(width: 5),

        NumberBall(
          number: star1,
          color: Colors.orange,
        ),

        const SizedBox(width: 3),

        NumberBall(
          number: star2,
          color: Colors.orange,
        ),
      ],
    );
  }
}