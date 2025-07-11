import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class GraficoColunaPrincipal extends StatefulWidget {
  final double saldoAtual;
  final double totalGastoMes;
  final double investimento;

  const GraficoColunaPrincipal({
    Key? key,
    required this.saldoAtual,
    required this.totalGastoMes,
    required this.investimento,
  }) : super(key: key);

  @override
  State<GraficoColunaPrincipal> createState() => _GraficoColunaPrincipalState();
}

class _GraficoColunaPrincipalState extends State<GraficoColunaPrincipal> {
  String normalizarLabel(String label) {
    // Converte '2025-07' ou '07/2025' para '2025/07'
    if (RegExp(r'^\d{4}-\d{2}$').hasMatch(label)) {
      // '2025-07' => '2025/07'
      return label.replaceAll('-', '/');
    }
    if (RegExp(r'^\d{2}/\d{4}$').hasMatch(label)) {
      // '07/2025' => '2025/07'
      var partes = label.split('/');
      return '${partes[1]}/${partes[0]}';
    }
    return label;
  }
  List<String> meses = [];
  List<double?> receitas = [];
  List<double?> despesas = [];
  List<double?> investimentos = [];
  bool loading = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final client = Supabase.instance.client;
    final now = DateTime.now();

    // Gera os labels dos últimos 12 meses (ex: ['2024/jul', ...])
    List<DateTime> ultimosMeses = List.generate(12, (i) {
      int year = now.year;
      int month = now.month - (11 - i);
      while (month <= 0) {
        month += 12;
        year -= 1;
      }
      return DateTime(year, month, 1);
    });
    List<String> mesesLabels = ultimosMeses
        .map((dt) {
          String mes = DateFormat('MMM', 'pt_BR').format(dt).toLowerCase();
          return '${dt.year}/$mes';
        })
        .toList();

    // Busca receitas
    final entradasResp = await client.rpc('entradas_por_periodo', params: {'periodo': 'Mês'});
    // Busca despesas
    final gastosResp = await client.rpc('total_gastos_por_periodo', params: {'periodo': 'Mês'});
    // Busca investimentos
    final investimentosRes = await client
        .from('investimentos')
        .select('valor, data')
        .eq('user_id', client.auth.currentUser!.id);

    // Mapear receitas e despesas por label
    Map<String, double> receitasMap = {};
    for (var item in (entradasResp ?? [])) {
      final label = normalizarLabel(item['label']);
      DateTime? dt;
      try {
        if (label.contains('/')) {
          var partes = label.split('/');
          dt = DateTime(int.parse(partes[0]), int.parse(partes[1]));
        } else if (label.contains('-')) {
          var partes = label.split('-');
          dt = DateTime(int.parse(partes[0]), int.parse(partes[1]));
        }
      } catch (_) {}
      String labelFormatado = dt != null
          ? '${dt.year}/${DateFormat('MMM', 'pt_BR').format(dt).toLowerCase()}'
          : label;
      receitasMap[labelFormatado] = (item['total'] as num?)?.toDouble() ?? 0.0;
    }
    Map<String, double> despesasMap = {};
    for (var item in (gastosResp ?? [])) {
      final label = normalizarLabel(item['label']);
      DateTime? dt;
      try {
        if (label.contains('/')) {
          var partes = label.split('/');
          dt = DateTime(int.parse(partes[0]), int.parse(partes[1]));
        } else if (label.contains('-')) {
          var partes = label.split('-');
          dt = DateTime(int.parse(partes[0]), int.parse(partes[1]));
        }
      } catch (_) {}
      String labelFormatado = dt != null
          ? '${dt.year}/${DateFormat('MMM', 'pt_BR').format(dt).toLowerCase()}'
          : label;
      despesasMap[labelFormatado] = (item['total'] as num?)?.toDouble() ?? 0.0;
    }

    // Mapear investimentos por mês
    Map<String, double> investimentosMap = {};
    for (var item in (investimentosRes as List? ?? [])) {
      final data = DateTime.parse(item['data']);
      final label = '${data.year}/${DateFormat('MMM', 'pt_BR').format(DateTime(data.year, data.month)).toLowerCase()}';
      investimentosMap[label] = (investimentosMap[label] ?? 0.0) + ((item['valor'] as num?)?.toDouble() ?? 0.0);
    }

    // Preencher arrays alinhados aos meses
    List<double?> receitas = [];
    List<double?> despesas = [];
    List<double?> investimentos = [];
    for (var label in mesesLabels) {
      receitas.add(receitasMap[label] ?? 0.0);
      despesas.add(despesasMap[label] ?? 0.0);
      investimentos.add(investimentosMap[label] ?? 0.0);
    }
    // Debug: mostrar mapas e arrays
    print('receitasMap: ' + receitasMap.toString());
    print('despesasMap: ' + despesasMap.toString());
    print('investimentosMap: ' + investimentosMap.toString());
    print('mesesLabels: ' + mesesLabels.toString());
    print('receitas: ' + receitas.toString());
    print('despesas: ' + despesas.toString());
    print('investimentos: ' + investimentos.toString());

    setState(() {
      meses = mesesLabels;
      this.receitas = receitas;
      this.despesas = despesas;
      this.investimentos = investimentos;
      loading = false;
    });

    // Aguarda o frame para garantir que o gráfico foi renderizado antes de rolar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        // Calcula a largura de cada mês (56) e rola para mostrar os 6 últimos meses
        double offset = (meses.length - 6) * 56.0;
        if (offset > 0) {
          _scrollController.jumpTo(offset);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    double maxY = [
      ...receitas,
      ...despesas,
      ...investimentos,
    ].map((e) => e ?? 0.0).fold<double>(0, (max, v) => v > max ? v : max);
    if (maxY == 0) maxY = 1000; // valor mínimo para evitar gráfico vazio
    maxY *= 1.1; // margem superior

    double intervaloY;
    if (maxY <= 20000) {
      intervaloY = 5000;
      maxY = ((maxY / intervaloY).ceil() * intervaloY).toDouble();
    } else {
      intervaloY = 15000;
      maxY = ((maxY / intervaloY).ceil() * intervaloY).toDouble();
    }

    // Eixo Y fixo + gráfico rolável
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
                width: meses.length * 56,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceBetween,
                    maxY: maxY,
                    minY: 0,
                    groupsSpace: 28,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        // tooltipBgColor: Colors.black87,
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
                        sideTitles: SideTitles(showTitles: false), // Oculta o eixo Y do gráfico
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx >= 0 && idx < meses.length) {
                              final partes = meses[idx].split('/');
                              final ano = partes[0];
                              var mes = partes[1];
                              mes = mes.replaceAll('.', '');
                              return Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Text(
                                  '$mes.\n$ano',
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
                    barGroups: List.generate(meses.length, (i) {
                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: receitas[i] ?? 0.0,
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
                            // Removido o backDrawRodData para não exibir barra de fundo
                          ),
                          BarChartRodData(
                            toY: despesas[i] ?? 0.0,
                            width: 12,
                            color: const Color(0xFFFF5252), // Vermelho mais vivo
                            borderRadius: BorderRadius.circular(10),
                            rodStackItems: [],
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF5252), Color(0xFFB71C1C)],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            borderSide: const BorderSide(color: Colors.white24, width: 1),
                            // Removido o backDrawRodData para não exibir barra de fundo
                          ),
                          BarChartRodData(
                            toY: investimentos[i] ?? 0.0,
                            width: 12,
                            color: const Color(0xFF00B0FF), // Azul claro
                            borderRadius: BorderRadius.circular(10),
                            rodStackItems: [],
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00B0FF), Color(0xFF40C4FF)],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            borderSide: const BorderSide(color: Colors.white24, width: 1),
                            // Removido o backDrawRodData para não exibir barra de fundo
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