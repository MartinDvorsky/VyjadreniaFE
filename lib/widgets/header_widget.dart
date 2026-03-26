import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

class HeaderWidget extends StatelessWidget {
  final String title;
  final bool sidebarOpen;
  final bool isMobile; // ✅ NOVÝ parameter
  final VoidCallback onMenuToggle;

  const HeaderWidget({
    Key? key,
    required this.title,
    required this.sidebarOpen,
    required this.isMobile, // ✅ NOVÝ parameter
    required this.onMenuToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final firebaseUser = authProvider.currentUser;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final iconColor = isDark ? Colors.white : AppTheme.textDark;

        return Container(
          height: 72,
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : AppConstants.largePadding, // ✅ Responzívny padding
          ),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurface : AppTheme.white,
            boxShadow: [
              BoxShadow(
                color: AppTheme.cardShadow,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: onMenuToggle,
                icon: Icon(
                  isMobile
                      ? Icons.menu_rounded // ✅ Na mobile vždy menu ikona (otvorí drawer)
                      : (sidebarOpen ? Icons.menu_open_rounded : Icons.menu_rounded),
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded( // ✅ Pridané Expanded aby text nezaberá priveľa miesta
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: isDark ? Colors.white : AppTheme.textDark,
                    fontSize: isMobile ? 18 : 20, // ✅ Menší text na mobile
                  ),
                  overflow: TextOverflow.ellipsis, // ✅ Skrátiť text ak je príliš dlhý
                ),
              ),
              const Spacer(),
              _buildProfileWidget(context, firebaseUser, authProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileWidget(
      BuildContext context, dynamic firebaseUser, AuthProvider authProvider) {
    if (firebaseUser == null) {
      return TextButton(
        onPressed: () {
          print("Navigácia na prihlasovaciu obrazovku...");
        },
        child: const Text('Prihlásiť sa', style: TextStyle(color: AppTheme.primaryRed)),
      );
    }

    final String initials = (firebaseUser.displayName != null &&
        firebaseUser.displayName!.isNotEmpty)
        ? firebaseUser.displayName!
        .split(' ')
        .map((name) => name[0])
        .join()
        .toUpperCase()
        .substring(0, 2)
        : (firebaseUser.email != null && firebaseUser.email!.isNotEmpty)
        ? firebaseUser.email![0].toUpperCase()
        : 'U';

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopupMenuButton<String>(
      tooltip: 'Profil používateľa',
      offset: const Offset(0, 50),
      color: isDark ? AppTheme.darkCard : AppTheme.white,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryRed.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: CircleAvatar(
          radius: isMobile ? 18 : 20, // ✅ Menší avatar na mobile
          backgroundColor: Colors.transparent,
          child: Text(
            initials,
            style: TextStyle(
              color: AppTheme.white,
              fontSize: isMobile ? 14 : 16, // ✅ Menší text na mobile
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                firebaseUser.displayName ?? 'Používateľ',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                firebaseUser.email ?? 'email@example.com',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.white70 : AppTheme.textMedium,
                ),
              ),
              Divider(height: 16, color: isDark ? Colors.white10 : Colors.grey[200]),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              const Icon(Icons.logout, color: AppTheme.primaryRed),
              const SizedBox(width: 8),
              Text(
                'Odhlásiť sa',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isDark ? Colors.white : AppTheme.textDark,
                ),
              ),
            ],
          ),
        ),
      ],
      onSelected: (String value) {
        if (value == 'logout') {
          authProvider.logout();
        }
      },
    );
  }
}
