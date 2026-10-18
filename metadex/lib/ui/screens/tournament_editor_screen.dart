import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import '../viewmodels/tournament_editor_viewmodel.dart';
import '../widgets/podium.dart';
import '../widgets/metagame_chart.dart';
import '../widgets/decklist_view.dart';
import '../../domain/models/tournament.dart';
import '../../domain/models/player.dart';
import '../../domain/models/deck.dart';
import '../../domain/services/deck_validator.dart';
import '../../data/services/pdf_export_service.dart';

class TournamentEditorScreen extends StatefulWidget {
  const TournamentEditorScreen({super.key});

  @override
  State<TournamentEditorScreen> createState() => _TournamentEditorScreenState();
}

class _TournamentEditorScreenState extends State<TournamentEditorScreen> {
  final GlobalKey _viewportKey = GlobalKey();
  final PdfExportService _pdfService = PdfExportService();

  Future<void> _exportViewportSnapshotAsPdf() async {
    try {
      final ctx = _viewportKey.currentContext;
      if (ctx == null) return;
      final boundary = ctx.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final pdf = pw.Document();
      final pdfImage = pw.MemoryImage(pngBytes);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          build: (pw.Context context) {
            return pw.Center(child: pw.Image(pdfImage));
          },
        ),
      );

      await Printing.sharePdf(bytes: await pdf.save(), filename: 'metadex_card_social.pdf');
    } catch (e) {
      debugPrint('Erro ao exportar imagem do viewport: $e');
    }
  }

  Future<void> _exportFullReportPdf(TournamentEditorViewModel vm) async {
    try {
      await _pdfService.shareOrPrintPdf(
        vm.currentTournament,
        cardPresence: vm.cardPresence,
        consensusDeck: vm.consensusDeck,
      );
    } catch (e) {
      debugPrint('Erro ao exportar relatório PDF completo: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TournamentEditorViewModel>();

    return Scaffold(
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'btn_pdf_full',
            onPressed: () => _exportFullReportPdf(vm),
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
            label: const Text(
              'Relatório PDF Oficial',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: const Color(0xFF222222),
          ),
          const SizedBox(width: 12),
          FloatingActionButton.extended(
            heroTag: 'btn_pdf_card',
            onPressed: _exportViewportSnapshotAsPdf,
            icon: const Icon(Icons.download, color: Colors.black),
            label: const Text(
              'Exportar Gráfico',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            backgroundColor: const Color(0xFFFF7A00),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 980;
          final panelWidth = isWide ? 430.0 : (constraints.maxWidth * 0.42).clamp(300.0, 420.0);

          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: panelWidth,
                decoration: const BoxDecoration(
                  color: Color(0xFF101010),
                  border: Border(
                    right: BorderSide(color: Color(0xFFFF7A00), width: 2),
                  ),
                ),
                child: const _EditorPanel(),
              ),
              Expanded(
                child: Container(
                  color: const Color(0xFF050505),
                  child: RepaintBoundary(
                    key: _viewportKey,
                    child: const _Viewport(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EditorPanel extends StatefulWidget {
  const _EditorPanel();

  @override
  State<_EditorPanel> createState() => _EditorPanelState();
}

class _EditorPanelState extends State<_EditorPanel> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TournamentEditorViewModel>();
    final pendingCuration = vm.curationQueue.length;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: const Color(0xFF161616),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Row(
                  children: [
                    Icon(Icons.shield_outlined, color: Color(0xFFFF7A00), size: 20),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'PAINEL DE COMANDO',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          fontSize: 13,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              if (pendingCuration > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$pendingCuration alerta(s) Juiz',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
        TabBar(
          controller: _tabController,
          labelPadding: const EdgeInsets.symmetric(horizontal: 4),
          indicatorColor: const Color(0xFFFF7A00),
          labelColor: const Color(0xFFFF7A00),
          unselectedLabelColor: Colors.white54,
          labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'GERAL'),
            Tab(text: 'IMPORTAR (TOM)'),
            Tab(text: 'JOGADORES'),
            Tab(text: 'JUIZ & LOG'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              _GeneralTab(),
              _ImportTomTab(),
              _PlayersTab(),
              _JudgeCurationTab(),
            ],
          ),
        ),
      ],
    );
  }
}

class _GeneralTab extends StatelessWidget {
  const _GeneralTab();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TournamentEditorViewModel>();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'CONFIGURAÇÃO DO TORNEIO & LOJA (TENANT)',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFFFA24D)),
        ),
        const SizedBox(height: 12),
        TextFormField(
          key: ValueKey('trn_name_${viewModel.tournamentName}'),
          initialValue: viewModel.tournamentName,
          onChanged: (val) => context.read<TournamentEditorViewModel>().updateTournamentName(val),
          decoration: const InputDecoration(
            labelText: 'Nome do Torneio',
            border: OutlineInputBorder(),
            isDense: true,
            filled: true,
            fillColor: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
                key: ValueKey('store_${viewModel.storeName}'),
                initialValue: viewModel.storeName,
                onChanged: (val) =>
                    context.read<TournamentEditorViewModel>().updateStoreInfo(nome: val),
                decoration: const InputDecoration(
                  labelText: 'Nome da Loja',
                  border: OutlineInputBorder(),
                  isDense: true,
                  filled: true,
                  fillColor: Color(0xFF1A1A1A),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: TextFormField(
                key: ValueKey('city_${viewModel.storeCity}'),
                initialValue: viewModel.storeCity,
                onChanged: (val) =>
                    context.read<TournamentEditorViewModel>().updateStoreInfo(cidade: val),
                decoration: const InputDecoration(
                  labelText: 'Cidade',
                  border: OutlineInputBorder(),
                  isDense: true,
                  filled: true,
                  fillColor: Color(0xFF1A1A1A),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<TopCut>(
                key: ValueKey('topcut_${viewModel.topCut.name}'),
                isExpanded: true,
                initialValue: viewModel.topCut,
                decoration: const InputDecoration(
                  labelText: 'Corte (Top Cut)',
                  border: OutlineInputBorder(),
                  isDense: true,
                  filled: true,
                  fillColor: Color(0xFF1A1A1A),
                ),
                items: const [
                  DropdownMenuItem(value: TopCut.top4, child: Text('Top 4', overflow: TextOverflow.ellipsis)),
                  DropdownMenuItem(value: TopCut.top8, child: Text('Top 8', overflow: TextOverflow.ellipsis)),
                ],
                onChanged: (val) {
                  if (val != null) context.read<TournamentEditorViewModel>().updateTopCut(val);
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<String>(
                key: ValueKey('fmt_${viewModel.formato.id}'),
                isExpanded: true,
                initialValue: viewModel.formato.id,
                decoration: const InputDecoration(
                  labelText: 'Formato (RN-01)',
                  border: OutlineInputBorder(),
                  isDense: true,
                  filled: true,
                  fillColor: Color(0xFF1A1A1A),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'fmt_std_ghi',
                    child: Text('Standard (G-H-I)', overflow: TextOverflow.ellipsis),
                  ),
                  DropdownMenuItem(
                    value: 'fmt_std_fgh',
                    child: Text('Standard (F-G-H)', overflow: TextOverflow.ellipsis),
                  ),
                ],
                onChanged: (val) {
                  if (val == 'fmt_std_ghi') {
                    context.read<TournamentEditorViewModel>().updateFormato(Formato.standardAtual());
                  } else if (val == 'fmt_std_fgh') {
                    context.read<TournamentEditorViewModel>().updateFormato(Formato.standardFGH());
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<EstadoTorneio>(
          key: ValueKey('est_${viewModel.estadoTorneio.name}'),
          isExpanded: true,
          initialValue: viewModel.estadoTorneio,
          decoration: const InputDecoration(
            labelText: 'Estado do Torneio & Embargo (RN-03)',
            border: OutlineInputBorder(),
            isDense: true,
            filled: true,
            fillColor: Color(0xFF1A1A1A),
          ),
          items: const [
            DropdownMenuItem(
              value: EstadoTorneio.emAndamento,
              child: Text('🔒 Em Andamento (Embargo Ativo)', overflow: TextOverflow.ellipsis),
            ),
            DropdownMenuItem(
              value: EstadoTorneio.encerrado,
              child: Text('🏁 Encerrado (Pós-Top Cut)', overflow: TextOverflow.ellipsis),
            ),
            DropdownMenuItem(
              value: EstadoTorneio.emCuradoria,
              child: Text('⚖️ Em Curadoria (Juiz)', overflow: TextOverflow.ellipsis),
            ),
            DropdownMenuItem(
              value: EstadoTorneio.publicado,
              child: Text('🌐 Publicado (Relatório Oficial)', overflow: TextOverflow.ellipsis),
            ),
          ],
          onChanged: (val) {
            if (val != null) {
              context.read<TournamentEditorViewModel>().updateEstadoTorneio(val);
            }
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<PoliticaVisibilidade>(
          key: ValueKey('pol_${viewModel.politicaVisibilidade.name}'),
          isExpanded: true,
          initialValue: viewModel.politicaVisibilidade,
          decoration: const InputDecoration(
            labelText: 'Política de Visibilidade (RN-04)',
            border: OutlineInputBorder(),
            isDense: true,
            filled: true,
            fillColor: Color(0xFF1A1A1A),
          ),
          items: const [
            DropdownMenuItem(
              value: PoliticaVisibilidade.todasAsListas,
              child: Text('Todas as Decklists Públicas', overflow: TextOverflow.ellipsis),
            ),
            DropdownMenuItem(
              value: PoliticaVisibilidade.apenasTopCut,
              child: Text('Apenas Listas do Top Cut', overflow: TextOverflow.ellipsis),
            ),
            DropdownMenuItem(
              value: PoliticaVisibilidade.somenteAgregadosAnonimos,
              child: Text('Somente Agregados Anônimos', overflow: TextOverflow.ellipsis),
            ),
          ],
          onChanged: (val) {
            if (val != null) {
              context.read<TournamentEditorViewModel>().updatePoliticaVisibilidade(val);
            }
          },
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF19130C),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF4A2C0A)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Color(0xFFFF7A00), size: 18),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'INSIGHTS AUTOMÁTICOS DA LOJA (ROBERTO)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF7A00),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...viewModel.naturalLanguageInsights.map(
                (insight) => Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Text(
                    insight,
                    style: const TextStyle(fontSize: 12, color: Colors.white70, height: 1.3),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ImportTomTab extends StatefulWidget {
  const _ImportTomTab();

  @override
  State<_ImportTomTab> createState() => _ImportTomTabState();
}

class _ImportTomTabState extends State<_ImportTomTab> {
  final TextEditingController _tdfController = TextEditingController();
  final TextEditingController _pdfStandingsController = TextEditingController();

  @override
  void dispose() {
    _tdfController.dispose();
    _pdfStandingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TournamentEditorViewModel>();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (vm.lastImportMessage != null)
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: vm.lastImportWasError ? const Color(0xFF3A1515) : const Color(0xFF0E2F20),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: vm.lastImportWasError ? Colors.redAccent : const Color(0xFF00E676),
              ),
            ),
            child: Text(
              vm.lastImportMessage!,
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
          ),
        const Text(
          '1. IMPORTAR ARQUIVO .TDF DO TOM (XML OFICIAL - RF-04)',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFFFA24D)),
        ),
        const SizedBox(height: 6),
        const Text(
          'Extrai inscritos, divisões etárias (descartando data de nascimento em memória - ADR-006), rodadas, partidas e calcula OWP/OOWP com deduplicação SHA-256.',
          style: TextStyle(fontSize: 11, color: Colors.white54),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF7A00),
            foregroundColor: Colors.black,
          ),
          onPressed: () {
            context.read<TournamentEditorViewModel>().loadSampleTdf();
          },
          icon: const Icon(Icons.bolt, size: 18),
          label: const Text(
            'Carregar .TDF Oficial de Exemplo (1 Clique)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _tdfController,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Colar Conteúdo XML do Arquivo .tdf',
            hintText: '<?xml version="1.0"?><tournament>...</tournament>',
            alignLabelWithHint: true,
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () {
            context.read<TournamentEditorViewModel>().importTdfXml(_tdfController.text);
          },
          icon: const Icon(Icons.upload_file, color: Color(0xFFFF7A00)),
          label: const Text('Processar XML .TDF Colado', style: TextStyle(color: Colors.white)),
        ),
        const Divider(height: 32, color: Color(0xFF2A2A2A)),
        const Text(
          '2. IMPORTAR STANDINGS DO PDF DO TOM (COPIAR E COLAR)',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFFFA24D)),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _pdfStandingsController,
          maxLines: 4,
          onChanged: (val) {
            context.read<TournamentEditorViewModel>().parseTomStandings(val);
          },
          decoration: const InputDecoration(
            labelText: 'Importar Classificação (Copiar do PDF do TOM)',
            hintText: 'Ex: 1 Arthur Mendonça 1 5/0/1 16 64.20% 58.10%',
            alignLabelWithHint: true,
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () {
            const samplePdf = '''1 Arthur Mendonça 1 5/0/1 16 68.50% 60.10%
2 Bruno Pereira 1 4/1/1 13 64.00% 58.20%
3 Marina Souza 1 4/1/1 13 61.50% 55.40%
4 Gabriel Santos 1 4/2/0 12 59.10% 54.00%''';
            _pdfStandingsController.text = samplePdf;
            context.read<TournamentEditorViewModel>().parseTomStandings(samplePdf);
          },
          icon: const Icon(Icons.paste, color: Color(0xFF56B4E9)),
          label: const Text(
            'Testar Colagem de PDF do TOM (Arthur, Bruno...)',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class _PlayersTab extends StatelessWidget {
  const _PlayersTab();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TournamentEditorViewModel>();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            maxLines: 2,
            onChanged: (val) {
              context.read<TournamentEditorViewModel>().parseTomStandings(val);
            },
            decoration: const InputDecoration(
              labelText: 'Importação Rápida de Standings (PDF TOM)',
              hintText: 'Cole as linhas da tabela do PDF aqui...',
              isDense: true,
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Color(0xFF1A1A1A),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: viewModel.players.length,
            itemBuilder: (context, index) {
              final player = viewModel.players[index];
              final isLegal = player.validationResult?.isValida ?? true;

              return Card(
                color: const Color(0xFF1A1A1A),
                margin: const EdgeInsets.only(bottom: 10),
                child: ExpansionTile(
                  title: Text(
                    '${player.placement}º - ${player.displayName}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  subtitle: Text(
                    '${player.deckName} • ${player.recordString} • ${isLegal ? "60 Cartas OK" : "Lista Inválida"}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isLegal ? const Color(0xFFFFA24D) : Colors.redAccent,
                    ),
                  ),
                  childrenPadding: const EdgeInsets.all(14),
                  onExpansionChanged: (expanded) {
                    if (expanded) {
                      context.read<TournamentEditorViewModel>().selectPlayer(index);
                    }
                  },
                  children: [
                    TextFormField(
                      key: ValueKey('p_name_${player.id}'),
                      initialValue: player.name,
                      onChanged: (val) {
                        final updated = player.copyWith(name: val);
                        context.read<TournamentEditorViewModel>().updatePlayer(index, updated);
                      },
                      decoration: const InputDecoration(
                        labelText: 'Nome Completo do Jogador',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<DivisaoEtaria>(
                            key: ValueKey('div_${player.id}_${player.division.name}'),
                            isExpanded: true,
                            initialValue: player.division,
                            decoration: const InputDecoration(
                              labelText: 'Divisão Etária',
                              isDense: true,
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: DivisaoEtaria.masters,
                                child: Text('Masters', overflow: TextOverflow.ellipsis),
                              ),
                              DropdownMenuItem(
                                value: DivisaoEtaria.senior,
                                child: Text('Senior (LGPD)', overflow: TextOverflow.ellipsis),
                              ),
                              DropdownMenuItem(
                                value: DivisaoEtaria.junior,
                                child: Text('Junior (LGPD)', overflow: TextOverflow.ellipsis),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                context.read<TournamentEditorViewModel>().updatePlayer(
                                      index,
                                      player.copyWith(division: val),
                                    );
                              }
                            },
                          ),
                        ),
                        if (player.division != DivisaoEtaria.masters) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: SwitchListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Consentimento Pais (RN-05)', style: TextStyle(fontSize: 11)),
                              value: player.hasParentalConsent,
                              onChanged: (val) {
                                context
                                    .read<TournamentEditorViewModel>()
                                    .toggleParentalConsent(index, val);
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      key: ValueKey('p_deck_${player.id}_${player.deckName}'),
                      initialValue: player.deckName,
                      onChanged: (val) {
                        final updated = player.copyWith(deckName: val);
                        context.read<TournamentEditorViewModel>().updatePlayer(index, updated);
                      },
                      decoration: const InputDecoration(
                        labelText: 'Nome do Deck / Arquétipo',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      key: ValueKey('p_img_${player.id}_${player.deckImagePath}'),
                      initialValue: player.deckImagePath ?? '',
                      onChanged: (val) {
                        final updated = player.copyWith(deckImagePath: val);
                        context.read<TournamentEditorViewModel>().updatePlayer(index, updated);
                      },
                      decoration: const InputDecoration(
                        labelText: 'URL da Imagem da Carta Destaque',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      key: ValueKey('p_dl_${player.id}_v${player.decklist?.version ?? 1}'),
                      initialValue: player.decklist?.rawText ?? '',
                      maxLines: 4,
                      onChanged: (val) {
                        context.read<TournamentEditorViewModel>().importPlayerDecklist(index, val);
                      },
                      decoration: const InputDecoration(
                        labelText: 'Colar Decklist (PTCG Live PT-BR ou EN)',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _JudgeCurationTab extends StatelessWidget {
  const _JudgeCurationTab();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TournamentEditorViewModel>();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'PAINEL DA JUÍZA (PROFESSOR) - VALIDAÇÃO & CURADORIA',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFFFA24D)),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // Simula uma lista ilegal com 5 cópias de Ultra Ball (reimpressões SVI + PAF) e 2 ACE SPECs
                  const illegalList = '''Pokémon: 15
3 Charizard ex OBF 125
4 Charmander OBF 26
2 Pidgeot ex OBF 164
2 Pidgey OBF 162
2 Radiant Charizard CRZ 20
2 Fezandipiti ex SFA 38

Trainer: 38
3 Ultra Ball SVI 196
2 Ultra Ball PAF 91
4 Rare Candy SVI 191
4 Buddy-Buddy Poffin TEF 144
4 Arven SVI 166
4 Iono PAL 185
1 Prime Catcher TEF 157
1 Unfair Stamp TWM 165
15 Nest Ball SVI 181

Energy: 6
6 Basic Fire Energy SVE 2''';
                  context.read<TournamentEditorViewModel>().importPlayerDecklist(0, illegalList);
                },
                icon: const Icon(Icons.bug_report, color: Colors.redAccent, size: 16),
                label: const Text('Testar Deck Ilegal (1º)', style: TextStyle(fontSize: 11)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  context.read<TournamentEditorViewModel>().initPlayers();
                },
                icon: const Icon(Icons.verified, color: Color(0xFF00E676), size: 16),
                label: const Text('Restaurar Decks Legais', style: TextStyle(fontSize: 11)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(vm.players.length, (index) {
          final p = vm.players[index];
          final val = p.validationResult;
          final isLegal = val?.isValida ?? true;
          final classif = p.classification;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isLegal ? const Color(0xFF2D2D2D) : Colors.redAccent,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${p.placement}º ${p.displayName} • ${p.deckName}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isLegal ? const Color(0xFF0E2F20) : const Color(0xFF3A1212),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isLegal ? 'LEGAL (60/60)' : '${val?.violacoes.length ?? 1} VIOLAÇÃO(ÕES)',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isLegal ? const Color(0xFF00E676) : Colors.redAccent,
                        ),
                      ),
                    ),
                  ],
                ),
                if (classif != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      'Classificador: ${classif.metodo} (Confiança: ${(classif.confianca * 100).toStringAsFixed(0)}%)',
                      style: const TextStyle(fontSize: 11, color: Colors.white54),
                    ),
                  ),
                if (val != null && val.violacoes.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  ...val.violacoes.map(
                    (v) => Padding(
                      padding: const EdgeInsets.only(bottom: 3.0),
                      child: Text(
                        '• [${v.codigo}] ${v.mensagem}',
                        style: const TextStyle(fontSize: 11, color: Colors.redAccent),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  key: ValueKey('cur_${p.id}_${p.deckName}'),
                  isExpanded: true,
                  initialValue: vm.catalogoArquetipos.any((a) => a.nome == p.deckName)
                      ? p.deckName
                      : vm.catalogoArquetipos.first.nome,
                  decoration: const InputDecoration(
                    labelText: 'Curadoria Manual de Arquétipo (Juiz - UC14)',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  items: vm.catalogoArquetipos
                      .map(
                        (a) => DropdownMenuItem(
                          value: a.nome,
                          child: Text(
                            a.nome,
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (novoNome) {
                    if (novoNome != null) {
                      final arq = vm.catalogoArquetipos.firstWhere((a) => a.nome == novoNome);
                      context.read<TournamentEditorViewModel>().assignArchetypeByJudge(index, arq);
                    }
                  },
                ),
              ],
            ),
          );
        }),
        const Divider(height: 28, color: Color(0xFF2A2A2A)),
        const Text(
          'TRILHA DE AUDITORIA IMUTÁVEL (RN-06)',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFFFA24D)),
        ),
        const SizedBox(height: 8),
        ...vm.auditLog.take(8).map(
              (ev) => Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Text(
                  '[${ev.ocorridoEm.hour.toString().padLeft(2, '0')}:${ev.ocorridoEm.minute.toString().padLeft(2, '0')}] ${ev.autor} (${ev.acao}): ${ev.detalhes}',
                  style: const TextStyle(fontSize: 11, color: Colors.white60),
                ),
              ),
            ),
      ],
    );
  }
}

class _Viewport extends StatelessWidget {
  const _Viewport();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TournamentEditorViewModel>();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cabeçalho do Relatório
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      viewModel.tournamentName.isEmpty
                          ? 'TORNEIO POKÉMON TCG'
                          : viewModel.tournamentName.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${viewModel.storeName} (${viewModel.storeCity}-${viewModel.storeUf}) • Formato ${viewModel.formato.nome} • ${viewModel.players.length} Jogadores',
                      style: const TextStyle(fontSize: 13, color: Color(0xFFFFA24D)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: viewModel.isEmbargoActive
                      ? const Color(0xFF3A1212)
                      : const Color(0xFF1A281E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: viewModel.isEmbargoActive
                        ? Colors.redAccent
                        : const Color(0xFF00E676),
                  ),
                ),
                child: Text(
                  viewModel.isEmbargoActive
                      ? '🔒 EMBARGO ATIVO (RN-03)'
                      : '✓ ${viewModel.currentTournament.estadoLabel.toUpperCase()}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: viewModel.isEmbargoActive
                        ? Colors.redAccent
                        : const Color(0xFF00E676),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Se o Embargo (RN-03) estiver ativo, bloqueia a exibição pública de listas contra scouting!
          if (viewModel.isEmbargoActive)
            Expanded(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 520),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141414),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.redAccent, width: 2),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.visibility_off, size: 64, color: Colors.redAccent),
                      const SizedBox(height: 16),
                      const Text(
                        'EMBARGO ANTI-SCOUTING ATIVO (RN-03)',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'O torneio está em andamento. De acordo com a Regra de Negócio RN-03, decklists individuais e estatísticas agregadas ficam ocultas até o encerramento para impedir espionagem de rodada.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Colors.white70, height: 1.4),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF7A00),
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () {
                          context
                              .read<TournamentEditorViewModel>()
                              .updateEstadoTorneio(EstadoTorneio.publicado);
                        },
                        icon: const Icon(Icons.lock_open),
                        label: const Text(
                          'Encerrar Torneio e Publicar Relatório',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Coluna Esquerda: Pódio Top Cut interativo
                  Expanded(
                    flex: 5,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(right: 12),
                      child: PodiumWidget(
                        players: viewModel.players,
                        isTop8: viewModel.topCut == TopCut.top8,
                        selectedPlayerIndex: viewModel.selectedPlayerIndex,
                        onSelectPlayer: (idx) {
                          context.read<TournamentEditorViewModel>().selectPlayer(idx);
                        },
                      ),
                    ),
                  ),
                  // Coluna Direita: Motor Analítico Completo em 5 Abas
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: DefaultTabController(
                        length: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const TabBar(
                              labelPadding: EdgeInsets.symmetric(horizontal: 4),
                              indicatorColor: Color(0xFFFF7A00),
                              labelColor: Color(0xFFFF7A00),
                              unselectedLabelColor: Colors.white54,
                              labelStyle: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold),
                              tabs: [
                                Tab(text: 'METAGAME'),
                                Tab(text: 'TOP CARTAS'),
                                Tab(text: 'DECKLIST'),
                                Tab(text: 'CONSENSO & DIFF'),
                                Tab(text: 'MATCHUPS'),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Expanded(
                              child: TabBarView(
                                children: [
                                  MetagameChartWidget(stats: viewModel.metagame),
                                  _buildTopCardsView(context, viewModel),
                                  _buildDecklistView(viewModel),
                                  _buildConsensusAndDiffView(viewModel),
                                  _buildMatchupMatrixView(viewModel),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopCardsView(BuildContext context, TournamentEditorViewModel viewModel) {
    final presence = viewModel.cardPresence;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'CARTAS MAIS USADAS & PRESENÇA (IR%)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF7A00),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: viewModel.availableArchetypeFilters.contains(viewModel.selectedArchetypeFilter)
                    ? viewModel.selectedArchetypeFilter
                    : 'TODOS',
                dropdownColor: const Color(0xFF1E1E1E),
                style: const TextStyle(fontSize: 12, color: Colors.white),
                items: viewModel.availableArchetypeFilters
                    .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    context.read<TournamentEditorViewModel>().setArchetypeFilter(val);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (presence.isEmpty)
            const Expanded(
              child: Center(
                child: Text('Nenhuma carta importada ainda.', style: TextStyle(color: Colors.white54)),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: presence.length,
                itemBuilder: (context, index) {
                  final stat = presence[index];
                  final dist = stat.copyDistribution;
                  final Color roleColor = stat.roleClass == CardRoleClass.core
                      ? const Color(0xFF009E73)
                      : (stat.roleClass == CardRoleClass.padrao
                          ? const Color(0xFF56B4E9)
                          : const Color(0xFFCC79A7));

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B1B1B),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF2B2B2B)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${index + 1}. ${stat.canonicalName}',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: roleColor.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: roleColor),
                                ),
                                child: Text(
                                  stat.roleLabel,
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: roleColor),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2A1500),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${stat.totalCopiesAcrossDecks}x (${(stat.inclusionRate * 100).toStringAsFixed(0)}%)',
                                  style: const TextStyle(
                                    color: Color(0xFFFF7A00),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Média: ${stat.conditionalMeanCopies.toStringAsFixed(1)} cópias • IR Ponderado (DCG): ${(stat.weightedInclusionRate * 100).toStringAsFixed(0)}% • Dist (1/2/3/4): ${dist[1] ?? 0}/${dist[2] ?? 0}/${dist[3] ?? 0}/${dist[4] ?? 0}',
                            style: const TextStyle(fontSize: 11, color: Colors.white60),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
    );
  }

  Widget _buildDecklistView(TournamentEditorViewModel viewModel) {
    if (viewModel.players.isEmpty) return const SizedBox.shrink();
    final playerIndex = viewModel.selectedPlayerIndex.clamp(0, viewModel.players.length - 1);
    final player = viewModel.players[playerIndex];

    if (viewModel.politicaVisibilidade == PoliticaVisibilidade.somenteAgregadosAnonimos) {
      return const Center(
        child: Text(
          'Política RN-04: Loja configurou exibição apenas de estatísticas agregadas anônimas.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    if (player.decklist == null || player.decklist!.cards.isEmpty) {
      return Center(
        child: Text(
          '${player.displayName} não possui decklist importada.',
          style: const TextStyle(color: Colors.white54),
        ),
      );
    }

    return DecklistViewWidget(
      decklist: player.decklist!,
      titlePrefix: 'DECKLIST: ${player.displayName.toUpperCase()} (${player.deckName})',
    );
  }

  Widget _buildConsensusAndDiffView(TournamentEditorViewModel viewModel) {
    final consensus = viewModel.consensusDeck;
    final diffs = viewModel.selectedPlayerDiff;
    final selectedPlayer = viewModel.players.isNotEmpty
        ? viewModel.players[viewModel.selectedPlayerIndex.clamp(0, viewModel.players.length - 1)]
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 6,
          child: DecklistViewWidget(
            decklist: consensus,
            titlePrefix: 'LISTA CONSENSO 60 CARTAS (${viewModel.selectedArchetypeFilter})',
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          flex: 4,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF141414),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2A2A2A)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'COMPARADOR DIFF: ${selectedPlayer?.displayName.toUpperCase() ?? "JOGADOR"} VS. CONSENSO (UC7)',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFA24D),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: diffs.length,
                    itemBuilder: (context, idx) {
                      final d = diffs[idx];
                      final delta = d.delta;
                      final Color deltaColor = delta > 0
                          ? const Color(0xFF00E676)
                          : (delta < 0 ? Colors.redAccent : Colors.white54);
                      final String deltaStr =
                          delta > 0 ? '+$delta tech' : (delta < 0 ? '$delta corte' : 'Idêntico');

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                d.cardName,
                                style: const TextStyle(fontSize: 12, color: Colors.white),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              'Jogador: ${d.playerQuantity}x | Consenso: ${d.consensusQuantity}x  ($deltaStr)',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: deltaColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMatchupMatrixView(TournamentEditorViewModel viewModel) {
    final cells = viewModel.matchupMatrix;
    final nonMirror = cells.where((c) => c.archetypeA != c.archetypeB && c.totalMatches > 0).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MATRIZ DE MATCHUPS & WIN RATE CRUZADO (FASE 7.2)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFFF7A00)),
          ),
          const SizedBox(height: 6),
          const Text(
            'Escala divergente centrada em 50% com Intervalo de Confiança de Wilson 95% e indicação de amostra (n < 5).',
            style: TextStyle(fontSize: 11, color: Colors.white54),
          ),
          const SizedBox(height: 12),
          if (nonMirror.isEmpty)
            const Expanded(
              child: Center(
                child: Text(
                  'Importe um arquivo .tdf com partidas para visualizar os confrontos diretos.',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: nonMirror.length,
                itemBuilder: (context, idx) {
                  final c = nonMirror[idx];
                  final wrPct = c.winRate * 100.0;
                  final Color heatColor = wrPct > 55
                      ? const Color(0xFF0E3A2A)
                      : (wrPct < 45 ? const Color(0xFF3A1515) : const Color(0xFF252525));

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: heatColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF383838)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${c.archetypeA}  vs.  ${c.archetypeB}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Recorde: ${c.recordLabel} (n=${c.totalMatches}) • IC Wilson: ${(c.wilsonLower * 100).toStringAsFixed(0)}%-${(c.wilsonUpper * 100).toStringAsFixed(0)}%${c.lowSample ? " • Amostra Baixa (RN-07)" : ""}',
                                style: const TextStyle(fontSize: 11, color: Colors.white70),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${wrPct.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: wrPct >= 50 ? const Color(0xFF00E676) : Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
