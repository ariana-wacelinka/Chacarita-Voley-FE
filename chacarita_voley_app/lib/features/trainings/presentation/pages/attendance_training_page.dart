import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../users/domain/entities/user.dart' show EstadoCuota;
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
  bool _hasChanges = false;
  bool _isSaving = false;

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

    final updatedAttendances = _training!.attendances.map((attendance) {
      if (attendance.playerId == playerId) {
        return attendance.copyWith(isPresent: !currentValue);
      }
      return attendance;
    }).toList();

    setState(() {
      _training = _training!.copyWith(attendances: updatedAttendances);
      _hasChanges = true;
    });
  }

  Future<void> _saveAttendance() async {
    if (_training == null || !_hasChanges || _isSaving) return;

    print('[_saveAttendance] Iniciando guardado de asistencia');
    setState(() {
      _isSaving = true;
    });

    try {
      await _repository.updateAttendance(
        widget.trainingId,
        _training!.attendances,
      );

      print('[_saveAttendance] Asistencia guardada, actualizando estado');

      if (!mounted) {
        print('[_saveAttendance] Widget no montado después de guardar');
        return;
      }

      setState(() {
        _hasChanges = false;
      });

      print('[_saveAttendance] Mostrando SnackBar');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Asistencia guardada correctamente'),
          backgroundColor: context.tokens.green,
          duration: const Duration(milliseconds: 1500),
        ),
      );

      print('[_saveAttendance] Esperando antes de navegar');

      // Navegar de vuelta al detalle del entrenamiento
      await Future.delayed(const Duration(milliseconds: 400));

      print('[_saveAttendance] Verificando mounted antes de navegar');

      if (!mounted) {
        print('[_saveAttendance] Widget no montado antes de navegar');
        return;
      }

      print('[_saveAttendance] Navegando a detalle del entrenamiento');
      context.pushReplacement('/trainings/${widget.trainingId}');
      print('[_saveAttendance] Navegación completada');
    } catch (e) {
      print('[_saveAttendance] Error al guardar: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar asistencia: $e'),
            backgroundColor: context.tokens.redToRosita,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
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
            fontSize: 20,
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
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Prof. ${training.professorName} - ${training.totalPlayers} jugadores',
                        style: TextStyle(
                          color: context.tokens.placeholder,
                          fontSize: 12,
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
                    itemCount: training.attendances.length + 1,
                    separatorBuilder: (context, index) =>
                        Divider(color: context.tokens.stroke, height: 1),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Symbols.group,
                                size: 20,
                                color: context.tokens.text,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Asistencia',
                                style: TextStyle(
                                  color: context.tokens.text,
                                  fontSize: 20,
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
                        );
                      }

                      final attendance = training.attendances[index - 1];
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

  Widget _buildAttendanceItem(
    BuildContext context,
    PlayerAttendance attendance,
    String playerId,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            child: Text(
              playerId,
              style: TextStyle(color: context.tokens.placeholder, fontSize: 13),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              attendance.playerName,
              style: TextStyle(color: context.tokens.text, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          if (attendance.estadoCuota != null)
            Icon(
              Symbols.credit_card,
              size: 20,
              color: _getPaymentStatusColor(attendance.estadoCuota!, context),
            ),
          const SizedBox(width: 12),
          InkWell(
            onTap: () =>
                _toggleAttendance(attendance.playerId, attendance.isPresent),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: attendance.isPresent
                    ? context.tokens.green
                    : Colors.transparent,
                border: Border.all(
                  color: attendance.isPresent
                      ? context.tokens.green
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
        ],
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
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isSaving ? null : _saveAttendance,
          style: ElevatedButton.styleFrom(
            backgroundColor: context.tokens.gray,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isSaving
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Symbols.check, size: 18, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Guardar asistencia',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Color _getPaymentStatusColor(EstadoCuota estado, BuildContext context) {
    switch (estado) {
      case EstadoCuota.alDia:
        return context.tokens.green;
      case EstadoCuota.vencida:
        return context.tokens.redToRosita;
      case EstadoCuota.ultimoPago:
        return context.tokens.pending;
    }
  }
}
