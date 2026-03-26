// lib/models/ai_extraction_models.dart

class AIExtractionResponse {
  final bool success;
  final ExtractedProjectData? data;
  final String? error;
  final ExtractionMetrics? metrics;
  final Map<String, String> fieldWarnings;


  AIExtractionResponse({
    required this.success,
    this.data,
    this.error,
    this.metrics,
    this.fieldWarnings = const {},
  });

  factory AIExtractionResponse.fromJson(Map<String, dynamic> json) {
    return AIExtractionResponse(
      success: json['success'] ?? false,
      data: json['data'] != null
          ? ExtractedProjectData.fromJson(json['data'])
          : null,
      error: json['error'],
      metrics: json['metrics'] != null
          ? ExtractionMetrics.fromJson(json['metrics'])
          : null,
      fieldWarnings: json['field_warnings'] != null  // pridať
          ? Map<String, String>.from(json['field_warnings'])
          : {},
    );
  }
}

class ExtractedProjectData {
  final String nazovStavby;
  final String? nazovStavbyVsd;
  final List<ProjectObject> objects;
  final List<ProjectObject> prevadzkoveSubory;
  final String? miestoStavby;
  final String? katastralneUzemie;
  final String? okres;
  final InvestorData investor;
  final DesignerData zodpovednyProjektant;
  final String? cisloZakazky;
  final String? datum;

  ExtractedProjectData({
    required this.nazovStavby,
    this.nazovStavbyVsd,
    required this.objects,
    required this.prevadzkoveSubory,
    this.miestoStavby,
    this.katastralneUzemie,
    this.okres,
    required this.investor,
    required this.zodpovednyProjektant,
    this.cisloZakazky,
    this.datum,
  });

  factory ExtractedProjectData.fromJson(Map<String, dynamic> json) {
    return ExtractedProjectData(
      nazovStavby: json['nazov_stavby'] ?? '',
      nazovStavbyVsd: json['nazov_stavby_vsd'],
      objects: (json['objects'] as List?)
          ?.map((e) => ProjectObject.fromJson(e))
          .toList() ?? [],
      prevadzkoveSubory: (json['prevadzkove_subory'] as List?)
          ?.map((e) => ProjectObject.fromJson(e))
          .toList() ?? [],
      miestoStavby: json['miesto_stavby'],
      katastralneUzemie: json['katastralne_uzemie'],
      okres: json['okres'],
      investor: InvestorData.fromJson(json['investor']),
      zodpovednyProjektant: DesignerData.fromJson(json['zodpovedny_projektant']),
      cisloZakazky: json['cislo_zakazky'],
      datum: json['datum'],
    );
  }
}

class ProjectObject {
  final String type;
  final String? code;
  final String name;

  ProjectObject({
    required this.type,
    this.code,
    required this.name,
  });

  factory ProjectObject.fromJson(Map<String, dynamic> json) {
    return ProjectObject(
      type: json['type'] ?? 'Objekt',
      code: json['code'],
      name: json['name'] ?? '',
    );
  }
}

class InvestorData {
  final bool isVsd;
  final String name;
  final String? obec;
  final String? ulica;
  final String? cisloDomu;
  final String? psc;
  final String? ico;
  final String? email;
  final String? telefon;
  final String typ;
  final String? menoLegalEntity;
  final String? emailLegalEntity;
  final String? typOpravnenia;

  InvestorData({
    required this.isVsd,
    required this.name,
    this.obec,
    this.ulica,
    this.cisloDomu,
    this.psc,
    this.ico,
    this.email,
    this.telefon,
    required this.typ,
    this.menoLegalEntity,
    this.emailLegalEntity,
    this.typOpravnenia,
  });

  factory InvestorData.fromJson(Map<String, dynamic> json) {
    return InvestorData(
      isVsd: json['is_vsd'] ?? false,
      name: json['name'] ?? '',
      obec: json['obec'],
      ulica: json['ulica'],
      cisloDomu: json['cislo_domu'],
      psc: json['psc'],
      ico: json['ico'],
      email: json['email'],
      telefon: json['telefon'],
      typ: json['typ'] ?? 'Právnická osoba',
      menoLegalEntity: json['meno_legal_entity'],
      emailLegalEntity: json['email_legal_entity'],
      typOpravnenia: json['typ_opravnenia'],
    );
  }
}

class DesignerData {
  final String fullName;
  final String? certificateNumber;

  DesignerData({
    required this.fullName,
    this.certificateNumber,
  });

  factory DesignerData.fromJson(Map<String, dynamic> json) {
    return DesignerData(
      fullName: json['full_name'] ?? '',
      certificateNumber: json['certificate_number'],
    );
  }
}

class ExtractionMetrics {
  final double processingTimeSeconds;
  final int? tokensUsed;
  final double? estimatedCostUsd;
  final String modelUsed;
  final DateTime timestamp;

  ExtractionMetrics({
    required this.processingTimeSeconds,
    this.tokensUsed,
    this.estimatedCostUsd,
    required this.modelUsed,
    required this.timestamp,
  });

  factory ExtractionMetrics.fromJson(Map<String, dynamic> json) {
    return ExtractionMetrics(
      processingTimeSeconds: (json['processing_time_seconds'] ?? 0.0).toDouble(),
      tokensUsed: json['tokens_used'],
      estimatedCostUsd: json['estimated_cost_usd']?.toDouble(),
      modelUsed: json['model_used'] ?? 'unknown',
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}