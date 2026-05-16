-- Main entry point for EZOAlerts.
EZOAlerts = EZOAlerts or {}
local EZOA = EZOAlerts

local ADDON_NAME = "EZOAlerts"
local LANGUAGE_AUTO = "auto"

local function Print(message)
    if LibChatMessage then
        LibChatMessage(ADDON_NAME, "EZOA"):Print(tostring(message))
    else
        d(tostring(message))
    end
end

EZOA.Print = Print

local function GetClientLanguage()
    if type(GetCVar) == "function" then
        local language = zo_strlower(tostring(GetCVar("Language.2") or ""))
        local prefix = language:sub(1, 2)
        if prefix == "es" then return "es" end
        if prefix == "en" then return "en" end
    end
    return "en"
end

function EZOA.GetDefaultLanguage()
    return LANGUAGE_AUTO
end

function EZOA.GetClientLanguage()
    return GetClientLanguage()
end

function EZOA.GetEffectiveLanguage(language)
    language = tostring(language or LANGUAGE_AUTO)
    if language == "es" or language == "en" then
        return language
    end
    return GetClientLanguage()
end

function EZOA.IsForcedLanguage(language)
    language = tostring(language or LANGUAGE_AUTO)
    return language == "es" or language == "en"
end

function EZOA:Initialize()
    if EZOAlerts_SavedVars and EZOAlerts_SavedVars.Init then
        EZOAlerts_SavedVars.Init()
    end

    if EZOAlerts_Lang and EZOAlerts_Lang.Apply then
        EZOAlerts_Lang.Apply(self.sv.general.language or LANGUAGE_AUTO)
    end

    if EZOAlerts_Registry and EZOAlerts_Registry.Init then
        EZOAlerts_Registry.Init()
    end

    if EZOAlerts_Renderer and EZOAlerts_Renderer.Init then
        EZOAlerts_Renderer.Init()
    end

    if EZOAlerts_Menu and EZOAlerts_Menu.Init then
        EZOAlerts_Menu.Init()
    end

    Print(GetString(EZOA_MSG_INIT))
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, function(_, name)
    if name ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    EZOAlerts:Initialize()
end)
