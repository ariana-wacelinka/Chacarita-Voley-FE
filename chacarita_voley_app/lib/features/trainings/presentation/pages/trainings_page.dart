import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../../app/theme/app_theme.dart';
import '../../domain/entities/training.dart';
import '../../data/repositories/training_repository.dart';

enum _TrainingMenuAction { view, edit, delete }

class TrainingsPage extends StatefulWidget {
  const TrainingsPage({super.key});

  @override
  State<TrainingsPage> createState() => _TrainingsPageState();
}

class _TrainingsPageState extends State<TrainingsPage> {
  final _repository = TrainingRepository();
  List<Training> _trainings = [];
  List<Training> _allTrainings = [];
  bool _isLoading = true;

  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();

  TrainingStatus? _selectedStatus;

  int _currentPage = 0;
  final int _itemsPerPage = 10;
  int get _totalPages => (_allTrainings.length / _itemsPerPage).ceil();

  @override
  void initState() {
    super.initState();
    _loadTrainings();
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
      final trainings = await _repository.getTrainings(status: _selectedStatus);
      if (mounted) {
        setState(() {
          _allTrainings = trainings;
          _currentPage = 0;
          _updatePagedTrainings();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _updatePagedTrainings() {
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(
      0,
      _allTrainings.length,
    );
    _trainings = _allTrainings.sublist(startIndex, endIndex);
  }

  void _goToPage(int page) {
    if (page >= 0 && page < _totalPages) {
      setState(() {
        _currentPage = page;
        _updatePagedTrainings();
      });
    }
  }

  void _toggleFilters() {}

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
                          context.tokens.redToRosita,
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
          onPressed: () => context.push('/trainings/create'),
          backgroundColor: context.tokens.redToRosita,
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
                color: context.tokens.redToRosita,
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
        });
        _loadTrainings();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? context.tokens.redToRosita : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? context.tokens.redToRosita
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
            'No hay entrenamientos',
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
            icon: Icon(Symbols.chevron_left, color: context.tokens.text),
            onPressed: _currentPage > 0
                ? () => _goToPage(_currentPage - 1)
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            'Página ${_currentPage + 1} de $_totalPages',
            style: TextStyle(color: context.tokens.text, fontSize: 14),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Symbols.chevron_right, color: context.tokens.text),
            onPressed: _currentPage < _totalPages - 1
                ? () => _goToPage(_currentPage + 1)
                : null,
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
                            ? context.tokens.redToRosita.withOpacity(0.1)
                            : context.tokens.placeholder.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        training.status.displayName,
                        style: TextStyle(
                          color: training.status == TrainingStatus.proximo
                              ? context.tokens.green
                              : training.status == TrainingStatus.completado
                              ? context.tokens.redToRosita
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
                      onSelected: (action) {
                        switch (action) {
                          case _TrainingMenuAction.view:
                            context.push('/trainings/${training.id}');
                            break;
                          case _TrainingMenuAction.edit:
                            context.push('/trainings/${training.id}/edit');
                            break;
                          case _TrainingMenuAction.delete:
                            _showDeleteDialog(context, training);
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: _TrainingMenuAction.view,
                          child: Text(
                            'Ver',
                            style: TextStyle(color: context.tokens.text),
                          ),
                        ),
                        PopupMenuItem(
                          value: _TrainingMenuAction.edit,
                          child: Text(
                            'Modificar',
                            style: TextStyle(color: context.tokens.text),
                          ),
                        ),
                        PopupMenuItem(
                          value: _TrainingMenuAction.delete,
                          child: Text(
                            'Eliminar',
                            style: TextStyle(color: context.tokens.redToRosita),
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
                      '${training.startTime} - ${training.endTime}',
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
              style: TextStyle(color: context.tokens.redToRosita),
            ),
          ),
        ],
      ),
    );
  }
}
