-- Avisa cuando el lider del grupo cambia de zona.
EZOAlerts_ProducerGroupLeaderZone = EZOAlerts_ProducerGroupLeaderZone or {}
local MOD = EZOAlerts_ProducerGroupLeaderZone

local EVENT_NAMESPACE = "EZOAlerts_ProducerGroupLeaderZone"
local SCAN_UPDATE = "EZOAlerts_GroupLeaderZoneScan"
local SCAN_DELAY_MS = 1200
local DEFAULT_INTERVAL_MS = 10000

local DEFAULT_SETTINGS = {
    enabled = true,
    ignoreIfPlayerInSameZone = true,
    minIntervalMs = DEFAULT_INTERVAL_MS,
}

local function NowMs()
    if type(GetFrameTimeMilliseconds) == "function" then
        return GetFrameTimeMilliseconds()
    end
    if type(GetTimeStamp) == "function" then
        return GetTimeStamp() * 1000
    end
    return 0
end

local function GetSettings()
    local sv = EZOAlerts and EZOAlerts.sv
    if not sv then
        return DEFAULT_SETTINGS
    end

    sv.producers = sv.producers or {}
    sv.producers.groupLeaderZone = sv.producers.groupLeaderZone or {}

    local settings = sv.producers.groupLeaderZone
    if settings.enabled == nil then settings.enabled = DEFAULT_SETTINGS.enabled end
    if settings.ignoreIfPlayerInSameZone == nil then settings.ignoreIfPlayerInSameZone = DEFAULT_SETTINGS.ignoreIfPlayerInSameZone end
    if settings.minIntervalMs == nil then settings.minIntervalMs = DEFAULT_SETTINGS.minIntervalMs end
    return settings
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

local function IsSelf(unitTag)
    if unitTag == "player" then
        return true
    end
    if type(AreUnitsEqual) == "function" then
        return AreUnitsEqual(unitTag, "player") == true
    end
    return false
end

local function GetName(unitTag)
    if type(GetUnitName) == "function" then
        local name = GetUnitName(unitTag)
        if name and name ~= "" then
            return name
        end
    end
    if type(GetUnitDisplayName) == "function" then
        return tostring(GetUnitDisplayName(unitTag) or "")
    end
    return ""
end

local function GetZone(unitTag)
    if type(GetUnitZone) ~= "function" then
        return ""
    end
    return tostring(GetUnitZone(unitTag) or "")
end

local function GetSubzone(unitTag)
    if type(GetUnitSubzone) ~= "function" then
        return ""
    end
    return tostring(GetUnitSubzone(unitTag) or "")
end

local function GetStateKey(state)
    return tostring(state.zone or "") .. "|" .. tostring(state.subzone or "")
end

local function GetDestinationText(state)
    local zone = tostring(state.zone or "")
    local subzone = tostring(state.subzone or "")
    if subzone ~= "" and subzone ~= zone then
        return subzone .. " - " .. zone
    end
    return zone
end

local function GetLeaderState()
    if type(GetGroupLeaderUnitTag) ~= "function" then
        return nil
    end

    local leaderTag = GetGroupLeaderUnitTag()
    if not leaderTag or leaderTag == "" or IsSelf(leaderTag) then
        return nil
    end

    local zone = GetZone(leaderTag)
    if zone == "" then
        return nil
    end

    return {
        unitTag = leaderTag,
        name = GetName(leaderTag),
        zone = zone,
        subzone = GetSubzone(leaderTag),
    }
end

local function PlayerIsInZone(zone)
    if zone == "" then
        return false
    end
    return GetZone("player") == zone
end

local function ShouldNotify(state, forceEvenSameZone)
    local settings = GetSettings()
    if settings.enabled == false then
        return false
    end

    if not forceEvenSameZone and settings.ignoreIfPlayerInSameZone == true and PlayerIsInZone(state.zone) then
        return false
    end

    local now = NowMs()
    local interval = tonumber(settings.minIntervalMs) or DEFAULT_INTERVAL_MS
    local messageKey = GetStateKey(state)
    if MOD.lastMessageKey == messageKey and (now - (MOD.lastMessageAt or 0)) < interval then
        return false
    end

    MOD.lastMessageKey = messageKey
    MOD.lastMessageAt = now
    return true
end

local function PrintLeaderZone(state)
    local message = FormatText(_G.EZOA_ALERT_GROUP_LEADER_ZONE_CHANGED, "Group leader is now in: <<1>>", {
        GetDestinationText(state),
        state.name,
    })

    if not EZOAlerts or type(EZOAlerts.Print) ~= "function" then
        return message
    end

    EZOAlerts.Print(message)
    return message
end

function MOD.Scan()
    local state = GetLeaderState()
    if not state then
        if MOD.lastLeaderKey ~= nil then
            MOD.leaderWasUnavailable = true
        end
        return
    end

    local stateKey = GetStateKey(state)
    if MOD.lastLeaderKey == nil then
        MOD.lastLeaderKey = stateKey
        MOD.leaderWasUnavailable = false
        return
    end

    local changedPlace = stateKey ~= MOD.lastLeaderKey
    local reappearedSamePlace = MOD.leaderWasUnavailable == true and stateKey == MOD.lastLeaderKey

    MOD.lastLeaderKey = stateKey
    MOD.leaderWasUnavailable = false

    if changedPlace or reappearedSamePlace then
        if ShouldNotify(state, reappearedSamePlace) then
            local message = PrintLeaderZone(state)
            if EZOAlerts_Log and EZOAlerts_Log.Record then
                EZOAlerts_Log.Record(GetText(_G.EZOA_LOG_CATEGORY_GROUP_LEADER, "Leader"), message)
            end
        end
    end
end

function MOD.QueueScan()
    EVENT_MANAGER:UnregisterForUpdate(SCAN_UPDATE)
    EVENT_MANAGER:RegisterForUpdate(SCAN_UPDATE, SCAN_DELAY_MS, function()
        EVENT_MANAGER:UnregisterForUpdate(SCAN_UPDATE)
        MOD.Scan()
    end)
end

function MOD.Reset()
    MOD.lastLeaderKey = nil
    MOD.leaderWasUnavailable = false
    MOD.lastMessageKey = nil
    MOD.lastMessageAt = 0
end

function MOD.Init()
    MOD.Reset()

    if EVENT_GROUP_MEMBER_SUBZONE_CHANGED ~= nil then
        EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_GROUP_MEMBER_SUBZONE_CHANGED, function()
            MOD.QueueScan()
        end)
    end

    if EVENT_UNIT_CREATED ~= nil then
        EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_UNIT_CREATED, function()
            MOD.QueueScan()
        end)
    end

    if EVENT_UNIT_DESTROYED ~= nil then
        EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_UNIT_DESTROYED, function()
            MOD.QueueScan()
        end)
    end

    if EVENT_GROUP_UPDATE ~= nil then
        EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_GROUP_UPDATE, function()
            MOD.QueueScan()
        end)
    end

    if EVENT_GROUP_MEMBER_JOINED ~= nil then
        EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_GROUP_MEMBER_JOINED, function()
            MOD.QueueScan()
        end)
    end

    if EVENT_GROUP_DISBANDED ~= nil then
        EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_GROUP_DISBANDED, function()
            MOD.Reset()
        end)
    end

    MOD.QueueScan()
end
