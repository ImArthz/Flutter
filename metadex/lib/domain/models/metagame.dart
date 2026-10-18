import 'dart:ui';
import 'deck.dart';

class MetagameStat {
  final String deckName;
  final double percentage; // Meta Share (%)
  final double topCutPercentage; // Top Cut Share (%)
  final double conversionRate; // CR(A) = (|T_A|/|T|) / (|D_A|/|D|)
  final int count; // |D_A|
  final int topCutCount; // |T_A|
  final double rawWinRate; // WR(A) = (3W + T) / 3(W + L + T)
  final double bayesianWinRate; // WR suavizado Bayesiano
  final double wilsonLower; // Intervalo de confiança de Wilson (inferior)
  final double wilsonUpper; // Intervalo de confiança de Wilson (superior)
  final bool lowSampleWarning; // RN-07: n < 5
  final Color color;
  final String? imageUrl;

  const MetagameStat({
    required this.deckName,
    required this.percentage,
    this.topCutPercentage = 0.0,
    this.conversionRate = 1.0,
    this.count = 1,
    this.topCutCount = 1,
    this.rawWinRate = 0.5,
    this.bayesianWinRate = 0.5,
    this.wilsonLower = 0.2,
    this.wilsonUpper = 0.8,
    this.lowSampleWarning = true,
    required this.color,
    this.imageUrl,
  });
}

/// Estatística de Presença / Inclusão de Carta (Fase 6.5 / US-10)
class CardPresenceStat {
  final String canonicalName;
  final CardType type;
  final String? imageUrl;
  final double inclusionRate; // IR(c, A) em [0, 1]
  final double conditionalMeanCopies; // q_bar(c, A)
  final double weightedInclusionRate; // IR_w(c, A) ponderado por colocação (DCG)
  final int totalCopiesAcrossDecks;
  final int decksWithCard;
  final int totalDecksEvaluated;
  final Map<int, int> copyDistribution; // {1: n1, 2: n2, 3: n3, 4: n4}
  final CardRoleClass roleClass; // Core (>=90%), Padrao (50-89%), Tech (<50%)

  const CardPresenceStat({
    required this.canonicalName,
    required this.type,
    this.imageUrl,
    required this.inclusionRate,
    required this.conditionalMeanCopies,
    required this.weightedInclusionRate,
    required this.totalCopiesAcrossDecks,
    required this.decksWithCard,
    required this.totalDecksEvaluated,
    required this.copyDistribution,
    required this.roleClass,
  });

  String get roleLabel {
    switch (roleClass) {
      case CardRoleClass.core:
        return 'Core';
      case CardRoleClass.padrao:
        return 'Padrão';
      case CardRoleClass.tech:
        return 'Tech / Flex';
    }
  }
}

/// Item de comparação (Diff) entre a lista do jogador e a Lista Consenso (UC7)
class DeckDiffItem {
  final String cardName;
  final int playerQuantity;
  final int consensusQuantity;
  final CardType type;

  const DeckDiffItem({
    required this.cardName,
    required this.playerQuantity,
    required this.consensusQuantity,
    required this.type,
  });

  int get delta => playerQuantity - consensusQuantity;
}

/// Célula da Matriz de Matchups (Fase 6.5 / Fase 7.2)
class MatchupCell {
  final String archetypeA;
  final String archetypeB;
  final int wins;
  final int losses;
  final int ties;
  final double winRate;
  final double wilsonLower;
  final double wilsonUpper;

  const MatchupCell({
    required this.archetypeA,
    required this.archetypeB,
    required this.wins,
    required this.losses,
    required this.ties,
    required this.winRate,
    required this.wilsonLower,
    required this.wilsonUpper,
  });

  int get totalMatches => wins + losses + ties;
  bool get lowSample => totalMatches < 5;
  String get recordLabel => '$wins-$losses-$ties';
}
