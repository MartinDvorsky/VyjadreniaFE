import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vyjadrenia/utils/permission_helper.dart';
import '../models/application_edit_model.dart';
import '../providers/application_edit_provider.dart';
import '../utils/app_theme.dart';

class ApplicationCreateDialog extends StatefulWidget {
  const ApplicationCreateDialog({Key? key}) : super(key: key);

  @override
  State<ApplicationCreateDialog> createState() => _ApplicationCreateDialogState();
}

class _ApplicationCreateDialogState extends State<ApplicationCreateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _departmentController = TextEditingController();
  final _streetController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();

  final _icoController = TextEditingController();
  final _icoUriController = TextEditingController();

  String _selectedTextType = 'Siete';
  String _selectedSubmission = 'Poštou';
  bool _isLoading = false;

  // Checkboxy
  bool _technicalSituation = false;
  bool _situation = false;
  bool _situationA3 = false;
  bool _broaderRelations = false;
  bool _fireProtection = false;
  bool _waterManagement = false;
  bool _publicHealth = false;
  bool _railways = false;
  bool _roads1 = false;
  bool _roads2 = false;
  bool _municipality = false;

  @override
  void dispose() {
    _nameController.dispose();
    _departmentController.dispose();
    _streetController.dispose();
    _postalCodeController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _icoController.dispose();
    _icoUriController.dispose();
    super.dispose();
  }

  Future<void> _createApplication() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider = context.read<ApplicationEditProvider>();

      await provider.createApplication({
        'name': _nameController.text.trim(),
        'department': _departmentController.text.trim(),
        'street_address': _streetController.text.trim(),
        'postal_code': _postalCodeController.text.trim(),
        'city': _cityController.text.trim(),
        'district': _districtController.text.trim(),
        // použitie mapovacích metód z ApplicationEdit
        'text_type': ApplicationEdit.mapTextTypeToApi(_selectedTextType),
        'submission': ApplicationEdit.mapSubmissionToApi(_selectedSubmission),

        'technical_situation': _technicalSituation,
        'situation': _situation,
        'situation_A3': _situationA3,
        'broader_relations': _broaderRelations,
        'fire_protection': _fireProtection,
        'water_management': _waterManagement,
        'public_health': _publicHealth,
        'railways': _railways,
        'roads_1': _roads1,
        'roads_2': _roads2,
        'municipality': _municipality,
        'sender_ico': _icoController.text.trim().isEmpty
            ? null
            : _icoController.text.trim(),
        'sender_uri': _icoUriController.text.trim().isEmpty
            ? null
            : _icoUriController.text.trim(),
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
                  child: Text('Úrad "${_nameController.text}" bol úspešne vytvorený'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      await context.showPermissionErrorIfNeeded(e, actionName: 'Vytváranie úradu');

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
    // ✅ Dynamické farby
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.darkCard : AppTheme.white;
    final footerBgColor = isDark ? AppTheme.darkSurface : AppTheme.lightGray;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.1)
        : AppTheme.borderColor;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: bgColor, // ✅ Dynamické
      child: Container(
        width: 700,
        constraints: const BoxConstraints(maxHeight: 800),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade400, Colors.green.shade600],
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
                      Icons.business,
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
                          'Nový úrad',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppTheme.white,
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Vytvorte nový záznam úradu alebo inštitúcie',
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
                      // Základné údaje
                      Text(
                        'Základné údaje',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Názov úradu *',
                          hintText: 'Napr. Krajský stavebný úrad',
                          prefixIcon: Icon(Icons.business, size: 20),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Názov je povinný';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _departmentController,
                        decoration: const InputDecoration(
                          labelText: 'Oddelenie',
                          hintText: 'Napr. Stavebné oddelenie',
                          prefixIcon: Icon(Icons.category, size: 20),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Adresa
                      Text(
                        'Adresa',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _streetController,
                        decoration: const InputDecoration(
                          labelText: 'Ulica a č.p. *',
                          hintText: 'Napr. Hlavná 1',
                          prefixIcon: Icon(Icons.home, size: 20),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Adresa je povinná';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _postalCodeController,
                              decoration: const InputDecoration(
                                labelText: 'PSČ *',
                                hintText: '04001',
                                prefixIcon: Icon(Icons.mail, size: 20),
                              ),
                              keyboardType: TextInputType.number,
                              maxLength: 5,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'PSČ je povinné';
                                }
                                if (value.trim().length != 5) {
                                  return 'PSČ = 5 číslic';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: _cityController,
                              decoration: const InputDecoration(
                                labelText: 'Mesto *',
                                hintText: 'Košice',
                                prefixIcon: Icon(Icons.location_city, size: 20),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Mesto je povinné';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
// ✅ PRIDAJ TENTO BLOK
                      TextFormField(
                        controller: _districtController,
                        decoration: const InputDecoration(
                          labelText: 'Okres',
                          hintText: 'Napr. Košice',
                          prefixIcon: Icon(Icons.map, size: 20),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Okres je povinný';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Typ textu a podanie
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedTextType,
                              decoration: const InputDecoration(
                                labelText: 'Typ textu',
                                prefixIcon: Icon(Icons.text_fields, size: 20),
                              ),
                              items: ['SPP', 'MVSR', 'Urady', 'Siete', 'Štandardný']
                                  .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ))
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _selectedTextType = value);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedSubmission,
                              decoration: const InputDecoration(
                                labelText: 'Spôsob podania',
                                prefixIcon: Icon(Icons.send, size: 20),
                              ),
                              items: ['Mailom', 'Poštou', 'Webová aplikacia', 'Slovensko.sk']
                                  .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ))
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _selectedSubmission = value);
                                }
                              },
                            ),
                          ),
                        ],
                      ),

                      // 🔽 nové – zobrazí sa len pri "Elektronicky"
                      if (_selectedSubmission == 'Elektronicky') ...[
                        const SizedBox(height: 16),
                        Text(
                          'Údaje odosielateľa (elektronicky)',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _icoController,
                          decoration: const InputDecoration(
                            labelText: 'IČO *',
                            hintText: 'Napr. 12345678',
                            prefixIcon: Icon(Icons.business_center, size: 20),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            final text = value?.trim() ?? '';

                            if (_selectedSubmission == 'Elektronicky') {
                              if (text.isEmpty) {
                                return 'IČO je povinné pri elektronickom podaní';
                              }
                              if (!RegExp(r'^\d{8}$').hasMatch(text)) {
                                return 'IČO musí mať 8 číslic';
                              }
                              // ak chceš, tu sa dá ešte doplniť kontrolný súčet
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _icoUriController,
                          decoration: const InputDecoration(
                            labelText: 'IČO URI',
                            hintText: 'Např. urn:oid:1.2.3.4...',
                            prefixIcon: Icon(Icons.link, size: 20),
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Prílohy
                      Text(
                        'Požadované prílohy',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),

                      _buildCheckboxTile('Technická situácia', _technicalSituation, (val) {
                        setState(() => _technicalSituation = val!);
                      }),
                      _buildCheckboxTile('Situácia', _situation, (val) {
                        setState(() => _situation = val!);
                      }),
                      _buildCheckboxTile('Situácia A3', _situationA3, (val) {
                        setState(() => _situationA3 = val!);
                      }),
                      _buildCheckboxTile('Širšie vzťahy', _broaderRelations, (val) {
                        setState(() => _broaderRelations = val!);
                      }),

                      const SizedBox(height: 16),

                      // Typy úradu
                      Text(
                        'Typ úradu',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),

                      _buildCheckboxTile('🔥 Požiarna ochrana (ORHAZZ)', _fireProtection, (val) {
                        setState(() => _fireProtection = val!);
                      }),
                      _buildCheckboxTile('💧 Vodné hospodárstvo (SVP)', _waterManagement, (val) {
                        setState(() => _waterManagement = val!);
                      }),
                      _buildCheckboxTile('🥼 Verejné zdravotníctvo (RÚVZ)', _publicHealth, (val) {
                        setState(() => _publicHealth = val!);
                      }),
                      _buildCheckboxTile('🚂 Železnice (ŽSR)', _railways, (val) {
                        setState(() => _railways = val!);
                      }),
                      _buildCheckboxTile('🛣️ Cesty I. triedy', _roads1, (val) {
                        setState(() => _roads1 = val!);
                      }),
                      _buildCheckboxTile('🛣️ Cesty II./III. triedy', _roads2, (val) {
                        setState(() => _roads2 = val!);
                      }),
                      _buildCheckboxTile('🏛️ Mesto/Obec', _municipality, (val) {
                        setState(() => _municipality = val!);
                      }),
                    ],
                  ),
                ),
              ),
            ),

            // Footer Actions
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: footerBgColor, // ✅ Dynamické
                border: Border(
                  top: BorderSide(color: borderColor, width: 1), // ✅ Dynamické
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
                      onPressed: _isLoading ? null : _createApplication,
                      icon: _isLoading
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : const Icon(Icons.add, size: 18),
                      label: Text(_isLoading ? 'Vytváram...' : 'Vytvoriť úrad'),
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

  Widget _buildCheckboxTile(String title, bool value, Function(bool?) onChanged) {
    return CheckboxListTile(
      title: Text(title, style: const TextStyle(fontSize: 14)),
      value: value,
      onChanged: onChanged,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}