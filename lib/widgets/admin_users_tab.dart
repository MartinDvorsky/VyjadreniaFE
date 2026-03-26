import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/admin_service.dart';
import '../models/user_model.dart';
import '../utils/app_theme.dart';
import '../widgets/add_user_dialog.dart';
import '../widgets/edit_role_dialog.dart';

class AdminUsersTab extends StatefulWidget {
  const AdminUsersTab({Key? key}) : super(key: key);

  @override
  State<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<AdminUsersTab> {
  final AdminService _adminService = AdminService();
  List<UserModel> _users = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await _adminService.getAllUsers();
      if (mounted) {
        setState(() {
          _users = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chyba pri načítaní: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  List<UserModel> get _filteredUsers {
    if (_searchQuery.isEmpty) return _users;
    return _users.where((user) {
      return user.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (user.fullName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    // ✅ OPRAVENÉ: Pridaný SafeArea a LayoutBuilder
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              // Header with search and add button
              Container(
                padding: const EdgeInsets.all(24),
                color: isDark ? AppTheme.darkCard : AppTheme.white,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            onChanged: (value) => setState(() => _searchQuery = value),
                            decoration: InputDecoration(
                              hintText: 'Hľadať používateľa...',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: () => _showAddUserDialog(),
                          icon: const Icon(Icons.add),
                          label: Text(isMobile ? 'Pridať' : 'Pridať používateľa'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryRed,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.people, size: 20, color: isDark ? Colors.white70 : AppTheme.textLight),
                        const SizedBox(width: 8),
                        Text(
                          'Celkovo ${_users.length} používateľov',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : AppTheme.textLight,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Users List
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredUsers.isEmpty
                    ? _buildEmptyState(isDark)
                    : isMobile
                    ? _buildMobileList(isDark)
                    : _buildDesktopTable(isDark),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: isDark ? Colors.white24 : Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty ? 'Žiadni používatelia' : 'Nenašli sa žiadni používatelia',
            style: TextStyle(
              color: isDark ? Colors.white54 : AppTheme.textLight,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // Mobile List View
  Widget _buildMobileList(bool isDark) {
    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredUsers.length,
        itemBuilder: (context, index) {
          final user = _filteredUsers[index];
          return _buildUserCard(user, isDark);
        },
      ),
    );
  }

  Widget _buildUserCard(UserModel user, bool isDark) {
    final bgColor = isDark ? AppTheme.darkCard : AppTheme.white;
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    user.email[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName ?? user.email.split('@')[0],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white70 : AppTheme.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(user.isActive, isDark),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildRoleBadge(user.isSuperuser, isDark),
              Text(
                DateFormat('dd.MM.yyyy').format(user.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white54 : Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showEditRoleDialog(user),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Rola'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryRed,
                    side: BorderSide(color: AppTheme.primaryRed),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _toggleUserStatus(user),
                  icon: Icon(user.isActive ? Icons.block : Icons.check_circle, size: 16),
                  label: Text(user.isActive ? 'Deaktivovať' : 'Aktivovať'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: user.isActive ? Colors.orange : Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Desktop Table View
  Widget _buildDesktopTable(bool isDark) {
    final bgColor = isDark ? AppTheme.darkCard : AppTheme.white;
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          children: [
            // Table Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  const Expanded(flex: 3, child: Text('Používateľ', style: TextStyle(fontWeight: FontWeight.bold))),
                  const Expanded(flex: 2, child: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
                  const Expanded(flex: 1, child: Text('Rola', style: TextStyle(fontWeight: FontWeight.bold))),
                  const Expanded(flex: 1, child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                  const Expanded(flex: 2, child: Text('Dátum reg.', style: TextStyle(fontWeight: FontWeight.bold))),
                  const Expanded(flex: 2, child: Text('Akcie', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
            ),
            // Table Rows
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredUsers.length,
              itemBuilder: (context, index) {
                final user = _filteredUsers[index];
                return _buildTableRow(user, isDark);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableRow(UserModel user, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor,
          ),
        ),
      ),
      child: Row(
        children: [
          // User
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      user.email[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    user.fullName ?? user.email.split('@')[0],
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Email
          Expanded(
            flex: 2,
            child: Text(
              user.email,
              style: TextStyle(color: isDark ? Colors.white70 : AppTheme.textLight),
            ),
          ),
          // Role
          Expanded(flex: 1, child: _buildRoleBadge(user.isSuperuser, isDark)),
          // Status
          Expanded(flex: 1, child: _buildStatusBadge(user.isActive, isDark)),
          // Date
          Expanded(
            flex: 2,
            child: Text(
              DateFormat('dd.MM.yyyy').format(user.createdAt),
              style: TextStyle(color: isDark ? Colors.white70 : AppTheme.textLight),
            ),
          ),
          // Actions
          Expanded(
            flex: 2,
            child: Row(
              children: [
                IconButton(
                  onPressed: () => _showEditRoleDialog(user),
                  icon: const Icon(Icons.edit),
                  tooltip: 'Zmeniť rolu',
                  color: AppTheme.primaryRed,
                ),
                IconButton(
                  onPressed: () => _toggleUserStatus(user),
                  icon: Icon(user.isActive ? Icons.block : Icons.check_circle),
                  tooltip: user.isActive ? 'Deaktivovať' : 'Aktivovať',
                  color: user.isActive ? Colors.orange : Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(bool isAdmin, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isAdmin
            ? AppTheme.primaryRed.withOpacity(0.1)
            : Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isAdmin ? 'Admin' : 'User',
        style: TextStyle(
          color: isAdmin ? AppTheme.primaryRed : Colors.blue,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isActive ? 'Aktívny' : 'Neaktívny',
        style: TextStyle(
          color: isActive ? Colors.green : Colors.red,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (context) => AddUserDialog(onUserAdded: _loadUsers),
    );
  }

  void _showEditRoleDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => EditRoleDialog(user: user, onRoleChanged: _loadUsers),
    );
  }

  Future<void> _toggleUserStatus(UserModel user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.isActive ? 'Deaktivovať používateľa' : 'Aktivovať používateľa'),
        content: Text(
          user.isActive
              ? 'Naozaj chcete deaktivovať ${user.email}? Používateľ sa nebude môcť prihlásiť.'
              : 'Naozaj chcete aktivovať ${user.email}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Zrušiť'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: user.isActive ? Colors.orange : Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text(user.isActive ? 'Deaktivovať' : 'Aktivovať'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _adminService.toggleUserStatus(user.id, !user.isActive);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(user.isActive ? 'Používateľ deaktivovaný' : 'Používateľ aktivovaný'),
              backgroundColor: Colors.green,
            ),
          );
          _loadUsers();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Chyba: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }
}