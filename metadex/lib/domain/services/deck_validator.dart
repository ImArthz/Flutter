import '../models/deck.dart';

/// Formato de jogo vigente em um período de datas (Fase 4.4 / RN-01)
class Formato {
  final String id;
  final String nome;
  final DateTime vigenteDe;
  final DateTime vigenteAte;
  final Set<String> marcasPermitidas;
  final Set<String> banlist;

  const Formato({
    required this.id,
    required this.nome,
    required this.vigenteDe,
    required this.vigenteAte,
    required this.marcasPermitidas,
    this.banlist = const {},
  });

  bool estaVigenteEm(DateTime data) {
    return !data.isBefore(vigenteDe) && !data.isAfter(vigenteAte);
  }

  /// Formato Standard atual (Marcas G, H, I)
  factory Formato.standardAtual() {
    return Formato(
      id: 'fmt_std_ghi',
      nome: 'Standard (G-H-I)',
      vigenteDe: DateTime(2025, 4, 1),
      vigenteAte: DateTime(2027, 4, 1),
      marcasPermitidas: const {'G', 'H', 'I'},
      banlist: const {'Scoop Up Net', 'Shaymin EX', 'Lysandre\'s Trump Card'},
    );
  }

  /// Formato Standard anterior (Marcas F, G, H) para torneios históricos
  factory Formato.standardFGH() {
    return Formato(
      id: 'fmt_std_fgh',
      nome: 'Standard (F-G-H)',
      vigenteDe: DateTime(2024, 4, 1),
      vigenteAte: DateTime(2025, 3, 31),
      marcasPermitidas: const {'F', 'G', 'H', 'I'},
      banlist: const {'Scoop Up Net'},
    );
  }
}

class ViolacaoLegalidade {
  final String codigo;
  final String mensagem;
  final String? cartaRelacionada;

  const ViolacaoLegalidade({
    required this.codigo,
    required this.mensagem,
    this.cartaRelacionada,
  });
}

class ResultadoValidacao {
  final bool isValida;
  final List<ViolacaoLegalidade> violacoes;
  final int totalCartas;
  final int totalAceSpec;
  final int totalRadiantes;
  final Decklist decklistAtualizada;

  const ResultadoValidacao({
    required this.isValida,
    required this.violacoes,
    required this.totalCartas,
    required this.totalAceSpec,
    required this.totalRadiantes,
    required this.decklistAtualizada,
  });
}

/// Interface Strategy / Specification para Regras de Legalidade (Fase 4.4)
abstract class RegraDeLegalidade {
  List<ViolacaoLegalidade> avaliar(Decklist decklist, Formato formato);
}

/// Regra 1: Soma exata de 60 cartas
class RegraSessentaCartas implements RegraDeLegalidade {
  @override
  List<ViolacaoLegalidade> avaliar(Decklist decklist, Formato formato) {
    final total = decklist.totalCards;
    if (total != 60) {
      return [
        ViolacaoLegalidade(
          codigo: 'SESSENTA_CARTAS',
          mensagem: 'A decklist possui $total cartas (o obrigatório são exatamente 60 cartas).',
        ),
      ];
    }
    return const [];
  }
}

/// Regra 2: Máximo de 4 cópias por Carta Canônica (agrupando reimpressões, exceto Energia Básica) - RN-02 / US-06
class RegraQuatroCopias implements RegraDeLegalidade {
  @override
  List<ViolacaoLegalidade> avaliar(Decklist decklist, Formato formato) {
    final violacoes = <ViolacaoLegalidade>[];
    final contagemCanonica = <String, int>{};
    final ehBasica = <String, bool>{};

    for (final card in decklist.cards) {
      final nomeCanonico = card.canonical.name;
      contagemCanonica[nomeCanonico] = (contagemCanonica[nomeCanonico] ?? 0) + card.quantity;
      ehBasica[nomeCanonico] = card.canonical.isBasicEnergy;
    }

    for (final entry in contagemCanonica.entries) {
      if (ehBasica[entry.key] == true) continue;
      if (entry.value > 4) {
        violacoes.add(
          ViolacaoLegalidade(
            codigo: 'QUATRO_COPIAS',
            mensagem: 'A carta "${entry.key}" possui ${entry.value} cópias somadas (máximo permitido: 4).',
            cartaRelacionada: entry.key,
          ),
        );
      }
    }
    return violacoes;
  }
}

/// Regra 3: Máximo de 1 carta ACE SPEC no baralho
class RegraAceSpecUnica implements RegraDeLegalidade {
  @override
  List<ViolacaoLegalidade> avaliar(Decklist decklist, Formato formato) {
    final aceSpecs = decklist.cards.where((c) => c.canonical.isAceSpec).toList();
    final totalAce = aceSpecs.fold(0, (s, c) => s + c.quantity);
    if (totalAce > 1) {
      final nomes = aceSpecs.map((c) => '${c.quantity}x ${c.name}').join(', ');
      return [
        ViolacaoLegalidade(
          codigo: 'ACE_SPEC_UNICA',
          mensagem: 'Deck contém $totalAce cartas ACE SPEC ($nomes). Máximo permitido: 1.',
        ),
      ];
    }
    return const [];
  }
}

/// Regra 4: Máximo de 1 Pokémon Radiante no baralho
class RegraRadianteUnico implements RegraDeLegalidade {
  @override
  List<ViolacaoLegalidade> avaliar(Decklist decklist, Formato formato) {
    final radiantes = decklist.cards.where((c) => c.canonical.isRadiant).toList();
    final totalRad = radiantes.fold(0, (s, c) => s + c.quantity);
    if (totalRad > 1) {
      final nomes = radiantes.map((c) => '${c.quantity}x ${c.name}').join(', ');
      return [
        ViolacaoLegalidade(
          codigo: 'RADIANTE_UNICO',
          mensagem: 'Deck contém $totalRad Pokémon Radiantes ($nomes). Máximo permitido: 1.',
        ),
      ];
    }
    return const [];
  }
}

/// Regra 5: Marca de Regulação compatível com o Formato vigente na data do torneio (RN-01 / US-06)
class RegraMarcaDeRegulacao implements RegraDeLegalidade {
  @override
  List<ViolacaoLegalidade> avaliar(Decklist decklist, Formato formato) {
    final violacoes = <ViolacaoLegalidade>[];
    for (final card in decklist.cards) {
      if (card.canonical.isBasicEnergy) continue;
      if (!formato.marcasPermitidas.contains(card.regulationMark.toUpperCase())) {
        violacoes.add(
          ViolacaoLegalidade(
            codigo: 'FORA_DO_FORMATO',
            mensagem:
                'A carta "${card.name}" (${card.setCode ?? "?"}) possui marca "${card.regulationMark}", inválida para ${formato.nome}.',
            cartaRelacionada: card.name,
          ),
        );
      }
    }
    return violacoes;
  }
}

/// Regra 6: Verificação de Banlist do formato
class RegraBanlist implements RegraDeLegalidade {
  @override
  List<ViolacaoLegalidade> avaliar(Decklist decklist, Formato formato) {
    final violacoes = <ViolacaoLegalidade>[];
    final banLower = formato.banlist.map((b) => b.toLowerCase()).toSet();

    for (final card in decklist.cards) {
      if (banLower.contains(card.canonical.name.toLowerCase())) {
        violacoes.add(
          ViolacaoLegalidade(
            codigo: 'BANLIST',
            mensagem: 'A carta "${card.name}" está banida no formato ${formato.nome}.',
            cartaRelacionada: card.name,
          ),
        );
      }
    }
    return violacoes;
  }
}

/// Validador Composto de Decklist (Fase 4.4)
class ValidadorDeDecklist {
  final List<RegraDeLegalidade> _regras;

  ValidadorDeDecklist({List<RegraDeLegalidade>? regras})
      : _regras = regras ??
            [
              RegraSessentaCartas(),
              RegraQuatroCopias(),
              RegraAceSpecUnica(),
              RegraRadianteUnico(),
              RegraMarcaDeRegulacao(),
              RegraBanlist(),
            ];

  ResultadoValidacao validar(Decklist decklist, Formato formato) {
    final todasViolacoes = <ViolacaoLegalidade>[];
    for (final regra in _regras) {
      todasViolacoes.addAll(regra.avaliar(decklist, formato));
    }

    final totalAce = decklist.cards
        .where((c) => c.canonical.isAceSpec)
        .fold(0, (s, c) => s + c.quantity);
    final totalRad = decklist.cards
        .where((c) => c.canonical.isRadiant)
        .fold(0, (s, c) => s + c.quantity);

    final isValida = todasViolacoes.isEmpty;
    final novoStatus = isValida ? DecklistStatus.valida : DecklistStatus.invalida;

    return ResultadoValidacao(
      isValida: isValida,
      violacoes: todasViolacoes,
      totalCartas: decklist.totalCards,
      totalAceSpec: totalAce,
      totalRadiantes: totalRad,
      decklistAtualizada: decklist.copyWith(status: novoStatus),
    );
  }
}
