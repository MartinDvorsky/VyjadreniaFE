// ========================================
// CITY_EDIT_PANEL.DART - S dropdown pre kraj
// ========================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vyjadrenia/utils/permission_helper.dart';
import '../models/city_model.dart';
import '../providers/city_provider.dart';
import '../utils/app_theme.dart';

class CityEditPanel extends StatefulWidget {
  final City city;
  final VoidCallback onCancel;
  final VoidCallback onSaved;
  final VoidCallback onDeleted;

  const CityEditPanel({
    Key? key,
    required this.city,
    required this.onCancel,
    required this.onSaved,
    required this.onDeleted,
  }) : super(key: key);

  @override
  State<CityEditPanel> createState() => _CityEditPanelState();
}

class _CityEditPanelState extends State<CityEditPanel> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _districtController;
  late String _selectedRegion; // ✅ ZMENENÉ - dropdown namiesto controller
  late bool _isCity;
  bool _isLoading = false;
  bool _hasChanges = false;

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
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.city.name);
    _districtController = TextEditingController(text: widget.city.district);
    _selectedRegion = widget.city.region; // ✅ ZMENENÉ
    _isCity = widget.city.isCity;

    _nameController.addListener(_onFieldChanged);
    _districtController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    setState(() {
      _hasChanges = _nameController.text != widget.city.name ||
          _districtController.text != widget.city.district ||
          _selectedRegion != widget.city.region || // ✅ ZMENENÉ
          _isCity != widget.city.isCity;
    });
  }

  @override
  void didUpdateWidget(CityEditPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.city.id != widget.city.id) {
      _initializeControllers();
      _hasChanges = false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _districtController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_hasChanges) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Neboli vykonané žiadne zmeny'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final cityProvider = context.read<CityProvider>();
      await cityProvider.updateCity(
        widget.city.id,
        {
          'name': _nameController.text.trim(),
          'district': _districtController.text.trim().toUpperCase(),
          'region': _selectedRegion, // ✅ ZMENENÉ - už je uppercase
          'is_city': _isCity,
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text('Mesto "${_nameController.text}" bolo úspešne aktualizované'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() => _hasChanges = false);
        widget.onSaved();
      }
    } catch (e) {
      await context.showPermissionErrorIfNeeded(e, actionName: "úprava mesta");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Chyba pri ukladaní: $e')),
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

  Future<void> _deleteCity() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? AppTheme.darkBackground : Colors.white;
    final dialogWarningBg = isDark ? const Color(0xFF2C1515) : Colors.red.shade50;
    final dialogInfoBg = isDark ? AppTheme.darkCard : AppTheme.lightGray;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: dialogBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: dialogWarningBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.warning_rounded,
                color: Colors.red.shade600,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text('Potvrdiť zmazanie',
                style: TextStyle(color: isDark ? Colors.white : Colors.black)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Naozaj chcete zmazať toto mesto?',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: dialogInfoBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        widget.city.isCity ? Icons.location_city : Icons.home,
                        size: 16,
                        color: AppTheme.textMedium,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.city.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Okres: ${widget.city.district} | Kraj: ${widget.city.region}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: dialogWarningBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? Colors.red.withOpacity(0.3) : Colors.red.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.red.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Táto akcia je nenávratná!',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Zrušiť'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.delete, size: 18),
            label: const Text('Zmazať'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      final cityProvider = context.read<CityProvider>();
      final cityName = widget.city.name;
      await cityProvider.deleteCity(widget.city.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Mesto "$cityName" bolo úspešne zmazané'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        widget.onDeleted();
      }
    } catch (e) {
      await context.showPermissionErrorIfNeeded(e, actionName: "zmazanie mesta");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Chyba pri mazaní: $e')),
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
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoCard(),
                    const SizedBox(height: 32),
                    _buildFormFields(),
                    const SizedBox(height: 32),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade400,
            Colors.blue.shade600,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
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
            child: Icon(
              widget.city.isCity ? Icons.location_city : Icons.home,
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
                  'Editácia mesta',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${widget.city.id}',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          if (_hasChanges)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.edit, size: 14, color: Colors.white),
                  SizedBox(width: 6),
                  Text(
                    'Neuložené zmeny',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: _isLoading ? null : _deleteCity,
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Zmazať mesto',
            color: AppTheme.white,
            style: IconButton.styleFrom(
              backgroundColor: Colors.red.shade400.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppTheme.darkBackground : AppTheme.lightGray;
    final textColor = isDark ? Colors.white : AppTheme.textDark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 20,
                color: Colors.blue.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                'Aktuálne údaje',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Názov', widget.city.name),
          const SizedBox(height: 8),
          _buildInfoRow('Okres', widget.city.district),
          const SizedBox(height: 8),
          _buildInfoRow('Kraj', '${widget.city.region} - ${_regions[widget.city.region] ?? widget.city.region}'),
          const SizedBox(height: 8),
          _buildInfoRow('Typ', widget.city.isCity ? 'Mesto' : 'Obec'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textLight,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppTheme.textDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final typeBoxBg = isDark ? AppTheme.darkBackground : AppTheme.lightGray;
    final typeBoxBorder = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upraviť údaje',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 20),

        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Názov mesta *',
            hintText: 'Zadajte názov mesta alebo obce',
            prefixIcon: Icon(Icons.location_city, size: 20),
          ),
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
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _districtController,
                decoration: const InputDecoration(
                  labelText: 'Okres *',
                  hintText: 'Napr. PO, KE, BA',
                  prefixIcon: Icon(Icons.map, size: 20),
                ),
                textCapitalization: TextCapitalization.characters,
                maxLength: 2,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Okres je povinný';
                  }
                  if (value.trim().length != 2) {
                    return 'Okres musí mať 2 znaky';
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
                items: _regions.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text('${entry.key} - ${entry.value}'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRegion = value!;
                    _onFieldChanged();
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
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: typeBoxBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: typeBoxBorder, width: 1),
          ),
          child: Row(
            children: [
              Icon(
                _isCity ? Icons.location_city : Icons.home,
                color: AppTheme.primaryRed,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Typ sídla',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isCity ? 'Označené ako mesto' : 'Označené ako obec',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _isCity,
                onChanged: (value) {
                  setState(() {
                    _isCity = value;
                    _onFieldChanged();
                  });
                },
                activeColor: AppTheme.primaryRed,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final dangerBg = isDark ? const Color(0xFF2C1515) : Colors.red.shade50;
    final dangerBorder = isDark ? Colors.red.withOpacity(0.3) : Colors.red.shade200;
    final dangerIconBg = isDark ? Colors.red.withOpacity(0.2) : Colors.red.shade100;
    final dangerTextColor = isDark ? Colors.red.shade200 : Colors.red.shade900;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: dangerBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: dangerBorder, width: 1),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: dangerIconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.warning_rounded,
                  color: Colors.red.shade700,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nebezpečná zóna',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: dangerTextColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Zmazanie mesta je nenávratné',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _deleteCity,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Zmazať'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade700,
                  side: BorderSide(color: Colors.red.shade300, width: 1.5),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : widget.onCancel,
                icon: const Icon(Icons.close, size: 18),
                label: const Text('Zrušiť'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveChanges,
                icon: _isLoading
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
                    : const Icon(Icons.save, size: 18),
                label: Text(_isLoading ? 'Ukladám...' : 'Uložiť zmeny'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: _hasChanges ? AppTheme.primaryRed : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
