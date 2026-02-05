import '../entities/user.dart';
import '../repositories/user_repository_interface.dart';

class CreateUserUseCase {
  final UserRepositoryInterface repository;

  CreateUserUseCase(this.repository);

  Future<User> execute(User user) async {
    try {
      final result = await repository.createUser(user);
      return result;
    } catch (e) {
      print('Error en use case: $e');
      rethrow;
    }
  }
}
