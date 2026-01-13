import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../users/data/repositories/user_repository.dart';
import '../../domain/entities/team.dart';
import '../../data/repositories/team_repository.dart';
import '../widgets/team_form_widget.dart';

class EditTeamPage extends StatefulWidget {
  final String teamId;

  const EditTeamPage({super.key, required this.teamId});

  @override
  State<EditTeamPage> createState() => _EditTeamPageState();
}

class _EditTeamPageState extends State<EditTeamPage> {
  late final TeamRepository _repository;
  late final UserRepository _userRepository;
  bool _isLoading = true;
  Team? _team;

  @override
  void initState() {
    super.initState();
    _repository = TeamRepository();
    _userRepository = UserRepository();
    _loadTeam();
  }

  Future<void> _loadTeam() async {
    try {
      final team = await _repository.getTeamById(widget.teamId);
      if (mounted) {
        setState(() {
          _team = team;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Error al cargar el equipo',
                    style: TextStyle(
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
        context.go('/teams');
      }
    }
  }

  Future<void> _handleUpdateTeam(Team team) async {
    if (_team == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Detectar si hubo cambios en datos básicos del equipo
      final hasBasicChanges =
          team.nombre != _team!.nombre ||
          team.abreviacion != _team!.abreviacion ||
          team.tipo != _team!.tipo ||
          team.entrenador != _team!.entrenador;

      // Detectar si hubo cambios en integrantes (comparar IDs)
      final originalPlayerIds = _team!.integrantes
          .where((m) => m.playerId != null)
          .map((m) => m.playerId!)
          .toSet();
      final newPlayerIds = team.integrantes
          .where((m) => m.playerId != null)
          .map((m) => m.playerId!)
          .toSet();
      final hasPlayerChanges =
          !originalPlayerIds.containsAll(newPlayerIds) ||
          !newPlayerIds.containsAll(originalPlayerIds);

      // Solo actualizar el equipo si hubo cambios en datos básicos o integrantes
      if (hasBasicChanges || hasPlayerChanges) {
        await _repository.updateTeam(team);
      }

      // Actualizar números de camiseta si es necesario
      int updatedCount = 0;
      int errorCount = 0;

      for (final newMember in team.integrantes) {
        if (newMember.playerId == null) continue;

        final originalMember = _team!.integrantes.firstWhere(
          (m) => m.playerId == newMember.playerId,
          orElse: () => TeamMember(dni: '', nombre: '', apellido: ''),
        );

        // Si el número de camiseta cambió o es un jugador nuevo con número
        if (newMember.numeroCamiseta != null &&
            newMember.numeroCamiseta!.isNotEmpty &&
            originalMember.numeroCamiseta != newMember.numeroCamiseta) {
          try {
            print(
              '🔢 Updating jersey number for player ${newMember.playerId}: '
              '${originalMember.numeroCamiseta ?? "none"} → ${newMember.numeroCamiseta}',
            );
            await _userRepository.updatePerson(newMember.playerId!, {
              'jerseyNumber': int.tryParse(newMember.numeroCamiseta!) ?? 0,
            });
            updatedCount++;
          } catch (e) {
            print('❌ Error updating jersey for ${newMember.playerId}: $e');
            errorCount++;
          }
        }
      }

      if (mounted) {
        String message = 'Equipo ${team.nombre} actualizado exitosamente';
        if (updatedCount > 0) {
          message = updatedCount == 1
              ? 'Número de camiseta actualizado'
              : '$updatedCount números de camiseta actualizados';
        }
        if (errorCount > 0) {
          message += ' ($errorCount error${errorCount > 1 ? 'es' : ''})';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  errorCount > 0
                      ? Icons.warning_amber
                      : Icons.check_circle_outline,
                  color: Colors.white,
                  size: 20,
                ),
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
            backgroundColor: errorCount > 0
                ? Colors.orange
                : context.tokens.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            duration: const Duration(seconds: 3),
          ),
        );

        context.go('/teams/view/${team.id}');
      }
    } catch (e) {
      print('❌ Error updating team: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Error al actualizar equipo: $e',
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
        backgroundColor: context.tokens.card1,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Symbols.arrow_back, color: context.tokens.text),
          onPressed: () => context.go('/teams/view/${widget.teamId}'),
        ),
        title: Text(
          'Modificar Equipo',
          style: TextStyle(
            color: context.tokens.text,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    context.tokens.redToRosita,
                  ),
                ),
              )
            : _team == null
            ? const Center(child: Text('Equipo no encontrado'))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: TeamFormWidget(team: _team, onSubmit: _handleUpdateTeam),
              ),
      ),
    );
  }
}
