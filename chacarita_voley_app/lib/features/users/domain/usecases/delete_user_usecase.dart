import '../repositories/user_repository_interface.dart';

class DeleteUserUseCase {
  final UserRepositoryInterface _userRepository;

  DeleteUserUseCase(this._userRepository);

  Future<void> execute(String userId) async {
    await _userRepository.deleteUser(userId);
  }
}
