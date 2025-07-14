import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Utilitário para detectar problemas de conectividade e configuração na web
class WebDiagnostics {
  static Future<Map<String, dynamic>> runDiagnostics() async {
    final results = <String, dynamic>{};
    
    try {
      // 1. Verifica se está rodando na web
      results['isWeb'] = kIsWeb;
      results['platform'] = kIsWeb ? 'web' : 'native';
      
      // 2. Verifica conectividade básica
      results['hasNavigator'] = kIsWeb ? true : false;
      
      // 3. Verifica inicialização do Supabase
      try {
        final supabase = Supabase.instance.client;
        results['supabaseInitialized'] = true;
        
        // 4. Testa conexão básica com Supabase
        await supabase
            .from('usuarios')
            .select('id')
            .limit(1)
            .timeout(Duration(seconds: 5));
        
        results['supabaseConnectable'] = true;
        results['supabaseResponse'] = 'success';
      } catch (supabaseError) {
        results['supabaseConnectable'] = false;
        results['supabaseError'] = supabaseError.toString();
      }
      
      // 5. Verifica usuário autenticado
      try {
        final user = Supabase.instance.client.auth.currentUser;
        results['userAuthenticated'] = user != null;
        if (user != null) {
          results['userId'] = user.id;
          results['userEmail'] = user.email;
        }
      } catch (authError) {
        results['userAuthenticated'] = false;
        results['authError'] = authError.toString();
      }
      
      // 6. Informações do navegador (apenas na web)
      if (kIsWeb) {
        results['userAgent'] = 'N/A'; // Seria necessário usar dart:html
        results['currentUrl'] = Uri.base.toString();
      }
      
    } catch (e) {
      results['diagnosticError'] = e.toString();
    }
    
    return results;
  }
  
  static void printDiagnostics(Map<String, dynamic> results) {
    print('🔍 === DIAGNÓSTICO WEB ===');
    results.forEach((key, value) {
      print('$key: $value');
    });
    print('🔍 === FIM DIAGNÓSTICO ===');
  }
  
  static String formatDiagnosticsForUser(Map<String, dynamic> results) {
    final buffer = StringBuffer();
    
    if (results['isWeb'] == true) {
      buffer.writeln('Executando na web');
    }
    
    if (results['supabaseConnectable'] == false) {
      buffer.writeln('❌ Problema de conectividade com servidor');
      if (results['supabaseError'] != null) {
        buffer.writeln('Erro: ${results['supabaseError']}');
      }
    } else {
      buffer.writeln('✅ Servidor conectado');
    }
    
    if (results['userAuthenticated'] == false) {
      buffer.writeln('❌ Usuário não autenticado');
    } else {
      buffer.writeln('✅ Usuário autenticado');
    }
    
    return buffer.toString();
  }
}
