import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vyjadrenia/utils/permission_helper.dart';
import '../providers/building_purpose_provider.dart';
import '../utils/app_theme.dart';

class BuildingPurposeCreateDialog extends StatefulWidget {
  const BuildingPurposeCreateDialog({Key? key}) : super(key: key);

  @override
  State<BuildingPurposeCreateDialog> createState() =>
      _BuildingPurposeCreateDialogState();
}

class _BuildingPurposeCreateDialogState
    extends State<BuildingPurposeCreateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _purposeNameController = TextEditingController();
  final _textController = TextEditingController();
  String _selectedDocumentForm = 'old';
  bool _isLoading = false;

  @override
  void dispose() {
    _purposeNameController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ 1. Zisti tému
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? AppTheme.darkBackground : Colors.white;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: dialogBg, // ✅ Nastav pozadie
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _purposeNameController,
                        label: 'Názov účelu stavby',
                        icon: Icons.title_rounded,
                        hint: 'napr. Rodinný dom',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Názov je povinný';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildDocumentFormDropdown(),
                      const SizedBox(height: 16),
                      _buildTextAreaField(
                        controller: _textController,
                        label: 'Text / Šablóna',
                        icon: Icons.notes_rounded,
                        hint: 'Zadajte textovú šablónu pre tento účel',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Text je povinný';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.withOpacity(0.2)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline, size: 18, color: Colors.blue.shade600),
                            const SizedBox(width: 8),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.blue.shade200 : Colors.blue.shade900,
                                    height: 1.4,
                                  ),
                                  children: const [
                                    TextSpan(text: 'Tento text bude použitý v univerzálnych šablónach pre inžinierske siete a úrady vo vete:\n\n'),
                                    TextSpan(
                                      text: '"Žiadame Vás o vyjadrenie k vyššie uvedenej stavbe prebiehajúcej v katastrálnom území KAT_UXX mesta/obce MESTOXX z hľadiska uloženia inžinierskych sieti, ktoré bude slúžiť pre účely ',
                                      style: TextStyle(fontStyle: FontStyle.italic),
                                    ),
                                    TextSpan(
                                      text: '[TU ZADANÝ TEXT]',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                                    ),
                                    TextSpan(
                                      text: '."',
                                      style: TextStyle(fontStyle: FontStyle.italic),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.cyan.shade400, Colors.cyan.shade600],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.add_rounded,
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
                  'Nový účel stavby',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Vyplňte údaje o účele stavby',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    String? Function(String?)? validator,
  }) {
    // TextField dedí farby z Theme, ale ikony treba ošetriť
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.white70 : Colors.grey[600];

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: iconColor), // ✅
      ),
      validator: validator,
    );
  }

  Widget _buildTextAreaField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.white70 : Colors.grey[600];

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: iconColor), // ✅
        alignLabelWithHint: true,
      ),
      maxLines: 5,
      validator: validator,
    );
  }

  Widget _buildDocumentFormDropdown() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.white70 : Colors.grey[600];
    final textColor = isDark ? Colors.white : Colors.black;
    final dropdownBg = isDark ? AppTheme.darkCard : Colors.white;

    return DropdownButtonFormField<String>(
      value: _selectedDocumentForm,
      decoration: InputDecoration(
        labelText: 'Forma dokumentu',
        prefixIcon: Icon(Icons.description_rounded, size: 20, color: iconColor), // ✅
      ),
      dropdownColor: dropdownBg, // ✅
      items: [
        DropdownMenuItem(
          value: 'old',
          child: Text('Stará forma', style: TextStyle(color: textColor)), // ✅
        ),
        DropdownMenuItem(
          value: 'new',
          child: Text('Nová forma', style: TextStyle(color: textColor)), // ✅
        ),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedDocumentForm = value);
        }
      },
    );
  }

  Widget _buildFooter() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: borderColor, width: 1), // ✅
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
            child: const Text('Zrušiť'),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _handleCreate,
            icon: _isLoading
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white),
            )
                : const Icon(Icons.add_rounded, size: 18),
            label: Text(_isLoading ? 'Vytvára sa...' : 'Vytvoriť'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan.shade600,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _handleCreate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final data = {
      'purpose_name': _purposeNameController.text.trim(),
      'text': _textController.text.trim(),
      'document_form': _selectedDocumentForm,
    };

    try {
      final provider = context.read<BuildingPurposeProvider>();
      await provider.createPurpose(data);

      if (!mounted) return;
      Navigator.of(context).pop(true);

      // ✅ SnackBar po zatvorení dialógu
      Future.delayed(Duration.zero, () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text('Účel "${data['purpose_name']}" bol vytvorený'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      });
    } catch (e) {
      await context.showPermissionErrorIfNeeded(e,
          actionName: 'vytváranie nového účelu stavby');
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('Chyba: $e')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
