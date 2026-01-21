import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../app/theme/app_theme.dart';
import '../../data/repositories/notification_repository.dart';
import '../../domain/entities/notification.dart';
import '../../../teams/data/repositories/team_repository.dart';
import '../../../teams/domain/entities/team_list_item.dart';
import '../../../users/data/repositories/user_repository.dart';
import '../../../users/domain/entities/user.dart';

class EditNotificationPage extends StatefulWidget {
  final String notificationId;

  const EditNotificationPage({super.key, required this.notificationId});

  @override
  State<EditNotificationPage> createState() => _EditNotificationPageState();
}

class _EditNotificationPageState extends State<EditNotificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _repository = NotificationRepository();
  final _teamRepository = TeamRepository();
  final _userRepository = UserRepository();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _teamsSearchController = TextEditingController();
  final _playersSearchController = TextEditingController();

  bool _isLoadingNotification = true;
  int _currentStep = 0;
  bool _isProgrammed = false;
  DateTime? _scheduledDate;
  TimeOfDay? _scheduledTime;
  bool _repeatNotification = false;
  String? _selectedFrequency;
  bool _isSaving = false;

  String? _recipientFilter;

  Set<String> _selectedTeams = {};
  Set<String> _selectedPlayers = {};

  final List<String> _frequencies = ['Diaria', 'Semanal', 'Mensual'];

  List<TeamListItem> _allTeams = [];
  List<User> _allPlayers = [];
  bool _isLoadingTeams = false;
  bool _isLoadingPlayers = false;

  @override
  void initState() {
    super.initState();
    _loadTeams();
    _loadPlayers();
    _loadNotification();
  }

  Future<void> _loadTeams() async {
    setState(() => _isLoadingTeams = true);
    try {
      final teams = await _teamRepository.getTeamsListItems();
      if (mounted) {
        setState(() {
          _allTeams = teams;
          _isLoadingTeams = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingTeams = false);
      }
    }
  }

  Future<void> _loadPlayers() async {
    setState(() => _isLoadingPlayers = true);
    try {
      final users = await _userRepository.getUsers();
      if (mounted) {
        setState(() {
          _allPlayers = users;
          _isLoadingPlayers = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingPlayers = false);
      }
    }
  }

  Future<void> _loadNotification() async {
    try {
      final notification = await _repository.getNotificationById(widget.notificationId);

      if (!mounted) return;

      setState(() {
        _titleController.text = notification.title;
        _messageController.text = notification.message;

        // Cargar datos de programación si existe
        if (notification.scheduledAt != null) {
          _isProgrammed = true;
          _scheduledDate = notification.scheduledAt;
          _scheduledTime = TimeOfDay.fromDateTime(notification.scheduledAt!);
          _dateController.text =
              '${notification.scheduledAt!.day.toString().padLeft(2, '0')}/${notification.scheduledAt!.month.toString().padLeft(2, '0')}/${notification.scheduledAt!.year}';
          _timeController.text =
              '${notification.scheduledAt!.hour.toString().padLeft(2, '0')}:${notification.scheduledAt!.minute.toString().padLeft(2, '0')}';
        }

        if (notification.repeatable && notification.frequency != null) {
          _repeatNotification = true;
          _selectedFrequency = notification.frequency!.displayName;
        }

        // Cargar destinatarios
        for (var destination in notification.destinations) {
          switch (destination.type) {
            case DestinationType.ALL_PLAYERS:
              _recipientFilter = 'todos';
              break;
            case DestinationType.DUES_PENDING:
              _recipientFilter = 'pendiente';
              break;
            case DestinationType.DUES_OVERDUE:
              _recipientFilter = 'vencida';
              break;
            case DestinationType.PLAYER:
              if (destination.referenceId != null) {
                _selectedPlayers.add(destination.referenceId!);
              }
              break;
            case DestinationType.TEAM:
              if (destination.referenceId != null) {
                _selectedTeams.add(destination.referenceId!);
              }
              break;
          }
        }

        _isLoadingNotification = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingNotification = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar notificación: $e'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _teamsSearchController.dispose();
    _playersSearchController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _scheduledDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _scheduledDate = picked;
        _dateController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _scheduledTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _scheduledTime = picked;
        _timeController.text =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_titleController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El título es obligatorio')),
        );
        return;
      }
      if (_messageController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El mensaje es obligatorio')),
        );
        return;
      }
      if (_isProgrammed && (_scheduledDate == null || _scheduledTime == null)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Completá la fecha y hora')),
        );
        return;
      }
      if (_isProgrammed && _repeatNotification && _selectedFrequency == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seleccioná una frecuencia')),
        );
        return;
      }
    }

    if (_currentStep < 2) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _updateNotification() async {
    setState(() => _isSaving = true);

    try {
      SendMode sendMode = SendMode.NOW;
      Frequency? frequency;
      String? time;
      String? date;

      if (_isProgrammed) {
        sendMode = _repeatNotification
            ? SendMode.SCHEDULED
            : SendMode.SCHEDULED;
        if (_repeatNotification && _selectedFrequency != null) {
          frequency = Frequency.fromSpanish(_selectedFrequency!);
        }
        if (_scheduledTime != null) {
          time =
              '${_scheduledTime!.hour.toString().padLeft(2, '0')}:${_scheduledTime!.minute.toString().padLeft(2, '0')}';
        }
        if (_scheduledDate != null) {
          date =
              '${_scheduledDate!.year}-${_scheduledDate!.month.toString().padLeft(2, '0')}-${_scheduledDate!.day.toString().padLeft(2, '0')}';
        }
      }

      // Construir destinations según la selección
      List<NotificationDestinationInput> destinations = [];

      if (_recipientFilter == 'todos') {
        destinations.add(
          NotificationDestinationInput(
            type: DestinationType.ALL_PLAYERS,
            referenceId: null,
          ),
        );
      } else if (_recipientFilter == 'pendiente') {
        destinations.add(
          NotificationDestinationInput(
            type: DestinationType.DUES_PENDING,
            referenceId: null,
          ),
        );
      } else if (_recipientFilter == 'vencida') {
        destinations.add(
          NotificationDestinationInput(
            type: DestinationType.DUES_OVERDUE,
            referenceId: null,
          ),
        );
      }

      // Agregar equipos seleccionados
      for (final teamId in _selectedTeams) {
        destinations.add(
          NotificationDestinationInput(
            type: DestinationType.TEAM,
            referenceId: teamId,
          ),
        );
      }

      // Agregar jugadores seleccionados
      for (final playerId in _selectedPlayers) {
        destinations.add(
          NotificationDestinationInput(
            type: DestinationType.PLAYER,
            referenceId: playerId,
          ),
        );
      }

      if (destinations.isEmpty) {
        throw Exception('Debés seleccionar al menos un destinatario');
      }

      await _repository.updateNotification(
        id: widget.notificationId,
        title: _titleController.text,
        message: _messageController.text,
        sendMode: sendMode,
        time: time,
        date: date,
        frequency: frequency,
        destinations: destinations,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Symbols.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Notificación actualizada exitosamente',
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

        // Return true to trigger refresh in parent page
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Symbols.error, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Error al actualizar la notificación: $e',
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
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingNotification) {
      return Scaffold(
        backgroundColor: context.tokens.background,
        appBar: AppBar(
          backgroundColor: context.tokens.card1,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Symbols.arrow_back, color: context.tokens.text),
            onPressed: () =>
                context.go('/notifications/${widget.notificationId}'),
          ),
          title: Text(
            'Cargando...',
            style: TextStyle(
              color: context.tokens.text,
              fontSize: 20,
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

    return Scaffold(
      backgroundColor: context.tokens.background,
      appBar: AppBar(
        backgroundColor: context.tokens.card2,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Symbols.arrow_back, color: context.tokens.text),
          onPressed: () =>
              context.go('/notifications/${widget.notificationId}'),
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Modificar Notificación',
              style: TextStyle(
                color: context.tokens.text,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              _getStepTitle(),
              style: TextStyle(
                color: context.tokens.text.withOpacity(0.6),
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_currentStep == 0) ..._buildStep1(),
                  if (_currentStep == 1) ..._buildStep2(),
                  if (_currentStep == 2) ..._buildStep3(),
                ],
              ),
            ),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Paso 1: Contenido';
      case 1:
        return 'Paso 2: Destinatarios';
      case 2:
        return 'Paso 3: Revisión';
      default:
        return '';
    }
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      color: context.tokens.card1,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;

          return Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive
                      ? Theme.of(context).colorScheme.primary
                      : isCompleted
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                      : Colors.grey.shade300,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: isActive || isCompleted
                          ? Colors.white
                          : Colors.grey.shade600,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              if (index < 2)
                Container(
                  width: MediaQuery.of(context).size.width * 0.25,
                  height: 2,
                  color: Colors.grey.shade300,
                ),
            ],
          );
        }),
      ),
    );
  }

  List<Widget> _buildStep1() {
    return [
      Container(
        decoration: BoxDecoration(
          color: context.tokens.card1,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.tokens.stroke),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Symbols.send, size: 20, color: context.tokens.text),
                const SizedBox(width: 8),
                Text(
                  'Tipo de Envío',
                  style: TextStyle(
                    color: context.tokens.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildRadioTile(
              'Enviar ahora',
              !_isProgrammed,
              () => setState(() => _isProgrammed = false),
            ),
            _buildRadioTile(
              'Programar envío',
              _isProgrammed,
              () => setState(() => _isProgrammed = true),
            ),
          ],
        ),
      ),

      if (_isProgrammed) ...[
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: context.tokens.card1,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.tokens.stroke),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Symbols.calendar_month,
                    size: 20,
                    color: context.tokens.text,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Fecha y hora',
                    style: TextStyle(
                      color: context.tokens.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _dateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Fecha *',
                        hintText: 'DD/MM/AAAA',
                        suffixIcon: IconButton(
                          icon: const Icon(Symbols.calendar_today, size: 20),
                          onPressed: _selectDate,
                        ),
                        filled: true,
                        fillColor: context.tokens.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: context.tokens.text.withOpacity(0.2),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: context.tokens.text.withOpacity(0.2),
                          ),
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
                      onTap: _selectDate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _timeController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Hora *',
                        hintText: 'HH:MM',
                        suffixIcon: IconButton(
                          icon: const Icon(Symbols.schedule, size: 20),
                          onPressed: _selectTime,
                        ),
                        filled: true,
                        fillColor: context.tokens.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: context.tokens.text.withOpacity(0.2),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: context.tokens.text.withOpacity(0.2),
                          ),
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
                      onTap: _selectTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () => setState(() {
                  _repeatNotification = !_repeatNotification;
                  if (!_repeatNotification) {
                    _selectedFrequency = null;
                  }
                }),
                child: Row(
                  children: [
                    Icon(Symbols.repeat, size: 20, color: context.tokens.text),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Repetir notificación',
                        style: TextStyle(
                          color: context.tokens.text,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Checkbox(
                      value: _repeatNotification,
                      onChanged: (value) => setState(() {
                        _repeatNotification = value ?? false;
                        if (!_repeatNotification) {
                          _selectedFrequency = null;
                        }
                      }),
                      activeColor: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
              if (_repeatNotification) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedFrequency,
                  decoration: InputDecoration(
                    labelText: 'Frecuencia *',
                    hintText: 'Seleccionar frecuencia...',
                    filled: true,
                    fillColor: context.tokens.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: context.tokens.text.withOpacity(0.2),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: context.tokens.text.withOpacity(0.2),
                      ),
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
                  items: _frequencies
                      .map(
                        (freq) =>
                            DropdownMenuItem(value: freq, child: Text(freq)),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedFrequency = value),
                ),
              ],
            ],
          ),
        ),
      ],

      const SizedBox(height: 16),
      Container(
        decoration: BoxDecoration(
          color: context.tokens.card1,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.tokens.stroke),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Symbols.info, size: 20, color: context.tokens.text),
                const SizedBox(width: 8),
                Text(
                  'Contenido del Mensaje',
                  style: TextStyle(
                    color: context.tokens.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              maxLength: 100,
              decoration: InputDecoration(
                labelText: 'Título *',
                filled: true,
                fillColor: context.tokens.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: context.tokens.text.withOpacity(0.2),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: context.tokens.text.withOpacity(0.2),
                  ),
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
            TextFormField(
              controller: _messageController,
              maxLength: 500,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Mensaje *',
                filled: true,
                fillColor: context.tokens.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: context.tokens.text.withOpacity(0.2),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: context.tokens.text.withOpacity(0.2),
                  ),
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
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildStep2() {
    final searchText = _teamsSearchController.text.toLowerCase();
    final filteredTeams = _allTeams
        .where((team) => team.nombre.toLowerCase().contains(searchText))
        .toList();

    final searchTextPlayers = _playersSearchController.text.toLowerCase();
    final filteredPlayers = _allPlayers
        .where(
          (player) =>
              player.nombreCompleto.toLowerCase().contains(searchTextPlayers) ||
              player.dni.toLowerCase().contains(searchTextPlayers),
        )
        .toList();

    return [
      Text(
        'Destinatarios:',
        style: TextStyle(
          color: context.tokens.text,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildFilterChip(
            label: 'Seleccionar todos',
            isSelected: _recipientFilter == 'todos',
            onTap: () => setState(
              () => _recipientFilter = _recipientFilter == 'todos'
                  ? null
                  : 'todos',
            ),
          ),
          _buildFilterChip(
            label: 'Cuota vencida',
            isSelected: _recipientFilter == 'vencida',
            onTap: () => setState(
              () => _recipientFilter = _recipientFilter == 'vencida'
                  ? null
                  : 'vencida',
            ),
          ),
          _buildFilterChip(
            label: 'Cuota pendiente',
            isSelected: _recipientFilter == 'pendiente',
            onTap: () => setState(
              () => _recipientFilter = _recipientFilter == 'pendiente'
                  ? null
                  : 'pendiente',
            ),
          ),
        ],
      ),

      const SizedBox(height: 24),
      Container(
        decoration: BoxDecoration(
          color: context.tokens.card1,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.tokens.stroke),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Symbols.group, size: 20, color: context.tokens.text),
                const SizedBox(width: 8),
                Text(
                  'Equipos',
                  style: TextStyle(
                    color: context.tokens.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _teamsSearchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre...',
                prefixIcon: const Icon(Symbols.search, size: 20),
                filled: true,
                fillColor: context.tokens.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: context.tokens.text.withOpacity(0.2),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: context.tokens.text.withOpacity(0.2),
                  ),
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
              onChanged: (value) => setState(() {}),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 150,
              child: _isLoadingTeams
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    )
                  : filteredTeams.isEmpty
                  ? Center(
                      child: Text(
                        'No se encontraron equipos',
                        style: TextStyle(
                          color: context.tokens.placeholder,
                          fontSize: 14,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredTeams.length,
                      itemBuilder: (context, index) {
                        final team = filteredTeams[index];
                        final isSelected = _selectedTeams.contains(team.id);
                        return CheckboxListTile(
                          value: isSelected,
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                _selectedTeams.add(team.id);
                              } else {
                                _selectedTeams.remove(team.id);
                              }
                            });
                          },
                          title: Text(
                            team.nombre,
                            style: TextStyle(
                              color: context.tokens.text,
                              fontSize: 14,
                            ),
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          activeColor: Theme.of(context).colorScheme.primary,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      const SizedBox(height: 16),
      Container(
        decoration: BoxDecoration(
          color: context.tokens.card1,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.tokens.stroke),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Symbols.person, size: 20, color: context.tokens.text),
                const SizedBox(width: 8),
                Text(
                  'Jugadores',
                  style: TextStyle(
                    color: context.tokens.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _playersSearchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o DNI...',
                prefixIcon: const Icon(Symbols.search, size: 20),
                filled: true,
                fillColor: context.tokens.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: context.tokens.text.withOpacity(0.2),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: context.tokens.text.withOpacity(0.2),
                  ),
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
              onChanged: (value) => setState(() {}),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 150,
              child: _isLoadingPlayers
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    )
                  : filteredPlayers.isEmpty
                  ? Center(
                      child: Text(
                        'No se encontraron jugadores',
                        style: TextStyle(
                          color: context.tokens.placeholder,
                          fontSize: 14,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredPlayers.length,
                      itemBuilder: (context, index) {
                        final player = filteredPlayers[index];
                        final isSelected = _selectedPlayers.contains(
                          player.id ?? '',
                        );
                        return CheckboxListTile(
                          value: isSelected,
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                _selectedPlayers.add(player.id ?? '');
                              } else {
                                _selectedPlayers.remove(player.id ?? '');
                              }
                            });
                          },
                          title: Text(
                            player.nombreCompleto,
                            style: TextStyle(
                              color: context.tokens.text,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            'DNI: ${player.dni}',
                            style: TextStyle(
                              color: context.tokens.placeholder,
                              fontSize: 12,
                            ),
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          activeColor: Theme.of(context).colorScheme.primary,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildStep3() {
    return [
      Container(
        decoration: BoxDecoration(
          color: context.tokens.card1,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.tokens.stroke),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen',
              style: TextStyle(
                color: context.tokens.text,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),

            // Título
            Text(
              'Título:',
              style: TextStyle(
                color: context.tokens.text,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _titleController.text.isEmpty
                  ? 'Título genérico de mensaje'
                  : _titleController.text,
              style: TextStyle(color: context.tokens.text, fontSize: 14),
            ),
            const SizedBox(height: 20),

            // Mensaje
            Text(
              'Mensaje:',
              style: TextStyle(
                color: context.tokens.text,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _messageController.text.isEmpty
                  ? 'Cuerpo genérico de mensaje'
                  : _messageController.text,
              style: TextStyle(color: context.tokens.text, fontSize: 14),
            ),
            const SizedBox(height: 20),

            // Tipo de envío
            Text(
              'Tipo de envío:',
              style: TextStyle(
                color: context.tokens.text,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            if (_isProgrammed) ...[
              Text(
                'Programado para ${_dateController.text} a las ${_timeController.text}',
                style: TextStyle(color: context.tokens.text, fontSize: 14),
              ),
              if (_repeatNotification && _selectedFrequency != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Se repite ${_selectedFrequency!.toLowerCase()}',
                  style: TextStyle(color: context.tokens.text, fontSize: 14),
                ),
              ],
            ] else ...[
              Text(
                'Enviar inmediatamente',
                style: TextStyle(color: context.tokens.text, fontSize: 14),
              ),
            ],
          ],
        ),
      ),
    ];
  }

  Widget _buildRadioTile(String title, bool value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: value
              ? Theme.of(context).colorScheme.primary.withOpacity(0.05)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: value
                ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Radio<bool>(
              value: value,
              groupValue: true,
              onChanged: (_) => onTap(),
              activeColor: Theme.of(context).colorScheme.primary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(color: context.tokens.text, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.tokens.card1,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Anterior',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: _isSaving
                  ? null
                  : (_currentStep == 2 ? _updateNotification : _nextStep),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 24,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      _currentStep == 2 ? 'Guardar cambios' : 'Siguiente',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : context.tokens.card1,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : context.tokens.stroke,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : context.tokens.text,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Icon(Symbols.check, size: 16, color: Colors.white),
            ],
          ],
        ),
      ),
    );
  }
}
