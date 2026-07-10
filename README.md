# EZOAlerts

**Public beta.** EZOAlerts is a standalone Elder Scrolls Online addon for modular on-screen alerts and controlled group-chat notifications in the EZO addon family.

Prefer Spanish? Read the [Spanish README](README.es.md).

Support, bug reports and suggestions: https://discord.gg/ekw8zUAcRm

## Current Scope

EZOAlerts provides a small alert system with internal producers, a shared HUD alert window, controlled group-chat output and a LibAddonMenu configuration panel. It is standalone for now, with a compact API and structure that can be integrated into EZOTools later if that becomes useful.

The addon currently focuses on group and role-awareness alerts. It does not replace combat UI, group frames, action bars or ESO systems.

## Version Metadata

- Addon version: `0.1.18`
- AddOnVersion: `10018`
- APIVersion: `101049 101050`
- Status: public beta

## Requirements

- The Elder Scrolls Online.
- LibAddonMenu-2.0.
- Optional: LibChatMessage, used only for cleaner local addon messages when available.

## Installation

1. Download or clone this repository.
2. Place the `EZOAlerts` folder in your ESO addons folder:
   - `Documents/Elder Scrolls Online/live/AddOns/EZOAlerts`
   - or `Documents/Elder Scrolls Online/pts/AddOns/EZOAlerts`
3. Make sure `LibAddonMenu-2.0` is installed and enabled.
4. Start ESO or run `/reloadui`.
5. Configure the addon from `Settings > Addons > EZOAlerts`.

## Implemented Features

- Shared on-screen alert window:
  - HUD/HUD UI-only visibility.
  - Info, warning and error styles.
  - Movable preview from LibAddonMenu.
  - Scale, anchor and temporary-alert duration settings.
  - Keyboard/gamepad prompt text for alert actions when ESO exposes the input mode.

- Controlled group-chat channel:
  - Global group-chat toggle.
  - Group-only guard for generated group messages.
  - Uses ESO chat input for party chat text; depending on ESO behavior, the player may still need to confirm the prepared line manually.

- Chest alerts:
  - Detects chest opening through lockpick and loot events.
  - Reports the player and detected lock quality.
  - Only generates messages while grouped.
  - Configurable enable toggle, group-chat toggle and cooldown.

- Heavy sack alerts:
  - Detects heavy sacks through loot target information.
  - Only generates messages while grouped.
  - Configurable enable toggle, group-chat toggle and cooldown.

- Shared-guild alerts:
  - Scans group members against your five ESO guilds.
  - Shows a local-only message listing the guilds shared with each detected group member.
  - Can suppress detection when the group leader shares a guild with you, to reduce noise during guild events.

- Group leader zone alert:
  - Shows a local message when the group leader changes zone or instance after the group is already formed.
  - Can ignore alerts when you are already in the same zone.
  - Includes a cooldown setting.

- Role check alerts:
  - Compares the selected group role with equipped weapons and basic slotted-skill signals.
  - Tank alarms check for sword and shield or frost staff; warnings check for a slotted taunt.
  - Healer alarms check for restoration staff; warnings check for known healing skills.
  - DD alarms/warnings check for clearly support-looking weapons or taunt signals.
  - Can show alarms only, alarms plus warnings, or be disabled.
  - Can be limited to grouped play.
  - Can be muted in settings or silenced for the current session from the alert window.
  - Does not use set detection.

- Localization:
  - English and Spanish.
  - Automatic mode follows the ESO client language; unsupported languages fall back to English.

- Optional central log:
  - One global `Log` setting.
  - Producers record events into a single log bus.
  - Log output is grouped and dumped after combat when needed.

## Main LibAddonMenu Options

- General:
  - Language: automatic, English or Spanish.
  - Log: enable one shared post-combat log.

- Alerts:
  - Enable on-screen alerts.
  - Enable group-chat alerts.
  - Temporary alert duration in seconds.
  - Alert scale.
  - Screen position anchor.
  - Move alert window.
  - Show test alert.
  - Send test group message.

- Generated alerts:
  - Chest alerts, group-chat output and cooldown.
  - Heavy sack alerts, group-chat output and cooldown.
  - Shared-guild group member detection.
  - Suppress shared-guild detection if the leader shares a guild with you.
  - Leader zone/instance alert, same-zone ignore and cooldown.
  - Role check mode, mute, grouped-only setting and cooldown.

## Safety Boundaries

- No combat automation.
- No automatic travel.
- No automatic role changing.
- No set scanning.
- No global input interception.
- No custom keybindings.
- No replacement of ESO action bars, group frames or menus.
- No Discord publishing or external workflow execution from the addon.

Group-chat alerts are intentionally constrained by addon settings, group state and ESO chat behavior. EZOAlerts does not attempt to bypass ESO input or chat restrictions.

## Recommended Beta Tests

- Load the addon with no Lua errors.
- Run `/reloadui`.
- Open the LibAddonMenu panel.
- Switch language between automatic, English and Spanish.
- Use the test screen alert.
- Use the test group message while grouped.
- Confirm chest and heavy sack messages do not trigger outside a group.
- Confirm shared-guild alerts are local-only.
- Confirm leader-zone alerts do not travel automatically.
- Test role-check alerts with tank, healer and DD roles.
- Test acknowledge and session mute on the role alert window.
- Test keyboard/mouse and gamepad mode prompt text.
- Confirm the alert window appears only in normal HUD/HUD UI scenes.
- Confirm move preview does not remain active after `/reloadui`.

## Development Checks

Useful local checks:

```powershell
.\tools\bump-version.ps1 -Check
git diff --check
```

The packaging script exists for release packaging, but release ZIPs are written to `dist/`, which is ignored by Git:

```powershell
.\tools\build-addon-package.ps1 -Force
```

## License

MIT. See [LICENSE](LICENSE).
