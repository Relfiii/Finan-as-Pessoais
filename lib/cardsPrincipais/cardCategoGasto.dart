import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CategoryCard extends StatelessWidget {
  final String categoryName;
  final double valor;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CategoryCard({
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
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: pressed 
                    ? [Color(0xFF3A3A3A), Color(0xFF2E2E2E)]
                    : [Color(0xFF2A2A2A), Color(0xFF1E1E1E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(pressed ? 0.3 : 0.1),
                    blurRadius: pressed ? 12 : 8,
                    offset: Offset(0, pressed ? 2 : 4),
                  ),
                  BoxShadow(
                    color: Color(0xFFB983FF).withOpacity(pressed ? 0.15 : 0.05),
                    blurRadius: pressed ? 24 : 20,
                    spreadRadius: pressed ? -2 : -4,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    splashColor: Color(0xFFB983FF).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    onTap: onTap,
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