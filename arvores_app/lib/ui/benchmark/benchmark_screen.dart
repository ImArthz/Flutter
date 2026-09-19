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
  double _progress = 0.0;
  List<dynamic> _results = []; // Mocks de resultados

  void _runBenchmark() async {
    setState(() {
      _isRunning = true;
      _progress = 0.0;
      _results = [];
    });

    // Simulando o processo de benchmark na UI usando Isolates/async
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() => _progress = i / 10.0);
    }
    
    // Gerar resultados mockados para exibir no gráfico
    _results = [
      {'struct': 'Splay', 'size': 1000, 'time': 0.012},
      {'struct': 'Splay', 'size': 10000, 'time': 0.035},
      {'struct': 'Treap', 'size': 1000, 'time': 0.010},
      {'struct': 'Treap', 'size': 10000, 'time': 0.028},
      {'struct': 'Trie', 'size': 1000, 'time': 0.022},
      {'struct': 'Trie', 'size': 10000, 'time': 0.200},
    ];

    setState(() => _isRunning = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Benchmarking')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text('Configurações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: const [
                         ChoiceChip(label: Text('1k'), selected: false),
                         ChoiceChip(label: Text('10k'), selected: true),
                         ChoiceChip(label: Text('100k'), selected: false),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isRunning ? null : _runBenchmark,
                      icon: _isRunning 
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.play_arrow),
                      label: Text(_isRunning ? 'Rodando...' : 'Executar Benchmark'),
                    ),
                    if (_isRunning) ...[
                      const SizedBox(height: 16),
                      LinearProgressIndicator(value: _progress),
                    ]
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            if (_results.isNotEmpty) ...[
              const Text('Tempo de Inserção vs Tamanho', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              Expanded(
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: true),
                    titlesData: const FlTitlesData(show: true),
                    borderData: FlBorderData(show: true),
                    lineBarsData: [
                      LineChartBarData(
                        spots: const [FlSpot(1, 0.012), FlSpot(10, 0.035)],
                        isCurved: false,
                        color: AppColors.splayNode,
                        barWidth: 3,
                      ),
                      LineChartBarData(
                        spots: const [FlSpot(1, 0.010), FlSpot(10, 0.028)],
                        isCurved: false,
                        color: AppColors.treapNode,
                        barWidth: 3,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  // TODO: path_provider -> salvar .csv no celular
                }, 
                icon: const Icon(Icons.download), 
                label: const Text('Exportar CSV')
              )
            ] else 
              const Expanded(child: Center(child: Text('Nenhum resultado ainda. Execute o benchmark.', style: TextStyle(color: Colors.grey)))),
          ],
        ),
      ),
    );
  }
}
