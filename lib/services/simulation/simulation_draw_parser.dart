class SimulationDrawParser {
  const SimulationDrawParser._();

  /// Valide, extrait et trie les tirages du plus récent au plus ancien.
  ///
  /// Chaque tirage retourné conserve les champs de l'API et reçoit
  /// un champ interne `_parsedDate` de type DateTime.
  static List<Map<String, dynamic>> parseResponse(
    Iterable<dynamic> response,
  ) {
    final parsedDraws = <Map<String, dynamic>>[];

    for (final item in response) {
      if (item is! Map) {
        continue;
      }

      final draw = Map<String, dynamic>.from(item);
      final drawDate = DateTime.tryParse('${draw['draw_date']}');

      if (drawDate == null) {
        continue;
      }

      final numbers = extractMainNumbers(draw);

      if (numbers.length != 5) {
        continue;
      }

      parsedDraws.add({
        ...draw,
        '_parsedDate': drawDate,
      });
    }

    parsedDraws.sort((a, b) {
      final dateA = a['_parsedDate'] as DateTime;
      final dateB = b['_parsedDate'] as DateTime;
      return dateB.compareTo(dateA);
    });

    return parsedDraws;
  }

  /// Extrait les cinq numéros principaux, compris entre 1 et 50.
  static List<int> extractMainNumbers(Map<String, dynamic> draw) {
    final numbers = <int>[];

    for (int i = 1; i <= 5; i++) {
      final value = draw['n$i'];
      if (value == null) {
        continue;
      }

      final number = int.tryParse(value.toString());
      if (number != null && number >= 1 && number <= 50) {
        numbers.add(number);
      }
    }

    return numbers;
  }
}
