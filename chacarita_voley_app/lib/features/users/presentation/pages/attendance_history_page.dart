import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_theme.dart';
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
  
  // Datos de ejemplo de asistencias
  final List<AttendanceRecord> _attendanceHistory = [
    AttendanceRecord(
      date: DateTime(2025, 11, 9),
      startTime: '18:00',
      endTime: '19:00',
      wasPresent: true,
    ),
    AttendanceRecord(
      date: DateTime(2025, 11, 9),
      startTime: '18:00',
      endTime: '19:00',
      wasPresent: false,
    ),
    AttendanceRecord(
      date: DateTime(2025, 11, 9),
      startTime: '18:00',
      endTime: '19:00',
      wasPresent: true,
    ),
    AttendanceRecord(
      date: DateTime(2025, 11, 9),
      startTime: '18:00',
      endTime: '19:00',
      wasPresent: false,
    ),
    AttendanceRecord(
      date: DateTime(2025, 11, 9),
      startTime: '18:00',
      endTime: '19:00',
      wasPresent: true,
    ),
    AttendanceRecord(
      date: DateTime(2025, 11, 9),
      startTime: '18:00',
      endTime: '19:00',
      wasPresent: false,
    ),
    AttendanceRecord(
      date: DateTime(2025, 11, 9),
      startTime: '18:00',
      endTime: '19:00',
      wasPresent: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _userRepository = UserRepository();
    _loadUser();
  }

  void _loadUser() {
    final user = _userRepository.getUserById(widget.userId);
    setState(() {
      _user = user;
      _isLoading = false;
    });
  }

  int get _presentCount => _attendanceHistory.where((a) => a.wasPresent).length;
  int get _absentCount => _attendanceHistory.where((a) => !a.wasPresent).length;
  double get _attendancePercentage => 
      _attendanceHistory.isEmpty ? 0 : (_presentCount / _attendanceHistory.length) * 100;

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
            'Cargando...',
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
      body: _attendanceHistory.isEmpty 
        ? _buildEmptyState(context)
        : _buildAttendanceContent(context),
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
        // Resumen de asistencias
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
                  Icon(Symbols.check_circle, color: context.tokens.text, size: 20),
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
                    '$_presentCount',
                    'Presentes',
                    context.tokens.green,
                  ),
                  _buildSummaryItem(
                    context,
                    '$_absentCount',
                    'Ausentes',
                    context.tokens.redToRosita,
                  ),
                  _buildSummaryItem(
                    context,
                    '${_attendancePercentage.round()}%',
                    'Asistencia',
                    Colors.blue,
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Lista de asistencias
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _attendanceHistory.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final record = _attendanceHistory[index];
              return _buildAttendanceItem(context, record);
            },
          ),
        ),
        
        // Paginación
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(Symbols.chevron_left, color: context.tokens.placeholder),
              ),
              Text(
                '1-15 de 87',
                style: TextStyle(
                  color: context.tokens.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Symbols.chevron_right, color: context.tokens.placeholder),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(BuildContext context, String value, String label, Color color) {
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

  Widget _buildAttendanceItem(BuildContext context, AttendanceRecord record) {
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
                  DateFormat('d \'de\' MMMM \'de\' yyyy').format(record.date),
                  style: TextStyle(
                    color: context.tokens.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${record.startTime} - ${record.endTime}',
                  style: TextStyle(
                    color: context.tokens.placeholder,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            record.wasPresent ? Symbols.check : Symbols.close,
            color: record.wasPresent 
              ? context.tokens.green 
              : context.tokens.redToRosita,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class AttendanceRecord {
  final DateTime date;
  final String startTime;
  final String endTime;
  final bool wasPresent;

  AttendanceRecord({
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.wasPresent,
  });
}