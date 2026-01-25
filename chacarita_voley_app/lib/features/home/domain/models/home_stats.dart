class HomeStats {
  final int totalMembers;
  final int totalOverdueDues;
  final int totalTrainingToday;
  final int totalScheduledNotifications;

  HomeStats({
    required this.totalMembers,
    required this.totalOverdueDues,
    required this.totalTrainingToday,
    required this.totalScheduledNotifications,
  });

  factory HomeStats.fromJson(Map<String, dynamic> json) {
    return HomeStats(
      totalMembers: json['totalMembers'] as int? ?? 0,
      totalOverdueDues: json['totalOverdueDues'] as int? ?? 0,
      totalTrainingToday: json['totalTrainingToday'] as int? ?? 0,
      totalScheduledNotifications:
          json['totalScheduledNotifications'] as int? ?? 0,
    );
  }

  factory HomeStats.empty() {
    return HomeStats(
      totalMembers: 0,
      totalOverdueDues: 0,
      totalTrainingToday: 0,
      totalScheduledNotifications: 0,
    );
  }
}
