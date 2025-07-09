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
import 'dart:ui';
import 'package:intl/intl.dart';

class CaixaTextoOverlay extends StatefulWidget {
  final GlobalKey<_CaixaTextoOverlayState> _key = GlobalKey();

  CaixaTextoOverlay({Key? key}) : super(key: key);

  void show(BuildContext context) {
    _key.currentState?.expand();
  }

  bool isExpanded(BuildContext context) {
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
        final userId = Supabase.instance.client.auth.currentUser!.id;
        final response = await Supabase.instance.client
          .from('categorias')
          .insert({'nome': nome, 'user_id': userId})
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

class CardGasto extends StatefulWidget {
  @override
  _CardGastoState createState() => _CardGastoState();
}

class _CardGastoState extends State<CardGasto> {

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
    return RefreshIndicator(
      onRefresh: () async {
        // Atualiza categorias e gastos
        await Provider.of<CategoryProvider>(context, listen: false).loadCategories();
        await Provider.of<GastoProvider>(context, listen: false).loadGastos();
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Fundo gradiente com desfoque
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
              child: RefreshIndicator(
                onRefresh: () async {
                  // Atualiza categorias e gastos
                  await Provider.of<CategoryProvider>(context, listen: false).loadCategories();
                  await Provider.of<GastoProvider>(context, listen: false).loadGastos();
                },
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
                          const Expanded(
                            child: Center(
                              child: Text(
                                'Despesa do Mês',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 40),
                        ],
                      ),
                    ),
                    const Divider(color: Colors.white24, thickness: 1, indent: 24, endIndent: 24),
                    // TopBar com botões de categoria, gasto e caixa de texto
                    Padding(
                      padding: const EdgeInsets.only(left: 8, right: 16, top: 8, bottom: 0),
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
                              label: const Text('Despesa'),
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
                                caixaTextoOverlay.show(context);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Cards de categorias no topo, logo abaixo dos botões
                    Consumer2<CategoryProvider, GastoProvider>(
                      builder: (context, categoryProvider, gastoProvider, child) {
                        final categories = categoryProvider.categories;
                        return Padding(
                          padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                          child: categories.isEmpty
                              ? Center(
                                  child: Text(
                                    'Nenhuma categoria cadastrada.',
                                    style: TextStyle(color: Colors.white54, fontSize: 16),
                                  ),
                                )
                              : GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.zero,
                                  itemCount: categories.length,
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 1.6, // valor menor deixa o card mais alto
                                  ),
                                  itemBuilder: (context, index) {
                                    final cat = categories[index];
                                    final valor = gastoProvider.totalPorCategoria(cat.id);
                                    return _CategoryCard(
                                      categoryName: cat.name,
                                      valor: valor,
                                      onTap: () async {
                                        final gastoProvider = Provider.of<GastoProvider>(context, listen: false);
                                        
                                        // Recarrega os dados da base para a categoria selecionada
                                        await gastoProvider.getGastosPorCategoria(cat.id);
                                      
                                        // Navega para a tela de detalhes da categoria
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
                        );
                      },
                    ),
                    // Spacer para empurrar o rodapé para baixo
                    const Spacer(),
                    Center(
                      child: Text(
                        'NossoDinDin v1.0',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.18),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            // Overlay da caixa de texto expandida
            CaixaTextoOverlay(),
          ],
        ),
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
    final ValueNotifier<bool> isPressed = ValueNotifier(false);
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return GestureDetector(
      onTap: onTap,
      onTapDown: (_) => isPressed.value = true,
      onTapUp: (_) => isPressed.value = false,
      onTapCancel: () => isPressed.value = false,
      child: ValueListenableBuilder<bool>(
        valueListenable: isPressed,
        builder: (context, pressed, child) {
          return AnimatedScale(
            scale: pressed ? 0.98 : 1.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2A2A2A), Color(0xFF1E1E1E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.red.withOpacity(0.2).withOpacity(0.10), 
                    blurRadius: 20,
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    splashColor: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
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
                                    fontSize: 18,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert, color: Colors.white54, size: 20),
                                color: const Color(0xFF2A2A2A),
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
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.attach_money, color: Color(0xFFB983FF), size: 20),
                              const SizedBox(width: 6),
                              Text(
                                formatter.format(valor),
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 214, 158, 158),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Declare a instância de CaixaTextoOverlay no escopo correto
final CaixaTextoOverlay caixaTextoOverlay = CaixaTextoOverlay();