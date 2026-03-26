import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart' as app_auth;
import '../utils/app_theme.dart';

class UserProfileTab extends StatelessWidget {
  const UserProfileTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<app_auth.AuthProvider>(context);
    final user = authProvider.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) {
      return const Center(child: Text('Nie ste prihlásený'));
    }

    // ✅ OPRAVENÉ: SafeArea + správne constraints
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card
            _buildProfileCard(context, user, authProvider.userRole ?? 'user', isDark),
            const SizedBox(height: 32),

            // Account Section
            _buildSectionHeader(context, 'Účet', Icons.account_circle_outlined, isDark),
            const SizedBox(height: 16),
            _buildSettingCard(
              context,
              isDark,
              children: [
                _buildInfoTile(
                  context,
                  title: 'Email',
                  value: user.email ?? 'N/A',
                  icon: Icons.email_outlined,
                  isDark: isDark,
                ),
                const Divider(),
                _buildInfoTile(
                  context,
                  title: 'Rola',
                  value: authProvider.isAdmin ? 'Administrátor' : 'Používateľ',
                  icon: Icons.badge_outlined,
                  isDark: isDark,
                ),
                const Divider(),
                _buildInfoTile(
                  context,
                  title: 'Dátum registrácie',
                  value: _formatDate(user.metadata.creationTime),
                  icon: Icons.calendar_today_outlined,
                  isDark: isDark,
                ),
                const Divider(),
                _buildInfoTile(
                  context,
                  title: 'Posledné prihlásenie',
                  value: _formatDate(user.metadata.lastSignInTime),
                  icon: Icons.login_outlined,
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Security Section
            _buildSectionHeader(context, 'Zabezpečenie', Icons.security_outlined, isDark),
            const SizedBox(height: 16),
            _buildSettingCard(
              context,
              isDark,
              children: [
                _buildActionTile(
                  context,
                  title: 'Zmeniť heslo',
                  subtitle: 'Resetovať heslo cez email',
                  icon: Icons.lock_outline,
                  isDark: isDark,
                  onTap: () => _changePassword(context, user.email!),
                ),
              ],
            ),


            const SizedBox(height: 16),



            const SizedBox(height: 32),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _logout(context, authProvider),
                icon: const Icon(Icons.logout),
                label: const Text('Odhlásiť sa'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, firebase_auth.User user, String role, bool isDark) {
    final bgColor = isDark ? AppTheme.darkCard : AppTheme.white;
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _getInitials(user.email ?? ''),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName ?? user.email?.split('@')[0] ?? 'Používateľ',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email ?? '',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : AppTheme.textLight,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: role == 'admin'
                        ? AppTheme.primaryRed.withOpacity(0.1)
                        : Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    role == 'admin' ? 'Admin' : 'Používateľ',
                    style: TextStyle(
                      color: role == 'admin' ? AppTheme.primaryRed : Colors.blue,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 24, color: AppTheme.primaryRed),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : null,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingCard(BuildContext context, bool isDark, {required List<Widget> children}) {
    final bgColor = isDark ? AppTheme.darkCard : AppTheme.white;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.1) : AppTheme.borderColor;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoTile(
      BuildContext context, {
        required String title,
        required String value,
        required IconData icon,
        required bool isDark,
      }) {
    return ListTile(
      leading: Icon(icon, color: isDark ? Colors.white54 : AppTheme.textLight),
      title: Text(
        title,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      ),
      trailing: Text(
        value,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: isDark ? Colors.white70 : Colors.black54,
        ),
      ),
    );
  }

  Widget _buildActionTile(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required bool isDark,
        required VoidCallback onTap,
      }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryRed),
      title: Text(
        title,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: isDark ? Colors.white54 : Colors.grey[600],
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: isDark ? Colors.white54 : AppTheme.textLight,
      ),
      onTap: onTap,
    );
  }

  String _getInitials(String email) {
    if (email.isEmpty) return '?';
    return email[0].toUpperCase();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd.MM.yyyy HH:mm').format(date);
  }

  void _changePassword(BuildContext context, String email) async {
    try {
      await firebase_auth.FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email na reset hesla bol odoslaný na $email'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Chyba: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _logout(BuildContext context, app_auth.AuthProvider authProvider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Odhlásiť sa'),
        content: const Text('Naozaj sa chcete odhlásiť?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Zrušiť'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Odhlásiť'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await authProvider.logout();
    }
  }
}