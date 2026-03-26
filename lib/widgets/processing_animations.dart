// lib/widgets/processing_animations.dart

import 'package:flutter/material.dart';
import 'dart:math' as Math;
import '../utils/app_theme.dart';

class ModernProcessingAnimation extends StatefulWidget {
  const ModernProcessingAnimation({Key? key}) : super(key: key);

  @override
  State<ModernProcessingAnimation> createState() => _ModernProcessingAnimationState();
}

class _ModernProcessingAnimationState extends State<ModernProcessingAnimation>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _iconFloatController;

  @override
  void initState() {
    super.initState();
    // Ovládač pre pulzujúce kruhy
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Ovládač pre vznášanie ikony (hore-dole)
    _iconFloatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _iconFloatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      alignment: Alignment.center,
      children: [
        // 1. Pulzujúce kruhy (Ripples)
        _buildRipple(0),
        _buildRipple(0.3), // Oneskorenie druhého kruhu
        _buildRipple(0.6), // Oneskorenie tretieho kruhu

        // 2. Stredový kruh (Pevné pozadie)
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
        ),

        // 3. Vznášajúca sa ikona
        AnimatedBuilder(
          animation: _iconFloatController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -5 + (_iconFloatController.value * 10)), // Pohyb -5 až +5
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient, // Použitie gradientu z témy
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRipple(double delay) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        // Vypočítame posunutý čas pre "wave" efekt
        final value = (_pulseController.value + delay) % 1.0;

        // Opacita klesá s rozširovaním (1.0 -> 0.0)
        final opacity = (1.0 - value).clamp(0.0, 1.0);
        // Veľkosť rastie (0.0 -> 1.0)
        final scale = value;

        return Transform.scale(
          scale: 1.0 + (scale * 1.5), // Zväčšenie až na 2.5 násobok
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.primaryRed.withOpacity(opacity * 0.5),
                width: 2,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ==================== 3D ISOMETRIC ANIMATION ====================

class IsometricDocumentAnimation extends StatefulWidget {
  final double size;
  final Color? accentColor; // New parameter
  const IsometricDocumentAnimation({Key? key, this.size = 250, this.accentColor}) : super(key: key);

  @override
  State<IsometricDocumentAnimation> createState() => _IsometricDocumentAnimationState();
}

class _IsometricDocumentAnimationState extends State<IsometricDocumentAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double scale = widget.size / 250.0;
    final Color accent = widget.accentColor ?? AppTheme.primaryRed;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Center(
        child: Transform.scale(
          scale: scale,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Spodný tieň (Ground shadow)
              Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001) // Perspektíva
                  ..rotateX(1.0) // Naklonenie
                  ..rotateZ(0.6), // Pootočenie
                alignment: Alignment.center,
                child: Container(
                  width: 100,
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
              ),

              // Spodný dokument (Statický)
              _buildIsoCard(context, offset: 0, isFloating: false, accent: accent),

              // Stredný dokument (Jemný pohyb)
              _buildIsoCard(context, offset: 15, isFloating: false, accent: accent),

              // Vrchný dokument (Lietajúci + Skenovanie)
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  // Pohyb hore-dole (Levitácia)
                  final floatValue = -30.0 + (5.0 * Math.sin(_controller.value * 2 * Math.pi));

                  return Transform.translate(
                    offset: Offset(0, floatValue), // Levituje nad ostatnými
                    child: _buildIsoCard(
                      context,
                      offset: 30,
                      isFloating: true,
                      scanValue: _controller.value, // Posielame hodnotu pre skener
                      accent: accent,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIsoCard(BuildContext context, {
    required double offset,
    required bool isFloating,
    double? scanValue,
    required Color accent,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Farby pre karty
    final Color cardColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;
    final Color borderColor = isDark ? Colors.white10 : Colors.grey.shade200;

    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001) // Zapnutie 3D perspektívy
        ..rotateX(0.9)  // Naklonenie dozadu
        ..rotateZ(0.6)  // Otočenie do strany
        ..translate(0.0, -offset, 0.0), // Posun v "hĺbke" (stacking effect)
      alignment: Alignment.center,
      child: Container(
        width: 120,
        height: 160,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            // Tieň na pravej strane (vytvára hrúbku)
            BoxShadow(
              color: isDark ? Colors.black45 : Colors.grey.withOpacity(0.3),
              offset: const Offset(4, 4),
              blurRadius: 4,
            ),
            if (isFloating) // Žiara pre hlavný dokument
              BoxShadow(
                color: accent.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: -5,
              ),
          ],
        ),
        // Obsah dokumentu (riadky textu)
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // 1. Riadky textu (Skeleton UI)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hlavička (červená bodka + čiara)
                    Row(
                      children: [
                        Container(width: 12, height: 12, decoration: BoxDecoration(color: accent, shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        Container(width: 40, height: 6, decoration: BoxDecoration(color: isDark? Colors.white24 : Colors.grey[300], borderRadius: BorderRadius.circular(4))),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Riadky
                    _line(isDark, 80),
                    const SizedBox(height: 8),
                    _line(isDark, 60),
                    const SizedBox(height: 8),
                    _line(isDark, 70),
                  ],
                ),
              ),

              // 2. Skenovací efekt (Len pre plávajúci dokument)
              if (isFloating && scanValue != null)
                Positioned.fill(
                  child: ShaderMask(
                    shaderCallback: (rect) {
                      return LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          accent.withOpacity(0.4), // Farba skenera
                          Colors.transparent,
                        ],
                        stops: [
                          scanValue - 0.2,
                          scanValue,
                          scanValue + 0.2,
                        ],
                      ).createShader(rect);
                    },
                    blendMode: BlendMode.srcATop,
                    child: Container(color: Colors.white.withOpacity(0.1)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _line(bool isDark, double width) {
    return Container(
      width: width,
      height: 4,
      decoration: BoxDecoration(
        color: isDark ? Colors.white12 : Colors.grey[200],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
