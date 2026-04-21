import 'package:flutter/material.dart';

class FeedbackButtons extends StatelessWidget {
  final String? messageId;
  final int? currentRating;
  final Function(int) onRatingSelected;

  const FeedbackButtons({
    Key? key,
    this.messageId,
    this.currentRating,
    required this.onRatingSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (messageId == null) return const SizedBox.shrink();

    final bool isHandled = currentRating != null;

    return Opacity(
      opacity: isHandled ? 1.0 : 0.7,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              currentRating == 1 ? Icons.thumb_up_rounded : Icons.thumb_up_outlined,
              size: 16,
              color: currentRating == 1 ? Colors.green : Colors.grey,
            ),
            onPressed: isHandled ? null : () => onRatingSelected(1),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            splashRadius: 16,
            tooltip: 'Užitočné',
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: Icon(
              currentRating == -1 ? Icons.thumb_down_rounded : Icons.thumb_down_outlined,
              size: 16,
              color: currentRating == -1 ? Colors.red : Colors.grey,
            ),
            onPressed: isHandled ? null : () => onRatingSelected(-1),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            splashRadius: 16,
            tooltip: 'Neužitočné',
          ),
        ],
      ),
    );
  }
}
