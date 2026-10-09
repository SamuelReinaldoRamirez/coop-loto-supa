import 'package:flutter/material.dart';

class SimulationLegend extends StatelessWidget {
  const SimulationLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Légende',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Wrap(
          spacing: 14,
          runSpacing: 8,
          children: [
            _LegendItem(color: Color(0xFFFFA000), label: 'Retard'),
            _LegendItem(color: Colors.red, label: 'Apparitions'),
            _LegendItem(color: Color(0xFF616161), label: 'Grilles du groupe'),
            _LegendItem(color: Color(0xFF1976D2), label: 'Présence groupe'),
            _LegendItem(color: Color(0xFFEEEEEE), label: 'Normal'),
            _LegendItem(color: Colors.red, label: 'Rouge'),
            _LegendItem(color: Colors.blue, label: 'Bleu'),
            _LegendItem(color: Colors.white, border: true, label: 'Carré'),
          ],
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool border;

  const _LegendItem({
    required this.color,
    required this.label,
    this.border = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(border ? 3 : 50),
            border: Border.all(
              color: border ? Colors.black54 : Colors.transparent,
            ),
          ),
        ),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
