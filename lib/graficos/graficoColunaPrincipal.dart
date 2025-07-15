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
    
    // Posicionar no período atual após a animação
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentPeriod();
    });
  }

  void _scrollToCurrentPeriod() {
    if (!_scrollController.hasClients) return;
    
    // Aguardar um pouco para garantir que o layout está completo
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted || !_scrollController.hasClients) return;
      
      final now = DateTime.now();
      int currentIndex = -1;
      
      // Encontrar o índice do período atual
      if (widget.isDailyView) {
        // Para visualização diária, encontrar o dia atual
        for (int i = 0; i < widget.labels.length; i++) {
          final label = widget.labels[i];
          try {
            // Tentar diferentes formatos de data
            if (label.contains('/')) {
              // Formato DD/MM ou DD/MM/YYYY
              List<String> parts = label.split('/');
              int day = int.parse(parts[0]);
              if (parts.length > 1) {
                int month = int.parse(parts[1]);
                if (day == now.day && month == now.month) {
                  currentIndex = i;
                  break;
                }
              } else if (day == now.day) {
                currentIndex = i;
                break;
              }
            } else if (label.contains('-')) {
              // Formato DD-MM ou DD-MM-YYYY
              List<String> parts = label.split('-');
              int day = int.parse(parts[0]);
              if (parts.length > 1) {
                int month = int.parse(parts[1]);
                if (day == now.day && month == now.month) {
                  currentIndex = i;
                  break;
                }
              } else if (day == now.day) {
                currentIndex = i;
                break;
              }
            } else {
              // Apenas número do dia
              int day = int.parse(label);
              if (day == now.day) {
                currentIndex = i;
                break;
              }
            }
          } catch (e) {
            // Se não conseguir parsear, verifica se contém o dia atual como string
            if (label.contains(now.day.toString())) {
              currentIndex = i;
              break;
            }
          }
        }
      } else {
        // Para visualização mensal/anual, encontrar o mês atual
        for (int i = 0; i < widget.labels.length; i++) {
          final label = widget.labels[i].toLowerCase();
          final currentMonth = _getMonthName(now.month).toLowerCase();
          final currentMonthShort = _getMonthNameShort(now.month).toLowerCase();
          final currentMonthNumber = now.month.toString().padLeft(2, '0');
          final currentYear = now.year.toString();
          
          // Verificar diferentes formatos possíveis
          if (label.contains(currentMonth) || 
              label.contains(currentMonthShort) ||
              label.contains(currentMonthNumber) ||
              (label.contains(currentYear) && 
               (label.contains(currentMonth) || label.contains(currentMonthShort)))) {
            currentIndex = i;
            break;
          }
        }
      }
      
      // Se encontrou o período atual, rolar para ele
      if (currentIndex != -1) {
        _scrollToIndex(currentIndex);
      }
    });
  }
  
  void _scrollToIndex(int index) {
    if (!_scrollController.hasClients) return;
    
    final screenWidth = MediaQuery.of(context).size.width;
    bool isSmallScreen = screenWidth < 600;
    bool isMediumScreen = screenWidth >= 600 && screenWidth < 1024;
    
    // Calcular dimensões (mesmo cálculo do build)
    late double itemWidth;
    late double yAxisWidth;
    
    if (isSmallScreen) {
      yAxisWidth = 35;
      if (widget.isDailyView) {
        itemWidth = (screenWidth - yAxisWidth - 40) / 7;
        if (itemWidth < 35) itemWidth = 35;
        if (itemWidth > 55) itemWidth = 55;
      } else {
        itemWidth = (screenWidth - yAxisWidth - 40) / 4;
        if (itemWidth < 45) itemWidth = 45;
        if (itemWidth > 75) itemWidth = 75;
      }
    } else if (isMediumScreen) {
      yAxisWidth = 45;
      if (widget.isDailyView) {
        itemWidth = (screenWidth - yAxisWidth - 60) / 10;
        if (itemWidth < 45) itemWidth = 45;
        if (itemWidth > 70) itemWidth = 70;
      } else {
        itemWidth = (screenWidth - yAxisWidth - 60) / 6;
        if (itemWidth < 55) itemWidth = 55;
        if (itemWidth > 85) itemWidth = 85;
      }
    } else {
      yAxisWidth = 55;
      if (widget.isDailyView) {
        itemWidth = (screenWidth - yAxisWidth - 100) / 15;
        if (itemWidth < 55) itemWidth = 55;
        if (itemWidth > 85) itemWidth = 85;
      } else {
        itemWidth = (screenWidth - yAxisWidth - 100) / 8;
        if (itemWidth < 65) itemWidth = 65;
        if (itemWidth > 100) itemWidth = 100;
      }
    }
    
    // Calcular posição de scroll para centralizar o item atual
    double groupsSpace = isSmallScreen 
      ? itemWidth * 0.15 
      : (widget.isDailyView ? itemWidth * 0.2 : itemWidth * 0.18);
    
    double itemPosition = index * (itemWidth + groupsSpace);
    double centerOffset = (screenWidth - yAxisWidth) / 2;
    double targetScroll = itemPosition - centerOffset + (itemWidth / 2);
    
    // Garantir que não role além dos limites
    double maxScroll = _scrollController.position.maxScrollExtent;
    targetScroll = targetScroll.clamp(0.0, maxScroll);
    
    _scrollController.animateTo(
      targetScroll,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutCubic,
    );
  }
  
  String _getMonthName(int month) {
    const months = [
      '', 'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    return months[month];
  }
  
  String _getMonthNameShort(int month) {
    const months = [
      '', 'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    return months[month];
  }
  
  bool _isCurrentPeriod(int index) {
    if (index >= widget.labels.length) return false;
    
    final now = DateTime.now();
    final label = widget.labels[index];
    
    if (widget.isDailyView) {
      // Para visualização diária, verificar se é o dia atual
      try {
        if (label.contains('/')) {
          List<String> parts = label.split('/');
          int day = int.parse(parts[0]);
          if (parts.length > 1) {
            int month = int.parse(parts[1]);
            return day == now.day && month == now.month;
          } else {
            return day == now.day;
          }
        } else if (label.contains('-')) {
          List<String> parts = label.split('-');
          int day = int.parse(parts[0]);
          if (parts.length > 1) {
            int month = int.parse(parts[1]);
            return day == now.day && month == now.month;
          } else {
            return day == now.day;
          }
        } else {
          int day = int.parse(label);
          return day == now.day;
        }
      } catch (e) {
        return label.contains(now.day.toString());
      }
    } else {
      // Para visualização mensal, verificar se é o mês atual
      final labelLower = label.toLowerCase();
      final currentMonth = _getMonthName(now.month).toLowerCase();
      final currentMonthShort = _getMonthNameShort(now.month).toLowerCase();
      final currentMonthNumber = now.month.toString().padLeft(2, '0');
      final currentYear = now.year.toString();
      
      return labelLower.contains(currentMonth) || 
             labelLower.contains(currentMonthShort) ||
             labelLower.contains(currentMonthNumber) ||
             (labelLower.contains(currentYear) && 
              (labelLower.contains(currentMonth) || labelLower.contains(currentMonthShort)));
    }
  }

  @override
  void didUpdateWidget(GraficoColunaPrincipal oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Se os dados mudaram, reposicionar no período atual
    if (oldWidget.labels != widget.labels ||
        oldWidget.isDailyView != widget.isDailyView) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToCurrentPeriod();
      });
    }
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
    final double screenWidth = MediaQuery.of(context).size.width;
    
    // Configuração responsiva baseada no tamanho da tela
    late double itemWidth;
    late double totalWidth;
    late double containerHeight;
    late double yAxisWidth;
    late double chartPadding;
    
    // Determinar breakpoints responsivos
    bool isSmallScreen = screenWidth < 600;
    bool isMediumScreen = screenWidth >= 600 && screenWidth < 1024;
    bool isLargeScreen = screenWidth >= 1024;
    
    // Configurar dimensões baseadas no tamanho da tela
    if (isSmallScreen) {
      // Celulares
      yAxisWidth = 35;
      chartPadding = 8;
      containerHeight = screenHeight * 0.45; // Reduzido para celulares
      
      if (widget.isDailyView) {
        itemWidth = (screenWidth - yAxisWidth - 40) / 7; // Mostra ~7 dias visíveis
        if (itemWidth < 35) itemWidth = 35;
        if (itemWidth > 55) itemWidth = 55;
      } else {
        itemWidth = (screenWidth - yAxisWidth - 40) / 4; // Mostra ~4 meses visíveis
        if (itemWidth < 45) itemWidth = 45;
        if (itemWidth > 75) itemWidth = 75;
      }
    } else if (isMediumScreen) {
      // Tablets
      yAxisWidth = 45;
      chartPadding = 12;
      containerHeight = screenHeight * 0.6;
      
      if (widget.isDailyView) {
        itemWidth = (screenWidth - yAxisWidth - 60) / 10; // Mostra ~10 dias visíveis
        if (itemWidth < 45) itemWidth = 45;
        if (itemWidth > 70) itemWidth = 70;
      } else {
        itemWidth = (screenWidth - yAxisWidth - 60) / 6; // Mostra ~6 meses visíveis
        if (itemWidth < 55) itemWidth = 55;
        if (itemWidth > 85) itemWidth = 85;
      }
    } else {
      // Desktop/Laptops
      yAxisWidth = 55;
      chartPadding = 16;
      containerHeight = kIsWeb ? screenHeight * 0.75 : screenHeight * 0.7;
      
      if (widget.isDailyView) {
        itemWidth = (screenWidth - yAxisWidth - 100) / 15; // Mostra ~15 dias visíveis
        if (itemWidth < 55) itemWidth = 55;
        if (itemWidth > 85) itemWidth = 85;
      } else {
        itemWidth = (screenWidth - yAxisWidth - 100) / 8; // Mostra ~8 meses visíveis
        if (itemWidth < 65) itemWidth = 65;
        if (itemWidth > 100) itemWidth = 100;
      }
    }
    
    totalWidth = minLength * itemWidth + (chartPadding * 4);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Center(
            child: Container(
              width: isLargeScreen 
                ? (screenWidth > 1200 ? 1200 : screenWidth * 0.95)
                : double.infinity,
              constraints: isLargeScreen 
                ? BoxConstraints(
                    maxWidth: 1200,
                    minWidth: 800,
                  )
                : null,
              child: Container(
                height: containerHeight,
                width: double.infinity,
                margin: EdgeInsets.all(chartPadding),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.grey[900]!.withOpacity(0.3),
                      Colors.grey[800]!.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(isSmallScreen ? 15 : 20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: isSmallScreen ? 10 : 15,
                      offset: Offset(0, isSmallScreen ? 4 : 8),
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: chartPadding, 
                  vertical: chartPadding + 4
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Eixo Y estilizado e responsivo
                    Container(
                      width: yAxisWidth,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.blue.withOpacity(0.1),
                            Colors.transparent,
                          ],
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(isSmallScreen ? 8 : 12),
                          bottomLeft: Radius.circular(isSmallScreen ? 8 : 12),
                        ),
                      ),
                      padding: EdgeInsets.only(
                        right: isSmallScreen ? 4 : 8, 
                        bottom: isSmallScreen ? 20 : 30, 
                        top: isSmallScreen ? 5 : 10
                      ),
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
                                margin: const EdgeInsets.symmetric(vertical: 1),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isSmallScreen ? 3 : 6
                                    ),
                                    child: Text(
                                      texto,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: isSmallScreen ? 8 : (isMediumScreen ? 9 : 10),
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
                    
                    // Área do gráfico com design moderno e responsivo
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
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(isSmallScreen ? 8 : 12),
                            bottomRight: Radius.circular(isSmallScreen ? 8 : 12),
                          ),
                        ),
                        child: NotificationListener<ScrollNotification>(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            controller: _scrollController,
                            physics: const ClampingScrollPhysics(),
                            child: Container(
                              width: totalWidth,
                              padding: EdgeInsets.only(
                                bottom: isSmallScreen ? 20 : 30, 
                                left: chartPadding - 3, 
                                right: chartPadding - 3, 
                                top: isSmallScreen ? 5 : 10
                              ),
                              child: BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceEvenly,
                                  maxY: maxY,
                                  minY: 0,
                                  groupsSpace: isSmallScreen 
                                    ? itemWidth * 0.15 
                                    : (widget.isDailyView ? itemWidth * 0.2 : itemWidth * 0.18),
                                  barTouchData: BarTouchData(
                                    enabled: true,
                                    touchTooltipData: BarTouchTooltipData(
                                      tooltipRoundedRadius: isSmallScreen ? 12 : 16,
                                      tooltipPadding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                                      tooltipMargin: isSmallScreen ? 6 : 8,
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
                                            fontSize: isSmallScreen ? 11 : (isMediumScreen ? 12 : 13),
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
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: isSmallScreen ? 10 : (isMediumScreen ? 11 : 12),
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
                                              margin: EdgeInsets.only(
                                                top: isSmallScreen ? 8 : 12
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                horizontal: isSmallScreen ? 4 : 6, 
                                                vertical: isSmallScreen ? 2 : 4
                                              ),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.white.withOpacity(0.1),
                                                    Colors.white.withOpacity(0.05),
                                                  ],
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                ),
                                                borderRadius: BorderRadius.circular(
                                                  isSmallScreen ? 6 : 8
                                                ),
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
                                                  fontSize: isSmallScreen ? 8 : (isMediumScreen ? 9 : 10),
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
                                        reservedSize: isSmallScreen ? 25 : (isMediumScreen ? 30 : 35),
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
                                    
                                    // Verificar se é o período atual para destacar
                                    bool isCurrentPeriod = _isCurrentPeriod(i);
                                    
                                    // Ajustar largura das barras baseado no tamanho da tela e tipo de visualização
                                    double barWidth;
                                    double barWidthMultiplier = isSmallScreen ? 0.35 : (isMediumScreen ? 0.45 : 0.55);
                                    
                                    if (widget.isDailyView) {
                                      barWidth = (itemWidth * barWidthMultiplier) / 3;
                                      if (isSmallScreen) {
                                        if (barWidth > 12) barWidth = 12;
                                        if (barWidth < 6) barWidth = 6;
                                      } else if (isMediumScreen) {
                                        if (barWidth > 16) barWidth = 16;
                                        if (barWidth < 8) barWidth = 8;
                                      } else {
                                        if (barWidth > 20) barWidth = 20;
                                        if (barWidth < 10) barWidth = 10;
                                      }
                                    } else {
                                      barWidth = (itemWidth * (barWidthMultiplier + 0.1)) / 3;
                                      if (isSmallScreen) {
                                        if (barWidth > 14) barWidth = 14;
                                        if (barWidth < 7) barWidth = 7;
                                      } else if (isMediumScreen) {
                                        if (barWidth > 18) barWidth = 18;
                                        if (barWidth < 9) barWidth = 9;
                                      } else {
                                        if (barWidth > 22) barWidth = 22;
                                        if (barWidth < 11) barWidth = 11;
                                      }
                                    }
                                    
                                    // Aumentar ligeiramente a largura se for o período atual
                                    if (isCurrentPeriod) {
                                      barWidth = barWidth * 1.1;
                                    }
                                    
                                    return BarChartGroupData(
                                      x: i,
                                      barRods: [
                                        // Receitas
                                        BarChartRodData(
                                          toY: receitaValue > 0 ? receitaValue : 0.1,
                                          width: barWidth,
                                          borderRadius: BorderRadius.circular(
                                            isSmallScreen ? 6 : 8
                                          ),
                                          gradient: LinearGradient(
                                            colors: isCurrentPeriod ? [
                                              const Color(0xFF4CAF50),
                                              const Color(0xFF00E676),
                                              const Color(0xFF81C784),
                                              const Color(0xFFE8F5E8),
                                            ] : [
                                              const Color(0xFF4CAF50),
                                              const Color(0xFF00E676),
                                              const Color(0xFF81C784),
                                            ],
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                            stops: isCurrentPeriod ? [0.0, 0.4, 0.7, 1.0] : [0.0, 0.5, 1.0],
                                          ),
                                          backDrawRodData: BackgroundBarChartRodData(
                                            show: true,
                                            toY: maxY,
                                            color: isCurrentPeriod 
                                              ? Colors.green.withOpacity(0.05)
                                              : Colors.white.withOpacity(0.03),
                                          ),
                                        ),
                                        // Despesas
                                        BarChartRodData(
                                          toY: despesaValue > 0 ? despesaValue : 0.1,
                                          width: barWidth,
                                          borderRadius: BorderRadius.circular(
                                            isSmallScreen ? 6 : 8
                                          ),
                                          gradient: LinearGradient(
                                            colors: isCurrentPeriod ? [
                                              const Color(0xFFE91E63),
                                              const Color(0xFFFF5252),
                                              const Color(0xFFFF8A80),
                                              const Color(0xFFFCE4EC),
                                            ] : [
                                              const Color(0xFFE91E63),
                                              const Color(0xFFFF5252),
                                              const Color(0xFFFF8A80),
                                            ],
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                            stops: isCurrentPeriod ? [0.0, 0.4, 0.7, 1.0] : [0.0, 0.5, 1.0],
                                          ),
                                          backDrawRodData: BackgroundBarChartRodData(
                                            show: true,
                                            toY: maxY,
                                            color: isCurrentPeriod 
                                              ? Colors.red.withOpacity(0.05)
                                              : Colors.white.withOpacity(0.03),
                                          ),
                                        ),
                                        // Investimentos
                                        BarChartRodData(
                                          toY: investimentoValue > 0 ? investimentoValue : 0.1,
                                          width: barWidth,
                                          borderRadius: BorderRadius.circular(
                                            isSmallScreen ? 6 : 8
                                          ),
                                          gradient: LinearGradient(
                                            colors: isCurrentPeriod ? [
                                              const Color(0xFF2196F3),
                                              const Color(0xFF00B0FF),
                                              const Color(0xFF81D4FA),
                                              const Color(0xFFE3F2FD),
                                            ] : [
                                              const Color(0xFF2196F3),
                                              const Color(0xFF00B0FF),
                                              const Color(0xFF81D4FA),
                                            ],
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                            stops: isCurrentPeriod ? [0.0, 0.4, 0.7, 1.0] : [0.0, 0.5, 1.0],
                                          ),
                                          backDrawRodData: BackgroundBarChartRodData(
                                            show: true,
                                            toY: maxY,
                                            color: isCurrentPeriod 
                                              ? Colors.blue.withOpacity(0.05)
                                              : Colors.white.withOpacity(0.03),
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
