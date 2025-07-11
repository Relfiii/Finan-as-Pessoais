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

    // Calcular o valor máximo de forma mais precisa
    double maxY = 0;
    for (int i = 0; i < labels.length; i++) {
      if (i < receitas.length && receitas[i] > maxY) maxY = receitas[i];
      if (i < despesas.length && despesas[i] > maxY) maxY = despesas[i];
      if (i < investimentos.length && investimentos[i] > maxY) maxY = investimentos[i];
    }
    
    // Se não há dados, definir um valor mínimo
    if (maxY == 0) maxY = 1000;
    
    // Adicionar margem de 10% para visualização
    maxY *= 1.1;

    // Calcular intervalo dinamicamente baseado no valor máximo
    double intervaloY;
    if (maxY <= 1000) {
      intervaloY = 200;
    } else if (maxY <= 5000) {
      intervaloY = 1000;
    } else if (maxY <= 20000) {
      intervaloY = 5000;
    } else if (maxY <= 50000) {
      intervaloY = 10000;
    } else {
      intervaloY = 15000;
    }
    
    // Ajustar maxY para ser múltiplo do intervalo
    maxY = ((maxY / intervaloY).ceil() * intervaloY).toDouble();

    final ScrollController _scrollController = ScrollController();

    return Column(
      children: [
        // Legenda
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem('Receitas', const Color(0xFF00E676)),
              _buildLegendItem('Despesas', const Color(0xFFFF5252)),
              _buildLegendItem('Investimentos', const Color(0xFF00B0FF)),
            ],
          ),
        ),
        // Gráfico
        SizedBox(
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
                      String texto = '';
                      if (value >= 1000000) {
                        texto = '${(value / 1000000).toStringAsFixed(1)}M';
                      } else if (value >= 1000) {
                        int milhares = (value / 1000).round();
                        texto = '${milhares}k';
                      } else if (value > 0) {
                        texto = value.toInt().toString();
                      } else {
                        texto = '0';
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
                    width: labels.length * 120, // Aumentar largura para dar mais espaço
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceEvenly,
                        maxY: maxY,
                        minY: 0,
                        groupsSpace: 25, // Aumentar espaço entre grupos
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            tooltipRoundedRadius: 12,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              String tipo = '';
                              Color cor = Colors.white;
                              double valorReal = 0.0;
                              
                              if (rodIndex == 0) {
                                tipo = 'Receita';
                                cor = const Color(0xFF00E676);
                                valorReal = (groupIndex < receitas.length) ? receitas[groupIndex] : 0.0;
                              }
                              if (rodIndex == 1) {
                                tipo = 'Despesa';
                                cor = const Color(0xFFFF5252);
                                valorReal = (groupIndex < despesas.length) ? despesas[groupIndex] : 0.0;
                              }
                              if (rodIndex == 2) {
                                tipo = 'Investimento';
                                cor = const Color(0xFF00B0FF);
                                valorReal = (groupIndex < investimentos.length) ? investimentos[groupIndex] : 0.0;
                              }
                              
                              return BarTooltipItem(
                                '$tipo\n',
                                TextStyle(
                                  color: cor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                children: [
                                  TextSpan(
                                    text: NumberFormat.simpleCurrency(locale: 'pt_BR').format(valorReal.abs()),
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
                          horizontalInterval: intervaloY,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: Colors.white12,
                            strokeWidth: 1.2,
                            dashArray: [4, 6],
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: List.generate(labels.length, (i) {
                          // Garantir que os índices são válidos e usar valores reais
                          double receitaValue = (i < receitas.length) ? receitas[i].abs() : 0.0;
                          double despesaValue = (i < despesas.length) ? despesas[i].abs() : 0.0;
                          double investimentoValue = (i < investimentos.length) ? investimentos[i].abs() : 0.0;
                          
                          return BarChartGroupData(
                            x: i,
                            barRods: [
                              // Receitas (Verde)
                              BarChartRodData(
                                toY: receitaValue > 0 ? receitaValue : 0.1, // Mínimo para visualização
                                width: 12, // Aumentar largura das barras
                                color: const Color(0xFF00E676),
                                borderRadius: BorderRadius.circular(6),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF00E676), Color(0xFF1DE9B6)],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                                borderSide: const BorderSide(color: Colors.white24, width: 0.5),
                              ),
                              // Despesas (Vermelho)
                              BarChartRodData(
                                toY: despesaValue > 0 ? despesaValue : 0.1, // Mínimo para visualização
                                width: 12, // Aumentar largura das barras
                                color: const Color(0xFFFF5252),
                                borderRadius: BorderRadius.circular(6),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFF5252), Color(0xFFB71C1C)],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                                borderSide: const BorderSide(color: Colors.white24, width: 0.5),
                              ),
                              // Investimentos (Azul)
                              BarChartRodData(
                                toY: investimentoValue > 0 ? investimentoValue : 0.1, // Mínimo para visualização
                                width: 12, // Aumentar largura das barras
                                color: const Color(0xFF00B0FF),
                                borderRadius: BorderRadius.circular(6),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF00B0FF), Color(0xFF40C4FF)],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                                borderSide: const BorderSide(color: Colors.white24, width: 0.5),
                              ),
                            ],
                            barsSpace: 4, // Aumentar espaço entre barras do mesmo grupo
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
