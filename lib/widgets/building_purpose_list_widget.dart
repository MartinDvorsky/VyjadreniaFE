import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/building_purpose_provider.dart';
import '../utils/app_theme.dart';

class BuildingPurposeListWidget extends StatefulWidget {
  const BuildingPurposeListWidget({Key? key}) : super(key: key);

  @override
  State<BuildingPurposeListWidget> createState() =>
      _BuildingPurposeListWidgetState();
}

class _BuildingPurposeListWidgetState extends State<BuildingPurposeListWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BuildingPurposeProvider>().loadAllPurposes();
    });
  }

  @override
  Widget build(BuildContext context) {
    // ✅ 1. Zisti tému
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ✅ 2. Dynamické farby
    final containerBg = isDark ? AppTheme.darkCard : AppTheme.white;
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor;

    return Container(
      decoration: BoxDecoration(
        color: containerBg, // ✅
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1), // ✅
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Consumer<BuildingPurposeProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return _buildLoadingState();
                }

                if (provider.error != null) {
                  return _buildErrorState(provider.error!);
                }

                if (provider.purposes.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildPurposesList(provider);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor;
    final refreshBtnBg = isDark ? Colors.white.withOpacity(0.1) : AppTheme.lightGray;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: borderColor, width: 1), // ✅
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.cyan.shade400, Colors.cyan.shade600],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.category_rounded,
              color: AppTheme.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Zoznam účelov stavby',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: isDark ? Colors.white : AppTheme.textDark, // ✅
                  ),
                ),
                const SizedBox(height: 2),
                Consumer<BuildingPurposeProvider>(
                  builder: (context, provider, child) {
                    return Text(
                      '${provider.purposes.length} účelov',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white70 : AppTheme.textMedium, // ✅
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              context.read<BuildingPurposeProvider>().loadAllPurposes();
            },
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Obnoviť zoznam',
            style: IconButton.styleFrom(
              backgroundColor: refreshBtnBg, // ✅
              foregroundColor: isDark ? Colors.white : AppTheme.textDark, // ✅
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurposesList(BuildingPurposeProvider provider) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: provider.purposes.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final purpose = provider.purposes[index];
        final isSelected = provider.selectedPurpose?.id == purpose.id;

        // ✅ Farby pre položky
        final isDark = Theme.of(context).brightness == Brightness.dark;

        final itemBg = isSelected
            ? (isDark ? Colors.cyan.withOpacity(0.15) : Colors.cyan.shade50)
            : (isDark ? Colors.white.withOpacity(0.05) : AppTheme.white);

        final itemBorderColor = isSelected
            ? (isDark ? Colors.cyan.shade400 : Colors.cyan.shade400)
            : (isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor);

        final iconBg = isSelected
            ? (isDark ? Colors.cyan.withOpacity(0.3) : Colors.cyan.shade100)
            : (isDark ? Colors.white.withOpacity(0.1) : AppTheme.lightGray);

        final iconColor = isSelected
            ? (isDark ? Colors.cyan.shade300 : Colors.cyan.shade700)
            : (isDark ? Colors.white70 : AppTheme.textLight);

        final titleColor = isSelected
            ? (isDark ? Colors.cyan.shade200 : Colors.cyan.shade900)
            : (isDark ? Colors.white : AppTheme.textDark);

        return InkWell(
          onTap: () {
            provider.selectPurpose(purpose);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: itemBg, // ✅
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: itemBorderColor, // ✅
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBg, // ✅
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.home_work_rounded,
                    color: iconColor, // ✅
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        purpose.purposeName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: titleColor, // ✅
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: purpose.documentForm == 'old'
                                  ? (isDark ? Colors.orange.withOpacity(0.2) : Colors.orange.shade100)
                                  : (isDark ? Colors.green.withOpacity(0.2) : Colors.green.shade100),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              purpose.documentForm == 'old'
                                  ? 'Stará forma'
                                  : 'Nová forma',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: purpose.documentForm == 'old'
                                    ? (isDark ? Colors.orange.shade300 : Colors.orange.shade800)
                                    : (isDark ? Colors.green.shade300 : Colors.green.shade800),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.notes_rounded,
                            size: 14,
                            color: isDark ? Colors.white54 : AppTheme.textLight, // ✅
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              purpose.text.length > 50
                                  ? '${purpose.text.substring(0, 50)}...'
                                  : purpose.text,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white54 : AppTheme.textMedium, // ✅
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Arrow
                if (isSelected)
                  Icon(
                    Icons.chevron_right_rounded,
                    color: isDark ? Colors.cyan.shade400 : Colors.cyan.shade600, // ✅
                    size: 24,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Colors.cyan.shade600,
          ),
          const SizedBox(height: 16),
          Text(
            'Načítavam účely stavby...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.white70 : null, // ✅
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? const Color(0xFF2C1515) : Colors.red.shade50;
    final iconColor = isDark ? Colors.red.shade300 : Colors.red.shade400;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: bg, // ✅
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: iconColor, // ✅
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Chyba pri načítaní',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: isDark ? Colors.white : null,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white70 : null,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<BuildingPurposeProvider>().loadAllPurposes();
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Skúsiť znova'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ✅ Empty state farby
    final gradientColors = isDark
        ? [Colors.cyan.withOpacity(0.1), Colors.cyan.withOpacity(0.2)]
        : [Colors.cyan.shade50, Colors.cyan.shade100];

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors, // ✅
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.category_rounded,
              size: 50,
              color: Colors.cyan.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Žiadne účely stavby',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: isDark ? Colors.white : null,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pridajte prvý účel stavby pomocou tlačidla hore',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.white70 : null,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
