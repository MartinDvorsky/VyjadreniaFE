// ========================================
// STEP 3: DETAILNÉ ÚDAJE - CHECKBOXY + DIALÓGY
// Uložiť ako: lib/screens/generate_steps/step_3_detailed_data.dart
// ========================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/step3_data_provider.dart';
import '../../services/building_purpose_service.dart';
import '../../models/building_purpose_model.dart';
import '../../utils/app_theme.dart';

class Step3DetailedData extends StatefulWidget {
  const Step3DetailedData({Key? key}) : super(key: key);

  @override
  State<Step3DetailedData> createState() => _Step3DetailedDataState();
}

class _Step3DetailedDataState extends State<Step3DetailedData> {
  final BuildingPurposeService _buildingPurposeService = BuildingPurposeService();
  List<BuildingPurpose> _buildingPurposes = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBuildingPurposes();
  }

  Future<void> _loadBuildingPurposes() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      final purposes = await _buildingPurposeService.getAllBuildingPurposes();
      if (!mounted) return;
      setState(() {
        _buildingPurposes = purposes;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Chyba pri načítaní typov žiadostí: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Consumer<Step3DataProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16 : 24), // ✅ Menší padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(context, isMobile),
              SizedBox(height: isMobile ? 16 : 24),

              // 🆕 Building Purpose Dropdown
              _buildBuildingPurposeSection(context, provider, isMobile),
              SizedBox(height: isMobile ? 16 : 24),

              // ✅ RESPONSÍVNE: Column na mobile, Row na desktop
              if (isMobile)
                Column(
                  children: [
                    _buildMainOfficesCard(context, provider, isMobile),
                    const SizedBox(height: 16),
                    _buildTransportOfficesCard(context, provider, isMobile),
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildMainOfficesCard(context, provider, isMobile),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTransportOfficesCard(context, provider, isMobile),
                    ),
                  ],
                ),

              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }


  Widget _buildHeader(BuildContext context, bool isMobile) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradientColors = isDark
        ? [const Color(0xFF1E3A5F), const Color(0xFF2C5282)]
        : [Colors.blue.shade50, Colors.blue.shade100];
    final borderColor = isDark ? Colors.blue.shade900 : Colors.blue.shade200;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24), // ✅ Menší padding
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 10 : 12), // ✅ Menší
            decoration: BoxDecoration(
              color: Colors.blue.shade600,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.business_rounded,
              color: Colors.white,
              size: isMobile ? 24 : 28, // ✅ Menšia ikona
            ),
          ),
          SizedBox(width: isMobile ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Výber úradov a inštitúcií',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: isDark ? Colors.white : null,
                    fontSize: isMobile ? 16 : null, // ✅ Menší text
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Zakliknite úrady, ktoré sa týkajú vašej stavby',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white70 : null,
                    fontSize: isMobile ? 13 : null, // ✅ Menší text
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  // 🆕 NOVÁ SEKCIA: Building Purpose Dropdown
  Widget _buildBuildingPurposeSection(
      BuildContext context, Step3DataProvider provider, bool isMobile) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.darkCard : AppTheme.white;
    final border = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor;
    final errorBg = isDark ? const Color(0xFF2C1515) : Colors.red.shade50;
    final errorBorder = isDark ? Colors.red.shade900 : Colors.red.shade200;
    final emptyBg = isDark ? const Color(0xFF3E2C00) : Colors.orange.shade50;
    final emptyBorder = isDark ? Colors.orange.shade900 : Colors.orange.shade200;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24), // ✅ Responsívny padding
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
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
                child: Icon(
                  Icons.assignment_rounded,
                  color: AppTheme.primaryRed,
                  size: isMobile ? 20 : 24, // ✅ Menšia ikona
                ),
              ),
              SizedBox(width: isMobile ? 10 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vyberte typ žiadosti',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: isDark ? Colors.white : null,
                        fontSize: isMobile ? 15 : null, // ✅ Menší text
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Vyberte účel stavby pre vašu žiadosť',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white54 : null,
                        fontSize: isMobile ? 12 : null, // ✅ Menší text
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 20),

          // Zvyšok zostáva rovnaký...
          if (_isLoading)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: CircularProgressIndicator(color: AppTheme.primaryRed),
              ),
            )
          else if (_errorMessage != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: errorBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: errorBorder),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _loadBuildingPurposes,
                    tooltip: 'Skúsiť znova',
                  ),
                ],
              ),
            )
          else if (_buildingPurposes.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: emptyBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: emptyBorder),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Žiadne typy žiadostí nie sú dostupné',
                        style: TextStyle(color: Colors.orange.shade700),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _loadBuildingPurposes,
                      tooltip: 'Skúsiť znova',
                    ),
                  ],
                ),
              )
            else
              DropdownButtonFormField<BuildingPurpose>(
                value: provider.selectedBuildingPurpose,
                isExpanded: true,
                dropdownColor: isDark ? AppTheme.darkCard : Colors.white,
                decoration: InputDecoration(
                  labelText: 'Typ žiadosti *',
                  hintText: 'Vyberte účel stavby',
                  labelStyle: TextStyle(fontSize: isMobile ? 13 : null),
                  prefixIcon: Icon(
                    Icons.category_rounded,
                    color: AppTheme.primaryRed,
                    size: isMobile ? 20 : 24,
                  ),
                  filled: true,
                  fillColor: isDark ? AppTheme.darkSurface : Colors.white,
                ),
                items: _buildingPurposes.map((purpose) {
                  return DropdownMenuItem<BuildingPurpose>(
                    value: purpose,
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 6 : 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: purpose.documentForm == 'new'
                                ? Colors.green.shade50
                                : Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: purpose.documentForm == 'new'
                                  ? Colors.green.shade200
                                  : Colors.blue.shade200,
                            ),
                          ),
                          child: Text(
                            purpose.documentForm == 'new'
                                ? (isMobile ? 'Nová' : 'Nová forma dokumentov')
                                : (isMobile ? 'Stará' : 'Stará forma dokumentov'),
                            style: TextStyle(
                              fontSize: isMobile ? 9 : 10,
                              fontWeight: FontWeight.w600,
                              color: purpose.documentForm == 'new'
                                  ? Colors.green.shade700
                                  : Colors.blue.shade700,
                            ),
                          ),
                        ),
                        SizedBox(width: isMobile ? 8 : 12),
                        Expanded(
                          child: Text(
                            purpose.purposeName,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontSize: isMobile ? 13 : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                // ✅✅✅ TOTO JE DÔLEŽITÁ ZMENA - NAHRAĎ TENTO RIADOK:
                onChanged: (BuildingPurpose? value) {
                  provider.setSelectedBuildingPurpose(value);

                  // ✅ Automaticky zaškrtni "Mesto/Obec" ak je paragraf 56
                  if (value != null && value.purposeName.contains('56')) {
                    provider.setMestoObec(true);
                  }
                },
                validator: (value) {
                  if (value == null) {
                    return 'Prosím vyberte typ žiadosti';
                  }
                  return null;
                },
              ),

          // Selected purpose info
          if (provider.selectedBuildingPurpose != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryRed.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppTheme.primaryRed.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 18,
                        color: AppTheme.primaryRed,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Vybraný účel stavby',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryRed,
                          fontSize: isMobile ? 13 : null, // ✅
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    provider.selectedBuildingPurpose!.text,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.white70 : null,
                      fontSize: isMobile ? 13 : null, // ✅
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }


  Widget _buildMainOfficesCard(
      BuildContext context, Step3DataProvider provider, bool isMobile) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.darkCard : AppTheme.white;
    final border = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24), // ✅ Menší padding
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_city_rounded,
                color: AppTheme.primaryRed,
                size: isMobile ? 20 : 24, // ✅ Menšia ikona
              ),
              SizedBox(width: isMobile ? 6 : 8),
              Expanded(
                child: Text(
                  'Hlavné úrady',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: isDark ? Colors.white : null,
                    fontSize: isMobile ? 16 : null, // ✅ Menší text
                  ),
                  overflow: TextOverflow.ellipsis, // ✅ Skrátiť ak dlhé
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 20),

          // ORHAZZ
          _buildCheckboxTile(
            context: context,
            value: provider.orhazz,
            title: 'ORHAZZ',
            description: 'Zaklikni ak sa v tejto stavbe rieši nová trafostanica',
            icon: Icons.electrical_services_rounded,
            color: Colors.orange,
            isMobile: isMobile, // ✅ Pridané
            onChanged: (val) => provider.setOrhazz(val ?? false),
          ),
          SizedBox(height: isMobile ? 12 : 16),

          // SVP
          _buildCheckboxTile(
            context: context,
            value: provider.svp,
            title: 'SVP',
            description: 'Zaklikni ak sa na situácii nachádza rieka, jazero alebo vodný tok',
            icon: Icons.water_rounded,
            color: Colors.blue,
            isMobile: isMobile, // ✅ Pridané
            onChanged: (val) => provider.setSvp(val ?? false),
          ),
          SizedBox(height: isMobile ? 12 : 16),

          // RUVZ
          _buildCheckboxTile(
            context: context,
            value: provider.ruvz,
            title: 'RUVZ',
            description: 'Zaklikni ak pri tejto stavbe riešime inžiniersku činnosť a zároveň trafostanicu',
            icon: Icons.health_and_safety_rounded,
            color: Colors.green,
            isMobile: isMobile, // ✅ Pridané
            onChanged: (val) => provider.setRuvz(val ?? false),
          ),
          SizedBox(height: isMobile ? 12 : 16),

          // Mesto/Obec
          _buildCheckboxTile(
            context: context,
            value: provider.mestoObec,
            title: 'Mesto/Obec',
            description: 'Zaklikni ak neriešime paragraf 24',
            icon: Icons.business_rounded,
            color: Colors.purple,
            isMobile: isMobile, // ✅ Pridané
            onChanged: (val) => provider.setMestoObec(val ?? false),
          ),
        ],
      ),
    );
  }


  Widget _buildTransportOfficesCard(
      BuildContext context, Step3DataProvider provider, bool isMobile) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.darkCard : AppTheme.white;
    final border = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.train_rounded,
                color: Colors.blue.shade700,
                size: isMobile ? 20 : 24,
              ),
              SizedBox(width: isMobile ? 6 : 8),
              Expanded(
                child: Text(
                  'Dopravné úrady',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: isDark ? Colors.white : null,
                    fontSize: isMobile ? 16 : null,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 20),

          // ŽSR (zostáva rovnaký)
          _buildCheckboxTile(
            context: context,
            value: provider.zsr,
            title: 'ŽSR',
            description: 'Zaklikni ak stavba zasahuje do ochranného pásma alebo križuje koľaj ŽSR',
            icon: Icons.train_rounded,
            color: Colors.blue.shade700,
            isMobile: isMobile,
            onChanged: (val) {
              provider.setZsr(val ?? false);
              if (val == true) {
                _showZsrDialog(context, provider);
              }
            },
          ),

          if (provider.zsr) ...[
            SizedBox(height: isMobile ? 10 : 12),
            _buildZsrDetailPanel(context, provider, isMobile),
          ],
          SizedBox(height: isMobile ? 12 : 16),

          // ✅ UPRAVENÉ: Cesty I. triedy
          _buildCheckboxTile(
            context: context,
            value: provider.cestyI,
            title: 'Cesty I. triedy',
            description: 'Zaklikni ak sa na situácii nachádza cesta I. triedy',
            icon: Icons.alt_route_rounded,
            color: Colors.orange.shade700,
            isMobile: isMobile,
            onChanged: (val) {
              provider.setCestyI(val ?? false);
              // ✅ Otvor dialog LEN ak zaškrtávame (val == true) A zatiaľ nie je nastavené
              if (val == true && _isAnyCestyDialogShown(provider)) {
                _showUnifiedCestyDialog(context, provider);
              }
            },
          ),
          SizedBox(height: isMobile ? 12 : 16),

          // ✅ UPRAVENÉ: Cesty II. a III. triedy
          _buildCheckboxTile(
            context: context,
            value: provider.cestyII,
            title: 'Cesty II. a III. triedy',
            description: 'Zaklikni ak sa na situácii nachádza cesta II. alebo III. triedy',
            icon: Icons.route_rounded,
            color: Colors.orange.shade500,
            isMobile: isMobile,
            onChanged: (val) {
              provider.setCestyII(val ?? false);
              // ✅ Otvor dialog LEN ak zaškrtávame (val == true) A zatiaľ nie je nastavené
              if (val == true && _isAnyCestyDialogShown(provider)) {
                _showUnifiedCestyDialog(context, provider);
              }
            },
          ),

          // ✅ NOVÉ: Spoločný detail panel pre obe cesty
          if (provider.cestyI || provider.cestyII) ...[
            SizedBox(height: isMobile ? 10 : 12),
            _buildUnifiedCestyDetailPanel(context, provider, isMobile),
          ],
        ],
      ),
    );
  }

  Widget _buildUnifiedCestyDetailPanel(
      BuildContext context,
      Step3DataProvider provider,
      bool isMobile,
      ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = Colors.orange.shade600;

    // Použijem typ z Cesty I (keďže budú synchronizované)
    final cestyTyp = provider.cestyITyp;

    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: color, size: isMobile ? 18 : 20),
              SizedBox(width: isMobile ? 6 : 8),
              Expanded(
                child: Text(
                  'Nastavenia ciest',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: color,
                    fontSize: isMobile ? 13 : null,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit, size: isMobile ? 16 : 18),
                onPressed: () => _showUnifiedCestyDialog(context, provider),
                tooltip: 'Upraviť',
                padding: EdgeInsets.all(isMobile ? 4 : 8),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 8 : 12),
          _buildDetailRow(context, 'Typ prílohy:', cestyTyp, isMobile),
          if (provider.cestyI && provider.cestyII) ...[
            SizedBox(height: isMobile ? 6 : 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline, size: 16, color: Colors.blue.shade700),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Platí pre obe cesty (I. aj II./III. triedy)',
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }


  bool _isAnyCestyDialogShown(Step3DataProvider provider) {
    print('cestyI: ${provider.cestyI}, cestyII: ${provider.cestyII}');
    // Ak sú oba typy už nastavené (nie sú "Bez prílohy"), dialog už bol zobrazený

    if (provider.cestyI == false && provider.cestyII == false) {
      return true; // Vráť true = "dialog už bol zobrazený" (nech sa nezobrazí)
    }

    return false;
  }

// ✅ NOVÁ METÓDA: Jednotný dialog pre obe cesty
  void _showUnifiedCestyDialog(BuildContext context, Step3DataProvider provider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _UnifiedCestyDialog(provider: provider),
    );
  }


  Widget _buildCheckboxTile({
    required BuildContext context,
    required bool value,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required bool isMobile, // ✅ Nový parameter
    required Function(bool?) onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor;

    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 12 : 16), // ✅ Menší padding
        decoration: BoxDecoration(
          color: value ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: value ? color : borderColor,
            width: value ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Transform.scale(
              scale: isMobile ? 0.9 : 1.0, // ✅ Menší checkbox na mobile
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                activeColor: color,
              ),
            ),
            SizedBox(width: isMobile ? 8 : 12),
            Container(
              padding: EdgeInsets.all(isMobile ? 6 : 8), // ✅ Menší padding
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: isMobile ? 18 : 20, // ✅ Menšia ikona
              ),
            ),
            SizedBox(width: isMobile ? 8 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: value ? color : (isDark ? Colors.white : AppTheme.textDark),
                      fontSize: isMobile ? 15 : null, // ✅ Menší text
                    ),
                  ),
                  SizedBox(height: isMobile ? 3 : 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white54 : null,
                      fontSize: isMobile ? 12 : null, // ✅ Menší text
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  // ========== ZSR DIALÓG ==========
  void _showZsrDialog(BuildContext context, Step3DataProvider provider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ZsrDialog(provider: provider),
    );
  }

  Widget _buildZsrDetailPanel(
      BuildContext context, Step3DataProvider provider, bool isMobile) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1E3A5F) : Colors.blue.shade50;
    final border = isDark ? Colors.blue.shade900 : Colors.blue.shade200;

    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700, size: isMobile ? 18 : 20),
              SizedBox(width: isMobile ? 6 : 8),
              Text(
                'ŽSR Nastavenia',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                  fontSize: isMobile ? 13 : null,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.edit, size: isMobile ? 16 : 18),
                onPressed: () => _showZsrDialog(context, provider),
                tooltip: 'Upraviť',
                padding: EdgeInsets.all(isMobile ? 4 : 8),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 8 : 12),
          _buildDetailRow(context, 'Typ stavby:', provider.zsrStavbaTyp, isMobile),
          SizedBox(height: isMobile ? 6 : 8),
          _buildDetailRow(context, 'Elektrifikovaná trať:', provider.zsrAnoNie ? 'Áno' : 'Nie', isMobile),

          if (provider.zsrStavbaTyp == 'Stavba zasahuje do ochranného pásma') ...[
            SizedBox(height: isMobile ? 6 : 8),
            _buildDetailRow(context, 'Číslo trate:', provider.zsrCisloTrate, isMobile),
            SizedBox(height: isMobile ? 6 : 8),
            _buildDetailRow(
              context,
              'V úseku medzi:',
              '${provider.zsrZaciatok} ↔ ${provider.zsrKoniec}',
              isMobile,
            ),
            SizedBox(height: isMobile ? 6 : 8),
            _buildDetailRow(
              context,
              'Vzdialenosť:',
              '${provider.zsrVzdialenost1} - ${provider.zsrVzdialenost2} km',
              isMobile,
            ),
          ],
          if (provider.zsrStavbaTyp == 'Stavba križuje') ...[
            SizedBox(height: isMobile ? 6 : 8),
            _buildDetailRow(context, 'V kilometri:', '${provider.zsrKilometer} km', isMobile),
            SizedBox(height: isMobile ? 6 : 8),
            _buildDetailRow(
              context,
              'Medzi stanicami:',
              '${provider.zsrStanica1} - ${provider.zsrStanica2}',
              isMobile,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCestyDetailPanel(
      BuildContext context,
      Step3DataProvider provider, {
        required bool isFirstClass,
        required bool isMobile, // ✅ Nový parameter
      }) {
    final color = isFirstClass ? Colors.orange.shade700 : Colors.orange.shade500;
    final cestyTyp = isFirstClass ? provider.cestyITyp : provider.cestyIITyp;

    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16), // ✅
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: color, size: isMobile ? 18 : 20),
              SizedBox(width: isMobile ? 6 : 8),
              Expanded(
                child: Text(
                  isFirstClass ? 'Nastavenia Ciest I.' : 'Nastavenia Ciest II./III.',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: color,
                    fontSize: isMobile ? 13 : null, // ✅
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit, size: isMobile ? 16 : 18),
                onPressed: () => _showCestyDialog(context, provider, isFirstClass: isFirstClass),
                tooltip: 'Upraviť',
                padding: EdgeInsets.all(isMobile ? 4 : 8),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 8 : 12),
          _buildDetailRow(context, 'Typ:', cestyTyp, isMobile),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, bool isMobile) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isMobile ? 12 : 13, // ✅
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : AppTheme.textMedium,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 12 : 13, // ✅
              color: isDark ? Colors.white : AppTheme.textDark,
            ),
          ),
        ),
      ],
    );
  }


  // ========== CESTY DIALÓG ==========
  void _showCestyDialog(BuildContext context, Step3DataProvider provider,
      {required bool isFirstClass}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          _CestyDialog(provider: provider, isFirstClass: isFirstClass),
    );
  }


}

// ========================================
// ZSR DIALÓG
// ========================================
class _ZsrDialog extends StatefulWidget {
  final Step3DataProvider provider;
  const _ZsrDialog({required this.provider});

  @override
  State<_ZsrDialog> createState() => _ZsrDialogState();
}

class _ZsrDialogState extends State<_ZsrDialog> {
  late String selectedTyp;
  late String zeleznicnaTrat;
  late String cisloTrate;
  late bool anoNie;
  late TextEditingController zaciatok;
  late TextEditingController koniec;
  late TextEditingController vzdialenost1;
  late TextEditingController vzdialenost2;
  late TextEditingController kilometer;
  late TextEditingController stanica1;
  late TextEditingController stanica2;

  @override
  void initState() {
    super.initState();
    selectedTyp = widget.provider.zsrStavbaTyp;
    zeleznicnaTrat = widget.provider.zsrZeleznicnaTrat;
    anoNie = widget.provider.zsrAnoNie;
    cisloTrate = widget.provider.zsrCisloTrate;
    zaciatok = TextEditingController(text: widget.provider.zsrZaciatok);
    koniec = TextEditingController(text: widget.provider.zsrKoniec);
    vzdialenost1 = TextEditingController(text: widget.provider.zsrVzdialenost1);
    vzdialenost2 = TextEditingController(text: widget.provider.zsrVzdialenost2);
    kilometer = TextEditingController(text: widget.provider.zsrKilometer);
    stanica1 = TextEditingController(text: widget.provider.zsrStanica1);
    stanica2 = TextEditingController(text: widget.provider.zsrStanica2);
  }

  @override
  void dispose() {
    zaciatok.dispose();
    koniec.dispose();
    vzdialenost1.dispose();
    vzdialenost2.dispose();
    kilometer.dispose();
    stanica1.dispose();
    stanica2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? AppTheme.darkCard : Colors.white;
    final titleColor = isDark ? Colors.white : null;

    return Dialog(
      backgroundColor: dialogBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 700,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.train_rounded, color: Colors.blue.shade700),
                ),
                const SizedBox(width: 12),
                Text(
                  'ŽSR Nastavenia',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: titleColor,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Typ stavby
            _buildRadioGroup(
              context: context,
              title: 'Stavba križuje železničnú trať',
              icon: Icons.description_rounded,
              options: [
                RadioOption(
                  value: 'Stavba zasahuje do ochranného pásma',
                  label: 'Stavba zasahuje do ochranného pásma',
                ),
                RadioOption(
                  value: 'Stavba križuje',
                  label: 'Stavba križuje',
                ),
              ],
              groupValue: selectedTyp,
              onChanged: (val) => setState(() => selectedTyp = val!),
            ),
            const SizedBox(height: 20),

            // Elektrifikovaná trať: Áno/Nie
            Row(
              children: [
                Icon(Icons.bolt_rounded, color: Colors.amber.shade700, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Elektrifikovaná trať',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: titleColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Radio<bool>(
                  value: true,
                  groupValue: anoNie,
                  onChanged: (val) => setState(() => anoNie = val!),
                ),
                const Text('Áno'),
                const SizedBox(width: 8),
                Radio<bool>(
                  value: false,
                  groupValue: anoNie,
                  onChanged: (val) => setState(() => anoNie = val!),
                ),
                const Text('Nie'),
              ],
            ),
            const SizedBox(height: 20),

            // ✅ ČERVENÝ INFO BOX - PRED "Číslo trate"
            if (selectedTyp == 'Stavba zasahuje do ochranného pásma')
              _buildSectionHeader(
                '✔ "stavba zasahuje do ochranného pásma"',
                Colors.red.shade700,
              ),

            // Číslo trate - len pri "Stavba zasahuje do ochranného pásma"
            if (selectedTyp == 'Stavba zasahuje do ochranného pásma') ...[
              const SizedBox(height: 12),
              Text(
                'Číslo trate',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Číslo trate',
                  hintText: 'Napr. 180, 188',
                ),
                onChanged: (val) => cisloTrate = val,
              ),
              const SizedBox(height: 16),
            ],

            // ✅ ČERVENÝ INFO BOX PRE "Stavba križuje"
            if (selectedTyp == 'Stavba križuje')
              _buildSectionHeader(
                '✔ Stavba križuje železničnú trať',
                Colors.red.shade700,
              ),

            // Podmienené polia - Stavba zasahuje do ochranného pásma
            if (selectedTyp == 'Stavba zasahuje do ochranného pásma') ...[
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: zaciatok,
                      decoration: const InputDecoration(labelText: 'Začiatok úseku'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.arrow_forward),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: koniec,
                      decoration: const InputDecoration(labelText: 'Koniec úseku'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.straighten, size: 18, color: AppTheme.textLight),
                  const SizedBox(width: 8),
                  Text(
                    'v úseku medzi',
                    style: TextStyle(color: isDark ? Colors.white70 : null),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: vzdialenost1,
                      decoration: const InputDecoration(
                        labelText: '0.000',
                        suffixText: 'km',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.arrow_forward),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: vzdialenost2,
                      decoration: const InputDecoration(
                        labelText: '0.000',
                        suffixText: 'kilometrom."',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ],

            // Podmienené polia - Stavba križuje
            if (selectedTyp == 'Stavba križuje') ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.location_on, size: 18, color: AppTheme.textLight),
                  const SizedBox(width: 8),
                  const Text('v'),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: kilometer,
                      decoration: const InputDecoration(
                        labelText: '0.000',
                        suffixText: 'km',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.apartment, size: 18, color: AppTheme.textLight),
                  const SizedBox(width: 8),
                  const Text('medzi stanicami'),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: stanica1,
                      decoration: const InputDecoration(
                        labelText: 'Názov stanice 1',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.arrow_forward),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: stanica2,
                      decoration: const InputDecoration(
                        labelText: 'Názov stanice 2',
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Zrušiť'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.provider.setZsrData(
                        stavbaTyp: selectedTyp,
                        zeleznicnaTrat: zeleznicnaTrat,
                        cisloTrate: cisloTrate,
                        anoNie: anoNie,
                        zaciatok: zaciatok.text,
                        koniec: koniec.text,
                        vzdialenost1: vzdialenost1.text,
                        vzdialenost2: vzdialenost2.text,
                        kilometer: kilometer.text,
                        stanica1: stanica1.text,
                        stanica2: stanica2.text,
                      );
                      Navigator.pop(context);
                    },
                    child: const Text('Uložiť'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioGroup({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<RadioOption> options,
    required String groupValue,
    required Function(String?) onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1E3A5F) : Colors.blue.shade50;
    final border = isDark ? Colors.blue.shade900 : Colors.blue.shade200;
    final textColor = isDark ? Colors.white : Colors.black;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg, // ✅
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border), // ✅
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: textColor)), // ✅
            ],
          ),
          const SizedBox(height: 12),
          ...options.map((opt) => RadioListTile<String>(
            value: opt.value,
            groupValue: groupValue,
            onChanged: onChanged,
            title: Text(opt.label, style: TextStyle(color: textColor)), // ✅
            dense: true,
            contentPadding: EdgeInsets.zero,
          )),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String text, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                  fontSize: 13, color: color, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ========================================
// CESTY DIALÓG
// ========================================
class _CestyDialog extends StatefulWidget {
  final Step3DataProvider provider;
  final bool isFirstClass;

  const _CestyDialog({required this.provider, required this.isFirstClass});

  @override
  State<_CestyDialog> createState() => _CestyDialogState();
}

class _CestyDialogState extends State<_CestyDialog> {
  late String selectedTyp;

  @override
  void initState() {
    super.initState();
    selectedTyp = widget.isFirstClass
        ? widget.provider.cestyITyp
        : widget.provider.cestyIITyp;
  }

  @override
  Widget build(BuildContext context) {
    final color =
    widget.isFirstClass ? Colors.orange.shade700 : Colors.orange.shade500;
    final title =
    widget.isFirstClass ? 'Nastavenia Ciest I.' : 'Nastavenia Ciest II./III.';

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? AppTheme.darkCard : Colors.white;
    final titleColor = isDark ? Colors.white : null;
    final radioBoxBg = isDark ? color.withOpacity(0.05) : color.withOpacity(0.1);

    return Dialog(
      backgroundColor: dialogBg, // ✅
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.route_rounded, color: color),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: titleColor, // ✅
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Nastavenia ciest
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: radioBoxBg, // ✅
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.settings_rounded, size: 20, color: color),
                      const SizedBox(width: 8),
                      const Text(
                        'Nastavenia ciest',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  RadioListTile<String>(
                    value: 'Bez prílohy',
                    groupValue: selectedTyp,
                    onChanged: (val) => setState(() => selectedTyp = val!),
                    title: Row(
                      children: [
                        Icon(Icons.check_circle_outline,
                            size: 18, color: color),
                        const SizedBox(width: 8),
                        const Text('Bez prílohy'),
                      ],
                    ),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  RadioListTile<String>(
                    value: 'Rez krizovania',
                    groupValue: selectedTyp,
                    onChanged: (val) => setState(() => selectedTyp = val!),
                    title: Row(
                      children: [
                        Icon(Icons.engineering_rounded,
                            size: 18, color: color),
                        const SizedBox(width: 8),
                        const Text('Rez krizovania'),
                      ],
                    ),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Zrušiť'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (widget.isFirstClass) {
                        widget.provider.setCestyITyp(selectedTyp);
                      } else {
                        widget.provider.setCestyIITyp(selectedTyp);
                      }
                      Navigator.pop(context);
                    },
                    child: const Text('Uložiť'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class RadioOption {
  final String value;
  final String label;

  RadioOption({required this.value, required this.label});
}


// Pridaj tento nový dialog na koniec súboru step_3_detailed_data.dart
// NAMIESTO starého _CestyDialog

// ========================================
// JEDNOTNÝ CESTY DIALÓG (pre Cesty I aj II/III)
// ========================================
class _UnifiedCestyDialog extends StatefulWidget {
  final Step3DataProvider provider;

  const _UnifiedCestyDialog({required this.provider});

  @override
  State<_UnifiedCestyDialog> createState() => _UnifiedCestyDialogState();
}

class _UnifiedCestyDialogState extends State<_UnifiedCestyDialog> {
  late String selectedTyp;

  @override
  void initState() {
    super.initState();
    // Použijem typ z Cesty I (keďže budú synchronizované)
    selectedTyp = widget.provider.cestyITyp;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? AppTheme.darkCard : Colors.white;
    final titleColor = isDark ? Colors.white : null;
    final color = Colors.orange.shade600;
    final radioBoxBg = isDark ? color.withOpacity(0.05) : color.withOpacity(0.1);

    // Zisti ktoré cesty sú zaškrtnuté
    final hasCestyI = widget.provider.cestyI;
    final hasCestyII = widget.provider.cestyII;
    final hasBoth = hasCestyI && hasCestyII;

    return Dialog(
      backgroundColor: dialogBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.route_rounded, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nastavenia ciest',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasBoth
                            ? 'Platí pre Cesty I. aj II./III. triedy'
                            : hasCestyI
                            ? 'Platí pre Cesty I. triedy'
                            : 'Platí pre Cesty II./III. triedy',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white60 : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Info box o zaškrtnutých cestách
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      hasBoth
                          ? 'Toto nastavenie sa použije pre obe zaškrtnuté cesty súčasne.'
                          : 'Toto nastavenie sa použije pre vybratú cestu.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Nastavenia ciest
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: radioBoxBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.settings_rounded, size: 20, color: color),
                      const SizedBox(width: 8),
                      const Text(
                        'Typ prílohy',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  RadioListTile<String>(
                    value: 'Bez prílohy',
                    groupValue: selectedTyp,
                    onChanged: (val) => setState(() => selectedTyp = val!),
                    title: Row(
                      children: [
                        Icon(Icons.check_circle_outline, size: 18, color: color),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text('Bez prílohy'),
                        ),
                      ],
                    ),
                    subtitle: const Padding(
                      padding: EdgeInsets.only(left: 26, top: 4),
                      child: Text(
                        'Neprikladám žiadnu prílohu k týmto cestám',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 8),
                  RadioListTile<String>(
                    value: 'Rez krizovania',
                    groupValue: selectedTyp,
                    onChanged: (val) => setState(() => selectedTyp = val!),
                    title: Row(
                      children: [
                        Icon(Icons.engineering_rounded, size: 18, color: color),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text('Rez krizovania'),
                        ),
                      ],
                    ),
                    subtitle: const Padding(
                      padding: EdgeInsets.only(left: 26, top: 4),
                      child: Text(
                        'Priložím technický rez miesta križovania',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Zrušiť'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // ✅ Nastav TEN ISTÝ typ pre obe cesty
                      widget.provider.setCestyITyp(selectedTyp);
                      widget.provider.setCestyIITyp(selectedTyp);
                      Navigator.pop(context);

                      // Zobraz potvrdenie
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle_outline, color: Colors.white),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  hasBoth
                                      ? 'Nastavenie uložené pre obe cesty'
                                      : 'Nastavenie uložené',
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: const Text('Uložiť'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
