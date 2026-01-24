class PayResponseModel {
  final String id;
  final String? fileName;
  final String? fileUrl;
  final String date;
  final String time;
  final double amount;
  final String state; // Map to PayState in repo

  PayResponseModel({
    required this.id,
    this.fileName,
    this.fileUrl,
    required this.date,
    required this.time,
    required this.amount,
    required this.state,
  });

  factory PayResponseModel.fromJson(Map<String, dynamic> json) {
    return PayResponseModel(
      id: json['id'] as String,
      fileName: json['fileName'] as String?,
      fileUrl: json['fileUrl'] as String?,
      date: json['date'] as String,
      time: json['time'] as String,
      amount: (json['amount'] as num).toDouble(),
      state: json['state'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'date': date,
      'time': time,
      'amount': amount,
      'state': state,
    };
  }
}

class PaginatedPayResponse {
  final List<PayResponseModel> content;
  final int totalElements;
  final int totalPages;
  final int pageNumber;
  final int pageSize;
  final bool hasNext;
  final bool hasPrevious;

  PaginatedPayResponse({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.pageNumber,
    required this.pageSize,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory PaginatedPayResponse.fromJson(Map<String, dynamic> json) {
    return PaginatedPayResponse(
      content: (json['content'] as List<dynamic>)
          .map((p) => PayResponseModel.fromJson(p as Map<String, dynamic>))
          .toList(),
      totalElements: json['totalElements'] as int,
      totalPages: json['totalPages'] as int,
      pageNumber: json['pageNumber'] as int,
      pageSize: json['pageSize'] as int,
      hasNext: json['hasNext'] as bool,
      hasPrevious: json['hasPrevious'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content.map((model) => model.toJson()).toList(),
      'totalElements': totalElements,
      'totalPages': totalPages,
      'pageNumber': pageNumber,
      'pageSize': pageSize,
      'hasNext': hasNext,
      'hasPrevious': hasPrevious,
    };
  }
}
