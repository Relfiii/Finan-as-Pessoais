import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class IdiomaProvedor extends ChangeNotifier {
  Locale _locale = const Locale('pt', 'BR');

  Locale get locale => _locale;

  /// Define o idioma preferido do usuário
  Future<void> loadUserLocale() async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser!.id; // Obtém o ID do usuário logado
      final response = await supabase
          .from('idiomas')
          .select('locale')
          .eq('user_id', userId)
          .single(); // Obtém o idioma preferido do usuário

      if (response['locale'] != null) {
        final localeParts = (response['locale'] as String).split('_');
        _locale = Locale(localeParts[0], localeParts.length > 1 ? localeParts[1] : null);
        notifyListeners();
      }
    } catch (e) {
      // Caso ocorra um erro, mantém o idioma padrão
      debugPrint('Erro ao carregar idioma do usuário: $e');
    }
  }

  void setLocale(Locale locale) {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
  }
}