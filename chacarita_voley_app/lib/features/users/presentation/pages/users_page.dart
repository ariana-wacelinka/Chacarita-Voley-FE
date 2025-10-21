import 'package:flutter/material.dart';
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
  List<User> _allUsers = [];
  List<User> _filteredUsers = [];
  List<User> _displayedUsers = [];
  String _searchQuery = '';

  static const int _usersPerPage = 12;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadUsers() {
    _allUsers = UserRepository.getUsers();
    _filteredUsers = List.from(_allUsers);
    _updateDisplayedUsers();
  }

  void _onSearchChanged() {
    _searchQuery = _searchController.text.toLowerCase();
    _currentPage = 0; // Reset a la primera página
    if (_searchQuery.isEmpty) {
      _filteredUsers = List.from(_allUsers);
    } else {
      _filteredUsers = _allUsers.where((user) {
        return user.nombreCompleto.toLowerCase().contains(_searchQuery) ||
            user.dni.contains(_searchQuery);
      }).toList();
    }
    _updateDisplayedUsers();
  }

  void _updateDisplayedUsers() {
    setState(() {
      final startIndex = _currentPage * _usersPerPage;
      final endIndex = (startIndex + _usersPerPage).clamp(
        0,
        _filteredUsers.length,
      );
      _displayedUsers = _filteredUsers.sublist(startIndex, endIndex);
    });
  }

  void _nextPage() {
    if ((_currentPage + 1) * _usersPerPage < _filteredUsers.length) {
      _currentPage++;
      _updateDisplayedUsers();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _currentPage--;
      _updateDisplayedUsers();
    }
  }

  int get _startItem =>
      _filteredUsers.isEmpty ? 0 : _currentPage * _usersPerPage + 1;
  int get _endItem =>
      ((_currentPage + 1) * _usersPerPage).clamp(0, _filteredUsers.length);

  void _showDeleteDialog(User user) {
    showDialog(
      context: context,
      builder: (context) => DeleteUserDialog(
        user: user,
        onConfirm: () {
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
              backgroundColor: context.tokens.redToRosita,
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
                color: context.tokens.card1,
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
                        decoration: InputDecoration(
                          hintText: 'Buscar por nombre o DNI...',
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
                      color: context.tokens.redToRosita,
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
              child: _filteredUsers.isEmpty
                  ? Center(
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
                    )
                  : Align(
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
                          rows: _displayedUsers.map((user) {
                            return DataRow(
                              cells: [
                                DataCell(Text(user.dni)),
                                DataCell(Text(user.nombreCompleto)),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: context.tokens.card3,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: context.tokens.strokeToNoStroke,
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      user.equipo,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: context.tokens.text,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Center(
                                    child: _buildEstadoCuotaIcon(
                                      context,
                                      user.estadoCuota,
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
                                    onSelected: (value) {
                                      switch (value) {
                                        case 'view':
                                          break;
                                        case 'edit':
                                          break;
                                        case 'delete':
                                          _showDeleteDialog(user);
                                          break;
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        value: 'view',
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
                                                color: context.tokens.text,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'edit',
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
                                                color: context.tokens.text,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Symbols.delete,
                                              size: 18,
                                              color: context.tokens.redToRosita,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Eliminar',
                                              style: TextStyle(
                                                color:
                                                    context.tokens.redToRosita,
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: context.tokens.card1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _currentPage > 0 ? _previousPage : null,
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
                  Text(
                    '$_startItem-$_endItem de ${_filteredUsers.length}',
                    style: TextStyle(color: context.tokens.text, fontSize: 14),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed:
                        (_currentPage + 1) * _usersPerPage <
                            _filteredUsers.length
                        ? _nextPage
                        : null,
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                    icon: Icon(
                      Symbols.chevron_right,
                      color:
                          (_currentPage + 1) * _usersPerPage <
                              _filteredUsers.length
                          ? context.tokens.text
                          : context.tokens.placeholder,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: context.tokens.redToRosita,
        child: const Icon(Symbols.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEstadoCuotaIcon(BuildContext context, EstadoCuota estado) {
    switch (estado) {
      case EstadoCuota.alDia:
        return Icon(Symbols.check_circle, color: Colors.green, size: 20);
      case EstadoCuota.vencida:
        return Icon(Symbols.cancel, color: Colors.red, size: 20);
      case EstadoCuota.ultimoPago:
        return Icon(Symbols.schedule, color: Colors.orange, size: 20);
    }
  }
}
