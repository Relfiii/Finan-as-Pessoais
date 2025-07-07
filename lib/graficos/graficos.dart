import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

class GraficoVisaoGeral extends StatelessWidget {
  final double totalGastoMes;
  final double saldoAtual;
  final double investimento;
  const GraficoVisaoGeral({
    super.key,
    required this.totalGastoMes,
    required this.saldoAtual,
    required this.investimento,
  });

  @override
  Widget build(BuildContext context) {
    final List<_BarInfo> barras = [
      _BarInfo('Saldo', saldoAtual, Colors.green),
      _BarInfo('Gastos', totalGastoMes, Colors.red),
      _BarInfo('Invest.', investimento, Colors.blue),
    ];

    final double maxY = [
      saldoAtual.abs(),
      totalGastoMes.abs(),
      investimento.abs(),
      1
    ].reduce((a, b) => a > b ? a : b) *
        1.2;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          // Fundo gradiente com desfoque
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1E1E2C), Color(0xFF121212)],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.show_chart, color: Color(0xFFB983FF)),
                    SizedBox(width: 8),
                    Text(
                      'Resumo Financeiro',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Mês atual',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 180,
                  child: BarChart(
                    BarChartData(
                      backgroundColor: Colors.transparent,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          tooltipRoundedRadius: 10,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              '${barras[group.x.toInt()].label}\n',
                              TextStyle(
                                color: barras[group.x.toInt()].color,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              children: [
                                TextSpan(
                                  text: 'R\$ ${rod.toY.toStringAsFixed(2).replaceAll('.', ',')}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final idx = value.toInt();
                              if (idx < 0 || idx >= barras.length) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  barras[idx].label,
                                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      gridData: FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(barras.length, (i) {
                        return BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: barras[i].valor > 0 ? barras[i].valor : 0.01,
                              color: barras[i].color,
                              width: 36,
                              borderRadius: BorderRadius.circular(8),
                              rodStackItems: [],
                              borderSide: BorderSide.none,
                              backDrawRodData: BackgroundBarChartRodData(show: false),
                            ),
                          ],
                        );
                      }),
                      minY: 0,
                      maxY: maxY,
                      groupsSpace: 32,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: barras
                      .map((b) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              children: [
                                Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: b.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  b.label,
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BarInfo {
  final String label;
  final double valor;
  final Color color;
  _BarInfo(this.label, this.valor, this.color);
}