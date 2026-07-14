# Changelog

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
