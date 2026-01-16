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
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();

  int _currentStep = 0;
  bool _isProgrammed = false;
  DateTime? _scheduledDate;
  TimeOfDay? _scheduledTime;
  bool _repeatNotification = false;
  String? _selectedFrequency;
  bool _isSaving = false;

  NotificationType _selectedType = NotificationType.general;
  String _selectedRecipients = 'todos';

  final List<String> _frequencies = [
    'Diaria',
    'Semanal',
    'Quincenal',
    'Mensual',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
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
      setState(() {
        _scheduledDate = picked;
        _dateController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
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
      setState(() {
        _scheduledTime = picked;
        _timeController.text =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_titleController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El título es obligatorio')),
        );
        return;
      }
      if (_messageController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El mensaje es obligatorio')),
        );
        return;
      }
      if (_isProgrammed && (_scheduledDate == null || _scheduledTime == null)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Completá la fecha y hora')),
        );
        return;
      }
      if (_isProgrammed && _repeatNotification && _selectedFrequency == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seleccioná una frecuencia')),
        );
        return;
      }
    }

    if (_currentStep < 2) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
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
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Crear Notificación',
              style: TextStyle(
                color: context.tokens.text,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              _getStepTitle(),
              style: TextStyle(
                color: context.tokens.text.withOpacity(0.6),
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_currentStep == 0) ..._buildStep1(),
                  if (_currentStep == 1) ..._buildStep2(),
                  if (_currentStep == 2) ..._buildStep3(),
                ],
              ),
            ),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Paso 1: Contenido';
      case 1:
        return 'Paso 2: Destinatarios';
      case 2:
        return 'Paso 3: Revisión';
      default:
        return '';
    }
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      color: context.tokens.card1,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;

          return Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive
                      ? context.tokens.redToRosita
                      : isCompleted
                      ? context.tokens.redToRosita.withOpacity(0.5)
                      : Colors.grey.shade300,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: isActive || isCompleted
                          ? Colors.white
                          : Colors.grey.shade600,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              if (index < 2)
                Container(
                  width: MediaQuery.of(context).size.width * 0.25,
                  height: 2,
                  color: Colors.grey.shade300,
                ),
            ],
          );
        }),
      ),
    );
  }

  List<Widget> _buildStep1() {
    return [
      Container(
        decoration: BoxDecoration(
          color: context.tokens.card1,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.tokens.stroke),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Symbols.send, size: 20, color: context.tokens.text),
                const SizedBox(width: 8),
                Text(
                  'Tipo de Envío',
                  style: TextStyle(
                    color: context.tokens.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildRadioTile(
              'Enviar ahora',
              !_isProgrammed,
              () => setState(() => _isProgrammed = false),
            ),
            _buildRadioTile(
              'Programar envío',
              _isProgrammed,
              () => setState(() => _isProgrammed = true),
            ),
          ],
        ),
      ),

      if (_isProgrammed) ...[
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: context.tokens.card1,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.tokens.stroke),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Symbols.calendar_month,
                    size: 20,
                    color: context.tokens.text,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Fecha y hora',
                    style: TextStyle(
                      color: context.tokens.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _dateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Fecha *',
                        hintText: 'DD/MM/AAAA',
                        suffixIcon: IconButton(
                          icon: const Icon(Symbols.calendar_today, size: 20),
                          onPressed: _selectDate,
                        ),
                        filled: true,
                        fillColor: context.tokens.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: context.tokens.text.withOpacity(0.2),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: context.tokens.text.withOpacity(0.2),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: context.tokens.redToRosita,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      onTap: _selectDate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _timeController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Hora *',
                        hintText: 'HH:MM',
                        suffixIcon: IconButton(
                          icon: const Icon(Symbols.schedule, size: 20),
                          onPressed: _selectTime,
                        ),
                        filled: true,
                        fillColor: context.tokens.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: context.tokens.text.withOpacity(0.2),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: context.tokens.text.withOpacity(0.2),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: context.tokens.redToRosita,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      onTap: _selectTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () => setState(() {
                  _repeatNotification = !_repeatNotification;
                  if (!_repeatNotification) {
                    _selectedFrequency = null;
                  }
                }),
                child: Row(
                  children: [
                    Icon(Symbols.repeat, size: 20, color: context.tokens.text),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Repetir notificación',
                        style: TextStyle(
                          color: context.tokens.text,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Checkbox(
                      value: _repeatNotification,
                      onChanged: (value) => setState(() {
                        _repeatNotification = value ?? false;
                        if (!_repeatNotification) {
                          _selectedFrequency = null;
                        }
                      }),
                      activeColor: context.tokens.redToRosita,
                    ),
                  ],
                ),
              ),
              if (_repeatNotification) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedFrequency,
                  decoration: InputDecoration(
                    labelText: 'Frecuencia *',
                    hintText: 'Seleccionar frecuencia...',
                    filled: true,
                    fillColor: context.tokens.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: context.tokens.text.withOpacity(0.2),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: context.tokens.text.withOpacity(0.2),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: context.tokens.redToRosita,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  items: _frequencies
                      .map(
                        (freq) =>
                            DropdownMenuItem(value: freq, child: Text(freq)),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedFrequency = value),
                ),
              ],
            ],
          ),
        ),
      ],

      const SizedBox(height: 16),
      Container(
        decoration: BoxDecoration(
          color: context.tokens.card1,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.tokens.stroke),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Symbols.info, size: 20, color: context.tokens.text),
                const SizedBox(width: 8),
                Text(
                  'Contenido del Mensaje',
                  style: TextStyle(
                    color: context.tokens.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              maxLength: 100,
              decoration: InputDecoration(
                labelText: 'Título *',
                filled: true,
                fillColor: context.tokens.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: context.tokens.text.withOpacity(0.2),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: context.tokens.text.withOpacity(0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: context.tokens.redToRosita,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _messageController,
              maxLength: 500,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Mensaje *',
                filled: true,
                fillColor: context.tokens.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: context.tokens.text.withOpacity(0.2),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: context.tokens.text.withOpacity(0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: context.tokens.redToRosita,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildStep2() {
    return [const Text('Paso 2: Destinatarios - En construcción')];
  }

  List<Widget> _buildStep3() {
    return [const Text('Paso 3: Revisión - En construcción')];
  }

  Widget _buildSectionHeader(String icon, String title) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: context.tokens.text,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildRadioTile(String title, bool value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: value
              ? context.tokens.redToRosita.withOpacity(0.05)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: value
                ? context.tokens.redToRosita.withOpacity(0.3)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Radio<bool>(
              value: value,
              groupValue: true,
              onChanged: (_) => onTap(),
              activeColor: context.tokens.redToRosita,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(color: context.tokens.text, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.tokens.card1,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: context.tokens.redToRosita),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Anterior',
                  style: TextStyle(
                    color: context.tokens.redToRosita,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          SizedBox(
            width: _currentStep == 0 ? 150 : null,
            child: FilledButton(
              onPressed: _currentStep == 2 ? null : _nextStep,
              style: FilledButton.styleFrom(
                backgroundColor: context.tokens.redToRosita,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 24,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                _currentStep == 2 ? 'Enviar' : 'Siguiente',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
