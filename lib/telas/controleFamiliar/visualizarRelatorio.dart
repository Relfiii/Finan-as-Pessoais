import 'package:flutter/material.dart';

class VisualizarRelatorioPage extends StatelessWidget {
  const VisualizarRelatorioPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E2C),
        title: const Text(
          'Relatórios',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFB983FF)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E1E2C), Color(0xFF121212)],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom,
                ),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      color: Colors.white.withOpacity(0.03),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.bar_chart, color: Color(0xFFB983FF)),
                        title: const Text(
                          'Gastos Mensais',
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: const Text(
                          'Resumo dos gastos por mês',
                          style: TextStyle(color: Colors.white70),
                        ),
                        onTap: () {
                          // Lógica para exibir detalhes dos gastos mensais
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      color: Colors.white.withOpacity(0.03),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.pie_chart, color: Color(0xFFB983FF)),
                        title: const Text(
                          'Distribuição por Categoria',
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: const Text(
                          'Veja como os gastos estão distribuídos',
                          style: TextStyle(color: Colors.white70),
                        ),
                        onTap: () {
                          // Lógica para exibir gráfico de categorias
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      color: Colors.white.withOpacity(0.03),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.trending_up, color: Color(0xFFB983FF)),
                        title: const Text(
                          'Tendências',
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: const Text(
                          'Acompanhe as tendências de gastos',
                          style: TextStyle(color: Colors.white70),
                        ),
                        onTap: () {
                          // Lógica para exibir tendências
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
