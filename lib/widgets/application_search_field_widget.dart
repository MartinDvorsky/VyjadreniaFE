import 'dart:async';
import 'package:flutter/material.dart';
import '../models/application_edit_model.dart';
import '../services/application_edit_service.dart';
import '../utils/app_theme.dart';

class ApplicationSearchField extends StatefulWidget {
  final Function(ApplicationEdit) onApplicationSelected;
  final ApplicationEdit? initialValue;

  const ApplicationSearchField({
    Key? key,
    required this.onApplicationSelected,
    this.initialValue,
  }) : super(key: key);

  @override
  State<ApplicationSearchField> createState() => _ApplicationSearchFieldState();
}

class _ApplicationSearchFieldState extends State<ApplicationSearchField> {
  final TextEditingController _controller = TextEditingController();
  final ApplicationEditService _service = ApplicationEditService();
  final LayerLink _layerLink = LayerLink();

  List<ApplicationEdit> _suggestions = [];
  bool _isLoading = false;
  bool _showSuggestions = false;
  Timer? _debounce;
  OverlayEntry? _overlayEntry;
  ApplicationEdit? _selectedApplication;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _selectedApplication = widget.initialValue;
      _controller.text = widget.initialValue!.name;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      _removeOverlay();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchApplications(query);
    });
  }

  Future<void> _searchApplications(String query) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await _service.searchApplications(name: query);

      if (mounted) {
        setState(() {
          _suggestions = results;
          _showSuggestions = results.isNotEmpty;
          _isLoading = false;
        });

        if (results.isNotEmpty) {
          _showOverlay();
        } else {
          _removeOverlay();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _showSuggestions = false;
        });
        _removeOverlay();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Chyba pri vyhľadávaní: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showOverlay() {
    _removeOverlay();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: _getTextFieldWidth(),
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, 60),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            child: _buildSuggestionsList(),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  double _getTextFieldWidth() {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    return renderBox?.size.width ?? 300;
  }

  void _selectApplication(ApplicationEdit application) {
    setState(() {
      _selectedApplication = application;
      _controller.text = application.name;
      _showSuggestions = false;
    });
    _removeOverlay();
    widget.onApplicationSelected(application);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CompositedTransformTarget(
      link: _layerLink,
      child: TextFormField(
        controller: _controller,
        decoration: InputDecoration(
          labelText: 'Vyhľadať úrad *',
          hintText: 'Začnite písať názov úradu...',
          prefixIcon: const Icon(Icons.business, size: 20),
          suffixIcon: _isLoading
              ? const Padding(
            padding: EdgeInsets.all(12),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
              : _selectedApplication != null
              ? IconButton(
            icon: const Icon(Icons.clear, size: 20),
            onPressed: () {
              setState(() {
                _controller.clear();
                _selectedApplication = null;
                _suggestions = [];
              });
              _removeOverlay();
            },
          )
              : null,
          helperText: _selectedApplication != null
              ? 'Vybraté: ${_selectedApplication!.name} (ID: ${_selectedApplication!.id})'
              : null,
        ),
        onChanged: _onSearchChanged,
        validator: (value) {
          if (_selectedApplication == null) {
            return 'Musíte vybrať úrad zo zoznamu';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildSuggestionsList() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.darkCard : Colors.white;

    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderColor,
        ),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.all(8),
        shrinkWrap: true,
        itemCount: _suggestions.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: isDark ? Colors.white10 : Colors.grey[200],
        ),
        itemBuilder: (context, index) {
          final app = _suggestions[index];
          return InkWell(
            onTap: () => _selectApplication(app),
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.business,
                      size: 20,
                      color: Colors.teal,
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
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : AppTheme.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.category_outlined,
                              size: 12,
                              color: AppTheme.textLight,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                app.department,
                                style: Theme.of(context).textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'ID: ${app.id}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textLight,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}