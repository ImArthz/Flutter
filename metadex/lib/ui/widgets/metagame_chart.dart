import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/models/metagame.dart';

class MetagameChartWidget extends StatelessWidget {
  final List<MetagameStat> stats;

  const MetagameChartWidget({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) {
      return const Center(
        child: Text(
          'Sem dados de metagame ainda.',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    final totalPlayers = stats.fold<int>(0, (s, item) => s + item.count);
    final hasLowSample = totalPlayers < 15 || stats.any((s) => s.lowSampleWarning);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 6,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
                  children: [
                    TextSpan(text: 'METAGAME '),
                    TextSpan(text: 'SHARE & CONVERSÃO', style: TextStyle(color: Color(0xFFFF7A00))),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (hasLowSample)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2F2208),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFF0E442)),
                  ),
                  child: Text(
                    'RN-07: Amostra (n=$totalPlayers) • IC Wilson 95%',
                    style: const TextStyle(fontSize: 10, color: Color(0xFFF0E442)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Donut Chart (Visão de Composição)
                Expanded(
                  flex: 4,
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 28,
                          sections: stats.map((stat) {
                            return PieChartSectionData(
                              color: stat.color,
                              value: stat.percentage,
                              title: '${stat.percentage.toStringAsFixed(0)}%',
                              radius: 68,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Barras Horizontais Ordenadas (Tufte/Cleveland) + Conversão + WR Bayesiano + IC Wilson
                Expanded(
                  flex: 6,
                  child: ListView.builder(
                    itemCount: stats.length,
                    itemBuilder: (context, index) {
                      final stat = stats[index];
                      final shareFraction = (stat.percentage / 100.0).clamp(0.02, 1.0);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B1B1B),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF2C2C2C)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: stat.color,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${stat.deckName} (${stat.count})',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    '${stat.percentage.toStringAsFixed(1)}%',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFFFA24D),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: shareFraction,
                                  minHeight: 7,
                                  backgroundColor: const Color(0xFF2A2A2A),
                                  valueColor: AlwaysStoppedAnimation<Color>(stat.color),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 10,
                                runSpacing: 4,
                                children: [
                                  _buildMetricBadge(
                                    'Conv. Top Cut: ${stat.conversionRate.toStringAsFixed(2)}x',
                                    stat.conversionRate >= 1.0
                                        ? const Color(0xFF009E73)
                                        : Colors.white54,
                                  ),
                                  _buildMetricBadge(
                                    'WR Bayes: ${(stat.bayesianWinRate * 100).toStringAsFixed(1)}%',
                                    const Color(0xFF56B4E9),
                                  ),
                                  _buildMetricBadge(
                                    'Wilson 95%: ${(stat.wilsonLower * 100).toStringAsFixed(0)}%-${(stat.wilsonUpper * 100).toStringAsFixed(0)}%',
                                    Colors.white70,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricBadge(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }
}
