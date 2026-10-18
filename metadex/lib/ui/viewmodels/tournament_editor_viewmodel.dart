import 'package:flutter/material.dart';
import '../../domain/models/tournament.dart';
import '../../domain/models/player.dart';
import '../../domain/models/metagame.dart';
import '../../domain/models/deck.dart';
import '../../domain/services/deck_validator.dart';
import '../../domain/services/archetype_classifier.dart';
import '../../domain/services/tom_tdf_parser.dart';
import '../../domain/services/analytics_engine.dart';

class TournamentEditorViewModel extends ChangeNotifier {
  String tournamentName = 'League Cup Outubro - Card House';
  String storeName = 'Card House TCG';
  String storeCity = 'São Paulo';
  String storeUf = 'SP';
  TipoTorneio tipoTorneio = TipoTorneio.leagueCup;
  Formato formato = Formato.standardAtual(); // Standard (H-I-J)
  EstadoTorneio estadoTorneio = EstadoTorneio.publicado;
  PoliticaVisibilidade politicaVisibilidade = PoliticaVisibilidade.todasAsListas;
  TopCut topCut = TopCut.top8;
  int swissRounds = 5;

  int selectedPlayerIndex = 0;
  String selectedArchetypeFilter = 'TODOS';
  String? lastImportMessage;
  bool lastImportWasError = false;

  /// Contador incrementado APENAS em ações de importação/reset em lote.
  /// Nunca é incrementado durante digitação manual, evitando perda de foco nos TextFormFields.
  int formResetGeneration = 0;

  /// Histórico de torneios salvos na sessão (acessível no Menu Inicial e Painel)
  final List<Tournament> savedTournaments = [];
  DateTime? lastSavedAt;
  String? saveStatusMessage;

  final Set<String> _importedTdfHashes = {};
  final ValidadorDeDecklist _validator = ValidadorDeDecklist();
  final ClassificadorComposto _classifier = ClassificadorComposto();

  List<Player> players = [];
  List<Partida> matches = [];
  List<EventoAuditoria> auditLog = [];

  bool get isEmbargoActive =>
      estadoTorneio == EstadoTorneio.rascunho ||
      estadoTorneio == EstadoTorneio.inscricoesAbertas ||
      estadoTorneio == EstadoTorneio.emAndamento;

  List<Arquetipo> get catalogoArquetipos => _classifier.catalogo;

  List<String> get availableArchetypeFilters {
    final names = players
        .map((p) => p.deckName.trim())
        .where((d) => d.isNotEmpty && d != 'Deck Desconhecido' && d != 'Aguardando Decklist')
        .toSet()
        .toList();
    return ['TODOS', ...names];
  }

  /// Jogadores visíveis de acordo com a configuração de Top Cut (Top 4, Top 8 ou Todos no Suíço Direto)
  List<Player> get visiblePodiumPlayers {
    if (topCut == TopCut.top4) {
      return players.take(4).toList();
    } else if (topCut == TopCut.top8) {
      return players.take(8).toList();
    }
    return players;
  }

  /// Metagame dinâmico completo (Meta Share, Conversão, WR Bayesiano, Intervalo de Wilson)
  List<MetagameStat> get metagame => AnalyticsEngine.calcularMetagame(
        players: players,
        topCut: topCut,
      );

  /// Presença de Cartas detalhada (IR, Média Condicional, IR Ponderado DCG, Histograma 1/2/3/4)
  List<CardPresenceStat> get cardPresence => AnalyticsEngine.calcularPresencaDeCartas(
        players: players,
        filtroArquetipo: selectedArchetypeFilter,
      );

  /// Lista rápida de Top 15 cartas por quantidade total
  List<MapEntry<String, int>> get topCards {
    return cardPresence
        .map((c) => MapEntry(c.canonicalName, c.totalCopiesAcrossDecks))
        .take(15)
        .toList();
  }

  /// Lista Consenso de 60 cartas gerada pelo Algoritmo Guloso (Fase 6.5)
  Decklist get consensusDeck => AnalyticsEngine.gerarListaConsenso(
        players: players,
        arquetipoAlvo: selectedArchetypeFilter,
      );

  /// Comparação (Diff) da lista do jogador selecionado contra a Lista Consenso (UC7)
  List<DeckDiffItem> get selectedPlayerDiff {
    if (players.isEmpty) return const [];
    final idx = selectedPlayerIndex.clamp(0, players.length - 1);
    final player = players[idx];
    if (player.decklist == null || player.decklist!.cards.isEmpty) return const [];
    final targetConsensus = AnalyticsEngine.gerarListaConsenso(
      players: players,
      arquetipoAlvo: player.deckName,
    );
    return AnalyticsEngine.compararComConsenso(player.decklist!, targetConsensus);
  }

  /// Matriz de Matchups (Fase 6.5 / 7.2)
  List<MatchupCell> get matchupMatrix => AnalyticsEngine.calcularMatrizMatchups(
        players: players,
        matches: matches,
      );

  /// Fila de Curadoria para a Juíza (listas inválidas ou com baixa confiança de arquétipo)
  List<Player> get curationQueue => players.where((p) {
        final invalid = p.validationResult != null && !p.validationResult!.isValida;
        final needsCur = (p.classification?.requerCuradoria ?? false) && !p.curatedByJudge;
        return invalid || needsCur;
      }).toList();

  /// Insights em linguagem natural para o Lojista Roberto (Fase 7.3)
  List<String> get naturalLanguageInsights {
    final stats = metagame;
    if (stats.isEmpty) {
      return ['Importe um arquivo .tdf ou preencha os decks para gerar insights automáticos.'];
    }
    final leader = stats.first;
    final bestConverter = List<MetagameStat>.from(stats)
      ..sort((a, b) => b.conversionRate.compareTo(a.conversionRate));
    final topCard = cardPresence.isNotEmpty ? cardPresence.first : null;
    final validDecks = players.where((p) => p.validationResult?.isValida ?? false).length;

    return [
      '🏆 Dominância Local: "${leader.deckName}" lidera o torneio com ${leader.percentage.toStringAsFixed(1)}% de Meta Share (${leader.count} jogadores) e Win Rate Bayesiano de ${(leader.bayesianWinRate * 100).toStringAsFixed(1)}%.',
      '📈 Melhor Conversão: "${bestConverter.first.deckName}" obteve taxa de conversão de ${bestConverter.first.conversionRate.toStringAsFixed(2)}x (${currentTournament.topCutLabel}).',
      if (topCard != null)
        '🃏 Staple Absoluta: "${topCard.canonicalName}" está presente em ${(topCard.inclusionRate * 100).toStringAsFixed(0)}% das listas com média de ${topCard.conditionalMeanCopies.toStringAsFixed(1)} cópias (${topCard.roleLabel}).',
      '⚖️ Integridade (Juiz): $validDecks de ${players.length} decklists aprovadas em todas as 6 regras do formato ${formato.nome}.',
    ];
  }

  Tournament get currentTournament => Tournament(
        id: 'trn_${tournamentName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}',
        name: tournamentName,
        loja: Loja(
          id: 'loja_01',
          nome: storeName,
          slug: storeName.toLowerCase().replaceAll(' ', '-'),
          cidade: storeCity,
          uf: storeUf,
          politicaVisibilidade: politicaVisibilidade,
        ),
        formato: formato,
        tipo: tipoTorneio,
        date: DateTime.now(),
        estado: estadoTorneio,
        politicaVisibilidade: politicaVisibilidade,
        swissRounds: swissRounds,
        topCut: topCut,
        players: List<Player>.from(players),
        matches: List<Partida>.from(matches),
        metagameStats: metagame,
        auditLog: List<EventoAuditoria>.from(auditLog),
      );

  /// Salva explicitamente o estado atual do torneio na lista de torneios salvos
  void saveCurrentTournament() {
    final snapshot = currentTournament;
    final existingIdx = savedTournaments.indexWhere(
      (t) => t.id == snapshot.id || t.name.toLowerCase() == snapshot.name.toLowerCase(),
    );
    if (existingIdx >= 0) {
      savedTournaments[existingIdx] = snapshot;
    } else {
      savedTournaments.insert(0, snapshot);
    }
    lastSavedAt = DateTime.now();
    final hh = lastSavedAt!.hour.toString().padLeft(2, '0');
    final mm = lastSavedAt!.minute.toString().padLeft(2, '0');
    final ss = lastSavedAt!.second.toString().padLeft(2, '0');
    saveStatusMessage = 'Salvo às $hh:$mm:$ss (${players.length} jogadores)';
    _logAudit(
      'Lojista / Operador',
      'SALVAMENTO_MANUAL',
      'Torneio "$tournamentName" salvo com ${players.length} jogadores no formato ${formato.nome}.',
    );
    notifyListeners();
  }

  /// Carrega um torneio salvo anteriormente
  void loadSavedTournament(Tournament t) {
    tournamentName = t.name;
    storeName = t.loja.nome;
    storeCity = t.loja.cidade;
    storeUf = t.loja.uf;
    formato = t.formato;
    tipoTorneio = t.tipo;
    estadoTorneio = t.estado;
    politicaVisibilidade = t.politicaVisibilidade;
    topCut = t.topCut;
    swissRounds = t.swissRounds;
    players = List<Player>.from(t.players);
    matches = List<Partida>.from(t.matches);
    auditLog = List<EventoAuditoria>.from(t.auditLog);
    selectedPlayerIndex = 0;
    formResetGeneration++;
    notifyListeners();
  }

  void initPlayers() {
    final rawTemplates = [
      (
        1,
        'Lucas Mendonça',
        DivisaoEtaria.masters,
        false,
        5,
        0,
        1,
        0.684,
        0.612,
        _sampleCharizardDeck(variant: 1),
      ),
      (
        2,
        'Marina Souza',
        DivisaoEtaria.senior, // Demonstra proteção LGPD RN-05 ("Marina S.")
        false,
        4,
        1,
        1,
        0.642,
        0.598,
        _sampleTerapagosDeck(),
      ),
      (
        3,
        'Roberto Almeida',
        DivisaoEtaria.masters,
        true,
        4,
        1,
        1,
        0.615,
        0.574,
        _sampleDragapultDeck(variant: 1),
      ),
      (
        4,
        'Ana Ferreira',
        DivisaoEtaria.masters,
        true,
        4,
        2,
        0,
        0.590,
        0.560,
        _sampleRagingBoltDeck(),
      ),
      (
        5,
        'Pedro Oliveira',
        DivisaoEtaria.masters,
        true,
        3,
        2,
        1,
        0.572,
        0.548,
        _sampleCharizardDeck(variant: 2),
      ),
      (
        6,
        'Julia Costa',
        DivisaoEtaria.masters,
        true,
        3,
        2,
        1,
        0.555,
        0.531,
        _sampleDragapultDeck(variant: 2),
      ),
      (
        7,
        'Marcos Ribeiro',
        DivisaoEtaria.masters,
        true,
        3,
        3,
        0,
        0.530,
        0.515,
        _sampleTerapagosDeck(),
      ),
      (
        8,
        'Carla Martins',
        DivisaoEtaria.masters,
        true,
        3,
        3,
        0,
        0.512,
        0.504,
        _sampleRagingBoltDeck(),
      ),
    ];

    final count = topCut == TopCut.top4 ? 4 : 8;
    players = rawTemplates.take(count).map((tpl) {
      final parsed = PtcgLiveParser.parse(tpl.$10);
      final valRes = _validator.validar(parsed, formato);
      final classRes = _classifier.classificar(valRes.decklistAtualizada);

      return Player(
        id: '100${tpl.$1}',
        placement: tpl.$1,
        name: tpl.$2,
        division: tpl.$3,
        hasParentalConsent: tpl.$4,
        deckName: classRes.arquetipo.nome,
        deckImagePath: classRes.arquetipo.imagemRepresentativa,
        decklist: valRes.decklistAtualizada,
        wins: tpl.$5,
        losses: tpl.$6,
        ties: tpl.$7,
        owp: tpl.$8,
        oowp: tpl.$9,
        validationResult: valRes,
        classification: classRes,
      );
    }).toList();

    _rebuildDefaultMatches();
    formResetGeneration++;
    _logAudit(
      'SISTEMA',
      'INICIALIZACAO',
      'Torneio inicializado com ${players.length} jogadores e decklists de 60 cartas no formato ${formato.nome}.',
    );
    if (savedTournaments.isEmpty) {
      savedTournaments.add(currentTournament);
    }
    notifyListeners();
  }

  void _rebuildDefaultMatches() {
    if (players.length < 4) return;
    matches = [
      Partida(
        id: 'm1',
        roundNumber: 1,
        tableNumber: 1,
        player1Id: players[0].id,
        player2Id: players[1].id,
        player1Name: players[0].name,
        player2Name: players[1].name,
        player1Deck: players[0].deckName,
        player2Deck: players[1].deckName,
        result: 1,
      ),
      Partida(
        id: 'm2',
        roundNumber: 1,
        tableNumber: 2,
        player1Id: players[2].id,
        player2Id: players[3].id,
        player1Name: players[2].name,
        player2Name: players[3].name,
        player1Deck: players[2].deckName,
        player2Deck: players[3].deckName,
        result: 1,
      ),
      if (players.length >= 6)
        Partida(
          id: 'm3',
          roundNumber: 2,
          tableNumber: 1,
          player1Id: players[4].id,
          player2Id: players[5].id,
          player1Name: players[4].name,
          player2Name: players[5].name,
          player1Deck: players[4].deckName,
          player2Deck: players[5].deckName,
          result: 2,
        ),
      Partida(
        id: 'm4',
        roundNumber: 2,
        tableNumber: 2,
        player1Id: players[0].id,
        player2Id: players[2].id,
        player1Name: players[0].name,
        player2Name: players[2].name,
        player1Deck: players[0].deckName,
        player2Deck: players[2].deckName,
        result: 1,
      ),
      Partida(
        id: 'm5',
        roundNumber: 3,
        tableNumber: 1,
        player1Id: players[1].id,
        player2Id: players[3].id,
        player1Name: players[1].name,
        player2Name: players[3].name,
        player1Deck: players[1].deckName,
        player2Deck: players[3].deckName,
        result: 1,
      ),
    ];
  }

  void _logAudit(String autor, String acao, String detalhes) {
    auditLog = [
      EventoAuditoria(
        id: 'aud_${DateTime.now().microsecondsSinceEpoch}',
        ocorridoEm: DateTime.now(),
        autor: autor,
        acao: acao,
        detalhes: detalhes,
      ),
      ...auditLog,
    ];
  }

  void updateTournamentName(String name) {
    tournamentName = name;
    notifyListeners();
  }

  void updateStoreInfo({String? nome, String? cidade, String? uf}) {
    if (nome != null) storeName = nome;
    if (cidade != null) storeCity = cidade;
    if (uf != null) storeUf = uf;
    notifyListeners();
  }

  void updateEstadoTorneio(EstadoTorneio novoEstado) {
    final anterior = estadoTorneio;
    estadoTorneio = novoEstado;
    _logAudit(
      'Lojista / Juiz',
      'MUDANCA_ESTADO',
      'Estado alterado de ${anterior.name} para ${novoEstado.name}.',
    );
    notifyListeners();
  }

  void updatePoliticaVisibilidade(PoliticaVisibilidade novaPolitica) {
    politicaVisibilidade = novaPolitica;
    _logAudit(
      'Lojista',
      'POLITICA_VISIBILIDADE',
      'Política de visibilidade alterada para ${novaPolitica.name}.',
    );
    notifyListeners();
  }

  void updateFormato(Formato novoFormato) {
    formato = novoFormato;
    // Revalida todas as decklists contra o novo formato (RN-01)
    players = players.map((p) {
      if (p.decklist == null) return p;
      final valRes = _validator.validar(p.decklist!, formato);
      return p.copyWith(
        decklist: valRes.decklistAtualizada,
        validationResult: valRes,
      );
    }).toList();
    _logAudit(
      'Juiz (Professor)',
      'MUDANCA_FORMATO',
      'Formato alterado para ${novoFormato.nome}; listas revalidadas.',
    );
    notifyListeners();
  }

  void selectPlayer(int index) {
    if (index >= 0 && index < players.length) {
      selectedPlayerIndex = index;
      notifyListeners();
    }
  }

  void setArchetypeFilter(String filter) {
    selectedArchetypeFilter = filter;
    notifyListeners();
  }

  /// Altera o modo de corte (Sem Corte Suíço, Top 4 ou Top 8) SEM apagar os jogadores editados manualmente!
  void updateTopCut(TopCut cut) {
    topCut = cut;
    if (cut == TopCut.none) {
      tipoTorneio = TipoTorneio.leagueChallenge;
    } else if (cut == TopCut.top8) {
      tipoTorneio = TipoTorneio.leagueCup;
    }
    if (cut == TopCut.top4 && players.length > 4) {
      players = players.sublist(0, 4);
    } else if ((cut == TopCut.top8 || cut == TopCut.none) && players.length < 8) {
      // Adiciona slots extras preservando integralmente os jogadores já editados
      for (int i = players.length + 1; i <= 8; i++) {
        final parsed = PtcgLiveParser.parse(_sampleCharizardDeck(variant: 2));
        final valRes = _validator.validar(parsed, formato);
        final classRes = _classifier.classificar(valRes.decklistAtualizada);
        players.add(
          Player(
            id: '100$i',
            placement: i,
            name: 'Jogador $i',
            division: DivisaoEtaria.masters,
            deckName: classRes.arquetipo.nome,
            deckImagePath: classRes.arquetipo.imagemRepresentativa,
            decklist: valRes.decklistAtualizada,
            wins: 3,
            losses: 2,
            ties: 0,
            owp: 0.520,
            oowp: 0.505,
            validationResult: valRes,
            classification: classRes,
          ),
        );
      }
    }
    notifyListeners();
  }

  /// Adiciona manualmente um novo jogador à classificação (ex: League Challenge / Suíço)
  void addManualPlayer() {
    final nextPos = players.length + 1;
    final parsed = PtcgLiveParser.parse(_sampleCharizardDeck(variant: 1));
    final valRes = _validator.validar(parsed, formato);
    final classRes = _classifier.classificar(valRes.decklistAtualizada);

    players = [
      ...players,
      Player(
        id: 'manual_${DateTime.now().millisecondsSinceEpoch}',
        placement: nextPos,
        name: 'Novo Jogador $nextPos',
        division: DivisaoEtaria.masters,
        deckName: classRes.arquetipo.nome,
        deckImagePath: classRes.arquetipo.imagemRepresentativa,
        decklist: valRes.decklistAtualizada,
        wins: 3,
        losses: 1,
        ties: 0,
        owp: 0.550,
        oowp: 0.520,
        validationResult: valRes,
        classification: classRes,
      ),
    ];
    selectedPlayerIndex = players.length - 1;
    _logAudit('Operador', 'ADICAO_JOGADOR', 'Jogador $nextPosº adicionado manualmente.');
    notifyListeners();
  }

  void updatePlayer(int index, Player player) {
    if (index < 0 || index >= players.length) return;
    var updated = player;
    if (updated.decklist != null) {
      final valRes = _validator.validar(updated.decklist!, formato);
      final classRes = _classifier.classificar(valRes.decklistAtualizada);
      final autoName = (updated.deckName.isEmpty ||
              updated.deckName == 'Deck Desconhecido' ||
              updated.deckName == 'Aguardando Decklist')
          ? classRes.arquetipo.nome
          : updated.deckName;
      final autoImg = (updated.deckImagePath == null || updated.deckImagePath!.isEmpty)
          ? classRes.arquetipo.imagemRepresentativa
          : updated.deckImagePath;

      updated = updated.copyWith(
        deckName: autoName,
        deckImagePath: autoImg,
        decklist: valRes.decklistAtualizada,
        validationResult: valRes,
        classification: classRes,
      );
    }
    players[index] = updated;
    notifyListeners();
  }

  /// Importa e valida a decklist em texto do PTCG Live para o jogador (RF-05, RF-06, RF-07)
  void importPlayerDecklist(int index, String rawDeckText, {bool isBulkAction = false}) {
    if (index < 0 || index >= players.length) return;
    if (rawDeckText.trim().isEmpty) return;

    final player = players[index];
    final parsed = PtcgLiveParser.parse(rawDeckText);
    final valRes = _validator.validar(parsed, formato);
    final classRes = _classifier.classificar(valRes.decklistAtualizada);

    players[index] = player.copyWith(
      deckName: classRes.arquetipo.nome,
      deckImagePath: classRes.arquetipo.imagemRepresentativa,
      decklist: valRes.decklistAtualizada.copyWith(version: (player.decklist?.version ?? 0) + 1),
      validationResult: valRes,
      classification: classRes,
      curatedByJudge: false,
    );

    if (isBulkAction) {
      formResetGeneration++;
    }

    _logAudit(
      player.displayName,
      'SUBMISSAO_DECKLIST',
      'Decklist v${players[index].decklist?.version} importada (${valRes.totalCartas} cartas, ${valRes.isValida ? "VÁLIDA" : "${valRes.violacoes.length} violações"}) -> ${classRes.arquetipo.nome}.',
    );
    notifyListeners();
  }

  /// Curadoria manual da Juíza: define o arquétipo de uma lista ambígua (UC14)
  void assignArchetypeByJudge(int playerIndex, Arquetipo arquetipo) {
    if (playerIndex < 0 || playerIndex >= players.length) return;
    final p = players[playerIndex];
    players[playerIndex] = p.copyWith(
      deckName: arquetipo.nome,
      deckImagePath: arquetipo.imagemRepresentativa,
      classification: ClassificacaoArquetipo(
        arquetipo: arquetipo,
        confianca: 1.0,
        requerCuradoria: false,
        metodo: 'Curadoria Humana (Juiz)',
      ),
      curatedByJudge: true,
    );
    formResetGeneration++;
    _logAudit(
      'Ana (Juíza)',
      'CURADORIA_ARQUETIPO',
      'Arquétipo do jogador ${p.displayName} definido manualmente para "${arquetipo.nome}".',
    );
    notifyListeners();
  }

  /// Alterna consentimento parental LGPD para exibir sobrenome completo de Junior/Senior (RN-05)
  void toggleParentalConsent(int playerIndex, bool consent) {
    if (playerIndex < 0 || playerIndex >= players.length) return;
    final p = players[playerIndex];
    players[playerIndex] = p.copyWith(hasParentalConsent: consent);
    _logAudit(
      'Responsável Legal',
      'CONSENTIMENTO_LGPD',
      'Consentimento parental (Art. 14 LGPD) para ${p.name}: ${consent ? "CONCEDIDO" : "REVOGADO"}.',
    );
    notifyListeners();
  }

  /// Importa um arquivo .tdf (XML do TOM) com verificação de idempotência SHA-256 (US-04 / RN-08)
  bool importTdfXml(String xmlContent, {bool forceReimport = false}) {
    if (xmlContent.trim().isEmpty) return false;
    try {
      final hash = TomTdfParser.computeTdfHash(xmlContent);
      if (!forceReimport && _importedTdfHashes.contains(hash)) {
        lastImportWasError = true;
        lastImportMessage =
            'Este arquivo .tdf já foi importado (Hash SHA-256 idempotente: ${hash.substring(0, 10)}...).';
        notifyListeners();
        return false;
      }

      final result = TomTdfParser.parseTdfXml(xmlContent);
      if (result.players.isEmpty) {
        lastImportWasError = true;
        lastImportMessage = 'Nenhum jogador encontrado no XML .tdf fornecido.';
        notifyListeners();
        return false;
      }

      _importedTdfHashes.add(hash);
      if (result.tournamentName != null && result.tournamentName!.isNotEmpty) {
        tournamentName = result.tournamentName!;
      }
      swissRounds = result.swissRounds;

      // Mescla os jogadores importados preservando decklists já existentes na mesma colocação
      final merged = <Player>[];
      for (int i = 0; i < result.players.length; i++) {
        final imported = result.players[i];
        final existing = i < players.length ? players[i] : null;
        merged.add(
          imported.copyWith(
            deckName: existing?.deckName ?? imported.deckName,
            deckImagePath: existing?.deckImagePath,
            decklist: existing?.decklist,
            validationResult: existing?.validationResult,
            classification: existing?.classification,
          ),
        );
      }
      players = merged;
      matches = result.matches;
      formResetGeneration++;

      lastImportWasError = false;
      lastImportMessage =
          'Sucesso! ${players.length} jogadores e ${matches.length} partidas importados do .tdf (Datas de nascimento descartadas em memória - LGPD).';
      _logAudit(
        'Roberto (Lojista)',
        'IMPORT_TDF',
        'Arquivo .tdf importado (${players.length} inscritos, ${matches.length} partidas, hash ${hash.substring(0, 8)}).',
      );
      notifyListeners();
      return true;
    } catch (e) {
      lastImportWasError = true;
      lastImportMessage = 'Erro ao importar .tdf: $e';
      notifyListeners();
      return false;
    }
  }

  /// Carrega o arquivo .tdf de demonstração em 1 clique
  void loadSampleTdf() {
    final sampleXml = TomTdfParser.gerarSampleTdfXml();
    importTdfXml(sampleXml, forceReimport: true);
  }

  /// Lê o texto copiado do PDF do TOM e atualiza nomes, recordes W/L/T e OWP/OOWP
  void parseTomStandings(String text) {
    if (text.trim().isEmpty) return;
    players = TomTdfParser.parseTomStandingsText(text, players);
    formResetGeneration++;
    lastImportWasError = false;
    lastImportMessage = 'Classificação do PDF do TOM aplicada com sucesso!';
    _logAudit('Roberto (Lojista)', 'IMPORT_PDF_TOM', 'Standings extraídos de texto do PDF do TOM.');
    notifyListeners();
  }

  // Decklists 100% legais em Standard (H-I-J), (G-H-I) e Expanded (60 cartas exatas)
  static String _sampleCharizardDeck({int variant = 1}) {
    final tech = variant == 1 ? '1 Briar SCR 132' : '1 Crispin SCR 133';
    return '''Pokémon: 18
3 Charizard ex OBF 125
1 Charmeleon PAF 8
4 Charmander OBF 26
2 Noctowl SCR 115
2 Hoothoot SCR 114
2 Dusknoir SFA 20
2 Dusclops SFA 19
1 Duskull SFA 18
1 Fezandipiti ex SFA 38

Trainer: 36
4 Rare Candy SVI 191
4 Buddy-Buddy Poffin TEF 144
4 Ultra Ball SVI 196
4 Arven SVI 166
3 Iono PAL 185
2 Boss's Orders PAL 172
2 Super Rod PAL 188
3 Nest Ball SVI 181
2 Counter Catcher PAR 160
2 Night Stretcher SFA 61
1 Prime Catcher TEF 157
2 Professor's Research SVI 189
2 Professor Turo's Scenario PAR 171
$tech

Energy: 6
6 Basic Fire Energy SVE 2''';
  }

  static String _sampleTerapagosDeck() {
    return '''Pokémon: 14
3 Terapagos ex SCR 128
3 Noctowl SCR 115
3 Hoothoot SCR 114
2 Bouffalant SCR 119
1 Fan Rotom SCR 118
1 Fezandipiti ex SFA 38
1 Teal Mask Ogerpon ex TWM 25

Trainer: 35
4 Buddy-Buddy Poffin TEF 144
4 Area Zero Underdepths SCR 131
4 Nest Ball SVI 181
4 Ultra Ball SVI 196
4 Arven SVI 166
3 Iono PAL 185
2 Boss's Orders PAL 172
2 Night Stretcher SFA 61
2 Super Rod PAL 188
2 Counter Catcher PAR 160
2 Crispin SCR 133
1 Prime Catcher TEF 157
1 Briar SCR 132

Energy: 11
5 Basic Grass Energy SVE 1
3 Basic Water Energy SVE 3
3 Basic Lightning Energy SVE 4''';
  }

  static String _sampleDragapultDeck({int variant = 1}) {
    final ace = variant == 1 ? '1 Sparkling Crystal SCR 142' : '1 Unfair Stamp TWM 165';
    return '''Pokémon: 17
3 Dragapult ex TWM 130
4 Drakloak TWM 129
4 Dreepy TWM 128
2 Noctowl SCR 115
2 Hoothoot SCR 114
1 Fezandipiti ex SFA 38
1 Dusknoir SFA 20

Trainer: 37
4 Buddy-Buddy Poffin TEF 144
4 Ultra Ball SVI 196
4 Arven SVI 166
4 Iono PAL 185
3 Rare Candy SVI 191
2 Boss's Orders PAL 172
2 Crispin SCR 133
3 Nest Ball SVI 181
2 Counter Catcher PAR 160
2 Super Rod PAL 188
2 Earthen Vessel PAR 163
2 Night Stretcher SFA 61
2 Professor Turo's Scenario PAR 171
$ace

Energy: 6
3 Basic Fire Energy SVE 2
3 Basic Psychic Energy SVE 5''';
  }

  static String _sampleRagingBoltDeck() {
    return '''Pokémon: 12
4 Raging Bolt ex TEF 123
4 Teal Mask Ogerpon ex TWM 25
2 Noctowl SCR 115
1 Hoothoot SCR 114
1 Fezandipiti ex SFA 38

Trainer: 36
4 Crispin SCR 133
4 Nest Ball SVI 181
4 Earthen Vessel PAR 163
4 Energy Retrieval SVI 171
4 Ultra Ball SVI 196
3 Pokégear 3.0 SVI 186
3 Night Stretcher SFA 61
3 Boss's Orders PAL 172
3 Iono PAL 185
2 Area Zero Underdepths SCR 131
1 Prime Catcher TEF 157
1 Briar SCR 132

Energy: 12
6 Basic Grass Energy SVE 1
3 Basic Fighting Energy SVE 6
3 Basic Lightning Energy SVE 4''';
  }
}
