import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

class GraficoVisaoGeral extends StatefulWidget {
  final double totalGastoMes;
  final double saldoAtual;
  final double investimento;
  const GraficoVisaoGeral({super.key, required this.totalGastoMes, required this.saldoAtual, required this.investimento});

  @override
  State<GraficoVisaoGeral> createState() => _GraficoVisaoGeralState();
}

class _GraficoVisaoGeralState extends State<GraficoVisaoGeral> {
  String filtro = 'Mês';

  List<Map<String, dynamic>> get dados {
    // Para a coluna aparecer, ela precisa ter um valor > 0
    return [
      {'mes': 'fev.', 'receita': 0.0, 'gasto': 0.0, 'invest': 0.0},
      {'mes': 'mar.', 'receita': 0.0, 'gasto': 0.0, 'invest': 0.0},
      {'mes': 'abr.', 'receita': 0.0, 'gasto': 0.0, 'invest': 0.0},
      {'mes': 'mai.', 'receita': 0.0, 'gasto': 0.0, 'invest': 0.0},
      {'mes': 'jun.', 'receita': 0.0, 'gasto': 0.0, 'invest': 0.0},
      {
        'mes': 'jul.',
        'receita': widget.saldoAtual > 0 ? widget.saldoAtual : 0.00,
        'gasto': widget.totalGastoMes > 0 ? widget.totalGastoMes : 0.00,
        'invest': widget.investimento > 0 ? widget.investimento : 0.00,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          // Fundo gradiente com desfoque igual ao CardInvestimento
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
                  children: [
                    const Icon(Icons.show_chart, color: Color(0xFFB983FF)),
                    const SizedBox(width: 8),
                    const Text(
                      'Visão Geral Financeira',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildFiltroButton('Dia'),
                    const SizedBox(width: 6),
                    _buildFiltroButton('Semana'),
                    const SizedBox(width: 6),
                    _buildFiltroButton('Mês'),
                    const SizedBox(width: 6),
                    _buildFiltroButton('Ano'),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Últimos 6 meses',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 220,
                  child: BarChart(_mainBarData()),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegenda(Colors.green, 'Receita'),
                    const SizedBox(width: 12),
                    _buildLegenda(Colors.red, 'Gastos'),
                    const SizedBox(width: 12),
                    _buildLegenda(Colors.blue, 'Investimentos'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltroButton(String label) {
    final bool ativo = filtro == label;
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: ativo ? const Color(0xFFB983FF) : Colors.black,
        foregroundColor: ativo ? Colors.black : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2), // menor
        minimumSize: const Size(0, 28),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () => setState(() => filtro = label),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: ativo ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildLegenda(Color cor, String texto) {
    return Row(
      children: [
        Container(width: 14, height: 14, decoration: BoxDecoration(color: cor, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(texto, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }

  BarChartData _mainBarData() {
    // Descobre o maior valor para ajustar o maxY
    double maxValue = 0;
    for (final d in dados) {
      maxValue = [maxValue, d['receita'] as double, d['gasto'] as double, d['invest'] as double].reduce((a, b) => a > b ? a : b);
    }
    double maxY = maxValue > 0 ? maxValue * 1.2 : 1;
    return BarChartData(
      backgroundColor: Colors.transparent,
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          tooltipRoundedRadius: 10,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final tipo = rodIndex == 0
                ? 'Saldo'
                : rodIndex == 1
                    ? 'Gasto'
                    : 'Investimento';
            final cor = rodIndex == 0
                ? Colors.green
                : rodIndex == 1
                    ? Colors.red
                    : Colors.blue;
            final valor = rod.toY;
            if (valor <= 0.01) return null;
            return BarTooltipItem(
              '$tipo\n',
              TextStyle(color: cor, fontWeight: FontWeight.bold, fontSize: 14),
              children: [
                TextSpan(
                  text: 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ],
            );
          },
        ),
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
            final idx = value.toInt();
            if (idx < 0 || idx >= dados.length) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(dados[idx]['mes'], style: const TextStyle(color: Colors.white70, fontSize: 13)),
            );
          }),
        ),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: FlGridData(show: false),
      borderData: FlBorderData(show: false),
      barGroups: List.generate(dados.length, (i) {
        final receita = dados[i]['receita'] as double;
        final gasto = dados[i]['gasto'] as double;
        final invest = dados[i]['invest'] as double;
        return BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: receita,
              color: Colors.green,
              width: 18,
              borderRadius: BorderRadius.circular(4),
              rodStackItems: [],
              borderSide: receita > 0.01 ? const BorderSide(color: Colors.white24, width: 1) : BorderSide.none,
              backDrawRodData: BackgroundBarChartRodData(show: false),
            ),
            BarChartRodData(
              toY: gasto,
              color: Colors.red,
              width: 8,
              borderRadius: BorderRadius.circular(4),
              rodStackItems: [],
              borderSide: gasto > 0.01 ? const BorderSide(color: Colors.white24, width: 1) : BorderSide.none,
              backDrawRodData: BackgroundBarChartRodData(show: false),
            ),
            BarChartRodData(
              toY: invest,
              color: Colors.blue,
              width: 8,
              borderRadius: BorderRadius.circular(4),
              rodStackItems: [],
              borderSide: invest > 0.01 ? const BorderSide(color: Colors.white24, width: 1) : BorderSide.none,
              backDrawRodData: BackgroundBarChartRodData(show: false),
            ),
          ],
        );
      }),
      minY: 0,
      maxY: maxY,
      groupsSpace: 24,
    );
  }
}
