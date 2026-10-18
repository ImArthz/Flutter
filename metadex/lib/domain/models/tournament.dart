import 'player.dart';
import 'metagame.dart';
import '../services/deck_validator.dart';

enum TopCut { top4, top8 }

enum TipoTorneio { ligaLocal, leagueChallenge, leagueCup, regional }

/// Máquina de Estados do Ciclo de Vida do Torneio (Fase 4.5)
enum EstadoTorneio {
  rascunho,
  inscricoesAbertas,
  emAndamento, // EMBARGO ATIVO (RN-03: decklists e agregados ocultos ao público)
  encerrado,
  emCuradoria,
  publicado,
  arquivado,
}

/// Política de visibilidade definida pelo lojista (RN-04)
enum PoliticaVisibilidade {
  todasAsListas,
  apenasTopCut,
  somenteAgregadosAnonimos,
}

class Loja {
  final String id;
  final String nome;
  final String slug;
  final String cidade;
  final String uf;
  final PoliticaVisibilidade politicaVisibilidade;

  const Loja({
    required this.id,
    required this.nome,
    required this.slug,
    required this.cidade,
    required this.uf,
    this.politicaVisibilidade = PoliticaVisibilidade.todasAsListas,
  });
}

class Partida {
  final String id;
  final int roundNumber;
  final int tableNumber;
  final String player1Id;
  final String player2Id;
  final String player1Name;
  final String player2Name;
  final String player1Deck;
  final String player2Deck;
  final int result; // 1 = Vitória P1, 2 = Vitória P2, 0 = Empate

  const Partida({
    required this.id,
    required this.roundNumber,
    required this.tableNumber,
    required this.player1Id,
    required this.player2Id,
    required this.player1Name,
    required this.player2Name,
    required this.player1Deck,
    required this.player2Deck,
    required this.result,
  });
}

class EventoAuditoria {
  final String id;
  final DateTime ocorridoEm;
  final String autor;
  final String acao;
  final String detalhes;

  const EventoAuditoria({
    required this.id,
    required this.ocorridoEm,
    required this.autor,
    required this.acao,
    required this.detalhes,
  });
}

class Tournament {
  final String id;
  final String name;
  final Loja loja;
  final Formato formato;
  final TipoTorneio tipo;
  final DateTime date;
  final EstadoTorneio estado;
  final PoliticaVisibilidade politicaVisibilidade;
  final int swissRounds;
  final String? logoPath;
  final String? tdfSha256;
  final TopCut topCut;
  final List<Player> players;
  final List<Partida> matches;
  final List<MetagameStat> metagameStats;
  final List<EventoAuditoria> auditLog;

  Tournament({
    required this.id,
    required this.name,
    Loja? loja,
    Formato? formato,
    this.tipo = TipoTorneio.leagueCup,
    required this.date,
    this.estado = EstadoTorneio.publicado,
    this.politicaVisibilidade = PoliticaVisibilidade.todasAsListas,
    this.swissRounds = 5,
    this.logoPath,
    this.tdfSha256,
    required this.topCut,
    required this.players,
    this.matches = const [],
    required this.metagameStats,
    this.auditLog = const [],
  })  : loja = loja ??
            const Loja(
              id: 'loja_1',
              nome: 'Card House TCG',
              slug: 'card-house-tcg',
              cidade: 'São Paulo',
              uf: 'SP',
            ),
        formato = formato ?? Formato.standardAtual();

  /// RN-03: Embargo ativo durante o torneio (Rascunho, Inscrições Abertas, Em Andamento)
  bool get isEmbargoActive =>
      estado == EstadoTorneio.rascunho ||
      estado == EstadoTorneio.inscricoesAbertas ||
      estado == EstadoTorneio.emAndamento;

  String get estadoLabel {
    switch (estado) {
      case EstadoTorneio.rascunho:
        return 'Rascunho';
      case EstadoTorneio.inscricoesAbertas:
        return 'Inscrições Abertas';
      case EstadoTorneio.emAndamento:
        return 'Em Andamento (Embargo Ativo)';
      case EstadoTorneio.encerrado:
        return 'Encerrado';
      case EstadoTorneio.emCuradoria:
        return 'Em Curadoria (Juiz)';
      case EstadoTorneio.publicado:
        return 'Publicado';
      case EstadoTorneio.arquivado:
        return 'Arquivado';
    }
  }

  String get tipoLabel {
    switch (tipo) {
      case TipoTorneio.ligaLocal:
        return 'Liga Local';
      case TipoTorneio.leagueChallenge:
        return 'League Challenge';
      case TipoTorneio.leagueCup:
        return 'League Cup';
      case TipoTorneio.regional:
        return 'Regional / Especial';
    }
  }
}
