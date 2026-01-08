import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../users/data/repositories/user_repository.dart';
import '../../../users/domain/entities/user.dart';
import '../../../users/domain/entities/gender.dart';
import '../../domain/entities/team.dart';

class TeamFormWidget extends StatefulWidget {
  final Team? team;
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
  List<String> _selectedEntrenadores = [];
  List<User> _users = [];
  List<TeamMember> _integrantes = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
    if (widget.team != null) {
      _nombreController.text = widget.team!.nombre;
      _abreviacionController.text = widget.team!.abreviacion;
      _selectedTipo = widget.team!.tipo;
      _integrantes = List.from(widget.team!.integrantes);
    }
  }

  void _loadUsers() async {
    final users = await _userRepository.getUsers();
    if (!mounted) return;
    setState(() {
      _users = users;

      // Cargar entrenadores después de tener la lista de usuarios
      if (widget.team != null && widget.team!.entrenador.isNotEmpty) {
        // Buscar el ID del entrenador por nombre
        final entrenador = _users.firstWhere(
          (u) => '${u.nombre} ${u.apellido}' == widget.team!.entrenador,
          orElse: () => _users.isNotEmpty
              ? _users.first
              : User(
                  id: 'temp',
                  nombre: 'Sin',
                  apellido: 'Entrenador',
                  dni: '',
                  email: '',
                  telefono: '',
                  fechaNacimiento: DateTime.now(),
                  genero: Gender.masculino,
                  equipo: '',
                  tipos: {UserType.profesor},
                  estadoCuota: EstadoCuota.alDia,
                ),
        );
        if (entrenador.id != null) {
          _selectedEntrenadores = [entrenador.id!];
        }
      }
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _abreviacionController.dispose();
    super.dispose();
  }

  void _addMember(User user, String? numeroCamiseta) {
    if (!_integrantes.any((m) => m.dni == user.dni)) {
      print(
        '➕ Adding member: ${user.nombre} ${user.apellido}, playerId: ${user.playerId}, id: ${user.id}',
      );
      setState(() {
        _integrantes.add(
          TeamMember(
            playerId: user.playerId ?? user.id, // Usar id si playerId es null
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
        playerId: member.playerId, // Preservar playerId
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
        entrenador: _selectedEntrenadores.isNotEmpty
            ? _selectedEntrenadores.first
            : '',
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
                          color: context.tokens.redToRosita,
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
                      if (_selectedEntrenadores.isNotEmpty)
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
                                children: _selectedEntrenadores.map((id) {
                                  final user = _users.firstWhere(
                                    (u) => u.id == id,
                                    orElse: () => User(
                                      id: id,
                                      nombre: 'Usuario',
                                      apellido: 'Desconocido',
                                      dni: '',
                                      email: '',
                                      telefono: '',
                                      fechaNacimiento: DateTime.now(),
                                      genero: Gender.masculino,
                                      equipo: '',
                                      tipos: {UserType.jugador},
                                      estadoCuota: EstadoCuota.alDia,
                                    ),
                                  );
                                  return Chip(
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
                                        _selectedEntrenadores.remove(id);
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
                                  onPressed: () =>
                                      _showSelectEntrenadoresDialog(context),
                                  child: const Text(
                                    'Agregar entrenador',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (_selectedEntrenadores.isEmpty)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () =>
                                _showSelectEntrenadoresDialog(context),
                            child: const Text(
                              'Agregar entrenador',
                              style: TextStyle(fontSize: 13),
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
                      hintText: 'Buscar por nombre o DNI...',
                      prefixIcon: Icon(Symbols.search, size: 20),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    style: const TextStyle(fontSize: 14),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  if (_searchQuery.isNotEmpty)
                    SizedBox(
                      height: 65,
                      child: ListView(
                        children: (() {
                          final filteredUsers = _users.where((user) {
                            if (user.id == null) return false;
                            if (_integrantes.any((m) => m.dni == user.dni)) {
                              return false;
                            }
                            final fullName = '${user.nombre} ${user.apellido}'
                                .toLowerCase();
                            final dni = user.dni.toLowerCase();
                            final query = _searchQuery.toLowerCase();
                            return fullName.contains(query) ||
                                dni.contains(query);
                          }).toList();

                          if (filteredUsers.isEmpty) {
                            return [
                              const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: Text(
                                    'No hay usuarios disponibles',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ];
                          }

                          return filteredUsers.map((user) {
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
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
                              onTap: () => _showAddMemberDialog(context, user),
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
                                      color: colorScheme.primary,
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

  void _showSelectEntrenadoresDialog(BuildContext context) {
    String searchQuery = '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final availableUsers = _users
                .where(
                  (user) =>
                      user.id != null &&
                      !_selectedEntrenadores.contains(user.id),
                )
                .toList();

            final filteredUsers = availableUsers.where((user) {
              if (searchQuery.isEmpty) return true;
              final fullName = '${user.nombre} ${user.apellido}'.toLowerCase();
              final dni = user.dni.toLowerCase();
              final query = searchQuery.toLowerCase();
              return fullName.contains(query) || dni.contains(query);
            }).toList();

            return AlertDialog(
              title: const Text('Seleccionar entrenador'),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Buscar por nombre o DNI...',
                        prefixIcon: Icon(Symbols.search, size: 18),
                      ),
                      onChanged: (value) {
                        setDialogState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 300,
                      child: filteredUsers.isEmpty
                          ? const Center(
                              child: Text('No hay usuarios disponibles'),
                            )
                          : ListView.builder(
                              itemCount: filteredUsers.length,
                              itemBuilder: (context, index) {
                                final user = filteredUsers[index];
                                return ListTile(
                                  title: Text(
                                    '${user.nombre} ${user.apellido}',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  subtitle: Text(
                                    'DNI: ${user.dni}',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  trailing: const Icon(Symbols.add_circle),
                                  onTap: () {
                                    setState(() {
                                      _selectedEntrenadores.add(user.id!);
                                    });
                                    Navigator.of(context).pop();
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
                  child: const Text('Cerrar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
