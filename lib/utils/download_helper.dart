import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/api_config.dart';

class DownloadHelper {
  /// Stiahni ZIP súbor z backendu
  static Future<String?> downloadZipFile(String downloadUrl) async {
    try {
      print('📥 Začínam sťahovanie: $downloadUrl');

      // Pre web použijeme iný prístup
      if (kIsWeb) {
        return await _downloadForWeb(downloadUrl);
      }

      // Pre desktop/mobile
      return await _downloadForDesktop(downloadUrl);

    } catch (e) {
      print('❌ Chyba pri sťahovaní: $e');
      rethrow;
    }
  }

  /// Sťahovanie pre web platform
  static Future<String?> _downloadForWeb(String downloadUrl) async {
    // ✅ OPRAVENÉ: Odstránenie duplicitného /api/v1/
    String fullUrl = downloadUrl;
    if (!downloadUrl.startsWith('http')) {
      // Ak downloadUrl začína s /api/v1/, použijeme len baseUrl bez /api/v1/
      if (downloadUrl.startsWith('/api/v1/')) {
        // ApiConfig.baseUrl už obsahuje /api/v1/, tak ho odstránime z downloadUrl
        fullUrl = '${ApiConfig.baseUrl.replaceAll('/api/v1', '')}$downloadUrl';
      } else {
        fullUrl = '${ApiConfig.baseUrl}$downloadUrl';
      }
    }

    print('🌐 Web download URL: $fullUrl');

    final uri = Uri.parse(fullUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Nie je možné otvoriť sťahovací link: $fullUrl');
    }

    return fullUrl;
  }

  /// Sťahovanie pre desktop/mobile
  static Future<String?> _downloadForDesktop(String downloadUrl) async {
    // 1. Vyber miesto kam uložiť
    String? outputPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Uložiť ZIP súbor',
      fileName: 'dokumenty.zip',
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );

    if (outputPath == null) {
      print('⚠️ Používateľ zrušil sťahovanie');
      return null;
    }

    // 2. Zostav správnu URL
    String fullUrl = downloadUrl;
    if (!downloadUrl.startsWith('http')) {
      // ✅ OPRAVENÉ: Kontrola duplicitného /api/v1/
      if (downloadUrl.startsWith('/api/v1/')) {
        // ApiConfig.baseUrl už obsahuje /api/v1/
        final baseWithoutApi = ApiConfig.baseUrl.replaceAll('/api/v1', '');
        fullUrl = '$baseWithoutApi$downloadUrl';
      } else {
        fullUrl = '${ApiConfig.baseUrl}$downloadUrl';
      }
    }

    print('📡 Sťahujem z: $fullUrl');

    // 3. Stiahni súbor z backendu
    final response = await http.get(Uri.parse(fullUrl));

    if (response.statusCode != 200) {
      throw Exception('Chyba pri sťahovaní: ${response.statusCode}\nURL: $fullUrl');
    }

    // 4. Ulož súbor
    final file = File(outputPath);
    await file.writeAsBytes(response.bodyBytes);

    print('✅ Súbor uložený: $outputPath');
    return outputPath;
  }

  /// Alternatívna metóda - stiahni do Downloads priečinka
  static Future<String?> downloadToDownloadsFolder(String downloadUrl) async {
    try {
      Directory? downloadsDir;
      
      if (!kIsWeb) {
        if (Platform.isAndroid || Platform.isIOS) {
          downloadsDir = await getApplicationDocumentsDirectory();
        } else {
          downloadsDir = await getDownloadsDirectory();
        }
      }
      
      if (downloadsDir == null) {
        throw Exception('Nepodarilo sa nájsť priečinok pre sťahovanie (na webe použite štandardné sťahovanie)');
      }

      // Vytvor názov súboru s timestampom
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final outputPath = '${downloadsDir.path}/dokumenty_$timestamp.zip';

      // Zostav správnu URL
      String fullUrl = downloadUrl;
      if (!downloadUrl.startsWith('http')) {
        if (downloadUrl.startsWith('/api/v1/')) {
          final baseWithoutApi = ApiConfig.baseUrl.replaceAll('/api/v1', '');
          fullUrl = '$baseWithoutApi$downloadUrl';
        } else {
          fullUrl = '${ApiConfig.baseUrl}$downloadUrl';
        }
      }

      // Stiahni súbor
      final response = await http.get(Uri.parse(fullUrl));

      if (response.statusCode != 200) {
        throw Exception('Chyba pri sťahovaní: ${response.statusCode}');
      }

      // Ulož súbor
      final file = File(outputPath);
      await file.writeAsBytes(response.bodyBytes);

      print('✅ Súbor uložený: $outputPath');
      return outputPath;

    } catch (e) {
      print('❌ Chyba: $e');
      rethrow;
    }
  }

  static Future<void> openFileLocation(String filePath) async {
    if (kIsWeb) return;
    
    try {
      if (Platform.isWindows) {
        // Windows: explorer /select,"cesta"
        await Process.run('explorer', ['/select,', filePath]);
      } else if (Platform.isMacOS) {
        // macOS: open -R cesta
        await Process.run('open', ['-R', filePath]);
      } else if (Platform.isLinux) {
        // Linux: xdg-open priečinok
        final directory = File(filePath).parent.path;
        await Process.run('xdg-open', [directory]);
      }
    } catch (e) {
      print('❌ Chyba pri otváraní priečinka: $e');
      // Nehodíme výnimku, len logujeme
    }
  }
}

