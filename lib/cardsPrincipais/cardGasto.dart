import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provedor/categoriaProvedor.dart';
import '../provedor/gastoProvedor.dart';

class CardGasto extends StatelessWidget {
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
          // Trocar ListView.separated por GridView.builder para duas colunas
          return GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            itemCount: categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.7, // Aumente o valor para cards mais baixos
            ),
            itemBuilder: (context, index) {
              final cat = categories[index];
              final valor = gastoProvider.totalPorCategoria(cat.id);
              return _ExpandableCategoryCard(
                categoryName: cat.name,
                valor: valor,
                onEdit: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Editar "${cat.name}"')),
                  );
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

class _ExpandableCategoryCard extends StatefulWidget {
  final String categoryName;
  final double valor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ExpandableCategoryCard({
    required this.categoryName,
    required this.valor,
    required this.onEdit,
    required this.onDelete,
    Key? key,
  }) : super(key: key);

  @override
  State<_ExpandableCategoryCard> createState() => _ExpandableCategoryCardState();
}

class _ExpandableCategoryCardState extends State<_ExpandableCategoryCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: const Color(0xFF232323),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          if (_expanded)
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(8), // Reduzido de 14 para 8
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.categoryName,
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
                            widget.onEdit();
                          } else if (value == 'deletar') {
                            widget.onDelete();
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
                        'R\$ ${widget.valor.toStringAsFixed(2).replaceAll('.', ',')}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  if (_expanded) ...[
                    const SizedBox(height: 14),
                    Divider(color: Colors.white12, thickness: 1),
                    const SizedBox(height: 8),
                    Text(
                      'Mais detalhes da categoria podem ser exibidos aqui.',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}