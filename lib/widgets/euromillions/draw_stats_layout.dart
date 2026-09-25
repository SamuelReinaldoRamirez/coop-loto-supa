import 'package:flutter/material.dart';

import '../../utils/euromillions_utils.dart';
import 'numbers_row.dart';
import 'stats_widget.dart';

class DrawStatsLayout extends StatelessWidget {
  final dynamic drawDate;
  final List<dynamic> numbers;
  final dynamic star1;
  final dynamic star2;
  final Map<String, dynamic>? stats;

  const DrawStatsLayout({
    super.key,
    required this.drawDate,
    required this.numbers,
    required this.star1,
    required this.star2,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final isMock = numbers.any(
      (number) => number.toString() == 'X',
    );

    final drawNumbers = numbers
        .where(
          (number) => number.toString() != 'X',
        )
        .map(
          (number) => int.parse(number.toString()),
        )
        .toList();

    return SizedBox(
      height: 80,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _topRow(isMock),
          const SizedBox(height: 5),
          _stats(drawNumbers),
        ],
      ),
    );
  }

  Widget _topRow(bool isMock) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _numbers(isMock),
        _date(),
      ],
    );
  }

  Widget _date() {
    return Text(
      drawDate.toString() == 'X'
          ? 'X'
          : formatDrawDate(drawDate),
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
    );
  }

  Widget _numbers(bool isMock) {
    return NumbersRow(
      numbers: numbers,
      star1: star1,
      star2: star2,
      statsMode: !isMock,
      stats: stats,
      alignment: MainAxisAlignment.start,
    );
  }

  Widget _stats(List<int> drawNumbers) {
    if (stats == null) {
      return const Text(
        'Chargement des statistiques...',
        style: TextStyle(
          fontSize: 11,
        ),
      );
    }

    return StatsWidget(
      stats: stats!,
      drawNumbers: drawNumbers,
    );
  }
}