-- LibAddonMenu panel for EZOAlerts.
EZOAlerts_Menu = EZOAlerts_Menu or {}
local MENU = EZOAlerts_Menu

local ADDON_NAME = "EZOAlerts"
local DISPLAY_NAME = "E|cB040FFZ|rOAlerts"

local function RefreshRenderer()
    if EZOAlerts_Renderer and EZOAlerts_Renderer.Refresh then
        EZOAlerts_Renderer.Refresh()
    end
end

local function WarnForcedLanguage()
    if EZOAlerts and type(EZOAlerts.Print) == "function" then
        EZOAlerts.Print(GetString(EZOA_MSG_LANGUAGE_FORCED_WARNING))
    end
end

local function GetOptions()
    local EZOA = EZOAlerts
    return {
        { type = "header", name = GetString(EZOA_OPTION_GENERAL) },
        {
            type          = "dropdown",
            name          = GetString(EZOA_OPTION_LANGUAGE),
            choices       = { GetString(EZOA_OPTION_LANGUAGE_AUTO), "English", "Espanol" },
            choicesValues = { "auto", "en", "es" },
            getFunc       = function() return EZOA.sv.general.language or "auto" end,
            setFunc       = function(value)
                value = tostring(value or "auto")
                EZOA.sv.general.language = value
                if EZOAlerts_Lang and EZOAlerts_Lang.Apply then
                    EZOAlerts_Lang.Apply(value)
                end
                if EZOA.IsForcedLanguage and EZOA.IsForcedLanguage(value) then
                    WarnForcedLanguage()
                end
            end,
            default = "auto",
            width   = "half",
            tooltip = GetString(EZOA_OPTION_LANGUAGE_TOOLTIP),
        },

        { type = "header", name = GetString(EZOA_OPTION_ALERTS) },
        {
            type    = "checkbox",
            name    = GetString(EZOA_OPTION_ALERTS_ENABLED),
            getFunc = function() return EZOA.sv.alerts.enabled ~= false end,
            setFunc = function(value) EZOA.sv.alerts.enabled = value == true end,
            default = true,
            width   = "full",
        },
        {
            type     = "slider",
            name     = GetString(EZOA_OPTION_DURATION),
            tooltip  = GetString(EZOA_OPTION_DURATION_TOOLTIP),
            min      = 500,
            max      = 10000,
            step     = 250,
            getFunc  = function() return tonumber(EZOA.sv.alerts.durationMs) or 2500 end,
            setFunc  = function(value) EZOA.sv.alerts.durationMs = tonumber(value) or 2500 end,
            default  = 2500,
            width    = "half",
        },
        {
            type     = "slider",
            name     = GetString(EZOA_OPTION_SCALE),
            min      = 0.6,
            max      = 1.8,
            step     = 0.05,
            decimals = 2,
            getFunc  = function() return tonumber(EZOA.sv.alerts.scale) or 1 end,
            setFunc  = function(value)
                EZOA.sv.alerts.scale = tonumber(value) or 1
                RefreshRenderer()
            end,
            default  = 1,
            width    = "half",
        },
        {
            type          = "dropdown",
            name          = GetString(EZOA_OPTION_ANCHOR),
            choices       = { GetString(EZOA_OPTION_ANCHOR_CENTER), GetString(EZOA_OPTION_ANCHOR_TOP), GetString(EZOA_OPTION_ANCHOR_BOTTOM) },
            choicesValues = { "CENTER", "TOP", "BOTTOM" },
            getFunc       = function() return EZOA.sv.alerts.anchor or "CENTER" end,
            setFunc       = function(value)
                EZOA.sv.alerts.anchor = tostring(value or "CENTER")
                RefreshRenderer()
            end,
            default = "CENTER",
            width   = "half",
        },
        {
            type    = "button",
            name    = GetString(EZOA_OPTION_TEST_ALERT),
            func    = function()
                if EZOAlerts.ShowAlert then
                    EZOAlerts.ShowAlert(GetString(EZOA_TEST_ALERT_TEXT), EZOAlerts.ALERT_KIND_INFO)
                end
            end,
            width   = "full",
        },
    }
end

function MENU.Init()
    local LAM = LibAddonMenu2
    if not LAM then return end

    local panelData = {
        type                = "panel",
        name                = ADDON_NAME,
        displayName         = DISPLAY_NAME,
        author              = "@Zuriplayer",
        version             = EZOAlerts.ADDON_VERSION,
        registerForRefresh  = true,
        registerForDefaults = true,
    }

    local panel = LAM:RegisterAddonPanel("EZOAlerts_Panel", panelData)
    EZOAlerts._lamPanel = panel
    _G.EZOAlerts_Panel = panel

    LAM:RegisterOptionControls("EZOAlerts_Panel", GetOptions())
end
