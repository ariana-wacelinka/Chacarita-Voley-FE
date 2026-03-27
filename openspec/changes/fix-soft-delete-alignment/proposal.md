# Proposal: Align frontend with backend soft deletes

## Intent

Backend now performs logical deletes across every entity, exposing `isDeleted` in filters and adding `restore` mutations. The Flutter app still assumes hard deletes, so dependent screens lose data when parents are deleted. We must propagate `isDeleted` through entities, repositories, UI lists, and actions so deleted records remain visible and can be restored without breaking flows.

## Scope

### In Scope
- Extend all domain entities, DTOs, and repositories to read/write the `isDeleted` flag.
- Update GraphQL queries/mutations to request `isDeleted`, pass filter flags, and call new `restore<Entity>` mutations.
- Adjust list/detail UI for users, teams, trainings, sessions, notifications, pays, assistances, etc., to show deleted states and expose restore actions.
- Ensure delete flows refresh data and that dependent screens handle soft-deleted parents gracefully.

### Out of Scope
- Backend changes (already implemented).
- Large UX redesigns beyond indicators/actions for deleted entities.
- Historical audit logs or bulk restore tooling.

## Approach

Implement a cross-cutting refactor: introduce a shared `isDeleted` property pattern across entities, wire repositories to fetch/send the flag, and add UI affordances (badges, warnings, restore buttons). Each feature module will reuse common helpers for filter toggles and restoration controls to keep behavior consistent.

## Affected Areas

| Area | Impact | Description |
|------|--------|-------------|
| `lib/features/users/**` | Modified | Entities, repositories, and UI reflect `isDeleted`, add restore actions.
| `lib/features/teams/**` | Modified | Supports `isDeleted` filters and restoration.
| `lib/features/trainings/**` | Modified | Sessions/trainings display delete state and restore options.
| `lib/features/payments/**` | Modified | Payment lists honor `isDeleted`, allow restore.
| `lib/features/notifications/**` | Modified | Include flag handling and restore mutation.
| `lib/core/network/graphql_client_factory.dart` | Modified | Ensure new queries/mutations are wired.
| Shared widgets/utilities | Modified | Add status badges, filter toggles, confirm dialogs.

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Missing an entity/filter leaves inconsistent behavior | Medium | Use checklists per feature; comprehensive testing.
| Confusing UX with too many deleted items visible | Medium | Use clear badges and optional filters to hide deleted entries by default.
| Restore actions may violate permissions | Low | Reuse backend role checks, expose buttons only for allowed roles.

## Rollback Plan

Revert the branch to the previous commit (`git reset --hard` to HEAD^ on feature branch) and redeploy current frontend. Since backend already changed, temporary mitigation would hide restore controls but rely on default `isDeleted = false` filters until frontend is ready.

## Dependencies

- Backend branch with soft-delete changes (already merged). No other external dependencies.

## Success Criteria

- [ ] Every GraphQL entity and filter includes `isDeleted` where provided by backend.
- [ ] Delete flows no longer cause dependent screens to break; deleted records can still be viewed/restored.
- [ ] UI exposes restore actions per entity and visually marks deleted records.
- [ ] Manual verification across key screens (users, teams, trainings, payments, notifications) confirms parity with backend soft deletes.
