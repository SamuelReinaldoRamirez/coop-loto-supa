import 'dart:math';

import 'simulation_draw_parser.dart';

class SimulationStatistics {
  final Map<int, int> appearances;
  final Map<int, int> overdue;
  final Map<int, int> groupGridCount;

  const SimulationStatistics({
    required this.appearances,
    required this.overdue,
    required this.groupGridCount,
  });

  factory SimulationStatistics.empty() {
    return SimulationStatistics(
      appearances: {
        for (int number = 1; number <= 50; number++) number: 0,
      },
      overdue: {
        for (int number = 1; number <= 50; number++) number: 0,
      },
      groupGridCount: {
        for (int number = 1; number <= 50; number++) number: 5,
      },
    );
  }
}

class SimulationStatisticsService {
  const SimulationStatisticsService();

  /// Calcule les fréquences sur les derniers tirages sélectionnés
  /// et le retard sur l'intégralité des tirages disponibles.
  SimulationStatistics calculate({
    required List<Map<String, dynamic>> draws,
    required int selectedDrawCount,
  }) {
    final appearances = {
      for (int number = 1; number <= 50; number++) number: 0,
    };

    final overdue = {
      for (int number = 1; number <= 50; number++)
        number: draws.length,
    };

    final groupGridCount = {
      for (int number = 1; number <= 50; number++) number: 5,
    };

    if (draws.isEmpty) {
      return SimulationStatistics(
        appearances: appearances,
        overdue: overdue,
        groupGridCount: groupGridCount,
      );
    }

    final safeDrawCount = selectedDrawCount.clamp(1, draws.length).toInt();

    // Hot/Cold : nombre d'apparitions dans la fenêtre sélectionnée.
    for (final draw in draws.take(safeDrawCount)) {
      for (final number in SimulationDrawParser.extractMainNumbers(draw)) {
        appearances[number] = (appearances[number] ?? 0) + 1;
      }
    }

    // Retard : index de la première apparition dans l'historique trié.
    // L'index 0 correspond au tirage le plus récent.
    final foundNumbers = <int>{};

    for (int index = 0; index < draws.length; index++) {
      final numbers = SimulationDrawParser.extractMainNumbers(draws[index]);

      for (final number in numbers) {
        if (foundNumbers.add(number)) {
          overdue[number] = index;
        }
      }

      if (foundNumbers.length == 50) {
        break;
      }
    }

    return SimulationStatistics(
      appearances: appearances,
      overdue: overdue,
      groupGridCount: groupGridCount,
    );
  }

  List<int> selectHotNumbers(Map<int, int> appearances, int count) {
    final numbers = List<int>.generate(50, (index) => index + 1);

    numbers.sort((a, b) {
      final comparison = (appearances[b] ?? 0).compareTo(appearances[a] ?? 0);
      return comparison != 0 ? comparison : a.compareTo(b);
    });

    return numbers.take(min(count.clamp(0, 50).toInt(), 50)).toList();
  }

  List<int> selectColdNumbers(Map<int, int> appearances, int count) {
    final numbers = List<int>.generate(50, (index) => index + 1);

    numbers.sort((a, b) {
      final comparison = (appearances[a] ?? 0).compareTo(appearances[b] ?? 0);
      return comparison != 0 ? comparison : a.compareTo(b);
    });

    return numbers.take(min(count.clamp(0, 50).toInt(), 50)).toList();
  }

  List<int> selectOverdueNumbers(Map<int, int> overdue, int count) {
    final numbers = List<int>.generate(50, (index) => index + 1);

    numbers.sort((a, b) {
      final comparison = (overdue[b] ?? 0).compareTo(overdue[a] ?? 0);
      return comparison != 0 ? comparison : a.compareTo(b);
    });

    return numbers.take(min(count.clamp(0, 50).toInt(), 50)).toList();
  }
}
