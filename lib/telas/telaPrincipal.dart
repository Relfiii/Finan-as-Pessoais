import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provedor/transicaoProvedor.dart';
import '../provedor/categoriaProvedor.dart';
import 'dart:ui';
import 'telaLateral.dart';
import '../caixaTexto/caixaTexto.dart';

/// Tela principal do aplicativo
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final transactionProvider = context.read<TransactionProvider>();
    final categoryProvider = context.read<CategoryProvider>();
    
    await Future.wait([
      transactionProvider.loadTransactions(),
      categoryProvider.loadCategories(),
    ]);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF181818),
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: RefreshIndicator(
            onRefresh: _loadData,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                // TOPO FIXO
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 16, top: 16, bottom: 0),
                  child: Row(
                    children: [
                      Builder(
                        builder: (context) => IconButton(
                          icon: Icon(Icons.menu, color: Color(0xFFB983FF)),
                          onPressed: () {
                            abrirMenuLateral(context);
                          },
                          tooltip: 'Abrir menu',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "NossoDinDin",
                        style: TextStyle(
                          color: Color(0xFFB983FF),
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      Spacer(),
                      // Botão de notificação adicionado
                      IconButton(
                        icon: Icon(Icons.notifications_none, color: Color(0xFFB983FF)),
                        tooltip: 'Notificações',
                        onPressed: () {
                          showGeneralDialog(
                            context: context,
                            barrierDismissible: true,
                            barrierLabel: "Notificações",
                            barrierColor: Colors.black.withOpacity(0.3),
                            transitionDuration: const Duration(milliseconds: 200),
                            pageBuilder: (context, anim1, anim2) {
                              return BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                child: Center(
                                  child: AlertDialog(
                                    backgroundColor: const Color(0xFF181818),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    title: Row(
                                      children: const [
                                        Icon(Icons.notifications, color: Color(0xFFB983FF)),
                                        SizedBox(width: 8),
                                        Text(
                                          'Notificações',
                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    content: const Text(
                                      'Nenhuma notificação no momento.',
                                      style: TextStyle(color: Colors.white70, fontSize: 14),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Fechar', style: TextStyle(color: Colors.white70)),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
                // Caixa de texto extraída para widget separado
                const CaixaTextoWidget(),
                // CONTEÚDO ROLÁVEL
                Expanded(
                  child: Consumer<TransactionProvider>(
                    builder: (context, transactionProvider, child) {
                      if (transactionProvider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (transactionProvider.error != null) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: theme.colorScheme.error,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                transactionProvider.error!,
                                style: theme.textTheme.bodyLarge,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadData,
                                child: const Text('Tentar novamente'),
                              ),
                            ],
                          ),
                        );
                      }

                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Mês/Ano
                            Padding(
                              padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                              child: Text(
                                "Junho 2025",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 32,
                                ),
                              ),
                            ),
                            // Cards de resumo
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                              child: Column(
                                children: [
                                  IntrinsicHeight(
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        // Saldo atual
                                        Expanded(
                                          child: Container(
                                            margin: const EdgeInsets.all(3),
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Color(0xFF23272F),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            constraints: const BoxConstraints(
                                              minHeight: 80,
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const SizedBox(height: 0),
                                                Text(
                                                  "Saldo atual",
                                                  style: TextStyle(color: Colors.white70, fontSize: 16),
                                                  softWrap: true,
                                                  overflow: TextOverflow.visible,
                                                ),
                                                const SizedBox(height: 8),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "R\$ 100.000.000,00",
                                                      style: TextStyle(
                                                        color: const Color.fromARGB(255, 24, 119, 5),
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 20,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        // Gasto total no mês
                                        Expanded(
                                          child: Container(
                                            margin: const EdgeInsets.all(3),
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Color(0xFF23272F),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            constraints: const BoxConstraints(
                                              minHeight: 80,
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const SizedBox(height: 0),
                                                Text(
                                                  "Gasto no mês",
                                                  style: TextStyle(color: Colors.white70, fontSize: 16),
                                                  softWrap: true,
                                                  overflow: TextOverflow.visible,
                                                ),
                                                const SizedBox(height: 8),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "R\$ 100.000.000,00",
                                                      style: TextStyle(
                                                        color: const Color.fromARGB(255, 151, 53, 53),
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 20,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Card de Investimentos abaixo
                                  Container(
                                    margin: const EdgeInsets.all(3),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF23272F),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    constraints: const BoxConstraints(
                                      minHeight: 80,
                                    ),
                                    width: double.infinity,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 0),
                                        Text(
                                          "Investimentos",
                                          style: TextStyle(color: Colors.white70, fontSize: 16),
                                          softWrap: true,
                                          overflow: TextOverflow.visible,
                                        ),
                                        const SizedBox(height: 8),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "R\$ 1.000.000.000,00",
                                              style: TextStyle(
                                                color: const Color.fromARGB(255, 15, 157, 240),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Lista de categorias em cards
                            Consumer<CategoryProvider>(
                              builder: (context, categoryProvider, child) {
                                final categories = categoryProvider.categories;
                                if (categories.isEmpty) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                    child: Text(
                                      'Nenhuma categoria cadastrada.',
                                      style: TextStyle(color: Colors.white54, fontSize: 16),
                                    ),
                                  );
                                }
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      // Responsivo: 4 colunas em telas largas, 2 em telas pequenas
                                      int crossAxisCount = constraints.maxWidth > 900
                                          ? 4
                                          : constraints.maxWidth > 600
                                              ? 3
                                              : 2;
                                      return GridView.builder(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: crossAxisCount,
                                          crossAxisSpacing: 10,
                                          mainAxisSpacing: 10,
                                          childAspectRatio: 2.0, // Proporção largura/altura do card
                                        ),
                                        itemCount: categories.length,
                                        itemBuilder: (context, index) {
                                          final cat = categories[index];
                                          // TODO: Buscar valor real da categoria e total do mês
                                          final valor = 'R\$ 0,00';
                                          return Container(
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF232323),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            padding: const EdgeInsets.all(10),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        cat.name,
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 16,
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                    PopupMenuButton<String>(
                                                      icon: const Icon(Icons.more_vert, color: Colors.white54),
                                                      color: const Color(0xFF23272F),
                                                      onSelected: (value) {
                                                        if (value == 'editar') {
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(content: Text('Editar "${cat.name}"')),
                                                          );
                                                        } else if (value == 'deletar') {
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(content: Text('Deletar "${cat.name}"')),
                                                          );
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
                                                const SizedBox(height: 2), // espaço menor
                                                Text(
                                                  valor,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18, // fonte um pouco menor
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}