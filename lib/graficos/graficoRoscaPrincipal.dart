import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

class GraficoRoscaPrincipal extends StatefulWidget {
  final double totalGastoMes;
  final double saldoAtual;
  final double investimento;
  const GraficoRoscaPrincipal({
    super.key,
    required this.totalGastoMes,
    required this.saldoAtual,
    required this.investimento,
  });

  @override
  _GraficoRoscaPrincipalState createState() => _GraficoRoscaPrincipalState();
}

class _GraficoRoscaPrincipalState extends State<GraficoRoscaPrincipal> with SingleTickerProviderStateMixin {
  String filtroSelecionado = 'Mês';
  late AnimationController _controller;
  Animation<double>? _animation;

  final Map<String, IconData> filtroIcones = {
    'Dia': Icons.calendar_view_day,
    'Mês': Icons.calendar_today,
    'Ano': Icons.calendar_month,
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<_BarInfo> getBarrasFiltradas() {
    switch (filtroSelecionado) {
      case 'Dia':
        return [
          _BarInfo('Saldo', widget.saldoAtual / 30, Colors.green),
          _BarInfo('Gastos', widget.totalGastoMes / 30, Colors.red),
          _BarInfo('Invest.', widget.investimento / 30, Colors.blue),
        ];
      case 'Ano':
        return [
          _BarInfo('Saldo', widget.saldoAtual * 12, Colors.green),
          _BarInfo('Gastos', widget.totalGastoMes * 12, Colors.red),
          _BarInfo('Invest.', widget.investimento * 12, Colors.blue),
        ];
      default:
        return [
          _BarInfo('Saldo', widget.saldoAtual, Colors.green),
          _BarInfo('Gastos', widget.totalGastoMes, Colors.red),
          _BarInfo('Invest.', widget.investimento, Colors.blue),
        ];
    }
  }

  Widget _buildFiltroButton(String label, IconData icon) {
    final bool selecionado = filtroSelecionado == label;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        gradient: selecionado
            ? const LinearGradient(
                colors: [Color(0xFFB983FF), Color(0xFF6E8BFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: selecionado ? null : Colors.grey[850],
        borderRadius: BorderRadius.circular(30),
        boxShadow: selecionado
            ? [
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
        border: Border.all(
          color: selecionado ? Colors.blueAccent : Colors.grey[700]!,
          width: selecionado ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () {
            setState(() {
              filtroSelecionado = label;
              _controller.forward(from: 0);
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Row(
              children: [
                Icon(icon, color: selecionado ? Colors.white : Colors.blue[200], size: 20),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: selecionado ? Colors.white : Colors.blue[200],
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<_BarInfo> barras = getBarrasFiltradas();
    final double total = barras.fold(0, (sum, b) => sum + b.valor.abs());

    return FadeTransition(
      opacity: _animation ?? const AlwaysStoppedAnimation(1.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF23233B), Color(0xFF181824)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFB983FF), Color(0xFF6E8BFF)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(Icons.pie_chart, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Resumo Financeiro',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Filtros estilizados
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: filtroIcones.entries
                    .map((e) => _buildFiltroButton(e.key, e.value))
                    .toList(),
              ),
            ),
            const SizedBox(height: 18),
            // Pie Chart estilizado
            SizedBox(
              height: 170,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 48,
                      startDegreeOffset: 270,
                      borderData: FlBorderData(show: false),
                      sections: barras.map((b) {
                        final percent = total > 0 ? (b.valor.abs() / total) * 100 : 0;
                        return PieChartSectionData(
                          color: b.color,
                          value: b.valor.abs(),
                          title: percent >= 10 ? '${percent.toStringAsFixed(0)}%' : '',
                          radius: 54,
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            shadows: [
                              Shadow(
                                color: Colors.black45,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          badgeWidget: percent >= 10
                              ? null
                              : Container(
                                  width: 0,
                                  height: 0,
                                ),
                        );
                      }).toList(),
                    ),
                  ),
                  // Valor total no centro
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        'R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Legenda estilizada
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: barras
                  .map((b) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: b.color,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: b.color.withOpacity(0.3),
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              b.label,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
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
