import '../../../../core/entities/soft_deletable.dart';

class PaymentStats with SoftDeletable {
  final int totalApprovedPayments;
  final int totalPendingPayments;
  final int totalRejectedPayments;
  @override
  final bool isDeleted;

  const PaymentStats({
    required this.totalApprovedPayments,
    required this.totalPendingPayments,
    required this.totalRejectedPayments,
    this.isDeleted = false,
  });

  factory PaymentStats.fromJson(Map<String, dynamic> json) {
    return PaymentStats(
      totalApprovedPayments: json['totalApprovedPayments'] as int,
      totalPendingPayments: json['totalPendingPayments'] as int,
      totalRejectedPayments: json['totalRejectedPayments'] as int,
      isDeleted: json['isDeleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalApprovedPayments': totalApprovedPayments,
      'totalPendingPayments': totalPendingPayments,
      'totalRejectedPayments': totalRejectedPayments,
      'isDeleted': isDeleted,
    };
  }

  @override
  PaymentStats copyWithIsDeleted(bool value) => PaymentStats(
    totalApprovedPayments: totalApprovedPayments,
    totalPendingPayments: totalPendingPayments,
    totalRejectedPayments: totalRejectedPayments,
    isDeleted: value,
  );
}
