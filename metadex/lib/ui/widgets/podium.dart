import 'package:flutter/material.dart';
import '../../domain/models/player.dart';
import '../../domain/models/tournament.dart';

class PodiumWidget extends StatelessWidget {
  final List<Player> players;
  final bool isTop8;
  final TopCut? topCut;
  final int? selectedPlayerIndex;
  final ValueChanged<int>? onSelectPlayer;

  const PodiumWidget({
    super.key,
    required this.players,
    this.isTop8 = false,
    this.topCut,
    this.selectedPlayerIndex,
    this.onSelectPlayer,
  });

  TopCut get _effectiveTopCut => topCut ?? (isTop8 ? TopCut.top8 : TopCut.top4);

  @override
  Widget build(BuildContext context) {
    if (players.isEmpty) return const SizedBox.shrink();

    final String headerText;
    switch (_effectiveTopCut) {
      case TopCut.none:
        headerText = 'CLASSIFICAÇÃO FINAL • SUÍÇO DIRETO (SEM CORTE / CHALLENGE)';
        break;
      case TopCut.top4:
        headerText = 'PÓDIO OFICIAL • CORTE TOP 4';
        break;
      case TopCut.top8:
        headerText = 'PÓDIO OFICIAL • CORTE TOP 8 (LEAGUE CUP)';
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Row(
            children: [
              Icon(
                _effectiveTopCut == TopCut.none ? Icons.format_list_numbered : Icons.emoji_events,
                color: const Color(0xFFFF7A00),
                size: 16,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  headerText,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: Color(0xFFFFA24D),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        _buildTopTwo(),
        const SizedBox(height: 12),
        _buildRest(),
      ],
    );
  }

  Widget _buildTopTwo() {
    return Row(
      children: [
        Expanded(
          child: _buildPlace(
            players.isNotEmpty ? players[0] : null,
            0,
            true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildPlace(
            players.length > 1 ? players[1] : null,
            1,
            false,
          ),
        ),
      ],
    );
  }

  Widget _buildRest() {
    final restCount = _effectiveTopCut == TopCut.top4
        ? 2
        : (_effectiveTopCut == TopCut.top8 ? 6 : (players.length - 2).clamp(0, 14));
    if (players.length <= 2 || restCount <= 0) return const SizedBox.shrink();

    final endIdx = players.length.clamp(2, 2 + restCount);
    final remainingPlayers = players.sublist(2, endIdx);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 124,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: remainingPlayers.length,
      itemBuilder: (context, index) {
        final actualIdx = index + 2;
        return _buildPlace(
          remainingPlayers[index],
          actualIdx,
          false,
          isSmall: true,
        );
      },
    );
  }

  Widget _buildPlace(
    Player? player,
    int playerIndex,
    bool isChampion, {
    bool isSmall = false,
  }) {
    if (player == null) return const SizedBox.shrink();

    final bool isSelected = selectedPlayerIndex == playerIndex;
    final bool isLegal = player.validationResult?.isValida ?? true;

    final Color borderColor = isSelected
        ? const Color(0xFF56B4E9)
        : (isChampion
            ? const Color(0xFFFF7A00)
            : (player.placement == 2
                ? const Color(0xFFE8E8E8)
                : const Color(0xFF3A3A3A)));

    final Color backgroundColor = isChampion
        ? const Color(0xFF261200)
        : (isSelected ? const Color(0xFF16222F) : const Color(0xFF141414));

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onSelectPlayer != null ? () => onSelectPlayer!(playerIndex) : null,
      child: Container(
        height: isSmall ? 124 : 168,
        padding: EdgeInsets.all(isSmall ? 10 : 14),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(
            color: borderColor,
            width: isChampion || isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isChampion
              ? const [BoxShadow(color: Color(0x33FF7A00), blurRadius: 32)]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AspectRatio(
              aspectRatio: 63 / 88,
              child: Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: const Color(0xFF1D1D1D),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF444444)),
                ),
                child: player.deckImagePath != null && player.deckImagePath!.isNotEmpty
                    ? Image.network(
                        player.deckImagePath!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildFallbackCardIcon(player),
                      )
                    : _buildFallbackCardIcon(player),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        '${player.placement}º',
                        style: TextStyle(
                          fontSize: isSmall ? 22 : (isChampion ? 38 : 32),
                          fontWeight: FontWeight.w900,
                          color: isChampion ? const Color(0xFFFF7A00) : Colors.white,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isLegal ? const Color(0xFF0E2F20) : const Color(0xFF3A1212),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isLegal ? '60 OK' : 'ILEGAL',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: isLegal ? const Color(0xFF00E676) : Colors.redAccent,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    player.deckName.isNotEmpty ? player.deckName : 'Deck Desconhecido',
                    style: TextStyle(
                      fontSize: isSmall ? 13 : 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${player.displayName} • ${player.divisionLabel}',
                    style: TextStyle(
                      fontSize: isSmall ? 11 : 13,
                      color: Colors.white70,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${player.recordString} (${player.matchPoints} pts) • OWP ${(player.owp * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFFFFA24D),
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackCardIcon(Player player) {
    return Container(
      color: const Color(0xFF221508),
      padding: const EdgeInsets.all(4),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.catching_pokemon, color: Color(0xFFFF7A00), size: 22),
          const SizedBox(height: 2),
          Text(
            player.deckName,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 8, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
