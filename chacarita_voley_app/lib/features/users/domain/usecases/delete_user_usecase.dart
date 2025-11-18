import '../../data/repositories/user_repository.dart';

class DeleteUserUseCase {
  final UserRepository _userRepository;

  DeleteUserUseCase(this._userRepository);

  Future<void> execute(String userId) async {
    await _userRepository.deleteUser(userId);
  }
}
