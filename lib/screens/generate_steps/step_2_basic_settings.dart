// ========================================
// OPRAVENÝ STEP_2_BASIC_SETTINGS.DART
// S TextEditingController a MOBILE SUPPORT
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:vyjadrenia/widgets/ai_extraction_widget.dart';
import 'package:vyjadrenia/widgets/team_member_selector_widget.dart';
import '../../providers/step2_data_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/project_designer_dropdown.dart';
import '../../widgets/builder_dialog.dart';
import '../../models/builder_model.dart';

class Step2BasicSettings extends StatelessWidget {
  const Step2BasicSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768; // ✅ Pridané

    return Consumer<Step2DataProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16 : 24), // ✅ Responsívny padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AIExtractionWidget(),
              SizedBox(height: isMobile ? 20 : 32),

              _buildSectionHeader(
                context,
                icon: Icons.article_rounded,
                title: 'Základné údaje',
                color: AppTheme.primaryRed,
                isMobile: isMobile, // ✅
              ),
              SizedBox(height: isMobile ? 12 : 16),
              _buildBasicDataSection(context, provider, isMobile), // ✅
              SizedBox(height: isMobile ? 20 : 32),

              _buildSectionHeader(
                context,
                icon: Icons.engineering_rounded,
                title: 'Technické údaje',
                color: Colors.blue,
                isMobile: isMobile, // ✅
              ),
              SizedBox(height: isMobile ? 12 : 16),
              _buildTechnicalDataSection(context, provider, isMobile), // ✅
              SizedBox(height: isMobile ? 20 : 32),

              _buildSectionHeader(
                context,
                icon: Icons.input_rounded,
                title: isMobile
                    ? 'Vstupné údaje § 21/22'
                    : 'Vstupné údaje podľa § 21 alebo § 22 Stavebného zákona',
                color: Colors.green,
                isMobile: isMobile, // ✅
              ),
              SizedBox(height: isMobile ? 12 : 16),
              _buildInputDataSection(context, provider, isMobile), // ✅
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, {
        required IconData icon,
        required String title,
        required Color color,
        required bool isMobile, // ✅ Pridané
      }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            child: Icon(icon, color: color, size: isMobile ? 20 : 22),
          ),
          SizedBox(width: isMobile ? 10 : 12),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: isMobile ? 15 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicDataSection(
      BuildContext context, Step2DataProvider provider, bool isMobile) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.darkCard : Colors.white;
    final border = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 1),
      ),
      child: Column(
        children: [
          if (isMobile)
            Column(
              children: [
                _buildTextField(
                  context: context,
                  label: 'Značka',
                  hint: 'Napr. 2024/001',
                  icon: Icons.tag_rounded,
                  value: provider.znacka,
                  onChanged: provider.setZnacka,
                  required: true,
                  isMobile: isMobile,
                  warningMessage: provider.getWarning('cislo_zakazky'),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  context: context,
                  label: 'Miesto stavby',
                  hint: 'Napr. Košice',
                  icon: Icons.location_on_rounded,
                  value: provider.miestoStavby,
                  onChanged: provider.setMiestoStavby,
                  required: true,
                  isMobile: isMobile,
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    context: context,
                    label: 'Značka',
                    hint: 'Napr. 2024/001',
                    icon: Icons.tag_rounded,
                    value: provider.znacka,
                    onChanged: provider.setZnacka,
                    required: true,
                    isMobile: isMobile,
                    warningMessage: provider.getWarning('cislo_zakazky'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    context: context,
                    label: 'Miesto stavby',
                    hint: 'Napr. Košice',
                    icon: Icons.location_on_rounded,
                    value: provider.miestoStavby,
                    onChanged: provider.setMiestoStavby,
                    required: true,
                    isMobile: isMobile,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),
          _buildTextField(
            context: context,
            label: 'Názov stavby',
            hint: 'Zadajte názov stavby',
            icon: Icons.business_rounded,
            value: provider.nazovStavby,
            onChanged: provider.setNazovStavby,
            required: true,
            isMobile: isMobile,
          ),
          const SizedBox(height: 16),
          _buildInvestorField(context, provider, isMobile),

          const SizedBox(height: 16),
          const TeamMemberSelector(),
        ],
      ),
    );
  }

  Widget _buildInvestorField(
      BuildContext context, Step2DataProvider provider, bool isMobile) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppTheme.textDark;
    final investorBoxBg = isDark ? AppTheme.darkSurface : Colors.grey[50];
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Investor',
              style: TextStyle(
                fontSize: isMobile ? 13 : 14,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const Text(
              ' *',
              style: TextStyle(
                color: AppTheme.primaryRed,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: isMobile ? 6 : 8),
        Container(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          decoration: BoxDecoration(
            color: investorBoxBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            children: [
              Icon(
                Icons.account_balance_rounded,
                color: AppTheme.primaryRed,
                size: isMobile ? 18 : 20,
              ),
              SizedBox(width: isMobile ? 10 : 12),
              Expanded(
                child: Text(
                  provider.investor,
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 14,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isMobile ? 10 : 12),
        Container(
          decoration: BoxDecoration(
            color: provider.isCustomBuilder
                ? AppTheme.primaryRed.withOpacity(0.05)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: provider.isCustomBuilder
                  ? AppTheme.primaryRed.withOpacity(0.3)
                  : borderColor,
              width: 1,
            ),
          ),
          child: CheckboxListTile(
            value: provider.isCustomBuilder,
            onChanged: (value) async {
              if (value == true) {
                print('🔶 fieldWarnings pri otvorení dialógu: ${provider.fieldWarnings}');
                final result = await showDialog<BuilderModel>(
                  context: context,
                  builder: (context) => BuilderDialog(
                    initialBuilder: provider.isCustomBuilder ? provider.builder : null,
                    fieldWarnings: provider.fieldWarnings,
                  ),
                );
                if (result != null) {
                  provider.setBuilder(result);
                } else {
                  provider.setIsCustomBuilder(false);
                }
              } else {
                provider.setIsCustomBuilder(false);
              }
            },
            title: Row(
              children: [
                Icon(
                  Icons.warning_rounded,
                  color: provider.isCustomBuilder ? AppTheme.primaryRed : Colors.orange,
                  size: isMobile ? 18 : 20,
                ),
                SizedBox(width: isMobile ? 6 : 8),
                Expanded(
                  child: Text(
                    'Stavebník iný ako VSD, a.s.',
                    style: TextStyle(
                      fontSize: isMobile ? 13 : 14,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            activeColor: AppTheme.primaryRed,
            contentPadding: EdgeInsets.symmetric(
              horizontal: isMobile ? 8 : 12,
              vertical: isMobile ? 4 : 8,
            ),
          ),
        ),
        if (provider.isCustomBuilder) ...[
          SizedBox(height: isMobile ? 10 : 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                print('🔶 fieldWarnings pri otvorení dialógu: ${provider.fieldWarnings}');
                final result = await showDialog<BuilderModel>(
                  context: context,
                  builder: (context) => BuilderDialog(
                    initialBuilder: provider.builder,
                    fieldWarnings: provider.fieldWarnings,
                  ),
                );
                if (result != null) {
                  provider.setBuilder(result);
                }
              },
              icon: Icon(Icons.edit_rounded, size: isMobile ? 16 : 18),
              label: Text(
                'Upraviť údaje stavebníka',
                style: TextStyle(fontSize: isMobile ? 13 : 14),
              ),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12 : 16,
                  vertical: isMobile ? 12 : 14,
                ),
                side: const BorderSide(color: AppTheme.primaryRed),
                foregroundColor: AppTheme.primaryRed,
              ),
            ),
          ),
        ],
      ],
    );
  }

  // Pokračujem v ďalšej časti...



  Widget _buildTechnicalDataSection(
      BuildContext context, Step2DataProvider provider, bool isMobile) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.darkCard : Colors.white;
    final border = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 1),
      ),
      child: Column(
        children: [
          if (isMobile)
            Column(
              children: [
                _buildTextField(
                  context: context,
                  label: 'Katastrálne územie',
                  hint: 'Len ak je rôzne od mesta',
                  icon: Icons.map_rounded,
                  value: provider.katastralneUzemie,
                  onChanged: provider.setKatastralneUzemie,
                  isMobile: isMobile,
                ),
                const SizedBox(height: 16),
                // ✅ NOVÝ TextField pre mierku s validáciou
                _buildMierkaTextField(
                  context: context,
                  provider: provider,
                  isMobile: isMobile,
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    context: context,
                    label: 'Katastrálne územie',
                    hint: 'Len ak je rôzne od mesta',
                    icon: Icons.map_rounded,
                    value: provider.katastralneUzemie,
                    onChanged: provider.setKatastralneUzemie,
                    isMobile: isMobile,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMierkaTextField(
                    context: context,
                    provider: provider,
                    isMobile: isMobile,
                  ),
                ),
              ],
            ),


          if (isMobile)
            Column(
              children: [
                _buildNumberField(
                  context: context,
                  label: 'Počet situácií',
                  icon: Icons.layers_rounded,
                  value: provider.pocetSituacii,
                  onChanged: (value) => provider.setPocetSituacii(value ?? 1),
                  isMobile: isMobile,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  context: context,
                  label: 'Parcelné číslo',
                  hint: 'Napr. 123/4',
                  icon: Icons.numbers_rounded,
                  value: provider.parcelneCislo,
                  onChanged: provider.setParcelneCislo,
                  required: true,
                  isMobile: isMobile,
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: _buildNumberField(
                    context: context,
                    label: 'Počet situácií',
                    icon: Icons.layers_rounded,
                    value: provider.pocetSituacii,
                    onChanged: (value) => provider.setPocetSituacii(value ?? 1),
                    isMobile: isMobile,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    context: context,
                    label: 'Parcelné číslo',
                    hint: 'Napr. 123/4',
                    icon: Icons.numbers_rounded,
                    value: provider.parcelneCislo,
                    onChanged: provider.setParcelneCislo,
                    required: true,
                    isMobile: isMobile,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),

          if (isMobile)
            Column(
              children: [
                _buildTextField(
                  context: context,
                  label: 'List vlastníctva',
                  hint: 'Napr. LV 1234',
                  icon: Icons.description_rounded,
                  value: provider.listVlastnictva,
                  onChanged: provider.setListVlastnictva,
                  required: true,
                  isMobile: isMobile,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  context: context,
                  label: 'ID stavby',
                  hint: 'ID stavby (voliteľné)',
                  icon: Icons.fingerprint_rounded,
                  value: provider.idStavby,
                  onChanged: provider.setIdStavby,
                  isMobile: isMobile,
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    context: context,
                    label: 'List vlastníctva',
                    hint: 'Napr. LV 1234',
                    icon: Icons.description_rounded,
                    value: provider.listVlastnictva,
                    onChanged: provider.setListVlastnictva,
                    required: true,
                    isMobile: isMobile,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    context: context,
                    label: 'ID stavby',
                    hint: 'ID stavby (voliteľné)',
                    icon: Icons.fingerprint_rounded,
                    value: provider.idStavby,
                    onChanged: provider.setIdStavby,
                    isMobile: isMobile,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),
          _buildTextField(
            context: context,
            label: 'Kód stavby',
            hint: 'Prednastavený: 2315',
            icon: Icons.qr_code_rounded,
            value: provider.kodStavby,
            onChanged: provider.setKodStavby,
            isMobile: isMobile,
          ),
        ],
      ),
    );
  }


  Widget _buildMierkaTextField({
    required BuildContext context,
    required Step2DataProvider provider,
    required bool isMobile,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppTheme.textDark;
    final fieldBg = isDark ? AppTheme.darkSurface : Colors.white;

    // ✅ UPRAVENÁ validácia - prázdny string je OK
    String? validateMierka(String? value) {
      // ✅ Ak je prázdne, je to validné (nepovinné pole)
      if (value == null || value.isEmpty) {
        return null; // Validné
      }

      // Regex pre formát 1:XXX (napr. 1:500, 1:1000)
      final regex = RegExp(r'^1:\d+$');

      if (!regex.hasMatch(value)) {
        return 'Formát musí byť 1:číslo (napr. 1:500)';
      }

      // Skontroluj, či číslo je rozumné (napr. medzi 100 a 50000)
      final scale = int.tryParse(value.split(':')[1]);
      if (scale == null || scale < 50 || scale > 100000) {
        return 'Mierka musí byť medzi 1:50 a 1:100000';
      }

      return null; // Validné
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ ODSTRÁNENÁ hviezdička - pole už nie je povinné
        Text(
          'Mierka',
          style: TextStyle(
            fontSize: isMobile ? 13 : 14,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        SizedBox(height: isMobile ? 6 : 8),

        // ✅ Pomocné tlačidlá PRED textfieldom
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _buildQuickMierkaChip(context, '1:250', provider, isMobile),
            _buildQuickMierkaChip(context, '1:500', provider, isMobile),
            _buildQuickMierkaChip(context, '1:1000', provider, isMobile),
            _buildQuickMierkaChip(context, '1:2000', provider, isMobile),
            _buildQuickMierkaChip(context, '1:5000', provider, isMobile),
          ],
        ),

        SizedBox(height: isMobile ? 10 : 12),

        _ManagedTextField(
          initialValue: provider.mierka,
          onChanged: (value) {
            provider.setMierka(value);
          },
          maxLines: 1,
          isMobile: isMobile,
          hint: '1:500 (voliteľné)', // ✅ Upravený hint
          icon: Icons.straighten_rounded,
          isDark: isDark,
          fieldBg: fieldBg,
          keyboardType: TextInputType.text,
          validator: validateMierka, // ✅ Používa upravenú validáciu
        ),

        // ✅ PRIDANÝ pomocný text
        if (provider.mierka.isEmpty) ...[
          SizedBox(height: isMobile ? 6 : 8),
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: isMobile ? 14 : 16,
                color: isDark ? Colors.white38 : Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Mierka je voliteľná. Ak ju nezadáte, nebude uvedená v dokumentoch.',
                  style: TextStyle(
                    fontSize: isMobile ? 11 : 12,
                    color: isDark ? Colors.white38 : Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

// ========================================
// POMOCNÉ TLAČIDLÁ PRE RÝCHLY VÝBER MIERKY
// ========================================

  Widget _buildQuickMierkaChip(
      BuildContext context,
      String value,
      Step2DataProvider provider,
      bool isMobile,
      ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = provider.mierka == value;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => provider.setMierka(value),
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 14,
            vertical: isMobile ? 8 : 10,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryRed
                : (isDark ? AppTheme.darkSurface : Colors.grey[100]),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primaryRed
                  : (isDark ? Colors.white.withOpacity(0.1) : Colors.grey[300]!),
              width: 1.5,
            ),
            boxShadow: isSelected ? [
              BoxShadow(
                color: AppTheme.primaryRed.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 12 : 13,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.white70 : Colors.grey[700]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputDataSection(
      BuildContext context, Step2DataProvider provider, bool isMobile) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.darkCard : Colors.white;
    final border = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 1),
      ),
      child: Column(
        children: [
          if (isMobile)
            Column(
              children: [
                _buildDateField(
                  context: context,
                  label: 'Dátum dokumentácie',
                  icon: Icons.calendar_today_rounded,
                  value: provider.datumDokumentacie,
                  onChanged: provider.setDatumDokumentacie,
                  required: true,
                  isMobile: isMobile,
                ),
                const SizedBox(height: 16),
                const ProjectDesignerDropdown(),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: _buildDateField(
                    context: context,
                    label: 'Dátum dokumentácie',
                    icon: Icons.calendar_today_rounded,
                    value: provider.datumDokumentacie,
                    onChanged: provider.setDatumDokumentacie,
                    required: true,
                    isMobile: isMobile,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: ProjectDesignerDropdown(),
                ),
              ],
            ),
          const SizedBox(height: 16),

          if (isMobile)
            Column(
              children: [
                _buildDropdownField(
                  context: context,
                  label: 'Typ žiadosti',
                  icon: Icons.request_page_rounded,
                  value: provider.typZiadosti,
                  items: provider.typZiadostiOptions,
                  onChanged: (value) => provider.setTypZiadosti(value!),
                  isMobile: isMobile,
                ),
                const SizedBox(height: 16),
                _buildDropdownField(
                  context: context,
                  label: 'Žiadateľ',
                  icon: Icons.person_outline_rounded,
                  value: provider.ziadatel,
                  items: provider.ziadatelOptions,
                  onChanged: (value) => provider.setZiadatel(value!),
                  isMobile: isMobile,
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: _buildDropdownField(
                    context: context,
                    label: 'Typ žiadosti',
                    icon: Icons.request_page_rounded,
                    value: provider.typZiadosti,
                    items: provider.typZiadostiOptions,
                    onChanged: (value) => provider.setTypZiadosti(value!),
                    isMobile: isMobile,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDropdownField(
                    context: context,
                    label: 'Žiadateľ',
                    icon: Icons.person_outline_rounded,
                    value: provider.ziadatel,
                    items: provider.ziadatelOptions,
                    onChanged: (value) => provider.setZiadatel(value!),
                    isMobile: isMobile,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),

          if (isMobile)
            Column(
              children: [
                _buildDropdownField(
                  context: context,
                  label: 'Súbor stavieb',
                  icon: Icons.account_tree_rounded,
                  value: provider.suborStavieb,
                  items: provider.suborStaviebOptions,
                  onChanged: (value) => provider.setSuborStavieb(value!),
                  isMobile: isMobile,
                ),
                const SizedBox(height: 16),
                _buildDropdownField(
                  context: context,
                  label: 'Projektová dokumentácia',
                  icon: Icons.folder_rounded,
                  value: provider.projektovaDokumentacia,
                  items: provider.projektovaDokumentaciaOptions,
                  onChanged: (value) => provider.setProjektovaDokumentacia(value!),
                  isMobile: isMobile,
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: _buildDropdownField(
                    context: context,
                    label: 'Súbor stavieb',
                    icon: Icons.account_tree_rounded,
                    value: provider.suborStavieb,
                    items: provider.suborStaviebOptions,
                    onChanged: (value) => provider.setSuborStavieb(value!),
                    isMobile: isMobile,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDropdownField(
                    context: context,
                    label: 'Projektová dokumentácia',
                    icon: Icons.folder_rounded,
                    value: provider.projektovaDokumentacia,
                    items: provider.projektovaDokumentaciaOptions,
                    onChanged: (value) => provider.setProjektovaDokumentacia(value!),
                    isMobile: isMobile,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),
          _buildDropdownField(
            context: context,
            label: 'Poplatok',
            icon: Icons.payments_rounded,
            value: provider.poplatok,
            items: provider.poplatokOptions,
            onChanged: (value) => provider.setPoplatok(value!),
            isMobile: isMobile,
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),
          _buildDynamicListSection(
            context: context,
            provider: provider,
            title: 'Objekty stavby',
            icon: Icons.apartment_rounded,
            items: provider.objektyStavby,
            onAdd: () => _showAddBuildingObjectDialog(context, provider),
            onRemove: (index) => provider.removeObjektStavby(index),
            isMobile: isMobile,
            itemBuilder: (obj, index) => _buildListItem(
              context: context,
              name: obj.name,
              subtitle: 'ID: ${obj.id}',
              onDelete: () => provider.removeObjektStavby(index),
              isMobile: isMobile,
            ),
          ),
          const SizedBox(height: 24),
          _buildDynamicListSection(
            context: context,
            provider: provider,
            title: 'Prevádzkové súbory',
            icon: Icons.inventory_2_rounded,
            items: provider.prevadzkoveSubory,
            onAdd: () => _showAddOperationalSetDialog(context, provider),
            onRemove: (index) => provider.removePrevadzkovySubor(index),
            isMobile: isMobile,
            itemBuilder: (set, index) => _buildListItem(
              context: context,
              name: set.name,
              subtitle: 'ID: ${set.id}',
              onDelete: () => provider.removePrevadzkovySubor(index),
              isMobile: isMobile,
            ),
          ),
        ],
      ),
    );
  }

  // ========== HELPER WIDGETS ==========

  Widget _buildTextField({
    required BuildContext context,
    required String label,
    required String hint,
    required IconData icon,
    required String value,
    required Function(String) onChanged,
    required bool isMobile,
    bool required = false,
    int maxLines = 1,
    String? warningMessage,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppTheme.textDark;
    final fieldBg = isDark ? AppTheme.darkSurface : Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: isMobile ? 13 : 14,
                  fontWeight: FontWeight.w600,
                  // ← Oranžový label pri warningu
                  color: warningMessage != null ? Colors.orange : textColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (required)
              const Text(
                ' *',
                style: TextStyle(
                  color: AppTheme.primaryRed,
                  fontWeight: FontWeight.w600,
                ),
              ),
            // ← Oranžová ikonka upozornenia vedľa labelu
            if (warningMessage != null) ...[
              const SizedBox(width: 4),
              Tooltip(
                message: warningMessage,
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: isMobile ? 14 : 16,
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: isMobile ? 6 : 8),
        _ManagedTextField(
          initialValue: value,
          onChanged: onChanged,
          maxLines: maxLines,
          isMobile: isMobile,
          hint: hint,
          icon: icon,
          isDark: isDark,
          fieldBg: fieldBg,
          validator: validator,
          warningMessage: warningMessage, // ← teraz ide priamo, nie cez validator
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required BuildContext context,
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    required bool isMobile,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppTheme.textDark;
    final fieldBg = isDark ? AppTheme.darkSurface : Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isMobile ? 13 : 14,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        SizedBox(height: isMobile ? 6 : 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: TextStyle(fontSize: isMobile ? 13 : 14),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: onChanged,
          isExpanded: true,
          dropdownColor: isDark ? AppTheme.darkCard : Colors.white,
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              size: isMobile ? 18 : 20,
              color: isDark ? Colors.white54 : null,
            ),
            filled: true,
            fillColor: fieldBg,
            contentPadding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 16,
              vertical: isMobile ? 14 : 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNumberField({
    required BuildContext context,
    required String label,
    required IconData icon,
    required int value,
    required Function(int?) onChanged,
    required bool isMobile,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppTheme.textDark;
    final fieldBg = isDark ? AppTheme.darkSurface : Colors.white;
    final controller = TextEditingController(text: value.toString());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isMobile ? 13 : 14,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: isMobile ? 6 : 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (val) => onChanged(int.tryParse(val)),
          style: TextStyle(fontSize: isMobile ? 14 : null),
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              size: isMobile ? 18 : 20,
              color: isDark ? Colors.white54 : null,
            ),
            filled: true,
            fillColor: fieldBg,
            contentPadding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 16,
              vertical: isMobile ? 14 : 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required BuildContext context,
    required String label,
    required IconData icon,
    required DateTime? value,
    required Function(DateTime?) onChanged,
    required bool isMobile,
    bool required = false,
  }) {
    final dateFormat = DateFormat('dd.MM.yyyy');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppTheme.textDark;
    final fieldBg = isDark ? AppTheme.darkSurface : Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: isMobile ? 13 : 14,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (required)
              const Text(
                ' *',
                style: TextStyle(
                  color: AppTheme.primaryRed,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        SizedBox(height: isMobile ? 6 : 8),
        TextFormField(
          readOnly: true,
          controller: TextEditingController(
            text: value != null ? dateFormat.format(value) : '',
          ),
          style: TextStyle(fontSize: isMobile ? 14 : null),
          decoration: InputDecoration(
            hintText: 'Vyberte dátum',
            hintStyle: TextStyle(
              color: isDark ? Colors.white54 : null,
              fontSize: isMobile ? 13 : null,
            ),
            prefixIcon: Icon(
              icon,
              size: isMobile ? 18 : 20,
              color: isDark ? Colors.white54 : null,
            ),
            suffixIcon: value != null
                ? IconButton(
              icon: Icon(
                Icons.clear,
                size: isMobile ? 16 : 18,
                color: isDark ? Colors.white54 : null,
              ),
              onPressed: () => onChanged(null),
            )
                : null,
            filled: true,
            fillColor: fieldBg,
            contentPadding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 16,
              vertical: isMobile ? 14 : 16,
            ),
          ),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: value ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: isDark
                        ? const ColorScheme.dark(primary: AppTheme.primaryRed)
                        : const ColorScheme.light(primary: AppTheme.primaryRed),
                  ),
                  child: child!,
                );
              },
            );
            if (date != null) {
              onChanged(date);
            }
          },
        ),
      ],
    );
  }

  Widget _buildDynamicListSection<T>({
    required BuildContext context,
    required Step2DataProvider provider,
    required String title,
    required IconData icon,
    required List<T> items,
    required VoidCallback onAdd,
    required Function(int) onRemove,
    required Widget Function(T, int) itemBuilder,
    required bool isMobile,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppTheme.textDark;
    final emptyBg = isDark ? AppTheme.darkSurface : AppTheme.lightGray;
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor;

    return Column(
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
                icon,
                color: AppTheme.primaryRed,
                size: isMobile ? 16 : 18,
              ),
            ),
            SizedBox(width: isMobile ? 8 : 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: isMobile ? 15 : 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: Icon(Icons.add, size: isMobile ? 16 : 18),
              label: Text(
                'Pridať',
                style: TextStyle(fontSize: isMobile ? 13 : 14),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12 : 16,
                  vertical: isMobile ? 8 : 10,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: isMobile ? 10 : 12),
        if (items.isEmpty)
          Container(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            decoration: BoxDecoration(
              color: emptyBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: isMobile ? 28 : 32,
                    color: isDark ? Colors.white30 : AppTheme.textLight,
                  ),
                  SizedBox(height: isMobile ? 6 : 8),
                  Text(
                    'Zatiaľ neboli pridané žiadne položky',
                    style: TextStyle(
                      color: isDark ? Colors.white38 : AppTheme.textLight,
                      fontSize: isMobile ? 13 : 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: borderColor, width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: borderColor),
              itemBuilder: (context, index) => itemBuilder(items[index], index),
            ),
          ),
      ],
    );
  }

  Widget _buildListItem({
    required BuildContext context,
    required String name,
    required String subtitle,
    required VoidCallback onDelete,
    required bool isMobile,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : null;
    final subTextColor = isDark ? Colors.white70 : AppTheme.textLight;

    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 16,
        vertical: isMobile ? 4 : 8,
      ),
      leading: Container(
        width: isMobile ? 36 : 40,
        height: isMobile ? 36 : 40,
        decoration: BoxDecoration(
          color: AppTheme.primaryRed.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.check_circle_rounded,
          color: AppTheme.primaryRed,
          size: isMobile ? 18 : 20,
        ),
      ),
      title: Text(
        name,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: isMobile ? 13 : 14,
          color: textColor,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: isMobile ? 11 : 12,
          color: subTextColor,
        ),
      ),
      trailing: IconButton(
        icon: Icon(
          Icons.delete_outline_rounded,
          size: isMobile ? 18 : 20,
        ),
        color: Colors.red,
        onPressed: onDelete,
        padding: EdgeInsets.all(isMobile ? 4 : 8),
      ),
    );
  }

  // ========== DIALÓGY ==========

  void _showAddBuildingObjectDialog(
      BuildContext context, Step2DataProvider provider) {
    final nameController = TextEditingController();
    final idController = TextEditingController();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.apartment_rounded,
                  color: AppTheme.primaryRed,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Pridať objekt stavby',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✅ Info box s príkladom
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Colors.blue[700],
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Príklad: SO 01 - Trafostanica',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.blue[200] : Colors.blue[900],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              TextField(
                controller: idController,
                decoration: InputDecoration(
                  labelText: 'ID objektu',
                  hintText: 'napr. SO 01', // ✅ Hint
                  prefixIcon: const Icon(Icons.tag),
                  filled: true,
                  fillColor: isDark ? AppTheme.darkSurface : Colors.grey[50],
                ),
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Názov objektu',
                  hintText: 'napr. Trafostanica', // ✅ Hint
                  prefixIcon: const Icon(Icons.description),
                  filled: true,
                  fillColor: isDark ? AppTheme.darkSurface : Colors.grey[50],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Zrušiť'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    idController.text.isNotEmpty) {
                  provider.addObjektStavby(
                    BuildingObject(
                      name: nameController.text,
                      id: idController.text,
                    ),
                  );
                  Navigator.of(context).pop();
                }
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Pridať'),
            ),
          ],
        );
      },
    );
  }

  void _showAddOperationalSetDialog(
      BuildContext context, Step2DataProvider provider) {
    final nameController = TextEditingController();
    final idController = TextEditingController();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.inventory_2_rounded,
                  color: AppTheme.primaryRed,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Pridať prevádzkový súbor',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✅ Info box s príkladom
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Colors.blue[700],
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Príklad: PS 01 - Trafostanica',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.blue[200] : Colors.blue[900],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              TextField(
                controller: idController,
                decoration: InputDecoration(
                  labelText: 'ID súboru',
                  hintText: 'napr. PS 01', // ✅ Hint
                  prefixIcon: const Icon(Icons.tag),
                  filled: true,
                  fillColor: isDark ? AppTheme.darkSurface : Colors.grey[50],
                ),
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Názov súboru',
                  hintText: 'napr. Trafostanica', // ✅ Hint
                  prefixIcon: const Icon(Icons.description),
                  filled: true,
                  fillColor: isDark ? AppTheme.darkSurface : Colors.grey[50],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Zrušiť'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    idController.text.isNotEmpty) {
                  provider.addPrevadzkovySubor(
                    OperationalSet(
                      name: nameController.text,
                      id: idController.text,
                    ),
                  );
                  Navigator.of(context).pop();
                }
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Pridať'),
            ),
          ],
        );
      },
    );
  }
}

// ========== MANAGED TEXT FIELD ==========
// StatefulWidget ktorý správne spravuje TextEditingController
// PRIDAŤ NA KONIEC SÚBORU - ZA POSLEDNÚ } TRIEDY Step2BasicSettings

class _ManagedTextField extends StatefulWidget {
  final String initialValue;
  final Function(String) onChanged;
  final int maxLines;
  final bool isMobile;
  final String hint;
  final IconData icon;
  final bool isDark;
  final Color fieldBg;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator; // pre štandardnú validáciu (červená)
  final String? warningMessage;               // ← NOVÉ: pre AI heuristiku (oranžová)

  const _ManagedTextField({
    required this.initialValue,
    required this.onChanged,
    required this.maxLines,
    required this.isMobile,
    required this.hint,
    required this.icon,
    required this.isDark,
    required this.fieldBg,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.warningMessage, // ← NOVÉ
  });

  @override
  State<_ManagedTextField> createState() => _ManagedTextFieldState();
}

class _ManagedTextFieldState extends State<_ManagedTextField> {
  late TextEditingController _controller;
  String? _validationError; // len pre štandardný validator (červená)

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(_ManagedTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }
    // warningMessage sa číta priamo z widget.warningMessage — nepotrebuje setState
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _runValidator(String value) {
    if (widget.validator != null) {
      setState(() {
        _validationError = widget.validator!(value);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // warningMessage má prednosť pred _validationError — zobrazujeme len jedno
    final hasWarning = widget.warningMessage != null;
    final displayError = hasWarning ? widget.warningMessage : _validationError;
    final errorColor = hasWarning ? Colors.orange : Colors.red;

    return TextFormField(
      controller: _controller,
      onChanged: (value) {
        widget.onChanged(value);
        _runValidator(value);
      },
      maxLines: widget.maxLines,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      style: TextStyle(fontSize: widget.isMobile ? 14 : null),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: TextStyle(
          color: widget.isDark ? Colors.white54 : null,
          fontSize: widget.isMobile ? 13 : null,
        ),
        prefixIcon: Icon(
          widget.icon,
          size: widget.isMobile ? 18 : 20,
          color: hasWarning
              ? Colors.orange
              : (widget.isDark ? Colors.white54 : null),
        ),
        // ← Oranžové pozadie pri warningu (jemné)
        fillColor: hasWarning
            ? Colors.orange.withOpacity(widget.isDark ? 0.08 : 0.05)
            : widget.fieldBg,
        filled: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: widget.isMobile ? 12 : 16,
          vertical: widget.isMobile ? 14 : 16,
        ),
        errorText: displayError,
        errorStyle: TextStyle(
          color: errorColor,
          fontSize: widget.isMobile ? 11 : 12,
        ),
        // Border keď pole nie je vo focuse
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: hasWarning
              ? BorderSide(color: Colors.orange, width: 1.5)
              : BorderSide(
            color: widget.isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.grey.withOpacity(0.3),
            width: 1,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: errorColor, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: hasWarning ? Colors.orange : Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: errorColor, width: 2),
        ),
      ),
    );
  }
}

