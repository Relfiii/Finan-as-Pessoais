import 'package:flutter/material.dart';
import 'dart:ui';

class ContasBancariasPage extends StatelessWidget {
  const ContasBancariasPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final contas = [
      {
        'banco': 'Banco do Brasil',
        'tipo': 'Conta Corrente',
        'numero': '12345-6',
        'icone': Icons.account_balance,
        'saldo': 2500.75,
      },
      {
        'banco': 'Nubank',
        'tipo': 'Conta Digital',
        'numero': '98765-4',
        'icone': Icons.account_balance_wallet,
        'saldo': 1200.00,
      },
      {
        'banco': 'Caixa',
        'tipo': 'Poupança',
        'numero': '54321-0',
        'icone': Icons.savings,
        'saldo': 800.50,
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
                        'Contas Bancárias',
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
                    itemCount: contas.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return const _SectionTitle('Minhas Contas');
                      }
                      final conta = contas[index - 1];
                      return _ContaTile(
                        icone: conta['icone'] as IconData,
                        banco: conta['banco'] as String,
                        tipo: conta['tipo'] as String,
                        numero: conta['numero'] as String,
                        saldo: conta['saldo'] as double,
                        onTap: () {
                          // Ação ao tocar na conta (editar, detalhes, etc)
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
                    label: const Text('Adicionar Conta'),
                    onPressed: () {
                      // Ação para adicionar nova conta
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

class _ContaTile extends StatelessWidget {
  final IconData icone;
  final String banco;
  final String tipo;
  final String numero;
  final double saldo;
  final VoidCallback onTap;

  const _ContaTile({
    required this.icone,
    required this.banco,
    required this.tipo,
    required this.numero,
    required this.saldo,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.03),
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      child: ListTile(
        leading: Icon(icone, color: const Color(0xFFB983FF)),
        title: Text(
          banco,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          '$tipo • $numero',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Saldo',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 11,
              ),
            ),
            Text(
              'R\$ ${saldo.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
