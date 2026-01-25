import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../../app/theme/app_theme.dart';
import '../../domain/entities/training.dart';
import '../../data/repositories/training_repository.dart';

enum _TrainingMenuAction { view, edit, delete, cancel, reactivate }

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

  Future<void> _handleDeleteSession(Training training) async {
    setState(() => _isLoading = true);

    try {
      await _repository.deleteSession(training.id);

      if (!mounted) return;

      setState(() {
        _trainings = [];
        _currentPage = 0;
      });

      await _loadTrainings();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Entrenamiento eliminado exitosamente'),
          backgroundColor: context.tokens.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar el entrenamiento: $e'),
          backgroundColor: context.tokens.redToRosita,
        ),
      );
    }
  }

  Future<void> _handleDeleteTraining(Training training) async {
    setState(() => _isLoading = true);

    try {
      final trainingId = training.trainingId ?? training.id;
      await _repository.deleteTraining(trainingId);

      if (!mounted) return;

      setState(() {
        _trainings = [];
        _currentPage = 0;
      });

      await _loadTrainings();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Entrenamiento eliminado exitosamente'),
          backgroundColor: context.tokens.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar el entrenamiento: $e'),
          backgroundColor: context.tokens.redToRosita,
        ),
      );
    }
  }

  Future<void> _handleCancelSession(Training training) async {
    setState(() => _isLoading = true);

    try {
      await _repository.cancelSession(training.id);

      if (!mounted) return;

      setState(() => _currentPage = 0);

      await _loadTrainings();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Entrenamiento cancelado exitosamente'),
          backgroundColor: context.tokens.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cancelar el entrenamiento: $e'),
          backgroundColor: context.tokens.redToRosita,
        ),
      );
    }
  }

  Future<void> _handleReactivateSession(Training training) async {
    setState(() => _isLoading = true);

    try {
      await _repository.reactivateSession(training.id);

      if (!mounted) return;

      setState(() => _currentPage = 0);

      await _loadTrainings();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Entrenamiento reactivado exitosamente'),
          backgroundColor: context.tokens.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al reactivar el entrenamiento: $e'),
          backgroundColor: context.tokens.redToRosita,
        ),
      );
    }
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

  bool get _hasActiveFilters {
    return _startDateController.text.isNotEmpty ||
        _endDateController.text.isNotEmpty ||
        _startTimeController.text.isNotEmpty ||
        _endTimeController.text.isNotEmpty ||
        _selectedStatus != null;
  }

  Future<void> _loadTrainings() async {
    setState(() => _isLoading = true);
    try {
      // Convertir fechas de DD/MM/AAAA a AAAA-MM-DD para el backend
      String? dateFrom;
      String? dateTo;

      if (_startDateController.text.isNotEmpty) {
        final parts = _startDateController.text.split('/');
        if (parts.length == 3) {
          dateFrom = '${parts[2]}-${parts[1]}-${parts[0]}';
        }
      }

      if (_endDateController.text.isNotEmpty) {
        final parts = _endDateController.text.split('/');
        if (parts.length == 3) {
          dateTo = '${parts[2]}-${parts[1]}-${parts[0]}';
        }
      }

      final result = await _repository.getTrainingsWithPagination(
        dateFrom: dateFrom,
        dateTo: dateTo,
        startTimeFrom: _startTimeController.text.isNotEmpty
            ? _startTimeController.text
            : null,
        startTimeTo: _endTimeController.text.isNotEmpty
            ? _endTimeController.text
            : null,
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
    setState(() {
      _currentPage = page;
    });
    _loadTrainings();
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
      _loadTrainings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.tokens.background,
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: _trainings.isEmpty
                        ? _buildEmptyStateWithFilters(context)
                        : _buildTrainingsList(context),
                  ),
                  if (_totalPages > 1) _buildPagination(context),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              if (_hasActiveFilters)
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _startDateController.clear();
                      _endDateController.clear();
                      _startTimeController.clear();
                      _endTimeController.clear();
                      _selectedStatus = null;
                      _currentPage = 0;
                    });
                    _loadTrainings();
                  },
                  icon: Icon(
                    Symbols.close,
                    color: context.tokens.text,
                    size: 18,
                  ),
                  label: Text(
                    'Limpiar filtros',
                    style: TextStyle(
                      color: context.tokens.text,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
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
                          _loadTrainings();
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
                          _loadTrainings();
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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildStatusChip(context, 'Próximos', TrainingStatus.proximo),
              _buildStatusChip(
                context,
                'Completados',
                TrainingStatus.completado,
              ),
              _buildStatusChip(context, 'Cancelados', TrainingStatus.cancelado),
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

  Widget _buildEmptyStateWithFilters(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildFilterSection(context),
        const SizedBox(height: 100),
        _buildEmptyState(context),
      ],
    );
  }

  Widget _buildTrainingsList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _trainings.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildFilterSection(context),
          );
        }

        final trainingIndex = index - 1;
        final training = _trainings[trainingIndex];
        return _buildTrainingCard(context, training);
      },
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
                            : training.status == TrainingStatus.cancelado
                            ? context.tokens.placeholder.withOpacity(0.1)
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
                              : training.status == TrainingStatus.cancelado
                              ? context.tokens.placeholder
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
                      onSelected: (action) async {
                        switch (action) {
                          case _TrainingMenuAction.view:
                            context.push('/trainings/${training.id}');
                            break;
                          case _TrainingMenuAction.edit:
                            context.push('/trainings/${training.id}/edit');
                            break;
                          case _TrainingMenuAction.delete:
                            final result = await _showDeleteDialog(
                              context,
                              training,
                            );
                            if (result != null && result && mounted) {
                              // _showDeleteDialog ya maneja la confirmación interna
                              // No necesitamos hacer nada aquí
                            }
                            break;
                          case _TrainingMenuAction.cancel:
                            final confirmed = await _showCancelDialog(
                              context,
                              training,
                            );
                            if (confirmed == true && mounted) {
                              await _handleCancelSession(training);
                            }
                            break;
                          case _TrainingMenuAction.reactivate:
                            final confirmed = await _showReactivateDialog(
                              context,
                              training,
                            );
                            if (confirmed == true && mounted) {
                              await _handleReactivateSession(training);
                            }
                            break;
                        }
                      },
                      itemBuilder: (context) {
                        final isCancelled =
                            training.status == TrainingStatus.cancelado;
                        final isFuture =
                            training.status == TrainingStatus.proximo;

                        return [
                          PopupMenuItem(
                            value: _TrainingMenuAction.view,
                            enabled: !isCancelled,
                            child: Text(
                              'Ver',
                              style: TextStyle(
                                color: isCancelled
                                    ? context.tokens.placeholder
                                    : context.tokens.text,
                              ),
                            ),
                          ),
                          PopupMenuItem(
                            value: _TrainingMenuAction.edit,
                            enabled: !isCancelled,
                            child: Text(
                              'Modificar',
                              style: TextStyle(
                                color: isCancelled
                                    ? context.tokens.placeholder
                                    : context.tokens.text,
                              ),
                            ),
                          ),
                          if (isFuture && !isCancelled)
                            PopupMenuItem(
                              value: _TrainingMenuAction.cancel,
                              child: Text(
                                'Cancelar',
                                style: TextStyle(
                                  color: context.tokens.redToRosita,
                                ),
                              ),
                            ),
                          if (isCancelled)
                            PopupMenuItem(
                              value: _TrainingMenuAction.reactivate,
                              child: Text(
                                'Reactivar',
                                style: TextStyle(color: context.tokens.green),
                              ),
                            ),
                          PopupMenuItem(
                            value: _TrainingMenuAction.delete,
                            child: Text(
                              'Eliminar',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ];
                      },
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

  Future<bool?> _showDeleteDialog(
    BuildContext context,
    Training training,
  ) async {
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: context.tokens.card1,
        title: Text(
          '¿Qué querés eliminar?',
          style: TextStyle(color: context.tokens.text),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Podés eliminar solo este entrenamiento o este y todos los posteriores.',
              style: TextStyle(color: context.tokens.placeholder, fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, null),
            child: Text(
              'Cancelar',
              style: TextStyle(color: context.tokens.placeholder),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, 'session'),
            child: Text(
              'Solo este entrenamiento',
              style: TextStyle(color: context.tokens.text),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, 'all'),
            child: Text(
              'Este y todos los posteriores',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
    );

    if (result == 'session') {
      final confirmed = await _showDeleteSessionConfirmation(context, training);
      if (confirmed == true && mounted) {
        await _handleDeleteSession(training);
        return true;
      }
    } else if (result == 'all') {
      final confirmed = await _showDeleteAllConfirmation(context, training);
      if (confirmed == true && mounted) {
        await _handleDeleteTraining(training);
        return true;
      }
    }
    return null;
  }

  Future<bool?> _showDeleteSessionConfirmation(
    BuildContext parentContext,
    Training training,
  ) {
    return showDialog<bool>(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: parentContext.tokens.card1,
        title: Text(
          'Eliminar entrenamiento',
          style: TextStyle(color: parentContext.tokens.text),
        ),
        content: Text(
          '¿Estás seguro de que querés eliminar este entrenamiento del ${training.dateFormatted}?',
          style: TextStyle(color: parentContext.tokens.text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'Cancelar',
              style: TextStyle(color: parentContext.tokens.placeholder),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              'Eliminar',
              style: TextStyle(
                color: Theme.of(parentContext).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDeleteAllConfirmation(
    BuildContext parentContext,
    Training training,
  ) {
    return showDialog<bool>(
      context: parentContext,
      builder: (dialogContext) {
        final confirmController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            backgroundColor: parentContext.tokens.card1,
            title: Text(
              '¡Atención!',
              style: TextStyle(
                color: Theme.of(parentContext).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estás por eliminar este entrenamiento y todos los posteriores. Esta acción no se puede deshacer.',
                  style: TextStyle(color: parentContext.tokens.text),
                ),
                const SizedBox(height: 16),
                Text(
                  'Escribí "ELIMINAR" para confirmar:',
                  style: TextStyle(
                    color: parentContext.tokens.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: confirmController,
                  decoration: InputDecoration(
                    hintText: 'ELIMINAR',
                    hintStyle: TextStyle(
                      color: parentContext.tokens.placeholder,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  style: TextStyle(color: parentContext.tokens.text),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(
                  'Cancelar',
                  style: TextStyle(color: parentContext.tokens.placeholder),
                ),
              ),
              TextButton(
                onPressed: () {
                  if (confirmController.text.trim().toUpperCase() !=
                      'ELIMINAR') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Debés escribir "ELIMINAR" para confirmar',
                        ),
                        backgroundColor: parentContext.tokens.redToRosita,
                      ),
                    );
                    return;
                  }
                  Navigator.pop(dialogContext, true);
                },
                child: Text(
                  'Confirmar',
                  style: TextStyle(
                    color: Theme.of(parentContext).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool?> _showCancelDialog(BuildContext context, Training training) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancelar Entrenamiento'),
        content: const Text(
          '¿Estás seguro de que querés cancelar este entrenamiento?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Volver'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              'Confirmar',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showReactivateDialog(BuildContext context, Training training) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reactivar Entrenamiento'),
        content: const Text(
          '¿Estás seguro de que querés reactivar este entrenamiento?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Volver'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              'Confirmar',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}
