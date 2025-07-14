import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'telas/telaPrincipal.dart';
import 'cadastroConta.dart';
import 'alterarSenha.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'provedor/transicaoProvedor.dart';
import 'provedor/categoriaProvedor.dart';
import 'provedor/gastoProvedor.dart';
import 'utils/web_diagnostics.dart';

class InteractiveParticlesPainter extends CustomPainter {
  final List<InteractiveParticle> particles;
  
  InteractiveParticlesPainter(this.particles);
  
  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      // Desenha efeito de brilho maior primeiro
      final outerGlowPaint = Paint()
        ..color = particle.color.withOpacity(particle.opacity * 0.15)
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, particle.size * 4);
      
      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size * 4,
        outerGlowPaint,
      );
      
      // Efeito de brilho médio
      final glowPaint = Paint()
        ..color = particle.color.withOpacity(particle.opacity * 0.4)
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, particle.size * 2);
      
      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size * 2,
        glowPaint,
      );
      
      // Círculo principal
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.opacity)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size,
        paint,
      );
      
      // Core brilhante no centro
      final corePaint = Paint()
        ..color = Colors.white.withOpacity(particle.opacity * 0.8)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size * 0.3,
        corePaint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class InteractiveParticle {
  late double x;
  late double y;
  late double baseX;
  late double baseY;
  late double vx;
  late double vy;
  late double size;
  late Color color;
  late double opacity;
  late double angle;
  late double speed;
  late double screenWidth;
  late double screenHeight;
  
  InteractiveParticle({double? screenWidth, double? screenHeight}) {
    this.screenWidth = screenWidth ?? 800;
    this.screenHeight = screenHeight ?? 600;
    reset();
  }
  
  void reset() {
    x = math.Random().nextDouble() * screenWidth;
    y = math.Random().nextDouble() * screenHeight;
    baseX = x;
    baseY = y;
    vx = (math.Random().nextDouble() - 0.5) * 0.5;
    vy = (math.Random().nextDouble() - 0.5) * 0.5;
    size = math.Random().nextDouble() * 4 + 1;
    opacity = math.Random().nextDouble() * 0.6 + 0.1;
    angle = math.Random().nextDouble() * math.pi * 2;
    speed = math.Random().nextDouble() * 0.02 + 0.01;
    
    // Cores variadas para as partículas
    final colors = [
      Color(0xFF00E6D8),
      Color(0xFFB983FF),
      Color(0xFF00B4D8),
      Colors.white,
      Color(0xFF4FC3F7),
      Color(0xFF64B5F6),
      Color(0xFFAB47BC),
    ];
    color = colors[math.Random().nextInt(colors.length)];
  }
  
  void update(Offset mousePosition) {
    // Movimento base das partículas
    baseX += vx;
    baseY += vy;
    
    // Rotação suave
    angle += speed;
    
    // Atração/repulsão ao mouse
    if (mousePosition != Offset.zero) {
      double dx = mousePosition.dx - baseX;
      double dy = mousePosition.dy - baseY;
      double distance = math.sqrt(dx * dx + dy * dy);
      
      if (distance < 120) {
        // Efeito de repulsão próximo ao mouse
        double force = (120 - distance) / 120;
        double angle = math.atan2(dy, dx);
        x = baseX - math.cos(angle) * force * 40;
        y = baseY - math.sin(angle) * force * 40;
        
        // Aumenta a opacidade quando próximo ao mouse
        opacity = math.min(1.0, 0.4 + force * 0.6);
        size = math.min(6.0, size + force * 2);
      } else if (distance < 250) {
        // Efeito de atração suave
        double force = (250 - distance) / 250;
        double angle = math.atan2(dy, dx);
        x = baseX + math.cos(angle) * force * 15;
        y = baseY + math.sin(angle) * force * 15;
        opacity = 0.3 + force * 0.4;
      } else {
        // Retorna à posição base
        x = baseX;
        y = baseY;
        opacity = math.max(0.1, opacity * 0.98);
      }
    } else {
      x = baseX;
      y = baseY;
    }
    
    // Reposiciona partículas que saem da tela
    if (baseX < -50) baseX = screenWidth + 50;
    if (baseX > screenWidth + 50) baseX = -50;
    if (baseY < -50) baseY = screenHeight + 50;
    if (baseY > screenHeight + 50) baseY = -50;
  }
  
  void updateScreenSize(double width, double height) {
    screenWidth = width;
    screenHeight = height;
  }
}

class TelaLogin extends StatefulWidget {
  static const routeName = '/login';
  @override
  _TelaLoginState createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> with TickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  bool loginInvalido = false;
  bool _senhaVisivel = false;
  String? mensagemErro;
  bool _isInitializing = true;
  String _initializationStatus = 'Inicializando aplicativo...';
  
  // Variáveis para animação interativa
  Offset _mousePosition = Offset.zero;
  List<InteractiveParticle> _particles = [];
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _initializeApp();
    _initializeAnimation();
  }
  
  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 16), // ~60 FPS
      vsync: this,
    )..repeat();
    
    _animationController.addListener(() {
      if (mounted) {
        setState(() {
          for (var particle in _particles) {
            particle.update(_mousePosition);
          }
        });
      }
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _initializeApp() async {
    try {
      setState(() {
        _initializationStatus = 'Executando diagnósticos...';
      });
      
      // Executa diagnósticos
      final diagnostics = await WebDiagnostics.runDiagnostics();
      WebDiagnostics.printDiagnostics(diagnostics);
      
      setState(() {
        _initializationStatus = 'Verificando conectividade...';
      });
      
      // Verifica se o Supabase está funcionando
      final supabase = Supabase.instance.client;
      await supabase.from('usuarios').select('id').limit(1);
      
      setState(() {
        _initializationStatus = 'Conectado com sucesso!';
      });
      
      // Aguarda um pouco para mostrar a mensagem
      await Future.delayed(Duration(milliseconds: 500));
      
      setState(() {
        _isInitializing = false;
      });
    } catch (e) {
      print('Erro na inicialização: $e');
      setState(() {
        _initializationStatus = 'Erro de conectividade. Tentando novamente...';
      });
      
      // Tenta novamente após 2 segundos
      await Future.delayed(Duration(seconds: 2));
      _initializeApp();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Cria/atualiza partículas baseado no tamanho da tela
    if (_particles.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final size = MediaQuery.of(context).size;
        final particleCount = ((size.width * size.height) / 8000).round().clamp(100, 300);
        
        setState(() {
          _particles = List.generate(particleCount, (index) => 
            InteractiveParticle(screenWidth: size.width, screenHeight: size.height));
        });
      });
    } else {
      // Atualiza o tamanho da tela para partículas existentes
      final size = MediaQuery.of(context).size;
      for (var particle in _particles) {
        particle.updateScreenSize(size.width, size.height);
      }
    }
    
    if (_isInitializing) {
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
          child: Stack(
            children: [
              // Efeito de partículas/estrelas
              ...List.generate(50, (index) => Positioned(
                left: (index * 37) % MediaQuery.of(context).size.width,
                top: (index * 43) % MediaQuery.of(context).size.height,
                child: Container(
                  width: 2,
                  height: 2,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                ),
              )),
              Center(
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
                      _initializationStatus,
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
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: MouseRegion(
        onHover: (event) {
          setState(() {
            _mousePosition = event.localPosition;
          });
        },
        onExit: (_) {
          setState(() {
            _mousePosition = Offset.zero;
          });
        },
        child: GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              _mousePosition = details.localPosition;
            });
          },
          onPanEnd: (_) {
            setState(() {
              _mousePosition = Offset.zero;
            });
          },
          child: Container(
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
            child: Stack(
              children: [
                // Partículas interativas
                CustomPaint(
                  painter: InteractiveParticlesPainter(_particles),
                  size: Size.infinite,
                ),
                // Efeito de brilho circular
                Positioned(
                  top: -100,
                  right: -100,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          Color(0xFF00E6D8).withOpacity(0.1),
                          Colors.transparent,
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -150,
                  left: -150,
                  child: Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          Color(0xFFB983FF).withOpacity(0.08),
                          Colors.transparent,
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            SafeArea(
              child: Column(
                children: [
                  // Header modernizado
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 30,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF00E6D8), Color(0xFFB983FF)],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Entrar',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 28,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Spacer(),
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: [
                              // Logo com efeito
                              Container(
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF00E6D8).withOpacity(0.1),
                                      Color(0xFFB983FF).withOpacity(0.1),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.1),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFF00E6D8).withOpacity(0.2),
                                      blurRadius: 30,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  'assets/logo-NossoDinDin.png',
                                  width: 100,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 40),
                              // Card principal com glassmorphism
                              Container(
                                padding: const EdgeInsets.all(32),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white.withOpacity(0.05),
                                      Colors.white.withOpacity(0.02),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.1),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: Offset(0, 10),
                                    ),
                                  ],
                                ),
                                constraints: BoxConstraints(
                                  maxWidth: 400,
                                  minWidth: 280,
                                ),
                                width: MediaQuery.of(context).size.width > 400 ? 400 : MediaQuery.of(context).size.width * 0.9,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Campo Email modernizado
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'E-mail',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.8),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: Colors.white.withOpacity(0.1),
                                              width: 1,
                                            ),
                                            gradient: LinearGradient(
                                              colors: [
                                                Color(0xFF1A202C).withOpacity(0.8),
                                                Color(0xFF2D3748).withOpacity(0.8),
                                              ],
                                            ),
                                          ),
                                          child: TextField(
                                            controller: emailController,
                                            decoration: InputDecoration(
                                              hintText: 'Digite seu e-mail',
                                              hintStyle: TextStyle(color: Colors.grey[500]),
                                              border: InputBorder.none,
                                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                              prefixIcon: Icon(
                                                Icons.email_outlined,
                                                color: Color(0xFF00E6D8),
                                                size: 20,
                                              ),
                                            ),
                                            style: const TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    // Campo Senha modernizado
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Senha',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.8),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: Colors.white.withOpacity(0.1),
                                              width: 1,
                                            ),
                                            gradient: LinearGradient(
                                              colors: [
                                                Color(0xFF1A202C).withOpacity(0.8),
                                                Color(0xFF2D3748).withOpacity(0.8),
                                              ],
                                            ),
                                          ),
                                          child: TextField(
                                            controller: senhaController,
                                            obscureText: !_senhaVisivel,
                                            decoration: InputDecoration(
                                              hintText: 'Digite sua senha',
                                              hintStyle: TextStyle(color: Colors.grey[500]),
                                              border: InputBorder.none,
                                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                              prefixIcon: Icon(
                                                Icons.lock_outline,
                                                color: Color(0xFF00E6D8),
                                                size: 20,
                                              ),
                                              suffixIcon: IconButton(
                                                icon: Icon(
                                                  _senhaVisivel ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                                  color: Colors.grey[400],
                                                  size: 20,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _senhaVisivel = !_senhaVisivel;
                                                  });
                                                },
                                              ),
                                            ),
                                            style: const TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Mensagem de erro
                                    if (mensagemErro != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 12.0),
                                        child: Container(
                                          padding: EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: mensagemErro!.contains('Fazendo login') || 
                                                   mensagemErro!.contains('Login realizado') ||
                                                   mensagemErro!.contains('Carregando') 
                                                ? Color(0xFF00E6D8).withOpacity(0.1)
                                                : Colors.red.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: mensagemErro!.contains('Fazendo login') || 
                                                     mensagemErro!.contains('Login realizado') ||
                                                     mensagemErro!.contains('Carregando')
                                                  ? Color(0xFF00E6D8)
                                                  : Colors.red,
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                mensagemErro!.contains('Fazendo login') || 
                                                mensagemErro!.contains('Login realizado') ||
                                                mensagemErro!.contains('Carregando')
                                                    ? Icons.info_outline
                                                    : Icons.error_outline,
                                                color: mensagemErro!.contains('Fazendo login') || 
                                                       mensagemErro!.contains('Login realizado') ||
                                                       mensagemErro!.contains('Carregando')
                                                    ? Color(0xFF00E6D8)
                                                    : Colors.red,
                                                size: 16,
                                              ),
                                              SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  mensagemErro!,
                                                  style: TextStyle(
                                                    color: mensagemErro!.contains('Fazendo login') || 
                                                           mensagemErro!.contains('Login realizado') ||
                                                           mensagemErro!.contains('Carregando')
                                                        ? Color(0xFF00E6D8)
                                                        : Colors.red,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 32),
                                    // Botão Entrar modernizado
                                    Container(
                                      width: double.infinity,
                                      height: 52,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [Color(0xFF00E6D8), Color(0xFF00B4D8)],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(0xFF00E6D8).withOpacity(0.3),
                                            blurRadius: 15,
                                            offset: Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          foregroundColor: Colors.black,
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        onPressed: () async {
                                          setState(() {
                                            loginInvalido = false;
                                            mensagemErro = null;
                                          });
                                          final supabase = Supabase.instance.client;
                                          final email = emailController.text.trim();

                                          if (email.isEmpty || senhaController.text.isEmpty) {
                                            setState(() {
                                              mensagemErro = 'Por favor, preencha todos os campos.';
                                              loginInvalido = true;
                                            });
                                            return;
                                          }

                                          try {
                                            setState(() {
                                              mensagemErro = 'Fazendo login...';
                                            });
                                            
                                            final response = await supabase.auth.signInWithPassword(
                                              email: email,
                                              password: senhaController.text,
                                            );
                                            
                                            if (response.user != null) {
                                              setState(() {
                                                mensagemErro = 'Login realizado! Carregando dados...';
                                              });
                                              
                                              // Adiciona ou atualiza o usuário na tabela 'usuarios'
                                              final user = response.user;
                                              if (user != null) {
                                                String? nome;
                                                try {
                                                  final userData = user.userMetadata;
                                                  if (userData != null && userData['nome'] != null) {
                                                    nome = userData['nome'] as String?;
                                                  }
                                                } catch (_) {}
                                                await supabase.from('usuarios').upsert({
                                                  'id': user.id,
                                                  'email': user.email,
                                                  if (nome != null) 'nome': nome,
                                                });
                                              }
                                              
                                              // Carrega dados com timeout
                                              try {
                                                setState(() {
                                                  mensagemErro = 'Carregando transações...';
                                                });
                                                await context.read<TransactionProvider>().loadTransactions().timeout(Duration(seconds: 10));
                                                
                                                setState(() {
                                                  mensagemErro = 'Carregando categorias...';
                                                });
                                                await context.read<CategoryProvider>().loadCategories().timeout(Duration(seconds: 10));
                                                
                                                setState(() {
                                                  mensagemErro = 'Carregando gastos...';
                                                });
                                                await context.read<GastoProvider>().loadGastos().timeout(Duration(seconds: 10));

                                                Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => HomeScreen()),
                                                );
                                              } catch (timeoutError) {
                                                print('Erro de timeout ao carregar dados: $timeoutError');
                                                // Mesmo com erro no carregamento, permite entrar no app
                                                Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => HomeScreen()),
                                                );
                                              }
                                            } else {
                                              setState(() {
                                                mensagemErro = 'E-mail ou senha inválidos.';
                                                loginInvalido = true;
                                              });
                                            }
                                          } on AuthException catch (e) {
                                            String mensagem = e.message;
                                            if (mensagem.contains('Invalid login credentials')) {
                                              mensagem = 'E-mail ou senha inválidos.';
                                            } else if (mensagem.contains('Email not confirmed')) {
                                              mensagem = 'Confirme seu e-mail antes de entrar.';
                                            } else if (mensagem.contains('User already registered')) {
                                              mensagem = 'Usuário já cadastrado.';
                                            } else if (mensagem.contains('Password should be at least')) {
                                              mensagem = 'A senha deve ter pelo menos 6 caracteres.';
                                            } else if (mensagem.contains('User not found')) {
                                              mensagem = 'Usuário não encontrado.';
                                            } else if (mensagem.contains('Network error')) {
                                              mensagem = 'Erro de conexão. Verifique sua internet.';
                                            } else {
                                              mensagem = 'Erro: ' + mensagem;
                                            }
                                            setState(() {
                                              mensagemErro = mensagem;
                                              loginInvalido = true;
                                            });
                                          } catch (e) {
                                            setState(() {
                                              mensagemErro = 'Erro ao tentar login.';
                                              loginInvalido = true;
                                            });
                                          }
                                        },
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.login, size: 20),
                                            SizedBox(width: 8),
                                            Text(
                                              'Entrar',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    // Botão Cadastrar modernizado
                                    Container(
                                      width: double.infinity,
                                      height: 52,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.2),
                                          width: 1,
                                        ),
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.white.withOpacity(0.05),
                                            Colors.white.withOpacity(0.02),
                                          ],
                                        ),
                                      ),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          foregroundColor: Colors.white,
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        onPressed: () {
                                          WidgetsBinding.instance.addPostFrameCallback((_) {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => CadastroContaScreen(),
                                              ),
                                            );
                                          });
                                        },
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.person_add_outlined, size: 20),
                                            SizedBox(width: 8),
                                            Text(
                                              'Cadastrar conta',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    // Link Esqueci a senha
                                    Center(
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => AlterarSenhaPage(),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(20),
                                            color: Color(0xFFB983FF).withOpacity(0.1),
                                          ),
                                          child: Text(
                                            'Esqueceu a senha?',
                                            style: TextStyle(
                                              color: Color(0xFFB983FF),
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Footer modernizado
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.02),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Color(0xFF00E6D8),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'NossoDinDin v1.0',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 1.1,
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Color(0xFFB983FF),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
        ),
        ),
      ),
    );
  }
}
