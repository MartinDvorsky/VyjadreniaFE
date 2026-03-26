// ========================================
// BUILDER DIALOG - Dialóg pre zadanie údajov o stavebnίkovi
// Uložiť ako: lib/widgets/builder_dialog.dart
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/builder_model.dart';
import '../utils/app_theme.dart';

class BuilderDialog extends StatefulWidget {
  final BuilderModel? initialBuilder;
  final Map<String, String> fieldWarnings; // ← NOVÉ

  const BuilderDialog({
    Key? key,
    this.initialBuilder,
    this.fieldWarnings = const {}, // ← default prázdna mapa
  }) : super(key: key);

  @override
  State<BuilderDialog> createState() => _BuilderDialogState();
}

class _BuilderDialogState extends State<BuilderDialog> {
  final _formKey = GlobalKey<FormState>();

  // Controllers pre základné údaje
  late TextEditingController _nameController;
  late TextEditingController _obecController;
  late TextEditingController _ulicaController;
  late TextEditingController _cisloDomuController;
  late TextEditingController _pscController;
  late TextEditingController _icoController;
  late TextEditingController _emailController;
  late TextEditingController _telefonController;

  // Controllers pre údaje právnickej osoby
  late TextEditingController _menoLegalEntityController;
  late TextEditingController _emailLegalEntityController;
  late TextEditingController _typOpravneniaController;

  String _selectedTyp = 'Fyzická osoba';
  bool _icoAutoValidate = false;

  final List<String> _typOptions = [
    'Fyzická osoba',
    'Právnická osoba',
    'Fyzická osoba podnikateľ',
  ];

  @override
  void initState() {
    super.initState();
    final builder = widget.initialBuilder;
    _nameController = TextEditingController(text: builder?.name ?? '');
    _obecController = TextEditingController(text: builder?.obec ?? '');
    _ulicaController = TextEditingController(text: builder?.ulica ?? '');
    _cisloDomuController = TextEditingController(text: builder?.cisloDomu ?? '');
    _pscController = TextEditingController(text: builder?.psc ?? '');
    _icoController = TextEditingController(text: builder?.ico ?? '');
    _emailController = TextEditingController(text: builder?.email ?? '');
    _telefonController = TextEditingController(text: builder?.telefon ?? '');
    _menoLegalEntityController = TextEditingController(text: builder?.menoLegalEntity ?? '');
    _emailLegalEntityController = TextEditingController(text: builder?.emailLegalEntity ?? '');
    _typOpravneniaController = TextEditingController(text: builder?.typOpravnenia ?? '');

    _selectedTyp = builder?.typ ?? 'Fyzická osoba';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _obecController.dispose();
    _ulicaController.dispose();
    _cisloDomuController.dispose();
    _pscController.dispose();
    _icoController.dispose();
    _emailController.dispose();
    _telefonController.dispose();
    _menoLegalEntityController.dispose();
    _emailLegalEntityController.dispose();
    _typOpravneniaController.dispose();
    super.dispose();
  }

  String? _validateICO(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    final ico = value.replaceAll(' ', '');

    if (!RegExp(r'^[0-9]+$').hasMatch(ico)) {
      return 'IČO musí obsahovať len číslice';
    }

    if (ico.length != 8) {
      return 'IČO musí mať presne 8 číslic';
    }

    try {
      int sum = 0;
      for (int i = 0; i < 7; i++) {
        sum += int.parse(ico[i]) * (8 - i);
      }

      int remainder = sum % 11;
      int checkDigit;

      if (remainder == 0) {
        checkDigit = 1;
      } else if (remainder == 1) {
        checkDigit = 0;
      } else {
        checkDigit = 11 - remainder;
      }

      if (int.parse(ico[7]) != checkDigit) {
        return 'Neplatné IČO - nesprávna kontrolná číslica';
      }
    } catch (e) {
      return 'Chyba pri validácii IČO';
    }

    return null;
  }

  void _saveBuilder() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      print('📝 Saving builder:');
      print('  ICO: ${_icoController.text}');
      print('  Name: ${_nameController.text}');

      final builder = BuilderModel(
        name: _nameController.text.trim(),
        obec: _obecController.text.trim(),
        ulica: _ulicaController.text.trim(),
        cisloDomu: _cisloDomuController.text.trim(),
        psc: _pscController.text.trim(),
        ico: _icoController.text.trim(),
        email: _emailController.text.trim(),
        telefon: _telefonController.text.trim(),
        typ: _selectedTyp,
        menoLegalEntity: _selectedTyp == 'Právnická osoba'
            ? _menoLegalEntityController.text.trim()
            : null,
        emailLegalEntity: _selectedTyp == 'Právnická osoba'
            ? _emailLegalEntityController.text.trim()
            : null,
        typOpravnenia: _selectedTyp == 'Právnická osoba'
            ? _typOpravneniaController.text.trim()
            : null,
      );

      print('✅ Builder model created: ${builder.toJson()}');

      Navigator.of(context).pop(builder);
    } else {
      print('❌ Form validation failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final dialogBg = isDark ? AppTheme.darkBackground : Colors.white;
    final headerBg = isDark ? AppTheme.darkCard : AppTheme.primaryRed.withOpacity(0.1);
    final footerBg = isDark ? AppTheme.darkCard : Colors.grey[100];
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : Colors.grey[300]!;
    final textColor = isDark ? Colors.white : AppTheme.textDark;
    final iconBg = isDark ? Colors.white.withOpacity(0.1) : Colors.white;

    // Ak existujú nejaké warningy, ukáž badge v headeri
    final hasAnyWarning = widget.fieldWarnings.isNotEmpty;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: dialogBg,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 700),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: hasAnyWarning
                    ? Colors.orange.withOpacity(isDark ? 0.15 : 0.08)
                    : headerBg,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                border: hasAnyWarning
                    ? Border(
                  bottom: BorderSide(
                    color: Colors.orange.withOpacity(0.3),
                    width: 1,
                  ),
                )
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.article_rounded,
                      color: hasAnyWarning ? Colors.orange : AppTheme.primaryRed,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Údaje o stavebnίkovi',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        // Upozornenie ak sú warningy
                        if (hasAnyWarning)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.orange,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'AI extrakcia — skontrolujte označené polia',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.orange[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    color: textColor,
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Základné údaje sekcia
                      _buildSectionHeader(
                        icon: Icons.home_rounded,
                        title: 'Základné údaje',
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _nameController,
                        label: 'Meno, priezvisko/obchodné meno:',
                        hint: 'Zadajte meno alebo obchodné meno',
                        required: true,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _obecController,
                        label: 'Obec:',
                        hint: 'Zadajte obec',
                        required: true,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _ulicaController,
                        label: 'Ulica:',
                        hint: 'Zadajte ulicu',
                        required: true,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _cisloDomuController,
                              label: 'Čίslo domu:',
                              hint: 'Napr. 31',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _pscController,
                              label: 'PSČ:',
                              hint: 'Napr. 042 91',
                              required: true,
                              // ← napojenie na backend warning
                              warningMessage: widget.fieldWarnings['investor.psc'],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _icoController,
                        label: 'IČO:',
                        hint: 'Zadajte 8-ciferné IČO',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(8),
                        ],
                        customValidator: _validateICO,
                        autoValidateMode: _icoAutoValidate
                            ? AutovalidateMode.always
                            : AutovalidateMode.disabled,
                        onChanged: (value) {
                          if (!_icoAutoValidate && value.isNotEmpty) {
                            setState(() {
                              _icoAutoValidate = true;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      Divider(color: borderColor),
                      const SizedBox(height: 24),

                      // Kontaktné údaje sekcia
                      _buildSectionHeader(
                        icon: Icons.phone_rounded,
                        title: 'Kontaktné údaje',
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email:',
                        hint: 'mital@elprokan.sk',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _telefonController,
                        label: 'Tel.:',
                        hint: '0948 042 013',
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 24),
                      Divider(color: borderColor),
                      const SizedBox(height: 24),

                      // Typ stavebnίka sekcia
                      _buildSectionHeader(
                        icon: Icons.person_rounded,
                        title: 'Typ stavebnίka',
                      ),
                      const SizedBox(height: 16),
                      _buildDropdownField(
                        label: 'Typ:',
                        value: _selectedTyp,
                        items: _typOptions,
                        onChanged: (value) {
                          setState(() {
                            _selectedTyp = value!;
                          });
                        },
                      ),

                      // Údaje právnickej osoby
                      if (_selectedTyp == 'Právnická osoba') ...[
                        const SizedBox(height: 24),
                        Divider(color: borderColor),
                        const SizedBox(height: 24),
                        _buildSectionHeader(
                          icon: Icons.business_rounded,
                          title: 'Údaje právnickej osoby',
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _menoLegalEntityController,
                          label: 'Meno (Len ak právnická osoba):',
                          hint: 'Zadajte meno zástupcu',
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _emailLegalEntityController,
                          label: 'Email a Tel. (Len ak právnická osoba):',
                          hint: 'email@example.com, 0900 123 456',
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _typOpravneniaController,
                          label: 'Typ oprávnenia (Len ak právnická osoba):',
                          hint: 'Zadajte typ oprávnenia',
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: footerBg,
                border: Border(
                  top: BorderSide(color: borderColor, width: 1),
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Zrušiť'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _saveBuilder,
                    icon: const Icon(Icons.check_circle_rounded, size: 20),
                    label: const Text('Potvrdiť údaje'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
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

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppTheme.primaryRed.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primaryRed, size: 18),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryRed,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool required = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? customValidator,
    AutovalidateMode? autoValidateMode,
    Function(String)? onChanged,
    String? warningMessage, // ← NOVÉ
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasWarning = warningMessage != null;

    final labelColor = hasWarning
        ? Colors.orange
        : (isDark ? AppTheme.textLight : AppTheme.textDark);
    final fillColor = hasWarning
        ? Colors.orange.withOpacity(isDark ? 0.08 : 0.05)
        : (isDark ? AppTheme.darkCard : Colors.grey[50]);
    final defaultBorderColor = isDark ? Colors.white.withOpacity(0.1) : Colors.grey[300]!;
    final hintColor = isDark ? Colors.grey[600] : Colors.grey[500];
    final inputTextColor = isDark ? Colors.white : Colors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: labelColor,
              ),
            ),
            if (required)
              const Text(
                ' *',
                style: TextStyle(
                  color: AppTheme.primaryRed,
                  fontWeight: FontWeight.w600,
                ),
              ),
            // ← Oranžová ikonka upozornenia vedľa labelu
            if (hasWarning) ...[
              const SizedBox(width: 6),
              Tooltip(
                message: warningMessage,
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 16,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          autovalidateMode: autoValidateMode,
          onChanged: onChanged,
          style: TextStyle(color: inputTextColor),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: hintColor),
            filled: true,
            fillColor: fillColor,
            // ← Oranžový border keď je warning, inak normálny
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: hasWarning
                  ? const BorderSide(color: Colors.orange, width: 1.5)
                  : BorderSide(color: defaultBorderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: hasWarning
                  ? const BorderSide(color: Colors.orange, width: 2)
                  : const BorderSide(color: AppTheme.primaryRed, width: 2),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: defaultBorderColor),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            // ← Warning text pod poľom (oranžový)
            errorText: hasWarning ? warningMessage : null,
            errorStyle: hasWarning
                ? const TextStyle(color: Colors.orange, fontSize: 12)
                : null,
          ),
          validator: customValidator ??
              (required
                  ? (value) {
                if (value == null || value.isEmpty) {
                  return 'Toto pole je povinné';
                }
                return null;
              }
                  : null),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final labelColor = isDark ? AppTheme.textLight : AppTheme.textDark;
    final fillColor = isDark ? AppTheme.darkCard : Colors.grey[50];
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : Colors.grey[300]!;
    final dropdownTextColor = isDark ? Colors.white : Colors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          dropdownColor: isDark ? AppTheme.darkCard : Colors.white,
          style: TextStyle(color: dropdownTextColor),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(
                item,
                style: TextStyle(color: dropdownTextColor),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: fillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.primaryRed, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}