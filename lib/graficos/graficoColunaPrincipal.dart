import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';



class GraficoColunaPrincipal extends StatelessWidget {
  final List<String> labels;
  final List<double> receitas;
  final List<double> despesas;
  final List<double> investimentos;

  const GraficoColunaPrincipal({
    Key? key,
    required this.labels,
    required this.receitas,
    required this.despesas,
    required this.investimentos,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (labels.isEmpty) {
      return const Center(child: Text('Sem dados para exibir', style: TextStyle(color: Colors.white70)));
    }

    double maxY = [
      ...receitas,
      ...despesas,
      ...investimentos,
    ].fold<double>(0, (max, v) => v > max ? v : max);
    if (maxY == 0) maxY = 1000;
    maxY *= 1.1;

    double intervaloY;
    if (maxY <= 20000) {
      intervaloY = 5000;
      maxY = ((maxY / intervaloY).ceil() * intervaloY).toDouble();
    } else {
      intervaloY = 15000;
      maxY = ((maxY / intervaloY).ceil() * intervaloY).toDouble();
    }

    final ScrollController _scrollController = ScrollController();

    return SizedBox(
      height: 320,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Eixo Y fixo
          Container(
            width: 56,
            height: 320,
            padding: const EdgeInsets.only(right: 4),
            child: Column(
              children: List.generate(
                ((maxY ~/ intervaloY) + 1),
                (i) {
                  double value = maxY - (i * intervaloY);
                  int arredondado = (value / 1000).round() * 1000;
                  String texto = '';
                  if (arredondado >= 1000) {
                    texto = '${(arredondado ~/ 1000)} mil';
                  } else {
                    texto = arredondado.toString();
                  }
                  return Expanded(
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Text(
                        texto,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          shadows: [Shadow(color: Colors.black54, blurRadius: 2)],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Gráfico rolável
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: _scrollController,
              child: SizedBox(
                width: labels.length * 56,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceBetween,
                    maxY: maxY,
                    minY: 0,
                    groupsSpace: 28,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipRoundedRadius: 12,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          String tipo = '';
                          if (rodIndex == 0) tipo = 'Receita';
                          if (rodIndex == 1) tipo = 'Despesa';
                          if (rodIndex == 2) tipo = 'Invest.';
                          return BarTooltipItem(
                            '$tipo\n',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            children: [
                              TextSpan(
                                text: NumberFormat.simpleCurrency(locale: 'pt_BR').format(rod.toY),
                                style: const TextStyle(
                                  color: Colors.amber,
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
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx >= 0 && idx < labels.length) {
                              final label = labels[idx];
                              if (RegExp(r'^\d{4}$').hasMatch(label)) {
                                // Só ano
                                return Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Text(
                                    label,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                      shadows: [Shadow(color: Colors.black45, blurRadius: 2)],
                                    ),
                                  ),
                                );
                              } else {
                                // Mês/ano ou dia
                                return Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Text(
                                    label,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                      shadows: [Shadow(color: Colors.black45, blurRadius: 2)],
                                    ),
                                  ),
                                );
                              }
                            }
                            return const SizedBox.shrink();
                          },
                          reservedSize: 44,
                          interval: 1,
                        ),
                      ),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 5500,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.white12,
                        strokeWidth: 1.2,
                        dashArray: [4, 6],
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(labels.length, (i) {
                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: receitas[i],
                            width: 12,
                            color: const Color(0xFF00E676),
                            borderRadius: BorderRadius.circular(10),
                            rodStackItems: [],
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00E676), Color(0xFF1DE9B6)],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            borderSide: const BorderSide(color: Colors.white24, width: 1),
                          ),
                          BarChartRodData(
                            toY: despesas[i],
                            width: 12,
                            color: const Color(0xFFFF5252),
                            borderRadius: BorderRadius.circular(10),
                            rodStackItems: [],
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF5252), Color(0xFFB71C1C)],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            borderSide: const BorderSide(color: Colors.white24, width: 1),
                          ),
                          BarChartRodData(
                            toY: investimentos[i],
                            width: 12,
                            color: const Color(0xFF00B0FF),
                            borderRadius: BorderRadius.circular(10),
                            rodStackItems: [],
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00B0FF), Color(0xFF40C4FF)],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            borderSide: const BorderSide(color: Colors.white24, width: 1),
                          ),
                        ],
                        barsSpace: 4,
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}