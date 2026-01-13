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
  List<NotificationModel> _filteredNotifications = [];
  bool _isLoading = true;
  int _currentPage = 1;
  final int _itemsPerPage = 25;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final notifications = await _repository.getNotifications();
      if (!mounted) return;
      setState(() {
        _notifications = notifications;
        _filteredNotifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _filterNotifications(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredNotifications = _notifications;
      } else {
        _filteredNotifications = _notifications
            .where((n) => n.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
      _currentPage = 1;
    });
  }

  Future<void> _deleteNotification(String id) async {
    try {
      await _repository.deleteNotification(id);
      if (!mounted) return;

      setState(() {
        _notifications.removeWhere((n) => n.id == id);
        _filteredNotifications.removeWhere((n) => n.id == id);
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
          backgroundColor: context.tokens.redToRosita,
        ),
      );
    }
  }

  int get _totalPages => (_filteredNotifications.length / _itemsPerPage).ceil();

  List<NotificationModel> get _paginatedNotifications {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    return _filteredNotifications.sublist(
      startIndex,
      endIndex > _filteredNotifications.length
          ? _filteredNotifications.length
          : endIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.tokens.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push('/notifications/new');
          _loadNotifications();
        },
        backgroundColor: context.tokens.redToRosita,
        child: const Icon(Symbols.add, color: Colors.white),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: context.tokens.redToRosita,
              ),
            )
          : Column(
              children: [
                _buildSearchBar(),
                Expanded(
                  child: _filteredNotifications.isEmpty
                      ? Center(
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
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _paginatedNotifications.length,
                          itemBuilder: (context, index) {
                            final notification = _paginatedNotifications[index];
                            return _buildNotificationCard(notification);
                          },
                        ),
                ),
                if (_filteredNotifications.isNotEmpty) _buildPagination(),
              ],
            ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
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
          onChanged: _filterNotifications,
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

  Widget _buildNotificationCard(NotificationModel notification) {
    final recipientCount = notification.recipients.length * 43;

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
                          Text(
                            notification.title,
                            style: TextStyle(
                              color: context.tokens.text,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Pamela Perez',
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
                      onSelected: (value) {
                        switch (value) {
                          case 'view':
                            break;
                          case 'edit':
                            break;
                          case 'delete':
                            _deleteNotification(notification.id);
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
                          child: Row(
                            children: [
                              Icon(
                                Symbols.edit,
                                size: 20,
                                color: context.tokens.text,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Modificar',
                                style: TextStyle(color: context.tokens.text),
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
                                color: context.tokens.redToRosita,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Eliminar',
                                style: TextStyle(
                                  color: context.tokens.redToRosita,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
                        if (notification.recurrence != null)
                          Text(
                            notification.recurrence!,
                            style: TextStyle(
                              color: context.tokens.placeholder,
                              fontSize: 11,
                            ),
                          )
                        else if (notification.specificDate != null)
                          Text(
                            'Fecha: ${notification.specificDate!.day.toString().padLeft(2, '0')}/${notification.specificDate!.month.toString().padLeft(2, '0')}/${notification.specificDate!.year.toString().substring(2)}',
                            style: TextStyle(
                              color: context.tokens.placeholder,
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      '$recipientCount',
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
                onTap: () {},
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
    final startItem = (_currentPage - 1) * _itemsPerPage + 1;
    final endItem = _currentPage * _itemsPerPage > _filteredNotifications.length
        ? _filteredNotifications.length
        : _currentPage * _itemsPerPage;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.tokens.card1,
        border: Border(top: BorderSide(color: context.tokens.stroke, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _currentPage > 1
                ? () => setState(() => _currentPage--)
                : null,
            icon: Icon(
              Symbols.chevron_left,
              color: _currentPage > 1
                  ? context.tokens.text
                  : context.tokens.text.withOpacity(0.3),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '$startItem-$endItem de ${_filteredNotifications.length}',
            style: TextStyle(
              color: context.tokens.text,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: _currentPage < _totalPages
                ? () => setState(() => _currentPage++)
                : null,
            icon: Icon(
              Symbols.chevron_right,
              color: _currentPage < _totalPages
                  ? context.tokens.text
                  : context.tokens.text.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }
}
