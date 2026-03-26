// filepath: lib/widgets/permission_denied_dialog.dart

import 'package:flutter/material.dart';
import 'dart:math' as math; // Potrebné pre výpočet sínusu pri levitácii
import '../utils/app_theme.dart';

/// Vylepšený animovaný dialog pre zobrazenie chyby pri nedostatočných oprávneniach
class PermissionDeniedDialog extends StatefulWidget {
  final String title;
  final String message;
  final String? actionName; // Napr. "Pridať mesto", "Zmazať úrad"
  final VoidCallback? onDismiss;

  const PermissionDeniedDialog({
    super.key,
    this.title = 'Prístup odmietnutý',
    // Zmenený predvolený text na explicitnejší
    this.message = 'Pre vykonanie tejto akcie (pridávanie alebo úprava údajov) musíte mať priraďené oprávnenia Administrátora.',
    this.actionName,
    this.onDismiss,
  });

  @override
  State<PermissionDeniedDialog> createState() => _PermissionDeniedDialogState();

  /// Statická metóda na jednoduchšie zobrazenie
  static Future<void> show(
      BuildContext context, {
        String title = 'Prístup odmietnutý',
        String? message, // Ak je null, použije sa default z konštruktora
        String? actionName,
      }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => PermissionDeniedDialog(
        title: title,
        // Tu musíme ošetriť default správu, ak parameter message neprišiel
        message: message ?? 'Pre vykonanie tejto akcie (pridávanie alebo úprava údajov) musíte mať priraďené oprávnenia Administrátora.',
        actionName: actionName,
      ),
    );
  }
}

// Zmena na TickerProviderStateMixin pre podporu viacerých animácií
class _PermissionDeniedDialogState extends State<PermissionDeniedDialog>
    with TickerProviderStateMixin {
  // Animácie pre vstup dialogu
  late AnimationController _entryController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  // NOVÉ: Animácie pre header (inšpirované processing_animations.dart)
  late AnimationController _pulseController; // Pre vlny na pozadí
  late AnimationController _iconFloatController; // Pre vznášanie ikony

  @override
  void initState() {
    super.initState();

    // 1. Nastavenie vstupnej animácie dialogu
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.elasticOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeIn),
    );

    // 2. NOVÉ: Nastavenie animácií pre header
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // Pomalšie, elegantnejšie vlny
    )..repeat();

    _iconFloatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Spustiť vstupnú animáciu
    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pulseController.dispose();
    _iconFloatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: _buildDialogContent(),
        ),
      ),
    );
  }

  Widget _buildDialogContent() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Farby pre dialog
    final dialogBg = isDark ? AppTheme.darkCard : Colors.white;
    final textColor = isDark ? Colors.white70 : Colors.grey.shade700;

    // Farby pre Amber box (Pokus)
    final amberBoxBg = isDark ? const Color(0xFF3E2C00) : Colors.amber.shade50;
    final amberBorder = isDark ? Colors.amber.shade900 : Colors.amber.shade200;
    final amberText = isDark ? Colors.amber.shade200 : Colors.amber.shade700;

    // Farby pre Blue box (Info)
    final blueBoxBg = isDark ? const Color(0xFF0D1B2A) : Colors.blue.shade50;
    final blueBorder = isDark ? Colors.blue.shade900 : Colors.blue.shade200;
    final blueText = isDark ? Colors.blue.shade200 : Colors.blue.shade700;

    return Container(
      width: 400,
      constraints: const BoxConstraints(maxWidth: 480),
      decoration: BoxDecoration(
        color: dialogBg,
        borderRadius: BorderRadius.circular(24), // Mierne oblejšie
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // === PREROBENÝ ANIMOVANÝ HEADER ===
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            child: Container(
              width: double.infinity,
              height: 180, // Pevná výška pre animácie
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.red.shade400,
                    AppTheme.primaryRed, // Použitie farby z témy
                  ],
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 1. Pulzujúce kruhy na pozadí (biele s nízkou opacitou)
                  _buildRipple(0, isDark),
                  _buildRipple(0.4, isDark),
                  _buildRipple(0.8, isDark),

                  // 2. Obsah headra (Ikona + Nadpis)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Vznášajúca sa ikona
                        AnimatedBuilder(
                          animation: _iconFloatController,
                          builder: (context, child) {
                            // Pohyb -6 až +6 pixelov
                            final floatOffset = 6.0 * math.sin(_iconFloatController.value * 2 * math.pi);
                            return Transform.translate(
                              offset: Offset(0, floatOffset),
                              child: child,
                            );
                          },
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  )
                                ]
                            ),
                            child: const Icon(
                              Icons.lock_person_rounded, // Explicitnejšia ikona
                              size: 36,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Nadpis
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            widget.title,
                            style: const TextStyle(
                              fontSize: 22, // Mierne väčšie
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // === CONTENT ===
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Správa - Zvýraznená
                Text(
                  widget.message,
                  style: TextStyle(
                    fontSize: 15, // Mierne väčšie
                    color: textColor,
                    height: 1.6, // Lepšia čitateľnosť
                    fontWeight: FontWeight.w500, // Trochu hrubšie
                  ),
                  textAlign: TextAlign.center,
                ),

                // Akcia (ak je zadaná)
                if (widget.actionName != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: amberBoxBg,
                      border: Border.all(
                        color: amberBorder,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.pan_tool_outlined, // Ikona stopky/ruky
                          size: 20,
                          color: amberText,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Zablokovaná akcia: ${widget.actionName}',
                            style: TextStyle(
                              fontSize: 13,
                              color: amberText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // Info box o administrátorovi
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: blueBoxBg,
                    border: Border.all(
                      color: blueBorder,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.admin_panel_settings_outlined, // Ikona admina
                        size: 20,
                        color: blueText,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Prosím, kontaktujte systémového administrátora pre overenie alebo pridelenie potrebných práv.',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // === BUTTON ===
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onDismiss?.call();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  shadowColor: AppTheme.primaryRed.withOpacity(0.5),
                ),
                child: const Text(
                  'Rozumiem',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Pomocný widget pre pulzujúce kruhy v headri (prevzaté a upravené z processing_animations.dart)
  Widget _buildRipple(double delay, bool isDark) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        // Vypočítame posunutý čas pre "wave" efekt
        final value = (_pulseController.value + delay) % 1.0;

        // Opacita klesá s rozširovaním (0.15 -> 0.0) - chceme to veľmi jemné
        final opacity = (0.15 * (1.0 - value)).clamp(0.0, 0.15);
        // Veľkosť rastie (0.6 -> 1.3)
        final scale = 0.6 + (value * 0.7);

        return Transform.scale(
          scale: scale,
          child: Container(
            width: 200, // Väčšie kruhy pre header
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                // Používame bielu farbu pre vlny na červenom pozadí
                color: Colors.white.withOpacity(opacity),
                width: 4, // Hrubšia čiara pre eleganciu
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Variant ako Snackbar (menej invazívny) - Tiež aktualizované texty
void showPermissionDeniedSnackbar(
    BuildContext context, {
      String message = 'Na túto akciu nemáte oprávnenie Administrátora.',
      String? actionName,
    }) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Skryť predchádzajúci
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(
            Icons.lock_person_rounded,
            color: Colors.white,
            size: 22,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Prístup odmietnutý',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message,
                  style: const TextStyle(fontSize: 13),
                ),
                if (actionName != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    'Akcia: $actionName',
                    style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      backgroundColor: AppTheme.primaryRed,
      duration: const Duration(seconds: 5), // Trochu dlhšie, keďže je tam viac textu
      behavior: SnackBarBehavior.floating,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(16),
    ),
  );
}