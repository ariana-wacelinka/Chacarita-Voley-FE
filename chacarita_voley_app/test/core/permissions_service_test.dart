import 'package:chacarita_voley_app/core/services/permissions_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PermissionsService', () {
    test('canSelectNotificationPlayers only for admin', () {
      expect(
        PermissionsService.canSelectNotificationPlayers(['ADMIN']),
        isTrue,
      );
      expect(
        PermissionsService.canSelectNotificationPlayers(['PROFESSOR']),
        isFalse,
      );
      expect(
        PermissionsService.canSelectNotificationPlayers(['PLAYER']),
        isFalse,
      );
    });

    test('canSelectNotificationFilters only for admin', () {
      expect(
        PermissionsService.canSelectNotificationFilters(['ADMIN']),
        isTrue,
      );
      expect(
        PermissionsService.canSelectNotificationFilters(['PROFESSOR']),
        isFalse,
      );
      expect(
        PermissionsService.canSelectNotificationFilters(['PLAYER']),
        isFalse,
      );
    });

    test('canShowUserQuickActions only for players being viewed', () {
      expect(
        PermissionsService.canShowUserQuickActions(
          isViewingPlayer: true,
          isOwnProfile: false,
          viewerRoles: ['ADMIN'],
        ),
        isTrue,
      );
      expect(
        PermissionsService.canShowUserQuickActions(
          isViewingPlayer: false,
          isOwnProfile: false,
          viewerRoles: ['ADMIN'],
        ),
        isFalse,
      );
    });

    test('canShowUserQuickActions hides for own profile player only', () {
      expect(
        PermissionsService.canShowUserQuickActions(
          isViewingPlayer: true,
          isOwnProfile: true,
          viewerRoles: ['PLAYER'],
        ),
        isFalse,
      );
      expect(
        PermissionsService.canShowUserQuickActions(
          isViewingPlayer: true,
          isOwnProfile: true,
          viewerRoles: ['ADMIN'],
        ),
        isTrue,
      );
    });
  });
}
