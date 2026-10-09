/// Critères de tri de la grille des 50 numéros.
enum SimulationNumberSortMode {
  numericAscending,
  numericDescending,
  hotDescending,
  hotAscending,
  coldDescending,
  coldAscending,
  overdueDescending,
  overdueAscending,
}

extension SimulationNumberSortModeLabel on SimulationNumberSortMode {
  String get label {
    switch (this) {
      case SimulationNumberSortMode.numericAscending:
        return 'Ordre numérique';
      case SimulationNumberSortMode.numericDescending:
        return 'Ordre numérique décroissant';
      case SimulationNumberSortMode.hotDescending:
        return 'Du plus hot au moins hot';
      case SimulationNumberSortMode.hotAscending:
        return 'Du moins hot au plus hot';
      case SimulationNumberSortMode.coldDescending:
        return 'Du plus cold au moins cold';
      case SimulationNumberSortMode.coldAscending:
        return 'Du moins cold au plus cold';
      case SimulationNumberSortMode.overdueDescending:
        return 'Du plus en retard au moins en retard';
      case SimulationNumberSortMode.overdueAscending:
        return 'Du moins en retard au plus en retard';
    }
  }
}
