-- Log central para eventos internos de EZOAlerts.
EZOAlerts_Log = EZOAlerts_Log or {}
local MOD = EZOAlerts_Log

local EVENT_NAMESPACE = "EZOAlerts_Log"
local MAX_ENTRIES = 80
local LOGGER_TAG = "EZOAlerts"

local function IsEnabled()
    local general = EZOAlerts and EZOAlerts.sv and EZOAlerts.sv.general
    return general and general.log == true
end

local function GetText(stringId, fallback)
    local text = fallback
    if stringId ~= nil and type(GetString) == "function" then
        text = GetString(stringId)
    end
    return tostring(text or fallback or "")
end

local function ReplaceParams(text, values)
    for index, value in ipairs(values) do
        text = text:gsub("<<" .. tostring(index) .. ">>", tostring(value or ""))
    end
    return text
end

local function FormatText(stringId, fallback, values)
    local text = GetText(stringId, fallback)
    if type(zo_strformat) == "function" then
        return zo_strformat(text, unpack(values))
    end
    return ReplaceParams(text, values)
end

local function GetLogger()
    if MOD.logger ~= nil then
        return MOD.logger
    end

    local lib = _G.LibDebugLogger
    if type(lib) ~= "function" and type(lib) ~= "table" then
        return nil
    end

    local ok, logger = false, nil
    if type(lib) == "function" then
        ok, logger = pcall(lib, LOGGER_TAG)
    end
    if (not ok or logger == nil) and type(lib) == "table" and type(lib.Create) == "function" then
        ok, logger = pcall(function()
            return lib:Create(LOGGER_TAG)
        end)
    end

    if ok and logger then
        MOD.logger = logger
        return logger
    end

    return nil
end

local function WriteLogViewer(message)
    local logger = GetLogger()
    if not logger then
        return false
    end

    local wrote = false
    local ok = pcall(function()
        if type(logger.Info) == "function" then
            logger:Info(tostring(message or ""))
            wrote = true
        elseif type(logger.Debug) == "function" then
            logger:Debug(tostring(message or ""))
            wrote = true
        end
    end)

    return ok == true and wrote == true
end

function MOD.Record(category, message)
    if not IsEnabled() then
        return false
    end

    if MOD.inCombat ~= true then
        return false
    end

    message = tostring(message or "")
    if message == "" then
        return false
    end

    MOD.entries = MOD.entries or {}
    table.insert(MOD.entries, {
        category = tostring(category or ""),
        message = message,
    })

    while #MOD.entries > MAX_ENTRIES do
        table.remove(MOD.entries, 1)
    end

    return true
end

function MOD.Flush()
    if not IsEnabled() then
        MOD.entries = {}
        return
    end

    if not MOD.entries or #MOD.entries == 0 then
        return
    end

    local lines = {
        GetText(_G.EZOA_LOG_HEADER, "EZOAlerts log"),
    }
    for _, entry in ipairs(MOD.entries) do
        lines[#lines + 1] = FormatText(_G.EZOA_LOG_LINE, "<<1>>: <<2>>", {
            entry.category,
            entry.message,
        })
    end

    WriteLogViewer(table.concat(lines, "\n"))

    MOD.entries = {}
end

function MOD.Init()
    MOD.entries = MOD.entries or {}
    MOD.inCombat = false

    if EVENT_PLAYER_COMBAT_STATE ~= nil then
        EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_COMBAT_STATE, function(_, inCombat)
            local wasInCombat = MOD.inCombat == true
            MOD.inCombat = inCombat == true

            if not MOD.inCombat and wasInCombat then
                MOD.Flush()
            end
        end)
    end
end
