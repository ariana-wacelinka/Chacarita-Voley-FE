import '../entities/pay_state.dart';

enum PostUploadAction { none, validate, reject }

PostUploadAction postUploadAction(PayState status) {
  switch (status) {
    case PayState.validated:
      return PostUploadAction.validate;
    case PayState.rejected:
      return PostUploadAction.reject;
    case PayState.pending:
      return PostUploadAction.none;
  }
}
