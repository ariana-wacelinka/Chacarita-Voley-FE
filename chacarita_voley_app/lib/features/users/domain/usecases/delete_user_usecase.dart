import '../repositories/user_repository_interface.dart';

class DeleteUserUseCase {
  final UserRepositoryInterface _userRepository;

  DeleteUserUseCase(this._userRepository);

  Future<void> execute(String userId) async {
    try {
      await _userRepository.deleteUser(userId);
      print('Usuario eliminado exitosamente desde use case');
    } catch (e, stackTrace) {
      print('ERROR en delete user use case:');
      print('Exception: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
}
