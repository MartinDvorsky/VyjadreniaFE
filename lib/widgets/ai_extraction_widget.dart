// lib/widgets/ai_extraction_widget.dart

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:provider/provider.dart';
import 'package:vyjadrenia/providers/city_provider.dart';
import 'package:vyjadrenia/services/project_designer_service.dart';
import 'dart:io';
import 'package:desktop_drop/desktop_drop.dart';
import '../models/city_model.dart';
import '../services/ai_extraction_service.dart';
import '../providers/step2_data_provider.dart';
import '../models/builder_model.dart';
import '../models/project_designer_model.dart';
import '../utils/app_theme.dart';
import '../widgets/builder_dialog.dart'; // ✅ Import dialógu

class AIExtractionWidget extends StatefulWidget {
  const AIExtractionWidget({Key? key}) : super(key: key);

  @override
  State<AIExtractionWidget> createState() => _AIExtractionWidgetState();
}

class _AIExtractionWidgetState extends State<AIExtractionWidget> {
  final AIExtractionService _aiService = AIExtractionService();
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  File? _selectedFile;
  bool _isDragging = false;

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'txt'],
        withData: false,
        withReadStream: true,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        setState(() {
          _selectedFile = file;
          _errorMessage = null;
        });
        await _processFile(file);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Chyba pri výbere súboru: $e';
      });
    }
  }

  Future<void> _handleDroppedFiles(List<dynamic> files) async {
    if (files.isEmpty) return;

    try {
      final xFile = files.first;
      final path = xFile.path;

      final extension = path.split('.').last.toLowerCase();
      if (!['pdf', 'docx', 'txt'].contains(extension)) {
        setState(() {
          _errorMessage = 'Nepodporovaný formát. Použite PDF, DOCX alebo TXT.';
        });
        return;
      }

      final file = File(path);
      setState(() {
        _selectedFile = file;
        _errorMessage = null;
        _isDragging = false;
      });

      await _processFile(file);
    } catch (e) {
      setState(() {
        _errorMessage = 'Chyba pri spracovaní súboru: $e';
        _isDragging = false;
      });
    }
  }

  Future<void> _processFile(File file) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final response = await _aiService.extractFromFile(file);

      if (response.success && response.data != null) {
        await _fillProviderData(response.data!);
        if (response.fieldWarnings.isNotEmpty) {
          context.read<Step2DataProvider>().setFieldWarnings(response.fieldWarnings);
        }

        setState(() {
          _isLoading = false;
          _successMessage = 'Dáta boli úspešne extrahované a naplnené!';

          if (response.metrics != null) {
            print('⏱️ Čas spracovania: ${response.metrics!.processingTimeSeconds.toStringAsFixed(2)}s');
            print('📢 Použité tokeny: ${response.metrics!.tokensUsed}');
            print('💰 Cena: \$${response.metrics!.estimatedCostUsd?.toStringAsFixed(4)}');
          }
        });

        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            setState(() {
              _successMessage = null;
            });
          }
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = response.error ?? 'Neznáma chyba pri extrakcii';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Chyba pri spracovaní: $e';
      });
    }
  }

  Future<void> _fillProviderData(dynamic extractedData) async {
    final provider = context.read<Step2DataProvider>();
    final cityProvider = context.read<CityProvider>();

    if (extractedData.nazovStavby != null) {
      provider.setNazovStavby(extractedData.nazovStavby);
    }
    if (extractedData.miestoStavby != null) {
      provider.setMiestoStavby(extractedData.miestoStavby);
    }
    City? firstCity = cityProvider.cities.firstOrNull;
    if (extractedData.katastralneUzemie != null && firstCity?.name != extractedData.katastralneUzemie) {
      provider.setKatastralneUzemie(extractedData.katastralneUzemie);
    }
    if (extractedData.cisloZakazky != null) {
      provider.setZnacka(extractedData.cisloZakazky);
    }

    // ✅ HLAVNÁ ZMENA - detekcia vlastného stavebníka
    bool isCustomBuilder = !extractedData.investor.isVsd;

    if (isCustomBuilder) {
      // Vytvor objekt stavebníka z extrahovaných dát
      final customBuilder = BuilderModel(
        name: extractedData.investor.name ?? '',
        obec: extractedData.investor.obec ?? '',
        ulica: extractedData.investor.ulica ?? '',
        cisloDomu: extractedData.investor.cisloDomu ?? '',
        psc: extractedData.investor.psc ?? '',
        ico: extractedData.investor.ico ?? '',
        email: extractedData.investor.email ?? '',
        telefon: extractedData.investor.telefon ?? '',
        typ: extractedData.investor.typ ?? 'Právnická osoba',
        menoLegalEntity: extractedData.investor.menoLegalEntity,
        emailLegalEntity: extractedData.investor.emailLegalEntity,
        typOpravnenia: extractedData.investor.typOpravnenia,
      );

      // ✅ KRITICKÁ ZMENA - nastav len raz, PRED zobrazením dialógu
      provider.setBuilder(customBuilder);
      provider.setIsCustomBuilder(true);

      // ✅ Po 2-3 sekundách otvor dialóg pre kontrolu
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _showBuilderVerificationDialog(customBuilder);
        }
      });

      // ✅ RETURN TU - nezavolaj druhýkrát setBuilder
      // (dialóg si sám updatne providera ak používateľ niečo zmení)
    } else {
      provider.setIsCustomBuilder(false);
    }


    if (extractedData.zodpovednyProjektant.certificateNumber != null) {
      await _selectProjectDesigner(
        extractedData.zodpovednyProjektant.certificateNumber!,
        extractedData.zodpovednyProjektant.fullName,
      );
    }

    for (var obj in extractedData.objects) {
      provider.addObjektStavby(
        BuildingObject(
          id: obj.code ?? 'SO',
          name: obj.name,
        ),
      );
    }

    for (var ps in extractedData.prevadzkoveSubory) {
      provider.addPrevadzkovySubor(
        OperationalSet(
          id: ps.code ?? 'PS',
          name: ps.name,
        ),
      );
    }

    if (extractedData.datum != null) {
      try {
        final parts = extractedData.datum!.split('/');
        if (parts.length == 2) {
          final month = int.parse(parts[0]);
          final year = int.parse(parts[1]);
          provider.setDatumDokumentacie(DateTime(year, month));
        }
      } catch (e) {
        print('⚠️ Chyba pri parsovaní dátumu: $e');
      }
    }
  }

  // ✅ NOVÁ METÓDA - zobrazenie dialógu s informačnou správou
  Future<void> _showBuilderVerificationDialog(BuilderModel builder) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ✅ Zobraz len informačný dialóg, ktorý vráti bool (či chce užívateľ upravovať)
    final shouldEdit = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: Colors.orange,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Stavebník iný ako VSD',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detegovaný bol vlastný stavebník:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[300]!,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    builder.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (builder.ulica.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      builder.fullAddress,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white60 : Colors.grey[700],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Colors.blue[700],
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Prosím skontrolujte údaje a doplňte potrebné informácie pre žiadosť podľa § 21 alebo § 22 Stavebného zákona.',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.blue[100] : Colors.blue[900],
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Neskôr'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(dialogContext).pop(true), // ✅ Len vráť true
            icon: const Icon(Icons.edit_rounded, size: 18),
            label: const Text('Skontrolovať a upraviť'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );

    // ✅ AŽ TU otvoríme edit dialóg (MIMO nested callbacku)
    if (shouldEdit == true && mounted) {
      print('🔓 Opening edit dialog...');

      final updatedBuilder = await showDialog<BuilderModel>(
        context: context,
        builder: (context) => BuilderDialog(
          initialBuilder: builder,
          fieldWarnings: Provider.of<Step2DataProvider>(context, listen: false).fieldWarnings,
        ),
      );

      print('📥 Received builder from dialog: ${updatedBuilder?.toJson()}');

      if (updatedBuilder != null && mounted) {
        print('✅ About to update provider');

        final provider = Provider.of<Step2DataProvider>(context, listen: false);
        print('🔧 Provider BEFORE: ${provider.builder.ico}');

        provider.setBuilder(updatedBuilder);

        print('🔧 Provider AFTER: ${provider.builder.ico}');
      }
    }
  }

  Future<void> _selectProjectDesigner(String licenseNumber, String fullName) async {
    try {
      final projectDesignerService = ProjectDesignerService();
      final designer = await projectDesignerService.searchByLicense(licenseNumber);

      if (designer != null) {
        final provider = context.read<Step2DataProvider>();
        provider.setSelectedProjektant(designer);
        print('✅ Projektant automaticky vybratý: ${designer.name}');
      } else {
        print('⚠️ Projektant s číslom $licenseNumber nebol nájdený v databáze');
      }
    } catch (e) {
      print('❌ Chyba pri výbere projektanta: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.darkCard : Colors.white;
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor;
    final textColor = isDark ? Colors.white : AppTheme.textDark;
    final subTextColor = isDark ? Colors.white70 : AppTheme.textLight;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppTheme.primaryRed,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Extrakcia z dokumentu',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Nahrajte obalku stavby (.pdf, .docx, .txt)',
                      style: TextStyle(
                        fontSize: 12,
                        color: subTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Drag & Drop Area
          DropTarget(
            onDragEntered: (_) {
              setState(() {
                _isDragging = true;
              });
            },
            onDragExited: (_) {
              setState(() {
                _isDragging = false;
              });
            },
            onDragDone: (details) async {
              await _handleDroppedFiles(details.files);
            },
            child: InkWell(
              onTap: _isLoading ? null : _pickFile,
              borderRadius: BorderRadius.circular(12),
              child: DottedBorder(
                color: _isDragging
                    ? Colors.green
                    : (_isLoading
                    ? (isDark ? Colors.white24 : Colors.grey)
                    : AppTheme.primaryRed),
                strokeWidth: _isDragging ? 3 : 2,
                dashPattern: const [8, 4],
                radius: const Radius.circular(12),
                borderType: BorderType.RRect,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: _isDragging
                        ? (isDark ? Colors.green.withOpacity(0.1) : Colors.green[50])
                        : (_isLoading
                        ? (isDark ? Colors.white10 : Colors.grey[50])
                        : AppTheme.primaryRed.withOpacity(0.05)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      if (_isLoading)
                        const AILoadingAnimation()
                      else
                        Column(
                          children: [
                            Icon(
                              _isDragging ? Icons.cloud_done_rounded : Icons.cloud_upload_rounded,
                              size: 48,
                              color: _isDragging
                                  ? Colors.green
                                  : AppTheme.primaryRed.withOpacity(0.6),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _isDragging
                                  ? 'Pusťte súbor sem'
                                  : 'Kliknite pre výber súboru',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _isDragging ? Colors.green : textColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _isDragging
                                  ? ''
                                  : 'alebo pretiahnite súbor sem',
                              style: TextStyle(
                                fontSize: 14,
                                color: subTextColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.black26 : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isDark ? Colors.white24 : AppTheme.borderColor,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'PDF, DOCX, TXT',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: subTextColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Success message
          if (_successMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1B3320) : Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: isDark ? Colors.green[900]! : Colors.green[200]!,
                    width: 1
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.green[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _successMessage!,
                      style: TextStyle(
                        color: isDark ? Colors.green[100] : Colors.green[900],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Error message
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2C1515) : Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: isDark ? Colors.red[900]! : Colors.red[200]!,
                    width: 1
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_rounded, color: Colors.red[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: isDark ? Colors.red[100] : Colors.red[900],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 20, color: isDark ? Colors.red[200] : Colors.red[900]),
                    onPressed: () {
                      setState(() {
                        _errorMessage = null;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}


class AILoadingAnimation extends StatefulWidget {
  const AILoadingAnimation({Key? key}) : super(key: key);

  @override
  State<AILoadingAnimation> createState() => _AILoadingAnimationState();
}

class _AILoadingAnimationState extends State<AILoadingAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scanAnimation;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    // Animácia trvá 2 sekundy a neustále sa opakuje (hore a dole)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Hodnoty pre skener (ShaderMask) od zhora nadol
    _scanAnimation = Tween<double>(begin: -0.2, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Hodnoty pre vznášanie dokumentu
    _floatAnimation = Tween<double>(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Ak používaš AppTheme.primaryRed, môžeš ho sem dosadiť. Zatiaľ dávam Colors.red
    final Color scanColor = Colors.red;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _floatAnimation.value),
                    child: Container(
                      width: 70,
                      height: 90,
                      decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: scanColor.withOpacity(isDark ? 0.2 : 0.15),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                          border: Border.all(
                            color: isDark ? Colors.white12 : Colors.grey[200]!,
                          )
                      ),
                      child: Stack(
                        children: [
                          // Naznačené riadky textu v dokumente
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLine(isDark, 35),
                                const SizedBox(height: 8),
                                _buildLine(isDark, 45),
                                const SizedBox(height: 8),
                                _buildLine(isDark, 25),
                                const SizedBox(height: 12),
                                _buildLine(isDark, 40),
                                const SizedBox(height: 8),
                                _buildLine(isDark, 30),
                              ],
                            ),
                          ),
                          // Skenovací efekt
                          Positioned.fill(
                            child: ShaderMask(
                              shaderCallback: (rect) {
                                return LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    scanColor.withOpacity(0.5),
                                    Colors.transparent,
                                  ],
                                  stops: [
                                    _scanAnimation.value - 0.2,
                                    _scanAnimation.value,
                                    _scanAnimation.value + 0.2,
                                  ],
                                ).createShader(rect);
                              },
                              blendMode: BlendMode.srcATop,
                              child: Container(color: Colors.white.withOpacity(0.1)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
            ),
            const SizedBox(height: 24),
            Text(
              "Spracovávam dokument",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Umelá inteligencia extrahuje potrebné údaje...",
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLine(bool isDark, double width) {
    return Container(
      width: width,
      height: 4,
      decoration: BoxDecoration(
        color: isDark ? Colors.white24 : Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}