import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../telaLogin.dart';
import '../telas/telaPrincipal.dart';
import '../provedor/transicaoProvedor.dart';
import '../provedor/categoriaProvedor.dart';
import '../provedor/gastoProvedor.dart';

class AuthWrapper extends StatefulWidget {
  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
    _setupAuthStateListener();
  }

  void _setupAuthStateListener() {
    final supabase = Supabase.instance.client;
    supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (mounted) {
        setState(() {
          _isInitialized = session != null;
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _checkAuthState() async {
    try {
      final supabase = Supabase.instance.client;
      
      // Verifica se há uma sessão ativa
      final session = supabase.auth.currentSession;
      
      if (session != null) {
        // Usuário está logado, carrega os dados
        await _loadUserData();
        setState(() {
          _isInitialized = true;
          _isLoading = false;
        });
      } else {
        // Não há sessão ativa
        setState(() {
          _isInitialized = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Erro ao verificar estado de autenticação: $e');
      setState(() {
        _isInitialized = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserData() async {
    try {
      // Carrega os dados do usuário em paralelo com timeout
      await Future.wait([
        context.read<TransactionProvider>().loadTransactions().timeout(Duration(seconds: 15)),
        context.read<CategoryProvider>().loadCategories().timeout(Duration(seconds: 15)),
        context.read<GastoProvider>().loadGastos().timeout(Duration(seconds: 15)),
      ]);
    } catch (e) {
      print('Erro ao carregar dados do usuário: $e');
      // Mesmo com erro, permite entrar no app
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0D1B2A),
                Color(0xFF1B263B), 
                Color(0xFF2D3748),
                Color(0xFF1A202C)
              ],
              stops: [0.0, 0.3, 0.7, 1.0],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF00E6D8), Color(0xFF00B4D8)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF00E6D8).withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 3,
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  'Verificando sessão...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Se o usuário está autenticado, vai para a tela principal
    // Caso contrário, vai para a tela de login
    return _isInitialized ? HomeScreen() : TelaLogin();
  }
}
