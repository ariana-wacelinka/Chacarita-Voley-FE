import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../../app/theme/app_theme.dart';
import '../../domain/entities/training.dart';
import '../../data/repositories/training_repository.dart';

class TrainingsPage extends StatefulWidget {
  const TrainingsPage({super.key});

  @override
  State<TrainingsPage> createState() => _TrainingsPageState();
}

class _TrainingsPageState extends State<TrainingsPage> {
  final _repository = TrainingRepository();
  List<Training> _trainings = [];
  bool _isLoading = true;
  bool _showFilters = false;

  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();

  TrainingStatus? _selectedStatus;

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
          _trainings = trainings;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _toggleFilters() {
    setState(() => _showFilters = !_showFilters);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.tokens.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            if (_showFilters) _buildFilterSection(context),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/trainings/create'),
        backgroundColor: context.tokens.redToRosita,
        child: const Icon(Symbols.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.tokens.card1,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Entrenamientos',
              style: TextStyle(
                color: context.tokens.text,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: context.tokens.redToRosita,
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              onPressed: _toggleFilters,
              icon: Icon(
                _showFilters ? Symbols.filter_alt_off : Symbols.filter_alt,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.tokens.card1,
        border: Border(bottom: BorderSide(color: context.tokens.stroke)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Symbols.filter_alt,
                color: context.tokens.redToRosita,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Filtro',
                style: TextStyle(
                  color: context.tokens.redToRosita,
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
                      'Fecha de inicio *',
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
                      'Fecha de fin *',
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
                      'Hora de inicio *',
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
                      'Hora de fin *',
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
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _trainings.length,
      itemBuilder: (context, index) {
        final training = _trainings[index];
        return _buildTrainingCard(context, training);
      },
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
            padding: const EdgeInsets.all(16),
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
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
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
                    IconButton(
                      onPressed: () => _showOptionsMenu(context, training),
                      icon: Icon(Symbols.more_vert, color: context.tokens.text),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Prof. ${training.professorName} - ${training.teamName}',
                  style: TextStyle(
                    color: context.tokens.placeholder,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Symbols.schedule,
                      size: 16,
                      color: context.tokens.placeholder,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${training.startTime} - ${training.endTime}',
                      style: TextStyle(
                        color: context.tokens.text,
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Symbols.group,
                      size: 16,
                      color: context.tokens.placeholder,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${training.presentCount}/${training.totalPlayers}',
                      style: TextStyle(
                        color: context.tokens.text,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(color: context.tokens.stroke, height: 1),
          InkWell(
            onTap: () => context.push('/trainings/${training.id}/attendance'),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    Symbols.check_circle,
                    size: 18,
                    color: context.tokens.text,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Pasar asistencia',
                    style: TextStyle(
                      color: context.tokens.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Symbols.chevron_right,
                    size: 18,
                    color: context.tokens.placeholder,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showOptionsMenu(BuildContext context, Training training) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.tokens.card1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Symbols.visibility, color: context.tokens.text),
            title: Text('Ver', style: TextStyle(color: context.tokens.text)),
            onTap: () {
              Navigator.pop(context);
              context.push('/trainings/${training.id}');
            },
          ),
          ListTile(
            leading: Icon(Symbols.edit, color: context.tokens.text),
            title: Text(
              'Modificar',
              style: TextStyle(color: context.tokens.text),
            ),
            onTap: () {
              Navigator.pop(context);
              context.push('/trainings/${training.id}/edit');
            },
          ),
          ListTile(
            leading: Icon(Symbols.delete, color: context.tokens.redToRosita),
            title: Text(
              'Eliminar',
              style: TextStyle(color: context.tokens.redToRosita),
            ),
            onTap: () {
              Navigator.pop(context);
              _showDeleteDialog(context, training);
            },
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
        title: Text(
          '¿Eliminar entrenamiento?',
          style: TextStyle(color: context.tokens.text),
        ),
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
