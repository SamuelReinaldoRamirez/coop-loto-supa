import 'package:flutter/material.dart';

class StatsWidget extends StatelessWidget {
  final Map<String, dynamic> stats;
  final List<dynamic>? drawNumbers;

  const StatsWidget({
    super.key,
    required this.stats,
    this.drawNumbers,
  });

  @override
  Widget build(BuildContext context) {
    final hot =
        (stats['hot'] as List?) ?? [];

    final cold =
        (stats['cold'] as List?) ?? [];

    final overdue =
        (stats['overdue'] as List?) ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _statsLine(
          'Hot : ',
          hot,
          color: Colors.red,
          showCount: true,
        ),

        const SizedBox(height: 2),

        _statsLine(
          'Cold : ',
          cold,
          color: Colors.blue.shade900,
          showCount: true,
        ),

        const SizedBox(height: 2),

        _overdueLine(overdue),
      ],
    );
  }

  // -----------------------------------------------------
  // Hot / Cold
  // -----------------------------------------------------

  Widget _statsLine(
    String label,
    List numbers, {
    required Color color,
    required bool showCount,
  }) {
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.clip,
      text: TextSpan(
        style: const TextStyle(
          color: Colors.black,
          fontSize: 11,
          height: 1.15,
        ),
        children: [
          TextSpan(
            text: label,
          ),

          ...numbers.map(
            (item) {
              final number = item['number'];

              final isInDraw =
                  drawNumbers?.contains(
                    int.parse(
                      number.toString(),
                    ),
                  ) ??
                  false;

              return TextSpan(
                text: showCount
                    ? '$number(${item['count']})  '
                    : '$number  ',

                style: TextStyle(
                  color: isInDraw
                      ? color
                      : Colors.black,
                  fontWeight: isInDraw
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------
  // Retard
  // -----------------------------------------------------

  Widget _overdueLine(List overdue) {
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.clip,
      text: TextSpan(
        style: const TextStyle(
          color: Colors.black,
          fontSize: 11,
          height: 1.15,
        ),
        children: [
          const TextSpan(
            text: 'Retard : ',
          ),

          ...overdue.map(
            (item) {
              final number = item['number'];

              final isInDraw =
                  drawNumbers?.contains(
                    int.parse(
                      number.toString(),
                    ),
                  ) ??
                  false;

              return TextSpan(
                text: '$number(${item['count']})  ',
                style: TextStyle(
                  color: isInDraw
                      ? Colors.yellow
                      : Colors.black,
                  fontWeight: isInDraw
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}