-- Valores guardados y defaults de EZOAlerts.
EZOAlerts_SavedVars = EZOAlerts_SavedVars or {}
local MOD = EZOAlerts_SavedVars

local LANGUAGE_AUTO = "auto"

function MOD.GetDefaults()
    return {
        general = {
            language = LANGUAGE_AUTO,
            log = false,
        },
        alerts = {
            enabled = true,
            durationMs = 2500,
            scale = 1.0,
            anchor = "CENTER",
            offsetX = 0,
            offsetY = -180,
        },
        channels = {
            screen = true,
            groupChat = false,
        },
        producers = {
            chests = {
                enabled = true,
                groupChat = true,
                minIntervalMs = 15000,
            },
            heavySacks = {
                enabled = true,
                groupChat = true,
                minIntervalMs = 15000,
            },
            groupGuilds = {
                enabled = true,
                suppressWhenLeaderSharesGuild = true,
            },
            groupLeaderZone = {
                enabled = true,
                ignoreIfPlayerInSameZone = true,
                minIntervalMs = 10000,
            },
        },
    }
end

function MOD.Init()
    local world = GetWorldName()
    EZOAlerts.sv = ZO_SavedVars:NewAccountWide("EZOAlerts_Saved", 1, world, MOD.GetDefaults())
end
