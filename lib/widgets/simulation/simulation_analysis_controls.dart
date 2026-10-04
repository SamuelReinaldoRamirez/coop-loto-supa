import 'package:flutter/material.dart';

class SimulationAnalysisControls extends StatelessWidget {
  final double drawHistoryCount;
  final double hotCount;
  final double coldCount;
  final double overdueCount;

  final int selectedDrawHistoryCount;
  final int selectedHotCount;
  final int selectedColdCount;
  final int selectedOverdueCount;

  final ValueChanged<double> onDrawHistoryChanged;
  final ValueChanged<double> onHotChanged;
  final ValueChanged<double> onColdChanged;
  final ValueChanged<double> onOverdueChanged;

  const SimulationAnalysisControls({
    super.key,
    required this.drawHistoryCount,
    required this.hotCount,
    required this.coldCount,
    required this.overdueCount,
    required this.selectedDrawHistoryCount,
    required this.selectedHotCount,
    required this.selectedColdCount,
    required this.selectedOverdueCount,
    required this.onDrawHistoryChanged,
    required this.onHotChanged,
    required this.onColdChanged,
    required this.onOverdueChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
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

            _buildSlider(
              context,
              title: 'Derniers tirages',
              value: drawHistoryCount,
              min: 5,
              max: 100,
              divisions: 19,
              color: Colors.black87,
              valueLabel:
                  '$selectedDrawHistoryCount',
              onChanged: onDrawHistoryChanged,
            ),

            _buildSlider(
              context,
              title: 'Hot numbers',
              value: hotCount,
              min: 0,
              max: 20,
              divisions: 20,
              color: Colors.red,
              valueLabel: '$selectedHotCount',
              onChanged: onHotChanged,
            ),

            _buildSlider(
              context,
              title: 'Cold numbers',
              value: coldCount,
              min: 0,
              max: 20,
              divisions: 20,
              color: Colors.blue.shade700,
              valueLabel:
                  '$selectedColdCount',
              onChanged: onColdChanged,
            ),

            _buildSlider(
              context,
              title: 'Numéros en retard',
              value: overdueCount,
              min: 0,
              max: 20,
              divisions: 20,
              color: Colors.amber.shade800,
              valueLabel:
                  '$selectedOverdueCount',
              onChanged: onOverdueChanged,
            ),

            const SizedBox(height: 4),

            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _buildAnalysisChip(
                  color: Colors.red,
                  label:
                      '$selectedHotCount Hot',
                ),
                _buildAnalysisChip(
                  color: Colors.blue.shade700,
                  label:
                      '$selectedColdCount Cold',
                ),
                _buildAnalysisChip(
                  color: Colors.amber.shade800,
                  label:
                      '$selectedOverdueCount retard',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(
    BuildContext context, {
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

  Widget _buildAnalysisChip({
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
}