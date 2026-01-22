enum TeamType {
  competitivo,
  recreativo;

  String get displayName {
    switch (this) {
      case TeamType.competitivo:
        return 'Competitivo';
      case TeamType.recreativo:
        return 'Recreativo';
    }
  }
}
