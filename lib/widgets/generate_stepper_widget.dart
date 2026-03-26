import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/generate_provider.dart';
import '../utils/app_theme.dart';
import '../providers/step2_data_provider.dart';
import '../providers/step3_data_provider.dart';
import '../providers/step5_data_provider.dart';
// Import krokov
import '../screens/generate_steps/step_1_city_selection.dart';
import '../screens/generate_steps/step_2_basic_settings.dart';
import '../screens/generate_steps/step_3_detailed_data.dart';
import '../screens/generate_steps/step_4_notifications.dart';
import '../screens/generate_steps/step_5_file_names.dart';
import '../screens/generate_steps/step_6_generate.dart';

class GenerateStepperWidget extends StatelessWidget {
  const GenerateStepperWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GenerateProvider>(
      builder: (context, provider, child) {
        // ✅ Nastav context pre validáciu
        provider.setContext(context);

        return Column(
          children: [
            _buildCompactHeaderWithIcons(context, provider),
            const SizedBox(height: 16),
            Expanded(
              child: _buildStepContent(context, provider),
            ),
            const SizedBox(height: 16),
            _buildNavigationButtons(context, provider),
          ],
        );
      },
    );
  }

  Widget _buildCompactHeaderWithIcons(BuildContext context, GenerateProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final containerBg = isDark ? AppTheme.darkCard : AppTheme.white;
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor.withOpacity(0.3);
    final iconBg = isDark ? AppTheme.primaryRed.withOpacity(0.2) : AppTheme.primaryRed.withOpacity(0.1);
    final progressBg = isDark ? AppTheme.primaryRed.withOpacity(0.15) : AppTheme.primaryRed.withOpacity(0.08);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: containerBg, // ✅
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1), // ✅
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBg, // ✅
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getIconData(provider.stepIcons[provider.currentStep]),
                  color: AppTheme.primaryRed,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.stepTitles[provider.currentStep],
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppTheme.textDark, // ✅
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Krok ${provider.currentStep + 1} z ${provider.totalSteps}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white70 : AppTheme.textMedium, // ✅
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: progressBg, // ✅
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(provider.progress * 100).toInt()}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.primaryRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(
              provider.totalSteps,
                  (index) {
                final isActive = provider.currentStep == index;
                final isCompleted = provider.currentStep > index;

                // Farby pre indikátory krokov
                final stepBg = isCompleted
                    ? (isDark ? AppTheme.primaryRed.withOpacity(0.2) : AppTheme.primaryRed.withOpacity(0.1))
                    : isActive
                    ? (isDark ? AppTheme.primaryRed.withOpacity(0.15) : AppTheme.primaryRed.withOpacity(0.08))
                    : Colors.transparent;

                final stepBorder = isActive
                    ? AppTheme.primaryRed
                    : isCompleted
                    ? AppTheme.primaryRed.withOpacity(0.3)
                    : (isDark ? Colors.white.withOpacity(0.1) : AppTheme.lightGray.withOpacity(0.5));

                final stepIconColor = isCompleted || isActive
                    ? AppTheme.primaryRed
                    : (isDark ? Colors.white38 : AppTheme.textLight);

                final separatorColor = isCompleted
                    ? AppTheme.primaryRed.withOpacity(0.3)
                    : (isDark ? Colors.white.withOpacity(0.1) : AppTheme.lightGray.withOpacity(0.3));

                return Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (index < provider.currentStep) {
                              provider.goToStep(index);
                            }
                          },
                          child: Container(
                            height: 32,
                            decoration: BoxDecoration(
                              color: stepBg, // ✅
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: stepBorder, // ✅
                                width: isActive ? 2 : 1,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                isCompleted
                                    ? Icons.check_rounded
                                    : _getIconData(provider.stepIcons[index]),
                                color: stepIconColor, // ✅
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (index < provider.totalSteps - 1)
                        Container(
                          width: 8,
                          height: 2,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: separatorColor, // ✅
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(BuildContext context, GenerateProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final containerBg = isDark ? AppTheme.darkCard : AppTheme.white;
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor.withOpacity(0.3);

    return Container(
      decoration: BoxDecoration(
        color: containerBg, // ✅
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1), // ✅
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _getStepWidget(provider.currentStep),
      ),
    );
  }

  Widget _getStepWidget(int step) {
    switch (step) {
      case 0:
        return const Step1CitySelection();
      case 1:
        return const Step2BasicSettings();
      case 2:
        return const Step3DetailedData();
      case 3:
        return const Step4Notifications();
      case 4:
        return const Step5FileNames();
      case 5:
        return const Step6Generate();
      default:
        return const Center(child: Text('Neznámy krok'));
    }
  }

  Widget _buildNavigationButtons(BuildContext context, GenerateProvider provider) {
    final isLastStep = provider.currentStep == provider.totalSteps - 1;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Farby pre panel tlačidiel
    final containerBg = isDark ? AppTheme.darkCard : AppTheme.white;
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor.withOpacity(0.3);
    final disabledBtnBg = isDark ? Colors.white.withOpacity(0.05) : AppTheme.lightGray;
    final disabledBtnFg = isDark ? Colors.white38 : AppTheme.textLight;
    final outlineBtnBorder = isDark ? Colors.white.withOpacity(0.2) : AppTheme.borderColor;

    // ✅ Na Step 6 zobraz len tlačidlo Späť
    if (isLastStep) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: containerBg, // ✅
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1), // ✅
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: provider.previousStep,
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text('Späť'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: outlineBtnBorder, width: 1.5), // ✅
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // ✅ Multi-Consumer pre reaktivitu na zmeny v Step2, Step3, Step5
    return Consumer3<Step2DataProvider, Step3DataProvider, Step5DataProvider>(
      builder: (context, step2, step3, step5, child) {
        // ✅ Validácia sa aktualizuje automaticky pri zmene v ktoromkoľvek provideri
        final canGoNext = provider.isStepValid(context, provider.currentStep);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: containerBg, // ✅
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1), // ✅
          ),
          child: Row(
            children: [
              // Späť button
              if (provider.currentStep > 0)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: provider.previousStep,
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    label: const Text('Späť'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: outlineBtnBorder, width: 1.5), // ✅
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              if (provider.currentStep > 0) const SizedBox(width: 12),
              // Pokračovať button
              Expanded(
                flex: provider.currentStep > 0 ? 2 : 1,
                child: ElevatedButton.icon(
                  onPressed: canGoNext ? provider.nextStep : null,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: const Text('Pokračovať'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryRed,
                    foregroundColor: AppTheme.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    disabledBackgroundColor: disabledBtnBg, // ✅
                    disabledForegroundColor: disabledBtnFg, // ✅
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getIconData(dynamic iconName) {
    switch (iconName) {
      case 'location_city':
        return Icons.location_city_rounded;
      case 'settings':
        return Icons.settings_rounded;
      case 'description':
        return Icons.description_rounded;
      case 'notifications':
        return Icons.notifications_rounded;
      case 'folder':
        return Icons.folder_rounded;
      case 'rocket_launch':
        return Icons.rocket_launch_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }
}
