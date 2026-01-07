import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../../app/theme/app_theme.dart';
import '../../domain/entities/team.dart';
import '../../data/repositories/team_repository.dart';

enum _TeamMenuAction { view, edit, delete }

class TeamsPage extends StatefulWidget {
  const TeamsPage({super.key});

  @override
  State<TeamsPage> createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> {
  final TextEditingController _searchController = TextEditingController();

  List<Team> _allTeams = [];
  List<Team> _filteredTeams = [];
  List<Team> _displayedTeams = [];
  String _searchQuery = '';
  bool _isLoading = true;

  String? _lastLocation;

  static const int _teamsPerPage = 12;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadTeams();
    _searchController.addListener(_onSearchChanged);
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
          _loadTeams();
        }
      });
    }

    _lastLocation = location;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTeams() async {
    setState(() => _isLoading = true);
    try {
      final repository = TeamRepository();
      final teams = await repository.getTeams();
      setState(() {
        _allTeams = teams;
        _filteredTeams = List.from(_allTeams);
        _updateDisplayedTeams();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged() {
    _searchQuery = _searchController.text.toLowerCase();
    _currentPage = 0;
    if (_searchQuery.isEmpty) {
      _filteredTeams = List.from(_allTeams);
    } else {
      _filteredTeams = _allTeams.where((team) {
        return team.nombre.toLowerCase().contains(_searchQuery) ||
            team.entrenador.toLowerCase().contains(_searchQuery);
      }).toList();
    }
    _updateDisplayedTeams();
  }

  void _updateDisplayedTeams() {
    setState(() {
      final startIndex = _currentPage * _teamsPerPage;
      final endIndex = (startIndex + _teamsPerPage).clamp(
        0,
        _filteredTeams.length,
      );
      _displayedTeams = _filteredTeams.sublist(startIndex, endIndex);
    });
  }

  void _nextPage() {
    if ((_currentPage + 1) * _teamsPerPage < _filteredTeams.length) {
      _currentPage++;
      _updateDisplayedTeams();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _currentPage--;
      _updateDisplayedTeams();
    }
  }

  int get _startItem =>
      _filteredTeams.isEmpty ? 0 : _currentPage * _teamsPerPage + 1;
  int get _endItem =>
      ((_currentPage + 1) * _teamsPerPage).clamp(0, _filteredTeams.length);

  void _showDeleteDialog(Team team) {
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (context) => AlertDialog(
        backgroundColor: context.tokens.card1,
        content: Text(
          '¿Estás seguro de que deseas eliminar el equipo "${team.nombre}"?',
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
              final repository = TeamRepository();
              await repository.deleteTeam(team.id);
              if (context.mounted) {
                Navigator.pop(context);
                _loadTeams();
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
                            '${team.nombre} fue eliminado exitosamente',
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
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.tokens.redToRosita,
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
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    context.tokens.redToRosita,
                  ),
                ),
              )
            : Column(
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
                    child: Container(
                      decoration: BoxDecoration(
                        color: context.tokens.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: context.tokens.stroke),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Buscar por nombre...',
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
                  Expanded(
                    child: _filteredTeams.isEmpty
                        ? Center(
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
                                  rows: _displayedTeams.map((team) {
                                    return DataRow(
                                      cells: [
                                        DataCell(Text(team.nombre)),
                                        DataCell(Text(team.entrenador)),
                                        DataCell(
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                '${team.jugadoresActuales}/20',
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
                                                      context.push(
                                                        '/teams/edit/${team.id}',
                                                      );
                                                      break;
                                                    case _TeamMenuAction.delete:
                                                      _showDeleteDialog(team);
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
                                                  PopupMenuItem(
                                                    value: _TeamMenuAction.edit,
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
                                                  PopupMenuItem(
                                                    value:
                                                        _TeamMenuAction.delete,
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
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
                          '$_startItem-$_endItem de ${_filteredTeams.length}',
                          style: TextStyle(
                            color: context.tokens.text,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed:
                              (_currentPage + 1) * _teamsPerPage <
                                  _filteredTeams.length
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
                                (_currentPage + 1) * _teamsPerPage <
                                    _filteredTeams.length
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
        onPressed: () async {
          final created = await context.push<bool>('/teams/register');

          if (created == true && mounted) {
            _loadTeams();
          }
        },
        backgroundColor: context.tokens.redToRosita,
        child: const Icon(Symbols.group_add, color: Colors.white),
      ),
    );
  }
}
