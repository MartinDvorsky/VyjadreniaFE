import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class AnimatedWelcomeBanner extends StatefulWidget {
  final String title;
  final String subtitle;
  final bool isDark;

  const AnimatedWelcomeBanner({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.isDark,
  }) : super(key: key);

  @override
  State<AnimatedWelcomeBanner> createState() => _AnimatedWelcomeBannerState();
}

class _AnimatedWelcomeBannerState extends State<AnimatedWelcomeBanner> with TickerProviderStateMixin {
  // Kontrolér pre úvodné zobrazenie (Fade a Slide)
  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Kontrolér pre nekonečné vznášanie ikony
  late AnimationController _floatingController;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Úvodná animácia (vynorenie)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3), // Začína kúsok nižšie
      end: Offset.zero,            // Skončí na pôvodnej pozícii
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    ));

    // 2. Animácia vznášania (Loop)
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _floatingAnimation = Tween<double>(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    // Spustenie úvodnej animácie po kratučkej pauze
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.isDark
                  ? [const Color(0xFF1E1E1E), const Color(0xFF2A1515)] // Tmavý režim
                  : [Colors.white, AppTheme.primaryRed.withOpacity(0.05)], // Svetlý režim
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isDark ? Colors.white12 : AppTheme.primaryRed.withOpacity(0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: widget.isDark ? Colors.black26 : Colors.black.withOpacity(0.03),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Textová časť
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: widget.isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.subtitle,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: widget.isDark ? Colors.white70 : Colors.black54,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Vznášajúca sa ikona
              AnimatedBuilder(
                  animation: _floatingAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _floatingAnimation.value),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryRed.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.rocket_launch_rounded, // Alebo akákoľvek iná ikona (napr. dashboard, auto_awesome)
                          size: 48,
                          color: AppTheme.primaryRed,
                        ),
                      ),
                    );
                  }
              ),
            ],
          ),
        ),
      ),
    );
  }
}