import '../../data/services/pokemon_tcg_api_service.dart';

enum CardType { pokemon, trainer, energy }

enum CardRoleClass { core, padrao, tech }

enum DecklistStatus {
  recebida,
  parseada,
  erroDeParsing,
  valida,
  invalida,
  classificada,
  aguardandoCuradoria,
  aprovada,
}

/// Representa a identidade funcional única de uma carta (RN-02),
/// agrupando reimpressões de coleções diferentes sob o mesmo nome funcional.
class CartaCanonica {
  final String name;
  final String functionalHash;
  final bool isAceSpec;
  final bool isRadiant;
  final bool isBasicEnergy;

  const CartaCanonica({
    required this.name,
    required this.functionalHash,
    this.isAceSpec = false,
    this.isRadiant = false,
    this.isBasicEnergy = false,
  });

  factory CartaCanonica.fromCardDetails({
    required String name,
    required CardType type,
  }) {
    final normalized = _normalizeCardName(name);
    final isAce = _knownAceSpecs.contains(normalized.toLowerCase()) ||
        normalized.toLowerCase().contains('ace spec');
    final isRad = normalized.toLowerCase().startsWith('radiant ') ||
        normalized.toLowerCase().contains(' radiante');
    final isBasicEn = type == CardType.energy &&
        (normalized.toLowerCase().startsWith('basic ') ||
            normalized.toLowerCase().startsWith('energia básica') ||
            normalized.toLowerCase().startsWith('energia basica') ||
            _basicEnergyNames.contains(normalized.toLowerCase()));

    return CartaCanonica(
      name: normalized,
      functionalHash: 'canon_${normalized.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}',
      isAceSpec: isAce,
      isRadiant: isRad,
      isBasicEnergy: isBasicEn,
    );
  }

  String get canonicalKey => name.toLowerCase();

  static String _normalizeCardName(String rawName) {
    var cleaned = rawName.trim();
    // Normaliza variações de energia básica do PTCG Live (ex: "Basic {R} Energy" -> "Basic Fire Energy")
    final energyMap = {
      '{r}': 'Fire',
      '{w}': 'Water',
      '{g}': 'Grass',
      '{l}': 'Lightning',
      '{p}': 'Psychic',
      '{f}': 'Fighting',
      '{d}': 'Darkness',
      '{m}': 'Metal',
    };
    for (final entry in energyMap.entries) {
      if (cleaned.toLowerCase().contains(entry.key)) {
        cleaned = cleaned.replaceAll(RegExp(entry.key, caseSensitive: false), entry.value);
      }
    }
    // Mapeia nomes comuns em PT-BR para chave canônica unificada se necessário
    final ptBrAliases = {
      'bola ultra': 'Ultra Ball',
      'bola de ninho': 'Nest Ball',
      'doce raro': 'Rare Candy',
      'poffin de colega': 'Buddy-Buddy Poffin',
      'ordens da chefia': "Boss's Orders",
      'pesquisa de professores': "Professor's Research",
      'juiz': 'Judge',
      'supervara': 'Super Rod',
      'pegador supremo': 'Prime Catcher',
      'carimbo injusto': 'Unfair Stamp',
      'charizard radiante': 'Radiant Charizard',
      'greninja radiante': 'Radiant Greninja',
      'alakazam radiante': 'Radiant Alakazam',
    };
    final lower = cleaned.toLowerCase();
    if (ptBrAliases.containsKey(lower)) {
      return ptBrAliases[lower]!;
    }
    return cleaned.replaceAll(RegExp(r'\s+'), ' ');
  }

  static const Set<String> _knownAceSpecs = {
    'prime catcher',
    'unfair stamp',
    'secret box',
    'maximum belt',
    "hero's cape",
    'legacy energy',
    'sparkling crystal',
    'precious trolley',
    'brilliant blender',
    'primeira captura',
    'pegador supremo',
    'carimbo injusto',
    'master ball',
    'hyper aroma',
    'neutralization zone',
    'scoop up cyclone',
    'survival brace',
    'grand tree',
    'deluxe bomb',
    'awakening drum',
    'reboot pod',
    'neo upper energy',
    'enriching energy',
  };

  static const Set<String> _basicEnergyNames = {
    'fire energy',
    'water energy',
    'grass energy',
    'lightning energy',
    'psychic energy',
    'fighting energy',
    'darkness energy',
    'metal energy',
    'basic fire energy',
    'basic water energy',
    'basic grass energy',
    'basic lightning energy',
    'basic psychic energy',
    'basic fighting energy',
    'basic darkness energy',
    'basic metal energy',
  };
}

class DeckCard {
  final String name;
  final int quantity;
  final String? setCode;
  final String? setNumber;
  final CardType type;
  final String regulationMark;
  final CartaCanonica canonical;
  final CardRoleClass? roleClass;
  String? imageUrl;

  DeckCard({
    required this.name,
    required this.quantity,
    required this.type,
    this.setCode,
    this.setNumber,
    String? regulationMark,
    CartaCanonica? canonical,
    this.roleClass,
    String? imageUrl,
  })  : canonical = canonical ?? CartaCanonica.fromCardDetails(name: name, type: type),
        regulationMark = regulationMark ?? _inferRegulationMark(setCode, name, type),
        imageUrl = imageUrl ?? resolveStaticCardImageUrl(setCode, setNumber, name);

  int get count => quantity;

  static String _inferRegulationMark(String? setCode, String name, CardType type) {
    final canon = CartaCanonica.fromCardDetails(name: name, type: type);
    if (canon.isBasicEnergy) return 'H';

    final code = setCode?.toUpperCase() ?? '';
    // Sets Sword & Shield (marcas D, E, F - válidas apenas no Expanded)
    const fSets = {
      'BRS', 'ASR', 'PGO', 'LOR', 'SIT', 'CRZ', 'FST', 'EVS',
      'CRE', 'BST', 'SHF', 'VIV', 'CPA', 'DAA', 'RCL', 'SSH',
    };
    if (fSets.contains(code) || canon.isRadiant) return 'F';

    // Sets com marca J (2026+)
    const jSets = {'MEG', 'asc', 'J01', 'J02', 'SV11', 'SV12'};
    if (jSets.contains(code)) return 'J';

    // Sets com marca I (2025-2026)
    const iSets = {'JTG', 'DRI', 'PRE', 'SV9', 'SV10'};
    if (iSets.contains(code)) return 'I';

    // Sets com marca H (TEF, TWM, SFA, SCR, SSP)
    const hSets = {'TEF', 'TWM', 'SFA', 'SCR', 'SSP', 'SV5', 'SV6', 'SV7', 'SV8'};
    if (hSets.contains(code)) return 'H';

    // Equivalência Funcional (RN-02): Staples de Treinadores reimpressos no bloco H-I-J
    // permanecem válidos em Standard (H-I-J) mesmo usando print antigo (ex: Ultra Ball SVI)
    const reprintedInHIJ = {
      'ultra ball',
      'nest ball',
      'rare candy',
      'buddy-buddy poffin',
      'arven',
      'iono',
      "boss's orders",
      "professor's research",
      'super rod',
      'counter catcher',
      'earthen vessel',
      "professor turo's scenario",
      'night stretcher',
      'prime catcher',
      'unfair stamp',
      'fezandipiti ex',
      'charizard ex',
      'charmander',
      'charmeleon',
      'pidgeot ex',
      'pidgey',
      'dragapult ex',
      'drakloak',
      'dreepy',
      'dusknoir',
      'dusclops',
      'duskull',
      'raging bolt ex',
      'teal mask ogerpon ex',
      'munkidori',
      'scream tail',
      'flutter mane',
      'bravery charm',
      'terapagos ex',
      'noctowl',
      'hoothoot',
      'fan rotom',
      'bouffalant',
      'area zero underdepths',
      'briar',
      'crispin',
      'sandy shocks ex',
      'pokégear 3.0',
      'energy retrieval',
      'superior energy retrieval',
      'switch',
    };
    if (reprintedInHIJ.contains(canon.canonicalKey)) {
      return 'H';
    }

    // Demais cartas exclusivas do bloco G (rotacionadas do Standard H-I-J, válidas em Expanded / G-H-I)
    const gSets = {'SVI', 'SV1', 'PAL', 'OBF', 'MEW', 'PAR', 'PAF', 'SVE', 'PR-SV'};
    if (gSets.contains(code)) return 'G';

    return 'H';
  }

  /// Resolve deterministicamente a URL de imagem da API pokemontcg.io
  /// mapeando códigos do PTCG Live (ex: OBF, SVI, PAL, PAF, PAR) para IDs reais de sets.
  static String? resolveStaticCardImageUrl(String? setCode, String? setNumber, String cardName) {
    if (setCode != null && setNumber != null && setCode.isNotEmpty && setNumber.isNotEmpty) {
      final apiSetId = _ptcgoToApiSetId[setCode.toUpperCase()];
      if (apiSetId != null) {
        return 'https://images.pokemontcg.io/$apiSetId/$setNumber.png';
      }
    }
    // Fallback por nome das cartas mais icônicas do metagame
    final lower = cardName.toLowerCase();
    for (final entry in _iconicCardImages.entries) {
      if (lower.contains(entry.key)) {
        return entry.value;
      }
    }
    return null;
  }

  static const Map<String, String> _ptcgoToApiSetId = {
    'SVI': 'sv1',
    'SV1': 'sv1',
    'PAL': 'sv2',
    'OBF': 'sv3',
    'MEW': 'sv3pt5',
    'PAR': 'sv4',
    'PAF': 'sv4pt5',
    'TEF': 'sv5',
    'TWM': 'sv6',
    'SFA': 'sv6pt5',
    'SCR': 'sv7',
    'SSP': 'sv8',
    'SVE': 'sve',
    'BRS': 'swsh9',
    'ASR': 'swsh10',
    'PGO': 'pgo',
    'LOR': 'swsh11',
    'SIT': 'swsh12',
    'CRZ': 'swsh12pt5',
    'FST': 'swsh8',
    'EVS': 'swsh7',
  };

  static const Map<String, String> _iconicCardImages = {
    'charizard ex': 'https://images.pokemontcg.io/sv4pt5/54.png',
    'pidgeot ex': 'https://images.pokemontcg.io/sv3/164.png',
    'dragapult ex': 'https://images.pokemontcg.io/sv6/130.png',
    'gardevoir ex': 'https://images.pokemontcg.io/sv1/86.png',
    'raging bolt ex': 'https://images.pokemontcg.io/sv5/123.png',
    'ogerpon ex': 'https://images.pokemontcg.io/sv6/25.png',
    'teal mask ogerpon': 'https://images.pokemontcg.io/sv6/25.png',
    'chien-pao ex': 'https://images.pokemontcg.io/sv2/61.png',
    'lugia vstar': 'https://images.pokemontcg.io/swsh12/139.png',
    'archeops': 'https://images.pokemontcg.io/swsh12/147.png',
    'regidrago vstar': 'https://images.pokemontcg.io/swsh12/136.png',
    'miraidon ex': 'https://images.pokemontcg.io/sv1/81.png',
    'roaring moon': 'https://images.pokemontcg.io/sv4/124.png',
    'iron hands ex': 'https://images.pokemontcg.io/sv4/70.png',
    'iron thorns ex': 'https://images.pokemontcg.io/sv6/77.png',
    'snorlax': 'https://images.pokemontcg.io/pgo/55.png',
    'comfey': 'https://images.pokemontcg.io/swsh11/79.png',
    'sableye': 'https://images.pokemontcg.io/swsh11/70.png',
    'terapagos ex': 'https://images.pokemontcg.io/sv7/128.png',
    'gholdengo ex': 'https://images.pokemontcg.io/sv4/139.png',
  };

  DeckCard copyWith({
    String? name,
    int? quantity,
    String? setCode,
    String? setNumber,
    CardType? type,
    String? regulationMark,
    CartaCanonica? canonical,
    CardRoleClass? roleClass,
    String? imageUrl,
  }) {
    return DeckCard(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      setCode: setCode ?? this.setCode,
      setNumber: setNumber ?? this.setNumber,
      type: type ?? this.type,
      regulationMark: regulationMark ?? this.regulationMark,
      canonical: canonical ?? this.canonical,
      roleClass: roleClass ?? this.roleClass,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

class Decklist {
  final String id;
  final List<DeckCard> cards;
  final DecklistStatus status;
  final String rawText;
  final int version;
  final List<String> unrecognizedLines;
  final List<String> parsingSuggestions;

  Decklist({
    String? id,
    required this.cards,
    this.status = DecklistStatus.parseada,
    this.rawText = '',
    this.version = 1,
    this.unrecognizedLines = const [],
    this.parsingSuggestions = const [],
  }) : id = id ?? 'dl_${DateTime.now().microsecondsSinceEpoch}';

  List<DeckCard> get pokemons => cards.where((c) => c.type == CardType.pokemon).toList();
  List<DeckCard> get trainers => cards.where((c) => c.type == CardType.trainer).toList();
  List<DeckCard> get energies => cards.where((c) => c.type == CardType.energy).toList();

  int get totalCards => cards.fold(0, (sum, c) => sum + c.quantity);

  /// Soma as cópias agrupadas pela Carta Canônica (RN-02: reimpressões somam juntas)
  int copiesOfCanonical(String canonicalName) {
    final target = canonicalName.toLowerCase().trim();
    return cards
        .where((c) => c.canonical.name.toLowerCase() == target)
        .fold(0, (sum, c) => sum + c.quantity);
  }

  /// Vetor de contagem v_d sobre o espaço de cartas canônicas (Fase 6.4)
  Map<String, int> get countVector {
    final map = <String, int>{};
    for (final c in cards) {
      final key = c.canonical.name;
      map[key] = (map[key] ?? 0) + c.quantity;
    }
    return map;
  }

  Decklist copyWith({
    String? id,
    List<DeckCard>? cards,
    DecklistStatus? status,
    String? rawText,
    int? version,
    List<String>? unrecognizedLines,
    List<String>? parsingSuggestions,
  }) {
    return Decklist(
      id: id ?? this.id,
      cards: cards ?? this.cards,
      status: status ?? this.status,
      rawText: rawText ?? this.rawText,
      version: version ?? this.version,
      unrecognizedLines: unrecognizedLines ?? this.unrecognizedLines,
      parsingSuggestions: parsingSuggestions ?? this.parsingSuggestions,
    );
  }

  /// Carrega assincronamente as imagens das cartas usando a API pokemontcg.io caso não resolvidas estaticamente
  Future<void> fetchCardImages(PokemonTcgApiService apiService) async {
    for (var card in cards) {
      if (card.setCode != null && card.setNumber != null && card.imageUrl == null) {
        card.imageUrl = await apiService.fetchCardImageUrl(card.setCode!, card.setNumber!);
      }
    }
  }
}

class PtcgLiveParser {
  static const List<String> _knownStapleCatalog = [
    'Ultra Ball SVI 196',
    'Nest Ball SVI 181',
    'Rare Candy SVI 191',
    'Buddy-Buddy Poffin TEF 144',
    "Boss's Orders PAL 172",
    'Iono PAL 185',
    'Arven SVI 166',
    "Professor's Research SVI 189",
    'Super Rod PAL 188',
    'Prime Catcher TEF 157',
    'Unfair Stamp TWM 165',
    'Counter Catcher PAR 160',
    'Night Stretcher SFA 61',
    'Fezandipiti ex SFA 38',
    'Radiant Charizard CRZ 20',
    'Radiant Greninja ASR 46',
    'Charizard ex OBF 125',
    'Pidgeot ex OBF 164',
    'Dragapult ex TWM 130',
    'Gardevoir ex SVI 86',
    'Raging Bolt ex TEF 123',
    'Teal Mask Ogerpon ex TWM 25',
  ];

  /// Faz o parse de uma string no formato exportado do PTCG Live (PT-BR ou EN) ou texto de PDF de decklist
  static Decklist parse(String exportString) {
    final parsedCards = <DeckCard>[];
    final unrecognized = <String>[];
    final suggestions = <String>[];
    CardType currentSection = CardType.pokemon;

    // Regex tolerante (Fase 6.3):
    // Aceita: "4 Arceus VSTAR BRS 123", "1 Basic {R} Energy SVE 2", "2 Ultra Ball", "3x Charizard ex OBF 125"
    final lineRegex = RegExp(
      r'^(\d+)x?\s+(.+?)(?:\s+([A-Za-z]{2,4}(?:-[A-Za-z0-9]+)?)\s+(\d+[a-zA-Z]*))?$',
    );

    final lines = exportString.split(RegExp(r'\r?\n'));

    for (var rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      final lower = line.toLowerCase();

      // Ignora rodapés de "Total Cards: 60" ou "Total de cartas: 60"
      if (lower.startsWith('total cards') || lower.startsWith('total de cartas')) {
        continue;
      }

      // Identifica cabeçalhos de seção em PT-BR e EN (Fase 6.3)
      if (lower.startsWith('pokémon') || lower.startsWith('pokemon')) {
        currentSection = CardType.pokemon;
        continue;
      } else if (lower.startsWith('trainer') ||
          lower.startsWith('treinador') ||
          lower.startsWith('supporter') ||
          lower.startsWith('item') ||
          lower.startsWith('stadium') ||
          lower.startsWith('tool')) {
        currentSection = CardType.trainer;
        continue;
      } else if (lower.startsWith('energy') || lower.startsWith('energia')) {
        currentSection = CardType.energy;
        continue;
      }

      final match = lineRegex.firstMatch(line);
      if (match != null) {
        final quantity = int.tryParse(match.group(1)!) ?? 0;
        final name = match.group(2)!.trim();
        final setCode = match.group(3)?.toUpperCase();
        final setNumber = match.group(4);

        if (quantity > 0 && name.isNotEmpty) {
          // Inferência automática de seção caso o usuário cole sem cabeçalhos
          var inferredType = currentSection;
          if (name.toLowerCase().contains('energy') || name.toLowerCase().contains('energia')) {
            inferredType = CardType.energy;
          } else if (_isLikelyTrainer(name) && currentSection == CardType.pokemon) {
            inferredType = CardType.trainer;
          }

          parsedCards.add(
            DeckCard(
              name: name,
              quantity: quantity,
              type: inferredType,
              setCode: setCode,
              setNumber: setNumber,
            ),
          );
          continue;
        }
      }

      // Linha não reconhecida -> gera sugestão por distância de Levenshtein (Fase 6.3)
      unrecognized.add(line);
      final closest = suggestClosestCard(line);
      if (closest != null) {
        suggestions.add('Linha "$line" não reconhecida. Você quis dizer "1 $closest"?');
      }
    }

    final status = unrecognized.isNotEmpty && parsedCards.isEmpty
        ? DecklistStatus.erroDeParsing
        : DecklistStatus.parseada;

    return Decklist(
      cards: parsedCards,
      status: status,
      rawText: exportString,
      unrecognizedLines: unrecognized,
      parsingSuggestions: suggestions,
    );
  }

  static bool _isLikelyTrainer(String name) {
    final l = name.toLowerCase();
    const trainerKeywords = [
      'ball',
      'candy',
      'poffin',
      'orders',
      'research',
      'iono',
      'arven',
      'rod',
      'catcher',
      'stamp',
      'stretcher',
      'vessel',
      'seal stone',
      'tm:',
      'technical machine',
      'pokéstop',
      'artazon',
      'turo',
      'penny',
      'roxanne',
      'judge',
      'briar',
      'crispin',
      'colress',
      'switch',
      'cart',
      'belt',
      'cape',
      'box',
    ];
    return trainerKeywords.any((k) => l.contains(k));
  }

  /// Sugere a carta mais próxima usando Distância de Levenshtein (Fase 6.3)
  static String? suggestClosestCard(String input) {
    final cleaned = input.replaceAll(RegExp(r'^\d+\s*'), '').trim().toLowerCase();
    if (cleaned.isEmpty) return null;

    String? bestMatch;
    int bestDistance = 999;

    for (final candidate in _knownStapleCatalog) {
      final candidateName = candidate.split(' ').sublist(0, candidate.split(' ').length - 2).join(' ').toLowerCase();
      final dist = levenshteinDistance(cleaned, candidateName);
      if (dist < bestDistance) {
        bestDistance = dist;
        bestMatch = candidate;
      }
    }
    return bestDistance <= 8 ? bestMatch : _knownStapleCatalog.first;
  }

  static int levenshteinDistance(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;

    List<int> v0 = List<int>.generate(t.length + 1, (i) => i);
    List<int> v1 = List<int>.filled(t.length + 1, 0);

    for (int i = 0; i < s.length; i++) {
      v1[0] = i + 1;
      for (int j = 0; j < t.length; j++) {
        final cost = (s[i] == t[j]) ? 0 : 1;
        final deletion = v0[j + 1] + 1;
        final insertion = v1[j] + 1;
        final substitution = v0[j] + cost;
        v1[j + 1] = [deletion, insertion, substitution].reduce((a, b) => a < b ? a : b);
      }
      for (int j = 0; j <= t.length; j++) {
        v0[j] = v1[j];
      }
    }
    return v1[t.length];
  }
}
