import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/api_service.dart';
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

  final ApiService _apiService = ApiService();

  // ============================================================
  // EFFETS VISUELS
  // ============================================================

  bool _randomColorsEnabled = false;
  bool _squareBordersEnabled = false;

  final Map<int, Color> _randomNumberColors = {};

  // ============================================================
  // PARAMÈTRES D'ANALYSE
  // ============================================================

  double _drawHistoryCount = 30;
  double _hotCount = 10;
  double _coldCount = 10;
  double _overdueCount = 10;

  // ============================================================
  // TIRAGES CHARGÉS EN MÉMOIRE
  // ============================================================

  List<Map<String, dynamic>> _draws = [];

  int _availableDrawCount = 1;

  bool _isLoadingDraws = true;

  String? _drawError;

  // ============================================================
  // STATISTIQUES CALCULÉES
  // ============================================================

  Map<int, int> _appearances = {};
  Map<int, int> _overdue = {};

  // Pour le moment conservé pour ton affichage existant.
  // On pourra ensuite le calculer réellement à partir
  // des grilles du groupe.
  Map<int, int> _groupGridCount = {};

  // ============================================================
  // INITIALISATION
  // ============================================================

  @override
  void initState() {
    super.initState();

    _generateInitialGroupStatistics();
    _loadAllDraws();
  }

  // ============================================================
  // CHARGEMENT DE TOUS LES TIRAGES
  // ============================================================

  Future<void> _loadAllDraws() async {
    try {
      print(
        '[SimulateGridPage] '
        'Chargement de tous les tirages...',
      );

      final response =
          await _apiService.fetchEuromillionsDraws();

      print(
        '[SimulateGridPage] '
        'Nombre de tirages reçus : ${response.length}',
      );

      final parsedDraws =
          <Map<String, dynamic>>[];

      for (final item in response) {
        if (item is! Map) {
          continue;
        }

        final draw =
            Map<String, dynamic>.from(item);

        final drawDate =
            DateTime.tryParse(
          '${draw['draw_date']}',
        );

        if (drawDate == null) {
          continue;
        }

        final numbers =
            _extractMainNumbers(draw);

        if (numbers.length != 5) {
          continue;
        }

        parsedDraws.add({
          ...draw,
          '_parsedDate': drawDate,
        });
      }

      // ========================================================
      // TRI DU PLUS RÉCENT AU PLUS ANCIEN
      // ========================================================

      parsedDraws.sort(
        (a, b) {
          final dateA =
              a['_parsedDate'] as DateTime;

          final dateB =
              b['_parsedDate'] as DateTime;

          return dateB.compareTo(dateA);
        },
      );

      print(
        '[SimulateGridPage] '
        'Tirages valides : ${parsedDraws.length}',
      );

      if (!mounted) {
        return;
      }

      if (parsedDraws.isEmpty) {
        setState(() {
          _draws = [];
          _availableDrawCount = 1;
          _drawHistoryCount = 1;
          _isLoadingDraws = false;
          _drawError =
              'Aucun tirage valide disponible.';
        });

        return;
      }

      setState(() {
        _draws = parsedDraws;

        _availableDrawCount =
            parsedDraws.length;

        _drawHistoryCount =
            min(
              30,
              _availableDrawCount,
            ).toDouble();

        _isLoadingDraws = false;

        _drawError = null;
      });

      // ========================================================
      // PREMIER CALCUL
      // ========================================================

      _recalculateStatistics();
    } catch (e, stackTrace) {
      print(
        '[SimulateGridPage] '
        'Erreur chargement tirages : $e',
      );

      print(stackTrace);

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingDraws = false;

        _drawError =
            'Impossible de charger les tirages.';
      });
    }
  }

  // ============================================================
  // EXTRACTION DES 5 NUMÉROS
  // ============================================================

  List<int> _extractMainNumbers(
    Map<String, dynamic> draw,
  ) {
    final numbers = <int>[];

    for (int i = 1; i <= 5; i++) {
      final value = draw['n$i'];

      if (value == null) {
        continue;
      }

      final number =
          int.tryParse(
        value.toString(),
      );

      if (number != null &&
          number >= 1 &&
          number <= 50) {
        numbers.add(number);
      }
    }

    return numbers;
  }

  // ============================================================
  // CALCUL DES STATISTIQUES
  // ============================================================

  void _recalculateStatistics() {
    if (_draws.isEmpty) {
      return;
    }

    final selectedDrawCount =
        _selectedDrawHistoryCount.clamp(
      1,
      _draws.length,
    );

    // ==========================================================
    // ON PREND LES N DERNIERS TIRAGES
    // _draws est déjà trié du plus récent au plus ancien.
    // ==========================================================

    final recentDraws =
        _draws
            .take(selectedDrawCount)
            .toList();

    // ==========================================================
    // APPARITIONS
    // ==========================================================

    final appearances =
        <int, int>{
      for (int number = 1;
          number <= 50;
          number++)
        number: 0,
    };

    for (final draw in recentDraws) {
      final numbers =
          _extractMainNumbers(draw);

      for (final number in numbers) {
        appearances[number] =
            (appearances[number] ?? 0) + 1;
      }
    }

    // ==========================================================
    // RETARD
    //
    // Le tirage le plus récent = index 0
    //
    // présent au dernier tirage -> retard 0
    // présent au tirage précédent -> retard 1
    // etc.
    //
    // jamais présent dans la fenêtre -> retard = N
    // ==========================================================

    final overdue =
        <int, int>{};

    for (int number = 1;
        number <= 50;
        number++) {
      int delay =
          selectedDrawCount;

      for (int index = 0;
          index < recentDraws.length;
          index++) {
        final numbers =
            _extractMainNumbers(
          recentDraws[index],
        );

        if (numbers.contains(number)) {
          delay = index;
          break;
        }
      }

      overdue[number] = delay;
    }

    // ==========================================================
    // GROUP GRID COUNT
    //
    // On conserve ici tes valeurs actuelles.
    // Elles ne dépendent pas encore des tirages EuroMillions.
    // ==========================================================

    final groupGridCount =
        <int, int>{
      for (int number = 1;
          number <= 50;
          number++)
        number:
            _groupGridCount[number] ??
                0,
    };

    // ==========================================================
    // MISE À JOUR DE L'INTERFACE
    // ==========================================================

    if (!mounted) {
      return;
    }

    setState(() {
      _appearances = appearances;
      _overdue = overdue;
      _groupGridCount =
          groupGridCount;
    });

    print(
      '[SimulateGridPage] '
      'Statistiques recalculées : '
      '$selectedDrawCount tirages',
    );
  }

  // ============================================================
  // STATISTIQUES INITIALES DU GROUPE
  // ============================================================

  void _generateInitialGroupStatistics() {
    _groupGridCount = {};

    for (int number = 1;
        number <= 50;
        number++) {
      _groupGridCount[number] =
          _random.nextInt(16);
    }

    _appearances = {
      for (int number = 1;
          number <= 50;
          number++)
        number: 0,
    };

    _overdue = {
      for (int number = 1;
          number <= 50;
          number++)
        number: 0,
    };
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
        List<int>.generate(
      50,
      (index) => index + 1,
    );

    numbers.sort(
      (a, b) {
        final comparison =
            (_appearances[b] ?? 0)
                .compareTo(
          _appearances[a] ?? 0,
        );

        if (comparison != 0) {
          return comparison;
        }

        return a.compareTo(b);
      },
    );

    return numbers
        .take(
          min(
            _selectedHotCount,
            50,
          ),
        )
        .toList();
  }

  // ============================================================
  // NUMÉROS COLD
  // ============================================================

  List<int> get _coldNumbers {
    final numbers =
        List<int>.generate(
      50,
      (index) => index + 1,
    );

    numbers.sort(
      (a, b) {
        final comparison =
            (_appearances[a] ?? 0)
                .compareTo(
          _appearances[b] ?? 0,
        );

        if (comparison != 0) {
          return comparison;
        }

        return a.compareTo(b);
      },
    );

    return numbers
        .take(
          min(
            _selectedColdCount,
            50,
          ),
        )
        .toList();
  }

  // ============================================================
  // NUMÉROS EN RETARD
  // ============================================================

  List<int> get _overdueNumbers {
    final numbers =
        List<int>.generate(
      50,
      (index) => index + 1,
    );

    numbers.sort(
      (a, b) {
        final comparison =
            (_overdue[b] ?? 0)
                .compareTo(
          _overdue[a] ?? 0,
        );

        if (comparison != 0) {
          return comparison;
        }

        return a.compareTo(b);
      },
    );

    return numbers
        .take(
          min(
            _selectedOverdueCount,
            50,
          ),
        )
        .toList();
  }

  // ============================================================
  // COULEURS ALÉATOIRES
  // ============================================================

  void _toggleRandomColors() {
    setState(() {
      _randomColorsEnabled =
          !_randomColorsEnabled;

      if (_randomColorsEnabled) {
        _randomNumberColors.clear();

        for (int number = 1;
            number <= 50;
            number++) {
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
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F6FA),
      appBar:
          _buildAppBar(context),
      body:
          _buildBody(context),
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
          fontWeight:
              FontWeight.bold,
        ),
      ),
      elevation: 0,
      actions: [
        IconButton(
          tooltip:
              _squareBordersEnabled
                  ? 'Désactiver les carrés'
                  : 'Afficher les carrés',
          onPressed:
              _toggleSquareBorders,
          icon: Icon(
            Icons.arrow_left_rounded,
            size: 34,
            color:
                _squareBordersEnabled
                    ? Theme.of(context)
                        .colorScheme
                        .primary
                    : Colors.grey.shade700,
          ),
        ),
        IconButton(
          tooltip:
              _randomColorsEnabled
                  ? 'Désactiver les couleurs'
                  : 'Colorer les numéros',
          onPressed:
              _toggleRandomColors,
          icon: Icon(
            Icons.arrow_right_rounded,
            size: 34,
            color:
                _randomColorsEnabled
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

  Widget _buildBody(
    BuildContext context,
  ) {
    if (_isLoadingDraws) {
      return const Center(
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Chargement des tirages...',
            ),
          ],
        ),
      );
    }

    if (_drawError != null) {
      return Center(
        child: Padding(
          padding:
              const EdgeInsets.all(24),
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(
                height: 16,
              ),
              Text(
                _drawError!,
                textAlign:
                    TextAlign.center,
              ),
              const SizedBox(
                height: 16,
              ),
              ElevatedButton.icon(
                onPressed:
                    _loadAllDraws,
                icon: const Icon(
                  Icons.refresh,
                ),
                label: const Text(
                  'Réessayer',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        ListView(
          padding:
              const EdgeInsets.fromLTRB(
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
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 6,
            ),

            Text(
              'Analyse des 50 numéros et des 12 étoiles.',
              style: TextStyle(
                fontSize: 14,
                color:
                    Colors.grey.shade600,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            Text(
              '$_availableDrawCount tirages chargés '
              'en mémoire',
              style: TextStyle(
                fontSize: 12,
                fontWeight:
                    FontWeight.w600,
                color:
                    Colors.grey.shade700,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            _buildAnalysisControls(),

            const SizedBox(
              height: 20,
            ),

            const Text(
              'Numéros',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 5,
            ),

            Text(
              'Les statistiques affichées sur chaque numéro '
              'dépendent des paramètres ci-dessus.',
              style: TextStyle(
                fontSize: 12,
                color:
                    Colors.grey.shade600,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            // ==================================================
            // LES 50 NUMÉROS
            //
            // IMPORTANT :
            // appearances et overdue sont maintenant calculés
            // à partir des vrais tirages.
            // ==================================================

            SimulationNumberGrid(
              appearances:
                  _appearances,
              overdue:
                  _overdue,
              groupGridCount:
                  _groupGridCount,
              hotNumbers:
                  _hotNumbers,
              coldNumbers:
                  _coldNumbers,
              overdueNumbers:
                  _overdueNumbers,
              randomColorsEnabled:
                  _randomColorsEnabled,
              randomNumberColors:
                  _randomNumberColors,
              squareBordersEnabled:
                  _squareBordersEnabled,
            ),

            const SizedBox(
              height: 24,
            ),

            const Text(
              'Étoiles',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            SimulationStarsGrid(
              squareBordersEnabled:
                  _squareBordersEnabled,
            ),

            const SizedBox(
              height: 24,
            ),

            const SimulationLegend(),

            const SizedBox(
              height: 24,
            ),

            SizedBox(
              width:
                  double.infinity,
              child:
                  ElevatedButton.icon(
                onPressed:
                    _generateGrid,
                icon: const Icon(
                  Icons
                      .auto_awesome_rounded,
                ),
                label: const Text(
                  'Générer cette grille',
                ),
                style:
                    ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets
                          .symmetric(
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
            child:
                SimulationNavigationArrow(
              direction:
                  NavigationArrowDirection
                      .left,
              onTap:
                  _openGroupPlayedGrids,
            ),
          ),
        ),

        Positioned(
          right: 4,
          top: 0,
          bottom: 0,
          child: Center(
            child:
                SimulationNavigationArrow(
              direction:
                  NavigationArrowDirection
                      .right,
              onTap:
                  _openPreviousDraws,
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
      drawHistoryCount:
          _drawHistoryCount,
      hotCount:
          _hotCount,
      coldCount:
          _coldCount,
      overdueCount:
          _overdueCount,

      drawHistoryMax:
          _availableDrawCount,

      selectedDrawHistoryCount:
          _selectedDrawHistoryCount,
      selectedHotCount:
          _selectedHotCount,
      selectedColdCount:
          _selectedColdCount,
      selectedOverdueCount:
          _selectedOverdueCount,

      onDrawHistoryChanged:
          (value) {
        setState(() {
          _drawHistoryCount =
              value;
        });

        _recalculateStatistics();
      },

      onHotChanged:
          (value) {
        setState(() {
          _hotCount =
              value;
        });

        _recalculateStatistics();
      },

      onColdChanged:
          (value) {
        setState(() {
          _coldCount =
              value;
        });

        _recalculateStatistics();
      },

      onOverdueChanged:
          (value) {
        setState(() {
          _overdueCount =
              value;
        });

        _recalculateStatistics();
      },
    );
  }

  // ============================================================
  // GÉNÉRATION
  // ============================================================

  void _generateGrid() {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Génération de grille — bientôt disponible.',
        ),
      ),
    );
  }
}