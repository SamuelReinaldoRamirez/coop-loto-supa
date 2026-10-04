import 'package:flutter/material.dart';

class SimulationNumberGrid extends StatelessWidget {
  final Map<int, int> appearances;
  final Map<int, int> overdue;
  final Map<int, int> groupGridCount;

  final List<int> hotNumbers;
  final List<int> coldNumbers;
  final List<int> overdueNumbers;

  final bool randomColorsEnabled;
  final Map<int, Color> randomNumberColors;
  final bool squareBordersEnabled;

  const SimulationNumberGrid({
    super.key,
    required this.appearances,
    required this.overdue,
    required this.groupGridCount,
    required this.hotNumbers,
    required this.coldNumbers,
    required this.overdueNumbers,
    required this.randomColorsEnabled,
    required this.randomNumberColors,
    required this.squareBordersEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(),
      itemCount: 50,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final number = index + 1;

        return _buildNumber(
          number,
          color: _getNumberColor(number),
          textColor:
              _getNumberTextColor(number),
        );
      },
    );
  }

  Widget _buildNumber(
    int number, {
    required Color color,
    required Color textColor,
  }) {
    final numberAppearances =
        appearances[number] ?? 0;

    final numberOverdue =
        overdue[number] ?? 0;

    final numberGroupGridCount =
        groupGridCount[number] ?? 0;

    final isHot =
        hotNumbers.contains(number);

    final isCold =
        coldNumbers.contains(number);

    final isOverdue =
        overdueNumbers.contains(number);

    return AnimatedContainer(
      duration:
          const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: color,
        borderRadius:
            squareBordersEnabled
                ? BorderRadius.circular(3)
                : BorderRadius.circular(50),
        border: Border.all(
          color: squareBordersEnabled
              ? Colors.black54
              : Colors.transparent,
          width: squareBordersEnabled
              ? 2
              : 0,
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              '$number',
              style: TextStyle(
                fontSize: 15,
                fontWeight:
                    FontWeight.bold,
                color: textColor,
              ),
            ),
          ),

          Positioned(
            left: 4,
            top: 3,
            child: _buildStatisticBadge(
              value: numberOverdue,
              color: Colors.amber.shade800,
              highlighted: isOverdue,
            ),
          ),

          Positioned(
            right: 4,
            top: 3,
            child: _buildStatisticBadge(
              value: numberAppearances,
              color: Colors.red,
              highlighted: isHot,
            ),
          ),

          Positioned(
            left: 4,
            bottom: 3,
            child: _buildStatisticBadge(
              value: numberGroupGridCount,
              color: Colors.grey.shade700,
              highlighted: false,
            ),
          ),

          Positioned(
            right: 4,
            bottom: 3,
            child: _buildStatisticBadge(
              value: numberGroupGridCount,
              color: Colors.blue.shade700,
              highlighted: isCold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getNumberColor(int number) {
    if (!randomColorsEnabled) {
      return Colors.grey.shade200;
    }

    return randomNumberColors[number] ??
        Colors.grey.shade200;
  }

  Color _getNumberTextColor(int number) {
    if (!randomColorsEnabled) {
      return Colors.black87;
    }

    return Colors.white;
  }

  Widget _buildStatisticBadge({
    required int value,
    required Color color,
    required bool highlighted,
  }) {
    return Container(
      constraints:
          const BoxConstraints(
        minWidth: 15,
        minHeight: 15,
      ),
      alignment: Alignment.center,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 2,
      ),
      decoration: BoxDecoration(
        color: highlighted
            ? color.withOpacity(0.16)
            : Colors.transparent,
        borderRadius:
            BorderRadius.circular(4),
      ),
      child: Text(
        '$value',
        style: TextStyle(
          fontSize: 9,
          fontWeight:
              highlighted
                  ? FontWeight.bold
                  : FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}