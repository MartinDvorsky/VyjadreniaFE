import 'package:flutter/foundation.dart';

class ChatSourceModel {
  final String label;
  final String file; // 'prirucka' or 'zakon'

  const ChatSourceModel({
    required this.label,
    required this.file,
  });

  factory ChatSourceModel.fromJson(Map<String, dynamic> json) {
    return ChatSourceModel(
      label: json['source_label'] as String? ?? '',
      file: json['source_file'] as String? ?? 'prirucka',
    );
  }
}

class ChatMessageModel {
  final String? id;
  final String role; // 'user' or 'assistant'
  final String content;
  final List<ChatSourceModel> sources;
  final String? createdAt;
  
  // UI specific fields
  final bool isGenerating;
  int? feedbackRating; // 1 = up, -1 = down, null = none

  ChatMessageModel({
    this.id,
    required this.role,
    required this.content,
    this.sources = const [],
    this.createdAt,
    this.isGenerating = false,
    this.feedbackRating,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    // The history endpoint uses `source_labels` while the message endpoint uses `sources`
    List<ChatSourceModel> parsedSources = [];
    
    if (json['sources'] != null) {
      parsedSources = (json['sources'] as List<dynamic>)
          .map((e) => ChatSourceModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (json['source_labels'] != null) {
      parsedSources = (json['source_labels'] as List<dynamic>)
          .map((e) => ChatSourceModel(label: e.toString(), file: 'prirucka')) // predvolené 'prirucka' ak chýba
          .toList();
    }

    // fallback mapping if message_id is in json instead of id (from /message response)
    final msgId = json['id'] as String? ?? json['message_id'] as String?;

    return ChatMessageModel(
      id: msgId,
      role: json['role'] as String? ?? 'assistant',
      content: json['content'] ?? json['answer'] ?? '',
      sources: parsedSources,
      createdAt: json['created_at'] as String?,
    );
  }

  ChatMessageModel copyWith({
    String? id,
    String? role,
    String? content,
    List<ChatSourceModel>? sources,
    String? createdAt,
    bool? isGenerating,
    int? feedbackRating,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      sources: sources ?? this.sources,
      createdAt: createdAt ?? this.createdAt,
      isGenerating: isGenerating ?? this.isGenerating,
      feedbackRating: feedbackRating ?? this.feedbackRating,
    );
  }
}
