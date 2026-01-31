class PermissionsService {
  // USUARIOS
  static bool canAccessUsers(List<String> roles) {
    return roles.contains('ADMIN') || roles.contains('PROFESSOR');
  }

  static bool canCreateUser(List<String> roles) {
    return roles.contains('ADMIN');
  }

  static bool canEditUser(List<String> roles) {
    return roles.contains('ADMIN');
  }

  static bool canViewUser(List<String> roles) {
    return roles.contains('ADMIN') || roles.contains('PROFESSOR');
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
    return roles.contains('ADMIN');
  }

  static bool canValidatePayments(List<String> roles) {
    return roles.contains('ADMIN');
  }

  static bool canCreatePayment(List<String> roles) {
    return roles.contains('ADMIN');
  }

  static bool canEditPayment(List<String> roles) {
    return roles.contains('ADMIN');
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
}
