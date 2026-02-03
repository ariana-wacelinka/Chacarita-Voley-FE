class DeliveryPreview {
  final String id;
  final String title;
  final String message;

  DeliveryPreview({
    required this.id,
    required this.title,
    required this.message,
  });

  factory DeliveryPreview.fromJson(Map<String, dynamic> json) {
    final notification = json['notification'] as Map<String, dynamic>?;

    return DeliveryPreview(
      id: json['id'] as String,
      title: notification?['title'] as String? ?? '',
      message: notification?['message'] as String? ?? '',
    );
  }
}
