import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/application_edit_model.dart';
import '../providers/application_edit_provider.dart';
import '../utils/app_theme.dart';

class ApplicationSearchWidget extends StatefulWidget {
  final Function(ApplicationEdit) onApplicationSelected;

  const ApplicationSearchWidget({
    Key? key,
    required this.onApplicationSelected,
  }) : super(key: key);

  @override
  State<ApplicationSearchWidget> createState() => _ApplicationSearchWidgetState();
}

class _ApplicationSearchWidgetState extends State<ApplicationSearchWidget> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onSearchChanged);
    _departmentController.addListener(_onSearchChanged);
    _cityController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _nameController.dispose();
    _departmentController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch();
    });
  }

  void _performSearch() {
    final provider = context.read<ApplicationEditProvider>();
    final name = _nameController.text.trim();
    final department = _departmentController.text.trim();
    final city = _cityController.text.trim();

    if (name.isEmpty && department.isEmpty && city.isEmpty) {
      provider.clearSearch();
      return;
    }

    provider.searchApplications(
      name: name.isEmpty ? null : name,
      department: department.isEmpty ? null : department,
      city: city.isEmpty ? null : city,
    );
  }

  void _clearSearch() {
    _nameController.clear();
    _departmentController.clear();
    _cityController.clear();
    context.read<ApplicationEditProvider>().clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ 1. Zisti tému
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ✅ 2. Priprav dynamické farby
    final cardBg = isDark ? AppTheme.darkCard : AppTheme.white;
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor;
    final primaryText = isDark ? Colors.white : AppTheme.textDark;
    final secondaryText = isDark ? Colors.white70 : AppTheme.textMedium;
    final iconColor = isDark ? Colors.white70 : AppTheme.textMedium;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Card
        Container(
          decoration: BoxDecoration(
            color: cardBg, // ✅
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1), // ✅
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
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.search,
                        color: Colors.green,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vyhľadávanie úradu',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: primaryText, // ✅
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Výsledky sa aktualizujú automaticky',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: secondaryText, // ✅
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_nameController.text.isNotEmpty ||
                        _departmentController.text.isNotEmpty ||
                        _cityController.text.isNotEmpty)
                      IconButton(
                        onPressed: _clearSearch,
                        icon: const Icon(Icons.clear_all),
                        tooltip: 'Vyčistiť všetko',
                        color: secondaryText, // ✅
                      ),
                  ],
                ),
                const SizedBox(height: 20),

                // Search Fields
                // TextFieldy zvyčajne dedia farby z Theme, ale ikony treba ošetriť ak nie sú v inputDecorationTheme
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Názov úradu',
                    hintText: 'Napr. Krajský stavebný úrad...',
                    prefixIcon: Icon(Icons.business, size: 20, color: iconColor), // ✅
                    suffixIcon: _nameController.text.isNotEmpty
                        ? IconButton(
                      icon: Icon(Icons.clear, size: 18, color: iconColor), // ✅
                      onPressed: () => _nameController.clear(),
                    )
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _departmentController,
                  decoration: InputDecoration(
                    labelText: 'Oddelenie',
                    hintText: 'Napr. Stavebné oddelenie...',
                    prefixIcon: Icon(Icons.category, size: 20, color: iconColor), // ✅
                    suffixIcon: _departmentController.text.isNotEmpty
                        ? IconButton(
                      icon: Icon(Icons.clear, size: 18, color: iconColor), // ✅
                      onPressed: () => _departmentController.clear(),
                    )
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    labelText: 'Mesto',
                    hintText: 'Napr. Košice...',
                    prefixIcon: Icon(Icons.location_city, size: 20, color: iconColor), // ✅
                    suffixIcon: _cityController.text.isNotEmpty
                        ? IconButton(
                      icon: Icon(Icons.clear, size: 18, color: iconColor), // ✅
                      onPressed: () => _cityController.clear(),
                    )
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Results Section
        Expanded(
          child: Consumer<ApplicationEditProvider>(
            builder: (context, provider, child) {
              // Loading State
              if (provider.isLoading) {
                return Container(
                  decoration: BoxDecoration(
                    color: cardBg, // ✅
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor, width: 1), // ✅
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(color: Colors.green),
                        const SizedBox(height: 16),
                        Text(
                          'Načítavam...',
                          style: TextStyle(color: secondaryText), // ✅
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Error State
              if (provider.error != null && provider.applications.isEmpty) {
                // Pre error state použijeme jemnejšie červené v dark mode
                final errorBg = isDark ? const Color(0xFF2C1515) : Colors.red.shade50;
                final errorIconBg = isDark ? Colors.red.withOpacity(0.2) : Colors.red.shade50;
                final errorBorder = isDark ? Colors.red.withOpacity(0.3) : Colors.red.shade200;

                return Container(
                  decoration: BoxDecoration(
                    color: cardBg, // ✅
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: errorBorder, width: 1), // ✅
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: errorIconBg, // ✅
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
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: primaryText, // ✅
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            provider.error!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: secondaryText), // ✅
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: _performSearch,
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text('Skúsiť znova'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              // Empty State
              if (provider.applications.isEmpty) {
                final emptyIconBg = isDark ? AppTheme.darkBackground : AppTheme.lightGray;

                return Container(
                  decoration: BoxDecoration(
                    color: cardBg, // ✅
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor, width: 1), // ✅
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
                              color: emptyIconBg, // ✅
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.search,
                              size: 40,
                              color: secondaryText, // ✅
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Začnite písať',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: primaryText, // ✅
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Zadajte názov úradu, oddelenie alebo mesto\npre vyhľadávanie',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: secondaryText, // ✅
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              // Results List
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Results Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.05),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      border: Border.all(color: borderColor, width: 1), // ✅
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          size: 18,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Nájdené výsledky: ${provider.applications.length}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: primaryText, // ✅
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Applications List
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: cardBg, // ✅
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                        border: Border.all(color: borderColor, width: 1), // ✅
                      ),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(8),
                        itemCount: provider.applications.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          color: borderColor, // ✅
                        ),
                        itemBuilder: (context, index) {
                          final app = provider.applications[index];
                          final isSelected = provider.selectedApplication?.id == app.id;

                          final itemBg = isDark ? Colors.white.withOpacity(0.1) : AppTheme.lightGray;

                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                provider.selectApplication(app);
                                widget.onApplicationSelected(app);
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.green.withOpacity(0.08)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    // Icon
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.green.withOpacity(0.15)
                                            : itemBg, // ✅
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.business,
                                        color: isSelected ? Colors.green : secondaryText, // ✅
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Application Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            app.name,
                                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                              fontWeight: isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.w500,
                                              color: isSelected
                                                  ? Colors.green
                                                  : primaryText, // ✅
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.category_outlined,
                                                size: 12,
                                                color: secondaryText, // ✅
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  app.department,
                                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                    color: secondaryText, // ✅
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.location_city_outlined,
                                                size: 12,
                                                color: secondaryText, // ✅
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                app.city,
                                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  color: secondaryText, // ✅
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Selected Indicator
                                    if (isSelected)
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Icon(
                                          Icons.check,
                                          color: AppTheme.white,
                                          size: 16,
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
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
