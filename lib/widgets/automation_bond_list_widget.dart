import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/automation_bond_model.dart';
import '../providers/automation_provider.dart';
import '../utils/app_theme.dart';

class AutomationBondListWidget extends StatefulWidget {
  final Function(AutomationBond) onBondSelected;

  const AutomationBondListWidget({
    Key? key,
    required this.onBondSelected,
  }) : super(key: key);

  @override
  State<AutomationBondListWidget> createState() => _AutomationBondListWidgetState();
}

class _AutomationBondListWidgetState extends State<AutomationBondListWidget> {
  String _filterType = 'all'; // 'all', 'active', 'inactive'
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final containerBg = isDark ? AppTheme.darkCard : AppTheme.white;
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header s filtrami
        Container(
          decoration: BoxDecoration(
            color: containerBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: AppTheme.cardShadow,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.teal,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Zoznam automatizácií',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: isDark ? Colors.white : null,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Consumer<AutomationProvider>(
                            builder: (context, provider, child) {
                              return Text(
                                'Celkom: ${provider.bonds.length} • Aktívne: ${provider.activeBondsCount}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: isDark ? Colors.white70 : null,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Filter chips
                _buildFilterChips(isDark),
                const SizedBox(height: 16),
                // Search field
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Vyhľadať úrad...',
                    prefixIcon: Icon(
                      Icons.search,
                      size: 20,
                      color: isDark ? Colors.white70 : Colors.grey[600],
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        size: 20,
                        color: isDark ? Colors.white70 : Colors.grey[600],
                      ),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                    )
                        : null,
                    filled: true,
                    fillColor: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Zoznam bonds
        Expanded(
          child: Consumer<AutomationProvider>(
            builder: (context, provider, child) {
              return _buildBondsList(provider, isDark);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips(bool isDark) {
    return Row(
      children: [
        _buildFilterChip(
          label: 'Všetky',
          value: 'all',
          icon: Icons.list,
          isDark: isDark,
        ),
        const SizedBox(width: 8),
        _buildFilterChip(
          label: 'Aktívne',
          value: 'active',
          icon: Icons.check_circle,
          isDark: isDark,
        ),
        const SizedBox(width: 8),
        _buildFilterChip(
          label: 'Neaktívne',
          value: 'inactive',
          icon: Icons.cancel,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String value,
    required IconData icon,
    required bool isDark,
  }) {
    final isSelected = _filterType == value;
    final selectedBg = isDark ? Colors.teal.withOpacity(0.2) : Colors.teal.shade50;
    final selectedBorder = Colors.teal.shade400;

    return InkWell(
      onTap: () {
        setState(() {
          _filterType = value;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? selectedBg : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? selectedBorder : (isDark ? Colors.white.withOpacity(0.2) : AppTheme.borderColor),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.teal.shade600 : (isDark ? Colors.white70 : AppTheme.textMedium),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.teal.shade700 : (isDark ? Colors.white : AppTheme.textDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBondsList(AutomationProvider provider, bool isDark) {
    final containerBg = isDark ? AppTheme.darkCard : AppTheme.white;
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor;

    // Loading state
    if (provider.isLoading && provider.bonds.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: containerBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.teal),
              SizedBox(height: 16),
              Text('Načítavam automatizácie...'),
            ],
          ),
        ),
      );
    }

    // Error state
    if (provider.error != null && provider.bonds.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: containerBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Chyba pri načítaní',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  provider.error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : AppTheme.textMedium,
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => provider.loadBonds(),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Skúsiť znova'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Filter bonds
    List<AutomationBond> filteredBonds;
    switch (_filterType) {
      case 'active':
        filteredBonds = provider.activeBonds;
        break;
      case 'inactive':
        filteredBonds = provider.inactiveBonds;
        break;
      default:
        filteredBonds = provider.bonds;
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      filteredBonds = filteredBonds.where((bond) {
        final name = (bond.applicationName ?? '').toLowerCase();
        final department = (bond.applicationDepartment ?? '').toLowerCase();
        final city = (bond.applicationCity ?? '').toLowerCase();
        final id = bond.applicationId.toString();

        return name.contains(_searchQuery) ||
            department.contains(_searchQuery) ||
            city.contains(_searchQuery) ||
            id.contains(_searchQuery);
      }).toList();
    }

    // Empty state
    if (filteredBonds.isEmpty) {
      final emptyIconBg = isDark ? AppTheme.darkSurface : AppTheme.lightGray;

      return Container(
        decoration: BoxDecoration(
          color: containerBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: emptyIconBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    _searchQuery.isNotEmpty ? Icons.search_off : Icons.inbox_outlined,
                    size: 40,
                    color: isDark ? Colors.white38 : AppTheme.textLight,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isNotEmpty
                      ? 'Žiadne výsledky'
                      : 'Žiadne automatizácie',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  _searchQuery.isNotEmpty
                      ? 'Skúste iné hľadané slovo'
                      : 'Vytvorte novú automatizáciu pomocou tlačidla hore',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white70 : null,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // List of bonds
    return Container(
      decoration: BoxDecoration(
        color: containerBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: filteredBonds.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: isDark ? Colors.white10 : Colors.grey[200],
        ),
        itemBuilder: (context, index) {
          final bond = filteredBonds[index];
          final isSelected = provider.selectedBond?.id == bond.id;

          return _buildBondListItem(bond, isSelected, isDark);
        },
      ),
    );
  }

  Widget _buildBondListItem(AutomationBond bond, bool isSelected, bool isDark) {
    final selectedBg = isDark ? Colors.teal.withOpacity(0.15) : Colors.teal.withOpacity(0.08);
    final selectedIconBg = isDark ? Colors.teal.withOpacity(0.25) : Colors.teal.withOpacity(0.15);
    final defaultIconBg = isDark ? AppTheme.darkSurface : AppTheme.lightGray;
    final textColor = isSelected ? Colors.teal.shade600 : (isDark ? Colors.white : AppTheme.textDark);
    final iconColor = isSelected ? Colors.teal.shade600 : (isDark ? Colors.white70 : AppTheme.textMedium);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          context.read<AutomationProvider>().selectBond(bond);
          widget.onBondSelected(bond);
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? selectedBg : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected ? selectedIconBg : defaultIconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.business,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Application name
                    Text(
                      bond.applicationName ?? 'Úrad #${bond.applicationId}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Department
                    if (bond.applicationDepartment != null)
                      Row(
                        children: [
                          Icon(
                            Icons.category_outlined,
                            size: 12,
                            color: AppTheme.textLight,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              bond.applicationDepartment!,
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 4),
                    // Conditions summary
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: AppTheme.textLight,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            bond.districtsSummary,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Status & Count
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Active status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: bond.active
                          ? Colors.green.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          bond.active ? Icons.check_circle : Icons.cancel,
                          size: 12,
                          color: bond.active ? Colors.green.shade600 : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          bond.active ? 'Aktívne' : 'Neaktívne',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: bond.active ? Colors.green.shade700 : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Conditions count
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.rule,
                          size: 12,
                          color: Colors.blue.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${bond.conditionsCount}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (isSelected) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}