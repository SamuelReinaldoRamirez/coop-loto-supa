import 'package:flutter/material.dart';

import '../services/api_service.dart';

import '../services/simulation/simulation_analysis_state.dart';

import '../services/simulation/simulation_draw_parser.dart';

import '../services/simulation/simulation_statistics_service.dart';

import '../utils/euromillions_utils.dart';

import '../widgets/euromillions/number_ball.dart';

import '../widgets/simulation/simulation_analysis_controls.dart';

import '../widgets/simulation/simulation_number_sort_mode.dart';

class GroupPlayedGridsPage extends StatefulWidget {

  final int groupId;

  final String username;

  const GroupPlayedGridsPage({

    super.key,

    required this.groupId,

    required this.username,

  });

  @override

  State<GroupPlayedGridsPage> createState() =>

      _GroupPlayedGridsPageState();

}

class _GroupPlayedGridsPageState extends State<GroupPlayedGridsPage> {

  final ApiService _apiService = ApiService();

  final SimulationAnalysisState _analysisState =

      SimulationAnalysisState.instance;

  final SimulationStatisticsService _statisticsService =

      const SimulationStatisticsService();

  List<Map<String, dynamic>> _grids = [];

  List<Map<String, dynamic>> _draws = [];

  Map<int, int> _groupGridCount = {
    for (var number = 1; number <= 50; number++) number: 0,
  };

  bool _isLoading = true;

  String? _error;

  int get _availableDrawCount => _draws.isEmpty ? 1 : _draws.length;

  int get _selectedDrawHistoryCount =>

      _analysisState.selectedDrawHistoryCount

          .clamp(1, _availableDrawCount)

          .toInt();

  int get _selectedHotCount => _analysisState.selectedHotCount;

  int get _selectedColdCount => _analysisState.selectedColdCount;

  int get _selectedOverdueCount => _analysisState.selectedOverdueCount;

  @override

  void initState() {

    super.initState();

    _analysisState.addListener(_onAnalysisStateChanged);

    _loadGrids();

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

  // ---------------------------------------------------------

  // Chargement

  // ---------------------------------------------------------

  Future<void> _loadGrids() async {

    if (!mounted) return;

    setState(() {

      _isLoading = true;

      _error = null;

    });

    try {

      debugPrint(

        '[GroupPlayedGridsPage] '

        'Chargement des grilles du groupe ${widget.groupId}...',

      );

      final results = await Future.wait([

        _apiService.fetchGroupGridsNextDraw(widget.groupId),

        _apiService.fetchEuromillionsDraws(),

      ]);

      final gridsResponse = results[0] as List<dynamic>;

      final drawsResponse = results[1];

      final grids = gridsResponse.map((grid) {

        return Map<String, dynamic>.from(grid as Map);

      }).toList();

      final draws = SimulationDrawParser.parseResponse(drawsResponse);

      if (!mounted) return;

      setState(() {

        _grids = grids;

        _groupGridCount = _calculateGroupGridCount(grids);

        _draws = draws;

        _isLoading = false;

        _error = null;

      });

      _analysisState.limitDrawHistory(_draws.length);

      debugPrint(

        '[GroupPlayedGridsPage] '

        '${grids.length} grille(s) récupérée(s).',

      );

    } catch (error, stackTrace) {

      debugPrint('[GroupPlayedGridsPage] Erreur : $error');

      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {

        _isLoading = false;

        _error = 'Impossible de charger les grilles du groupe.';

      });

    }

  }

  // ---------------------------------------------------------

  // Lecture et formatage des données

  // ---------------------------------------------------------

  int _readInt(dynamic value) {

    if (value is int) return value;

    if (value is num) return value.toInt();

    return int.tryParse(value?.toString() ?? '') ?? 0;

  }

  DateTime? _readDate(dynamic value) {

    if (value == null) return null;

    return DateTime.tryParse(value.toString());

  }

  String _formatDate(dynamic value) {

    if (value == null || value.toString().trim().isEmpty) {

      return 'Date inconnue';

    }

    // Même formatage que dans DrawCard.

    return formatDrawDate(value);

  }

  List<int> _readNumbers(Map<String, dynamic> grid) {

    return [

      _readInt(grid['n1']),

      _readInt(grid['n2']),

      _readInt(grid['n3']),

      _readInt(grid['n4']),

      _readInt(grid['n5']),

    ];

  }

  // Compte toutes les grilles renvoyées par l'API, quel que soit leur statut
  // (jouée, validée, suggérée, annulée, etc.). Une grille compte au maximum
  // une fois pour chaque numéro principal.
  Map<int, int> _calculateGroupGridCount(
    List<Map<String, dynamic>> grids,
  ) {
    final counts = <int, int>{
      for (var number = 1; number <= 50; number++) number: 0,
    };

    for (final grid in grids) {
      final uniqueNumbers = _readNumbers(grid).toSet();
      for (final number in uniqueNumbers) {
        if (number >= 1 && number <= 50) {
          counts[number] = (counts[number] ?? 0) + 1;
        }
      }
    }

    return counts;
  }

  List<int> _readStars(Map<String, dynamic> grid) {

    return [

      _readInt(grid['e1']),

      _readInt(grid['e2']),

    ];

  }

  String _readAuthor(Map<String, dynamic> grid) {

    final pseudo = grid['author_pseudo']?.toString().trim();

    if (pseudo != null && pseudo.isNotEmpty) {

      return pseudo;

    }

    return 'Utilisateur inconnu';

  }

  String _readStatus(Map<String, dynamic> grid) {

    final status = grid['status']?.toString().trim();

    if (status == null || status.isEmpty) {

      return 'Statut inconnu';

    }

    switch (status.toLowerCase()) {

      case 'suggérée':

      case 'suggeree':

        return 'Suggérée';

      case 'jouée':

      case 'jouee':

        return 'Jouée';

      case 'validée':

      case 'validee':

        return 'Validée';

      case 'annulée':

      case 'annulee':

        return 'Annulée';

      default:

        return status;

    }

  }

  Color _statusColor(dynamic value) {

    switch (value?.toString().toLowerCase()) {

      case 'jouée':

      case 'jouee':

      case 'validée':

      case 'validee':

        return Colors.green.shade700;

      case 'annulée':

      case 'annulee':

        return Colors.red.shade700;

      case 'suggérée':

      case 'suggeree':

        return Colors.orange.shade800;

      default:

        return Colors.grey.shade700;

    }

  }

  // ---------------------------------------------------------

  // Statistiques historiques de chaque grille

  // ---------------------------------------------------------

  SimulationStatistics _statisticsForGrid(

    Map<String, dynamic> grid,

  ) {

    if (_draws.isEmpty) {

      return SimulationStatistics.empty();

    }

    final gridDate = _readDate(grid['draw_date']);

    if (gridDate == null) {

      return SimulationStatistics.empty();

    }

    // Les tirages sont supposés triés du plus récent au plus ancien.

    // On ne retient que ceux antérieurs à la date de la grille.

    final previousDraws = _draws.where((draw) {

      final drawDate = _readDate(draw['draw_date']);

      return drawDate != null && drawDate.isBefore(gridDate);

    }).toList();

    if (previousDraws.isEmpty) {

      return SimulationStatistics.empty();

    }

    final historyCount = _selectedDrawHistoryCount

        .clamp(1, previousDraws.length)

        .toInt();

    return _statisticsService.calculate(

      draws: previousDraws,

      selectedDrawCount: historyCount,

    );

  }

  Map<String, dynamic> _statsMapForGrid(

    SimulationStatistics statistics,

  ) {

    final hotNumbers = _statisticsService.selectHotNumbers(

      statistics.appearances,

      _selectedHotCount,

    );

    final coldNumbers = _statisticsService.selectColdNumbers(

      statistics.appearances,

      _selectedColdCount,

    );

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

  int _statValue(Map<int, int> values, int number) {

    return values[number] ?? 0;

  }

  // ---------------------------------------------------------

  // Trois indicateurs sous chaque numéro

  // ---------------------------------------------------------

  Widget _buildIndicator({

    required String value,

    required Color color,

    required double width,

  }) {

    return SizedBox(

      width: width,

      child: Text(

        value,

        textAlign: TextAlign.center,

        maxLines: 1,

        overflow: TextOverflow.clip,

        style: TextStyle(

          fontSize: 10,

          fontWeight: FontWeight.w700,

          color: color,

        ),

      ),

    );

  }

  Widget _buildNumberColumn({
    required int number,
    required Map<String, dynamic> stats,
    required SimulationStatistics statistics,
    required Set<int> hotNumbers,
    required Set<int> coldNumbers,
  }) {
    final overdueCount = _statValue(statistics.overdue, number);
    final appearanceCount = _statValue(statistics.appearances, number);

    final groupGridCount = _groupGridCount[number] ?? 0;

    final Color appearanceColor;

    if (hotNumbers.contains(number)) {
      appearanceColor = Colors.red;
    } else if (coldNumbers.contains(number)) {
      appearanceColor = Colors.blue.shade900;
    } else {
      final total = statistics.appearances.values.fold<int>(
        0,
        (sum, count) => sum + count,
      );

      final average = statistics.appearances.isEmpty
          ? 0.0
          : total / statistics.appearances.length;

      appearanceColor =
          appearanceCount >= average ? Colors.red : Colors.blue.shade900;
    }

    return SizedBox(
      width: 28,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Taille fixe : la bordure jaune ne doit jamais déplacer la boule.
          SizedBox(
            width: 26,
            height: 26,
            child: Stack(
              alignment: Alignment.center,
              children: [
                NumberBall(
                  number: number,
                  color: Colors.blue,
                  numberColor: getNumberColor(number, stats),
                ),
                if (isNumberOverdue(number, stats))
                  IgnorePointer(
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.yellow,
                          width: 2.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          _buildIndicator(
            value: '$groupGridCount',
            color: Colors.grey.shade600,
            width: double.infinity,
          ),
          _buildIndicator(
            value: '$overdueCount',
            color: Colors.amber.shade700,
            width: double.infinity,
          ),
          _buildIndicator(
            value: '$appearanceCount',
            color: appearanceColor,
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  Widget _buildStarColumn(int star) {
    return SizedBox(
      width: 26,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 26,
            height: 26,
            child: Center(
              child: NumberBall(
                number: star,
                color: Colors.orange,
              ),
            ),
          ),
          const SizedBox(height: 4),
          const SizedBox(height: 36),
        ],
      ),
    );
  }

  Widget _buildGridCard(Map<String, dynamic> grid) {
    final numbers = _readNumbers(grid);
    final stars = _readStars(grid);
    final statistics = _statisticsForGrid(grid);
    final stats = _statsMapForGrid(statistics);

    final hotNumbers = _statisticsService
        .selectHotNumbers(statistics.appearances, _selectedHotCount)
        .toSet();

    final coldNumbers = _statisticsService
        .selectColdNumbers(statistics.appearances, _selectedColdCount)
        .toSet();

    final drawDate = _formatDate(grid['draw_date']);
    final author = _readAuthor(grid);
    final status = _readStatus(grid);

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Largeurs fixes : les numéros restent regroupés à gauche,
                // comme dans PreviousDrawsPage, et libèrent de la place à la date.
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final number in numbers)
                      _buildNumberColumn(
                        number: number,
                        stats: stats,
                        statistics: statistics,
                        hotNumbers: hotNumbers,
                        coldNumbers: coldNumbers,
                      ),
                    const SizedBox(width: 5),
                    _buildStarColumn(stars[0]),
                    const SizedBox(width: 3),
                    _buildStarColumn(stars[1]),
                  ],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      drawDate,
                      textAlign: TextAlign.end,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    author,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Statut : ',
                  style: TextStyle(fontSize: 12),
                ),
                Flexible(
                  child: Text(
                    status,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _statusColor(grid['status']),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onDrawHistoryChanged(double value) {

    _analysisState.setDrawHistoryCount(

      value.clamp(1, _availableDrawCount.toDouble()).toDouble(),

    );

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

  // ---------------------------------------------------------

  // Corps de la page

  // ---------------------------------------------------------

  Widget _buildBody() {

    if (_isLoading) {

      return const Center(

        child: CircularProgressIndicator(),

      );

    }

    if (_error != null) {

      return Center(

        child: Padding(

          padding: const EdgeInsets.all(24),

          child: Column(

            mainAxisSize: MainAxisSize.min,

            children: [

              const Icon(

                Icons.cloud_off_outlined,

                size: 48,

                color: Colors.grey,

              ),

              const SizedBox(height: 12),

              Text(

                _error!,

                textAlign: TextAlign.center,

                style: const TextStyle(fontSize: 15),

              ),

              const SizedBox(height: 16),

              ElevatedButton.icon(

                onPressed: _loadGrids,

                icon: const Icon(Icons.refresh),

                label: const Text('Réessayer'),

              ),

            ],

          ),

        ),

      );

    }

    return Column(

      children: [

        Padding(

          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),

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

                  '${_grids.length} grille(s) enregistrée(s)',

                  style: Theme.of(context).textTheme.bodySmall,

                ),

              ),

              Text(

                'Historique : $_selectedDrawHistoryCount tirages',

                style: Theme.of(context).textTheme.bodySmall,

              ),

            ],

          ),

        ),

        const Divider(height: 1),

        Expanded(

          child: _grids.isEmpty

              ? RefreshIndicator(

                  onRefresh: _loadGrids,

                  child: ListView(

                    physics: const AlwaysScrollableScrollPhysics(),

                    padding: const EdgeInsets.all(24),

                    children: const [

                      SizedBox(height: 70),

                      Icon(

                        Icons.confirmation_number_outlined,

                        size: 56,

                        color: Colors.grey,

                      ),

                      SizedBox(height: 16),

                      Text(

                        'Aucune grille enregistrée',

                        textAlign: TextAlign.center,

                        style: TextStyle(

                          fontSize: 18,

                          fontWeight: FontWeight.bold,

                        ),

                      ),

                      SizedBox(height: 8),

                      Text(

                        'Les grilles ajoutées à ce groupe apparaîtront ici.',

                        textAlign: TextAlign.center,

                        style: TextStyle(color: Colors.black54),

                      ),

                    ],

                  ),

                )

              : RefreshIndicator(

                  onRefresh: _loadGrids,

                  child: ListView.builder(

                    physics: const AlwaysScrollableScrollPhysics(),

                    padding: const EdgeInsets.all(8),

                    itemCount: _grids.length,

                    itemBuilder: (context, index) {

                      return _buildGridCard(_grids[index]);

                    },

                  ),

                ),

        ),

      ],

    );

  }

  @override

  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(

        title: const Text(

          'Grilles jouées par votre groupe',

          style: TextStyle(fontWeight: FontWeight.bold),

        ),

        elevation: 0,

        actions: [

          IconButton(

            tooltip: 'Actualiser les grilles',

            onPressed: _isLoading ? null : _loadGrids,

            icon: const Icon(Icons.refresh),

          ),

        ],

      ),

      body: _buildBody(),

    );

  }

}