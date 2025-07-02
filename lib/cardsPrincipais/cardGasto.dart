import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provedor/categoriaProvedor.dart';
import '../provedor/gastoProvedor.dart';
import '../telas/criarCategoria.dart';
import '../telas/detalhesCategoria.dart';

class CardGasto extends StatelessWidget {
  // Novo método para editar categoria
  Future<void> _editarCategoriaPopup(BuildContext context, CategoryProvider categoryProvider, dynamic categoria) async {
    final TextEditingController controller = TextEditingController(text: categoria.name);
    await showDialog<String>(
      context: context,
      builder: (context) {
        return EditCategoryDialog(
          initialName: categoria.name,
          onConfirm: (novoNome) async {
            if (novoNome.trim().isNotEmpty && novoNome != categoria.name) {
              await categoryProvider.updateCategoryName(categoria.id, novoNome.trim());
            }
            Navigator.of(context).pop();
          },
        );
      },
    );
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gasto do Mês'),
        backgroundColor: const Color(0xFF181818),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      backgroundColor: const Color(0xFF181818),
      body: Consumer2<CategoryProvider, GastoProvider>(
        builder: (context, categoryProvider, gastoProvider, child) {
          final categories = categoryProvider.categories;
          if (categories.isEmpty) {
            return Center(
              child: Text(
                'Nenhuma categoria cadastrada.',
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            itemCount: categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.7,
            ),
            itemBuilder: (context, index) {
              final cat = categories[index];
              final valor = gastoProvider.totalPorCategoria(cat.id);
              return _CategoryCard(
                categoryName: cat.name,
                valor: valor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetalhesCategoriaScreen(
                        categoryId: cat.id,
                        categoryName: cat.name,
                      ),
                    ),
                  );
                },
                onEdit: () async {
                  await _editarCategoriaPopup(context, categoryProvider, cat);
                },
                onDelete: () async {
                  await categoryProvider.deleteCategory(cat.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Categoria "${cat.name}" deletada!')),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String categoryName;
  final double valor;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryCard({
    required this.categoryName,
    required this.valor,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF232323),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          categoryName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.white54, size: 20),
                        color: const Color(0xFF23272F),
                        padding: EdgeInsets.zero,
                        onSelected: (value) {
                          if (value == 'editar') {
                            onEdit();
                          } else if (value == 'deletar') {
                            onDelete();
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
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const SizedBox(width: 6),
                      Text(
                        'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}',
                        style: const TextStyle(
                          color: Color.fromARGB(255, 214, 158, 158),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}