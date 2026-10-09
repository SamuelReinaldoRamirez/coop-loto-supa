import 'dart:math';

import 'package:flutter/material.dart';

import 'simulation_number_sort_mode.dart';

class SimulationAnalysisControls extends StatelessWidget {
  final double drawHistoryCount;
  final double hotCount;
  final double coldCount;
  final double overdueCount;
  final int drawHistoryMax;
  final int selectedDrawHistoryCount;
  final int selectedHotCount;
  final int selectedColdCount;
  final int selectedOverdueCount;
  final ValueChanged<double> onDrawHistoryChanged;
  final ValueChanged<double> onHotChanged;
  final ValueChanged<double> onColdChanged;
  final ValueChanged<double> onOverdueChanged;
  final SimulationNumberSortMode sortMode;
  final ValueChanged<SimulationNumberSortMode> onSortModeChanged;

  const SimulationAnalysisControls({
    super.key,
    required this.drawHistoryCount,
    required this.hotCount,
    required this.coldCount,
    required this.overdueCount,
    required this.drawHistoryMax,
    required this.selectedDrawHistoryCount,
    required this.selectedHotCount,
    required this.selectedColdCount,
    required this.selectedOverdueCount,
    required this.onDrawHistoryChanged,
    required this.onHotChanged,
    required this.onColdChanged,
    required this.onOverdueChanged,
    required this.sortMode,
    required this.onSortModeChanged,
  });

  double _drawCountToSliderValue(int count) {
    final maxValue = max(1, drawHistoryMax).toDouble();
    if (maxValue <= 1) return 0;

    final safeCount = count.clamp(1, drawHistoryMax);
    final minLog = log(1.0);
    final maxLog = log(maxValue);
    final valueLog = log(safeCount.toDouble());

    return (valueLog - minLog) / (maxLog - minLog);
  }

  int _sliderValueToDrawCount(double value) {
    final maxValue = max(1, drawHistoryMax).toDouble();
    if (maxValue <= 1) return 1;

    final minLog = log(1.0);
    final maxLog = log(maxValue);
    final clampedValue = value.clamp(0.0, 1.0);
    final valueLog = minLog + clampedValue * (maxLog - minLog);
    return exp(valueLog).round().clamp(1, drawHistoryMax).toInt();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.tune_rounded,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Paramètres d’analyse',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildSlider(
              context,
              title: 'Derniers tirages',
              value: _drawCountToSliderValue(selectedDrawHistoryCount),
              min: 0,
              max: 1,
              divisions: null,
              color: Colors.black87,
              valueLabel: '$selectedDrawHistoryCount',
              onChanged: (value) {
                onDrawHistoryChanged(_sliderValueToDrawCount(value).toDouble());
              },
            ),
            _buildSlider(
              context,
              title: 'Hot numbers',
              value: hotCount.clamp(1, 50).toDouble(),
              min: 1,
              max: 50,
              divisions: 49,
              color: Colors.red,
              valueLabel: '$selectedHotCount',
              onChanged: onHotChanged,
              sortDescending: SimulationNumberSortMode.hotDescending,
              sortAscending: SimulationNumberSortMode.hotAscending,
            ),
            _buildSlider(
              context,
              title: 'Cold numbers',
              value: coldCount.clamp(1, 50).toDouble(),
              min: 1,
              max: 50,
              divisions: 49,
              color: Colors.blue.shade700,
              valueLabel: '$selectedColdCount',
              onChanged: onColdChanged,
              sortDescending: SimulationNumberSortMode.coldDescending,
              sortAscending: SimulationNumberSortMode.coldAscending,
            ),
            _buildSlider(
              context,
              title: 'Numéros en retard',
              value: overdueCount.clamp(1, 50).toDouble(),
              min: 1,
              max: 50,
              divisions: 49,
              color: Colors.amber.shade800,
              valueLabel: '$selectedOverdueCount',
              onChanged: onOverdueChanged,
              sortDescending: SimulationNumberSortMode.overdueDescending,
              sortAscending: SimulationNumberSortMode.overdueAscending,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.sort_rounded, size: 16, color: Colors.black54),
                const SizedBox(width: 5),
                const Text(
                  'Tri actuel :',
                  style: TextStyle(fontSize: 11, color: Colors.black54),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    sortMode.label,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => onSortModeChanged(
                    SimulationNumberSortMode.numericAscending,
                  ),
                  icon: const Icon(Icons.format_list_numbered, size: 15),
                  label: const Text('Numérique'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    minimumSize: const Size(0, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _buildAnalysisChip(color: Colors.red, label: '$selectedHotCount Hot'),
                _buildAnalysisChip(
                  color: Colors.blue.shade700,
                  label: '$selectedColdCount Cold',
                ),
                _buildAnalysisChip(
                  color: Colors.amber.shade800,
                  label: '$selectedOverdueCount retard',
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
    required int? divisions,
    required Color color,
    required String valueLabel,
    required ValueChanged<double> onChanged,
    SimulationNumberSortMode? sortDescending,
    SimulationNumberSortMode? sortAscending,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
            ),
            Container(
              width: 42,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 3),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                valueLabel,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 30,
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: color,
                    thumbColor: color,
                    overlayColor: color.withOpacity(0.12),
                    inactiveTrackColor: Colors.grey.shade300,
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(
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
            ),
            if (sortDescending != null && sortAscending != null) ...[
              _buildSortButton(
                icon: Icons.arrow_upward_rounded,
                tooltip: sortDescending.label,
                mode: sortDescending,
                color: color,
              ),
              _buildSortButton(
                icon: Icons.arrow_downward_rounded,
                tooltip: sortAscending.label,
                mode: sortAscending,
                color: color,
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildSortButton({
    required IconData icon,
    required String tooltip,
    required SimulationNumberSortMode mode,
    required Color color,
  }) {
    final selected = sortMode == mode;

    return IconButton(
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints.tightFor(width: 30, height: 30),
      padding: EdgeInsets.zero,
      onPressed: () => onSortModeChanged(mode),
      icon: Icon(
        icon,
        size: 17,
        color: selected ? color : Colors.grey.shade600,
      ),
      style: IconButton.styleFrom(
        backgroundColor: selected ? color.withOpacity(0.12) : Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }

  Widget _buildAnalysisChip({required Color color, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}
