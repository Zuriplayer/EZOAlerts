-- Panel de opciones de EZOAlerts en LibAddonMenu.
EZOAlerts_Menu = EZOAlerts_Menu or {}
local MENU = EZOAlerts_Menu

local ADDON_NAME = "EZOAlerts"
local DISPLAY_NAME = "E|cB040FFZ|rOAlerts"
local PANEL_ID = "EZOAlerts_Panel"
local FEEDBACK_URL = "https://discord.gg/ekw8zUAcRm"

local function MsToSeconds(value, fallbackMs)
    local ms = tonumber(value) or fallbackMs or 0
    return ms / 1000
end

local function SecondsToMs(value, fallbackSeconds)
    local seconds = tonumber(value) or fallbackSeconds or 0
    return zo_round(seconds * 1000)
end

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

local function GetRoleCheckSettings()
    EZOAlerts.sv.producers = EZOAlerts.sv.producers or {}
    EZOAlerts.sv.producers.roleCheck = EZOAlerts.sv.producers.roleCheck or {}

    local settings = EZOAlerts.sv.producers.roleCheck
    if settings.mode == nil then settings.mode = "alarms" end
    if settings.muted == nil then settings.muted = false end
    if settings.onlyGrouped == nil then settings.onlyGrouped = true end
    if settings.minIntervalMs == nil then settings.minIntervalMs = 60000 end
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
            min      = 0.5,
            max      = 10,
            step     = 0.5,
            decimals = 1,
            getFunc  = function() return MsToSeconds(EZOA.sv.alerts.durationMs, 2500) end,
            setFunc  = function(value) EZOA.sv.alerts.durationMs = SecondsToMs(value, 2.5) end,
            default  = 2.5,
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
            type    = "checkbox",
            name    = GetString(EZOA_OPTION_MOVE_WINDOW),
            tooltip = GetString(EZOA_OPTION_MOVE_WINDOW_TOOLTIP),
            getFunc = function()
                return EZOAlerts_Renderer and EZOAlerts_Renderer.IsMoveMode and EZOAlerts_Renderer.IsMoveMode() or false
            end,
            setFunc = function(value)
                if EZOAlerts_Renderer and EZOAlerts_Renderer.SetMoveMode then
                    EZOAlerts_Renderer.SetMoveMode(value == true)
                end
                if value == true and EZOAlerts and EZOAlerts.Print then
                    EZOAlerts.Print(GetString(EZOA_MSG_MOVE_WINDOW_HINT))
                end
            end,
            default = false,
            width   = "full",
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
            min      = 5,
            max      = 60,
            step     = 5,
            getFunc  = function() return MsToSeconds(GetChestSettings().minIntervalMs, 15000) end,
            setFunc  = function(value) GetChestSettings().minIntervalMs = SecondsToMs(value, 15) end,
            default  = 15,
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
            min      = 5,
            max      = 60,
            step     = 5,
            getFunc  = function() return MsToSeconds(GetHeavySackSettings().minIntervalMs, 15000) end,
            setFunc  = function(value) GetHeavySackSettings().minIntervalMs = SecondsToMs(value, 15) end,
            default  = 15,
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
            min      = 5,
            max      = 60,
            step     = 5,
            getFunc  = function() return MsToSeconds(GetGroupLeaderZoneSettings().minIntervalMs, 10000) end,
            setFunc  = function(value) GetGroupLeaderZoneSettings().minIntervalMs = SecondsToMs(value, 10) end,
            default  = 10,
            width    = "half",
        },
        {
            type          = "dropdown",
            name          = GetString(EZOA_OPTION_ROLE_CHECK_MODE),
            tooltip       = GetString(EZOA_OPTION_ROLE_CHECK_MODE_TOOLTIP),
            choices       = { GetString(EZOA_OPTION_ROLE_CHECK_DISABLED), GetString(EZOA_OPTION_ROLE_CHECK_ALARMS), GetString(EZOA_OPTION_ROLE_CHECK_ALL) },
            choicesValues = { "disabled", "alarms", "all" },
            getFunc       = function() return GetRoleCheckSettings().mode or "alarms" end,
            setFunc       = function(value)
                GetRoleCheckSettings().mode = tostring(value or "alarms")
                if EZOAlerts_ProducerRoleCheck and EZOAlerts_ProducerRoleCheck.Reset then
                    EZOAlerts_ProducerRoleCheck.Reset()
                end
                if EZOAlerts_ProducerRoleCheck and EZOAlerts_ProducerRoleCheck.QueueScan then
                    EZOAlerts_ProducerRoleCheck.QueueScan()
                end
            end,
            default = "alarms",
            width   = "full",
        },
        {
            type    = "checkbox",
            name    = GetString(EZOA_OPTION_ROLE_CHECK_MUTED),
            tooltip = GetString(EZOA_OPTION_ROLE_CHECK_MUTED_TOOLTIP),
            getFunc = function() return GetRoleCheckSettings().muted == true end,
            setFunc = function(value)
                GetRoleCheckSettings().muted = value == true
                if EZOAlerts_ProducerRoleCheck and EZOAlerts_ProducerRoleCheck.Reset then
                    EZOAlerts_ProducerRoleCheck.Reset()
                end
                if value ~= true and EZOAlerts_ProducerRoleCheck and EZOAlerts_ProducerRoleCheck.QueueScan then
                    EZOAlerts_ProducerRoleCheck.QueueScan()
                end
            end,
            default = false,
            width   = "full",
        },
        {
            type    = "checkbox",
            name    = GetString(EZOA_OPTION_ROLE_CHECK_ONLY_GROUPED),
            tooltip = GetString(EZOA_OPTION_ROLE_CHECK_ONLY_GROUPED_TOOLTIP),
            getFunc = function() return GetRoleCheckSettings().onlyGrouped == true end,
            setFunc = function(value)
                GetRoleCheckSettings().onlyGrouped = value == true
                if EZOAlerts_ProducerRoleCheck and EZOAlerts_ProducerRoleCheck.QueueScan then
                    EZOAlerts_ProducerRoleCheck.QueueScan()
                end
            end,
            default = true,
            width   = "full",
        },
        {
            type     = "slider",
            name     = GetString(EZOA_OPTION_ROLE_CHECK_INTERVAL),
            tooltip  = GetString(EZOA_OPTION_ROLE_CHECK_INTERVAL_TOOLTIP),
            min      = 15,
            max      = 300,
            step     = 15,
            getFunc  = function() return MsToSeconds(GetRoleCheckSettings().minIntervalMs, 60000) end,
            setFunc  = function(value) GetRoleCheckSettings().minIntervalMs = SecondsToMs(value, 60) end,
            default  = 60,
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
        feedback            = FEEDBACK_URL,
        registerForRefresh  = true,
        registerForDefaults = true,
    }

    local options = GetOptions()
    if EZOCore and type(EZOCore.RegisterSettingsPanel) == "function" then
        local registered = EZOCore:RegisterSettingsPanel(ADDON_NAME, PANEL_ID, panelData, options)
        if registered then
            EZOAlerts.ezoSettingsRegistered = true
            return
        end
    end

    local panel = LAM:RegisterAddonPanel(PANEL_ID, panelData)
    EZOAlerts._lamPanel = panel
    _G.EZOAlerts_Panel = panel

    LAM:RegisterOptionControls(PANEL_ID, options)
end
