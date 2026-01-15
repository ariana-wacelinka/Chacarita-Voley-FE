import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../../app/theme/app_theme.dart';
import '../../domain/entities/team.dart';
import '../../domain/entities/team_type.dart';
import '../../data/repositories/team_repository.dart';
import '../../../users/data/repositories/user_repository.dart';
import '../../../users/domain/entities/user.dart';

enum _MemberMenuAction {
  viewUser,
  editUser,
  viewCompetitiveData,
  editCompetitiveData,
}

class ViewTeamPage extends StatefulWidget {
  final String teamId;

  const ViewTeamPage({super.key, required this.teamId});

  @override
  State<ViewTeamPage> createState() => _ViewTeamPageState();
}

class _ViewTeamPageState extends State<ViewTeamPage> {
  late final TeamRepository _repository;
  late final UserRepository _userRepository;
  Team? _team;
  bool _isLoading = true;

  String _resolveUserIdForMember(TeamMember member) {
    return member.dni;
  }

  void _showCompetitiveDataDialog(TeamMember member) {
    showDialog<void>(
      context: context,
      useRootNavigator: true,
      builder: (context) {
        return AlertDialog(
          title: const Text('Datos competitivos'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.nombreCompleto.trim().isEmpty
                      ? member.dni
                      : member.nombreCompleto,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Número de camiseta: ${member.numeroCamiseta ?? '-'}',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
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
    final controller = TextEditingController(text: member.numeroCamiseta ?? '');

    showDialog<void>(
      context: context,
      useRootNavigator: true,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modificar datos competitivos'),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.nombreCompleto.trim().isEmpty
                        ? member.dni
                        : member.nombreCompleto,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    key: const Key('competitive-jersey-number-field'),
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Número de camiseta',
                      hintText: 'Ej: 10',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              key: const Key('competitive-save-button'),
              onPressed: () async {
                final value = controller.text.trim();
                print(
                  '🔢 Saving jersey number: $value for player ${member.playerId}',
                );

                final updated = member.copyWith(
                  numeroCamiseta: value.isEmpty ? null : value,
                );

                if (member.playerId != null && value.isNotEmpty) {
                  try {
                    print(
                      '🚀 Calling updatePerson with playerId: ${member.playerId}, jerseyNumber: ${int.tryParse(value)}',
                    );
                    await _userRepository.updatePerson(member.playerId!, {
                      'jerseyNumber': int.tryParse(value) ?? 0,
                    });
                    print('✅ Jersey number updated successfully');
                  } catch (e) {
                    print('❌ Error updating jersey number: $e');
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Error al actualizar número de camiseta: $e',
                          ),
                          backgroundColor: context.tokens.redToRosita,
                        ),
                      );
                    }
                    return;
                  }
                }

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
                      content: const Text('Número de camiseta actualizado'),
                      backgroundColor: context.tokens.green,
                    ),
                  );
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _repository = TeamRepository();
    _userRepository = UserRepository();
    _loadTeam();
  }

  Future<void> _loadTeam() async {
    // ignore: avoid_print
    print('🔍 ViewTeamPage: Cargando equipo con ID: ${widget.teamId}');
    try {
      final team = await _repository.getTeamById(widget.teamId);
      // ignore: avoid_print
      print('✅ ViewTeamPage: Equipo obtenido: ${team?.nombre ?? "null"}');
      if (mounted) {
        setState(() {
          _team = team;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      // ignore: avoid_print
      print('❌ ViewTeamPage: Error cargando equipo: $e');
      // ignore: avoid_print
      print('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
                backgroundColor: context.tokens.redToRosita,
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
              context.tokens.redToRosita,
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
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Symbols.shield,
                          size: 20,
                          color: context.tokens.redToRosita,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Tipo de Equipo',
                          style: TextStyle(
                            color: context.tokens.redToRosita,
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
                        border: Border.all(color: Colors.grey.shade300),
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
                  border: Border.all(color: Colors.grey.shade300),
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
                  border: Border.all(color: Colors.grey.shade300),
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
                                        return const [
                                          PopupMenuItem(
                                            value: _MemberMenuAction
                                                .viewCompetitiveData,
                                            child: Text(
                                              'Ver datos competitivos',
                                            ),
                                          ),
                                          PopupMenuItem(
                                            value: _MemberMenuAction
                                                .editCompetitiveData,
                                            child: Text(
                                              'Modificar datos competitivos',
                                            ),
                                          ),
                                          PopupMenuItem(
                                            value: _MemberMenuAction.viewUser,
                                            child: Text('Visualizar jugador'),
                                          ),
                                          PopupMenuItem(
                                            value: _MemberMenuAction.editUser,
                                            child: Text('Modificar usuario'),
                                          ),
                                        ];
                                      } else {
                                        return const [
                                          PopupMenuItem(
                                            value: _MemberMenuAction.viewUser,
                                            child: Text('Ver'),
                                          ),
                                          PopupMenuItem(
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
                  border: Border.all(color: Colors.grey.shade300),
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
                        border: Border.all(color: Colors.grey.shade300),
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
                            color: Colors.grey.shade300,
                          ),
                          InkWell(
                            onTap: () {
                              // TODO: Implementar enviar notificación
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

            // Botón Modificar equipo
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  context.go('/teams/edit/${_team!.id}');
                },
                style: FilledButton.styleFrom(
                  backgroundColor: context.tokens.text,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Symbols.edit, size: 18),
                label: const Text(
                  'Modificar equipo',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Botón Eliminar equipo
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _handleDeleteTeam,
                style: FilledButton.styleFrom(
                  backgroundColor: context.tokens.redToRosita,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Symbols.delete, size: 18),
                label: const Text(
                  'Eliminar equipo',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
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
            content: Text('Error al eliminar: $e'),
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
                    context.tokens.redToRosita,
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
                  backgroundColor: context.tokens.redToRosita,
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
