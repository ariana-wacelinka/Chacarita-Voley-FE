import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../../app/theme/app_theme.dart';
import '../../domain/entities/training.dart';
import '../../data/repositories/training_repository.dart';

class AttendanceTrainingPage extends StatefulWidget {
  final String trainingId;

  const AttendanceTrainingPage({super.key, required this.trainingId});

  @override
  State<AttendanceTrainingPage> createState() => _AttendanceTrainingPageState();
}

class _AttendanceTrainingPageState extends State<AttendanceTrainingPage> {
  final _repository = TrainingRepository();
  Training? _training;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTraining();
  }

  Future<void> _loadTraining() async {
    setState(() => _isLoading = true);
    try {
      final training = await _repository.getTrainingById(widget.trainingId);
      if (mounted) {
        setState(() {
          _training = training;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _toggleAttendance(String playerId, bool currentValue) async {
    if (_training == null) return;

    try {
      final updatedAttendances = _training!.attendances.map((attendance) {
        if (attendance.playerId == playerId) {
          return attendance.copyWith(isPresent: !currentValue);
        }
        return attendance;
      }).toList();

      await _repository.updateAttendance(widget.trainingId, updatedAttendances);
      await _loadTraining();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar asistencia: $e'),
            backgroundColor: context.tokens.redToRosita,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.tokens.background,
      appBar: AppBar(
        backgroundColor: context.tokens.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Symbols.arrow_back, color: context.tokens.text),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Pasar Asistencia',
          style: TextStyle(
            color: context.tokens.text,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  context.tokens.redToRosita,
                ),
              ),
            )
          : _training == null
          ? _buildErrorState(context)
          : _buildContent(context),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Symbols.error, size: 64, color: context.tokens.placeholder),
          const SizedBox(height: 16),
          Text(
            'Entrenamiento no encontrado',
            style: TextStyle(
              color: context.tokens.text,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final training = _training!;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
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
                            Symbols.calendar_month,
                            size: 24,
                            color: context.tokens.text,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            training.dateFormatted,
                            style: TextStyle(
                              color: context.tokens.text,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 32),
                        child: Text(
                          'Prof. ${training.professorName} - ${training.totalPlayers} jugadores',
                          style: TextStyle(
                            color: context.tokens.placeholder,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
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
                                      'Horario:',
                                      style: TextStyle(
                                        color: context.tokens.text,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Padding(
                                  padding: const EdgeInsets.only(left: 26),
                                  child: Text(
                                    '${training.startTime} - ${training.endTime}',
                                    style: TextStyle(
                                      color: context.tokens.text,
                                      fontSize: 13,
                                    ),
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
                                Row(
                                  children: [
                                    Icon(
                                      Symbols.location_on,
                                      size: 18,
                                      color: context.tokens.placeholder,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Ubicación:',
                                      style: TextStyle(
                                        color: context.tokens.text,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Padding(
                                  padding: const EdgeInsets.only(left: 26),
                                  child: Text(
                                    training.location,
                                    style: TextStyle(
                                      color: context.tokens.text,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(
                            Symbols.sports,
                            size: 18,
                            color: context.tokens.placeholder,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Tipo de Entrenamiento:',
                            style: TextStyle(
                              color: context.tokens.text,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 26),
                        child: Row(
                          children: [
                            Text(
                              training.type.displayName,
                              style: TextStyle(
                                color: context.tokens.text,
                                fontSize: 13,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: training.status == TrainingStatus.proximo
                                    ? context.tokens.green.withOpacity(0.1)
                                    : training.status ==
                                          TrainingStatus.completado
                                    ? context.tokens.redToRosita.withOpacity(
                                        0.1,
                                      )
                                    : context.tokens.placeholder.withOpacity(
                                        0.1,
                                      ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                training.status.displayName,
                                style: TextStyle(
                                  color:
                                      training.status == TrainingStatus.proximo
                                      ? context.tokens.green
                                      : training.status ==
                                            TrainingStatus.completado
                                      ? context.tokens.redToRosita
                                      : context.tokens.placeholder,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Icon(Symbols.group, size: 20, color: context.tokens.text),
                      const SizedBox(width: 8),
                      Text(
                        'Asistencia',
                        style: TextStyle(
                          color: context.tokens.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${training.presentCount}/${training.totalPlayers}',
                        style: TextStyle(
                          color: context.tokens.text,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: context.tokens.card1,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.tokens.stroke),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: training.attendances.length,
                    separatorBuilder: (context, index) =>
                        Divider(color: context.tokens.stroke, height: 1),
                    itemBuilder: (context, index) {
                      final attendance = training.attendances[index];
                      return _buildAttendanceItem(
                        context,
                        attendance,
                        attendance.playerId,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        _buildBottomButtons(context, training),
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: context.tokens.placeholder),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: context.tokens.text,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: TextStyle(color: context.tokens.text, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceItem(
    BuildContext context,
    PlayerAttendance attendance,
    String playerId,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: SizedBox(
        width: 0,
        child: Text(
          playerId,
          style: TextStyle(color: context.tokens.placeholder, fontSize: 13),
        ),
      ),
      title: Text(
        attendance.playerName,
        style: TextStyle(color: context.tokens.text, fontSize: 14),
      ),
      trailing: InkWell(
        onTap: () =>
            _toggleAttendance(attendance.playerId, attendance.isPresent),
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: attendance.isPresent
                ? context.tokens.redToRosita
                : Colors.transparent,
            border: Border.all(
              color: attendance.isPresent
                  ? context.tokens.redToRosita
                  : context.tokens.stroke,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: attendance.isPresent
              ? Icon(Symbols.check, size: 16, color: Colors.white)
              : null,
        ),
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context, Training training) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: BoxDecoration(
        color: context.tokens.background,
        border: Border(top: BorderSide(color: context.tokens.stroke)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.push('/trainings/${training.id}/edit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.tokens.card1,
                foregroundColor: context.tokens.text,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: context.tokens.stroke),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Symbols.edit, size: 18, color: context.tokens.text),
                  const SizedBox(width: 8),
                  const Text(
                    'Modificar entrenamiento',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showDeleteDialog(context, training),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.tokens.redToRosita,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Symbols.delete, size: 18, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Eliminar entrenamiento',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
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
                context.go('/trainings');
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
