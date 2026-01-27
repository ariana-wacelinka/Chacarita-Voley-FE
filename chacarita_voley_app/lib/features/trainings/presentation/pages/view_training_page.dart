import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../users/domain/entities/user.dart' show EstadoCuota;
import '../../domain/entities/training.dart';
import '../../data/repositories/training_repository.dart';

class ViewTrainingPage extends StatefulWidget {
  final String trainingId;

  const ViewTrainingPage({super.key, required this.trainingId});

  @override
  State<ViewTrainingPage> createState() => _ViewTrainingPageState();
}

class _ViewTrainingPageState extends State<ViewTrainingPage> {
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
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final teamName = _training?.teamName ?? '';

    return Scaffold(
      backgroundColor: context.tokens.background,
      appBar: AppBar(
        backgroundColor: context.tokens.card1,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Symbols.arrow_back, color: context.tokens.text),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/trainings');
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Detalle del Entrenamiento',
              style: TextStyle(
                color: context.tokens.text,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (teamName.isNotEmpty)
              Text(
                teamName,
                style: TextStyle(
                  color: context.tokens.placeholder,
                  fontSize: 11,
                ),
              ),
          ],
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
          : _buildContent(context, _training!),
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

  Widget _buildContent(BuildContext context, Training training) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(context, training),
                const SizedBox(height: 12),
                _buildAttendanceSection(context, training),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        _buildBottomButtons(context, training),
      ],
    );
  }

  Widget _buildHeaderCard(BuildContext context, Training training) {
    return Container(
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
            style: TextStyle(color: context.tokens.placeholder, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Symbols.schedule,
                      size: 18,
                      color: context.tokens.placeholder,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Horario:',
                          style: TextStyle(
                            color: context.tokens.text,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${training.startTimeFormatted} - ${training.endTimeFormatted}',
                          style: TextStyle(
                            color: context.tokens.text,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Symbols.location_on,
                      size: 18,
                      color: context.tokens.placeholder,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ubicación:',
                            style: TextStyle(
                              color: context.tokens.text,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            training.location,
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
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Symbols.sports, size: 18, color: context.tokens.placeholder),
              const SizedBox(width: 8),
              Text(
                'Tipo de Entrenamiento:',
                style: TextStyle(
                  color: context.tokens.text,
                  fontSize: 14,
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
                  style: TextStyle(color: context.tokens.text, fontSize: 14),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceSection(BuildContext context, Training training) {
    return Container(
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            );
          }

          final attendance = training.attendances[index - 1];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 16,
                  child: Text(
                    attendance.playerId,
                    style: TextStyle(
                      color: context.tokens.placeholder,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
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
                    color: _getPaymentStatusColor(
                      attendance.estadoCuota!,
                      context,
                    ),
                  ),
                const SizedBox(width: 8),
                Icon(
                  attendance.isPresent ? Symbols.check : Symbols.close,
                  color: attendance.isPresent
                      ? context.tokens.green
                      : context.tokens.redToRosita,
                  size: 18,
                ),
              ],
            ),
          );
        },
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
                backgroundColor: context.tokens.secondaryButton,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Symbols.edit, size: 18, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text(
                    'Modificar entrenamiento',
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
