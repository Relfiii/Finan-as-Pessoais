import 'package:flutter/material.dart';
import 'dart:ui';
import 'criarGasto.dart';
import 'criarCategoria.dart';
import 'configuracoes/configuracao.dart';
import '../telaLogin.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'controleFamiliar/controleFamiliar.dart';
import 'configuracoes/orcamento.dart';

class TelaLateral extends StatelessWidget {
  const TelaLateral({Key? key}) : super(key: key);
  

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Stack(
        children: [
          // Fundo translúcido com desfoque
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.black.withOpacity(0.0), // Ajuste a opacidade conforme necessário
            ),
          ),
          // Conteúdo da tela lateral
          SafeArea(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1E1E2C), Color(0xFF121212)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header com avatar e informações do usuário
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: const Color(0xFF7B2FF2),
                          child: const Icon(Icons.account_circle, size: 50, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        // Adicione o Flexible aqui
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Builder(
                                builder: (context) {
                                  final supabase = Supabase.instance.client;
                                  final userId = supabase.auth.currentUser?.id ?? '';
                                  return FutureBuilder(
                                    future: supabase.from('usuarios').select('nome, apelido').eq('id', userId).single(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const Text(
                                          'Carregando...',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: true,
                                        );
                                      } else if (snapshot.hasError || !snapshot.hasData) {
                                        return const Text(
                                          'Olá, Usuário!',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: true,
                                        );
                                      } else {
                                        final data = snapshot.data as Map<String, dynamic>;
                                        final apelido = (data['apelido'] ?? '').toString().trim();
                                        final nomeCompleto = data['nome'] ?? 'Usuário';
                                        final primeiroNome = apelido.isNotEmpty
                                            ? apelido
                                            : nomeCompleto.split(' ').first;
                                        return Text(
                                          'Olá, $primeiroNome!',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: true,
                                        );
                                      }
                                    },
                                  );
                                },
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Bem-vindo de volta',
                                style: TextStyle(
                                  color: Color(0xFFB983FF),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.white24, thickness: 1),
                  // Botões do menu
                  Expanded(
                    child: ListView(
                      children: [
                        _buildDrawerButton(
                          context,
                          icon: Icons.home_rounded,
                          label: 'Início',
                          onTap: () => Navigator.pop(context),
                        ),
                        _buildDrawerButton(
                          context,
                          icon: Icons.add_circle_outline,
                          label: 'Novo Gasto',
                          onTap: () {
                            Navigator.pop(context);
                            showGeneralDialog(
                              context: context,
                              barrierDismissible: true,
                              barrierLabel: "Adicionar Gasto",
                              barrierColor: Colors.black.withOpacity(0.3),
                              transitionDuration: const Duration(milliseconds: 200),
                              pageBuilder: (context, anim1, anim2) {
                                return const AddExpenseDialog();
                              },
                            );
                          },
                        ),
                        _buildDrawerButton(
                          context,
                          icon: Icons.category_outlined,
                          label: 'Categorias',
                          onTap: () {
                            Navigator.pop(context);
                            showGeneralDialog(
                              context: context,
                              barrierDismissible: true,
                              barrierLabel: "Adicionar Categoria",
                              barrierColor: Colors.black.withOpacity(0.3),
                              transitionDuration: const Duration(milliseconds: 200),
                              pageBuilder: (context, anim1, anim2) {
                                return const AddCategoryDialog();
                              },
                            );
                          },
                        ),
                        _buildDrawerButton(
                          context,
                          icon: Icons.pie_chart_outline,
                          label: 'Orçamento',
                          onTap: () {
                            final navigator = Navigator.of(context);
                            Navigator.pop(context);
                            Future.delayed(const Duration(milliseconds: 220), () {
                              navigator.push(
                                MaterialPageRoute(
                                  builder: (context) => const OrcamentoPage(),
                                ),
                              );
                            });
                          },
                          disabled: true,
                        ),
                        _buildDrawerButton(
                          context,
                          icon: Icons.family_restroom_outlined,
                          label: 'Controle Familiar',
                          onTap: () {
                            final navigator = Navigator.of(context);
                            Navigator.pop(context);
                            Future.delayed(const Duration(milliseconds: 220), () {
                              navigator.push(
                                MaterialPageRoute(
                                  builder: (context) => const ControleFamiliarPage(),
                                ),
                              );
                            });
                          },
                          disabled: true,
                        ),
                        _buildDrawerButton(
                          context,
                          icon: Icons.settings_outlined,
                          label: 'Configurações',
                          onTap: () {
                            final navigator = Navigator.of(context);
                            Navigator.pop(context);
                            Future.delayed(const Duration(milliseconds: 220), () {
                              navigator.push(
                                MaterialPageRoute(
                                  builder: (context) => const ConfiguracaoPage(),
                                ),
                              );
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.white24, thickness: 1),
                  // Ações rápidas no rodapé
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildQuickAction(
                          context,
                          icon: Icons.logout,
                          label: 'Sair',
                          onTap: () async {
                            final shouldLogout = await showGeneralDialog<bool>(
                              context: context,
                              barrierDismissible: true,
                              barrierLabel: "Confirmar Sair",
                              barrierColor: Colors.black.withOpacity(0.3),
                              transitionDuration: const Duration(milliseconds: 200),
                              pageBuilder: (context, anim1, anim2) {
                                return _LogoutConfirmDialog();
                              },
                            );
                            if (shouldLogout == true) {
                              try {
                                // Faz logout do Supabase
                                final supabase = Supabase.instance.client;
                                await supabase.auth.signOut();
                                
                                // Navega para a tela de login
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => TelaLogin()),
                                  (route) => false,
                                );
                              } catch (e) {
                                print('Erro durante logout: $e');
                                // Mesmo com erro, navega para login
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => TelaLogin()),
                                  (route) => false,
                                );
                              }
                            }
                          },
                        ),
                        _buildQuickAction(
                          context,
                          icon: Icons.help_outline,
                          label: 'Ajuda',
                          onTap: () {
                            // Adicione lógica de ajuda aqui
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, bottom: 12),
                    child: Text(
                      'NossoDinDin v1.0',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.2),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerButton(BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool disabled = false, // Adicionado
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: disabled ? Colors.grey : const Color(0xFFB983FF), // Cinza se desativado
        ),
      title: Text(
        label,
        style: TextStyle(
          color: disabled ? Colors.grey : Colors.white, // Cinza se desativado
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: disabled ? null : onTap, // Desativa o clique
    );
  }

  Widget _buildQuickAction(BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFB983FF), size: 20),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFFB983FF),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoutConfirmDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Center(
        child: AlertDialog(
          backgroundColor: const Color(0xFF181818),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text(
            'Sair',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Deseja sair?',
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB983FF),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Sair'),
            ),
          ],
        ),
      ),
    );
  }
}

