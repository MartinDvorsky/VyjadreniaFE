// ========================================
// STEP 4: NOTIFIKÁCIE - UPRAVENÝ DIZAJN
// Uložiť ako: lib/screens/generate_steps/step_4_notifications.dart
// ========================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/step2_data_provider.dart';
import '../../providers/step4_notifications_provider.dart';
import '../../utils/app_theme.dart';

class Step4Notifications extends StatelessWidget {
  const Step4Notifications({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768; // ✅ Pridané

    return Consumer2<Step2DataProvider, Step4NotificationsProvider>(
      builder: (context, step2Provider, step4Provider, child) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16 : 24), // ✅ Responsívny padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header sekcia
              _buildSectionHeader(context, isMobile: isMobile),
              SizedBox(height: isMobile ? 12 : 16),
              // Hlavná karta s notifikáciami
              _buildNotificationCard(context, step2Provider, step4Provider, isMobile),
              SizedBox(height: isMobile ? 20 : 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, {required bool isMobile}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = AppTheme.primaryRed;

    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(isDark ? 0.3 : 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: isMobile ? 36 : 40,
            height: isMobile ? 36 : 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.notifications_outlined,
              color: color,
              size: isMobile ? 20 : 22,
            ),
          ),
          SizedBox(width: isMobile ? 10 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Emailové notifikácie',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: isMobile ? 15 : null,
                  ),
                ),
                SizedBox(height: isMobile ? 1 : 2),
                Text(
                  'Nastavte pripomienky pre vašu stavbu',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white70 : AppTheme.textMedium, // ✅
                    fontSize: isMobile ? 12 : 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, Step2DataProvider step2Provider,
      Step4NotificationsProvider provider, bool isMobile) {
    final now = DateTime.now();
    final firstNotification = now.add(const Duration(days: 20));
    final secondNotification = now.add(const Duration(days: 40));

    String formatDate(DateTime date) {
      return '${date.day}.${date.month}.${date.year}';
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.darkCard : Colors.white;
    final border = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor;

    return Container(
      decoration: BoxDecoration(
        color: bg, // ✅
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 1), // ✅
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hlavný checkbox
          InkWell(
            onTap: () {
              if (!provider.emailNotificationsEnabled) {
                // Zapnutie - nastaviť dátumy
                provider.setNotificationData(
                  enabled: true,
                  znacka: step2Provider.znacka,
                  nazovstavby: step2Provider.nazovStavby,
                );
              } else {
                // Vypnutie
                provider.setEmailNotificationsEnabled(false);
              }
            },
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              padding: EdgeInsets.all(isMobile ? 16 : 20),
              decoration: BoxDecoration(
                color: provider.emailNotificationsEnabled
                    ? AppTheme.primaryRed.withOpacity(0.03)
                    : Colors.transparent,
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(12)),
                border: provider.emailNotificationsEnabled
                    ? Border.all(
                    color: AppTheme.primaryRed.withOpacity(0.2), width: 2)
                    : null,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Transform.scale(
                    scale: 1.15,
                    child: Checkbox(
                      value: provider.emailNotificationsEnabled,
                      onChanged: (val) {
                        if (val ?? false) {
                          provider.setNotificationData(
                            enabled: true,
                            znacka: step2Provider.znacka,
                            nazovstavby: step2Provider.nazovStavby,
                          );
                        } else {
                          provider.setEmailNotificationsEnabled(false);
                        }
                      },
                      activeColor: AppTheme.primaryRed,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chcete zapnúť emailové notifikácie pre danú stavbu?',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : AppTheme.textDark, // ✅
                            fontSize: isMobile ? 14 : 15,
                          ),
                        ),
                        SizedBox(height: isMobile ? 6 : 8),
                        Text(
                          'Notifikácie prídu s linkom na zdieľanú tabuľku karty stavby',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.white60 : AppTheme.textMedium, // ✅
                            fontSize: isMobile ? 12 : 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Harmonogram - zobrazí sa len ak sú notifikácie zapnuté
          if (provider.emailNotificationsEnabled) ...[
            Divider(color: border, height: 1), // ✅
            Padding(
              padding: EdgeInsets.all(isMobile ? 16 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: isMobile ? 28 : 32,
                        height: isMobile ? 28 : 32,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.calendar_today_rounded,
                          color: AppTheme.primaryRed,
                          size: isMobile ? 14 : 16,
                        ),
                      ),
                      SizedBox(width: isMobile ? 10 : 12),
                      Text(
                        'Harmonogram notifikácií',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppTheme.textDark, // ✅
                          fontSize: isMobile ? 14 : 15,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isMobile ? 12 : 16),
                  _buildTimelineItem(
                    context,
                    number: '1',
                    title: 'Prvá pripomienka',
                    date: formatDate(firstNotification),
                    isFirst: true,
                    isMobile: isMobile,
                  ),
                  SizedBox(height: isMobile ? 8 : 10),
                  _buildTimelineItem(
                    context,
                    number: '2',
                    title: 'Druhá pripomienka',
                    date: formatDate(secondNotification),
                    isFirst: false,
                    isMobile: isMobile,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
      BuildContext context, {
        required String number,
        required String title,
        required String date,
        required bool isFirst,
        required bool isMobile,
      }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.darkSurface : AppTheme.lightGray;
    final border = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor;

    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: bg, // ✅
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border, width: 1), // ✅
      ),
      child: Row(
        children: [
          Container(
            width: isMobile ? 32 : 36,
            height: isMobile ? 32 : 36,
            decoration: const BoxDecoration(
              color: AppTheme.primaryRed,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: isMobile ? 14 : 15,
                ),
              ),
            ),
          ),
          SizedBox(width: isMobile ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: isMobile ? 13 : 14,
                    color: isDark ? Colors.white : AppTheme.textDark, // ✅
                  ),
                ),
                SizedBox(height: isMobile ? 2 : 4),
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: isMobile ? 12 : 14,
                      color: isDark ? Colors.white60 : AppTheme.textLight, // ✅
                    ),
                    SizedBox(width: isMobile ? 4 : 6),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 13,
                        color: isDark ? Colors.white60 : AppTheme.textLight, // ✅
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
