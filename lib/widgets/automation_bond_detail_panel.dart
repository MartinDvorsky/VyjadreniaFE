import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/automation_bond_model.dart';
import '../providers/automation_provider.dart';
import '../utils/permission_helper.dart';
import '../utils/app_theme.dart';
import 'automation_condition_add_dialog.dart';

class AutomationBondDetailPanel extends StatefulWidget {
  final AutomationBond bond;
  final VoidCallback onDeleted;
  final VoidCallback onUpdated;

  const AutomationBondDetailPanel({
    Key? key,
    required this.bond,
    required this.onDeleted,
    required this.onUpdated,
  }) : super(key: key);

  @override
  State<AutomationBondDetailPanel> createState() => _AutomationBondDetailPanelState();
}

class _AutomationBondDetailPanelState extends State<AutomationBondDetailPanel> {
  bool _isLoading = false;

  Future<void> _toggleActive() async {
    setState(() => _isLoading = true);

    try {
      final provider = context.read<AutomationProvider>();
      await provider.updateBond(widget.bond.id, active: !widget.bond.active);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  widget.bond.active
                      ? 'Automatizácia deaktivovaná'
                      : 'Automatizácia aktivovaná',
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        widget.onUpdated();
      }
    } catch (e) {
      await context.showPermissionErrorIfNeeded(e,
          actionName: "zmena stavu automatizácie");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Chyba: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteBond() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? AppTheme.darkBackground : Colors.white;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: dialogBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.warning_rounded,
                color: Colors.red.shade600,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Potvrdiť zmazanie'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Naozaj chcete zmazať túto automatizáciu?'),
            const SizedBox(height: 12),
            Text(
              'Úrad: ${widget.bond.applicationName ?? "ID ${widget.bond.applicationId}"}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Podmienky: ${widget.bond.conditionsCount}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.red),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Táto akcia je nenávratná!',
                      style: TextStyle(fontSize: 12, color: Colors.red),
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
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.delete, size: 18),
            label: const Text('Zmazať'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      final provider = context.read<AutomationProvider>();
      await provider.deleteBond(widget.bond.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Automatizácia bola zmazaná'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        widget.onDeleted();
      }
    } catch (e) {
      await context.showPermissionErrorIfNeeded(e,
          actionName: "zmazanie automatizácie");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Chyba pri mazaní: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteCondition(int conditionId) async {
    try {
      final provider = context.read<AutomationProvider>();
      await provider.deleteCondition(conditionId, widget.bond.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Podmienka bola odstránená'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        widget.onUpdated();
      }
    } catch (e) {
      await context.showPermissionErrorIfNeeded(e,
          actionName: "odstránenie podmienky");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Chyba: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addCondition() async {
    final provider = context.read<AutomationProvider>();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ChangeNotifierProvider.value(
        value: provider,
        child: AutomationConditionAddDialog(bondId: widget.bond.id),
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Podmienka bola pridaná'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      widget.onUpdated();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final containerBg = isDark ? AppTheme.darkCard : AppTheme.white;
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor;

    return Container(
      decoration: BoxDecoration(
        color: containerBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppTheme.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(isDark),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoSection(isDark),
                  const SizedBox(height: 24),
                  _buildConditionsSection(isDark),
                  const SizedBox(height: 24),
                  _buildActionsSection(isDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade400, Colors.teal.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
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
              Icons.auto_awesome_rounded,
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
                  'Detail automatizácie',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${widget.bond.id}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: widget.bond.active
                  ? Colors.green.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.bond.active ? Icons.check_circle : Icons.cancel,
                  size: 14,
                  color: Colors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  widget.bond.statusText,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(bool isDark) {
    final infoBg = isDark ? AppTheme.darkSurface : AppTheme.lightGray;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: infoBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.business,
                size: 20,
                color: Colors.teal.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                'Informácie o úrade',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Názov', widget.bond.applicationName ?? 'N/A', isDark),
          if (widget.bond.applicationDepartment != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow('Oddelenie', widget.bond.applicationDepartment!, isDark),
          ],
          if (widget.bond.applicationCity != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow('Mesto', widget.bond.applicationCity!, isDark),
          ],
          const SizedBox(height: 8),
          _buildInfoRow('Application ID', widget.bond.applicationId.toString(), isDark),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textLight,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppTheme.textDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConditionsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.rule,
              size: 20,
              color: Colors.blue.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              'Podmienky priraďovania',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${widget.bond.conditionsCount}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _addCondition,
              icon: const Icon(Icons.add_circle_outline_rounded),
              color: Colors.blue.shade600,
              tooltip: 'Pridať podmienku',
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (widget.bond.conditions.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Žiadne podmienky. Táto automatizácia sa nebude použiť.',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
              ],
            ),
          )
        else
          ...widget.bond.conditions.map((condition) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildConditionCard(condition, isDark),
            );
          }).toList(),
      ],
    );
  }

  Widget _buildConditionCard(condition, bool isDark) {
    final cardBg = isDark ? AppTheme.darkSurface : Colors.white;
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Text(
            condition.icon,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  condition.displayText,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'ID: ${condition.id}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _deleteCondition(condition.id),
            icon: const Icon(Icons.delete_outline, size: 20),
            color: Colors.red.shade400,
            tooltip: 'Odstrániť podmienku',
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection(bool isDark) {
    final dangerBg = isDark ? const Color(0xFF2C1515) : Colors.red.shade50;
    final dangerBorder = isDark ? Colors.red.withOpacity(0.3) : Colors.red.shade200;

    return Column(
      children: [
        // Toggle active/inactive
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _toggleActive,
            icon: Icon(
              widget.bond.active ? Icons.cancel : Icons.check_circle,
              size: 20,
            ),
            label: Text(
              widget.bond.active ? 'Deaktivovať' : 'Aktivovať',
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: widget.bond.active ? Colors.orange : Colors.green,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Delete section
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: dangerBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: dangerBorder, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.warning_rounded,
                    color: Colors.red.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Nebezpečná zóna',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.red.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Zmazanie automatizácie je nenávratné',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red.shade700,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _deleteBond,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Zmazať automatizáciu'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                    side: BorderSide(color: Colors.red.shade300, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}