// Entidad Player para el contexto de pagos (viene del backend en getAllPays)
class PlayerPerson {
  final String id;
  final String name;
  final String surname;
  final String dni;

  PlayerPerson({
    required this.id,
    required this.name,
    required this.surname,
    required this.dni,
  });

  String get fullName => '$name $surname';

  factory PlayerPerson.fromJson(Map<String, dynamic> json) {
    return PlayerPerson(
      id: json['id'] as String,
      name: json['name'] as String,
      surname: json['surname'] as String,
      dni: json['dni'] as String,
    );
  }
}

class PlayerCurrentDue {
  final String id;
  final String period;
  final String state;

  PlayerCurrentDue({
    required this.id,
    required this.period,
    required this.state,
  });

  factory PlayerCurrentDue.fromJson(Map<String, dynamic> json) {
    return PlayerCurrentDue(
      id: json['id'] as String,
      period: json['period'] as String,
      state: json['state'] as String,
    );
  }
}

class Player {
  final String id;
  final PlayerCurrentDue? currentDue;
  final PlayerPerson person;

  Player({required this.id, required this.person, this.currentDue});

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as String,
      person: PlayerPerson.fromJson(json['person'] as Map<String, dynamic>),
      currentDue: json['currentDue'] != null
          ? PlayerCurrentDue.fromJson(
              json['currentDue'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}
