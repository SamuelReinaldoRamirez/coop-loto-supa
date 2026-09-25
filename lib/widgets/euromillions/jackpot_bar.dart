import 'package:flutter/material.dart';

import '../../utils/euromillions_utils.dart';

class JackpotBar extends StatelessWidget {
  static const int minJackpot = 10000000;
  static const int maxJackpot = 250000000;

  final dynamic jackpot;

  const JackpotBar({
    super.key,
    required this.jackpot,
  });

  @override
  Widget build(BuildContext context) {
    final isMock = jackpot.toString() == 'X';

    final double fill;
    final String label;

    if (isMock) {
      fill = 0.10;
      label = 'X';
    } else {
      final value = int.parse(jackpot.toString());

      double ratio =
          (value - minJackpot) /
          (maxJackpot - minJackpot);

      ratio = ratio.clamp(0.0, 1.0);

      fill = 0.05 + ratio * 0.90;
      label = '${formatJackpot(value)} €';
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: constraints.maxWidth,
              height: 22,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: constraints.maxWidth * fill,
                height: 22,
                decoration: BoxDecoration(
                  color: Colors.orange[300],
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        );
      },
    );
  }
}