import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../../../app/theme/app_theme.dart';
import '../../domain/entities/assistance.dart';
import '../../domain/entities/assistance_stats.dart';
import '../../domain/entities/user.dart';
import '../../data/repositories/user_repository.dart';

class AttendanceHistoryPage extends StatefulWidget {
  final String userId;

  const AttendanceHistoryPage({super.key, required this.userId});

  @override
  State<AttendanceHistoryPage> createState() => _AttendanceHistoryPageState();
}

class _AttendanceHistoryPageState extends State<AttendanceHistoryPage> {
  late final UserRepository _userRepository;
  User? _user;
  bool _isLoading = true;
  String? _loadError;

  List<Assistance> _attendanceHistory = [];
  int _currentPage = 0;
  final int _pageSize = 10;
  int _totalElements = 0;
  bool _hasNext = false;
  bool _hasPrevious = false;
  bool _isLoadingPage = false;

  // Estadísticas desde el backend
  AssistanceStats? _stats;

  @override
  void initState() {
    super.initState();
    _userRepository = UserRepository();
    initializeDateFormatting('es');
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      // Primero cargar el usuario para obtener el playerId
      final user = await _userRepository.getUserById(widget.userId);

      if (!mounted) return;

      if (user?.playerId == null) {
        setState(() {
          _isLoading = false;
          _loadError = 'Usuario no es un jugador';
        });
        return;
      }

      // Luego cargar asistencias y estadísticas en paralelo con el playerId
      final results = await Future.wait([
        _userRepository.getAllAssistance(
          playerId: user!.playerId!,
          page: _currentPage,
          size: _pageSize,
        ),
        _userRepository.getAssistanceStatsByPlayerId(user.playerId!),
      ]);

      if (!mounted) return;

      final assistancePage = results[0] as AssistancePage;
      final stats = results[1] as AssistanceStats;

      setState(() {
        _user = user;
        _attendanceHistory = assistancePage.content;
        _totalElements = assistancePage.totalElements;
        _hasNext = assistancePage.hasNext;
        _hasPrevious = assistancePage.hasPrevious;
        _stats = stats;
        _isLoading = false;
        _loadError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = 'Error al cargar datos: $e';
      });
    }
  }

  Future<void> _loadAttendanceHistory() async {
    if (_isLoadingPage || _user?.playerId == null) return;

    setState(() {
      _isLoadingPage = true;
    });

    try {
      final assistancePage = await _userRepository.getAllAssistance(
        playerId: _user!.playerId!,
        page: _currentPage,
        size: _pageSize,
      );

      if (!mounted) return;

      setState(() {
        _attendanceHistory = assistancePage.content;
        _totalElements = assistancePage.totalElements;
        _hasNext = assistancePage.hasNext;
        _hasPrevious = assistancePage.hasPrevious;
        _isLoadingPage = false;
        _loadError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingPage = false;
        _loadError = 'Error al cargar asistencias: $e';
      });
    }
  }

  void _goToNextPage() {
    if (_hasNext && !_isLoadingPage) {
      setState(() {
        _currentPage++;
      });
      _loadAttendanceHistory();
    }
  }

  void _goToPreviousPage() {
    if (_hasPrevious && !_isLoadingPage) {
      setState(() {
        _currentPage--;
      });
      _loadAttendanceHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: context.tokens.background,
        appBar: AppBar(
          backgroundColor: context.tokens.card1,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Symbols.arrow_back, color: context.tokens.text),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Historial de Asistencias',
            style: TextStyle(
              color: context.tokens.text,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              context.tokens.redToRosita,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.tokens.background,
      appBar: AppBar(
        backgroundColor: context.tokens.card1,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Symbols.arrow_back, color: context.tokens.text),
          onPressed: () => context.pop(),
        ),
        title: Column(
          children: [
            Text(
              'Historial de Asistencias',
              style: TextStyle(
                color: context.tokens.text,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_user != null)
              Text(
                _user!.nombreCompleto,
                style: TextStyle(
                  color: context.tokens.placeholder,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _loadError != null
            ? Center(
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
                      _loadError!,
                      style: TextStyle(
                        color: context.tokens.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            : _attendanceHistory.isEmpty
            ? _buildEmptyState(context)
            : _buildAttendanceContent(context),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Symbols.event_busy, size: 64, color: context.tokens.placeholder),
          const SizedBox(height: 16),
          Text(
            'Sin registros de asistencia',
            style: TextStyle(
              color: context.tokens.text,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No hay registros de asistencias para este usuario.',
            style: TextStyle(color: context.tokens.placeholder, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceContent(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.tokens.card1,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.tokens.stroke),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Symbols.check_circle,
                    color: context.tokens.text,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Resumen de Asistencias',
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
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem(
                    context,
                    '${_stats?.assisted ?? 0}',
                    'Presentes',
                    context.tokens.green,
                  ),
                  _buildSummaryItem(
                    context,
                    '${_stats?.notAssisted ?? 0}',
                    'Ausentes',
                    context.tokens.redToRosita,
                  ),
                  _buildSummaryItem(
                    context,
                    '${_stats?.assistedPercentage.round() ?? 0}%',
                    'Asistencia',
                    Colors.blue,
                  ),
                ],
              ),
            ],
          ),
        ),

        if (_isLoadingPage)
          Expanded(
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  context.tokens.redToRosita,
                ),
              ),
            ),
          )
        else
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await _loadAttendanceHistory();
              },
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _attendanceHistory.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final record = _attendanceHistory[index];
                  return _buildAttendanceItem(context, record);
                },
              ),
            ),
          ),

        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _hasPrevious && !_isLoadingPage
                    ? _goToPreviousPage
                    : null,
                icon: Icon(
                  Symbols.chevron_left,
                  color: _hasPrevious && !_isLoadingPage
                      ? context.tokens.text
                      : context.tokens.placeholder,
                ),
              ),
              Text(
                _totalElements > 0
                    ? '${_currentPage * _pageSize + 1}-${(_currentPage + 1) * _pageSize > _totalElements ? _totalElements : (_currentPage + 1) * _pageSize} de $_totalElements'
                    : '0-0 de 0',
                style: TextStyle(
                  color: context.tokens.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              IconButton(
                onPressed: _hasNext && !_isLoadingPage ? _goToNextPage : null,
                icon: Icon(
                  Symbols.chevron_right,
                  color: _hasNext && !_isLoadingPage
                      ? context.tokens.text
                      : context.tokens.placeholder,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: context.tokens.placeholder,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceItem(BuildContext context, Assistance record) {
    DateTime? recordDate;
    try {
      recordDate = DateTime.parse(record.date);
    } catch (e) {
      recordDate = null;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.tokens.card1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.tokens.stroke),
      ),
      child: Row(
        children: [
          Icon(
            Symbols.calendar_today,
            color: context.tokens.placeholder,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recordDate != null
                      ? DateFormat(
                          'd \'de\' MMMM \'de\' yyyy',
                          'es',
                        ).format(recordDate)
                      : record.date,
                  style: TextStyle(
                    color: context.tokens.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  record.startTime != null && record.endTime != null
                      ? '${record.startTime!.substring(0, 5)} - ${record.endTime!.substring(0, 5)}'
                      : '18:00 - 19:00',
                  style: TextStyle(
                    color: context.tokens.placeholder,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            record.assistance ? Symbols.check : Symbols.close,
            color: record.assistance
                ? context.tokens.green
                : context.tokens.redToRosita,
            size: 20,
          ),
        ],
      ),
    );
  }
}
