import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../../app/theme/app_theme.dart';
import '../../domain/entities/training.dart';
import '../../data/repositories/training_repository.dart';

enum _TrainingMenuAction { view, edit, delete }

class TrainingsPage extends StatefulWidget {
  final String? teamId;
  final String? teamName;
  final String? refresh;

  const TrainingsPage({super.key, this.teamId, this.teamName, this.refresh});

  @override
  State<TrainingsPage> createState() => _TrainingsPageState();
}

class _TrainingsPageState extends State<TrainingsPage> {
  final _repository = TrainingRepository();
  List<Training> _trainings = [];
  bool _isLoading = true;

  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();

  TrainingStatus? _selectedStatus;

  int _currentPage = 0;
  final int _itemsPerPage = 10;
  int _totalPages = 0;
  int _totalElements = 0;
  bool _hasNext = false;
  bool _hasPrevious = false;

  @override
  void initState() {
    super.initState();
    _loadTrainings();
  }

  @override
  void didUpdateWidget(TrainingsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.refresh != null && widget.refresh != oldWidget.refresh) {
      _currentPage = 0;
      _loadTrainings();
    }
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  Future<void> _loadTrainings() async {
    setState(() => _isLoading = true);
    try {
      final result = await _repository.getTrainingsWithPagination(
        status: _selectedStatus,
        page: _currentPage,
        size: _itemsPerPage,
      );
      if (mounted) {
        setState(() {
          _trainings = result['content'] as List<Training>;
          _totalPages = result['totalPages'] as int;
          _totalElements = result['totalElements'] as int;
          _hasNext = result['hasNext'] as bool;
          _hasPrevious = result['hasPrevious'] as bool;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _goToPage(int page) {
    if (page >= 0 && page < _totalPages) {
      setState(() {
        _currentPage = page;
      });
      _loadTrainings();
    }
  }

  Future<void> _pickTime(TextEditingController controller) async {
    final now = DateTime.now();
    DateTime initialDateTime = DateTime(now.year, now.month, now.day);

    if (controller.text.isNotEmpty) {
      final parts = controller.text.split(':');
      if (parts.length == 2) {
        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);
        if (hour != null && minute != null) {
          initialDateTime = DateTime(
            now.year,
            now.month,
            now.day,
            hour,
            minute,
          );
        }
      }
    }

    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        DateTime selected = initialDateTime;
        return Container(
          decoration: BoxDecoration(
            color: context.tokens.card1,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    'Seleccionar horario',
                    style: TextStyle(
                      color: context.tokens.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context, selected),
                    child: Text(
                      'Listo',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 180,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat: true,
                  initialDateTime: initialDateTime,
                  onDateTimeChanged: (dateTime) {
                    selected = dateTime;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (picked != null) {
      final hour = picked.hour.toString().padLeft(2, '0');
      final minute = picked.minute.toString().padLeft(2, '0');
      controller.text = '$hour:$minute';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.tokens.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    )
                  : _trainings.isEmpty
                  ? _buildEmptyState(context)
                  : _buildTrainingsList(context),
            ),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        width: 56,
        height: 56,
        child: FloatingActionButton(
          onPressed: () {
            if (widget.teamId != null && widget.teamName != null) {
              final teamNameEncoded = Uri.encodeComponent(widget.teamName!);
              context.push(
                '/trainings/create?teamId=${widget.teamId}&teamName=$teamNameEncoded',
              );
            } else {
              context.push('/trainings/create');
            }
          },
          backgroundColor: Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: const [
              Icon(Symbols.sports_volleyball, color: Colors.white, size: 26),
              Positioned(
                top: 8,
                right: 8,
                child: Icon(Symbols.add, color: Colors.white, size: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
                Symbols.filter_alt,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Filtro',
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fecha de inicio',
                      style: TextStyle(
                        color: context.tokens.text,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _startDateController,
                      readOnly: true,
                      onTap: () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: now,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          _startDateController.text =
                              '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'DD/MM/AAAA',
                        hintStyle: TextStyle(color: context.tokens.placeholder),
                        suffixIcon: Icon(
                          Symbols.calendar_month,
                          color: context.tokens.placeholder,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: context.tokens.stroke),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      style: TextStyle(
                        color: context.tokens.text,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fecha de fin',
                      style: TextStyle(
                        color: context.tokens.text,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _endDateController,
                      readOnly: true,
                      onTap: () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: now,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          _endDateController.text =
                              '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'DD/MM/AAAA',
                        hintStyle: TextStyle(color: context.tokens.placeholder),
                        suffixIcon: Icon(
                          Symbols.calendar_month,
                          color: context.tokens.placeholder,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: context.tokens.stroke),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
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
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hora de inicio',
                      style: TextStyle(
                        color: context.tokens.text,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _startTimeController,
                      readOnly: true,
                      onTap: () => _pickTime(_startTimeController),
                      decoration: InputDecoration(
                        hintText: 'HH:MM',
                        hintStyle: TextStyle(color: context.tokens.placeholder),
                        suffixIcon: Icon(
                          Symbols.schedule,
                          color: context.tokens.placeholder,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: context.tokens.stroke),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      style: TextStyle(
                        color: context.tokens.text,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hora de fin',
                      style: TextStyle(
                        color: context.tokens.text,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _endTimeController,
                      readOnly: true,
                      onTap: () => _pickTime(_endTimeController),
                      decoration: InputDecoration(
                        hintText: 'HH:MM',
                        hintStyle: TextStyle(color: context.tokens.placeholder),
                        suffixIcon: Icon(
                          Symbols.schedule,
                          color: context.tokens.placeholder,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: context.tokens.stroke),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
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
          const SizedBox(height: 16),
          Text(
            'Filtrar por:',
            style: TextStyle(color: context.tokens.text, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildStatusChip(context, 'Próximos', TrainingStatus.proximo),
              const SizedBox(width: 8),
              _buildStatusChip(
                context,
                'Completados',
                TrainingStatus.completado,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(
    BuildContext context,
    String label,
    TrainingStatus status,
  ) {
    final isSelected = _selectedStatus == status;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedStatus = isSelected ? null : status;
          _currentPage = 0;
        });
        _loadTrainings();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : context.tokens.stroke,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : context.tokens.text,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Symbols.sports, size: 64, color: context.tokens.placeholder),
          const SizedBox(height: 16),
          Text(
            widget.teamName != null
                ? 'No hay entrenamientos para ${widget.teamName}'
                : 'No hay entrenamientos',
            style: TextStyle(
              color: context.tokens.text,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agregá un entrenamiento para comenzar',
            style: TextStyle(color: context.tokens.placeholder, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainingsList(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _trainings.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildFilterSection(context);
              }

              final trainingIndex = index - 1;
              final training = _trainings[trainingIndex];
              return _buildTrainingCard(context, training);
            },
          ),
        ),
        if (_totalPages > 1) _buildPagination(context),
      ],
    );
  }

  Widget _buildPagination(BuildContext context) {
    final startIndex = _currentPage * _itemsPerPage + 1;
    final endIndex = (_currentPage * _itemsPerPage) + _trainings.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.tokens.background,
        border: Border(top: BorderSide(color: context.tokens.stroke)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(
              Symbols.keyboard_double_arrow_left,
              color: _hasPrevious
                  ? context.tokens.text
                  : context.tokens.placeholder,
            ),
            onPressed: _hasPrevious ? () => _goToPage(0) : null,
          ),
          IconButton(
            icon: Icon(
              Symbols.chevron_left,
              color: _hasPrevious
                  ? context.tokens.text
                  : context.tokens.placeholder,
            ),
            onPressed: _hasPrevious ? () => _goToPage(_currentPage - 1) : null,
          ),
          const SizedBox(width: 8),
          Text(
            '$startIndex-$endIndex de $_totalElements',
            style: TextStyle(color: context.tokens.text, fontSize: 14),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              Symbols.chevron_right,
              color: _hasNext
                  ? context.tokens.text
                  : context.tokens.placeholder,
            ),
            onPressed: _hasNext ? () => _goToPage(_currentPage + 1) : null,
          ),
          IconButton(
            icon: Icon(
              Symbols.keyboard_double_arrow_right,
              color: _hasNext
                  ? context.tokens.text
                  : context.tokens.placeholder,
            ),
            onPressed: _hasNext ? () => _goToPage(_totalPages - 1) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildTrainingCard(BuildContext context, Training training) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.tokens.card1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.tokens.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 2, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        training.dateFormatted,
                        style: TextStyle(
                          color: context.tokens.text,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 0,
                      ),
                      decoration: BoxDecoration(
                        color: training.status == TrainingStatus.proximo
                            ? context.tokens.green.withOpacity(0.1)
                            : training.status == TrainingStatus.completado
                            ? Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.1)
                            : context.tokens.placeholder.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        training.status.displayName,
                        style: TextStyle(
                          color: training.status == TrainingStatus.proximo
                              ? context.tokens.green
                              : training.status == TrainingStatus.completado
                              ? Theme.of(context).colorScheme.primary
                              : context.tokens.placeholder,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    PopupMenuButton<_TrainingMenuAction>(
                      icon: Icon(Symbols.more_vert, color: context.tokens.text),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: context.tokens.card1,
                      elevation: 4,
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: _TrainingMenuAction.view,
                          onTap: () {
                            Future.microtask(() {
                              context.push('/trainings/${training.id}');
                            });
                          },
                          child: Text(
                            'Ver',
                            style: TextStyle(color: context.tokens.text),
                          ),
                        ),
                        PopupMenuItem(
                          value: _TrainingMenuAction.edit,
                          onTap: () {
                            Future.microtask(() {
                              context.push('/trainings/${training.id}/edit');
                            });
                          },
                          child: Text(
                            'Modificar',
                            style: TextStyle(color: context.tokens.text),
                          ),
                        ),
                        PopupMenuItem(
                          value: _TrainingMenuAction.delete,
                          onTap: () {
                            Future.microtask(() {
                              _showDeleteDialog(context, training);
                            });
                          },
                          child: Text(
                            'Eliminar',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Transform.translate(
                  offset: const Offset(0, -12),
                  child: Text(
                    'Prof. ${training.professorName} - ${training.totalPlayers} jugadores',
                    style: TextStyle(
                      color: context.tokens.placeholder,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: context.tokens.stroke, height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Symbols.schedule,
                      size: 18,
                      color: context.tokens.placeholder,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${training.startTimeFormatted} - ${training.endTimeFormatted}',
                      style: TextStyle(
                        color: context.tokens.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${training.presentCount}/${training.totalPlayers}',
                      style: TextStyle(
                        color: context.tokens.placeholder,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Symbols.group,
                      size: 18,
                      color: context.tokens.placeholder,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 26),
                  child: Text(
                    training.location,
                    style: TextStyle(
                      color: context.tokens.placeholder,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () =>
                      context.push('/trainings/${training.id}/attendance'),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: context.tokens.card1,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: context.tokens.stroke),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Symbols.check_circle,
                          size: 20,
                          color: context.tokens.text,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Pasar asistencia',
                            style: TextStyle(
                              color: context.tokens.text,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Icon(
                          Symbols.chevron_right,
                          size: 20,
                          color: context.tokens.placeholder,
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
    );
  }

  void _showDeleteDialog(BuildContext context, Training training) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.tokens.card1,
        content: Text(
          '¿Estás seguro de que querés eliminar este entrenamiento?',
          style: TextStyle(color: context.tokens.text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: context.tokens.placeholder),
            ),
          ),
          TextButton(
            onPressed: () async {
              await _repository.deleteTraining(training.id);
              if (context.mounted) {
                Navigator.pop(context);
                _loadTrainings();
              }
            },
            child: Text(
              'Eliminar',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}
