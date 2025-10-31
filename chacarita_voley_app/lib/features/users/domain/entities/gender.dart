enum Gender { masculino, femenino, otro }

extension GenderExtension on Gender {
  String get displayName {
    switch (this) {
      case Gender.masculino:
        return 'Masculino';
      case Gender.femenino:
        return 'Femenino';
      case Gender.otro:
        return 'Otro';
    }
  }
}