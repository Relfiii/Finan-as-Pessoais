import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Widget responsivo que adapta o layout para diferentes tamanhos de tela
class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.maxWidth = 1200,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    // Em dispositivos móveis, usa toda a largura
    if (!kIsWeb || MediaQuery.of(context).size.width < 768) {
      return child;
    }

    // Na web, centraliza o conteúdo com largura máxima
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
        child: child,
      ),
    );
  }
}

/// Widget para cards responsivos
class ResponsiveCardLayout extends StatelessWidget {
  final List<Widget> cards;
  final double spacing;

  const ResponsiveCardLayout({
    super.key,
    required this.cards,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Na web com tela grande, usa grid responsivo
    if (kIsWeb && screenWidth > 1024) {
      return _buildDesktopLayout();
    } 
    // Em tablets ou telas médias
    else if (screenWidth > 768) {
      return _buildTabletLayout();
    } 
    // Em dispositivos móveis, mantém layout original
    else {
      return _buildMobileLayout();
    }
  }

  Widget _buildDesktopLayout() {
    return Column(
      children: [
        // Primeira linha: Cards de Saldo e Gasto lado a lado
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 1, child: cards[0]), // Saldo
              SizedBox(width: spacing),
              Expanded(flex: 1, child: cards[1]), // Gasto
            ],
          ),
        ),
        SizedBox(height: spacing),
        // Segunda linha: Card de Investimento com largura controlada
        Row(
          children: [
            Expanded(
              flex: 2,
              child: cards[2], // Investimento
            ),
            const Expanded(flex: 1, child: SizedBox()), // Espaço vazio
          ],
        ),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Column(
      children: [
        // Cards de Saldo e Gasto lado a lado
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: cards[0]),
              SizedBox(width: spacing),
              Expanded(child: cards[1]),
            ],
          ),
        ),
        SizedBox(height: spacing),
        // Card de Investimento full width
        cards[2],
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        // Layout original para mobile
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: cards[0]),
              Expanded(child: cards[1]),
            ],
          ),
        ),
        SizedBox(height: spacing),
        cards[2],
      ],
    );
  }
}

/// Extension para verificar se é desktop
extension ScreenSize on BuildContext {
  bool get isDesktop => kIsWeb && MediaQuery.of(this).size.width > 1024;
  bool get isTablet => MediaQuery.of(this).size.width > 768 && MediaQuery.of(this).size.width <= 1024;
  bool get isMobile => MediaQuery.of(this).size.width <= 768;
}
