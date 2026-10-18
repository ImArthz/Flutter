import 'dart:math' as math;
import 'dart:ui';
import '../models/deck.dart';
import '../models/metagame.dart';
import '../models/player.dart';
import '../models/tournament.dart';

class AnalyticsEngine {
  /// Paleta segura para daltonismo inspirada em Okabe-Ito + acentos MetaDex (RNF-05)
  static const List<Color> okabeItoPalette = [
    Color(0xFFFF7A00), // Laranja MetaDex / Okabe-Ito Orange
    Color(0xFF56B4E9), // Azul Céu Okabe-Ito
    Color(0xFF009E73), // Verde Azulado Okabe-Ito
    Color(0xFFF0E442), // Amarelo Okabe-Ito
    Color(0xFFCC79A7), // Rosa/Púrpura Okabe-Ito
    Color(0xFF0072B2), // Azul Escuro Okabe-Ito
    Color(0xFFD55E00), // Vermelho-Laranja Okabe-Ito
    Color(0xFFE8E8E8), // Prata Neutro
  ];

  /// Intervalo de Confiança de Wilson para proporção binomial (Fase 6.5, z = 1.96)
  static (double lower, double upper) calcularIntervaloWilson(
    double pHat,
    int n, {
    double z = 1.96,
  }) {
    if (n <= 0) return (0.0, 1.0);
    final p = pHat.clamp(0.0, 1.0);
    final z2 = z * z;
    final denom = 1.0 + (z2 / n);
    final center = p + (z2 / (2.0 * n));
    final rad = math.sqrt((p * (1.0 - p) / n) + (z2 / (4.0 * n * n)));
    final lower = ((center - z * rad) / denom).clamp(0.0, 1.0);
    final upper = ((center + z * rad) / denom).clamp(0.0, 1.0);
    return (lower, upper);
  }

  /// Win Rate oficial Play! Pokémon (empate vale 1/3): WR = (3W + T) / 3(W + L + T)
  static double calcularWinRate(int wins, int losses, int ties) {
    final total = wins + losses + ties;
    if (total <= 0) return 0.50;
    return ((3.0 * wins) + ties) / (3.0 * total);
  }

  /// Suavização Bayesiana do Win Rate (Fase 6.5):
  /// WR_bayes(A) = (pontos_equivalentes + k * mediaGlobal) / (partidas + k)
  static double calcularWinRateBayesiano(
    int wins,
    int losses,
    int ties, {
    double priorMean = 0.50,
    double k = 10.0,
  }) {
    final partidas = wins + losses + ties;
    final vitoriasEquivalentes = wins + (ties / 3.0);
    return ((vitoriasEquivalentes + (k * priorMean)) / (partidas + k)).clamp(0.0, 1.0);
  }

  /// Calcula todas as métricas de Metagame (Meta Share, Taxa de Conversão, Win Rate, Wilson, Bayes)
  static List<MetagameStat> calcularMetagame({
    required List<Player> players,
    required TopCut topCut,
  }) {
    final validPlayers = players
        .where((p) =>
            p.deckName.trim().isNotEmpty &&
            p.deckName != 'Deck Desconhecido' &&
            p.deckName != 'Aguardando Decklist')
        .toList();

    if (validPlayers.isEmpty) return const [];

    final totalField = validPlayers.length;
    final topCutLimit = topCut == TopCut.top4 ? 4 : 8;
    final topCutPlayers = validPlayers.where((p) => p.placement <= topCutLimit).toList();
    final totalTopCut = topCutPlayers.isEmpty ? 1 : topCutPlayers.length;

    final byDeck = <String, List<Player>>{};
    for (final p in validPlayers) {
      byDeck.putIfAbsent(p.deckName.trim(), () => []).add(p);
    }

    int colorIdx = 0;
    final stats = <MetagameStat>[];

    for (final entry in byDeck.entries) {
      final deckName = entry.key;
      final group = entry.value;
      final count = group.length;
      final metaShare = (count / totalField) * 100.0;

      final inTopCut = group.where((p) => p.placement <= topCutLimit).length;
      final topCutShare = (inTopCut / totalTopCut) * 100.0;

      // CR(A) = (|T_A|/|T|) / (|D_A|/|D|)
      final conversionRate = metaShare > 0 ? (topCutShare / metaShare) : 0.0;

      final sumW = group.fold(0, (s, p) => s + p.wins);
      final sumL = group.fold(0, (s, p) => s + p.losses);
      final sumT = group.fold(0, (s, p) => s + p.ties);
      final totalMatches = sumW + sumL + sumT;

      final rawWr = calcularWinRate(sumW, sumL, sumT);
      final bayesWr = calcularWinRateBayesiano(sumW, sumL, sumT);
      final (wLow, wHigh) = calcularIntervaloWilson(
        rawWr,
        totalMatches > 0 ? totalMatches : count,
      );

      final img = group
          .map((p) => p.deckImagePath)
          .firstWhere((u) => u != null && u.isNotEmpty, orElse: () => null);

      stats.add(
        MetagameStat(
          deckName: deckName,
          percentage: metaShare,
          topCutPercentage: topCutShare,
          conversionRate: conversionRate,
          count: count,
          topCutCount: inTopCut,
          rawWinRate: rawWr,
          bayesianWinRate: bayesWr,
          wilsonLower: wLow,
          wilsonUpper: wHigh,
          lowSampleWarning: count < 5, // RN-07
          color: okabeItoPalette[colorIdx % okabeItoPalette.length],
          imageUrl: img,
        ),
      );
      colorIdx++;
    }

    stats.sort((a, b) {
      final cmp = b.percentage.compareTo(a.percentage);
      if (cmp != 0) return cmp;
      return b.rawWinRate.compareTo(a.rawWinRate);
    });
    return stats;
  }

  /// Calcula a Presença de Cartas (IR, Média Condicional, IR Ponderado DCG e Histograma 1/2/3/4) - Fase 6.5
  static List<CardPresenceStat> calcularPresencaDeCartas({
    required List<Player> players,
    String? filtroArquetipo,
  }) {
    final decksValidos = players.where((p) {
      if (p.decklist == null || p.decklist!.cards.isEmpty) return false;
      if (filtroArquetipo != null &&
          filtroArquetipo.isNotEmpty &&
          filtroArquetipo != 'TODOS') {
        return p.deckName.toLowerCase() == filtroArquetipo.toLowerCase();
      }
      return true;
    }).toList();

    final nDecks = decksValidos.length;
    if (nDecks == 0) return const [];

    // Soma de pesos DCG: w_d = 1 / log_2(1 + rank_d)
    double somaPesosTotal = 0.0;
    final pesoPorPlayer = <Player, double>{};
    for (final p in decksValidos) {
      final rank = p.placement < 1 ? 1 : p.placement;
      final w = 1.0 / (math.log(1 + rank) / math.ln2);
      pesoPorPlayer[p] = w;
      somaPesosTotal += w;
    }

    // Mapeia cada Carta Canônica presente
    final todasCanonicas = <String, DeckCard>{};
    for (final p in decksValidos) {
      for (final c in p.decklist!.cards) {
        todasCanonicas.putIfAbsent(c.canonical.name, () => c);
      }
    }

    final resultado = <CardPresenceStat>[];

    for (final entry in todasCanonicas.entries) {
      final canonName = entry.key;
      final sampleCard = entry.value;

      int decksComACarta = 0;
      int somaCopias = 0;
      double somaPesoInclusao = 0.0;
      final dist = <int, int>{1: 0, 2: 0, 3: 0, 4: 0};

      for (final p in decksValidos) {
        final qtd = p.decklist!.copiesOfCanonical(canonName);
        if (qtd > 0) {
          decksComACarta++;
          somaCopias += qtd;
          somaPesoInclusao += pesoPorPlayer[p] ?? 1.0;
          final bucket = qtd.clamp(1, 4);
          dist[bucket] = (dist[bucket] ?? 0) + 1;
        }
      }

      if (decksComACarta == 0) continue;

      final ir = decksComACarta / nDecks;
      final mediaCondicional = somaCopias / decksComACarta;
      final irPonderado = somaPesosTotal > 0 ? (somaPesoInclusao / somaPesosTotal) : ir;

      final CardRoleClass role;
      if (ir >= 0.90) {
        role = CardRoleClass.core;
      } else if (ir >= 0.50) {
        role = CardRoleClass.padrao;
      } else {
        role = CardRoleClass.tech;
      }

      resultado.add(
        CardPresenceStat(
          canonicalName: canonName,
          type: sampleCard.type,
          imageUrl: sampleCard.imageUrl,
          inclusionRate: ir,
          conditionalMeanCopies: mediaCondicional,
          weightedInclusionRate: irPonderado,
          totalCopiesAcrossDecks: somaCopias,
          decksWithCard: decksComACarta,
          totalDecksEvaluated: nDecks,
          copyDistribution: dist,
          roleClass: role,
        ),
      );
    }

    resultado.sort((a, b) {
      final cmpIr = b.inclusionRate.compareTo(a.inclusionRate);
      if (cmpIr != 0) return cmpIr;
      return b.totalCopiesAcrossDecks.compareTo(a.totalCopiesAcrossDecks);
    });

    return resultado;
  }

  /// Algoritmo Guloso da Lista Consenso de 60 Cartas (Fase 6.5)
  /// 1. Calcula IR e moda de cópias para cada carta no arquétipo.
  /// 2. Ordena por IR decrescente e adiciona com quantidade modal.
  /// 3. Ajusta flex slots para fechar exatamente 60 cartas e marca Core / Padrão / Tech.
  static Decklist gerarListaConsenso({
    required List<Player> players,
    String? arquetipoAlvo,
  }) {
    final candidatos = players.where((p) {
      if (p.decklist == null || p.decklist!.cards.isEmpty) return false;
      if (arquetipoAlvo != null &&
          arquetipoAlvo.isNotEmpty &&
          arquetipoAlvo != 'TODOS') {
        return p.deckName.toLowerCase() == arquetipoAlvo.toLowerCase();
      }
      return true;
    }).toList();

    if (candidatos.isEmpty) {
      return Decklist(cards: const []);
    }

    final stats = calcularPresencaDeCartas(
      players: candidatos,
      filtroArquetipo: arquetipoAlvo,
    );

    // Referência de metadados por carta canônica
    final cardRef = <String, DeckCard>{};
    for (final p in candidatos) {
      for (final c in p.decklist!.cards) {
        cardRef.putIfAbsent(c.canonical.name, () => c);
      }
    }

    final selecionadas = <DeckCard>[];
    int totalAcumulado = 0;
    bool jaTemAceSpec = false;
    bool jaTemRadiante = false;

    for (final stat in stats) {
      if (totalAcumulado >= 60) break;
      final base = cardRef[stat.canonicalName];
      if (base == null) continue;

      if (base.canonical.isAceSpec && jaTemAceSpec) continue;
      if (base.canonical.isRadiant && jaTemRadiante) continue;

      // Calcula a moda de cópias entre as listas que usam a carta
      int modaCopias = stat.conditionalMeanCopies.round().clamp(1, 4);
      int maxFreq = -1;
      for (final entry in stat.copyDistribution.entries) {
        if (entry.value > maxFreq || (entry.value == maxFreq && entry.key > modaCopias)) {
          maxFreq = entry.value;
          modaCopias = entry.key;
        }
      }
      // Se for energia básica, permite a média arredondada real
      if (base.canonical.isBasicEnergy) {
        modaCopias = stat.conditionalMeanCopies.round().clamp(1, 15);
      }
      if (base.canonical.isAceSpec || base.canonical.isRadiant) {
        modaCopias = 1;
      }

      final espacoRestante = 60 - totalAcumulado;
      final qtdAdicionar = math.min(modaCopias, espacoRestante);
      if (qtdAdicionar <= 0) continue;

      if (base.canonical.isAceSpec) jaTemAceSpec = true;
      if (base.canonical.isRadiant) jaTemRadiante = true;

      selecionadas.add(
        base.copyWith(
          name: stat.canonicalName,
          quantity: qtdAdicionar,
          roleClass: stat.roleClass,
        ),
      );
      totalAcumulado += qtdAdicionar;
    }

    // Se ainda faltar para 60 cartas, completa com a energia básica principal do deck
    if (totalAcumulado < 60 && selecionadas.isNotEmpty) {
      final faltam = 60 - totalAcumulado;
      final idxEnergia = selecionadas.indexWhere((c) => c.canonical.isBasicEnergy);
      if (idxEnergia >= 0) {
        final atual = selecionadas[idxEnergia];
        selecionadas[idxEnergia] = atual.copyWith(quantity: atual.quantity + faltam);
      } else {
        selecionadas.add(
          DeckCard(
            name: 'Basic Fire Energy',
            quantity: faltam,
            type: CardType.energy,
            setCode: 'SVE',
            setNumber: '2',
            roleClass: CardRoleClass.padrao,
          ),
        );
      }
    }

    return Decklist(
      cards: selecionadas,
      status: DecklistStatus.aprovada,
      rawText: 'Lista Consenso Sintética (60 Cartas)',
    );
  }

  /// Compara a lista de um jogador contra a Lista Consenso (UC7 - Diff)
  static List<DeckDiffItem> compararComConsenso(Decklist playerDeck, Decklist consensusDeck) {
    final todasCartas = <String, CardType>{};
    for (final c in consensusDeck.cards) {
      todasCartas[c.canonical.name] = c.type;
    }
    for (final c in playerDeck.cards) {
      todasCartas[c.canonical.name] = c.type;
    }

    final diffs = <DeckDiffItem>[];
    for (final entry in todasCartas.entries) {
      final nome = entry.key;
      final pQtd = playerDeck.copiesOfCanonical(nome);
      final cQtd = consensusDeck.copiesOfCanonical(nome);
      diffs.add(
        DeckDiffItem(
          cardName: nome,
          playerQuantity: pQtd,
          consensusQuantity: cQtd,
          type: entry.value,
        ),
      );
    }

    diffs.sort((a, b) {
      final absA = a.delta.abs();
      final absB = b.delta.abs();
      if (absA != absB) return absB.compareTo(absA);
      return b.playerQuantity.compareTo(a.playerQuantity);
    });
    return diffs;
  }

  /// Calcula a Matriz de Matchups cruzando os arquétipos das partidas (Fase 6.5 / 7.2)
  static List<MatchupCell> calcularMatrizMatchups({
    required List<Player> players,
    required List<Partida> matches,
  }) {
    final deckPorPlayerId = <String, String>{};
    final deckPorNome = <String, String>{};
    for (final p in players) {
      deckPorPlayerId[p.id] = p.deckName;
      deckPorNome[p.name.toLowerCase()] = p.deckName;
    }

    final arquetipos = players
        .map((p) => p.deckName.trim())
        .where((d) => d.isNotEmpty && d != 'Deck Desconhecido' && d != 'Aguardando Decklist')
        .toSet()
        .take(6)
        .toList();

    final cells = <MatchupCell>[];

    for (final arqA in arquetipos) {
      for (final arqB in arquetipos) {
        if (arqA == arqB) {
          cells.add(
            MatchupCell(
              archetypeA: arqA,
              archetypeB: arqB,
              wins: 0,
              losses: 0,
              ties: 0,
              winRate: 0.50,
              wilsonLower: 0.50,
              wilsonUpper: 0.50,
            ),
          );
          continue;
        }

        int w = 0;
        int l = 0;
        int t = 0;

        for (final m in matches) {
          final d1 = m.player1Deck.isNotEmpty
              ? m.player1Deck
              : (deckPorPlayerId[m.player1Id] ?? deckPorNome[m.player1Name.toLowerCase()] ?? '');
          final d2 = m.player2Deck.isNotEmpty
              ? m.player2Deck
              : (deckPorPlayerId[m.player2Id] ?? deckPorNome[m.player2Name.toLowerCase()] ?? '');

          if (d1 == arqA && d2 == arqB) {
            if (m.result == 1) {
              w++;
            } else if (m.result == 2) {
              l++;
            } else {
              t++;
            }
          } else if (d2 == arqA && d1 == arqB) {
            if (m.result == 2) {
              w++;
            } else if (m.result == 1) {
              l++;
            } else {
              t++;
            }
          }
        }

        final total = w + l + t;
        final wr = calcularWinRate(w, l, t);
        final (wLow, wHigh) = calcularIntervaloWilson(wr, total);

        cells.add(
          MatchupCell(
            archetypeA: arqA,
            archetypeB: arqB,
            wins: w,
            losses: l,
            ties: t,
            winRate: wr,
            wilsonLower: wLow,
            wilsonUpper: wHigh,
          ),
        );
      }
    }

    return cells;
  }
}
