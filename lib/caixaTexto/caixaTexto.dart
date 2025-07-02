import 'package:flutter/material.dart';
import 'dart:ui';

class CaixaTextoWidget extends StatefulWidget {
  const CaixaTextoWidget({Key? key}) : super(key: key);

  @override
  State<CaixaTextoWidget> createState() => _CaixaTextoWidgetState();
}

class _CaixaTextoWidgetState extends State<CaixaTextoWidget> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Container(
        height: 56,
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
              // ...existing code...
              Expanded(
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  style: const TextStyle(color: Colors.white, fontSize: 17),
                  minLines: 1,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    isCollapsed: true,
                    hintText: "Comprei uma camisa de 70 reais",
                    hintStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.normal,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 16),
                  ),
                ),
              ),
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
    );
  }
}
