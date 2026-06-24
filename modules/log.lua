-- Log central para eventos internos de EZOAlerts.
EZOAlerts_Log = EZOAlerts_Log or {}
local MOD = EZOAlerts_Log

local EVENT_NAMESPACE = "EZOAlerts_Log"
local FLUSH_UPDATE = "EZOAlerts_LogFlush"
local FLUSH_DELAY_MS = 1000
local MAX_ENTRIES = 80

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

local function Print(message)
    if EZOAlerts and type(EZOAlerts.Print) == "function" then
        EZOAlerts.Print(message)
    end
end

function MOD.QueueFlush()
    if MOD.inCombat == true then
        return
    end

    EVENT_MANAGER:UnregisterForUpdate(FLUSH_UPDATE)
    EVENT_MANAGER:RegisterForUpdate(FLUSH_UPDATE, FLUSH_DELAY_MS, function()
        EVENT_MANAGER:UnregisterForUpdate(FLUSH_UPDATE)
        MOD.Flush()
    end)
end

function MOD.Record(category, message)
    if not IsEnabled() then
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

    MOD.QueueFlush()
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

    Print(GetText(_G.EZOA_LOG_HEADER, "EZOAlerts log"))

    for _, entry in ipairs(MOD.entries) do
        Print(FormatText(_G.EZOA_LOG_LINE, "<<1>>: <<2>>", {
            entry.category,
            entry.message,
        }))
    end

    MOD.entries = {}
end

function MOD.Init()
    MOD.entries = MOD.entries or {}
    MOD.inCombat = false

    if EVENT_PLAYER_COMBAT_STATE ~= nil then
        EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_COMBAT_STATE, function(_, inCombat)
            local wasInCombat = MOD.inCombat == true
            MOD.inCombat = inCombat == true

            if MOD.inCombat then
                EVENT_MANAGER:UnregisterForUpdate(FLUSH_UPDATE)
            elseif wasInCombat then
                MOD.Flush()
            end
        end)
    end
end
