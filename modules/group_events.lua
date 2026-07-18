-- Eventos de grupo recibidos por EZOCore para avisos visuales locales.
EZOAlerts_GroupEvents = EZOAlerts_GroupEvents or {}
local MOD = EZOAlerts_GroupEvents

local CALLBACK_EVENT = "EZO_CORE_GROUP_ALERT_EVENT_RECEIVED"

local QUALITY_KEYS = {
    unknown = true,
    simple = true,
    intermediate = true,
    advanced = true,
    master = true,
    impossible = true,
}

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

local function GetQualityText(qualityKey)
    qualityKey = tostring(qualityKey or "unknown")
    if not QUALITY_KEYS[qualityKey] then
        qualityKey = "unknown"
    end
    local stringId = _G["EZOA_ALERT_CHEST_QUALITY_" .. string.upper(qualityKey)]
    return GetText(stringId, qualityKey)
end

local function CanShowScreenAlert()
    local sv = EZOAlerts and EZOAlerts.sv
    if not sv then
        return true
    end
    if sv.alerts and sv.alerts.enabled == false then
        return false
    end
    return not (sv.channels and sv.channels.screen == false)
end

local function IsEventEnabled(eventType)
    local producers = EZOAlerts and EZOAlerts.sv and EZOAlerts.sv.producers
    if not producers then
        return true
    end

    if eventType == "chest" then
        local settings = producers.chests
        return not (settings and settings.enabled == false)
    end
    if eventType == "heavySack" then
        local settings = producers.heavySacks
        return not (settings and settings.enabled == false)
    end
    return true
end

local function GetGroupPresence()
    if not (EZOCore and type(EZOCore.GetService) == "function") then
        return nil
    end
    return EZOCore:GetService("family.groupPresence", 1)
end

local function BuildMessage(eventType, actorName, qualityKey)
    if eventType == "chest" then
        return FormatText(_G.EZOA_ALERT_CHEST_SCREEN, "<<1>> opened a <<2>> chest.", {
            actorName,
            GetQualityText(qualityKey),
        })
    end
    if eventType == "heavySack" then
        return FormatText(_G.EZOA_ALERT_HEAVY_SACK_SCREEN, "<<1>> opened a heavy sack.", {
            actorName,
        })
    end
    return nil
end

function MOD.ShowEvent(eventType, actorName, qualityKey)
    if not CanShowScreenAlert() then
        return false
    end
    if not IsEventEnabled(eventType) then
        return false
    end

    local message = BuildMessage(eventType, actorName, qualityKey)
    if not message or message == "" then
        return false
    end

    if EZOAlerts_Renderer and EZOAlerts_Renderer.Show then
        return EZOAlerts_Renderer.Show(message, EZOAlerts.ALERT_KIND_INFO, {
            key = "group_event_" .. tostring(eventType or "unknown"),
        })
    end
    return false
end

function MOD.Publish(eventType, actorName, qualityKey)
    local groupPresence = GetGroupPresence()
    if not groupPresence or type(groupPresence.PublishAlertEvent) ~= "function" then
        return false
    end

    local sent = groupPresence:PublishAlertEvent({
        sourceAddonId = "ezoalerts",
        eventType = eventType,
        quality = qualityKey or "unknown",
        actorName = actorName,
        ttlSeconds = 15,
    })
    if sent then
        MOD.ShowEvent(eventType, actorName, qualityKey)
    end
    return sent == true
end

function MOD.OnRemoteEvent(_unitTag, event)
    if type(event) ~= "table" then
        return false
    end
    if event.sourceAddonId ~= "ezoalerts" then
        return false
    end
    return MOD.ShowEvent(event.eventType, event.actorName, event.quality)
end

function MOD.Init()
    if MOD.callbackRegistered then
        return
    end
    if EZOCore and type(EZOCore.RegisterCallback) == "function" then
        EZOCore:RegisterCallback(CALLBACK_EVENT, function(unitTag, event)
            MOD.OnRemoteEvent(unitTag, event)
        end)
        MOD.callbackRegistered = true
    end
end
