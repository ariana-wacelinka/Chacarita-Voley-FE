import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../../app/theme/app_theme.dart';
import '../../domain/entities/user.dart';

class UserListItem extends StatelessWidget {
  final User user;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const UserListItem({
    super.key,
    required this.user,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.tokens.card1,
        border: Border(
          bottom: BorderSide(color: context.tokens.stroke, width: 0.5),
        ),
      ),
      child: InkWell(
        onTap: onView,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  user.dni,
                  style: TextStyle(
                    color: context.tokens.text,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              Expanded(
                flex: 2,
                child: Text(
                  user.nombreCompleto,
                  style: TextStyle(
                    color: context.tokens.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              SizedBox(
                width: 60,
                child: Text(
                  user.equipo,
                  style: TextStyle(
                    color: context.tokens.text,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(width: 60, child: _buildEstadoCuotaIcon(context)),

              SizedBox(
                width: 40,
                child: PopupMenuButton<String>(
                  icon: Icon(
                    Symbols.more_vert,
                    color: context.tokens.placeholder,
                    weight: 1000,
                    size: 20,
                  ),
                  onSelected: (value) {
                    switch (value) {
                      case 'view':
                        onView();
                        break;
                      case 'edit':
                        onEdit();
                        break;
                      case 'delete':
                        onDelete();
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
                            size: 18,
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
                            size: 18,
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
                            size: 18,
                            color: context.tokens.redToRosita,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Eliminar',
                            style: TextStyle(color: context.tokens.redToRosita),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEstadoCuotaIcon(BuildContext context) {
    // Si no tiene playerId, no paga cuota - mostrar "-"
    if (user.playerId == null || user.playerId!.isEmpty) {
      return Center(
        child: Text(
          '-',
          style: TextStyle(
            color: context.tokens.placeholder,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    // Usuario con playerId: mostrar estado de cuota
    IconData icon;
    Color color;

    switch (user.estadoCuota) {
      case EstadoCuota.alDia:
        icon = Symbols.check_circle;
        color = context.tokens.green;
        break;
      case EstadoCuota.vencida:
        icon = Symbols.cancel;
        color = context.tokens.redToRosita;
        break;
      case EstadoCuota.ultimoPago:
        icon = Symbols.schedule;
        color = context.tokens.pending;
        break;
    }

    return Icon(icon, color: color, size: 20);
  }
}
