// ========================================
// TEXT TYPES SECTION - Editácia textov
// lib/screens/database_sections/text_types_section.dart
// ========================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/text_type_provider.dart';
import '../../models/text_type_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/permission_helper.dart';

class TextTypesSection extends StatefulWidget {
  const TextTypesSection({Key? key}) : super(key: key);

  @override
  State<TextTypesSection> createState() => _TextTypesSectionState();
}

class _TextTypesSectionState extends State<TextTypesSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TextTypeProvider>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightGray,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ľavá strana - Zoznam textov
                  Expanded(
                    flex: 4,
                    child: _buildTextTypesList(context),
                  ),
                  const SizedBox(width: 24),
                  // Pravá strana - Edit Panel
                  Expanded(
                    flex: 6,
                    child: Consumer<TextTypeProvider>(
                      builder: (context, provider, child) {
                        if (provider.selectedTextType == null) {
                          return _buildEmptyState(context);
                        }
                        return _TextTypeEditPanel(
                          key: ValueKey(provider.selectedTextType!.id),
                          textType: provider.selectedTextType!,
                          onCancel: () => provider.clearSelection(),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== HEADER ====================

  Widget _buildHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.darkSurface : AppTheme.white;
    final border = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: BoxDecoration(
        color: bg,
        border: Border(
          bottom: BorderSide(color: border, width: 1),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: 'Späť na databázy',
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.pink.shade400, Colors.pink.shade600],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.edit_note_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Editácia textov',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: isDark ? Colors.white : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Správa textových šablón a formulácií',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white70 : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Stats
          Consumer<TextTypeProvider>(
            builder: (context, provider, child) {
              return _buildStatChip(
                context: context,
                icon: Icons.text_snippet_rounded,
                label: 'Celkom',
                value: '${provider.textTypes.length}',
                color: Colors.pink,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? color.withOpacity(0.15) : color.withOpacity(0.1);
    final borderColor = isDark ? color.withOpacity(0.4) : color.withOpacity(0.3);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white70 : AppTheme.textLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== ZOZNAM TEXTOV ====================

  Widget _buildTextTypesList(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.darkSurface : AppTheme.white;
    final border = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 1),
      ),
      child: Consumer<TextTypeProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
                  const SizedBox(height: 12),
                  Text(
                    'Chyba pri načítaní',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    provider.error!,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : AppTheme.textLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => provider.loadAll(),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Skúsiť znova'),
                  ),
                ],
              ),
            );
          }

          if (provider.textTypes.isEmpty) {
            return Center(
              child: Text(
                'Žiadne texty',
                style: TextStyle(
                  color: isDark ? Colors.white54 : AppTheme.textLight,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: provider.textTypes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 4),
            itemBuilder: (context, index) {
              final textType = provider.textTypes[index];
              final isSelected = provider.selectedTextType?.id == textType.id;
              return _buildTextTypeItem(context, textType, isSelected);
            },
          );
        },
      ),
    );
  }

  Widget _buildTextTypeItem(BuildContext context, TextType textType, bool isSelected) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final selectedBg = isDark
        ? Colors.pink.withOpacity(0.15)
        : Colors.pink.withOpacity(0.08);
    final hoverBg = isDark
        ? Colors.white.withOpacity(0.05)
        : Colors.grey.withOpacity(0.05);
    final selectedBorder = Colors.pink.withOpacity(0.4);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          context.read<TextTypeProvider>().selectTextType(textType);
        },
        hoverColor: hoverBg,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? selectedBg : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? selectedBorder : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.pink.withOpacity(0.2)
                      : (isDark ? Colors.white.withOpacity(0.08) : Colors.grey.withOpacity(0.1)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(
                    Icons.text_fields_rounded,
                    size: 20,
                    color: isSelected
                        ? Colors.pink
                        : (isDark ? Colors.white54 : AppTheme.textLight),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      textType.type,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: isSelected
                            ? Colors.pink
                            : (isDark ? Colors.white : AppTheme.textDark),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      textType.text.length > 60
                          ? '${textType.text.substring(0, 60)}...'
                          : textType.text,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : AppTheme.textLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.pink.withOpacity(0.6),
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== EMPTY STATE ====================

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.darkSurface : AppTheme.white;
    final border = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor;
    final gradientColors = isDark
        ? [const Color(0xFF3D0028), const Color(0xFF57003D)]
        : [Colors.pink.shade50, Colors.pink.shade100];

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 1),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradientColors),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                Icons.touch_app_rounded,
                size: 60,
                color: Colors.pink.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Vyberte text na úpravu',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: isDark ? Colors.white : null,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kliknite na text zo zoznamu\npre zobrazenie a úpravu',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white70 : null,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== EDIT PANEL ====================

class _TextTypeEditPanel extends StatefulWidget {
  final TextType textType;
  final VoidCallback onCancel;

  const _TextTypeEditPanel({
    Key? key,
    required this.textType,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<_TextTypeEditPanel> createState() => _TextTypeEditPanelState();
}

class _TextTypeEditPanelState extends State<_TextTypeEditPanel> {
  late TextEditingController _textController;
  bool _isSaving = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.textType.text);
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final changed = _textController.text != widget.textType.text;
    if (changed != _hasChanges) {
      setState(() {
        _hasChanges = changed;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (!_hasChanges || _isSaving) return;

    setState(() => _isSaving = true);

    try {
      await context.read<TextTypeProvider>().updateTextType(
        widget.textType.id,
        _textController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Text bol úspešne uložený'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
        setState(() {
          _hasChanges = false;
        });
      }
    } catch (e) {
      await context.showPermissionErrorIfNeeded(e, actionName: "úprava textu");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Chyba: $e'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.darkSurface : AppTheme.white;
    final border = isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor;
    final fieldBg = isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Panel Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: border, width: 1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.pink.withOpacity(isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.edit_rounded,
                    color: Colors.pink.shade400,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Editácia textu',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: isDark ? Colors.white : AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Typ: ${widget.textType.type}',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white60 : AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_hasChanges)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Text(
                      'Neuložené zmeny',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: widget.onCancel,
                  icon: const Icon(Icons.close_rounded, size: 20),
                  tooltip: 'Zavrieť',
                ),
              ],
            ),
          ),

          // Form Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type field (readonly)
                  Text(
                    'Typ textu',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: isDark ? Colors.white70 : AppTheme.textMedium,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: fieldBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: border),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          size: 16,
                          color: isDark ? Colors.white38 : AppTheme.textLight,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.textType.type,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white54 : AppTheme.textMedium,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Text field (editable)
                  Text(
                    'Obsah textu',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: isDark ? Colors.white70 : AppTheme.textMedium,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _textController,
                    maxLines: 12,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white : AppTheme.textDark,
                      height: 1.6,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Zadajte text...',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.white30 : AppTheme.textLight,
                      ),
                      filled: true,
                      fillColor: fieldBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.pink.shade400, width: 2),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Footer with Save button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: border, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: widget.onCancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark ? Colors.white70 : null,
                    side: isDark
                        ? BorderSide(color: Colors.white.withOpacity(0.2))
                        : null,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  ),
                  child: const Text('Zrušiť'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _hasChanges && !_isSaving ? _saveChanges : null,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_rounded, size: 20),
                  label: Text(_isSaving ? 'Ukladám...' : 'Uložiť'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink.shade600,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
