import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vyjadrenia/utils/permission_helper.dart';
import '../models/city_model.dart';
import '../providers/city_provider.dart';
import '../utils/app_theme.dart';



class CityCreateDialog extends StatefulWidget {
  const CityCreateDialog({Key? key}) : super(key: key);

  @override
  State<CityCreateDialog> createState() => _CityCreateDialogState();
}

class _CityCreateDialogState extends State<CityCreateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _districtController = TextEditingController();
  String? _selectedRegion; // ✅ ZMENENÉ - dropdown namiesto controller
  bool _isCity = false;
  bool _isLoading = false;

  // ✅ Mapa krajov
  final Map<String, String> _regions = {
    'BA': 'Bratislavský kraj',
    'TT': 'Trnavský kraj',
    'TN': 'Trenčiansky kraj',
    'NR': 'Nitriansky kraj',
    'ZA': 'Žilinský kraj',
    'BB': 'Banskobystrický kraj',
    'PO': 'Prešovský kraj',
    'KE': 'Košický kraj',
  };

  @override
  void dispose() {
    _nameController.dispose();
    _districtController.dispose();
    super.dispose();
  }

  Future<void> _createCity() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final cityProvider = context.read<CityProvider>();

      await cityProvider.createCity({
        'name': _nameController.text.trim(),
        'district': _districtController.text.trim().toUpperCase(),
        'region': _selectedRegion!, // ✅ ZMENENÉ
        'is_city': _isCity,
      });

      if (mounted) {
        Navigator.of(context).pop(true);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Mesto "${_nameController.text}" bolo úspešne vytvorené',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      await context.showPermissionErrorIfNeeded(e, actionName: "vytváranie mesta");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Chyba pri vytváraní: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? AppTheme.darkBackground : Colors.white;
    final footerBg = isDark ? AppTheme.darkSurface : AppTheme.lightGray;
    final footerBorder = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor;
    final titleColor = isDark ? Colors.white : AppTheme.white;
    final typeLabelColor = isDark ? AppTheme.textLight : AppTheme.textDark;

    final infoBg = isDark ? Colors.blue.withOpacity(0.1) : Colors.blue.shade50;
    final infoBorder = isDark ? Colors.blue.withOpacity(0.3) : Colors.blue.shade200;
    final infoIconColor = isDark ? Colors.blue.shade300 : Colors.blue.shade700;
    final infoTextColor = isDark ? Colors.blue.shade200 : Colors.blue.shade900;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: dialogBg,
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green.shade400,
                    Colors.green.shade600,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.add_location_alt,
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
                          'Nové mesto',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: titleColor,
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Vytvorte nový záznam mesta alebo obce',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: AppTheme.white),
                    tooltip: 'Zavrieť',
                  ),
                ],
              ),
            ),

            // Form Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Info Box
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: infoBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: infoBorder,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: infoIconColor,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Vyplňte všetky povinné polia označené hviezdičkou (*)',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: infoTextColor,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Názov mesta
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Názov mesta *',
                          hintText: 'Zadajte názov mesta alebo obce',
                          prefixIcon: Icon(Icons.location_city, size: 20),
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Názov je povinný';
                          }
                          if (value.trim().length < 2) {
                            return 'Názov musí mať aspoň 2 znaky';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Okres a Kraj
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _districtController,
                              decoration: const InputDecoration(
                                labelText: 'Okres *',
                                hintText: 'PO, KE, BA...',
                                prefixIcon: Icon(Icons.map, size: 20),
                              ),
                              textCapitalization: TextCapitalization.characters,
                              maxLength: 2,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Okres je povinný';
                                }
                                if (value.trim().length != 2) {
                                  return 'Okres = 2 znaky';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          // ✅ ZMENENÉ - Dropdown namiesto TextFormField
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedRegion,
                              decoration: const InputDecoration(
                                labelText: 'Kraj *',
                                prefixIcon: Icon(Icons.public, size: 20),
                              ),
                              hint: const Text('Vyberte kraj'),
                              items: _regions.entries.map((entry) {
                                return DropdownMenuItem(
                                  value: entry.key,
                                  child: Text('${entry.key} - ${entry.value}'),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedRegion = value;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Kraj je povinný';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Typ sídla
                      Text(
                        'Typ sídla',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: typeLabelColor,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: _buildTypeCard(
                              icon: Icons.home,
                              label: 'Obec',
                              isSelected: !_isCity,
                              onTap: () => setState(() => _isCity = false),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTypeCard(
                              icon: Icons.location_city,
                              label: 'Mesto',
                              isSelected: _isCity,
                              onTap: () => setState(() => _isCity = true),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer Actions
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: footerBg,
                border: Border(
                  top: BorderSide(color: footerBorder, width: 1),
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Zrušiť'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _createCity,
                      icon: _isLoading
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : const Icon(Icons.add, size: 18),
                      label: Text(_isLoading ? 'Vytvárám...' : 'Vytvoriť mesto'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.green.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeCard({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseBg = isDark ? AppTheme.darkCard : AppTheme.white;
    final selectedBg =
    isDark ? Colors.green.withOpacity(0.2) : Colors.green.shade50;
    final borderColor =
    isSelected ? Colors.green.shade400 : (isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor);
    final iconColor = isSelected
        ? Colors.green.shade600
        : (isDark ? Colors.white70 : AppTheme.textMedium);
    final textColor = isSelected
        ? Colors.green.shade700
        : (isDark ? Colors.white : AppTheme.textDark);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? selectedBg : baseBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: iconColor,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: textColor,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: 4),
              Icon(
                Icons.check_circle,
                size: 16,
                color: Colors.green.shade600,
              ),
            ],
          ],
        ),
      ),
    );
  }
}