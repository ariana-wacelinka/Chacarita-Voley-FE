import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../app/theme/app_theme.dart';
import '../../domain/entities/notification.dart';
import '../../data/repositories/notification_repository.dart';

class NewNotificationPage extends StatefulWidget {
  const NewNotificationPage({super.key});

  @override
  State<NewNotificationPage> createState() => _NewNotificationPageState();
}

class _NewNotificationPageState extends State<NewNotificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _repository = NotificationRepository();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();

  NotificationType _selectedType = NotificationType.general;
  String _selectedRecipients = 'todos';
  bool _isProgrammed = false;
  DateTime? _scheduledDate;
  TimeOfDay? _scheduledTime;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    DateTime? scheduledFor;
    if (_isProgrammed && _scheduledDate != null && _scheduledTime != null) {
      scheduledFor = DateTime(
        _scheduledDate!.year,
        _scheduledDate!.month,
        _scheduledDate!.day,
        _scheduledTime!.hour,
        _scheduledTime!.minute,
      );
    }

    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      message: _messageController.text.trim(),
      type: _selectedType,
      status: _isProgrammed
          ? NotificationStatus.programada
          : NotificationStatus.enviada,
      createdAt: DateTime.now(),
      scheduledFor: scheduledFor,
      recipients: [_selectedRecipients],
      recipientsText: _getRecipientsText(_selectedRecipients),
      startTime: _scheduledTime != null
          ? '${_scheduledTime!.hour.toString().padLeft(2, '0')}:${_scheduledTime!.minute.toString().padLeft(2, '0')}'
          : '18:00',
    );

    try {
      await _repository.createNotification(notification);

      if (!mounted) return;

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
              Text(
                _isProgrammed
                    ? 'Notificación programada'
                    : 'Notificación enviada',
              ),
            ],
          ),
          backgroundColor: context.tokens.redToRosita,
          behavior: SnackBarBehavior.floating,
        ),
      );

      context.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: context.tokens.redToRosita,
        ),
      );
    }
  }

  String _getRecipientsText(String recipients) {
    switch (recipients) {
      case 'todos':
        return 'Todos los socios';
      case 'profesores':
        return 'Todos los profesores';
      case 'equipo-1':
        return 'Equipo Masculino A';
      case 'equipo-2':
        return 'Equipo Femenino B';
      default:
        return 'Sin destinatarios';
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _scheduledDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: context.tokens.redToRosita),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _scheduledDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _scheduledTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: context.tokens.redToRosita),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _scheduledTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Nueva Notificación',
          style: TextStyle(
            color: context.tokens.text,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTitleField(),
            const SizedBox(height: 16),
            _buildMessageField(),
            const SizedBox(height: 16),
            _buildTypeSelector(),
            const SizedBox(height: 16),
            _buildRecipientsSelector(),
            const SizedBox(height: 16),
            _buildScheduleSection(),
            const SizedBox(height: 32),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Título *',
          style: TextStyle(color: context.tokens.text, fontSize: 12),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            hintText: 'Ej: Recordatorio de cuota',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Ingresá un título';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildMessageField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mensaje *',
          style: TextStyle(color: context.tokens.text, fontSize: 12),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: _messageController,
          decoration: const InputDecoration(
            hintText: 'Escribí el mensaje de la notificación',
          ),
          maxLines: 4,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Ingresá un mensaje';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de notificación *',
          style: TextStyle(color: context.tokens.text, fontSize: 12),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<NotificationType>(
          value: _selectedType,
          decoration: const InputDecoration(hintText: 'Seleccionar...'),
          items: NotificationType.values
              .map(
                (type) => DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedType = value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildRecipientsSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Destinatarios *',
          style: TextStyle(color: context.tokens.text, fontSize: 12),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: _selectedRecipients,
          decoration: const InputDecoration(hintText: 'Seleccionar...'),
          items: const [
            DropdownMenuItem(value: 'todos', child: Text('Todos los socios')),
            DropdownMenuItem(
              value: 'profesores',
              child: Text('Todos los profesores'),
            ),
            DropdownMenuItem(
              value: 'equipo-1',
              child: Text('Equipo Masculino A'),
            ),
            DropdownMenuItem(
              value: 'equipo-2',
              child: Text('Equipo Femenino B'),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedRecipients = value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildScheduleSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.tokens.card1,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Programar envío',
                  style: TextStyle(
                    color: context.tokens.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Switch(
                value: _isProgrammed,
                onChanged: (value) {
                  setState(() => _isProgrammed = value);
                },
                activeColor: context.tokens.redToRosita,
              ),
            ],
          ),
          if (_isProgrammed) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _selectDate,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.tokens.card2,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Symbols.calendar_today,
                            color: context.tokens.text.withOpacity(0.7),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _scheduledDate == null
                                ? 'Fecha'
                                : '${_scheduledDate!.day}/${_scheduledDate!.month}/${_scheduledDate!.year}',
                            style: TextStyle(
                              color: context.tokens.text,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: _selectTime,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.tokens.card2,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Symbols.schedule,
                            color: context.tokens.text.withOpacity(0.7),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _scheduledTime == null
                                ? 'Hora'
                                : '${_scheduledTime!.hour}:${_scheduledTime!.minute.toString().padLeft(2, '0')} hs',
                            style: TextStyle(
                              color: context.tokens.text,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isSaving ? null : _submit,
      style: ElevatedButton.styleFrom(
        backgroundColor: context.tokens.redToRosita,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: _isSaving
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(
              _isProgrammed ? 'Programar' : 'Enviar ahora',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
    );
  }
}
