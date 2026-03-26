// lib/widgets/ai_usage_widget.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vyjadrenia/providers/ai_usage_provider.dart';
import 'package:vyjadrenia/services/openai_usage_service.dart';
import 'package:vyjadrenia/utils/app_theme.dart';

class AIUsageWidget extends StatefulWidget {
  const AIUsageWidget({Key? key}) : super(key: key);

  @override
  State<AIUsageWidget> createState() => _AIUsageWidgetState();
}

class _AIUsageWidgetState extends State<AIUsageWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AIUsageProvider>().loadUsage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AIUsageProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.usage == null) {
          return _buildLoadingCard();
        }

        if (provider.error != null && provider.usage == null) {
          return _buildErrorCard(provider.error!, provider);
        }

        if (provider.usage == null) {
          return const SizedBox.shrink();
        }

        return _buildUsageCard(provider.usage!, provider);
      },
    );
  }

  Widget _buildLoadingCard() {
    // ✅ Dynamické farby
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.darkCard : AppTheme.white;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.1)
        : AppTheme.borderColor;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor, // ✅ Dynamické
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor), // ✅ Dynamické
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryRed),
            ),
            const SizedBox(height: 12),
            Text(
              'Načítavam OpenAI usage...',
              style: TextStyle(
                color: isDark ? Colors.white60 : AppTheme.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(String error, AIUsageProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Nepodarilo sa načítať usage dáta',
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => provider.refresh(),
            color: Colors.red.shade700,
          ),
        ],
      ),
    );
  }

  Widget _buildUsageCard(TotalUsage usage, AIUsageProvider provider) {
    // ✅ Dynamické farby
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.darkCard : AppTheme.white;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.1)
        : AppTheme.borderColor;
    final textColor = isDark ? Colors.white : AppTheme.textDark;

    final percentage = usage.percentageUsed;

    // Farba podľa percentuálneho využitia
    Color progressColor;
    if (percentage >= 95) {
      progressColor = Colors.red;
    } else if (percentage >= 90) {
      progressColor = Colors.orange;
    } else if (percentage >= 80) {
      progressColor = Colors.yellow.shade700;
    } else {
      progressColor = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bgColor, // ✅ Dynamické
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor), // ✅ Dynamické
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.credit_card,
                      color: AppTheme.primaryRed,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'OpenAI Kredit',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: textColor, // ✅ Dynamické
                        ),
                      ),
                      Text(
                        'Od septembra 2024',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white60 : AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Refresh button s loading indikátorom
              provider.isLoading
                  ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryRed,
                  ),
                ),
              )
                  : IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                onPressed: () => provider.refresh(),
                tooltip: 'Obnoviť údaje',
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Využitie kreditu',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: textColor, // ✅ Dynamické
                    ),
                  ),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: progressColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  minHeight: 8,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Minuté',
                  '\$${usage.totalSpent.toStringAsFixed(2)}',
                  Icons.payments_outlined,
                  Colors.red.shade100,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  'Zostáva',
                  '\$${usage.remainingCredit.toStringAsFixed(2)}',
                  Icons.account_balance_wallet_outlined,
                  Colors.green.shade100,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Celkový vklad',
                  '\$${usage.myDeposit.toStringAsFixed(2)}',
                  Icons.savings_outlined,
                  Colors.blue.shade100,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  'Dní od dobitia',
                  '${usage.daysSinceDeposit}',
                  Icons.calendar_today,
                  Colors.purple.shade100,
                ),
              ),
            ],
          ),

          // Alert message
          if (usage.alertMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: progressColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: progressColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: progressColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      usage.alertMessage!,
                      style: TextStyle(
                        color: progressColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Last update time
          if (provider.lastFetchTime != null) ...[
            const SizedBox(height: 12),
            Text(
              'Naposledy aktualizované: ${_formatTime(provider.lastFetchTime!)}',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white60 : AppTheme.textLight,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String label,
      String value,
      IconData icon,
      Color bgColor,
      ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black87),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'pred chvíľou';
    } else if (diff.inMinutes < 60) {
      return 'pred ${diff.inMinutes} min';
    } else if (diff.inHours < 24) {
      return 'pred ${diff.inHours} h';
    } else {
      return 'pred ${diff.inDays} dňami';
    }
  }
}