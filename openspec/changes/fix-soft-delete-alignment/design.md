# Design: Align frontend with backend soft deletes

## Technical Approach

Add an `isDeleted` property everywhere we hydrate backend entities, extend repository queries/mutations to request the flag, and wire UI controls (toggle + restore actions) to GraphQL. Use shared helpers to avoid code duplication: a `SoftDeleteFilter` toggle widget plus a generic `RestoreAction` button that takes mutation callbacks. Repositories default to `isDeleted: false` until toggled. Restore flows reuse existing Riverpod providers to refresh after mutation.

## Architecture Decisions

### Decision: Represent deleted state via shared mixin
**Choice**: Introduce `SoftDeletable` mixin (with `bool isDeleted`) implemented by every domain entity.
**Alternatives considered**: Copy-paste `bool? isDeleted` per entity.
**Rationale**: Reduces boilerplate and enables shared UI logic like `entity.isDeleted` badges.

### Decision: Toggle filter stored in Riverpod state
**Choice**: Add `softDeleteFilterProvider` per feature to persist “show deleted” toggle.
**Alternatives considered**: Local `StatefulWidget` toggles.
**Rationale**: Centralized state ensures GraphQL queries receive consistent filters across pagination, refresh, and navigation.

### Decision: Shared restore dialog service
**Choice**: Extend `SnackbarService`/dialogs with `confirmRestore` method used by all features.
**Alternatives considered**: Feature-specific dialogs.
**Rationale**: Uniform UX and easier to adjust copy/behavior.

## Data Flow

```
UI toggle ──> Riverpod provider ──> Repository filter builder ──> GraphQL query
    ↑                                                    │
    └──── restore button ← mutation result ← GraphQL client
```

1. Page loads → reads `showDeleted` from provider → repository includes `isDeleted` filter.  
2. GraphQL response now includes `isDeleted` per entity → mapper sets `SoftDeletable.isDeleted`.  
3. UI lists render badges; delete buttons call existing mutation; restore buttons call new `restore<Entity>` mutation via repository; success refreshes provider state/list.

## File Changes

| File | Action | Description |
|------|--------|-------------|
| `lib/core/entities/soft_deletable.dart` | Create | Defines mixin/interface with `bool isDeleted`. |
| `lib/features/**/domain/entities/*.dart` | Modify | Add mixin, parsing/serialization for `isDeleted`. |
| `lib/features/**/data/repositories/*_repository.dart` | Modify | Request `isDeleted`, send filter variables, add `restore<Entity>` methods calling new mutations. |
| `lib/features/**/presentation/widgets/*` | Modify | Display badges, disable actions, add restore buttons using shared components. |
| `lib/features/**/presentation/pages/*` | Modify | Add “show deleted” toggles wired to providers. |
| `lib/features/**/presentation/widgets/soft_delete_filter.dart` | Create | Shared toggle widget. |
| `lib/features/**/presentation/widgets/restore_button.dart` | Create | Standard restore button with loading/error states. |
| `lib/core/graphql/documents/*.graphql.dart` | Modify | Include `isDeleted` selections and new mutations. |

## Interfaces / Contracts

```dart
mixin SoftDeletable {
  bool get isDeleted;
  SoftDeletable copyWithIsDeleted(bool value);
}

final softDeleteFilterProvider = StateProvider.autoDispose<bool>((ref) => false);

typedef RestoreCallback = Future<void> Function(String id);
```

Repositories expose:

```dart
Future<void> restoreTeam(String id);
Future<void> restoreTraining(String id);
```

## Testing Strategy

| Layer | What to Test | Approach |
|-------|--------------|----------|
| Unit | Entity mappers set `isDeleted`; filter providers default false | Add Dart unit tests for mappers/providers. |
| Integration | Repository GraphQL queries include `isDeleted` selections | Use mocked GraphQL client to assert queries/variables. |
| UI/E2E | Toggle shows deleted items; restore button calls mutation | Run Flutter widget tests for list components; manual smoke test on devices for key flows. |

## Migration / Rollout

No data migration required. Rollout via new `feature/fix-soft-delete-alignment` branch; deploy when QA approves. Ensure backend already deployed with restore mutations.

## Open Questions

- [ ] Confirm whether any entities (e.g., dues, deliveries) remain hard delete; if so, exclude from mixin.
- [ ] Verify required roles per restore mutation to hide UI when unauthorized.
