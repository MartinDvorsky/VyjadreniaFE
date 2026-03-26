// lib/services/xml_generator_service.dart

import '../models/application_model.dart';
import '../providers/step2_data_provider.dart';
import '../providers/step3_data_provider.dart';
import '../models/city_model.dart';

class XmlGeneratorService {
  /// Vygeneruje validný XML formulár App.GeneralAgenda pre slovensko.sk
  /// podľa XSD schémy http://schemas.gov.sk/form/App.GeneralAgenda/1.9
  static String generateGeneralAgendaXml({
    required Application application,
    required City city,
    required Step2DataProvider step2,
    required Step3DataProvider step3,
  }) {
    final now = DateTime.now();
    final formattedDate = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final formattedDateTime = now.toIso8601String();

    // Generuj obsah vyjadrenia
    final statementText = _generateStatementText(application, step2, step3, city);

    return '''<?xml version="1.0" encoding="UTF-8"?>
<GeneralAgenda xmlns="http://schemas.gov.sk/form/App.GeneralAgenda/1.9" 
               xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <Meta>
    <ID>App.GeneralAgenda</ID>
    <Name>Všeobecná agenda</Name>
    <Version>1.9</Version>
    <ZepRequired>false</ZepRequired>
    <EformUseXHTML>false</EformUseXHTML>
  </Meta>
  
  <Body>
    <Subject>Vyjadrenie k žiadosti: ${_escapeXml(step2.nazovStavby)}</Subject>
    
    <Sender>
      <BusinessEntity>
        <Name>${_escapeXml(step2.builder.name)}</Name>
        <ICO>${step2.builder.ico ?? ''}</ICO>
        <FormattedAddress>
          <Street>${_escapeXml(step2.builder.ulica)}</Street>
          <BuildingNumber>${step2.builder.cisloDomu ?? ''}</BuildingNumber>
          <City>${_escapeXml(step2.builder.obec)}</City>
          <ZipCode>${step2.builder.psc ?? ''}</ZipCode>
        </FormattedAddress>
      </BusinessEntity>
    </Sender>
    
    <Recipient>
      <Name>${_escapeXml(application.name)}</Name>
      <ICO>${application.senderIco ?? ''}</ICO>
      <FormattedAddress>
        <Street>${_escapeXml(application.streetAddress)}</Street>
        <City>${_escapeXml(application.city)}</City>
        <ZipCode>${application.postalCode ?? ''}</ZipCode>
      </FormattedAddress>
    </Recipient>
    
    <MessageContent>
      <Subject>Vyjadrenie k stavbe: ${_escapeXml(step2.znacka)}</Subject>
      <Text>$statementText</Text>
      <CreatedAt>$formattedDateTime</CreatedAt>
    </MessageContent>
    
    <BuildingInfo>
      <BuildingName>${_escapeXml(step2.nazovStavby)}</BuildingName>
      <BuildingLocation>${_escapeXml(step2.miestoStavby)}</BuildingLocation>
      <CadastralArea>${_escapeXml(step2.katastralneUzemie ?? city.name)}</CadastralArea>
      <ParcelNumber>${_escapeXml(step2.parcelneCislo ?? '')}</ParcelNumber>
    </BuildingInfo>
    
    <Attachments>
      ${_generateAttachmentReferences(application)}
    </Attachments>
    
    <AdditionalInfo>
      <Note>Generované automaticky systémom Vyjadrenia</Note>
      <GeneratedAt>$formattedDateTime</GeneratedAt>
    </AdditionalInfo>
  </Body>
</GeneralAgenda>''';
  }

  /// Escapuje špeciálne XML znaky
  static String _escapeXml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

  /// Generuje odkazy na prílohy
  static String _generateAttachmentReferences(Application app) {
    final attachments = <String>[];

    if (app.technicalSituation) {
      attachments.add('<Attachment><Type>TECHNICAL_SITUATION</Type><Name>Technická situácia</Name></Attachment>');
    }
    if (app.situation) {
      attachments.add('<Attachment><Type>SITUATION</Type><Name>Situácia</Name></Attachment>');
    }
    if (app.situationA3) {
      attachments.add('<Attachment><Type>SITUATION_A3</Type><Name>Situácia A3</Name></Attachment>');
    }
    if (app.broaderRelations) {
      attachments.add('<Attachment><Type>BROADER_RELATIONS</Type><Name>Širšie vzťahy</Name></Attachment>');
    }
    if (app.fireProtection) {
      attachments.add('<Attachment><Type>FIRE_PROTECTION</Type><Name>Požiarna ochrana</Name></Attachment>');
    }
    if (app.waterManagement) {
      attachments.add('<Attachment><Type>WATER_MANAGEMENT</Type><Name>Vodné hospodárstvo</Name></Attachment>');
    }
    if (app.publicHealth) {
      attachments.add('<Attachment><Type>PUBLIC_HEALTH</Type><Name>Verejné zdravie</Name></Attachment>');
    }
    if (app.railways) {
      attachments.add('<Attachment><Type>RAILWAYS</Type><Name>Železnice</Name></Attachment>');
    }
    if (app.roads1) {
      attachments.add('<Attachment><Type>ROADS_1</Type><Name>Cesty I. triedy</Name></Attachment>');
    }
    if (app.roads2) {
      attachments.add('<Attachment><Type>ROADS_2</Type><Name>Cesty II. triedy</Name></Attachment>');
    }
    if (app.municipality) {
      attachments.add('<Attachment><Type>MUNICIPALITY</Type><Name>Obec/Mesto</Name></Attachment>');
    }

    return attachments.join('\n      ');
  }

  /// Generuje textový obsah vyjadrenia
  static String _generateStatementText(
      Application app,
      Step2DataProvider step2,
      Step3DataProvider step3,
      City city,
      ) {
    StringBuffer buffer = StringBuffer();

    // Úvodná časť
    buffer.writeln('VYJADRENIE K ŽIADOSTI');
    buffer.writeln('');
    buffer.writeln('Označenie stavby: ${step2.znacka}');
    buffer.writeln('Názov stavby: ${step2.nazovStavby}');
    buffer.writeln('Miesto stavby: ${step2.miestoStavby}');
    buffer.writeln('Katastrálne územie: ${step2.katastralneUzemie ?? city.name}');
    buffer.writeln('');

    // Špecifické informácie podľa typu úradu
    if (app.railways && step3.zsr) {
      buffer.writeln('═══════════════════════════════════════');
      buffer.writeln('K STAVBE V OCHRANNOM PÁSME ŽELEZNICE');
      buffer.writeln('═══════════════════════════════════════');
      buffer.writeln('');
      buffer.writeln('Typ stavby: ${step3.zsrStavbaTyp}');

      if (step3.zsrStavbaTyp == 'Stavba zasahuje do ochranného pásma') {
        buffer.writeln('Železničná trať: ${step3.zsrZeleznicnaTrat ?? 'neuvedené'}');
        buffer.writeln('Úsek medzi: ${step3.zsrZaciatok} - ${step3.zsrKoniec}');
        buffer.writeln('Vzdialenosť od osi krajnej koľaje: ${step3.zsrVzdialenost1} m');
        if (step3.zsrVzdialenost2?.isNotEmpty ?? false) {
          buffer.writeln('Vzdialenosť 2: ${step3.zsrVzdialenost2} m');
        }
      } else if (step3.zsrStavbaTyp == 'Stavba križuje') {
        buffer.writeln('Kilometer: ${step3.zsrKilometer}');
        buffer.writeln('Medzi stanicami: ${step3.zsrStanica1} - ${step3.zsrStanica2}');
      }

      if (step3.zsrAnoNie) {
        buffer.writeln('Trať: Elektrifikovaná');
      } else {
        buffer.writeln('Trať: Neelektrifikovaná');
      }
      buffer.writeln('');
      buffer.writeln('Vyjadrenie: Súhlasíme s navrhovanou stavbou za podmienok uvedených v prílohe.');
      buffer.writeln('');
    }

    if (app.fireProtection && step3.orhazz) {
      buffer.writeln('═══════════════════════════════════════');
      buffer.writeln('K POŽIARNEJ OCHRANE');
      buffer.writeln('═══════════════════════════════════════');
      buffer.writeln('');
      buffer.writeln('Vyjadrujeme sa súhlasne s navrhovanou stavbou.');
      buffer.writeln('Podmienky sú uvedené v prílohe.');
      buffer.writeln('');
    }

    if (app.waterManagement && step3.svp) {
      buffer.writeln('═══════════════════════════════════════');
      buffer.writeln('K VODNÉMU HOSPODÁRSTVU');
      buffer.writeln('═══════════════════════════════════════');
      buffer.writeln('');
      buffer.writeln('Stavba je v súlade s podmienkami vodného hospodárstva.');
      buffer.writeln('Bližšie informácie sú uvedené v prílohe.');
      buffer.writeln('');
    }

    if (app.publicHealth && step3.ruvz) {
      buffer.writeln('═══════════════════════════════════════');
      buffer.writeln('Z HĽADISKA VEREJNÉHO ZDRAVIA');
      buffer.writeln('═══════════════════════════════════════');
      buffer.writeln('');
      buffer.writeln('K stavbe nemáme námietky z hľadiska ochrany verejného zdravia.');
      buffer.writeln('');
    }

    if ((app.roads1 || app.roads2) && (step3.cestyI || step3.cestyII)) {
      buffer.writeln('═══════════════════════════════════════');
      buffer.writeln('K VPLYVU NA CESTNÉ KOMUNIKÁCIE');
      buffer.writeln('═══════════════════════════════════════');
      buffer.writeln('');
      if (step3.cestyI) {
        buffer.writeln('Cesty I. triedy: ${step3.cestyITyp}');
      }
      if (step3.cestyII) {
        buffer.writeln('Cesty II. triedy: ${step3.cestyIITyp}');
      }
      buffer.writeln('');
      buffer.writeln('Podrobnosti sú uvedené v priložených výkresoch.');
      buffer.writeln('');
    }

    if (app.municipality && step3.mestoObec) {
      buffer.writeln('═══════════════════════════════════════');
      buffer.writeln('STANOVISKO OBCE/MESTA');
      buffer.writeln('═══════════════════════════════════════');
      buffer.writeln('');
      buffer.writeln('Stavba je v súlade s územným plánom obce/mesta.');
      buffer.writeln('');
    }

    // Závere čná časť
    buffer.writeln('═══════════════════════════════════════');
    buffer.writeln('ZÁVER');
    buffer.writeln('═══════════════════════════════════════');
    buffer.writeln('');
    buffer.writeln('Toto vyjadrenie je platné 2 roky od dátumu vystavenia.');
    buffer.writeln('');
    buffer.writeln('Stavebník:');
    buffer.writeln('${step2.builder.name}');
    buffer.writeln('${step2.builder.ulica} ${step2.builder.cisloDomu}');
    buffer.writeln('${step2.builder.psc} ${step2.builder.obec}');
    if (step2.builder.ico?.isNotEmpty ?? false) {
      buffer.writeln('IČO: ${step2.builder.ico}');
    }

    return _escapeXml(buffer.toString());
  }
}