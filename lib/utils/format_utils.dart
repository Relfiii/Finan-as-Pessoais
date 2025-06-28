import 'package:intl/intl.dart';
import 'package:decimal/decimal.dart';

/// Utilitários para formatação de números e datas
class FormatUtils {
  /// Formatador de moeda brasileira
  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  /// Formatador de data brasileiro
  static final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');

  /// Formatador de data e hora brasileiro
  static final DateFormat _dateTimeFormatter = DateFormat('dd/MM/yyyy HH:mm');

  /// Formatador de mês e ano
  static final DateFormat _monthYearFormatter = DateFormat('MMMM yyyy', 'pt_BR');

  /// Formata um valor Decimal como moeda
  static String formatCurrency(Decimal value) {
    return _currencyFormatter.format(value.toDouble());
  }

  /// Formata uma data
  static String formatDate(DateTime date) {
    return _dateFormatter.format(date);
  }

  /// Formata uma data e hora
  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormatter.format(dateTime);
  }

  /// Formata mês e ano
  static String formatMonthYear(DateTime date) {
    return _monthYearFormatter.format(date);
  }

  /// Converte string para Decimal
  static Decimal? parseDecimal(String value) {
    try {
      // Remove formatação de moeda se houver
      final cleanValue = value
          .replaceAll('R\$', '')
          .replaceAll('.', '')
          .replaceAll(',', '.')
          .trim();
      
      return Decimal.parse(cleanValue);
    } catch (e) {
      return null;
    }
  }

  /// Formata número como porcentagem
  static String formatPercentage(double value, {int decimalPlaces = 1}) {
    return '${value.toStringAsFixed(decimalPlaces)}%';
  }

  /// Formata número grande com abreviações (1K, 1M, etc.)
  static String formatCompactNumber(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return value.toStringAsFixed(0);
    }
  }
}
