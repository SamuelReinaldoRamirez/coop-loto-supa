import 'package:flutter/foundation.dart';

class SimulationAnalysisState extends ChangeNotifier {
  SimulationAnalysisState._();

  static final SimulationAnalysisState instance =
      SimulationAnalysisState._();

  double _drawHistoryCount = 30;
  double _hotCount = 10;
  double _coldCount = 10;
  double _overdueCount = 10;

  bool _analysisHighlightEnabled = false;

  double get drawHistoryCount => _drawHistoryCount;
  double get hotCount => _hotCount;
  double get coldCount => _coldCount;
  double get overdueCount => _overdueCount;

  bool get analysisHighlightEnabled => _analysisHighlightEnabled;

  int get selectedDrawHistoryCount => _drawHistoryCount.round();
  int get selectedHotCount => _hotCount.round();
  int get selectedColdCount => _coldCount.round();
  int get selectedOverdueCount => _overdueCount.round();

  void setDrawHistoryCount(double value) {
    final normalized = value.clamp(1, 1000000).toDouble();

    if (_drawHistoryCount == normalized) return;

    _drawHistoryCount = normalized;
    notifyListeners();
  }

  void setHotCount(double value) {
    final normalized = value.clamp(1, 50).toDouble();

    if (_hotCount == normalized) return;

    _hotCount = normalized;
    notifyListeners();
  }

  void setColdCount(double value) {
    final normalized = value.clamp(1, 50).toDouble();

    if (_coldCount == normalized) return;

    _coldCount = normalized;
    notifyListeners();
  }

  void setOverdueCount(double value) {
    final normalized = value.clamp(1, 50).toDouble();

    if (_overdueCount == normalized) return;

    _overdueCount = normalized;
    notifyListeners();
  }

  void setAnalysisHighlightEnabled(bool value) {
    if (_analysisHighlightEnabled == value) return;

    _analysisHighlightEnabled = value;
    notifyListeners();
  }

  /// Ajuste le nombre de tirages sélectionnés à l'historique disponible.
  void limitDrawHistory(int availableDrawCount) {
    final maxCount = availableDrawCount < 1 ? 1 : availableDrawCount;
    final value = _drawHistoryCount.clamp(1, maxCount).toDouble();

    if (_drawHistoryCount == value) return;

    _drawHistoryCount = value;
    notifyListeners();
  }
}