import 'package:flutter/material.dart';
import 'dart:ui';
import 'criarGasto.dart';
import 'criarCategoria.dart';


// Widget para ser usado no showGeneralDialog, com desfoque global
class TelaLateralDialog extends StatelessWidget {
  const TelaLateralDialog({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: 260,
        height: double.infinity,
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF181A20),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 8),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(8),
                          child: const Icon(Icons.account_circle, size: 44, color: Color(0xFFB983FF)),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Menu',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Color(0xFF23242B), thickness: 1, indent: 8, endIndent: 8),
                  const SizedBox(height: 6),
                  _ModernDrawerButton(
                    icon: Icons.home,
                    label: 'Início',
                    onTap: () {
                      Navigator.pop(context);
                    },
                    dark: true,
                  ),
                  _ModernDrawerButton(
                    icon: Icons.add,
                    label: 'Gasto',
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
                    icon: Icons.category,
                    label: 'Categoria',
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
                    icon: Icons.family_restroom,
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
                    icon: Icons.settings,
                    label: 'Configurações',
                    onTap: () {},
                    dark: true,
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
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
      return Stack(
        children: [
          // Desfoque global
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              color: Colors.black.withOpacity(0.15),
            ),
          ),
          const TelaLateralDialog(),
        ],
      );
    },
    transitionBuilder: (context, anim1, anim2, child) {
      final offset = Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero).animate(anim1);
      return SlideTransition(position: offset, child: child);
    },
  );
}

// Botão customizado para o Drawer moderno
class _ModernDrawerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool dark;

  const _ModernDrawerButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.dark = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final Color backgroundColor = dark ? const Color(0xFF23242B) : const Color(0xFF7B2FF2); // não utilizado
    final Color iconColor = dark ? const Color(0xFFB983FF) : Colors.white;
    final Color textColor = dark ? Colors.white : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: TextButton.icon(
          onPressed: onTap,
          icon: Icon(icon, color: iconColor, size: 22),
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
            backgroundColor: Colors.transparent, // Sem fundo
            elevation: 0,
          ),
        ),
      ),
    );
  }
}
