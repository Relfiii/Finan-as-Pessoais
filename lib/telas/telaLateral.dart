import 'package:flutter/material.dart';
import 'dart:ui';
import 'criarGasto.dart';
import 'criarCategoria.dart';
import 'configuracao.dart';

// Widget para ser usado no showGeneralDialog, com desfoque global
class TelaLateralDialog extends StatelessWidget {
  const TelaLateralDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: 290,
        height: double.infinity,
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF23242B), Color(0xFF181A20)],
              ),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 24,
                  offset: const Offset(4, 0),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabeçalho com avatar e nome
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 28.0, horizontal: 20),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFB983FF), Color(0xFF7B2FF2)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.18),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(3),
                          child: const CircleAvatar(
                            radius: 26,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.account_circle, size: 44, color: Color(0xFF7B2FF2)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Olá, Usuário!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Bem-vindo de volta',
                              style: TextStyle(
                                color: Color(0xFFB983FF),
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Divider(
                      color: Colors.white.withOpacity(0.08),
                      thickness: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Menu principal
                  _ModernDrawerButton(
                    icon: Icons.home_rounded,
                    label: 'Início',
                    onTap: () {
                      Navigator.pop(context);
                    },
                    dark: true,
                    highlight: true,
                  ),
                  _ModernDrawerButton(
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
                    dark: true,
                  ),
                  _ModernDrawerButton(
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
                    dark: true,
                  ),
                  _ModernDrawerButton(
                    icon: Icons.family_restroom_outlined,
                    label: 'Controle Familiar',
                    onTap: () {
                      Navigator.pop(context);
                      showGeneralDialog(
                        context: context,
                        barrierDismissible: true,
                        barrierLabel: "Controle Familiar",
                        barrierColor: Colors.black.withOpacity(0.3),
                        transitionDuration: const Duration(milliseconds: 200),
                        pageBuilder: (context, anim1, anim2) {
                          return const AddCategoryDialog();
                        },
                      );
                    },
                    dark: true,
                  ),
                  _ModernDrawerButton(
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
                    dark: true,
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Divider(
                      color: Colors.white.withOpacity(0.08),
                      thickness: 1.2,
                    ),
                  ),
                  // Ações rápidas no rodapé
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _QuickActionButton(
                          icon: Icons.logout,
                          label: 'Sair',
                          onTap: () async {
                            Navigator.pop(context);
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
                              // ignore: use_build_context_synchronously
                              Navigator.pushReplacementNamed(context, '/login');
                            }
                          },
                        ),
                        _QuickActionButton(
                          icon: Icons.help_outline,
                          label: 'Ajuda',
                          onTap: () {
                            // Adicione aqui a lógica de ajuda
                          },
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, bottom: 12, top: 8),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Botão de ação rápida no rodapé
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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

// Função utilitária para abrir o menu lateral com desfoque global
void abrirMenuLateral(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Menu Lateral",
    barrierColor: Colors.black.withOpacity(0.2),
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, anim1, anim2) {
      return _AnimatedLateralMenu();
    },
    transitionBuilder: (context, anim1, anim2, child) {
      // Removido o SlideTransition daqui, pois será controlado internamente
      return child;
    },
  );
}

// Widget com animação de slide para o menu lateral
class _AnimatedLateralMenu extends StatefulWidget {
  @override
  State<_AnimatedLateralMenu> createState() => _AnimatedLateralMenuState();
}

class _AnimatedLateralMenuState extends State<_AnimatedLateralMenu> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: 1.0, // Começa visível
    );
  }

  bool _closing = false;

  void _closeMenu() async {
    if (_closing) return;
    setState(() => _closing = true);
    await _controller.reverse();
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Camada que captura o clique fora do menu
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _closeMenu,
          child: Container(
            color: Colors.transparent,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        // Desfoque global
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            color: Colors.black.withOpacity(0.15),
          ),
        ),
        // Menu lateral animado
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return AnimatedSlide(
              offset: Offset(-1 + _controller.value, 0),
              duration: Duration.zero, // controlado pelo AnimationController
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {}, // Previne propagação do tap para o fundo
                child: child,
              ),
            );
          },
          child: const TelaLateralDialog(),
        ),
      ],
    );
  }
}

// Botão customizado para o Drawer moderno
class _ModernDrawerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool dark;
  final bool highlight;

  const _ModernDrawerButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.dark = false,
    this.highlight = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color iconColor = highlight
        ? const Color(0xFF7B2FF2)
        : (dark ? const Color(0xFFB983FF) : Colors.white);
    final Color textColor = highlight
        ? const Color(0xFF7B2FF2)
        : (dark ? Colors.white : Colors.white);
    final Color? bgColor = highlight
        ? Colors.white.withOpacity(0.10)
        : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(13),
            boxShadow: highlight
                ? [
                    BoxShadow(
                      color: const Color(0xFF7B2FF2).withOpacity(0.10),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: TextButton.icon(
              onPressed: onTap,
              icon: Icon(icon, color: iconColor, size: 23),
              label: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              style: TextButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                foregroundColor: textColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Adicione ao final do arquivo:
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
