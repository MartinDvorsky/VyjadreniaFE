import 'package:flutter/material.dart';
import '../../models/application_model.dart';
import '../../screens/slovensko_sk_prototype_screen.dart';
import '../../utils/app_theme.dart';

class SubmissionProgressWidget extends StatelessWidget {
  final List<Application> applications;
  final int currentIndex;
  final Map<int, SubmissionStatus> statuses;

  const SubmissionProgressWidget({
    Key? key,
    required this.applications,
    required this.currentIndex,
    required this.statuses,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = currentIndex / applications.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Celkový progress
        _buildOverallProgress(context, isDark, progress),

        const SizedBox(height: 32),

        // Zoznam úradov
        Text(
          'Stav odosielania',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 16),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: applications.length,
          itemBuilder: (context, index) {
            final app = applications[index];
            final status = statuses[app.id] ?? SubmissionStatus.pending;
            final isActive = index == currentIndex;

            return _buildApplicationCard(context, app, status, isActive, isDark);
          },
        ),
      ],
    );
  }

  Widget _buildOverallProgress(BuildContext context, bool isDark, double progress) {
    final successCount = statuses.values.where((s) => s == SubmissionStatus.success).length;
    final errorCount = statuses.values.where((s) => s == SubmissionStatus.error).length;
    final sendingCount = statuses.values.where((s) => s == SubmissionStatus.sending).length;

    return Card(
      color: isDark ? AppTheme.darkCard : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Celkový priebeh',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  '${currentIndex + 1} / ${applications.length}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryRed,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 16,
                backgroundColor: isDark ? Colors.white10 : Colors.grey[200],
                valueColor: AlwaysStoppedAnimation(
                  errorCount > 0 ? Colors.orange : Colors.green,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Štatistiky
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatChip(
                  icon: Icons.check_circle,
                  label: 'Úspešné',
                  value: successCount.toString(),
                  color: Colors.green,
                ),
                _buildStatChip(
                  icon: Icons.hourglass_bottom,
                  label: 'Odosielam',
                  value: sendingCount.toString(),
                  color: Colors.blue,
                ),
                _buildStatChip(
                  icon: Icons.error,
                  label: 'Chyby',
                  value: errorCount.toString(),
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildApplicationCard(
      BuildContext context,
      Application app,
      SubmissionStatus status,
      bool isActive,
      bool isDark,
      ) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
      case SubmissionStatus.pending:
        statusColor = Colors.grey;
        statusIcon = Icons.pending_outlined;
        statusText = 'Čaká';
        break;
      case SubmissionStatus.sending:
        statusColor = Colors.blue;
        statusIcon = Icons.sync;
        statusText = 'Odosielam...';
        break;
      case SubmissionStatus.success:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Odoslané';
        break;
      case SubmissionStatus.error:
        statusColor = Colors.red;
        statusIcon = Icons.error;
        statusText = 'Chyba';
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isDark ? AppTheme.darkCard : Colors.white,
      elevation: isActive ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isActive ? AppTheme.primaryRed : Colors.transparent,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Status ikona
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: status == SubmissionStatus.sending
                  ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation(statusColor),
                ),
              )
                  : Icon(statusIcon, color: statusColor, size: 24),
            ),

            const SizedBox(width: 16),

            // Info o úrade
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    app.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    app.department,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white60 : Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (app.senderIco != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.business,
                          size: 14,
                          color: isDark ? Colors.white38 : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'IČO: ${app.senderIco}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white38 : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}