import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import 'notification_badge_widget.dart';

class MenuItemWidget extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final int? badgeCount;

  const MenuItemWidget({
    Key? key,
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
    this.badgeCount,
  }) : super(key: key);

  @override
  State<MenuItemWidget> createState() => _MenuItemWidgetState();
}

class _MenuItemWidgetState extends State<MenuItemWidget> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    // ✅ Dynamické farby
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hoverColor = isDark
        ? Colors.white.withOpacity(0.05)
        : AppTheme.hoverColor;
    final inactiveTextColor = isDark
        ? Colors.white
        : AppTheme.textDark;
    final iconColor = isDark
        ? Colors.white70
        : AppTheme.textMedium;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: MouseRegion(
        onEnter: (_) => setState(() => isHovered = true),
        onExit: (_) => setState(() => isHovered = false),
        child: AnimatedContainer(
          duration: AppConstants.animationDuration,
          decoration: BoxDecoration(
            gradient: widget.isActive ? AppTheme.primaryGradient : null,
            color: widget.isActive
                ? null
                : isHovered
                ? hoverColor // ✅ Dynamické
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: widget.isActive
                ? [
              BoxShadow(
                color: AppTheme.primaryRed.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.icon,
                      size: 22,
                      color: widget.isActive
                          ? AppTheme.white
                          : iconColor, // ✅ Dynamické
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        widget.label,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: widget.isActive
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: widget.isActive
                              ? AppTheme.white
                              : inactiveTextColor, // ✅ Dynamické
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    if (widget.badgeCount != null && widget.badgeCount! > 0) ...[
                      const SizedBox(width: 8),
                      NotificationBadge(
                        count: widget.badgeCount!,
                        backgroundColor: widget.isActive
                            ? Colors.white
                            : AppTheme.primaryRed,
                        textColor: widget.isActive
                            ? AppTheme.primaryRed
                            : Colors.white,
                      ),
                    ],
                    if (widget.isActive && (widget.badgeCount == null || widget.badgeCount == 0))
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppTheme.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}