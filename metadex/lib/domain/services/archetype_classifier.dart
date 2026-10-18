import 'dart:math' as math;
import '../models/deck.dart';

class Arquetipo {
  final String id;
  final String nome;
  final String slug;
  final List<String> cartasAssinatura;
  final int prioridade;
  final String imagemRepresentativa;
  final Map<String, int> centroide;

  const Arquetipo({
    required this.id,
    required this.nome,
    required this.slug,
    required this.cartasAssinatura,
    required this.prioridade,
    required this.imagemRepresentativa,
    required this.centroide,
  });

  static List<Arquetipo> catalogoPadrao() {
    return const [
      Arquetipo(
        id: 'arq_zard_dusknoir',
        nome: 'Charizard ex / Dusknoir',
        slug: 'charizard-dusknoir',
        cartasAssinatura: ['Charizard ex', 'Dusknoir'],
        prioridade: 1,
        imagemRepresentativa: 'https://images.pokemontcg.io/sv4pt5/54.png',
        centroide: {
          'Charizard ex': 3,
          'Charmander': 4,
          'Dusknoir': 2,
          'Dusclops': 2,
          'Rare Candy': 4,
          'Buddy-Buddy Poffin': 4,
          'Ultra Ball': 4,
          'Arven': 4,
          'Iono': 3,
          "Boss's Orders": 2,
          'Super Rod': 2,
          'Basic Fire Energy': 6,
        },
      ),
      Arquetipo(
        id: 'arq_zard_pidgeot',
        nome: 'Charizard ex / Pidgeot ex',
        slug: 'charizard-pidgeot',
        cartasAssinatura: ['Charizard ex', 'Pidgeot ex'],
        prioridade: 2,
        imagemRepresentativa: 'https://images.pokemontcg.io/sv4pt5/54.png',
        centroide: {
          'Charizard ex': 3,
          'Charmander': 4,
          'Pidgeot ex': 2,
          'Pidgey': 2,
          'Rare Candy': 4,
          'Buddy-Buddy Poffin': 4,
          'Ultra Ball': 4,
          'Arven': 4,
          'Iono': 3,
          "Boss's Orders": 2,
          'Super Rod': 2,
          'Basic Fire Energy': 6,
        },
      ),
      Arquetipo(
        id: 'arq_terapagos_noctowl',
        nome: 'Terapagos ex / Noctowl',
        slug: 'terapagos-noctowl',
        cartasAssinatura: ['Terapagos ex', 'Noctowl'],
        prioridade: 3,
        imagemRepresentativa: 'https://images.pokemontcg.io/sv7/128.png',
        centroide: {
          'Terapagos ex': 3,
          'Noctowl': 3,
          'Hoothoot': 3,
          'Fan Rotom': 1,
          'Bouffalant': 2,
          'Area Zero Underdepths': 4,
          'Buddy-Buddy Poffin': 4,
          'Ultra Ball': 4,
          'Nest Ball': 4,
          'Basic Grass Energy': 5,
        },
      ),
      Arquetipo(
        id: 'arq_dragapult',
        nome: 'Dragapult ex',
        slug: 'dragapult-ex',
        cartasAssinatura: ['Dragapult ex'],
        prioridade: 2,
        imagemRepresentativa: 'https://images.pokemontcg.io/sv6/130.png',
        centroide: {
          'Dragapult ex': 3,
          'Drakloak': 4,
          'Dreepy': 4,
          'Buddy-Buddy Poffin': 4,
          'Ultra Ball': 4,
          'Rare Candy': 3,
          'Arven': 4,
          'Iono': 3,
          'Crispin': 2,
          'Basic Fire Energy': 3,
          'Basic Psychic Energy': 3,
        },
      ),
      Arquetipo(
        id: 'arq_gardevoir',
        nome: 'Gardevoir ex',
        slug: 'gardevoir-ex',
        cartasAssinatura: ['Gardevoir ex', 'Kirlia'],
        prioridade: 3,
        imagemRepresentativa: 'https://images.pokemontcg.io/sv1/86.png',
        centroide: {
          'Gardevoir ex': 2,
          'Kirlia': 4,
          'Ralts': 4,
          'Munkidori': 1,
          'Scream Tail': 1,
          'Drifloon': 1,
          'Buddy-Buddy Poffin': 4,
          'Ultra Ball': 4,
          'Iono': 4,
          'Arven': 4,
          'Basic Psychic Energy': 9,
        },
      ),
      Arquetipo(
        id: 'arq_raging_bolt',
        nome: 'Raging Bolt ex / Ogerpon ex',
        slug: 'raging-bolt-ogerpon',
        cartasAssinatura: ['Raging Bolt ex', 'Teal Mask Ogerpon ex'],
        prioridade: 4,
        imagemRepresentativa: 'https://images.pokemontcg.io/sv5/123.png',
        centroide: {
          'Raging Bolt ex': 4,
          'Teal Mask Ogerpon ex': 4,
          'Squawkabilly ex': 1,
          'Nest Ball': 4,
          'Earthen Vessel': 4,
          "Professor's Research": 4,
          'Energy Retrieval': 3,
          'Basic Grass Energy': 6,
          'Basic Fighting Energy': 3,
          'Basic Lightning Energy': 3,
        },
      ),
      Arquetipo(
        id: 'arq_chien_pao',
        nome: 'Chien-Pao ex / Baxcalibur',
        slug: 'chien-pao-baxcalibur',
        cartasAssinatura: ['Chien-Pao ex', 'Baxcalibur'],
        prioridade: 5,
        imagemRepresentativa: 'https://images.pokemontcg.io/sv2/61.png',
        centroide: {
          'Chien-Pao ex': 3,
          'Baxcalibur': 3,
          'Frigibax': 3,
          'Irida': 4,
          'Superior Energy Retrieval': 4,
          'Rare Candy': 4,
          'Ultra Ball': 4,
          'Buddy-Buddy Poffin': 4,
          'Basic Water Energy': 8,
        },
      ),
      Arquetipo(
        id: 'arq_lugia',
        nome: 'Lugia VSTAR / Archeops',
        slug: 'lugia-vstar',
        cartasAssinatura: ['Lugia VSTAR', 'Archeops'],
        prioridade: 6,
        imagemRepresentativa: 'https://images.pokemontcg.io/swsh12/139.png',
        centroide: {
          'Lugia VSTAR': 3,
          'Lugia V': 3,
          'Archeops': 4,
          'Cinccino': 2,
          'Minccino': 3,
          'Ultra Ball': 4,
          'Capturing Aroma': 4,
          'Jet Energy': 4,
        },
      ),
      Arquetipo(
        id: 'arq_regidrago',
        nome: 'Regidrago VSTAR',
        slug: 'regidrago-vstar',
        cartasAssinatura: ['Regidrago VSTAR', 'Teal Mask Ogerpon ex'],
        prioridade: 7,
        imagemRepresentativa: 'https://images.pokemontcg.io/swsh12/136.png',
        centroide: {
          'Regidrago VSTAR': 3,
          'Regidrago V': 3,
          'Teal Mask Ogerpon ex': 4,
          'Dragapult ex': 1,
          'Ultra Ball': 4,
          'Nest Ball': 4,
          'Earthen Vessel': 4,
          "Professor's Research": 4,
          'Basic Grass Energy': 7,
          'Basic Fire Energy': 3,
        },
      ),
      Arquetipo(
        id: 'arq_miraidon',
        nome: 'Miraidon ex / Iron Hands ex',
        slug: 'miraidon-ex',
        cartasAssinatura: ['Miraidon ex'],
        prioridade: 8,
        imagemRepresentativa: 'https://images.pokemontcg.io/sv1/81.png',
        centroide: {
          'Miraidon ex': 3,
          'Iron Hands ex': 2,
          'Raikou V': 1,
          'Electric Generator': 4,
          'Nest Ball': 4,
          'Ultra Ball': 3,
          'Arven': 3,
          "Boss's Orders": 3,
          'Basic Lightning Energy': 14,
        },
      ),
      Arquetipo(
        id: 'arq_snorlax',
        nome: 'Snorlax Stall',
        slug: 'snorlax-stall',
        cartasAssinatura: ['Snorlax'],
        prioridade: 9,
        imagemRepresentativa: 'https://images.pokemontcg.io/pgo/55.png',
        centroide: {
          'Snorlax': 4,
          'Rotom V': 2,
          'Pidgeot V': 1,
          'Nest Ball': 4,
          'Counter Catcher': 4,
          'Pokegear 3.0': 4,
          'Arven': 4,
          'Penny': 3,
        },
      ),
      Arquetipo(
        id: 'arq_roaring_moon',
        nome: 'Roaring Moon',
        slug: 'roaring-moon',
        cartasAssinatura: ['Roaring Moon ex'],
        prioridade: 10,
        imagemRepresentativa: 'https://images.pokemontcg.io/sv4/124.png',
        centroide: {
          'Roaring Moon ex': 3,
          'Roaring Moon': 2,
          'Dark Patch': 4,
          'Professor Sada\'s Vitality': 4,
          'Earthen Vessel': 4,
          'Nest Ball': 4,
          'Ultra Ball': 4,
          'Basic Darkness Energy': 10,
        },
      ),
    ];
  }
}

class ClassificacaoArquetipo {
  final Arquetipo arquetipo;
  final double confianca;
  final bool requerCuradoria;
  final String metodo;

  const ClassificacaoArquetipo({
    required this.arquetipo,
    required this.confianca,
    required this.requerCuradoria,
    required this.metodo,
  });
}

abstract class ClassificadorDeArquetipo {
  ClassificacaoArquetipo? classificar(Decklist decklist, List<Arquetipo> catalogo);
}

/// 1. Classificador por Assinatura Determinístico (Fase 6.4)
class ClassificadorPorAssinatura implements ClassificadorDeArquetipo {
  @override
  ClassificacaoArquetipo? classificar(Decklist decklist, List<Arquetipo> catalogo) {
    final sorted = List<Arquetipo>.from(catalogo)
      ..sort((a, b) => a.prioridade.compareTo(b.prioridade));

    final nomesNoDeck = decklist.cards
        .map((c) => c.canonical.name.toLowerCase())
        .toSet();

    for (final arq in sorted) {
      final possuiTodas = arq.cartasAssinatura.every(
        (sig) => nomesNoDeck.any((n) => n.contains(sig.toLowerCase())),
      );
      if (possuiTodas) {
        final jaccard = ClassificadorPorSimilaridade.calcularJaccardPonderado(
          decklist.countVector,
          arq.centroide,
        );
        final confianca = (0.75 + 0.25 * jaccard).clamp(0.75, 1.0);
        return ClassificacaoArquetipo(
          arquetipo: arq,
          confianca: confianca,
          requerCuradoria: false,
          metodo: 'Assinatura Determinística',
        );
      }
    }
    return null;
  }
}

/// 2. Classificador por Similaridade de Jaccard Ponderada (Fase 6.4)
/// J_w(a, b) = sum_c min(a_c, b_c) / sum_c max(a_c, b_c)
class ClassificadorPorSimilaridade implements ClassificadorDeArquetipo {
  final double limiarMinimo;

  const ClassificadorPorSimilaridade({this.limiarMinimo = 0.55});

  static double calcularJaccardPonderado(Map<String, int> a, Map<String, int> b) {
    final todasChaves = <String>{
      ...a.keys.map((k) => k.toLowerCase()),
      ...b.keys.map((k) => k.toLowerCase()),
    };
    if (todasChaves.isEmpty) return 0.0;

    final mapALower = {for (final e in a.entries) e.key.toLowerCase(): e.value};
    final mapBLower = {for (final e in b.entries) e.key.toLowerCase(): e.value};

    double somaMin = 0;
    double somaMax = 0;

    for (final k in todasChaves) {
      final va = mapALower[k] ?? 0;
      final vb = mapBLower[k] ?? 0;
      somaMin += math.min(va, vb);
      somaMax += math.max(va, vb);
    }

    if (somaMax == 0) return 0.0;
    return somaMin / somaMax;
  }

  @override
  ClassificacaoArquetipo? classificar(Decklist decklist, List<Arquetipo> catalogo) {
    if (catalogo.isEmpty || decklist.cards.isEmpty) return null;

    Arquetipo? melhorArq;
    double melhorScore = -1.0;
    final vetorDeck = decklist.countVector;

    for (final arq in catalogo) {
      final score = calcularJaccardPonderado(vetorDeck, arq.centroide);
      if (score > melhorScore) {
        melhorScore = score;
        melhorArq = arq;
      }
    }

    if (melhorArq == null) return null;

    final requerCuradoria = melhorScore < limiarMinimo;
    return ClassificacaoArquetipo(
      arquetipo: melhorArq,
      confianca: melhorScore,
      requerCuradoria: requerCuradoria,
      metodo: requerCuradoria
          ? 'Similaridade Baixa (Requer Curadoria)'
          : 'Similaridade de Jaccard Ponderada',
    );
  }
}

/// 3. Classificador Composto Híbrido (Assinatura -> Similaridade -> Fila de Curadoria)
class ClassificadorComposto {
  final List<Arquetipo> catalogo;
  final ClassificadorPorAssinatura _porAssinatura;
  final ClassificadorPorSimilaridade _porSimilaridade;

  ClassificadorComposto({
    List<Arquetipo>? catalogo,
    double limiarMinimo = 0.55,
  })  : catalogo = catalogo ?? Arquetipo.catalogoPadrao(),
        _porAssinatura = ClassificadorPorAssinatura(),
        _porSimilaridade = ClassificadorPorSimilaridade(limiarMinimo: limiarMinimo);

  ClassificacaoArquetipo classificar(Decklist decklist) {
    final resAssinatura = _porAssinatura.classificar(decklist, catalogo);
    if (resAssinatura != null) return resAssinatura;

    final resSimilaridade = _porSimilaridade.classificar(decklist, catalogo);
    if (resSimilaridade != null) return resSimilaridade;

    const rogue = Arquetipo(
      id: 'arq_rogue',
      nome: 'Rogue / Outro',
      slug: 'rogue-outro',
      cartasAssinatura: [],
      prioridade: 999,
      imagemRepresentativa: 'https://images.pokemontcg.io/sv1/196.png',
      centroide: {},
    );
    return const ClassificacaoArquetipo(
      arquetipo: rogue,
      confianca: 0.0,
      requerCuradoria: true,
      metodo: 'Não Identificado (Fila de Curadoria)',
    );
  }
}
