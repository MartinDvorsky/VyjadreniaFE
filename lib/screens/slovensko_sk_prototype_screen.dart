import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/step5_data_provider.dart';
import '../models/application_model.dart';
import '../widgets/attachment_upload_widget.dart';
import '../widgets/submission_progress_widget.dart';
import '../services/slovensko_sk_service.dart';
import '../utils/app_theme.dart';
import 'dart:io';

class SlovenskoSkPrototypeScreen extends StatefulWidget {
  const SlovenskoSkPrototypeScreen({Key? key}) : super(key: key);

  @override
  State<SlovenskoSkPrototypeScreen> createState() => _SlovenskoSkPrototypeScreenState();
}

class _SlovenskoSkPrototypeScreenState extends State<SlovenskoSkPrototypeScreen> {
  // Stav odosielania
  bool _isSubmitting = false;
  int _currentSubmissionIndex = 0;
  final Map<int, SubmissionStatus> _submissionStatuses = {};

  // Prílohy (4 povinné)
  File? _technicalSituationFile;
  File? _situationFile;
  File? _situationA3File;
  File? _broaderRelationsFile;

  List<Application> _electronicApplications = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadElectronicApplications();
    });
  }

  void _loadElectronicApplications() {
    final step5 = context.read<Step5DataProvider>();
    setState(() {
      // Filtruj len elektronické žiadosti (submission = 'E')
      _electronicApplications = step5.applications
          .where((app) =>
      app.submission == 'E' &&
          !step5.isHidden(app.applicationId))
          .toList();

      // Inicializuj statusy
      for (var app in _electronicApplications) {
        _submissionStatuses[app.id] = SubmissionStatus.pending;
      }
    });
  }

  bool get _canSubmit {
    // Skontroluj či sú všetky prílohy nahrané
    return _technicalSituationFile != null &&
        _situationFile != null &&
        _situationA3File != null &&
        _broaderRelationsFile != null &&
        _electronicApplications.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('slovensko.sk - Prototyp odosielania'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ⚠️ Prototyp banner
              _buildPrototypeBanner(isDark),

              const SizedBox(height: 32),

              // Sumár žiadostí
              _buildApplicationsSummary(isDark),

              const SizedBox(height: 32),

              // Nahrávanie príloh
              if (!_isSubmitting) ...[
                _buildAttachmentsSection(isDark),
                const SizedBox(height: 32),

                // Tlačidlo odoslať
                _buildSubmitButton(),
              ],

              // Progress odosielania
              if (_isSubmitting) ...[
                const SizedBox(height: 32),
                _buildSubmissionProgress(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ==================== WIDGETS ====================

  Widget _buildPrototypeBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.amber.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.amber.shade700,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '⚠️ Prototyp funkcionality',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Toto je simulované prostredie pre demonštráciu integrácie so slovensko.sk API. '
                      'V reálnom nasadení by sa vyjadrenia odosielali skutočne na úrady cez štátnu API.',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationsSummary(bool isDark) {
    return Card(
      color: isDark ? AppTheme.darkCard : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.email_outlined,
                    color: AppTheme.primaryRed,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Žiadosti na odoslanie',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: isDark ? Colors.white24 : null),
            const SizedBox(height: 16),

            // Info riadky
            _buildInfoRow(
              icon: Icons.check_circle_outline,
              label: 'Elektronické žiadosti',
              value: '${_electronicApplications.length}',
              valueColor: Colors.green,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.attach_file,
              label: 'Požadované prílohy',
              value: '4 súbory (PDF)',
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: isDark ? Colors.white60 : Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.grey[700],
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: valueColor ?? (isDark ? Colors.white : Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nahraj povinné prílohy',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Všetky prílohy sú povinné a musia byť vo formáte PDF. '
              'Tieto prílohy budú pripojené ku každému vyjadreniu.',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white70 : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 20),

        // 4 Drag & Drop zóny
        AttachmentUploadWidget(
          label: '1. Technická situácia',
          description: 'Situačný výkres so zakreslenou stavbou',
          file: _technicalSituationFile,
          onFileSelected: (file) {
            setState(() => _technicalSituationFile = file);
          },
        ),
        const SizedBox(height: 16),

        AttachmentUploadWidget(
          label: '2. Situácia',
          description: 'Situačný výkres lokality',
          file: _situationFile,
          onFileSelected: (file) {
            setState(() => _situationFile = file);
          },
        ),
        const SizedBox(height: 16),

        AttachmentUploadWidget(
          label: '3. Situácia A3',
          description: 'Situačný výkres vo formáte A3',
          file: _situationA3File,
          onFileSelected: (file) {
            setState(() => _situationA3File = file);
          },
        ),
        const SizedBox(height: 16),

        AttachmentUploadWidget(
          label: '4. Širšie vzťahy',
          description: 'Výkres širších vzťahov územia',
          file: _broaderRelationsFile,
          onFileSelected: (file) {
            setState(() => _broaderRelationsFile = file);
          },
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _canSubmit ? _startSubmission : null,
        icon: const Icon(Icons.send_rounded, size: 24),
        label: const Text(
          'Odoslať vyjadrenia',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryRed,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildSubmissionProgress() {
    return SubmissionProgressWidget(
      applications: _electronicApplications,
      currentIndex: _currentSubmissionIndex,
      statuses: _submissionStatuses,
    );
  }

  // ==================== SUBMISSION LOGIC ====================

  Future<void> _startSubmission() async {
    setState(() {
      _isSubmitting = true;
      _currentSubmissionIndex = 0;
    });

    final service = SlovenskoSkService();

    // Postupné odosielanie každej aplikácie
    for (int i = 0; i < _electronicApplications.length; i++) {
      setState(() => _currentSubmissionIndex = i);

      final app = _electronicApplications[i];

      try {
        // Update status na "odosielam"
        setState(() {
          _submissionStatuses[app.id] = SubmissionStatus.sending;
        });

        // Simuluj odoslanie (v realite volanie API)
        await Future.delayed(const Duration(seconds: 2));

        // Odošli vyjadrenie
        final result = await service.submitStatement(
          applicationId: app.id,
          statementXml: '<Statement>Mock XML</Statement>',
          attachments: {
            'technical_situation': _technicalSituationFile!,
            'situation': _situationFile!,
            'situation_a3': _situationA3File!,
            'broader_relations': _broaderRelationsFile!,
          },
        );

        // Update status
        setState(() {
          _submissionStatuses[app.id] = result['success']
              ? SubmissionStatus.success
              : SubmissionStatus.error;
        });

      } catch (e) {
        // Chyba
        setState(() {
          _submissionStatuses[app.id] = SubmissionStatus.error;
        });

        print('❌ Chyba pri odosielaní ${app.name}: $e');
      }
    }

    // Hotovo
    setState(() => _isSubmitting = false);

    // Zobraz výsledok
    _showCompletionDialog();
  }

  void _showCompletionDialog() {
    final successCount = _submissionStatuses.values
        .where((s) => s == SubmissionStatus.success)
        .length;
    final errorCount = _submissionStatuses.values
        .where((s) => s == SubmissionStatus.error)
        .length;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              successCount == _electronicApplications.length
                  ? Icons.check_circle
                  : Icons.warning_rounded,
              color: successCount == _electronicApplications.length
                  ? Colors.green
                  : Colors.orange,
            ),
            const SizedBox(width: 12),
            const Text('Odosielanie dokončené'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('✅ Úspešne odoslané: $successCount'),
            if (errorCount > 0) ...[
              const SizedBox(height: 8),
              Text('❌ Chyby: $errorCount'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Zatvor dialog
              Navigator.pop(context); // Zatvor screen
            },
            child: const Text('Zatvoriť'),
          ),
          if (errorCount > 0)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _retryFailed();
              },
              child: const Text('Skúsiť znova'),
            ),
        ],
      ),
    );
  }

  void _retryFailed() {
    // Reset failed statuses
    _submissionStatuses.forEach((key, value) {
      if (value == SubmissionStatus.error) {
        _submissionStatuses[key] = SubmissionStatus.pending;
      }
    });

    setState(() {
      _electronicApplications = _electronicApplications
          .where((app) => _submissionStatuses[app.id] != SubmissionStatus.success)
          .toList();
    });

    _startSubmission();
  }
}

// ==================== ENUMS ====================

enum SubmissionStatus {
  pending,
  sending,
  success,
  error,
}