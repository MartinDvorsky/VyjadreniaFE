import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/automation_provider.dart';
import '../utils/permission_helper.dart';
import '../utils/app_theme.dart';

class AutomationConditionAddDialog extends StatefulWidget {
  final int bondId;

  const AutomationConditionAddDialog({
    Key? key,
    required this.bondId,
  }) : super(key: key);

  @override
  State<AutomationConditionAddDialog> createState() => _AutomationConditionAddDialogState();
}

class _AutomationConditionAddDialogState extends State<AutomationConditionAddDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _selectedRegion;
  String? _selectedDistrict;
  bool _allDistricts = true;

  // Zoznam krajov a okresov (reused from AutomationBondCreateDialog)
  static const Map<String, List<String>> _regions = {
    'BA': ['Bratislava I', 'Bratislava II', 'Bratislava III', 'Bratislava IV', 'Bratislava V', 'Malacky', 'Pezinok', 'Senec'],
    'TT': ['Dunajská Streda', 'Galanta', 'Hlohovec', 'Piešťany', 'Senica', 'Skalica', 'Trnava'],
    'TN': ['Bánovce nad Bebravou', 'Ilava', 'Myjava', 'Nové Mesto nad Váhom', 'Partizánske', 'Považská Bystrica', 'Prievidza', 'Púchov', 'Trenčín'],
    'NR': ['Komárno', 'Levice', 'Nitra', 'Nové Zámky', 'Šaľa', 'Topoľčany', 'Zlaté Moravce'],
    'ZA': ['Bytča', 'Čadca', 'Dolný Kubín', 'Kysucké Nové Mesto', 'Liptovský Mikuláš', 'Martin', 'Námestovo', 'Ružomberok', 'Turčianske Teplice', 'Tvrdošín', 'Žilina'],
    'BB': ['Banská Bystrica', 'Banská Štiavnica', 'Brezno', 'Detva', 'Krupina', 'Lučenec', 'Poltár', 'Revúca', 'Rimavská Sobota', 'Veľký Krtíš', 'Zvolen', 'Žarnovica', 'Žiar nad Hronom'],
    'PO': ['Bardejov', 'Humenné', 'Kežmarok', 'Levoča', 'Medzilaborce', 'Poprad', 'Prešov', 'Sabinov', 'Snina', 'Stará Ľubovňa', 'Stropkov', 'Svidník', 'Vranov nad Topľou'],
    'KE': ['Gelnica', 'Košice I', 'Košice II', 'Košice III', 'Košice IV', 'Košice-okolie', 'Michalovce', 'Rožňava', 'Sobrance', 'Spišská Nová Ves', 'Trebišov'],
  };

  static const Map<String, String> _regionNames = {
    'BA': 'Bratislavský kraj',
    'TT': 'Trnavský kraj',
    'TN': 'Trenčiansky kraj',
    'NR': 'Nitriansky kraj',
    'ZA': 'Žilinský kraj',
    'BB': 'Banskobystrický kraj',
    'PO': 'Prešovský kraj',
    'KE': 'Košický kraj',
  };

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final provider = context.read<AutomationProvider>();
      await provider.addCondition(
        bondId: widget.bondId,
        region: _selectedRegion,
        district: _allDistricts ? null : _selectedDistrict,
      );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      await context.showPermissionErrorIfNeeded(e,
          actionName: "pridanie podmienky");
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? AppTheme.darkBackground : Colors.white;

    return AlertDialog(
      backgroundColor: dialogBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.adb_rounded, color: Colors.teal),
          ),
          const SizedBox(width: 12),
          const Text('Pridať podmienku'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Region
            DropdownButtonFormField<String>(
              value: _selectedRegion,
              decoration: const InputDecoration(
                labelText: 'Kraj',
                prefixIcon: Icon(Icons.public, size: 20),
                hintText: 'Všetky kraje',
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Všetky kraje'),
                ),
                ..._regionNames.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))),
              ],
              onChanged: (val) {
                setState(() {
                  _selectedRegion = val;
                  _selectedDistrict = null;
                  _allDistricts = true;
                });
              },
            ),
            const SizedBox(height: 16),
            // District toggle
            Row(
              children: [
                Checkbox(
                  value: _allDistricts,
                  onChanged: _selectedRegion == null ? null : (val) {
                    setState(() {
                      _allDistricts = val ?? true;
                      if (_allDistricts) _selectedDistrict = null;
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    _selectedRegion == null ? 'Všetky okresy (vyberte kraj)' : 'Všetky okresy v kraji',
                    style: TextStyle(
                      fontSize: 13,
                      color: _selectedRegion == null ? Colors.grey : null,
                    ),
                  ),
                ),
              ],
            ),
            // District selector
            if (!_allDistricts && _selectedRegion != null) ...[
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedDistrict,
                decoration: const InputDecoration(
                  labelText: 'Okres',
                  prefixIcon: Icon(Icons.location_on, size: 20),
                ),
                items: _regions[_selectedRegion]!.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                onChanged: (val) => setState(() => _selectedDistrict = val),
                validator: (val) => val == null ? 'Vyberte okres' : null,
              ),
            ],
          ],
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Zrušiť'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _save,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
          child: _isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Pridať'),
        ),
      ],
    );
  }
}
