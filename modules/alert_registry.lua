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

function REG.Show(id, context)
    local definition = REG.Get(id)
    if not definition then
        return false
    end

    local text = definition.text
    if type(text) == "function" then
        text = text(context)
    end

    local kind = definition.kind or (EZOAlerts and EZOAlerts.ALERT_KIND_INFO) or "info"
    if EZOAlerts_Renderer and EZOAlerts_Renderer.Show then
        return EZOAlerts_Renderer.Show(text, kind, definition.options)
    end
    return false
end

function EZOAlerts.ShowAlert(text, kind, options)
    if EZOAlerts_Renderer and EZOAlerts_Renderer.Show then
        return EZOAlerts_Renderer.Show(text, kind, options)
    end
    return false
end

function EZOAlerts.RegisterAlert(id, definition)
    return REG.Register(id, definition)
end

function EZOAlerts.TriggerAlert(id, context)
    return REG.Show(id, context)
end
