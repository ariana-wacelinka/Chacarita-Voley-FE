import 'dart:core';

import 'package:chacarita_voley_app/core/services/file_upload_service.dart';
import 'package:chacarita_voley_app/features/payments/data/repositories/pay_repository.dart';
import 'package:chacarita_voley_app/features/payments/domain/entities/payment_stats.dart';
import 'package:chacarita_voley_app/features/payments/domain/entities/pay_state.dart';
import 'package:chacarita_voley_app/features/payments/domain/entities/pay_filter_input.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../../app/theme/app_theme.dart';
import '../../domain/entities/pay.dart';

class PaymentsValidationPage extends StatefulWidget {
  final String? refresh;

  const PaymentsValidationPage({super.key, this.refresh});

  @override
  State<PaymentsValidationPage> createState() => _PaymentsValidationPageState();
}

class _PaymentsValidationPageState extends State<PaymentsValidationPage> {
  late final PayRepository _repository;
  List<Pay> _pays = [];
  bool _isLoading = true;
  PaymentStats? _stats;

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  PayState? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  int _currentPage = 0;
  final int _itemsPerPage = 15;
  int _totalElements = 0;
  int _totalPages = 0;
  bool _hasNext = false;
  bool _hasPrevious = false;
  final Map<String, bool> _downloadingFiles = {};
  @override
  void initState() {
    super.initState();
    _repository = PayRepository();
    _loadStats();
    _loadPays();
  }

  @override
  void didUpdateWidget(PaymentsValidationPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si cambia el parámetro refresh, recargar datos
    if (oldWidget.refresh != widget.refresh && widget.refresh != null) {
      _loadStats();
      _loadPays();
    }
  }

  Future<void> _loadStats() async {
    try {
      final stats = await _repository.getPaymentsStats();
      setState(() {
        _stats = stats;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar estadísticas: $e')),
        );
      }
    }
  }

  Future<void> _loadPays() async {
    setState(() => _isLoading = true);
    try {
      final payPage = await _repository.getAllPays(
        page: _currentPage,
        size: _itemsPerPage,
        filters: PayFilterInput(
          state: _selectedStatus,
          dateFrom: _startDate?.toIso8601String().split('T')[0],
          dateTo: _endDate?.toIso8601String().split('T')[0],
          timeFrom: _startTime != null
              ? '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}:00'
              : null,
          timeTo: _endTime != null
              ? '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}:00'
              : null,
        ),
      );
      setState(() {
        _pays = payPage.content;
        _totalElements = payPage.totalElements;
        _totalPages = payPage.totalPages;
        _hasNext = payPage.hasNext;
        _hasPrevious = payPage.hasPrevious;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al cargar pagos: $e')));
      }
    }
  }

  void _goToPage(int page) {
    setState(() {
      _currentPage = page;
    });
    _loadPays();
  }

  Future<void> _downloadReceipt(Pay payment) async {
    setState(() => _downloadingFiles[payment.id] = true);

    try {
      await FileUploadService.downloadPaymentReceiptWithNotification(
        paymentId: payment.id,
        fileName: payment.fileName ?? 'comprobante.pdf',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Comprobante descargado exitosamente'),
            backgroundColor: context.tokens.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al descargar comprobante: $e'),
            backgroundColor: context.tokens.redToRosita,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _downloadingFiles[payment.id] = false);
      }
    }
  }

  int get _approvedCount => _stats?.totalApprovedPayments ?? 0;
  int get _rejectedCount => _stats?.totalRejectedPayments ?? 0;
  int get _pendingCount => _stats?.totalPendingPayments ?? 0;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: tokens.background,
        body: Center(
          child: CircularProgressIndicator(color: tokens.redToRosita),
        ),
      );
    }

    return Scaffold(
      backgroundColor: tokens.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _pays.isEmpty
                  ? _buildEmptyState(context)
                  : _buildPaymentsList(context),
            ),
            if (_pays.isNotEmpty) _buildPagination(context),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        width: 56,
        height: 56,
        child: FloatingActionButton(
          onPressed: () {
            context.go('/payments/create');
          },
          backgroundColor: Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: const [
              Icon(Symbols.credit_card, color: Colors.white, size: 26),
              Positioned(
                top: 8,
                right: 8,
                child: Icon(Symbols.add, color: Colors.white, size: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildSummarySection(context)),
        SliverToBoxAdapter(child: _buildFilterSection(context)),
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Symbols.payments,
                  size: 64,
                  color: context.tokens.placeholder,
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay pagos para validar',
                  style: TextStyle(
                    color: context.tokens.placeholder,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentsList(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await _loadPays();
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: _pays.length + 2,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildSummarySection(context),
            );
          }

          if (index == 1) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildFilterSection(context),
            );
          }

          final paymentIndex = index - 2;
          final payment = _pays[paymentIndex];
          return _buildPaymentCard(context, payment);
        },
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.tokens.card1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.tokens.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Symbols.check_circle_outline,
                color: context.tokens.gray,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Resumen de Validaciones',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.tokens.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                number: _approvedCount.toString(),
                label: 'Aprobados',
                numberColor: context.tokens.green,
              ),
              _buildSummaryItem(
                number: _rejectedCount.toString(),
                label: 'Rechazados',
                numberColor: context.tokens.redToRosita,
              ),
              _buildSummaryItem(
                number: _pendingCount.toString(),
                label: 'Pendientes',
                numberColor: context.tokens.pending,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required String number,
    required String label,
    required Color numberColor,
  }) {
    return Column(
      children: [
        Text(
          number,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: numberColor,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: context.tokens.placeholder),
        ),
      ],
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.tokens.card1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.tokens.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Symbols.filter_alt,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Filtro',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.tokens.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  label: 'Fecha de inicio',
                  value: _startDate,
                  onTap: () => _selectDate(context, true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateField(
                  label: 'Fecha de fin',
                  value: _endDate,
                  onTap: () => _selectDate(context, false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTimeField(
                  label: 'Hora de inicio',
                  value: _startTime,
                  onTap: () => _selectTime(context, true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTimeField(
                  label: 'Hora de fin',
                  value: _endTime,
                  onTap: () => _selectTime(context, false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Filtrar por:',
            style: TextStyle(
              color: context.tokens.text,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip(
                label: 'Validados',
                status: PayState.validated,
                color: context.tokens.green,
              ),
              _buildFilterChip(
                label: 'Rechazados',
                status: PayState.rejected,
                color: context.tokens.redToRosita,
              ),
              _buildFilterChip(
                label: 'Pendientes',
                status: PayState.pending,
                color: context.tokens.pending,
              ),
            ],
          ),
          if (_selectedStatus != null ||
              _startDate != null ||
              _endDate != null ||
              _startTime != null ||
              _endTime != null) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _selectedStatus = null;
                  _startDate = null;
                  _endDate = null;
                  _startTime = null;
                  _endTime = null;
                  _currentPage = 0;
                });
                _loadPays();
              },
              icon: Icon(Symbols.close, size: 16, color: context.tokens.text),
              label: Text(
                'Limpiar filtros',
                style: TextStyle(color: context.tokens.text),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required PayState status,
    required Color color,
  }) {
    final isSelected = _selectedStatus == status;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatus = isSelected ? null : status;
          _currentPage = 0;
        });
        _loadPays();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : context.tokens.stroke,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? color : context.tokens.text,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentCard(BuildContext context, Pay payment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.tokens.card1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.tokens.stroke),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Avatar, Nombre, DNI y Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF1E1E1E)
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: context.tokens.stroke),
                  ),
                  child: Icon(
                    Symbols.person,
                    color: context.tokens.placeholder,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment.effectiveUserName,
                        style: TextStyle(
                          color: context.tokens.text,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'DNI: ${payment.effectiveDni}',
                        style: TextStyle(
                          color: context.tokens.placeholder,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(
                      payment.status,
                    ).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    payment.status.displayName,
                    style: TextStyle(
                      color: _getStatusColor(payment.status),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Fechas
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Symbols.calendar_today,
                            color: context.tokens.placeholder,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'FECHA DE PAGO',
                            style: TextStyle(
                              color: context.tokens.placeholder,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _dateFormat.format(payment.paymentDate),
                        style: TextStyle(
                          color: context.tokens.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Symbols.send,
                            color: context.tokens.placeholder,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'ENVIADO',
                            style: TextStyle(
                              color: context.tokens.placeholder,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _dateFormat.format(payment.sentDate),
                        style: TextStyle(
                          color: context.tokens.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Monto
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.tokens.gray.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MONTO',
                    style: TextStyle(
                      color: context.tokens.placeholder,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${payment.amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                    style: TextStyle(
                      color: context.tokens.text,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Iconos de acción y botones
            Row(
              children: [
                InkWell(
                  onTap: () {
                    context.go('/payments/detail/${payment.id}');
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Symbols.visibility,
                      color: context.tokens.placeholder,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                InkWell(
                  onTap: (payment.fileName?.isNotEmpty ?? false)
                      ? () => _downloadReceipt(payment)
                      : null,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: _downloadingFiles[payment.id] == true
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                context.tokens.placeholder,
                              ),
                            ),
                          )
                        : Icon(
                            Symbols.description,
                            color: (payment.fileName?.isNotEmpty ?? false)
                                ? context.tokens.placeholder
                                : context.tokens.placeholder.withValues(
                                    alpha: 0.3,
                                  ),
                            size: 24,
                          ),
                  ),
                ),
                const Spacer(),
                if (payment.status == PayState.pending)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: context.tokens.redToRosita,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              _showValidationDialog(context, payment, false);
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Symbols.close,
                                    size: 20,
                                    color: context.tokens.redToRosita,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Rechazar',
                                    style: TextStyle(
                                      color: context.tokens.redToRosita,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: context.tokens.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              _showValidationDialog(context, payment, true);
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Symbols.check,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Aprobar',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                if (payment.status == PayState.rejected)
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: context.tokens.stroke,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          context
                              .push(
                                '/payments/edit/${payment.id}?from=validation',
                              )
                              .then((_) {
                                // Recargar datos después de editar
                                _loadStats();
                                _loadPays();
                              });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Symbols.edit,
                                size: 20,
                                color: context.tokens.text,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Modificar',
                                style: TextStyle(
                                  color: context.tokens.text,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(PayState status) {
    switch (status) {
      case PayState.validated:
        return context.tokens.green;
      case PayState.rejected:
        return context.tokens.redToRosita;
      case PayState.pending:
        return context.tokens.pending;
    }
  }

  Widget _buildPagination(BuildContext context) {
    final startIndex = _currentPage * _itemsPerPage + 1;
    final endIndex = (_currentPage * _itemsPerPage) + _pays.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.tokens.background,
        border: Border(top: BorderSide(color: context.tokens.stroke)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(
              Symbols.keyboard_double_arrow_left,
              color: _hasPrevious
                  ? context.tokens.text
                  : context.tokens.placeholder,
            ),
            onPressed: _hasPrevious ? () => _goToPage(0) : null,
          ),
          IconButton(
            icon: Icon(
              Symbols.chevron_left,
              color: _hasPrevious
                  ? context.tokens.text
                  : context.tokens.placeholder,
            ),
            onPressed: _hasPrevious ? () => _goToPage(_currentPage - 1) : null,
          ),
          const SizedBox(width: 8),
          Text(
            '$startIndex-$endIndex de $_totalElements',
            style: TextStyle(color: context.tokens.text, fontSize: 14),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              Symbols.chevron_right,
              color: _hasNext
                  ? context.tokens.text
                  : context.tokens.placeholder,
            ),
            onPressed: _hasNext ? () => _goToPage(_currentPage + 1) : null,
          ),
          IconButton(
            icon: Icon(
              Symbols.keyboard_double_arrow_right,
              color: _hasNext
                  ? context.tokens.text
                  : context.tokens.placeholder,
            ),
            onPressed: _hasNext ? () => _goToPage(_totalPages - 1) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: label,
                style: TextStyle(
                  color: context.tokens.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextSpan(
                text: ' *',
                style: TextStyle(
                  color: context.tokens.redToRosita,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: context.tokens.stroke),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value != null ? _dateFormat.format(value) : 'DD/MM/AAAA',
                    style: TextStyle(
                      color: value != null
                          ? context.tokens.text
                          : context.tokens.placeholder,
                      fontSize: 14,
                    ),
                  ),
                ),
                Icon(
                  Symbols.calendar_month,
                  size: 20,
                  color: context.tokens.placeholder,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField({
    required String label,
    required TimeOfDay? value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: label,
                style: TextStyle(
                  color: context.tokens.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextSpan(
                text: ' *',
                style: TextStyle(
                  color: context.tokens.redToRosita,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: context.tokens.stroke),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value != null
                        ? '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}'
                        : 'HH:MM',
                    style: TextStyle(
                      color: value != null
                          ? context.tokens.text
                          : context.tokens.placeholder,
                      fontSize: 14,
                    ),
                  ),
                ),
                Icon(
                  Symbols.schedule,
                  size: 20,
                  color: context.tokens.placeholder,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: context.tokens.redToRosita,
              onPrimary: Colors.white,
              surface: context.tokens.card1,
              onSurface: context.tokens.text,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
        _currentPage = 0;
      });
      _loadPays();
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart
          ? (_startTime ?? TimeOfDay.now())
          : (_endTime ?? TimeOfDay.now()),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: context.tokens.redToRosita,
              onPrimary: Colors.white,
              surface: context.tokens.card1,
              onSurface: context.tokens.text,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
        _currentPage = 0;
      });
      _loadPays();
    }
  }

  void _showValidationDialog(BuildContext context, Pay payment, bool approve) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        // Capturar el ScaffoldMessenger antes de cerrar el diálogo
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        final theme = Theme.of(context);
        final tokens = context.tokens;

        return AlertDialog(
          backgroundColor: tokens.card1,
          title: Text(
            approve ? '¿Aprobar pago?' : '¿Rechazar pago?',
            style: TextStyle(color: tokens.text),
          ),
          content: Text(
            'Esta acción ${approve ? 'aprobará' : 'rechazará'} el pago de ${payment.effectiveUserName} por \$${payment.amount.toStringAsFixed(3).replaceAll('.', ',')}',
            style: TextStyle(color: tokens.text),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancelar',
                style: TextStyle(color: tokens.placeholder),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                try {
                  if (approve) {
                    await _repository.validatePay(payment.id);
                  } else {
                    await _repository.rejectPay(payment.id);
                  }

                  scaffoldMessenger.showSnackBar(
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
                              approve
                                  ? 'Pago aprobado exitosamente'
                                  : 'Pago rechazado',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: approve
                          ? tokens.green
                          : tokens.redToRosita,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      margin: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                      duration: const Duration(seconds: 3),
                    ),
                  );

                  // Recargar datos después de validar/rechazar
                  _loadStats();
                  _loadPays();
                } catch (e) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Error al ${approve ? 'aprobar' : 'rechazar'} el pago: $e',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: tokens.redToRosita,
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
                backgroundColor: approve ? tokens.green : tokens.redToRosita,
              ),
              child: Text(
                approve ? 'Aprobar' : 'Rechazar',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
