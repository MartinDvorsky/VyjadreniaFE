import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart' as app_auth;
import '../utils/app_theme.dart';
import '../widgets/user_profile_tab.dart';
import '../widgets/admin_users_tab.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<app_auth.AuthProvider>(context, listen: false);
    // Ak je admin, má 2 taby, inak len 1
    _tabController = TabController(
      length: authProvider.isAdmin ? 2 : 1,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<app_auth.AuthProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Header s TabBar
        if (authProvider.isAdmin)
          Container(
            color: isDark ? AppTheme.darkCard : AppTheme.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppTheme.primaryRed,
              unselectedLabelColor: isDark ? Colors.white54 : AppTheme.textLight,
              indicatorColor: AppTheme.primaryRed,
              tabs: const [
                Tab(
                  icon: Icon(Icons.person_outline),
                  text: 'Môj profil',
                ),
                Tab(
                  icon: Icon(Icons.admin_panel_settings_outlined),
                  text: 'Správa používateľov',
                ),
              ],
            ),
          ),

        // Content
        Expanded(
          child: authProvider.isAdmin
              ? TabBarView(
            controller: _tabController,
            children: const [
              UserProfileTab(),
              AdminUsersTab(),
            ],
          )
              : const UserProfileTab(),
        ),
      ],
    );
  }
}