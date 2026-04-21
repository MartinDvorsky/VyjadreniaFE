import 'package:flutter/material.dart';
import '../../data/models/chat_message_model.dart';
import 'feedback_buttons.dart';
import 'typing_indicator.dart';
import 'package:vyjadrenia/utils/app_theme.dart';
import 'package:provider/provider.dart';
import '../chat_notifier.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessageModel message;

  const MessageBubble({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isUser = message.role == 'user';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser
                        ? AppTheme.primaryRed
                        : (isDark ? AppTheme.darkSurface : Colors.white),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    border: isUser 
                        ? null 
                        : Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: message.isGenerating
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 4.0),
                          child: TypingIndicator(),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildContent(context, message.content, isUser),
                            if (!isUser && message.id != null) ...[
                              const SizedBox(height: 8),
                              FeedbackButtons(
                                messageId: message.id,
                                currentRating: message.feedbackRating,
                                onRatingSelected: (rating) {
                                  context.read<ChatNotifier>().provideFeedback(message.id!, rating);
                                },
                              ),
                            ],
                          ],
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, String content, bool isUser) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseStyle = TextStyle(
      color: isUser ? Colors.white : (isDark ? Colors.white.withOpacity(0.9) : AppTheme.textDark),
      fontSize: 15,
      height: 1.5,
      letterSpacing: -0.1,
    );

    // Simple markdown support (bolding and line breaks)
    final parts = content.split('**');
    if (parts.length <= 1) {
      return Text(content, style: baseStyle);
    }

    List<TextSpan> spans = [];
    for (int i = 0; i < parts.length; i++) {
      if (i % 2 == 1) {
        spans.add(TextSpan(
          text: parts[i], 
          style: baseStyle.copyWith(fontWeight: FontWeight.bold, color: isUser ? Colors.white : (isDark ? Colors.white : Colors.black))
        ));
      } else {
        spans.add(TextSpan(text: parts[i], style: baseStyle));
      }
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}
