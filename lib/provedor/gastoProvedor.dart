import 'package:flutter/material.dart';
import '../modelos/gasto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GastoProvider with ChangeNotifier {
  final List<Gasto> _gastos = [];

  List<Gasto> gastosPorCategoria(String categoryId) {
    return _gastos.where((gasto) => gasto.categoriaId == categoryId).toList();
  }

  void addGasto(Gasto gasto) {
    _gastos.add(gasto);
    notifyListeners();
  }

  // Método para deletar gasto
  Future<void> deleteGasto(String gastoId) async {
    try {
      // Remove do Supabase
      await Supabase.instance.client
          .from('gastos')
          .delete()
          .eq('id', gastoId);

      // Remove da lista local
      _gastos.removeWhere((gasto) => gasto.id == gastoId);
      notifyListeners();
    } catch (e) {
      throw Exception('Erro ao deletar gasto: $e');
    }
  }

  double totalPorCategoria(String categoriaId) {
    return _gastos
        .where((g) => g.categoriaId == categoriaId)
        .fold(0.0, (soma, g) => soma + g.valor);
  }

  double totalGastoMes({DateTime? referencia}) {
    final now = referencia ?? DateTime.now();
    return _gastos
        .where((g) => g.data.month == now.month && g.data.year == now.year)
        .fold(0.0, (soma, g) => soma + g.valor);
  }
}