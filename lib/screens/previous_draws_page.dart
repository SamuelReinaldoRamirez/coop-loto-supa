
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/api_service.dart';
import '../services/simulation/simulation_analysis_state.dart';
import '../services/simulation/simulation_draw_parser.dart';
import '../services/simulation/simulation_statistics_service.dart';
import '../widgets/euromillions/draw_card.dart';
import '../widgets/simulation/simulation_analysis_controls.dart';
import '../widgets/simulation/simulation_number_sort_mode.dart';

class PreviousDrawsPage extends StatefulWidget {
  final int groupId;
  final String username;

  const PreviousDrawsPage({
    super.key,
    required this.groupId,
    required this.username,
  });

  @override
  State<PreviousDrawsPage> createState() => _PreviousDrawsPageState();
}

class _PreviousDrawsPageState extends State<PreviousDrawsPage> {
  final ApiService _apiService = ApiService();

  final SimulationAnalysisState _analysisState =
      SimulationAnalysisState.instance;

  final SimulationStatisticsService _statisticsService =
      const SimulationStatisticsService();

  List<Map<String, dynamic>> _draws = [];

  bool _isLoading = true;
  String? _error;

  int get _availableDrawCount =>
      _draws.isEmpty ? 1 : _draws.length;

  int get _selectedDrawHistoryCount =>
      _analysisState.selectedDrawHistoryCount
          .clamp(1, _availableDrawCount)
          .toInt();

  int get _selectedHotCount =>
      _analysisState.selectedHotCount;

  int get _selectedColdCount =>
      _analysisState.selectedColdCount;

  int get _selectedOverdueCount =>
      _analysisState.selectedOverdueCount;

  @override
  void initState() {
    super.initState();

    _analysisState.addListener(_onAnalysisStateChanged);

    _loadDraws();
  }

  @override
  void dispose() {
    _analysisState.removeListener(_onAnalysisStateChanged);
    super.dispose();
  }

  void _onAnalysisStateChanged() {
    if (!mounted) return;

    setState(() {});
  }

  Future<void> _loadDraws() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final response = await _apiService.fetchEuromillionsDraws();

      final parsedDraws =
          SimulationDrawParser.parseResponse(response);

      if (!mounted) return;

      setState(() {
        _draws = parsedDraws;
        _isLoading = false;
        _error = null;
      });

      _analysisState.limitDrawHistory(_draws.length);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = 'Impossible de charger les tirages : $e';
      });
    }
  }

  /// Calcule les statistiques connues AVANT le tirage étudié.
  ///
  /// Les tirages sont triés du plus récent au plus ancien.
  /// On exclut donc le tirage courant et les tirages plus récents.
  ///
  /// Les listes retournées contiennent :
  /// - number : le numéro concerné ;
  /// - count : sa fréquence ou son retard.
  Map<String, dynamic> _buildStatsForDraw(int drawIndex) {
    final previousDraws = _draws.skip(drawIndex + 1).toList();

    // Aucun historique antérieur pour le tirage le plus ancien.
    if (previousDraws.isEmpty) {
      return {
        'hot': <Map<String, dynamic>>[],
        'cold': <Map<String, dynamic>>[],
        'overdue': <Map<String, dynamic>>[],
      };
    }

    // On utilise au maximum le nombre de tirages demandé
    // par le curseur noir, sans dépasser l'historique disponible.
    final historyCount = _analysisState.selectedDrawHistoryCount
        .clamp(1, previousDraws.length)
        .toInt();

    final statistics = _statisticsService.calculate(
      draws: previousDraws,
      selectedDrawCount: historyCount,
    );

    // Sélection des numéros chauds pour CE tirage.
    final hotNumbers = _statisticsService.selectHotNumbers(
      statistics.appearances,
      _selectedHotCount,
    );

    // Sélection des numéros froids pour CE tirage.
    final coldNumbers = _statisticsService.selectColdNumbers(
      statistics.appearances,
      _selectedColdCount,
    );

    // Sélection des numéros les plus en retard à cette date.
    // Le retard est calculé sur l'historique antérieur complet.
    final overdueNumbers = _statisticsService.selectOverdueNumbers(
      statistics.overdue,
      _selectedOverdueCount,
    );

    return {
      'hot': hotNumbers.map((number) {
        return {
          'number': number,
          'count': statistics.appearances[number] ?? 0,
        };
      }).toList(),

      'cold': coldNumbers.map((number) {
        return {
          'number': number,
          'count': statistics.appearances[number] ?? 0,
        };
      }).toList(),

      'overdue': overdueNumbers.map((number) {
        return {
          'number': number,
          'count': statistics.overdue[number] ?? 0,
        };
      }).toList(),
    };
  }

  void _onDrawHistoryChanged(double value) {
    _analysisState.setDrawHistoryCount(value);
  }

  void _onHotChanged(double value) {
    _analysisState.setHotCount(value);
  }

  void _onColdChanged(double value) {
    _analysisState.setColdCount(value);
  }

  void _onOverdueChanged(double value) {
    _analysisState.setOverdueCount(value);
  }

  Widget _buildAnalysisControls() {
    return SimulationAnalysisControls(
      drawHistoryCount: _analysisState.drawHistoryCount,
      hotCount: _analysisState.hotCount,
      coldCount: _analysisState.coldCount,
      overdueCount: _analysisState.overdueCount,
      drawHistoryMax: _availableDrawCount,
      selectedDrawHistoryCount: _selectedDrawHistoryCount,
      selectedHotCount: _selectedHotCount,
      selectedColdCount: _selectedColdCount,
      selectedOverdueCount: _selectedOverdueCount,
      onDrawHistoryChanged: _onDrawHistoryChanged,
      onHotChanged: _onHotChanged,
      onColdChanged: _onColdChanged,
      onOverdueChanged: _onOverdueChanged,
      sortModes: SimulationNumberSortMode.values,
      onSortModeChanged: (_) {},
    );
  }

  void _openDrawDetails(Map<String, dynamic> draw) {
    context.push(
      '/euromillions/${draw['id']}',
      extra: draw,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tirages précédents'),
        actions: [
          IconButton(
            tooltip: 'Actualiser les tirages',
            onPressed: _isLoading ? null : _loadDraws,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 42,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadDraws,
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        12,
                        8,
                        12,
                        4,
                      ),
                      child: _buildAnalysisControls(),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${_draws.length} tirages disponibles',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall,
                            ),
                          ),
                          Text(
                            'Historique : '
                            '$_selectedDrawHistoryCount tirages',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: _draws.isEmpty
                          ? const Center(
                              child: Text(
                                'Aucun tirage disponible.',
                              ),
                            )
                          : ListView.builder(
                              itemCount: _draws.length,
                              itemBuilder: (context, index) {
                                final draw = _draws[index];

                                // Statistiques propres à ce tirage.
                                final drawStats =
                                    _buildStatsForDraw(index);

                                return DrawCard(
                                  draw: draw,
                                  statsMode: true,
                                  stats: drawStats,
                                  onTap: () =>
                                      _openDrawDetails(draw),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}