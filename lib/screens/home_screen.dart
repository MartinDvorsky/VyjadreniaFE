import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vyjadrenia/providers/generate_provider.dart';
import 'package:vyjadrenia/screens/database_screen.dart';
import 'package:vyjadrenia/screens/generate_screen.dart';
import 'package:vyjadrenia/screens/notifications_screen.dart';
import 'package:vyjadrenia/screens/profile_screen.dart';
import 'package:vyjadrenia/screens/settings_screen.dart';
import '../models/menu_model.dart';
import '../widgets/sidebar_menu.dart';
import '../widgets/header_widget.dart';
import '../widgets/feature_card.dart';
import '../widgets/processing_animations.dart';
import '../utils/constants.dart';
import '../services/statistics_service.dart';
import '../features/chat/presentation/chat_notifier.dart';
import '../features/chat/presentation/chat_panel.dart';
import '../utils/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String activeMenuId = 'home';
  bool sidebarOpen = true;
  final StatisticsService _statisticsService = StatisticsService();
  HomeStatistics? _statistics;
  bool _isLoadingStats = true;

  // ✅ PRIDANÉ: GlobalKey pre Scaffold (kvôli openDrawer)
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoadingStats = true;
    });
    try {
      final stats = await _statisticsService.getHomeStatistics();
      if (mounted) {
        setState(() {
          _statistics = stats;
          _isLoadingStats = false;
        });
      }
      print('✅ Štatistiky načítané: $stats');
    } catch (e) {
      print('❌ Chyba pri načítaní štatistík: $e');
      if (mounted) {
        setState(() {
          _isLoadingStats = false;
        });
      }
    }
  }

  final List<MenuItem> menuItems = [
    MenuItem(
      id: 'home',
      label: AppConstants.menuHome,
      icon: Icons.home_rounded,
      description: AppConstants.descHome,
    ),
    MenuItem(
      id: 'generate',
      label: AppConstants.menuGenerate,
      icon: Icons.description_rounded,
      description: AppConstants.descGenerate,
    ),
    MenuItem(
      id: 'database',
      label: AppConstants.menuDatabase,
      icon: Icons.storage_rounded,
      description: AppConstants.descDatabase,
    ),
    MenuItem(
      id: 'notifications',
      label: AppConstants.menuNotifications,
      icon: Icons.notifications_rounded,
      description: AppConstants.descNotifications,
    ),
    MenuItem(
      id: 'settings',
      label: AppConstants.menuSettings,
      icon: Icons.settings_rounded,
      description: AppConstants.descSettings,
    ),
    MenuItem(
      id: 'profile',
      label: AppConstants.menuProfile,
      icon: Icons.person_rounded,
      description: AppConstants.descProfile,
    ),
  ];

  void _handleMenuSelection(String menuId) {
    setState(() {
      activeMenuId = menuId;
    });

    // ✅ Zatvor drawer na mobile po výbere
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 768 && _scaffoldKey.currentState?.isDrawerOpen == true) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 📱 Responsívne breakpointy
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    return Scaffold(
      key: _scaffoldKey, // ✅ PRIDANÉ: key pre scaffold
      drawer: isMobile
          ? Drawer(
        child: SidebarMenu(
          menuItems: menuItems,
          activeMenuId: activeMenuId,
          onMenuSelected: _handleMenuSelection,
        ),
      )
          : null,
      body: Stack(
        children: [
          Row(
            children: [
              // Sidebar - skryť na mobile, zobraziť na desktop
              if (!isMobile)
                AnimatedContainer(
                  duration: AppConstants.animationDuration,
                  width: sidebarOpen ? 280 : 0,
                  child: sidebarOpen
                      ? SidebarMenu(
                    menuItems: menuItems,
                    activeMenuId: activeMenuId,
                    onMenuSelected: _handleMenuSelection,
                  )
                      : null,
                ),

              // Main Content
              Expanded(
                child: Column(
                  children: [
                    // Header
                    if (activeMenuId != 'generate')
                      HeaderWidget(
                        title: _getPageTitle(activeMenuId),
                        sidebarOpen: sidebarOpen,
                        isMobile: isMobile, // ✅ Posielame isMobile parameter
                        onMenuToggle: () {
                          if (isMobile) {
                            // ✅ Na mobile otvor drawer cez GlobalKey
                            _scaffoldKey.currentState?.openDrawer();
                          } else {
                            // Na desktop toggle sidebar
                            setState(() {
                              sidebarOpen = !sidebarOpen;
                            });
                          }
                        },
                      ),

                    // Content Area
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: AppConstants.animationDuration,
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.01, 0), // Jemný posun sprava
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: KeyedSubtree(
                          key: ValueKey<String>(activeMenuId),
                          child: activeMenuId == 'generate' ||
                                  activeMenuId == 'notifications' ||
                                  activeMenuId == 'profile'
                              ? _buildContent(activeMenuId)
                              : SingleChildScrollView(
                                  padding: EdgeInsets.all(
                                    isMobile ? 16 : AppConstants.largePadding,
                                  ),
                                  child: _buildContent(activeMenuId),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // ✅ AI Chat Assistant Widget
          Consumer<GenerateProvider>(
            builder: (context, generateProvider, child) {
              final String screenId = activeMenuId == 'generate'
                  ? 'step${generateProvider.currentStep + 1}'
                  : activeMenuId;
              return ChatPanel(screenId: screenId);
            },
          ),
        ],
      ),
      floatingActionButton: Consumer<ChatNotifier>(
        builder: (context, chatNotifier, child) {
          if (chatNotifier.isPanelOpen) return const SizedBox.shrink();
          return FloatingActionButton(
            onPressed: chatNotifier.togglePanel,
            backgroundColor: AppTheme.primaryRed,
            child: const Icon(Icons.chat_rounded, color: Colors.white),
          );
        },
      ),
    );
  }

  Widget _buildContent(String menuId) {
    switch (menuId) {
      case 'home':
        return _buildHomePage();
      case 'generate':
        return GenerateScreen(
          onBackPressed: () {
            setState(() {
              activeMenuId = 'home';
              sidebarOpen = true;
            });
          },
        );
      case 'database':
        return const DatabaseScreen();
      case 'notifications':
        return const NotificationsScreen();
      case 'settings':
        return const SettingsScreen();
      case 'profile':
        return const ProfileScreen();
      default:
        return _buildHomePage();
    }
  }

  Widget _buildHomePage() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 📱 Welcome Section - responsívny
        Container(
          padding: EdgeInsets.all(isMobile ? 20 : AppConstants.largePadding * 1.5),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryRed.withOpacity(0.2),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: isMobile
              ? _buildMobileWelcome(isDark)
              : _buildDesktopWelcome(isDark),
        ),

        SizedBox(height: isMobile ? 20 : 32),

        // 📱 Statistics - responsívne
        _isLoadingStats
            ? _buildLoadingStats(isMobile)
            : _buildStatisticsRow(isMobile),

        SizedBox(height: isMobile ? 20 : 32),

        // Features Section
        Text(
          'Funkcie aplikácie',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontSize: isMobile ? 20 : null,
          ),
        ),
        const SizedBox(height: 16),

        // 📱 GridView - responsívny počet stĺpcov
        GridView.count(
          crossAxisCount: isMobile ? 1 : (isTablet ? 2 : 3),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: isMobile ? 1.8 : (isTablet ? 1.5 : 1.4),
          children: [
            FeatureCard(
              title: 'Generovanie',
              description: AppConstants.descGenerate,
              icon: Icons.description_rounded,
              onTap: () => _handleMenuSelection('generate'),
            ),
            FeatureCard(
              title: 'Databázy',
              description: AppConstants.descDatabase,
              icon: Icons.storage_rounded,
              onTap: () => _handleMenuSelection('database'),
            ),
            FeatureCard(
              title: 'Nastavenia',
              description: AppConstants.descSettings,
              icon: Icons.settings_rounded,
              onTap: () => _handleMenuSelection('settings'),
            ),
          ],
        ),
      ],
    );
  }

  // 📱 Mobile welcome layout (stĺpcový)
  Widget _buildMobileWelcome(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 80,
          height: 80,
          child: IsometricDocumentAnimation(
            size: 80,
            accentColor: Colors.white70,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Generovanie žiadosti o vyjadrenie',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppTheme.white,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Systém pre generovanie vyjadrení pre projektovanie v energetike',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.white.withOpacity(0.9),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _handleMenuSelection('generate'),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Vytvoriť nové žiadosti'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.white,
              foregroundColor: isDark ? Colors.white : AppTheme.primaryRed,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  // 💻 Desktop welcome layout (riadkový)
  Widget _buildDesktopWelcome(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Generovanie žiadosti o vyjadrenie',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: AppTheme.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Systém pre generovanie vyjadrení pre projektovanie v energetike',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _handleMenuSelection('generate'),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Vytvoriť nové žiadosti pre projektovanú stavbu'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.white,
                  foregroundColor: isDark ? Colors.white : AppTheme.primaryRed,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        const SizedBox(
          width: 180,
          height: 180,
          child: IsometricDocumentAnimation(
            size: 180,
            accentColor: Colors.white70,
          ),
        ),
      ],
    );
  }

  // 📱 Statistics - responsívne (Column na mobile, Row na desktop)
  Widget _buildStatisticsRow(bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          _buildStatCard(
            title: 'Generované vyjadrenia',
            value: _statistics?.generatedDocuments.toString() ?? 'N/A',
            icon: Icons.description_rounded,
            color: AppTheme.primaryRed,
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            title: 'Mestá a obce',
            value: _statistics?.cities.toString() ?? '0',
            icon: Icons.location_city_rounded,
            color: Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            title: 'Úrady a inštitúcie',
            value: _statistics?.applications.toString() ?? '0',
            icon: Icons.business_rounded,
            color: Colors.green,
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Generované vyjadrenia',
            value: _statistics?.generatedDocuments.toString() ?? 'N/A',
            icon: Icons.description_rounded,
            color: AppTheme.primaryRed,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'Mestá a obce',
            value: _statistics?.cities.toString() ?? '0',
            icon: Icons.location_city_rounded,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'Úrady a inštitúcie',
            value: _statistics?.applications.toString() ?? '0',
            icon: Icons.business_rounded,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingStats(bool isMobile) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.darkCard : AppTheme.white;
    final border = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor;

    final loadingCard = Container(
      height: 100,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 1),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );

    if (isMobile) {
      return Column(
        children: [
          loadingCard,
          const SizedBox(height: 12),
          loadingCard,
          const SizedBox(height: 12),
          loadingCard,
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: loadingCard),
        const SizedBox(width: 16),
        Expanded(child: loadingCard),
        const SizedBox(width: 16),
        Expanded(child: loadingCard),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.darkCard : AppTheme.white;
    final border = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor;
    final titleColor = isDark ? Colors.white : null;
    final subtitleColor = isDark ? Colors.white70 : AppTheme.textLight;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: subtitleColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(String title, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.darkCard : AppTheme.white;
    final border = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor;
    final titleColor = isDark ? Colors.white : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppConstants.largePadding * 2),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border, width: 1),
          ),
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primaryRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: AppTheme.primaryRed,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Obsah tejto sekcie je v príprave...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white70 : null,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getPageTitle(String menuId) {
    switch (menuId) {
      case 'home':
        return AppConstants.menuHome;
      case 'generate':
        return AppConstants.menuGenerate;
      case 'database':
        return AppConstants.menuDatabase;
      case 'notifications':
        return AppConstants.menuNotifications;
      case 'settings':
        return AppConstants.menuSettings;
      case 'profile':
        return AppConstants.menuProfile;
      default:
        return AppConstants.menuHome;
    }
  }
}
