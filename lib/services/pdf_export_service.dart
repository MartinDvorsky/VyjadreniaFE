// lib/services/pdf_export_service.dart

import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/application_model.dart';

class PdfExportService {
  /// Generuje PDF s návodom na odoslanie
  static Future<void> generateInstructionPdf({
    required String znacka,
    required String nazovStavby,
    required String miestoStavby,
    required List<Application> printApplications,
    required List<Application> electronicApplications,
    required List<Application> onlineApplications,
    required List<Application> mailApplications,
    required List<Application> zsrApplications,
    required bool p56Check,
    required bool hasMOSR,
    required bool hasRUVZ,
    required bool hasORHAZZ,
    required int techSitCount,
    required int sitCount,
    required int sitA3Count,
    required int broadRelCount,
    required int rezKrizovaniaCount,
  }) async {
    final pdf = pw.Document();

    // ✅ Načítaj Roboto font s plnou UTF-8 podporou
    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    // Vytvor PDF stránky s fontom
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        theme: pw.ThemeData.withFont(
          base: font,
          bold: fontBold,
        ),
        build: (context) => [
          // Hlavička
          _buildHeader(znacka, nazovStavby, miestoStavby),
          pw.SizedBox(height: 20),

          // Úvodná správa
          _buildIntroSection(),
          pw.SizedBox(height: 30),

          // ZSR žiadosti
          if (zsrApplications.isNotEmpty) ...[
            _buildZsrSection(zsrApplications),
            pw.SizedBox(height: 30),
          ],

          // Tlačené žiadosti
          if (printApplications.isNotEmpty || hasMOSR) ...[
            _buildSectionHeader('Tlacene ziadosti a obalky', PdfColors.orange),
            pw.SizedBox(height: 10),
            _buildApplicationsList(printApplications),
            pw.SizedBox(height: 15),
            _buildAttachmentsSection(
              techSitCount: techSitCount,
              sitCount: sitCount,
              sitA3Count: sitA3Count,
              broadRelCount: broadRelCount,
              rezKrizovaniaCount: rezKrizovaniaCount,
              hasMOSR: hasMOSR,
              hasRUVZ: hasRUVZ,
              p56Check: p56Check,
            ),
            pw.SizedBox(height: 30),
          ],

          // Elektronické žiadosti
          if (electronicApplications.isNotEmpty) ...[
            _buildSectionHeader('Elektronicke podania (Slovensko.sk)', PdfColors.blue),
            pw.SizedBox(height: 10),
            _buildApplicationsList(electronicApplications),
            pw.SizedBox(height: 15),
            _buildSlovenskoSkInfo(znacka, nazovStavby),
            pw.SizedBox(height: 30),
          ],

          // Online žiadosti
          if (onlineApplications.isNotEmpty) ...[
            _buildSectionHeader('Online portaly', PdfColors.purple),
            pw.SizedBox(height: 10),
            _buildApplicationsList(onlineApplications),
            pw.SizedBox(height: 30),
          ],

          // Mailové žiadosti
          if (mailApplications.isNotEmpty || hasORHAZZ) ...[
            _buildSectionHeader('E-mailove ziadosti', PdfColors.teal),
            pw.SizedBox(height: 10),
            if (hasORHAZZ) ...[
              _buildMailItem('Poslat ziadost o spracovanie projektu PBS na pbsengineering1@gmail.com'),
              pw.SizedBox(height: 5),
            ],
            if (mailApplications.isNotEmpty)
              _buildApplicationsList(mailApplications),
          ],
        ],
        footer: (context) => _buildFooter(context),
      ),
    );

    // Preview alebo stiahnutie
    await _showPdfPreview(pdf, znacka);
  }

  /// Hlavička PDF
  static pw.Widget _buildHeader(String znacka, String nazovStavby, String miestoStavby) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.red,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Container(
                width: 32,
                height: 32,
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFFFFCCCC),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Center(
                  child: pw.Text(
                    'P',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ),
              pw.SizedBox(width: 10),
              pw.Text(
                znacka,
                style: const pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            nazovStavby,
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            miestoStavby,
            style: const pw.TextStyle(
              fontSize: 12,
              color: PdfColors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Úvodná sekcia
  static pw.Widget _buildIntroSection() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.blue200),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 24,
            height: 24,
            decoration: pw.BoxDecoration(
              color: PdfColors.blue,
              shape: pw.BoxShape.circle,
            ),
            child: pw.Center(
              child: pw.Text(
                'i',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ),
          pw.SizedBox(width: 12),
          pw.Expanded(
            child: pw.Text(
              'Dokumenty boli uspesne vygenerovane. Nizsie najdes postup, ako ich spravne odoslat na prislusne urady.',
              style: const pw.TextStyle(
                fontSize: 11,
                color: PdfColors.blue900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Hlavička sekcie
  static pw.Widget _buildSectionHeader(String title, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(_lightenColor(color)),
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: color),
      ),
      child: pw.Row(
        children: [
          pw.Container(
            width: 28,
            height: 28,
            padding: const pw.EdgeInsets.all(6),
            decoration: pw.BoxDecoration(
              color: color,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Center(
              child: pw.Text(
                '✓',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Helper na zosvetlenie farby
  static int _lightenColor(PdfColor color) {
    // Konverzia na RGB a zosvetlenie
    final r = ((color.red * 255 * 0.2) + (255 * 0.8)).toInt();
    final g = ((color.green * 255 * 0.2) + (255 * 0.8)).toInt();
    final b = ((color.blue * 255 * 0.2) + (255 * 0.8)).toInt();
    return 0xFF000000 | (r << 16) | (g << 8) | b;
  }

  /// Zoznam aplikácií
  static pw.Widget _buildApplicationsList(List<Application> applications) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: applications.asMap().entries.map((entry) {
          final index = entry.key;
          final app = entry.value;
          final isLast = index == applications.length - 1;

          return pw.Column(
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Checkbox placeholder
                    pw.Container(
                      width: 16,
                      height: 16,
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey400, width: 2),
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                    ),
                    pw.SizedBox(width: 12),
                    // Text
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            _formatAppName(app),
                            style: pw.TextStyle(
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          if (app.envelope != null && app.envelope!.isNotEmpty) ...[
                            pw.SizedBox(height: 4),
                            pw.Text(
                              'Obalka: ${app.envelope}',
                              style: const pw.TextStyle(
                                fontSize: 9,
                                color: PdfColors.grey700,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                pw.Divider(color: PdfColors.grey300, height: 0),
            ],
          );
        }).toList(),
      ),
    );
  }

  /// Formátovanie názvu aplikácie
  static String _formatAppName(Application app) {
    String base = app.department.isNotEmpty
        ? '${app.name} - ${app.department}'
        : app.name;

    if (base.toLowerCase().contains('ruvz') ||
        base.toLowerCase().contains('regionalny urad')) {
      return '$base - kolok 50 EUR';
    }
    return base;
  }

  /// Sekcia s prílohami
  static pw.Widget _buildAttachmentsSection({
    required int techSitCount,
    required int sitCount,
    required int sitA3Count,
    required int broadRelCount,
    required int rezKrizovaniaCount,
    required bool hasMOSR,
    required bool hasRUVZ,
    required bool p56Check,
  }) {
    if (techSitCount == 0 && sitCount == 0 && sitA3Count == 0 &&
        broadRelCount == 0 && rezKrizovaniaCount == 0 && !hasMOSR && !hasRUVZ) {
      return pw.SizedBox.shrink();
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Container(
                width: 20,
                height: 20,
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey700,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Center(
                  child: pw.Text(
                    'D',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Text(
                'Potrebne prilohy k tlacenym ziadostiam:',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey800,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          if (techSitCount > 0)
            _buildAttachmentRow('${techSitCount}x', 'Technicka sprava${p56Check ? ' (+1 extra)' : ''}'),
          if (sitCount > 0)
            _buildAttachmentRow('${sitCount}x', 'Situacia v mierke'),
          if (sitA3Count > 0)
            _buildAttachmentRow('${sitA3Count}x', 'Situacia A3'),
          if (broadRelCount > 0)
            _buildAttachmentRow('${broadRelCount}x', 'Situacia sirsich vztahov'),
          if (rezKrizovaniaCount > 0)
            _buildAttachmentRow('${rezKrizovaniaCount}x', 'Rez krizovania'),
          if (hasMOSR || hasRUVZ) ...[
            pw.SizedBox(height: 5),
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 5),
            if (hasMOSR)
              _buildAttachmentRow('1x', 'Plna moc (pre MOSR)'),
            if (hasRUVZ) ...[
              _buildAttachmentRow('1x', 'Plna moc (pre RUVZ)'),
              _buildAttachmentRow('1x', 'Obchodny register (pre RUVZ)'),
            ],
          ],
        ],
      ),
    );
  }

  /// Riadok prílohy
  static pw.Widget _buildAttachmentRow(String count, String label) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        children: [
          pw.Container(
            width: 12,
            height: 12,
            decoration: pw.BoxDecoration(
              color: PdfColors.red,
              shape: pw.BoxShape.circle,
            ),
          ),
          pw.SizedBox(width: 8),
          pw.SizedBox(
            width: 40,
            child: pw.Text(
              count,
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.red,
                fontSize: 10,
              ),
            ),
          ),
          pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }

  /// Info pre Slovensko.sk
  static pw.Widget _buildSlovenskoSkInfo(String znacka, String nazovStavby) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.blue200),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Text pre Slovensko.sk',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
              fontSize: 12,
            ),
          ),
          pw.SizedBox(height: 12),
          _buildCopyField('Znacka odosielatela (nepovinne):', znacka),
          pw.SizedBox(height: 10),
          _buildCopyField('Predmet:', 'Ziadost o vyjadrenie k PD $znacka'),
          pw.SizedBox(height: 10),
          _buildCopyField(
            'Text spravy:',
            'Dobry den\n\nziadame Vas o vyjadrenie k stavbe $nazovStavby\nv prilohe Vam posielam ziadost a potrebne dokumenty.\n\nDakujem.',
          ),
        ],
      ),
    );
  }

  /// Pole na kopírovanie
  static pw.Widget _buildCopyField(String label, String text) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey700,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            color: PdfColors.white,
            border: pw.Border.all(color: PdfColors.grey400),
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Text(
            text,
            style: const pw.TextStyle(
              fontSize: 9,
              color: PdfColors.black,
            ),
          ),
        ),
      ],
    );
  }

  /// ZSR sekcia so špecifickým postupom
  static pw.Widget _buildZsrSection(List<Application> applications) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('ZSR (Zeleznice Slovenskej republiky)', PdfColors.deepPurple),
        pw.SizedBox(height: 10),

        // Info o postupe
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromInt(0xFFF4EEFF),
            borderRadius: pw.BorderRadius.circular(8),
            border: pw.Border.all(color: PdfColors.deepPurple200),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                children: [
                  pw.Container(
                    width: 20,
                    height: 20,
                    decoration: pw.BoxDecoration(
                      color: PdfColors.deepPurple,
                      shape: pw.BoxShape.circle,
                    ),
                    child: pw.Center(
                      child: pw.Text(
                        'i',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Text(
                    'Špecifický postup podania pre ZSR',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.deepPurple900,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Pre ZSR je potrebné dodržať nasledujúci postup:',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey800,
                ),
              ),
              pw.SizedBox(height: 8),
              _buildNumberedStep(
                '1.',
                'Najprv odoslať dokument "ZSR objednávka"',
                'Dokument ZSR objednávka je medzi vygenerovanými súbormi, ale nie je v zozname aplikácií. Je potrebné ho odoslať ako prvý krok.',
              ),
              pw.SizedBox(height: 6),
              _buildNumberedStep(
                '2.',
                'Po schválení objednávky',
                'Až po schválení ZSR objednávky je možné podať vyjadrenia podľa konkrétnych úradov danej ZSR.',
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 10),

        // Zoznam ZSR aplikácií
        _buildApplicationsList(applications),
      ],
    );
  }

  /// Číslovaný krok pre ZSR postup
  static pw.Widget _buildNumberedStep(String stepNumber, String title, String description) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 22,
          height: 22,
          decoration: pw.BoxDecoration(
            color: PdfColors.deepPurple,
            shape: pw.BoxShape.circle,
          ),
          alignment: pw.Alignment.center,
          child: pw.Text(
            stepNumber,
            style: pw.TextStyle(
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 3),
              pw.Text(
                description,
                style: pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey700,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Mail item
  static pw.Widget _buildMailItem(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        children: [
          pw.Container(
            width: 16,
            height: 16,
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400, width: 2),
              borderRadius: pw.BorderRadius.circular(4),
            ),
          ),
          pw.SizedBox(width: 12),
          pw.Expanded(
            child: pw.Text(
              text,
              style: const pw.TextStyle(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  /// Footer
  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 10),
      child: pw.Text(
        'Strana ${context.pageNumber} z ${context.pagesCount} | Vygenerovane: ${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}',
        style: pw.TextStyle(
          fontSize: 8,
          color: PdfColors.grey600,
          fontStyle: pw.FontStyle.italic,
        ),
      ),
    );
  }

  /// Priamo stiahni PDF s výberom umiestnenia
  static Future<void> _showPdfPreview(pw.Document pdf, String znacka) async {
    try {
      final bytes = await pdf.save();

      // ✅ Sanitizuj názov súboru - odstráň nepovolené znaky pre Windows
      final sanitizedZnacka = znacka
          .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')  // Nahrad nepovolené znaky
          .replaceAll(RegExp(r'\s+'), '_');  // Nahrad medzery

      if (!kIsWeb) {
        final outputPath = await FilePicker.platform.saveFile(
          dialogTitle: 'Ulozit PDF navod',
          fileName: 'Navod_na_odoslanie_$sanitizedZnacka.pdf',
          type: FileType.custom,
          allowedExtensions: ['pdf'],
        );

        if (outputPath == null) {
          print('Pouzivatel zrusil ulozenie PDF');
          return;
        }

        // Ulož súbor
        final file = File(outputPath);
        await file.writeAsBytes(bytes);
        print('PDF ulozene: $outputPath');
      } else {
        // Pre web použijeme share
        await Printing.sharePdf(
          bytes: bytes,
          filename: 'Navod_na_odoslanie_$sanitizedZnacka.pdf',
        );
      }
    } catch (e) {
      print('Error saving PDF: $e');
      rethrow;
    }
  }

  /// Alternatíva: Priamo stiahnuť PDF bez preview
  static Future<String?> savePdfToFile(pw.Document pdf, String znacka) async {
    try {
      final bytes = await pdf.save();
      final dir = await getApplicationDocumentsDirectory();
      final sanitizedZnacka = znacka.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
      final file = File('${dir.path}/Navod_na_odoslanie_$sanitizedZnacka.pdf');
      await file.writeAsBytes(bytes);
      return file.path;
    } catch (e) {
      print('Error saving PDF: $e');
      return null;
    }
  }
}