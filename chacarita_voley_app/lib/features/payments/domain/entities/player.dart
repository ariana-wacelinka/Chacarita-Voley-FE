import '../../../../core/entities/soft_deletable.dart';

// Entidad Player para el contexto de pagos (viene del backend en getAllPays)
class PlayerPerson with SoftDeletable {
  final String id;
  final String name;
  final String surname;
  final String dni;
  @override
  final bool isDeleted;

  PlayerPerson({
    required this.id,
    required this.name,
    required this.surname,
    required this.dni,
    this.isDeleted = false,
  });

  String get fullName => '$name $surname';

  factory PlayerPerson.fromJson(Map<String, dynamic> json) {
    return PlayerPerson(
      id: json['id'] as String,
      name: json['name'] as String,
      surname: json['surname'] as String,
      dni: json['dni'] as String,
      isDeleted: json['isDeleted'] ?? false,
    );
  }

  @override
  PlayerPerson copyWithIsDeleted(bool value) => PlayerPerson(
    id: id,
    name: name,
    surname: surname,
    dni: dni,
    isDeleted: value,
  );
}

class PlayerCurrentDue with SoftDeletable {
  final String id;
  final String period;
  final String state;
  @override
  final bool isDeleted;

  PlayerCurrentDue({
    required this.id,
    required this.period,
    required this.state,
    this.isDeleted = false,
  });

  factory PlayerCurrentDue.fromJson(Map<String, dynamic> json) {
    return PlayerCurrentDue(
      id: json['id'] as String,
      period: json['period'] as String,
      state: json['state'] as String,
      isDeleted: json['isDeleted'] ?? false,
    );
  }

  @override
  PlayerCurrentDue copyWithIsDeleted(bool value) =>
      PlayerCurrentDue(id: id, period: period, state: state, isDeleted: value);
}

class Player with SoftDeletable {
  final String id;
  final PlayerCurrentDue? currentDue;
  final PlayerPerson person;
  @override
  final bool isDeleted;

  Player({
    required this.id,
    required this.person,
    this.currentDue,
    this.isDeleted = false,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as String,
      person: PlayerPerson.fromJson(json['person'] as Map<String, dynamic>),
      currentDue: json['currentDue'] != null
          ? PlayerCurrentDue.fromJson(
              json['currentDue'] as Map<String, dynamic>,
            )
          : null,
      isDeleted: json['isDeleted'] ?? false,
    );
  }

  @override
  Player copyWithIsDeleted(bool value) =>
      Player(id: id, person: person, currentDue: currentDue, isDeleted: value);
}
