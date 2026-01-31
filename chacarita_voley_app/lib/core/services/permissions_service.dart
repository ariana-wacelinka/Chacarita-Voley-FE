class PermissionsService {
  static bool canAccessUsers(List<String> roles) {
    return roles.contains('ADMIN');
  }

  static bool canAccessPayments(List<String> roles) {
    return roles.contains('PLAYER') ||
        roles.contains('PROFESSOR') ||
        roles.contains('ADMIN');
  }

  static bool canAccessNotifications(List<String> roles) {
    return roles.contains('PROFESSOR') || roles.contains('ADMIN');
  }

  static bool canAccessTeams(List<String> roles) {
    return roles.contains('ADMIN');
  }

  static bool canAccessTrainings(List<String> roles) {
    return roles.contains('PROFESSOR') || roles.contains('ADMIN');
  }

  static bool canAccessSettings(List<String> roles) {
    return roles.isNotEmpty;
  }

  static bool canAccessHome(List<String> roles) {
    return roles.isNotEmpty;
  }
}
