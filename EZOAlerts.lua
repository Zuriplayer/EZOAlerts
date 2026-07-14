-- Entrada principal de EZOAlerts.
EZOAlerts = EZOAlerts or {}
local EZOA = EZOAlerts

local ADDON_NAME = "EZOAlerts"
local LANGUAGE_INHERIT = "inherit"
local LANGUAGE_AUTO = "auto"
EZOA.LANGUAGE_INHERIT = LANGUAGE_INHERIT
EZOA.LANGUAGE_AUTO = LANGUAGE_AUTO

local languageCallbackRegistered = false

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
    return LANGUAGE_INHERIT
end

function EZOA.GetClientLanguage()
    return GetClientLanguage()
end

function EZOA.GetEffectiveLanguage(language)
    language = tostring(language or EZOA.GetDefaultLanguage())
    if language == LANGUAGE_INHERIT then
        if EZOCore and type(EZOCore.GetLanguage) == "function" then
            local ok, inherited = pcall(function()
                return EZOCore:GetLanguage()
            end)
            if ok and (inherited == "es" or inherited == "en") then
                return inherited
            end
        end
        return GetClientLanguage()
    end
    if language == "es" or language == "en" then
        return language
    end
    return GetClientLanguage()
end

function EZOA.IsForcedLanguage(language)
    language = tostring(language or EZOA.GetDefaultLanguage())
    return language == "es" or language == "en"
end

function EZOA.ApplyLanguagePreference(language)
    local configuredLanguage = tostring(language or EZOA.GetDefaultLanguage())
    if EZOAlerts_Lang and EZOAlerts_Lang.Apply then
        EZOAlerts_Lang.Apply(configuredLanguage)
    end
end

function EZOA.RegisterEZOCoreLanguageCallback()
    if languageCallbackRegistered
        or not (EZOCore and type(EZOCore.RegisterCallback) == "function") then
        return false
    end

    local eventName = EZOCore.EVENT_LANGUAGE_CHANGED or "EZO_CORE_LANGUAGE_CHANGED"
    local ok, result = pcall(function()
        return EZOCore:RegisterCallback(eventName, function()
            if EZOA.sv and EZOA.sv.general and EZOA.sv.general.language == LANGUAGE_INHERIT then
                EZOA.ApplyLanguagePreference(LANGUAGE_INHERIT)
                if EZOAlerts_Renderer and EZOAlerts_Renderer.Refresh then
                    EZOAlerts_Renderer.Refresh()
                end
            end
        end)
    end)
    languageCallbackRegistered = ok and result == true
    return languageCallbackRegistered
end

function EZOA:Initialize()
    if EZOAlerts_SavedVars and EZOAlerts_SavedVars.Init then
        EZOAlerts_SavedVars.Init()
    end

    EZOA.ApplyLanguagePreference(self.sv.general.language or EZOA.GetDefaultLanguage())
    EZOA.RegisterEZOCoreLanguageCallback()

    if EZOAlerts_Registry and EZOAlerts_Registry.Init then
        EZOAlerts_Registry.Init()
    end

    if EZOAlerts_Log and EZOAlerts_Log.Init then
        EZOAlerts_Log.Init()
    end

    if EZOAlerts_Renderer and EZOAlerts_Renderer.Init then
        EZOAlerts_Renderer.Init()
    end

    if EZOAlerts_GroupChat and EZOAlerts_GroupChat.Init then
        EZOAlerts_GroupChat.Init()
    end

    if EZOAlerts_Channels and EZOAlerts_Channels.Init then
        EZOAlerts_Channels.Init()
    end

    if EZOAlerts_Producers and EZOAlerts_Producers.Init then
        EZOAlerts_Producers.Init()
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
