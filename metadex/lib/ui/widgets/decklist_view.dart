import 'package:flutter/material.dart';
import '../../domain/models/deck.dart';

class DecklistViewWidget extends StatelessWidget {
  final Decklist decklist;
  final String titlePrefix;

  const DecklistViewWidget({
    super.key,
    required this.decklist,
    this.titlePrefix = 'DECKLIST',
  });

  @override
  Widget build(BuildContext context) {
    final total = decklist.totalCards;
    final isSixty = total == 60;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        border: Border.all(color: const Color(0xFF2A2A2A)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  titlePrefix,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    color: Color(0xFFFF7A00),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isSixty ? const Color(0xFF0E2F20) : const Color(0xFF3A1212),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$total/60 CARTAS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isSixty ? const Color(0xFF00E676) : Colors.redAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildSection('POKÉMON', decklist.pokemons)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildSection('TRAINER', decklist.trainers)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildSection('ENERGY', decklist.energies)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<DeckCard> cards) {
    final count = cards.fold(0, (sum, item) => sum + item.quantity);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title ($count)',
          style: const TextStyle(
            color: Color(0xFFFFA24D),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const Divider(color: Color(0xFF2A2A2A)),
        const SizedBox(height: 6),
        ...cards.map((card) {
          final isSpecial = card.canonical.isAceSpec || card.canonical.isRadiant;
          return Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: isSpecial ? const Color(0xFF2A1228) : const Color(0xFF1B1B1B),
                borderRadius: BorderRadius.circular(6),
                border: isSpecial
                    ? Border.all(color: const Color(0xFFCC79A7), width: 1)
                    : null,
              ),
              child: Row(
                children: [
                  Text(
                    '${card.quantity}x',
                    style: const TextStyle(
                      color: Color(0xFFFF7A00),
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          card.name,
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${card.setCode ?? "SV"} ${card.setNumber ?? ""} • Reg ${card.regulationMark}${card.roleClass != null ? " • ${_roleShort(card.roleClass!)}" : ""}',
                          style: const TextStyle(color: Colors.white54, fontSize: 9),
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
        }),
      ],
    );
  }

  String _roleShort(CardRoleClass role) {
    switch (role) {
      case CardRoleClass.core:
        return 'CORE';
      case CardRoleClass.padrao:
        return 'PADRÃO';
      case CardRoleClass.tech:
        return 'TECH';
    }
  }
}
