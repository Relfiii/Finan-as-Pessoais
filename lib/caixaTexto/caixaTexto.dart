import 'package:flutter/material.dart';
import 'dart:ui';

class CaixaTextoWidget extends StatefulWidget {
  final bool asButton;
  final bool autofocus;
  final VoidCallback? onExpand;
  final VoidCallback? onCollapse;
  final double buttonWidth;
  final double buttonHeight;
  final Future<void> Function(String, BuildContext)? onSend;

  const CaixaTextoWidget({
    Key? key,
    this.asButton = false,
    this.autofocus = false,
    this.onExpand,
    this.onCollapse,
    this.buttonWidth = 20,
    this.buttonHeight = 40,
    this.onSend,
  }) : super(key: key);

  @override
  State<CaixaTextoWidget> createState() => _CaixaTextoWidgetState();
}

class _CaixaTextoWidgetState extends State<CaixaTextoWidget> with SingleTickerProviderStateMixin {
  bool _showSend = false;
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
    if (widget.asButton) {
      double iconSize = (widget.buttonWidth < widget.buttonHeight
              ? widget.buttonWidth
              : widget.buttonHeight) *
          0.8;
      iconSize = iconSize.clamp(12.0, 28.0);

      return GestureDetector(
        onTap: () {
          if (widget.onExpand != null) widget.onExpand!();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          height: widget.buttonHeight,
          width: widget.buttonWidth,
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
            child: Icon(
              Icons.smart_toy,
              color: Colors.cyanAccent,
              size: iconSize,
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (widget.onCollapse != null) widget.onCollapse!();
      },
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 12, right: 0, top: 0, bottom: 0),
          child: Container(
            height: 64,
            width: MediaQuery.of(context).size.width * 1.0,
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
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              focusNode: _focusNode,
                              autofocus: widget.autofocus,
                              style: const TextStyle(color: Colors.white, fontSize: 17),
                              cursorColor: Colors.cyanAccent,
                              decoration: InputDecoration(
                                hintText: 'Ex: Digite aqui o que deseja...',
                                hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                                border: InputBorder.none,
                                isCollapsed: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                              ),
                              minLines: 1,
                              maxLines: 1,
                              textAlign: TextAlign.left,
                              onChanged: (value) {
                                setState(() {
                                  _showSend = value.trim().isNotEmpty;
                                });
                              },
                              onSubmitted: (value) async {
                                final trimmedValue = value.trim();
                                if (trimmedValue.isNotEmpty) {
                                  if (trimmedValue.startsWith('Criar categoria')) {
                                    final category = trimmedValue.replaceFirst('Criar categoria', '').trim();
                                    if (category.isNotEmpty) {
                                      print('Categoria "$category" criada com sucesso!');
                                    } else {
                                      print('Erro: Nome da categoria não fornecido.');
                                    }
                                  } else if (trimmedValue.startsWith('Nova categoria')) {
                                    final category = trimmedValue.replaceFirst('Nova categoria', '').trim();
                                    if (category.isNotEmpty) {
                                      print('Categoria "$category" criada com sucesso!');
                                    } else {
                                      print('Erro: Nome da categoria não fornecido.');
                                    }
                                  } else if (trimmedValue.startsWith('Deletar categoria')) {
                                    final category = trimmedValue.replaceFirst('Deletar categoria', '').trim();
                                    if (category.isNotEmpty) {
                                      print('Categoria "$category" deletada com sucesso!');
                                    } else {
                                      print('Erro: Nome da categoria não fornecido.');
                                    }
                                  } else if (trimmedValue.startsWith('Remover categoria')) {
                                    final category = trimmedValue.replaceFirst('Remover categoria', '').trim();
                                    if (category.isNotEmpty) {
                                      print('Categoria "$category" removida com sucesso!');
                                    } else {
                                      print('Erro: Nome da categoria não fornecido.');
                                    }
                                  } else {
                                    print('Comando não reconhecido: $trimmedValue');
                                  }
                                }
                                setState(() {
                                  _controller.clear();
                                  _showSend = false;
                                });
                                if (widget.onCollapse != null) widget.onCollapse!();
                              },
                            ),
                          ),
                          if (_showSend)
                            IconButton(
                              icon: const Icon(Icons.send, color: Colors.cyanAccent, size: 20),
                              tooltip: 'Enviar',
                              onPressed: () async {
                                final value = _controller.text.trim();
                                if (widget.onSend != null && value.isNotEmpty) {
                                  await widget.onSend!(value, context);
                                }
                                setState(() {
                                  _controller.clear();
                                  _showSend = false;
                                });
                                if (widget.onCollapse != null) widget.onCollapse!();
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 6, left: 4),
                    child: SizedBox(
                      width: 32,
                      height: 32,
                      child: IconButton(
                        icon: const Icon(Icons.help_outline, color: Color(0xFF3B82F6), size: 20),
                        tooltip: 'Como usar IA e comandos',
                        padding: EdgeInsets.zero,
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
