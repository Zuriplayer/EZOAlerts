-- Avisos de sacos pesados detectados desde el propio addon.
EZOAlerts_ProducerHeavySacks = EZOAlerts_ProducerHeavySacks or {}
local MOD = EZOAlerts_ProducerHeavySacks

local EVENT_NAMESPACE = "EZOAlerts_ProducerHeavySacks"
local ALERT_ID = "heavy_sack.opened"
local TARGET_TTL_MS = 4000
local DEFAULT_INTERVAL_MS = 15000

local DEFAULT_SETTINGS = {
    enabled = true,
    groupChat = true,
    minIntervalMs = DEFAULT_INTERVAL_MS,
}

local HEAVY_SACK_WORDS = {
    ["heavy sack"] = true,
    ["heavy sacks"] = true,
    ["saco pesado"] = true,
    ["sacos pesados"] = true,
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

local function Lower(value)
    value = tostring(value or "")
    if type(zo_strlower) == "function" then
        return zo_strlower(value)
    end
    return string.lower(value)
end

local function Trim(value)
    return tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function CleanName(value)
    value = Trim(value)
    value = value:gsub("|c%x%x%x%x%x%x", ""):gsub("|r", "")
    if type(zo_strformat) == "function" and SI_UNIT_NAME ~= nil then
        value = zo_strformat(SI_UNIT_NAME, value)
    end
    value = value:gsub("%^%a+", "")
    value = Lower(Trim(value))
    return Trim(value)
end

local function IsHeavySackName(value)
    value = CleanName(value)
    if value == "" then
        return false
    end
    return HEAVY_SACK_WORDS[value] == true
end

local function GetSettings()
    local sv = EZOAlerts and EZOAlerts.sv
    if not sv then
        return DEFAULT_SETTINGS
    end

    sv.producers = sv.producers or {}
    sv.producers.heavySacks = sv.producers.heavySacks or {}

    local settings = sv.producers.heavySacks
    if settings.enabled == nil then settings.enabled = DEFAULT_SETTINGS.enabled end
    if settings.groupChat == nil then settings.groupChat = DEFAULT_SETTINGS.groupChat end
    if settings.minIntervalMs == nil then settings.minIntervalMs = DEFAULT_SETTINGS.minIntervalMs end
    return settings
end

local function IsGrouped()
    if type(IsUnitGrouped) == "function" and IsUnitGrouped("player") then
        return true
    end
    if type(GetGroupSize) == "function" and (tonumber(GetGroupSize()) or 0) > 1 then
        return true
    end
    return false
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

local function GetPlayerName()
    local name = nil
    if type(GetUnitName) == "function" then
        name = GetUnitName("player")
    end
    if (not name or name == "") and type(GetDisplayName) == "function" then
        name = GetDisplayName()
    end
    return tostring(name or "")
end

local function GetTargetName(context)
    local name = context and context.targetName
    if name and tostring(name) ~= "" then
        return name
    end
    return GetText(_G.EZOA_ALERT_HEAVY_SACK_UNKNOWN, "Heavy Sack")
end

local function RegisterAlert()
    if not EZOAlerts.RegisterAlert then return end

    EZOAlerts.RegisterAlert(ALERT_ID, {
        kind = EZOAlerts.ALERT_KIND_INFO,
        channels = function()
            local settings = GetSettings()
            return {
                screen = false,
                groupChat = settings.groupChat == true,
            }
        end,
        screenText = function(context)
            return FormatText(_G.EZOA_ALERT_HEAVY_SACK_SCREEN, "<<1>> opened a heavy sack.", {
                context and context.playerName or GetPlayerName(),
                GetTargetName(context),
            })
        end,
        groupText = function(context)
            return FormatText(_G.EZOA_ALERT_HEAVY_SACK_GROUP, "<<1>> opened a heavy sack.", {
                context and context.playerName or GetPlayerName(),
                GetTargetName(context),
            })
        end,
    })
end

local function CaptureCameraTarget()
    if type(GetGameCameraInteractableActionInfo) ~= "function" then
        return
    end

    local actionName, interactableName, interactionBlocked, isOwned, additionalInteractInfo = GetGameCameraInteractableActionInfo()
    if interactionBlocked then
        return
    end

    MOD.lastTarget = {
        actionName = actionName,
        name = interactableName,
        additionalInfo = additionalInteractInfo,
        isOwned = isOwned,
        capturedAt = NowMs(),
    }
end

local function GetLootTarget()
    if type(GetLootTargetInfo) ~= "function" then
        return nil
    end

    local name, targetType, actionName, isOwned = GetLootTargetInfo()
    if not name or name == "" then
        return nil
    end

    return {
        name = name,
        targetType = targetType,
        actionName = actionName,
        isOwned = isOwned,
    }
end

local function FindHeavySackTarget()
    local now = NowMs()
    local lastTarget = MOD.lastTarget

    if lastTarget and (now - (lastTarget.capturedAt or 0)) <= TARGET_TTL_MS then
        if IsHeavySackName(lastTarget.additionalInfo) or IsHeavySackName(lastTarget.name) then
            return lastTarget
        end
    end

    local lootTarget = GetLootTarget()
    if lootTarget and IsHeavySackName(lootTarget.name) then
        return lootTarget
    end

    return nil
end

local function ShouldSend(target)
    local settings = GetSettings()
    if settings.enabled == false then
        return false
    end
    if not IsGrouped() then
        return false
    end

    local now = NowMs()
    local interval = tonumber(settings.minIntervalMs) or DEFAULT_INTERVAL_MS
    local key = CleanName(target and (target.name or target.additionalInfo))

    if MOD.lastSentKey == key and (now - (MOD.lastSentAt or 0)) < interval then
        return false
    end

    MOD.lastSentKey = key
    MOD.lastSentAt = now
    return true
end

local function TriggerHeavySackAlert(target)
    local context = {
        playerName = GetPlayerName(),
        targetName = target and (target.name or target.additionalInfo),
        actionName = target and target.actionName,
    }
    if EZOAlerts.TriggerAlert then
        EZOAlerts.TriggerAlert(ALERT_ID, context)
    end
    if EZOAlerts_Log and EZOAlerts_Log.Record then
        EZOAlerts_Log.Record(GetText(_G.EZOA_LOG_CATEGORY_HEAVY_SACKS, "Heavy sacks"), FormatText(_G.EZOA_ALERT_HEAVY_SACK_GROUP, "<<1>> opened a heavy sack.", {
            context.playerName,
            GetTargetName(context),
        }))
    end
end

function MOD.OnLootUpdated()
    local target = FindHeavySackTarget()
    if not target or not ShouldSend(target) then
        return
    end

    TriggerHeavySackAlert(target)
end

function MOD.Init()
    RegisterAlert()
    CaptureCameraTarget()

    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_RETICLE_TARGET_CHANGED, function()
        CaptureCameraTarget()
    end)

    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_LOOT_UPDATED, function()
        MOD.OnLootUpdated()
    end)
end
