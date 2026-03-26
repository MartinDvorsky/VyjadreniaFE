import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vyjadrenia/utils/permission_helper.dart';
import '../models/building_purpose_model.dart';
import '../providers/building_purpose_provider.dart';
import '../utils/app_theme.dart';

class BuildingPurposeEditPanel extends StatefulWidget {
  final BuildingPurpose purpose;
  final VoidCallback onCancel;
  final VoidCallback onSaved;
  final VoidCallback onDeleted;

  const BuildingPurposeEditPanel({
    Key? key,
    required this.purpose,
    required this.onCancel,
    required this.onSaved,
    required this.onDeleted,
  }) : super(key: key);

  @override
  State<BuildingPurposeEditPanel> createState() =>
      _BuildingPurposeEditPanelState();
}

class _BuildingPurposeEditPanelState extends State<BuildingPurposeEditPanel> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _purposeNameController;
  late TextEditingController _textController;
  late String _selectedDocumentForm;
  bool _isModified = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  @override
  void didUpdateWidget(BuildingPurposeEditPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // ✅ Ak sa zmenil účel, reinicializuj controllery
    if (oldWidget.purpose.id != widget.purpose.id) {
      _purposeNameController.dispose();
      _textController.dispose();
      _initControllers();
      setState(() => _isModified = false);
    }
  }

  void _initControllers() {
    _purposeNameController =
        TextEditingController(text: widget.purpose.purposeName);
    _textController = TextEditingController(text: widget.purpose.text);
    _selectedDocumentForm = widget.purpose.documentForm;

    _purposeNameController.addListener(_onFieldChanged);
    _textController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (!_isModified) {
      setState(() => _isModified = true);
    }
  }

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

    // ✅ 2. Dynamické farby
    final containerBg = isDark ? AppTheme.darkCard : AppTheme.white;
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor;

    return Container(
      decoration: BoxDecoration(
        color: containerBg, // ✅
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1), // ✅
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      controller: _purposeNameController,
                      label: 'Názov účelu stavby',
                      icon: Icons.title_rounded,
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Text je povinný';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.edit_rounded,
              color: AppTheme.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Úprava účelu stavby',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'ID: ${widget.purpose.id}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          if (_isModified)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.edit_rounded, size: 14, color: AppTheme.white),
                  const SizedBox(width: 6),
                  Text(
                    'Upravené',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.white,
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
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.white70 : Colors.grey[600];

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: iconColor), // ✅
      ),
      validator: validator,
    );
  }

  Widget _buildTextAreaField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.white70 : Colors.grey[600];

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: iconColor), // ✅
        alignLabelWithHint: true,
      ),
      maxLines: 6,
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
        if (value != null && value != _selectedDocumentForm) {
          setState(() {
            _selectedDocumentForm = value;
            _isModified = true;
          });
        }
      },
    );
  }

  Widget _buildFooter() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: borderColor, width: 1), // ✅
        ),
      ),
      child: Row(
        children: [
          OutlinedButton.icon(
            onPressed: _showDeleteConfirmation,
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            label: const Text('Zmazať'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: BorderSide(color: Colors.red.shade300),
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: widget.onCancel,
            child: const Text('Zrušiť'),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: _isModified ? _handleSave : null,
            icon: const Icon(Icons.save_rounded, size: 18),
            label: const Text('Uložiť zmeny'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan.shade600,
            ),
          ),
        ],
      ),
    );
  }

  void _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<BuildingPurposeProvider>();
    final data = {
      'purpose_name': _purposeNameController.text.trim(),
      'text': _textController.text.trim(),
      'document_form': _selectedDocumentForm,
    };

    try {
      await provider.updatePurpose(widget.purpose.id, data);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text('Účel "${_purposeNameController.text}" bol aktualizovaný'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      setState(() => _isModified = false);
      widget.onSaved();
    } catch (e) {
      await context.showPermissionErrorIfNeeded(e,
          actionName: "aktualizovať účel stavby");
      if (!mounted) return;

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

  void _showDeleteConfirmation() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? AppTheme.darkBackground : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final warningBg = isDark ? const Color(0xFF2C1515) : Colors.red.shade50; // ✅

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: dialogBg, // ✅
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: warningBg, // ✅
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.warning_rounded,
                  color: Colors.red.shade600, size: 24),
            ),
            const SizedBox(width: 12),
            Text('Zmazať účel stavby?', style: TextStyle(color: textColor)), // ✅
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Naozaj chcete zmazať účel "${widget.purpose.purposeName}"?', style: TextStyle(color: textColor)), // ✅
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: warningBg, // ✅
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.red.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Táto operácia je nevratná!',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.red.shade700), // Červená je čitateľná na oboch
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Zrušiť'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _handleDelete();
            },
            icon: const Icon(Icons.delete, size: 18),
            label: const Text('Zmazať'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  void _handleDelete() async {
    final provider = context.read<BuildingPurposeProvider>();
    final name = widget.purpose.purposeName;

    try {
      await provider.deletePurpose(widget.purpose.id);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text('Účel "$name" bol zmazaný'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      widget.onDeleted();
    } catch (e) {
      await context.showPermissionErrorIfNeeded(e,
          actionName: "zmazanie účelu stavby");
      if (!mounted) return;
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
