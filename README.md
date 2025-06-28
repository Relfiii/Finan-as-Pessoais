# financeiro_app

# Financeiro App

Um aplicativo Flutter para controle financeiro pessoal, convertido de um projeto Next.js/TypeScript original.

## Recursos

- ✅ Gerenciamento de transações (receitas e despesas)
- ✅ Categorização de transações
- ✅ Dashboard com resumo financeiro
- ✅ Histórico de transações
- ✅ Persistência de dados local (SQLite)
- 🚧 Orçamentos e metas
- 🚧 Relatórios e gráficos
- 🚧 Exportação de dados

## Tecnologias Utilizadas

- **Flutter** - Framework UI multiplataforma
- **Dart** - Linguagem de programação
- **Provider** - Gerenciamento de estado
- **SQLite** - Banco de dados local
- **Decimal** - Cálculos precisos com valores monetários
- **Material Design 3** - Sistema de design

## Estrutura do Projeto

```
lib/
├── main.dart                 # Ponto de entrada do app
├── models/                   # Modelos de dados
│   ├── transaction.dart
│   ├── category.dart
│   └── budget.dart
├── providers/                # Gerenciamento de estado
│   ├── transaction_provider.dart
│   ├── category_provider.dart
│   └── budget_provider.dart
├── screens/                  # Telas do aplicativo
│   └── home_screen.dart
├── services/                 # Serviços e lógica de negócio
│   ├── database_service.dart
│   ├── transaction_service.dart
│   ├── category_service.dart
│   └── budget_service.dart
├── utils/                    # Utilitários
│   ├── format_utils.dart
│   └── calculation_utils.dart
└── widgets/                  # Componentes reutilizáveis
    ├── dashboard_card.dart
    └── recent_transactions.dart
```

## Como Executar

### Pré-requisitos

- Flutter SDK (versão 3.8.1 ou superior)
- Dart SDK
- Editor de código (VS Code recomendado)

### Instalação

1. Clone o repositório:
```bash
git clone <url-do-repositorio>
cd financeiro-app
```

2. Instale as dependências:
```bash
flutter pub get
```

3. Execute o aplicativo:
```bash
flutter run
```

## Comandos Úteis

- **Executar em modo debug**: `flutter run`
- **Executar testes**: `flutter test`
- **Analisar código**: `flutter analyze`
- **Formatar código**: `dart format .`
- **Gerar build**: `flutter build apk` (Android) ou `flutter build ios` (iOS)

## Dependências Principais

- `provider: ^6.1.2` - Gerenciamento de estado
- `sqflite: ^2.3.0` - Banco de dados SQLite
- `decimal: ^3.0.2` - Cálculos precisos com dinheiro
- `intl: ^0.19.0` - Formatação de data/hora e localização
- `fl_chart: ^0.68.0` - Gráficos e visualizações

## Contribuição

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

## Roadmap

- [ ] Tela de adicionar/editar transações
- [ ] Tela de categorias
- [ ] Tela de orçamentos
- [ ] Gráficos e relatórios
- [ ] Backup e restauração
- [ ] Tema escuro
- [ ] Filtros avançados
- [ ] Notificações
- [ ] Sincronização na nuvem

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
