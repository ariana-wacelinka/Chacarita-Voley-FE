import '../entities/assistance.dart';
import '../entities/assistance_stats.dart';
import '../entities/user.dart';

abstract class UserRepositoryInterface {
  Future<List<User>> getUsers({
    String? role,
    String? searchQuery,
    String? statusCurrentDue,
    int? page,
    int? size,
    bool forTeamSelection = false,
  });
  Future<int> getTotalUsers({
    String? role,
    String? searchQuery,
    String? statusCurrentDue,
  });
  Future<User?> getUserById(String id);
  Future<User> createUser(User user);
  Future<User> updateUser(User user);
  Future<void> deleteUser(String id);
  Future<AssistancePage> getAllAssistance({
    required String playerId,
    String? startTimeFrom,
    String? endTimeTo,
    required int page,
    required int size,
  });
  Future<AssistanceStats> getAssistanceStatsByPlayerId(String playerId);
}
