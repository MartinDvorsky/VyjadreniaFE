import '../utils/constants.dart';
import 'menu_item_widget.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SidebarMenu extends StatelessWidget {
  final List<MenuItem> menuItems;
  final String activeMenuId;
  final Function(String) onMenuSelected;

  const SidebarMenu({
    Key? key,
    required this.menuItems,
    required this.activeMenuId,
    required this.onMenuSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ✅ Dynamické farby
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.darkSurface : AppTheme.white;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.1)
        : AppTheme.borderColor;
    final footerBg = isDark
        ? AppTheme.darkCard
        : AppTheme.lightGray;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          right: BorderSide(
            color: borderColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // ✅ UPRAVENÉ: Logo Section s adaptívnym logom
          Container(
            padding: const EdgeInsets.all(12), // ✅ Rovnaký padding ako menu items
            decoration: BoxDecoration(
              color: bgColor,
              border: Border(
                bottom: BorderSide(
                  color: borderColor,
                  width: 1,
                ),
              ),
            ),
            child: _buildAdaptiveLogo(isDark),
          ),

          // Menu Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 16,
              ),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                final isActive = item.id == activeMenuId;

                return MenuItemWidget(
                  label: item.label,
                  icon: item.icon,
                  isActive: isActive,
                  onTap: () => onMenuSelected(item.id),
                );
              },
            ),
          ),

          // Footer
          Container(
            decoration: BoxDecoration(
              color: footerBg,
              border: Border(
                top: BorderSide(
                  color: borderColor,
                  width: 1,
                ),
              ),
            ),
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: isDark ? Colors.white60 : AppTheme.textLight,
                ),
                const SizedBox(width: 8),
                FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    final version = snapshot.hasData ? snapshot.data!.version : '...';
                    return Text(
                      'v$version',
                      style: TextStyle(
                        color: isDark ? Colors.white60 : AppTheme.textLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                ),
                const Spacer(),
                Text(
                  '© 2025',
                  style: TextStyle(
                    color: isDark ? Colors.white60 : AppTheme.textLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ NOVÁ METÓDA: Adaptívne logo
  Widget _buildAdaptiveLogo(bool isDark) {
    if (isDark) {
      // V dark mode: logo s bielym pozadím (plná šírka)
      return Container(
        width: double.infinity, // ✅ Plná šírka ako červený button
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Image.asset(
          'assets/images/logo2.jpg',
          height: 60,
          fit: BoxFit.contain,
        ),
      );
    } else {
      // V light mode: normálne logo bez pozadia (plná šírka)
      return SizedBox(
        width: double.infinity, // ✅ Plná šírka
        height: 80,
        child: Image.asset(
          'assets/images/logo2.jpg',
          fit: BoxFit.contain,
        ),
      );
    }
  }
}