import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/api_service.dart';
import '../services/simulation/simulation_draw_parser.dart';
import '../services/simulation/simulation_statistics_service.dart';
import '../widgets/simulation/simulation_analysis_controls.dart';
import '../widgets/simulation/simulation_body.dart';
import '../widgets/simulation/simulation_navigation_arrow.dart';
import '../widgets/simulation/simulation_number_sort_mode.dart';

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
  State<SimulateGridPage> createState() => _SimulateGridPageState();
}

class _SimulateGridPageState extends State<SimulateGridPage> {
  final ApiService _apiService = ApiService();
  final SimulationStatisticsService _statisticsService =
      const SimulationStatisticsService();

  bool _analysisHighlightEnabled = false;
  bool _squareBordersEnabled = false;
  List<SimulationNumberSortMode> _sortModes = [
    SimulationNumberSortMode.numericAscending,
  ];

  double _drawHistoryCount = 30;
  double _hotCount = 10;
  double _coldCount = 10;
  double _overdueCount = 10;

  List<Map<String, dynamic>> _draws = [];
  int _availableDrawCount = 1;
  bool _isLoadingDraws = true;
  String? _drawError;

  SimulationStatistics _statistics = SimulationStatistics.empty();

  int get _selectedDrawHistoryCount => _drawHistoryCount.round();
  int get _selectedHotCount => _hotCount.round();
  int get _selectedColdCount => _coldCount.round();
  int get _selectedOverdueCount => _overdueCount.round();

  List<int> get _hotNumbers => _statisticsService.selectHotNumbers(
        _statistics.appearances,
        _selectedHotCount,
      );

  List<int> get _coldNumbers => _statisticsService.selectColdNumbers(
        _statistics.appearances,
        _selectedColdCount,
      );

  List<int> get _overdueNumbers => _statisticsService.selectOverdueNumbers(
        _statistics.overdue,
        _selectedOverdueCount,
      );

  
  List<int> get _orderedNumbers {
    final numbers = List<int>.generate(50, (index) => index + 1);

    numbers.sort((a, b) {
      for (final mode in _sortModes) {
        int comparison;

        switch (mode) {
          case SimulationNumberSortMode.numericAscending:
            comparison = a.compareTo(b);
            break;

          case SimulationNumberSortMode.numericDescending:
            comparison = b.compareTo(a);
            break;

          case SimulationNumberSortMode.hotDescending:
            comparison = (_statistics.appearances[b] ?? 0)
                .compareTo(_statistics.appearances[a] ?? 0);
            break;

          case SimulationNumberSortMode.hotAscending:
            comparison = (_statistics.appearances[a] ?? 0)
                .compareTo(_statistics.appearances[b] ?? 0);
            break;

          case SimulationNumberSortMode.coldDescending:
            comparison = (_statistics.appearances[a] ?? 0)
                .compareTo(_statistics.appearances[b] ?? 0);
            break;

          case SimulationNumberSortMode.coldAscending:
            comparison = (_statistics.appearances[b] ?? 0)
                .compareTo(_statistics.appearances[a] ?? 0);
            break;

          case SimulationNumberSortMode.overdueDescending:
            comparison = (_statistics.overdue[b] ?? 0)
                .compareTo(_statistics.overdue[a] ?? 0);
            break;

          case SimulationNumberSortMode.overdueAscending:
            comparison = (_statistics.overdue[a] ?? 0)
                .compareTo(_statistics.overdue[b] ?? 0);
            break;
        }

        // Dès qu'un critère départage les deux numéros,
        // on utilise son résultat.
        if (comparison != 0) {
          return comparison;
        }
      }

      // Égalité sur tous les critères : ordre numérique croissant.
      return a.compareTo(b);
    });

    return numbers;
  }

  
  void _onSortModeChanged(SimulationNumberSortMode mode) {
    setState(() {
      // Un clic sur une flèche numérique réinitialise le tri.
      if (mode == SimulationNumberSortMode.numericAscending ||
          mode == SimulationNumberSortMode.numericDescending) {
        _sortModes = [mode];
        return;
      }

      // Un critère statistique remplace le sens opposé
      // du même critère.
      final oppositeModes = <SimulationNumberSortMode, SimulationNumberSortMode>{
        SimulationNumberSortMode.hotDescending:
            SimulationNumberSortMode.hotAscending,
        SimulationNumberSortMode.hotAscending:
            SimulationNumberSortMode.hotDescending,
        SimulationNumberSortMode.coldDescending:
            SimulationNumberSortMode.coldAscending,
        SimulationNumberSortMode.coldAscending:
            SimulationNumberSortMode.coldDescending,
        SimulationNumberSortMode.overdueDescending:
            SimulationNumberSortMode.overdueAscending,
        SimulationNumberSortMode.overdueAscending:
            SimulationNumberSortMode.overdueDescending,
      };

      // Le tri numérique explicite est retiré :
      // il restera le départage final croissant.
      _sortModes.remove(SimulationNumberSortMode.numericAscending);
      _sortModes.remove(SimulationNumberSortMode.numericDescending);

      // On retire l'ancien sens du critère choisi.
      final oppositeMode = oppositeModes[mode];
      if (oppositeMode != null) {
        _sortModes.remove(oppositeMode);
      }

      // Si ce critère était déjà présent, on le retire
      // pour le replacer en première position.
      _sortModes.remove(mode);
      _sortModes.insert(0, mode);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadAllDraws();
  }

  Future<void> _loadAllDraws() async {
    setState(() {
      _isLoadingDraws = true;
      _drawError = null;
    });

    try {
      debugPrint('[SimulateGridPage] Chargement de tous les tirages...');
      final response = await _apiService.fetchEuromillionsDraws();
      final parsedDraws = SimulationDrawParser.parseResponse(response);

      debugPrint('[SimulateGridPage] Tirages valides : ${parsedDraws.length}');

      if (!mounted) return;

      if (parsedDraws.isEmpty) {
        setState(() {
          _draws = [];
          _availableDrawCount = 1;
          _drawHistoryCount = 1;
          _statistics = SimulationStatistics.empty();
          _isLoadingDraws = false;
          _drawError = 'Aucun tirage valide disponible.';
        });
        return;
      }

      setState(() {
        _draws = parsedDraws;
        _availableDrawCount = parsedDraws.length;
        _drawHistoryCount = min(30, _availableDrawCount).toDouble();
        _isLoadingDraws = false;
        _drawError = null;
      });

      _recalculateStatistics();
    } catch (error, stackTrace) {
      debugPrint('[SimulateGridPage] Erreur chargement tirages : $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _isLoadingDraws = false;
        _drawError = 'Impossible de charger les tirages.';
      });
    }
  }

  void _recalculateStatistics() {
    if (_draws.isEmpty) return;

    final result = _statisticsService.calculate(
      draws: _draws,
      selectedDrawCount: _selectedDrawHistoryCount,
    );

    if (!mounted) return;
    setState(() {
      _statistics = result;
    });
  }

  void _onDrawHistoryChanged(double value) {
    setState(() {
      _drawHistoryCount = value.clamp(1, max(1, _availableDrawCount).toDouble()).toDouble();
    });
    _recalculateStatistics();
  }

  void _onHotChanged(double value) {
    setState(() {
      _hotCount = value.clamp(1, 50).toDouble();
    });
  }

  void _onColdChanged(double value) {
    setState(() {
      _coldCount = value.clamp(1, 50).toDouble();
    });
  }

  void _onOverdueChanged(double value) {
    setState(() {
      _overdueCount = value.clamp(1, 50).toDouble();
    });
  }

  void _toggleAnalysisHighlight() {
    setState(() {
      _analysisHighlightEnabled = !_analysisHighlightEnabled;
    });
  }

  void _toggleSquareBorders() {
    setState(() {
      _squareBordersEnabled = !_squareBordersEnabled;
    });
  }

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

  void _generateGrid() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Génération de grille — bientôt disponible.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          SimulationBody(
            isLoading: _isLoadingDraws,
            error: _drawError,
            onRetry: _loadAllDraws,
            availableDrawCount: _availableDrawCount,
            analysisControls: _buildAnalysisControls(),
            appearances: _statistics.appearances,
            overdue: _statistics.overdue,
            groupGridCount: _statistics.groupGridCount,
            hotNumbers: _hotNumbers,
            coldNumbers: _coldNumbers,
            overdueNumbers: _overdueNumbers,
            orderedNumbers: _orderedNumbers,
            analysisHighlightEnabled: _analysisHighlightEnabled,
            squareBordersEnabled: _squareBordersEnabled,
            onGenerateGrid: _generateGrid,
          ),
          if (!_isLoadingDraws && _drawError == null) ...[
            Positioned(
              left: 4,
              top: 0,
              bottom: 0,
              child: Center(
                child: SimulationNavigationArrow(
                  direction: NavigationArrowDirection.left,
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
                  direction: NavigationArrowDirection.right,
                  onTap: _openPreviousDraws,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'Simuler une grille',
        style: TextStyle(fontWeight: FontWeight.bold),
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
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade700,
          ),
        ),
        IconButton(
          tooltip: _analysisHighlightEnabled
              ? 'Masquer les analyses'
              : 'Afficher les analyses',
          onPressed: _toggleAnalysisHighlight,
          icon: Icon(
            Icons.arrow_right_rounded,
            size: 34,
            color: _analysisHighlightEnabled
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisControls() {
    return SimulationAnalysisControls(
      drawHistoryCount: _drawHistoryCount,
      hotCount: _hotCount,
      coldCount: _coldCount,
      overdueCount: _overdueCount,
      drawHistoryMax: _availableDrawCount,
      selectedDrawHistoryCount: _selectedDrawHistoryCount,
      selectedHotCount: _selectedHotCount,
      selectedColdCount: _selectedColdCount,
      selectedOverdueCount: _selectedOverdueCount,
      onDrawHistoryChanged: _onDrawHistoryChanged,
      onHotChanged: _onHotChanged,
      onColdChanged: _onColdChanged,
      onOverdueChanged: _onOverdueChanged,
      sortModes: _sortModes,
      onSortModeChanged: _onSortModeChanged,
    );
  }
}
