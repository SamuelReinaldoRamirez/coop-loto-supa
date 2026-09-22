import 'dart:async';

import 'api_service.dart';

class CollectService {
  CollectService._();

  static final CollectService instance = CollectService._();

  final ApiService _api = ApiService();

  bool isCollecting = false;
  String? lastMessage;

  Future<String>? _runningFuture;

  Future<String> collect() {
    if (_runningFuture != null) {
      return _runningFuture!;
    }

    isCollecting = true;
    lastMessage = null;

    _runningFuture = _api.collectEuromillions().then((message) {
      lastMessage = message;
      return message;
    }).whenComplete(() {
      isCollecting = false;
      _runningFuture = null;
    });

    return _runningFuture!;
  }
}