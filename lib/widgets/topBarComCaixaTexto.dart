import 'package:flutter/material.dart';
import 'dart:ui';
import '../caixaTexto/caixaTexto.dart';
import '../telas/telaLateral.dart';

/// Widget reutilizável para TopBar com CaixaTextoWidget
class TopBarComCaixaTexto extends StatefulWidget {
  final String? titulo;
  final bool mostrarMenuLateral;
  final bool mostrarNotificacao;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onNotificationPressed;
  
  const TopBarComCaixaTexto({
    Key? key,
    this.titulo,
    this.mostrarMenuLateral = true,
    this.mostrarNotificacao = true,
    this.onMenuPressed,
    this.onNotificationPressed,
  }) : super(key: key);

  @override
  State<TopBarComCaixaTexto> createState() => _TopBarComCaixaTextoState();
}

class _TopBarComCaixaTextoState extends State<TopBarComCaixaTexto> {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Menu lateral ou botão de voltar
        if (widget.mostrarMenuLateral)
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Color(0xFFB983FF)),
              onPressed: widget.onMenuPressed ?? () {
                abrirMenuLateral(context);
              },
              tooltip: 'Abrir menu',
            ),
          )
        else
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFFB983FF)),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Voltar',
          ),
        
        const SizedBox(width: 8),
        
        // Título
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: !CaixaTextoOverlay.isExpanded(context)
              ? Text(
                  widget.titulo ?? "NossoDinDin",
                  key: const ValueKey('title'),
                  style: const TextStyle(
                    color: Color(0xFFB983FF),
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                )
              : const SizedBox(width: 120),
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
        
        const SizedBox(width: 8),
        
        // Botão de notificação
        if (widget.mostrarNotificacao)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: !CaixaTextoOverlay.isExpanded(context)
                ? IconButton(
                    key: const ValueKey('notif'),
                    icon: const Icon(Icons.notifications_none, color: Color(0xFFB983FF)),
                    tooltip: 'Notificações',
                    onPressed: widget.onNotificationPressed ?? _mostrarNotificacoes,
                  )
                : const SizedBox(width: 48),
          ),
      ],
    );
  }

  void _mostrarNotificacoes() {
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              title: const Row(
                children: [
                  Icon(Icons.notifications, color: Color(0xFFB983FF)),
                  SizedBox(width: 8),
                  Text(
                    'Notificações',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
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
                  child: const Text('Fechar',
                      style: TextStyle(color: Colors.white70)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Overlay global para caixa de texto expandida
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

  @override
  Widget build(BuildContext context) {
    if (!expanded) return const SizedBox.shrink();
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
            ),
          ),
        ),
      ),
    );
  }
}
