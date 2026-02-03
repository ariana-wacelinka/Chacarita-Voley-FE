class PermissionsService {
  // USUARIOS
  static bool canAccessUsers(List<String> roles) {
    return roles.contains('ADMIN') || roles.contains('PROFESSOR');
  }

  static bool canCreateUser(List<String> roles) {
    return roles.contains('ADMIN');
  }

  static bool canEditUser(List<String> roles) {
    // Jugador puede editar su propio perfil (verificar en runtime que sea su propio ID)
    // Admin puede editar cualquier usuario
    return roles.contains('ADMIN') ||
        roles.contains('PROFESSOR') ||
        roles.contains('PLAYER');
  }

  static bool canDeleteUser(List<String> roles) {
    return roles.contains('ADMIN');
  }

  static bool canViewUser(List<String> roles) {
    // Jugador puede ver su propio perfil
    // Admin y Profesor pueden ver todos
    return roles.contains('ADMIN') ||
        roles.contains('PROFESSOR') ||
        roles.contains('PLAYER');
  }

  static bool canSendUserNotification(List<String> roles) {
    return roles.contains('ADMIN') || roles.contains('PROFESSOR');
  }

  static bool canViewUserAttendance(List<String> roles) {
    return roles.contains('ADMIN') || roles.contains('PROFESSOR');
  }

  static bool canViewUserPayments(List<String> roles) {
    return roles.contains('ADMIN') || roles.contains('PROFESSOR');
  }

  // CUOTAS/PAGOS
  static bool canAccessPayments(List<String> roles) {
    // Admin accede a la gestión completa de pagos de todos
    return roles.contains('ADMIN');
  }

  static bool canValidatePayments(List<String> roles) {
    return roles.contains('ADMIN');
  }

  static bool canCreatePayment(List<String> roles) {
    // Jugador puede crear sus propios pagos (subir comprobantes)
    // Admin puede crear pagos de cualquiera
    return roles.contains('ADMIN') || roles.contains('PLAYER');
  }

  static bool canEditPayment(List<String> roles) {
    // Jugador puede editar sus propios pagos pendientes
    // Admin puede editar cualquier pago
    return roles.contains('ADMIN') || roles.contains('PLAYER');
  }

  static bool canViewPaymentDetail(List<String> roles) {
    // Todos pueden ver detalles de pagos (los jugadores solo los suyos)
    return roles.contains('ADMIN') ||
        roles.contains('PLAYER') ||
        roles.contains('PROFESSOR');
  }

  // NOTIFICACIONES
  static bool canAccessNotifications(List<String> roles) {
    return roles.contains('PROFESSOR') || roles.contains('ADMIN');
  }

  // EQUIPOS
  static bool canAccessTeams(List<String> roles) {
    return roles.contains('PROFESSOR') || roles.contains('ADMIN');
  }

  static bool canCreateTeam(List<String> roles) {
    return roles.contains('ADMIN');
  }

  static bool canEditTeam(List<String> roles) {
    return roles.contains('PROFESSOR') || roles.contains('ADMIN');
  }

  static bool canDeleteTeam(List<String> roles) {
    return roles.contains('ADMIN');
  }

  // ENTRENAMIENTOS
  static bool canAccessTrainings(List<String> roles) {
    return roles.contains('PROFESSOR') || roles.contains('ADMIN');
  }

  // CONFIGURACIONES
  static bool canAccessSettings(List<String> roles) {
    return roles.isNotEmpty;
  }

  // HOME
  static bool canAccessHome(List<String> roles) {
    return roles.isNotEmpty;
  }

  // JUGADOR - Acceso a su propia información
  static bool canViewOwnPayments(List<String> roles) {
    return roles.contains('PLAYER') ||
        roles.contains('PROFESSOR') ||
        roles.contains('ADMIN');
  }

  static bool canViewOwnAttendance(List<String> roles) {
    return roles.contains('PLAYER') ||
        roles.contains('PROFESSOR') ||
        roles.contains('ADMIN');
  }

  /// Retorna true solo si el usuario es ÚNICAMENTE jugador
  /// Si tiene rol PROFESSOR o ADMIN además de PLAYER, retorna false
  static bool isPlayer(List<String> roles) {
    return roles.contains('PLAYER') &&
        !roles.contains('PROFESSOR') &&
        !roles.contains('ADMIN');
  }
}
