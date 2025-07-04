import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provedor/categoriaProvedor.dart';
import '../provedor/gastoProvedor.dart';
import '../telas/criarCategoria.dart';
import '../telas/criarGasto.dart';
import '../telas/detalhesCategoria.dart';
import '../caixaTexto/caixaTexto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../modelos/categoria.dart';

class CaixaTextoOverlay extends StatefulWidget {
  static final GlobalKey<_CaixaTextoOverlayState> _key = GlobalKey();
  CaixaTextoOverlay({Key? key}) : super(key: _key);

  static void show(BuildContext context) {
    _key.currentState?.expand();
  }

  static bool isExpanded(BuildContext context) {
    return _key.currentState?.expanded ?? false;
  }

  @override
  State<CaixaTextoOverlay> createState() => _CaixaTextoOverlayState();
}

class _CaixaTextoOverlayState extends State<CaixaTextoOverlay> {
  bool expanded = false;
  void expand() => setState(() => expanded = true);
  void collapse() => setState(() => expanded = false);

  Future<void> _processarComandoIA(BuildContext context, String comando, CategoryProvider categoryProvider) async {
    final comandoLower = comando.toLowerCase();
    // Adicionar categoria
    if (comandoLower.startsWith('criar categoria') || comandoLower.startsWith('nova categoria')) {
      // Extrai o nome da categoria
      final nome = comando.replaceFirst(RegExp(r'(?i)criar categoria|nova categoria|adicionar categoria'), '').trim();
      if (nome.isNotEmpty) {
        // Simula o mesmo fluxo do botão de criar categoria
        final supabase = Supabase.instance.client;
        final response = await supabase
            .from('categorias')
            .insert({'nome': nome})
            .select()
            .single();
        final newCategory = Category(
          id: response['id'],
          name: nome,
          description: '',
          color: const Color(0xFFB983FF),
          icon: Icons.category,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await categoryProvider.addCategory(newCategory);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Categoria "$nome" criada!')),
        );
      }
    }
    // Deletar categoria
    else if (comandoLower.startsWith('deletar categoria') || comandoLower.startsWith('remover categoria')) {
      final nome = comandoLower
          .replaceFirst('deletar categoria', '')
          .replaceFirst('remover categoria', '')
          .trim();
      debugPrint('Comando para deletar categoria recebido: $nome');
      if (nome.isNotEmpty) {
        final categorias = categoryProvider.categories;
        Category? categoria;
        try {
          categoria = categorias.firstWhere(
            (cat) => cat.name.toLowerCase() == nome.toLowerCase(),
          );
          debugPrint('Categoria encontrada: ${categoria.name}');
        } catch (e) {
          categoria = null;
          debugPrint('Categoria não encontrada: $nome');
        }
        if (categoria != null) {
          await categoryProvider.deleteCategory(categoria.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Categoria "${categoria.name}" deletada!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Categoria "$nome" não encontrada!')),
          );
        }
      } else {
        debugPrint('Erro: Nome da categoria vazio no comando de deleção.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!expanded) return SizedBox.shrink();
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.45),
        child: Center(
          child: FractionallySizedBox(
            widthFactor: 0.95,
            child: CaixaTextoWidget(
              asButton: false,
              autofocus: true,
              onCollapse: () => setState(() => expanded = false),
              onSend: (comando, ctx) async {
                final categoryProvider = Provider.of<CategoryProvider>(ctx, listen: false);
                await _processarComandoIA(ctx, comando, categoryProvider);
              },
            ),
          ),
        ),
      ),
    );
  }
}

class CardGasto extends StatelessWidget {
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
          return Stack(
            children: [
              Column(
                children: [
                  // TopBar com botões de categoria, gasto e caixa de texto
                  Padding(
                    padding: const EdgeInsets.only(left: 8, right: 16, top: 16, bottom: 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(width: 10),
                        // Botão de categoria
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
                            icon: const Icon(Icons.category, color: Color(0xFFB983FF)),
                            label: const Text('Categoria'),
                            onPressed: () async {
                              await showDialog(
                                context: context,
                                builder: (context) => const AddCategoryDialog(),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Botão de gasto
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
                              CaixaTextoOverlay.show(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Conteúdo principal
                  Expanded(
                    child: categories.isEmpty
                        ? Center(
                            child: Text(
                              'Nenhuma categoria cadastrada.',
                              style: TextStyle(color: Colors.white54, fontSize: 16),
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                          ),
                  ),
                ],
              ),
              // Overlay da caixa de texto expandida
              CaixaTextoOverlay(),
            ],
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