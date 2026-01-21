// import '../entities/user.dart';

import 'package:chacarita_voley_app/features/payments/Temp/user.dart';

abstract class UserRepositoryInterface {
  List<User> getUsers();

  User? getUserById(String id);

  Future<User> createUser(User user);

  Future<User> updateUser(User user);

  Future<void> deleteUser(String id);
}
