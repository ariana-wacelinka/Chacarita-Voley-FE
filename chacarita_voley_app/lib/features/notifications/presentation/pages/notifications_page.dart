import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../app/theme/app_theme.dart';
import '../../domain/entities/notification.dart';
import '../../data/repositories/notification_repository.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final _repository = NotificationRepository();
  final _searchController = TextEditingController();
  List<NotificationModel> _notifications = [];
  Future<void>? _notificationsFuture;
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  int _totalPages = 1;
  int _totalElements = 0;
  bool _hasNext = false;
  bool _hasPrevious = false;
  String _searchQuery = '';
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _notificationsFuture = _fetchNotifications();
    });
  }

  Future<void> _fetchNotifications() async {
    try {
      final result = await _repository.getNotifications(
        page: _currentPage - 1, // Backend usa 0-based indexing
        size: _itemsPerPage,
        search: _searchQuery,
      );
      if (!mounted) return;
      setState(() {
        _notifications = result.notifications;
        _totalPages = result.totalPages;
        _totalElements = result.totalElements;
        _hasNext = result.hasNext;
        _hasPrevious = result.hasPrevious;
      });
    } catch (e) {
      if (!mounted) return;
    }
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = query;
        _currentPage = 1;
      });
      _loadNotifications();
    });
  }

  Future<void> _showDeleteConfirmation(String id) async {
    final notification = _notifications.firstWhere((n) => n.id == id);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.tokens.card1,
        title: Text(
          'Confirmar eliminación',
          style: TextStyle(
            color: context.tokens.text,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          '¿Estás seguro de que querés eliminar "${notification.title}"? Esta acción no se puede deshacer.',
          style: TextStyle(color: context.tokens.text),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE0E0E0),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF8B0000),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Confirmar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _deleteNotification(id);
    }
  }

  Future<void> _deleteNotification(String id) async {
    try {
      await _repository.deleteNotification(id);
      if (!mounted) return;

      setState(() {
        _notifications.removeWhere((n) => n.id == id);
        _notifications.removeWhere((n) => n.id == id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Text('Notificación eliminada'),
            ],
          ),
          backgroundColor: context.tokens.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar: $e'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }

  void _nextPage() {
    if (_hasNext) {
      setState(() {
        _currentPage++;
      });
      _loadNotifications();
    }
  }

  void _previousPage() {
    if (_currentPage > 1 && _hasPrevious) {
      setState(() {
        _currentPage--;
      });
      _loadNotifications();
    }
  }

  List<NotificationModel> get _paginatedNotifications {
    // Ahora los datos ya vienen paginados del backend
    return _notifications;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.tokens.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await context.push('/notifications/new');
          if (result == true && mounted) {
            _loadNotifications();
          }
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Symbols.add, color: Colors.white),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: FutureBuilder<void>(
              future: _notificationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    _notifications.isEmpty) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  );
                }

                if (_notifications.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Symbols.notifications_off,
                          size: 64,
                          color: context.tokens.text.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay notificaciones',
                          style: TextStyle(
                            color: context.tokens.text.withOpacity(0.5),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    _loadNotifications();
                    await Future.delayed(
                      const Duration(milliseconds: 500),
                    );
                  },
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: _paginatedNotifications.length,
                    itemBuilder: (context, index) {
                      final notification = _paginatedNotifications[index];
                      return _buildNotificationCard(notification);
                    },
                  ),
                );
              },
            ),
          ),
          if (_notifications.isNotEmpty) _buildPagination(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
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
            hintText: 'Buscar por título...',
            hintStyle: TextStyle(color: context.tokens.placeholder),
            prefixIcon: Icon(Symbols.search, color: context.tokens.placeholder),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          style: TextStyle(color: context.tokens.text),
        ),
      ),
    );
  }

  Color _getStatusColor(NotificationStatus status) {
    switch (status) {
      case NotificationStatus.SENT:
        return Colors.green;
      case NotificationStatus.FAILED:
        return context.tokens.redToRosita;
      case NotificationStatus.PROCESSING:
        return Colors.orange;
      case NotificationStatus.SCHEDULED:
        return Theme.of(context).colorScheme.primary;
      case NotificationStatus.CREATED:
        return context.tokens.placeholder;
    }
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.tokens.card1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.tokens.stroke, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  notification.title,
                                  style: TextStyle(
                                    color: context.tokens.text,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (!notification.repeatable) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: notification.status != null
                                        ? _getStatusColor(
                                            notification.status!,
                                          ).withOpacity(0.15)
                                        : (notification.deliveries.isNotEmpty
                                              ? Colors.green.withOpacity(0.15)
                                              : Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                    .withOpacity(0.15)),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: notification.status != null
                                          ? _getStatusColor(
                                              notification.status!,
                                            )
                                          : (notification.deliveries.isNotEmpty
                                                ? Colors.green
                                                : Theme.of(
                                                    context,
                                                  ).colorScheme.primary),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    notification.status != null
                                        ? notification.status!.displayName
                                        : (notification.deliveries.isNotEmpty
                                              ? 'Enviado'
                                              : 'Programado'),
                                    style: TextStyle(
                                      color: notification.status != null
                                          ? _getStatusColor(
                                              notification.status!,
                                            )
                                          : (notification.deliveries.isNotEmpty
                                                ? Colors.green
                                                : Theme.of(
                                                    context,
                                                  ).colorScheme.primary),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            notification.sender != null
                                ? '${notification.sender!.name} ${notification.sender!.surname}'
                                : 'Usuario desconocido',
                            style: TextStyle(
                              color: context.tokens.text.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Symbols.more_vert,
                        color: context.tokens.text,
                        size: 20,
                      ),
                      color: context.tokens.card2,
                      onSelected: (value) async {
                        switch (value) {
                          case 'view':
                            final result = await context.push(
                              '/notifications/${notification.id}',
                            );
                            if (result == true && mounted) {
                              _loadNotifications();
                            }
                            break;
                          case 'edit':
                            final result = await context.push(
                              '/notifications/${notification.id}/edit',
                            );
                            if (result == true && mounted) {
                              _loadNotifications();
                            }
                            break;
                          case 'delete':
                            _showDeleteConfirmation(notification.id);
                            break;
                        }
                      },
                      itemBuilder: (context) {
                        final canEdit =
                            (notification.sendMode == SendMode.SCHEDULED ||
                                notification.deliveries.isEmpty) &&
                            notification.status != NotificationStatus.SENT;

                        return [
                          PopupMenuItem(
                            value: 'view',
                            child: Row(
                              children: [
                                Icon(
                                  Symbols.visibility,
                                  size: 20,
                                  color: context.tokens.text,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Ver',
                                  style: TextStyle(color: context.tokens.text),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'edit',
                            enabled: canEdit,
                            child: Row(
                              children: [
                                Icon(
                                  Symbols.edit,
                                  size: 20,
                                  color: canEdit
                                      ? context.tokens.text
                                      : context.tokens.text.withOpacity(0.3),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Modificar',
                                  style: TextStyle(
                                    color: canEdit
                                        ? context.tokens.text
                                        : context.tokens.text.withOpacity(0.3),
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
                                  size: 20,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Eliminar',
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ];
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Symbols.schedule,
                              size: 16,
                              color: context.tokens.text.withOpacity(0.6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              notification.startTime,
                              style: TextStyle(
                                color: context.tokens.text.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        if (notification.getRepeatText().isNotEmpty)
                          Text(
                            notification.getRepeatText(),
                            style: TextStyle(
                              color: context.tokens.placeholder,
                              fontSize: 11,
                            ),
                          ),
                        if (notification.sendMode == SendMode.SCHEDULED &&
                            !notification.repeatable &&
                            notification.scheduledAt != null)
                          Text(
                            'Envío: ${notification.scheduledAt!.day.toString().padLeft(2, '0')}/${notification.scheduledAt!.month.toString().padLeft(2, '0')}/${notification.scheduledAt!.year}',
                            style: TextStyle(
                              color: context.tokens.placeholder,
                              fontSize: 11,
                            ),
                          ),
                        if (notification.sendMode == SendMode.NOW &&
                            !notification.repeatable &&
                            notification.createdAt != null)
                          Text(
                            'Envío no programado: ${notification.createdAt!.day.toString().padLeft(2, '0')}/${notification.createdAt!.month.toString().padLeft(2, '0')}/${notification.createdAt!.year}',
                            style: TextStyle(
                              color: context.tokens.placeholder,
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      '${notification.countOfPlayers}',
                      style: TextStyle(
                        color: context.tokens.text.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Symbols.group,
                      size: 16,
                      color: context.tokens.text.withOpacity(0.6),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: context.tokens.stroke, width: 1),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  final result = await context.push(
                    '/notifications/${notification.id}',
                  );
                  if (result == true && mounted) {
                    _loadNotifications();
                  }
                },
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Symbols.notifications,
                        size: 20,
                        color: context.tokens.text.withOpacity(0.7),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Ver detalle',
                        style: TextStyle(
                          color: context.tokens.text,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Symbols.chevron_right,
                        size: 20,
                        color: context.tokens.text.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: context.tokens.background),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _hasPrevious ? _previousPage : null,
            icon: Icon(
              Symbols.chevron_left,
              color: _hasPrevious
                  ? context.tokens.text
                  : context.tokens.text.withOpacity(0.3),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            _buildPaginationText(),
            style: TextStyle(
              color: context.tokens.text,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: _hasNext ? _nextPage : null,
            icon: Icon(
              Symbols.chevron_right,
              color: _hasNext
                  ? context.tokens.text
                  : context.tokens.text.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  String _buildPaginationText() {
    if (_totalElements == 0) {
      return '0-0 de 0';
    }
    final start = (_currentPage - 1) * _itemsPerPage + 1;
    final end = (_currentPage * _itemsPerPage).clamp(0, _totalElements);
    return '$start-$end de $_totalElements';
  }
}
