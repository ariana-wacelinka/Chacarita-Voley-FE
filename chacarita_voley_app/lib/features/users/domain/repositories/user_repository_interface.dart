import '../entities/user.dart';

abstract class UserRepositoryInterface {
  Future<List<User>> getUsers({
    String? role,
    String? searchQuery,
    int? page,
    int? size,
    bool forTeamSelection = false,
  });
  Future<int> getTotalUsers({String? role, String? searchQuery});
  Future<User?> getUserById(String id);
  Future<User> createUser(User user);
  Future<User> updateUser(User user);
  Future<void> deleteUser(String id);
}
