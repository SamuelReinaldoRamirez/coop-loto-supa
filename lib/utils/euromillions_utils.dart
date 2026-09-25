import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String formatJackpot(dynamic jackpot) {
  final value = int.parse(jackpot.toString());

  return value.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ' ',
  );
}

String getDrawDay(dynamic drawDate) {
  final date = DateTime.parse(drawDate.toString());

  return DateFormat(
    'EEEE',
    'fr_FR',
  ).format(date);
}

Color getCardColor(dynamic winners) {
  final count = int.parse(winners.toString());

  if (count == 1) {
    return const Color(0xFFD2B48C);
  }

  if (count > 1) {
    return const Color(0xFFF4CCCC);
  }

  return Colors.grey.shade500;
}

// -----------------------------------------------------
// Couleur du numéro
//
// Hot   -> rouge
// Cold  -> bleu
// Retard seul -> blanc
// Normal -> blanc
//
// IMPORTANT : le retard ne change PAS la couleur
// du numéro. Il est géré séparément par la bordure.
// -----------------------------------------------------

Color getNumberColor(
  dynamic number,
  Map<String, dynamic> drawStats,
) {
  final numberValue = int.parse(number.toString());

  final hot = (drawStats['hot'] as List?) ?? [];
  final cold = (drawStats['cold'] as List?) ?? [];

  final isHot = hot.any(
    (item) =>
        int.parse(item['number'].toString()) == numberValue,
  );

  final isCold = cold.any(
    (item) =>
        int.parse(item['number'].toString()) == numberValue,
  );

  // Hot est prioritaire si jamais les listes
  // présentent un chevauchement.
  if (isHot) {
    return Colors.red;
  }

  if (isCold) {
    return Colors.blue.shade900;
  }

  return Colors.white;
}

// -----------------------------------------------------
// Est-ce que le numéro est en retard ?
// -----------------------------------------------------

bool isNumberOverdue(
  dynamic number,
  Map<String, dynamic> drawStats,
) {
  final numberValue = int.parse(number.toString());

  final overdue =
      (drawStats['overdue'] as List?) ?? [];

  return overdue.any(
    (item) =>
        int.parse(item['number'].toString()) == numberValue,
  );
}