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
  final int? jerseyNumber;
  final int? leagueId;

  UserModel({required this.id, this.jerseyNumber, this.leagueId});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      jerseyNumber: json['jerseyNumber'] as int?,
      leagueId: json['leagueId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (jerseyNumber != null) 'jerseyNumber': jerseyNumber,
      if (leagueId != null) 'leagueId': leagueId,
    };
  }
}

class TeamResponseModel {
  final String id;
  final String name;
  final String? abbreviation;
  final bool isCompetitive;
  final List<UserModel>? players;
  final List<UserModel>? professors;
  final List<TrainingModel>? trainings;

  TeamResponseModel({
    required this.id,
    required this.name,
    this.abbreviation,
    required this.isCompetitive,
    this.players,
    this.professors,
    this.trainings,
  });

  factory TeamResponseModel.fromJson(Map<String, dynamic> json) {
    return TeamResponseModel(
      id: json['id'] as String,
      name: json['name'] as String,
      abbreviation: json['abbreviation'] as String?,
      isCompetitive: json['isCompetitive'] as bool,
      players: (json['players'] as List<dynamic>?)
          ?.map((p) => UserModel.fromJson(p as Map<String, dynamic>))
          .toList(),
      professors: (json['professors'] as List<dynamic>?)
          ?.map((p) => UserModel.fromJson(p as Map<String, dynamic>))
          .toList(),
      trainings: (json['trainings'] as List<dynamic>?)
          ?.map((t) => TrainingModel.fromJson(t as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (abbreviation != null) 'abbreviation': abbreviation,
      'isCompetitive': isCompetitive,
      if (players != null) 'players': players!.map((p) => p.toJson()).toList(),
      if (professors != null)
        'professors': professors!.map((p) => p.toJson()).toList(),
      if (trainings != null)
        'trainings': trainings!.map((t) => t.toJson()).toList(),
    };
  }
}

class CreateTeamRequestModel {
  final String name;
  final String? abbreviation;
  final bool isCompetitive;
  final List<String> playerIds;
  final List<String> professorIds;

  CreateTeamRequestModel({
    required this.name,
    this.abbreviation,
    required this.isCompetitive,
    required this.playerIds,
    required this.professorIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (abbreviation != null) 'abbreviation': abbreviation,
      'isCompetitive': isCompetitive,
      // No enviar playerIds/professorIds si están vacíos
      if (playerIds.isNotEmpty) 'playerIds': playerIds.join(','),
      if (professorIds.isNotEmpty) 'professorIds': professorIds.join(','),
    };
  }
}

class UpdateTeamRequestModel {
  final String id;
  final String? name;
  final String? abbreviation;
  final bool? isCompetitive;
  final List<String>? trainingIds;

  UpdateTeamRequestModel({
    required this.id,
    this.name,
    this.abbreviation,
    this.isCompetitive,
    this.trainingIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (name != null) 'name': name,
      if (abbreviation != null) 'abbreviation': abbreviation,
      if (isCompetitive != null) 'isCompetitive': isCompetitive,
      if (trainingIds != null) 'trainingIds': trainingIds!.join(','),
    };
  }
}

class TeamFilters {
  final String? name;
  final bool? isCompetitive;

  TeamFilters({this.name, this.isCompetitive});

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (isCompetitive != null) 'isCompetitive': isCompetitive,
    };
  }
}

class PaginatedTeamResponse {
  final List<TeamResponseModel> content;
  final bool hasNext;
  final bool hasPrevious;
  final int pageNumber;
  final int totalElements;
  final int pageSize;
  final int totalPages;

  PaginatedTeamResponse({
    required this.content,
    required this.hasNext,
    required this.hasPrevious,
    required this.pageNumber,
    required this.totalElements,
    required this.pageSize,
    required this.totalPages,
  });

  factory PaginatedTeamResponse.fromJson(Map<String, dynamic> json) {
    return PaginatedTeamResponse(
      content: (json['content'] as List<dynamic>)
          .map((t) => TeamResponseModel.fromJson(t as Map<String, dynamic>))
          .toList(),
      hasNext: json['hasNext'] as bool,
      hasPrevious: json['hasPrevious'] as bool,
      pageNumber: json['pageNumber'] as int,
      totalElements: json['totalElements'] as int,
      pageSize: json['pageSize'] as int,
      totalPages: json['totalPages'] as int,
    );
  }
}
