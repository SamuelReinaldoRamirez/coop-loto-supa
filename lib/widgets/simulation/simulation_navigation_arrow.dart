import 'package:flutter/material.dart';

enum NavigationArrowDirection {
  left,
  right,
}

class SimulationNavigationArrow extends StatelessWidget {
  final NavigationArrowDirection direction;
  final VoidCallback onTap;

  const SimulationNavigationArrow({
    super.key,
    required this.direction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLeft = direction == NavigationArrowDirection.left;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 100,
          child: Center(
            child: Icon(
              isLeft ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
              size: 38,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }
}
