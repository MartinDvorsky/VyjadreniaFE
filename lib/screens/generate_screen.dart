import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/generate_provider.dart';
import '../providers/generation_provider.dart';
import '../providers/step2_data_provider.dart';
import '../providers/step3_data_provider.dart';
import '../providers/step4_notifications_provider.dart';
import '../providers/step5_data_provider.dart';
import '../providers/city_provider.dart';
import '../widgets/generate_stepper_widget.dart';
import '../utils/app_theme.dart';

class GenerateScreen extends StatelessWidget {
  // ✅ Callback pre návrat na home
  final VoidCallback? onBackPressed;

  const GenerateScreen({
    Key? key,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ✅ БЕЗ Scaffold - konzistentné s home_screen layoutom
    return Column(
      children: [
        // Header (rovnaký štýl ako Cities Section)
        _buildHeader(context),
        // Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: const GenerateStepperWidget(),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    // Farby pre Header
    final headerBg = isDark ? AppTheme.darkSurface : AppTheme.white;
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor;
    final backButtonBg = isDark ? Colors.white.withOpacity(0.1) : AppTheme.lightGray;
    final backButtonIconColor = isDark ? Colors.white : AppTheme.textDark;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 32,
        vertical: isMobile ? 12 : 20,
      ),
      decoration: BoxDecoration(
        color: headerBg,
        border: Border(
          bottom: BorderSide(color: borderColor, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.cardShadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isMobile
          ? _buildMobileHeader(
        context,
        isDark,
        backButtonBg,
        backButtonIconColor,
      )
          : _buildDesktopHeader(
        context,
        isDark,
        backButtonBg,
        backButtonIconColor,
      ),
    );
  }

  // 📱 Mobile header (stĺpcový layout)
  Widget _buildMobileHeader(
      BuildContext context,
      bool isDark,
      Color backButtonBg,
      Color backButtonIconColor,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Riadok 1: Back button + Icon + Title + Reset
        Row(
          children: [
            IconButton(
              onPressed: onBackPressed,
              icon: Icon(Icons.arrow_back_rounded, color: backButtonIconColor),
              tooltip: 'Späť',
              style: IconButton.styleFrom(
                backgroundColor: backButtonBg,
                padding: EdgeInsets.all(8),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryRed,
                    AppTheme.primaryRed.withOpacity(0.8)
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.rocket_launch_rounded,
                color: AppTheme.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Generovanie dokumentov',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: isDark ? Colors.white : null,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Postupný sprievodca',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white70 : null,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // ✅ NOVÉ: Reset tlačidlo (mobile)
            Consumer<GenerateProvider>(
              builder: (context, provider, child) {
                if (provider.currentStep > 0) {
                  return IconButton(
                    onPressed: () => _showResetDialog(context),
                    icon: const Icon(Icons.refresh_rounded),
                    tooltip: 'Resetovať projekt',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.orange.withOpacity(0.1),
                      foregroundColor: Colors.orange,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Riadok 2: Progress badge (plná šírka na mobile)
        Consumer<GenerateProvider>(
          builder: (context, provider, child) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.primaryRed.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_turned_in_rounded,
                    size: 16,
                    color: AppTheme.primaryRed,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Krok ${provider.currentStep + 1}/${provider.totalSteps}',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.primaryRed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(provider.progress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white : AppTheme.textDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // 💻 Desktop header (riadkový layout)
  Widget _buildDesktopHeader(
      BuildContext context,
      bool isDark,
      Color backButtonBg,
      Color backButtonIconColor,
      ) {
    return Row(
      children: [
        IconButton(
          onPressed: onBackPressed,
          icon: Icon(Icons.arrow_back_rounded, color: backButtonIconColor),
          tooltip: 'Späť',
          style: IconButton.styleFrom(
            backgroundColor: backButtonBg,
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryRed,
                AppTheme.primaryRed.withOpacity(0.8)
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.rocket_launch_rounded,
            color: AppTheme.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Generovanie dokumentov',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: isDark ? Colors.white : null,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Postupný sprievodca',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.white70 : null,
                ),
              ),
            ],
          ),
        ),
        // ✅ NOVÉ: Reset tlačidlo (desktop)
        Consumer<GenerateProvider>(
          builder: (context, provider, child) {
            if (provider.currentStep > 0) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: OutlinedButton.icon(
                  onPressed: () => _showResetDialog(context),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Resetovať'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                    side: const BorderSide(color: Colors.orange, width: 1.5),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        Consumer<GenerateProvider>(
          builder: (context, provider, child) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppTheme.primaryRed.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.assignment_turned_in_rounded,
                    size: 18,
                    color: AppTheme.primaryRed,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Krok ${provider.currentStep + 1}/${provider.totalSteps}',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.primaryRed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${(provider.progress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white : AppTheme.textDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // ✅ UPRAVENÝ: Reset dialog s resetom VŠETKÝCH providerov
  void _showResetDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Dialog Colors
    final dialogBg = isDark ? AppTheme.darkCard : Colors.white;
    final warningBoxBg = isDark ? const Color(0xFF3E2C00) : Colors.orange.shade50;
    final warningBorder = isDark ? Colors.orange.shade900 : Colors.orange.shade200;
    final titleColor = isDark ? Colors.white : Colors.black;
    final textColor = isDark ? Colors.white70 : Colors.black87;
    final orangeText = isDark ? Colors.orange.shade200 : Colors.orange.shade900;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: dialogBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: warningBoxBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.warning_rounded,
                color: Colors.orange.shade600,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Resetovať projekt?',
                style: TextStyle(color: titleColor),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Naozaj chceš začať odznova? Všetky vyplnené údaje budú stratené.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: warningBoxBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: warningBorder),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color: isDark
                        ? Colors.orange.shade400
                        : Colors.orange.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Vymaže sa:\n• Výber mesta\n• Základné údaje\n• Detailné údaje\n• Notifikácie\n• Názvy súborov\n• Priebeh generovania',
                      style: TextStyle(
                        fontSize: 13,
                        color: orangeText,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'ZRUŠIŤ',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(dialogContext);

              // ✅ Reset VŠETKÝCH providerov
              final genProvider =
              Provider.of<GenerationProvider>(context, listen: false);
              final step2Provider =
              Provider.of<Step2DataProvider>(context, listen: false);
              final step3Provider =
              Provider.of<Step3DataProvider>(context, listen: false);
              final step4Provider =
              Provider.of<Step4NotificationsProvider>(context, listen: false);
              final step5Provider =
              Provider.of<Step5DataProvider>(context, listen: false);
              final cityProvider =
              Provider.of<CityProvider>(context, listen: false);
              final generateProvider =
              Provider.of<GenerateProvider>(context, listen: false);

              genProvider.reset();
              step2Provider.reset();
              step3Provider.reset();
              step4Provider.reset();
              step5Provider.reset();
              cityProvider.reset();
              generateProvider.reset();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.check_circle_outline, color: Colors.white),
                      SizedBox(width: 12),
                      Text('Projekt bol úspešne resetovaný'),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text(
              'ÁNO, RESETOVAŤ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}