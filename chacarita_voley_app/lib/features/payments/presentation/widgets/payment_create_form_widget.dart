import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_theme.dart';

import '../../../users/domain/entities/gender.dart';
import '../../../users/domain/entities/user.dart'; // Para User entity
import '../../../users/data/repositories/user_repository.dart'; // Para buscar usuarios

import '../../domain/entities/pay.dart';
import '../../domain/entities/pay_state.dart';
//TODO review to deprecated into page

class PaymentCreateForm extends StatefulWidget {
  final String? initialUserId; // Pre-cargar si viene de user
  final Function(Pay newPayment, User selectedUser) onSave;

  const PaymentCreateForm({
    super.key,
    this.initialUserId,
    required this.onSave,
  });

  @override
  State<PaymentCreateForm> createState() => _PaymentCreateFormState();
}

class _PaymentCreateFormState extends State<PaymentCreateForm> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _montoController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  String? _comprobanteFileName; // Para upload simulado
  PayState _selectedStatus = PayState.pending; // Default

  List<User> _allUsers = [];
  List<User> _filteredUsers = [];
  User? _selectedUser; // Usuario seleccionado

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _searchController.addListener(_onSearchChanged);
    if (widget.initialUserId != null) {
      _loadInitialUser();
    }
  }

  Future<void> _loadInitialUser() async {
    // Pre-cargar usuario si proporcionado
    final repo = UserRepository();
    _selectedUser = await repo.getUserById(widget.initialUserId!);
    if (_selectedUser != null && mounted) {
      setState(() {
        _searchController.text = _selectedUser!.nombreCompleto;
      });
    }
  }

  Future<void> _loadUsers() async {
    final repo = UserRepository();
    _allUsers = await repo.getUsers(); // Usuarios reales
    if (_allUsers.isEmpty) {
      _allUsers = _getDummyUsers(); // Fallback dummy
    }
    _filteredUsers = [];
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _allUsers.where((user) {
        return user.nombreCompleto.toLowerCase().contains(query) ||
            user.dni.contains(query);
      }).toList();
    });
  }

  void _selectUser(User user) {
    setState(() {
      _selectedUser = user;
      _searchController.text = user.nombreCompleto;
      _filteredUsers = []; // Ocultar sugerencias
    });
  }

  List<User> _getDummyUsers() {
    return [
      User(
        id: '1',
        dni: '12345678',
        nombre: 'Juan',
        apellido: 'Perez',
        fechaNacimiento: DateTime(1990, 1, 1),
        genero: Gender.masculino,
        email: 'juan@example.com',
        telefono: '123456789',
        equipo: 'Equipo A',
        tipos: {UserType.jugador},
        estadoCuota: EstadoCuota.vencida,
      ),
      User(
        id: '2',
        dni: '87654321',
        nombre: 'Maria',
        apellido: 'Gonzalez',
        fechaNacimiento: DateTime(1995, 5, 5),
        genero: Gender.femenino,
        email: 'maria@example.com',
        telefono: '987654321',
        equipo: 'Equipo B',
        tipos: {UserType.jugador},
        estadoCuota: EstadoCuota.alDia,
      ),
      // Agrega más dummies si necesitas
    ];
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sección Usuario con card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: tokens.card1,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: tokens.stroke),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.person, color: tokens.text, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Usuario',
                    style: TextStyle(
                      color: tokens.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre o DNI...',
                  hintStyle: TextStyle(color: tokens.placeholder),
                  filled: true,
                  fillColor: tokens.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: tokens.stroke),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: tokens.stroke),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  suffixIcon: Icon(Icons.search, color: tokens.gray, size: 20),
                ),
              ),
              if (_filteredUsers.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    color: tokens.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: tokens.stroke),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = _filteredUsers[index];
                      return ListTile(
                        title: Text(user.nombreCompleto),
                        subtitle: Text('DNI: ${user.dni}'),
                        onTap: () => _selectUser(user),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Sección Fecha y Monto con card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: tokens.card1,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: tokens.stroke),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today, color: tokens.text, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Fecha y Monto',
                    style: TextStyle(
                      color: tokens.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildFormField(
                label: 'Monto',
                controller: _montoController,
                keyboardType: TextInputType.number,
                required: true,
              ),
              const SizedBox(height: 16),
              _buildDateField(
                label: 'Fecha del pago',
                controller: _fechaController,
                required: true,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Sección Comprobante con card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: tokens.card1,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: tokens.stroke),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.description, color: tokens.text, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Comprobante de pago',
                    style: TextStyle(
                      color: tokens.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildFileUploadField(tokens),
              const SizedBox(height: 8),
              Text(
                '* El comprobante será revisado por un administrador para validar el pago',
                style: TextStyle(color: tokens.gray, fontSize: 12),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Sección Estado del pago con card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: tokens.card1,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: tokens.stroke),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: tokens.text, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Estado del pago',
                    style: TextStyle(
                      color: tokens.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildStatusRadioGroup(tokens),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Botón Registrar
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (_selectedUser == null ||
                  _montoController.text.isEmpty ||
                  _fechaController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Completa todos los campos requeridos'),
                  ),
                );
                return;
              }
              final newPayment = Pay(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                status: _selectedStatus,
                amount: double.parse(_montoController.text),
                date: _dateFormat.format(
                  _dateFormat.parse(_fechaController.text),
                ),
                time: DateTime.now().toIso8601String().split('T')[1],
                fileName: _comprobanteFileName ?? '',
                fileUrl: '',
                userName: _selectedUser!.nombreCompleto,
                dni: _selectedUser!.dni,
              );
              widget.onSave(newPayment, _selectedUser!);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: tokens.redToRosita,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Registrar pago',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Campo genérico
  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: TextStyle(
              color: context.tokens.text,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            children: [
              if (required)
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: context.tokens.redToRosita),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(color: context.tokens.text),
          decoration: InputDecoration(
            filled: true,
            fillColor: context.tokens.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: context.tokens.stroke),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: context.tokens.stroke),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  // Campo fecha
  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: TextStyle(
              color: context.tokens.text,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            children: [
              if (required)
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: context.tokens.redToRosita),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (selectedDate != null) {
              controller.text = _dateFormat.format(selectedDate);
            }
          },
          child: AbsorbPointer(
            child: TextFormField(
              controller: controller,
              style: TextStyle(color: context.tokens.text),
              decoration: InputDecoration(
                hintText: 'DD/MM/AAAA',
                hintStyle: TextStyle(color: context.tokens.placeholder),
                filled: true,
                fillColor: context.tokens.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: context.tokens.stroke),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: context.tokens.stroke),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                suffixIcon: Icon(
                  Icons.calendar_today,
                  color: context.tokens.gray,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Campo upload
  Widget _buildFileUploadField(AppTokens tokens) {
    return GestureDetector(
      onTap: () {
        // Lógica real de file_picker
        setState(() {
          _comprobanteFileName =
              'comprobante_${DateTime.now().millisecondsSinceEpoch}.pdf';
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: tokens.stroke, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(8),
          color: tokens.background,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.upload_file_outlined, color: tokens.gray, size: 40),
            const SizedBox(height: 12),
            if (_comprobanteFileName == null)
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: 'Arrastrá y soltá el comprobante acá o\n',
                  style: TextStyle(color: tokens.text, fontSize: 14),
                  children: [
                    TextSpan(
                      text: 'seleccioná un archivo',
                      style: TextStyle(
                        color: tokens.redToRosita,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            else
              Text(
                _comprobanteFileName!,
                style: TextStyle(color: tokens.text, fontSize: 14),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }

  // Grupo de radios para estado
  Widget _buildStatusRadioGroup(AppTokens tokens) {
    return Column(
      children: [
        _buildStatusOption(
          tokens: tokens,
          status: PayState.pending,
          title: 'Pendiente',
          subtitle: 'Pendiente de revisión',
        ),
        const SizedBox(height: 8),
        _buildStatusOption(
          tokens: tokens,
          status: PayState.validated,
          title: 'Validada',
          subtitle: 'Pago confirmado y registrado',
        ),
        const SizedBox(height: 8),
        _buildStatusOption(
          tokens: tokens,
          status: PayState.rejected,
          title: 'Rechazada',
          subtitle: 'Comprobante inválido o pago no recibido',
        ),
      ],
    );
  }

  Widget _buildStatusOption({
    required AppTokens tokens,
    required PayState status,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedStatus == status;
    return GestureDetector(
      onTap: () => setState(() => _selectedStatus = status),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: tokens.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? tokens.redToRosita : tokens.stroke,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? tokens.redToRosita : tokens.gray,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: tokens.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: tokens.gray, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _montoController.dispose();
    _fechaController.dispose();
    super.dispose();
  }
}
