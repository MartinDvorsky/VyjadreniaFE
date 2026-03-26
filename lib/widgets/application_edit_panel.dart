import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/application_edit_model.dart';
import '../providers/application_edit_provider.dart';
import '../utils/app_theme.dart';
import '../utils/permission_helper.dart';
import 'permission_denied_dialog.dart';

class ApplicationEditPanel extends StatefulWidget {
  final ApplicationEdit application;
  final VoidCallback onCancel;
  final VoidCallback onSaved;
  final VoidCallback onDeleted;

  const ApplicationEditPanel({
    Key? key,
    required this.application,
    required this.onCancel,
    required this.onSaved,
    required this.onDeleted,
  }) : super(key: key);

  @override
  State<ApplicationEditPanel> createState() => _ApplicationEditPanelState();
}

class _ApplicationEditPanelState extends State<ApplicationEditPanel> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _departmentController;
  late TextEditingController _streetController;
  late TextEditingController _postalCodeController;
  late TextEditingController _cityController;
  late TextEditingController _districtController;

  late TextEditingController _icoController;
  late TextEditingController _icoUriController;

  static const List<String> _textTypeOptions = ['SPP', 'MVSR', 'Urady', 'Siete', 'Štandardný'];
  static const List<String> _submissionOptions = ['Mailom', 'Poštou', 'Webová aplikacia', 'Slovensko.sk'];

  late String _textType;
  late String _submission;

  late bool _technicalSituation;
  late bool _situation;
  late bool _situationA3;
  late bool _broaderRelations;
  late bool _fireProtection;
  late bool _waterManagement;
  late bool _publicHealth;
  late bool _railways;
  late bool _roads1;
  late bool _roads2;
  late bool _municipality;

  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.application.name);
    _departmentController = TextEditingController(text: widget.application.department);
    _streetController = TextEditingController(text: widget.application.streetAddress);
    _postalCodeController = TextEditingController(text: widget.application.postalCode);
    _cityController = TextEditingController(text: widget.application.city);
    _districtController = TextEditingController(text: widget.application.district);
    _icoController = TextEditingController(text: widget.application.senderIco ?? '');
    _icoUriController = TextEditingController(text: widget.application.senderUri ?? '');


    _textType = _textTypeOptions.contains(widget.application.textType)
        ? widget.application.textType
        : _textTypeOptions.first;

    _submission = _submissionOptions.contains(widget.application.submission)
        ? widget.application.submission
        : _submissionOptions.first;

    _technicalSituation = widget.application.technicalSituation;
    _situation = widget.application.situation;
    _situationA3 = widget.application.situationA3;
    _broaderRelations = widget.application.broaderRelations;
    _fireProtection = widget.application.fireProtection;
    _waterManagement = widget.application.waterManagement;
    _publicHealth = widget.application.publicHealth;
    _railways = widget.application.railways;
    _roads1 = widget.application.roads1;
    _roads2 = widget.application.roads2;
    _municipality = widget.application.municipality;

    _nameController.addListener(_onFieldChanged);
    _departmentController.addListener(_onFieldChanged);
    _streetController.addListener(_onFieldChanged);
    _postalCodeController.addListener(_onFieldChanged);
    _cityController.addListener(_onFieldChanged);
    _icoController.addListener(_onFieldChanged);
    _icoUriController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    setState(() {
      _hasChanges = _nameController.text != widget.application.name ||
          _departmentController.text != widget.application.department ||
          _streetController.text != widget.application.streetAddress ||
          _postalCodeController.text != widget.application.postalCode ||
          _cityController.text != widget.application.city ||
          _districtController.text != widget.application.district ||
          _textType != widget.application.textType ||
          _submission != widget.application.submission ||
          _technicalSituation != widget.application.technicalSituation ||
          _situation != widget.application.situation ||
          _situationA3 != widget.application.situationA3 ||
          _broaderRelations != widget.application.broaderRelations ||
          _fireProtection != widget.application.fireProtection ||
          _waterManagement != widget.application.waterManagement ||
          _publicHealth != widget.application.publicHealth ||
          _railways != widget.application.railways ||
          _roads1 != widget.application.roads1 ||
          _roads2 != widget.application.roads2 ||
          _municipality != widget.application.municipality ||
          _icoController.text != (widget.application.senderIco ?? '') ||
          _icoUriController.text != (widget.application.senderUri ?? '');
    });
  }

  @override
  void didUpdateWidget(ApplicationEditPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.application.id != widget.application.id) {
      _initializeControllers();
      _hasChanges = false;
    }
  }

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
      final provider = context.read<ApplicationEditProvider>();
      await provider.updateApplication(
        widget.application.id,
        {
          'name': _nameController.text.trim(),
          'department': _departmentController.text.trim(),
          'street_address': _streetController.text.trim(),
          'postal_code': _postalCodeController.text.replaceAll(' ', '').trim(),
          'city': _cityController.text.trim(),
          'district': _districtController.text.trim(),
          // mapovanie na API kódy
          'text_type': ApplicationEdit.mapTextTypeToApi(_textType),
          'submission': ApplicationEdit.mapSubmissionToApi(_submission),

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
        },
      );


      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text('Úrad "${_nameController.text}" bol úspešne aktualizovaný'),
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
      await context.showPermissionErrorIfNeeded(e, actionName: "úprava úradu");
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

  Future<void> _deleteApplication() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (mounted) {
        await PermissionDeniedDialog.show(
          context,
          title: 'Nie ste prihlásený',
          message: 'Musíte byť prihlásený aby ste mohli mazať úrady.',
          actionName: 'Zmazanie úradu',
        );
      }
      return;
    }

    // 🔥 Dynamické farby pre dialóg
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogWarningBg = isDark ? const Color(0xFF2C1515) : Colors.red.shade50;
    final dialogWarningBorder = isDark ? Colors.red.withOpacity(0.3) : Colors.red.shade200;
    final dialogInfoBg = isDark ? AppTheme.darkBackground : AppTheme.lightGray;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
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
            const Text('Potvrdiť zmazanie'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Naozaj chcete zmazať tento úrad?',
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
                      const Icon(
                        Icons.business,
                        size: 16,
                        color: AppTheme.textMedium,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.application.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: isDark ? Colors.white : AppTheme.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.application.department,
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
                border: Border.all(color: dialogWarningBorder),
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
                        color: Colors.red.shade700, // Červená je čitateľná aj na tmavom
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
      final provider = context.read<ApplicationEditProvider>();
      final appName = widget.application.name;
      await provider.deleteApplication(widget.application.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Úrad "$appName" bol úspešne zmazaný'),
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
      await context.showPermissionErrorIfNeeded(e,
          actionName: 'Zmazanie úradu "${widget.application.name}"');

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
    // ✅ 1. Zistenie témy
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ✅ 2. Príprava dynamických farieb pre kontajner
    final containerBg = isDark ? AppTheme.darkCard : AppTheme.white;
    final containerBorder = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor;

    return Container(
      decoration: BoxDecoration(
        color: containerBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: containerBorder, width: 1),
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
          colors: [Colors.green.shade400, Colors.green.shade600],
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
                  'Editácia úradu',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${widget.application.id}',
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
            onPressed: _isLoading ? null : _deleteApplication,
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Zmazať úrad',
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
    // ✅ Dynamické farby pre Info Kartu
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppTheme.darkBackground : AppTheme.lightGray;
    final iconColor = Colors.green.shade600; // Zelená je OK na oboch

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: isDark ? Border.all(color: Colors.white.withOpacity(0.05)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 20,
                color: iconColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Aktuálne údaje',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.white : AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Názov', widget.application.name),
          const SizedBox(height: 8),
          _buildInfoRow('Oddelenie', widget.application.department),
          const SizedBox(height: 8),
          _buildInfoRow('Adresa',
              '${widget.application.streetAddress}, ${widget.application.postalCode} ${widget.application.city}'),
          const SizedBox(height: 8),
          _buildInfoRow('Typ textu', widget.application.textType),
          const SizedBox(height: 8),
          _buildInfoRow('Podanie', widget.application.submission),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textLight, // Sivá je čitateľná na oboch
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppTheme.textDark, // ✅ Biela v tmavom
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upraviť údaje',
          // Tento štýl sa automaticky preberie z Theme (headlineMedium),
          // takže ak máš v AppTheme nastavenú farbu pre darkTheme, bude to fungovať.
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Názov úradu *',
            prefixIcon: Icon(Icons.business, size: 20),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Názov je povinný';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _departmentController,
          decoration: const InputDecoration(
            labelText: 'Oddelenie',
            prefixIcon: Icon(Icons.category, size: 20),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _streetController,
          decoration: const InputDecoration(
            labelText: 'Ulica a č.p. *',
            prefixIcon: Icon(Icons.home, size: 20),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Adresa je povinná';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _postalCodeController,
                decoration: const InputDecoration(
                  labelText: 'PSČ *',
                  hintText: 'Napr. 09111',
                  prefixIcon: Icon(Icons.mail, size: 20),
                ),
                maxLength: 6,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final stripped = value.replaceAll(' ', '');
                  if (stripped != value) {
                    _postalCodeController.value = TextEditingValue(
                      text: stripped,
                      selection: TextSelection.collapsed(offset: stripped.length),
                    );
                  }
                },
                validator: (value) {
                  final text = (value ?? '').replaceAll(' ', '');
                  if (text.isEmpty) {
                    return 'PSČ je povinné';
                  }
                  if (!RegExp(r'^\d{5}$').hasMatch(text)) {
                    return 'PSČ musí mať 5 číslic';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'Mesto *',
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
            labelText: 'Okres *',
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

        // Dropdowny
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _textType,
                decoration: const InputDecoration(
                  labelText: 'Typ textu',
                  prefixIcon: Icon(Icons.text_fields, size: 20),
                ),
                items: _textTypeOptions
                    .map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type),
                ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _textType = value;
                      _onFieldChanged();
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _submission,
                decoration: const InputDecoration(
                  labelText: 'Spôsob podania',
                  prefixIcon: Icon(Icons.send, size: 20),
                ),
                items: _submissionOptions
                    .map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type),
                ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _submission = value;
                      _onFieldChanged();
                    });
                  }
                },
              ),
            ),
          ],
        ),

        if (_submission == 'Elektronicky') ...[
          const SizedBox(height: 16),
          Text(
            'Údaje odosielateľa (elektronicky)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _icoController,
            decoration: const InputDecoration(
              labelText: 'IČO',
              hintText: 'Napr. 12345678',
              prefixIcon: Icon(Icons.business_center, size: 20),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.isNotEmpty && !RegExp(r'^\d{8}$').hasMatch(text)) {
                return 'IČO musí mať 8 číslic';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _icoUriController,
            decoration: const InputDecoration(
              labelText: 'IČO URI',
              hintText: 'Napr. urn:oid:1.2.3.4...',
              prefixIcon: Icon(Icons.link, size: 20),
            ),
            validator: (value) {
              return null;
            },
          ),
        ],

        const SizedBox(height: 24),

        // Checkboxy - Prílohy
        Text(
          'Požadované prílohy',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        _buildCheckboxTile('Technická situácia', _technicalSituation, (val) {
          setState(() {
            _technicalSituation = val!;
            _onFieldChanged();
          });
        }),
        _buildCheckboxTile('Situácia', _situation, (val) {
          setState(() {
            _situation = val!;
            _onFieldChanged();
          });
        }),
        _buildCheckboxTile('Situácia A3', _situationA3, (val) {
          setState(() {
            _situationA3 = val!;
            _onFieldChanged();
          });
        }),
        _buildCheckboxTile('Širšie vzťahy', _broaderRelations, (val) {
          setState(() {
            _broaderRelations = val!;
            _onFieldChanged();
          });
        }),

        const SizedBox(height: 24),

        // Checkboxy - Typy úradu
        Text(
          'Typ úradu',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        _buildCheckboxTile('🔥 Požiarna ochrana (ORHAZZ)', _fireProtection, (val) {
          setState(() {
            _fireProtection = val!;
            _onFieldChanged();
          });
        }),
        _buildCheckboxTile('💧 Vodné hospodárstvo (SVP)', _waterManagement, (val) {
          setState(() {
            _waterManagement = val!;
            _onFieldChanged();
          });
        }),
        _buildCheckboxTile('🏥 Verejné zdravotníctvo (RÚVZ)', _publicHealth, (val) {
          setState(() {
            _publicHealth = val!;
            _onFieldChanged();
          });
        }),
        _buildCheckboxTile('🚂 Železnice (ŽSR)', _railways, (val) {
          setState(() {
            _railways = val!;
            _onFieldChanged();
          });
        }),
        _buildCheckboxTile('🛣️ Cesty I. triedy', _roads1, (val) {
          setState(() {
            _roads1 = val!;
            _onFieldChanged();
          });
        }),
        _buildCheckboxTile('🛣️ Cesty II./III. triedy', _roads2, (val) {
          setState(() {
            _roads2 = val!;
            _onFieldChanged();
          });
        }),
        _buildCheckboxTile('🏛️ Mesto/Obec', _municipality, (val) {
          setState(() {
            _municipality = val!;
            _onFieldChanged();
          });
        }),
      ],
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

  Widget _buildActionButtons() {
    // ✅ Dynamické farby pre Danger Zone
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final dangerBg = isDark ? const Color(0xFF2C1515) : Colors.red.shade50;
    final dangerBorder = isDark ? Colors.red.withOpacity(0.3) : Colors.red.shade200;
    final dangerIconBg = isDark ? Colors.red.withOpacity(0.2) : Colors.red.shade100;
    final dangerTextColor = isDark ? Colors.red.shade200 : Colors.red.shade900;

    return Column(
      children: [
        // Danger Zone
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
                      'Zmazanie úradu je nenávratné',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _deleteApplication,
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

        // Save/Cancel buttons
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
                  backgroundColor: _hasChanges ? Colors.green.shade600 : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}