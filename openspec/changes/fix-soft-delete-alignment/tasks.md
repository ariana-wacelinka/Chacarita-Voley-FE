# Tasks: Align frontend with backend soft deletes

## Phase 1: Foundation

- [ ] 1.1 Create `lib/core/entities/soft_deletable.dart` mixin with `bool isDeleted` and helper copy method.
- [ ] 1.2 Update `lib/features/**/domain/entities/*.dart` to implement `SoftDeletable`, parse `isDeleted` from JSON, and include it in `toJson` where needed.
- [ ] 1.3 Ensure shared DTOs (e.g., filters, inputs) include optional `isDeleted` fields with defaults.

## Phase 2: Data layer

- [ ] 2.1 Update GraphQL documents in `lib/**/graphql/*.dart` (or string queries) to request `isDeleted` selections and accept `isDeleted` filter arguments.
- [ ] 2.2 Extend repositories (`lib/features/**/data/repositories/*`) to pass `isDeleted` filters (default false) and map the returned flag.
- [ ] 2.3 Add `restore<Entity>` methods to repositories calling the matching GraphQL mutations.
- [ ] 2.4 Update provider/controllers to expose `showDeleted` state feeding repository calls.

## Phase 3: Presentation layer

- [ ] 3.1 Create shared `SoftDeleteFilter` widget to toggle `showDeleted` using Riverpod providers per feature page.
- [ ] 3.2 Create `RestoreButton` widget that calls repository restore callbacks with confirmation dialog/snackbar handling.
- [ ] 3.3 Update list/detail widgets (users, teams, trainings, sessions, payments, notifications, assistances) to display deleted badges, disable actions, and include restore controls.
- [ ] 3.4 Adjust delete flows to refresh data honoring current filter toggles.

## Phase 4: Testing & Verification

- [ ] 4.1 Add unit tests for entity mappers ensuring `isDeleted` persists through serialization/deserialization.
- [ ] 4.2 Add repository tests (or mocked client checks) verifying `isDeleted` filter variables and restore mutation calls.
- [ ] 4.3 Add widget tests for `SoftDeleteFilter` and `RestoreButton` plus at least one feature page showing toggle + badge behavior.
- [ ] 4.4 Manual verification checklists for key flows (users, teams, trainings, payments, notifications) following spec scenarios.
