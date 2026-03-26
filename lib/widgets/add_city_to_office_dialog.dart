import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vyjadrenia/utils/permission_helper.dart';
import '../models/application_edit_model.dart';
import '../models/city_model.dart';
import '../providers/office_cities_provider.dart';
import '../providers/city_provider.dart';
import '../widgets/city_search_widget.dart';
import '../utils/app_theme.dart';

class AddCityToOfficeDialog extends StatefulWidget {
  final ApplicationEdit office;

  const AddCityToOfficeDialog({
    Key? key,
    required this.office,
  }) : super(key: key);

  @override
  State<AddCityToOfficeDialog> createState() => _AddCityToOfficeDialogState();
}

class _AddCityToOfficeDialogState extends State<AddCityToOfficeDialog> {
  City? _selectedCity;
  bool _isAdding = false;

  @override
  Widget build(BuildContext context) {
    // ✅ Dynamické farby
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.darkCard : Colors.white;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: bgColor, // ✅ Dynamické
      child: Container(
        width: 900,
        height: 700,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
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
                    Icons.add_location_rounded,
                    color: AppTheme.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pridať mesto k úradu',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Úrad: ${widget.office.name}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.purple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  icon: const Icon(Icons.close),
                  tooltip: 'Zavrieť',
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Divider(height: 1),
            const SizedBox(height: 24),

            // Search Widget
            Expanded(
              child: ChangeNotifierProvider(
                create: (_) => CityProvider(),
                child: CitySearchWidget(
                  onCitySelected: (city) {
                    setState(() {
                      _selectedCity = city;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // Footer s akciami
            Row(
              children: [
                // Selected City Info
                if (_selectedCity != null) ...[
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.purple.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.purple,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Vybrané mesto:',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                Text(
                                  _selectedCity!.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.purple,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],

                // Cancel Button
                OutlinedButton(
                  onPressed: _isAdding
                      ? null
                      : () => Navigator.of(context).pop(false),
                  child: const Text('Zrušiť'),
                ),
                const SizedBox(width: 12),

                // Add Button
                ElevatedButton.icon(
                  onPressed: _selectedCity == null || _isAdding
                      ? null
                      : _handleAddCity,
                  icon: _isAdding
                      ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.white,
                      ),
                    ),
                  )
                      : const Icon(Icons.add_rounded),
                  label: Text(_isAdding ? 'Pridávam...' : 'Pridať mesto'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAddCity() async {
    if (_selectedCity == null) return;

    setState(() {
      _isAdding = true;
    });

    try {
      final officeCitiesProvider = context.read<OfficeCitiesProvider>();

      await officeCitiesProvider.addCityToOffice(
        widget.office.id,
        _selectedCity!.id,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Mesto "${_selectedCity!.name}" bolo úspešne pridané k úradu "${widget.office.name}"',
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

        Navigator.of(context).pop(true);
      }
    } catch (e) {
      await context.showPermissionErrorIfNeeded(e, actionName: "pridať mesto k úradu");

      if (mounted) {
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
    } finally {
      if (mounted) {
        setState(() {
          _isAdding = false;
        });
      }
    }
  }
}