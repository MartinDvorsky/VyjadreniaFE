import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/automation_provider.dart';
import '../models/automation_bond_model.dart';
import '../utils/app_theme.dart';

class ApplicationAutomationSyncDialog extends StatefulWidget {
  final AutomationBond bond;

  const ApplicationAutomationSyncDialog({
    Key? key,
    required this.bond,
  }) : super(key: key);

  @override
  State<ApplicationAutomationSyncDialog> createState() => _ApplicationAutomationSyncDialogState();
}

class _ApplicationAutomationSyncDialogState extends State<ApplicationAutomationSyncDialog> {
  bool _removeExtra = false;
  bool _isSyncing = false;
  Map<String, dynamic>? _syncReport;

  Future<void> _sync() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange),
            SizedBox(width: 12),
            Text('Potvrdiť synchronizáciu'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Naozaj chcete synchronizovať úrad ${widget.bond.applicationName ?? 'ID ${widget.bond.applicationId}'}?'),
            const SizedBox(height: 12),
            if (_removeExtra)
              const Text(
                '⚠️ Odstránia sa aj prípadné nesprávne priradenia, ktoré nespĺňajú pravidlá!',
                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600),
              ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tento proces aplikuje aktuálne nastavené pravidlá úradu a pridelí mu príslušné mestá.',
                      style: TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Zrušiť'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
            ),
            child: const Text('Synchronizovať'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isSyncing = true;
      _syncReport = null;
    });

    try {
      final provider = context.read<AutomationProvider>();
      final report = await provider.syncApplication(
        widget.bond.applicationId,
        removeExtra: _removeExtra,
      );

      setState(() {
        _syncReport = report;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text('Synchronizácia úradu ${report['application_name']} dokončená.'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Chyba pri synchronizácii: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? AppTheme.darkBackground : Colors.white;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: dialogBg,
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSettings(isDark),
                    const SizedBox(height: 24),
                    _buildSyncButton(),
                    if (_syncReport != null) ...[
                      const SizedBox(height: 24),
                      _buildSyncReport(isDark),
                    ],
                  ],
                ),
              ),
            ),
            _buildFooter(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade500, Colors.teal.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.sync_alt_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Synchronizácia úradu',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.bond.applicationName ?? 'ID ${widget.bond.applicationId}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.white),
            tooltip: 'Zavrieť',
          ),
        ],
      ),
    );
  }

  Widget _buildSettings(bool isDark) {
    final boxBg = isDark ? AppTheme.darkSurface : AppTheme.lightGray;
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: boxBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            _removeExtra ? Icons.delete_sweep : Icons.add_circle_outline,
            color: _removeExtra ? Colors.orange : Colors.blue,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Odstrániť nesprávne väzby',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _removeExtra
                      ? '⚠️ Odstráni aj mestá, ktoré nespĺňajú pravidlá.'
                      : 'Len pridá chýbajúce väzby podľa pravidiel.',
                  style: TextStyle(
                    fontSize: 12,
                    color: _removeExtra ? Colors.orange : AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _removeExtra,
            onChanged: (value) {
              setState(() {
                _removeExtra = value;
              });
            },
            activeColor: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildSyncButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isSyncing ? null : _sync,
        icon: _isSyncing
            ? const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : const Icon(Icons.sync_alt, size: 20),
        label: Text(_isSyncing ? 'Synchronizujem...' : 'Synchronizovať'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.teal.shade700,
        ),
      ),
    );
  }

  Widget _buildSyncReport(bool isDark) {
    final report = _syncReport!;
    final successBg = isDark ? Colors.green.withOpacity(0.1) : Colors.green.shade50;

    final addedCount = (report['added'] as List?)?.length ?? 0;
    final removedCount = (report['removed'] as List?)?.length ?? 0;
    final unchangedCount = (report['unchanged'] as List?)?.length ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: successBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 24),
              SizedBox(width: 12),
              Text(
                'Synchronizácia dokončená!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildReportRow('Úrad', report['application_name']?.toString() ?? '-'),
          _buildReportRow('Pridané väzby', addedCount.toString()),
          _buildReportRow('Odstránené väzby', removedCount.toString()),
          _buildReportRow('Nezmenené väzby', unchangedCount.toString()),
        ],
      ),
    );
  }

  Widget _buildReportRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(bool isDark) {
    final footerBg = isDark ? AppTheme.darkSurface : AppTheme.lightGray;
    final footerBorder = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: footerBg,
        border: Border(
          top: BorderSide(color: footerBorder, width: 1),
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text('Zavrieť'),
        ),
      ),
    );
  }
}
