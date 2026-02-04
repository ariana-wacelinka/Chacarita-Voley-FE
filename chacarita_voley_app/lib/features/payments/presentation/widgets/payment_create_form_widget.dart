import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/services/file_upload_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/permissions_service.dart';

import '../../../users/domain/entities/gender.dart';
import '../../../users/domain/entities/user.dart';
import '../../../users/domain/entities/due.dart';
import '../../../users/data/repositories/user_repository.dart';

import '../../domain/entities/pay.dart' as payment_entities;
import '../../domain/entities/pay_state.dart' as payment_state;

class PaymentCreateForm extends StatefulWidget {
  final String? initialUserId; // Pre-cargar si viene de user
  final Function(
    payment_entities.Pay newPayment,
    User selectedUser,
    String dueId,
  )
  onSave;

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
  String? _comprobanteFileName;
  String? _comprobanteFileUrl;
  bool _isUploadingFile = false;
  payment_state.PayState _selectedStatus = payment_state.PayState.pending;

  List<User> _allUsers = [];
  List<User> _filteredUsers = [];
  User? _selectedUser;
  List<String> _userRoles = [];
  bool _isPlayer = false;

  // Cuotas del jugador seleccionado
  List<CurrentDue> _availableDues = [];
  CurrentDue? _selectedDue;
  bool _isLoadingDues = false;
  bool _isDuesSelectorExpanded = false;

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _loadUserRoles();
    _loadUsers();
    _searchController.addListener(_onSearchChanged);
    if (widget.initialUserId != null) {
      _loadInitialUser();
    }
  }

  Future<void> _loadUserRoles() async {
    final authService = AuthService();
    final roles = await authService.getUserRoles();
    final userId = await authService.getUserId();

    if (mounted) {
      setState(() {
        _userRoles = roles ?? [];
        // Mostrar estado solo si tiene rol ADMIN
        _isPlayer = !_userRoles.contains('ADMIN');
      });

      // Si es player Y NO viene un initialUserId (no viene desde historial de otra persona),
      // cargar automáticamente su usuario
      if (_isPlayer && userId != null && widget.initialUserId == null) {
        _loadPlayerUser(userId.toString());
      }
    }
  }

  Future<void> _loadPlayerUser(String userId) async {
    final repo = UserRepository();
    try {
      final user = await repo.getUserById(userId);
      if (user != null && mounted) {
        setState(() {
          _selectedUser = user;
          _searchController.text = user.nombreCompleto;
        });
        _loadDuesForPlayer(user);
      }
    } catch (e) {
      print('⚠️ Error cargando usuario del player: $e');
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
      // Cargar cuotas del usuario pre-seleccionado
      _loadDuesForPlayer(_selectedUser!);
    }
  }

  Future<void> _loadUsers() async {
    final repo = UserRepository();
    _allUsers = await repo
        .getUsersForPayments(); // Solo jugadores con player.id
    if (_allUsers.isEmpty) {
      _allUsers = []; // Fallback empty list
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

      // Resetear cuota seleccionada
      _selectedDue = null;
      _availableDues = [];
    });

    // Cargar cuotas del jugador
    _loadDuesForPlayer(user);
  }

  Future<void> _loadDuesForPlayer(User user) async {
    // Validar que el usuario tenga playerId
    if (user.playerId == null) {
      setState(() {
        _availableDues = [];
        _selectedDue = null;
        _isLoadingDues = false;
      });
      return;
    }

    setState(() => _isLoadingDues = true);

    try {
      final repo = UserRepository();
      var dues = await repo.getAllDuesByPlayerId(
        user.playerId!,
        states: [DueState.PENDING, DueState.OVERDUE],
      );

      // Aplicar lógica de filtrado según estado de pago
      List<CurrentDue> filteredDues = dues;

      // Caso 1: Una sola cuota con pago PENDING/REJECTED
      if (dues.length == 1) {
        final due = dues.first;
        if (due.pay != null &&
            (due.pay!.state == PayState.PENDING ||
                due.pay!.state == PayState.REJECTED)) {
          filteredDues = [];
        }
      }
      // Caso 2: Varias cuotas - verificar si cuota del mes actual tiene pago PENDING
      else if (dues.length > 1) {
        final currentMonthDue = dues.firstWhere(
          (due) => due.state == DueState.PENDING,
          orElse: () => dues.first,
        );

        if (currentMonthDue.pay != null &&
            currentMonthDue.pay!.state == PayState.PENDING) {
          filteredDues = dues
              .where((due) => due.state == DueState.OVERDUE)
              .toList();
        }
      }

      if (mounted) {
        setState(() {
          _availableDues = filteredDues;
          _isLoadingDues = false;
          // Seleccionar automáticamente la cuota PENDING (mes actual)
          if (filteredDues.isNotEmpty) {
            _selectedDue = filteredDues.firstWhere(
              (due) => due.state == DueState.PENDING,
              orElse: () => filteredDues.first,
            );
          }
        });
      }
    } catch (e) {
      print('❌ Error cargando cuotas: $e');
      if (mounted) {
        setState(() {
          _availableDues = [];
          _isLoadingDues = false;
        });
      }
    }
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
              if ((widget.initialUserId != null || _isPlayer) &&
                  _selectedUser != null)
                // Mostrar solo el nombre cuando viene de historial o es player
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: tokens.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: tokens.stroke),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedUser!.nombreCompleto,
                              style: TextStyle(
                                color: tokens.text,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'DNI: ${_selectedUser!.dni}',
                              style: TextStyle(
                                color: tokens.placeholder,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              else if (!_isPlayer)
                // Mostrar buscador normal solo si NO es player
                Column(
                  children: [
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
                        suffixIcon: Icon(
                          Icons.search,
                          color: tokens.gray,
                          size: 20,
                        ),
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
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Sección unificada: Cuota + Fecha y Monto (solo si hay usuario seleccionado)
        if (_selectedUser != null)
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
                // Sección Cuota a pagar
                Row(
                  children: [
                    Icon(Icons.credit_card, color: tokens.text, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Cuota a pagar',
                      style: TextStyle(
                        color: tokens.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    if (_isLoadingDues)
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(
                            tokens.redToRosita,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDueSelector(tokens),

                // Divider
                const SizedBox(height: 24),
                Divider(height: 1, color: tokens.stroke),
                const SizedBox(height: 24),

                // Sección Fecha y Monto
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

        // Sección Estado del pago con card - Solo visible para ADMIN/PROFESOR
        if (!_isPlayer)
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
              print('🔵 ========== BOTÓN REGISTRAR PAGO PRESIONADO ==========');

              if (_selectedUser == null ||
                  _selectedDue == null ||
                  _montoController.text.isEmpty ||
                  _fechaController.text.isEmpty) {
                print('❌ Validación fallida: campos incompletos');
                print(
                  '   - Usuario seleccionado: ${_selectedUser?.nombreCompleto ?? "null"}',
                );
                print('   - Cuota seleccionada: ${_selectedDue?.id ?? "null"}');
                print('   - Monto: ${_montoController.text}');
                print('   - Fecha: ${_fechaController.text}');
                print(
                  '=======================================================',
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Completa todos los campos requeridos'),
                  ),
                );
                return;
              }

              // Validar que la fecha no sea futura
              final selectedDate = _dateFormat.parse(_fechaController.text);
              final today = DateTime.now();
              final todayDateOnly = DateTime(
                today.year,
                today.month,
                today.day,
              );

              if (selectedDate.isAfter(todayDateOnly)) {
                print('❌ Validación fallida: fecha futura');
                print('   - Fecha seleccionada: $selectedDate');
                print('   - Hoy: $todayDateOnly');
                print(
                  '=======================================================',
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'No se puede registrar un pago con fecha futura',
                    ),
                    backgroundColor: context.tokens.redToRosita,
                  ),
                );
                return;
              }

              print('✅ Validaciones pasadas, creando objeto Pay...');
              print('👤 Usuario: ${_selectedUser!.nombreCompleto}');
              print('🆔 Due ID: ${_selectedDue!.id}');
              print('💰 Monto: ${_montoController.text}');
              print('📅 Fecha: ${_fechaController.text}');
              print(
                '📊 Estado seleccionado: ${_isPlayer ? "PENDING (forzado por jugador)" : _selectedStatus.name}',
              );
              print('📄 Comprobante: ${_comprobanteFileName ?? "sin archivo"}');
              print('=======================================================');

              final newPayment = payment_entities.Pay(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                status: _isPlayer
                    ? payment_state.PayState.pending
                    : _selectedStatus,
                amount: double.parse(_montoController.text),
                date: _dateFormat.format(
                  _dateFormat.parse(_fechaController.text),
                ),
                createdAt: DateTime.now().toIso8601String(),
                fileName: _comprobanteFileName ?? '',
                fileUrl: _comprobanteFileUrl ?? '',
                userName: _selectedUser!.nombreCompleto,
                dni: _selectedUser!.dni,
              );
              widget.onSave(newPayment, _selectedUser!, _selectedDue!.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
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

  // Widget para selector de cuota
  Widget _buildDueSelector(AppTokens tokens) {
    if (_availableDues.isEmpty && !_isLoadingDues) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: tokens.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: tokens.stroke),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: tokens.gray, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No hay cuotas pendientes o vencidas para este jugador',
                style: TextStyle(color: tokens.gray, fontSize: 14),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Seleccioná la cuota que querés pagar *',
          style: TextStyle(
            color: tokens.text,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        // Campo principal (cerrado o con selección)
        GestureDetector(
          onTap: () {
            if (_selectedDue == null) {
              setState(() {
                _isDuesSelectorExpanded = !_isDuesSelectorExpanded;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: tokens.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: tokens.stroke),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _selectedDue == null
                      ? Text(
                          'Seleccioná la cuota que querés pagar',
                          style: TextStyle(color: tokens.placeholder),
                        )
                      : Text(
                          _selectedDue!.formattedPeriod,
                          style: TextStyle(
                            color: tokens.text,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
                if (_selectedDue != null)
                  _buildDueBadge(_selectedDue!.state, tokens),
                if (_selectedDue != null) const SizedBox(width: 8),
                if (_selectedDue != null)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDue = null;
                        _isDuesSelectorExpanded = false;
                      });
                    },
                    child: Icon(Icons.close, color: tokens.gray, size: 20),
                  ),
                if (_selectedDue == null)
                  Icon(
                    _isDuesSelectorExpanded
                        ? Icons.arrow_drop_up
                        : Icons.arrow_drop_down,
                    color: tokens.text,
                  ),
              ],
            ),
          ),
        ),
        // Lista desplegable de cuotas
        if (_isDuesSelectorExpanded && _selectedDue == null) ...[
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: tokens.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: tokens.stroke),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _availableDues.length,
              itemBuilder: (context, index) {
                final due = _availableDues[index];
                return ListTile(
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          due.formattedPeriod,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      _buildDueBadge(due.state, tokens),
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      _selectedDue = due;
                      _isDuesSelectorExpanded = false;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  // Badge para el estado de la cuota
  Widget _buildDueBadge(DueState state, AppTokens tokens) {
    final color = state == DueState.OVERDUE
        ? tokens.redToRosita
        : tokens.pending; // Naranja para pendiente
    final label = state == DueState.OVERDUE ? 'Vencida' : 'Pendiente';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
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
      onTap: _isUploadingFile ? null : _handleFileUpload,
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
            if (_isUploadingFile)
              CircularProgressIndicator(color: tokens.redToRosita)
            else
              Icon(Icons.upload_file_outlined, color: tokens.gray, size: 40),
            const SizedBox(height: 12),
            if (_isUploadingFile)
              Text(
                'Subiendo archivo...',
                style: TextStyle(color: tokens.text, fontSize: 14),
                textAlign: TextAlign.center,
              )
            else if (_comprobanteFileName == null)
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: tokens.green, size: 20),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      _comprobanteFileName!,
                      style: TextStyle(color: tokens.text, fontSize: 14),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleFileUpload() async {
    setState(() => _isUploadingFile = true);

    try {
      // Mostrar opciones: Galería o Archivo
      final option = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Seleccionar comprobante'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galería'),
                onTap: () => Navigator.pop(context, 'gallery'),
              ),
              ListTile(
                leading: const Icon(Icons.insert_drive_file),
                title: const Text('Archivo'),
                onTap: () => Navigator.pop(context, 'file'),
              ),
            ],
          ),
        ),
      );

      if (option == null) {
        setState(() => _isUploadingFile = false);
        return;
      }

      Map<String, String>? result;

      if (option == 'gallery') {
        final file = await FileUploadService.pickImage(
          source: ImageSource.gallery,
        );
        if (file != null) {
          result = {
            'fileName': file.path.split('/').last,
            'fileUrl': file.path,
          };
        }
      } else if (option == 'file') {
        final file = await FileUploadService.pickFile(
          allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        );
        if (file != null) {
          result = {
            'fileName': file.path.split('/').last,
            'fileUrl': file.path,
          };
        }
      }

      if (result != null && mounted) {
        setState(() {
          _comprobanteFileName = result!['fileName'];
          _comprobanteFileUrl = result['fileUrl'];
          _isUploadingFile = false;
        });
      } else {
        setState(() => _isUploadingFile = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingFile = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al subir archivo: $e'),
            backgroundColor: context.tokens.redToRosita,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  // Grupo de radios para estado
  Widget _buildStatusRadioGroup(AppTokens tokens) {
    return Column(
      children: [
        _buildStatusOption(
          tokens: tokens,
          status: payment_state.PayState.pending,
          title: 'Pendiente',
          subtitle: 'Pendiente de revisión',
        ),
        const SizedBox(height: 8),
        _buildStatusOption(
          tokens: tokens,
          status: payment_state.PayState.validated,
          title: 'Validada',
          subtitle: 'Pago confirmado y registrado',
        ),
        const SizedBox(height: 8),
        _buildStatusOption(
          tokens: tokens,
          status: payment_state.PayState.rejected,
          title: 'Rechazada',
          subtitle: 'Comprobante inválido o pago no recibido',
        ),
      ],
    );
  }

  Widget _buildStatusOption({
    required AppTokens tokens,
    required payment_state.PayState status,
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
