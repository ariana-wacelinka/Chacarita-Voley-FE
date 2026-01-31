class PaymentStats {
  final int totalApprovedPayments;
  final int totalPendingPayments;
  final int totalRejectedPayments;

  const PaymentStats({
    required this.totalApprovedPayments,
    required this.totalPendingPayments,
    required this.totalRejectedPayments,
  });

  factory PaymentStats.fromJson(Map<String, dynamic> json) {
    return PaymentStats(
      totalApprovedPayments: json['totalApprovedPayments'] as int,
      totalPendingPayments: json['totalPendingPayments'] as int,
      totalRejectedPayments: json['totalRejectedPayments'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalApprovedPayments': totalApprovedPayments,
      'totalPendingPayments': totalPendingPayments,
      'totalRejectedPayments': totalRejectedPayments,
    };
  }
}
