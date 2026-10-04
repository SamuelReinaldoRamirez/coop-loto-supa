import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

  // Nombre de derniers tirages pris en compte
  double _drawHistoryCount = 20;

  // Nombre de Hot numbers
  double _hotCount = 5;

  // Nombre de Cold numbers
  double _coldCount = 5;

  // Nombre de numéros en retard
  double _overdueCount = 5;

  // ============================================================
  // DONNÉES MOCKÉES
  //
  // Ces données seront ensuite remplacées par les données
  // récupérées depuis le backend.
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
      // Nombre d'apparitions sur les derniers tirages
      _appearances[number] = _random.nextInt(11);

      // Nombre de tirages depuis la dernière apparition
      _overdue[number] = _random.nextInt(21);

      // Nombre de grilles du groupe contenant ce numéro
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
    final numbers = List<int>.generate(50, (index) => index + 1);

    numbers.sort((a, b) {
      final comparison =
          _appearances[b]!.compareTo(_appearances[a]!);

      if (comparison != 0) {
        return comparison;
      }

      return a.compareTo(b);
    });

    return numbers
        .take(_selectedHotCount)
        .toList();
  }

  // ============================================================
  // NUMÉROS COLD
  // ============================================================

  List<int> get _coldNumbers {
    final numbers = List<int>.generate(50, (index) => index + 1);

    numbers.sort((a, b) {
      final comparison =
          _appearances[a]!.compareTo(_appearances[b]!);

      if (comparison != 0) {
        return comparison;
      }

      return a.compareTo(b);
    });

    return numbers
        .take(_selectedColdCount)
        .toList();
  }

  // ============================================================
  // NUMÉROS EN RETARD
  // ============================================================

  List<int> get _overdueNumbers {
    final numbers = List<int>.generate(50, (index) => index + 1);

    numbers.sort((a, b) {
      final comparison =
          _overdue[b]!.compareTo(_overdue[a]!);

      if (comparison != 0) {
        return comparison;
      }

      return a.compareTo(b);
    });

    return numbers
        .take(_selectedOverdueCount)
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
  // COULEUR D'UN NUMÉRO
  // ============================================================

  Color _getNumberColor(int number) {
    if (!_randomColorsEnabled) {
      return Colors.grey.shade200;
    }

    return _randomNumberColors[number] ??
        Colors.grey.shade200;
  }

  Color _getNumberTextColor(int number) {
    if (!_randomColorsEnabled) {
      return Colors.black87;
    }

    return Colors.white;
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

      appBar: AppBar(
        title: const Text(
          'Simuler une grille',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        actions: [

          // TRIANGLE GAUCHE = CARRÉS

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

          // TRIANGLE DROIT = ROUGE / BLEU

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
      ),

      body: Stack(
        children: [

          // ======================================================
          // CONTENU SCROLLABLE
          // ======================================================

          ListView(
            padding: const EdgeInsets.fromLTRB(
              55,
              16,
              55,
              30,
            ),
            children: [

              // --------------------------------------------------
              // TITRE
              // --------------------------------------------------

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

              // --------------------------------------------------
              // PARAMÈTRES D'ANALYSE
              // --------------------------------------------------

              _buildAnalysisControls(),

              const SizedBox(height: 20),

              // --------------------------------------------------
              // NUMÉROS
              // --------------------------------------------------

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

              _buildNumberGrid(),

              const SizedBox(height: 24),

              // --------------------------------------------------
              // ÉTOILES
              // --------------------------------------------------

              const Text(
                'Étoiles',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              _buildStarsGrid(),

              const SizedBox(height: 24),

              // --------------------------------------------------
              // LÉGENDE
              // --------------------------------------------------

              _buildLegend(),

              const SizedBox(height: 24),

              // --------------------------------------------------
              // BOUTON GÉNÉRER
              // --------------------------------------------------

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Génération de grille — '
                          'bientôt disponible.',
                        ),
                      ),
                    );
                  },
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

          // ======================================================
          // FLÈCHE GAUCHE FIXE
          // ======================================================

          Positioned(
            left: 4,
            top: 0,
            bottom: 0,
            child: Center(
              child: _buildNavigationArrow(
                context,
                direction:
                    NavigationArrowDirection.left,
                onTap: _openGroupPlayedGrids,
              ),
            ),
          ),

          // ======================================================
          // FLÈCHE DROITE FIXE
          // ======================================================

          Positioned(
            right: 4,
            top: 0,
            bottom: 0,
            child: Center(
              child: _buildNavigationArrow(
                context,
                direction:
                    NavigationArrowDirection.right,
                onTap: _openPreviousDraws,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PARAMÈTRES D'ANALYSE
  // ============================================================

  Widget _buildAnalysisControls() {
    return Card(
      elevation: 1,
      shadowColor:
          Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          14,
          12,
          14,
          10,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            Row(
              children: [
                Icon(
                  Icons.tune_rounded,
                  size: 20,
                  color: Theme.of(context)
                      .colorScheme
                      .primary,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Paramètres d’analyse',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // --------------------------------------------------
            // DERNIERS TIRAGES
            // --------------------------------------------------

            _buildSlider(
              title: 'Derniers tirages',
              value:
                  _drawHistoryCount,
              min: 5,
              max: 100,
              divisions: 19,
              color: Colors.black87,
              valueLabel:
                  '$_selectedDrawHistoryCount',
              onChanged: (value) {
                setState(() {
                  _drawHistoryCount = value;
                });
              },
            ),

            // --------------------------------------------------
            // HOT
            // --------------------------------------------------

            _buildSlider(
              title: 'Hot numbers',
              value: _hotCount,
              min: 0,
              max: 20,
              divisions: 20,
              color: Colors.red,
              valueLabel:
                  '$_selectedHotCount',
              onChanged: (value) {
                setState(() {
                  _hotCount = value;
                });
              },
            ),

            // --------------------------------------------------
            // COLD
            // --------------------------------------------------

            _buildSlider(
              title: 'Cold numbers',
              value: _coldCount,
              min: 0,
              max: 20,
              divisions: 20,
              color: Colors.blue.shade700,
              valueLabel:
                  '$_selectedColdCount',
              onChanged: (value) {
                setState(() {
                  _coldCount = value;
                });
              },
            ),

            // --------------------------------------------------
            // RETARD
            // --------------------------------------------------

            _buildSlider(
              title: 'Numéros en retard',
              value: _overdueCount,
              min: 0,
              max: 20,
              divisions: 20,
              color: Colors.amber.shade800,
              valueLabel:
                  '$_selectedOverdueCount',
              onChanged: (value) {
                setState(() {
                  _overdueCount = value;
                });
              },
            ),

            const SizedBox(height: 4),

            // --------------------------------------------------
            // RÉSUMÉ
            // --------------------------------------------------

            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _analysisChip(
                  color: Colors.red,
                  label:
                      '$_selectedHotCount Hot',
                ),
                _analysisChip(
                  color: Colors.blue.shade700,
                  label:
                      '$_selectedColdCount Cold',
                ),
                _analysisChip(
                  color: Colors.amber.shade800,
                  label:
                      '$_selectedOverdueCount retard',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider({
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required Color color,
    required String valueLabel,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      children: [

        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              width: 42,
              alignment: Alignment.center,
              padding:
                  const EdgeInsets.symmetric(
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius:
                    BorderRadius.circular(6),
              ),
              child: Text(
                valueLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),

        SizedBox(
          height: 30,
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              thumbColor: color,
              overlayColor:
                  color.withOpacity(0.12),
              inactiveTrackColor:
                  Colors.grey.shade300,
              trackHeight: 3,
              thumbShape:
                  const RoundSliderThumbShape(
                enabledThumbRadius: 7,
              ),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _analysisChip({
    required Color color,
    required String label,
  }) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius:
            BorderRadius.circular(7),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  // ============================================================
  // GRILLE DES 50 NUMÉROS
  // ============================================================

  Widget _buildNumberGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(),
      itemCount: 50,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final number = index + 1;

        return _buildNumber(
          number,
          color:
              _getNumberColor(number),
          textColor:
              _getNumberTextColor(number),
        );
      },
    );
  }

  // ============================================================
  // NUMÉRO
  // ============================================================

  Widget _buildNumber(
    int number, {
    required Color color,
    required Color textColor,
  }) {
    final appearances =
        _appearances[number] ?? 0;

    final overdue =
        _overdue[number] ?? 0;

    final groupGridCount =
        _groupGridCount[number] ?? 0;

    final isHot =
        _hotNumbers.contains(number);

    final isCold =
        _coldNumbers.contains(number);

    final isOverdue =
        _overdueNumbers.contains(number);

    return AnimatedContainer(
      duration:
          const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: color,
        borderRadius:
            _squareBordersEnabled
                ? BorderRadius.circular(3)
                : BorderRadius.circular(50),
        border: Border.all(
          color: _squareBordersEnabled
              ? Colors.black54
              : Colors.transparent,
          width: _squareBordersEnabled
              ? 2
              : 0,
        ),
      ),
      child: Stack(
        children: [

          // ====================================================
          // NUMÉRO PRINCIPAL
          // ====================================================

          Center(
            child: Text(
              '$number',
              style: TextStyle(
                fontSize: 15,
                fontWeight:
                    FontWeight.bold,
                color: textColor,
              ),
            ),
          ),

          // ====================================================
          // HAUT GAUCHE
          //
          // JAUNE = RETARD
          // ====================================================

          Positioned(
            left: 4,
            top: 3,
            child: _buildStatisticBadge(
              value: overdue,
              color: Colors.amber.shade800,
              highlighted: isOverdue,
            ),
          ),

          // ====================================================
          // HAUT DROITE
          //
          // ROUGE = APPARITIONS
          // ====================================================

          Positioned(
            right: 4,
            top: 3,
            child: _buildStatisticBadge(
              value: appearances,
              color: Colors.red,
              highlighted: isHot,
            ),
          ),

          // ====================================================
          // BAS GAUCHE
          //
          // GRIS = NOMBRE DE GRILLES DU GROUPE
          // ====================================================

          Positioned(
            left: 4,
            bottom: 3,
            child: _buildStatisticBadge(
              value: groupGridCount,
              color: Colors.grey.shade700,
              highlighted: false,
            ),
          ),

          // ====================================================
          // BAS DROITE
          //
          // BLEU = APPARITIONS DANS LES GRILLES DU GROUPE
          //
          // Pour l'instant on utilise la même donnée mockée.
          // Elle sera séparée du nombre de grilles quand le
          // backend fournira les deux statistiques.
          // ====================================================

          Positioned(
            right: 4,
            bottom: 3,
            child: _buildStatisticBadge(
              value: groupGridCount,
              color: Colors.blue.shade700,
              highlighted: isCold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PETIT BADGE STATISTIQUE
  // ============================================================

  Widget _buildStatisticBadge({
    required int value,
    required Color color,
    required bool highlighted,
  }) {
    return Container(
      constraints:
          const BoxConstraints(
        minWidth: 15,
        minHeight: 15,
      ),
      alignment: Alignment.center,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 2,
      ),
      decoration: BoxDecoration(
        color: highlighted
            ? color.withOpacity(0.16)
            : Colors.transparent,
        borderRadius:
            BorderRadius.circular(4),
      ),
      child: Text(
        '$value',
        style: TextStyle(
          fontSize: 9,
          fontWeight:
              highlighted
                  ? FontWeight.bold
                  : FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  // ============================================================
  // GRILLE DES 12 ÉTOILES
  // ============================================================

  Widget _buildStarsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(),
      itemCount: 12,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final star = index + 1;

        return AnimatedContainer(
          duration:
              const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: Colors.amber.shade100,
            borderRadius:
                _squareBordersEnabled
                    ? BorderRadius.circular(3)
                    : BorderRadius.circular(50),
            border: Border.all(
              color: _squareBordersEnabled
                  ? Colors.black54
                  : Colors.transparent,
              width: _squareBordersEnabled
                  ? 2
                  : 0,
            ),
          ),
          child: Center(
            child: Text(
              '★$star',
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    FontWeight.bold,
                color:
                    Colors.amber.shade900,
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // LÉGENDE
  // ============================================================

  Widget _buildLegend() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [

        const Text(
          'Légende',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Wrap(
          spacing: 14,
          runSpacing: 8,
          children: [

            _legendItem(
              color: Colors.amber.shade800,
              label: 'Retard',
            ),

            _legendItem(
              color: Colors.red,
              label: 'Apparitions',
            ),

            _legendItem(
              color: Colors.grey.shade700,
              label: 'Grilles du groupe',
            ),

            _legendItem(
              color: Colors.blue.shade700,
              label: 'Présence groupe',
            ),

            _legendItem(
              color: Colors.grey.shade200,
              label: 'Normal',
            ),

            _legendItem(
              color: Colors.red,
              label: 'Rouge',
            ),

            _legendItem(
              color: Colors.blue,
              label: 'Bleu',
            ),

            _legendItem(
              color: Colors.white,
              border: true,
              label: 'Carré',
            ),
          ],
        ),
      ],
    );
  }

  Widget _legendItem({
    required Color color,
    required String label,
    bool border = false,
  }) {
    return Row(
      mainAxisSize:
          MainAxisSize.min,
      children: [

        Container(
          width: 18,
          height: 18,
          decoration:
              BoxDecoration(
            color: color,
            borderRadius:
                BorderRadius.circular(
              border ? 3 : 50,
            ),
            border: Border.all(
              color: border
                  ? Colors.black54
                  : Colors.transparent,
            ),
          ),
        ),

        const SizedBox(width: 5),

        Text(
          label,
          style:
              const TextStyle(
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // FLÈCHES DE NAVIGATION LATÉRALES
  // ============================================================

  Widget _buildNavigationArrow(
    BuildContext context, {
    required NavigationArrowDirection direction,
    required VoidCallback onTap,
  }) {
    final isLeft =
        direction ==
            NavigationArrowDirection.left;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius:
            BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: 42,
          height: 100,
          alignment:
              Alignment.center,
          child: Icon(
            isLeft
                ? Icons.arrow_back_rounded
                : Icons.arrow_forward_rounded,
            size: 38,
            color:
                Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}

enum NavigationArrowDirection {
  left,
  right,
}