import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_theme.dart';
import '../../domain/entities/due.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/gender.dart';
import '../../data/repositories/user_repository.dart';
import '../../domain/usecases/delete_user_usecase.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/permissions_service.dart';

class ViewUserPage extends StatefulWidget {
  final String userId;

  const ViewUserPage({super.key, required this.userId});

  @override
  State<ViewUserPage> createState() => _ViewUserPageState();
}

class _ViewUserPageState extends State<ViewUserPage> {
  late final UserRepository _userRepository;
  late final DeleteUserUseCase _deleteUserUseCase;
  User? _user;
  bool _isLoading = true;
  String? _errorMessage;
  List<String> _userRoles = [];
  bool _canEdit = false;
  bool _isOwnProfile = false;

  @override
  void initState() {
    super.initState();
    _userRepository = UserRepository();
    _deleteUserUseCase = DeleteUserUseCase(_userRepository);
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
        _canEdit = PermissionsService.canEditUser(_userRoles);
        _isOwnProfile = userId.toString() == widget.userId;
      });
    }
  }

  void _handleBack() {
    if (_isOwnProfile) {
      context.go('/settings');
    } else {
      context.go('/users');
    }
  }

  Future<void> _loadUser() async {
    try {
      final user = await _userRepository.getUserById(widget.userId);
      if (!mounted) return;
      setState(() {
        _user = user;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error al cargar usuario';
      });
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _getGenderDisplayName(Gender gender) {
    switch (gender) {
      case Gender.masculino:
        return 'Masculino';
      case Gender.femenino:
        return 'Femenino';
      case Gender.otro:
        return 'Otro';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: context.tokens.background,
        appBar: AppBar(
          backgroundColor: context.tokens.secondaryButton,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Symbols.arrow_back, color: context.tokens.text),
            onPressed: _handleBack,
          ),
          title: Text(
            'Cargando...',
            style: TextStyle(
              color: context.tokens.text,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: context.tokens.background,
        appBar: AppBar(
          backgroundColor: context.tokens.card1,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Symbols.arrow_back, color: context.tokens.text),
            onPressed: _handleBack,
          ),
          title: Text(
            _errorMessage!,
            style: TextStyle(
              color: context.tokens.text,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Symbols.error, size: 64, color: context.tokens.placeholder),
              const SizedBox(height: 16),
              Text(
                'No se pudo cargar el usuario',
                style: TextStyle(
                  color: context.tokens.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_user == null) {
      return Scaffold(
        backgroundColor: context.tokens.background,
        appBar: AppBar(
          backgroundColor: context.tokens.card1,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Symbols.arrow_back, color: context.tokens.text),
            onPressed: _handleBack,
          ),
          title: Text(
            'Usuario no encontrado',
            style: TextStyle(
              color: context.tokens.text,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Symbols.error, size: 64, color: context.tokens.placeholder),
              const SizedBox(height: 16),
              Text(
                'Usuario no encontrado',
                style: TextStyle(
                  color: context.tokens.text,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.tokens.background,
      appBar: AppBar(
        backgroundColor: context.tokens.card1,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Symbols.arrow_back, color: context.tokens.text),
          onPressed: _handleBack,
        ),
        title: Text(
          _user!.nombreCompleto,
          style: TextStyle(
            color: context.tokens.text,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildUserTypeSection(context),
              const SizedBox(height: 24),
              _buildPersonalDataSection(context),
              const SizedBox(height: 24),
              _buildContactDataSection(context),
              const SizedBox(height: 24),
              _buildTeamsSection(context),
              const SizedBox(height: 24),
              // Ocultar acciones rápidas si es jugador solo player viendo su propio perfil
              if (!(_isOwnProfile && PermissionsService.isPlayer(_userRoles)))
                _buildQuickActionsSection(context),
              if (!(_isOwnProfile && PermissionsService.isPlayer(_userRoles)))
                const SizedBox(height: 24),
              _buildActionButtons(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserTypeSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.tokens.card1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.tokens.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Symbols.shield,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Tipo de Usuario y Cuota',
                style: TextStyle(
                  color: context.tokens.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Roles asignados:',
            style: TextStyle(
              color: context.tokens.text,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Column(
            children: _user!.tipos
                .map((tipo) => _buildUserTypeItem(context, tipo))
                .toList(),
          ),
          if (_user!.tipos.contains(UserType.jugador)) ...[
            const SizedBox(height: 16),
            Divider(color: context.tokens.stroke, height: 1),
            const SizedBox(height: 16),
            _buildDueSection(context),
          ],
        ],
      ),
    );
  }

  Widget _buildDueSection(BuildContext context) {
    final currentDue = _user!.currentDue;

    if (currentDue == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estado de cuota:',
            style: TextStyle(
              color: context.tokens.text,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.tokens.card2,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: context.tokens.stroke),
            ),
            child: Text(
              'No hay información de cuota disponible',
              style: TextStyle(color: context.tokens.placeholder, fontSize: 14),
            ),
          ),
        ],
      );
    }

    final dueState = currentDue.state;
    final pay = currentDue.pay;

    Color bgColor;
    Color borderColor;
    Color textColor;
    IconData iconData;
    String statusTitle;
    String statusMessage;

    switch (dueState) {
      case DueState.PAID:
        bgColor = context.tokens.green.withOpacity(0.1);
        borderColor = context.tokens.green;
        textColor = context.tokens.green;
        iconData = Symbols.check_circle;
        statusTitle = 'Cuota pagada';
        statusMessage = 'La cuota está al día';
        break;
      case DueState.OVERDUE:
        bgColor = context.tokens.redToRosita.withOpacity(0.1);
        borderColor = context.tokens.redToRosita;
        textColor = context.tokens.redToRosita;
        iconData = Symbols.error;
        statusTitle = 'Cuota vencida';
        statusMessage = 'La cuota mensual está vencida';
        break;
      case DueState.PENDING:
        if (pay?.state == PayState.REJECTED) {
          bgColor = context.tokens.redToRosita.withOpacity(0.1);
          borderColor = context.tokens.redToRosita;
          textColor = context.tokens.redToRosita;
          iconData = Symbols.cancel;
          statusTitle = 'Pago rechazado';
          statusMessage = 'El comprobante fue rechazado';
        } else {
          bgColor = Colors.amber.withOpacity(0.1);
          borderColor = Colors.amber;
          textColor = Colors.amber.shade700;
          iconData = Symbols.schedule;
          statusTitle = 'Pendiente de pago';
          statusMessage = pay != null
              ? 'Sin pago registrado'
              : 'Sin pago registrado';
        }
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de Usuario y Cuota',
          style: TextStyle(
            color: context.tokens.text,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(iconData, color: textColor, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      statusTitle,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cuota:',
                    style: TextStyle(
                      color: context.tokens.placeholder,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    currentDue.formattedPeriod,
                    style: TextStyle(
                      color: context.tokens.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (pay != null) ...[
                const SizedBox(height: 12),
                Divider(color: borderColor.withOpacity(0.3), height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      pay.state == PayState.REJECTED
                          ? Symbols.cancel
                          : pay.state == PayState.APPROVED
                          ? Symbols.check_circle
                          : Symbols.receipt_long,
                      color: pay.state == PayState.REJECTED
                          ? context.tokens.redToRosita
                          : pay.state == PayState.APPROVED
                          ? Colors.green
                          : textColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      pay.state == PayState.REJECTED
                          ? 'Pago rechazado'
                          : pay.state == PayState.APPROVED
                          ? 'Pago aprobado'
                          : 'Pago en revisión',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Fecha: ${pay.date?.split('-').reversed.join('/') ?? 'N/A'}',
                  style: TextStyle(color: context.tokens.text, fontSize: 13),
                ),
                if (pay.state == PayState.REJECTED) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: context.tokens.redToRosita.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Symbols.warning,
                          color: context.tokens.redToRosita,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Comprobante rechazado - Por favor, volver a cargar',
                            style: TextStyle(
                              color: context.tokens.redToRosita,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],

              const SizedBox(height: 8),
              Text(
                statusMessage,
                style: TextStyle(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalDataSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.tokens.card1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.tokens.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Symbols.person, color: context.tokens.text, size: 20),
              const SizedBox(width: 8),
              Text(
                'Datos Personales',
                style: TextStyle(
                  color: context.tokens.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDataColumn(context, 'Nombre', _user!.nombre),
                    const SizedBox(height: 16),
                    _buildDataColumn(
                      context,
                      'Fecha de nacimiento',
                      _formatDate(_user!.fechaNacimiento),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDataColumn(context, 'DNI', _user!.dni),
                    const SizedBox(height: 16),
                    _buildDataColumn(
                      context,
                      'Género',
                      _getGenderDisplayName(_user!.genero),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactDataSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.tokens.card1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.tokens.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Symbols.mail, color: context.tokens.text, size: 20),
              const SizedBox(width: 8),
              Text(
                'Datos de Contacto',
                style: TextStyle(
                  color: context.tokens.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDataColumn(context, 'Email', _user!.email),
          const SizedBox(height: 16),
          _buildDataColumn(context, 'Celular', _user!.telefono),
        ],
      ),
    );
  }

  Widget _buildTeamsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.tokens.card1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.tokens.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Symbols.groups, color: context.tokens.text, size: 20),
              const SizedBox(width: 8),
              Text(
                'Equipos Asignados',
                style: TextStyle(
                  color: context.tokens.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_user?.equipos.isEmpty ?? true)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No pertenece a ningún equipo',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            )
          else
            Column(
              children: (_user?.equipos ?? [])
                  .map(
                    (team) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildTeamItem(context, team.name),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.tokens.card1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.tokens.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Symbols.bolt, color: context.tokens.text, size: 20),
              const SizedBox(width: 8),
              Text(
                'Acciones Rápidas',
                style: TextStyle(
                  color: context.tokens.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildActionItem(
            context,
            icon: Symbols.credit_card,
            title: 'Ver historial de pagos',
            onTap: () {
              context.push(
                '/users/${widget.userId}/payments?userName=${Uri.encodeComponent('${_user!.nombre} ${_user!.apellido}')}',
              );
            },
          ),
          const SizedBox(height: 8),
          _buildActionItem(
            context,
            icon: Symbols.notifications_active,
            title: 'Enviar notificación',
            onTap: () {
              context.push(
                '/users/${widget.userId}/notification?userName=${Uri.encodeComponent('${_user!.nombre} ${_user!.apellido}')}',
              );
            },
          ),
          const SizedBox(height: 8),
          if (_user?.tipos.contains(UserType.jugador) ?? false)
            _buildActionItem(
              context,
              icon: Symbols.check_circle,
              title: 'Historial de asistencias',
              onTap: () {
                context.push('/users/${widget.userId}/attendance');
              },
            ),
        ],
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            Icon(icon, color: context.tokens.placeholder, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: context.tokens.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Symbols.chevron_right,
              color: context.tokens.placeholder,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserTypeItem(BuildContext context, UserType type) {
    IconData icon;
    switch (type) {
      case UserType.jugador:
        icon = Symbols.sports_volleyball;
        break;
      case UserType.profesor:
        icon = Symbols.school;
        break;
      case UserType.administrador:
        icon = Symbols.admin_panel_settings;
        break;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.tokens.card1,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.tokens.stroke, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: context.tokens.placeholder, size: 20),
          const SizedBox(width: 12),
          Text(
            type.displayName,
            style: TextStyle(
              color: context.tokens.text,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataColumn(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: context.tokens.placeholder,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: context.tokens.text,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTeamItem(BuildContext context, String teamName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: Text(
        teamName,
        style: TextStyle(
          color: context.tokens.text,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (!_canEdit) {
      return const SizedBox.shrink();
    }

    final isPlayerOnly =
        _isOwnProfile && PermissionsService.isPlayer(_userRoles);
    final canDelete = PermissionsService.canDeleteUser(_userRoles);

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              final route = '/users/${widget.userId}/edit';
              print('✏️ Modificar usuario clicked');
              print('🔗 Navegando a: $route');
              print('👤 isOwnProfile: $_isOwnProfile');
              print('🎭 isPlayer: ${PermissionsService.isPlayer(_userRoles)}');
              final result = await context.push(route);
              // Si se editó exitosamente, recargar datos
              if (result == true && mounted) {
                _loadUser();
              }
            },
            icon: const Icon(Symbols.edit, color: Colors.white, size: 18),
            label: const Text(
              'Modificar usuario',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.tokens.secondaryButton,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        // Ocultar botón de eliminar si es jugador solo player viendo su propio perfil o si es profesor
        if (!isPlayerOnly && canDelete) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showDeleteDialog(context),
              icon: const Icon(Symbols.delete, color: Colors.white, size: 18),
              label: const Text(
                'Eliminar usuario',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.tokens.card1,
        title: Text(
          'Confirmar eliminación',
          style: TextStyle(color: context.tokens.text),
        ),
        content: Text(
          '¿Estás seguro de que querés eliminar a ${_user!.nombreCompleto}? Esta acción no se puede deshacer.',
          style: TextStyle(color: context.tokens.text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancelar',
              style: TextStyle(color: context.tokens.text),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Eliminar',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        await _deleteUserUseCase.execute(widget.userId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Usuario eliminado exitosamente'),
              backgroundColor: context.tokens.green,
            ),
          );
          _handleBack();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Error al eliminar usuario'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        }
      }
    }
  }
}
