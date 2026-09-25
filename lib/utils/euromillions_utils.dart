import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String formatJackpot(dynamic jackpot) {
  final value = int.parse(jackpot.toString());

  return value.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ' ',
  );
}

String formatDrawDate(dynamic drawDate) {
  final date = DateTime.parse(drawDate.toString());

  final formatted = DateFormat(
    'EEEE d MMMM y',
    'fr_FR',
  ).format(date);

  return formatted[0].toUpperCase() + formatted.substring(1);
}

Color getCardColor(dynamic winners) {
  final count = int.parse(winners.toString());

  if (count == 1) {
    return const Color(0xFFD2B48C);
  }

  if (count > 1) {
    return const Color(0xFFF4CCCC);
  }

  return Colors.white;
}

Color getNumberColor(
  dynamic number,
  Map<String, dynamic> drawStats,
) {
  final numberValue = int.parse(number.toString());

  final hot = (drawStats['hot'] as List?) ?? [];
  final cold = (drawStats['cold'] as List?) ?? [];

  final isHot = hot.any(
    (item) => int.parse(item['number'].toString()) == numberValue,
  );

  final isCold = cold.any(
    (item) => int.parse(item['number'].toString()) == numberValue,
  );

  if (isHot) return Colors.red;
  if (isCold) return Colors.blue.shade900;

  return Colors.white;
}

bool isNumberOverdue(
  dynamic number,
  Map<String, dynamic> drawStats,
) {
  final numberValue = int.parse(number.toString());

  final overdue = (drawStats['overdue'] as List?) ?? [];

  return overdue.any(
    (item) => int.parse(item['number'].toString()) == numberValue,
  );
}