import 'package:flutter/material.dart';

import 'simulation_number_ball.dart';

class SimulationNumberGrid extends StatelessWidget {
  final Map<int, int> appearances;
  final Map<int, int> overdue;
  final Map<int, int> groupGridCount;
  final List<int> hotNumbers;
  final List<int> coldNumbers;
  final List<int> overdueNumbers;
  final List<int> orderedNumbers;
  final bool analysisHighlightEnabled;
  final bool squareBordersEnabled;

  const SimulationNumberGrid({
    super.key,
    required this.appearances,
    required this.overdue,
    required this.groupGridCount,
    required this.hotNumbers,
    required this.coldNumbers,
    required this.overdueNumbers,
    required this.orderedNumbers,
    required this.analysisHighlightEnabled,
    required this.squareBordersEnabled,
  });

  @override
  Widget build(BuildContext context) {
    final hotSet = hotNumbers.toSet();
    final coldSet = coldNumbers.toSet();
    final overdueSet = overdueNumbers.toSet();

    final totalAppearances = List<int>.generate(
      50,
      (index) => appearances[index + 1] ?? 0,
    ).fold<int>(0, (sum, value) => sum + value);
    final average = totalAppearances / 50;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 50,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final number = orderedNumbers[index];
        final isHot = hotSet.contains(number);
        final isCold = coldSet.contains(number);
        final isOverdue = overdueSet.contains(number);

        final Color hotColdColor;
        if (isHot) {
          hotColdColor = Colors.red;
        } else if (isCold) {
          hotColdColor = Colors.blue.shade700;
        } else {
          hotColdColor = (appearances[number] ?? 0) > average
              ? Colors.red
              : Colors.blue.shade700;
        }

        final Color backgroundColor;
        if (!analysisHighlightEnabled) {
          backgroundColor = Colors.grey.shade200;
        } else if (isHot) {
          backgroundColor = Colors.red;
        } else if (isCold) {
          backgroundColor = Colors.blue.shade700;
        } else {
          backgroundColor = Colors.grey.shade200;
        }

        final textColor = analysisHighlightEnabled && (isHot || isCold)
            ? Colors.white
            : Colors.black87;

        return SimulationNumberBall(
          number: number,
          appearances: appearances[number] ?? 0,
          overdue: overdue[number] ?? 0,
          groupGridCount: groupGridCount[number] ?? 5,
          backgroundColor: backgroundColor,
          textColor: textColor,
          hotColdColor: hotColdColor,
          isHot: isHot,
          isCold: isCold,
          isOverdue: isOverdue,
          analysisHighlightEnabled: analysisHighlightEnabled,
          squareBordersEnabled: squareBordersEnabled,
        );
      },
    );
  }
}
