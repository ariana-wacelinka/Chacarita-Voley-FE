class AssistanceStats {
  final int assisted;
  final int notAssisted;
  final double assistedPercentage;

  AssistanceStats({
    required this.assisted,
    required this.notAssisted,
    required this.assistedPercentage,
  });

  factory AssistanceStats.fromJson(Map<String, dynamic> json) {
    return AssistanceStats(
      assisted: json['assisted'] as int,
      notAssisted: json['notAssisted'] as int,
      assistedPercentage: (json['assistedPercentage'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assisted': assisted,
      'notAssisted': notAssisted,
      'assistedPercentage': assistedPercentage,
    };
  }
}
