import 'pay.dart';

class PayPage {
  final List<Pay> content;
  final int totalElements;
  final int totalPages;
  final int pageNumber;
  final int pageSize;
  final bool hasNext;
  final bool hasPrevious;

  const PayPage({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.pageNumber,
    required this.pageSize,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory PayPage.fromJson(Map<String, dynamic> json) {
    return PayPage(
      content: (json['content'] as List<dynamic>)
          .map((p) => Pay.fromJson(p as Map<String, dynamic>))
          .toList(),
      totalElements: json['totalElements'] as int,
      totalPages: json['totalPages'] as int,
      pageNumber: json['pageNumber'] as int,
      pageSize: json['pageSize'] as int,
      hasNext: json['hasNext'] as bool,
      hasPrevious: json['hasPrevious'] as bool,
    );
  }
}
