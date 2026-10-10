
import 'package:flutter/material.dart';

class SimulationStarsGrid extends StatelessWidget {
  final bool squareBordersEnabled;
  final Set<int> selectedStars;
  final ValueChanged<int> onStarTap;

  const SimulationStarsGrid({
    super.key,
    required this.squareBordersEnabled,
    required this.selectedStars,
    required this.onStarTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 12,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final star = index + 1;
        final isSelected = selectedStars.contains(star);
        final canSelect = isSelected || selectedStars.length < 2;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.amber.shade400
                : Colors.amber.shade100,
            borderRadius: BorderRadius.circular(
              squareBordersEnabled ? 3 : 50,
            ),
            border: Border.all(
              color: isSelected
                  ? Colors.amber.shade900
                  : squareBordersEnabled
                      ? Colors.black54
                      : Colors.transparent,
              width: isSelected || squareBordersEnabled ? 2 : 0,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(
                squareBordersEnabled ? 3 : 50,
              ),
              onTap: canSelect ? () => onStarTap(star) : null,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '★$star',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade900,
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 2),
                      Icon(
                        Icons.check_circle,
                        size: 12,
                        color: Colors.amber.shade900,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
