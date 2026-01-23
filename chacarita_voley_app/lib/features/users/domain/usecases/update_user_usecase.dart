import '../entities/user.dart';
import '../repositories/user_repository_interface.dart';

class UpdateUserUseCase {
  final UserRepositoryInterface repository;

  UpdateUserUseCase(this.repository);

  Future<User> execute(User user) async {
    return await repository.updateUser(user);
  }
}