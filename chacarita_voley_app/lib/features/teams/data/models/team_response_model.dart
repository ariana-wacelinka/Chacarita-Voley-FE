class TrainingModel {
  final String id;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final String trainingType;
  final String location;

  TrainingModel({
    required this.id,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.trainingType,
    required this.location,
  });

  factory TrainingModel.fromJson(Map<String, dynamic> json) {
    return TrainingModel(
      id: json['id'] as String,
      dayOfWeek: json['dayOfWeek'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      trainingType: json['trainingType'] as String,
      location: json['location'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      'trainingType': trainingType,
      'location': location,
    };
  }
}

class UserModel {
  final String id;

  UserModel({required this.id});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(id: json['id'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}

class TeamResponseModel {
  final String id;
  final String name;
  final bool isCompetitive;
  final List<UserModel> players;
  final List<UserModel> professors;
  final List<TrainingModel> trainings;

  TeamResponseModel({
    required this.id,
    required this.name,
    required this.isCompetitive,
    required this.players,
    required this.professors,
    required this.trainings,
  });

  factory TeamResponseModel.fromJson(Map<String, dynamic> json) {
    return TeamResponseModel(
      id: json['id'] as String,
      name: json['name'] as String,
      isCompetitive: json['isCompetitive'] as bool,
      players:
          (json['players'] as List<dynamic>?)
              ?.map((p) => UserModel.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      professors:
          (json['professors'] as List<dynamic>?)
              ?.map((p) => UserModel.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      trainings:
          (json['trainings'] as List<dynamic>?)
              ?.map((t) => TrainingModel.fromJson(t as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isCompetitive': isCompetitive,
      'players': players.map((p) => p.toJson()).toList(),
      'professors': professors.map((p) => p.toJson()).toList(),
      'trainings': trainings.map((t) => t.toJson()).toList(),
    };
  }
}

class CreateTeamRequestModel {
  final String name;
  final bool isCompetitive;
  final List<String> playerIds;
  final List<String> professorIds;

  CreateTeamRequestModel({
    required this.name,
    required this.isCompetitive,
    required this.playerIds,
    required this.professorIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'isCompetitive': isCompetitive,
      'playerIds': playerIds.join(','),
      'professorIds': professorIds.join(','),
    };
  }
}

class UpdateTeamRequestModel {
  final String id;
  final String? name;
  final bool? isCompetitive;
  final List<String>? playerIds;
  final List<String>? professorIds;
  final List<String>? trainingIds;

  UpdateTeamRequestModel({
    required this.id,
    this.name,
    this.isCompetitive,
    this.playerIds,
    this.professorIds,
    this.trainingIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (name != null) 'name': name,
      if (isCompetitive != null) 'isCompetitive': isCompetitive,
      if (playerIds != null) 'playerIds': playerIds!.join(','),
      if (professorIds != null) 'professorIds': professorIds!.join(','),
      if (trainingIds != null) 'trainingIds': trainingIds!.join(','),
    };
  }
}
