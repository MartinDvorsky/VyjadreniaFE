// lib/providers/metrics_provider.dart

import 'package:flutter/foundation.dart';
import '../services/metrics_service.dart';

class MetricsProvider with ChangeNotifier {
  DateTime? _startTime;
  bool _isReporting = false;

  bool get isReporting => _isReporting;
  bool get isStarted => _startTime != null;

  /// Spustí meranie času
  void startTimer() {
    _startTime = DateTime.now();
    print('⏱️ Metrics: Timer started at $_startTime');
    notifyListeners();
  }

  /// Zastaví meranie a pošle métriku na backend
  Future<void> stopAndReport({
    required String znacka,
    required String nazovStavby,
    required int documentCount,
  }) async {
    if (_startTime == null) {
      print('⚠️ Metrics: Cannot report, timer was not started.');
      return;
    }

    final endTime = DateTime.now();
    final durationMs = endTime.difference(_startTime!).inMilliseconds;
    
    _isReporting = true;
    notifyListeners();

    print('⏱️ Metrics: Total duration $durationMs ms for $documentCount documents');

    final success = await MetricsService.sendGenerationMetric(
      znacka: znacka,
      nazovStavby: nazovStavby,
      totalDurationMs: durationMs,
      documentCount: documentCount,
    );

    _isReporting = false;
    // Resetuj časovač po úspešnom reporte
    if (success) {
      _startTime = null;
    }
    notifyListeners();
  }

  /// Resetuje metriky (napr. pri novom projekte)
  void reset() {
    _startTime = null;
    _isReporting = false;
    notifyListeners();
  }
}
