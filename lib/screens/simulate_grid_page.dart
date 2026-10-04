import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/simulation/simulation_analysis_controls.dart';
import '../widgets/simulation/simulation_legend.dart';
import '../widgets/simulation/simulation_navigation_arrow.dart';
import '../widgets/simulation/simulation_number_grid.dart';
import '../widgets/simulation/simulation_stars_grid.dart';

class SimulateGridPage extends StatefulWidget {
  final int groupId;
  final String username;
  final Map<String, dynamic>? stats;

  const SimulateGridPage({
    super.key,
    required this.groupId,
    required this.username,
    this.stats,
  });

  @override
  State<SimulateGridPage> createState() =>
      _SimulateGridPageState();
}

class _SimulateGridPageState extends State<SimulateGridPage> {
  final Random _random = Random();

  // ============================================================
  // EFFETS VISUELS
  // ============================================================

  bool _randomColorsEnabled = false;
  bool _squareBordersEnabled = false;

  final Map<int, Color> _randomNumberColors = {};

  // ============================================================
  // PARAMÈTRES D'ANALYSE
  // ============================================================

  double _drawHistoryCount = 20;
  double _hotCount = 5;
  double _coldCount = 5;
  double _overdueCount = 5;

  // ============================================================
  // DONNÉES MOCKÉES
  // ============================================================

  late final Map<int, int> _appearances;
  late final Map<int, int> _overdue;
  late final Map<int, int> _groupGridCount;

  @override
  void initState() {
    super.initState();

    _generateMockStatistics();
  }

  // ============================================================
  // GÉNÉRATION DES STATISTIQUES MOCKÉES
  // ============================================================

  void _generateMockStatistics() {
    _appearances = {};
    _overdue = {};
    _groupGridCount = {};

    for (int number = 1; number <= 50; number++) {
      _appearances[number] = _random.nextInt(11);
      _overdue[number] = _random.nextInt(21);
      _groupGridCount[number] = _random.nextInt(16);
    }
  }

  // ============================================================
  // VALEURS DES CURSEURS
  // ============================================================

  int get _selectedDrawHistoryCount =>
      _drawHistoryCount.round();

  int get _selectedHotCount =>
      _hotCount.round();

  int get _selectedColdCount =>
      _coldCount.round();

  int get _selectedOverdueCount =>
      _overdueCount.round();

  // ============================================================
  // NUMÉROS HOT
  // ============================================================

  List<int> get _hotNumbers {
    final numbers =
        List<int>.generate(50, (index) => index + 1);

    numbers.sort((a, b) {
      final comparison =
          _appearances[b]!.compareTo(_appearances[a]!);

      if (comparison != 0) {
        return comparison;
      }

      return a.compareTo(b);
    });

    return numbers.take(_selectedHotCount).toList();
  }

  // ============================================================
  // NUMÉROS COLD
  // ============================================================

  List<int> get _coldNumbers {
    final numbers =
        List<int>.generate(50, (index) => index + 1);

    numbers.sort((a, b) {
      final comparison =
          _appearances[a]!.compareTo(_appearances[b]!);

      if (comparison != 0) {
        return comparison;
      }

      return a.compareTo(b);
    });

    return numbers.take(_selectedColdCount).toList();
  }

  // ============================================================
  // NUMÉROS EN RETARD
  // ============================================================

  List<int> get _overdueNumbers {
    final numbers =
        List<int>.generate(50, (index) => index + 1);

    numbers.sort((a, b) {
      final comparison =
          _overdue[b]!.compareTo(_overdue[a]!);

      if (comparison != 0) {
        return comparison;
      }

      return a.compareTo(b);
    });

    return numbers.take(_selectedOverdueCount).toList();
  }

  // ============================================================
  // COULEURS ALÉATOIRES
  // ============================================================

  void _toggleRandomColors() {
    setState(() {
      _randomColorsEnabled = !_randomColorsEnabled;

      if (_randomColorsEnabled) {
        _randomNumberColors.clear();

        for (int number = 1; number <= 50; number++) {
          _randomNumberColors[number] =
              _random.nextBool()
                  ? Colors.red
                  : Colors.blue;
        }
      } else {
        _randomNumberColors.clear();
      }
    });
  }

  // ============================================================
  // CARRÉS
  // ============================================================

  void _toggleSquareBorders() {
    setState(() {
      _squareBordersEnabled =
          !_squareBordersEnabled;
    });
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  void _openPreviousDraws() {
    context.push(
      '/group/${widget.groupId}/previous-draws'
      '?username=${Uri.encodeComponent(widget.username)}',
    );
  }

  void _openGroupPlayedGrids() {
    context.push(
      '/group/${widget.groupId}/played-grids'
      '?username=${Uri.encodeComponent(widget.username)}',
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: _buildAppBar(context),
      body: _buildBody(context),
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
  ) {
    return AppBar(
      title: const Text(
        'Simuler une grille',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      elevation: 0,
      actions: [
        IconButton(
          tooltip: _squareBordersEnabled
              ? 'Désactiver les carrés'
              : 'Afficher les carrés',
          onPressed: _toggleSquareBorders,
          icon: Icon(
            Icons.arrow_left_rounded,
            size: 34,
            color: _squareBordersEnabled
                ? Theme.of(context)
                    .colorScheme
                    .primary
                : Colors.grey.shade700,
          ),
        ),
        IconButton(
          tooltip: _randomColorsEnabled
              ? 'Désactiver les couleurs'
              : 'Colorer les numéros',
          onPressed: _toggleRandomColors,
          icon: Icon(
            Icons.arrow_right_rounded,
            size: 34,
            color: _randomColorsEnabled
                ? Theme.of(context)
                    .colorScheme
                    .primary
                : Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody(BuildContext context) {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(
            55,
            16,
            55,
            30,
          ),
          children: [
            const Text(
              'Simulation',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Analyse des 50 numéros et des 12 étoiles.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 20),

            _buildAnalysisControls(),

            const SizedBox(height: 20),

            const Text(
              'Numéros',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              'Les statistiques affichées sur chaque numéro '
              'dépendent des paramètres ci-dessus.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 12),

            SimulationNumberGrid(
              appearances: _appearances,
              overdue: _overdue,
              groupGridCount: _groupGridCount,
              hotNumbers: _hotNumbers,
              coldNumbers: _coldNumbers,
              overdueNumbers: _overdueNumbers,
              randomColorsEnabled: _randomColorsEnabled,
              randomNumberColors: _randomNumberColors,
              squareBordersEnabled: _squareBordersEnabled,
            ),

            const SizedBox(height: 24),

            const Text(
              'Étoiles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            SimulationStarsGrid(
              squareBordersEnabled:
                  _squareBordersEnabled,
            ),

            const SizedBox(height: 24),

            const SimulationLegend(),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _generateGrid,
                icon: const Icon(
                  Icons.auto_awesome_rounded,
                ),
                label: const Text(
                  'Générer cette grille',
                ),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ],
        ),

        Positioned(
          left: 4,
          top: 0,
          bottom: 0,
          child: Center(
            child: SimulationNavigationArrow(
              direction:
                  NavigationArrowDirection.left,
              onTap: _openGroupPlayedGrids,
            ),
          ),
        ),

        Positioned(
          right: 4,
          top: 0,
          bottom: 0,
          child: Center(
            child: SimulationNavigationArrow(
              direction:
                  NavigationArrowDirection.right,
              onTap: _openPreviousDraws,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PARAMÈTRES D'ANALYSE
  // ============================================================

  Widget _buildAnalysisControls() {
    return SimulationAnalysisControls(
      drawHistoryCount: _drawHistoryCount,
      hotCount: _hotCount,
      coldCount: _coldCount,
      overdueCount: _overdueCount,
      selectedDrawHistoryCount:
          _selectedDrawHistoryCount,
      selectedHotCount: _selectedHotCount,
      selectedColdCount: _selectedColdCount,
      selectedOverdueCount:
          _selectedOverdueCount,
      onDrawHistoryChanged: (value) {
        setState(() {
          _drawHistoryCount = value;
        });
      },
      onHotChanged: (value) {
        setState(() {
          _hotCount = value;
        });
      },
      onColdChanged: (value) {
        setState(() {
          _coldCount = value;
        });
      },
      onOverdueChanged: (value) {
        setState(() {
          _overdueCount = value;
        });
      },
    );
  }

  // ============================================================
  // GÉNÉRATION
  // ============================================================

  void _generateGrid() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Génération de grille — bientôt disponible.',
        ),
      ),
    );
  }
}