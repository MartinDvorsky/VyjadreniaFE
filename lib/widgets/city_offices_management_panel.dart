// ========================================
// CITY OFFICES MANAGEMENT PANEL - DEBUG VERZIA
// ========================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vyjadrenia/utils/permission_helper.dart';
import '../models/city_model.dart';
import '../models/application_model.dart';
import '../providers/city_offices_provider.dart';
import '../widgets/add_office_dialog.dart';
import '../utils/app_theme.dart';

class CityOfficesManagementPanel extends StatelessWidget {
  final City city;

  const CityOfficesManagementPanel({
    Key? key,
    required this.city,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final containerBg = isDark ? AppTheme.darkCard : AppTheme.white;
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor;

    return Container(
      decoration: BoxDecoration(
        color: containerBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
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
          Divider(height: 1, color: borderColor),
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
                colors: [Colors.blue.shade400, Colors.blue.shade600],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.location_city_rounded,
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
                  city.name,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
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
                    Text(
                      'Okres: ${city.district}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 16),
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
          Consumer<CityOfficesProvider>(
            builder: (context, provider, child) {
              return ElevatedButton.icon(
                onPressed: provider.isLoading
                    ? null
                    : () => _showAddOfficeDialog(context),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Pridať úrad'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
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

    return Consumer<CityOfficesProvider>(
      builder: (context, provider, child) {
        // 🔍 DEBUG INFO
        print('🔍 DEBUG: offices.length = ${provider.offices.length}');
        if (provider.offices.isNotEmpty) {
          print('🔍 First office: ${provider.offices[0].name}');
          print('🔍 First office department: ${provider.offices[0].department}');
          print('🔍 First office city: ${provider.offices[0].city}');
        }

        // Loading State
        if (provider.isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: Colors.blue),
                const SizedBox(height: 16),
                Text(
                  'Načítavam úrady...',
                  style: TextStyle(color: isDark ? Colors.white70 : null),
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
                      color: isDark ? const Color(0xFF2C1515) : Colors.red.shade50,
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
                    onPressed: () => provider.loadOfficesForCity(city.id),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Skúsiť znova'),
                  ),
                ],
              ),
            ),
          );
        }

        // Empty State
        if (provider.offices.isEmpty) {
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
                      color: isDark ? Colors.blue.withOpacity(0.1) : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      Icons.business_outlined,
                      size: 50,
                      color: Colors.blue.shade300,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Žiadne priradené úrady',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Toto mesto nemá zatiaľ žiadne priradené úrady.\nKliknite na "Pridať úrad" pre pridanie.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showAddOfficeDialog(context),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Pridať prvý úrad'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Offices List
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.business_rounded,
                    size: 18,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Priradené úrady: ${provider.offices.length}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppTheme.textDark,
                    ),
                  ),
                ],
              ),
            ),
            // Offices List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: provider.offices.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final office = provider.offices[index];
                  // 🔍 DEBUG pre každý item
                  print('🔍 Building card $index: ${office.name}');
                  return _buildOfficeCard(context, office, provider);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOfficeCard(
      BuildContext context,
      Application office,
      CityOfficesProvider provider,
      ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppTheme.darkSurface : AppTheme.white;
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor;
    final iconBg = isDark ? Colors.blue.withOpacity(0.2) : Colors.blue.withOpacity(0.1);
    final titleColor = isDark ? Colors.white : AppTheme.textDark;

    // 🔍 DEBUG output
    print('🔍 Office Card Data:');
    print('   name: "${office.name}"');
    print('   department: "${office.department}"');
    print('   streetAddress: "${office.streetAddress}"');
    print('   city: "${office.city}"');

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
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
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.business,
                color: Colors.blue,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Office Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ Zobraz name (alebo fallback ak je prázdny)
                  Text(
                    office.name.isEmpty ? '(Bez názvu)' : office.name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // ✅ Department
                  Row(
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: 14,
                        color: AppTheme.textLight,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          office.department.isEmpty ? '(Bez odboru)' : office.department,
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  // ✅ Address
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppTheme.textLight,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${office.streetAddress.isEmpty ? "(Bez adresy)" : office.streetAddress}, ${office.city.isEmpty ? "(Bez mesta)" : office.city}',
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Delete Button
            OutlinedButton.icon(
              onPressed: () => _confirmRemoveOffice(context, office, provider),
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

  Future<void> _showAddOfficeDialog(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (context) => AddOfficeDialog(city: city),
    );

    if (result == true) {
      // Refresh
    }
  }

  Future<void> _confirmRemoveOffice(
      BuildContext context,
      Application office,
      CityOfficesProvider provider,
      ) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? AppTheme.darkBackground : Colors.white;
    final officeInfoBg = isDark ? const Color(0xFF2C1515) : Colors.red.withOpacity(0.05);
    final officeInfoBorder = isDark ? Colors.red.withOpacity(0.3) : Colors.red.withOpacity(0.2);
    final textColor = isDark ? Colors.white : Colors.black;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: dialogBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            const SizedBox(width: 12),
            Text('Potvrdenie odstránenia', style: TextStyle(color: textColor)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Naozaj chcete odstrániť toto prepojenie?',
              style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: officeInfoBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: officeInfoBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Úrad: ${office.name}',
                    style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
                  ),
                  const SizedBox(height: 4),
                  Text('Mesto: ${city.name}', style: TextStyle(color: textColor)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Toto odstráni len prepojenie medzi mestom a úradom. Samotný úrad zostane v databáze.',
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
        await provider.removeOfficeFromCity(office.applicationId, city.id);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Úrad "${office.name}" bol odstránený z mesta "${city.name}"',
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
        await context.showPermissionErrorIfNeeded(e, actionName: "odstránenie úradu z mesta");
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