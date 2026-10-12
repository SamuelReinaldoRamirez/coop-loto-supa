enum SimulationNumberSortMode {
  numericAscending,
  numericDescending,
  hotDescending,
  hotAscending,
  coldDescending,
  coldAscending,
  overdueDescending,
  overdueAscending,
  groupGridCountAscending,
  groupGridCountDescending,
}

extension SimulationNumberSortModeLabel on SimulationNumberSortMode {
  String get label {
    switch (this) {
      case SimulationNumberSortMode.numericAscending:
        return 'Numéro croissant';
      case SimulationNumberSortMode.numericDescending:
        return 'Numéro décroissant';
      case SimulationNumberSortMode.hotDescending:
        return 'Hot numbers décroissant';
      case SimulationNumberSortMode.hotAscending:
        return 'Hot numbers croissant';
      case SimulationNumberSortMode.coldDescending:
        return 'Cold numbers décroissant';
      case SimulationNumberSortMode.coldAscending:
        return 'Cold numbers croissant';
      case SimulationNumberSortMode.overdueDescending:
        return 'Retard décroissant';
      case SimulationNumberSortMode.overdueAscending:
        return 'Retard croissant';
      case SimulationNumberSortMode.groupGridCountAscending:
        return 'Fréquence du groupe croissante';
      case SimulationNumberSortMode.groupGridCountDescending:
        return 'Fréquence du groupe décroissante';
    }
  }
}
