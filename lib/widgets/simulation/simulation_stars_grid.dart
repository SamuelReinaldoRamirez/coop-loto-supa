import 'package:flutter/material.dart';

class SimulationStarsGrid extends StatelessWidget {
  final bool squareBordersEnabled;

  const SimulationStarsGrid({
    super.key,
    required this.squareBordersEnabled,
  });

  @override
  Widget build(BuildContext context) {
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
                squareBordersEnabled
                    ? BorderRadius.circular(3)
                    : BorderRadius.circular(50),
            border: Border.all(
              color: squareBordersEnabled
                  ? Colors.black54
                  : Colors.transparent,
              width: squareBordersEnabled
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
                color: Colors.amber.shade900,
              ),
            ),
          ),
        );
      },
    );
  }
}