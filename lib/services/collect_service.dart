import 'dart:async';

import 'api_service.dart';

class CollectService {
  CollectService._();

  static final CollectService instance = CollectService._();

  final ApiService _api = ApiService();

  bool isCollecting = false;
  String? lastMessage;

  Future<String>? _runningFuture;

  Future<String> collect({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    if (_runningFuture != null) {
      return _runningFuture!;
    }

    isCollecting = true;
    lastMessage = null;

    final Future<String> future;

    if (startDate == null && endDate == null) {
      // Aucune date sélectionnée :
      // on récupère uniquement le dernier tirage.
      future = _api.collectEuromillions();
    } else {
      // Une ou deux dates sélectionnées :
      // on utilise l'endpoint période.
      future = _api.collectEuromillionsPeriod(
        startDate!,
        endDate ?? startDate,
      );
    }

    _runningFuture = future
        .then((message) {
          lastMessage = message;
          return message;
        })
        .whenComplete(() {
          isCollecting = false;
          _runningFuture = null;
        });

    return _runningFuture!;
  }

  // Future<String> collect() {
  //   if (_runningFuture != null) {
  //     return _runningFuture!;
  //   }

  //   isCollecting = true;
  //   lastMessage = null;

  //   _runningFuture = _api.collectEuromillions().then((message) {
  //     lastMessage = message;
  //     return message;
  //   }).whenComplete(() {
  //     isCollecting = false;
  //     _runningFuture = null;
  //   });

  //   return _runningFuture!;
  // }
}