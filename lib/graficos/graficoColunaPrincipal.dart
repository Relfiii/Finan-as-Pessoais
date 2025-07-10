
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../services/supabase_graficos.dart';

class GraficoColunaPrincipal extends StatefulWidget {
  final double saldoAtual;
  final double totalGastoMes;
  final double investimento;
  final Future<Map<String, double>> Function(String periodo)? onPeriodoChanged;

  const GraficoColunaPrincipal({
    Key? key,
    required this.saldoAtual,
    required this.totalGastoMes,
    required this.investimento,
    this.onPeriodoChanged,
  }) : super(key: key);

  @override
  State<GraficoColunaPrincipal> createState() => _GraficoColunaPrincipalState();
}

class _GraficoColunaPrincipalState extends State<GraficoColunaPrincipal> {
  // Controle dos filtros
  bool showSaldo = true;
  bool showGasto = true;
  bool showInvest = true;

  // Períodos disponíveis
  final List<String> periodos = [
    'Atual',
    'Semana',
    'Mês',
    'Ano',
  ];
  String periodoSelecionado = 'Atual';

  // Inicialização direta para evitar LateInitializationError
  late double saldoAtual = widget.saldoAtual;
  late double totalGastoMes = widget.totalGastoMes;
  late double investimento = widget.investimento;
  bool carregando = false;

  Future<void> _atualizarPeriodo(String novoPeriodo) async {
    setState(() {
      periodoSelecionado = novoPeriodo;
      carregando = true;
    });
    if (novoPeriodo == 'Atual') {
      setState(() {
        saldoAtual = widget.saldoAtual;
        totalGastoMes = widget.totalGastoMes;
        investimento = widget.investimento;
        carregando = false;
      });
      return;
    }
    // Busca dados reais do Supabase
    final gastos = await SupabaseGraficosService.getGastosPorPeriodo(novoPeriodo);
    final entradas = await SupabaseGraficosService.getEntradasPorPeriodo(novoPeriodo);
    final investimentos = await SupabaseGraficosService.getInvestimentosPorPeriodo(novoPeriodo);
    // Monta labels únicos ordenados
    final Set<String> labels = {
      ...gastos.map((e) => e['label'] as String),
      ...entradas.map((e) => e['label'] as String),
      ...investimentos.map((e) => e['label'] as String),
    };
    final sortedLabels = labels.toList()..sort();
    // Monta valores para cada label
    List<List<double>> novosValores = sortedLabels.map((label) {
      final entrada = entradas.firstWhere((e) => e['label'] == label, orElse: () => {'total': 0.0});
      final gasto = gastos.firstWhere((e) => e['label'] == label, orElse: () => {'total': 0.0});
      final invest = investimentos.firstWhere((e) => e['label'] == label, orElse: () => {'total': 0.0});
      return [
        (entrada['total'] as num?)?.toDouble() ?? 0.0,
        (gasto['total'] as num?)?.toDouble() ?? 0.0,
        (invest['total'] as num?)?.toDouble() ?? 0.0,
      ];
    }).toList();
    setState(() {
      xLabels = sortedLabels;
      valores = novosValores;
      carregando = false;
    });
  }

  // Variáveis para labels e valores dinâmicos
  List<String> xLabels = [];
  List<List<double>> valores = [];

  @override
  void initState() {
    super.initState();
    // Inicializa com o período atual
    final now = DateTime.now();
    final meses = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    String mesAtual = '${meses[now.month - 1]}\n${now.year}';
    xLabels = [mesAtual];
    valores = [
      [saldoAtual, totalGastoMes, investimento]
    ];
  }

  @override
  Widget build(BuildContext context) {

    // Calcula o novo maxY para o gráfico
    final double maxY = valores.isNotEmpty
        ? valores
            .expand((v) => v)
            .map((v) => v.abs())
            .reduce((a, b) => a > b ? a : b) *
          1.2
        : 1;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 8),
          // Filtro de período
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Período:',
                style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: periodoSelecionado,
                dropdownColor: const Color(0xFF23233B),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                iconEnabledColor: Colors.white,
                underline: Container(height: 1, color: Colors.white24),
                items: periodos
                    .map((p) => DropdownMenuItem(
                          value: p,
                          child: Text(p),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null && value != periodoSelecionado) {
                    _atualizarPeriodo(value);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: carregando
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : valores.isEmpty
                    ? const Center(
                        child: Text(
                          'Selecione pelo menos um filtro',
                          style: TextStyle(color: Colors.white54, fontSize: 15),
                        ),
                      )
                    : Stack(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: BarChart(
                              BarChartData(
                                backgroundColor: Colors.transparent,
                                barTouchData: BarTouchData(
                                  enabled: true,
                                  touchTooltipData: BarTouchTooltipData(
                                    tooltipRoundedRadius: 12,
                                    tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                      // Formata o valor com ponto a cada milhar e vírgula para decimal
                                      String valorFormatado = rod.toY
                                          .toStringAsFixed(2)
                                          .replaceAll('.', ',');
                                      double valor = rod.toY;
                                      // Adiciona separador de milhar
                                      RegExp reg = RegExp(r'\B(?=(\d{3})+(?!\d))');
                                      String inteiro = valor.floor().toString();
                                      String inteiroFormatado = inteiro.replaceAllMapped(reg, (match) => '.');
                                      String decimal = valorFormatado.substring(valorFormatado.length - 3);
                                      String valorFinal = 'R\$ $inteiroFormatado$decimal';
                                      return BarTooltipItem(
                                        valorFinal,
                                        const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 10,
                                          letterSpacing: 0.2,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 48,
                                      // Corrija aqui para nunca ser zero:
                                      interval: (maxY / 2).clamp(1, double.infinity),
                                      getTitlesWidget: (value, meta) {
                                        if (value < 0 || value > maxY) return const SizedBox.shrink();
                                        return Padding(
                                          padding: const EdgeInsets.only(right: 8),
                                          child: Text(
                                            '${value.toStringAsFixed(0).replaceAll('.', ',')}',
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.right,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        final idx = value.toInt();
                                        if (idx < 0 || idx >= xLabels.length) return const SizedBox.shrink();
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8),
                                          child: Text(
                                            xLabels[idx],
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                gridData: FlGridData(
                                  show: true,
                                  drawHorizontalLine: true,
                                  // Corrija aqui para nunca ser zero:
                                  horizontalInterval: (maxY / 2).clamp(1, double.infinity),
                                  getDrawingHorizontalLine: (value) => FlLine(
                                    color: Colors.white10,
                                    strokeWidth: 1,
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                // Grupos de barras dinâmicos conforme período
                                barGroups: List.generate(xLabels.length, (i) {
                                  final v = valores[i];
                                  // Defina a largura das barras: maior para "Atual", padrão para outros
                                  final double barWidth = (periodoSelecionado == 'Atual') ? 28 : 14;
                                  // Defina o espaçamento entre as barras: maior para "Atual"
                                  final double barsSpace = (periodoSelecionado == 'Atual') ? 18 : 4;
                                  return BarChartGroupData(
                                    x: i,
                                    barRods: [
                                      BarChartRodData(
                                        toY: v[0],
                                        width: barWidth,
                                        borderRadius: BorderRadius.circular(6),
                                        rodStackItems: const [],
                                        backDrawRodData: BackgroundBarChartRodData(show: false),
                                        gradient: const LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Color(0xFF43EA7A),
                                            Color(0xFF189F05),
                                          ],
                                        ),
                                      ),
                                      BarChartRodData(
                                        toY: v[1],
                                        width: barWidth,
                                        borderRadius: BorderRadius.circular(6),
                                        rodStackItems: const [],
                                        backDrawRodData: BackgroundBarChartRodData(show: false),
                                        gradient: const LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Color(0xFFFF8A80),
                                            Color(0xFF973535),
                                          ],
                                        ),
                                      ),
                                      BarChartRodData(
                                        toY: v[2],
                                        width: barWidth,
                                        borderRadius: BorderRadius.circular(6),
                                        rodStackItems: const [],
                                        backDrawRodData: BackgroundBarChartRodData(show: false),
                                        gradient: const LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Color(0xFF64B5F6),
                                            Color(0xFF0F9DF0),
                                          ],
                                        ),
                                      ),
                                    ],
                                    barsSpace: barsSpace,
                                  );
                                }),
                                minY: 0,
                                maxY: maxY > 0 ? maxY : 1,
                                groupsSpace: (xLabels.length == 1)
                                    ? ((MediaQuery.of(context).size.width - (3 * 14)) / 2).clamp(18, 200)
                                    : (xLabels.length > 1)
                                        ? ((MediaQuery.of(context).size.width - (xLabels.length * 3 * 14)) / (xLabels.length - 1)).clamp(4, 60)
                                        : 18,
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
}