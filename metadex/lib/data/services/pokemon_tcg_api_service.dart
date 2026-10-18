import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../domain/models/deck.dart';

class PokemonTcgApiService {
  static const String _baseUrl = 'https://api.pokemontcg.io/v2';

  /// Busca a imagem da carta baseado no código da coleção (ex: OBF, SVI) e no número (ex: 125)
  Future<String?> fetchCardImageUrl(String setCode, String setNumber, {String cardName = ''}) async {
    // 1. Tenta resolver estaticamente pela tabela de sets oficiais da CDN pokemontcg.io (instantâneo)
    final staticUrl = DeckCard.resolveStaticCardImageUrl(setCode, setNumber, cardName);
    if (staticUrl != null) return staticUrl;

    // 2. Fallback via requisição HTTP à API pokemontcg.io
    try {
      final url = Uri.parse('$_baseUrl/cards?q=set.ptcgoCode:$setCode number:$setNumber');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final list = data['data'] as List<dynamic>?;
        if (list != null && list.isNotEmpty) {
          final first = list.first as Map<String, dynamic>;
          final images = first['images'] as Map<String, dynamic>?;
          return (images?['small'] ?? images?['large']) as String?;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao buscar imagem da carta: $e');
      return null;
    }
  }
}
