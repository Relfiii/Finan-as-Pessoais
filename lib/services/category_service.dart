import 'package:sqflite/sqflite.dart';
import '../models/category.dart';
import 'database_service.dart';

/// Serviço para operações CRUD com categorias
class CategoryService {
  /// Busca todas as categorias
  static Future<List<Category>> getAll() async {
    final db = await DatabaseService.database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    
    return List.generate(maps.length, (i) {
      return Category.fromMap(maps[i]);
    });
  }

  /// Busca uma categoria por ID
  static Future<Category?> getById(String id) async {
    final db = await DatabaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Category.fromMap(maps.first);
    }
    return null;
  }

  /// Insere uma nova categoria
  static Future<void> insert(Category category) async {
    final db = await DatabaseService.database;
    await db.insert(
      'categories',
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Atualiza uma categoria existente
  static Future<void> update(Category category) async {
    final db = await DatabaseService.database;
    await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  /// Remove uma categoria
  static Future<void> delete(String id) async {
    final db = await DatabaseService.database;
    await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Verifica se uma categoria tem transações associadas
  static Future<bool> hasTransactions(String categoryId) async {
    final db = await DatabaseService.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM transactions WHERE categoryId = ?',
      [categoryId],
    );
    final count = result.first['count'] as int;
    return count > 0;
  }
}
