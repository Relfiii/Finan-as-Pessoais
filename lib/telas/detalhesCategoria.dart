import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provedor/gastoProvedor.dart';
import '../provedor/categoriaProvedor.dart';
import '../telas/criarCategoria.dart';
import '../telas/criarGasto.dart';
import '../widgets/topBarComCaixaTexto.dart';
import 'dart:ui';

class DetalhesCategoriaScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const DetalhesCategoriaScreen({
    Key? key,
    required this.categoryId,
    required this.categoryName,
  }) : super(key: key);

  @override
  State<DetalhesCategoriaScreen> createState() => _DetalhesCategoriaScreenState();
}

class _DetalhesCategoriaScreenState extends State<DetalhesCategoriaScreen> {
  String _sortBy = 'data';
  bool _ascending = false;

  double _calcularTotal(List<dynamic> gastos) {
    return gastos.fold(0.0, (total, gasto) => total + gasto.valor);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181818),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // TopBar com caixa de texto
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 16, top: 16, bottom: 8),
                  child: TopBarComCaixaTexto(
                    titulo: widget.categoryName,
                    mostrarMenuLateral: false,
                    mostrarNotificacao: false,
                  ),
                ),
                // Header com total e actions
                Consumer2<GastoProvider, CategoryProvider>(
                  builder: (context, gastoProvider, categoryProvider, child) {
                    final gastos = gastoProvider.gastosPorCategoria(widget.categoryId);
                    final total = _calcularTotal(gastos);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total: R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, color: Colors.white),
                            color: const Color(0xFF23272F),
                            onSelected: (value) async {
                              if (value == 'editar') {
                                // TODO: Implementar edição de categoria
                              } else if (value == 'deletar') {
                                await categoryProvider.deleteCategory(widget.categoryId);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Categoria "${widget.categoryName}" deletada!')),
                                  );
                                  Navigator.pop(context);
                                }
                              }
                            },
                            itemBuilder: (BuildContext context) => [
                              const PopupMenuItem<String>(
                                value: 'editar',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, color: Colors.white, size: 20),
                                    SizedBox(width: 8),
                                    Text('Editar categoria', style: TextStyle(color: Colors.white)),
                                  ],
                                ),
                              ),
                              const PopupMenuItem<String>(
                                value: 'deletar',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red, size: 20),
                                    SizedBox(width: 8),
                                    Text('Deletar categoria', style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                // Conteúdo principal
                Expanded(
                  child: Consumer<GastoProvider>(
                    builder: (context, gastoProvider, child) {
                      final gastos = gastoProvider.gastosPorCategoria(widget.categoryId);
                      
                      if (gastos.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                size: 64,
                                color: Colors.white24,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Nenhum gasto encontrado',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Adicione gastos para esta categoria',
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: gastos.length,
                        itemBuilder: (context, index) {
                          final gasto = gastos[index];
                          return Card(
                            color: const Color(0xFF23272F),
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              title: Text(
                                gasto.descricao.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                '${gasto.data.day.toString().padLeft(2, '0')}/${gasto.data.month.toString().padLeft(2, '0')}/${gasto.data.year}',
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'R\$ ${gasto.valor.toStringAsFixed(2).replaceAll('.', ',')}',
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert, color: Colors.white54),
                                    color: const Color(0xFF23272F),
                                    onSelected: (value) async {
                                      if (value == 'deletar') {
                                        // TODO: Implementar confirmação e deleção
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem<String>(
                                        value: 'deletar',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete, color: Colors.red, size: 18),
                                            SizedBox(width: 8),
                                            Text('Deletar', style: TextStyle(color: Colors.red)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
            // Overlay da caixa de texto
            CaixaTextoOverlay(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const AddExpenseDialog(),
          );
        },
        backgroundColor: const Color(0xFFB983FF),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}
