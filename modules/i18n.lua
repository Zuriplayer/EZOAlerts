-- Minimal i18n layer for EZOAlerts.
EZOAlerts_Lang = EZOAlerts_Lang or {}

local function ApplyString(id, value, version)
    local stringId = _G[id]
    if stringId == nil then
        ZO_CreateStringId(id, value)
        stringId = _G[id]
    end

    if stringId ~= nil then
        SafeAddString(stringId, value, version)
    end
end

function EZOAlerts_Lang.Apply(language)
    local effectiveLanguage = language
    if EZOAlerts and type(EZOAlerts.GetEffectiveLanguage) == "function" then
        effectiveLanguage = EZOAlerts.GetEffectiveLanguage(language)
    end

    local source = (effectiveLanguage == "es" and EZOALERTS_STRINGS_ES) or EZOALERTS_STRINGS_EN
    if not source then return end

    EZOAlerts_Lang._stringVersion = (tonumber(EZOAlerts_Lang._stringVersion) or 0) + 1
    for key, value in pairs(source) do
        ApplyString(key, value, EZOAlerts_Lang._stringVersion)
    end

    EZOAlerts_Lang.current = (effectiveLanguage == "es") and "es" or "en"
    EZOAlerts_Lang.configured = tostring(language or "auto")
end
