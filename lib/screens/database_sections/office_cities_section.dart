// ========================================
// OFFICE CITIES SECTION - OPRAVENÝ DARK MODE
// Uložiť ako: lib/screens/database_sections/office_cities_section.dart
// ========================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/office_cities_provider.dart';
import '../../providers/application_edit_provider.dart';
import '../../widgets/application_search_widget.dart';
import '../../widgets/office_cities_management_panel.dart';
import '../../utils/app_theme.dart';

class OfficeCitiesSection extends StatefulWidget {
  const OfficeCitiesSection({Key? key}) : super(key: key);

  @override
  State<OfficeCitiesSection> createState() => _OfficeCitiesSectionState();
}

class _OfficeCitiesSectionState extends State<OfficeCitiesSection> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ✅ HLAVNÝ provider pre túto sekciu
    return ChangeNotifierProvider(
      create: (_) => OfficeCitiesProvider(),
      child: Scaffold(
        backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightGray, // ✅
        body: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ľavá strana - Office Search
                    Expanded(
                      flex: 4,
                      child: ChangeNotifierProvider(
                        create: (_) => ApplicationEditProvider(),
                        child: Builder(
                          builder: (context) {
                            return ApplicationSearchWidget(
                              onApplicationSelected: (office) {
                                // ✅ Zavolaj OfficeCitiesProvider zo PARENT context
                                context
                                    .read<OfficeCitiesProvider>()
                                    .selectOffice(office);
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Pravá strana - Cities Management
                    Expanded(
                      flex: 6,
                      child: Consumer<OfficeCitiesProvider>(
                        builder: (context, provider, child) {
                          if (provider.selectedOffice == null) {
                            return _buildEmptyState(context);
                          }

                          return OfficeCitiesManagementPanel(
                            office: provider.selectedOffice!,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.darkSurface : AppTheme.white;
    final border = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: BoxDecoration(
        color: bg, // ✅
        border: Border(
          bottom: BorderSide(color: border, width: 1), // ✅
        ),
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: 'Späť na databázy',
          ),
          const SizedBox(width: 16),
          // Title
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple.shade400, Colors.purple.shade600],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.hub_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Úrad - Mestá',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: isDark ? Colors.white : null, // ✅
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Správa prepojení medzi úradmi a mestami',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white70 : null, // ✅
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Stats
          Consumer<OfficeCitiesProvider>(
            builder: (context, provider, child) {
              if (provider.selectedOffice == null) {
                return const SizedBox.shrink();
              }

              return Row(
                children: [
                  _buildStatChip(
                    context: context,
                    icon: Icons.business,
                    label: 'Úrad',
                    value: provider.selectedOffice!.name,
                    color: Colors.purple,
                  ),
                  const SizedBox(width: 12),
                  _buildStatChip(
                    context: context,
                    icon: Icons.location_city,
                    label: 'Mestá',
                    value: '${provider.cities.length}',
                    color: Colors.green,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? color.withOpacity(0.15) : color.withOpacity(0.1);
    final borderColor = isDark ? color.withOpacity(0.4) : color.withOpacity(0.3);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: bg, // ✅
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 1), // ✅
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white70 : AppTheme.textLight, // ✅
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.darkSurface : AppTheme.white;
    final border = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor;
    final gradientColors = isDark
        ? [const Color(0xFF4A148C), const Color(0xFF6A1B9A)] // Dark Purple Gradient
        : [Colors.purple.shade50, Colors.purple.shade100];
    final infoBg = isDark ? Colors.purple.withOpacity(0.15) : Colors.purple.withOpacity(0.05);

    return Container(
      decoration: BoxDecoration(
        color: bg, // ✅
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 1), // ✅
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors, // ✅
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                Icons.touch_app_rounded,
                size: 60,
                color: Colors.purple.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Vyberte úrad',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: isDark ? Colors.white : null, // ✅
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kliknite na úrad zo zoznamu\npre zobrazenie priradených miest',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white70 : null, // ✅
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: infoBg, // ✅
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.purple.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color: Colors.purple.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Po výbere úradu môžete pridávať a odstraňovať mestá',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.purple.shade200 : Colors.purple.shade700, // ✅
                      fontWeight: FontWeight.w500,
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
}
