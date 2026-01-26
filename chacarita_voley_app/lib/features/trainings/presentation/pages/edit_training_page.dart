import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../app/theme/app_theme.dart';
import '../../domain/entities/training.dart';
import '../../data/repositories/training_repository.dart';

class EditTrainingPage extends StatefulWidget {
  final String trainingId;

  const EditTrainingPage({super.key, required this.trainingId});

  @override
  State<EditTrainingPage> createState() => _EditTrainingPageState();
}

class _EditTrainingPageState extends State<EditTrainingPage> {
  final _formKey = GlobalKey<FormState>();
  final _repository = TrainingRepository();

  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _locationController = TextEditingController();

  TrainingType? _selectedType;
  DayOfWeek? _selectedDayOfWeek;
  Training? _originalTraining;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTraining();
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadTraining() async {
    setState(() => _isLoading = true);
    try {
      final training = await _repository.getTrainingById(widget.trainingId);
      print('[EditTraining] Training cargado: ${training?.id}');
      print('[EditTraining] startDate: ${training?.startDate}');
      print('[EditTraining] endDate: ${training?.endDate}');
      print('[EditTraining] startTime: ${training?.startTime}');
      print('[EditTraining] endTime: ${training?.endTime}');

      if (!mounted) return;

      if (training != null) {
        _originalTraining = training;

        // Cargar fechas de inicio y fin si existen
        if (training.startDate != null) {
          final startDate = training.startDate!;
          final formattedStartDate =
              '${startDate.day.toString().padLeft(2, '0')}/${startDate.month.toString().padLeft(2, '0')}/${startDate.year}';
          _startDateController.text = formattedStartDate;
          print(
            '[EditTraining] startDateController.text = $formattedStartDate',
          );
        } else {
          print('[EditTraining] startDate es null');
        }

        if (training.endDate != null) {
          final endDate = training.endDate!;
          final formattedEndDate =
              '${endDate.day.toString().padLeft(2, '0')}/${endDate.month.toString().padLeft(2, '0')}/${endDate.year}';
          _endDateController.text = formattedEndDate;
          print('[EditTraining] endDateController.text = $formattedEndDate');
        } else {
          print('[EditTraining] endDate es null');
        }

        _startTimeController.text = training.startTime;
        _endTimeController.text = training.endTime;
        _locationController.text = training.location;
        _selectedType = training.type;
        _selectedDayOfWeek = training.dayOfWeek;
      } else {
        print('[EditTraining] training es null');
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('[EditTraining] Error al cargar training: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _originalTraining?.startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        _startDateController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _originalTraining?.endDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        _endDateController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  Future<void> _selectStartTime() async {
    final currentTime = _parseTime(_startTimeController.text);
    final picked = await showTimePicker(
      context: context,
      initialTime: currentTime,
    );

    if (picked != null) {
      setState(() {
        _startTimeController.text =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _selectEndTime() async {
    final currentTime = _parseTime(_endTimeController.text);
    final picked = await showTimePicker(
      context: context,
      initialTime: currentTime,
    );

    if (picked != null) {
      setState(() {
        _endTimeController.text =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  TimeOfDay _parseTime(String time) {
    if (time.isEmpty) return TimeOfDay.now();
    final parts = time.split(':');
    if (parts.length != 2) return TimeOfDay.now();
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_originalTraining == null) return;

    final startTime = _startTimeController.text.trim();
    final endTime = _endTimeController.text.trim();

    if (startTime.isNotEmpty && endTime.isNotEmpty) {
      final startParts = startTime.split(':');
      final endParts = endTime.split(':');
      if (startParts.length == 2 && endParts.length == 2) {
        final startHour = int.tryParse(startParts[0]);
        final startMinute = int.tryParse(startParts[1]);
        final endHour = int.tryParse(endParts[0]);
        final endMinute = int.tryParse(endParts[1]);

        if (startHour != null &&
            startMinute != null &&
            endHour != null &&
            endMinute != null) {
          final now = DateTime.now();
          final start = DateTime(
            now.year,
            now.month,
            now.day,
            startHour,
            startMinute,
          );
          final end = DateTime(
            now.year,
            now.month,
            now.day,
            endHour,
            endMinute,
          );

          if (end.isBefore(start) || end.isAtSameMomentAs(start)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'La hora de fin debe ser posterior a la hora de inicio',
                ),
                backgroundColor: context.tokens.redToRosita,
              ),
            );
            return;
          }
        }
      }
    }

    final updated = _originalTraining!.copyWith(
      dayOfWeek: _selectedDayOfWeek ?? _originalTraining!.dayOfWeek,
      startTime: startTime,
      endTime: endTime,
      location: _locationController.text.trim(),
      type: _selectedType ?? _originalTraining!.type,
    );

    try {
      await _repository.updateTraining(updated);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Entrenamiento actualizado exitosamente',
                  style: TextStyle(
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          duration: const Duration(seconds: 3),
        ),
      );

      context.pop(true);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Error al actualizar entrenamiento',
                  style: TextStyle(
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          duration: const Duration(seconds: 3),
        ),
      );
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
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Editar Entrenamiento',
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
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            )
          : _originalTraining == null
          ? _buildErrorState(context)
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTeamSummaryCard(context),
                      const SizedBox(height: 16),
                      _buildDateTimeCard(context),
                      const SizedBox(height: 16),
                      _buildDetailsCard(context),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Guardar cambios',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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

  Widget _buildTeamSummaryCard(BuildContext context) {
    final training = _originalTraining!;

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
              Icon(
                Symbols.sports_volleyball,
                color: context.tokens.text,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Equipo',
                style: TextStyle(
                  color: context.tokens.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Equipo: ${training.teamName}',
            style: TextStyle(
              color: context.tokens.text,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeCard(BuildContext context) {
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
              Icon(
                Symbols.calendar_month,
                color: context.tokens.text,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Fecha y horario',
                style: TextStyle(
                  color: context.tokens.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Día de la semana *',
            style: TextStyle(color: context.tokens.text, fontSize: 12),
          ),
          const SizedBox(height: 4),
          DropdownButtonFormField<DayOfWeek>(
            value: _selectedDayOfWeek,
            decoration: InputDecoration(
              hintText: 'Seleccioná el día',
              prefixIcon: Icon(
                Symbols.calendar_today,
                color: context.tokens.placeholder,
              ),
            ),
            items: DayOfWeek.values.map((day) {
              return DropdownMenuItem<DayOfWeek>(
                value: day,
                child: Text(day.displayName),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedDayOfWeek = value;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Seleccioná un día';
              }
              return null;
            },
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
                    TextFormField(
                      controller: _startDateController,
                      decoration: InputDecoration(
                        hintText: 'DD/MM/AAAA',
                        suffixIcon: Icon(
                          Symbols.calendar_month,
                          color: context.tokens.placeholder,
                        ),
                      ),
                      readOnly: true,
                      onTap: _selectStartDate,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingresá una fecha';
                        }
                        return null;
                      },
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
                    TextFormField(
                      controller: _endDateController,
                      decoration: InputDecoration(
                        hintText: 'DD/MM/AAAA',
                        suffixIcon: Icon(
                          Symbols.calendar_month,
                          color: context.tokens.placeholder,
                        ),
                      ),
                      readOnly: true,
                      onTap: _selectEndDate,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingresá una fecha';
                        }
                        return null;
                      },
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
                    TextFormField(
                      controller: _startTimeController,
                      decoration: InputDecoration(
                        hintText: 'HH:MM',
                        suffixIcon: Icon(
                          Symbols.schedule,
                          color: context.tokens.placeholder,
                        ),
                      ),
                      readOnly: true,
                      onTap: _selectStartTime,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingresá una hora';
                        }
                        return null;
                      },
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
                    TextFormField(
                      controller: _endTimeController,
                      decoration: InputDecoration(
                        hintText: 'HH:MM',
                        suffixIcon: Icon(
                          Symbols.schedule,
                          color: context.tokens.placeholder,
                        ),
                      ),
                      readOnly: true,
                      onTap: _selectEndTime,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingresá una hora';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context) {
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
              Icon(Symbols.info, color: context.tokens.text, size: 20),
              const SizedBox(width: 8),
              Text(
                'Detalles',
                style: TextStyle(
                  color: context.tokens.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Ubicación *',
            style: TextStyle(color: context.tokens.text, fontSize: 12),
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: _locationController,
            decoration: const InputDecoration(
              hintText: 'Ej: Gimnasio Principal',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Ingresá una ubicación';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Tipo de entrenamiento *',
            style: TextStyle(color: context.tokens.text, fontSize: 12),
          ),
          const SizedBox(height: 4),
          DropdownButtonFormField<TrainingType>(
            value: _selectedType,
            decoration: const InputDecoration(hintText: 'Seleccionar...'),
            items: TrainingType.values
                .map(
                  (type) => DropdownMenuItem(
                    value: type,
                    child: Text(type.displayName),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedType = value;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Seleccioná un tipo';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
