import 'deck.dart';
import '../services/deck_validator.dart';
import '../services/archetype_classifier.dart';

enum DivisaoEtaria { junior, senior, masters }

class Player {
  final String id;
  final String playerIdHash; // Pseudonimização LGPD (Art. 13 §4º)
  final int placement;
  final String name;
  final DivisaoEtaria division;
  final bool hasParentalConsent; // LGPD Art. 14 para Junior/Senior (RN-05)
  final String deckName;
  final String? deckImagePath;
  final Decklist? decklist;
  final int wins;
  final int losses;
  final int ties;
  final double owp;
  final double oowp;
  final ResultadoValidacao? validationResult;
  final ClassificacaoArquetipo? classification;
  final bool curatedByJudge;

  Player({
    String? id,
    String? playerIdHash,
    required this.placement,
    required this.name,
    this.division = DivisaoEtaria.masters,
    this.hasParentalConsent = false,
    required this.deckName,
    this.deckImagePath,
    this.decklist,
    this.wins = 0,
    this.losses = 0,
    this.ties = 0,
    this.owp = 0.50,
    this.oowp = 0.50,
    this.validationResult,
    this.classification,
    this.curatedByJudge = false,
  })  : id = id ?? 'p_$placement',
        playerIdHash = playerIdHash ?? _hashPlayerId(name, placement);

  int get matchPoints => (wins * 3) + ties;

  String get recordString => '$wins-$losses-$ties';

  /// RN-05: Jogadores das divisões Junior e Senior aparecem com sobrenome abreviado
  /// por padrão (ex: "Marina S."), salvo consentimento explícito do responsável.
  String get displayName {
    if (name.trim().isEmpty) return 'Jogador $placement';
    if (division == DivisaoEtaria.masters || hasParentalConsent) {
      return name.trim();
    }
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length <= 1) return parts.first;
    final firstName = parts.first;
    final lastInitial = parts.last.isNotEmpty ? '${parts.last[0].toUpperCase()}.' : '';
    return '$firstName $lastInitial'.trim();
  }

  String get divisionLabel {
    switch (division) {
      case DivisaoEtaria.junior:
        return 'Junior';
      case DivisaoEtaria.senior:
        return 'Senior';
      case DivisaoEtaria.masters:
        return 'Masters';
    }
  }

  static String _hashPlayerId(String raw, int placement) {
    var hash = 5381;
    final input = 'metadex_salt_${raw.toLowerCase()}_$placement';
    for (final code in input.codeUnits) {
      hash = ((hash << 5) + hash) ^ code;
    }
    return 'hmac_${(hash & 0x7FFFFFFF).toRadixString(16).padLeft(8, '0')}';
  }

  Player copyWith({
    String? id,
    String? playerIdHash,
    int? placement,
    String? name,
    DivisaoEtaria? division,
    bool? hasParentalConsent,
    String? deckName,
    String? deckImagePath,
    Decklist? decklist,
    int? wins,
    int? losses,
    int? ties,
    double? owp,
    double? oowp,
    ResultadoValidacao? validationResult,
    ClassificacaoArquetipo? classification,
    bool? curatedByJudge,
  }) {
    return Player(
      id: id ?? this.id,
      playerIdHash: playerIdHash ?? this.playerIdHash,
      placement: placement ?? this.placement,
      name: name ?? this.name,
      division: division ?? this.division,
      hasParentalConsent: hasParentalConsent ?? this.hasParentalConsent,
      deckName: deckName ?? this.deckName,
      deckImagePath: deckImagePath ?? this.deckImagePath,
      decklist: decklist ?? this.decklist,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      ties: ties ?? this.ties,
      owp: owp ?? this.owp,
      oowp: oowp ?? this.oowp,
      validationResult: validationResult ?? this.validationResult,
      classification: classification ?? this.classification,
      curatedByJudge: curatedByJudge ?? this.curatedByJudge,
    );
  }
}
