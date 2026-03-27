class PayResponseModel {
  final String id;
  final String? fileName;
  final String? fileUrl;
  final String date;
  final String? createdAt;
  final String? updateAt;
  final double amount;
  final String state; // Map to PayState in repo
  final bool isDeleted;

  PayResponseModel({
    required this.id,
    this.fileName,
    this.fileUrl,
    required this.date,
    this.createdAt,
    this.updateAt,
    required this.amount,
    required this.state,
    this.isDeleted = false,
  });

  factory PayResponseModel.fromJson(Map<String, dynamic> json) {
    return PayResponseModel(
      id: json['id'] as String,
      fileName: json['fileName'] as String?,
      fileUrl: json['fileUrl'] as String?,
      date: json['date'] as String,
      createdAt: json['createdAt'] as String?,
      updateAt: json['updateAt'] as String?,
      amount: (json['amount'] as num).toDouble(),
      state: json['state'] as String,
      isDeleted: json['isDeleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'date': date,
      if (createdAt != null) 'createdAt': createdAt,
      if (updateAt != null) 'updateAt': updateAt,
      'amount': amount,
      'state': state,
      'isDeleted': isDeleted,
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
  final bool isDeleted;

  PaginatedPayResponse({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.pageNumber,
    required this.pageSize,
    required this.hasNext,
    required this.hasPrevious,
    this.isDeleted = false,
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
      isDeleted: json['isDeleted'] ?? false,
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
      'isDeleted': isDeleted,
    };
  }
}
