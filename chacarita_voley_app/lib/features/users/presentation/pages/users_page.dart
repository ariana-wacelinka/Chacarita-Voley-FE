import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../../app/theme/app_theme.dart';
import '../../domain/entities/user.dart';
import '../../data/repositories/user_repository.dart';
import '../widgets/delete_user_dialog.dart';

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
  Timer? _debounceTimer;

  static const int _usersPerPage = 12;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _usersFuture = _repository.getUsers(page: 0, size: _usersPerPage);
    _totalElementsFuture = _repository.getTotalUsers();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      setState(() {
        _searchQuery = value;
        _currentPage = 0;
        _usersFuture = _repository.getUsers(
          searchQuery: value.isEmpty ? null : value,
          page: 0,
          size: _usersPerPage,
        );
        _totalElementsFuture = _repository.getTotalUsers(
          searchQuery: value.isEmpty ? null : value,
        );
      });
    });
  }

  void _nextPage() {
    setState(() {
      _currentPage++;
      _usersFuture = _repository.getUsers(
        searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
        page: _currentPage,
        size: _usersPerPage,
      );
    });
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
        _usersFuture = _repository.getUsers(
          searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
          page: _currentPage,
          size: _usersPerPage,
        );
      });
    }
  }

  void _showDeleteDialog(User user) {
    showDialog(
      context: context,
      builder: (context) => DeleteUserDialog(
        user: user,
        onConfirm: () {
          setState(() {
            _usersFuture = _repository.getUsers(
              searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
              page: _currentPage,
              size: _usersPerPage,
            );
          });
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
                        color: context.tokens.background,
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
                      onPressed: () {},
                      icon: const Icon(Symbols.tune, color: Colors.white),
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
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: SingleChildScrollView(
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
                                                    '/users/${user.id}/view',
                                                  );
                                                });
                                              },
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Symbols.visibility,
                                                    size: 18,
                                                    color: context.tokens.text,
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
                                            PopupMenuItem(
                                              onTap: () {
                                                Future.microtask(() async {
                                                  final updated = await context
                                                      .push(
                                                        '/users/${user.id}/edit',
                                                      );
                                                  if (updated == true &&
                                                      mounted) {
                                                    setState(() {
                                                      _usersFuture = _repository
                                                          .getUsers(
                                                            searchQuery:
                                                                _searchQuery
                                                                    .isEmpty
                                                                ? null
                                                                : _searchQuery,
                                                            page: _currentPage,
                                                            size: _usersPerPage,
                                                          );
                                                      _totalElementsFuture =
                                                          _repository
                                                              .getTotalUsers(
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
                                                    color: context.tokens.text,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'Modificar',
                                                    style: TextStyle(
                                                      color:
                                                          context.tokens.text,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/users/register'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Symbols.add, color: Colors.white),
      ),
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
