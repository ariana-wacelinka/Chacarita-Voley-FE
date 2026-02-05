import '../entities/user.dart';
import '../repositories/user_repository_interface.dart';

class CreateUserUseCase {
  final UserRepositoryInterface repository;

  CreateUserUseCase(this.repository);

  Future<User> execute(User user) async {
    print('========== CREATE USER USE CASE ==========');
    print('Ejecutando caso de uso CreateUser');
    print('Usuario: ${user.nombreCompleto} (${user.email})');
    try {
      final result = await repository.createUser(user);
      print('Use case completado exitosamente');
      print('========================================');
      return result;
    } catch (e) {
      print('Error en use case: $e');
      print('========================================');
      rethrow;
    }
  }
}
