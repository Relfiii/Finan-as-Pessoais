import 'package:flutter/material.dart';
import 'dart:ui';

class OrcamentoPage extends StatelessWidget {
  const OrcamentoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final orcamentos = [
      {
        'categoria': 'Alimentação',
        'limite': 800.0,
        'gasto': 450.0,
        'icone': Icons.fastfood_outlined,
      },
      {
        'categoria': 'Transporte',
        'limite': 300.0,
        'gasto': 120.0,
        'icone': Icons.directions_car_outlined,
      },
      {
        'categoria': 'Lazer',
        'limite': 400.0,
        'gasto': 250.0,
        'icone': Icons.movie_outlined,
      },
    ];

    return Scaffold(
      body: Stack(
        children: [
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
          SafeArea(
            child: Column(
              children: [
                // AppBar customizada
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Color(0xFFB983FF)),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Orçamentos',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white24, thickness: 1, indent: 24, endIndent: 24),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: orcamentos.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return const _SectionTitle('Meus Orçamentos');
                      }
                      final orcamento = orcamentos[index - 1];
                      return _OrcamentoTile(
                        icone: orcamento['icone'] as IconData,
                        categoria: orcamento['categoria'] as String,
                        limite: orcamento['limite'] as double,
                        gasto: orcamento['gasto'] as double,
                        onTap: () {
                          // Ação ao tocar no orçamento (editar, detalhes, etc)
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB983FF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Adicionar Orçamento'),
                    onPressed: () {
                      // Ação para adicionar novo orçamento
                    },
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

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8, left: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFB983FF),
          fontSize: 15,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

class _OrcamentoTile extends StatelessWidget {
  final IconData icone;
  final String categoria;
  final double limite;
  final double gasto;
  final VoidCallback onTap;

  const _OrcamentoTile({
    required this.icone,
    required this.categoria,
    required this.limite,
    required this.gasto,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final restante = limite - gasto;
    final percent = (gasto / limite).clamp(0.0, 1.0);

    return Card(
      color: Colors.white.withOpacity(0.03),
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      child: ListTile(
        leading: Icon(icone, color: const Color(0xFFB983FF)),
        title: Text(
          categoria,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Limite: R\$ ${limite.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: percent,
              backgroundColor: Colors.white12,
              color: percent < 0.8 ? const Color(0xFFB983FF) : Colors.redAccent,
              minHeight: 6,
            ),
            const SizedBox(height: 2),
            Text(
              'Gasto: R\$ ${gasto.toStringAsFixed(2)} • Restante: R\$ ${restante.toStringAsFixed(2)}',
              style: TextStyle(
                color: percent < 0.8 ? Colors.white54 : Colors.redAccent,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white38),
        onTap: onTap,
      ),
    );
  }
}
