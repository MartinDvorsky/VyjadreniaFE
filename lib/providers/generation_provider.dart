// lib/providers/generation_provider.dart

import 'package:flutter/foundation.dart';
import '../models/generation_progress_event.dart';

enum GenerationState {
  idle,
  generating,
  success,
  error,
}

class GenerationProvider with ChangeNotifier {
  GenerationState _state = GenerationState.idle;
  
  // SSE progress
  double _progress = 0.0;
  int _currentCount = 0;
  int _totalCount = 0;
  String? _errorMessage;
  String? _currentFile;
  String? _statusMessage; // "generating", "zipping", "done"

  // Výsledky generovania
  List<String> _generatedFiles = [];
  List<String> _failedFiles = [];
  String? _downloadUrl;

  // Getters
  GenerationState get state => _state;
  double get progress => _progress;
  int get currentCount => _currentCount;
  int get totalCount => _totalCount;
  String? get errorMessage => _errorMessage;
  String? get currentFile => _currentFile;
  String? get statusMessage => _statusMessage;
  List<String> get generatedFiles => _generatedFiles;
  List<String> get failedFiles => _failedFiles;
  String? get downloadUrl => _downloadUrl;

  /// Nastav stav generovania
  void setState(GenerationState newState) {
    _state = newState;

    // Reset progress pri idle alebo error
    if (newState == GenerationState.idle || newState == GenerationState.error) {
      _progress = 0.0;
      _currentCount = 0;
      _totalCount = 0;
      _currentFile = null;
      _statusMessage = null;
    }

    // Nastav progress na 100% pri success
    if (newState == GenerationState.success) {
      _progress = 1.0;
      _currentFile = null;
    }

    notifyListeners();
  }

  /// Aktualizuj progress z SSE eventu
  void updateFromEvent(GenerationProgressEvent event) {
    _currentCount = event.current;
    _totalCount = event.total;
    _progress = event.progress;
    
    if (event.status == 'generating' || event.status == 'zipping') {
      _currentFile = event.filename;
      _statusMessage = event.message;
      if (event.status == 'zipping') {
        _statusMessage = 'Vytváranie ZIP...';
      }
    } else if (event.status == 'error') {
      // Zapíšeme do chýb, ale neukončujeme
      if (!failedFiles.contains(event.filename) && event.filename.isNotEmpty) {
        _failedFiles.add(event.filename);
      }
    }
    
    notifyListeners();
  }

  /// Pridaj úspešný súbor (z eventu)
  void addGeneratedFile(String filename) {
    if (!generatedFiles.contains(filename) && filename.isNotEmpty) {
      _generatedFiles.add(filename);
    }
    // notifyListeners sa volá v updateFromEvent, tu netreba extra
  }

  /// Nastav download URL
  void setDownloadUrl(String url) {
    _downloadUrl = url;
    notifyListeners();
  }

  /// Aktualizuj progress (0.0 - 1.0) - pre spätnú kompatibilitu/simuláciu
  void updateProgress(double progress, {String? currentFile}) {
    _progress = progress.clamp(0.0, 1.0);
    _currentFile = currentFile;
    notifyListeners();
  }

  /// Nastav chybovú správu
  void setError(String message) {
    _errorMessage = message;
    _state = GenerationState.error;
    notifyListeners();
  }

  /// Nastav výsledky generovania
  void setResults({
    required List<String> generatedFiles,
    required List<String> failedFiles,
    String? downloadUrl,
  }) {
    _generatedFiles = generatedFiles;
    _failedFiles = failedFiles;
    _downloadUrl = downloadUrl;
    notifyListeners();
  }

  /// Reset providera
  void reset() {
    _state = GenerationState.idle;
    _progress = 0.0;
    _currentCount = 0;
    _totalCount = 0;
    _errorMessage = null;
    _currentFile = null;
    _statusMessage = null;
    _generatedFiles = [];
    _failedFiles = [];
    _downloadUrl = null;
    notifyListeners();
  }

  /// Simulácia progress (pre testovanie)
  Future<void> simulateProgress() async {
    setState(GenerationState.generating);

    for (int i = 0; i <= 100; i += 10) {
      await Future.delayed(Duration(milliseconds: 300));
      updateProgress(i / 100, currentFile: 'dokument_$i.docx');
    }

    // Simulované výsledky
    setResults(
      generatedFiles: ['dokument_1.docx', 'dokument_2.docx', 'dokument_3.docx'],
      failedFiles: [],
      downloadUrl: '/api/download/test.zip',
    );

    setState(GenerationState.success);
  }
}