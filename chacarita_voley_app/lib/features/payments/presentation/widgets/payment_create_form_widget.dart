// lib/features/payments/presentation/widgets/create_payment_form.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_theme.dart';

// import '../../../users/domain/entities/user.dart'; // Para User entity
// import '../../../users/data/repositories/user_repository.dart'; // Para buscar usuarios
/*
TODO se integra cuando se haga el merge fijarse donde estan los user
 */
import '../../Temp/gender.dart';
import '../../Temp/user.dart';
import '../../Temp/user_repository.dart';
import '../../domain/entities/payment.dart';

class PaymentCreateForm extends StatefulWidget {
  final String? initialUserId; // Pre-cargar si viene de user
  final Function(Payment newPayment) onSave;

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
  PaymentStatus _selectedStatus = PaymentStatus.pendiente; // Default

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
      // Pre-cargar usuario si proporcionado
      final repo = UserRepository();
      _selectedUser = repo.getUserById(widget.initialUserId!);
      if (_selectedUser != null) {
        _searchController.text = _selectedUser!.nombreCompleto;
      }
    }
  }

  void _loadUsers() {
    final repo = UserRepository();
    _allUsers = repo.getUsers(); // Usuarios reales
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
        // Sección Usuario
        Text(
          'Usuario',
          style: TextStyle(
            color: tokens.text,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Buscar por nombre o DNI...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: tokens.stroke),
            ),
            prefixIcon: Icon(Icons.person_outline, color: tokens.gray),
            suffixIcon: Icon(Icons.search, color: tokens.gray),
          ),
        ),
        if (_filteredUsers.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
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

        const SizedBox(height: 24),

        // Sección Fecha y Monto
        Text(
          'Fecha y Monto',
          style: TextStyle(
            color: tokens.text,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildFormField(
          label: 'Monto *',
          controller: _montoController,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        _buildDateField(
          label: 'Fecha del pago *',
          controller: _fechaController,
        ),

        const SizedBox(height: 24),

        // Sección Comprobante
        Text(
          'Comprobante de pago',
          style: TextStyle(
            color: tokens.text,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildFileUploadField(tokens),
        const SizedBox(height: 4),
        Text(
          '* El comprobante será revisado por un administrador para validar el pago',
          style: TextStyle(color: tokens.gray, fontSize: 12),
        ),

        const SizedBox(height: 24),

        // Sección Estado del pago
        Text(
          'Estado del pago',
          style: TextStyle(
            color: tokens.text,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildStatusRadioGroup(tokens),

        const SizedBox(height: 32),

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
              final newPayment = Payment(
                userId: _selectedUser!.id!,
                userName: _selectedUser!.nombreCompleto,
                dni: _selectedUser!.dni,
                paymentDate: _dateFormat.parse(_fechaController.text),
                sentDate: DateTime.now(),
                amount: double.parse(_montoController.text),
                status: _selectedStatus,
                comprobantePath: _comprobanteFileName,
              );
              widget.onSave(newPayment);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: tokens.redToRosita,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: context.tokens.text,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: context.tokens.stroke),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: context.tokens.text,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
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
              decoration: InputDecoration(
                hintText: 'DD/MM/AAAA',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: context.tokens.stroke),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                suffixIcon: Icon(
                  Icons.calendar_today_outlined,
                  color: context.tokens.gray,
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
              'comprobante_${DateTime.now().millisecondsSinceEpoch}.pdf'; // Simulado
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          border: Border.all(color: tokens.stroke),
          borderRadius: BorderRadius.circular(8),
          color: tokens.permanentWhite,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.upload_file, color: tokens.redToRosita, size: 32),
            const SizedBox(height: 8),
            Text(
              _comprobanteFileName ??
                  'Arrastrá y soltá el comprobante acá o seleccioná un archivo',
              style: TextStyle(
                color: _comprobanteFileName != null
                    ? tokens.text
                    : tokens.redToRosita,
              ),
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
      children: PaymentStatus.values.map((status) {
        return RadioListTile<PaymentStatus>(
          title: Text(status.name.capitalize()),
          subtitle: Text(status.displayName),
          value: status,
          groupValue: _selectedStatus,
          onChanged: (value) => setState(() => _selectedStatus = value!),
          activeColor: tokens.redToRosita,
        );
      }).toList(),
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

// Extensión helper para capitalize (opcional)
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
