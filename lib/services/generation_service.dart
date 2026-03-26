// lib/services/generation_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/api_config.dart';
import '../providers/step2_data_provider.dart';
import '../providers/step3_data_provider.dart';
import '../providers/step5_data_provider.dart';
import '../models/generation_progress_event.dart';

class GenerationService {
  static const String baseUrl = ApiConfig.baseUrl;

  // 🔥 Firebase Auth inštancia
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // 🔥 Metóda na získanie autorizačných hlavičiek s Firebase ID tokenom
  static Future<Map<String, String>> _getAuthHeaders() async {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      throw Exception('Nie ste prihlásený. Chýba autorizačný token.');
    }

    try {
      final token = await user.getIdToken();

      if (token == null || token.isEmpty) {
        throw Exception('Nie je možné získať Firebase token.');
      }

      return {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      };
    } catch (e) {
      throw Exception('Chyba pri získavaní tokenu: $e');
    }
  }

  /// Vygeneruj dokumenty
  static Future<GenerateResponse> generateDocuments({
    required List<int> applicationIds,
    required Step2DataProvider step2Data,
    required Step3DataProvider step3Data,
    required List<int> cityIds,
    required Step5DataProvider step5Data,
    String outputFormat = 'docx',
    bool compressToZip = true,
  }) async {
    try {
      // Priprav request body
      final requestBody = {
        'application_ids': applicationIds,
        'city_ids': cityIds,
        'output_format': outputFormat,
        'compress_to_zip': compressToZip,

        // File mappings (custom názvy súborov)
        'file_mappings': applicationIds.map((appId) {
          return {
            'application_id': appId,
            'custom_filename': step5Data.getFilename(
              appId,
              znacka: step2Data.znacka,
            ),
          };
        }).toList(),

        // ✅ Step 2 data s builder objektom
        'step2_data': {
          'znacka': step2Data.znacka,
          'nazov_stavby': step2Data.nazovStavby,
          'miesto_stavby': step2Data.miestoStavby,

          // Builder objekt
          'builder': {
            'name': step2Data.builder.name,
            'obec': step2Data.builder.obec,
            'ulica': step2Data.builder.ulica,
            'cislo_domu': step2Data.builder.cisloDomu,
            'psc': step2Data.builder.psc,
            'ico': step2Data.builder.ico,
            'email': step2Data.builder.email,
            'telefon': step2Data.builder.telefon,
            'typ': step2Data.builder.typ,
            'meno_legal_entity': step2Data.builder.menoLegalEntity,
            'email_legal_entity': step2Data.builder.emailLegalEntity,
            'typ_opravnenia': step2Data.builder.typOpravnenia,
          },
          'is_custom_builder': step2Data.isCustomBuilder,

          // Technické údaje
          'katastralne_uzemie': step2Data.katastralneUzemie,
          'pocet_situacii': step2Data.pocetSituacii,
          'mierka': step2Data.mierka,
          'parcelne_cislo': step2Data.parcelneCislo,
          'list_vlastnictva': step2Data.listVlastnictva,
          'id_stavby': step2Data.idStavby,
          'kod_stavby': step2Data.kodStavby,

          // Vstupné údaje
          'datum_dokumentacie': step2Data.datumDokumentacie?.toIso8601String(),
          'typ_ziadosti': step2Data.typZiadosti,
          'ziadatel': step2Data.ziadatel,
          'subor_stavieb': step2Data.suborStavieb,
          'projektova_dokumentacia': step2Data.projektovaDokumentacia,
          'poplatok': step2Data.poplatok,

          // ✅ Vedúci projektant (s osvedčením)
          'projektant': step2Data.selectedProjektant != null ? {
            'id': step2Data.selectedProjektant!.id,
            'name': step2Data.selectedProjektant!.name,
            'city': step2Data.selectedProjektant!.city,
            'address': step2Data.selectedProjektant!.address,
            'license': step2Data.selectedProjektant!.license,
            'email': step2Data.selectedProjektant!.email,
            'phone': step2Data.selectedProjektant!.phone,
          } : null,

          // ✅ NOVÉ: Člen tímu, ktorý vypracoval projekt
          'team_member': step2Data.selectedTeamMember != null ? {
            'id': step2Data.selectedTeamMember!.id,
            'name': step2Data.selectedTeamMember!.name,
            'email': step2Data.selectedTeamMember!.email,
            'phone': step2Data.selectedTeamMember!.phone,
          } : null,

          // Objekty a prevádzkové súbory
          'objekty_stavby': step2Data.objektyStavby.map((obj) => obj.toJson()).toList(),
          'prevadzkove_subory': step2Data.prevadzkoveSubory.map((set) => set.toJson()).toList(),
        },

        // Step 3 data
        'step3_data': {
          'orhazz': step3Data.orhazz,
          'svp': step3Data.svp,
          'ruvz': step3Data.ruvz,
          'mesto_obec': step3Data.mestoObec,
          'zsr': step3Data.zsr,
          'cesty_i': step3Data.cestyI,
          'cesty_ii': step3Data.cestyII,
          'building_purpose_id': step3Data.selectedBuildingPurpose?.id,

          // ŽSR údaje
          if (step3Data.zsr) ...{
            'zsr_stavba_typ': step3Data.zsrStavbaTyp,
            'zsr_zeleznicna_trat': step3Data.zsrZeleznicnaTrat,
            'zsr_cislo_trate': step3Data.zsrCisloTrate,
            'zsr_ano_nie': step3Data.zsrAnoNie,
            'zsr_zaciatok': step3Data.zsrZaciatok,
            'zsr_koniec': step3Data.zsrKoniec,
            'zsr_vzdialenost1': step3Data.zsrVzdialenost1,
            'zsr_vzdialenost2': step3Data.zsrVzdialenost2,
            'zsr_kilometer': step3Data.zsrKilometer,
            'zsr_stanica1': step3Data.zsrStanica1,
            'zsr_stanica2': step3Data.zsrStanica2,
          },

          // Cesty údaje
          if (step3Data.cestyI) 'cesty_i_typ': step3Data.cestyITyp,
          if (step3Data.cestyII) 'cesty_ii_typ': step3Data.cestyIITyp,
        },
      };

      print('🔍 DEBUG - ŽSR Data v requeste:');
      print('zsr checkbox: ${step3Data.zsr}');
      print('zsrStanica1: "${step3Data.zsrStanica1}"');
      print('zsrStanica2: "${step3Data.zsrStanica2}"');
      print('zsrStavbaTyp: "${step3Data.zsrStavbaTyp}"');
      print('zsrZaciatok: "${step3Data.zsrZaciatok}"');
      print('zsrKoniec: "${step3Data.zsrKoniec}"');
      print('Full step3_data: ${requestBody['step3_data']}');

      print('📤 Sending generation request...');
      print('Applications: ${applicationIds.length}');
      print('City IDs: $cityIds');
      print('Builder: ${step2Data.builder.name}');
      print('✅ Vedúci projektant: ${step2Data.selectedProjektant?.name ?? "nie je vybraný"}');
      print('✅ Člen tímu: ${step2Data.selectedTeamMember?.name ?? "nie je vybraný"}');

      // 🔍 NOVÝ DEBUG: Vypis všetkých úradov s ID a názvami
      print('\n========== ÚRADY NA GENEROVANIE ==========');
      for (int i = 0; i < applicationIds.length; i++) {
        final appId = applicationIds[i];
        final app = step5Data.applications.firstWhere(
          (a) => a.applicationId == appId,
        );
        final filename = step5Data.getFilename(appId, znacka: step2Data.znacka);
        print('${i + 1}. ID: $appId | Názov: ${app?.name ?? "NEZNÁMY"} | Departmán: ${app?.department ?? "?"} | Filename: $filename');
      }
      print('==========================================\n');

      // 🔥 Získaj autentifikačné hlavičky s Firebase tokenom
      final headers = await _getAuthHeaders();


      print('\n🚀 Odosielam request na: $baseUrl/generate\n');

      final response = await http.post(
        Uri.parse('$baseUrl/generate'),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return GenerateResponse.fromJson(data);
      } else {
        throw Exception('Server error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Generation error: $e');
      rethrow;
    }
  }

  /// Priprav generovanie (1. krok pre SSE)
  static Future<PrepareGenerationResponse> prepareGeneration({
    required List<int> applicationIds,
    required Step2DataProvider step2Data,
    required Step3DataProvider step3Data,
    required List<int> cityIds,
    required Step5DataProvider step5Data,
    String outputFormat = 'docx',
    bool compressToZip = true,
  }) async {
    try {
      // Priprav request body (rovnaké ako generateDocuments)
      final requestBody = {
        'application_ids': applicationIds,
        'city_ids': cityIds,
        'output_format': outputFormat,
        'compress_to_zip': compressToZip,
        'file_mappings': applicationIds.map((appId) {
          return {
            'application_id': appId,
            'custom_filename': step5Data.getFilename(
              appId,
              znacka: step2Data.znacka,
            ),
          };
        }).toList(),
        'step2_data': {
          'znacka': step2Data.znacka,
          'nazov_stavby': step2Data.nazovStavby,
          'miesto_stavby': step2Data.miestoStavby,
          'builder': {
            'name': step2Data.builder.name,
            'obec': step2Data.builder.obec,
            'ulica': step2Data.builder.ulica,
            'cislo_domu': step2Data.builder.cisloDomu,
            'psc': step2Data.builder.psc,
            'ico': step2Data.builder.ico,
            'email': step2Data.builder.email,
            'telefon': step2Data.builder.telefon,
            'typ': step2Data.builder.typ,
            'meno_legal_entity': step2Data.builder.menoLegalEntity,
            'email_legal_entity': step2Data.builder.emailLegalEntity,
            'typ_opravnenia': step2Data.builder.typOpravnenia,
          },
          'is_custom_builder': step2Data.isCustomBuilder,
          'katastralne_uzemie': step2Data.katastralneUzemie,
          'pocet_situacii': step2Data.pocetSituacii,
          'mierka': step2Data.mierka,
          'parcelne_cislo': step2Data.parcelneCislo,
          'list_vlastnictva': step2Data.listVlastnictva,
          'id_stavby': step2Data.idStavby,
          'kod_stavby': step2Data.kodStavby,
          'datum_dokumentacie': step2Data.datumDokumentacie?.toIso8601String(),
          'typ_ziadosti': step2Data.typZiadosti,
          'ziadatel': step2Data.ziadatel,
          'subor_stavieb': step2Data.suborStavieb,
          'projektova_dokumentacia': step2Data.projektovaDokumentacia,
          'poplatok': step2Data.poplatok,
          'projektant': step2Data.selectedProjektant != null ? {
            'id': step2Data.selectedProjektant!.id,
            'name': step2Data.selectedProjektant!.name,
            'city': step2Data.selectedProjektant!.city,
            'address': step2Data.selectedProjektant!.address,
            'license': step2Data.selectedProjektant!.license,
            'email': step2Data.selectedProjektant!.email,
            'phone': step2Data.selectedProjektant!.phone,
          } : null,
          'team_member': step2Data.selectedTeamMember != null ? {
            'id': step2Data.selectedTeamMember!.id,
            'name': step2Data.selectedTeamMember!.name,
            'email': step2Data.selectedTeamMember!.email,
            'phone': step2Data.selectedTeamMember!.phone,
          } : null,
          'objekty_stavby': step2Data.objektyStavby.map((obj) => obj.toJson()).toList(),
          'prevadzkove_subory': step2Data.prevadzkoveSubory.map((set) => set.toJson()).toList(),
        },
        'step3_data': {
          'orhazz': step3Data.orhazz,
          'svp': step3Data.svp,
          'ruvz': step3Data.ruvz,
          'mesto_obec': step3Data.mestoObec,
          'zsr': step3Data.zsr,
          'cesty_i': step3Data.cestyI,
          'cesty_ii': step3Data.cestyII,
          'building_purpose_id': step3Data.selectedBuildingPurpose?.id,
          if (step3Data.zsr) ...{
            'zsr_stavba_typ': step3Data.zsrStavbaTyp,
            'zsr_zeleznicna_trat': step3Data.zsrZeleznicnaTrat,
            'zsr_cislo_trate': step3Data.zsrCisloTrate,
            'zsr_ano_nie': step3Data.zsrAnoNie,
            'zsr_zaciatok': step3Data.zsrZaciatok,
            'zsr_koniec': step3Data.zsrKoniec,
            'zsr_vzdialenost1': step3Data.zsrVzdialenost1,
            'zsr_vzdialenost2': step3Data.zsrVzdialenost2,
            'zsr_kilometer': step3Data.zsrKilometer,
            'zsr_stanica1': step3Data.zsrStanica1,
            'zsr_stanica2': step3Data.zsrStanica2,
          },
          if (step3Data.cestyI) 'cesty_i_typ': step3Data.cestyITyp,
          if (step3Data.cestyII) 'cesty_ii_typ': step3Data.cestyIITyp,
        },
      };

      final headers = await _getAuthHeaders();
      
      print('🚀 Odosielam prepare request na: $baseUrl/generate/prepare\n');

      final response = await http.post(
        Uri.parse('$baseUrl/generate/prepare'),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PrepareGenerationResponse.fromJson(data);
      } else {
        throw Exception('Server error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Prepare Generation error: $e');
      rethrow;
    }
  }

  /// Stream SSE udalosti generovania (2. krok)
  static Stream<GenerationProgressEvent> streamGenerationProgress(String taskToken) async* {
    final headers = await _getAuthHeaders();
    final request = http.Request(
      'GET',
      Uri.parse('$baseUrl/generate/stream?token=$taskToken'),
    );
    
    headers.forEach((key, value) {
      request.headers[key] = value;
    });

    final client = http.Client();
    try {
      final streamedResponse = await client.send(request);
      
      await for (final line in streamedResponse.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())) {
        if (line.startsWith('data: ')) {
          final jsonStr = line.substring(6);
          if (jsonStr.trim().isEmpty) continue;
          final json = jsonDecode(jsonStr);
          yield GenerationProgressEvent.fromJson(json);
        }
      }
    } finally {
      client.close();
    }
  }

  /// Validuj request pred generovaním
  static Future<ValidationResponse> validateRequest({
    required List<int> applicationIds,
    required Step2DataProvider step2Data,
    required Step3DataProvider step3Data,
    required List<int> cityIds,
  }) async {
    try {
      final requestBody = {
        'application_ids': applicationIds,
        'city_ids': cityIds,

        'step2_data': {
          'znacka': step2Data.znacka,
          'nazov_stavby': step2Data.nazovStavby,
          'miesto_stavby': step2Data.miestoStavby,

          'builder': {
            'name': step2Data.builder.name,
            'obec': step2Data.builder.obec,
            'ulica': step2Data.builder.ulica,
            'cislo_domu': step2Data.builder.cisloDomu,
            'psc': step2Data.builder.psc,
            'ico': step2Data.builder.ico,
            'email': step2Data.builder.email,
            'telefon': step2Data.builder.telefon,
            'typ': step2Data.builder.typ,
            'meno_legal_entity': step2Data.builder.menoLegalEntity,
            'email_legal_entity': step2Data.builder.emailLegalEntity,
            'typ_opravnenia': step2Data.builder.typOpravnenia,
          },
          'is_custom_builder': step2Data.isCustomBuilder,

          'katastralne_uzemie': step2Data.katastralneUzemie,
          'pocet_situacii': step2Data.pocetSituacii,
          'mierka': step2Data.mierka,
          'parcelne_cislo': step2Data.parcelneCislo,
          'list_vlastnictva': step2Data.listVlastnictva,
          'id_stavby': step2Data.idStavby,
          'kod_stavby': step2Data.kodStavby,
          'datum_dokumentacie': step2Data.datumDokumentacie?.toIso8601String(),
          'projektant_id': step2Data.selectedProjektant?.id,
          'projektant_name': step2Data.selectedProjektant?.name,

          // ✅ NOVÉ: Team member v validácii
          'team_member_id': step2Data.selectedTeamMember?.id,
          'team_member_name': step2Data.selectedTeamMember?.name,

          'typ_ziadosti': step2Data.typZiadosti,
          'ziadatel': step2Data.ziadatel,
          'subor_stavieb': step2Data.suborStavieb,
          'projektova_dokumentacia': step2Data.projektovaDokumentacia,
          'poplatok': step2Data.poplatok,
          'objekty_stavby': [],
          'prevadzkove_subory': [],
        },

        'step3_data': {
          'orhazz': step3Data.orhazz,
          'svp': step3Data.svp,
          'ruvz': step3Data.ruvz,
          'mesto_obec': step3Data.mestoObec,
          'zsr': step3Data.zsr,
          'cesty_i': step3Data.cestyI,
          'cesty_ii': step3Data.cestyII,
          'building_purpose_id': step3Data.selectedBuildingPurpose?.id,
        },
      };

      // 🔥 Získaj autentifikačné hlavičky s Firebase tokenom
      final headers = await _getAuthHeaders();

      final response = await http.post(
        Uri.parse('$baseUrl/generate/validate'),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ValidationResponse.fromJson(data);
      } else {
        throw Exception('Validation failed: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Validation error: $e');
      rethrow;
    }
  }

  /// Stiahni vygenerovaný ZIP súbor
  static Future<String?> downloadFile(String downloadUrl) async {
    try {
      print('📥 Downloading from: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('❌ Download error: $e');
      rethrow;
    }
  }
}


// ========================================
// RESPONSE MODELS
// ========================================

class PrepareGenerationResponse {
  final String taskToken;
  final int totalDocuments;

  PrepareGenerationResponse({
    required this.taskToken,
    required this.totalDocuments,
  });

  factory PrepareGenerationResponse.fromJson(Map<String, dynamic> json) {
    return PrepareGenerationResponse(
      taskToken: json['task_token'],
      totalDocuments: json['total_documents'] ?? 0,
    );
  }
}

class GenerateResponse {
  final bool success;
  final bool partialSuccess;
  final String message;
  final int totalDocuments;
  final List<String> generatedFiles;
  final List<String> failedFiles;
  final String? downloadUrl;

  GenerateResponse({
    required this.success,
    required this.partialSuccess,
    required this.message,
    required this.totalDocuments,
    required this.generatedFiles,
    required this.failedFiles,
    this.downloadUrl,
  });

  factory GenerateResponse.fromJson(Map<String, dynamic> json) {
    return GenerateResponse(
      success: json['success'] ?? false,
      partialSuccess: json['partial_success'] ?? false,
      message: json['message'] ?? '',
      totalDocuments: json['total_documents'] ?? 0,
      generatedFiles: List<String>.from(json['generated_files'] ?? []),
      failedFiles: List<String>.from(json['failed_files'] ?? []),
      downloadUrl: json['download_url'],
    );
  }
}

class ValidationResponse {
  final bool valid;
  final List<String> errors;
  final List<String> warnings;
  final int totalApplications;
  final String? cityName;

  ValidationResponse({
    required this.valid,
    required this.errors,
    required this.warnings,
    required this.totalApplications,
    this.cityName,
  });

  factory ValidationResponse.fromJson(Map<String, dynamic> json) {
    return ValidationResponse(
      valid: json['valid'] ?? false,
      errors: List<String>.from(json['errors'] ?? []),
      warnings: List<String>.from(json['warnings'] ?? []),
      totalApplications: json['total_applications'] ?? 0,
      cityName: json['city_name'],
    );
  }
}