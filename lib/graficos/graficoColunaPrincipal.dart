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

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final client = Supabase.instance.client;
    final now = DateTime.now();

    // Gera os labels dos últimos 6 meses (ex: ['2025/07', '2025/06', ...])
    List<DateTime> ultimosMeses = List.generate(6, (i) => DateTime(now.year, now.month - (5 - i), 1));
    List<String> mesesLabels = ultimosMeses
        .map((dt) => DateFormat('yyyy/MM').format(dt))
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
      receitasMap[label] = (item['total'] as num?)?.toDouble() ?? 0.0;
    }
    Map<String, double> despesasMap = {};
    for (var item in (gastosResp ?? [])) {
      final label = normalizarLabel(item['label']);
      despesasMap[label] = (item['total'] as num?)?.toDouble() ?? 0.0;
    }

    // Mapear investimentos por mês
    Map<String, double> investimentosMap = {};
    for (var item in (investimentosRes as List? ?? [])) {
      final data = DateTime.parse(item['data']);
      final label = DateFormat('yyyy/MM').format(DateTime(data.year, data.month));
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

    return SizedBox(
      height: 280,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          minY: 0,
          groupsSpace: 18,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: 5500,
                getTitlesWidget: (value, meta) {
                  return Text(
                    NumberFormat.compact(locale: 'pt_BR').format(value),
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx >= 0 && idx < meses.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        meses[idx],
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
                reservedSize: 38,
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
              color: Colors.white24,
              strokeWidth: 1,
              dashArray: [6, 6],
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(meses.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: receitas[i] ?? 0.0,
                  width: 8,
                  color: const Color(0xFF1DE9B6), // Verde claro
                  borderRadius: BorderRadius.circular(4),
                ),
                BarChartRodData(
                  toY: despesas[i] ?? 0.0,
                  width: 8,
                  color: const Color(0xFFB71C1C), // Vermelho escuro
                  borderRadius: BorderRadius.circular(4),
                ),
                BarChartRodData(
                  toY: investimentos[i] ?? 0.0,
                  width: 8,
                  color: const Color(0xFF00B0FF), // Azul claro
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
              barsSpace: 2,
            );
          }),
        ),
      ),
    );
  }
}
