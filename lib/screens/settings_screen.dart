// lib/screens/settings_screen.dart

import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:vyjadrenia/utils/app_theme.dart';
import 'package:vyjadrenia/widgets/ai_usage_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Settings values
  bool _autoSaveEnabled = true;
  bool _notificationsEnabled = true;
  bool _emailNotifications = false;
  String _selectedLanguage = 'SK';
  String _dateFormat = 'DD/MM/YYYY';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Usage Widget
          const AIUsageWidget(),
          const SizedBox(height: 32),

          // Appearance Section
          _buildSectionHeader(
            'Vzhľad',
            Icons.palette_outlined,
          ),
          const SizedBox(height: 16),
          _buildSettingCard(
            children: [
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return _buildSwitchTile(
                    title: 'Tmavý režim',
                    subtitle: 'Aktivovať tmavý vzhľad',
                    value: themeProvider.isDarkMode,
                    onChanged: (val) async {
                      await themeProvider.toggleTheme();
                    },
                    icon: Icons.dark_mode_outlined,
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 32),

          // System Info Section
          _buildSectionHeader(
            'Systémové informácie',
            Icons.info_outline,
          ),
          const SizedBox(height: 16),
          _buildSettingCard(
            children: [
              _buildInfoTile(
                title: 'Verzia aplikácie',
                value: '1.0.0-beta',
                icon: Icons.apps,
              ),
              const Divider(),
              _buildInfoTile(
                title: 'Backend API',
                value: 'v1.0',
                icon: Icons.api,
              ),
              const Divider(),
              _buildInfoTile(
                title: 'Database',
                value: 'PostgreSQL 15',
                icon: Icons.storage,
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Support Section
          _buildSectionHeader(
            'Podpora',
            Icons.help_outline,
          ),
          const SizedBox(height: 16),
          _buildSettingCard(
            children: [
              _buildActionTile(
                title: 'Dokumentácia',
                subtitle: 'Návod na používanie',
                icon: Icons.menu_book,
                onTap: () => _openDocumentation(),
              ),
              const Divider(),
              _buildActionTile(
                title: 'Nahlásiť chybu',
                subtitle: 'Pošlite nám feedback',
                icon: Icons.bug_report,
                onTap: () => _reportBug(),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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

  Widget _buildSettingCard({required List<Widget> children}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.darkCard : AppTheme.white;
    final borderColor =
    isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryRed,
      ),
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String value,
    required IconData icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading:
      Icon(icon, color: isDark ? Colors.white54 : AppTheme.textLight),
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

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppTheme.primaryRed),
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

  void _openDocumentation() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Otváram dokumentáciu...')),
    );
  }

  void _reportBug() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Formulár na hlásenie chýb v príprave...')),
    );
  }
}
