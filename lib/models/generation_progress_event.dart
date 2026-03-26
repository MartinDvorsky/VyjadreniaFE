// lib/models/generation_progress_event.dart

class GenerationProgressEvent {
  final int current;
  final int total;
  final String filename;
  final String status; // "generating" | "zipping" | "done" | "error"
  final String? message;

  GenerationProgressEvent({
    required this.current,
    required this.total,
    required this.filename,
    required this.status,
    this.message,
  });

  factory GenerationProgressEvent.fromJson(Map<String, dynamic> json) {
    return GenerationProgressEvent(
      current: json['current'] ?? 0,
      total: json['total'] ?? 0,
      filename: json['filename'] ?? '',
      status: json['status'] ?? 'generating',
      message: json['message'],
    );
  }

  double get progress => total > 0 ? current / total : 0.0;
}
