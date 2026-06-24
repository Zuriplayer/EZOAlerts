-- Panel de opciones de EZOAlerts en LibAddonMenu.
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

local function GetChestSettings()
    EZOAlerts.sv.producers = EZOAlerts.sv.producers or {}
    EZOAlerts.sv.producers.chests = EZOAlerts.sv.producers.chests or {}

    local settings = EZOAlerts.sv.producers.chests
    if settings.enabled == nil then settings.enabled = true end
    if settings.groupChat == nil then settings.groupChat = true end
    if settings.minIntervalMs == nil then settings.minIntervalMs = 15000 end
    return settings
end

local function GetGroupGuildSettings()
    EZOAlerts.sv.producers = EZOAlerts.sv.producers or {}
    EZOAlerts.sv.producers.groupGuilds = EZOAlerts.sv.producers.groupGuilds or {}

    local settings = EZOAlerts.sv.producers.groupGuilds
    if settings.enabled == nil then settings.enabled = true end
    if settings.suppressWhenLeaderSharesGuild == nil then settings.suppressWhenLeaderSharesGuild = true end
    return settings
end

local function GetHeavySackSettings()
    EZOAlerts.sv.producers = EZOAlerts.sv.producers or {}
    EZOAlerts.sv.producers.heavySacks = EZOAlerts.sv.producers.heavySacks or {}

    local settings = EZOAlerts.sv.producers.heavySacks
    if settings.enabled == nil then settings.enabled = true end
    if settings.groupChat == nil then settings.groupChat = true end
    if settings.minIntervalMs == nil then settings.minIntervalMs = 15000 end
    return settings
end

local function GetGroupLeaderZoneSettings()
    EZOAlerts.sv.producers = EZOAlerts.sv.producers or {}
    EZOAlerts.sv.producers.groupLeaderZone = EZOAlerts.sv.producers.groupLeaderZone or {}

    local settings = EZOAlerts.sv.producers.groupLeaderZone
    if settings.enabled == nil then settings.enabled = true end
    if settings.ignoreIfPlayerInSameZone == nil then settings.ignoreIfPlayerInSameZone = true end
    if settings.minIntervalMs == nil then settings.minIntervalMs = 10000 end
    return settings
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
        {
            type    = "checkbox",
            name    = GetString(EZOA_OPTION_LOG_ENABLED),
            tooltip = GetString(EZOA_OPTION_LOG_ENABLED_TOOLTIP),
            getFunc = function() return EZOA.sv.general.log == true end,
            setFunc = function(value) EZOA.sv.general.log = value == true end,
            default = false,
            width   = "full",
        },

        { type = "header", name = GetString(EZOA_OPTION_ALERTS) },
        {
            type    = "checkbox",
            name    = GetString(EZOA_OPTION_ALERTS_ENABLED),
            getFunc = function() return EZOA.sv.channels.screen ~= false end,
            setFunc = function(value)
                EZOA.sv.channels.screen = value == true
                EZOA.sv.alerts.enabled = value == true
            end,
            default = true,
            width   = "full",
        },
        {
            type    = "checkbox",
            name    = GetString(EZOA_OPTION_GROUP_CHAT_ENABLED),
            tooltip = GetString(EZOA_OPTION_GROUP_CHAT_ENABLED_TOOLTIP),
            getFunc = function() return EZOA.sv.channels.groupChat == true end,
            setFunc = function(value) EZOA.sv.channels.groupChat = value == true end,
            default = false,
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
        {
            type    = "button",
            name    = GetString(EZOA_OPTION_TEST_GROUP_CHAT),
            tooltip = GetString(EZOA_OPTION_TEST_GROUP_CHAT_TOOLTIP),
            func    = function()
                if EZOAlerts.SendGroupAlert then
                    EZOAlerts.SendGroupAlert(GetString(EZOA_TEST_GROUP_CHAT_TEXT))
                end
            end,
            width   = "full",
        },

        { type = "header", name = GetString(EZOA_OPTION_GENERATED_ALERTS) },
        {
            type    = "checkbox",
            name    = GetString(EZOA_OPTION_CHESTS_ENABLED),
            tooltip = GetString(EZOA_OPTION_CHESTS_ENABLED_TOOLTIP),
            getFunc = function() return GetChestSettings().enabled ~= false end,
            setFunc = function(value) GetChestSettings().enabled = value == true end,
            default = true,
            width   = "full",
        },
        {
            type    = "checkbox",
            name    = GetString(EZOA_OPTION_CHESTS_GROUP_CHAT),
            tooltip = GetString(EZOA_OPTION_CHESTS_GROUP_CHAT_TOOLTIP),
            getFunc = function() return GetChestSettings().groupChat == true end,
            setFunc = function(value) GetChestSettings().groupChat = value == true end,
            default = true,
            width   = "full",
        },
        {
            type     = "slider",
            name     = GetString(EZOA_OPTION_CHESTS_INTERVAL),
            tooltip  = GetString(EZOA_OPTION_CHESTS_INTERVAL_TOOLTIP),
            min      = 5000,
            max      = 60000,
            step     = 5000,
            getFunc  = function() return tonumber(GetChestSettings().minIntervalMs) or 15000 end,
            setFunc  = function(value) GetChestSettings().minIntervalMs = tonumber(value) or 15000 end,
            default  = 15000,
            width    = "half",
        },
        {
            type    = "checkbox",
            name    = GetString(EZOA_OPTION_HEAVY_SACKS_ENABLED),
            tooltip = GetString(EZOA_OPTION_HEAVY_SACKS_ENABLED_TOOLTIP),
            getFunc = function() return GetHeavySackSettings().enabled ~= false end,
            setFunc = function(value) GetHeavySackSettings().enabled = value == true end,
            default = true,
            width   = "full",
        },
        {
            type    = "checkbox",
            name    = GetString(EZOA_OPTION_HEAVY_SACKS_GROUP_CHAT),
            tooltip = GetString(EZOA_OPTION_HEAVY_SACKS_GROUP_CHAT_TOOLTIP),
            getFunc = function() return GetHeavySackSettings().groupChat == true end,
            setFunc = function(value) GetHeavySackSettings().groupChat = value == true end,
            default = true,
            width   = "full",
        },
        {
            type     = "slider",
            name     = GetString(EZOA_OPTION_HEAVY_SACKS_INTERVAL),
            tooltip  = GetString(EZOA_OPTION_HEAVY_SACKS_INTERVAL_TOOLTIP),
            min      = 5000,
            max      = 60000,
            step     = 5000,
            getFunc  = function() return tonumber(GetHeavySackSettings().minIntervalMs) or 15000 end,
            setFunc  = function(value) GetHeavySackSettings().minIntervalMs = tonumber(value) or 15000 end,
            default  = 15000,
            width    = "half",
        },
        {
            type    = "checkbox",
            name    = GetString(EZOA_OPTION_GROUP_GUILDS_ENABLED),
            tooltip = GetString(EZOA_OPTION_GROUP_GUILDS_ENABLED_TOOLTIP),
            getFunc = function() return GetGroupGuildSettings().enabled ~= false end,
            setFunc = function(value)
                GetGroupGuildSettings().enabled = value == true
                if value == true and EZOAlerts_ProducerGroupGuilds and EZOAlerts_ProducerGroupGuilds.QueueScan then
                    EZOAlerts_ProducerGroupGuilds.QueueScan()
                end
            end,
            default = true,
            width   = "full",
        },
        {
            type    = "checkbox",
            name    = GetString(EZOA_OPTION_GROUP_GUILDS_SUPPRESS_LEADER),
            tooltip = GetString(EZOA_OPTION_GROUP_GUILDS_SUPPRESS_LEADER_TOOLTIP),
            getFunc = function() return GetGroupGuildSettings().suppressWhenLeaderSharesGuild == true end,
            setFunc = function(value)
                GetGroupGuildSettings().suppressWhenLeaderSharesGuild = value == true
                if EZOAlerts_ProducerGroupGuilds and EZOAlerts_ProducerGroupGuilds.ResetSession then
                    EZOAlerts_ProducerGroupGuilds.ResetSession()
                end
            end,
            default = true,
            width   = "full",
        },
        {
            type    = "checkbox",
            name    = GetString(EZOA_OPTION_GROUP_LEADER_ZONE_ENABLED),
            tooltip = GetString(EZOA_OPTION_GROUP_LEADER_ZONE_ENABLED_TOOLTIP),
            getFunc = function() return GetGroupLeaderZoneSettings().enabled ~= false end,
            setFunc = function(value)
                GetGroupLeaderZoneSettings().enabled = value == true
                if EZOAlerts_ProducerGroupLeaderZone and EZOAlerts_ProducerGroupLeaderZone.Reset then
                    EZOAlerts_ProducerGroupLeaderZone.Reset()
                end
                if value == true and EZOAlerts_ProducerGroupLeaderZone and EZOAlerts_ProducerGroupLeaderZone.QueueScan then
                    EZOAlerts_ProducerGroupLeaderZone.QueueScan()
                end
            end,
            default = true,
            width   = "full",
        },
        {
            type    = "checkbox",
            name    = GetString(EZOA_OPTION_GROUP_LEADER_ZONE_IGNORE_SAME),
            tooltip = GetString(EZOA_OPTION_GROUP_LEADER_ZONE_IGNORE_SAME_TOOLTIP),
            getFunc = function() return GetGroupLeaderZoneSettings().ignoreIfPlayerInSameZone == true end,
            setFunc = function(value) GetGroupLeaderZoneSettings().ignoreIfPlayerInSameZone = value == true end,
            default = true,
            width   = "full",
        },
        {
            type     = "slider",
            name     = GetString(EZOA_OPTION_GROUP_LEADER_ZONE_INTERVAL),
            tooltip  = GetString(EZOA_OPTION_GROUP_LEADER_ZONE_INTERVAL_TOOLTIP),
            min      = 5000,
            max      = 60000,
            step     = 5000,
            getFunc  = function() return tonumber(GetGroupLeaderZoneSettings().minIntervalMs) or 10000 end,
            setFunc  = function(value) GetGroupLeaderZoneSettings().minIntervalMs = tonumber(value) or 10000 end,
            default  = 10000,
            width    = "half",
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
