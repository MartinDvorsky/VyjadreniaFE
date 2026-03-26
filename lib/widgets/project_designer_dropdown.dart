import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/project_designer_model.dart';
import '../services/project_designer_service.dart';
import '../providers/step2_data_provider.dart';
import '../utils/app_theme.dart'; // ✅ Import AppTheme

class ProjectDesignerDropdown extends StatefulWidget {
  const ProjectDesignerDropdown({Key? key}) : super(key: key);

  @override
  State<ProjectDesignerDropdown> createState() =>
      _ProjectDesignerDropdownState();
}

class _ProjectDesignerDropdownState extends State<ProjectDesignerDropdown> {
  List<ProjectDesigner>? _designers;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDesigners();
  }

  Future<void> _loadDesigners() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final designers = await ProjectDesignerService().getAllProjectDesigners();
      if (mounted) {
        setState(() {
          _designers = designers;
          _isLoading = false;
        });
        _syncWithProvider();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _syncWithProvider() {
    final provider = context.read<Step2DataProvider>();
    final selectedProjektant = provider.selectedProjektant;

    if (selectedProjektant != null && _designers != null) {
      ProjectDesigner? matchingDesigner;

      if (selectedProjektant.id != null) {
        matchingDesigner = _designers!.firstWhere(
              (d) => d.id == selectedProjektant.id,
          orElse: () => selectedProjektant,
        );
      }

      if (matchingDesigner == null && selectedProjektant.license != null) {
        matchingDesigner = _designers!.firstWhere(
              (d) => d.license == selectedProjektant.license,
          orElse: () => selectedProjektant,
        );
      }

      if (matchingDesigner != null && _designers!.contains(matchingDesigner)) {
        provider.setSelectedProjektant(matchingDesigner);
        print('✅ Synchronized designer: ${matchingDesigner.name}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Farby pre Loading/Error stavy
    final containerBg = isDark ? AppTheme.darkCard : Colors.white;
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : Colors.grey[300]!;
    final textColor = isDark ? Colors.white : Colors.black;
    final hintColor = isDark ? Colors.white54 : Colors.grey[600];

    return Consumer<Step2DataProvider>(
      builder: (context, provider, child) {
        if (_isLoading) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Projektant',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor, // ✅
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(4),
                  color: containerBg, // ✅
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: isDark ? Colors.blue.shade200 : Colors.blue), // ✅
                    ),
                    const SizedBox(width: 12),
                    Text('Načítavam projektantov...',
                        style: TextStyle(color: textColor)), // ✅
                  ],
                ),
              ),
            ],
          );
        }

        if (_error != null) {
          final errorBg = isDark ? const Color(0xFF2C1515) : Colors.red[50]!;
          final errorBorder = isDark ? Colors.red.shade900 : Colors.red[300]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Projektant',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor, // ✅
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: errorBorder),
                  borderRadius: BorderRadius.circular(4),
                  color: errorBg, // ✅
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Chyba pri načítaní',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    TextButton(
                      onPressed: _loadDesigners,
                      child: const Text('Skúsiť znova'),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        if (_designers == null || _designers!.isEmpty) {
          final emptyBg = isDark ? AppTheme.darkCard : Colors.grey[50]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Projektant',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor, // ✅
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(4),
                  color: emptyBg, // ✅
                ),
                child: Text(
                  'Žiadni projektanti v databáze',
                  style: TextStyle(color: isDark ? Colors.white54 : Colors.grey), // ✅
                ),
              ),
            ],
          );
        }

        final selectedProjektant = provider.selectedProjektant;
        final isInList = selectedProjektant != null &&
            _designers!.any((d) =>
            d.id == selectedProjektant.id ||
                d.license == selectedProjektant.license);

        List<ProjectDesigner> displayDesigners = List.from(_designers!);
        if (selectedProjektant != null && !isInList) {
          displayDesigners.insert(0, selectedProjektant);
        }

        ProjectDesigner? dropdownValue;
        if (selectedProjektant != null && isInList) {
          dropdownValue = displayDesigners.firstWhere(
                (d) =>
            d.id == selectedProjektant.id ||
                d.license == selectedProjektant.license,
          );
        } else if (selectedProjektant != null && !isInList) {
          dropdownValue = selectedProjektant;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Projektant',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor, // ✅
                  ),
                ),
                const Text(
                  ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Dropdown
            DropdownButtonFormField<ProjectDesigner>(
              value: dropdownValue,
              dropdownColor: isDark ? AppTheme.darkCard : Colors.white, // ✅
              decoration: InputDecoration(
                hintText: 'Vyberte projektanta',
                hintStyle: TextStyle(color: hintColor), // ✅
                prefixIcon: Icon(Icons.person_rounded,
                    size: 20, color: isDark ? Colors.white70 : null), // ✅
                filled: true,
                fillColor: containerBg, // ✅
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
              ),
              isExpanded: true,
              items: displayDesigners.map((designer) {
                return DropdownMenuItem(
                  value: designer,
                  child: Text(
                    '${designer.name}${designer.license != null ? ' - ${designer.license}' : ''}',
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor, // ✅
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (designer) {
                provider.setSelectedProjektant(designer);
              },
              validator: (value) {
                if (value == null) {
                  return 'Prosím vyberte projektanta';
                }
                return null;
              },
            ),

            // Warning ak nenájdený
            if (selectedProjektant != null && !isInList) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF3E2C00) : Colors.orange[50], // ✅
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                      color: isDark ? Colors.orange.shade900 : Colors.orange[300]!), // ✅
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: isDark ? Colors.orange.shade400 : Colors.orange[700],
                        size: 18), // ✅
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Projektant ${selectedProjektant.name} nebol nájdený v databáze',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.orange.shade200 : Colors.orange[900], // ✅
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
