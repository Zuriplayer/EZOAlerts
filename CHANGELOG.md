# Changelog

## Unreleased

- Replaces the separate LAM test/move buttons with one persistent positioning toggle shared with EZOCore layout mode.
- Allows the shared EZOCore layout move-all mode to keep the alert preview movable while the player is in combat.
- Reorganizes LAM into output, treasure, group-awareness and role-alert sections with disabled dependent controls.
- Keeps role alert combat visibility configurable.
- Removes non-functional keyboard and gamepad prompts from persistent role-alert actions.

## 0.1.24 - Shared group screen alerts

- Publishes chest and heavy-sack events through EZOCore group presence when available.
- Shows received chest and heavy-sack events in the local EZOAlerts HUD window when on-screen alerts are enabled.

## 0.1.23 - Character names in alerts

- Uses character names first for generated alert messages, falling back to account names only when ESO does not provide a character name.

## 0.1.22 - Shared diagnostics control

- Registers the optional event-log mode with EZOCore so the family-wide action can disable it.
- Keeps the existing local logging setting and standalone behavior unchanged without EZOCore.
- Restricts alert-window dragging to the left mouse button.

## 0.1.21 - Shared layout integration

- Registers the alert preview with EZOCore `family.layout` for global or individual movement control.
- Keeps the existing local move checkbox and combat safety when EZOCore is unavailable.

## 0.1.20 - Settings panel polish

- Reformats the settings panel with EZO-style informational section headers and field-specific tooltips.
- Registers EZOAlerts controls inside the native `Settings > EZO` window when EZOCore is available.
- Keeps the standalone LibAddonMenu panel only as a compatibility fallback when EZOCore is unavailable.
- Adds the permanent EZO Discord feedback link to the settings header.

## 0.1.19 - Log noise fix

- Restricted the optional central log to combat-time entries and post-combat DebugLogViewer output.
- Removed the normal chat fallback for EZOAlerts log dumps.

## 0.1.18 - Public beta

- Prepared EZOAlerts for public beta publication.
- Added internal alert producers for chests, heavy sacks, shared guilds in group, leader zone changes and role checks.
- Added a shared HUD/HUD UI-only on-screen alert renderer with movable position preview.
- Added role mismatch alerts with acknowledge and session mute actions.
- Added English and Spanish localization with automatic language mode.
- Added optional central logging with grouped output after combat.
- Added controlled group-chat output for configured group events.
- Added release metadata, package tooling and public documentation.
