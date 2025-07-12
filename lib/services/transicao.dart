import 'package:sqflite/sqflite.dart' as sqflite;
import '../modelos/transicao.dart';
import 'database.dart';
import 'package:flutter/foundation.dart';
import 'transicao_web.dart';

/// Serviço para operações CRUD com transações
class TransactionService {
  /// Busca todas as transações
  static Future<List<Transaction>> getAll() async {
    if (kIsWeb) {
      return await TransactionServiceWeb.getAll();
    }
    
    final db = await DatabaseService.database;
    if (db == null) return [];
    
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      orderBy: 'date DESC',
    );
    
    return List.generate(maps.length, (i) {
      return Transaction.fromMap(maps[i]);
    });
  }

  /// Busca transações por período
  static Future<List<Transaction>> getByDateRange(DateTime start, DateTime end) async {
    if (kIsWeb) {
      return await TransactionServiceWeb.getByDateRange(start, end);
    }
    
    final db = await DatabaseService.database;
    if (db == null) return [];
    
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'date >= ? AND date <= ?',
      whereArgs: [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
      orderBy: 'date DESC',
    );
    
    return List.generate(maps.length, (i) {
      return Transaction.fromMap(maps[i]);
    });
  }

  /// Busca transações por categoria
  static Future<List<Transaction>> getByCategory(String categoryId) async {
    if (kIsWeb) {
      return await TransactionServiceWeb.getByCategory(categoryId);
    }
    
    final db = await DatabaseService.database;
    if (db == null) return [];
    
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'categoryId = ?',
      whereArgs: [categoryId],
      orderBy: 'date DESC',
    );
    
    return List.generate(maps.length, (i) {
      return Transaction.fromMap(maps[i]);
    });
  }

  /// Busca transações por tipo
  static Future<List<Transaction>> getByType(TransactionType type) async {
    if (kIsWeb) {
      return await TransactionServiceWeb.getByType(type);
    }
    
    final db = await DatabaseService.database;
    if (db == null) return [];
    
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'type = ?',
      whereArgs: [type.name],
      orderBy: 'date DESC',
    );
    
    return List.generate(maps.length, (i) {
      return Transaction.fromMap(maps[i]);
    });
  }

  /// Busca uma transação por ID
  static Future<Transaction?> getById(String id) async {
    if (kIsWeb) {
      return await TransactionServiceWeb.getById(id);
    }
    
    final db = await DatabaseService.database;
    if (db == null) return null;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return Transaction.fromMap(maps.first);
    }
    
    return null;
  }

  /// Insere uma nova transação
  static Future<void> insert(Transaction transaction) async {
    if (kIsWeb) {
      return await TransactionServiceWeb.insert(transaction);
    }
    
    final db = await DatabaseService.database;
    if (db == null) return;
    
    await db.insert(
      'transactions',
      transaction.toMap(),
      conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
    );
  }

  /// Atualiza uma transação existente
  static Future<void> update(Transaction transaction) async {
    if (kIsWeb) {
      return await TransactionServiceWeb.update(transaction);
    }
    
    final db = await DatabaseService.database;
    if (db == null) return;
    
    await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  /// Exclui uma transação
  static Future<void> delete(String id) async {
    if (kIsWeb) {
      return await TransactionServiceWeb.delete(id);
    }
    
    final db = await DatabaseService.database;
    if (db == null) return;
    
    await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Busca transações com dados da categoria
  static Future<List<Map<String, dynamic>>> getTransactionsWithCategory() async {
    if (kIsWeb) {
      return await TransactionServiceWeb.getTransactionsWithCategory();
    }
    
    final db = await DatabaseService.database;
    if (db == null) return [];
    
    return await db.rawQuery('''
      SELECT 
        t.*,
        c.name as categoryName,
        c.color as categoryColor,
        c.icon as categoryIcon
      FROM transactions t
      LEFT JOIN categories c ON t.categoryId = c.id
      ORDER BY t.date DESC
    ''');
  }

  /// Busca resumo de transações por categoria em um período
  static Future<List<Map<String, dynamic>>> getCategorySummary(
    DateTime start, 
    DateTime end,
    TransactionType? type,
  ) async {
    if (kIsWeb) {
      return await TransactionServiceWeb.getCategorySummary(start, end, type);
    }
    
    final db = await DatabaseService.database;
    if (db == null) return [];
    
    String whereClause = 'WHERE t.date >= ? AND t.date <= ?';
    List<dynamic> whereArgs = [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch];
    
    if (type != null) {
      whereClause += ' AND t.type = ?';
      whereArgs.add(type.name);
    }
    
    return await db.rawQuery('''
      SELECT 
        c.id as categoryId,
        c.name as categoryName,
        c.color as categoryColor,
        c.icon as categoryIcon,
        SUM(CAST(t.amount as REAL)) as totalAmount,
        COUNT(t.id) as transactionCount
      FROM transactions t
      LEFT JOIN categories c ON t.categoryId = c.id
      $whereClause
      GROUP BY c.id, c.name, c.color, c.icon
      ORDER BY totalAmount DESC
    ''', whereArgs);
  }

  /// Busca receitas do mês
  static Future<List<Map<String, dynamic>>> getReceitasMes(int ano, int mes) async {
    if (kIsWeb) {
      return await TransactionServiceWeb.getReceitasMes(ano, mes);
    }
    
    final db = await DatabaseService.database;
    if (db == null) return [];
    
    return await db.rawQuery('''
      SELECT 
        date,
        SUM(CAST(amount AS REAL)) as total
      FROM transactions 
      WHERE type = 'income' 
        AND strftime('%Y', datetime(date/1000, 'unixepoch')) = ?
        AND strftime('%m', datetime(date/1000, 'unixepoch')) = ?
      GROUP BY date
      ORDER BY date ASC
    ''', [ano.toString(), mes.toString().padLeft(2, '0')]);
  }

  /// Busca investimentos do mês
  static Future<List<Map<String, dynamic>>> getInvestimentosMes(int ano, int mes) async {
    if (kIsWeb) {
      return await TransactionServiceWeb.getInvestimentosMes(ano, mes);
    }
    
    final db = await DatabaseService.database;
    if (db == null) return [];
    
    return await db.rawQuery('''
      SELECT 
        date,
        SUM(CAST(amount AS REAL)) as total
      FROM transactions 
      WHERE type = 'investment' 
        AND strftime('%Y', datetime(date/1000, 'unixepoch')) = ?
        AND strftime('%m', datetime(date/1000, 'unixepoch')) = ?
      GROUP BY date
      ORDER BY date ASC
    ''', [ano.toString(), mes.toString().padLeft(2, '0')]);
  }
}
