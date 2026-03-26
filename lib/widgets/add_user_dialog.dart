import 'package:flutter/material.dart';
import '../services/admin_service.dart';
import '../utils/permission_helper.dart';
import '../utils/app_theme.dart';

class AddUserDialog extends StatefulWidget {
  final VoidCallback onUserAdded;

  const AddUserDialog({Key? key, required this.onUserAdded}) : super(key: key);

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final AdminService _adminService = AdminService();

  String _selectedRole = 'user';
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _adminService.createUser(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim().isEmpty
            ? null
            : _fullNameController.text.trim(),
        role: _selectedRole,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Používateľ úspešne vytvorený'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onUserAdded();
      }
    } catch (e) {
      await context.showPermissionErrorIfNeeded(e,
          actionName: "vytvorenie používateľa");

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Chyba: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
      title: Row(
        children: [
          Icon(Icons.person_add, color: AppTheme.primaryRed),
          const SizedBox(width: 12),
          Text(
            'Pridať nového používateľa',
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          ),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Email
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'user@example.com',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Zadajte email';
                    }
                    if (!value.contains('@')) {
                      return 'Neplatný email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Heslo',
                    hintText: 'Min. 6 znakov',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Zadajte heslo';
                    }
                    if (value.length < 6) {
                      return 'Heslo musí mať aspoň 6 znakov';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Full Name (optional)
                TextFormField(
                  controller: _fullNameController,
                  decoration: InputDecoration(
                    labelText: 'Celé meno (voliteľné)',
                    hintText: 'Ján Novák',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Role Selection
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : AppTheme.borderColor,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rola používateľa',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      RadioListTile<String>(
                        title: const Text('👤 Používateľ'),
                        subtitle: const Text('Základné oprávnenia'),
                        value: 'user',
                        groupValue: _selectedRole,
                        onChanged: (value) => setState(() => _selectedRole = value!),
                        activeColor: AppTheme.primaryRed,
                      ),
                      RadioListTile<String>(
                        title: const Text('👑 Administrátor'),
                        subtitle: const Text('Plný prístup k systému'),
                        value: 'admin',
                        groupValue: _selectedRole,
                        onChanged: (value) => setState(() => _selectedRole = value!),
                        activeColor: AppTheme.primaryRed,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Zrušiť'),
        ),
        ElevatedButton.icon(
          onPressed: _isLoading ? null : _submitForm,
          icon: _isLoading
              ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
              : const Icon(Icons.add),
          label: Text(_isLoading ? 'Vytváram...' : 'Vytvoriť'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryRed,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ],
    );
  }
}