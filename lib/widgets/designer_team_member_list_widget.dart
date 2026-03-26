import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/designer_team_member_edit_provider.dart';
import '../utils/app_theme.dart';

class DesignerTeamMemberListWidget extends StatefulWidget {
  const DesignerTeamMemberListWidget({Key? key}) : super(key: key);

  @override
  State<DesignerTeamMemberListWidget> createState() =>
      _DesignerTeamMemberListWidgetState();
}

class _DesignerTeamMemberListWidgetState extends State<DesignerTeamMemberListWidget> {
  @override
  void initState() {
    super.initState();
    // Načítaj členov tímu pri otvorení
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DesignerTeamMemberEditProvider>().loadAllMembers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
            child: Consumer<DesignerTeamMemberEditProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return _buildLoadingState();
                }

                if (provider.error != null) {
                  return _buildErrorState(provider.error!);
                }

                if (provider.members.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildMembersList(provider);
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
    final iconBg = isDark ? Colors.white.withOpacity(0.1) : AppTheme.lightGray;

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
                colors: [Colors.blue.shade400, Colors.blue.shade600],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.groups_rounded,
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
                  'Zoznam členov tímu',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: isDark ? Colors.white : null, // ✅
                  ),
                ),
                const SizedBox(height: 2),
                Consumer<DesignerTeamMemberEditProvider>(
                  builder: (context, provider, child) {
                    return Text(
                      '${provider.members.length} členov',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white70 : null, // ✅
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              context.read<DesignerTeamMemberEditProvider>().loadAllMembers();
            },
            icon: Icon(Icons.refresh_rounded,
                color: isDark ? Colors.white70 : null), // ✅
            tooltip: 'Obnoviť zoznam',
            style: IconButton.styleFrom(
              backgroundColor: iconBg, // ✅
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersList(DesignerTeamMemberEditProvider provider) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: provider.members.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final member = provider.members[index];
        final isSelected = provider.selectedMember?.id == member.id;

        // Colors
        final isDark = Theme.of(context).brightness == Brightness.dark;

        // Backgrounds
        final itemBg = isSelected
            ? (isDark ? const Color(0xFF003366) : Colors.blue.shade50)
            : (isDark ? AppTheme.darkSurface : AppTheme.white);

        // Borders
        final itemBorder = isSelected
            ? (isDark ? Colors.blue.shade700 : Colors.blue.shade400)
            : (isDark ? Colors.white.withOpacity(0.05) : AppTheme.borderColor);

        // Icons
        final iconBg = isSelected
            ? (isDark ? Colors.blue.shade900 : Colors.blue.shade100)
            : (isDark ? Colors.white.withOpacity(0.05) : AppTheme.lightGray);

        final iconColor = isSelected
            ? (isDark ? Colors.blue.shade200 : Colors.blue.shade700)
            : (isDark ? Colors.white54 : AppTheme.textLight);

        // Texts
        final titleColor = isSelected
            ? (isDark ? Colors.blue.shade200 : Colors.blue.shade900)
            : (isDark ? Colors.white : AppTheme.textDark);

        final subTextColor = isDark ? Colors.white54 : AppTheme.textMedium;

        return InkWell(
          onTap: () {
            provider.selectMember(member);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: itemBg, // ✅
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: itemBorder, // ✅
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
                    Icons.person_rounded,
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
                        member.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: titleColor, // ✅
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.email_outlined,
                            size: 14,
                            color: subTextColor, // ✅
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              member.email,
                              style: TextStyle(
                                fontSize: 13,
                                color: subTextColor, // ✅
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (member.phone != null && member.phone!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.phone_outlined,
                              size: 14,
                              color: subTextColor, // ✅
                            ),
                            const SizedBox(width: 6),
                            Text(
                              member.phone!,
                              style: TextStyle(
                                fontSize: 13,
                                color: subTextColor, // ✅
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                // Arrow
                if (isSelected)
                  Icon(
                    Icons.chevron_right_rounded,
                    color: isDark ? Colors.blue.shade400 : Colors.blue.shade600, // ✅
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
            color: Colors.blue.shade600,
          ),
          const SizedBox(height: 16),
          Text(
            'Načítavam členov tímu...',
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
    final errorBg = isDark ? const Color(0xFF2C1515) : Colors.red.shade50;

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
                color: errorBg, // ✅
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Chyba pri načítaní',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: isDark ? Colors.white : null, // ✅
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white70 : null, // ✅
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<DesignerTeamMemberEditProvider>().loadAllMembers();
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Skúsiť znova'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconBg = isDark
        ? [const Color(0xFF003366), const Color(0xFF004C99)]
        : [Colors.blue.shade50, Colors.blue.shade100];

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: iconBg, // ✅
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.groups_rounded,
              size: 50,
              color: Colors.blue.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Žiadni členovia tímu',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: isDark ? Colors.white : null, // ✅
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pridajte prvého člena tímu pomocou tlačidla hore',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.white70 : null, // ✅
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}