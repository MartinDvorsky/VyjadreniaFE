import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vyjadrenia/utils/permission_helper.dart';
import '../models/project_designer_model.dart';
import '../providers/project_designer_edit_provider.dart';
import '../utils/app_theme.dart';

class ProjectDesignerEditPanel extends StatefulWidget {
  final ProjectDesigner designer;
  final VoidCallback onCancel;
  final VoidCallback onSaved;
  final VoidCallback onDeleted;

  const ProjectDesignerEditPanel({
    Key? key,
    required this.designer,
    required this.onCancel,
    required this.onSaved,
    required this.onDeleted,
  }) : super(key: key);

  @override
  State<ProjectDesignerEditPanel> createState() =>
      _ProjectDesignerEditPanelState();
}

class _ProjectDesignerEditPanelState extends State<ProjectDesignerEditPanel> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _cityController;
  late TextEditingController _addressController;
  late TextEditingController _licenseController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  bool _isModified = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    _nameController = TextEditingController(text: widget.designer.name);
    _cityController = TextEditingController(text: widget.designer.city);
    _addressController = TextEditingController(text: widget.designer.address);
    _licenseController = TextEditingController(text: widget.designer.license);
    _emailController = TextEditingController(text: widget.designer.email);
    _phoneController = TextEditingController(text: widget.designer.phone ?? '');

    // Sleduj zmeny
    _nameController.addListener(_onFieldChanged);
    _cityController.addListener(_onFieldChanged);
    _addressController.addListener(_onFieldChanged);
    _licenseController.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (!_isModified) {
      setState(() => _isModified = true);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _licenseController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                      controller: _nameController,
                      label: 'Meno projektanta',
                      icon: Icons.person_rounded,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Meno je povinné';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _licenseController,
                      label: 'Licenčné číslo',
                      icon: Icons.badge_rounded,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Licencia je povinná';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _cityController,
                      label: 'Mesto',
                      icon: Icons.location_city_rounded,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Mesto je povinné';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _addressController,
                      label: 'Adresa',
                      icon: Icons.location_on_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Adresa je povinná';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email je povinný';
                        }
                        if (!value.contains('@')) {
                          return 'Neplatný email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Telefón (voliteľné)',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
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
          colors: [Colors.amber.shade400, Colors.amber.shade600],
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
                  'Úprava projektanta',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'ID: ${widget.designer.id}',
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
                  Icon(
                    Icons.edit_rounded,
                    size: 14,
                    color: AppTheme.white,
                  ),
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
    TextInputType? keyboardType,
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
      keyboardType: keyboardType,
      validator: validator,
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
          // Delete button
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
          // Cancel button
          TextButton(
            onPressed: widget.onCancel,
            child: const Text('Zrušiť'),
          ),
          const SizedBox(width: 12),
          // Save button
          ElevatedButton.icon(
            onPressed: _isModified ? _handleSave : null,
            icon: const Icon(Icons.save_rounded, size: 18),
            label: const Text('Uložiť zmeny'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade600,
            ),
          ),
        ],
      ),
    );
  }

  void _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ProjectDesignerEditProvider>();
    final data = {
      'name': _nameController.text.trim(),
      'city': _cityController.text.trim(),
      'address': _addressController.text.trim(),
      'license': _licenseController.text.trim(),
      'email': _emailController.text.trim(),
      if (_phoneController.text.trim().isNotEmpty)
        'phone': _phoneController.text.trim(),
    };

    try {
      await provider.updateDesigner(widget.designer.id, data);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text('Projektant "${_nameController.text}" bol aktualizovaný'),
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
          actionName: "upraviť projektanta");

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
    final warningBg = isDark ? const Color(0xFF2C1515) : Colors.red.shade50;
    final warningBorder = isDark ? Colors.red.shade900 : Colors.red.shade200;

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
            Text('Zmazať projektanta?', style: TextStyle(color: textColor)), // ✅
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Naozaj chcete zmazať projektanta "${widget.designer.name}"?',
              style: TextStyle(color: textColor), // ✅
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: warningBg, // ✅
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: warningBorder), // ✅
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      size: 16, color: Colors.red.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Táto operácia je nevratná!',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.red.shade200 : Colors.black87), // ✅
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
    final provider = context.read<ProjectDesignerEditProvider>();
    final name = widget.designer.name;

    try {
      await provider.deleteDesigner(widget.designer.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text('Projektant "$name" bol zmazaný'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      widget.onDeleted();
    } catch (e) {
      await context.showPermissionErrorIfNeeded(e,
          actionName: "zmazanie projektanta");
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
