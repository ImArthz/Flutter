import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metadex/main.dart';
import 'package:metadex/domain/models/deck.dart';
import 'package:metadex/domain/models/player.dart';
import 'package:metadex/domain/models/tournament.dart';
import 'package:metadex/domain/services/deck_validator.dart';
import 'package:metadex/domain/services/archetype_classifier.dart';
import 'package:metadex/domain/services/tom_tdf_parser.dart';
import 'package:metadex/domain/services/analytics_engine.dart';
import 'package:metadex/data/services/pdf_export_service.dart';
import 'package:metadex/ui/viewmodels/tournament_editor_viewmodel.dart';

void main() {
  group('Fase 4 & 6 - Parser PTCG Live, Carta Canônica e Validador de Legalidade (Standard H-I-J & Expanded)', () {
    test('Agrupa reimpressões na mesma Carta Canônica e detecta violação de 5 cópias (US-06 / RN-02)', () {
      const deckText = '''Pokémon: 4
4 Charmander OBF 26

Trainer: 5
3 Ultra Ball SVI 196
2 Ultra Ball PAF 91

Energy: 51
51 Basic Fire Energy SVE 2''';

      final deck = PtcgLiveParser.parse(deckText);
      expect(deck.totalCards, equals(60));
      expect(deck.copiesOfCanonical('Ultra Ball'), equals(5));

      final validator = ValidadorDeDecklist();
      final result = validator.validar(deck, Formato.standardAtual());

      expect(result.isValida, isFalse);
      expect(result.violacoes.any((v) => v.codigo == 'QUATRO_COPIAS'), isTrue);
    });

    test('Valida rotação Standard (H-I-J): carta G pura reprova no Standard H-I-J mas aprova no Expanded', () {
      const gOnlyDeck = '''Pokémon: 4
4 Gardevoir ex SVI 86

Trainer: 4
4 Buddy-Buddy Poffin TEF 144

Energy: 52
52 Basic Psychic Energy SVE 5''';

      final deck = PtcgLiveParser.parse(gOnlyDeck);
      final validator = ValidadorDeDecklist();

      final stdHijResult = validator.validar(deck, Formato.standardAtual());
      expect(Formato.standardAtual().marcasPermitidas, equals({'H', 'I', 'J'}));
      expect(stdHijResult.isValida, isFalse);
      expect(stdHijResult.violacoes.any((v) => v.codigo == 'FORA_DO_FORMATO'), isTrue);

      final expandedResult = validator.validar(deck, Formato.expanded());
      expect(expandedResult.isValida, isTrue);
    });

    test('Detecta múltiplas ACE SPECs, múltiplos Radiantes e carta rotacionada (Marca F)', () {
      const illegalDeck = '''Pokémon: 6
4 Charmander OBF 26
1 Radiant Charizard CRZ 20
1 Radiant Greninja ASR 46

Trainer: 2
1 Prime Catcher TEF 157
1 Unfair Stamp TWM 165

Energy: 50
50 Basic Fire Energy SVE 2''';

      final deck = PtcgLiveParser.parse(illegalDeck);
      final validator = ValidadorDeDecklist();
      final result = validator.validar(deck, Formato.standardAtual());

      expect(result.isValida, isFalse);
      expect(result.violacoes.any((v) => v.codigo == 'SESSENTA_CARTAS'), isTrue);
      expect(result.violacoes.any((v) => v.codigo == 'ACE_SPEC_UNICA'), isTrue);
      expect(result.violacoes.any((v) => v.codigo == 'RADIANTE_UNICO'), isTrue);
      expect(result.violacoes.any((v) => v.codigo == 'FORA_DO_FORMATO'), isTrue);
    });

    test('Gera sugestão por distância de Levenshtein para linha com erro de digitação', () {
      final suggestion = PtcgLiveParser.suggestClosestCard('Ultra Bal');
      expect(suggestion, isNotNull);
      expect(suggestion!.toLowerCase(), contains('ultra ball'));
    });
  });

  group('Fase 6.4 - Classificador Híbrido de Arquétipos (Assinatura + Jaccard)', () {
    test('Classifica Charizard ex / Pidgeot ex por assinatura com alta confiança', () {
      const zardText = '''Pokémon: 10
3 Charizard ex OBF 125
4 Charmander OBF 26
2 Pidgeot ex OBF 164
1 Pidgey OBF 162

Trainer: 12
4 Rare Candy SVI 191
4 Ultra Ball SVI 196
4 Buddy-Buddy Poffin TEF 144

Energy: 38
38 Basic Fire Energy SVE 2''';

      final deck = PtcgLiveParser.parse(zardText);
      final classifier = ClassificadorComposto();
      final res = classifier.classificar(deck);

      expect(res.arquetipo.nome, equals('Charizard ex / Pidgeot ex'));
      expect(res.requerCuradoria, isFalse);
      expect(res.confianca, greaterThanOrEqualTo(0.75));
    });

    test('Envia deck desconhecido/rogue para a Fila de Curadoria Humana (confiança < 0.55)', () {
      const rogueText = '''Pokémon: 4
4 Pikachu SVI 60

Energy: 56
56 Basic Psychic Energy SVE 5''';

      final deck = PtcgLiveParser.parse(rogueText);
      final classifier = ClassificadorComposto();
      final res = classifier.classificar(deck);

      expect(res.requerCuradoria, isTrue);
      expect(res.confianca, lessThan(0.55));
    });
  });

  group('Fase 6.1 & 8.2 - Parser TOM .TDF, Segurança XXE, Idempotência e LGPD', () {
    test('Extrai jogadores, rodadas, OWP/OOWP e aplica proteção LGPD para menor (RN-05 / ADR-006)', () {
      final sampleXml = TomTdfParser.gerarSampleTdfXml();
      final result = TomTdfParser.parseTdfXml(sampleXml, referenceDate: DateTime(2026, 10, 18));

      expect(result.players.length, equals(8));
      expect(result.matches.length, equals(16));
      expect(result.birthdatesDiscardedInMemory, isTrue);

      // Marina nasceu em 2011 -> Senior -> Nome público abreviado "Marina S." (RN-05)
      final marina = result.players.firstWhere((p) => p.name.startsWith('Marina'));
      expect(marina.division, equals(DivisaoEtaria.senior));
      expect(marina.displayName, equals('Marina S.'));
    });

    test('Bloqueia tentativa de ataque XXE (DOCTYPE / ENTITY) no XML .tdf', () {
      const maliciousXml = '''<?xml version="1.0"?>
<!DOCTYPE foo [ <!ENTITY xxe SYSTEM "file:///etc/passwd"> ]>
<tournament><data><name>&xxe;</name></data></tournament>''';

      expect(
        () => TomTdfParser.parseTdfXml(maliciousXml),
        throwsA(isA<TomTdfSecurityException>()),
      );
    });

    test('Garante idempotência por hash SHA-256 ao importar o mesmo .tdf duas vezes (RN-08)', () {
      final vm = TournamentEditorViewModel()..initPlayers();
      final xml = TomTdfParser.gerarSampleTdfXml();

      final firstImport = vm.importTdfXml(xml);
      final secondImport = vm.importTdfXml(xml);

      expect(firstImport, isTrue);
      expect(secondImport, isFalse);
      expect(vm.lastImportWasError, isTrue);
    });
  });

  group('Fase 6.5 - Motor Analítico, Sem Corte (Suíço), Persistência Manual e Exportação PDF/Infográfico', () {
    test('Calcula Metagame, Presença de Cartas, Lista Consenso 60 Cartas e preserva edições ao trocar Corte/Salvar', () async {
      final vm = TournamentEditorViewModel()..initPlayers();

      expect(vm.metagame, isNotEmpty);
      expect(vm.cardPresence, isNotEmpty);

      final consensus = vm.consensusDeck;
      expect(consensus.totalCards, equals(60));

      final (low, high) = AnalyticsEngine.calcularIntervaloWilson(0.75, 20);
      expect(low, greaterThan(0.50));
      expect(high, lessThan(0.95));

      // Edita manualmente o jogador 1 e alterna para Sem Corte (League Challenge)
      vm.updatePlayer(0, vm.players[0].copyWith(name: 'Campeão Manual Challenge'));
      vm.updateTopCut(TopCut.none);
      expect(vm.topCut, equals(TopCut.none));
      expect(vm.players[0].name, equals('Campeão Manual Challenge'));

      // Salva manualmente o torneio
      vm.saveCurrentTournament();
      expect(vm.savedTournaments.length, equals(1));
      expect(vm.savedTournaments.first.name, equals(vm.tournamentName));

      // Testa geração dos dois PDFs (Relatório Oficial A4 e Infográfico Visual A4 Paisagem)
      final pdfService = PdfExportService();
      final reportBytes = await pdfService.generateTournamentReport(
        vm.currentTournament,
        cardPresence: vm.cardPresence,
        consensusDeck: vm.consensusDeck,
      );
      final infographicBytes = await pdfService.generateVisualInfographicPdf(
        vm.currentTournament,
        cardPresence: vm.cardPresence,
        consensusDeck: vm.consensusDeck,
      );
      expect(reportBytes.length, greaterThan(1000));
      expect(infographicBytes.length, greaterThan(1000));
    });
  });

  group('Fase 7 - Testes de UI, Digitação Contínua sem Perda de Foco, Abas e Embargo Anti-Scouting', () {
    testWidgets('Digita texto completo sem perder foco, preserva estado entre abas e valida UI',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1440, 900));
      await tester.pumpWidget(const MetaDexApp());
      await tester.pumpAndSettle();

      expect(find.text('METADEX'), findsOneWidget);
      expect(find.text('CRIAR NOVO RELATÓRIO'), findsOneWidget);

      await tester.tap(find.text('CRIAR NOVO RELATÓRIO'));
      await tester.pumpAndSettle();

      // Verifica que o editor abriu sem overflow e exibe o torneio e as abas
      expect(find.text('PAINEL DE COMANDO'), findsOneWidget);
      expect(find.text('METAGAME'), findsOneWidget);
      expect(find.text('TOP CARTAS'), findsOneWidget);

      // Digita múltiplos caracteres no campo "Nome do Torneio" e verifica que não perde o foco após 1 letra
      final nameField = find.widgetWithText(TextFormField, 'Nome do Torneio');
      expect(nameField, findsOneWidget);
      await tester.enterText(nameField, 'League Challenge Outubro H-I-J');
      await tester.pumpAndSettle();
      expect(find.text('LEAGUE CHALLENGE OUTUBRO H-I-J'), findsOneWidget);

      // Clica no botão SALVAR do Painel de Comando
      await tester.tap(find.text('SALVAR'));
      await tester.pumpAndSettle();

      // Navega para a aba TOP CARTAS no Viewport
      await tester.tap(find.text('TOP CARTAS'));
      await tester.pumpAndSettle();
      expect(find.textContaining('CARTAS MAIS USADAS'), findsOneWidget);

      // Navega para a aba JOGADORES no Painel de Comando
      await tester.tap(find.text('JOGADORES'));
      await tester.pumpAndSettle();
      expect(find.text('+ Adicionar Jogador'), findsOneWidget);

      // Clica no primeiro jogador para expandir
      final playerTile = find.textContaining('1º -');
      expect(playerTile, findsOneWidget);
      await tester.tap(playerTile);
      await tester.pumpAndSettle();

      // Verifica se todos os campos do jogador expandido estão visíveis
      expect(find.widgetWithText(TextFormField, 'Nome Completo do Jogador'), findsOneWidget);
      expect(find.widgetWithText(DropdownButtonFormField<DivisaoEtaria>, 'Divisão Etária'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Nome do Deck / Arquétipo'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Colar Decklist (PTCG Live PT-BR ou EN)'), findsOneWidget);

      await tester.binding.setSurfaceSize(null);
    });
  });
}

