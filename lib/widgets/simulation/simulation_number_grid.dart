import 'package:flutter/material.dart';
import 'group_frequency_shape_painter.dart';

class SimulationNumberGrid extends StatelessWidget {
  final Map<int, int> appearances;
  final Map<int, int> overdue;
  final Map<int, int> groupGridCount;

  final List<int> hotNumbers;
  final List<int> coldNumbers;
  final List<int> overdueNumbers;
  final List<int> orderedNumbers;
  final Set<int> selectedNumbers;
  final ValueChanged<int> onNumberTap;

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
    required this.orderedNumbers,
    required this.selectedNumbers,
    required this.onNumberTap,
    required this.analysisHighlightEnabled,
    required this.squareBordersEnabled,
  });
  

  @override
  Widget build(BuildContext context) {
    final bool allNumbersSelected = selectedNumbers.length == 5;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: allNumbersSelected
            ? Colors.grey.shade300
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 50,
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) {
          final number = index < orderedNumbers.length
              ? orderedNumbers[index]
              : index + 1;

          final isSelected = selectedNumbers.contains(number);

          return GestureDetector(
            onTap: () => onNumberTap(number),
            child: _buildNumber(
              number,
              color: _getNumberColor(number),
              textColor: _getNumberTextColor(number),
              isSelected: isSelected,
            ),
          );
        },
      ),
    );
  }


  // ============================================================
  // NUMÉRO
  // ============================================================

  Widget _buildNumber(
    int number, {
    required Color color,
    required Color textColor,
    required bool isSelected,
  }) {
    final numberGroupGridCount = groupGridCount[number] ?? 0;
    final numberOverdue = overdue[number] ?? 0;
    final hotColdValue = appearances[number] ?? 0;

    final isHot = hotNumbers.contains(number);
    final isCold = coldNumbers.contains(number);
    final isOverdue = overdueNumbers.contains(number);
    final hotColdColor = _getHotColdColor(number);

    // En mode formes, le contour est dessiné par le CustomPainter.
    // En mode normal, on conserve le contour existant.
    // final BorderSide borderSide = squareBordersEnabled
    //     ? const BorderSide(
    //         color: Colors.transparent,
    //         width: 0,
    //       )
    //     : _getBorderSide(
    //         isOverdue: isOverdue,
    //         isSelected: isSelected,
    //       );

    final List<BorderSide> borderSides = squareBordersEnabled
        ? const []
        : _getBorderSide(
            isOverdue: isOverdue,
            isSelected: isSelected,
          );

    final BorderSide borderSide = borderSides.isNotEmpty
        ? borderSides.first
        : const BorderSide(
            color: Colors.transparent,
            width: 0,
          );

    final bool showDoubleBorder =
        !squareBordersEnabled &&
        analysisHighlightEnabled &&
        isOverdue &&
        isSelected;


    // Priorité des couleurs : retard jaune, sélection verte,
    // puis contour noir pour les numéros non sélectionnés.
    // final Color shapeColor =
    //     analysisHighlightEnabled && isOverdue
    //         ? Colors.amber.shade700
    //         : isSelected
    //             ? Colors.green
    //             : Colors.black54;

    // final double shapeWidth =
    //     (analysisHighlightEnabled && isOverdue) || isSelected
    //         ? 3.0
    //         : 2.0;
    final Color shapeColor =
      analysisHighlightEnabled && isOverdue
          ? Colors.amber.shade700
          : Colors.black54;

    final double shapeWidth =
      analysisHighlightEnabled && isOverdue ? 3.0 : 2.0;

    // Le numéro conserve sa couleur d'origine,
    // mais elle est assombrie lorsqu'il est sélectionné.
    final Color numberBackgroundColor = isSelected
        ? Color.lerp(color, Colors.black, 0.22)!
        : color;

    return CustomPaint(
      foregroundPainter: squareBordersEnabled
          ? GroupFrequencyShapePainter(
              count: numberGroupGridCount,
              color: shapeColor,
              strokeWidth: shapeWidth,
            )
          : null,
        
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: numberBackgroundColor,
              borderRadius: BorderRadius.circular(50),
              border: borderSide.width > 0
                  ? Border.fromBorderSide(borderSide)
                  : null,
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    '$number',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                Positioned(
                  left: 4,
                  top: 3,
                  child: _buildStatisticBadge(
                    value: numberOverdue,
                    color: Colors.amber.shade800,
                    highlighted: isOverdue,
                  ),
                ),
                Positioned(
                  right: 4,
                  top: 3,
                  child: _buildStatisticBadge(
                    value: hotColdValue,
                    color: hotColdColor,
                    highlighted: isHot || isCold,
                  ),
                ),
                Positioned(
                  left: 4,
                  bottom: 3,
                  child: _buildStatisticBadge(
                    value: numberGroupGridCount,
                    color: Colors.grey.shade700,
                    highlighted: false,
                  ),
                ),
              ],
            ),
          ),

          if (showDoubleBorder)
            IgnorePointer(
              child: CustomPaint(
                painter: _YellowForegroundBorderPainter(),
              ),
            ),
        ],
      ),

      // child: AnimatedContainer(
      //   duration: const Duration(milliseconds: 180),
      //   decoration: BoxDecoration(
      //     // On conserve le fond gris, rouge ou bleu.
      //     color: numberBackgroundColor,
      //     borderRadius: BorderRadius.circular(50),
      //     border: borderSide.width > 0
      //         ? Border.fromBorderSide(borderSide)
      //         : null,
      //   ),
      //   child: Stack(
      //     children: [
      //       // NUMÉRO CENTRAL : conservé avec sa couleur d'origine.
      //       Center(
      //         child: Text(
      //           '$number',
      //           style: TextStyle(
      //             fontSize: 15,
      //             fontWeight: FontWeight.bold,
      //             color: textColor,
      //           ),
      //         ),
      //       ),

      //       // JAUNE : retard, en haut à gauche.
      //       Positioned(
      //         left: 4,
      //         top: 3,
      //         child: _buildStatisticBadge(
      //           value: numberOverdue,
      //           color: Colors.amber.shade800,
      //           highlighted: isOverdue,
      //         ),
      //       ),

      //       // ROUGE / BLEU : fréquence Hot/Cold, en haut à droite.
      //       Positioned(
      //         right: 4,
      //         top: 3,
      //         child: _buildStatisticBadge(
      //           value: hotColdValue,
      //           color: hotColdColor,
      //           highlighted: isHot || isCold,
      //         ),
      //       ),

      //       // GRIS : nombre de grilles du groupe, en bas à gauche.
      //       Positioned(
      //         left: 4,
      //         bottom: 3,
      //         child: _buildStatisticBadge(
      //           value: numberGroupGridCount,
      //           color: Colors.grey.shade700,
      //           highlighted: false,
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
    );
  }

  // Widget _buildNumber(
  //   int number, {
  //   required Color color,
  //   required Color textColor,
  //   required bool isSelected,
  // }) {
  //   // ==========================================================
  //   // VALEUR GRISE
  //   //
  //   // Nombre de fois où le numéro a été joué
  //   // par les camarades du groupe.
  //   //
  //   // Valeur calculée depuis les grilles du groupe.
  //   // ==========================================================

  //   final numberGroupGridCount =
  //       groupGridCount[number] ?? 0;

  //   // ==========================================================
  //   // VALEUR JAUNE
  //   //
  //   // Nombre de tirages depuis la dernière apparition.
  //   //
  //   // Cette valeur n'est PAS modifiée par le slider jaune.
  //   // ==========================================================

  //   final numberOverdue =
  //       overdue[number] ?? 0;

  //   // ==========================================================
  //   // VALEUR HOT / COLD
  //   //
  //   // Nombre d'apparitions sur les X derniers tirages.
  //   //
  //   // X est défini par le slider noir.
  //   // ==========================================================

  //   final hotColdValue =
  //       appearances[number] ?? 0;

  //   // ==========================================================
  //   // ÉTAT HOT / COLD
  //   // ==========================================================

  //   final isHot =
  //       hotNumbers.contains(number);

  //   final isCold =
  //       coldNumbers.contains(number);

  //   // ==========================================================
  //   // ÉTAT RETARD
  //   //
  //   // Le slider jaune détermine uniquement les numéros
  //   // à mettre en évidence.
  //   // ==========================================================

  //   final isOverdue =
  //       overdueNumbers.contains(number);

  //   // ==========================================================
  //   // COULEUR DU BADGE HOT / COLD
  //   //
  //   // HOT  -> rouge
  //   // COLD -> bleu
  //   //
  //   // Pour les autres numéros, on compare la fréquence
  //   // à la moyenne des 50 numéros.
  //   // ==========================================================

  //   final hotColdColor =
  //       _getHotColdColor(number);

  //   // ==========================================================
  //   // CONTOUR
  //   //
  //   // Si le numéro est dans les N numéros les plus en retard,
  //   // on affiche un contour jaune.
  //   //
  //   // Ce contour est indépendant du fond rouge / bleu.
  //   // ==========================================================

  //   final BorderSide borderSide = squareBordersEnabled
  //     ? const BorderSide(
  //         color: Colors.transparent,
  //         width: 0,
  //       )
  //     : _getBorderSide(
  //         isOverdue: isOverdue,
  //         isSelected: isSelected,
  //       );

  //   final shapeColor =
  //     analysisHighlightEnabled && isOverdue
  //         ? Colors.amber.shade700
  //         : isSelected
  //             ? Colors.green
  //             : Colors.black54;

  //   final shapeWidth =
  //     analysisHighlightEnabled && isOverdue || isSelected
  //         ? 3.0
  //         : 2.0;

  //   // return AnimatedContainer(
  //   //   duration:
  //   //       const Duration(milliseconds: 180),
  //   //   decoration: BoxDecoration(
  //   //     color: color,
  //   //     borderRadius:
  //   //         squareBordersEnabled
  //   //             ? BorderRadius.circular(3)
  //   //             : BorderRadius.circular(50),
  //   //     border:
  //   //         borderSide.width > 0
  //   //             ? Border.fromBorderSide(
  //   //                 borderSide,
  //   //               )
  //   //             : null,
  //   //   ),
  //   //   child: Stack(
  //   //     children: [
  //   //       // ====================================================
  //   //       // NUMÉRO CENTRAL
  //   //       // ====================================================

  //   //       Center(
  //   //         child: Text(
  //   //           '$number',
  //   //           style: TextStyle(
  //   //             fontSize: 15,
  //   //             fontWeight:
  //   //                 FontWeight.bold,
  //   //             color: textColor,
  //   //           ),
  //   //         ),
  //   //       ),

  //   //       // ====================================================
  //   //       // JAUNE : RETARD
  //   //       //
  //   //       // En haut à gauche.
  //   //       // ====================================================

  //   //       Positioned(
  //   //         left: 4,
  //   //         top: 3,
  //   //         child:
  //   //             _buildStatisticBadge(
  //   //           value:
  //   //               numberOverdue,
  //   //           color:
  //   //               Colors.amber.shade800,
  //   //           highlighted:
  //   //               isOverdue,
  //   //         ),
  //   //       ),

  //   //       // ====================================================
  //   //       // ROUGE / BLEU : HOT-COLD
  //   //       //
  //   //       // En haut à droite.
  //   //       //
  //   //       // La valeur correspond au nombre d'apparitions
  //   //       // sur les X derniers tirages.
  //   //       // ====================================================

  //   //       Positioned(
  //   //         right: 4,
  //   //         top: 3,
  //   //         child:
  //   //             _buildStatisticBadge(
  //   //           value:
  //   //               hotColdValue,
  //   //           color:
  //   //               hotColdColor,
  //   //           highlighted:
  //   //               isHot || isCold,
  //   //         ),
  //   //       ),

  //   //       // ====================================================
  //   //       // GRIS : GROUPE
  //   //       //
  //   //       // En bas à gauche.
  //   //       //
  //   //       // Valeur calculée à partir des grilles du groupe.
  //   //       // ====================================================

  //   //       Positioned(
  //   //         left: 4,
  //   //         bottom: 3,
  //   //         child:
  //   //             _buildStatisticBadge(
  //   //           value:
  //   //               numberGroupGridCount,
  //   //           color:
  //   //               Colors.grey.shade700,
  //   //           highlighted:
  //   //               false,
  //   //         ),
  //   //       ),
  //   //     ],
  //   //   ),
  //   // );

  //   return CustomPaint(
  //     foregroundPainter: squareBordersEnabled
  //         ? GroupFrequencyShapePainter(
  //             count: numberGroupGridCount,
  //             color: shapeColor,
  //             strokeWidth: shapeWidth,
  //           )
  //         : null,
  //     child: AnimatedContainer(
  //       duration: const Duration(milliseconds: 180),
  //       decoration: BoxDecoration(
  //         color: color,
  //         // Le mode fréquence utilise son propre contour.
  //         // Le mode normal conserve le cercle actuel.
  //         borderRadius: BorderRadius.circular(50),
  //         border: borderSide.width > 0
  //             ? Border.fromBorderSide(borderSide)
  //             : null,
  //       ),
  //       child: Stack(
  //         children: [
  //           // Garde ici le Center du numéro et les trois
  //           // Positioned de tes badges existants :
  //           // - retard jaune
  //           // - fréquence Hot/Cold
  //           // - fréquence du groupe en gris
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // ============================================================
  // CONTOUR DU NUMÉRO
  // ============================================================

  
  List<BorderSide> _getBorderSide({
    required bool isOverdue,
    required bool isSelected,
  }) {
    // Les deux conditions sont réunies :
    // vert extérieur et jaune intérieur, au premier plan.
    if (analysisHighlightEnabled && isOverdue && isSelected) {
      return [
        const BorderSide(
          color: Colors.green,
          width: 5.5,
        ),
        BorderSide(
          color: Colors.amber.shade700,
          width: 2.5,
        ),
      ];
    }

    // Numéro en retard uniquement : jaune.
    if (analysisHighlightEnabled && isOverdue) {
      return [
        BorderSide(
          color: Colors.amber.shade700,
          width: 3,
        ),
      ];
    }

    // Numéro sélectionné uniquement : vert.
    if (isSelected) {
      return [
        const BorderSide(
          color: Colors.green,
          width: 5,
        ),
      ];
    }

    // Aucun contour.
    return [];
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


class _YellowForegroundBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.amber.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final rect = Offset.zero & size;
    final radius = Radius.circular(size.width / 2);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.deflate(2),
        radius,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(
    covariant _YellowForegroundBorderPainter oldDelegate,
  ) {
    return false;
  }
}
