import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../../app/theme/app_theme.dart';
import '../../domain/entities/team_list_item.dart';
import '../../data/repositories/team_repository.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/permissions_service.dart';

enum _TeamMenuAction { view, edit, delete }

class TeamsPage extends StatefulWidget {
  const TeamsPage({super.key});

  @override
  State<TeamsPage> createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> {
  final TextEditingController _searchController = TextEditingController();
  final _repository = TeamRepository();

  Future<List<TeamListItem>>? _teamsFuture;
  Future<int>? _totalElementsFuture;
  String _searchQuery = '';
  Timer? _debounceTimer;

  String? _lastLocation;

  static const int _teamsPerPage = 12;
  int _currentPage = 0;

  List<String> _userRoles = [];
  bool _canEdit = false;
  bool _canDelete = false;
  bool _canCreate = false;

  @override
  void initState() {
    super.initState();
    _loadUserRoles();
    _teamsFuture = _repository.getTeamsListItems(page: 0, size: _teamsPerPage);
    _totalElementsFuture = _repository.getTotalTeams();
  }

  Future<void> _loadUserRoles() async {
    final authService = AuthService();
    final roles = await authService.getUserRoles();
    if (mounted) {
      setState(() {
        _userRoles = roles ?? [];
        _canEdit = PermissionsService.canEditTeam(_userRoles);
        _canDelete = PermissionsService.canDeleteTeam(_userRoles);
        _canCreate = PermissionsService.canCreateTeam(_userRoles);
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final location = GoRouterState.of(context).uri.toString();

    if (_lastLocation != null &&
        _lastLocation != location &&
        location == '/teams') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _teamsFuture = _repository.getTeamsListItems(
              page: 0,
              size: _teamsPerPage,
            );
            _totalElementsFuture = _repository.getTotalTeams();
          });
        }
      });
    }

    _lastLocation = location;
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
        _teamsFuture = _repository.getTeamsListItems(
          searchQuery: value.isEmpty ? null : value,
          page: 0,
          size: _teamsPerPage,
        );
        _totalElementsFuture = _repository.getTotalTeams(
          searchQuery: value.isEmpty ? null : value,
        );
      });
    });
  }

  void _nextPage() {
    setState(() {
      _currentPage++;
      _teamsFuture = _repository.getTeamsListItems(
        searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
        page: _currentPage,
        size: _teamsPerPage,
      );
    });
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
        _teamsFuture = _repository.getTeamsListItems(
          searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
          page: _currentPage,
          size: _teamsPerPage,
        );
      });
    }
  }

  void _showDeleteDialog(String teamId, String teamName) {
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (context) => AlertDialog(
        backgroundColor: context.tokens.card1,
        content: Text(
          '¿Estás seguro de que deseas eliminar el equipo "$teamName"?',
          style: TextStyle(color: context.tokens.text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: context.tokens.text),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await _repository.deleteTeam(teamId);
              if (context.mounted) {
                Navigator.pop(context);
                setState(() {
                  _teamsFuture = _repository.getTeamsListItems(
                    searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
                    page: _currentPage,
                    size: _teamsPerPage,
                  );
                  _totalElementsFuture = _repository.getTotalTeams(
                    searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
                  );
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '$teamName fue eliminado exitosamente',
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
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
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
                    color: context.tokens.background,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
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
                    hintText: 'Buscar por nombre...',
                    hintStyle: TextStyle(color: context.tokens.placeholder),
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
            Expanded(
              child: FutureBuilder<List<TeamListItem>>(
                future: _teamsFuture,
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
                            Symbols.error_outline,
                            size: 64,
                            color: context.tokens.placeholder,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error al cargar equipos',
                            style: TextStyle(
                              color: context.tokens.placeholder,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final teams = snapshot.data ?? [];
                  if (teams.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Symbols.group_off,
                            size: 64,
                            color: context.tokens.placeholder,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No hay equipos'
                                : 'No se encontraron equipos',
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
                            setState(() {
                              _teamsFuture = _repository.getTeamsListItems(
                                searchQuery: _searchQuery.isEmpty
                                    ? null
                                    : _searchQuery,
                                page: _currentPage,
                                size: _teamsPerPage,
                              );
                              _totalElementsFuture = _repository.getTotalTeams(
                                searchQuery: _searchQuery.isEmpty
                                    ? null
                                    : _searchQuery,
                              );
                            });
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
                                  headingRowHeight: 40,
                                  dataRowMinHeight: 44,
                                  columnSpacing: 12,
                                  horizontalMargin: 5,
                                  dividerThickness: 0,
                                  columns: const [
                                    DataColumn(label: Text('Nombre')),
                                    DataColumn(label: Text('Entrenador')),
                                    DataColumn(label: Text('Jugadores')),
                                    DataColumn(label: SizedBox(width: 0)),
                                  ],
                                  rows: teams.map((team) {
                                    return DataRow(
                                      cells: [
                                        DataCell(Text(team.nombre)),
                                        DataCell(Text(team.entrenador)),
                                        DataCell(
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                '${team.cantidadJugadores}/20',
                                                style: TextStyle(
                                                  color: context.tokens.text,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Icon(
                                                Symbols.group,
                                                size: 18,
                                                color:
                                                    context.tokens.placeholder,
                                              ),
                                            ],
                                          ),
                                        ),
                                        DataCell(
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: Transform.translate(
                                              offset: const Offset(4, 0),
                                              child: PopupMenuButton<_TeamMenuAction>(
                                                useRootNavigator: true,
                                                padding: EdgeInsets.zero,
                                                icon: Icon(
                                                  Symbols.more_vert,
                                                  color: context
                                                      .tokens
                                                      .placeholder,
                                                  weight: 1000,
                                                  size: 18,
                                                ),
                                                tooltip: 'Más opciones',
                                                onSelected: (action) {
                                                  switch (action) {
                                                    case _TeamMenuAction.view:
                                                      context.push(
                                                        '/teams/view/${team.id}',
                                                      );
                                                      break;
                                                    case _TeamMenuAction.edit:
                                                      () async {
                                                        final updated =
                                                            await context.push(
                                                          '/teams/edit/${team.id}',
                                                        );
                                                        if (updated == true &&
                                                            mounted) {
                                                          setState(() {
                                                            _teamsFuture =
                                                                _repository
                                                                    .getTeamsListItems(
                                                              searchQuery:
                                                                  _searchQuery
                                                                          .isEmpty
                                                                      ? null
                                                                      : _searchQuery,
                                                              page: _currentPage,
                                                              size: _teamsPerPage,
                                                            );
                                                            _totalElementsFuture =
                                                                _repository
                                                                    .getTotalTeams(
                                                              searchQuery:
                                                                  _searchQuery
                                                                          .isEmpty
                                                                      ? null
                                                                      : _searchQuery,
                                                            );
                                                          });
                                                        }
                                                      }();
                                                      break;
                                                    case _TeamMenuAction.delete:
                                                      _showDeleteDialog(
                                                        team.id,
                                                        team.nombre,
                                                      );
                                                      break;
                                                  }
                                                },
                                                itemBuilder: (_) => [
                                                  PopupMenuItem(
                                                    value: _TeamMenuAction.view,
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Symbols.visibility,
                                                          size: 18,
                                                          color: context
                                                              .tokens
                                                              .text,
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        Text(
                                                          'Ver',
                                                          style: TextStyle(
                                                            color: context
                                                                .tokens
                                                                .text,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  if (_canEdit)
                                                    PopupMenuItem(
                                                      value:
                                                          _TeamMenuAction.edit,
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            Symbols.edit,
                                                            size: 18,
                                                            color: context
                                                                .tokens
                                                                .text,
                                                          ),
                                                          const SizedBox(
                                                            width: 8,
                                                          ),
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
                                                      value: _TeamMenuAction
                                                          .delete,
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            Symbols.delete,
                                                            size: 18,
                                                            color: context
                                                                .tokens
                                                                .redToRosita,
                                                          ),
                                                          const SizedBox(
                                                            width: 8,
                                                          ),
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
                        child: FutureBuilder<int>(
                          future: _totalElementsFuture,
                          builder: (context, snapshot) {
                            final total = snapshot.data ?? 0;
                            final start = teams.isEmpty
                                ? 0
                                : _currentPage * _teamsPerPage + 1;
                            final end =
                                (_currentPage * _teamsPerPage) +
                                teams.length;
                            final canNext = end < total;

                            return Row(
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
                                Text(
                                  '$start-$end de $total',
                                  style: TextStyle(
                                    color: context.tokens.text,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: canNext ? _nextPage : null,
                                  padding: const EdgeInsets.all(8),
                                  constraints: const BoxConstraints(
                                    minWidth: 40,
                                    minHeight: 40,
                                  ),
                                  icon: Icon(
                                    Symbols.chevron_right,
                                    color: canNext
                                        ? context.tokens.text
                                        : context.tokens.placeholder,
                                    size: 20,
                                  ),
                                ),
                              ],
                            );
                          },
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
              onPressed: () async {
                final created = await context.push<bool>('/teams/register');

                if (created == true && mounted) {
                  setState(() {
                    _teamsFuture = _repository.getTeamsListItems(
                      searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
                      page: _currentPage,
                      size: _teamsPerPage,
                    );
                    _totalElementsFuture = _repository.getTotalTeams(
                      searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
                    );
                  });
                }
              },
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Symbols.group_add, color: Colors.white),
            )
          : null,
    );
  }
}
