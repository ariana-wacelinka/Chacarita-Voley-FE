import '../../../../core/entities/soft_deletable.dart';

class Assistance with SoftDeletable {
  final String id;
  final String date;
  final bool assistance;
  final String? startTime;
  final String? endTime;
  @override
  final bool isDeleted;

  Assistance({
    required this.id,
    required this.date,
    required this.assistance,
    this.startTime,
    this.endTime,
    this.isDeleted = false,
  });

  factory Assistance.fromJson(Map<String, dynamic> json) {
    final sessionData = json['session'] as Map<String, dynamic>?;
    return Assistance(
      id: json['id'] as String,
      date: json['date'] as String,
      assistance: json['assistance'] as bool,
      startTime: sessionData?['startTime'] as String?,
      endTime: sessionData?['endTime'] as String?,
      isDeleted: json['isDeleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'assistance': assistance,
      'session': {'startTime': startTime, 'endTime': endTime},
      'isDeleted': isDeleted,
    };
  }

  Assistance copyWith({
    String? id,
    String? date,
    bool? assistance,
    String? startTime,
    String? endTime,
    bool? isDeleted,
  }) {
    return Assistance(
      id: id ?? this.id,
      date: date ?? this.date,
      assistance: assistance ?? this.assistance,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  Assistance copyWithIsDeleted(bool value) => copyWith(isDeleted: value);
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
