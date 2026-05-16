-- Alert registry. Producers register small alert definitions here.
EZOAlerts_Registry = EZOAlerts_Registry or {}
local REG = EZOAlerts_Registry

REG._alerts = REG._alerts or {}

function REG.Init()
    REG._alerts = REG._alerts or {}
end

function REG.Register(id, definition)
    id = tostring(id or "")
    if id == "" or type(definition) ~= "table" then
        return false
    end
    REG._alerts[id] = definition
    return true
end

function REG.Get(id)
    return REG._alerts and REG._alerts[tostring(id or "")] or nil
end

local function ResolveValue(value, context)
    if type(value) == "function" then
        return value(context)
    end
    return value
end

local function BuildPayload(definition, context)
    local payload = {
        text = ResolveValue(definition.text, context),
        screenText = ResolveValue(definition.screenText, context),
        groupText = ResolveValue(definition.groupText, context),
        kind = definition.kind or (EZOAlerts and EZOAlerts.ALERT_KIND_INFO) or "info",
        options = definition.options,
    }

    payload.screenText = payload.screenText or payload.text
    payload.groupText = payload.groupText or payload.text
    return payload
end

function REG.Trigger(id, context)
    local definition = REG.Get(id)
    if not definition then
        return false
    end

    local payload = BuildPayload(definition, context)
    if EZOAlerts_Channels and EZOAlerts_Channels.Dispatch then
        return EZOAlerts_Channels.Dispatch(payload, definition.channels)
    end
    return false
end

function EZOAlerts.ShowAlert(text, kind, options)
    if EZOAlerts_Channels and EZOAlerts_Channels.Dispatch then
        return EZOAlerts_Channels.Dispatch({
            text = text,
            screenText = text,
            kind = kind or EZOAlerts.ALERT_KIND_INFO,
            options = options,
        }, { screen = true })
    end
    return false
end

function EZOAlerts.SendGroupAlert(text, options)
    if EZOAlerts_Channels and EZOAlerts_Channels.Dispatch then
        return EZOAlerts_Channels.Dispatch({
            text = text,
            groupText = text,
            options = options,
        }, { groupChat = true })
    end
    return false
end

function EZOAlerts.RegisterAlert(id, definition)
    return REG.Register(id, definition)
end

function EZOAlerts.TriggerAlert(id, context)
    return REG.Trigger(id, context)
end
