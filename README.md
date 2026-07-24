# EZOAlerts

**Public beta.** EZOAlerts is a standalone Elder Scrolls Online addon for modular on-screen alerts and controlled group-chat notifications in the EZO addon family.

¿Prefieres español? Lee el [README en español](README.es.md).

Support, bug reports and suggestions: https://discord.gg/ekw8zUAcRm


## Current Scope

EZOAlerts provides a small alert system with internal producers, a shared HUD alert window and controlled group-chat output. When EZOCore is active, its configuration is embedded in `Settings > EZO` and the alert preview participates in the shared interface layout mode; otherwise it registers a standalone LibAddonMenu panel with its own move control.

The addon currently focuses on group and role-awareness alerts. It does not replace combat UI, group frames, action bars or ESO systems.

## Version Metadata

- Addon version: `0.1.26`
- AddOnVersion: `10026`
- APIVersion: `101049 101050`
- Status: public beta

## Requirements

- The Elder Scrolls Online.
- LibAddonMenu-2.0.
- Optional: EZOCore for the central `Settings > EZO` configuration.
- Optional: LibGroupBroadcast through EZOCore for shared group screen alerts.
- Optional: LibChatMessage for cleaner local addon messages.
- Optional: LibDebugLogger and DebugLogViewer for the combat log output.

## Installation

1. Download or clone this repository.
2. Place the `EZOAlerts` folder in your ESO addons folder:
   - `Documents/Elder Scrolls Online/live/AddOns/EZOAlerts`
   - or `Documents/Elder Scrolls Online/pts/AddOns/EZOAlerts`
3. Make sure `LibAddonMenu-2.0` is installed and enabled.
4. Start ESO or run `/reloadui`.
5. Configure the addon from `Settings > EZO > EZOAlerts`. Without EZOCore, use the standalone `Settings > Addons > EZOAlerts` panel.

## Implemented Features

- Shared on-screen alert window:
  - HUD/HUD UI-only visibility.
  - Info, warning and error styles.
  - One-drag positioning action from the configuration panel, using the same visual sample as the test alert, plus the EZOCore shared layout mode when available.
  - Left-mouse-button dragging, including while in combat.
  - Scale, anchor and temporary-alert duration settings.

- Controlled group-chat channel:
  - Global group-chat toggle.
  - Group-only guard for generated group messages.
  - Uses ESO chat input for party chat text; depending on ESO behavior, the player may still need to confirm the prepared line manually.

- Chest alerts:
  - Detects chest opening through lockpick and loot events.
  - Reports the character name and detected lock quality.
  - Only generates messages while grouped.
  - Can appear as a temporary local HUD alert for compatible grouped players who have EZOCore, LibGroupBroadcast and EZOAlerts loaded.
  - Configurable enable toggle, group-chat toggle and cooldown.

- Heavy sack alerts:
  - Detects heavy sacks through loot target information.
  - Reports the character name when ESO provides it.
  - Only generates messages while grouped.
  - Can appear as a temporary local HUD alert for compatible grouped players who have EZOCore, LibGroupBroadcast and EZOAlerts loaded.
  - Configurable enable toggle, group-chat toggle and cooldown.

- Shared-guild alerts:
  - Scans group members against your five ESO guilds.
  - Shows a local-only message listing the guilds shared with each detected group member, using character names when ESO provides them.
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
  - Can hide an existing persistent alert when combat starts.
  - Can be muted in settings or silenced for the current session from the alert window.
  - Persistent alert actions use the alert-window buttons; no keybinds or input interception are registered.
  - Does not use set detection.

- Localization:
  - English and Spanish.
  - Can inherit the shared EZO-family language from EZOCore when available.
  - Automatic mode follows the ESO client language; unsupported languages fall back to English.

- Optional central log:
  - One global `Log` setting.
  - Producers record combat-time events into a single log bus.
  - Log output is grouped and dumped to LibDebugLogger/DebugLogViewer after combat when available.
  - It does not print log summaries to the normal chat window.
  - When EZOCore provides the family debug service, this log can be disabled by the shared EZO debug control.

## Main Configuration Options

Configuration sections use EZO-style informational headers with a purple help icon. General help is attached to the section heading; setting-specific help is attached to each field tooltip.

- General:
  - Language: use EZOCore global setting, automatic, English or Spanish.
  - Log: enable one shared post-combat DebugLogViewer log.

- Alerts:
  - Enable on-screen alerts.
  - Enable group-chat alerts.
  - Temporary alert duration in seconds.
  - Alert scale.
  - Screen position anchor.
  - One-drag alert-window positioning action using the test-alert visual.
  - Show test alert without moving the window; when launched from Settings, it appears after returning to the HUD.
  - Send test group message.

- Treasure alerts:
  - Chest alerts, group-chat output and cooldown.
  - Heavy sack alerts, group-chat output and cooldown.

- Group awareness:
  - Shared-guild group member detection.
  - Suppress shared-guild detection if the leader shares a guild with you.
  - Leader zone/instance alert, same-zone ignore and cooldown.

- Role alerts:
  - Role check mode, mute, grouped-only setting and cooldown.
  - Visibility of an existing persistent role alert during combat.

## Safety Boundaries

- No combat automation.
- No automatic travel.
- No automatic role changing.
- No set scanning.
- No global input interception.
- No custom keybindings.
- No replacement of ESO action bars, group frames or menus.
- No Discord publishing or external workflow execution from the addon.
- Shared group screen alerts require EZOCore, LibGroupBroadcast transport and EZOAlerts on the receiving client.
- Received chest and heavy-sack screen alerts respect the receiving client's matching producer toggle and global on-screen alert channel.

Group-chat alerts are intentionally constrained by addon settings, group state and ESO chat behavior. EZOAlerts does not attempt to bypass ESO input or chat restrictions.

## Recommended Beta Tests

- Load the addon with no Lua errors.
- Run `/reloadui`.
- Open `Settings > EZO > EZOAlerts` and confirm the controls remain inside the EZO window.
- If EZOCore debug controls are available, confirm the shared disable action can turn off EZOAlerts `Log`.
- With EZOCore disabled, confirm the standalone LibAddonMenu panel is available.
- Switch language between automatic, English and Spanish.
- Use the test screen alert, closing Settings after pressing the button so the HUD-only window can appear.
- Use the one-drag positioning action and confirm it shows the same visual sample as the test alert, stays visible while positioning and hides after releasing the drag.
- Use the test group message while grouped.
- In a group with compatible EZOCore transport, open a chest or heavy sack and confirm compatible clients show the temporary HUD alert when the matching producer and on-screen alerts are enabled.
- Confirm chest and heavy sack messages do not trigger outside a group.
- Confirm shared-guild alerts are local-only.
- Confirm leader-zone alerts do not travel automatically.
- Test role-check alerts with tank, healer and DD roles.
- Test acknowledge and session mute on the role alert window.
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
