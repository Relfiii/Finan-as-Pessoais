import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'provedor/idioma_provedor.dart';
import 'provedor/transicaoProvedor.dart';
import 'provedor/categoriaProvedor.dart';
import 'provedor/orcamentoProvedor.dart';
import 'widgets/auth_wrapper.dart';
import 'services/database.dart';
import 'provedor/gastoProvedor.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'provedor/usuarioProvedor.dart';
import 'package:flutter/foundation.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await initializeDateFormatting('pt_BR', null);
    
    await Supabase.initialize(
      url: 'https://bfcuvqovxsnjbcpsnjwj.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJmY3V2cW92eHNuamJjcHNuandqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTEzODMzNTcsImV4cCI6MjA2Njk1OTM1N30.3GON-bbY4N11n9PJgMSl28HgiyqpPupYwv-E3Kse2co',
      authOptions: FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
    
    // SQLite só funciona em platforms nativas (não web)
    if (!kIsWeb) {
      await DatabaseService.database;
    }

    // Remove o # das URLs na web
    if (kIsWeb) {
      setPathUrlStrategy();
    }
    
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => TransactionProvider()),
          ChangeNotifierProvider(create: (_) => CategoryProvider()),
          ChangeNotifierProvider(create: (_) => BudgetProvider()),
          ChangeNotifierProvider(create: (_) => GastoProvider()),
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProvider(create: (_) => IdiomaProvedor()),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e) {
    print('Erro durante a inicialização: $e');
    // Em caso de erro, ainda assim inicializa o app com configuração mínima
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => TransactionProvider()),
          ChangeNotifierProvider(create: (_) => CategoryProvider()),
          ChangeNotifierProvider(create: (_) => BudgetProvider()),
          ChangeNotifierProvider(create: (_) => GastoProvider()),
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProvider(create: (_) => IdiomaProvedor()),
        ],
        child: const MyApp(),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final idiomaProvedor = Provider.of<IdiomaProvedor>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NossoDinDin',
      theme: ThemeData.dark(),
      locale: idiomaProvedor.locale,
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('pt', ''), // Portuguese
        Locale('es', ''), // Spanish
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: AuthWrapper(), // Wrapper de autenticação
    );
  }
}