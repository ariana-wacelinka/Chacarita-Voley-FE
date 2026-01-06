import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../app/theme/app_theme.dart';
import '../../domain/entities/training.dart';
import '../../data/repositories/training_repository.dart';

class NewTrainingPage extends StatefulWidget {
  final String? teamId;
  final String? teamName;

  const NewTrainingPage({super.key, this.teamId, this.teamName});

  @override
  State<NewTrainingPage> createState() => _NewTrainingPageState();
}

class _NewTrainingPageState extends State<NewTrainingPage> {
  final _formKey = GlobalKey<FormState>();
  final _repository = TrainingRepository();

  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _locationController = TextEditingController();

  String? _selectedTeamId;
  String? _selectedTeamName;
  TrainingType? _selectedType;

  final List<_TeamOption> _teamOptions = const [
    _TeamOption(id: '1', name: 'Equipo A'),
    _TeamOption(id: '2', name: 'Equipo B'),
    _TeamOption(id: '3', name: 'Equipo C'),
  ];

  final Set<int> _selectedWeekdays = {};

  @override
  void initState() {
    super.initState();
    if (widget.teamId != null && widget.teamName != null) {
      _selectedTeamId = widget.teamId;
      _selectedTeamName = widget.teamName;
    }
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final teamId = _selectedTeamId;
    final teamName = _selectedTeamName;

    if (teamId == null || teamName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Seleccioná un equipo para el entrenamiento'),
          backgroundColor: context.tokens.redToRosita,
        ),
      );
      return;
    }

    final date = _parseDate(_startDateController.text.trim());

    final training = Training(
      id: '',
      teamId: teamId,
      teamName: teamName,
      professorId: '4',
      professorName: 'Profesor 1',
      date: date,
      startTime: _startTimeController.text.trim(),
      endTime: _endTimeController.text.trim(),
      location: _locationController.text.trim(),
      type: _selectedType ?? TrainingType.fisico,
      status: TrainingStatus.proximo,
      attendances: const [],
    );

    try {
      await _repository.createTraining(training);

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
                  'Entrenamiento registrado exitosamente',
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

      context.go('/trainings');
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
                  'Error al registrar entrenamiento',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: context.tokens.redToRosita,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  DateTime _parseDate(String text) {
    final parts = text.split('/');
    if (parts.length == 3) {
      final day = int.tryParse(parts[0]) ?? 1;
      final month = int.tryParse(parts[1]) ?? 1;
      final year = int.tryParse(parts[2]) ?? DateTime.now().year;
      return DateTime(year, month, day);
    }
    return DateTime.now();
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
          onPressed: () => context.go('/trainings'),
        ),
        title: Text(
          'Nuevo Entrenamiento',
          style: TextStyle(
            color: context.tokens.text,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTeamCard(context),
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
                      backgroundColor: context.tokens.redToRosita,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Registrar entrenamiento',
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

  Widget _buildTeamCard(BuildContext context) {
    final isFixedTeam = widget.teamId != null && widget.teamName != null;

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
          if (isFixedTeam)
            Text(
              'Equipo: ${widget.teamName}',
              style: TextStyle(
                color: context.tokens.text,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            )
          else
            DropdownButtonFormField<String>(
              value: _selectedTeamId,
              decoration: const InputDecoration(
                labelText: 'Seleccionar equipo',
              ),
              items: _teamOptions
                  .map(
                    (t) => DropdownMenuItem(value: t.id, child: Text(t.name)),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTeamId = value;
                  _selectedTeamName = _teamOptions
                      .firstWhere((t) => t.id == value)
                      .name;
                });
              },
              validator: (value) {
                if (!isFixedTeam && (value == null || value.isEmpty)) {
                  return 'Seleccioná un equipo';
                }
                return null;
              },
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
                      keyboardType: TextInputType.datetime,
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
                      keyboardType: TextInputType.datetime,
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
                      keyboardType: TextInputType.datetime,
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
                      keyboardType: TextInputType.datetime,
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
          const SizedBox(height: 16),
          Text(
            'Repetir los días...',
            style: TextStyle(color: context.tokens.text, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(7, (index) {
              const labels = [
                'Lunes',
                'Martes',
                'Miércoles',
                'Jueves',
                'Viernes',
                'Sábado',
                'Domingo',
              ];
              final isSelected = _selectedWeekdays.contains(index);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedWeekdays.remove(index);
                    } else {
                      _selectedWeekdays.add(index);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? context.tokens.redToRosita
                        : context.tokens.card1,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: context.tokens.stroke),
                  ),
                  child: Text(
                    labels[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : context.tokens.text,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }),
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

class _TeamOption {
  final String id;
  final String name;

  const _TeamOption({required this.id, required this.name});
}
