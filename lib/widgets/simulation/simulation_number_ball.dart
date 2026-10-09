import 'package:flutter/material.dart';

class SimulationNumberBall extends StatelessWidget {
  final int number;
  final int appearances;
  final int overdue;
  final int groupGridCount;
  final Color backgroundColor;
  final Color textColor;
  final Color hotColdColor;
  final bool isHot;
  final bool isCold;
  final bool isOverdue;
  final bool analysisHighlightEnabled;
  final bool squareBordersEnabled;

  const SimulationNumberBall({
    super.key,
    required this.number,
    required this.appearances,
    required this.overdue,
    required this.groupGridCount,
    required this.backgroundColor,
    required this.textColor,
    required this.hotColdColor,
    required this.isHot,
    required this.isCold,
    required this.isOverdue,
    required this.analysisHighlightEnabled,
    required this.squareBordersEnabled,
  });

  @override
  Widget build(BuildContext context) {
    final borderSide = _getBorderSide();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(squareBordersEnabled ? 3 : 50),
        border: borderSide.width > 0 ? Border.fromBorderSide(borderSide) : null,
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              '$number',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          Positioned(
            left: 4,
            top: 3,
            child: _buildBadge(
              value: overdue,
              color: Colors.amber.shade800,
              highlighted: isOverdue,
            ),
          ),
          Positioned(
            right: 4,
            top: 3,
            child: _buildBadge(
              value: appearances,
              color: hotColdColor,
              highlighted: isHot || isCold,
            ),
          ),
          Positioned(
            left: 4,
            bottom: 3,
            child: _buildBadge(
              value: groupGridCount,
              color: Colors.grey.shade700,
              highlighted: false,
            ),
          ),
        ],
      ),
    );
  }

  BorderSide _getBorderSide() {
    if (analysisHighlightEnabled && isOverdue) {
      return BorderSide(color: Colors.amber.shade700, width: 3);
    }

    if (squareBordersEnabled) {
      return const BorderSide(color: Colors.black54, width: 2);
    }

    return const BorderSide(color: Colors.transparent, width: 0);
  }

  Widget _buildBadge({
    required int value,
    required Color color,
    required bool highlighted,
  }) {
    return Container(
      constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: highlighted ? color.withOpacity(0.16) : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$value',
        style: TextStyle(
          fontSize: 9,
          fontWeight: highlighted ? FontWeight.bold : FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
