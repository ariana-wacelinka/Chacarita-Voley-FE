import '../models/pay_response_model.dart';

abstract class PayServiceInterface {
  Future<List<PayResponseModel>> getPays({
    Map<String, dynamic>? filter,
    int? page,
    int? size,
  });

  Future<PaginatedPayResponse> getPayPage({
    Map<String, dynamic>? filter,
    int? page,
    int? size,
  });

  Future<PayResponseModel?> getPayById(String id);

  Future<PayResponseModel> createPay(Map<String, dynamic> input);

  Future<PayResponseModel> updatePay(Map<String, dynamic> input);

  Future<void> deletePay(String id);
}
