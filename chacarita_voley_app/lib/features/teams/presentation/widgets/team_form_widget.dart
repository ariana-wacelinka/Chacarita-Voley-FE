import 'dart:async';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../users/data/repositories/user_repository.dart';
import '../../../users/domain/entities/user.dart';
import '../../../users/domain/entities/gender.dart';
import '../../domain/entities/team.dart';
import '../../domain/entities/team_detail.dart';
import '../../domain/entities/team_type.dart';

class TeamFormWidget extends StatefulWidget {
  final TeamDetail? team;
  final Function(Team) onSubmit;

  const TeamFormWidget({super.key, this.team, required this.onSubmit});

  @override
  State<TeamFormWidget> createState() => _TeamFormWidgetState();
}

class _TeamFormWidgetState extends State<TeamFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _abreviacionController = TextEditingController();
  final _userRepository = UserRepository();

  TeamType _selectedTipo = TeamType.recreativo;
  List<User> _selectedEntrenadores = [];
  List<User> _playersSearchResults = [];
  List<User> _professorsSearchResults = [];
  List<TeamMember> _integrantes = [];
  String _searchQuery = '';
  bool _isSearching = false;
  bool _professorsLoaded = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadInitialProfessors();
    if (widget.team != null) {
      _nombreController.text = widget.team!.nombre;
      _abreviacionController.text = widget.team!.abreviacion;
      _selectedTipo = widget.team!.tipo;
      _integrantes = List.from(widget.team!.integrantes);
    }
  }

  Future<void> _loadInitialProfessors() async {
    try {
      final professors = await _userRepository.getUsers(
        role: 'PROFESSOR',
        page: 0,
        size: 100,
        forTeamSelection: true,
      );
      if (!mounted) return;

      // Preparar profesores seleccionados ANTES del setState
      final selectedProfessors = <User>[];
      if (widget.team != null && widget.team!.professorIds.isNotEmpty) {
        for (final profId in widget.team!.professorIds) {
          // Buscar en la lista de profesores cargados
          final profesor = professors.firstWhere(
            (u) => u.professorId == profId,
            orElse: () {
              // Si no se encuentra, crear User minimal desde TeamDetail.entrenadores
              final index = widget.team!.professorIds.indexOf(profId);
              final nombreCompleto = index < widget.team!.entrenadores.length
                  ? widget.team!.entrenadores[index]
                  : 'Profesor Desconocido';
              final parts = nombreCompleto.split(' ');
              return User(
                id: 'temp-$profId',
                nombre: parts.isNotEmpty ? parts.first : 'Profesor',
                apellido: parts.length > 1 ? parts.skip(1).join(' ') : '',
                dni: '',
                email: '',
                telefono: '',
                fechaNacimiento: DateTime.now(),
                genero: Gender.masculino,
                equipo: '',
                tipos: {UserType.profesor},
                estadoCuota: EstadoCuota.alDia,
                professorId: profId,
              );
            },
          );
          if (profesor.professorId != null) {
            selectedProfessors.add(profesor);
          }
        }
      }

      // CRÍTICO: MERGE en vez de sobrescribir para evitar race condition
      setState(() {
        _professorsSearchResults = professors;

        // Merge: mantener lo que el usuario ya agregó + lo precargado del team
        final Map<String, User> byProfessorId = {};

        // Primero agregar lo que ya está seleccionado (agregado manualmente)
        for (final u in _selectedEntrenadores) {
          final profId = u.professorId;
          if (profId != null) byProfessorId[profId] = u;
        }

        // Luego agregar/sobrescribir con lo precargado del team
        for (final u in selectedProfessors) {
          final profId = u.professorId;
          if (profId != null) byProfessorId[profId] = u;
        }

        _selectedEntrenadores = byProfessorId.values.toList();
        _professorsLoaded = true;
      });
    } catch (e) {
      // Error silencioso, ya se mostrará en la UI si es necesario
      if (mounted) {
        setState(() {
          _professorsLoaded = true; // Marcar como cargado incluso en error
        });
      }
    }
  }

  Future<void> _loadInitialPlayers() async {
    setState(() {
      _isSearching = true;
    });
    try {
      final players = await _userRepository.getUsers(
        role: 'PLAYER',
        page: 0,
        size: 20,
        forTeamSelection: true,
      );
      if (!mounted) return;
      setState(() {
        _playersSearchResults = players;
        _isSearching = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _playersSearchResults = [];
        _isSearching = false;
      });
    }
  }

  void _searchPlayers(String query) {
    _debounceTimer?.cancel();

    if (query.isEmpty) {
      _loadInitialPlayers();
      return;
    }

    setState(() {
      _isSearching = true;
    });

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      try {
        final results = await _userRepository.getUsers(
          role: 'PLAYER',
          searchQuery: query,
          page: 0,
          size: 20,
          forTeamSelection: true,
        );
        if (!mounted) return;
        setState(() {
          _playersSearchResults = results;
          _isSearching = false;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _playersSearchResults = [];
          _isSearching = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _nombreController.dispose();
    _abreviacionController.dispose();
    super.dispose();
  }

  void _addMember(User user, String? numeroCamiseta) {
    if (!_integrantes.any((m) => m.playerId == user.playerId)) {
      setState(() {
        _integrantes.add(
          TeamMember(
            playerId: user.playerId,
            personId: user.id,
            dni: user.dni,
            nombre: user.nombre,
            apellido: user.apellido,
            numeroCamiseta: numeroCamiseta,
          ),
        );
      });
    }
  }

  void _removeMember(String dni) {
    setState(() {
      _integrantes.removeWhere((m) => m.dni == dni);
    });
  }

  void _updateMemberCamiseta(int index, String? numeroCamiseta) {
    setState(() {
      final member = _integrantes[index];
      _integrantes[index] = TeamMember(
        playerId: member.playerId,
        personId: member.personId,
        dni: member.dni,
        nombre: member.nombre,
        apellido: member.apellido,
        numeroCamiseta: numeroCamiseta,
      );
    });
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final team = Team(
        id: widget.team?.id ?? DateTime.now().toString(),
        nombre: _nombreController.text,
        abreviacion: _abreviacionController.text.isEmpty
            ? 'N/A'
            : _abreviacionController.text,
        tipo: _selectedTipo,
        professorIds: _selectedEntrenadores
            .map((u) => u.professorId)
            .whereType<String>()
            .toList(),
        entrenadores: _selectedEntrenadores
            .map((u) => u.nombreCompleto)
            .toList(),
        integrantes: _integrantes,
      );
      widget.onSubmit(team);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide.none,
            ),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Symbols.shield,
                        size: 20,
                        color: context.tokens.redToRosita,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tipo de Equipo',
                        style: TextStyle(
                          color: context.tokens.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    value: _selectedTipo == TeamType.competitivo,
                    onChanged: (value) {
                      setState(() {
                        _selectedTipo = value == true
                            ? TeamType.competitivo
                            : TeamType.recreativo;
                      });
                    },
                    title: const Text(
                      'Competitivo',
                      style: TextStyle(fontSize: 14),
                    ),
                    secondary: const Icon(Symbols.emoji_events),
                    controlAffinity: ListTileControlAffinity.trailing,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide.none,
            ),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Symbols.group, size: 20, color: context.tokens.text),
                      const SizedBox(width: 8),
                      Text(
                        'Información General',
                        style: TextStyle(
                          color: context.tokens.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _nombreController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre *',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    style: const TextStyle(fontSize: 14),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El nombre es obligatorio';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _abreviacionController,
                    decoration: const InputDecoration(
                      labelText: 'Abreviación *',
                      helperText: 'Máx 4 caracteres',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    style: const TextStyle(fontSize: 14),
                    maxLength: 4,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'La abreviación es obligatoria';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Entrenador',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (!_professorsLoaded)
                        // Skeleton mientras cargan los profesores
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                        )
                      else if (_selectedEntrenadores.isNotEmpty)
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _selectedEntrenadores.map((user) {
                                  return Chip(
                                    key: ValueKey(user.professorId),
                                    label: Text(
                                      '${user.nombre} ${user.apellido}',
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 12,
                                      ),
                                    ),
                                    backgroundColor: Colors.grey.shade200,
                                    deleteIcon: Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                    onDeleted: () {
                                      setState(() {
                                        _selectedEntrenadores =
                                            _selectedEntrenadores
                                                .where(
                                                  (u) =>
                                                      u.professorId !=
                                                      user.professorId,
                                                )
                                                .toList();
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                              if (_selectedEntrenadores.isNotEmpty)
                                const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: !_professorsLoaded
                                      ? null
                                      : () => _showSelectEntrenadoresDialog(
                                          context,
                                        ),
                                  child: Text(
                                    'Agregar entrenador',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: context.tokens.redToRosita,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: !_professorsLoaded
                                ? null
                                : () => _showSelectEntrenadoresDialog(context),
                            child: Text(
                              'Agregar entrenador',
                              style: TextStyle(
                                fontSize: 13,
                                color: context.tokens.redToRosita,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide.none,
            ),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Symbols.group_add,
                        size: 20,
                        color: context.tokens.text,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Integrantes',
                        style: TextStyle(
                          color: context.tokens.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Buscar...',
                      hintStyle: TextStyle(fontSize: 13),
                      prefixIcon: Icon(Symbols.search, size: 18),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    style: const TextStyle(fontSize: 13),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                      _searchPlayers(value);
                    },
                    onTap: () {
                      if (_playersSearchResults.isEmpty &&
                          _searchQuery.isEmpty) {
                        _loadInitialPlayers();
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: _isSearching
                        ? const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : (_playersSearchResults.isEmpty &&
                              _searchQuery.isEmpty)
                        ? const SizedBox.shrink()
                        : ListView(
                            shrinkWrap: true,
                            children: (() {
                              final filteredUsers = _playersSearchResults
                                  .where(
                                    (user) =>
                                        user.playerId != null &&
                                        !_integrantes.any(
                                          (m) => m.playerId == user.playerId,
                                        ),
                                  )
                                  .toList();

                              if (filteredUsers.isEmpty) {
                                return [
                                  const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Center(
                                      child: Text(
                                        'No hay jugadores disponibles',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ];
                              }

                              return filteredUsers.map((user) {
                                return ListTile(
                                  dense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 0,
                                  ),
                                  title: Text(
                                    '${user.nombre} ${user.apellido}',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  subtitle: Text(
                                    'DNI: ${user.dni}',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  trailing: const Icon(
                                    Symbols.add_circle,
                                    size: 20,
                                  ),
                                  onTap: () =>
                                      _showAddMemberDialog(context, user),
                                );
                              }).toList();
                            })(),
                          ),
                  ),
                  if (_integrantes.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          'No hay integrantes',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ),
                    )
                  else
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width - 80,
                        child: DataTable(
                          headingRowHeight: 36,
                          dataRowMinHeight: 48,
                          dataRowMaxHeight: 48,
                          columnSpacing: 16,
                          horizontalMargin: 0,
                          headingTextStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          dataTextStyle: const TextStyle(fontSize: 13),
                          columns: [
                            const DataColumn(label: Text('DNI')),
                            const DataColumn(label: Text('Nombre')),
                            DataColumn(
                              label: Text(
                                _selectedTipo == TeamType.competitivo
                                    ? 'Camiseta'
                                    : '',
                              ),
                            ),
                            const DataColumn(label: Text('')),
                          ],
                          rows: _integrantes.asMap().entries.map((entry) {
                            final index = entry.key;
                            final member = entry.value;
                            return DataRow(
                              cells: [
                                DataCell(Text(member.dni)),
                                DataCell(Text(member.nombreCompleto)),
                                DataCell(
                                  _selectedTipo == TeamType.competitivo
                                      ? SizedBox(
                                          width: 80,
                                          child: TextFormField(
                                            initialValue: member.numeroCamiseta,
                                            decoration: const InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              isDense: true,
                                            ),
                                            style: const TextStyle(
                                              fontSize: 13,
                                            ),
                                            keyboardType: TextInputType.number,
                                            onChanged: (value) {
                                              _updateMemberCamiseta(
                                                index,
                                                value.isEmpty ? null : value,
                                              );
                                            },
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                ),
                                DataCell(
                                  IconButton(
                                    icon: Icon(
                                      Symbols.delete,
                                      size: 18,
                                      color: context.tokens.redToRosita,
                                    ),
                                    onPressed: () => _removeMember(member.dni),
                                    tooltip: 'Eliminar',
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _handleSubmit,
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                widget.team == null ? 'Registrar equipo' : 'Actualizar equipo',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMemberDialog(BuildContext context, User user) {
    _addMember(user, null);
  }

  void _showSelectEntrenadoresDialog(BuildContext context) async {
    List<User> searchResults = _professorsSearchResults;
    bool isSearching = false;
    Timer? dialogDebounceTimer;

    void searchProfessors(String query, StateSetter setDialogState) {
      dialogDebounceTimer?.cancel();

      if (query.isEmpty) {
        setDialogState(() {
          searchResults = _professorsSearchResults;
          isSearching = false;
        });
        return;
      }

      setDialogState(() {
        isSearching = true;
      });

      dialogDebounceTimer = Timer(const Duration(milliseconds: 500), () async {
        try {
          final results = await _userRepository.getUsers(
            role: 'PROFESSOR',
            searchQuery: query,
            forTeamSelection: true,
          );
          setDialogState(() {
            searchResults = results;
            isSearching = false;
          });
        } catch (e) {
          setDialogState(() {
            searchResults = [];
            isSearching = false;
          });
        }
      });
    }

    final User? selectedProfesor = await showDialog<User>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final filteredUsers = searchResults
                .where(
                  (user) =>
                      user.tipos.contains(UserType.profesor) &&
                      !_selectedEntrenadores.any(
                        (selected) => selected.professorId == user.professorId,
                      ),
                )
                .toList();

            return AlertDialog(
              title: const Text(
                'Seleccionar entrenador',
                style: TextStyle(fontSize: 16),
              ),
              contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Buscar...',
                        hintStyle: TextStyle(fontSize: 13),
                        prefixIcon: Icon(Symbols.search, size: 18),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      style: const TextStyle(fontSize: 13),
                      onChanged: (value) {
                        searchProfessors(value, setDialogState);
                      },
                    ),
                    const SizedBox(height: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 250),
                      child: isSearching
                          ? const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : filteredUsers.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  'No hay profesores disponibles',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: filteredUsers.length,
                              itemBuilder: (context, index) {
                                final user = filteredUsers[index];
                                return ListTile(
                                  dense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 0,
                                  ),
                                  title: Text(
                                    '${user.nombre} ${user.apellido}',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  subtitle: Text(
                                    'DNI: ${user.dni}',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  trailing: const Icon(
                                    Symbols.add_circle,
                                    size: 20,
                                  ),
                                  onTap: () {
                                    Navigator.of(context).pop(user);
                                    dialogDebounceTimer?.cancel();
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cerrar', style: TextStyle(fontSize: 13)),
                ),
              ],
            );
          },
        );
      },
    );

    if (selectedProfesor == null) return;

    if (_selectedEntrenadores.any(
      (e) => e.professorId == selectedProfesor.professorId,
    )) {
      return; // Evitar duplicados
    }

    setState(() {
      // Crear NUEVA lista para que Flutter detecte el cambio
      _selectedEntrenadores = [..._selectedEntrenadores, selectedProfesor];
    });
  }
}
