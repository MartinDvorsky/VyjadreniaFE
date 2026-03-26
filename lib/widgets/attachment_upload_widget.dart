import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'dart:io';

class AttachmentUploadWidget extends StatefulWidget {
  final String label;
  final String description;
  final File? file;
  final Function(File?) onFileSelected;

  const AttachmentUploadWidget({
    Key? key,
    required this.label,
    required this.description,
    required this.file,
    required this.onFileSelected,
  }) : super(key: key);

  @override
  State<AttachmentUploadWidget> createState() => _AttachmentUploadWidgetState();
}

class _AttachmentUploadWidgetState extends State<AttachmentUploadWidget> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasFile = widget.file != null;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: _pickFile,
        child: DottedBorder(
          color: hasFile
              ? Colors.green
              : (_isHovering ? Colors.blue : (isDark ? Colors.white38 : Colors.grey)),
          strokeWidth: 2,
          dashPattern: const [8, 4],
          borderType: BorderType.RRect,
          radius: const Radius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: hasFile
                  ? Colors.green.withOpacity(0.05)
                  : (_isHovering
                  ? Colors.blue.withOpacity(0.05)
                  : (isDark ? Colors.white.withOpacity(0.02) : Colors.grey[50])),
              borderRadius: BorderRadius.circular(12),
            ),
            child: hasFile ? _buildFileInfo(isDark) : _buildUploadPrompt(isDark),
          ),
        ),
      ),
    );
  }

  Widget _buildUploadPrompt(bool isDark) {
    return Column(
      children: [
        Icon(
          Icons.cloud_upload_outlined,
          size: 48,
          color: _isHovering ? Colors.blue : (isDark ? Colors.white38 : Colors.grey),
        ),
        const SizedBox(height: 12),
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.description,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white60 : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Klikni alebo pretiahni PDF súbor',
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFileInfo(bool isDark) {
    final fileName = widget.file!.path.split('/').last;
    final fileSize = widget.file!.lengthSync();
    final fileSizeMB = (fileSize / 1024 / 1024).toStringAsFixed(2);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.picture_as_pdf,
            color: Colors.green,
            size: 32,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                fileName,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black,
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
          icon: const Icon(Icons.close, color: Colors.red),
          onPressed: () => widget.onFileSelected(null),
          tooltip: 'Odstrániť',
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.blue),
          onPressed: _pickFile,
          tooltip: 'Zmeniť súbor',
        ),
      ],
    );
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        widget.onFileSelected(File(result.files.single.path!));
      }
    } catch (e) {
      print('❌ File pick error: $e');
    }
  }
}