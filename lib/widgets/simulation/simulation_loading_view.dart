import 'package:flutter/material.dart';

class SimulationLoadingView extends StatelessWidget {
  const SimulationLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Chargement des tirages...'),
        ],
      ),
    );
  }
}
