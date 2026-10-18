import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../domain/models/tournament.dart';
import '../../domain/models/metagame.dart';
import '../../domain/models/deck.dart';

class PdfExportService {
  static const PdfColor _brandOrange = PdfColor.fromInt(0xFFFF7A00);
  static const PdfColor _brandGold = PdfColor.fromInt(0xFFFFA24D);
  static const PdfColor _darkBg = PdfColor.fromInt(0xFF121212);
  static const PdfColor _cardBg = PdfColor.fromInt(0xFF1C1C1C);
  static const PdfColor _borderDark = PdfColor.fromInt(0xFF333333);
  static const PdfColor _okGreen = PdfColor.fromInt(0xFF00C853);

  static const List<PdfColor> _okabeItoPdfColors = [
    PdfColor.fromInt(0xFFFF7A00),
    PdfColor.fromInt(0xFF56B4E9),
    PdfColor.fromInt(0xFF009E73),
    PdfColor.fromInt(0xFFF0E442),
    PdfColor.fromInt(0xFFCC79A7),
    PdfColor.fromInt(0xFF0072B2),
    PdfColor.fromInt(0xFFD55E00),
  ];

  /// Sanitiza qualquer caractere fora do conjunto Latin-1 (WinAnsi) da fonte Helvetica padrão do PDF
  /// evitando caixas de glifo ausente "[X]" em bullets (•), travessões (—) ou emojis.
  static String _clean(String text) {
    return text
        .replaceAll('•', '|')
        .replaceAll('—', '-')
        .replaceAll('–', '-')
        .replaceAll('“', '"')
        .replaceAll('”', '"')
        .replaceAll('’', "'")
        .replaceAll('‘', "'")
        .replaceAll('→', '->')
        .replaceAll(RegExp(r'[^\x00-\xFF]'), '');
  }

  /// Gera o Infográfico Visual Vetorial em A4 Paisagem (Broadcast / Redes Sociais)
  Future<Uint8List> generateVisualInfographicPdf(
    Tournament tournament, {
    List<CardPresenceStat> cardPresence = const [],
    Decklist? consensusDeck,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(18),
            decoration: pw.BoxDecoration(
              color: _darkBg,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
              border: pw.Border.all(color: _brandOrange, width: 2),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                _buildInfographicHeader(tournament),
                pw.SizedBox(height: 12),
                pw.Expanded(
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                    children: [
                      // Coluna Esquerda: Pódio / Classificação Visual
                      pw.Expanded(
                        flex: 5,
                        child: _buildInfographicPodium(tournament),
                      ),
                      pw.SizedBox(width: 14),
                      // Coluna Direita: Gráfico de Barras do Metagame + Top Cartas
                      pw.Expanded(
                        flex: 5,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                          children: [
                            pw.Expanded(
                              flex: 6,
                              child: _buildInfographicMetagameChart(tournament.metagameStats),
                            ),
                            pw.SizedBox(height: 10),
                            pw.Expanded(
                              flex: 5,
                              child: _buildInfographicTopCards(cardPresence),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      _clean(
                        'METADEX TCG STUDIO | Relatorio Analitico de Torneio | Formato ${tournament.formato.nome} | ${tournament.topCutLabel}',
                      ),
                      style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey400),
                    ),
                    pw.Text(
                      _clean(
                        'Data: ${tournament.date.day.toString().padLeft(2, '0')}/${tournament.date.month.toString().padLeft(2, '0')}/${tournament.date.year}',
                      ),
                      style: const pw.TextStyle(fontSize: 8, color: _brandGold),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildInfographicHeader(Tournament tournament) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: pw.BoxDecoration(
        color: _cardBg,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: _borderDark),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                _clean(tournament.name.toUpperCase()),
                style: const pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
              pw.SizedBox(height: 3),
              pw.Text(
                _clean(
                  '${tournament.loja.nome} (${tournament.loja.cidade}-${tournament.loja.uf})  |  Formato: ${tournament.formato.nome}  |  ${tournament.topCutLabel}  |  ${tournament.players.length} Jogadores',
                ),
                style: const pw.TextStyle(fontSize: 9, color: _brandGold),
              ),
            ],
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: const pw.BoxDecoration(
              color: _brandOrange,
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(6)),
            ),
            child: pw.Text(
              _clean(tournament.tipoLabel.toUpperCase()),
              style: const pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildInfographicPodium(Tournament tournament) {
    final limit = tournament.topCut == TopCut.top4
        ? 4
        : (tournament.topCut == TopCut.top8 ? 8 : tournament.players.length.clamp(1, 8));
    final list = tournament.players.take(limit).toList();

    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: _cardBg,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: _borderDark),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            _clean(
              tournament.topCut == TopCut.none
                  ? 'CLASSIFICACAO FINAL (SUICO DIRETO - SEM CORTE)'
                  : 'PODIO & CLASSIFICACAO (${tournament.topCutLabel.toUpperCase()})',
            ),
            style: const pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: _brandOrange,
            ),
          ),
          pw.SizedBox(height: 8),
          ...list.map((p) {
            final isChamp = p.placement == 1;
            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 5),
              padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: pw.BoxDecoration(
                color: isChamp ? const PdfColor.fromInt(0xFF2B1700) : const PdfColor.fromInt(0xFF141414),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                border: pw.Border.all(
                  color: isChamp ? _brandOrange : _borderDark,
                  width: isChamp ? 1.5 : 0.8,
                ),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Row(
                    children: [
                      pw.Container(
                        width: 26,
                        child: pw.Text(
                          '${p.placement}o',
                          style: pw.TextStyle(
                            fontSize: isChamp ? 13 : 11,
                            fontWeight: pw.FontWeight.bold,
                            color: isChamp ? _brandOrange : PdfColors.white,
                          ),
                        ),
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            _clean(p.deckName),
                            style: const pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white,
                            ),
                          ),
                          pw.Text(
                            _clean('${p.displayName} (${p.divisionLabel})'),
                            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey400),
                          ),
                        ],
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        _clean('${p.recordString} (${p.matchPoints} pts)'),
                        style: const pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: _brandGold,
                        ),
                      ),
                      pw.Text(
                        'OWP ${(p.owp * 100).toStringAsFixed(1)}%',
                        style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey400),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  pw.Widget _buildInfographicMetagameChart(List<MetagameStat> stats) {
    final topStats = stats.take(6).toList();
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: _cardBg,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: _borderDark),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'METAGAME SHARE, CONVERSAO & WIN RATE (BAYES / WILSON 95%)',
            style: const pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: _brandOrange,
            ),
          ),
          pw.SizedBox(height: 8),
          ...List.generate(topStats.length, (idx) {
            final s = topStats[idx];
            final barColor = _okabeItoPdfColors[idx % _okabeItoPdfColors.length];
            final pctFraction = (s.percentage / 100.0).clamp(0.04, 1.0);

            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 7),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        _clean('${s.deckName} (${s.count}x)'),
                        style: const pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                      pw.Text(
                        _clean(
                          'Share: ${s.percentage.toStringAsFixed(1)}%  |  Conv: ${s.conversionRate.toStringAsFixed(2)}x  |  WR: ${(s.bayesianWinRate * 100).toStringAsFixed(0)}%',
                        ),
                        style: const pw.TextStyle(fontSize: 8, color: _brandGold),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 3),
                  pw.LayoutBuilder(
                    builder: (context, constraints) {
                      final maxW = constraints?.maxWidth ?? 280.0;
                      return pw.Stack(
                        children: [
                          pw.Container(
                            width: maxW,
                            height: 7,
                            decoration: const pw.BoxDecoration(
                              color: PdfColor.fromInt(0xFF2A2A2A),
                              borderRadius: pw.BorderRadius.all(pw.Radius.circular(3)),
                            ),
                          ),
                          pw.Container(
                            width: maxW * pctFraction,
                            height: 7,
                            decoration: pw.BoxDecoration(
                              color: barColor,
                              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  pw.Widget _buildInfographicTopCards(List<CardPresenceStat> cardPresence) {
    final top = cardPresence.take(6).toList();
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: _cardBg,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: _borderDark),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'STAPLES & PRESENCA DE CARTAS (TAXA DE INCLUSAO IR%)',
            style: const pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: _brandOrange,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Wrap(
            spacing: 8,
            runSpacing: 6,
            children: top.map((c) {
              return pw.Container(
                width: 165,
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: pw.BoxDecoration(
                  color: const PdfColor.fromInt(0xFF141414),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
                  border: pw.Border.all(color: _borderDark),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            _clean(c.canonicalName),
                            style: const pw.TextStyle(
                              fontSize: 8.5,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white,
                            ),
                            maxLines: 1,
                          ),
                          pw.Text(
                            _clean('${c.roleLabel} | Media ${c.conditionalMeanCopies.toStringAsFixed(1)}x'),
                            style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey400),
                          ),
                        ],
                      ),
                    ),
                    pw.Text(
                      '${(c.inclusionRate * 100).toStringAsFixed(0)}%',
                      style: const pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: _okGreen,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Gera o relatório completo em PDF A4 Retrato (Standings + Metagame + Presença + Lista Consenso em 3 colunas)
  Future<Uint8List> generateTournamentReport(
    Tournament tournament, {
    List<CardPresenceStat> cardPresence = const [],
    Decklist? consensusDeck,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (pw.Context context) {
          return [
            _buildHeader(tournament),
            pw.SizedBox(height: 14),
            _buildTopCutTable(tournament),
            pw.SizedBox(height: 18),
            _buildMetagameSection(tournament.metagameStats),
            if (cardPresence.isNotEmpty) ...[
              pw.SizedBox(height: 18),
              _buildCardPresenceSection(cardPresence),
            ],
            if (consensusDeck != null && consensusDeck.cards.isNotEmpty) ...[
              pw.SizedBox(height: 18),
              _buildDecklistSection('LISTA CONSENSO (60 CARTAS)', consensusDeck),
            ],
            pw.SizedBox(height: 16),
            pw.Divider(color: PdfColors.grey400),
            pw.Text(
              _clean(
                'Gerado por MetaDex TCG Studio | Projeto de fa nao oficial. Pokemon e seus elementos sao marcas de Nintendo, Creatures, GAME FREAK e The Pokemon Company.',
              ),
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader(Tournament tournament) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: _darkBg,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: _brandOrange, width: 1.5),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                _clean(tournament.name.toUpperCase()),
                style: const pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                _clean(
                  'Loja: ${tournament.loja.nome} (${tournament.loja.cidade}-${tournament.loja.uf})  |  ${tournament.tipoLabel}  |  Formato: ${tournament.formato.nome}',
                ),
                style: const pw.TextStyle(fontSize: 9.5, color: _brandGold),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'Data: ${tournament.date.day.toString().padLeft(2, '0')}/${tournament.date.month.toString().padLeft(2, '0')}/${tournament.date.year}',
                style: const pw.TextStyle(
                  fontSize: 9.5,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                _clean('${tournament.topCutLabel} | ${tournament.estadoLabel}'),
                style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey300),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildTopCutTable(Tournament tournament) {
    final headers = ['Pos', 'Jogador (LGPD)', 'Divisao', 'Arquetipo', 'Recorde', 'Pts', 'OWP%', 'Legalidade'];
    final data = tournament.players.map((p) {
      final isLegal = p.validationResult?.isValida ?? true;
      return [
        '${p.placement}o',
        _clean(p.displayName),
        _clean(p.divisionLabel),
        _clean(p.deckName),
        p.recordString,
        '${p.matchPoints}',
        '${(p.owp * 100).toStringAsFixed(1)}%',
        isLegal ? 'VALIDA (60)' : 'INVALIDA',
      ];
    }).toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          _clean('CLASSIFICACAO & STANDINGS (${tournament.topCutLabel.toUpperCase()})'),
          style: const pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 6),
        pw.TableHelper.fromTextArray(
          headers: headers,
          data: data,
          headerStyle: const pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey900),
          cellStyle: const pw.TextStyle(fontSize: 8.5),
          cellAlignment: pw.Alignment.centerLeft,
        ),
      ],
    );
  }

  pw.Widget _buildMetagameSection(List<MetagameStat> stats) {
    final headers = ['Arquetipo', 'Qtd', 'Meta Share', 'Top Cut%', 'Conversao', 'WR Real', 'WR Bayes', 'IC Wilson 95%'];
    final data = stats.map((s) {
      return [
        _clean(s.deckName),
        '${s.count}',
        '${s.percentage.toStringAsFixed(1)}%',
        '${s.topCutPercentage.toStringAsFixed(1)}%',
        '${s.conversionRate.toStringAsFixed(2)}x',
        '${(s.rawWinRate * 100).toStringAsFixed(1)}%',
        '${(s.bayesianWinRate * 100).toStringAsFixed(1)}%',
        '${(s.wilsonLower * 100).toStringAsFixed(0)}-${(s.wilsonUpper * 100).toStringAsFixed(0)}%',
      ];
    }).toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'METAGAME ANALYTICS & TAXA DE CONVERSAO',
          style: const pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 6),
        pw.TableHelper.fromTextArray(
          headers: headers,
          data: data,
          headerStyle: const pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.orange800),
          cellStyle: const pw.TextStyle(fontSize: 8.5),
        ),
      ],
    );
  }

  pw.Widget _buildCardPresenceSection(List<CardPresenceStat> stats) {
    final top = stats.take(12).toList();
    final headers = ['Carta Canonica', 'Inclusao (IR)', 'Media Copias', 'IR Ponderado (DCG)', '1x/2x/3x/4x', 'Classe'];
    final data = top.map((c) {
      final d = c.copyDistribution;
      return [
        _clean(c.canonicalName),
        '${(c.inclusionRate * 100).toStringAsFixed(0)}%',
        c.conditionalMeanCopies.toStringAsFixed(1),
        '${(c.weightedInclusionRate * 100).toStringAsFixed(0)}%',
        '${d[1] ?? 0}/${d[2] ?? 0}/${d[3] ?? 0}/${d[4] ?? 0}',
        _clean(c.roleLabel),
      ];
    }).toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'PRESENCA DE CARTAS & TAXA DE INCLUSAO',
          style: const pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 6),
        pw.TableHelper.fromTextArray(
          headers: headers,
          data: data,
          headerStyle: const pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey800),
          cellStyle: const pw.TextStyle(fontSize: 8.5),
        ),
      ],
    );
  }

  /// Renderiza a Lista Consenso (60 Cartas) estruturada em 3 colunas (Pokemon, Trainers, Energias) sem glifos quebrados
  pw.Widget _buildDecklistSection(String title, Decklist deck) {
    final pkmn = deck.pokemons;
    final trainers = deck.trainers;
    final energies = deck.energies;

    pw.Widget buildCategoryColumn(String catTitle, List<DeckCard> list) {
      final total = list.fold(0, (s, c) => s + c.quantity);
      return pw.Container(
        padding: const pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
          color: PdfColors.grey100,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
          border: pw.Border.all(color: PdfColors.grey300),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              _clean('$catTitle ($total)'),
              style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.orange900),
            ),
            pw.Divider(color: PdfColors.grey300, height: 8),
            ...list.map(
              (c) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 2.5),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        _clean('${c.quantity}x ${c.name}'),
                        style: const pw.TextStyle(fontSize: 8),
                      ),
                    ),
                    pw.Text(
                      _clean('${c.setCode ?? "SV"} ${c.setNumber ?? ""}'),
                      style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(_clean(title), style: const pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(child: buildCategoryColumn('POKEMON', pkmn)),
            pw.SizedBox(width: 8),
            pw.Expanded(child: buildCategoryColumn('TRAINERS', trainers)),
            pw.SizedBox(width: 8),
            pw.Expanded(child: buildCategoryColumn('ENERGIAS', energies)),
          ],
        ),
      ],
    );
  }

  /// Abre a janela de compartilhamento/download do Relatório Analítico Oficial (A4 Retrato)
  Future<void> shareOrPrintPdf(
    Tournament tournament, {
    List<CardPresenceStat> cardPresence = const [],
    Decklist? consensusDeck,
  }) async {
    final pdfBytes = await generateTournamentReport(
      tournament,
      cardPresence: cardPresence,
      consensusDeck: consensusDeck,
    );
    await Printing.sharePdf(bytes: pdfBytes, filename: 'relatorio_oficial_${tournament.id}.pdf');
  }

  /// Abre a janela de compartilhamento/download do Infográfico Visual (A4 Paisagem Dark/Gold)
  Future<void> shareVisualInfographicPdf(
    Tournament tournament, {
    List<CardPresenceStat> cardPresence = const [],
    Decklist? consensusDeck,
  }) async {
    final pdfBytes = await generateVisualInfographicPdf(
      tournament,
      cardPresence: cardPresence,
      consensusDeck: consensusDeck,
    );
    await Printing.sharePdf(bytes: pdfBytes, filename: 'infografico_metagame_${tournament.id}.pdf');
  }
}
