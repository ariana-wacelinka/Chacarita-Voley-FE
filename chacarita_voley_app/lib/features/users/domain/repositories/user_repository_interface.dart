import '../entities/assistance.dart';
import '../entities/assistance_stats.dart';
import '../entities/user.dart';

abstract class UserRepositoryInterface {
  Future<List<User>> getUsers({
    String? role,
    String? searchQuery,
    String? statusCurrentDue,
    bool? playerIsCompetitive,
    bool includeDeleted,
    int? page,
    int? size,
    bool forTeamSelection = false,
  });
  Future<int> getTotalUsers({
    String? role,
    String? searchQuery,
    String? statusCurrentDue,
    bool includeDeleted,
  });
  Future<User?> getUserById(String id);
  Future<User> createUser(User user);
  Future<User> updateUser(User user);
  Future<void> deleteUser(String id);
  Future<void> restoreUser(String id);
  Future<AssistancePage> getAllAssistance({
    required String playerId,
    String? startTimeFrom,
    String? endTimeTo,
    required int page,
    required int size,
  });
  Future<AssistanceStats> getAssistanceStatsByPlayerId(String playerId);
  Future<List<User>> getUsersForNotifications({bool includeDeleted = false});
  Future<List<User>> getUsersForPayments({
    String? searchQuery,
    bool includeDeleted = false,
  });
}
