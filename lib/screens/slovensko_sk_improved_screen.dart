import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vyjadrenia/providers/city_provider.dart';
import 'package:vyjadrenia/providers/step2_data_provider.dart';
import 'package:vyjadrenia/providers/step3_data_provider.dart';
import 'package:vyjadrenia/services/xml_generator_service.dart';
import 'package:vyjadrenia/widgets/simulation_warning_dialog.dart';
import '../providers/step5_data_provider.dart';
import '../models/application_model.dart';
import '../services/slovensko_sk_service.dart';
import '../utils/app_theme.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class SlovenskoSkImprovedScreen extends StatefulWidget {
  const SlovenskoSkImprovedScreen({Key? key}) : super(key: key);

  @override
  State<SlovenskoSkImprovedScreen> createState() => _SlovenskoSkImprovedScreenState();
}

class _SlovenskoSkImprovedScreenState extends State<SlovenskoSkImprovedScreen> {
  // KROKY
  int _currentStep = 0;
  final List<String> _stepTitles = [
    'Overenie spojenia',
    'Výber žiadostí',
    'Nahratie príloh',
    'Odosielanie',
    'Výsledky',
  ];

  // STAV
  bool _isLoading = false;
  String? _errorMessage;

  // KROK 1: Health check
  bool? _healthCheckPassed;

  // KROK 2: Vybrané aplikácie
  List<Application> _selectedApplications = [];
  List<Application> _availableApplications = [];

  // KROK 3: Prílohy (mapa: typ → súbor)
  final Map<String, File> _uploadedAttachments = {};
  Set<String> _requiredAttachmentTypes = {};

  // KROK 4: Progress odosielania
  final Map<int, SubmissionResult> _submissionResults = {};
  int _currentSubmissionIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadElectronicApplications();
    // Automaticky spusti health check
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await SimulationWarningDialog.show(context);
      _performHealthCheck();
    });
  }

  void _loadElectronicApplications() {
    final step5 = context.read<Step5DataProvider>();
    _availableApplications = step5.applications
        .where((app) => app.submission == 'E' && !step5.isHidden(app.applicationId))
        .toList();
  }

  // ==================== KROK 1: HEALTH CHECK ====================

  Future<void> _performHealthCheck() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _healthCheckPassed = null;
    });

    try {
      final service = SlovenskoSkService();
      // Zavolaj health endpoint
      final result = await service.verifyIdentity();

      setState(() {
        _healthCheckPassed = true;
        _isLoading = false;
      });

      // Auto-presun na ďalší krok po 1.5s
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        setState(() => _currentStep = 1);
      }
    } catch (e) {
      setState(() {
        _healthCheckPassed = false;
        _errorMessage = 'Nepodarilo sa pripojiť k slovensko.sk API.\n\nDetail: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  // ==================== KROK 2: VÝBER ŽIADOSTÍ ====================

  void _toggleApplicationSelection(Application app) {
    setState(() {
      if (_selectedApplications.contains(app)) {
        _selectedApplications.remove(app);
      } else {
        _selectedApplications.add(app);
      }

      // Prepočítaj požadované prílohy
      _updateRequiredAttachments();
    });
  }

  void _selectAllApplications() {
    setState(() {
      _selectedApplications = List.from(_availableApplications);
      _updateRequiredAttachments();
    });
  }

  void _deselectAllApplications() {
    setState(() {
      _selectedApplications.clear();
      _updateRequiredAttachments();
    });
  }

  void _updateRequiredAttachments() {
    final types = <String>{};

    for (var app in _selectedApplications) {
      // Kontroluj všetky možné prílohy
      if (app.technicalSituation) types.add('technical_situation');
      if (app.situation) types.add('situation');
      if (app.situationA3) types.add('situation_a3');
      if (app.broaderRelations) types.add('broader_relations');
      if (app.fireProtection) types.add('fire_protection');
      if (app.waterManagement) types.add('water_management');
      if (app.publicHealth) types.add('public_health');
      if (app.railways) types.add('railways');
      if (app.roads1) types.add('roads_1');
      if (app.roads2) types.add('roads_2');
      if (app.municipality) types.add('municipality');
    }

    print('📎 Celkovo potrebných príloh: ${types.length}');
    print('   Typy: $types');

    setState(() {
      _requiredAttachmentTypes = types;
    });
  }

  // ==================== KROK 3: NAHRATIE PRÍLOH ====================

  Future<void> _pickAttachment(String type) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _uploadedAttachments[type] = File(result.files.single.path!);
        });
      }
    } catch (e) {
      _showErrorSnackbar('Chyba pri výbere súboru: $e');
    }
  }

  void _removeAttachment(String type) {
    setState(() {
      _uploadedAttachments.remove(type);
    });
  }

  bool get _allRequiredAttachmentsUploaded {
    for (var type in _requiredAttachmentTypes) {
      if (!_uploadedAttachments.containsKey(type)) {
        return false;
      }
    }
    return true;
  }

  // ==================== KROK 4: ODOSIELANIE ====================

  Future<void> _startSubmission() async {
    setState(() {
      _currentStep = 3;
      _currentSubmissionIndex = 0;
      _submissionResults.clear();
    });

    final service = SlovenskoSkService();

    for (int i = 0; i < _selectedApplications.length; i++) {
      setState(() => _currentSubmissionIndex = i);

      final app = _selectedApplications[i];


      try {
        // ✅ Priprav prílohy len pre tento úrad - KOMPLETNÝ MAPPING
        final attachmentsForThisApp = <String, File>{};

        // Všetky možné typy príloh
        if (app.technicalSituation && _uploadedAttachments.containsKey('technical_situation')) {
          attachmentsForThisApp['technical_situation'] = _uploadedAttachments['technical_situation']!;
        }
        if (app.situation && _uploadedAttachments.containsKey('situation')) {
          attachmentsForThisApp['situation'] = _uploadedAttachments['situation']!;
        }
        if (app.situationA3 && _uploadedAttachments.containsKey('situation_a3')) {
          attachmentsForThisApp['situation_a3'] = _uploadedAttachments['situation_a3']!;
        }
        if (app.broaderRelations && _uploadedAttachments.containsKey('broader_relations')) {
          attachmentsForThisApp['broader_relations'] = _uploadedAttachments['broader_relations']!;
        }
        // ✅ PRIDAJ ZVYŠNÉ TYPY
        if (app.fireProtection && _uploadedAttachments.containsKey('fire_protection')) {
          attachmentsForThisApp['fire_protection'] = _uploadedAttachments['fire_protection']!;
        }
        if (app.waterManagement && _uploadedAttachments.containsKey('water_management')) {
          attachmentsForThisApp['water_management'] = _uploadedAttachments['water_management']!;
        }
        if (app.publicHealth && _uploadedAttachments.containsKey('public_health')) {
          attachmentsForThisApp['public_health'] = _uploadedAttachments['public_health']!;
        }
        if (app.railways && _uploadedAttachments.containsKey('railways')) {
          attachmentsForThisApp['railways'] = _uploadedAttachments['railways']!;
        }
        if (app.roads1 && _uploadedAttachments.containsKey('roads_1')) {
          attachmentsForThisApp['roads_1'] = _uploadedAttachments['roads_1']!;
        }
        if (app.roads2 && _uploadedAttachments.containsKey('roads_2')) {
          attachmentsForThisApp['roads_2'] = _uploadedAttachments['roads_2']!;
        }
        if (app.municipality && _uploadedAttachments.containsKey('municipality')) {
          attachmentsForThisApp['municipality'] = _uploadedAttachments['municipality']!;
        }

        print('📎 Odosielam ${attachmentsForThisApp.length} príloh pre: ${app.name}');
        print('   Typy: ${attachmentsForThisApp.keys.toList()}');

        setState(() {
          _submissionResults[app.id] = SubmissionResult(
            status: SubmissionStatus.sending,
            appName: app.name,
          );
        });

        // Odošli
        final xmlContent = XmlGeneratorService.generateGeneralAgendaXml(
          application: app,
          city: context.read<CityProvider>().selectedCities.firstWhere(
            (c) => c.name == app.city,
            orElse: () => context.read<CityProvider>().selectedCities.first,
          ),
          step2: context.read<Step2DataProvider>(),
          step3: context.read<Step3DataProvider>(),
        );

        final result = await service.submitStatement(
          applicationId: app.applicationId,
          statementXml: xmlContent,
          attachments: attachmentsForThisApp,
        );

        setState(() {
          _submissionResults[app.id] = SubmissionResult(
            status: result['success'] ? SubmissionStatus.success : SubmissionStatus.error,
            appName: app.name,
            messageId: result['message_id'],
            errorMessage: result['success'] ? null : result['message'],
          );
        });

        // Pauza medzi odosielaniami
        await Future.delayed(const Duration(milliseconds: 500));

      } catch (e) {
        setState(() {
          _submissionResults[app.id] = SubmissionResult(
            status: SubmissionStatus.error,
            appName: app.name,
            errorMessage: e.toString(),
          );
        });
      }
    }

    // Prejdi na výsledky
    setState(() => _currentStep = 4);
  }

  // ==================== KROK 5: VÝSLEDKY ====================

  void _retryFailedSubmissions() {
    final failedApps = _selectedApplications.where((app) {
      final result = _submissionResults[app.id];
      return result?.status == SubmissionStatus.error;
    }).toList();

    if (failedApps.isEmpty) return;

    setState(() {
      _selectedApplications = failedApps;
      _currentStep = 3;
    });

    _startSubmission();
  }

  // ==================== UI ====================

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('slovensko.sk - Elektronické podanie'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _currentStep == 3 ? null : () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Progress stepper
          _buildStepIndicator(isDark),

          // Obsah podľa kroku
          Expanded(
            child: _buildStepContent(isDark),
          ),

          // Navigačné tlačidlá (okrem krokov 0 a 3)
          if (_currentStep != 0 && _currentStep != 3)
            _buildNavigationButtons(isDark),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(_stepTitles.length, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? Colors.green
                              : isActive
                              ? AppTheme.primaryRed
                              : (isDark ? Colors.white12 : Colors.grey[300]),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: isCompleted
                              ? const Icon(Icons.check, color: Colors.white, size: 20)
                              : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isActive ? Colors.white : (isDark ? Colors.white38 : Colors.grey[600]),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _stepTitles[index],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          color: isActive
                              ? (isDark ? Colors.white : Colors.black)
                              : (isDark ? Colors.white60 : Colors.grey[600]),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (index < _stepTitles.length - 1)
                  Container(
                    height: 2,
                    width: 20,
                    color: isCompleted ? Colors.green : (isDark ? Colors.white12 : Colors.grey[300]),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent(bool isDark) {
    switch (_currentStep) {
      case 0:
        return _buildHealthCheckStep(isDark);
      case 1:
        return _buildApplicationSelectionStep(isDark);
      case 2:
        return _buildAttachmentUploadStep(isDark);
      case 3:
        return _buildSubmissionProgressStep(isDark);
      case 4:
        return _buildResultsStep(isDark);
      default:
        return const SizedBox();
    }
  }

  // KROK 0: Health Check
  Widget _buildHealthCheckStep(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading) ...[
              const SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(strokeWidth: 6),
              ),
              const SizedBox(height: 32),
              const Text(
                'Overujem spojenie so slovensko.sk API...',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ] else if (_healthCheckPassed == true) ...[
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, size: 80, color: Colors.green),
              ),
              const SizedBox(height: 32),
              const Text(
                'Spojenie a overenie identity úspešné',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
              ),
              const SizedBox(height: 16),
              const Text(
                'Pripojenie na slovensko.sk API funguje správne.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ] else if (_healthCheckPassed == false) ...[
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.error_outline, size: 80, color: Colors.red),
              ),
              const SizedBox(height: 32),
              const Text(
                '❌ Chyba spojenia',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Text(
                  _errorMessage ?? 'Neznáma chyba',
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _performHealthCheck,
                icon: const Icon(Icons.refresh),
                label: const Text('Skúsiť znova'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // KROK 1: Výber žiadostí
  Widget _buildApplicationSelectionStep(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Vyber žiadosti na odoslanie',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              Wrap(
                spacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: _selectAllApplications,
                    icon: const Icon(Icons.select_all, size: 18),
                    label: const Text('Vybrať všetky'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _deselectAllApplications,
                    icon: const Icon(Icons.deselect, size: 18),
                    label: const Text('Zrušiť výber'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Vybrané: ${_selectedApplications.length} / ${_availableApplications.length}',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),

          if (_availableApplications.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 80,
                      color: isDark ? Colors.white24 : Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Žiadne žiadosti s elektronickým podaním',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white60 : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _availableApplications.length,
              itemBuilder: (context, index) {
                final app = _availableApplications[index];
                final isSelected = _selectedApplications.contains(app);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: isDark ? AppTheme.darkCard : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? Colors.green : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: CheckboxListTile(
                    value: isSelected,
                    onChanged: (_) => _toggleApplicationSelection(app),
                    title: Text(
                      app.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(app.department),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: _getRequiredAttachmentChips(app, isDark),
                        ),
                      ],
                    ),
                    activeColor: Colors.green,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  List<Widget> _getRequiredAttachmentChips(Application app, bool isDark) {
    final chips = <Widget>[];

    if (app.technicalSituation) {
      chips.add(_buildAttachmentChip('Technická situácia', isDark));
    }
    if (app.situation) {
      chips.add(_buildAttachmentChip('Situácia', isDark));
    }
    if (app.situationA3) {
      chips.add(_buildAttachmentChip('Situácia A3', isDark));
    }
    if (app.broaderRelations) {
      chips.add(_buildAttachmentChip('Širšie vzťahy', isDark));
    }

    return chips;
  }

  Widget _buildAttachmentChip(String label, bool isDark) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 11),
      ),
      avatar: const Icon(Icons.attach_file, size: 14),
      backgroundColor: Colors.blue.withOpacity(0.1),
      side: BorderSide(color: Colors.blue.withOpacity(0.3)),
      padding: EdgeInsets.zero,
      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  // KROK 2: Nahratie príloh
  Widget _buildAttachmentUploadStep(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nahraj potrebné prílohy',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Na základe vybraných žiadostí potrebuješ nahrať ${_requiredAttachmentTypes.length} ${_requiredAttachmentTypes.length == 1 ? "prílohu" : _requiredAttachmentTypes.length < 5 ? "prílohy" : "príloh"}.',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),

          // Zobraz len tie prílohy, ktoré sú potrebné
          if (_requiredAttachmentTypes.contains('technical_situation'))
            _buildAttachmentCard(
              type: 'technical_situation',
              label: 'Technická situácia',
              description: 'Situačný výkres so zakreslenou stavbou',
              isDark: isDark,
            ),

          if (_requiredAttachmentTypes.contains('situation'))
            _buildAttachmentCard(
              type: 'situation',
              label: 'Situácia',
              description: 'Situačný výkres lokality',
              isDark: isDark,
            ),

          if (_requiredAttachmentTypes.contains('situation_a3'))
            _buildAttachmentCard(
              type: 'situation_a3',
              label: 'Situácia A3',
              description: 'Situačný výkres vo formáte A3',
              isDark: isDark,
            ),

          if (_requiredAttachmentTypes.contains('broader_relations'))
            _buildAttachmentCard(
              type: 'broader_relations',
              label: 'Širšie vzťahy',
              description: 'Výkres širších vzťahov územia',
              isDark: isDark,
            ),

          // ✅ PRIDAJ ZVYŠNÉ TYPY
          if (_requiredAttachmentTypes.contains('fire_protection'))
            _buildAttachmentCard(
              type: 'fire_protection',
              label: 'Požiarna ochrana',
              description: 'Stanovisko požiarnej ochrany',
              isDark: isDark,
            ),

          if (_requiredAttachmentTypes.contains('water_management'))
            _buildAttachmentCard(
              type: 'water_management',
              label: 'Vodné hospodárstvo',
              description: 'Stanovisko vodného hospodárstva',
              isDark: isDark,
            ),

          if (_requiredAttachmentTypes.contains('public_health'))
            _buildAttachmentCard(
              type: 'public_health',
              label: 'Verejné zdravotníctvo',
              description: 'Stanovisko verejného zdravotníctva',
              isDark: isDark,
            ),

          if (_requiredAttachmentTypes.contains('railways'))
            _buildAttachmentCard(
              type: 'railways',
              label: 'Železnice',
              description: 'Stanovisko správy železníc',
              isDark: isDark,
            ),

          if (_requiredAttachmentTypes.contains('roads_1'))
            _buildAttachmentCard(
              type: 'roads_1',
              label: 'Cesty 1',
              description: 'Stanovisko správy ciest',
              isDark: isDark,
            ),

          if (_requiredAttachmentTypes.contains('roads_2'))
            _buildAttachmentCard(
              type: 'roads_2',
              label: 'Cesty 2',
              description: 'Doplňujúce stanovisko správy ciest',
              isDark: isDark,
            ),

          if (_requiredAttachmentTypes.contains('municipality'))
            _buildAttachmentCard(
              type: 'municipality',
              label: 'Obec',
              description: 'Stanovisko obce',
              isDark: isDark,
            ),
        ],
      ),
    );
  }

  Widget _buildAttachmentCard({
    required String type,
    required String label,
    required String description,
    required bool isDark,
  }) {
    final hasFile = _uploadedAttachments.containsKey(type);
    final file = _uploadedAttachments[type];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: isDark ? AppTheme.darkCard : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: hasFile ? Colors.green : (isDark ? Colors.white12 : Colors.grey[300]!),
          width: hasFile ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: hasFile
            ? _buildUploadedFileInfo(type, label, file!, isDark)
            : _buildUploadPrompt(type, label, description, isDark),
      ),
    );
  }

  Widget _buildUploadPrompt(String type, String label, String description, bool isDark) {
    return InkWell(
      onTap: () => _pickAttachment(type),
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Icon(
            Icons.cloud_upload_outlined,
            size: 48,
            color: isDark ? Colors.white38 : Colors.grey,
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white60 : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _pickAttachment(type),
            icon: const Icon(Icons.upload_file),
            label: const Text('Vybrať PDF súbor'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadedFileInfo(String type, String label, File file, bool isDark) {
    final fileName = file.path.split('/').last;
    final fileSize = file.lengthSync();
    final fileSizeMB = (fileSize / 1024 / 1024).toStringAsFixed(2);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.picture_as_pdf, color: Colors.green, size: 32),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                fileName,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white70 : Colors.grey[700],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '$fileSizeMB MB',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white60 : Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.blue),
          onPressed: () => _pickAttachment(type),
          tooltip: 'Zmeniť súbor',
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.red),
          onPressed: () => _removeAttachment(type),
          tooltip: 'Odstrániť',
        ),
      ],
    );
  }

  // KROK 3: Progress odosielania
  Widget _buildSubmissionProgressStep(bool isDark) {
    final progress = _currentSubmissionIndex / _selectedApplications.length;
    final successCount = _submissionResults.values.where((r) => r.status == SubmissionStatus.success).length;
    final errorCount = _submissionResults.values.where((r) => r.status == SubmissionStatus.error).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Overall progress
          Card(
            color: isDark ? AppTheme.darkCard : Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Odosielam vyjadrenia...',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        '${_currentSubmissionIndex + 1} / ${_selectedApplications.length}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryRed,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 16,
                      backgroundColor: isDark ? Colors.white10 : Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation(
                        errorCount > 0 ? Colors.orange : Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatChip(
                        icon: Icons.check_circle,
                        label: 'Úspešné',
                        value: successCount.toString(),
                        color: Colors.green,
                      ),
                      _buildStatChip(
                        icon: Icons.error,
                        label: 'Chyby',
                        value: errorCount.toString(),
                        color: Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Zoznam žiadostí
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _selectedApplications.length,
            itemBuilder: (context, index) {
              final app = _selectedApplications[index];
              final result = _submissionResults[app.id];
              final isActive = index == _currentSubmissionIndex;

              return _buildSubmissionCard(app, result, isActive, isDark);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildSubmissionCard(Application app, SubmissionResult? result, bool isActive, bool isDark) {
    final status = result?.status ?? SubmissionStatus.pending;
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
      case SubmissionStatus.pending:
        statusColor = Colors.grey;
        statusIcon = Icons.pending_outlined;
        statusText = 'Čaká';
        break;
      case SubmissionStatus.sending:
        statusColor = Colors.blue;
        statusIcon = Icons.sync;
        statusText = 'Odosielam...';
        break;
      case SubmissionStatus.success:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Odoslané ✓';
        break;
      case SubmissionStatus.error:
        statusColor = Colors.red;
        statusIcon = Icons.error;
        statusText = 'Chyba ✗';
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isDark ? AppTheme.darkCard : Colors.white,
      elevation: isActive ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isActive ? AppTheme.primaryRed : Colors.transparent,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: status == SubmissionStatus.sending
                      ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation(statusColor),
                    ),
                  )
                      : Icon(statusIcon, color: statusColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        app.department,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white60 : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            if (result?.errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        result!.errorMessage!,
                        style: const TextStyle(fontSize: 12, color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // KROK 4: Výsledky
  Widget _buildResultsStep(bool isDark) {
    final successCount = _submissionResults.values.where((r) => r.status == SubmissionStatus.success).length;
    final errorCount = _submissionResults.values.where((r) => r.status == SubmissionStatus.error).length;
    final allSuccess = errorCount == 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(48),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: (allSuccess ? Colors.green : Colors.orange).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                allSuccess ? Icons.check_circle_rounded : Icons.warning_rounded,
                size: 80,
                color: allSuccess ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              allSuccess ? 'Všetko odoslané!' : 'Odosielanie dokončené',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: allSuccess ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 48),

            // Sumár
            Container(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Card(
                color: isDark ? AppTheme.darkCard : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      _buildResultRow(
                        icon: Icons.check_circle,
                        label: 'Úspešne odoslané',
                        value: successCount.toString(),
                        color: Colors.green,
                        isDark: isDark,
                      ),
                      if (errorCount > 0) ...[
                        const SizedBox(height: 20),
                        _buildResultRow(
                          icon: Icons.error,
                          label: 'Chyby',
                          value: errorCount.toString(),
                          color: Colors.red,
                          isDark: isDark,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),

            // Tlačidlá
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                if (errorCount > 0)
                  ElevatedButton.icon(
                    onPressed: _retryFailedSubmissions,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Opakovať chybné'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                    ),
                  ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.check),
                  label: const Text('Zatvoriť'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white70 : Colors.grey[700],
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  // Navigačné tlačidlá
  Widget _buildNavigationButtons(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 1)
            OutlinedButton.icon(
              onPressed: () => setState(() => _currentStep--),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Späť'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            )
          else
            const SizedBox.shrink(),

          ElevatedButton.icon(
            onPressed: _canProceedToNextStep() ? _proceedToNextStep : null,
            icon: Icon(_currentStep == 2 ? Icons.send : Icons.arrow_forward),
            label: Text(_currentStep == 2 ? 'Odoslať' : 'Ďalej'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              disabledBackgroundColor: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceedToNextStep() {
    switch (_currentStep) {
      case 1:
        return _selectedApplications.isNotEmpty;
      case 2:
        return _allRequiredAttachmentsUploaded;
      default:
        return false;
    }
  }

  void _proceedToNextStep() {
    if (_currentStep == 2) {
      _startSubmission();
    } else {
      setState(() => _currentStep++);
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// ==================== MODELY ====================

enum SubmissionStatus {
  pending,
  sending,
  success,
  error,
}

class SubmissionResult {
  final SubmissionStatus status;
  final String appName;
  final String? messageId;
  final String? errorMessage;

  SubmissionResult({
    required this.status,
    required this.appName,
    this.messageId,
    this.errorMessage,
  });
}