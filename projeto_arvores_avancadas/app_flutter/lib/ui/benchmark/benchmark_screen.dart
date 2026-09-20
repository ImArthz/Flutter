import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';

class BenchmarkScreen extends StatefulWidget {
  const BenchmarkScreen({super.key});

  @override
  State<BenchmarkScreen> createState() => _BenchmarkScreenState();
}

class _BenchmarkScreenState extends State<BenchmarkScreen> {
  bool _isRunning = false;
  List<FlSpot> _splaySpots = [];
  List<FlSpot> _treapSpots = [];
  int _maxElements = 10000;

  void _runBenchmark() async {
    setState(() {
      _isRunning = true;
      _splaySpots.clear();
      _treapSpots.clear();
    });

    // Simulacao de benchmark assintotico
    for (int i = 1000; i <= _maxElements; i += 2000) {
      await Future.delayed(const Duration(milliseconds: 300));
      
      final splayTime = (i * 0.05) + (i * 0.01 * (i % 3));
      final treapTime = (i * 0.04) + (i * 0.005 * (i % 2));

      setState(() {
        _splaySpots.add(FlSpot(i.toDouble(), splayTime));
        _treapSpots.add(FlSpot(i.toDouble(), treapTime));
      });
    }

    setState(() {
      _isRunning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Benchmark'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Panel for Settings
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Max Elements:'),
                      Expanded(
                        child: Slider(
                          value: _maxElements.toDouble(),
                          min: 1000,
                          max: 50000,
                          divisions: 49,
                          label: _maxElements.toString(),
                          activeColor: AppColors.primary,
                          onChanged: _isRunning ? null : (val) {
                            setState(() => _maxElements = val.toInt());
                          },
                        ),
                      ),
                      Text('$_maxElements'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _isRunning ? null : _runBenchmark,
                    icon: _isRunning 
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.play_arrow),
                    label: Text(_isRunning ? 'Running...' : 'Run Benchmark'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48)
                    ),
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            const Text('Insertion Time vs Size', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            
            Expanded(
              child: _splaySpots.isEmpty 
                ? const Center(child: Text('No results yet. Run the benchmark.', style: TextStyle(color: AppColors.textDisabled)))
                : Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: true),
                        titlesData: const FlTitlesData(
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: true, border: Border.all(color: AppColors.border)),
                        lineBarsData: [
                          LineChartBarData(
                            spots: _splaySpots,
                            isCurved: true,
                            color: AppColors.splayNode,
                            barWidth: 3,
                            dotData: const FlDotData(show: false),
                          ),
                          LineChartBarData(
                            spots: _treapSpots,
                            isCurved: true,
                            color: AppColors.treapNode,
                            barWidth: 3,
                            dotData: const FlDotData(show: false),
                          ),
                        ],
                      ),
                    ),
                  ),
            ),
            
            if (_splaySpots.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _LegendItem(color: AppColors.splayNode, label: 'Splay Tree'),
                    const SizedBox(width: 24),
                    _LegendItem(color: AppColors.treapNode, label: 'Treap'),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}
