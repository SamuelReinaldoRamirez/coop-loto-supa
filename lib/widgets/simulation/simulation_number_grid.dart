import 'package:flutter/material.dart';

class SimulationNumberGrid
    extends StatelessWidget {
  final Map<int, int> appearances;
  final Map<int, int> overdue;
  final Map<int, int> groupGridCount;

  final List<int> hotNumbers;
  final List<int> coldNumbers;
  final List<int> overdueNumbers;

  final bool randomColorsEnabled;
  final Map<int, Color> randomNumberColors;
  final bool squareBordersEnabled;

  const SimulationNumberGrid({
    super.key,
    required this.appearances,
    required this.overdue,
    required this.groupGridCount,
    required this.hotNumbers,
    required this.coldNumbers,
    required this.overdueNumbers,
    required this.randomColorsEnabled,
    required this.randomNumberColors,
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
    // COULEUR DU BADGE HOT/COLD
    //
    // Si le numéro fait partie des HOT :
    //      rouge
    //
    // Sinon s'il fait partie des COLD :
    //      bleu
    //
    // Pour les autres numéros, on utilise une couleur
    // correspondant à leur position :
    //
    // - au-dessus de la moyenne -> rouge
    // - en dessous ou égal -> bleu
    //
    // Cela permet d'afficher une véritable couleur
    // Hot/Cold même lorsque le numéro n'est pas surligné.
    // ==========================================================

    final hotColdColor =
        _getHotColdColor(number);

    return AnimatedContainer(
      duration:
          const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: color,
        borderRadius:
            squareBordersEnabled
                ? BorderRadius.circular(3)
                : BorderRadius.circular(50),
        border: Border.all(
          color:
              squareBordersEnabled
                  ? Colors.black54
                  : Colors.transparent,
          width:
              squareBordersEnabled
                  ? 2
                  : 0,
        ),
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
          // La valeur est le nombre de fois où le numéro
          // est apparu sur les X derniers tirages.
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
    // Pour les numéros qui ne sont pas dans les listes
    // de surbrillance, on conserve quand même une couleur
    // Hot/Cold cohérente.
    //
    // On compare la fréquence du numéro à la fréquence
    // moyenne des 50 numéros.
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
    if (!randomColorsEnabled) {
      return Colors.grey.shade200;
    }

    return randomNumberColors[number] ??
        Colors.grey.shade200;
  }

  // ============================================================
  // COULEUR DU TEXTE CENTRAL
  // ============================================================

  Color _getNumberTextColor(
    int number,
  ) {
    if (!randomColorsEnabled) {
      return Colors.black87;
    }

    return Colors.white;
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