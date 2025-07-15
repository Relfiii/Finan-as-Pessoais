import 'package:flutter/material.dart';

/// Widget para mostrar estados de loading granulares com melhor UX
class GranularLoadingIndicator extends StatelessWidget {
  final bool isLoading;
  final String? loadingText;
  final Widget child;
  final Color? loadingColor;
  final double size;

  const GranularLoadingIndicator({
    super.key,
    required this.isLoading,
    required this.child,
    this.loadingText,
    this.loadingColor,
    this.size = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return child;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Tornar o conteúdo semi-transparente quando carregando
        Opacity(
          opacity: 0.3,
          child: child,
        ),
        // Indicador de loading
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    loadingColor ?? Theme.of(context).primaryColor,
                  ),
                ),
              ),
              if (loadingText != null) ...[
                const SizedBox(height: 8),
                Text(
                  loadingText!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Widget para mostrar loading em cards específicos
class CardLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String loadingMessage;

  const CardLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.loadingMessage = "Carregando...",
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      loadingMessage,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Widget para mostrar múltiplos estados de loading específicos
class MultipleLoadingIndicator extends StatelessWidget {
  final Map<String, bool> loadingStates;
  final Map<String, String> loadingMessages;
  final Widget child;

  const MultipleLoadingIndicator({
    super.key,
    required this.loadingStates,
    required this.child,
    this.loadingMessages = const {},
  });

  @override
  Widget build(BuildContext context) {
    final activeLoadings = loadingStates.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (activeLoadings.isEmpty) return child;

    return Stack(
      children: [
        Opacity(
          opacity: 0.5,
          child: child,
        ),
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Carregando...',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ...activeLoadings.map((loading) => Padding(
                  padding: const EdgeInsets.only(left: 24, top: 2),
                  child: Text(
                    loadingMessages[loading] ?? loading,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontSize: 11,
                    ),
                  ),
                )),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Helper para criar mensagens de loading amigáveis
class LoadingMessages {
  static const Map<String, String> messages = {
    'receitas': 'Carregando receitas...',
    'investimentos': 'Carregando investimentos...',
    'gastos': 'Carregando gastos...',
    'chart': 'Preparando gráfico...',
    'year_range': 'Buscando período de dados...',
    'totals': 'Calculando totais...',
  };

  static String getMessage(String key) {
    if (key.contains('_')) {
      final parts = key.split('_');
      if (parts.length >= 2) {
        final type = parts[0];
        final period = parts[1];
        return '${messages[type] ?? 'Carregando'} ($period)';
      }
    }
    return messages[key] ?? 'Carregando $key...';
  }
}
