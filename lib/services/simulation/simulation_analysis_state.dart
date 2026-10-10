
import 'package:flutter/foundation.dart';

class SimulationAnalysisState extends ChangeNotifier {
  SimulationAnalysisState._();

  static final SimulationAnalysisState instance =
      SimulationAnalysisState._();

  double _drawHistoryCount = 30;
  double _hotCount = 10;
  double _coldCount = 10;
  double _overdueCount = 10;

  double get drawHistoryCount => _drawHistoryCount;
  double get hotCount => _hotCount;
  double get coldCount => _coldCount;
  double get overdueCount => _overdueCount;

  int get selectedDrawHistoryCount => _drawHistoryCount.round();
  int get selectedHotCount => _hotCount.round();
  int get selectedColdCount => _coldCount.round();
  int get selectedOverdueCount => _overdueCount.round();

  void setDrawHistoryCount(double value) {
    if (_drawHistoryCount == value) return;
    _drawHistoryCount = value;
    notifyListeners();
  }

  void setHotCount(double value) {
    if (_hotCount == value) return;
    _hotCount = value;
    notifyListeners();
  }

  void setColdCount(double value) {
    if (_coldCount == value) return;
    _coldCount = value;
    notifyListeners();
  }

  void setOverdueCount(double value) {
    if (_overdueCount == value) return;
    _overdueCount = value;
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