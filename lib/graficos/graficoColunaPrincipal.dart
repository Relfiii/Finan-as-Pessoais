import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GraficoColunaPrincipal extends StatefulWidget {
  final List<String> labels;
  final List<double> receitas;
  final List<double> despesas;
  final List<double> investimentos;
  final bool enableAutoScroll; // Novo parâmetro

  const GraficoColunaPrincipal({
    Key? key,
    required this.labels,
    required this.receitas,
    required this.despesas,
    required this.investimentos,
    this.enableAutoScroll = false, // Padrão false
  }) : super(key: key);

  @override
  State<GraficoColunaPrincipal> createState() => _GraficoColunaPrincipalState();
}

class _GraficoColunaPrincipalState extends State<GraficoColunaPrincipal>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late ScrollController _scrollController;
  // int _currentVisibleMonth = 6;
  bool _hasAutoScrolled = false; // Controle do scroll único

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

    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    // Ajuste: itemWidth maior e totalWidth mais generosa para garantir scroll
    final double itemWidth = 65; // Aumentado para dar mais espaço
    final double totalWidth = minLength * itemWidth + 60; // Margem extra para scroll baseada no número real de elementos
    final double availableWidth = screenWidth - 80; // Mais margem

    // Scroll automático único para iniciar no mês atual (apenas se habilitado)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && 
          _scrollController.hasClients && 
          widget.enableAutoScroll && 
          !_hasAutoScrolled) {
        // Verificar se realmente precisa de scroll
        if (totalWidth > availableWidth) {
          // Marcar como executado antes de fazer o scroll
          _hasAutoScrolled = true;
          
          // Usar Timer para dar tempo do layout se estabilizar
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted && _scrollController.hasClients) {
              final maxScroll = _scrollController.position.maxScrollExtent;
              if (maxScroll > 0) {
                _scrollController.animateTo(
                  maxScroll, // Vai para o final (mês atual)
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeOutCubic,
                );
              }
            }
          });
        }
      }
    });

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            height: screenHeight * 0.6, // 60% da altura da tela
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Eixo Y reduzido
                Container(
                  width: 30,
                  padding: const EdgeInsets.only(right: 1, bottom: 25),
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
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              texto,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                // Área do gráfico maximizada
                Expanded(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification is ScrollUpdateNotification) {
                        // double position = _scrollController.position.pixels;
                        // double maxScroll = _scrollController.position.maxScrollExtent;
                        // setState(() {
                        //   _currentVisibleMonth = ((position / maxScroll) * 8 + 4).clamp(4, 12).toInt();
                        // });
                      }
                      return true;
                    },
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      controller: _scrollController,
                      physics: const ClampingScrollPhysics(), // Mudado para ClampingScrollPhysics
                      child: Container(
                        width: totalWidth,
                        padding: const EdgeInsets.only(bottom: 25, left: 10, right: 10), // Padding extra
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceEvenly,
                            maxY: maxY,
                            minY: 0,
                            groupsSpace: itemWidth * 0.2, // Ajustado espaçamento
                            barTouchData: BarTouchData(
                              enabled: true,
                              touchTooltipData: BarTouchTooltipData(
                                tooltipRoundedRadius: 12,
                                tooltipPadding: const EdgeInsets.all(8),
                                tooltipMargin: 6,
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
                                      fontSize: 12,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: NumberFormat.simpleCurrency(locale: 'pt_BR').format(valorReal.abs()),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 11,
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
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          label,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                  reservedSize: 25,
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
                                color: Colors.white.withOpacity(0.1),
                                strokeWidth: 1,
                                dashArray: [4, 6],
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            barGroups: List.generate(minLength, (i) {
                              double receitaValue = (i < receitasDoGrafico.length) ? receitasDoGrafico[i].abs() : 0.0;
                              double despesaValue = (i < despesasDoGrafico.length) ? despesasDoGrafico[i].abs() : 0.0;
                              double investimentoValue = (i < investimentosDoGrafico.length) ? investimentosDoGrafico[i].abs() : 0.0;
                              
                              double barWidth = (itemWidth * 0.6) / 3; // Ajustado para melhor proporção
                              if (barWidth > 18) barWidth = 18; // Limite máximo ajustado
                              if (barWidth < 8) barWidth = 8; // Limite mínimo ajustado
                              
                              return BarChartGroupData(
                                x: i,
                                barRods: [
                                  // Receitas
                                  BarChartRodData(
                                    toY: receitaValue > 0 ? receitaValue : 0.1,
                                    width: barWidth,
                                    borderRadius: BorderRadius.circular(6),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF00E676),
                                        Color(0xFF4CAF50),
                                      ],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                  ),
                                  // Despesas
                                  BarChartRodData(
                                    toY: despesaValue > 0 ? despesaValue : 0.1,
                                    width: barWidth,
                                    borderRadius: BorderRadius.circular(6),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFFF5252),
                                        Color(0xFFE91E63),
                                      ],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                  ),
                                  // Investimentos
                                  BarChartRodData(
                                    toY: investimentoValue > 0 ? investimentoValue : 0.1,
                                    width: barWidth,
                                    borderRadius: BorderRadius.circular(6),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF00B0FF),
                                        Color(0xFF2196F3),
                                      ],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                  ),
                                ],
                                barsSpace: barWidth * 0.2, // Reduzido espaçamento entre barras
                              );
                            }),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}