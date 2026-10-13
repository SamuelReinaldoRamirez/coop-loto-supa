import 'dart:math';



import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';



import '../services/api_service.dart';

import '../services/simulation/simulation_analysis_state.dart';

import '../services/simulation/simulation_draw_parser.dart';

import '../services/simulation/simulation_statistics_service.dart';

import '../widgets/simulation/simulation_analysis_controls.dart';

import '../widgets/simulation/simulation_body.dart';

import '../widgets/simulation/simulation_navigation_arrow.dart';

import '../widgets/simulation/simulation_number_sort_mode.dart';
import 'package:timezone/timezone.dart' as tz;



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



  final SimulationAnalysisState _analysisState =

      SimulationAnalysisState.instance;



  bool _squareBordersEnabled = false;



  List<SimulationNumberSortMode> _sortModes = [

    SimulationNumberSortMode.numericAscending,

  ];



  List<Map<String, dynamic>> _draws = [];

  List<Map<String, dynamic>> _groupGrids = [];

  Map<int, int> _groupGridCount = {
    for (var number = 1; number <= 50; number++) number: 0,
  };



  int _availableDrawCount = 1;

  bool _isLoadingDraws = true;

  String? _drawError;



  SimulationStatistics _statistics = SimulationStatistics.empty();



  final Set<int> _selectedNumbers = <int>{};

  final Set<int> _selectedStars = <int>{};



  bool _isGeneratingGrid = false;



  bool get _analysisHighlightEnabled =>

      _analysisState.analysisHighlightEnabled;



  bool get _canGenerateGrid =>

      _selectedNumbers.length == 5 &&

      _selectedStars.length == 2 &&

      !_isGeneratingGrid;



  int get _selectedDrawHistoryCount =>

      _analysisState.selectedDrawHistoryCount

          .clamp(1, max(1, _availableDrawCount))

          .toInt();



  int get _selectedHotCount => _analysisState.selectedHotCount;

  int get _selectedColdCount => _analysisState.selectedColdCount;

  int get _selectedOverdueCount => _analysisState.selectedOverdueCount;



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

          case SimulationNumberSortMode.groupGridCountAscending:
            comparison = (_groupGridCount[a] ?? 0)
                .compareTo(_groupGridCount[b] ?? 0);
            break;

          case SimulationNumberSortMode.groupGridCountDescending:
            comparison = (_groupGridCount[b] ?? 0)
                .compareTo(_groupGridCount[a] ?? 0);
            break;

        }



        if (comparison != 0) {

          return comparison;

        }

      }



      return a.compareTo(b);

    });



    return numbers;

  }



    int _readGridNumber(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  Map<int, int> _calculateGroupGridCount(
    List<Map<String, dynamic>> grids,
  ) {
    final counts = <int, int>{
      for (var number = 1; number <= 50; number++) number: 0,
    };

    for (final grid in grids) {
      // Les statuts ne sont volontairement pas filtrés : les grilles
      // suggérées, jouées, validées et annulées sont toutes comptées.
      final numbers = <int>{
        _readGridNumber(grid['n1']),
        _readGridNumber(grid['n2']),
        _readGridNumber(grid['n3']),
        _readGridNumber(grid['n4']),
        _readGridNumber(grid['n5']),
      };

      for (final number in numbers) {
        if (number >= 1 && number <= 50) {
          counts[number] = (counts[number] ?? 0) + 1;
        }
      }
    }

    return counts;
  }

  @override
  void initState() {

    super.initState();



    _analysisState.addListener(_onAnalysisStateChanged);

    _loadAllDraws();

  }



  @override

  void dispose() {

    debugPrint('🔴 simulate grid page DISPOSE');



    _analysisState.removeListener(_onAnalysisStateChanged);



    super.dispose();

  }



  void _onAnalysisStateChanged() {

    if (!mounted) return;



    setState(() {});



    _recalculateStatistics();

  }



  Future<void> _loadAllDraws() async {

    if (!mounted) return;



    setState(() {

      _isLoadingDraws = true;

      _drawError = null;

    });



    try {

      debugPrint('[SimulateGridPage] Chargement de tous les tirages...');



      final responses = await Future.wait<dynamic>([
        _apiService.fetchEuromillionsDraws(),
        _apiService.fetchGroupGridsNextDraw(widget.groupId),
      ]);

      final response = responses[0];
      final gridsResponse = responses[1] as List<dynamic>;
      final parsedGroupGrids = gridsResponse
          .whereType<Map>()
          .map((grid) => Map<String, dynamic>.from(grid))
          .toList();
      final groupGridCounts = _calculateGroupGridCount(parsedGroupGrids);

      debugPrint(
        '[SimulateGridPage] Grilles du groupe : ${parsedGroupGrids.length}',
      );

      final parsedDraws = SimulationDrawParser.parseResponse(response);



      debugPrint(

        '[SimulateGridPage] Tirages valides : ${parsedDraws.length}',

      );



      if (!mounted) return;



      if (parsedDraws.isEmpty) {

        setState(() {

          _draws = [];

          _groupGrids = parsedGroupGrids;

          _groupGridCount = groupGridCounts;

          _availableDrawCount = 1;

          _statistics = SimulationStatistics.empty();

          _isLoadingDraws = false;

          _drawError = 'Aucun tirage valide disponible.';

        });



        _analysisState.limitDrawHistory(1);

        return;

      }



      setState(() {

        _draws = parsedDraws;

        _groupGrids = parsedGroupGrids;

        _groupGridCount = groupGridCounts;

        _availableDrawCount = parsedDraws.length;

        _isLoadingDraws = false;

        _drawError = null;

      });



      _analysisState.limitDrawHistory(_availableDrawCount);



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

    if (_draws.isEmpty || !mounted) return;



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

    _analysisState.setDrawHistoryCount(

      value.clamp(1, max(1, _availableDrawCount).toDouble()).toDouble(),

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



  void _onSortModeChanged(SimulationNumberSortMode mode) {

    setState(() {

      if (mode == SimulationNumberSortMode.numericAscending ||

          mode == SimulationNumberSortMode.numericDescending) {

        _sortModes = [mode];

        return;

      }



      final oppositeModes =

          <SimulationNumberSortMode, SimulationNumberSortMode>{

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

        SimulationNumberSortMode.groupGridCountDescending:
            SimulationNumberSortMode.groupGridCountAscending,
        SimulationNumberSortMode.groupGridCountAscending:
            SimulationNumberSortMode.groupGridCountDescending,
      };



      _sortModes.remove(SimulationNumberSortMode.numericAscending);

      _sortModes.remove(SimulationNumberSortMode.numericDescending);



      final oppositeMode = oppositeModes[mode];



      if (oppositeMode != null) {

        _sortModes.remove(oppositeMode);

      }



      _sortModes.remove(mode);

      _sortModes.insert(0, mode);

    });

  }



  void _toggleAnalysisHighlight() {

    _analysisState.setAnalysisHighlightEnabled(

      !_analysisState.analysisHighlightEnabled,

    );

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



  void _toggleNumber(int number) {

    if (!mounted) return;



    setState(() {

      if (_selectedNumbers.contains(number)) {

        _selectedNumbers.remove(number);

      } else if (_selectedNumbers.length < 5) {

        _selectedNumbers.add(number);

      }

    });

  }



  void _toggleStar(int star) {

    if (!mounted) return;



    setState(() {

      if (_selectedStars.contains(star)) {

        _selectedStars.remove(star);

      } else if (_selectedStars.length < 2) {

        _selectedStars.add(star);

      }

    });

  }



  Future<void> _generateGrid() async {

    if (_isGeneratingGrid) return;



    if (_selectedNumbers.length != 5 || _selectedStars.length != 2) {

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(

          content: Text(

            'Sélectionne exactement 5 numéros et 2 étoiles.',

          ),

        ),

      );



      return;

    }



    setState(() {

      _isGeneratingGrid = true;

    });



    try {

      final drawDate = _getNextDrawDate();



      final response = await _apiService.createGroupGrid(

        groupId: widget.groupId,

        numbers: _selectedNumbers.toList()..sort(),

        stars: _selectedStars.toList()..sort(),

        drawDate: drawDate,

      );



      if (!mounted) return;



      if (response['success'] != true) {

        throw Exception(

          response['message'] ?? 'Impossible d’enregistrer la grille.',

        );

      }



      setState(() {

        _selectedNumbers.clear();

        _selectedStars.clear();

      });



      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(

          content: Text(

            'Grille ajoutée au groupe pour le '

            '${drawDate.day.toString().padLeft(2, '0')}/'

            '${drawDate.month.toString().padLeft(2, '0')}/'

            '${drawDate.year}.',

          ),

        ),

      );

    } catch (error, stackTrace) {

      debugPrint('[SimulateGridPage] Erreur création grille : $error');

      debugPrintStack(stackTrace: stackTrace);



      if (!mounted) return;



      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(

          content: Text(

            'Erreur lors de l’enregistrement : ${error.toString()}',

          ),

        ),

      );

    } finally {

      if (mounted) {

        setState(() {

          _isGeneratingGrid = false;

        });

      }

    }

  }


  DateTime _getNextDrawDate([DateTime? now]) {
    final paris = tz.getLocation('Europe/Paris');

    // L'heure courante est toujours interprétée dans le
    // fuseau de Paris, quel que soit le fuseau du téléphone.
    final tz.TZDateTime current = now == null
        ? tz.TZDateTime.now(paris)
        : tz.TZDateTime.from(now, paris);

    final weekday = current.weekday;
    final minutes = current.hour * 60 + current.minute;

    const cutoff = 20 * 60;

    late final tz.TZDateTime nextDraw;

    // Mardi avant 20 h : tirage du mardi.
    if (weekday == DateTime.tuesday && minutes < cutoff) {
      nextDraw = tz.TZDateTime(
        paris,
        current.year,
        current.month,
        current.day,
      );
    }
    // Vendredi avant 20 h : tirage du vendredi.
    else if (weekday == DateTime.friday && minutes < cutoff) {
      nextDraw = tz.TZDateTime(
        paris,
        current.year,
        current.month,
        current.day,
      );
    }
    // Mardi à partir de 20 h : prochain tirage vendredi.
    else if (weekday == DateTime.tuesday) {
      nextDraw = tz.TZDateTime(
        paris,
        current.year,
        current.month,
        current.day + 3,
      );
    }
    // Vendredi à partir de 20 h : prochain tirage mardi.
    else if (weekday == DateTime.friday) {
      nextDraw = tz.TZDateTime(
        paris,
        current.year,
        current.month,
        current.day + 4,
      );
    }
    // Autres jours : prochain mardi.
    else {
      final daysUntilTuesday =
          (DateTime.tuesday - weekday + 7) % 7;

      nextDraw = tz.TZDateTime(
        paris,
        current.year,
        current.month,
        current.day + daysUntilTuesday,
      );
    }

    // Retourne une date sans heure, compatible avec un champ SQL DATE.
    // On conserve le jour calendaire de Paris sans convertir minuit
    // vers le fuseau du téléphone.
    return DateTime(
      nextDraw.year,
      nextDraw.month,
      nextDraw.day,
    );
  }



  // DateTime _getNextDrawDate([DateTime? now]) {

  //   final current = now ?? DateTime.now();



  //   final weekday = current.weekday;

  //   final minutes = current.hour * 60 + current.minute;

  //   const cutoff = 20 * 60;



  //   if (weekday == DateTime.tuesday && minutes < cutoff) {

  //     return DateTime(current.year, current.month, current.day);

  //   }



  //   if (weekday == DateTime.friday && minutes < cutoff) {

  //     return DateTime(current.year, current.month, current.day);

  //   }



  //   if (weekday == DateTime.tuesday) {

  //     return current.add(

  //       const Duration(days: 3),

  //     ).copyWith(

  //       hour: 0,

  //       minute: 0,

  //       second: 0,

  //       millisecond: 0,

  //       microsecond: 0,

  //     );

  //   }



  //   if (weekday == DateTime.friday) {

  //     return current.add(

  //       const Duration(days: 4),

  //     ).copyWith(

  //       hour: 0,

  //       minute: 0,

  //       second: 0,

  //       millisecond: 0,

  //       microsecond: 0,

  //     );

  //   }



  //   final daysUntilTuesday =

  //       (DateTime.tuesday - weekday + 7) % 7;



  //   return DateTime(

  //     current.year,

  //     current.month,

  //     current.day + daysUntilTuesday,

  //   );

  // }



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

            groupGridCount: _groupGridCount,

            hotNumbers: _hotNumbers,

            coldNumbers: _coldNumbers,

            overdueNumbers: _overdueNumbers,

            orderedNumbers: _orderedNumbers,

            analysisHighlightEnabled: _analysisHighlightEnabled,

            squareBordersEnabled: _squareBordersEnabled,

            selectedNumbers: _selectedNumbers,

            selectedStars: _selectedStars,

            onNumberTap: _toggleNumber,

            onStarTap: _toggleStar,

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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SimulationAnalysisControls(

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

      sortModes: _sortModes,

      onSortModeChanged: _onSortModeChanged,

        ),
      ],
    );
  }


}