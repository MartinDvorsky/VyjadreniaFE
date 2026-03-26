// ========================================
// STEP 5: NÁZVY SÚBOROV - FINÁLNA OPRAVENÁ VERZIA
// Uložiť ako: lib/screens/generate_steps/step_5_file_names.dart
// ========================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/step5_data_provider.dart';
import '../../providers/step3_data_provider.dart';
import '../../providers/step2_data_provider.dart';
import '../../providers/generate_provider.dart';
import '../../models/application_model.dart';
import '../../utils/app_theme.dart';
import '../../services/application_service.dart';

class Step5FileNames extends StatefulWidget {
  const Step5FileNames({Key? key}) : super(key: key);

  @override
  State<Step5FileNames> createState() => _Step5FileNamesState();
}

class _Step5FileNamesState extends State<Step5FileNames> {
  bool _hasInitialized = false;
  final Map<int, TextEditingController> _controllers = {};
  bool _hasShownP56Dialog = false;

  // ✅ Kontrola, či je vybraný Paragraf 56
  bool _isParagraf56(BuildContext context) {
    final step3Provider = context.read<Step3DataProvider>();
    return step3Provider.selectedBuildingPurpose?.purposeName.contains('56') ?? false;
  }

  // ✅ Automatické skrytie úradov pre Paragraf 56
  List<int> _autoHideOfficesForP56(Step5DataProvider provider) {
    final hiddenOfficeIds = <int>[];

    final keywordsToHide = [
      'Odbor starostlivosti o žp',
      'Ministerstvo obrany',
      'KPÚ',
      'Krajský pamiatový úrad',
      'MV SR',
    ];

    for (var app in provider.applications) {
      if (provider.isHidden(app.applicationId)) continue;

      final shouldHide = keywordsToHide.any((keyword) =>
      app.name.contains(keyword) || app.department.contains(keyword));

      if (shouldHide) {
        provider.hideApplication(app.applicationId);
        hiddenOfficeIds.add(app.applicationId);
      }
    }

    return hiddenOfficeIds;
  }

  // ✅ Zobrazenie dialógu pre P56
  void _showP56AutoHideDialog(List<int> hiddenOfficeIds) {
    if (hiddenOfficeIds.isEmpty || _hasShownP56Dialog) return;

    _hasShownP56Dialog = true;

    final step5Provider = context.read<Step5DataProvider>();

    final hiddenOfficeNames = hiddenOfficeIds
        .map((id) => step5Provider.applications
        .firstWhere((app) => app.applicationId == id)
        .name)
        .toList();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final isDark = Theme.of(context).brightness == Brightness.dark;
      final dialogBg = isDark ? AppTheme.darkCard : Colors.white;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: dialogBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.info_rounded,
                  color: Colors.blue.shade600,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Paragraf 56 - Automatické skrytie',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline,
                        color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Pre Paragraf 56 boli automaticky skryté úrady, ktoré nie sú potrebné.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Skryté úrady (${hiddenOfficeNames.length}):',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                child: SingleChildScrollView(
                  child: Column(
                    children: hiddenOfficeNames
                        .map((name) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.visibility_off,
                            size: 16,
                            color: Colors.orange.shade600,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              name,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? Colors.white70
                                    : Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ))
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 18,
                      color: isDark ? Colors.white54 : Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Skryté úrady nájdete v sekcii "Skryté úrady" nižšie.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white54 : Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            OutlinedButton.icon(
              onPressed: () {
                for (var id in hiddenOfficeIds) {
                  step5Provider.showApplication(id);
                }
                _initializeControllers();
                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.undo, color: Colors.white),
                        const SizedBox(width: 12),
                        Text('Zobrazených ${hiddenOfficeIds.length} úradov späť'),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.undo, size: 18),
              label: const Text('Vrátiť späť'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange.shade700,
                side: BorderSide(color: Colors.orange.shade700),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(dialogContext),
              icon: const Icon(Icons.check, size: 18),
              label: const Text('Rozumiem'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryRed,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_hasInitialized) {
        _initializeData();
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    super.dispose();
  }

  // ✅ OPRAVENÁ INICIALIZÁCIA S TIMEOUTOM
  Future<void> _initializeData() async {
    if (_hasInitialized) return;

    _hasInitialized = true;

    final generateProvider = context.read<GenerateProvider>();
    final step3Provider = context.read<Step3DataProvider>();
    final step5Provider = context.read<Step5DataProvider>();

    step5Provider.setContext(context);

    if (generateProvider.selectedCities.isEmpty) {
      print('⚠️ No city selected');
      return;
    }

    print('🚀 Starting Step 5 initialization...');

    try {
      // ✅ TIMEOUT 30 sekúnd - zabráni nekonečnému čakaniu
      await step5Provider
          .loadFilteredApplications(
        cityIds: generateProvider.selectedCities.map((c) => c.id).toList(),
        fireProtection: step3Provider.orhazz,
        waterManagement: step3Provider.svp,
        publicHealth: step3Provider.ruvz,
        railways: step3Provider.zsr,
        roads1: step3Provider.cestyI,
        roads2: step3Provider.cestyII,
        municipality: step3Provider.mestoObec,
      )
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Načítanie trvalo príliš dlho (>30s)');
        },
      );

      print('✅ Step5: Applications loaded: ${step5Provider.applications.length}');

      if (!mounted) {
        print('⚠️ Step5: Widget is not mounted, skipping initialization');
        return;
      }

      _initializeControllers();
      step5Provider.markAsReady();

      print('✅ Step5: Initialization complete');

      // ✅ Automatické skrytie úradov pre Paragraf 56
      if (_isParagraf56(context) && !_hasShownP56Dialog) {
        final hiddenIds = _autoHideOfficesForP56(step5Provider);
        if (hiddenIds.isNotEmpty) {
          print('🔒 Step5: Auto-hiding ${hiddenIds.length} offices for P56');
          _showP56AutoHideDialog(hiddenIds);
        }
      }
    } on TimeoutException catch (e) {
      print('⏱️ Step5: Timeout error: $e');
      if (mounted) {

      }
    } catch (e, stackTrace) {
      print('❌ Step5: Error loading applications: $e');
      print('Stack trace: $stackTrace');

      if (mounted) {

      }
    }
  }

  void _initializeControllers() {
    final provider = context.read<Step5DataProvider>();
    final step2Provider = context.read<Step2DataProvider>();
    final znacka = step2Provider.znacka;

    print('🎮 Initializing ${provider.applications.length} controllers');

    for (var app in provider.applications) {
      if (!_controllers.containsKey(app.applicationId)) {
        final filename = provider.getFilename(app.applicationId, znacka: znacka);
        _controllers[app.applicationId] = TextEditingController(text: filename);
      }
    }

    print('✅ Controllers initialized: ${_controllers.length}');
  }

  Future<void> _refreshData() async {
    _hasInitialized = false;
    _hasShownP56Dialog = false;
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    await _initializeData();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<Step5DataProvider, _Step5State>(
      selector: (_, provider) => _Step5State(
        isLoading: provider.isLoading,
        errorMessage: provider.errorMessage,
        applicationsCount: provider.applicationsCount,
        visibleCount: provider.visibleCount,
        hiddenCount: provider.hiddenCount,
      ),
      builder: (context, state, child) {
        print('🔄 Step5 rebuild - Loading: ${state.isLoading}, Apps: ${state.applicationsCount}');

        if (state.isLoading) {
          return _buildLoadingState();
        }

        if (state.errorMessage != null) {
          return _buildErrorState(state.errorMessage!);
        }

        if (state.applicationsCount == 0) {
          return _buildEmptyState();
        }

        return _buildSuccessState();
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppTheme.primaryRed),
          const SizedBox(height: 16),
          Text(
            'Načítavam úrady...',
            style: TextStyle(
              color: AppTheme.textMedium,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF2C1515) : Colors.red.shade50;
    final border = isDark ? Colors.red.shade900 : Colors.red.shade200;

    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700, size: 48),
            const SizedBox(height: 16),
            Text(
              'Chyba pri načítaní úradov',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red.shade600),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _refreshData,
              icon: const Icon(Icons.refresh),
              label: const Text('Skúsiť znova'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF3E2C00) : Colors.orange.shade50;
    final border = isDark ? Colors.orange.shade900 : Colors.orange.shade200;

    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, color: Colors.orange.shade700, size: 48),
            const SizedBox(height: 16),
            Text(
              'Žiadne úrady',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.orange.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pre vybrané mesto a kritériá neboli nájdené žiadne úrady.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.orange.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessState() {
    return Consumer<Step5DataProvider>(
      builder: (context, provider, child) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isMobile = screenWidth < 768;

        // ✅ Rozdeľ úrady na online a non-online
        final nonOnlineApps = provider.applications
            .where((app) =>
        !provider.isHidden(app.applicationId) &&
            app.submission != 'online')
            .toList();

        final onlineApps = provider.applications
            .where((app) =>
        !provider.isHidden(app.applicationId) &&
            app.submission == 'online')
            .toList();

        final hiddenApps = provider.applications
            .where((app) => provider.isHidden(app.applicationId))
            .toList();

        final isDark = Theme.of(context).brightness == Brightness.dark;

        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, provider, isMobile),
              const SizedBox(height: 24),

              // ✅ ÚRADY NA GENEROVANIE (NON-ONLINE)
              if (nonOnlineApps.isEmpty)
                _buildEmptyNonOnlineState(isDark)
              else
                ...nonOnlineApps.map((app) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildApplicationCard(context, provider, app, isMobile),
                )),

              // ✅ ONLINE ÚRADY - EXPANDABLE SEKCIA
              if (onlineApps.isNotEmpty) ...[
                const SizedBox(height: 32),
                _buildOnlineOfficesSection(context, provider, onlineApps, isDark, isMobile),
              ],

              // ✅ SKRYTÉ ÚRADY - EXPANDABLE SEKCIA
              if (hiddenApps.isNotEmpty) ...[
                const SizedBox(height: 32),
                _buildHiddenOfficesSection(context, provider, hiddenApps, isDark),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyNonOnlineState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(
              Icons.description_outlined,
              size: 64,
              color: isDark ? Colors.white24 : Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Žiadne dokumenty na generovanie',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Všetky úrady majú elektronické podanie',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white38 : Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

// ✅ NOVÁ METÓDA: Sekcia pre online úrady
  Widget _buildOnlineOfficesSection(
      BuildContext context,
      Step5DataProvider provider,
      List<Application> onlineApps,
      bool isDark,
      bool isMobile,
      ) {
    final cardBg = isDark ? const Color(0xFF001F3F) : Colors.blue.shade50;
    final borderColor = isDark ? Colors.blue.shade900 : Colors.blue.shade300;
    final headerBg = isDark ? const Color(0xFF003366) : Colors.blue.shade100;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          initiallyExpanded: false,
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          backgroundColor: headerBg,
          collapsedBackgroundColor: headerBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.shade600.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.cloud_upload_rounded,
              color: Colors.blue.shade700,
              size: 24,
            ),
          ),
          title: Text(
            'Úrady s online podaním',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.shade700,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${onlineApps.length}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          children: [
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.blue.shade900.withOpacity(0.2)
                    : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? Colors.blue.shade700 : Colors.blue.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color: isDark ? Colors.blue.shade300 : Colors.blue.shade700,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tieto úrady majú online podanie - podanie sa realizuje priamo cez ich webovú stránku.',
                      style: TextStyle(
                        fontSize: 13,
                        color:
                        isDark ? Colors.blue.shade200 : Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ...onlineApps.map((app) => _buildOnlineOfficeItem(
              context,
              provider,
              app,
              isDark,
              isMobile,
            )),
          ],
        ),
      ),
    );
  }

// ✅ NOVÁ METÓDA: Item pre online úrad
  Widget _buildOnlineOfficeItem(
      BuildContext context,
      Step5DataProvider provider,
      Application app,
      bool isDark,
      bool isMobile,
      ) {
    final itemBg = isDark ? AppTheme.darkCard : Colors.white;
    final borderColor =
    isDark ? Colors.blue.shade700.withOpacity(0.3) : Colors.blue.shade200;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(isMobile ? 14 : 16),
      decoration: BoxDecoration(
        color: itemBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 8 : 10),
            decoration: BoxDecoration(
              color: Colors.blue.shade600.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.cloud_upload_rounded,
              color: Colors.blue.shade700,
              size: isMobile ? 20 : 24,
            ),
          ),
          SizedBox(width: isMobile ? 10 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  app.name,
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${app.department} • ${app.city}',
                  style: TextStyle(
                    fontSize: isMobile ? 11 : 12,
                    color: isDark ? Colors.white54 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.language_rounded,
                        size: 14,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Online podanie',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.visibility_off_outlined),
            onPressed: () => _showHideDialog(context, provider, app),
            tooltip: 'Skryť úrad',
            color: Colors.orange.shade600,
            padding: EdgeInsets.all(isMobile ? 6 : 8),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyVisibleState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(
              Icons.visibility_off_outlined,
              size: 64,
              color: isDark ? Colors.white24 : Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Všetky úrady sú skryté',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Zobraz aspoň jeden úrad v skrytých položkách nižšie',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white38 : Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHiddenOfficesSection(
      BuildContext context,
      Step5DataProvider provider,
      List<Application> hiddenApps,
      bool isDark,
      ) {
    final cardBg = isDark ? const Color(0xFF2C2000) : Colors.orange.shade50;
    final borderColor = isDark ? Colors.orange.shade900 : Colors.orange.shade300;
    final headerBg = isDark ? const Color(0xFF3E2C00) : Colors.orange.shade100;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          initiallyExpanded: false,
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          backgroundColor: headerBg,
          collapsedBackgroundColor: headerBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.shade600.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.visibility_off_rounded,
              color: Colors.orange.shade700,
              size: 24,
            ),
          ),
          title: Text(
            'Skryté úrady',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange.shade700,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${hiddenApps.length}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          children: [
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.blue.shade900.withOpacity(0.2)
                    : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? Colors.blue.shade700 : Colors.blue.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color: isDark ? Colors.blue.shade300 : Colors.blue.shade700,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Kliknutím na checkbox zobrazíte úrad späť v aktívnych položkách',
                      style: TextStyle(
                        fontSize: 13,
                        color:
                        isDark ? Colors.blue.shade200 : Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ...hiddenApps.map((app) => _buildHiddenOfficeItem(
              context,
              provider,
              app,
              isDark,
            )),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  for (var app in hiddenApps) {
                    provider.showApplication(app.applicationId);
                  }
                  _initializeControllers();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 12),
                          Text('Zobrazených ${hiddenApps.length} úradov'),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.visibility, size: 20),
                label: const Text('Zobraziť všetky'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(
                    color: Colors.orange.shade700,
                    width: 2,
                  ),
                  foregroundColor: Colors.orange.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHiddenOfficeItem(
      BuildContext context,
      Step5DataProvider provider,
      Application app,
      bool isDark,
      ) {
    final itemBg = isDark ? AppTheme.darkCard : Colors.white;
    final borderColor =
    isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade300;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: itemBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Transform.scale(
            scale: 1.1,
            child: Checkbox(
              value: false,
              onChanged: (value) {
                if (value == true) {
                  provider.showApplication(app.applicationId);
                  _initializeControllers();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.visibility, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text('Úrad "${app.name}" bol zobrazený'),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              activeColor: Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getColorByType(app).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _getIconByType(app),
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  app.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${app.department} • ${app.city}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          _buildTypeBadge(context, app),
        ],
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, Step5DataProvider provider, bool isMobile) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradientColors = isDark
        ? [const Color(0xFF1B3320), const Color(0xFF27442E)]
        : [Colors.green.shade50, Colors.green.shade100];
    final borderColor = isDark ? Colors.green.shade900 : Colors.green.shade200;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: isMobile
          ? _buildMobileHeader(context, provider, isDark)
          : _buildDesktopHeader(context, provider, isDark),
    );
  }

  Widget _buildMobileHeader(
      BuildContext context, Step5DataProvider provider, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.shade600,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.folder_open_rounded,
                  color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Názvy súborov pre úrady',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: isDark ? Colors.white : null,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Upravte názvy súborov alebo skryte nepotrebné úrady',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isDark ? Colors.white70 : null,
            fontSize: 13,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.shade300),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.description_outlined,
                  color: Colors.green.shade700, size: 18),
              const SizedBox(width: 8),
              Text(
                '${provider.visibleCount} úradov',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showAddSubjectDialog(context),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Pridať subjekt'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopHeader(
      BuildContext context, Step5DataProvider provider, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.shade600,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.folder_open_rounded,
              color: Colors.white, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Názvy súborov pre úrady',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: isDark ? Colors.white : null,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Upravte názvy súborov alebo skryte nepotrebné úrady',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white70 : null,
                ),
              ),
            ],
          ),
        ),
        // ✅ Zobraz počet dokumentov na generovanie
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.shade300),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.description_outlined,
                  color: Colors.green.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                '${provider.toGenerateCount} dokumentov',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade700,
                ),
              ),
              if (provider.onlineCount > 0) ...[
                const SizedBox(width: 12),
                Container(
                  width: 1,
                  height: 20,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(width: 12),
                Icon(Icons.cloud_upload_rounded,
                    color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${provider.onlineCount} online',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: () => _showAddSubjectDialog(context),
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Pridať subjekt'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildApplicationCard(
      BuildContext context,
      Step5DataProvider provider,
      Application app,
      bool isMobile,
      ) {
    final step2Provider = context.watch<Step2DataProvider>();
    final znacka = step2Provider.znacka;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardBg = isDark ? AppTheme.darkCard : AppTheme.white;
    final cardBorder =
    isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor;
    final infoBg = isDark ? AppTheme.darkSurface : Colors.grey.shade50;
    final infoBorder =
    isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200;

    if (!_controllers.containsKey(app.applicationId)) {
      final filename = provider.getFilename(app.applicationId, znacka: znacka);
      _controllers[app.applicationId] = TextEditingController(text: filename);
    }

    final controller = _controllers[app.applicationId]!;

    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 8 : 10),
                decoration: BoxDecoration(
                  color: _getColorByType(app).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getIconByType(app),
                  style: TextStyle(fontSize: isMobile ? 20 : 24),
                ),
              ),
              SizedBox(width: isMobile ? 8 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.name,
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${app.department} • ${app.city}',
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 13,
                        color: isDark ? Colors.white70 : AppTheme.textMedium,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (!isMobile) ...[
                if (provider.isManuallyAdded(app.applicationId)) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.green.shade900.withOpacity(0.3) : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: isDark ? Colors.green.shade700 : Colors.green.shade300),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person_add_rounded, size: 12, color: Colors.green.shade700),
                        const SizedBox(width: 4),
                        Text(
                          'Manuálne pridané',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                _buildTypeBadge(context, app),
                const SizedBox(width: 8),
              ],
              IconButton(
                icon: Icon(
                  Icons.visibility_off_outlined,
                  size: isMobile ? 20 : 24,
                ),
                tooltip: 'Skryť úrad',
                color: Colors.orange.shade600,
                onPressed: () => _showHideDialog(context, provider, app),
                padding: EdgeInsets.all(isMobile ? 6 : 8),
              ),
            ],
          ),
          if (isMobile) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                _buildTypeBadge(context, app),
                if (provider.isManuallyAdded(app.applicationId)) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person_add_rounded, size: 12, color: Colors.green.shade700),
                        const SizedBox(width: 4),
                        Text(
                          'Manuálne',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
          SizedBox(height: isMobile ? 12 : 16),
          TextFormField(
            controller: controller,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: isMobile ? 13 : 14,
            ),
            decoration: InputDecoration(
              labelText: 'Názov súboru',
              labelStyle: TextStyle(fontSize: isMobile ? 12 : 14),
              hintText: 'napr: ORHAZZ_Kosice_2024',
              hintStyle: TextStyle(
                color: isDark ? Colors.white30 : null,
                fontSize: isMobile ? 12 : 14,
              ),
              prefixIcon: Icon(
                Icons.insert_drive_file_outlined,
                color: AppTheme.primaryRed,
                size: isMobile ? 18 : 20,
              ),
              suffixIcon: IconButton(
                icon: Icon(Icons.auto_awesome, size: isMobile ? 18 : 20),
                tooltip: 'Generovať automaticky',
                onPressed: () {
                  provider.setFilename(app.applicationId, '');
                  final newFilename =
                  provider.getFilename(app.applicationId, znacka: znacka);
                  controller.text = newFilename;
                },
              ),
              filled: true,
              fillColor: isDark ? AppTheme.darkSurface : Colors.white,
              contentPadding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 16,
                vertical: isMobile ? 12 : 14,
              ),
            ),
            onChanged: (value) => provider.setFilename(app.applicationId, value),
          ),
          SizedBox(height: isMobile ? 10 : 12),
          Container(
            padding: EdgeInsets.all(isMobile ? 10 : 12),
            decoration: BoxDecoration(
              color: infoBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: infoBorder),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: isMobile ? 14 : 16,
                  color: isDark ? Colors.white54 : AppTheme.textMedium,
                ),
                SizedBox(width: isMobile ? 6 : 8),
                Expanded(
                  child: Text(
                    '${app.streetAddress}, ${app.postalCode} ${app.city}',
                    style: TextStyle(
                      fontSize: isMobile ? 11 : 12,
                      color: isDark ? Colors.white54 : AppTheme.textMedium,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ NOVÁ METÓDA: Dialóg na vyhľadanie a pridanie subjektu z DB
  void _showAddSubjectDialog(BuildContext context) {
    final applicationService = ApplicationService();
    final step5Provider = context.read<Step5DataProvider>();
    final step2Provider = context.read<Step2DataProvider>();
    final znacka = step2Provider.znacka;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return _AddSubjectDialog(
          applicationService: applicationService,
          step5Provider: step5Provider,
          znacka: znacka,
          onAdded: () {
            _initializeControllers();
          },
        );
      },
    );
  }

  void _showHideDialog(
      BuildContext context, Step5DataProvider provider, Application app) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? AppTheme.darkCard : Colors.white;
    final infoBg = isDark ? AppTheme.darkSurface : Colors.grey.shade100;
    final infoBorder =
    isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade300;
    final textColor = isDark ? Colors.white : null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: dialogBg,
        title: Row(
          children: [
            Icon(Icons.visibility_off, color: Colors.orange.shade600),
            const SizedBox(width: 12),
            Text('Skryť úrad?', style: TextStyle(color: textColor)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chcete skryť tento úrad z generovania?',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: textColor),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: infoBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: infoBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    app.name,
                    style:
                    TextStyle(fontWeight: FontWeight.w600, color: textColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    app.department,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : AppTheme.textMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Môžete ho neskôr znova zobraziť.',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white54 : AppTheme.textMedium,
                fontStyle: FontStyle.italic,
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
              provider.hideApplication(app.applicationId);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(child: Text('Úrad "${app.name}" bol skrytý')),
                    ],
                  ),
                  backgroundColor: Colors.orange.shade600,
                  behavior: SnackBarBehavior.floating,
                  action: SnackBarAction(
                    label: 'Vrátiť',
                    textColor: Colors.white,
                    onPressed: () {
                      provider.showApplication(app.applicationId);
                      _initializeControllers();
                    },
                  ),
                ),
              );
            },
            icon: const Icon(Icons.visibility_off, size: 18),
            label: const Text('Skryť'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeBadge(BuildContext context, Application app) {
    String label = '';
    Color color = Colors.grey;

    if (app.fireProtection) {
      label = 'ORHAZZ';
      color = Colors.orange;
    } else if (app.waterManagement) {
      label = 'SVP';
      color = Colors.blue;
    } else if (app.publicHealth) {
      label = 'RUVZ';
      color = Colors.green;
    } else if (app.railways) {
      label = 'ŽSR';
      color = Colors.blue.shade700;
    } else if (app.roads1) {
      label = 'Cesty I.';
      color = Colors.orange.shade700;
    } else if (app.roads2) {
      label = 'Cesty II.';
      color = Colors.orange.shade500;
    } else if (app.municipality) {
      label = 'Obec';
      color = Colors.purple;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  String _getIconByType(Application app) {
    if (app.fireProtection) return '⚡';
    if (app.waterManagement) return '💧';
    if (app.publicHealth) return '🏥';
    if (app.railways) return '🚂';
    if (app.roads1 || app.roads2) return '🛣️';
    if (app.municipality) return '🏛️';
    return '📋';
  }

  Color _getColorByType(Application app) {
    if (app.fireProtection) return Colors.orange;
    if (app.waterManagement) return Colors.blue;
    if (app.publicHealth) return Colors.green;
    if (app.railways) return Colors.blue.shade700;
    if (app.roads1 || app.roads2) return Colors.orange.shade600;
    if (app.municipality) return Colors.purple;
    return Colors.grey;
  }
}

class _Step5State {
  final bool isLoading;
  final String? errorMessage;
  final int applicationsCount;
  final int visibleCount;
  final int hiddenCount;

  _Step5State({
    required this.isLoading,
    required this.errorMessage,
    required this.applicationsCount,
    required this.visibleCount,
    required this.hiddenCount,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is _Step5State &&
              runtimeType == other.runtimeType &&
              isLoading == other.isLoading &&
              errorMessage == other.errorMessage &&
              applicationsCount == other.applicationsCount &&
              visibleCount == other.visibleCount &&
              hiddenCount == other.hiddenCount;

  @override
  int get hashCode =>
      isLoading.hashCode ^
      errorMessage.hashCode ^
      applicationsCount.hashCode ^
      visibleCount.hashCode ^
      hiddenCount.hashCode;
}

// =============================================
// DIALOG: Vyhľadanie a pridanie subjektu z DB
// =============================================
class _AddSubjectDialog extends StatefulWidget {
  final ApplicationService applicationService;
  final Step5DataProvider step5Provider;
  final String znacka;
  final VoidCallback onAdded;

  const _AddSubjectDialog({
    required this.applicationService,
    required this.step5Provider,
    required this.znacka,
    required this.onAdded,
  });

  @override
  State<_AddSubjectDialog> createState() => _AddSubjectDialogState();
}

class _AddSubjectDialogState extends State<_AddSubjectDialog> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  List<Application> _searchResults = [];
  bool _isSearching = false;
  String? _searchError;
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    if (query.trim().length < 2) {
      setState(() {
        _searchResults = [];
        _hasSearched = false;
        _searchError = null;
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _performSearch(query.trim());
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isSearching = true;
      _searchError = null;
    });

    try {
      final results = await widget.applicationService.searchApplications(
        name: query,
      );
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
          _hasSearched = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _searchError = 'Chyba pri vyhľadávaní: $e';
          _hasSearched = true;
        });
      }
    }
  }

  bool _isAlreadyAdded(Application app) {
    return widget.step5Provider.applications
        .any((a) => a.applicationId == app.applicationId);
  }

  void _addSubject(Application app) {
    final added = widget.step5Provider.addManualApplication(app);
    if (added) {
      widget.onAdded();
      setState(() {}); // refresh to show "Už pridané"

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('Úrad "${app.name}" bol pridaný')),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? AppTheme.darkCard : Colors.white;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Dialog(
      backgroundColor: dialogBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      insetPadding: EdgeInsets.all(isMobile ? 16 : 40),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? Colors.green.shade900.withOpacity(0.3) : Colors.green.shade50,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.shade600,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.search_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pridať subjekt',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Vyhľadajte úrad podľa názvu a pridajte ho do generovania',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white54 : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    color: isDark ? Colors.white54 : Colors.grey.shade600,
                  ),
                ],
              ),
            ),

            // Search field
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: 'Zadajte názov úradu...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white30 : Colors.grey.shade400,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: isDark ? Colors.white54 : Colors.grey.shade600,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                          color: isDark ? Colors.white54 : Colors.grey.shade600,
                        )
                      : null,
                  filled: true,
                  fillColor: isDark ? AppTheme.darkSurface : Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.green.shade600, width: 2),
                  ),
                ),
                onChanged: _onSearchChanged,
              ),
            ),

            // Results area
            Flexible(
              child: _buildResultsArea(isDark),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Zavrieť'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsArea(bool isDark) {
    if (_isSearching) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.green.shade600),
            const SizedBox(height: 12),
            Text(
              'Vyhľadávam...',
              style: TextStyle(color: isDark ? Colors.white54 : Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    if (_searchError != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade600, size: 40),
            const SizedBox(height: 8),
            Text(
              _searchError!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red.shade600, fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (!_hasSearched) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.manage_search_rounded,
              size: 48,
              color: isDark ? Colors.white24 : Colors.grey.shade300,
            ),
            const SizedBox(height: 12),
            Text(
              'Zadajte aspoň 2 znaky pre vyhľadávanie',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white38 : Colors.grey.shade500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: isDark ? Colors.white24 : Colors.grey.shade300,
            ),
            const SizedBox(height: 12),
            Text(
              'Žiadne výsledky pre "${_searchController.text}"',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white38 : Colors.grey.shade500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: _searchResults.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final app = _searchResults[index];
        final alreadyAdded = _isAlreadyAdded(app);

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: alreadyAdded
                ? (isDark ? Colors.grey.shade800.withOpacity(0.5) : Colors.grey.shade100)
                : (isDark ? AppTheme.darkSurface : Colors.white),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: alreadyAdded
                  ? (isDark ? Colors.grey.shade700 : Colors.grey.shade300)
                  : (isDark ? Colors.green.shade700.withOpacity(0.3) : Colors.green.shade200),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: alreadyAdded
                            ? (isDark ? Colors.white38 : Colors.grey.shade500)
                            : (isDark ? Colors.white : Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${app.department} • ${app.city}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white38 : Colors.grey.shade600,
                      ),
                    ),
                    if (app.streetAddress.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${app.streetAddress}, ${app.postalCode} ${app.city}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white24 : Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              alreadyAdded
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Už pridané',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white38 : Colors.grey.shade500,
                        ),
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: () => _addSubject(app),
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: const Text('Pridať'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }
}