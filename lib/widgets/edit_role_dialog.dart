import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/admin_service.dart';
import '../utils/permission_helper.dart';
import '../utils/app_theme.dart';

class EditRoleDialog extends StatefulWidget {
  final UserModel user;
  final VoidCallback onRoleChanged;

  const EditRoleDialog({
    Key? key,
    required this.user,
    required this.onRoleChanged,
  }) : super(key: key);

  @override
  State<EditRoleDialog> createState() => _EditRoleDialogState();
}

class _EditRoleDialogState extends State<EditRoleDialog> {
  final AdminService _adminService = AdminService();
  late String _selectedRole;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.user.isSuperuser ? 'admin' : 'user';
  }

  Future<void> _submitForm() async {
    // Ak sa rola nezmenila, zatvor dialog
    final currentRole = widget.user.isSuperuser ? 'admin' : 'user';
    if (_selectedRole == currentRole) {
      Navigator.pop(context);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _adminService.updateUserRole(widget.user.id, _selectedRole);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Rola používateľa ${widget.user.email} bola zmenená na $_selectedRole',
            ),
            backgroundColor: Colors.green,
          ),
        );
        widget.onRoleChanged();
      }
    } catch (e) {
      await context.showPermissionErrorIfNeeded(e,
          actionName: "zmena roly používateľa");

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
          Icon(Icons.edit, color: AppTheme.primaryRed),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Zmeniť rolu používateľa',
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info
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
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        widget.user.email[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.user.fullName ?? widget.user.email.split('@')[0],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.user.email,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white70 : AppTheme.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Role Selection
            Text(
              'Vyberte novú rolu',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
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

            // Warning
            if (_selectedRole != (widget.user.isSuperuser ? 'admin' : 'user'))
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.orange, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedRole == 'admin'
                            ? 'Používateľ bude mať prístup ku všetkým funkciám'
                            : 'Používateľ stratí administrátorské oprávnenia',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
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
              : const Icon(Icons.save),
          label: Text(_isLoading ? 'Ukladám...' : 'Uložiť'),
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