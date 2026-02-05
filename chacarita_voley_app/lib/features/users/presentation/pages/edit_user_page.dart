import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/permissions_service.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/update_user_usecase.dart';
import '../../data/repositories/user_repository.dart';
import '../widgets/user_form_widget.dart';
import '../widgets/player_profile_form_widget.dart';

class EditUserPage extends StatefulWidget {
  final String userId;
  final String? from;

  const EditUserPage({super.key, required this.userId, this.from});

  @override
  State<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  late final UpdateUserUseCase _updateUserUseCase;
  late final UserRepository _userRepository;
  User? _user;
  bool _isLoading = false;
  bool _isLoadingUser = true;
  String? _loadError;
  List<String> _userRoles = [];
  int? _currentUserId;
  bool _isOwnProfile = false;

  void _handleBack() {
    // Volver a view con el mismo parámetro from y refresh=true
    final fromParam = widget.from != null ? 'from=${widget.from}&' : '';
    context.go('/users/${widget.userId}/view?${fromParam}refresh=true');
  }

  @override
  void initState() {
    super.initState();
    _userRepository = UserRepository();
    _updateUserUseCase = UpdateUserUseCase(_userRepository);
    _loadUserRoles();
    _loadUser();
  }

  Future<void> _loadUserRoles() async {
    final authService = AuthService();
    final roles = await authService.getUserRoles();
    final userId = await authService.getUserId();
    if (mounted) {
      setState(() {
        _userRoles = roles ?? [];
        _currentUserId = userId;
        _isOwnProfile = userId.toString() == widget.userId;
      });
    }
  }

  Future<void> _loadUser() async {
    try {
      final user = await _userRepository.getUserById(widget.userId);
      if (!mounted) return;
      setState(() {
        _user = user;
        _isLoadingUser = false;
        _loadError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _user = null;
        _isLoadingUser = false;
        _loadError = 'Error al cargar usuario';
      });
    }
  }

  Future<bool> _handleUpdateUser(User user) async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('\u2699\ufe0f Ejecutando actualización de usuario...');
      await _updateUserUseCase.execute(user);
      print('\u2705 Usuario actualizado exitosamente');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Usuario ${user.nombreCompleto} actualizado exitosamente',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: context.tokens.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            duration: const Duration(seconds: 3),
          ),
        );

        _handleBack();
      }
      return true;
    } catch (e) {
      print('\u274c Error al actualizar usuario:');
      print('  Tipo de error: ${e.runtimeType}');
      print('  Mensaje: $e');
      print('  Stack trace:');
      print(StackTrace.current);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Error al actualizar usuario',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return false; // Error
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.tokens.background,
      appBar: AppBar(
        backgroundColor: context.tokens.card2,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Symbols.arrow_back, color: context.tokens.text),
          onPressed: _handleBack,
        ),
        title: Text(
          'Modificar Usuario',
          style: TextStyle(
            color: context.tokens.text,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoadingUser
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              )
            : _loadError != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Symbols.error,
                      size: 64,
                      color: context.tokens.placeholder,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _loadError!,
                      style: TextStyle(
                        color: context.tokens.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      child: const Text(
                        'Volver a la lista',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              )
            : _user == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Symbols.error,
                      size: 64,
                      color: context.tokens.placeholder,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Usuario no encontrado',
                      style: TextStyle(
                        color: context.tokens.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      child: const Text(
                        'Volver a la lista',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              )
            : _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child:
                    (_isOwnProfile && PermissionsService.isPlayer(_userRoles))
                    ? PlayerProfileFormWidget(
                        initialUser: _user!,
                        onSave: _handleUpdateUser,
                      )
                    : UserFormWidget(
                        initialUser: _user,
                        onSave: _handleUpdateUser,
                        submitButtonText: 'Guardar cambios',
                        currentUserRoles: _userRoles,
                      ),
              ),
      ),
    );
  }
}
