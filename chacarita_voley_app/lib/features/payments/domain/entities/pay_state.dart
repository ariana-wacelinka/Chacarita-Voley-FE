enum PayState {
  pending,
  validated,
  rejected,
  // Agrega más si tu API tiene (e.g., from introspection)
}

extension PayStateExtension on PayState {
  String get displayName {
    switch (this) {
      case PayState.pending:
        return 'Pendiente';
      case PayState.validated:
        return 'Aprobado';
      case PayState.rejected:
        return 'Rechazado';
    }
  }
}
