import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../../app/theme/app_theme.dart';
import '../../domain/entities/team.dart';
import '../../domain/entities/team_type.dart';
import '../../data/repositories/team_repository.dart';
import '../../../users/data/repositories/user_repository.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/permissions_service.dart';
import 'package:chacarita_voley_app/core/errors/backend_error_mapper.dart';

enum _MemberMenuAction {
  viewUser,
  editUser,
  viewCompetitiveData,
  editCompetitiveData,
}

class ViewTeamPage extends StatefulWidget {
  final String teamId;
  final TeamRepository? repository;
  final UserRepository? userRepository;
  final AuthService? authService;

  const ViewTeamPage({
    super.key,
    required this.teamId,
    this.repository,
    this.userRepository,
    this.authService,
  });

  @override
  State<ViewTeamPage> createState() => _ViewTeamPageState();
}

class _ViewTeamPageState extends State<ViewTeamPage> {
  late final TeamRepository _repository;
  late final UserRepository _userRepository;
  late final AuthService _authService;
  Team? _team;
  bool _isLoading = true;
  List<String> _userRoles = [];
  bool _canEdit = false;
  bool _canEditUser = false;
  bool _canDelete = false;
  bool _canRestore = false;
  bool _isRestoring = false;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? TeamRepository();
    _userRepository = widget.userRepository ?? UserRepository();
    _authService = widget.authService ?? AuthService();
    _loadUserRoles();
    _loadTeam();
  }

  Future<void> _loadUserRoles() async {
    final roles = await _authService.getUserRoles();
    if (mounted) {
      setState(() {
        _userRoles = roles ?? [];
        _canEdit = PermissionsService.canEditTeam(_userRoles);
        _canEditUser = PermissionsService.canEditUser(_userRoles);
        _canDelete = PermissionsService.canDeleteTeam(_userRoles);
        _canRestore = PermissionsService.canRestoreTeam(_userRoles);
      });
    }
  }

  String _resolveUserIdForMember(TeamMember member) {
    return member.personId ?? member.playerId ?? member.dni;
  }

  void _showCompetitiveDataDialog(TeamMember member) {
    showDialog<void>(
      context: context,
      useRootNavigator: true,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Datos del Jugador Competitivo',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          content: SizedBox(
            width: 350,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.tokens.card1,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.tokens.stroke),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Symbols.badge, size: 24, color: context.tokens.text),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Número de afiliado',
                            style: TextStyle(
                              color: context.tokens.text,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            member.numeroAfiliado ?? 'No asignado',
                            style: TextStyle(
                              color: context.tokens.text,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Symbols.apparel,
                        size: 24,
                        color: context.tokens.text,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Camiseta',
                            style: TextStyle(
                              color: context.tokens.text,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            member.numeroCamiseta ?? 'No asignado',
                            style: TextStyle(
                              color: context.tokens.text,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: context.tokens.text,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cerrar',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                final memberIndex = _team!.integrantes.indexOf(member);
                _showEditCompetitiveDataDialog(
                  memberIndex: memberIndex,
                  member: member,
                );
              },
              child: const Text(
                'Modificar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEditCompetitiveDataDialog({
    required int memberIndex,
    required TeamMember member,
  }) {
    final afiliadoController = TextEditingController(
      text: member.numeroAfiliado ?? '',
    );
    final camisetaController = TextEditingController(
      text: member.numeroCamiseta ?? '',
    );

    showDialog<void>(
      context: context,
      useRootNavigator: true,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Modificar Datos Competitivos',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          content: SizedBox(
            width: 350,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Número de afiliado',
                    style: TextStyle(
                      color: context.tokens.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: afiliadoController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Ingrese el número de afiliado',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: context.tokens.stroke),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: context.tokens.stroke),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Ingrese el número de camiseta',
                    style: TextStyle(
                      color: context.tokens.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    key: const Key('competitive-jersey-number-field'),
                    controller: camisetaController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Número de camiseta',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: context.tokens.stroke),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: context.tokens.stroke),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: context.tokens.text,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
            FilledButton(
              key: const Key('competitive-save-button'),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              onPressed: () async {
                final afiliadoValue = afiliadoController.text.trim();
                final camisetaValue = camisetaController.text.trim();

                if (member.personId != null) {
                  try {
                    final Map<String, dynamic> updates = {};

                    if (afiliadoValue.isNotEmpty) {
                      updates['leagueId'] = int.tryParse(afiliadoValue) ?? 0;
                    }

                    if (camisetaValue.isNotEmpty) {
                      updates['jerseyNumber'] =
                          int.tryParse(camisetaValue) ?? 0;
                    }

                    if (updates.isNotEmpty) {
                      await _userRepository.updatePerson(
                        member.personId!,
                        updates,
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'No se pudieron actualizar los datos: ${BackendErrorMapper.fromException(e)}',
                          ),
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                        ),
                      );
                    }
                    return;
                  }
                }

                final updated = member.copyWith(
                  numeroAfiliado: afiliadoValue.isEmpty ? null : afiliadoValue,
                  numeroCamiseta: camisetaValue.isEmpty ? null : camisetaValue,
                );

                setState(() {
                  final updatedMembers = List<TeamMember>.from(
                    _team!.integrantes,
                  );
                  updatedMembers[memberIndex] = updated;
                  _team = _team!.copyWith(integrantes: updatedMembers);
                });

                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Datos competitivos actualizados'),
                      backgroundColor: context.tokens.green,
                    ),
                  );
                }
              },
              child: const Text(
                'Confirmar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadTeam() async {
    try {
      final team = await _repository.getTeamById(widget.teamId);
      final filteredMembers = team == null
          ? <TeamMember>[]
          : await _getCurrentActiveMembers(team.integrantes);
      if (mounted) {
        setState(() {
          _team = team?.copyWith(integrantes: filteredMembers);
          _isLoading = false;
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print('❌ ViewTeamPage: Error cargando equipo: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<List<TeamMember>> _getCurrentActiveMembers(
    List<TeamMember> members,
  ) async {
    if (members.isEmpty) return const [];

    final activeUsers = await _userRepository.getUsersForNotifications(
      includeDeleted: false,
    );
    final activePersonIds = activeUsers
        .map((user) => user.id)
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toSet();

    return members.where((member) {
      final personId = member.personId;
      if (personId == null || personId.isEmpty) return false;
      return activePersonIds.contains(personId);
    }).toList();
  }

  Future<void> _handleDeleteTeam() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _DeleteTeamDialog(
        teamName: _team!.nombre,
        onDelete: () async {
          await _repository.deleteTeam(widget.teamId);
        },
      ),
    );

    if (confirmed == true && mounted) {
      context.go('/teams');
      // Delay para liberar socket HTTP
      await Future.delayed(const Duration(milliseconds: 200));
      // Mostrar snackbar después de navegar
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 100), () {
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
                        '${_team!.nombre} fue eliminado exitosamente',
                        style: const TextStyle(
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
        });
      }
    }
  }

  Future<void> _handleRestoreTeam() async {
    if (_team == null || _isRestoring) return;
    setState(() => _isRestoring = true);

    try {
      await _repository.restoreTeam(_team!.id);
      await _loadTeam();
      if (!mounted) return;
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
                  '${_team!.nombre} fue restaurado exitosamente',
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo restaurar el equipo: ${BackendErrorMapper.fromException(e)}',
          ),
          backgroundColor: context.tokens.redToRosita,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isRestoring = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: context.tokens.background,
        appBar: AppBar(
          backgroundColor: context.tokens.card1,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Symbols.arrow_back, color: context.tokens.text),
            onPressed: () => context.go('/teams'),
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

    if (_team == null) {
      return Scaffold(
        backgroundColor: context.tokens.background,
        appBar: AppBar(
          backgroundColor: context.tokens.card1,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Symbols.arrow_back, color: context.tokens.text),
            onPressed: () => context.go('/teams'),
          ),
          title: Text(
            'Equipo no encontrado',
            style: TextStyle(
              color: context.tokens.text,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: const Center(child: Text('El equipo no existe')),
      );
    }

    return Scaffold(
      backgroundColor: context.tokens.background,
      appBar: AppBar(
        backgroundColor: context.tokens.card1,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Symbols.arrow_back, color: context.tokens.text),
          onPressed: () => context.go('/teams'),
        ),
        title: Text(
          _team!.nombre,
          style: TextStyle(
            color: context.tokens.text,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_team!.isDeleted)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: context.tokens.redToRosita.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Equipo eliminado',
                  style: TextStyle(
                    color: context.tokens.redToRosita,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 16 + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tipo de Equipo
            Card(
              margin: EdgeInsets.zero,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide.none,
              ),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: context.tokens.strokeToNoStroke),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_team!.isDeleted)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: context.tokens.redToRosita.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: context.tokens.redToRosita.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Symbols.info,
                              color: context.tokens.redToRosita,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Este equipo fue eliminado. Solo podés verlo y restaurarlo. Todas las acciones están deshabilitadas hasta que lo restaures.',
                                style: TextStyle(
                                  color: context.tokens.redToRosita,
                                  fontSize: 13,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Row(
                      children: [
                        Icon(
                          Symbols.shield,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Tipo de Equipo',
                          style: TextStyle(
                            color: context.tokens.text,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: context.tokens.card1,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: context.tokens.strokeToNoStroke,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _team!.tipo == TeamType.competitivo
                                ? Symbols.emoji_events
                                : Symbols.sports,
                            size: 20,
                            color: context.tokens.text,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _team!.tipo == TeamType.competitivo
                                ? 'Competitivo'
                                : 'Recreativo',
                            style: TextStyle(
                              color: context.tokens.text,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Información General
            Card(
              margin: EdgeInsets.zero,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide.none,
              ),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: context.tokens.strokeToNoStroke),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Symbols.group,
                          size: 20,
                          color: context.tokens.text,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Información General',
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
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nombre',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _team!.nombre,
                                style: TextStyle(
                                  color: context.tokens.text,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Abreviación',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _team!.abreviacion,
                                style: TextStyle(
                                  color: context.tokens.text,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _team!.entrenadores.length > 1
                              ? 'Entrenadores'
                              : 'Entrenador',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (_team!.entrenadores.isEmpty)
                          Text(
                            'Sin entrenador',
                            style: TextStyle(
                              color: context.tokens.text,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _team!.entrenadores.map((entrenador) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.person,
                                      size: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      entrenador,
                                      style: TextStyle(
                                        color: context.tokens.text,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Integrantes
            Card(
              margin: EdgeInsets.zero,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide.none,
              ),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: context.tokens.strokeToNoStroke),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Symbols.group_add,
                          size: 20,
                          color: context.tokens.text,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Integrantes',
                          style: TextStyle(
                            color: context.tokens.text,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_team!.integrantes.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: Text(
                            'No hay integrantes',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ),
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        child: DataTable(
                          headingRowHeight: 36,
                          dataRowMinHeight: 48,
                          dataRowMaxHeight: 48,
                          columnSpacing: 16,
                          horizontalMargin: 0,
                          headingTextStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          dataTextStyle: const TextStyle(fontSize: 13),
                          columns: [
                            DataColumn(label: Expanded(child: Text('DNI'))),
                            DataColumn(label: Expanded(child: Text('Nombre'))),
                            if (_team!.tipo == TeamType.competitivo)
                              DataColumn(
                                label: Expanded(child: Text('Camiseta')),
                              ),
                            const DataColumn(label: SizedBox(width: 24)),
                          ],
                          rows: _team!.integrantes.asMap().entries.map((entry) {
                            final index = entry.key;
                            final member = entry.value;
                            return DataRow(
                              cells: [
                                DataCell(Text(member.dni)),
                                DataCell(Text(member.nombreCompleto)),
                                if (_team!.tipo == TeamType.competitivo)
                                  DataCell(Text(member.numeroCamiseta ?? '-')),
                                DataCell(
                                  PopupMenuButton<_MemberMenuAction>(
                                    useRootNavigator: true,
                                    icon: const Icon(
                                      Symbols.more_vert,
                                      size: 18,
                                    ),
                                    onSelected: (action) {
                                      final userId = _resolveUserIdForMember(
                                        member,
                                      );

                                      switch (action) {
                                        case _MemberMenuAction.viewUser:
                                          context.push('/users/$userId/view');
                                          break;
                                        case _MemberMenuAction.editUser:
                                          context.push('/users/$userId/edit');
                                          break;
                                        case _MemberMenuAction
                                            .viewCompetitiveData:
                                          _showCompetitiveDataDialog(member);
                                          break;
                                        case _MemberMenuAction
                                            .editCompetitiveData:
                                          _showEditCompetitiveDataDialog(
                                            memberIndex: index,
                                            member: member,
                                          );
                                          break;
                                      }
                                    },
                                    itemBuilder: (_) {
                                      if (_team!.tipo == TeamType.competitivo) {
                                        return [
                                          const PopupMenuItem(
                                            value: _MemberMenuAction
                                                .viewCompetitiveData,
                                            child: Text(
                                              'Ver datos competitivos',
                                            ),
                                          ),
                                          if (_canEdit && !_team!.isDeleted)
                                            const PopupMenuItem(
                                              value: _MemberMenuAction
                                                  .editCompetitiveData,
                                              child: Text(
                                                'Modificar datos competitivos',
                                              ),
                                            ),
                                          const PopupMenuItem(
                                            value: _MemberMenuAction.viewUser,
                                            child: Text('Visualizar jugador'),
                                          ),
                                          if (_canEditUser && !_team!.isDeleted)
                                            const PopupMenuItem(
                                              value: _MemberMenuAction.editUser,
                                              child: Text('Modificar usuario'),
                                            ),
                                        ];
                                      } else {
                                        return [
                                          const PopupMenuItem(
                                            value: _MemberMenuAction.viewUser,
                                            child: Text('Ver'),
                                          ),
                                          if (_canEditUser && !_team!.isDeleted)
                                            const PopupMenuItem(
                                              value: _MemberMenuAction.editUser,
                                              child: Text('Modificar'),
                                            ),
                                        ];
                                      }
                                    },
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Acciones rápidas
            Card(
              margin: EdgeInsets.zero,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide.none,
              ),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: context.tokens.strokeToNoStroke),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Symbols.bolt,
                          size: 20,
                          color: context.tokens.text,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Acciones rápidas',
                          style: TextStyle(
                            color: context.tokens.text,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: context.tokens.card1,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: context.tokens.strokeToNoStroke,
                        ),
                      ),
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () {
                              if (_team == null) return;

                              final teamNameEncoded = Uri.encodeComponent(
                                _team!.nombre,
                              );
                              context.go(
                                '/trainings?teamId=${_team!.id}&teamName=$teamNameEncoded',
                              );
                            },
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Icon(
                                    Symbols.sports_volleyball,
                                    size: 20,
                                    color: context.tokens.text,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Gestionar entrenamiento',
                                      style: TextStyle(
                                        color: context.tokens.text,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Symbols.chevron_right,
                                    size: 20,
                                    color: context.tokens.text,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: context.tokens.strokeToNoStroke,
                          ),
                          InkWell(
                            onTap: () {
                              if (_team == null) return;
                              context.push(
                                '/teams/${widget.teamId}/notification?teamName=${Uri.encodeComponent(_team!.nombre)}',
                              );
                            },
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Icon(
                                    Symbols.notifications_active,
                                    size: 20,
                                    color: context.tokens.text,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Enviar notificación',
                                      style: TextStyle(
                                        color: context.tokens.text,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Symbols.chevron_right,
                                    size: 20,
                                    color: context.tokens.text,
                                  ),
                                ],
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
            const SizedBox(height: 20),

            // Botones de edición solo para ADMIN
            if (_canEdit)
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _team!.isDeleted
                          ? null
                          : () async {
                              final result = await context.push(
                                '/teams/edit/${_team!.id}',
                              );
                              if (result == true && mounted) {
                                _loadTeam();
                              }
                            },
                      style: FilledButton.styleFrom(
                        backgroundColor: context.tokens.secondaryButton,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Symbols.edit, size: 18),
                      label: const Text(
                        'Modificar equipo',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_team!.isDeleted)
                    if (_canRestore)
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _isRestoring ? null : _handleRestoreTeam,
                          style: FilledButton.styleFrom(
                            backgroundColor: context.tokens.green,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: _isRestoring
                              ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Icon(
                                  Symbols.settings_backup_restore,
                                  size: 18,
                                ),
                          label: Text(
                            _isRestoring
                                ? 'Restaurando...'
                                : 'Restaurar equipo',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: null,
                          style: FilledButton.styleFrom(
                            backgroundColor: context.tokens.redToRosita
                                .withOpacity(0.2),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: Icon(
                            Symbols.info,
                            size: 18,
                            color: context.tokens.redToRosita,
                          ),
                          label: const Text(
                            'No tenés permisos para restaurar',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                  else if (_canDelete)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _handleDeleteTeam,
                        style: FilledButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Symbols.delete, size: 18),
                        label: const Text(
                          'Eliminar equipo',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _DeleteTeamDialog extends StatefulWidget {
  final String teamName;
  final Future<void> Function() onDelete;

  const _DeleteTeamDialog({required this.teamName, required this.onDelete});

  @override
  State<_DeleteTeamDialog> createState() => _DeleteTeamDialogState();
}

class _DeleteTeamDialogState extends State<_DeleteTeamDialog> {
  bool _isDeleting = false;

  Future<void> _handleConfirm() async {
    if (_isDeleting) return; // Guardia contra doble tap

    setState(() => _isDeleting = true);

    try {
      await widget.onDelete();
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDeleting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No se pudo eliminar el equipo: ${BackendErrorMapper.fromException(e)}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.tokens.card1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(
        'Estás seguro de que querés eliminar este equipo?',
        style: TextStyle(
          color: context.tokens.text,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: _isDeleting
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Eliminando equipo...',
                  style: TextStyle(color: context.tokens.text, fontSize: 14),
                ),
              ],
            )
          : null,
      actions: _isDeleting
          ? []
          : [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: TextButton.styleFrom(
                  foregroundColor: context.tokens.placeholder,
                ),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: _isDeleting ? null : _handleConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Confirmar'),
              ),
            ],
    );
  }
}
