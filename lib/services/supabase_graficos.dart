import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class SupabaseGraficosService {
  static final _client = Supabase.instance.client;

  static Future<List<Map<String, dynamic>>> getEntradasPorPeriodo(String periodo) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];
    final res = await _client.rpc('entradas_por_periodo', params: {
      'periodo': periodo
    });
    if (res is List) {
      return List<Map<String, dynamic>>.from(res);
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> getGastosPorPeriodo(String periodo) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];
    final res = await _client.rpc('total_gastos_por_periodo', params: {
      'periodo': periodo
    });
    if (res is List) {
      return List<Map<String, dynamic>>.from(res);
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> getInvestimentosPorPeriodo(String periodo) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];
    String dateCol = 'data';
    final List res = await _client.from('investimentos')
      .select('valor, $dateCol')
      .eq('user_id', userId);
    final Map<String, double> totals = {};
    for (final item in res) {
      final dt = DateTime.parse(item[dateCol]);
      String label;
      if (periodo == 'Semana') {
        final week = int.parse(DateFormat('w').format(dt));
        label = '${week.toString().padLeft(2, '0')}/${dt.year}';
      } else if (periodo == 'Mês') {
        label = DateFormat('MM/yyyy').format(dt);
      } else {
        label = DateFormat('yyyy').format(dt);
      }
      totals[label] = (totals[label] ?? 0) + (item['valor'] as num).toDouble();
    }
    return totals.entries.map((e) => {'label': e.key, 'total': e.value}).toList();
  }

  static Future<List<Map<String, dynamic>>> getGastosPorAno(int ano) async {
    final response = await _client
        .from('sua_tabela_gastos')
        .select('data, total')
        .gte('data', '$ano-01-01')
        .lte('data', '$ano-12-31');
    // Agrupe por mês e monte o label no formato yyyy/MM
    final Map<String, double> agrupado = {};
    for (var item in response) {
      final data = DateTime.parse(item['data']);
      final label = '${data.year}/${data.month.toString().padLeft(2, '0')}';
      agrupado[label] = (agrupado[label] ?? 0) + (item['total'] as num).toDouble();
    }
    return agrupado.entries
        .map((e) => {'label': e.key, 'total': e.value})
        .toList();
  }

  static Future<List<Map<String, dynamic>>> getEntradasPorAno(int ano) async {
    // Repita a lógica acima para entradas
    // ...
    return [];
  }

  static Future<List<Map<String, dynamic>>> getInvestimentosPorAno(int ano) async {
    // Repita a lógica acima para investimentos
    // ...
    return [];
  }

  static Future<List<Map<String, dynamic>>> getGastosPorMes(int ano, int mes) async {
    final inicio = DateTime(ano, mes, 1);
    final fim = DateTime(ano, mes + 1, 0);
    final response = await _client
        .from('sua_tabela_gastos')
        .select('data, total')
        .gte('data', inicio.toIso8601String())
        .lte('data', fim.toIso8601String());
    // Agrupe por dia e monte o label no formato yyyy/MM/dd
    final Map<String, double> agrupado = {};
    for (var item in response) {
      final data = DateTime.parse(item['data']);
      final label =
          '${data.year}/${data.month.toString().padLeft(2, '0')}/${data.day.toString().padLeft(2, '0')}';
      agrupado[label] = (agrupado[label] ?? 0) + (item['total'] as num).toDouble();
    }
    return agrupado.entries
        .map((e) => {'label': e.key, 'total': e.value})
        .toList();
  }

  static Future<List<Map<String, dynamic>>> getEntradasPorMes(int ano, int mes) async {
    // Repita a lógica acima para entradas
    // ...
    return [];
  }

  static Future<List<Map<String, dynamic>>> getInvestimentosPorMes(int ano, int mes) async {
    // Repita a lógica acima para investimentos
    // ...
    return [];
  }
}
