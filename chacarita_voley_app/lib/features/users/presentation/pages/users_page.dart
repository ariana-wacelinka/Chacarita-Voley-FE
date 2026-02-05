import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../../app/theme/app_theme.dart';
import '../../domain/entities/user.dart';
import '../../data/repositories/user_repository.dart';
import '../widgets/delete_user_dialog.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/permissions_service.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final TextEditingController _searchController = TextEditingController();
  final _repository = UserRepository();

  Future<List<User>>? _usersFuture;
  Future<int>? _totalElementsFuture;
  String _searchQuery = '';
  String? _selectedRole;
  String? _selectedDueState;
  bool _showFilters = false;
  Timer? _debounceTimer;

  static const int _usersPerPage = 12;
  int _currentPage = 0;

  List<String> _userRoles = [];
  bool _canCreate = false;
  bool _canEdit = false;
  bool _canDelete = false;

  @override
  void initState() {
    super.initState();
    _loadUserRoles();
    _loadUsers();
  }

  Future<void> _loadUserRoles() async {
    final authService = AuthService();
    final roles = await authService.getUserRoles();
    setState(() {
      _userRoles = roles ?? [];
      _canCreate = PermissionsService.canCreateUser(_userRoles);
      _canEdit = PermissionsService.canEditUser(_userRoles);
      _canDelete = PermissionsService.canDeleteUser(_userRoles);
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _loadUsers() {
    setState(() {
      _usersFuture = _repository.getUsers(
        searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
        role: _selectedRole,
        statusCurrentDue: _selectedDueState,
        page: _currentPage,
        size: _usersPerPage,
      );
      _totalElementsFuture = _repository.getTotalUsers(
        searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
        role: _selectedRole,
        statusCurrentDue: _selectedDueState,
      );
    });
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      setState(() {
        _searchQuery = value;
        _currentPage = 0;
      });
      _loadUsers();
    });
  }

  void _nextPage() {
    setState(() {
      _currentPage++;
    });
    _loadUsers();
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
      _loadUsers();
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedRole = null;
      _selectedDueState = null;
      _currentPage = 0;
    });
    _loadUsers();
  }

  void _showDeleteDialog(User user) {
    showDialog(
      context: context,
      builder: (context) => DeleteUserDialog(
        user: user,
        onConfirm: () {
          _loadUsers();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${user.nombreCompleto} fue eliminado exitosamente',
                      style: const TextStyle(
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: 'Deshacer',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.tokens.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.tokens.background,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF1E1E1E)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: context.tokens.stroke),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: 'Buscar por nombre, apellido o DNI...',
                          hintStyle: TextStyle(
                            color: context.tokens.placeholder,
                          ),
                          prefixIcon: Icon(
                            Symbols.search,
                            color: context.tokens.placeholder,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        style: TextStyle(color: context.tokens.text),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          _showFilters = !_showFilters;
                        });
                      },
                      icon: Icon(
                        Symbols.tune,
                        color: Colors.white,
                        fill:
                            (_selectedRole != null || _selectedDueState != null)
                            ? 1
                            : 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (_showFilters)
              Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                decoration: BoxDecoration(color: context.tokens.background),
                child: Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rol',
                          style: TextStyle(
                            color: context.tokens.text,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: context.tokens.stroke),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String?>(
                              value: _selectedRole,
                              isExpanded: true,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              dropdownColor: context.tokens.card1,
                              items: [
                                DropdownMenuItem(
                                  value: null,
                                  child: Text(
                                    'Todos',
                                    style: TextStyle(
                                      color: context.tokens.text,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'PLAYER',
                                  child: Text(
                                    'Jugador',
                                    style: TextStyle(
                                      color: context.tokens.text,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'PROFESSOR',
                                  child: Text(
                                    'Profesor',
                                    style: TextStyle(
                                      color: context.tokens.text,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'ADMIN',
                                  child: Text(
                                    'Admin',
                                    style: TextStyle(
                                      color: context.tokens.text,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedRole = value;
                                  _currentPage = 0;
                                });
                                _loadUsers();
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Estado de Cuota',
                          style: TextStyle(
                            color: context.tokens.text,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: context.tokens.stroke),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String?>(
                              value: _selectedDueState,
                              isExpanded: true,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              dropdownColor: context.tokens.card1,
                              items: [
                                DropdownMenuItem(
                                  value: null,
                                  child: Text(
                                    'Todos',
                                    style: TextStyle(
                                      color: context.tokens.text,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'PAID',
                                  child: Text(
                                    'Pagada',
                                    style: TextStyle(
                                      color: context.tokens.text,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'PENDING',
                                  child: Text(
                                    'Pendiente',
                                    style: TextStyle(
                                      color: context.tokens.text,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'OVERDUE',
                                  child: Text(
                                    'Vencida',
                                    style: TextStyle(
                                      color: context.tokens.text,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedDueState = value;
                                  _currentPage = 0;
                                });
                                _loadUsers();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_selectedRole != null || _selectedDueState != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: _clearFilters,
                            icon: Icon(
                              Symbols.close,
                              color: context.tokens.redToRosita,
                              size: 18,
                            ),
                            label: Text(
                              'Limpiar filtros',
                              style: TextStyle(
                                color: context.tokens.redToRosita,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

            Expanded(
              child: FutureBuilder<List<User>>(
                future: _usersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Symbols.error,
                            size: 64,
                            color: context.tokens.placeholder,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error al cargar usuarios',
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

                  final users = snapshot.data ?? [];

                  if (users.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Symbols.person_search,
                            size: 64,
                            color: context.tokens.placeholder,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No hay usuarios'
                                : 'No se encontraron usuarios',
                            style: TextStyle(
                              color: context.tokens.placeholder,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            _loadUsers();
                            await Future.delayed(
                              const Duration(milliseconds: 500),
                            );
                          },
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.95,
                                margin: const EdgeInsets.only(top: 10),
                                child: DataTable(
                                  headingTextStyle: TextStyle(
                                    color: context.tokens.text,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  dataTextStyle: TextStyle(
                                    color: context.tokens.text,
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                  ),
                                  columnSpacing: 12,
                                  horizontalMargin: 5,
                                  dividerThickness: 0,
                                  columns: const [
                                    DataColumn(label: Text('DNI')),
                                    DataColumn(label: Text('Nombre')),
                                    DataColumn(label: Text('Equipo')),
                                    DataColumn(label: Text('Cuota')),
                                    DataColumn(label: SizedBox(width: 32)),
                                  ],
                                  rows: users.map((user) {
                                    return DataRow(
                                      cells: [
                                        DataCell(Text(user.dni)),
                                        DataCell(Text(user.nombreCompleto)),
                                        DataCell(
                                          Center(
                                            child: _buildEquipoChip(
                                              context,
                                              user,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Center(
                                            child: _buildEstadoCuotaIcon(
                                              context,
                                              user,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          PopupMenuButton<String>(
                                            padding: EdgeInsets.zero,
                                            icon: Icon(
                                              Symbols.more_vert,
                                              color: context.tokens.placeholder,
                                              weight: 1000,
                                              size: 18,
                                            ),
                                            tooltip: 'Más opciones',
                                            itemBuilder: (context) => [
                                              PopupMenuItem(
                                                onTap: () {
                                                  Future.microtask(() {
                                                    context.go(
                                                      '/users/${user.id}/view?from=users',
                                                    );
                                                  });
                                                },
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Symbols.visibility,
                                                      size: 18,
                                                      color:
                                                          context.tokens.text,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      'Ver',
                                                      style: TextStyle(
                                                        color:
                                                            context.tokens.text,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (_canEdit &&
                                                  !(_userRoles.contains(
                                                        'PROFESSOR',
                                                      ) &&
                                                      user.tipos.contains(
                                                        UserType.administrador,
                                                      )))
                                                PopupMenuItem(
                                                  onTap: () {
                                                    Future.microtask(() async {
                                                      final updated =
                                                          await context.push(
                                                            '/users/${user.id}/edit',
                                                          );
                                                      if (updated == true &&
                                                          mounted) {
                                                        setState(() {
                                                          _usersFuture =
                                                              _repository.getUsers(
                                                                searchQuery:
                                                                    _searchQuery
                                                                        .isEmpty
                                                                    ? null
                                                                    : _searchQuery,
                                                                page:
                                                                    _currentPage,
                                                                size:
                                                                    _usersPerPage,
                                                              );
                                                          _totalElementsFuture =
                                                              _repository.getTotalUsers(
                                                                searchQuery:
                                                                    _searchQuery
                                                                        .isEmpty
                                                                    ? null
                                                                    : _searchQuery,
                                                              );
                                                        });
                                                      }
                                                    });
                                                  },
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Symbols.edit,
                                                        size: 18,
                                                        color:
                                                            context.tokens.text,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        'Modificar',
                                                        style: TextStyle(
                                                          color: context
                                                              .tokens
                                                              .text,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              if (_canDelete)
                                                PopupMenuItem(
                                                  onTap: () {
                                                    Future.microtask(() {
                                                      _showDeleteDialog(user);
                                                    });
                                                  },
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Symbols.delete,
                                                        size: 18,
                                                        color: context
                                                            .tokens
                                                            .redToRosita,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        'Eliminar',
                                                        style: TextStyle(
                                                          color: context
                                                              .tokens
                                                              .redToRosita,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: context.tokens.background,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: _currentPage > 0
                                  ? _previousPage
                                  : null,
                              padding: const EdgeInsets.all(8),
                              constraints: const BoxConstraints(
                                minWidth: 40,
                                minHeight: 40,
                              ),
                              icon: Icon(
                                Symbols.chevron_left,
                                color: _currentPage > 0
                                    ? context.tokens.text
                                    : context.tokens.placeholder,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 8),
                            FutureBuilder<int>(
                              future: _totalElementsFuture,
                              builder: (context, snapshot) {
                                final total = snapshot.data ?? 0;
                                final start = users.isEmpty
                                    ? 0
                                    : _currentPage * _usersPerPage + 1;
                                final end =
                                    (_currentPage * _usersPerPage) +
                                    users.length;
                                return Text(
                                  '$start-$end de $total',
                                  style: TextStyle(
                                    color: context.tokens.text,
                                    fontSize: 14,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: users.length >= _usersPerPage
                                  ? _nextPage
                                  : null,
                              padding: const EdgeInsets.all(8),
                              constraints: const BoxConstraints(
                                minWidth: 40,
                                minHeight: 40,
                              ),
                              icon: Icon(
                                Symbols.chevron_right,
                                color: users.length >= _usersPerPage
                                    ? context.tokens.text
                                    : context.tokens.placeholder,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _canCreate
          ? FloatingActionButton(
              onPressed: () => context.go('/users/register'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Symbols.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildEquipoChip(BuildContext context, User user) {
    // Si no tiene equipos, mostrar "-"
    if (user.equipos.isEmpty) {
      return Text(
        '-',
        style: TextStyle(color: context.tokens.placeholder, fontSize: 14),
      );
    }

    // Mostrar chip con la abreviación del primer equipo
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.tokens.card2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.tokens.stroke, width: 1),
      ),
      child: Text(
        user.equipos.first.abbreviation,
        style: TextStyle(
          color: context.tokens.text,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEstadoCuotaIcon(BuildContext context, User user) {
    // Si no tiene playerId (no es jugador), mostrar "-"
    if (user.playerId == null || user.playerId!.isEmpty) {
      return Text(
        '-',
        style: TextStyle(color: context.tokens.placeholder, fontSize: 14),
      );
    }

    // Mostrar ícono según estado de cuota
    switch (user.estadoCuota) {
      case EstadoCuota.alDia:
        return Icon(
          Symbols.check_circle,
          color: context.tokens.green,
          size: 20,
        );
      case EstadoCuota.vencida:
        return Icon(
          Symbols.cancel,
          color: Theme.of(context).colorScheme.primary,
          size: 20,
        );
      case EstadoCuota.ultimoPago:
        return Icon(Symbols.schedule, color: context.tokens.pending, size: 20);
    }
  }
}
