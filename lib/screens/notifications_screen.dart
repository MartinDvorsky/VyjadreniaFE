import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/processing_animations.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  List<NotificationModel> _allNotifications = [];
  List<NotificationModel> _filteredNotifications = [];
  bool _isLoading = true;
  String _selectedFilter = 'upcoming'; // upcoming, completed, all
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    print('📱 NotificationsScreen initState() - štartuje');
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    print('🔄 _loadNotifications() - začínam');
    setState(() => _isLoading = true);

    try {
      print('📡 Volám _notificationService.getAllNotifications()...');
      final notifications = await _notificationService.getAllNotifications();
      print('✅ Načítané ${notifications.length} notifikácií');

      if (mounted) {
        setState(() {
          _allNotifications = notifications;
          _applyFilters();
          _isLoading = false;
        });
      }
      print('📊 Po filtrovaní: ${_filteredNotifications.length} notifikácií');
    } catch (e, stackTrace) {
      print('❌ CHYBA pri načítaní notifikácií: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar('Nepodarilo sa načítať notifikácie: $e');
      }
    }
  }

  void _applyFilters() {
    List<NotificationModel> filtered = _allNotifications;

    // Filter podľa typu
    switch (_selectedFilter) {
      case 'upcoming':
      // Nadchádzajúce - notifikácie s budúcim termínom (1. alebo 2.)
        filtered = filtered.where((n) {
          if (n.done) return false;
          final now = DateTime.now();
          // Skontroluj či existuje budúci termín
          final hasUpcoming = (n.firstnotification != null &&
              n.firstnotification!.isAfter(now)) ||
              (n.secondnotification != null &&
                  n.secondnotification!.isAfter(now));
          return hasUpcoming;
        }).toList();
        // Zoraď podľa najbližšieho dátumu
        filtered.sort((a, b) {
          final aDates = [
            if (a.firstnotification != null) a.firstnotification!,
            if (a.secondnotification != null) a.secondnotification!,
          ];
          final bDates = [
            if (b.firstnotification != null) b.firstnotification!,
            if (b.secondnotification != null) b.secondnotification!,
          ];
          final aNearest = aDates.isNotEmpty
              ? aDates.reduce((a, b) => a.isBefore(b) ? a : b)
              : DateTime(2099);
          final bNearest = bDates.isNotEmpty
              ? bDates.reduce((a, b) => a.isBefore(b) ? a : b)
              : DateTime(2099);
          return aNearest.compareTo(bNearest);
        });
        break;
      case 'completed':
      // Ukončené
        filtered = filtered.where((n) => n.done).toList();
        break;
      case 'all':
      // Všetky - bez zmeny
        break;
    }

    // Filter podľa vyhľadávania
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((n) {
        return n.znacka.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            n.nazovstavby.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    setState(() {
      _filteredNotifications = filtered;
    });
  }

  Future<void> _markAsComplete(int id) async {
    try {
      await _notificationService.markAsComplete(id);
      _showSuccessSnackBar('Notifikácia označená ako ukončená');
      _loadNotifications();
    } catch (e) {
      _showErrorSnackBar('Chyba pri označovaní: $e');
    }
  }

  Future<void> _deleteNotification(int id) async {
    final confirm = await _showDeleteConfirmDialog();
    if (confirm != true) return;

    try {
      await _notificationService.deleteNotification(id);
      _showSuccessSnackBar('Notifikácia vymazaná');
      _loadNotifications();
    } catch (e) {
      _showErrorSnackBar('Chyba pri mazaní: $e');
    }
  }

  Future<bool?> _showDeleteConfirmDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkCard : Colors.white, // ✅
        title: Text('Potvrdiť vymazanie',
            style: TextStyle(color: isDark ? Colors.white : Colors.black)), // ✅
        content: Text('Naozaj chcete vymazať túto notifikáciu?',
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)), // ✅
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Zrušiť'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryRed,
            ),
            child: const Text('Vymazať'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.primaryRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('🎨 NotificationsScreen build() - rendering');
    print(' _isLoading: $_isLoading');
    print(' _filteredNotifications.length: ${_filteredNotifications.length}');

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightGray, // ✅
      body: Column(
        children: [
          _buildHeader(),
          _buildFilters(),
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _filteredNotifications.isEmpty
                ? _buildEmptyState()
                : _buildNotificationsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final activeCount = _allNotifications.where((n) => !n.done).length;
    final upcomingCount = _allNotifications
        .where((n) => !n.done && n.hasUpcomingNotification)
        .length;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.darkSurface : AppTheme.white;
    final border = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor;

    return Container(
      padding: const EdgeInsets.all(AppConstants.largePadding),
      decoration: BoxDecoration(
        color: bg, // ✅
        border: Border(
          bottom: BorderSide(color: border, width: 1), // ✅
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifikácie',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: isDark ? Colors.white : null, // ✅
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$activeCount aktívnych • $upcomingCount nadchádzajúcich',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _loadNotifications,
            icon: Icon(Icons.refresh_rounded,
                color: isDark ? Colors.white70 : null), // ✅
            tooltip: 'Obnoviť',
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.darkCard : AppTheme.lightGray;
    final border = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor;
    final fieldBg = isDark ? AppTheme.darkSurface : AppTheme.white;

    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: bg, // ✅
        border: Border(
          bottom: BorderSide(color: border, width: 1), // ✅
        ),
      ),
      child: Column(
        children: [
          // Vyhľadávanie
          TextField(
            decoration: InputDecoration(
              hintText: 'Hľadať podľa značky alebo názvu stavby...',
              hintStyle: TextStyle(color: isDark ? Colors.white54 : null), // ✅
              prefixIcon: Icon(Icons.search_rounded,
                  color: isDark ? Colors.white54 : null), // ✅
              filled: true,
              fillColor: fieldBg, // ✅
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: border), // ✅
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: border), // ✅
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
                _applyFilters();
              });
            },
          ),
          const SizedBox(height: 12),
          // Filter tlačidlá
          Row(
            children: [
              _buildFilterChip(
                'Nadchádzajúce',
                'upcoming',
                _getUpcomingCount(),
                color: Colors.blue,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                'Ukončené',
                'completed',
                _allNotifications.where((n) => n.done).length,
                color: Colors.green,
              ),
              const SizedBox(width: 8),
              _buildFilterChip('Všetky', 'all', _allNotifications.length),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, int count,
      {Color? color}) {
    final isSelected = _selectedFilter == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Chip Colors
    final bg = isDark ? AppTheme.darkSurface : AppTheme.white;
    final textColor = isDark ? Colors.white : AppTheme.textDark;

    return FilterChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
          _applyFilters();
        });
      },
      backgroundColor: bg, // ✅
      selectedColor: (color ?? AppTheme.primaryRed).withOpacity(0.1),
      checkmarkColor: color ?? AppTheme.primaryRed,
      labelStyle: TextStyle(
        color: isSelected ? (color ?? AppTheme.primaryRed) : textColor, // ✅
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      ),
      side: isSelected ? BorderSide.none : BorderSide(color: isDark ? Colors.white10 : Colors.grey[300]!), // ✅
    );
  }

  Widget _buildLoadingState() {
    print('⏳ Zobrazujem loading state');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppTheme.primaryRed),
          ),
          const SizedBox(height: 16),
          Text(
            'Načítavam notifikácie...',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: isDark ? Colors.white70 : null, // ✅
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    print('📭 Zobrazujem empty state');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 80,
            color: isDark ? Colors.grey[700] : AppTheme.textLight, // ✅
          ),
          const SizedBox(height: 16),
          Text(
            'Žiadne notifikácie',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: isDark ? Colors.white : null, // ✅
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Momentálne nemáte žiadne notifikácie',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    print(
        '📋 Zobrazujem list notifikácií: ${_filteredNotifications.length} položiek');
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: _filteredNotifications.length,
      itemBuilder: (context, index) {
        print(
            ' → Renderujem notifikáciu #$index: ${_filteredNotifications[index].znacka}');
        return _buildNotificationCard(_filteredNotifications[index]);
      },
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    final dateFormat = DateFormat('dd.MM.yyyy');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Card Colors
    final cardBg = isDark ? AppTheme.darkCard : Colors.white;
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor;
    final titleColor = isDark ? Colors.white : null;
    final subtitleColor = isDark ? Colors.white70 : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: cardBg, // ✅
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: 1), // ✅
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Status ikona
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getStatusColor(notification).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getStatusIcon(notification),
                    color: _getStatusColor(notification),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                // Hlavné info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.znacka,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: titleColor, // ✅
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.nazovstavby,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: subtitleColor, // ✅
                        ),
                      ),
                    ],
                  ),
                ),
                // Akcie
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert_rounded,
                      color: isDark ? Colors.white70 : null), // ✅
                  color: isDark ? AppTheme.darkSurface : Colors.white, // ✅
                  itemBuilder: (context) => [
                    if (!notification.done)
                      const PopupMenuItem<String>(
                        value: 'complete',
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_outline_rounded, size: 20),
                            SizedBox(width: 8),
                            Text('Označiť ako ukončené'),
                          ],
                        ),
                      ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded,
                              size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Vymazať', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'complete') {
                      _markAsComplete(notification.id);
                    } else if (value == 'delete') {
                      _deleteNotification(notification.id);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: borderColor), // ✅
            const SizedBox(height: 12),
            // Termíny notifikácií
            Row(
              children: [
                Expanded(
                  child: _buildNotificationDate(
                    'Prvá notifikácia',
                    notification.firstnotification,
                    notification,
                    true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildNotificationDate(
                    'Druhá notifikácia',
                    notification.secondnotification,
                    notification,
                    false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Vytvorené
            Text(
              'Vytvorené: ${dateFormat.format(notification.createdAt)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationDate(String label, DateTime? date,
      NotificationModel notification, bool isFirst) {
    final dateFormat = DateFormat('dd.MM.yyyy');
    final isOverdue = date != null && DateTime.now().isAfter(date);
    final showCompletedLabel = isFirst && notification.done && isOverdue;
    // "Odoslané" sa zobrazí, keď termín uplynul ale ešte nie je označené ako ukončené
    final showSentLabel = isFirst && !notification.done && isOverdue;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final boxBg = isDark ? AppTheme.darkSurface : AppTheme.lightGray;
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor;
    final dateColor = isDark ? Colors.white : AppTheme.textDark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: boxBg, // ✅
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor, // ✅
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 14,
                color: AppTheme.textLight,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            date != null ? dateFormat.format(date) : 'Nenastavené',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: dateColor, // ✅
            ),
          ),
          if (showSentLabel) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.primaryRed,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Odoslané',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ] else if (showCompletedLabel) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Ukončené',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  int _getUpcomingCount() {
    final now = DateTime.now();
    return _allNotifications.where((n) {
      if (n.done) return false;
      // Skontroluj či existuje budúci termín
      final hasUpcoming = (n.firstnotification != null &&
          n.firstnotification!.isAfter(now)) ||
          (n.secondnotification != null && n.secondnotification!.isAfter(now));
      return hasUpcoming;
    }).length;
  }

  Color _getStatusColor(NotificationModel notification) {
    if (notification.done) return Colors.green;
    return Colors.blue;
  }

  IconData _getStatusIcon(NotificationModel notification) {
    if (notification.done) return Icons.check_circle_rounded;
    return Icons.schedule_rounded;
  }
}
