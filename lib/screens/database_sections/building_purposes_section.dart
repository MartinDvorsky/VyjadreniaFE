// ========================================
// BUILDING PURPOSES SECTION - OPRAVENÝ DARK MODE
// Uložiť ako: lib/screens/database_sections/building_purposes_section.dart
// ========================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/building_purpose_provider.dart';
import '../../widgets/building_purpose_list_widget.dart';
import '../../widgets/building_purpose_edit_panel.dart';
import '../../widgets/building_purpose_create_dialog.dart';
import '../../utils/app_theme.dart';

class BuildingPurposesSection extends StatefulWidget {
  const BuildingPurposesSection({Key? key}) : super(key: key);

  @override
  State<BuildingPurposesSection> createState() =>
      _BuildingPurposesSectionState();
}

class _BuildingPurposesSectionState extends State<BuildingPurposesSection> {
  @override
  void initState() {
    super.initState();
    // ✅ Načítaj data pri otvorení sekcie
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BuildingPurposeProvider>().loadAllPurposes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ✅ Používa globálny provider z main.dart
    return Scaffold(
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
                  // Ľavá strana - Zoznam účelov
                  Expanded(
                    flex: 4,
                    child: BuildingPurposeListWidget(),
                  ),
                  const SizedBox(width: 24),
                  // Pravá strana - Edit Panel
                  Expanded(
                    flex: 6,
                    child: Consumer<BuildingPurposeProvider>(
                      builder: (context, provider, child) {
                        if (provider.selectedPurpose == null) {
                          return _buildEmptyState(context);
                        }
                        // ✅ KEY je kritický - zabezpečí refresh pri zmene selectedPurpose
                        return BuildingPurposeEditPanel(
                          key: ValueKey(provider.selectedPurpose!.id),
                          purpose: provider.selectedPurpose!,
                          onCancel: () {
                            provider.clearSelection();
                          },
                          onSaved: () {
                            // Refresh ak je potrebné
                          },
                          onDeleted: () {
                            // Už je vymazané cez provider
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
                      colors: [Colors.cyan.shade400, Colors.cyan.shade600],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.category_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Účely stavby',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: isDark ? Colors.white : null, // ✅
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Správa účelov a ich textových šablón',
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
          Consumer<BuildingPurposeProvider>(
            builder: (context, provider, child) {
              final oldCount =
                  provider.purposes.where((p) => p.documentForm == 'old').length;
              final newCount =
                  provider.purposes.where((p) => p.documentForm == 'new').length;
              return Row(
                children: [
                  _buildStatChip(
                    context: context,
                    icon: Icons.category_rounded,
                    label: 'Celkom',
                    value: '${provider.purposes.length}',
                    color: Colors.cyan,
                  ),
                  const SizedBox(width: 12),
                  _buildStatChip(
                    context: context,
                    icon: Icons.description_outlined,
                    label: 'Staré/Nové',
                    value: '$oldCount/$newCount',
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 12),
                  if (provider.selectedPurpose != null)
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
          // Add New Purpose Button
          ElevatedButton.icon(
            onPressed: _showCreatePurposeDialog,
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text('Nový účel'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan.shade600,
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
        ? [const Color(0xFF00363D), const Color(0xFF004D57)] // Dark Cyan Gradient
        : [Colors.cyan.shade50, Colors.cyan.shade100];

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
                color: Colors.cyan.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Vyberte účel stavby',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: isDark ? Colors.white : null, // ✅
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kliknite na účel zo zoznamu\npre zobrazenie a úpravu údajov',
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

  void _showCreatePurposeDialog() async {
    final provider = context.read<BuildingPurposeProvider>();
    final result = await showDialog(
      context: context,
      builder: (dialogContext) => ChangeNotifierProvider.value(
        value: provider,
        child: const BuildingPurposeCreateDialog(),
      ),
    );
    // Nepotrebujeme refresh - provider automaticky pridáva do zoznamu
  }
}
