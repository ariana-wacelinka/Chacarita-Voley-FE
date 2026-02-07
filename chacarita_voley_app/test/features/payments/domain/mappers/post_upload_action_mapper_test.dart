import 'package:chacarita_voley_app/features/payments/domain/entities/pay_state.dart';
import 'package:chacarita_voley_app/features/payments/domain/mappers/post_upload_action_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('postUploadAction maps status correctly', () {
    expect(postUploadAction(PayState.pending), PostUploadAction.none);
    expect(postUploadAction(PayState.validated), PostUploadAction.validate);
    expect(postUploadAction(PayState.rejected), PostUploadAction.reject);
  });
}
