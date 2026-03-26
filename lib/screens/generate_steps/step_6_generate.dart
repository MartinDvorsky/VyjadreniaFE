// lib/screens/generate_steps/step_6_generate.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vyjadrenia/providers/generate_provider.dart';
import 'package:vyjadrenia/screens/slovensko_sk_improved_screen.dart';
import 'package:vyjadrenia/screens/slovensko_sk_prototype_screen.dart';
import '../../providers/generation_provider.dart';
import '../../providers/step2_data_provider.dart';
import '../../providers/step3_data_provider.dart';
import '../../providers/step4_notifications_provider.dart';
import '../../providers/step5_data_provider.dart';
import '../../providers/city_provider.dart';
import '../../providers/metrics_provider.dart';
import '../../services/generation_service.dart';
import '../../services/notification_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/download_helper.dart';
import '../../widgets/instruction_guide_widget_v2.dart'; // ✅ NOVÝ IMPORT
import '../../widgets/processing_animations.dart';
import 'dart:math' as Math;

class Step6Generate extends StatelessWidget {
  const Step6Generate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GenerationProvider>(
      builder: (context, genProvider, child) {
        switch (genProvider.state) {
          case GenerationState.idle:
            return _buildIdleState(context);
          case GenerationState.generating:
            return _buildGeneratingState(context, genProvider);
          case GenerationState.success:
            return _buildSuccessState(context, genProvider);
          case GenerationState.error:
            return _buildErrorState(context, genProvider);
          default:
            return _buildIdleState(context);
        }
      },
    );
  }

  // ==================== IDLE STATE ====================
  Widget _buildIdleState(BuildContext context) {
    final step5 = Provider.of<Step5DataProvider>(context, listen: false);
    final step2 = Provider.of<Step2DataProvider>(context, listen: false);
    final cityProvider = Provider.of<CityProvider>(context, listen: false);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ikona
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.primaryRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.rocket_launch_rounded,
                size: 64,
                color: AppTheme.primaryRed,
              ),
            ),
            const SizedBox(height: 32),
            // Nadpis
            Text(
              'Pripravené na generovanie',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : null,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Skontroluj si prosím údaje pred spustením',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 48),
            // Sumár karta
            _buildModernSummaryCard(context, step5, step2, cityProvider),
            const SizedBox(height: 48),
            // Tlačidlo generovania
            ElevatedButton(
              onPressed: () => _startGeneration(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.play_arrow, size: 28),
                  SizedBox(width: 12),
                  Text(
                    'Spustiť generovanie',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernSummaryCard(
      BuildContext context,
      Step5DataProvider step5,
      Step2DataProvider step2,
      CityProvider cityProvider,
      ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppTheme.darkCard : Colors.white;

    return Card(
      elevation: 2,
      color: cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hlavička karty
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.summarize_rounded,
                    color: AppTheme.primaryRed,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Sumár generovania',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Divider(color: isDark ? Colors.white24 : null),
            const SizedBox(height: 24),
            // Informácie
            _buildInfoRow(
              icon: Icons.folder_outlined,
              label: 'Projekt',
              value: step2.znacka,
              context: context,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.business_outlined,
              label: 'Stavba',
              value: step2.nazovStavby,
              context: context,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.location_city_outlined,
              label: 'Mestá',
              value: cityProvider.selectedCities.isNotEmpty 
                  ? cityProvider.selectedCities.map((c) => c.name).join(', ') 
                  : 'Nevybraté',
              context: context,
            ),
            const SizedBox(height: 16),
            // ✅ Dokumenty na generovanie
            _buildInfoRow(
              icon: Icons.description_outlined,
              label: 'Dokumenty na generovanie',
              value: '${step5.toGenerateCount}',
              context: context,
              valueColor: AppTheme.primaryRed,
            ),
            // ✅ Online úrady
            if (step5.onlineCount > 0) ...[
              const SizedBox(height: 16),
              _buildInfoRow(
                icon: Icons.cloud_upload_rounded,
                label: 'Online podania na vlastnej webovej stránke',
                value: '${step5.onlineCount}',
                context: context,
                valueColor: Colors.blue.shade700,
              ),
            ],
            // Skryté úrady
            if (step5.hiddenCount > 0) ...[
              const SizedBox(height: 16),
              _buildInfoRow(
                icon: Icons.visibility_off_outlined,
                label: 'Skryté úrady',
                value: '${step5.hiddenCount}',
                context: context,
                valueColor: Colors.orange,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required BuildContext context,
    Color? valueColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Icon(icon, size: 20, color: isDark ? Colors.white60 : Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white70 : Colors.grey[700],
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor ?? (isDark ? Colors.white : Colors.black87),
          ),
        ),
      ],
    );
  }

  // ==================== GENERATING STATE ====================
  Widget _buildGeneratingState(BuildContext context, GenerationProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    double visualProgress = provider.progress;

    // Dynamický text zo SSE
    String statusText = 'Pripravuje sa štruktúra dokumentov';
    String subText = provider.currentFile ?? 'Prebieha analýza vstupných údajov';

    if (provider.statusMessage != null) {
      statusText = provider.statusMessage!;
    } else if (provider.currentCount > 0) {
      statusText = 'Prebieha generovanie dokumentov (${provider.currentCount} / ${provider.totalCount})';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 1. 3D IZOMETRICKÁ ANIMÁCIA
          const SizedBox(
            height: 250,
            width: 250,
            child: IsometricDocumentAnimation(),
          ),

          const SizedBox(height: 40),

          // 2. Texty (S plynulou animáciou zmeny)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Column(
              key: ValueKey<String>(statusText + subText),
              children: [
                Text(
                  statusText,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppTheme.darkGray,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  subText,
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.grey[500],
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // 3. Ultra-tenký moderný progress bar
          Container(
            width: 220, // Trochu širší
            height: 6,  // Trochu hrubší pre lepší vizuál
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : Colors.grey[200],
              borderRadius: BorderRadius.circular(3),
            ),
            child: Stack(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300), 
                  curve: Curves.easeOutCubic,
                  width: 220 * visualProgress,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    gradient: const LinearGradient(
                      colors: [
                        AppTheme.primaryRed,
                        Color(0xFFFF5F6D)
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryRed.withOpacity(0.4),
                        blurRadius: 10,
                        spreadRadius: 0,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Percentá
          Text(
            '${(visualProgress * 100).toInt()}%',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: AppTheme.primaryRed,
            ),
          ),
        ],
      ),
    );
  }



  // ==================== SUCCESS STATE ====================
  Widget _buildSuccessState(BuildContext context, GenerationProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppTheme.darkCard : Colors.white;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    // ✅ Získaj počet online úradov
    final step5Provider = Provider.of<Step5DataProvider>(context, listen: false);
    final onlineCount = step5Provider.onlineCount;

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success animácia (namiesto statickej ikony)
              const SizedBox(
                height: 180,
                width: 180,
                child: IsometricDocumentAnimation(
                  size: 180,
                  accentColor: Colors.green,
                ),
              ),
              const SizedBox(height: 32),
              // Nadpis
              Text(
                'Hotovo!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Dokumenty boli úspešne vygenerované',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isDark ? Colors.white70 : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 48),

              // Výsledky karty
              Container(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Card(
                  elevation: 2,
                  color: cardBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        _buildStatRow(
                          context: context,
                          icon: Icons.check_circle_outline,
                          label: 'Vygenerované súbory',
                          value: provider.generatedFiles.length.toString(),
                          color: Colors.green,
                        ),
                        if (provider.failedFiles.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Divider(color: isDark ? Colors.white24 : null),
                          const SizedBox(height: 16),
                          _buildStatRow(
                            context: context,
                            icon: Icons.error_outline,
                            label: 'Chyby',
                            value: provider.failedFiles.length.toString(),
                            color: Colors.red,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Tlačidlá - zostávajú bez zmeny
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  // Tlačidlo sťahovania
                  ElevatedButton.icon(
                    onPressed: provider.downloadUrl != null
                        ? () => _downloadDocuments(context, provider.downloadUrl!)
                        : null,
                    icon: const Icon(Icons.download_rounded, size: 28),
                    label: Text(
                      isMobile ? 'Stiahnuť' : 'Stiahnuť dokumenty',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 24 : 48,
                        vertical: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),

                  // Tlačidlo návodu
                  OutlinedButton.icon(
                    onPressed: () => _showInstructionGuide(context, provider),
                    icon: const Icon(Icons.assignment_rounded, size: 28),
                    label: Text(
                      isMobile ? 'Návod' : 'Návod na odoslanie',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue, width: 2),
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 24 : 48,
                        vertical: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  // Tlačidlo odoslania
                  ElevatedButton.icon(
                    onPressed: () => _openSlovenskoSkPrototype(context),
                    icon: const Icon(Icons.cloud_upload_rounded, size: 28),
                    label: Text(
                      isMobile ? 'Odoslať' : 'Odoslať na slovensko.sk',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryRed,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 24 : 48,
                        vertical: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              Container(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Row(
                  children: [
                    // Tlačidlo opakovania generovania (menšie)
                    Expanded(
                      flex: 1,
                      child: OutlinedButton.icon(
                        onPressed: () => _repeatGeneration(context),
                        icon: const Icon(Icons.replay_rounded, size: 20),
                        label: const Text(
                          'Opakovať generovanie',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryRed,
                          side: const BorderSide(
                            color: AppTheme.primaryRed,
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Tlačidlo resetu projektu
                    Expanded(
                      flex: 1,
                      child: OutlinedButton.icon(
                        onPressed: () => _resetGeneration(context),
                        icon: const Icon(Icons.refresh_rounded, size: 20),
                        label: const Text(
                          'Spustiť nový projekt',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? Colors.white70 : Colors.grey[700],
                          side: BorderSide(
                            color: isDark ? Colors.white24 : Colors.grey[300]!,
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  void _repeatGeneration(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.replay_rounded,
                color: AppTheme.primaryRed,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Opakovať generovanie?'),
          ],
        ),
        content: const Text(
          'Dokumenty sa vygenerujú znova.',
          style: TextStyle(fontSize: 15),
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

              // Reset len generation providera, nie dát
              final genProvider = Provider.of<GenerationProvider>(context, listen: false);
              genProvider.reset();

              // Spusti generovanie znova
              _startGeneration(context);
            },
            icon: const Icon(Icons.replay_rounded),
            label: const Text(
              'ÁNO, OPAKOVAŤ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

// ✅ NOVÁ METÓDA: Reset celého generovania
  void _resetGeneration(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: Colors.orange,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Resetovať projekt?'),
          ],
        ),
        content: const Text(
          'Naozaj chceš spustiť nový projekt? Všetky vyplnené údaje budú vymazané.',
          style: TextStyle(fontSize: 15),
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

              // Reset všetkých providerov
              final genProvider = Provider.of<GenerationProvider>(context, listen: false);
              final step2Provider = Provider.of<Step2DataProvider>(context, listen: false);
              final step3Provider = Provider.of<Step3DataProvider>(context, listen: false);
              final step4Provider = Provider.of<Step4NotificationsProvider>(context, listen: false);
              final step5Provider = Provider.of<Step5DataProvider>(context, listen: false);
              final cityProvider = Provider.of<CityProvider>(context, listen: false);
              final generateProvider = Provider.of<GenerateProvider>(context, listen: false);

              // Resetuj všetkých
              genProvider.reset();
              step2Provider.reset();
              step3Provider.reset();
              step4Provider.reset();
              step5Provider.reset();
              cityProvider.reset();
              generateProvider.reset();
              Provider.of<MetricsProvider>(context, listen: false).reset();

              // Zobraz potvrdenie
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: Colors.white),
                      const SizedBox(width: 12),
                      const Text('Projekt bol úspešne resetovaný'),
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
              backgroundColor: AppTheme.primaryRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openSlovenskoSkPrototype(BuildContext context) async {
    // Najprv skontroluj či sú nejaké elektronické žiadosti
    final step5 = Provider.of<Step5DataProvider>(context, listen: false);
    final electronicApps = step5.applications
        .where((app) =>
    app.submission == 'E' &&
        !step5.isHidden(app.applicationId))
        .toList();

    if (electronicApps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text('Žiadne žiadosti s elektronickým podaním (E)'),
              ),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      return;
    }

    // ✅ ZMENENÉ: Otvor IMPROVED screen namiesto starého
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SlovenskoSkImprovedScreen(),
      ),
    );
  }


  Widget _buildStatRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white70 : Colors.grey[700],
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  // ==================== ERROR STATE ====================
  Widget _buildErrorState(BuildContext context, GenerationProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF2C1515) : Colors.red[50];
    final cardBorder = isDark ? Colors.red.shade900 : Colors.red[200]!;
    final textColor = isDark ? Colors.red.shade200 : Colors.red[900];

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error ikona
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 32),
              // Nadpis
              Text(
                'Chyba pri generovaní',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 48),
              // Chybová správa
              Container(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Card(
                  elevation: 2,
                  color: cardBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: cardBorder, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.red),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            provider.errorMessage ?? 'Neznáma chyba',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              // Tlačidlo skúsiť znova
              ElevatedButton(
                onPressed: () => _startGeneration(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded, size: 28),
                    SizedBox(width: 12),
                    Text(
                      'Skúsiť znova',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== AKCIE ====================
  void _startGeneration(BuildContext context) async {
    final genProvider = Provider.of<GenerationProvider>(context, listen: false);
    final step2Provider =
    Provider.of<Step2DataProvider>(context, listen: false);
    final step3Provider =
    Provider.of<Step3DataProvider>(context, listen: false);
    final step4Provider =
    Provider.of<Step4NotificationsProvider>(context, listen: false);
    final step5Provider =
    Provider.of<Step5DataProvider>(context, listen: false);
    final cityProvider = Provider.of<CityProvider>(context, listen: false);
    final metricsProvider = Provider.of<MetricsProvider>(context, listen: false);

    // Validácia
    if (cityProvider.selectedCities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Text('Chýba vybrané mesto!'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    // ✅ Kontroluj len non-online úrady
    if (step5Provider.toGenerateCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_outlined, color: Colors.white),
              SizedBox(width: 12),
              Text('Žiadne dokumenty na generovanie!'),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    // Nastav stav na generating
    genProvider.setState(GenerationState.generating);

    try {
      // ✅ Získaj IDs viditeľných NON-ONLINE aplikácií
      final visibleAppIds = step5Provider.applications
          .where((app) =>
      !step5Provider.isHidden(app.applicationId))  // ✅ Vynechaj online úrady
          .map((app) => app.applicationId)
          .toList();

      // ✅ POSLI METRIKY (Celkový čas od Step 1 po kliknutie na generovanie)
      metricsProvider.stopAndReport(
        znacka: step2Provider.znacka,
        nazovStavby: step2Provider.nazovStavby,
        documentCount: visibleAppIds.length,
      );

      // ✅ Volanie API pre prípravu (krok 1)
      final prepareResponse = await GenerationService.prepareGeneration(
        applicationIds: visibleAppIds,
        step2Data: step2Provider,
        step3Data: step3Provider,
        step5Data: step5Provider,
        cityIds: cityProvider.selectedCities.map((c) => c.id).toList(),
      );

      final taskToken = prepareResponse.taskToken;

      // ✅ Počúvanie streamu (krok 2)
      await for (final event in GenerationService.streamGenerationProgress(taskToken)) {
        genProvider.updateFromEvent(event);
        
        if (event.status == 'done') {
           genProvider.setDownloadUrl(event.filename);
           break;
        }
      }

      // Pre spätnú kompatibilitu výsledkov pre success UI
      genProvider.setResults(
        generatedFiles: List.generate(genProvider.totalCount - genProvider.failedFiles.length, (i) => 'doc_$i'),
        failedFiles: genProvider.failedFiles,
        downloadUrl: genProvider.downloadUrl,
      );

      // Všetko zbehlo
      if (genProvider.failedFiles.isEmpty) {
        // Všetky dokumenty OK → stiahnutie je dostupné cez tlačidlo "Stiahnuť dokumenty" v UI
        // Vytvorenie notifikácie ak je zapnutá
        if (step4Provider.emailNotificationsEnabled) {
          try {
            final notificationService = NotificationService();
            await notificationService.createNotification(
              znacka: step4Provider.znacka ?? 'Bez značky',
              nazovstavby: step4Provider.nazovstavby ?? 'Bez názvu',
              firstNotificationDate: step4Provider.firstNotificationDate ??
                  DateTime.now().add(const Duration(days: 20)),
              secondNotificationDate: step4Provider.secondNotificationDate ??
                  DateTime.now().add(const Duration(days: 40)),
            );
          } catch (notifError) {
            // Neignorujeme chybu - pokračujeme ďalej
          }
        }

        genProvider.setState(GenerationState.success);
      } else if (genProvider.failedFiles.length < genProvider.totalCount && genProvider.totalCount > 0) {
        // Niektoré zlyhali, ale ZIP existuje
        genProvider.setState(GenerationState.success);
        
        _showPartialSuccessDialog(
          context: context,
          downloaded: genProvider.totalCount - genProvider.failedFiles.length,
          total: genProvider.totalCount,
          failedFiles: genProvider.failedFiles,
          downloadUrl: genProvider.downloadUrl,
        );
      } else {
        genProvider.setState(GenerationState.error);
        _showErrorDialog(context, 'Chyba pri generovaní všetkých dokumentov.');
      }
    } catch (e) {
      genProvider.setState(GenerationState.error);
      _showErrorDialog(context, e.toString());
    }
  }

  void _downloadDocuments(BuildContext context, String downloadUrl) async {
    try {
      final filePath = await DownloadHelper.downloadZipFile(downloadUrl);
      if (filePath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white),
                SizedBox(width: 12),
                Text('Sťahovanie zrušené'),
              ],
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text('Dokumenty úspešne stiahnuté!'),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          action: SnackBarAction(
            label: 'OTVORIŤ',
            textColor: Colors.white,
            onPressed: () {
              DownloadHelper.openFileLocation(filePath);
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Chyba pri sťahovaní: $e'),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  // ✅ NOVÁ METÓDA: Zobrazenie návodu na odoslanie
  void _showInstructionGuide(BuildContext context, GenerationProvider provider) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => InstructionGuideWidgetV2(
        generatedFiles: provider.generatedFiles,
      ),
    );
  }

  // ✅ NOVÁ METÓDA: Zobrazenie dialogu pri čiastočnom úspechu
  void _showPartialSuccessDialog({
    required BuildContext context,
    required int downloaded,
    required int total,
    required List<String> failedFiles,
    String? downloadUrl,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Text('Čiastočný úspech'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vygenerovaných $downloaded z $total dokumentov.\nNiektoré dokumenty sa nepodarilo vygenerovať.',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                'Zlyhané dokumenty:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: failedFiles.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          Expanded(child: Text(failedFiles[index], style: const TextStyle(fontSize: 14))),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ZAVRIEŤ'),
          ),
          if (downloadUrl != null)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                _downloadDocuments(context, downloadUrl);
              },
              icon: const Icon(Icons.download_rounded),
              label: const Text('STIAHNUŤ VYGENEROVANÉ'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryRed,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  // ✅ NOVÁ METÓDA: Zobrazenie dialogu pri chybe
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text('Chyba generovania'),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ZAVRIEŤ'),
          ),
        ],
      ),
    );
  }
}



