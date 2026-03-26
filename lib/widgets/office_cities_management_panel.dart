import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vyjadrenia/utils/permission_helper.dart';
import '../models/application_edit_model.dart';
import '../models/city_model.dart';
import '../providers/office_cities_provider.dart';
import '../widgets/add_city_to_office_dialog.dart';
import '../utils/app_theme.dart';

class OfficeCitiesManagementPanel extends StatefulWidget {
  final ApplicationEdit office;

  const OfficeCitiesManagementPanel({
    Key? key,
    required this.office,
  }) : super(key: key);

  @override
  State<OfficeCitiesManagementPanel> createState() =>
      _OfficeCitiesManagementPanelState();
}

class _OfficeCitiesManagementPanelState
    extends State<OfficeCitiesManagementPanel> {
  final TextEditingController _searchController = TextEditingController();
  List<City> _filteredCities = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterCities);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCities() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCities = [];
      } else {
        final provider = context.read<OfficeCitiesProvider>();
        _filteredCities = provider.cities
            .where((city) =>
        city.name.toLowerCase().contains(query) ||
            city.district.toLowerCase().contains(query) ||
            city.region.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // ✅ 1. Zisti tému
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ✅ 2. Dynamické farby
    final containerBg = isDark ? AppTheme.darkCard : AppTheme.white;
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor;

    return Container(
      decoration: BoxDecoration(
        color: containerBg, // ✅
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1), // ✅
        boxShadow: [
          BoxShadow(
            color: AppTheme.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          Divider(height: 1, color: borderColor), // ✅
          Expanded(child: _buildContent(context)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade400, Colors.purple.shade600],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.business_rounded,
              color: AppTheme.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.office.name,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.category_outlined,
                      size: 14,
                      color: AppTheme.textLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.office.department,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: AppTheme.textLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.office.city,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Consumer<OfficeCitiesProvider>(
            builder: (context, provider, child) {
              return ElevatedButton.icon(
                onPressed: provider.isLoading
                    ? null
                    : () => _showAddCityDialog(context),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Pridať mesto'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<OfficeCitiesProvider>(
      builder: (context, provider, child) {
        // Loading State
        if (provider.isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: Colors.purple),
                const SizedBox(height: 16),
                Text(
                  'Načítavam mestá...',
                  style: TextStyle(color: isDark ? Colors.white70 : null), // ✅
                ),
              ],
            ),
          );
        }

        // Error State
        if (provider.error != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2C1515) : Colors.red.shade50, // ✅
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.error_outline,
                      size: 32,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nastala chyba',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textMedium),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () =>
                        provider.loadCitiesForOffice(widget.office.id),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Skúsiť znova'),
                  ),
                ],
              ),
            ),
          );
        }

        // Empty State
        if (provider.cities.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.purple.withOpacity(0.1) : Colors.purple.shade50, // ✅
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      Icons.location_city_outlined,
                      size: 50,
                      color: Colors.purple.shade300,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Žiadne priradené mestá',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tento úrad nemá zatiaľ žiadne priradené mestá.\nKliknite na "Pridať mesto" pre pridanie.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showAddCityDialog(context),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Pridať prvé mesto'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Initialize filtered cities on first build
        if (_filteredCities.isEmpty &&
            provider.cities.isNotEmpty &&
            _searchController.text.isEmpty) {
          _filteredCities = provider.cities;
        }

        // Determine which cities to display
        final citiesToDisplay = _searchController.text.isEmpty
            ? provider.cities
            : _filteredCities;

        // Cities List
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.05),
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor, // ✅
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_city_rounded,
                    size: 18,
                    color: Colors.purple,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Priradené mestá: ${provider.cities.length}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppTheme.textDark, // ✅
                    ),
                  ),
                  if (_searchController.text.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Text(
                        'Nájdených: ${_filteredCities.length}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Search Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Vyhľadať mestá podľa názvu, okresu alebo kraja...',
                  prefixIcon: const Icon(Icons.search, color: Colors.purple),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                    },
                  )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppTheme.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppTheme.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.purple, width: 2),
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            // Cities List
            Expanded(
              child: citiesToDisplay.isEmpty
                  ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 48,
                        color: isDark ? Colors.grey.shade600 : Colors.grey.shade400, // ✅
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Žiadne mestá sa nenašli',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Skúste zmeniť vyhľadávaný text',
                        style: TextStyle(color: AppTheme.textMedium),
                      ),
                    ],
                  ),
                ),
              )
                  : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: citiesToDisplay.length,
                separatorBuilder: (context, index) =>
                const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final city = citiesToDisplay[index];
                  return _buildCityCard(context, city, provider);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCityCard(
      BuildContext context,
      City city,
      OfficeCitiesProvider provider,
      ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppTheme.darkSurface : AppTheme.white;
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor;
    final textColor = isDark ? Colors.white : AppTheme.textDark;

    return Container(
      decoration: BoxDecoration(
        color: cardBg, // ✅
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1), // ✅
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDark ? Colors.purple.withOpacity(0.2) : Colors.purple.withOpacity(0.1), // ✅
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.location_city,
                color: Colors.purple,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // City Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    city.name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textColor, // ✅
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.map_outlined,
                        size: 14,
                        color: AppTheme.textLight,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Okres: ${city.district}',
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.public,
                        size: 14,
                        color: AppTheme.textLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Kraj: ${city.region}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Delete Button
            OutlinedButton.icon(
              onPressed: () => _confirmRemoveCity(context, city, provider),
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Odstrániť'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: BorderSide(color: Colors.red.shade300),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddCityDialog(BuildContext context) async {
    final officeCitiesProvider = context.read<OfficeCitiesProvider>();
    final result = await showDialog(
      context: context,
      builder: (context) => ChangeNotifierProvider.value(
        value: officeCitiesProvider,
        child: AddCityToOfficeDialog(office: widget.office),
      ),
    );

    if (result == true) {
      // Refresh handled by provider
    }
  }

  Future<void> _confirmRemoveCity(
      BuildContext context,
      City city,
      OfficeCitiesProvider provider,
      ) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Dialog Colors
    final dialogBg = isDark ? AppTheme.darkBackground : Colors.white;
    final infoBg = isDark ? const Color(0xFF2C1515) : Colors.red.withOpacity(0.05);
    final infoBorder = isDark ? Colors.red.withOpacity(0.3) : Colors.red.withOpacity(0.2);
    final textColor = isDark ? Colors.white : Colors.black;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: dialogBg, // ✅
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            const SizedBox(width: 12),
            Text('Potvrdenie odstránenia', style: TextStyle(color: textColor)), // ✅
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Naozaj chcete odstrániť toto prepojenie?',
              style: TextStyle(fontWeight: FontWeight.w600, color: textColor), // ✅
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: infoBg, // ✅
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: infoBorder), // ✅
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mesto: ${city.name}',
                    style: TextStyle(fontWeight: FontWeight.w600, color: textColor), // ✅
                  ),
                  const SizedBox(height: 4),
                  Text('Úrad: ${widget.office.name}', style: TextStyle(color: textColor)), // ✅
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Toto odstráni len prepojenie medzi mestom a úradom. Samotné mesto zostane v databáze.',
              style: TextStyle(fontSize: 12, color: AppTheme.textMedium),
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Zrušiť'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Odstrániť'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await provider.removeCityFromOffice(widget.office.id, city.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Mesto "${city.name}" bolo odstránené z úradu "${widget.office.name}"',
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      } catch (e) {
        await context.showPermissionErrorIfNeeded(e, actionName: "odstraňovanie mesta z úradu");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Chyba: ${e.toString().replaceAll("Exception: ", "")}',
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      }
    }
  }
}
