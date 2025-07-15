import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';

class GraficoColunaPrincipal extends StatefulWidget {
  final List<String> labels;
  final List<double> receitas;
  final List<double> despesas;
  final List<double> investimentos;
  final bool enableAutoScroll;
  final bool isDailyView;

  const GraficoColunaPrincipal({
    Key? key,
    required this.labels,
    required this.receitas,
    required this.despesas,
    required this.investimentos,
    this.enableAutoScroll = false,
    this.isDailyView = false,
  }) : super(key: key);

  @override
  State<GraficoColunaPrincipal> createState() => _GraficoColunaPrincipalState();
}

class _GraficoColunaPrincipalState extends State<GraficoColunaPrincipal>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    _scrollController = ScrollController();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Usar os dados reais passados pelo widget em vez de gerar novos
    List<String> mesesDoGrafico = widget.labels;
    List<double> receitasDoGrafico = widget.receitas;
    List<double> despesasDoGrafico = widget.despesas;
    List<double> investimentosDoGrafico = widget.investimentos;

    // Verificar se há dados válidos
    if (mesesDoGrafico.isEmpty || 
        receitasDoGrafico.isEmpty || 
        despesasDoGrafico.isEmpty || 
        investimentosDoGrafico.isEmpty) {
      return Center(
        child: Text(
          'Nenhum dado disponível para exibir',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    // Garantir que todas as listas tenham o mesmo tamanho
    int minLength = [
      mesesDoGrafico.length,
      receitasDoGrafico.length,
      despesasDoGrafico.length,
      investimentosDoGrafico.length
    ].reduce((a, b) => a < b ? a : b);

    if (minLength == 0) {
      return Center(
        child: Text(
          'Dados insuficientes para exibir o gráfico',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    // Ajustar listas para ter o mesmo tamanho
    mesesDoGrafico = mesesDoGrafico.take(minLength).toList();
    receitasDoGrafico = receitasDoGrafico.take(minLength).toList();
    despesasDoGrafico = despesasDoGrafico.take(minLength).toList();
    investimentosDoGrafico = investimentosDoGrafico.take(minLength).toList();

    // Calcular o valor máximo de forma mais precisa
    double maxY = 0;
    for (int i = 0; i < minLength; i++) {
      if (receitasDoGrafico[i] > maxY) maxY = receitasDoGrafico[i];
      if (despesasDoGrafico[i] > maxY) maxY = despesasDoGrafico[i];
      if (investimentosDoGrafico[i] > maxY) maxY = investimentosDoGrafico[i];
    }
    
    // Se não há dados, definir um valor mínimo
    if (maxY == 0) maxY = 1000;
    maxY *= 1.15; // Aumentando margem para 15%

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

    final double screenHeight = MediaQuery.of(context).size.height;
    
    // Configuração específica para visualização diária
    late double itemWidth;
    late double totalWidth;
    
    if (widget.isDailyView) {
      // Para visualização diária: 31 dias (25 anteriores + hoje + 5 posteriores)
      itemWidth = 70; // Largura adequada para 31 dias
      totalWidth = minLength * itemWidth + 120; // Total com margem extra
    } else {
      // Para visualização mensal/anual: comportamento original
      itemWidth = 65;
      totalWidth = minLength * itemWidth + 60;
    }

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Center(
            child: Container(
              width: kIsWeb ? 1000 : double.infinity,
              constraints: kIsWeb 
                ? const BoxConstraints(maxWidth: 1000)
                : null,
              child: Container(
                height: kIsWeb ? screenHeight * 1.90 : screenHeight * 1.9,
                width: double.infinity,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.grey[900]!.withOpacity(0.3),
                      Colors.grey[800]!.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Eixo Y estilizado
                    Container(
                      width: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.blue.withOpacity(0.1),
                            Colors.transparent,
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                      ),
                      padding: const EdgeInsets.only(right: 8, bottom: 30, top: 10),
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
                              texto = '${milhares} mil';
                            } else if (value > 0) {
                              texto = value.toInt().toString();
                            } else {
                              texto = '0';
                            }
                            return Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.white.withOpacity(0.05),
                                ),
                                margin: const EdgeInsets.symmetric(vertical: 1),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 6),
                                    child: Text(
                                      texto,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black.withOpacity(0.5),
                                            offset: const Offset(1, 1),
                                            blurRadius: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    
                    // Área do gráfico com design moderno
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.2),
                              Colors.transparent,
                            ],
                          ),
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: NotificationListener<ScrollNotification>(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            controller: _scrollController,
                            physics: const ClampingScrollPhysics(),
                            child: Container(
                              width: totalWidth,
                              padding: const EdgeInsets.only(bottom: 30, left: 15, right: 15, top: 10),
                              child: BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceEvenly,
                                  maxY: maxY,
                                  minY: 0,
                                  groupsSpace: widget.isDailyView ? itemWidth * 0.25 : itemWidth * 0.2,
                                  barTouchData: BarTouchData(
                                    enabled: true,
                                    touchTooltipData: BarTouchTooltipData(
                                      tooltipRoundedRadius: 16,
                                      tooltipPadding: const EdgeInsets.all(12),
                                      tooltipMargin: 8,
                                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                        String tipo = '';
                                        Color cor = Colors.white;
                                        double valorReal = 0.0;
                                        
                                        if (rodIndex == 0) {
                                          tipo = 'Receita';
                                          cor = const Color(0xFF00E676);
                                          valorReal = (groupIndex < receitasDoGrafico.length) ? receitasDoGrafico[groupIndex] : 0.0;
                                        } else if (rodIndex == 1) {
                                          tipo = 'Despesa';
                                          cor = const Color(0xFFFF5252);
                                          valorReal = (groupIndex < despesasDoGrafico.length) ? despesasDoGrafico[groupIndex] : 0.0;
                                        } else if (rodIndex == 2) {
                                          tipo = 'Investimento';
                                          cor = const Color(0xFF00B0FF);
                                          valorReal = (groupIndex < investimentosDoGrafico.length) ? investimentosDoGrafico[groupIndex] : 0.0;
                                        }
                                        
                                        return BarTooltipItem(
                                          '$tipo\n',
                                          TextStyle(
                                            color: cor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black.withOpacity(0.5),
                                                offset: const Offset(1, 1),
                                                blurRadius: 2,
                                              ),
                                            ],
                                          ),
                                          children: [
                                            TextSpan(
                                              text: NumberFormat.simpleCurrency(locale: 'pt_BR').format(valorReal.abs()),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                  titlesData: FlTitlesData(
                                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          final idx = value.toInt();
                                          if (idx >= 0 && idx < minLength && idx < mesesDoGrafico.length) {
                                            final label = mesesDoGrafico[idx];
                                            return Container(
                                              margin: const EdgeInsets.only(top: 12),
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.white.withOpacity(0.1),
                                                    Colors.white.withOpacity(0.05),
                                                  ],
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                ),
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: Colors.white.withOpacity(0.2),
                                                  width: 0.5,
                                                ),
                                              ),
                                              child: Text(
                                                label,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.white.withOpacity(0.9),
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  shadows: [
                                                    Shadow(
                                                      color: Colors.black.withOpacity(0.7),
                                                      offset: const Offset(1, 1),
                                                      blurRadius: 2,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }
                                          return const SizedBox.shrink();
                                        },
                                        reservedSize: 35,
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
                                      color: Colors.white.withOpacity(0.15),
                                      strokeWidth: 1.5,
                                      dashArray: [6, 8],
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  barGroups: List.generate(minLength, (i) {
                                    double receitaValue = (i < receitasDoGrafico.length) ? receitasDoGrafico[i].abs() : 0.0;
                                    double despesaValue = (i < despesasDoGrafico.length) ? despesasDoGrafico[i].abs() : 0.0;
                                    double investimentoValue = (i < investimentosDoGrafico.length) ? investimentosDoGrafico[i].abs() : 0.0;
                                    
                                    // Ajustar largura das barras baseado no tipo de visualização
                                    double barWidth;
                                    if (widget.isDailyView) {
                                      barWidth = (itemWidth * 0.45) / 3;
                                      if (barWidth > 18) barWidth = 18;
                                      if (barWidth < 8) barWidth = 8;
                                    } else {
                                      barWidth = (itemWidth * 0.6) / 3;
                                      if (barWidth > 18) barWidth = 18;
                                      if (barWidth < 8) barWidth = 8;
                                    }
                                    
                                    return BarChartGroupData(
                                      x: i,
                                      barRods: [
                                        // Receitas
                                        BarChartRodData(
                                          toY: receitaValue > 0 ? receitaValue : 0.1,
                                          width: barWidth,
                                          borderRadius: BorderRadius.circular(8),
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF4CAF50),
                                              Color(0xFF00E676),
                                              Color(0xFF81C784),
                                            ],
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                            stops: [0.0, 0.5, 1.0],
                                          ),
                                          backDrawRodData: BackgroundBarChartRodData(
                                            show: true,
                                            toY: maxY,
                                            color: Colors.white.withOpacity(0.03),
                                          ),
                                        ),
                                        // Despesas
                                        BarChartRodData(
                                          toY: despesaValue > 0 ? despesaValue : 0.1,
                                          width: barWidth,
                                          borderRadius: BorderRadius.circular(8),
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFFE91E63),
                                              Color(0xFFFF5252),
                                              Color(0xFFFF8A80),
                                            ],
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                            stops: [0.0, 0.5, 1.0],
                                          ),
                                          backDrawRodData: BackgroundBarChartRodData(
                                            show: true,
                                            toY: maxY,
                                            color: Colors.white.withOpacity(0.03),
                                          ),
                                        ),
                                        // Investimentos
                                        BarChartRodData(
                                          toY: investimentoValue > 0 ? investimentoValue : 0.1,
                                          width: barWidth,
                                          borderRadius: BorderRadius.circular(8),
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF2196F3),
                                              Color(0xFF00B0FF),
                                              Color(0xFF81D4FA),
                                            ],
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                            stops: [0.0, 0.5, 1.0],
                                          ),
                                          backDrawRodData: BackgroundBarChartRodData(
                                            show: true,
                                            toY: maxY,
                                            color: Colors.white.withOpacity(0.03),
                                          ),
                                        ),
                                      ],
                                      barsSpace: barWidth * 0.2,
                                    );
                                  }),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
