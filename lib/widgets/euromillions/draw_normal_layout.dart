import 'package:flutter/material.dart';

import '../../utils/euromillions_utils.dart';
import 'jackpot_bar.dart';
import 'numbers_row.dart';

class DrawNormalLayout extends StatelessWidget {
  final dynamic drawDate;
  final List<dynamic> numbers;
  final dynamic star1;
  final dynamic star2;
  final dynamic jackpot;
  final dynamic winners;

  const DrawNormalLayout({
    super.key,
    required this.drawDate,
    required this.numbers,
    required this.star1,
    required this.star2,
    required this.jackpot,
    required this.winners,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _topRow(),
          const SizedBox(height: 7),
          _jackpot(),
          const SizedBox(height: 6),
          _winners(),
        ],
      ),
    );
  }

  Widget _topRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _numbers(),
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

  Widget _numbers() {
    return NumbersRow(
      numbers: numbers,
      star1: star1,
      star2: star2,
      statsMode: false,
      stats: null,
      alignment: MainAxisAlignment.start,
    );
  }

  Widget _jackpot() {
    return JackpotBar(
      jackpot: jackpot,
    );
  }

  Widget _winners() {
    return Align(
      alignment: Alignment.bottomRight,
      child: Text(
        '$winners gagnants',
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey.shade700,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}