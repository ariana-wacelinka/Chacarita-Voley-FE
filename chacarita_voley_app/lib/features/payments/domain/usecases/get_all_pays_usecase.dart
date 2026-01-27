import 'dart:ffi';

import 'package:chacarita_voley_app/features/payments/domain/entities/pay_page.dart';

import '../entities/pay.dart';
import '../entities/pay_filter_input.dart';
import '../repositories/pay_repository_interface.dart';

class GetAllPaymentsUseCase {
  final PayRepositoryInterface repository;

  GetAllPaymentsUseCase(this.repository);

  Future<PayPage> execute(int page, int size, PayFilterInput filter) async {
    // return await repository.getPayments();
    return await repository.getAllPays(page: page, size: size, filters: filter);
  }
}
