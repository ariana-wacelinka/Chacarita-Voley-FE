import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../../app/theme/app_theme.dart';
import '../../domain/entities/notification.dart';
import '../../data/repositories/notification_repository.dart';
import '../../../teams/data/repositories/team_repository.dart';
import '../../../teams/domain/entities/team_list_item.dart';
import '../../../users/data/repositories/user_repository.dart';
import '../../../users/domain/entities/user.dart';

class ViewNotificationPage extends StatefulWidget {
  final String notificationId;

  const ViewNotificationPage({super.key, required this.notificationId});

  @override
  State<ViewNotificationPage> createState() => _ViewNotificationPageState();
}

class _ViewNotificationPageState extends State<ViewNotificationPage> {
  final _repository = NotificationRepository();
  final _teamRepository = TeamRepository();
  final _userRepository = UserRepository();
  NotificationModel? _notification;
  bool _isLoading = true;
  String? _errorMessage;
  
  Map<String, String> _teamNames = {};
  Map<String, String> _playerNames = {};

  @override
  void initState() {
    super.initState();
    _loadNotification();
  }

  Future<void> _loadNotification() async {
    try {
      final notification = await _repository.getNotificationById(widget.notificationId);

      // Cargar nombres de equipos y jugadores
      await _loadTeamAndPlayerNames(notification);

      if (!mounted) return;
      setState(() {
        _notification = notification;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error al cargar notificación';
      });
    }
  }

  Future<void> _loadTeamAndPlayerNames(NotificationModel notification) async {
    try {
      // Obtener IDs únicos de equipos y jugadores
      final teamIds = <String>{};
      final playerIds = <String>{};

      for (var destination in notification.destinations) {
        if (destination.type == DestinationType.TEAM && 
            destination.referenceId != null) {
          teamIds.add(destination.referenceId!);
        } else if (destination.type == DestinationType.PLAYER && 
                   destination.referenceId != null) {
          playerIds.add(destination.referenceId!);
        }
      }

      // Cargar equipos
      if (teamIds.isNotEmpty) {
        final teams = await _teamRepository.getTeamsListItems();
        for (var team in teams) {
          if (teamIds.contains(team.id)) {
            _teamNames[team.id] = team.nombre;
          }
        }
      }

      // Cargar jugadores
      if (playerIds.isNotEmpty) {
        print('🔍 playerIds needed: $playerIds');
        final users = await _userRepository.getUsersForNotifications();
        print('📋 Total users loaded: ${users.length}');
        for (var user in users) {
          final userId = user.id;
          print('  User: ${user.nombre} ${user.apellido} - id: $userId');
          if (userId != null && playerIds.contains(userId)) {
            _playerNames[userId] = '${user.nombre} ${user.apellido}';
            print('  ✅ Matched player: $userId = ${user.nombre} ${user.apellido}');
          }
        }
        print('🎯 Final _playerNames: $_playerNames');
      }
    } catch (e) {
      print('Error loading team/player names: $e');
    }
  }

  Future<void> _showDeleteConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.tokens.card1,
        title: Text(
          'Confirmar eliminación',
          style: TextStyle(
            color: context.tokens.text,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          '¿Estás seguro de que querés eliminar "${_notification!.title}"? Esta acción no se puede deshacer.',
          style: TextStyle(color: context.tokens.text),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE0E0E0),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF8B0000),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
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
      ),
    );

    if (confirmed == true) {
      _deleteNotification();
    }
  }

  Future<void> _deleteNotification() async {
    try {
      await _repository.deleteNotification(widget.notificationId);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Text('Notificación eliminada'),
            ],
          ),
          backgroundColor: context.tokens.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      context.go('/notifications');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar: $e'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
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
            onPressed: () => context.go('/notifications'),
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

    if (_errorMessage != null || _notification == null) {
      return Scaffold(
        backgroundColor: context.tokens.background,
        appBar: AppBar(
          backgroundColor: context.tokens.card1,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Symbols.arrow_back, color: context.tokens.text),
            onPressed: () => context.go('/notifications'),
          ),
          title: Text(
            'Error',
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
                'No se pudo cargar la notificación',
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

    return Scaffold(
      backgroundColor: context.tokens.background,
      appBar: AppBar(
        backgroundColor: context.tokens.card1,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Symbols.arrow_back, color: context.tokens.text),
          onPressed: () => context.go('/notifications'),
        ),
        title: Text(
          'Notificación',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitleSection(context),
              const SizedBox(height: 16),
              _buildMessageSection(context),
              const SizedBox(height: 16),
              _buildRecipientsSection(context),
              const SizedBox(height: 32),
              _buildActionButtons(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleSection(BuildContext context) {
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
          Text(
            _notification!.title,
            style: TextStyle(
              color: context.tokens.text,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _notification!.sender != null
                ? '${_notification!.sender!.name} ${_notification!.sender!.surname}'
                : 'Usuario desconocido',
            style: TextStyle(color: context.tokens.placeholder, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Symbols.schedule, size: 16, color: context.tokens.text),
              const SizedBox(width: 6),
              Text(
                _notification!.startTime,
                style: TextStyle(color: context.tokens.text, fontSize: 14),
              ),
            ],
          ),
          if (_notification!.getRepeatText().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              _notification!.getRepeatText(),
              style: TextStyle(color: context.tokens.placeholder, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.tokens.card1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.tokens.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detalle del Mensaje',
            style: TextStyle(
              color: context.tokens.text,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _notification!.message,
            style: TextStyle(
              color: context.tokens.text,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipientsSection(BuildContext context) {
    final destinations = _notification?.destinations ?? [];

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
                'Destinatarios',
                style: TextStyle(
                  color: context.tokens.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (destinations.isEmpty)
            Text(
              'Sin destinatarios',
              style: TextStyle(color: context.tokens.placeholder, fontSize: 14),
            )
          else ...[
            Container(
              constraints: const BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                border: Border.all(color: context.tokens.stroke),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: destinations.length,
                separatorBuilder: (context, index) =>
                    Divider(height: 1, color: context.tokens.stroke),
                itemBuilder: (context, index) {
                  final destination = destinations[index];
                  String displayText = _getDestinationDisplayText(destination);

                  return Container(
                    color: context.tokens.background,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getDestinationIcon(destination.type),
                          color: context.tokens.placeholder,
                          size: 18,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            displayText,
                            style: TextStyle(
                              color: context.tokens.text,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                '1-${destinations.length} de ${destinations.length}',
                style: TextStyle(color: context.tokens.text, fontSize: 14),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getDestinationDisplayText(NotificationDestination destination) {
    switch (destination.type) {
      case DestinationType.ALL_PLAYERS:
        return 'Todos los jugadores';
      case DestinationType.TEAM:
        if (destination.referenceId != null) {
          return _teamNames[destination.referenceId] ?? 
                 'Equipo (ID: ${destination.referenceId})';
        }
        return 'Equipo';
      case DestinationType.PLAYER:
        if (destination.referenceId != null) {
          return _playerNames[destination.referenceId] ?? 
                 'Jugador (ID: ${destination.referenceId})';
        }
        return 'Jugador';
      case DestinationType.DUES_PENDING:
        return 'Jugadores con cuota pendiente';
      case DestinationType.DUES_OVERDUE:
        return 'Jugadores con cuota vencida';
    }
  }

  IconData _getDestinationIcon(DestinationType type) {
    switch (type) {
      case DestinationType.ALL_PLAYERS:
        return Symbols.groups;
      case DestinationType.TEAM:
        return Symbols.sports_volleyball;
      case DestinationType.PLAYER:
        return Symbols.person;
      case DestinationType.DUES_PENDING:
      case DestinationType.DUES_OVERDUE:
        return Symbols.payment;
    }
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              final result = await context.push(
                '/notifications/${widget.notificationId}/edit',
              );
              if (result == true && mounted) {
                _loadNotification();
                // Propagate the update signal back to the list
                context.pop(true);
              }
            },
            icon: const Icon(Symbols.edit, color: Colors.white, size: 18),
            label: const Text(
              'Modificar notificación',
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
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _showDeleteConfirmation,
            icon: const Icon(Symbols.delete, color: Colors.white, size: 18),
            label: const Text(
              'Eliminar notificación',
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
    );
  }
}
