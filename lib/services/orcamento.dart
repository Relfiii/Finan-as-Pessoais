import 'package:sqflite/sqflite.dart';
import '../modelos/orcamento.dart';
import 'database.dart';
import 'package:flutter/foundation.dart';

/// Serviço para operações CRUD com orçamentos
class BudgetService {
  /// Busca todos os orçamentos
  static Future<List<Budget>> getAll() async {
    if (kIsWeb) {
      // Na web, retorna lista vazia ou usa Supabase
      return [];
    }
    
    final db = await DatabaseService.database;
    if (db == null) return [];
    
    final List<Map<String, dynamic>> maps = await db.query(
      'budgets',
      orderBy: 'startDate DESC',
    );
    
    return List.generate(maps.length, (i) {
      return Budget.fromMap(maps[i]);
    });
  }

  /// Busca orçamentos ativos (que incluem a data atual)
  static Future<List<Budget>> getActive() async {
    if (kIsWeb) {
      // Na web, retorna lista vazia ou usa Supabase
      return [];
    }
    
    final now = DateTime.now();
    final db = await DatabaseService.database;
    if (db == null) return [];
    
    final List<Map<String, dynamic>> maps = await db.query(
      'budgets',
      where: 'startDate <= ? AND endDate >= ?',
      whereArgs: [now.millisecondsSinceEpoch, now.millisecondsSinceEpoch],
      orderBy: 'startDate DESC',
    );
    
    return List.generate(maps.length, (i) {
      return Budget.fromMap(maps[i]);
    });
  }

  /// Busca orçamentos por categoria
  static Future<List<Budget>> getByCategory(String categoryId) async {
    if (kIsWeb) {
      // Na web, retorna lista vazia ou usa Supabase
      return [];
    }
    
    final db = await DatabaseService.database;
    if (db == null) return [];
    
    final List<Map<String, dynamic>> maps = await db.query(
      'budgets',
      where: 'categoryId = ?',
      whereArgs: [categoryId],
      orderBy: 'startDate DESC',
    );
    
    return List.generate(maps.length, (i) {
      return Budget.fromMap(maps[i]);
    });
  }

  /// Busca um orçamento por ID
  static Future<Budget?> getById(String id) async {
    if (kIsWeb) {
      // Na web, retorna null ou usa Supabase
      return null;
    }
    
    final db = await DatabaseService.database;
    if (db == null) return null;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'budgets',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Budget.fromMap(maps.first);
    }
    return null;
  }

  /// Insere um novo orçamento
  static Future<void> insert(Budget budget) async {
    if (kIsWeb) {
      // Na web, não faz nada ou usa Supabase
      return;
    }
    
    final db = await DatabaseService.database;
    if (db == null) return;
    
    await db.insert(
      'budgets',
      budget.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Atualiza um orçamento existente
  static Future<void> update(Budget budget) async {
    if (kIsWeb) {
      // Na web, não faz nada ou usa Supabase
      return;
    }
    
    final db = await DatabaseService.database;
    if (db == null) return;
    
    await db.update(
      'budgets',
      budget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  /// Remove um orçamento
  static Future<void> delete(String id) async {
    if (kIsWeb) {
      // Na web, não faz nada ou usa Supabase
      return;
    }
    
    final db = await DatabaseService.database;
    if (db == null) return;
    
    await db.delete(
      'budgets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Busca orçamentos com dados da categoria
  static Future<List<Map<String, dynamic>>> getBudgetsWithCategory() async {
    if (kIsWeb) {
      // Na web, retorna lista vazia ou usa Supabase
      return [];
    }
    
    final db = await DatabaseService.database;
    if (db == null) return [];
    
    return await db.rawQuery('''
      SELECT 
        b.*,
        c.name as categoryName,
        c.color as categoryColor,
        c.icon as categoryIcon
      FROM budgets b
      LEFT JOIN categories c ON b.categoryId = c.id
      ORDER BY b.startDate DESC
    ''');
  }
}
