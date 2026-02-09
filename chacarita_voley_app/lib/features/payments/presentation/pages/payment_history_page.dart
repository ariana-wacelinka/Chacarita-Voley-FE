import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../app/layout/app_drawer.dart';
import '../../../../core/services/file_upload_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/permissions_service.dart';
import '../../domain/entities/pay.dart';
import '../../data/repositories/pay_repository.dart';
import '../../domain/entities/pay_state.dart';
import '../../domain/entities/pay_page.dart';
import '../widgets/payment_history_content_widget.dart';
import '../../../users/domain/entities/due.dart' show CurrentDue;
import '../../../users/data/repositories/user_repository.dart';

class PaymentHistoryPage extends StatefulWidget {
  final String userId;
  final String userName;
  final PayRepository? payRepository;
  final UserRepository? userRepository;

  const PaymentHistoryPage({
    super.key,
    required this.userId,
    required this.userName,
    this.payRepository,
    this.userRepository,
  });

  @override
  State<PaymentHistoryPage> createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  late final PayRepository _payRepository;
  late final UserRepository _userRepository;
  List<Pay> _payments = [];
  bool _isLoading = true;
  List<String> _userRoles = [];
  int? _currentUserId;
  bool _isOwnPaymentHistory = false;
  CurrentDue? _currentDue;
  String? _playerId;

  int _currentPage = 0;
  static const int _itemsPerPage = 7;
  int _totalElements = 0;
  int _totalPages = 0;
  bool _hasNext = false;
  bool _hasPrevious = false;

  DateTime? _startDate;
  DateTime? _endDate;

  final Map<String, bool> _downloadingFiles = {};

  @override
  void initState() {
    super.initState();
    _payRepository = widget.payRepository ?? PayRepository();
    _userRepository = widget.userRepository ?? UserRepository();
    _loadUserRoles();
    _loadData();
  }

  Future<void> _loadUserRoles() async {
    final authService = AuthService();
    final roles = await authService.getUserRoles();
    final userId = await authService.getUserId();
    if (mounted) {
      setState(() {
        _userRoles = roles ?? [];
        _currentUserId = userId;
        _isOwnPaymentHistory = userId.toString() == widget.userId;
      });
    }
  }

  void _handleBack() {
    // Intentar hacer pop si hay stack, sino navegar según contexto
    if (context.canPop()) {
      context.pop();
    } else if (_isOwnPaymentHistory) {
      final isPlayer = PermissionsService.isPlayer(_userRoles);
      if (isPlayer) {
        context.go('/home');
      } else {
        context.go('/settings');
      }
    } else {
      context.go('/users/${widget.userId}/view');
    }
  }

  Future<void> _loadData() async {
    await _loadCurrentDue();
    await _loadPays();
  }

  Future<void> _loadCurrentDue() async {
    try {
      final user = await _userRepository.getUserById(widget.userId);
      if (mounted) {
        setState(() {
          _currentDue = user?.currentDue;
          _playerId = user?.playerId;
        });
      }
    } catch (e) {
      // No es crítico si falla, continuar sin currentDue
    }
  }

  Future<void> _loadPays() async {
    setState(() => _isLoading = true);

    try {
      final playerId = _playerId;
      if (playerId == null || playerId.isEmpty) {
        if (!mounted) return;
        setState(() {
          _payments = [];
          _totalElements = 0;
          _totalPages = 0;
          _hasNext = false;
          _hasPrevious = false;
          _isLoading = false;
        });
        return;
      }

      final payPage = await _payRepository.getPaysByPlayerId(
        playerId: playerId,
        page: _currentPage,
        size: _itemsPerPage,
        dateFrom: _startDate?.toIso8601String().split('T')[0],
        dateTo: _endDate?.toIso8601String().split('T')[0],
      );

      if (!mounted) return;

      setState(() {
        _payments = payPage.content;
        _totalElements = payPage.totalElements;
        _totalPages = payPage.totalPages;
        _hasNext = payPage.hasNext;
        _hasPrevious = payPage.hasPrevious;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar historial de pagos: $e'),
          backgroundColor: context.tokens.redToRosita,
        ),
      );
    }
  }

  Future<void> _handleDownload(Pay payment) async {
    if (payment.fileName == null || payment.fileName!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No hay comprobante disponible'),
          backgroundColor: context.tokens.redToRosita,
        ),
      );
      return;
    }

    setState(() {
      _downloadingFiles[payment.id] = true;
    });

    try {
      await FileUploadService.downloadPaymentReceiptWithNotification(
        paymentId: payment.id,
        fileName: payment.fileName!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Comprobante descargado'),
            backgroundColor: context.tokens.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al descargar: $e'),
            backgroundColor: context.tokens.redToRosita,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _downloadingFiles.remove(payment.id);
        });
      }
    }
  }

  void _handleEdit(Pay payment) {
    context
        .push(
          '/payments/edit/${payment.id}?userId=${widget.userId}&userName=${Uri.encodeComponent(widget.userName)}&from=payment-history',
        )
        .then((_) {
          // Recargar datos después de editar
          _loadData();
        });
  }

  void _nextPage() {
    if (_hasNext) {
      setState(() => _currentPage++);
      _loadPays();
    }
  }

  void _previousPage() {
    if (_hasPrevious) {
      setState(() => _currentPage--);
      _loadPays();
    }
  }

  int get _startItem =>
      _totalElements == 0 ? 0 : _currentPage * _itemsPerPage + 1;

  int get _endItem =>
      ((_currentPage + 1) * _itemsPerPage).clamp(0, _totalElements);

  void _onFiltersChanged(DateTime? startDate, DateTime? endDate) {
    setState(() {
      _startDate = startDate;
      _endDate = endDate;
      _currentPage = 0;
    });
    _loadPays();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isPlayer = PermissionsService.isPlayer(_userRoles);

    return Scaffold(
      backgroundColor: tokens.background,
      drawer: (isPlayer && _isOwnPaymentHistory) ? const AppDrawer() : null,
      appBar: AppBar(
        backgroundColor: tokens.card1,
        elevation: 0,
        leading: (isPlayer && _isOwnPaymentHistory)
            ? null
            : IconButton(
                icon: Icon(Symbols.arrow_back, color: tokens.text),
                onPressed: _handleBack,
              ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Historial de Pagos',
              style: TextStyle(
                color: tokens.text,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (!isPlayer)
              Text(
                widget.userName,
                style: TextStyle(
                  color: tokens.placeholder,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
          ],
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(tokens.redToRosita),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: PaymentHistoryContent(
                        payments: _payments,
                        allPayments: _payments,
                        userName: widget.userName,
                        userId: widget.userId,
                        currentDue: _currentDue,
                        onFiltersChanged: _onFiltersChanged,
                        onDownload: _handleDownload,
                        onEdit: _handleEdit,
                        downloadingFiles: _downloadingFiles,
                        startDate: _startDate,
                        endDate: _endDate,
                      ),
                    ),
                  ),
                ),
                if (_totalElements > 0) _buildPagination(tokens),
              ],
            ),
      floatingActionButton: SizedBox(
        width: 56,
        height: 56,
        child: FloatingActionButton(
          onPressed: () {
            context.push(
              '/payments/create?userId=${widget.userId}&userName=${Uri.encodeComponent(widget.userName)}',
            );
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

  Widget _buildPagination(AppTokens tokens) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: context.tokens.background),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _hasPrevious ? _previousPage : null,
            icon: Icon(
              Symbols.chevron_left,
              color: _hasPrevious ? tokens.text : tokens.placeholder,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$_startItem-$_endItem de $_totalElements',
            style: TextStyle(
              color: tokens.text,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _hasNext ? _nextPage : null,
            icon: Icon(
              Symbols.chevron_right,
              color: _hasNext ? tokens.text : tokens.placeholder,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
