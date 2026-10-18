import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../domain/models/tournament.dart';
import '../../domain/models/metagame.dart';
import '../../domain/models/deck.dart';

class PdfExportService {
  /// Gera o relatório completo em PDF (Standings + Metagame + Presença de Cartas + Decklist Consenso)
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
            pw.SizedBox(height: 16),
            _buildTopCutTable(tournament),
            pw.SizedBox(height: 20),
            _buildMetagameSection(tournament.metagameStats),
            if (cardPresence.isNotEmpty) ...[
              pw.SizedBox(height: 20),
              _buildCardPresenceSection(cardPresence),
            ],
            if (consensusDeck != null && consensusDeck.cards.isNotEmpty) ...[
              pw.SizedBox(height: 20),
              _buildDecklistSection('LISTA CONSENSO (60 CARTAS)', consensusDeck),
            ],
            pw.SizedBox(height: 16),
            pw.Divider(color: PdfColors.grey400),
            pw.Text(
              'Gerado por MetaDex • Projeto de fã não oficial. Pokémon e seus elementos são marcas de Nintendo, Creatures, GAME FREAK e The Pokémon Company.',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader(Tournament tournament) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  tournament.name.toUpperCase(),
                  style: const pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Loja: ${tournament.loja.nome} (${tournament.loja.cidade}-${tournament.loja.uf}) • ${tournament.tipoLabel} • Formato: ${tournament.formato.nome}',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'Data: ${tournament.date.day.toString().padLeft(2, '0')}/${tournament.date.month.toString().padLeft(2, '0')}/${tournament.date.year}',
                  style: const pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  'Estado: ${tournament.estadoLabel}',
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Divider(),
      ],
    );
  }

  pw.Widget _buildTopCutTable(Tournament tournament) {
    final headers = ['Pos', 'Jogador (LGPD)', 'Divisão', 'Arquétipo', 'Recorde', 'Pts', 'OWP%', 'Legalidade'];
    final data = tournament.players.map((p) {
      final isLegal = p.validationResult?.isValida ?? true;
      return [
        '${p.placement}º',
        p.displayName,
        p.divisionLabel,
        p.deckName,
        p.recordString,
        '${p.matchPoints}',
        '${(p.owp * 100).toStringAsFixed(1)}%',
        isLegal ? 'VÁLIDA (60)' : 'INVÁLIDA',
      ];
    }).toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'CLASSIFICAÇÃO & STANDINGS (TOM)',
          style: const pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        pw.TableHelper.fromTextArray(
          headers: headers,
          data: data,
          headerStyle: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey900),
          cellStyle: const pw.TextStyle(fontSize: 9),
          cellAlignment: pw.Alignment.centerLeft,
        ),
      ],
    );
  }

  pw.Widget _buildMetagameSection(List<MetagameStat> stats) {
    final headers = ['Arquétipo', 'Qtd', 'Meta Share', 'Top Cut%', 'Conversão', 'WR Real', 'WR Bayes', 'IC Wilson 95%'];
    final data = stats.map((s) {
      return [
        s.deckName,
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
          'METAGAME ANALYTICS & TAXA DE CONVERSÃO',
          style: const pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        pw.TableHelper.fromTextArray(
          headers: headers,
          data: data,
          headerStyle: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.orange800),
          cellStyle: const pw.TextStyle(fontSize: 9),
        ),
      ],
    );
  }

  pw.Widget _buildCardPresenceSection(List<CardPresenceStat> stats) {
    final top = stats.take(12).toList();
    final headers = ['Carta Canônica', 'Inclusão (IR)', 'Média Cópias', 'IR Ponderado (DCG)', '1x/2x/3x/4x', 'Classe'];
    final data = top.map((c) {
      final d = c.copyDistribution;
      return [
        c.canonicalName,
        '${(c.inclusionRate * 100).toStringAsFixed(0)}%',
        c.conditionalMeanCopies.toStringAsFixed(1),
        '${(c.weightedInclusionRate * 100).toStringAsFixed(0)}%',
        '${d[1] ?? 0}/${d[2] ?? 0}/${d[3] ?? 0}/${d[4] ?? 0}',
        c.roleLabel,
      ];
    }).toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'PRESENÇA DE CARTAS & TAXA DE INCLUSÃO',
          style: const pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        pw.TableHelper.fromTextArray(
          headers: headers,
          data: data,
          headerStyle: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey800),
          cellStyle: const pw.TextStyle(fontSize: 9),
        ),
      ],
    );
  }

  pw.Widget _buildDecklistSection(String title, Decklist deck) {
    final lines = deck.cards.map((c) => '${c.quantity}x ${c.name} (${c.setCode ?? "SV"} ${c.setNumber ?? ""})').join('  •  ');
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: const pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        pw.Text(lines, style: const pw.TextStyle(fontSize: 9)),
      ],
    );
  }

  /// Imprime ou abre a janela de compartilhamento (Share) do sistema
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
    await Printing.sharePdf(bytes: pdfBytes, filename: 'report_${tournament.id}.pdf');
  }
}
