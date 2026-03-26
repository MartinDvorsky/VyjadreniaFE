import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/city_model.dart';
import '../providers/city_provider.dart';
import '../utils/app_theme.dart';

class CitySearchWidget extends StatefulWidget {
  final Function(City) onCitySelected;

  const CitySearchWidget({
    Key? key,
    required this.onCitySelected,
  }) : super(key: key);

  @override
  State<CitySearchWidget> createState() => _CitySearchWidgetState();
}

class _CitySearchWidgetState extends State<CitySearchWidget> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _regionController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onSearchChanged);
    _districtController.addListener(_onSearchChanged);
    _regionController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _nameController.dispose();
    _districtController.dispose();
    _regionController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _performSearch();
    });
  }

  void _performSearch() {
    final cityProvider = context.read<CityProvider>();

    if (_nameController.text.trim().isEmpty &&
        _districtController.text.trim().isEmpty &&
        _regionController.text.trim().isEmpty) {
      cityProvider.clearSearch();
      return;
    }

    cityProvider.searchCities(
      name: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
      district: _districtController.text.trim().isEmpty ? null : _districtController.text.trim(),
      region: _regionController.text.trim().isEmpty ? null : _regionController.text.trim(),
    );
  }

  void _clearSearch() {
    _nameController.clear();
    _districtController.clear();
    _regionController.clear();
    context.read<CityProvider>().clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    final containerBg = isDark ? AppTheme.darkCard : AppTheme.white;
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor;

    return Consumer<CityProvider>(
      builder: (context, cityProvider, child) {
        return Column(
          children: [
            // ✅ Search Card - SizedBox s fixnou výškou (nie Expanded)
            SizedBox(
              child: Container(
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
                  padding: EdgeInsets.all(isMobile ? 16.0 : 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min, // ✅ KĽÚČOVÉ!
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryRed.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.search,
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
                                  'Vyhľadávanie mesta',
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: isDark ? Colors.white : null,
                                    fontSize: isMobile ? 16 : null,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Výsledky sa aktualizujú automaticky',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: isDark ? Colors.white70 : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_nameController.text.isNotEmpty ||
                              _districtController.text.isNotEmpty ||
                              _regionController.text.isNotEmpty)
                            IconButton(
                              onPressed: _clearSearch,
                              icon: const Icon(Icons.clear_all),
                              tooltip: 'Vyčistiť všetko',
                              color: isDark ? Colors.white70 : AppTheme.textMedium,
                            ),
                        ],
                      ),
                      SizedBox(height: isMobile ? 16 : 20),
                      _buildSearchFields(isDark),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: isMobile ? 12 : 16),

            // ✅ Results - Expanded (zaberie zvyšný priestor)
            Expanded(
              child: _buildResultsSimple(cityProvider, isDark, isMobile),
            ),
          ],
        );
      },
    );
  }
  Widget _buildResultsSimple(CityProvider cityProvider, bool isDark, bool isMobile) {
    final containerBg = isDark ? AppTheme.darkCard : AppTheme.white;
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor;

    // Loading
    if (cityProvider.isLoading) {
      return Container(
        decoration: BoxDecoration(
          color: containerBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryRed),
        ),
      );
    }

    // Error
    if (cityProvider.error != null && cityProvider.cities.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: containerBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Center(
          child: Text(cityProvider.error!, style: TextStyle(color: Colors.red)),
        ),
      );
    }

    // Empty
    if (cityProvider.cities.isEmpty) {
      final emptyIconBg = isDark ? AppTheme.darkSurface : AppTheme.lightGray;
      return Container(
        decoration: BoxDecoration(
          color: containerBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: emptyIconBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.search,
                  size: 40,
                  color: isDark ? Colors.white38 : AppTheme.textLight,
                ),
              ),
              const SizedBox(height: 16),
              Text('Začnite písať', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'Zadajte názov mesta, okres alebo kraj\npre vyhľadávanie',
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

    // ✅ Results with cities - JEDNODUCHÝ Container + ListView
    final headerBg = isDark ? Colors.red.withOpacity(0.1) : AppTheme.primaryRed.withOpacity(0.05);

    return Container(
      decoration: BoxDecoration(
        color: containerBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      // ✅ Priamo ListView, BEZ Column a Expanded!
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: cityProvider.cities.length + 1, // +1 pre header
        itemBuilder: (context, index) {
          // Header ako prvý item
          if (index == 0) {
            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 16,
                vertical: isMobile ? 12 : 14,
              ),
              decoration: BoxDecoration(
                color: headerBg,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline, size: 18, color: AppTheme.primaryRed),
                  const SizedBox(width: 8),
                  Text(
                    'Nájdené výsledky: ${cityProvider.cities.length}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppTheme.textDark,
                      fontSize: isMobile ? 14 : null,
                    ),
                  ),
                ],
              ),
            );
          }

          final cityIndex = index - 1;
          final city = cityProvider.cities[cityIndex];
          final isSelected = cityProvider.selectedCities.any((c) => c.id == city.id);

          final selectedBg = isDark
              ? AppTheme.primaryRed.withOpacity(0.2)
              : AppTheme.primaryRed.withOpacity(0.08);
          final selectedIconBg = isDark
              ? AppTheme.primaryRed.withOpacity(0.3)
              : AppTheme.primaryRed.withOpacity(0.15);
          final defaultIconBg = isDark ? AppTheme.darkSurface : AppTheme.lightGray;
          final textColor = isSelected
              ? AppTheme.primaryRed
              : (isDark ? Colors.white : AppTheme.textDark);
          final iconColor = isSelected
              ? AppTheme.primaryRed
              : (isDark ? Colors.white70 : AppTheme.textMedium);

          return InkWell(
            onTap: () {
              cityProvider.selectCity(city);
              widget.onCitySelected(city);
            },
            child: Container(
              padding: EdgeInsets.all(isMobile ? 16 : 12),
              decoration: BoxDecoration(
                color: isSelected ? selectedBg : Colors.transparent,
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? Colors.white10 : Colors.grey[200]!,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: isMobile ? 48 : 44,
                    height: isMobile ? 48 : 44,
                    decoration: BoxDecoration(
                      color: isSelected ? selectedIconBg : defaultIconBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      city.isCity ? Icons.location_city : Icons.home,
                      color: iconColor,
                      size: isMobile ? 24 : 22,
                    ),
                  ),
                  SizedBox(width: isMobile ? 14 : 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          city.name,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: textColor,
                            fontSize: isMobile ? 17 : 15,
                          ),
                        ),
                        SizedBox(height: isMobile ? 6 : 4),
                        if (isMobile)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.map_outlined, size: 14, color: AppTheme.textLight),
                                  const SizedBox(width: 4),
                                  Text('Okres: ${city.district}',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 13)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.public, size: 14, color: AppTheme.textLight),
                                  const SizedBox(width: 4),
                                  Text('Kraj: ${city.region}',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 13)),
                                ],
                              ),
                            ],
                          )
                        else
                          Row(
                            children: [
                              Icon(Icons.map_outlined, size: 12, color: AppTheme.textLight),
                              const SizedBox(width: 4),
                              Text('Okres: ${city.district}', style: Theme.of(context).textTheme.bodySmall),
                              const SizedBox(width: 12),
                              Icon(Icons.public, size: 12, color: AppTheme.textLight),
                              const SizedBox(width: 4),
                              Text('Kraj: ${city.region}', style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Container(
                      padding: EdgeInsets.all(isMobile ? 10 : 8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryRed,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(Icons.check, color: AppTheme.white, size: isMobile ? 20 : 18),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }



  Widget _buildSearchFields(bool isDark) {
    final iconColor = isDark ? Colors.white70 : Colors.grey[600];
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Column(
      children: [
        // Názov mesta - vždy na celú šírku
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Názov mesta',
            hintText: 'Napr. Prešov, Košice...',
            prefixIcon: Icon(Icons.location_city, size: 20, color: iconColor),
            suffixIcon: _nameController.text.isNotEmpty
                ? IconButton(
              icon: Icon(Icons.clear, size: 18, color: iconColor),
              onPressed: () => _nameController.clear(),
            )
                : null,
          ),
        ),
        const SizedBox(height: 12),

        // 📱 Okres a Kraj - responsive layout
        if (isMobile)
        // Mobile: stĺpcový layout (každý input na celú šírku)
          Column(
            children: [
              TextField(
                controller: _districtController,
                decoration: InputDecoration(
                  labelText: 'Okres',
                  hintText: 'Napr. PO',
                  prefixIcon: Icon(Icons.map, size: 20, color: iconColor),
                  suffixIcon: _districtController.text.isNotEmpty
                      ? IconButton(
                    icon: Icon(Icons.clear, size: 18, color: iconColor),
                    onPressed: () => _districtController.clear(),
                  )
                      : null,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _regionController,
                decoration: InputDecoration(
                  labelText: 'Kraj',
                  hintText: 'Napr. PO',
                  prefixIcon: Icon(Icons.public, size: 20, color: iconColor),
                  suffixIcon: _regionController.text.isNotEmpty
                      ? IconButton(
                    icon: Icon(Icons.clear, size: 18, color: iconColor),
                    onPressed: () => _regionController.clear(),
                  )
                      : null,
                ),
              ),
            ],
          )
        else
        // Desktop: riadkový layout (pôvodný)
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _districtController,
                  decoration: InputDecoration(
                    labelText: 'Okres',
                    hintText: 'Napr. PO',
                    prefixIcon: Icon(Icons.map, size: 20, color: iconColor),
                    suffixIcon: _districtController.text.isNotEmpty
                        ? IconButton(
                      icon: Icon(Icons.clear, size: 18, color: iconColor),
                      onPressed: () => _districtController.clear(),
                    )
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _regionController,
                  decoration: InputDecoration(
                    labelText: 'Kraj',
                    hintText: 'Napr. PO',
                    prefixIcon: Icon(Icons.public, size: 20, color: iconColor),
                    suffixIcon: _regionController.text.isNotEmpty
                        ? IconButton(
                      icon: Icon(Icons.clear, size: 18, color: iconColor),
                      onPressed: () => _regionController.clear(),
                    )
                        : null,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }


  Widget _buildResults(CityProvider cityProvider, bool isDark, bool isMobile) {
    final containerBg = isDark ? AppTheme.darkCard : AppTheme.white;
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor;

    // Loading State
    if (cityProvider.isLoading) {
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
              CircularProgressIndicator(color: AppTheme.primaryRed),
              SizedBox(height: 16),
              Text('Načítavam...'),
            ],
          ),
        ),
      );
    }

    // Error State
    if (cityProvider.error != null && cityProvider.cities.isEmpty) {
      final errorBg = isDark ? const Color(0xFF2C1515) : Colors.red.shade50;
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: errorBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.error_outline, size: 32, color: Colors.red),
                ),
                const SizedBox(height: 16),
                Text('Nastala chyba', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  cityProvider.error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: isDark ? Colors.white70 : AppTheme.textMedium),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Empty State
    if (cityProvider.cities.isEmpty) {
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: emptyIconBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.search,
                    size: 40,
                    color: isDark ? Colors.white38 : AppTheme.textLight,
                  ),
                ),
                const SizedBox(height: 16),
                Text('Začnite písať', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  'Zadajte názov mesta, okres alebo kraj\npre vyhľadávanie',
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

    // ✅ Results List - BEZ vnútorného Expanded!
    final headerBg = isDark
        ? Colors.red.withOpacity(0.1)
        : AppTheme.primaryRed.withOpacity(0.05);

    return Container(
      decoration: BoxDecoration(
        color: containerBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        children: [
          // Results Header
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 16,
              vertical: isMobile ? 10 : 12,
            ),
            decoration: BoxDecoration(
              color: headerBg,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, size: 18, color: AppTheme.primaryRed),
                const SizedBox(width: 8),
                Text(
                  'Nájdené výsledky: ${cityProvider.cities.length}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppTheme.textDark,
                    fontSize: isMobile ? 14 : null,
                  ),
                ),
              ],
            ),
          ),

          // ✅ Cities List - Expanded (toto funguje lebo je vnútri Column)
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.all(isMobile ? 4 : 8),
              itemCount: cityProvider.cities.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: isDark ? Colors.white10 : Colors.grey[200],
              ),
              itemBuilder: (context, index) {
                final city = cityProvider.cities[index];
                final isSelected = cityProvider.selectedCities.any((c) => c.id == city.id);

                final selectedBg = isDark
                    ? AppTheme.primaryRed.withOpacity(0.2)
                    : AppTheme.primaryRed.withOpacity(0.08);
                final selectedIconBg = isDark
                    ? AppTheme.primaryRed.withOpacity(0.3)
                    : AppTheme.primaryRed.withOpacity(0.15);
                final defaultIconBg = isDark ? AppTheme.darkSurface : AppTheme.lightGray;
                final textColor = isSelected
                    ? AppTheme.primaryRed
                    : (isDark ? Colors.white : AppTheme.textDark);
                final iconColor = isSelected
                    ? AppTheme.primaryRed
                    : (isDark ? Colors.white70 : AppTheme.textMedium);

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      cityProvider.selectCity(city);
                      widget.onCitySelected(city);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: isMobile ? 14 : 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? selectedBg : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          // Icon
                          Container(
                            width: isMobile ? 44 : 40,
                            height: isMobile ? 44 : 40,
                            decoration: BoxDecoration(
                              color: isSelected ? selectedIconBg : defaultIconBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              city.isCity ? Icons.location_city : Icons.home,
                              color: iconColor,
                              size: isMobile ? 22 : 20,
                            ),
                          ),
                          SizedBox(width: isMobile ? 12 : 12),

                          // City Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  city.name,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                    color: textColor,
                                    fontSize: isMobile ? 16 : 15,
                                  ),
                                ),
                                SizedBox(height: isMobile ? 6 : 4),

                                // Okres a Kraj
                                if (isMobile)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.map_outlined, size: 14, color: AppTheme.textLight),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Okres: ${city.district}',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 13),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.public, size: 14, color: AppTheme.textLight),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Kraj: ${city.region}',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 13),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                else
                                  Row(
                                    children: [
                                      Icon(Icons.map_outlined, size: 12, color: AppTheme.textLight),
                                      const SizedBox(width: 4),
                                      Text('Okres: ${city.district}', style: Theme.of(context).textTheme.bodySmall),
                                      const SizedBox(width: 12),
                                      Icon(Icons.public, size: 12, color: AppTheme.textLight),
                                      const SizedBox(width: 4),
                                      Text('Kraj: ${city.region}', style: Theme.of(context).textTheme.bodySmall),
                                    ],
                                  ),
                              ],
                            ),
                          ),

                          // Selected Indicator
                          if (isSelected)
                            Container(
                              padding: EdgeInsets.all(isMobile ? 8 : 6),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryRed,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.check,
                                color: AppTheme.white,
                                size: isMobile ? 18 : 16,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }


}
