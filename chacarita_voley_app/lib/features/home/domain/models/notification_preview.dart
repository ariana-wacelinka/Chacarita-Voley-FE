class NotificationPreview {
  final String id;
  final String title;

  NotificationPreview({required this.id, required this.title});

  factory NotificationPreview.fromJson(Map<String, dynamic> json) {
    return NotificationPreview(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
    );
  }
}
