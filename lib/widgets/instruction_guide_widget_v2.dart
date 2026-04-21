// lib/widgets/instruction_guide_widget_v2.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/step2_data_provider.dart';
import '../providers/step3_data_provider.dart';
import '../providers/step5_data_provider.dart';
import '../utils/app_theme.dart';
import '../services/pdf_export_service.dart';

class InstructionGuideWidgetV2 extends StatefulWidget {
  final List<String> generatedFiles;

  const InstructionGuideWidgetV2({
    Key? key,
    required this.generatedFiles,
  }) : super(key: key);

  @override
  State<InstructionGuideWidgetV2> createState() => _InstructionGuideWidgetV2State();
}

class _InstructionGuideWidgetV2State extends State<InstructionGuideWidgetV2> {
  final Map<String, bool> _checkedItems = {};

  @override
  Widget build(BuildContext context) {
    final step2 = context.read<Step2DataProvider>();
    final step3 = context.read<Step3DataProvider>();
    final step5 = context.read<Step5DataProvider>();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    final bool p56Check = step3.selectedBuildingPurpose?.purposeName.contains('56') ?? false;

    final allApplications = step5.applications
        .where((app) => !step5.isHidden(app.applicationId))
        .toList();

    final zsrApplications = allApplications.where((app) => app.railways == true).toList();

    final nonZsrApplications = allApplications.where((app) => app.railways != true).toList();

    final printApplications = nonZsrApplications
        .where((app) => app.submission == 'P')
        .toList();

    final electronicApplications = nonZsrApplications
        .where((app) => app.submission == 'E')
        .toList();

    final onlineApplications = nonZsrApplications
        .where((app) => app.submission == 'online')
        .toList();

    final mailApplications = nonZsrApplications
        .where((app) => app.submission == 'M')
        .toList();

    final bool hasMOSR = nonZsrApplications.any((app) =>
    !step5.isHidden(app.applicationId) &&
        (app.name.toString().toLowerCase().contains('ministerstvo obrany') ||
            app.name.toString().toLowerCase().contains('mosr'))
    );

    final bool hasRUVZ = nonZsrApplications.any((app) =>
    !step5.isHidden(app.applicationId) &&
        (app.name.toString().toLowerCase().contains('rúvz') ||
            app.name.toString().toLowerCase().contains('regionálny úrad'))
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(isMobile ? 10 : 24),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 1000,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.transparent,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildHeader(context, isMobile),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 16 : 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProjectInfoCard(context, step2, isMobile),
                    SizedBox(height: isMobile ? 24 : 32),
                    _buildIntroMessage(context, isMobile),
                    SizedBox(height: isMobile ? 24 : 32),


                    if (printApplications.isNotEmpty || hasMOSR) ...[
                      _buildSectionHeader(
                        context,
                        title: 'Tlačené žiadosti a obálky',
                        icon: Icons.print_rounded,
                        color: Colors.orange,
                        isMobile: isMobile,
                      ),
                      const SizedBox(height: 16),
                      if (printApplications.isNotEmpty)
                        _buildChecklistGroup(context, printApplications, isMobile, p56Check, step3),
                      const SizedBox(height: 16),
                      _buildDocumentsSubsection(
                          context,
                          printApplications,
                          p56Check,
                          hasMOSR,
                          hasRUVZ,
                          isMobile
                      ),
                      SizedBox(height: isMobile ? 24 : 32),
                    ],

                    if (electronicApplications.isNotEmpty) ...[
                      _buildSectionHeader(
                        context,
                        title: 'Elektronické podania (Slovensko.sk)',
                        icon: Icons.alternate_email_rounded,
                        color: Colors.blue,
                        isMobile: isMobile,
                      ),
                      const SizedBox(height: 16),
                      _buildChecklistGroup(context, electronicApplications, isMobile, p56Check, step3),
                      const SizedBox(height: 16),
                      _buildSlovenskoSkInfo(context, step2, isMobile),
                      SizedBox(height: isMobile ? 24 : 32),
                    ],

                    if (onlineApplications.isNotEmpty) ...[
                      _buildSectionHeader(
                        context,
                        title: 'Online portály',
                        icon: Icons.public_rounded,
                        color: Colors.purple,
                        isMobile: isMobile,
                      ),
                      const SizedBox(height: 16),
                      _buildChecklistGroup(context, onlineApplications, isMobile, p56Check, step3),
                      SizedBox(height: isMobile ? 24 : 32),
                    ],


                    if (zsrApplications.isNotEmpty) ...[
                      _buildZsrSection(context, zsrApplications, isMobile, p56Check, step3),
                      SizedBox(height: isMobile ? 24 : 32),
                    ],

                    if (mailApplications.isNotEmpty || step3.orhazz) ...[
                      _buildSectionHeader(
                        context,
                        title: 'E-mailové žiadosti',
                        icon: Icons.mail_outline_rounded,
                        color: Colors.teal,
                        isMobile: isMobile,
                      ),
                      const SizedBox(height: 16),
                      if (step3.orhazz) ...[
                        _buildSpecialCheckboxItem(
                          context: context,
                          text: 'Poslať žiadosť o spracovanie projektu PBS na pbsengineering1@gmail.com',
                          key: 'special_orhazz_mail',
                          isMobile: isMobile,
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (mailApplications.isNotEmpty)
                        _buildChecklistGroup(context, mailApplications, isMobile, p56Check, step3),
                      SizedBox(height: isMobile ? 24 : 32),
                    ],
                  ],
                ),
              ),
            ),
            _buildFooter(context, isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistGroup(BuildContext context, List<dynamic> applications, bool isMobile, bool p56Check, Step3DataProvider step3) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor,
        ),
      ),
      child: Column(
        children: applications.asMap().entries.map((entry) {
          final index = entry.key;
          final app = entry.value;
          final isLast = index == applications.length - 1;

          List<String> attachments = [];
          if (app.technicalSituation == true) {
            attachments.add('Technická správa${p56Check ? ' (+1 extra P56)' : ''}');
          }
          if (app.situation == true) {
            attachments.add('Situácia v mierke');
          }
          if (app.situationA3 == true) {
            attachments.add('Situácia A3');
          }
          if (app.broaderRelations == true) {
            attachments.add('Situácia širších vzťahov');
          }
          if (app.roads1 == true || app.roads2 == true) {
            if (step3.cestyITyp != 'Bez prílohy' || step3.cestyIITyp != 'Bez prílohy') {
              attachments.add('Rez krížovania');
            }
          }
          
          String appNameLower = app.name.toString().toLowerCase();
          if (appNameLower.contains('ministerstvo obrany') || appNameLower.contains('mosr')) {
            attachments.add('Plná moc (pre MOSR)');
          }
          if (appNameLower.contains('rúvz') || appNameLower.contains('regionálny úrad')) {
            attachments.add('Plná moc (pre RÚVZ)');
            attachments.add('Obchodný register (pre RÚVZ)');
          }

          return Column(
            children: [
              _buildCheckboxItem(
                context: context,
                text: _formatAppName(app),
                subtext: app.envelope != null && app.envelope.isNotEmpty ? 'Obálka: ${app.envelope}' : null,
                attachments: attachments,
                key: 'app_${app.applicationId}',
                isMobile: isMobile,
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  color: isDark ? Colors.white.withOpacity(0.05) : AppTheme.borderColor.withOpacity(0.5),
                  indent: 56,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  String _formatAppName(dynamic app) {
    String base = app.department != null && app.department.isNotEmpty
        ? '${app.name} - ${app.department}'
        : app.name.toString();

    if (base.toLowerCase().contains('rúvz') ||
        base.toLowerCase().contains('regionálny úrad')) {
      return '$base - kolok 50€';
    }
    return base;
  }

  Widget _buildSpecialCheckboxItem({
    required BuildContext context,
    required String text,
    required String key,
    required bool isMobile,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isChecked = _checkedItems[key] ?? false;

    return InkWell(
      onTap: () => setState(() => _checkedItems[key] = !isChecked),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor,
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: isMobile ? 12 : 16,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isChecked ? AppTheme.primaryRed : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isChecked ? AppTheme.primaryRed : (isDark ? Colors.white54 : Colors.grey[400]!),
                  width: 2,
                ),
              ),
              child: isChecked ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: isMobile ? 14 : 15,
                  color: isDark ? Colors.white : AppTheme.textDark,
                  decoration: isChecked ? TextDecoration.lineThrough : null,
                  decorationColor: isDark ? Colors.white54 : Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckboxItem({
    required BuildContext context, 
    required String text, 
    String? subtext, 
    required List<String> attachments,
    required String key, 
    required bool isMobile
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isChecked = _checkedItems[key] ?? false;

    return InkWell(
      onTap: () => setState(() => _checkedItems[key] = !isChecked),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: isMobile ? 12 : 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24, height: 24,
              decoration: BoxDecoration(
                color: isChecked ? AppTheme.primaryRed : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isChecked ? AppTheme.primaryRed : (isDark ? Colors.white54 : Colors.grey[400]!), width: 2),
              ),
              child: isChecked ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(text, style: TextStyle(
                    fontSize: isMobile ? 14 : 15, 
                    color: isDark ? Colors.white : AppTheme.textDark, 
                    decoration: isChecked ? TextDecoration.lineThrough : null, 
                    decorationColor: isDark ? Colors.white54 : Colors.grey, 
                    fontWeight: FontWeight.w500
                  )),
                  if (subtext != null) ...[
                    const SizedBox(height: 4), 
                    Text(subtext, style: TextStyle(
                      fontSize: 13, 
                      color: isChecked ? (isDark ? Colors.white30 : Colors.grey[400]) : (isDark ? Colors.white60 : AppTheme.textLight)
                    ))
                  ],
                  if (attachments.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Prílohy: ${attachments.join(', ')}',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: isChecked 
                            ? (isDark ? Colors.white30 : Colors.grey[400]) 
                            : (isDark ? Colors.white54 : Colors.grey[600]),
                        decoration: isChecked ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsSubsection(
      BuildContext context,
      List<dynamic> applications,
      bool p56Check,
      bool hasMOSR,
      bool hasRUVZ,
      bool isMobile
      ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final step3 = context.read<Step3DataProvider>();

    int techSitCount = _countTechnicalSituation(applications) + (p56Check ? 1 : 0);
    int sitCount = _countSituation(applications);
    int sitA3Count = _countSituationA3(applications);
    int broadRelCount = _countBroaderRelations(applications);

    int rezKrizovaniaCount = 0;
    if (step3.cestyITyp != 'Bez prílohy' || step3.cestyIITyp != 'Bez prílohy') {
      rezKrizovaniaCount = applications.where((app) =>
      app.roads1 == true || app.roads2 == true
      ).length;
    }

    if (techSitCount == 0 && sitCount == 0 && sitA3Count == 0 &&
        broadRelCount == 0 && rezKrizovaniaCount == 0 && !hasMOSR && !hasRUVZ) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : AppTheme.lightGray.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.folder_open_rounded,
                  size: 18,
                  color: isDark ? Colors.white70 : AppTheme.textLight
              ),
              const SizedBox(width: 8),
              Text(
                'Celkový počet vytlačených príloh:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : AppTheme.textLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (techSitCount > 0)
            _buildAttachmentRow(context, '${techSitCount}x', 'Technická správa${p56Check ? ' (+1 extra P56)' : ''}'),
          if (sitCount > 0)
            _buildAttachmentRow(context, '${sitCount}x', 'Situácia v mierke'),
          if (sitA3Count > 0)
            _buildAttachmentRow(context, '${sitA3Count}x', 'Situácia A3'),
          if (broadRelCount > 0)
            _buildAttachmentRow(context, '${broadRelCount}x', 'Situácia širších vzťahov'),

          if (rezKrizovaniaCount > 0)
            _buildAttachmentRow(context, '${rezKrizovaniaCount}x', 'Rez krížovania'),

          if (hasMOSR || hasRUVZ) ...[
            const SizedBox(height: 8),
            Divider(color: isDark ? Colors.white10 : Colors.black12),
            const SizedBox(height: 8),

            if (hasMOSR) ...[
              _buildAttachmentRow(context, '1x', 'Plná moc (pre MOSR)'),
              const SizedBox(height: 8),
            ],
            if (hasRUVZ)
              _buildAttachmentRow(context, '1x', 'Plná moc (pre RÚVZ)'),
          ],
          if (hasRUVZ)
            _buildAttachmentRow(context, '1x', 'Obchodný register (pre RÚVZ)'),
        ],
      ),
    );
  }

  Widget _buildSlovenskoSkInfo(BuildContext context, Step2DataProvider step2, bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🇸🇰 Text pre Slovensko.sk',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
              fontSize: isMobile ? 15 : 16,
            ),
          ),
          const SizedBox(height: 12),
          _buildCopyField(
              context,
              'Značka odosielateľa (nepovinné):',
              '${step2.znacka}',
              isMobile
          ),
          const SizedBox(height: 16),
          _buildCopyField(
              context,
              'Predmet:',
              'Žiadosť o vyjadrenie k PD ${step2.znacka}',
              isMobile
          ),
          const SizedBox(height: 12),
          _buildCopyField(
            context,
            'Text správy:',
            'Dobrý deň\n\nžiadame Vás o vyjadrenie k stavbe ${step2.nazovStavby}\nv prílohe Vám posielam žiadosť a potrebné dokumenty.\n\nĎakujem.',
            isMobile,
            isMultiLine: true,
          ),
        ],
      ),
    );
  }

  Widget _buildCopyField(
      BuildContext context,
      String label,
      String text,
      bool isMobile,
      {bool isMultiLine = false}
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500
            )
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Skopírované do schránky'),
                          duration: Duration(seconds: 1)
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.copy_rounded, size: 16, color: Colors.blue),
                        SizedBox(width: 6),
                        Text(
                          'Kopírovať',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 16 : 24,
        isMobile ? 16 : 20,
        isMobile ? 8 : 12,
        isMobile ? 16 : 20,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white.withOpacity(0.05) : AppTheme.borderColor,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.checklist_rtl_rounded,
              color: AppTheme.primaryRed,
              size: isMobile ? 20 : 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Návod na odoslanie',
              style: TextStyle(
                fontSize: isMobile ? 18 : 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppTheme.textDark,
              ),
            ),
          ),
          if (!isMobile)
            ElevatedButton.icon(
              onPressed: () => _exportToPdf(context),
              icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
              label: const Text('Stiahnuť PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            )
          else
            IconButton(
              icon: Icon(
                Icons.picture_as_pdf_rounded,
                color: Colors.red.shade600,
              ),
              tooltip: 'Stiahnuť PDF',
              onPressed: () => _exportToPdf(context),
            ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              Icons.close_rounded,
              color: isDark ? Colors.white54 : AppTheme.textLight,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectInfoCard(BuildContext context, Step2DataProvider step2, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppTheme.primaryRed.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.business_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(step2.znacka, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          Text(step2.nazovStavby, style: TextStyle(fontSize: isMobile ? 18 : 22, fontWeight: FontWeight.bold, color: Colors.white, height: 1.3)),
          const SizedBox(height: 4),
          Text(step2.miestoStavby, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8))),
        ],
      ),
    );
  }

  Widget _buildIntroMessage(BuildContext context, bool isMobile) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(isDark ? 0.3 : 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: Colors.blue[400], size: 24),
          const SizedBox(width: 16),
          Expanded(child: Text('Dokumenty boli úspešne vygenerované. Nižšie nájdeš postup, ako ich správne odoslať na príslušné úrady.', style: TextStyle(fontSize: isMobile ? 14 : 15, color: isDark ? Colors.blue[100] : Colors.blue[900], height: 1.5))),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, {required String title, required IconData icon, required Color color, required bool isMobile}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(isDark ? 0.3 : 0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Text(title, style: TextStyle(fontSize: isMobile ? 15 : 16, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _buildZsrSection(BuildContext context, List<dynamic> applications, bool isMobile, bool p56Check, Step3DataProvider step3) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          title: 'Železnice Slovenskej republiky',
          icon: Icons.train_rounded,
          color: Colors.deepPurple,
          isMobile: isMobile,
        ),
        const SizedBox(height: 16),

        // Info o postupe
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.deepPurple.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.deepPurple.withOpacity(isDark ? 0.3 : 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: Colors.deepPurple[400], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Špecifický postup podania pre ŽSR',
                    style: TextStyle(
                      fontSize: isMobile ? 15 : 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.deepPurple[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Pre ŽSR je potrebné dodržať nasledujúci postup:',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 15,
                  color: isDark ? Colors.white70 : AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 12),
              _buildNumberedStep(
                context,
                '1.',
                'Ako prvé odoslať dokument - ZSR objednávka',
                'Dokument ZSR objednávka je medzi vygenerovanými súbormi v priecinku /zsr',
                isMobile,
              ),
              const SizedBox(height: 12),
              _buildNumberedStep(
                context,
                '2.',
                'Podanie ostatnych dokuemntov az po schavelni obejnavky',
                '',
                isMobile,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Zoznam ŽSR aplikácií
        _buildChecklistGroup(context, applications, isMobile, p56Check, step3),
      ],
    );
  }

  Widget _buildNumberedStep(
    BuildContext context,
    String stepNumber,
    String title,
    String description,
    bool isMobile,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.deepPurple,
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Text(
            stepNumber,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: isMobile ? 14 : 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: isMobile ? 13 : 14,
                  color: isDark ? Colors.white60 : AppTheme.textLight,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentRow(BuildContext context, String count, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(width: 32, child: Text(count, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryRed))),
          Text(label, style: TextStyle(color: isDark ? Colors.white70 : AppTheme.textDark)),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, bool isMobile) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        border: Border(top: BorderSide(color: isDark ? Colors.white.withOpacity(0.05) : AppTheme.borderColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: isMobile ? 12 : 16)),
            child: Text('Zavrieť', style: TextStyle(color: isDark ? Colors.white70 : AppTheme.textLight)),
          ),
          SizedBox(width: isMobile ? 8 : 16),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.done_all_rounded, size: 18),
            label: const Text('Hotovo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryRed, foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 32, vertical: isMobile ? 12 : 16),
              elevation: 4, shadowColor: AppTheme.primaryRed.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  int _countTechnicalSituation(List<dynamic> applications) => applications.where((app) => app.technicalSituation == true).length;
  int _countSituation(List<dynamic> applications) => applications.where((app) => app.situation == true).length;
  int _countSituationA3(List<dynamic> applications) => applications.where((app) => app.situationA3 == true).length;
  int _countBroaderRelations(List<dynamic> applications) => applications.where((app) => app.broaderRelations == true).length;

  Future<void> _exportToPdf(BuildContext context) async {
    final step2 = context.read<Step2DataProvider>();
    final step3 = context.read<Step3DataProvider>();
    final step5 = context.read<Step5DataProvider>();

    final bool p56Check = step3.selectedBuildingPurpose?.purposeName.contains('56') ?? false;

    final allApplications = step5.applications
        .where((app) => !step5.isHidden(app.applicationId))
        .toList();

    final zsrApplications = allApplications.where((app) => app.railways == true).toList();

    final nonZsrApplications = allApplications.where((app) => app.railways != true).toList();

    final printApplications = nonZsrApplications
        .where((app) => app.submission == 'P')
        .toList();

    final electronicApplications = nonZsrApplications
        .where((app) => app.submission == 'E')
        .toList();

    final onlineApplications = nonZsrApplications
        .where((app) => app.submission == 'online')
        .toList();

    final mailApplications = nonZsrApplications
        .where((app) => app.submission == 'M')
        .toList();

    final bool hasMOSR = nonZsrApplications.any((app) =>
    !step5.isHidden(app.applicationId) &&
        (app.name.toString().toLowerCase().contains('ministerstvo obrany') ||
            app.name.toString().toLowerCase().contains('mosr'))
    );

    final bool hasRUVZ = nonZsrApplications.any((app) =>
    !step5.isHidden(app.applicationId) &&
        (app.name.toString().toLowerCase().contains('rúvz') ||
            app.name.toString().toLowerCase().contains('regionálny úrad'))
    );

    int techSitCount = _countTechnicalSituation(printApplications) + (p56Check ? 1 : 0);
    int sitCount = _countSituation(printApplications);
    int sitA3Count = _countSituationA3(printApplications);
    int broadRelCount = _countBroaderRelations(printApplications);

    int rezKrizovaniaCount = 0;
    if (step3.cestyITyp != 'Bez prílohy' || step3.cestyIITyp != 'Bez prílohy') {
      rezKrizovaniaCount = printApplications.where((app) =>
      app.roads1 == true || app.roads2 == true
      ).length;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppTheme.primaryRed),
                const SizedBox(height: 16),
                const Text('Generujem PDF...'),
              ],
            ),
          ),
        ),
      );

      await PdfExportService.generateInstructionPdf(
        znacka: step2.znacka,
        nazovStavby: step2.nazovStavby,
        miestoStavby: step2.miestoStavby,
        printApplications: printApplications,
        electronicApplications: electronicApplications,
        onlineApplications: onlineApplications,
        mailApplications: mailApplications,
        zsrApplications: zsrApplications,
        p56Check: p56Check,
        hasMOSR: hasMOSR,
        hasRUVZ: hasRUVZ,
        hasORHAZZ: step3.orhazz,
        techSitCount: techSitCount,
        sitCount: sitCount,
        sitA3Count: sitA3Count,
        broadRelCount: broadRelCount,
        rezKrizovaniaCount: rezKrizovaniaCount,
      );

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white),
              const SizedBox(width: 12),
              const Text('PDF bolo úspešne vygenerované'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } catch (e) {
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Text('Chyba pri generovaní PDF: $e'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }
}
