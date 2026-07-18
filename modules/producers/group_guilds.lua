-- Detecta miembros del grupo que comparten guild contigo.
EZOAlerts_ProducerGroupGuilds = EZOAlerts_ProducerGroupGuilds or {}
local MOD = EZOAlerts_ProducerGroupGuilds

local EVENT_NAMESPACE = "EZOAlerts_ProducerGroupGuilds"
local SCAN_UPDATE = "EZOAlerts_GroupGuildScan"
local SCAN_DELAY_MS = 700

local DEFAULT_SETTINGS = {
    enabled = true,
    suppressWhenLeaderSharesGuild = true,
}

local function GetSettings()
    local sv = EZOAlerts and EZOAlerts.sv
    if not sv then
        return DEFAULT_SETTINGS
    end

    sv.producers = sv.producers or {}
    sv.producers.groupGuilds = sv.producers.groupGuilds or {}

    local settings = sv.producers.groupGuilds
    if settings.enabled == nil then settings.enabled = DEFAULT_SETTINGS.enabled end
    if settings.suppressWhenLeaderSharesGuild == nil then
        settings.suppressWhenLeaderSharesGuild = DEFAULT_SETTINGS.suppressWhenLeaderSharesGuild
    end
    return settings
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

local function JoinNames(names)
    return table.concat(names, ", ")
end

local function FormatUnitName(name)
    name = tostring(name or "")
    if name ~= "" and type(zo_strformat) == "function" and SI_UNIT_NAME ~= nil then
        return zo_strformat(SI_UNIT_NAME, name)
    end
    return name
end

local function GetGuildNameSafe(guildId)
    if type(GetGuildName) ~= "function" then
        return tostring(guildId or "")
    end
    return tostring(GetGuildName(guildId) or "")
end

local function GetSharedGuilds(displayName)
    displayName = tostring(displayName or "")
    if displayName == "" then
        return {}
    end
    if type(GetNumGuilds) ~= "function" or type(GetGuildId) ~= "function" then
        return {}
    end
    if type(GetGuildMemberIndexFromDisplayName) ~= "function" then
        return {}
    end

    local shared = {}
    for guildIndex = 1, GetNumGuilds() do
        local guildId = GetGuildId(guildIndex)
        if guildId then
            local memberIndex = GetGuildMemberIndexFromDisplayName(guildId, displayName)
            if memberIndex ~= nil and tonumber(memberIndex) ~= nil and tonumber(memberIndex) > 0 then
                local guildName = GetGuildNameSafe(guildId)
                if guildName ~= "" then
                    table.insert(shared, guildName)
                end
            end
        end
    end
    return shared
end

local function GetMemberName(unitTag)
    local displayName = ""
    local characterName = ""

    if type(GetUnitDisplayName) == "function" then
        displayName = tostring(GetUnitDisplayName(unitTag) or "")
    end
    if type(GetRawUnitName) == "function" then
        characterName = tostring(GetRawUnitName(unitTag) or "")
    end
    if type(GetUnitName) == "function" then
        characterName = characterName ~= "" and characterName or tostring(GetUnitName(unitTag) or "")
    end

    if characterName ~= "" then
        return FormatUnitName(characterName)
    end
    return displayName
end

local function IsSelf(unitTag, displayName)
    if unitTag == "player" then
        return true
    end

    if type(AreUnitsEqual) == "function" and AreUnitsEqual(unitTag, "player") then
        return true
    end

    if type(GetDisplayName) == "function" and displayName ~= "" then
        return displayName == GetDisplayName()
    end

    return false
end

local function GetGroupMembers()
    local members = {}
    if type(GetGroupSize) ~= "function" or type(GetGroupUnitTagByIndex) ~= "function" then
        return members
    end

    local size = tonumber(GetGroupSize()) or 0
    for index = 1, size do
        local unitTag = GetGroupUnitTagByIndex(index)
        if unitTag then
            local displayName = ""
            if type(GetUnitDisplayName) == "function" then
                displayName = tostring(GetUnitDisplayName(unitTag) or "")
            end
            if displayName ~= "" and not IsSelf(unitTag, displayName) then
                table.insert(members, {
                    unitTag = unitTag,
                    displayName = displayName,
                    name = GetMemberName(unitTag),
                })
            end
        end
    end
    return members
end

local function LeaderSharesGuild()
    if type(GetGroupLeaderUnitTag) ~= "function" then
        return false
    end

    local leaderTag = GetGroupLeaderUnitTag()
    if not leaderTag or IsSelf(leaderTag, "") then
        return false
    end

    local displayName = ""
    if type(GetUnitDisplayName) == "function" then
        displayName = tostring(GetUnitDisplayName(leaderTag) or "")
    end

    return #GetSharedGuilds(displayName) > 0
end

local function PrintSharedGuilds(member, sharedGuilds)
    local message = FormatText(_G.EZOA_ALERT_GROUP_GUILD_SHARED, "<<1>> shares guilds with you: <<2>>", {
        member.name or member.displayName,
        JoinNames(sharedGuilds),
    })

    if not EZOAlerts or type(EZOAlerts.Print) ~= "function" then
        return message
    end

    EZOAlerts.Print(message)
    return message
end

function MOD.ScanGroup()
    local settings = GetSettings()
    if settings.enabled == false then
        return
    end

    if settings.suppressWhenLeaderSharesGuild == true and LeaderSharesGuild() then
        return
    end

    MOD.seen = MOD.seen or {}

    for _, member in ipairs(GetGroupMembers()) do
        local sharedGuilds = GetSharedGuilds(member.displayName)
        if #sharedGuilds > 0 and not MOD.seen[member.displayName] then
            MOD.seen[member.displayName] = true
            local message = PrintSharedGuilds(member, sharedGuilds)
            if EZOAlerts_Log and EZOAlerts_Log.Record then
                EZOAlerts_Log.Record(GetText(_G.EZOA_LOG_CATEGORY_GROUP_GUILDS, "Guilds"), message)
            end
        end
    end
end

function MOD.QueueScan()
    EVENT_MANAGER:UnregisterForUpdate(SCAN_UPDATE)
    EVENT_MANAGER:RegisterForUpdate(SCAN_UPDATE, SCAN_DELAY_MS, function()
        EVENT_MANAGER:UnregisterForUpdate(SCAN_UPDATE)
        MOD.ScanGroup()
    end)
end

function MOD.ResetSession()
    MOD.seen = {}
end

function MOD.Init()
    MOD.ResetSession()

    if EVENT_GROUP_MEMBER_JOINED ~= nil then
        EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_GROUP_MEMBER_JOINED, function()
            MOD.QueueScan()
        end)
    end

    if EVENT_GROUP_UPDATE ~= nil then
        EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_GROUP_UPDATE, function()
            MOD.QueueScan()
        end)
    end

    if EVENT_GROUP_MEMBER_LEFT ~= nil then
        EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_GROUP_MEMBER_LEFT, function()
            MOD.QueueScan()
        end)
    end

    if EVENT_GROUP_DISBANDED ~= nil then
        EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_GROUP_DISBANDED, function()
            MOD.ResetSession()
        end)
    end

    MOD.QueueScan()
end
