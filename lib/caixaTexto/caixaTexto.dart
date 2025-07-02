import 'package:flutter/material.dart';
import 'dart:ui';

class CaixaTextoWidget extends StatefulWidget {
  final bool asButton;
  final bool autofocus;
  final VoidCallback? onExpand;
  final VoidCallback? onCollapse;
  const CaixaTextoWidget({Key? key, this.asButton = false, this.autofocus = false, this.onExpand, this.onCollapse}) : super(key: key);

  @override
  State<CaixaTextoWidget> createState() => _CaixaTextoWidgetState();
}

class _CaixaTextoWidgetState extends State<CaixaTextoWidget> with SingleTickerProviderStateMixin {
  bool isExpanded = false;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Se for modo botão, mostra compacto e só expande via callback
    if (widget.asButton) {
      return GestureDetector(
        onTap: () {
          if (widget.onExpand != null) widget.onExpand!();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF101828),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF3B82F6), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B82F6).withOpacity(0.18),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: const Icon(Icons.smart_toy, color: Colors.cyanAccent, size: 22),
          ),
        ),
      );
    }

    // Modo expandido (overlay)
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (widget.onCollapse != null) widget.onCollapse!();
      },
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3B82F6).withOpacity(0.25),
                  blurRadius: 16,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: const Color(0xFF3B82F6),
                width: 1.5,
              ),
            ),
            child: Container(
              margin: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                color: const Color(0xFF101828),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Animated input field com ícone IA
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1C1E),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.blueAccent.withOpacity(0.5), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.18),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.smart_toy, color: Colors.cyanAccent, size: 22),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              focusNode: _focusNode,
                              autofocus: widget.autofocus,
                              style: const TextStyle(color: Colors.white, fontSize: 17),
                              cursorColor: Colors.cyanAccent,
                              decoration: InputDecoration(
                                hintText: 'Ex: Comprei uma camisa de 70 reais',
                                hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                                border: InputBorder.none,
                                isCollapsed: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                              ),
                              minLines: 1,
                              maxLines: 1,
                              textAlign: TextAlign.left,
                              onSubmitted: (value) {
                                // Lógica para processar o texto e salvar
                                setState(() {
                                  _controller.clear();
                                });
                                if (widget.onCollapse != null) widget.onCollapse!();
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.cyanAccent, size: 20),
                            tooltip: 'Fechar',
                            onPressed: () {
                              if (widget.onCollapse != null) widget.onCollapse!();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Botão de ajuda permanece ao lado
                  Padding(
                    padding: const EdgeInsets.only(right: 14, left: 8),
                    child: IconButton(
                      icon: const Icon(Icons.help_outline, color: Color(0xFF3B82F6), size: 22),
                      tooltip: 'Como usar IA e comandos',
                      onPressed: () {
                        showGeneralDialog(
                          context: context,
                          barrierDismissible: true,
                          barrierLabel: "Ajuda IA",
                          barrierColor: Colors.black.withOpacity(0.3),
                          transitionDuration: const Duration(milliseconds: 200),
                          pageBuilder: (context, anim1, anim2) {
                            return BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                              child: Center(
                                child: AlertDialog(
                                  backgroundColor: const Color(0xFF23272F),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: const [
                                            Text(
                                              "🧠 IA Inteligente:",
                                              style: TextStyle(
                                                color: Color(0xFFFF6EC7),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          '• "Comprei carne 25.90" → 🛒 Mercado\n'
                                          '• "Comprei pizza 35" → 🍽️ Restaurante\n'
                                          '• "Comprei refrigerante 5.50" → ❓ Opções\n'
                                          '• "Gastei 50 no mercado"\n'
                                          '• "Uber custou 18"',
                                          style: TextStyle(color: Colors.white, fontSize: 14),
                                        ),
                                        Divider(color: Colors.white24, height: 24),
                                        Row(
                                          children: const [
                                            Text(
                                              "🟦 Criar Categorias:",
                                              style: TextStyle(
                                                color: Color(0xFF00E0C6),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          '• "Criar categoria Pets"\n'
                                          '• "Nova categoria Academia"',
                                          style: TextStyle(color: Colors.white, fontSize: 14),
                                        ),
                                        SizedBox(height: 12),
                                        Row(
                                          children: const [
                                            Text(
                                              "🟥 Deletar Categoria:",
                                              style: TextStyle(
                                                color: Color(0xFFFFB300),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          '• "Deletar categoria Pets"\n'
                                          '• "Remover categoria Academia"',
                                          style: TextStyle(color: Colors.white, fontSize: 14),
                                        ),
                                        SizedBox(height: 12),
                                        Row(
                                          children: const [
                                            Icon(Icons.info_outline, color: Color(0xFFFF6EC7), size: 18),
                                            SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                "A IA diferencia ingredientes de comida pronta!",
                                                style: TextStyle(
                                                  color: Color(0xFFFF6EC7),
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        Row(
                                          children: const [
                                            Icon(Icons.warning_amber_rounded, color: Color(0xFFFFB300), size: 18),
                                            SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                "Quando ambíguo, você escolhe a categoria!",
                                                style: TextStyle(
                                                  color: Color(0xFFFFB300),
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      child: const Text('Fechar', style: TextStyle(color: Color(0xFFB983FF))),
                                      onPressed: () => Navigator.of(context).pop(),
                                    ),
                                  ],
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
          ),
        ),
      ),
    );
  }
}
