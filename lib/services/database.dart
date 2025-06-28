import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Serviço responsável por gerenciar o banco de dados SQLite
class DatabaseService {
  static Database? _database;
  static const String _databaseName = 'financeiro.db';
  static const int _databaseVersion = 1;

  /// Singleton para obter a instância do banco
  static Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Inicializa o banco de dados
  static Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), _databaseName);
    
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Cria as tabelas do banco
  static Future<void> _onCreate(Database db, int version) async {
    // Tabela de categorias
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        color INTEGER NOT NULL,
        icon INTEGER NOT NULL,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    ''');

    // Tabela de transações
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        description TEXT NOT NULL,
        amount TEXT NOT NULL,
        type TEXT NOT NULL,
        categoryId TEXT NOT NULL,
        date INTEGER NOT NULL,
        notes TEXT,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL,
        FOREIGN KEY (categoryId) REFERENCES categories (id)
      )
    ''');

    // Tabela de orçamentos
    await db.execute('''
      CREATE TABLE budgets (
        id TEXT PRIMARY KEY,
        categoryId TEXT NOT NULL,
        amount TEXT NOT NULL,
        startDate INTEGER NOT NULL,
        endDate INTEGER NOT NULL,
        description TEXT,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL,
        FOREIGN KEY (categoryId) REFERENCES categories (id)
      )
    ''');

    // Inserir categorias padrão
    await _insertDefaultCategories(db);
  }

  /// Atualiza o banco de dados
  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Implementar migrações futuras aqui
  }

  /// Insere categorias padrão
  static Future<void> _insertDefaultCategories(Database db) async {
    final now = DateTime.now();
    final defaultCategories = [
      {
        'id': 'cat_food',
        'name': 'Alimentação',
        'description': 'Gastos com comida e bebida',
        'color': 0xFFFF5722,
        'icon': 0xe57c, // Icons.restaurant
        'createdAt': now.millisecondsSinceEpoch,
        'updatedAt': now.millisecondsSinceEpoch,
      },
      {
        'id': 'cat_transport',
        'name': 'Transporte',
        'description': 'Gastos com transporte',
        'color': 0xFF2196F3,
        'icon': 0xe571, // Icons.directions_car
        'createdAt': now.millisecondsSinceEpoch,
        'updatedAt': now.millisecondsSinceEpoch,
      },
      {
        'id': 'cat_entertainment',
        'name': 'Entretenimento',
        'description': 'Gastos com lazer e entretenimento',
        'color': 0xFF9C27B0,
        'icon': 0xe30a, // Icons.movie
        'createdAt': now.millisecondsSinceEpoch,
        'updatedAt': now.millisecondsSinceEpoch,
      },
      {
        'id': 'cat_health',
        'name': 'Saúde',
        'description': 'Gastos com saúde e medicamentos',
        'color': 0xFF4CAF50,
        'icon': 0xe3bf, // Icons.local_hospital
        'createdAt': now.millisecondsSinceEpoch,
        'updatedAt': now.millisecondsSinceEpoch,
      },
      {
        'id': 'cat_salary',
        'name': 'Salário',
        'description': 'Receita do trabalho',
        'color': 0xFF4CAF50,
        'icon': 0xe227, // Icons.attach_money
        'createdAt': now.millisecondsSinceEpoch,
        'updatedAt': now.millisecondsSinceEpoch,
      },
      {
        'id': 'cat_investment',
        'name': 'Investimentos',
        'description': 'Receita de investimentos',
        'color': 0xFF607D8B,
        'icon': 0xe8c8, // Icons.trending_up
        'createdAt': now.millisecondsSinceEpoch,
        'updatedAt': now.millisecondsSinceEpoch,
      },
    ];

    for (final category in defaultCategories) {
      await db.insert('categories', category);
    }
  }

  /// Fecha o banco de dados
  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  /// Limpa todas as tabelas (usado para testes)
  static Future<void> clearAll() async {
    final db = await database;
    await db.delete('transactions');
    await db.delete('budgets');
    await db.delete('categories');
    await _insertDefaultCategories(db);
  }
}
