// ========================================
// APPLICATIONS SECTION - OPRAVENÝ DARK MODE
// Uložiť ako: lib/screens/database_sections/applications_section.dart
// ========================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/application_edit_provider.dart';
import '../../widgets/application_search_widget.dart';
import '../../widgets/application_edit_panel.dart';
import '../../widgets/application_create_dialog.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';

class ApplicationsSection extends StatefulWidget {
  const ApplicationsSection({Key? key}) : super(key: key);

  @override
  State<ApplicationsSection> createState() => _ApplicationsSectionState();
}

class _ApplicationsSectionState extends State<ApplicationsSection> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChangeNotifierProvider(
      create: (_) => ApplicationEditProvider(),
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
                    // Ľavá strana - Search & Results
                    Expanded(
                      flex: 4,
                      child: ApplicationSearchWidget(
                        onApplicationSelected: (application) {},
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Pravá strana - Edit Panel
                    Expanded(
                      flex: 6,
                      child: Consumer<ApplicationEditProvider>(
                        builder: (context, provider, child) {
                          if (provider.selectedApplication == null) {
                            return _buildEmptyState(context);
                          }
                          return ApplicationEditPanel(
                            application: provider.selectedApplication!,
                            onCancel: () {
                              provider.clearSelection();
                            },
                            onSaved: () {
                              _refreshSearch();
                            },
                            onDeleted: () {
                              _refreshSearch();
                            },
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
                      colors: [Colors.green.shade400, Colors.green.shade600],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.business_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Úrady a inštitúcie',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: isDark ? Colors.white : null, // ✅
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Správa úradov a inštitúcií v systéme',
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
          Consumer<ApplicationEditProvider>(
            builder: (context, provider, child) {
              return Row(
                children: [
                  _buildStatChip(
                    context: context,
                    icon: Icons.search,
                    label: 'Nájdené',
                    value: '${provider.applications.length}',
                    color: Colors.green,
                  ),
                  const SizedBox(width: 12),
                  if (provider.selectedApplication != null)
                    _buildStatChip(
                      context: context,
                      icon: Icons.edit,
                      label: 'Vybrané',
                      value: '1',
                      color: Colors.blue,
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 16),
          // Add New Application Button
          ElevatedButton.icon(
            onPressed: _showCreateApplicationDialog,
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text('Nový úrad'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
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
                  fontSize: 16,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
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
        ? [const Color(0xFF1B3320), const Color(0xFF27442E)] // Dark Green Gradient
        : [Colors.green.shade50, Colors.green.shade100];

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
                color: Colors.green.shade400,
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
              'Kliknite na úrad zo zoznamu\npre zobrazenie a úpravu údajov',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white70 : null, // ✅
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateApplicationDialog() async {
    final result = await showDialog(
      context: context,
      builder: (context) => const ApplicationCreateDialog(),
    );

    if (result == true) {
      _refreshSearch();
    }
  }

  void _refreshSearch() {
    final provider = context.read<ApplicationEditProvider>();
    if (provider.applications.isNotEmpty) {
      provider.searchApplications();
    }
  }
}
