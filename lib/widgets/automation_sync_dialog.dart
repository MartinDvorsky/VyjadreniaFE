import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/automation_provider.dart';
import '../utils/app_theme.dart';

class AutomationSyncDialog extends StatefulWidget {
  const AutomationSyncDialog({Key? key}) : super(key: key);

  @override
  State<AutomationSyncDialog> createState() => _AutomationSyncDialogState();
}

class _AutomationSyncDialogState extends State<AutomationSyncDialog> {
  bool _removeExtra = false;
  int? _limit;
  bool _isValidating = false;
  bool _isSyncing = false;
  Map<String, dynamic>? _validationReport;
  Map<String, dynamic>? _syncReport;

  Future<void> _validate() async {
    setState(() {
      _isValidating = true;
      _validationReport = null;
    });

    try {
      final provider = context.read<AutomationProvider>();
      final report = await provider.validateAllCities(limit: _limit);

      setState(() {
        _validationReport = report;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Chyba pri validácii: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isValidating = false;
        });
      }
    }
  }

  Future<void> _sync() async {
    // Confirm dialog
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
            const Text('Naozaj chcete synchronizovať všetky mestá?'),
            const SizedBox(height: 12),
            if (_limit != null)
              Text(
                'Limit: $_limit miest',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            if (_removeExtra)
              const Text(
                '⚠️ Odstránia sa aj nesprávne priradenia!',
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
                      'Toto môže trvať niekoľko sekúnd',
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
      final report = await provider.syncAllCities(
        removeExtra: _removeExtra,
        limit: _limit,
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
                Text('Synchronizácia dokončená: ${report['processed_cities']} miest'),
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
        width: 700,
        constraints: const BoxConstraints(maxHeight: 800),
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
                    _buildInfoBox(isDark),
                    const SizedBox(height: 24),
                    _buildSettings(isDark),
                    const SizedBox(height: 24),
                    _buildActions(isDark),
                    if (_validationReport != null) ...[
                      const SizedBox(height: 24),
                      _buildValidationReport(isDark),
                    ],
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
          colors: [Colors.blue.shade400, Colors.blue.shade600],
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
              Icons.sync_rounded,
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
                  'Synchronizácia miest',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Skontrolujte a synchronizujte priraďovanie úradov',
                  style: TextStyle(
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

  Widget _buildInfoBox(bool isDark) {
    final infoBg = isDark ? Colors.blue.withOpacity(0.1) : Colors.blue.shade50;
    final infoBorder = isDark ? Colors.blue.withOpacity(0.3) : Colors.blue.shade200;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: infoBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: infoBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: isDark ? Colors.blue.shade300 : Colors.blue.shade700,
                size: 20,
              ),
              const SizedBox(width: 12),
              const Text(
                'Čo robí synchronizácia?',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '1. Validácia - Skontroluje, ktoré mestá majú chybné priradenia\n'
                '2. Synchronizácia - Pridá chybajúce úrady podľa pravidiel automatizácie',
            style: TextStyle(fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildSettings(bool isDark) {
    final boxBg = isDark ? AppTheme.darkSurface : AppTheme.lightGray;
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nastavenia',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        // Limit
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Limit miest (voliteľné)',
            hintText: 'Nechajte prázdne pre všetky mestá',
            prefixIcon: Icon(Icons.numbers, size: 20),
            helperText: 'Odporúčam najprv otestovať s malým číslom (napr. 10)',
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            setState(() {
              _limit = value.isEmpty ? null : int.tryParse(value);
            });
          },
        ),
        const SizedBox(height: 16),
        // Remove extra switch
        Container(
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
                      'Odstrániť nesprávne priradenia',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _removeExtra
                          ? '⚠️ Odstráni úrady, ktoré tam nemajú byť'
                          : 'Len pridá chybajúce (bezpečnejšie)',
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
        ),
      ],
    );
  }

  Widget _buildActions(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isValidating || _isSyncing ? null : _validate,
            icon: _isValidating
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Icon(Icons.check_circle_outline, size: 20),
            label: Text(_isValidating ? 'Validujem...' : 'Validovať'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: _isValidating || _isSyncing ? null : _sync,
            icon: _isSyncing
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : const Icon(Icons.sync, size: 20),
            label: Text(_isSyncing ? 'Synchronizujem...' : 'Synchronizovať'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.teal.shade600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildValidationReport(bool isDark) {
    final report = _validationReport!;
    final validBg = isDark ? Colors.green.withOpacity(0.1) : Colors.green.shade50;
    final invalidBg = isDark ? Colors.red.withOpacity(0.1) : Colors.red.shade50;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Validačný report',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Celkom miest',
                report['total_cities'].toString(),
                Colors.blue,
                Icons.location_city,
                isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'V poriadku',
                report['valid_cities'].toString(),
                Colors.green,
                Icons.check_circle,
                isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Chýba',
                report['total_missing'].toString(),
                Colors.orange,
                Icons.add_circle,
                isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Navyše',
                report['total_extra'].toString(),
                Colors.red,
                Icons.remove_circle,
                isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSyncReport(bool isDark) {
    final report = _syncReport!;
    final successBg = isDark ? Colors.green.withOpacity(0.1) : Colors.green.shade50;

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
          _buildReportRow('Spracovaných miest', report['processed_cities'].toString()),
          _buildReportRow('Pridaných väzieb', report['total_added'].toString()),
          if (report['total_removed'] > 0)
            _buildReportRow('Odstránených väzieb', report['total_removed'].toString()),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon, bool isDark) {
    final cardBg = isDark ? AppTheme.darkSurface : Colors.white;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
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
          Text(label, style: const TextStyle(fontSize: 13)),
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