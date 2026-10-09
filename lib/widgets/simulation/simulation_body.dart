import 'package:flutter/material.dart';

import 'simulation_error_view.dart';
import 'simulation_legend.dart';
import 'simulation_loading_view.dart';
import 'simulation_number_grid.dart';
import 'simulation_stars_grid.dart';

class SimulationBody extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;
  final int availableDrawCount;
  final Widget analysisControls;
  final Map<int, int> appearances;
  final Map<int, int> overdue;
  final Map<int, int> groupGridCount;
  final List<int> hotNumbers;
  final List<int> coldNumbers;
  final List<int> overdueNumbers;
  final List<int> orderedNumbers;
  final bool analysisHighlightEnabled;
  final bool squareBordersEnabled;
  final VoidCallback onGenerateGrid;

  const SimulationBody({
    super.key,
    required this.isLoading,
    required this.error,
    required this.onRetry,
    required this.availableDrawCount,
    required this.analysisControls,
    required this.appearances,
    required this.overdue,
    required this.groupGridCount,
    required this.hotNumbers,
    required this.coldNumbers,
    required this.overdueNumbers,
    required this.orderedNumbers,
    required this.analysisHighlightEnabled,
    required this.squareBordersEnabled,
    required this.onGenerateGrid,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SimulationLoadingView();
    }

    if (error != null) {
      return SimulationErrorView(message: error!, onRetry: onRetry);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(55, 16, 55, 30),
      children: [
        const Text(
          'Simulation',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          'Analyse des 50 numéros et des 12 étoiles.',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 12),
        Text(
          '$availableDrawCount tirages chargés en mémoire',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 20),
        analysisControls,
        const SizedBox(height: 20),
        const Text(
          'Numéros',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(
          'Chaque numéro affiche le nombre de grilles du groupe, son retard et sa fréquence Hot/Cold.',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 12),
        SimulationNumberGrid(
          appearances: appearances,
          overdue: overdue,
          groupGridCount: groupGridCount,
          hotNumbers: hotNumbers,
          coldNumbers: coldNumbers,
          overdueNumbers: overdueNumbers,
          orderedNumbers: orderedNumbers,
          analysisHighlightEnabled: analysisHighlightEnabled,
          squareBordersEnabled: squareBordersEnabled,
        ),
        const SizedBox(height: 24),
        const Text(
          'Étoiles',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SimulationStarsGrid(squareBordersEnabled: squareBordersEnabled),
        const SizedBox(height: 24),
        const SimulationLegend(),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onGenerateGrid,
            icon: const Icon(Icons.auto_awesome_rounded),
            label: const Text('Générer cette grille'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}
