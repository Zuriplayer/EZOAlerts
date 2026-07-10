# EZOAlerts

**Public beta.** EZOAlerts is a standalone Elder Scrolls Online addon for modular on-screen alerts and controlled group-chat notifications in the EZO addon family.

The addon is intentionally small and conservative. It can generate alerts on its own, while keeping a simple public API for future integration with other EZO addons.

## Requirements

- The Elder Scrolls Online.
- LibAddonMenu-2.0.
- Optional: LibChatMessage.

Current manifest API versions:

- `101049`
- `101050`

## Installation

1. Download or clone this repository.
2. Copy the `EZOAlerts` folder to your ESO addons folder:
   - `Documents/Elder Scrolls Online/live/AddOns/EZOAlerts`
   - or `Documents/Elder Scrolls Online/pts/AddOns/EZOAlerts`
3. Make sure `LibAddonMenu-2.0` is installed and enabled.
4. Start ESO or run `/reloadui`.
5. Configure the addon from `Settings > Addons > EZOAlerts`.

## Main Features

- On-screen alerts with a shared movable alert window.
- Controlled group-chat messages for configured group events.
- Chest and heavy-sack alerts while grouped.
- Local-only alerts when a group member shares one or more guilds with you.
- Optional leader-zone alert when the group leader changes zone or instance.
- Local role check based on selected role, equipped weapons and basic slotted-skill signals.
- English and Spanish localization, with automatic language mode.
- Central optional log with one grouped dump after combat.

## Safety Boundaries

- No combat automation.
- No automatic travel.
- No global input interception.
- No custom keybindings.
- No set scanning in the role check.
- Group-chat alerts only run when the relevant options are enabled and the player is grouped.
- ESO chat restrictions may require a prepared group-chat line to be confirmed manually.

## Beta Notes

This is a beta build. Please test with `/reloadui`, grouped and solo play, keyboard/mouse and gamepad mode, and both English and Spanish settings.

Useful checks during testing:

- The addon loads without Lua errors.
- The LibAddonMenu panel opens correctly.
- The test screen alert appears only in normal HUD/HUD UI scenes.
- The movable alert preview does not remain active after `/reloadui`.
- Chest and heavy-sack alerts do not trigger outside a group.
- Role-check alerts can be acknowledged or muted for the current session.

## Development

Quick validation commands:

```powershell
.\tools\bump-version.ps1 -Check
git diff --check
.\tools\build-addon-package.ps1 -Force
```

The package script writes release ZIP files to `dist/`, which is ignored by Git.

## License

MIT. See `LICENSE`.
