# Copilot Instructions

<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

## Project Overview
This is a Flutter/Dart financial management application converted from a Next.js/TypeScript project. The app provides comprehensive financial tracking including:

- Expense and income management
- Category organization
- Dashboard with financial analytics
- Transaction history
- Budget planning

## Development Guidelines

### Architecture
- Follow Flutter best practices with proper separation of concerns
- Use Provider or Riverpod for state management
- Implement clean architecture patterns where appropriate
- Use proper folder structure: lib/models, lib/screens, lib/widgets, lib/services

### Code Style
- Follow Dart naming conventions (camelCase for variables, PascalCase for classes)
- Use meaningful variable and function names
- Add proper documentation comments for public APIs
- Implement error handling for all async operations

### Financial Data Handling
- Always use decimal arithmetic for monetary calculations (avoid floating point)
- Implement proper validation for financial inputs
- Use appropriate date/time handling for transactions
- Ensure data persistence with local storage (SQLite/Hive)

### UI/UX Guidelines
- Follow Material Design 3 principles
- Implement responsive design for different screen sizes
- Use proper color schemes for financial data (red for expenses, green for income)
- Include loading states and error handling in the UI
- Implement proper accessibility features

### Dependencies
- Use official Flutter packages when possible
- Keep dependencies minimal and well-maintained
- Document any custom implementations or workarounds
