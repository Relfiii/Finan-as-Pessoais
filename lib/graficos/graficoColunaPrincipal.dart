import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum PeriodoFiltro { mes, ano, dia }

class GraficoColunaPrincipal extends StatefulWidget {
  final double saldoAtual;
  final double totalGastoMes;
  final double investimento;
  final PeriodoFiltro periodo;
  final List<DateTime>? meses;
  final List<String>? labels;

  const GraficoColunaPrincipal({
    Key? key,
    required this.saldoAtual,
    required this.totalGastoMes,
    required this.investimento,
    required this.periodo,
    this.meses,
    this.labels,
  }) : super(key: key);

  @override
  State<GraficoColunaPrincipal> createState() => _GraficoColunaPrincipalState();
}

class _GraficoColunaPrincipalState extends State<GraficoColunaPrincipal> {
  // Use widget.periodo para montar os dados
  List<Map<String, dynamic>> get _dados {
    if (widget.periodo == PeriodoFiltro.mes && widget.meses != null) {
      return List.generate(widget.meses!.length, (i) {
        final mes = widget.meses![i];
        final label = widget.labels != null && widget.labels!.length > i
            ? widget.labels![i]
            : DateFormat("MMM. yyyy", "pt_BR").format(mes);
        return {
          'label': label,
          'receita': widget.saldoAtual,        // Troque aqui para buscar o valor real do mês
          'despesa': widget.totalGastoMes,     // Troque aqui para buscar o valor real do mês
          'investimento': widget.investimento, // Troque aqui para buscar o valor real do mês
        };
      });
    } else {
      // Filtro por ano ou dia (mantém como estava)
      return [
        {
          'label': widget.periodo == PeriodoFiltro.ano
              ? DateFormat("yyyy").format(DateTime.now())
              : DateFormat("dd/MM").format(DateTime.now()),
          'receita': widget.saldoAtual,
          'despesa': widget.totalGastoMes,
          'investimento': widget.investimento,
        }
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxValor = _dados.fold<double>(
      0,
      (max, e) => [
        max,
        (e['receita'] is int ? (e['receita'] as int).toDouble() : e['receita'] as double),
        (e['despesa'] is int ? (e['despesa'] as int).toDouble() : e['despesa'] as double),
        (e['investimento'] is int ? (e['investimento'] as int).toDouble() : e['investimento'] as double),
      ].reduce((a, b) => a > b ? a : b),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 12),
        // Gráfico de barras
        SizedBox(
          height: 200, // Defina uma altura fixa aqui
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xFF181828),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: _dados.isEmpty
                ? Center(
                    child: Text(
                      'Sem dados para o período',
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final barGroupWidth = 32.0; // largura fixa para cada grupo de barras
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            for (final d in _dados)
                              SizedBox(
                                width: barGroupWidth,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    // Barras
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        // Receita
                                        Container(
                                          width: 6,
                                          height: maxValor > 0 ? ((d['receita'] as double) / maxValor) * 120 : 0,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(3),
                                            gradient: LinearGradient(
                                              colors: [
                                                Color(0xFF4EF37B),
                                                Color(0xFF1EAA6F),
                                              ],
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 2),
                                        // Despesa
                                        Container(
                                          width: 6,
                                          height: maxValor > 0 ? ((d['despesa'] as double) / maxValor) * 120 : 0,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(3),
                                            gradient: LinearGradient(
                                              colors: [
                                                Color(0xFFB983FF),
                                                Color(0xFF7B1FA2),
                                              ],
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 2),
                                        // Investimento
                                        Container(
                                          width: 6,
                                          height: maxValor > 0 ? ((d['investimento'] as double) / maxValor) * 120 : 0,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(3),
                                            gradient: LinearGradient(
                                              colors: [
                                                Color(0xFF0FD0FF),
                                                Color(0xFF0F6FFF),
                                              ],
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    // Labels
                                    Text(
                                      d['label'],
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 10,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ),
        SizedBox(height: 8),
        // Legenda
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendaCor(cor: Color(0xFF4EF37B), texto: 'Receita'),
            SizedBox(width: 16),
            _LegendaCor(cor: Color(0xFFB983FF), texto: 'Despesa'),
            SizedBox(width: 16),
            _LegendaCor(cor: Color(0xFF0FD0FF), texto: 'Investimento'),
          ],
        ),
      ],
    );
  }
}

class _LegendaCor extends StatelessWidget {
  final Color cor;
  final String texto;
  const _LegendaCor({required this.cor, required this.texto});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 16, height: 8, decoration: BoxDecoration(color: cor, borderRadius: BorderRadius.circular(4))),
        SizedBox(width: 4),
        Text(texto, style: TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}
