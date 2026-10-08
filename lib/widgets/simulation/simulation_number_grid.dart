import 'package:flutter/material.dart';

class SimulationNumberGrid extends StatelessWidget {
  final Map<int, int> appearances;
  final Map<int, int> overdue;
  final Map<int, int> groupGridCount;

  final List<int> hotNumbers;
  final List<int> coldNumbers;
  final List<int> overdueNumbers;

  final bool analysisHighlightEnabled;
  final bool squareBordersEnabled;

  const SimulationNumberGrid({
    super.key,
    required this.appearances,
    required this.overdue,
    required this.groupGridCount,
    required this.hotNumbers,
    required this.coldNumbers,
    required this.overdueNumbers,
    required this.analysisHighlightEnabled,
    required this.squareBordersEnabled,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
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
      itemBuilder: (
        context,
        index,
      ) {
        final number = index + 1;

        return _buildNumber(
          number,
          color: _getNumberColor(number),
          textColor: _getNumberTextColor(number),
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
    // ==========================================================
    // VALEUR GRISE
    //
    // Nombre de fois où le numéro a été joué
    // par les camarades du groupe.
    //
    // Pour le moment : mock = 5.
    // ==========================================================

    final numberGroupGridCount =
        groupGridCount[number] ?? 5;

    // ==========================================================
    // VALEUR JAUNE
    //
    // Nombre de tirages depuis la dernière apparition.
    //
    // Cette valeur n'est PAS modifiée par le slider jaune.
    // ==========================================================

    final numberOverdue =
        overdue[number] ?? 0;

    // ==========================================================
    // VALEUR HOT / COLD
    //
    // Nombre d'apparitions sur les X derniers tirages.
    //
    // X est défini par le slider noir.
    // ==========================================================

    final hotColdValue =
        appearances[number] ?? 0;

    // ==========================================================
    // ÉTAT HOT / COLD
    // ==========================================================

    final isHot =
        hotNumbers.contains(number);

    final isCold =
        coldNumbers.contains(number);

    // ==========================================================
    // ÉTAT RETARD
    //
    // Le slider jaune détermine uniquement les numéros
    // à mettre en évidence.
    // ==========================================================

    final isOverdue =
        overdueNumbers.contains(number);

    // ==========================================================
    // COULEUR DU BADGE HOT / COLD
    //
    // HOT  -> rouge
    // COLD -> bleu
    //
    // Pour les autres numéros, on compare la fréquence
    // à la moyenne des 50 numéros.
    // ==========================================================

    final hotColdColor =
        _getHotColdColor(number);

    // ==========================================================
    // CONTOUR
    //
    // Si le numéro est dans les N numéros les plus en retard,
    // on affiche un contour jaune.
    //
    // Ce contour est indépendant du fond rouge / bleu.
    // ==========================================================

    final BorderSide borderSide =
        _getBorderSide(
      isOverdue: isOverdue,
    );

    return AnimatedContainer(
      duration:
          const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: color,
        borderRadius:
            squareBordersEnabled
                ? BorderRadius.circular(3)
                : BorderRadius.circular(50),
        border:
            borderSide.width > 0
                ? Border.fromBorderSide(
                    borderSide,
                  )
                : null,
      ),
      child: Stack(
        children: [
          // ====================================================
          // NUMÉRO CENTRAL
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
          // JAUNE : RETARD
          //
          // En haut à gauche.
          // ====================================================

          Positioned(
            left: 4,
            top: 3,
            child:
                _buildStatisticBadge(
              value:
                  numberOverdue,
              color:
                  Colors.amber.shade800,
              highlighted:
                  isOverdue,
            ),
          ),

          // ====================================================
          // ROUGE / BLEU : HOT-COLD
          //
          // En haut à droite.
          //
          // La valeur correspond au nombre d'apparitions
          // sur les X derniers tirages.
          // ====================================================

          Positioned(
            right: 4,
            top: 3,
            child:
                _buildStatisticBadge(
              value:
                  hotColdValue,
              color:
                  hotColdColor,
              highlighted:
                  isHot || isCold,
            ),
          ),

          // ====================================================
          // GRIS : GROUPE
          //
          // En bas à gauche.
          //
          // Pour le moment tous les numéros valent 5.
          // ====================================================

          Positioned(
            left: 4,
            bottom: 3,
            child:
                _buildStatisticBadge(
              value:
                  numberGroupGridCount,
              color:
                  Colors.grey.shade700,
              highlighted:
                  false,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CONTOUR DU NUMÉRO
  // ============================================================

  BorderSide _getBorderSide({
    required bool isOverdue,
  }) {
    // ==========================================================
    // Le contour jaune est activé uniquement lorsque
    // l'analyse visuelle est activée ET que le numéro
    // fait partie des N numéros les plus en retard.
    // ==========================================================

    if (analysisHighlightEnabled &&
        isOverdue) {
      return BorderSide(
        color: Colors.amber.shade700,
        width: 3,
      );
    }

    // ==========================================================
    // Sinon, si l'utilisateur a activé l'affichage carré,
    // on conserve le contour noir.
    // ==========================================================

    if (squareBordersEnabled) {
      return const BorderSide(
        color: Colors.black54,
        width: 2,
      );
    }

    return const BorderSide(
      color: Colors.transparent,
      width: 0,
    );
  }

  // ============================================================
  // COULEUR HOT / COLD
  // ============================================================

  Color _getHotColdColor(
    int number,
  ) {
    // ==========================================================
    // Si le numéro est explicitement dans la liste HOT,
    // il est rouge.
    // ==========================================================

    if (hotNumbers.contains(number)) {
      return Colors.red;
    }

    // ==========================================================
    // Si le numéro est explicitement dans la liste COLD,
    // il est bleu.
    // ==========================================================

    if (coldNumbers.contains(number)) {
      return Colors.blue.shade700;
    }

    // ==========================================================
    // Pour les autres numéros :
    //
    // au-dessus de la moyenne -> rouge
    // en dessous ou égal -> bleu
    // ==========================================================

    if (appearances.isEmpty) {
      return Colors.blue.shade700;
    }

    double total = 0;

    int count = 0;

    for (int currentNumber = 1;
        currentNumber <= 50;
        currentNumber++) {
      total +=
          appearances[currentNumber] ?? 0;

      count++;
    }

    final average =
        count == 0
            ? 0
            : total / count;

    final value =
        appearances[number] ?? 0;

    if (value > average) {
      return Colors.red;
    }

    return Colors.blue.shade700;
  }

  // ============================================================
  // COULEUR DU NUMÉRO
  // ============================================================

  Color _getNumberColor(
    int number,
  ) {
    // ==========================================================
    // Si l'affichage analytique est désactivé,
    // tous les numéros restent gris.
    // ==========================================================

    if (!analysisHighlightEnabled) {
      return Colors.grey.shade200;
    }

    // ==========================================================
    // HOT -> ROUGE
    // ==========================================================

    if (hotNumbers.contains(number)) {
      return Colors.red;
    }

    // ==========================================================
    // COLD -> BLEU
    //
    // Si un numéro appartient aux deux listes, HOT est
    // prioritaire car il est testé en premier.
    // ==========================================================

    if (coldNumbers.contains(number)) {
      return Colors.blue.shade700;
    }

    // ==========================================================
    // NUMÉRO NORMAL
    // ==========================================================

    return Colors.grey.shade200;
  }

  // ============================================================
  // COULEUR DU TEXTE CENTRAL
  // ============================================================

  Color _getNumberTextColor(
    int number,
  ) {
    if (!analysisHighlightEnabled) {
      return Colors.black87;
    }

    final isHot =
        hotNumbers.contains(number);

    final isCold =
        coldNumbers.contains(number);

    if (isHot || isCold) {
      return Colors.white;
    }

    return Colors.black87;
  }

  // ============================================================
  // BADGE STATISTIQUE
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
      alignment:
          Alignment.center,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 2,
      ),
      decoration:
          BoxDecoration(
        color:
            highlighted
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
}
