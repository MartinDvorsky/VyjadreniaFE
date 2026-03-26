// lib/widgets/notification_badge_widget.dart

import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class NotificationBadge extends StatelessWidget {
  final int count;
  final Color? backgroundColor;
  final Color? textColor;

  const NotificationBadge({
    Key? key,
    required this.count,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();

    // V Dark mode môžeme chcieť jemne iný odtieň červenej ak nie je explicitne zadaná
    // Ale pre badge je štandardná červená zvyčajne OK.
    // Prípadne: final badgeBg = Theme.of(context).brightness == Brightness.dark ? Colors.redAccent : AppTheme.primaryRed;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.primaryRed,
        borderRadius: BorderRadius.circular(10),
      ),
      constraints: const BoxConstraints(
        minWidth: 18,
        minHeight: 18,
      ),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
