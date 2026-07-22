-- Valores guardados y defaults de EZOAlerts.
EZOAlerts_SavedVars = EZOAlerts_SavedVars or {}
local MOD = EZOAlerts_SavedVars
local SAVED_VARIABLES_NAME = "EZOAlerts_Saved"
local SAVED_VARIABLES_VERSION = 1
local MIGRATION_MARKER = "__ezoPreferenceScopeMigrated"

local function DeepCopy(src)
    if type(src) ~= "table" then
        return src
    end

    local out = {}
    for key, value in pairs(src) do
        out[key] = DeepCopy(value)
    end
    return out
end

local function ApplyDefaults(target, defaults)
    if type(target) ~= "table" or type(defaults) ~= "table" then
        return
    end

    for key, value in pairs(defaults) do
        if target[key] == nil then
            target[key] = DeepCopy(value)
        elseif type(target[key]) == "table" and type(value) == "table" then
            ApplyDefaults(target[key], value)
        end
    end
end

local function CopySavedValues(target, source)
    if type(target) ~= "table" or type(source) ~= "table" then
        return
    end

    for key, value in pairs(source) do
        if key ~= MIGRATION_MARKER then
            target[key] = DeepCopy(value)
        end
    end
end

local function GetPreferenceScope()
    if EZOCore and type(EZOCore.GetPreferenceScope) == "function" then
        local ok, scope = pcall(function()
            return EZOCore:GetPreferenceScope("ezoalerts", "settings")
        end)
        if ok and scope == "character" then
            return "character"
        end
    end
    return "account"
end

function MOD.GetDefaults()
    return {
        general = {
            language = EZOAlerts.GetDefaultLanguage and EZOAlerts.GetDefaultLanguage() or "auto",
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
            roleCheck = {
                mode = "alarms",
                muted = false,
                onlyGrouped = true,
                minIntervalMs = 60000,
            },
        },
    }
end

function MOD.Init()
    local world = GetWorldName()
    local defaults = MOD.GetDefaults()
    local scope = GetPreferenceScope()
    EZOAlerts.preferenceScope = scope

    if scope == "character" then
        EZOAlerts.sv = ZO_SavedVars:NewCharacterIdSettings(
            SAVED_VARIABLES_NAME,
            SAVED_VARIABLES_VERSION,
            world,
            defaults)
        if type(EZOAlerts.sv) == "table" and EZOAlerts.sv[MIGRATION_MARKER] ~= true then
            local accountSv = ZO_SavedVars:NewAccountWide(
                SAVED_VARIABLES_NAME,
                SAVED_VARIABLES_VERSION,
                world,
                nil)
            CopySavedValues(EZOAlerts.sv, accountSv)
            EZOAlerts.sv[MIGRATION_MARKER] = true
        end
    else
        EZOAlerts.sv = ZO_SavedVars:NewAccountWide(SAVED_VARIABLES_NAME, SAVED_VARIABLES_VERSION, world, defaults)
    end

    ApplyDefaults(EZOAlerts.sv, defaults)
end
