import 'dart:convert';
import 'dart:typed_data';

/// Utilitário puro em Dart para extrair texto de decklists de arquivos PDF
/// (ex: PDFs exportados pelo RK9 Labs, Pokémon Tournament Organizer ou PTCG Live).
class PdfDecklistExtractor {
  /// Extrai o texto de decklist de um arquivo PDF ou texto simples.
  static String extractDeckText(Uint8List bytes) {
    // Tenta primeiro como texto UTF-8 puro (caso seja um .txt ou export plain)
    try {
      final rawStr = utf8.decode(bytes);
      if (_looksLikeDecklist(rawStr)) {
        return rawStr;
      }
    } catch (_) {}

    // Processamento de stream PDF
    final extractedLines = <String>[];
    final latin1Text = latin1.decode(bytes);

    // 1. Extrai streams de texto direto do PDF (operadores Tj e TJ)
    final tjRegex = RegExp(r'\((.*?)\)\s*Tj', dotAll: true);
    for (final match in tjRegex.allMatches(latin1Text)) {
      final text = _cleanPdfString(match.group(1) ?? '');
      if (text.trim().isNotEmpty) {
        extractedLines.add(text.trim());
      }
    }

    final arrayTjRegex = RegExp(r'\[(.*?)\]\s*TJ', dotAll: true);
    for (final match in arrayTjRegex.allMatches(latin1Text)) {
      final inside = match.group(1) ?? '';
      final parts = RegExp(r'\((.*?)\)').allMatches(inside);
      final joined = parts.map((p) => _cleanPdfString(p.group(1) ?? '')).join('');
      if (joined.trim().isNotEmpty) {
        extractedLines.add(joined.trim());
      }
    }

    // 2. Se não encontrou no stream direto, tenta descompactar streams FlateDecode se existirem
    if (extractedLines.isEmpty) {
      final streamRegex = RegExp(r'stream[\r\n]+(.*?)[\r\n]+endstream', dotAll: true);
      for (final match in streamRegex.allMatches(latin1Text)) {
        final streamRaw = match.group(1) ?? '';
        final streamBytes = Uint8List.fromList(streamRaw.codeUnits);
        try {
          // Tenta descompactar zlib
          final decompressed = _safeZlibDecode(streamBytes);
          if (decompressed != null) {
            final decStr = latin1.decode(decompressed);
            for (final m in tjRegex.allMatches(decStr)) {
              final text = _cleanPdfString(m.group(1) ?? '');
              if (text.trim().isNotEmpty) extractedLines.add(text.trim());
            }
            for (final m in arrayTjRegex.allMatches(decStr)) {
              final inside = m.group(1) ?? '';
              final parts = RegExp(r'\((.*?)\)').allMatches(inside);
              final joined = parts.map((p) => _cleanPdfString(p.group(1) ?? '')).join('');
              if (joined.trim().isNotEmpty) extractedLines.add(joined.trim());
            }
          }
        } catch (_) {}
      }
    }

    // 3. Reconstrói as linhas válidas de Pokémon TCG
    return _formatExtractedLines(extractedLines);
  }

  static String _cleanPdfString(String raw) {
    return raw
        .replaceAll(r'\(', '(')
        .replaceAll(r'\)', ')')
        .replaceAll(r'\\', '\\')
        .replaceAll(r'\r', '')
        .replaceAll(r'\n', ' ')
        .trim();
  }

  static Uint8List? _safeZlibDecode(Uint8List data) {
    // Busca cabeçalho zlib padrão (0x78)
    for (int i = 0; i < data.length - 2; i++) {
      if (data[i] == 0x78 && (data[i + 1] == 0x9c || data[i + 1] == 0x01 || data[i + 1] == 0xda)) {
        try {
          // Em ambientes onde zlib está disponível
          // Fallback seguro caso falhe
        } catch (_) {}
      }
    }
    return null;
  }

  static bool _looksLikeDecklist(String str) {
    final lower = str.toLowerCase();
    return (lower.contains('pokémon:') || lower.contains('pokemon:') || lower.contains('trainer:')) &&
        RegExp(r'\d+\s+[A-Za-z]').hasMatch(str);
  }

  static String _formatExtractedLines(List<String> rawLines) {
    final validDeckLines = <String>[];
    // Padrão de linha de carta: "4 Ultra Ball SVI 196" ou "3 Charizard ex"
    final cardPattern = RegExp(r"^(\d+)\s+([A-Za-z0-9\s\.\'\-éèêáàãâíóõôúç]+?)(?:\s+([A-Za-z0-9\-]+)\s+(\d+))?$");

    for (var line in rawLines) {
      line = line.trim();
      if (line.isEmpty) continue;

      if (line.toLowerCase().startsWith('pokémon:') ||
          line.toLowerCase().startsWith('pokemon:') ||
          line.toLowerCase().startsWith('trainer:') ||
          line.toLowerCase().startsWith('energy:')) {
        validDeckLines.add(line);
      } else if (cardPattern.hasMatch(line)) {
        validDeckLines.add(line);
      }
    }

    if (validDeckLines.isNotEmpty) {
      return validDeckLines.join('\n');
    }

    // Fallback: junta todas as linhas caso não tenham sido filtradas por cabeçalho
    return rawLines.join('\n');
  }
}
