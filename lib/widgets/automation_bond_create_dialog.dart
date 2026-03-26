import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/automation_provider.dart';
import '../utils/permission_helper.dart';
import '../utils/app_theme.dart';
import '../widgets/application_search_field_widget.dart';
import '../models/application_edit_model.dart';

class AutomationBondCreateDialog extends StatefulWidget {
  const AutomationBondCreateDialog({Key? key}) : super(key: key);

  @override
  State<AutomationBondCreateDialog> createState() => _AutomationBondCreateDialogState();
}

class _AutomationBondCreateDialogState extends State<AutomationBondCreateDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _active = true;
  bool _isLoading = false;
  int? _selectedApplicationId;

  // Zoznam krajov a okresov
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

  // Podmienky s informáciou o "všetky"
  final List<Map<String, dynamic>> _conditions = [];

  @override
  void dispose() {
    super.dispose();
  }

  void _addCondition() {
    setState(() {
      _conditions.add({
        'region': null,
        'district': null,
        'allDistricts': true,
      });
    });
  }

  void _removeCondition(int index) {
    setState(() {
      _conditions.removeAt(index);
    });
  }

  Future<void> _createBond() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedApplicationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vyberte úrad zo zoznamu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_conditions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pridajte aspoň jednu podmienku'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider = context.read<AutomationProvider>();

      // Transformujeme podmienky - odstraníme pomocné flagy
      final transformedConditions = _conditions.map((condition) {
        return {
          'region': condition['region'],
          'district': condition['allDistricts'] ? null : condition['district'],
        };
      }).toList();

      await provider.createBond(
        applicationId: _selectedApplicationId!,
        active: _active,
        conditions: transformedConditions,
      );

      if (mounted) {
        Navigator.of(context).pop(true);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Automatizácia bola vytvorená'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      await context.showPermissionErrorIfNeeded(e,
          actionName: "vytváranie automatizácie");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Chyba: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
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
    final footerBg = isDark ? AppTheme.darkSurface : AppTheme.lightGray;
    final footerBorder = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: dialogBg,
      child: Container(
        width: 700,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoBox(isDark),
                      const SizedBox(height: 24),
                      _buildApplicationIdField(),
                      const SizedBox(height: 16),
                      _buildActiveSwitch(isDark),
                      const SizedBox(height: 24),
                      _buildConditionsSection(isDark),
                    ],
                  ),
                ),
              ),
            ),
            _buildFooter(footerBg, footerBorder),
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
          colors: [Colors.teal.shade400, Colors.teal.shade600],
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
                  'Nová automatizácia',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Vytvorte pravidlo pre automatické priraďovanie',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
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
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: isDark ? Colors.blue.shade300 : Colors.blue.shade700,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Automatizácia priradí úrad k mestám na základe podmienok (kraj/okres)',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.blue.shade200 : Colors.blue.shade900,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationIdField() {
    return ApplicationSearchField(
      onApplicationSelected: (application) {
        setState(() {
          _selectedApplicationId = application.id;
        });
      },
    );
  }

  Widget _buildActiveSwitch(bool isDark) {
    final boxBg = isDark ? AppTheme.darkSurface : AppTheme.lightGray;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: boxBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _active ? Icons.check_circle : Icons.cancel,
            color: _active ? Colors.green : Colors.grey,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stav automatizácie',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _active ? 'Hneď aktívna' : 'Neaktívna (môžete aktivovať neskôr)',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _active,
            onChanged: (value) {
              setState(() {
                _active = value;
              });
            },
            activeColor: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildConditionsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
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
                '${_conditions.length}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_conditions.isEmpty)
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
                    'Zatiaľ žiadne podmienky. Pridajte aspoň jednu.',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
              ],
            ),
          )
        else
          ..._conditions.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildConditionCard(entry.key, entry.value, isDark),
            );
          }).toList(),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _addCondition,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Pridať podmienku'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConditionCard(int index, Map<String, dynamic> condition, bool isDark) {
    final cardBg = isDark ? AppTheme.darkSurface : Colors.white;
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor;
    final allDistricts = condition['allDistricts'] ?? true;
    final selectedRegion = condition['region'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Podmienka ${index + 1}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppTheme.textDark,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _removeCondition(index),
                icon: const Icon(Icons.delete_outline, size: 20),
                color: Colors.red.shade400,
                tooltip: 'Odstrániť',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Výber kraja
          DropdownButtonFormField<String>(
            value: selectedRegion,
            decoration: const InputDecoration(
              labelText: 'Kraj',
              prefixIcon: Icon(Icons.public, size: 20),
              hintText: 'Vyberte kraj',
            ),
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('Všetky kraje'),
              ),
              ..._regionNames.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }),
            ],
            onChanged: (value) {
              setState(() {
                _conditions[index]['region'] = value;
                // Pri zmene kraja resetujeme okres
                if (value != selectedRegion) {
                  _conditions[index]['district'] = null;
                  _conditions[index]['allDistricts'] = true;
                }
              });
            },
            validator: (value) {
              // Validácia nie je potrebná, null = všetky kraje je validné
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Checkbox "Všetky okresy"
          Row(
            children: [
              Checkbox(
                value: allDistricts,
                onChanged: selectedRegion == null ? null : (value) {
                  setState(() {
                    _conditions[index]['allDistricts'] = value ?? true;
                    if (value == true) {
                      _conditions[index]['district'] = null;
                    }
                  });
                },
                activeColor: Colors.teal,
              ),
              Expanded(
                child: Text(
                  selectedRegion == null
                      ? 'Všetky okresy (vyberte najprv kraj)'
                      : 'Všetky okresy v kraji',
                  style: TextStyle(
                    fontSize: 13,
                    color: selectedRegion == null
                        ? Colors.grey
                        : (isDark ? Colors.white : AppTheme.textDark),
                  ),
                ),
              ),
            ],
          ),

          // Dropdown pre okres (len ak nie sú všetky okresy a kraj je vybraný)
          if (!allDistricts && selectedRegion != null) ...[
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: condition['district'],
              decoration: const InputDecoration(
                labelText: 'Okres',
                prefixIcon: Icon(Icons.map, size: 20),
                hintText: 'Vyberte okres',
              ),
              items: _regions[selectedRegion]!.map((district) {
                return DropdownMenuItem<String>(
                  value: district,
                  child: Text(district),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _conditions[index]['district'] = value;
                });
              },
              validator: (value) {
                if (!allDistricts && selectedRegion != null && value == null) {
                  return 'Vyberte okres alebo označte "Všetky okresy"';
                }
                return null;
              },
            ),
          ],

          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getConditionHint(condition),
                    style: const TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getConditionHint(Map<String, dynamic> condition) {
    final region = condition['region'];
    final allDistricts = condition['allDistricts'] ?? true;
    final district = condition['district'];

    if (region == null) {
      return 'Platí pre celú SR (všetky kraje a okresy)';
    }

    final regionName = _regionNames[region] ?? region;

    if (allDistricts) {
      return 'Platí pre celý $regionName';
    } else if (district != null) {
      return 'Platí len pre okres $district v kraji $regionName';
    } else {
      return 'Vyberte okres';
    }
  }

  Widget _buildFooter(Color footerBg, Color footerBorder) {
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
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, size: 18),
              label: const Text('Zrušiť'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _createBond,
              icon: _isLoading
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : const Icon(Icons.add, size: 18),
              label: Text(_isLoading ? 'Vytvárám...' : 'Vytvoriť automatizáciu'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.teal.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}