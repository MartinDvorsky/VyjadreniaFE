// lib/widgets/warning_text_field.dart

import 'package:flutter/material.dart';

class WarningTextField extends StatelessWidget {
  final String label;
  final String? value;
  final String? warningMessage;
  final ValueChanged<String>? onChanged;

  const WarningTextField({
    super.key,
    required this.label,
    this.value,
    this.warningMessage,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasWarning = warningMessage != null && warningMessage!.isNotEmpty;

    return Tooltip(
      message: hasWarning ? warningMessage! : '',
      child: TextFormField(
        initialValue: value ?? '',
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: hasWarning ? Colors.orange : null,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: hasWarning ? Colors.orange : Colors.grey,
              width: hasWarning ? 2.0 : 1.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: hasWarning ? Colors.orange : Theme.of(context).primaryColor,
              width: 2.0,
            ),
          ),
          suffixIcon: hasWarning
              ? const Tooltip(
            message: '',
            child: Icon(Icons.warning_amber_rounded, color: Colors.orange),
          )
              : null,
        ),
      ),
    );
  }
}