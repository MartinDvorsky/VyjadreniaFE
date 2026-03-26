import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/automation_provider.dart';
import '../../widgets/automation_bond_list_widget.dart';
import '../../widgets/automation_bond_detail_panel.dart';
import '../../widgets/automation_bond_create_dialog.dart';
import '../../widgets/automation_sync_dialog.dart';
import '../../utils/app_theme.dart';

class AutomationSection extends StatefulWidget {
  const AutomationSection({Key? key}) : super(key: key);

  @override
  State<AutomationSection> createState() => _AutomationSectionState();
}

class _AutomationSectionState extends State<AutomationSection> {
  late AutomationProvider _provider;

  @override
  void initState() {
    super.initState();
    // Vytvor provider a načítaj dáta
    _provider = AutomationProvider();
    _loadData();
  }

  Future<void> _loadData() async {
    await _provider.refresh();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChangeNotifierProvider.value(
      value: _provider,
      child: Scaffold(
        backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightGray,
        body: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ľavá strana - Zoznam bonds
                    Expanded(
                      flex: 4,
                      child: AutomationBondListWidget(
                        onBondSelected: (bond) {},
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Pravá strana - Detail panel
                    Expanded(
                      flex: 6,
                      child: Consumer<AutomationProvider>(
                        builder: (context, provider, child) {
                          if (provider.selectedBond == null) {
                            return _buildEmptyState(context);
                          }
                          return AutomationBondDetailPanel(
                            bond: provider.selectedBond!,
                            onDeleted: () {
                              provider.clearSelection();
                              _refreshData();
                            },
                            onUpdated: () {
                              _refreshData();
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
        color: bg,
        border: Border(
          bottom: BorderSide(color: border, width: 1),
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
                      colors: [Colors.teal.shade400, Colors.teal.shade600],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Automatizácia',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: isDark ? Colors.white : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Správa automatického priraďovania úradov',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white70 : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Stats
          Consumer<AutomationProvider>(
            builder: (context, provider, child) {
              return Row(
                children: [
                  _buildStatChip(
                    context: context,
                    icon: Icons.auto_awesome,
                    label: 'Celkom',
                    value: '${provider.bonds.length}',
                    color: Colors.teal,
                  ),
                  const SizedBox(width: 12),
                  _buildStatChip(
                    context: context,
                    icon: Icons.check_circle,
                    label: 'Aktívne',
                    value: '${provider.activeBondsCount}',
                    color: Colors.green,
                  ),
                  const SizedBox(width: 12),
                  _buildStatChip(
                    context: context,
                    icon: Icons.rule,
                    label: 'Podmienky',
                    value: '${provider.totalConditionsCount}',
                    color: Colors.blue,
                  ),
                ],
              );
            },
          ),
          const SizedBox(width: 16),
          // Sync button
          OutlinedButton.icon(
            onPressed: _showSyncDialog,
            icon: const Icon(Icons.sync_rounded, size: 20),
            label: const Text('Synchronizovať'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
          const SizedBox(width: 12),
          // Add New Automation Button
          ElevatedButton.icon(
            onPressed: _showCreateDialog,
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text('Nová automatizácia'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal.shade600,
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
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 1),
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
                  color: isDark ? Colors.white70 : AppTheme.textLight,
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
        ? [const Color(0xFF004D40), const Color(0xFF00695C)]
        : [Colors.teal.shade50, Colors.teal.shade100];

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 1),
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
                  colors: gradientColors,
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                Icons.touch_app_rounded,
                size: 60,
                color: Colors.teal.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Vyberte automatizáciu',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: isDark ? Colors.white : null,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kliknite na automatizáciu zo zoznamu\npre zobrazenie a úpravu detailov',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white70 : null,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateDialog() async {
    final result = await showDialog(
      context: context,
      builder: (context) => ChangeNotifierProvider.value(
        value: _provider,
        child: const AutomationBondCreateDialog(),
      ),
    );

    if (result == true) {
      _refreshData();
    }
  }

  void _showSyncDialog() async {
    await showDialog(
      context: context,
      builder: (context) => ChangeNotifierProvider.value(
        value: _provider,
        child: const AutomationSyncDialog(),
      ),
    );
    _refreshData();
  }

  void _refreshData() {
    _provider.refresh();
  }
}