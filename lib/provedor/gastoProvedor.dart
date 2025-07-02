import 'package:flutter/material.dart';
import '../modelos/gasto.dart';

class GastoProvider with ChangeNotifier {
  final List<Gasto> _gastos = [];

  List<Gasto> get gastos => _gastos;

  void addGasto(Gasto gasto) {
    _gastos.add(gasto);
    notifyListeners();
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