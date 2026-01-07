import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../teams/domain/entities/team.dart';
import '../../../teams/data/repositories/team_repository.dart';
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

  late final TeamRepository _teamRepository;

  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _locationController = TextEditingController();

  String? _selectedTeamId;
  String? _selectedTeamName;
  TrainingType? _selectedType;

  List<Team> _teams = [];
  bool _isLoadingTeams = false;

  final Set<int> _selectedWeekdays = {};

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
                      style: TextStyle(color: context.tokens.redToRosita),
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
  void initState() {
    super.initState();

    _teamRepository = TeamRepository();

    if (widget.teamId != null && widget.teamName != null) {
      _selectedTeamId = widget.teamId;
      _selectedTeamName = widget.teamName;
    } else {
      _loadTeams();
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

  Future<void> _loadTeams() async {
    setState(() {
      _isLoadingTeams = true;
    });

    try {
      final teams = await _teamRepository.getTeams();
      if (!mounted) return;

      setState(() {
        _teams = teams;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingTeams = false;
        });
      }
    }
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

      if (widget.teamId != null && widget.teamName != null) {
        final teamNameEncoded = Uri.encodeComponent(widget.teamName!);
        context.go(
          '/trainings?teamId=${widget.teamId}&teamName=$teamNameEncoded',
        );
      } else {
        context.go('/trainings');
      }
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
          onPressed: () {
            if (widget.teamId != null && widget.teamName != null) {
              final teamNameEncoded = Uri.encodeComponent(widget.teamName!);
              context.go(
                '/trainings?teamId=${widget.teamId}&teamName=$teamNameEncoded',
              );
            } else {
              context.go('/trainings');
            }
          },
        ),
        title: Text(
          'Nuevo Entrenamiento',
          style: TextStyle(
            color: context.tokens.text,
            fontSize: 20,
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
            Builder(
              builder: (context) {
                if (_isLoadingTeams) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: LinearProgressIndicator(minHeight: 2),
                  );
                }

                if (_teams.isEmpty) {
                  return Text(
                    'No hay equipos disponibles',
                    style: TextStyle(
                      color: context.tokens.placeholder,
                      fontSize: 13,
                    ),
                  );
                }

                return DropdownButtonFormField<String>(
                  value: _selectedTeamId,
                  decoration: const InputDecoration(
                    labelText: 'Seleccionar equipo',
                  ),
                  items: _teams
                      .map(
                        (team) => DropdownMenuItem(
                          value: team.id,
                          child: Text(team.nombre),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTeamId = value;
                      _selectedTeamName = _teams
                          .firstWhere((t) => t.id == value)
                          .nombre;
                    });
                  },
                  validator: (value) {
                    if (!isFixedTeam && (value == null || value.isEmpty)) {
                      return 'Seleccioná un equipo';
                    }
                    return null;
                  },
                );
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
                        suffixIcon: Icon(
                          Symbols.calendar_month,
                          color: context.tokens.placeholder,
                        ),
                      ),
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
                        suffixIcon: Icon(
                          Symbols.calendar_month,
                          color: context.tokens.placeholder,
                        ),
                      ),
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
                      readOnly: true,
                      onTap: () => _pickTime(_startTimeController),
                      decoration: InputDecoration(
                        hintText: 'HH:MM',
                        suffixIcon: Icon(
                          Symbols.schedule,
                          color: context.tokens.placeholder,
                        ),
                      ),
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
                      readOnly: true,
                      onTap: () => _pickTime(_endTimeController),
                      decoration: InputDecoration(
                        hintText: 'HH:MM',
                        suffixIcon: Icon(
                          Symbols.schedule,
                          color: context.tokens.placeholder,
                        ),
                      ),
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
