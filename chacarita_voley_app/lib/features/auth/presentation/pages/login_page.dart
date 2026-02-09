import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/network/graphql_client_factory.dart';
import '../../../../core/services/firebase_messaging_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _rememberMe = true;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        elevation: 6,
      ),
    );
  }

  Future<void> _handleLogin() async {
    // Validar email
    final email = _usernameController.text.trim();
    if (email.isEmpty) {
      _showErrorSnackBar('El email es obligatorio');
      return;
    }

    if (!email.contains('@')) {
      _showErrorSnackBar('Ingresa un email válido');
      return;
    }

    // Validar contraseña
    final password = _passwordController.text;
    if (password.isEmpty) {
      _showErrorSnackBar('La contraseña es obligatoria');
      return;
    }

    if (password.length < 3) {
      _showErrorSnackBar('La contraseña debe tener al menos 3 caracteres');
      return;
    }

    setState(() => _isLoading = true);

    try {
      debugPrint('📡 Login request: /api/auth/login');
      final response = await _authService.login(
        email: _usernameController.text.trim(),
        password: _passwordController.text,
        rememberMe: _rememberMe,
      );

      // Obtener información del usuario
      debugPrint('📡 Login request: /api/auth/me');
      final user = await _authService.getCurrentUser();
      if (user != null) {
      } else {
        print('⚠️ No se pudo obtener la información del usuario');
      }

      // Login exitoso, intentar actualizar el token
      try {
        GraphQLClientFactory.updateToken(response.accessToken);
      } catch (e) {
        // Si falla actualizar el token, solo logueamos pero seguimos
        print('⚠️ Error actualizando token en GraphQL: $e');
      }

      debugPrint('📡 Login request: registerDevice');
      await FirebaseMessagingService().registerDeviceForLogin();

      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      // Determinar tipo de error
      String errorMessage = 'Error al iniciar sesión';

      final errorString = e.toString();
      if (errorString.contains('401') ||
          errorString.contains('403') ||
          errorString.contains('autenticación')) {
        errorMessage = 'Email o contraseña incorrectos';
      } else if (errorString.contains('Timeout') ||
          errorString.contains('timeout')) {
        errorMessage = 'Tiempo de espera agotado. Verifica tu conexión';
      } else if (errorString.contains('SocketException') ||
          errorString.contains('network')) {
        errorMessage = 'Error de conexión. Verifica tu red';
      }

      if (mounted) {
        _showErrorSnackBar(errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF121212) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final textColorSecondary = isDark ? Colors.white70 : Colors.black87;
    final borderColor = isDark ? Colors.white54 : Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              bottom: false,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: Image.asset(
                              'assets/images/chacarita_logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Iniciar sesión',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Accedé a tu cuenta',
                            style: TextStyle(
                              fontSize: 15,
                              color: textColorSecondary,
                            ),
                          ),
                          const SizedBox(height: 40),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nombre de usuario',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _usernameController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: backgroundColor,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: borderColor,
                                      width: 1,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: borderColor,
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: borderColor,
                                      width: 1.5,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 14,
                                  ),
                                ),
                                style: TextStyle(
                                  fontSize: 15,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Contraseña',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: backgroundColor,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: borderColor,
                                      width: 1,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: borderColor,
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: borderColor,
                                      width: 1.5,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 14,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: isDark
                                          ? Colors.white54
                                          : Colors.black54,
                                      size: 22,
                                    ),
                                    onPressed: () => setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    ),
                                  ),
                                ),
                                style: TextStyle(
                                  fontSize: 15,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: Checkbox(
                                        value: _rememberMe,
                                        onChanged: (value) => setState(
                                          () => _rememberMe = value ?? false,
                                        ),
                                        activeColor: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            3,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Recordarme',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: textColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    context.push('/forgot-password'),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  '¿Olvidaste tu contraseña?',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                disabledBackgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Iniciar sesión',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 13,
                      color: textColorSecondary,
                      height: 1.4,
                    ),
                    children: [
                      const TextSpan(
                        text:
                            'Solo miembros del club con usuario activo pueden ingresar.\n',
                      ),
                      const TextSpan(text: '¿No tenés usuario? '),
                      TextSpan(
                        text: 'Consultá con la administración',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          decoration: TextDecoration.underline,
                          decorationColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                        ),
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
