import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../../app/theme/app_theme.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/gender.dart';

class PlayerProfileFormWidget extends StatefulWidget {
  final User initialUser;
  final Function(User) onSave;

  const PlayerProfileFormWidget({
    super.key,
    required this.initialUser,
    required this.onSave,
  });

  @override
  State<PlayerProfileFormWidget> createState() =>
      _PlayerProfileFormWidgetState();
}

class _PlayerProfileFormWidgetState extends State<PlayerProfileFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _dniController = TextEditingController();
  final _fechaNacimientoController = TextEditingController();
  final _emailController = TextEditingController();
  final _celularController = TextEditingController();

  DateTime? _fechaNacimiento;
  Gender? _generoSeleccionado;

  @override
  void initState() {
    super.initState();
    _initializeWithUser(widget.initialUser);
  }

  void _initializeWithUser(User user) {
    _nombreController.text = user.nombre;
    _apellidoController.text = user.apellido;
    _dniController.text = user.dni;
    _emailController.text = user.email;
    _celularController.text = user.telefono ?? '';
    _fechaNacimiento = user.fechaNacimiento;
    _fechaNacimientoController.text = _formatDate(user.fechaNacimiento);
    _generoSeleccionado = user.genero;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _dniController.dispose();
    _fechaNacimientoController.dispose();
    _emailController.dispose();
    _celularController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaNacimiento ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _fechaNacimiento = picked;
        _fechaNacimientoController.text = _formatDate(picked);
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && _fechaNacimiento != null) {
      // Preservar todos los datos originales del usuario, solo actualizar campos editables
      final user = User(
        id: widget.initialUser.id,
        playerId: widget.initialUser.playerId,
        professorId: widget.initialUser.professorId,
        dni: _dniController.text,
        nombre: _nombreController.text,
        apellido: _apellidoController.text,
        fechaNacimiento: _fechaNacimiento!,
        genero: _generoSeleccionado!,
        email: _emailController.text,
        telefono: _celularController.text,
        equipo: widget.initialUser.equipo,
        tipos: widget.initialUser.tipos, // Preservar roles originales
        estadoCuota: widget.initialUser.estadoCuota,
      );

      print('\ud83d\udce6 Datos a enviar:');
      print('  ID: ${user.id}');
      print('  PlayerId: ${user.playerId}');
      print('  ProfessorId: ${user.professorId}');
      print('  DNI: ${user.dni}');
      print('  Nombre: ${user.nombre}');
      print('  Apellido: ${user.apellido}');
      print('  Fecha Nacimiento: ${user.fechaNacimiento}');
      print('  Género: ${user.genero}');
      print('  Email: ${user.email}');
      print('  Teléfono: ${user.telefono}');
      print('  Equipo: ${user.equipo}');
      print('  Tipos: ${user.tipos}');
      print('  Estado Cuota: ${user.estadoCuota}');

      widget.onSave(user);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Datos Personales
          Container(
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
                    Icon(Symbols.person, color: context.tokens.text, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Datos Personales',
                      style: TextStyle(
                        color: context.tokens.text,
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
                            'Nombre *',
                            style: TextStyle(
                              color: context.tokens.text,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _nombreController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: context.tokens.stroke,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: context.tokens.stroke,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Campo requerido';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Apellido *',
                            style: TextStyle(
                              color: context.tokens.text,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _apellidoController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: context.tokens.stroke,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: context.tokens.stroke,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Campo requerido';
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
                  'DNI *',
                  style: TextStyle(
                    color: context.tokens.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _dniController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: context.tokens.stroke),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: context.tokens.stroke),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Fecha de nacimiento *',
                  style: TextStyle(
                    color: context.tokens.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _fechaNacimientoController,
                  readOnly: true,
                  onTap: _selectDate,
                  decoration: InputDecoration(
                    suffixIcon: Icon(
                      Symbols.calendar_month,
                      color: context.tokens.text,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: context.tokens.stroke),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: context.tokens.stroke),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Género *',
                  style: TextStyle(
                    color: context.tokens.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<Gender>(
                  value: _generoSeleccionado,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: context.tokens.stroke),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: context.tokens.stroke),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: Gender.values.map((Gender gender) {
                    return DropdownMenuItem<Gender>(
                      value: gender,
                      child: Text(_getGenderDisplayName(gender)),
                    );
                  }).toList(),
                  onChanged: (Gender? newValue) {
                    setState(() {
                      _generoSeleccionado = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Campo requerido';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Datos de Contacto
          Container(
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
                      Symbols.contact_mail,
                      color: context.tokens.text,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Datos de Contacto',
                      style: TextStyle(
                        color: context.tokens.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Email *',
                  style: TextStyle(
                    color: context.tokens.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: context.tokens.stroke),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: context.tokens.stroke),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo requerido';
                    }
                    if (!value.contains('@')) {
                      return 'Email inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Celular *',
                  style: TextStyle(
                    color: context.tokens.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _celularController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: context.tokens.stroke),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: context.tokens.stroke),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo requerido';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Botón Guardar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Guardar cambios',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getGenderDisplayName(Gender gender) {
    switch (gender) {
      case Gender.masculino:
        return 'Masculino';
      case Gender.femenino:
        return 'Femenino';
      case Gender.otro:
        return 'Otro';
    }
  }
}
