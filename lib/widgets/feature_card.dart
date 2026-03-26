import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';

class FeatureCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const FeatureCard({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  @override
  State<FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<FeatureCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppTheme.darkCard : AppTheme.white;
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor;
    final textColor = isDark ? Colors.white : AppTheme.textDark;
    final descriptionColor = isDark ? Colors.white70 : AppTheme.textMedium;

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: AppConstants.animationDuration,
        transform: Matrix4.translationValues(0, isHovered ? -4 : 0, 0),
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isHovered ? AppTheme.primaryRed : borderColor,
              width: isHovered ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isHovered
                    ? AppTheme.primaryRed.withOpacity(0.15)
                    : (isDark ? Colors.black26 : AppTheme.cardShadow),
                blurRadius: isHovered ? 16 : 8,
                offset: Offset(0, isHovered ? 8 : 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 14 : 20), // ✅ Ešte menší padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Ikona
                    Container(
                      width: isMobile ? 44 : 56, // ✅ Ešte menšia ikona
                      height: isMobile ? 44 : 56,
                      decoration: BoxDecoration(
                        color: isHovered
                            ? AppTheme.primaryRed
                            : AppTheme.primaryRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        widget.icon,
                        size: isMobile ? 22 : 28, // ✅ Menšia ikona
                        color: isHovered ? AppTheme.white : AppTheme.primaryRed,
                      ),
                    ),
                    SizedBox(height: isMobile ? 10 : 16), // ✅ Menší spacing

                    // Titulok
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: isMobile ? 15 : 18, // ✅ Menší text
                        fontWeight: FontWeight.w700,
                        color: textColor,
                        letterSpacing: -0.3,
                        height: 1.2, // ✅ Pridané pre menší line height
                      ),
                      maxLines: 2, // ✅ Max 2 riadky
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: isMobile ? 4 : 8), // ✅ Menší spacing

                    // Popis
                    Text(
                      widget.description,
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14, // ✅ Menší text
                        color: descriptionColor,
                        height: 1.3, // ✅ Menší line height
                        letterSpacing: -0.1,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // ✅ Menší spacing pred tlačidlom
                    SizedBox(height: isMobile ? 8 : 16),

                    // Tlačidlo Otvoriť
                    Row(
                      children: [
                        Text(
                          'Otvoriť',
                          style: TextStyle(
                            fontSize: isMobile ? 12 : 14, // ✅ Menší text
                            fontWeight: FontWeight.w600,
                            color: isHovered
                                ? AppTheme.primaryRed
                                : (isDark ? Colors.white60 : AppTheme.textLight),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: isMobile ? 13 : 16, // ✅ Menšia ikona
                          color: isHovered
                              ? AppTheme.primaryRed
                              : (isDark ? Colors.white60 : AppTheme.textLight),
                        ),
                      ],
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
