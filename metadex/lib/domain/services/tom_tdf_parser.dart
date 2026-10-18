import '../models/player.dart';
import '../models/tournament.dart';

class TomImportResult {
  final String? tournamentName;
  final String tdfHash;
  final List<Player> players;
  final List<Partida> matches;
  final int swissRounds;
  final bool birthdatesDiscardedInMemory;

  const TomImportResult({
    this.tournamentName,
    required this.tdfHash,
    required this.players,
    required this.matches,
    required this.swissRounds,
    this.birthdatesDiscardedInMemory = true,
  });
}

class TomTdfSecurityException implements Exception {
  final String message;
  const TomTdfSecurityException(this.message);
  @override
  String toString() => 'TomTdfSecurityException: $message';
}

/// Anti-Corruption Layer (ACL) para parsing de arquivos .tdf (XML do TOM) e texto PDF do TOM
class TomTdfParser {
  /// Calcula hash determinístico (tipo SHA-256) do conteúdo para idempotência (RN-08)
  static String computeTdfHash(String content) {
    final normalized = content.trim().replaceAll('\r\n', '\n');
    int h1 = 0x6a09e667;
    int h2 = 0xbb67ae85;
    int h3 = 0x3c6ef372;
    int h4 = 0xa54ff53a;

    for (int i = 0; i < normalized.length; i++) {
      final c = normalized.codeUnitAt(i);
      h1 = ((h1 ^ c) * 0x01000193) & 0x7FFFFFFF;
      h2 = ((h2 + (c << 3)) * 0x85ebca6b) & 0x7FFFFFFF;
      h3 = ((h3 ^ (c * 31)) * 0xc2b2ae35) & 0x7FFFFFFF;
      h4 = ((h4 + c + i) * 0x27d4eb2f) & 0x7FFFFFFF;
    }

    return [h1, h2, h3, h4]
        .map((h) => h.toRadixString(16).padLeft(8, '0'))
        .join('');
  }

  /// Faz o parse completo de um arquivo .tdf (XML do TOM)
  /// Protege contra XXE (Fase 8.2) e descarta datas de nascimento em memória (ADR-006 / LGPD)
  static TomImportResult parseTdfXml(String xmlContent, {DateTime? referenceDate}) {
    final refYear = (referenceDate ?? DateTime.now()).year;

    // Mitigação STRIDE / OWASP contra XXE (XML External Entity)
    final upperXml = xmlContent.toUpperCase();
    if (upperXml.contains('<!DOCTYPE') || upperXml.contains('<!ENTITY')) {
      throw const TomTdfSecurityException(
        'Entidades externas XML (DOCTYPE/ENTITY) bloqueadas por política de segurança OWASP (XXE).',
      );
    }

    final hash = computeTdfHash(xmlContent);

    // Extrai nome do torneio (<data><name>...</name>)
    final nameMatch = RegExp(r'<data>[\s\S]*?<name>(.*?)</name>', caseSensitive: false)
        .firstMatch(xmlContent);
    final tournamentName = nameMatch?.group(1)?.trim();

    // 1. Extrai jogadores (<player userid="1001"> ... </player>)
    final playerMap = <String, _RawTdfPlayer>{};
    final playerBlocks = RegExp(
      r'<player\s+userid="([^"]+)"[^>]*>([\s\S]*?)</player>',
      caseSensitive: false,
    ).allMatches(xmlContent);

    for (final match in playerBlocks) {
      final userId = match.group(1)!.trim();
      final body = match.group(2)!;

      final firstName = _extractTag(body, 'firstname') ?? '';
      final lastName = _extractTag(body, 'lastname') ?? '';
      final fullName = '$firstName $lastName'.trim();

      // ADR-006: Lê <birthdate> APENAS em memória para inferir a divisão etária e descarta imediatamente!
      final birthStr = _extractTag(body, 'birthdate');
      final division = _inferDivisionAndDiscardBirthdate(birthStr, refYear);

      if (fullName.isNotEmpty) {
        playerMap[userId] = _RawTdfPlayer(
          userId: userId,
          fullName: fullName,
          division: division,
        );
      }
    }

    // 2. Extrai rodadas e partidas (<round number="1" ...> <matches> <match outcome="1">...)
    final matches = <Partida>[];
    final winsMap = <String, int>{};
    final lossesMap = <String, int>{};
    final tiesMap = <String, int>{};
    final opponentsMap = <String, List<String>>{};
    int maxRound = 0;

    final roundBlocks = RegExp(
      r'<round\s+number="(\d+)"[^>]*>([\s\S]*?)</round>',
      caseSensitive: false,
    ).allMatches(xmlContent);

    for (final rMatch in roundBlocks) {
      final roundNum = int.tryParse(rMatch.group(1)!) ?? 1;
      if (roundNum > maxRound) maxRound = roundNum;
      final roundBody = rMatch.group(2)!;

      final matchBlocks = RegExp(
        r'<match\s+outcome="(\d+)"[^>]*>([\s\S]*?)</match>',
        caseSensitive: false,
      ).allMatches(roundBody);

      for (final mBlock in matchBlocks) {
        final outcome = int.tryParse(mBlock.group(1)!) ?? 0;
        final mBody = mBlock.group(2)!;
        final tableNum = int.tryParse(_extractTag(mBody, 'tablenumber') ?? '1') ?? 1;

        final p1Match = RegExp(r'<player1\s+userid="([^"]+)"', caseSensitive: false)
            .firstMatch(mBody);
        final p2Match = RegExp(r'<player2\s+userid="([^"]+)"', caseSensitive: false)
            .firstMatch(mBody);
        final byeMatch = RegExp(r'<player\s+userid="([^"]+)"', caseSensitive: false)
            .firstMatch(mBody);

        if (p1Match != null && p2Match != null) {
          final p1Id = p1Match.group(1)!;
          final p2Id = p2Match.group(1)!;
          opponentsMap.putIfAbsent(p1Id, () => []).add(p2Id);
          opponentsMap.putIfAbsent(p2Id, () => []).add(p1Id);

          int normalizedResult = 0;
          // No TOM: outcome 1 = P1 vence, 2 = P2 vence, 3 = Empate
          if (outcome == 1) {
            winsMap[p1Id] = (winsMap[p1Id] ?? 0) + 1;
            lossesMap[p2Id] = (lossesMap[p2Id] ?? 0) + 1;
            normalizedResult = 1;
          } else if (outcome == 2) {
            winsMap[p2Id] = (winsMap[p2Id] ?? 0) + 1;
            lossesMap[p1Id] = (lossesMap[p1Id] ?? 0) + 1;
            normalizedResult = 2;
          } else {
            tiesMap[p1Id] = (tiesMap[p1Id] ?? 0) + 1;
            tiesMap[p2Id] = (tiesMap[p2Id] ?? 0) + 1;
            normalizedResult = 0;
          }

          matches.add(
            Partida(
              id: 'm_r${roundNum}_t$tableNum',
              roundNumber: roundNum,
              tableNumber: tableNum,
              player1Id: p1Id,
              player2Id: p2Id,
              player1Name: playerMap[p1Id]?.fullName ?? p1Id,
              player2Name: playerMap[p2Id]?.fullName ?? p2Id,
              player1Deck: '',
              player2Deck: '',
              result: normalizedResult,
            ),
          );
        } else if (byeMatch != null && outcome == 5) {
          // Outcome 5 = BYE (vitória automática)
          final pId = byeMatch.group(1)!;
          winsMap[pId] = (winsMap[pId] ?? 0) + 1;
        }
      }
    }

    // 3. Calcula Win Rate individual para cálculo de OWP e OOWP (US-04)
    final winRateMap = <String, double>{};
    for (final userId in playerMap.keys) {
      final w = winsMap[userId] ?? 0;
      final l = lossesMap[userId] ?? 0;
      final t = tiesMap[userId] ?? 0;
      final total = w + l + t;
      if (total == 0) {
        winRateMap[userId] = 0.25;
      } else {
        // Piso oficial Play! Pokémon de 25% para OWP
        final wr = w / total;
        winRateMap[userId] = wr < 0.25 ? 0.25 : wr;
      }
    }

    final owpMap = <String, double>{};
    for (final userId in playerMap.keys) {
      final opps = opponentsMap[userId] ?? const [];
      if (opps.isEmpty) {
        owpMap[userId] = 0.25;
      } else {
        final sum = opps.fold(0.0, (s, oId) => s + (winRateMap[oId] ?? 0.25));
        owpMap[userId] = sum / opps.length;
      }
    }

    final oowpMap = <String, double>{};
    for (final userId in playerMap.keys) {
      final opps = opponentsMap[userId] ?? const [];
      if (opps.isEmpty) {
        oowpMap[userId] = 0.25;
      } else {
        final sum = opps.fold(0.0, (s, oId) => s + (owpMap[oId] ?? 0.25));
        oowpMap[userId] = sum / opps.length;
      }
    }

    // 4. Verifica se há bloco explícito <standings> no .tdf; se não, ordena por Pontos -> OWP -> OOWP
    final explicitPlacements = <String, int>{};
    final standingMatches = RegExp(
      r'<player\s+id="([^"]+)"\s+place="(\d+)"',
      caseSensitive: false,
    ).allMatches(xmlContent);
    for (final sm in standingMatches) {
      final uId = sm.group(1)!;
      final place = int.tryParse(sm.group(2)!) ?? 999;
      if (!explicitPlacements.containsKey(uId) || place < explicitPlacements[uId]!) {
        explicitPlacements[uId] = place;
      }
    }

    final sortedIds = playerMap.keys.toList();
    sortedIds.sort((a, b) {
      if (explicitPlacements.containsKey(a) && explicitPlacements.containsKey(b)) {
        return explicitPlacements[a]!.compareTo(explicitPlacements[b]!);
      }
      final ptsA = ((winsMap[a] ?? 0) * 3) + (tiesMap[a] ?? 0);
      final ptsB = ((winsMap[b] ?? 0) * 3) + (tiesMap[b] ?? 0);
      if (ptsA != ptsB) return ptsB.compareTo(ptsA);
      final owpComp = (owpMap[b] ?? 0).compareTo(owpMap[a] ?? 0);
      if (owpComp != 0) return owpComp;
      return (oowpMap[b] ?? 0).compareTo(oowpMap[a] ?? 0);
    });

    final resultPlayers = <Player>[];
    for (int i = 0; i < sortedIds.length; i++) {
      final uId = sortedIds[i];
      final raw = playerMap[uId]!;
      final place = explicitPlacements[uId] ?? (i + 1);
      resultPlayers.add(
        Player(
          id: uId,
          placement: place,
          name: raw.fullName,
          division: raw.division,
          deckName: 'Aguardando Decklist',
          wins: winsMap[uId] ?? 0,
          losses: lossesMap[uId] ?? 0,
          ties: tiesMap[uId] ?? 0,
          owp: owpMap[uId] ?? 0.50,
          oowp: oowpMap[uId] ?? 0.50,
        ),
      );
    }

    return TomImportResult(
      tournamentName: tournamentName,
      tdfHash: hash,
      players: resultPlayers,
      matches: matches,
      swissRounds: maxRound > 0 ? maxRound : 4,
      birthdatesDiscardedInMemory: true,
    );
  }

  /// Faz o parse de texto copiado de PDF de Standings do TOM
  /// Suporta formatos como:
  /// "1 Arthur Mendonça 1 4/0/1 13 62.50% 54.12%"
  /// "1\tLucas Silva\t5-1-0\t15"
  static List<Player> parseTomStandingsText(String text, List<Player> existingPlayers) {
    final lines = text.split(RegExp(r'\r?\n'));
    final updatedByPlace = <int, Player>{
      for (final p in existingPlayers) p.placement: p,
    };

    for (var rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      // Captura colocação, nome, e opcionalmente W/L/T (ou W-L-T) e OWP%/OOWP%
      final match = RegExp(
        r'^(\d+)[\.\º\s\t]+([A-Za-zÀ-ÖØ-öø-ÿ\s\.\-]+?)(?=\s+\d+\s+|\s+\d+[\/\-]\d+[\/\-]\d+|\t|\s+\d+$|$)(.*)$',
      ).firstMatch(line);

      if (match != null) {
        final placement = int.tryParse(match.group(1)!);
        final name = match.group(2)!.trim();
        final tail = match.group(3) ?? '';

        if (placement != null && placement >= 1 && name.isNotEmpty) {
          int wins = 0;
          int losses = 0;
          int ties = 0;
          double owp = 0.55;
          double oowp = 0.52;

          final wltMatch = RegExp(r'(\d+)[\/\-](\d+)[\/\-](\d+)').firstMatch(tail);
          if (wltMatch != null) {
            wins = int.tryParse(wltMatch.group(1)!) ?? 0;
            losses = int.tryParse(wltMatch.group(2)!) ?? 0;
            ties = int.tryParse(wltMatch.group(3)!) ?? 0;
          }

          final percents = RegExp(r'(\d+[\.,]\d+)%')
              .allMatches(tail)
              .map((m) => double.tryParse(m.group(1)!.replaceAll(',', '.')) ?? 50.0)
              .toList();
          if (percents.isNotEmpty) owp = percents[0] / 100.0;
          if (percents.length >= 2) oowp = percents[1] / 100.0;

          final existing = updatedByPlace[placement];
          updatedByPlace[placement] = Player(
            id: existing?.id ?? 'p_$placement',
            placement: placement,
            name: name,
            division: existing?.division ?? DivisaoEtaria.masters,
            hasParentalConsent: existing?.hasParentalConsent ?? false,
            deckName: existing?.deckName ?? 'Charizard ex / Pidgeot ex',
            deckImagePath: existing?.deckImagePath,
            decklist: existing?.decklist,
            wins: wins > 0 ? wins : (existing?.wins ?? 0),
            losses: wltMatch != null ? losses : (existing?.losses ?? 0),
            ties: wltMatch != null ? ties : (existing?.ties ?? 0),
            owp: percents.isNotEmpty ? owp : (existing?.owp ?? 0.55),
            oowp: percents.length >= 2 ? oowp : (existing?.oowp ?? 0.52),
            validationResult: existing?.validationResult,
            classification: existing?.classification,
            curatedByJudge: existing?.curatedByJudge ?? false,
          );
        }
      }
    }

    final sortedPlaces = updatedByPlace.keys.toList()..sort();
    return sortedPlaces.map((k) => updatedByPlace[k]!).toList();
  }

  static String? _extractTag(String xml, String tag) {
    final m = RegExp('<$tag[^>]*>(.*?)</$tag>', caseSensitive: false).firstMatch(xml);
    return m?.group(1)?.trim();
  }

  static DivisaoEtaria _inferDivisionAndDiscardBirthdate(String? birthStr, int refYear) {
    if (birthStr == null || birthStr.isEmpty) return DivisaoEtaria.masters;
    // Suporta MM/DD/YYYY ou YYYY-MM-DD
    final yearMatch = RegExp(r'(\d{4})').firstMatch(birthStr);
    if (yearMatch == null) return DivisaoEtaria.masters;
    final birthYear = int.tryParse(yearMatch.group(1)!) ?? 2000;
    final age = refYear - birthYear;
    if (age <= 12) return DivisaoEtaria.junior;
    if (age <= 16) return DivisaoEtaria.senior;
    return DivisaoEtaria.masters;
  }

  /// Gera um arquivo .tdf XML realista de League Cup para testes de 1 clique
  static String gerarSampleTdfXml() {
    return '''<?xml version="1.0" encoding="UTF-8"?>
<tournament type="2" stage="5" version="1.70">
  <data>
    <name>League Cup Outubro - Card House TCG</name>
    <id>26-10-000421</id>
    <city>São Paulo</city>
    <startdate>10/18/2026</startdate>
  </data>
  <players>
    <player userid="1001"><firstname>Lucas</firstname><lastname>Mendonca</lastname><birthdate>04/12/2001</birthdate></player>
    <player userid="1002"><firstname>Marina</firstname><lastname>Souza</lastname><birthdate>08/21/2011</birthdate></player>
    <player userid="1003"><firstname>Roberto</firstname><lastname>Almeida</lastname><birthdate>11/03/1985</birthdate></player>
    <player userid="1004"><firstname>Ana</firstname><lastname>Ferreira</lastname><birthdate>02/15/1997</birthdate></player>
    <player userid="1005"><firstname>Pedro</firstname><lastname>Oliveira</lastname><birthdate>07/19/2000</birthdate></player>
    <player userid="1006"><firstname>Julia</firstname><lastname>Costa</lastname><birthdate>09/10/2002</birthdate></player>
    <player userid="1007"><firstname>Marcos</firstname><lastname>Ribeiro</lastname><birthdate>01/30/1999</birthdate></player>
    <player userid="1008"><firstname>Carla</firstname><lastname>Martins</lastname><birthdate>05/25/2003</birthdate></player>
  </players>
  <pods>
    <pod category="2" stage="1">
      <rounds>
        <round number="1" type="2" stage="6">
          <matches>
            <match outcome="1"><player1 userid="1001"/><player2 userid="1008"/><tablenumber>1</tablenumber></match>
            <match outcome="1"><player1 userid="1002"/><player2 userid="1007"/><tablenumber>2</tablenumber></match>
            <match outcome="1"><player1 userid="1003"/><player2 userid="1006"/><tablenumber>3</tablenumber></match>
            <match outcome="1"><player1 userid="1004"/><player2 userid="1005"/><tablenumber>4</tablenumber></match>
          </matches>
        </round>
        <round number="2" type="2" stage="6">
          <matches>
            <match outcome="1"><player1 userid="1001"/><player2 userid="1004"/><tablenumber>1</tablenumber></match>
            <match outcome="1"><player1 userid="1002"/><player2 userid="1003"/><tablenumber>2</tablenumber></match>
            <match outcome="1"><player1 userid="1005"/><player2 userid="1008"/><tablenumber>3</tablenumber></match>
            <match outcome="1"><player1 userid="1006"/><player2 userid="1007"/><tablenumber>4</tablenumber></match>
          </matches>
        </round>
        <round number="3" type="2" stage="6">
          <matches>
            <match outcome="1"><player1 userid="1001"/><player2 userid="1002"/><tablenumber>1</tablenumber></match>
            <match outcome="1"><player1 userid="1003"/><player2 userid="1005"/><tablenumber>2</tablenumber></match>
            <match outcome="1"><player1 userid="1004"/><player2 userid="1006"/><tablenumber>3</tablenumber></match>
            <match outcome="1"><player1 userid="1007"/><player2 userid="1008"/><tablenumber>4</tablenumber></match>
          </matches>
        </round>
        <round number="4" type="2" stage="6">
          <matches>
            <match outcome="3"><player1 userid="1001"/><player2 userid="1003"/><tablenumber>1</tablenumber></match>
            <match outcome="1"><player1 userid="1002"/><player2 userid="1004"/><tablenumber>2</tablenumber></match>
            <match outcome="1"><player1 userid="1005"/><player2 userid="1006"/><tablenumber>3</tablenumber></match>
            <match outcome="2"><player1 userid="1008"/><player2 userid="1007"/><tablenumber>4</tablenumber></match>
          </matches>
        </round>
      </rounds>
    </pod>
  </pods>
  <standings>
    <pod category="2" type="1">
      <player id="1001" place="1"/>
      <player id="1002" place="2"/>
      <player id="1003" place="3"/>
      <player id="1004" place="4"/>
      <player id="1005" place="5"/>
      <player id="1006" place="6"/>
      <player id="1007" place="7"/>
      <player id="1008" place="8"/>
    </pod>
  </standings>
</tournament>''';
  }
}

class _RawTdfPlayer {
  final String userId;
  final String fullName;
  final DivisaoEtaria division;

  const _RawTdfPlayer({
    required this.userId,
    required this.fullName,
    required this.division,
  });
}
