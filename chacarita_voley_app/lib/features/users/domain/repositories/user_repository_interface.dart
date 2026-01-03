import '../entities/user.dart';

abstract class UserRepositoryInterface {
  Future<List<User>> getUsers();
  Future<User?> getUserById(String id);
  Future<User> createUser(User user);
  Future<User> updateUser(User user);
  Future<void> deleteUser(String id);
}
