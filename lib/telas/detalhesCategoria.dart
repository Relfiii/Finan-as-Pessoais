import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provedor/gastoProvedor.dart';
import '../provedor/categoriaProvedor.dart';
import '../telas/criarCategoria.dart';
import '../telas/criarGasto.dart';
import 'dart:ui';
import '../caixaTexto/caixaTexto.dart';

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

  // Método para confirmar deleção do gasto
  Future<void> _confirmarDeletarGasto(BuildContext context, dynamic gasto, GastoProvider gastoProvider) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Center(
            child: AlertDialog(
              backgroundColor: const Color(0xFF181818),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Confirmar exclusão',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.of(context).pop(),
                    splashRadius: 20,
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tem certeza que deseja deletar este gasto?',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF23272F),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          gasto.descricao.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'R\$ ${gasto.valor.toStringAsFixed(2).replaceAll('.', ',')}',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${gasto.data.day.toString().padLeft(2, '0')}/${gasto.data.month.toString().padLeft(2, '0')}/${gasto.data.year}',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white54),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () async {
                          try {
                            // Deleta o gasto da base de dados e da lista
                            await gastoProvider.deleteGasto(gasto.id);
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Gasto deletado com sucesso!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Erro ao deletar gasto: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: const Text(
                          'Deletar',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
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
  }

  // Método para editar gasto
  Future<void> _editarGasto(BuildContext context, dynamic gasto) async {
    // Por enquanto, vamos abrir o dialog de adicionar gasto
    await showDialog(
      context: context,
      builder: (context) => const AddExpenseDialog(),
    );
    setState(() {}); // Atualiza a lista após edição
  }

  // Método para editar categoria
  Future<void> _editarCategoriaPopup(BuildContext context, CategoryProvider categoryProvider) async {
    await showDialog<String>(
      context: context,
      builder: (context) {
        return EditCategoryDialog(
          initialName: widget.categoryName,
          onConfirm: (novoNome) async {
            if (novoNome.trim().isNotEmpty && novoNome != widget.categoryName) {
              await categoryProvider.updateCategoryName(widget.categoryId, novoNome.trim());
              setState(() {}); // Atualiza a tela
            }
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  double _calcularTotal(List<dynamic> gastos) {
    return gastos.fold(0.0, (sum, gasto) => sum + gasto.valor);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181818),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181818),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Text(
              widget.categoryName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          Consumer2<GastoProvider, CategoryProvider>(
            builder: (context, gastoProvider, categoryProvider, child) {
              final gastos = gastoProvider.gastosPorCategoria(widget.categoryId);
              final total = _calcularTotal(gastos);
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Row(
                  children: [
                    Text(
                      'R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}',
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
                          await _editarCategoriaPopup(context, categoryProvider);
                        } else if (value == 'deletar') {
                          await categoryProvider.deleteCategory(widget.categoryId);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Categoria "${widget.categoryName}" deletada!')),
                          );
                          Navigator.pop(context); // Volta para a tela anterior
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'editar',
                          child: Text('Editar', style: TextStyle(color: Colors.white)),
                        ),
                        const PopupMenuItem(
                          value: 'deletar',
                          child: Text('Deletar', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        elevation: 0,
      ),
      body: Consumer<GastoProvider>(
        builder: (context, gastoProvider, child) {
          final gastos = gastoProvider.gastosPorCategoria(widget.categoryId);
          
          return Column(
            children: [
              // Linha de botões: adicionar gasto e caixa de texto
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Botão de adicionar gasto
                    SizedBox(
                      height: 44,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF23272F),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          minimumSize: const Size(0, 44),
                        ),
                        icon: const Icon(Icons.add, color: Color(0xFFB983FF)),
                        label: const Text('Gasto'),
                        onPressed: () async {
                          await showDialog(
                            context: context,
                            builder: (context) => const AddExpenseDialog(),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    // CaixaTextoWidget como botão
                    Expanded(
                      child: CaixaTextoWidget(
                        asButton: true,
                        onExpand: () {
                          showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (context) {
                              return BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                child: Center(
                                  child: FractionallySizedBox(
                                    widthFactor: 0.95,
                                    child: Material(
                                      color: Colors.transparent,
                                      child: CaixaTextoWidget(
                                        asButton: false,
                                        autofocus: true,
                                        onCollapse: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ),
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
              ),
              // Header com mês/ano
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Julho 2025',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left, color: Colors.white70),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right, color: Colors.white70),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Cabeçalho da tabela
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.white24, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            if (_sortBy == 'descricao') {
                              _ascending = !_ascending;
                            } else {
                              _sortBy = 'descricao';
                              _ascending = true;
                            }
                          });
                        },
                        child: Row(
                          children: [
                            Text(
                              'Descrição',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (_sortBy == 'descricao')
                              Icon(
                                _ascending ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                color: Colors.white70,
                                size: 18,
                              ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            if (_sortBy == 'data') {
                              _ascending = !_ascending;
                            } else {
                              _sortBy = 'data';
                              _ascending = false;
                            }
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Data',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (_sortBy == 'data')
                              Icon(
                                _ascending ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                color: Colors.white70,
                                size: 18,
                              ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            if (_sortBy == 'valor') {
                              _ascending = !_ascending;
                            } else {
                              _sortBy = 'valor';
                              _ascending = false;
                            }
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Valor',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (_sortBy == 'valor')
                              Icon(
                                _ascending ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                color: Colors.white70,
                                size: 18,
                              ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 40), // Espaço para coluna "Ações"
                    Text(
                      'Ações',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Lista de gastos
              Expanded(
                child: gastos.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhum gasto encontrado nesta categoria.',
                          style: TextStyle(color: Colors.white54, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: gastos.length,
                        itemBuilder: (context, index) {
                          final gasto = gastos[index];
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.white12, width: 0.5),
                              ),
                            ),
                            child: Row(
                              children: [
                                // Descrição
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    gasto.descricao.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                // Data
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '${gasto.data.day.toString().padLeft(2, '0')}/${gasto.data.month.toString().padLeft(2, '0')}/${gasto.data.year}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                // Valor
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'R\$ ${gasto.valor.toStringAsFixed(2).replaceAll('.', ',')}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                                // Ações
                                SizedBox(
                                  width: 40,
                                  child: Consumer<GastoProvider>(
                                    builder: (context, gastoProvider, child) {
                                      return PopupMenuButton<String>(
                                        icon: const Icon(Icons.more_vert, color: Colors.white70, size: 20),
                                        color: const Color(0xFF23272F),
                                        onSelected: (value) async {
                                          if (value == 'editar') {
                                            await _editarGasto(context, gasto);
                                          } else if (value == 'deletar') {
                                            await _confirmarDeletarGasto(context, gasto, gastoProvider);
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(
                                            value: 'editar',
                                            child: Text('Editar', style: TextStyle(color: Colors.white)),
                                          ),
                                          const PopupMenuItem(
                                            value: 'deletar',
                                            child: Text('Deletar', style: TextStyle(color: Colors.red)),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
