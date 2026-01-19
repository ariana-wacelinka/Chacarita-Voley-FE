import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../../app/theme/app_theme.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/gender.dart';

class UserFormWidget extends StatefulWidget {
  final User? initialUser;
  final Function(User) onSave;
  final String submitButtonText;

  const UserFormWidget({
    super.key,
    this.initialUser,
    required this.onSave,
    required this.submitButtonText,
  });

  @override
  State<UserFormWidget> createState() => _UserFormWidgetState();
}

class _UserFormWidgetState extends State<UserFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _dniController = TextEditingController();
  final _fechaNacimientoController = TextEditingController();
  final _emailController = TextEditingController();
  final _celularController = TextEditingController();

  DateTime? _fechaNacimiento;
  Gender? _generoSeleccionado;
  Set<UserType> _tiposSeleccionados = {UserType.jugador};

  @override
  void initState() {
    super.initState();
    if (widget.initialUser != null) {
      _initializeWithUser(widget.initialUser!);
    } else {
      _generoSeleccionado = Gender.masculino;
    }
  }

  void _initializeWithUser(User user) {
    _nombreController.text = user.nombre;
    _apellidoController.text = user.apellido;
    _dniController.text = user.dni;
    _emailController.text = user.email;
    _celularController.text = user.telefono;
    _fechaNacimiento = user.fechaNacimiento;
    _fechaNacimientoController.text = _formatDate(user.fechaNacimiento);
    _generoSeleccionado = user.genero;
    _tiposSeleccionados = Set.from(user.tipos);
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
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaNacimiento ?? DateTime(2000),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: context.tokens.redToRosita),
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
      final user = User(
        id: widget.initialUser?.id,
        playerId: widget.initialUser?.playerId,
        professorId: widget.initialUser?.professorId,
        dni: _dniController.text,
        nombre: _nombreController.text,
        apellido: _apellidoController.text,
        fechaNacimiento: _fechaNacimiento!,
        genero: _generoSeleccionado!,
        email: _emailController.text,
        telefono: _celularController.text,
        equipo: 'CHR',
        tipos: _tiposSeleccionados,
        estadoCuota: EstadoCuota.alDia,
      );

      widget.onSave(user);
    }
  }

  Widget _buildUserTypeCard(UserType type, IconData icon) {
    final isSelected = _tiposSeleccionados.contains(type);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            // Solo permitir deseleccionar si hay más de un tipo seleccionado
            if (_tiposSeleccionados.length > 1) {
              _tiposSeleccionados.remove(type);
            }
          } else {
            _tiposSeleccionados.add(type);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: context.tokens.card1,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: context.tokens.stroke, width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: context.tokens.placeholder, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                type.displayName,
                style: TextStyle(
                  color: context.tokens.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (isSelected)
              Icon(Symbols.check, color: context.tokens.redToRosita, size: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                      Symbols.shield,
                      color: context.tokens.redToRosita,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tipo de Usuario',
                      style: TextStyle(
                        color: context.tokens.redToRosita,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildUserTypeCard(UserType.jugador, Symbols.sports_volleyball),
                const SizedBox(height: 8),
                _buildUserTypeCard(UserType.profesor, Symbols.school),
                const SizedBox(height: 8),
                _buildUserTypeCard(
                  UserType.administrador,
                  Symbols.admin_panel_settings,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

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
                                  color: context.tokens.redToRosita,
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
                    const SizedBox(width: 12),
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
                                  color: context.tokens.redToRosita,
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
                      borderSide: BorderSide(color: context.tokens.redToRosita),
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
                    hintText: 'DD/MM/AAAA',
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
                      borderSide: BorderSide(color: context.tokens.redToRosita),
                    ),
                    suffixIcon: Icon(
                      Symbols.calendar_month,
                      color: context.tokens.placeholder,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  validator: (value) {
                    if (_fechaNacimiento == null) {
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
                  initialValue: _generoSeleccionado,
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
                      borderSide: BorderSide(color: context.tokens.redToRosita),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: Gender.values.map((gender) {
                    return DropdownMenuItem<Gender>(
                      value: gender,
                      child: Text(
                        gender.displayName,
                        style: TextStyle(color: context.tokens.text),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _generoSeleccionado = value;
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
                      borderSide: BorderSide(color: context.tokens.redToRosita),
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
                      borderSide: BorderSide(color: context.tokens.redToRosita),
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
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.tokens.redToRosita,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                widget.submitButtonText,
                style: const TextStyle(
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
}
