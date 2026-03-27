# Frontend Soft-Delete Specification

## Purpose

Ensure the Flutter frontend fully supports backend logical deletes by persisting the `isDeleted` state, exposing filters, and allowing authorized users to restore entities so dependent UI flows remain intact.

## Requirements

### Requirement: Entity models expose isDeleted

The frontend **MUST** add an `isDeleted` flag to every domain entity that maps to a backend model with soft delete semantics.

#### Scenario: Deserialize deleted user
- GIVEN the backend returns a user object with `"isDeleted": true`
- WHEN the app parses the response into a `User` entity
- THEN the resulting `User.isDeleted` **SHALL** be `true`

#### Scenario: Serialize entity for update keeps flag intact
- GIVEN a `Team` entity with `isDeleted = true`
- WHEN it is serialized for an update mutation
- THEN the payload **MUST** include `isDeleted: true` if the backend mutation accepts it (otherwise the flag is preserved client-side).

### Requirement: Queries and filters include isDeleted

All repository queries **MUST** request the `isDeleted` field and they **SHALL** send filter flags so users can include/exclude deleted records.

#### Scenario: Fetch trainings with deleted filter
- GIVEN an admin toggles “show deleted trainings” on
- WHEN the repository performs the `getAllTrainings` query
- THEN the GraphQL variables **MUST** include `{ filters: { isDeleted: true } }`
- AND the response **SHALL** include `isDeleted` for each training.

#### Scenario: Default filter hides deleted users
- GIVEN no filter toggle is enabled
- WHEN the users list loads
- THEN the repository **MUST** send `{ filters: { isDeleted: false } }` (or omit to default false)
- AND deleted users **SHALL NOT** appear.

### Requirement: UI indicates deleted state

Screens that list or display entities **MUST** visually mark deleted records and disable destructive actions until restored.

#### Scenario: Deleted team card state
- GIVEN a team returned with `isDeleted = true`
- WHEN the teams page renders the card
- THEN it **SHALL** show a badge or banner indicating “Eliminado”
- AND primary actions like “Edit” **SHOULD** be disabled or prompt to restore first.

#### Scenario: Restore action availability
- GIVEN the current user has role Admin
- WHEN they view a deleted training
- THEN a “Restaurar” action **MUST** be visible.

### Requirement: Restore mutations available per entity

Each entity that can be deleted **MUST** provide a UI flow to call the corresponding `restore<Entity>` mutation.

#### Scenario: Restore a player
- GIVEN a player is soft-deleted
- WHEN the user taps “Restaurar jugador”
- THEN the app **SHALL** execute the `restorePlayer(id)` mutation
- AND upon success **MUST** refresh the player list showing the restored state.

#### Scenario: Restore fails
- GIVEN the backend rejects a restore because of permissions
- WHEN the mutation returns an error
- THEN the UI **MUST** show the backend error message via the snackbar service.

### Requirement: Dependent screens handle deleted parents

Views that rely on parent entities (e.g., sessions needing trainings) **SHALL** continue working when a parent is deleted, provided `isDeleted` filters include them.

#### Scenario: Access training sessions for deleted training
- GIVEN a training is soft-deleted but sessions remain
- WHEN the sessions page loads with “include deleted trainings” toggle on
- THEN it **MUST** retrieve the parent training and its sessions without error
- AND the UI **SHALL** display both with deleted indicators.

#### Scenario: Attempt action with hidden parent
- GIVEN deleted trainings are hidden
- WHEN a user tries to open a session whose parent is deleted
- THEN the UI **MUST** present a message like “La sesión pertenece a un entrenamiento eliminado. Mostralo para restaurar.” and offer to enable the filter.

### Requirement: Delete flows refresh with filters

After performing a delete, the UI **MUST** refresh data respecting current filter toggles so the deleted item either stays visible (if showing deleted) or disappears (if hiding them).

#### Scenario: Delete while showing deleted
- GIVEN the “show deleted” toggle is on
- WHEN a team is deleted
- THEN it **SHALL** remain in the list marked as deleted after refresh.

#### Scenario: Delete while hiding deleted
- GIVEN deleted entities are hidden
- WHEN a notification is deleted
- THEN the refresh **MUST** remove it from the visible list.
