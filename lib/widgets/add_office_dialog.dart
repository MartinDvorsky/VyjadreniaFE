import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vyjadrenia/utils/permission_helper.dart';
import '../models/application_edit_model.dart';
import '../models/city_model.dart';
import '../providers/application_edit_provider.dart';
import '../providers/city_offices_provider.dart';
import '../widgets/application_search_widget.dart';
import '../utils/app_theme.dart';
import 'package:provider/provider.dart';

class AddOfficeDialog extends StatefulWidget {
  final City city;

  const AddOfficeDialog({
    Key? key,
    required this.city,
  }) : super(key: key);

  @override
  State<AddOfficeDialog> createState() => _AddOfficeDialogState();
}

class _AddOfficeDialogState extends State<AddOfficeDialog> {
  ApplicationEdit? _selectedApplication;
  bool _isAdding = false;


  @override
  Widget build(BuildContext context) {

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.darkCard : Colors.white;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: bgColor,
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
                      colors: [Colors.blue.shade400, Colors.blue.shade600],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.add_business_rounded,
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
                        'Pridať úrad k mestu',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Mesto: ${widget.city.name}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.blue,
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

            // Search Widget (znovu použijeme existujúci!)
            Expanded(
              child: ApplicationSearchWidget(
                onApplicationSelected: (application) {
                  setState(() {
                    _selectedApplication = application;
                  });
                },
              ),
            ),

            const SizedBox(height: 24),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // Footer s akciami
            Row(
              children: [
                // Selected Application Info
                if (_selectedApplication != null) ...[
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.blue.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.blue,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Vybraný úrad:',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                Text(
                                  _selectedApplication!.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue,
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
                  onPressed: _selectedApplication == null || _isAdding
                      ? null
                      : _handleAddOffice,
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
                  label: Text(_isAdding ? 'Pridávam...' : 'Pridať úrad'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
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

  Future<void> _handleAddOffice() async {
    if (_selectedApplication == null) return;

    setState(() {
      _isAdding = true;
    });

    try {
      final cityOfficesProvider = context.read<CityOfficesProvider>();

      // ✅ addOfficeToCity už obsahuje refresh
      await cityOfficesProvider.addOfficeToCity(
        _selectedApplication!.id,
        widget.city.id,
      );

      // ❌ ODSTRÁŇ túto riadku - už sa volá v addOfficeToCity
      // await cityOfficesProvider.loadOfficesForCity(widget.city.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Úrad "${_selectedApplication!.name}" bol úspešne pridaný k mestu "${widget.city.name}"',
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

      await context.showPermissionErrorIfNeeded(e, actionName: "pridávanie úradu k mestu");

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