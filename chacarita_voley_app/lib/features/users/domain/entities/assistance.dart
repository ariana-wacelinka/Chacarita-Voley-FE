class Assistance {
  final String id;
  final String date;
  final bool assistance;
  final String? startTime;
  final String? endTime;

  Assistance({
    required this.id,
    required this.date,
    required this.assistance,
    this.startTime,
    this.endTime,
  });

  factory Assistance.fromJson(Map<String, dynamic> json) {
    final sessionData = json['session'] as Map<String, dynamic>?;
    return Assistance(
      id: json['id'] as String,
      date: json['date'] as String,
      assistance: json['assistance'] as bool,
      startTime: sessionData?['startTime'] as String?,
      endTime: sessionData?['endTime'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'assistance': assistance,
      'session': {'startTime': startTime, 'endTime': endTime},
    };
  }
}

class AssistancePage {
  final List<Assistance> content;
  final bool hasNext;
  final bool hasPrevious;
  final int pageNumber;
  final int pageSize;
  final int totalElements;
  final int totalPages;

  AssistancePage({
    required this.content,
    required this.hasNext,
    required this.hasPrevious,
    required this.pageNumber,
    required this.pageSize,
    required this.totalElements,
    required this.totalPages,
  });

  factory AssistancePage.fromJson(Map<String, dynamic> json) {
    return AssistancePage(
      content: (json['content'] as List)
          .map((item) => Assistance.fromJson(item as Map<String, dynamic>))
          .toList(),
      hasNext: json['hasNext'] as bool? ?? false,
      hasPrevious: json['hasPrevious'] as bool? ?? false,
      pageNumber: json['pageNumber'] as int? ?? 0,
      pageSize: json['pageSize'] as int? ?? 10,
      totalElements: json['totalElements'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
    );
  }
}
