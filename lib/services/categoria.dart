import 'package:sqflite/sqflite.dart';
import '../modelos/categoria.dart' as models;
import 'database.dart';
import 'package:flutter/foundation.dart';

/// Serviço para operações CRUD com categorias
class CategoryService {
  /// Busca todas as categorias
  static Future<List<models.Category>> getAll() async {
    if (kIsWeb) {
      // Na web, retorna lista vazia ou usa Supabase
      return [];
    }
    
    final db = await DatabaseService.database;
    if (db == null) return [];
    
    final List<Map<String, dynamic>> maps = await db.query('categories');
    
    return List.generate(maps.length, (i) {
      return models.Category.fromMap(maps[i]);
    });
  }

  /// Busca uma categoria por ID
  static Future<models.Category?> getById(String id) async {
    if (kIsWeb) {
      // Na web, retorna null ou usa Supabase
      return null;
    }
    
    final db = await DatabaseService.database;
    if (db == null) return null;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return models.Category.fromMap(maps.first);
    }
    return null;
  }

  /// Insere uma nova categoria
  static Future<void> insert(models.Category category) async {
    if (kIsWeb) {
      // Na web, não faz nada ou usa Supabase
      return;
    }
    
    final db = await DatabaseService.database;
    if (db == null) return;
    
    await db.insert(
      'categories',
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Atualiza uma categoria existente
  static Future<void> update(models.Category category) async {
    if (kIsWeb) {
      // Na web, não faz nada ou usa Supabase
      return;
    }
    
    final db = await DatabaseService.database;
    if (db == null) return;
    
    await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  /// Remove uma categoria
  static Future<void> delete(String id) async {
    if (kIsWeb) {
      // Na web, não faz nada ou usa Supabase
      return;
    }
    
    final db = await DatabaseService.database;
    if (db == null) return;
    
    await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Verifica se uma categoria tem transações associadas
  static Future<bool> hasTransactions(String categoryId) async {
    if (kIsWeb) {
      // Na web, retorna false ou usa Supabase
      return false;
    }
    
    final db = await DatabaseService.database;
    if (db == null) return false;
    
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM transactions WHERE categoryId = ?',
      [categoryId],
    );
    final count = result.first['count'] as int;
    return count > 0;
  }
}
