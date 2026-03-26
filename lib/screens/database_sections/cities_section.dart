// ========================================
// CITIES SECTION - RESPONSÍVNY
// ========================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/city_provider.dart';
import '../../widgets/city_search_widget.dart';
import '../../widgets/city_edit_panel.dart';
import '../../widgets/city_create_dialog.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';

class CitiesSection extends StatefulWidget {
  const CitiesSection({Key? key}) : super(key: key);

  @override
  State<CitiesSection> createState() => _CitiesSectionState();
}

class _CitiesSectionState extends State<CitiesSection> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768; // ✅ Pridané

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChangeNotifierProvider(
      create: (_) => CityProvider(),
      child: Scaffold(
        backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightGray,
        body: Column(
          children: [
            _buildHeader(context, isMobile), // ✅ Pridaný parameter
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 12 : 24), // ✅ Menší padding
                child: isMobile
                    ? _buildMobileLayout() // ✅ Nový mobile layout
                    : _buildDesktopLayout(), // ✅ Pôvodný desktop layout
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ NOVÝ: Mobile layout - Column namiesto Row
  Widget _buildMobileLayout() {
    return Consumer<CityProvider>(
      builder: (context, cityProvider, child) {
        // Ak je vybrané mesto, zobraz len edit panel
        if (cityProvider.selectedCities.isNotEmpty) {
          return CityEditPanel(
            city: cityProvider.selectedCities.first,
            onCancel: () {
              cityProvider.clearSelection();
            },
            onSaved: () {
              _refreshSearch();
            },
            onDeleted: () {
              _refreshSearch();
            },
          );
        }

        // Ak nie je vybrané, zobraz len search
        return CitySearchWidget(
          onCitySelected: (city) {},
        );
      },
    );
  }

  // ✅ Desktop layout - pôvodný Row
  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ľavá strana - Search & Results
        Expanded(
          flex: 4,
          child: CitySearchWidget(
            onCitySelected: (city) {},
          ),
        ),
        const SizedBox(width: 24),

        // Pravá strana - Edit Panel
        Expanded(
          flex: 6,
          child: Consumer<CityProvider>(
            builder: (context, cityProvider, child) {
              if (cityProvider.selectedCities.isEmpty) {
                return _buildEmptyState(context, false);
              }

              return CityEditPanel(
                city: cityProvider.selectedCities.first,
                onCancel: () {
                  cityProvider.clearSelection();
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
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) { // ✅ Pridaný parameter
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.darkSurface : AppTheme.white;
    final border = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 32, // ✅ Menší padding
        vertical: isMobile ? 12 : 24,
      ),
      decoration: BoxDecoration(
        color: bg,
        border: Border(
          bottom: BorderSide(color: border, width: 1),
        ),
      ),
      child: isMobile
          ? _buildMobileHeader(context) // ✅ Nový mobile header
          : _buildDesktopHeader(context), // ✅ Pôvodný desktop header
    );
  }

  // ✅ NOVÝ: Mobile header - zjednodušený
  Widget _buildMobileHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        // Back button
        IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_rounded, size: 20),
          tooltip: 'Späť',
          padding: const EdgeInsets.all(8),
        ),
        const SizedBox(width: 8),

        // Title
        Expanded(
          child: Text(
            'Mestá a obce',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: isDark ? Colors.white : null,
              fontSize: 18,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // Add New City Button
        ElevatedButton.icon(
          onPressed: _showCreateCityDialog,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text(
            'Nové',
            style: TextStyle(fontSize: 13),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }

  // ✅ Desktop header - pôvodný
  Widget _buildDesktopHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
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
                    colors: [Colors.blue.shade400, Colors.blue.shade600],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.location_city_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mestá a obce',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: isDark ? Colors.white : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Správa miest a obcí v systéme',
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
        Consumer<CityProvider>(
          builder: (context, cityProvider, child) {
            return Row(
              children: [
                _buildStatChip(
                  context: context,
                  icon: Icons.search,
                  label: 'Nájdené',
                  value: '${cityProvider.cities.length}',
                  color: Colors.blue,
                ),
                const SizedBox(width: 12),
                if (cityProvider.selectedCities.isNotEmpty)
                  _buildStatChip(
                    context: context,
                    icon: Icons.edit,
                    label: 'Vybrané',
                    value: '${cityProvider.selectedCities.length}',
                    color: Colors.green,
                  ),
              ],
            );
          },
        ),
        const SizedBox(width: 16),

        // Add New City Button
        ElevatedButton.icon(
          onPressed: _showCreateCityDialog,
          icon: const Icon(Icons.add_rounded, size: 20),
          label: const Text('Nové mesto'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ],
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

  Widget _buildEmptyState(BuildContext context, bool isMobile) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.darkSurface : AppTheme.white;
    final border = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor;
    final gradientColors = isDark
        ? [const Color(0xFF0D47A1), const Color(0xFF1565C0)]
        : [Colors.blue.shade50, Colors.blue.shade100];

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
              width: isMobile ? 80 : 120, // ✅
              height: isMobile ? 80 : 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                ),
                borderRadius: BorderRadius.circular(isMobile ? 20 : 30), // ✅
              ),
              child: Icon(
                Icons.touch_app_rounded,
                size: isMobile ? 40 : 60, // ✅
                color: Colors.blue.shade400,
              ),
            ),
            SizedBox(height: isMobile ? 16 : 24), // ✅
            Text(
              'Vyberte mesto',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: isDark ? Colors.white : null,
                fontSize: isMobile ? 18 : null, // ✅
              ),
            ),
            SizedBox(height: isMobile ? 6 : 8), // ✅
            Text(
              'Kliknite na mesto zo zoznamu\npre zobrazenie a úpravu údajov',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white70 : null,
                fontSize: isMobile ? 13 : null, // ✅
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateCityDialog() async {
    final result = await showDialog(
      context: context,
      builder: (context) => const CityCreateDialog(),
    );

    if (result == true) {
      _refreshSearch();
    }
  }

  void _refreshSearch() {
    final cityProvider = context.read<CityProvider>();
    if (cityProvider.cities.isNotEmpty) {
      cityProvider.searchCities();
    }
  }
}
