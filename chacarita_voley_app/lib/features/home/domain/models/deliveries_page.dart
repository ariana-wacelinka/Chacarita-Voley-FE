import 'delivery_preview.dart';

class DeliveriesPage {
  final int totalPages;
  final int totalElements;
  final int pageSize;
  final int pageNumber;
  final bool hasPrevious;
  final bool hasNext;
  final List<DeliveryPreview> content;

  DeliveriesPage({
    required this.totalPages,
    required this.totalElements,
    required this.pageSize,
    required this.pageNumber,
    required this.hasPrevious,
    required this.hasNext,
    required this.content,
  });

  factory DeliveriesPage.fromJson(Map<String, dynamic> json) {
    final contentList = json['content'] as List<dynamic>? ?? [];

    return DeliveriesPage(
      totalPages: json['totalPages'] as int? ?? 0,
      totalElements: json['totalElements'] as int? ?? 0,
      pageSize: json['pageSize'] as int? ?? 0,
      pageNumber: json['pageNumber'] as int? ?? 0,
      hasPrevious: json['hasPrevious'] as bool? ?? false,
      hasNext: json['hasNext'] as bool? ?? false,
      content: contentList
          .map((item) => DeliveryPreview.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  factory DeliveriesPage.empty() {
    return DeliveriesPage(
      totalPages: 0,
      totalElements: 0,
      pageSize: 0,
      pageNumber: 0,
      hasPrevious: false,
      hasNext: false,
      content: [],
    );
  }
}
