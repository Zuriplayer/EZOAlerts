-- Comprueba si el rol elegido encaja con las armas y senales basicas.
EZOAlerts_ProducerRoleCheck = EZOAlerts_ProducerRoleCheck or {}
local MOD = EZOAlerts_ProducerRoleCheck

local EVENT_NAMESPACE = "EZOAlerts_ProducerRoleCheck"
local ALERT_ID = "role.check"
local SCAN_UPDATE = "EZOAlerts_RoleCheckScan"
local SCAN_DELAY_MS = 1200
local DEFAULT_INTERVAL_MS = 60000

local MODE_DISABLED = "disabled"
local MODE_ALARMS = "alarms"
local MODE_ALL = "all"
local LEVEL_ALARM = "alarm"
local LEVEL_WARNING = "warning"

local DEFAULT_SETTINGS = {
    mode = MODE_ALARMS,
    onlyGrouped = true,
    minIntervalMs = DEFAULT_INTERVAL_MS,
}

local ONE_HAND_WEAPONS = {
    [WEAPONTYPE_AXE] = true,
    [WEAPONTYPE_DAGGER] = true,
    [WEAPONTYPE_HAMMER] = true,
    [WEAPONTYPE_SWORD] = true,
}

local DAMAGE_WEAPONS = {
    [WEAPONTYPE_BOW] = true,
    [WEAPONTYPE_FIRE_STAFF] = true,
    [WEAPONTYPE_LIGHTNING_STAFF] = true,
    [WEAPONTYPE_TWO_HANDED_AXE] = true,
    [WEAPONTYPE_TWO_HANDED_HAMMER] = true,
    [WEAPONTYPE_TWO_HANDED_SWORD] = true,
}

local TAUNT_ABILITIES = {
    [28306] = 0, -- Puncture
    [38250] = 0, -- Pierce Armor
    [38256] = 0, -- Ransack
    [38984] = 1, -- Destructive Clench
    [38985] = 1, -- Flame Clench
    [38989] = 1, -- Frost Clench
    [38993] = 1, -- Shock Clench
    [39114] = 0, -- Deafening Roar
    [39475] = 0, -- Inner Fire
    [42056] = 0, -- Inner Rage
    [42060] = 0, -- Inner Beast
    [183165] = 0, -- Runic Jolt
    [183430] = 0, -- Runic Sunder
    [186531] = 0, -- Runic Embrace
}

local HEAL_ABILITIES = {
    [22250] = true, -- Breath of Life
    [22253] = true,
    [22256] = true,
    [28385] = true, -- Grand Healing
    [28536] = true, -- Regeneration
    [34727] = true, -- Healthy Offering
    [37243] = true, -- Combat Prayer
    [40058] = true,
    [40060] = true,
    [40076] = true,
    [40079] = true,
    [40094] = true,
    [40103] = true,
    [42038] = true, -- Energy Orb
    [77369] = true, -- Twilight Matriarch
    [85536] = true, -- Enchanted Growth
    [85862] = true,
    [85863] = true,
    [114196] = true, -- Blood Sacrifice
    [117883] = true,
    [117888] = true,
}

local function NowMs()
    if type(GetFrameTimeMilliseconds) == "function" then
        return GetFrameTimeMilliseconds()
    end
    if type(GetTimeStamp) == "function" then
        return GetTimeStamp() * 1000
    end
    return 0
end

local function GetSettings()
    local sv = EZOAlerts and EZOAlerts.sv
    if not sv then
        return DEFAULT_SETTINGS
    end

    sv.producers = sv.producers or {}
    sv.producers.roleCheck = sv.producers.roleCheck or {}

    local settings = sv.producers.roleCheck
    if settings.mode == nil then settings.mode = DEFAULT_SETTINGS.mode end
    if settings.muted == nil then settings.muted = false end
    if settings.onlyGrouped == nil then settings.onlyGrouped = DEFAULT_SETTINGS.onlyGrouped end
    if settings.minIntervalMs == nil then settings.minIntervalMs = DEFAULT_SETTINGS.minIntervalMs end
    return settings
end

local function IsAcknowledged(issueKey)
    return MOD.sessionAcknowledged and MOD.sessionAcknowledged[issueKey] == true
end

function MOD.AcknowledgeSession(issueKey)
    issueKey = tostring(issueKey or "")
    if issueKey == "" then
        return
    end

    MOD.sessionAcknowledged = MOD.sessionAcknowledged or {}
    MOD.sessionAcknowledged[issueKey] = true
    if EZOAlerts_Renderer and EZOAlerts_Renderer.HideByKey then
        EZOAlerts_Renderer.HideByKey("role_check")
    end
end

function MOD.MuteSession()
    MOD.sessionMuted = true
    if EZOAlerts_Renderer and EZOAlerts_Renderer.HideByKey then
        EZOAlerts_Renderer.HideByKey("role_check")
    end
end

local function GetText(stringId, fallback)
    local text = fallback
    if stringId ~= nil and type(GetString) == "function" then
        text = GetString(stringId)
    end
    return tostring(text or fallback or "")
end

local function IsGrouped()
    if type(IsUnitGrouped) == "function" and IsUnitGrouped("player") then
        return true
    end
    if type(GetGroupSize) == "function" and (tonumber(GetGroupSize()) or 0) > 1 then
        return true
    end
    return false
end

local function IsInCombat()
    if type(IsUnitInCombat) == "function" then
        return IsUnitInCombat("player") == true
    end
    return false
end

local function GetRole()
    if type(GetSelectedLFGRole) ~= "function" then
        return nil
    end
    local role = GetSelectedLFGRole()
    if role == LFG_ROLE_TANK or role == LFG_ROLE_HEAL or role == LFG_ROLE_DPS then
        return role
    end
    return nil
end

local function GetWeaponType(slot)
    if slot == nil or type(GetItemWeaponType) ~= "function" then
        return nil
    end
    local weaponType = GetItemWeaponType(BAG_WORN, slot)
    if weaponType == nil or weaponType == WEAPONTYPE_NONE then
        return nil
    end
    return weaponType
end

local function GetWeaponBars()
    return {
        {
            hotbar = HOTBAR_CATEGORY_PRIMARY,
            mainSlot = EQUIP_SLOT_MAIN_HAND,
            offSlot = EQUIP_SLOT_OFF_HAND,
            main = GetWeaponType(EQUIP_SLOT_MAIN_HAND),
            off = GetWeaponType(EQUIP_SLOT_OFF_HAND),
        },
        {
            hotbar = HOTBAR_CATEGORY_BACKUP,
            mainSlot = EQUIP_SLOT_BACKUP_MAIN,
            offSlot = EQUIP_SLOT_BACKUP_OFF,
            main = GetWeaponType(EQUIP_SLOT_BACKUP_MAIN),
            off = GetWeaponType(EQUIP_SLOT_BACKUP_OFF),
        },
    }
end

local function HasOneHandAndShield(bar)
    return bar and ONE_HAND_WEAPONS[bar.main] == true and bar.off == WEAPONTYPE_SHIELD
end

local function IsTankBar(bar)
    return HasOneHandAndShield(bar) or (bar and bar.main == WEAPONTYPE_FROST_STAFF)
end

local function IsHealingBar(bar)
    return bar and bar.main == WEAPONTYPE_HEALING_STAFF
end

local function IsDamageBar(bar)
    if not bar then return false end
    if DAMAGE_WEAPONS[bar.main] == true then return true end
    if ONE_HAND_WEAPONS[bar.main] == true and ONE_HAND_WEAPONS[bar.off] == true then return true end
    return false
end

local function ScanWeapons()
    local result = {
        bars = GetWeaponBars(),
        equippedBars = 0,
        tankBars = 0,
        healingBars = 0,
        damageBars = 0,
    }

    for _, bar in ipairs(result.bars) do
        if bar.main ~= nil then
            result.equippedBars = result.equippedBars + 1
            if IsTankBar(bar) then result.tankBars = result.tankBars + 1 end
            if IsHealingBar(bar) then result.healingBars = result.healingBars + 1 end
            if IsDamageBar(bar) then result.damageBars = result.damageBars + 1 end
        end
    end

    return result
end

local function GetSlotAbilityId(slotIndex, hotbarCategory)
    if type(GetSlotBoundId) ~= "function" or type(GetSlotType) ~= "function" then
        return nil, nil
    end

    local actionType = GetSlotType(slotIndex, hotbarCategory)
    local boundId = GetSlotBoundId(slotIndex, hotbarCategory)
    if not boundId or boundId == 0 then
        return nil, actionType
    end
    return boundId, actionType
end

local function HasTauntSlotted(weaponScan)
    if type(GetSlotBoundId) ~= "function" or type(GetSlotType) ~= "function" then
        return false
    end

    for _, bar in ipairs(weaponScan.bars or {}) do
        if bar.hotbar ~= nil then
            for slotIndex = 3, 8 do
                local abilityId, actionType = GetSlotAbilityId(slotIndex, bar.hotbar)
                if abilityId then
                    local weaponCheck = TAUNT_ABILITIES[abilityId]
                    if actionType == ACTION_TYPE_ABILITY and (weaponCheck == 0 or (weaponCheck == 1 and bar.main == WEAPONTYPE_FROST_STAFF)) then
                        return true
                    end
                    if actionType == ACTION_TYPE_CRAFTED_ABILITY and type(GetCraftedAbilityActiveScriptIds) == "function" then
                        if GetCraftedAbilityActiveScriptIds(abilityId) == 12 then
                            return true
                        end
                    end
                end
            end
        end
    end

    return false
end

local function HasHealSlotted()
    if type(GetSlotBoundId) ~= "function" or type(GetSlotType) ~= "function" then
        return false
    end

    local hotbars = { HOTBAR_CATEGORY_PRIMARY, HOTBAR_CATEGORY_BACKUP }
    for _, hotbarCategory in ipairs(hotbars) do
        if hotbarCategory ~= nil then
            for slotIndex = 3, 8 do
                local abilityId, actionType = GetSlotAbilityId(slotIndex, hotbarCategory)
                if actionType == ACTION_TYPE_ABILITY and abilityId and HEAL_ABILITIES[abilityId] == true then
                    return true
                end
            end
        end
    end

    return false
end

local function BuildIssue(role, weaponScan)
    local hasTaunt = HasTauntSlotted(weaponScan)
    local hasHeal = HasHealSlotted()

    if role == LFG_ROLE_TANK then
        if weaponScan.tankBars == 0 then
            return LEVEL_ALARM, "tank_no_weapon", GetString(EZOA_ALERT_ROLE_TANK_NO_WEAPON)
        end
        if not hasTaunt then
            return LEVEL_WARNING, "tank_no_taunt", GetString(EZOA_ALERT_ROLE_TANK_NO_TAUNT)
        end
    elseif role == LFG_ROLE_HEAL then
        if weaponScan.healingBars == 0 then
            return LEVEL_ALARM, "heal_no_weapon", GetString(EZOA_ALERT_ROLE_HEAL_NO_WEAPON)
        end
        if not hasHeal then
            return LEVEL_WARNING, "heal_no_heal_skill", GetString(EZOA_ALERT_ROLE_HEAL_NO_HEAL_SKILL)
        end
    elseif role == LFG_ROLE_DPS then
        if weaponScan.equippedBars > 0 and weaponScan.damageBars == 0 and (weaponScan.tankBars > 0 or weaponScan.healingBars > 0) then
            return LEVEL_ALARM, "dps_support_weapons", GetString(EZOA_ALERT_ROLE_DPS_SUPPORT_WEAPONS)
        end
        if hasTaunt or weaponScan.tankBars > 0 or weaponScan.healingBars > 0 then
            return LEVEL_WARNING, "dps_support_hint", GetString(EZOA_ALERT_ROLE_DPS_SUPPORT_HINT)
        end
    end

    return nil
end

local function CanShowLevel(level)
    local mode = tostring(GetSettings().mode or MODE_ALARMS)
    if mode == MODE_DISABLED then
        return false
    end
    if level == LEVEL_ALARM then
        return true
    end
    return mode == MODE_ALL
end

local function CanNotify(issueKey)
    local settings = GetSettings()
    local now = NowMs()
    local interval = tonumber(settings.minIntervalMs) or DEFAULT_INTERVAL_MS

    if MOD.lastIssueKey == issueKey and (now - (MOD.lastMessageAt or 0)) < interval then
        return false
    end

    return true
end

local function MarkNotified(issueKey)
    MOD.lastIssueKey = issueKey
    MOD.lastMessageAt = NowMs()
end

local function GetRoleAlertTitle(level)
    if level == LEVEL_ALARM then
        return GetString(EZOA_ALERT_ROLE_TITLE_ALARM)
    end
    return GetString(EZOA_ALERT_ROLE_TITLE_WARNING)
end

local function RegisterAlert()
    if not EZOAlerts.RegisterAlert then return end

    EZOAlerts.RegisterAlert(ALERT_ID, {
        kind = function(context)
            return context and context.kind or EZOAlerts.ALERT_KIND_WARNING
        end,
        channels = { screen = true },
        screenText = function(context)
            return context and context.message or ""
        end,
        options = function(context)
            return {
                title = context and context.title,
                body = context and context.message,
                durationMs = 0,
                hideInCombat = true,
                key = "role_check",
                actions = {
                    {
                        text = GetString(EZOA_ALERT_ACTION_ACKNOWLEDGE),
                        keyboardHint = "E",
                        gamepadHint = "A",
                        keyboardKey = _G.KEY_E,
                        gamepadKey = _G.KEY_GAMEPAD_BUTTON_1,
                        primary = true,
                        callback = function()
                            MOD.AcknowledgeSession(context and context.issueKey)
                        end,
                    },
                    {
                        text = GetString(EZOA_ALERT_ACTION_MUTE_SESSION),
                        keyboardHint = "X",
                        gamepadHint = "X",
                        keyboardKey = _G.KEY_X,
                        gamepadKey = _G.KEY_GAMEPAD_BUTTON_3,
                        callback = function()
                            MOD.MuteSession()
                        end,
                    },
                },
            }
        end,
    })
end

function MOD.Scan()
    local settings = GetSettings()
    if settings.mode == MODE_DISABLED or settings.muted == true or MOD.sessionMuted == true then
        MOD.lastIssueKey = nil
        return
    end
    if IsInCombat() then
        return
    end
    if settings.onlyGrouped == true and not IsGrouped() then
        MOD.lastIssueKey = nil
        return
    end

    local role = GetRole()
    if not role then
        MOD.lastIssueKey = nil
        return
    end

    local level, issueKey, message = BuildIssue(role, ScanWeapons())
    if not level or not CanShowLevel(level) then
        MOD.lastIssueKey = nil
        if EZOAlerts_Renderer and EZOAlerts_Renderer.HideByKey then
            EZOAlerts_Renderer.HideByKey("role_check")
        end
        return
    end
    if IsAcknowledged(issueKey) then
        return
    end
    if not CanNotify(issueKey) then
        return
    end

    local kind = (level == LEVEL_ALARM) and EZOAlerts.ALERT_KIND_ERROR or EZOAlerts.ALERT_KIND_WARNING
    local sent = false
    if EZOAlerts.TriggerAlert then
        sent = EZOAlerts.TriggerAlert(ALERT_ID, {
            message = message,
            title = GetRoleAlertTitle(level),
            issueKey = issueKey,
            kind = kind,
        })
    end

    if not sent then
        return
    end

    MarkNotified(issueKey)
    if EZOAlerts_Log and EZOAlerts_Log.Record then
        EZOAlerts_Log.Record(GetText(_G.EZOA_LOG_CATEGORY_ROLE_CHECK, "Role check"), message)
    end
end

function MOD.QueueScan()
    EVENT_MANAGER:UnregisterForUpdate(SCAN_UPDATE)
    EVENT_MANAGER:RegisterForUpdate(SCAN_UPDATE, SCAN_DELAY_MS, function()
        EVENT_MANAGER:UnregisterForUpdate(SCAN_UPDATE)
        MOD.Scan()
    end)
end

function MOD.Reset()
    MOD.lastIssueKey = nil
    MOD.lastMessageAt = 0
end

function MOD.Init()
    MOD.sessionMuted = false
    MOD.sessionAcknowledged = {}
    MOD.Reset()
    RegisterAlert()

    if EVENT_PLAYER_ACTIVATED ~= nil then
        EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_ACTIVATED, function()
            MOD.QueueScan()
        end)
    end

    if EVENT_GROUP_MEMBER_ROLE_CHANGED ~= nil then
        EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_GROUP_MEMBER_ROLE_CHANGED, function()
            MOD.QueueScan()
        end)
    end

    if EVENT_GROUP_MEMBER_ROLES_CHANGED ~= nil then
        EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_Roles", EVENT_GROUP_MEMBER_ROLES_CHANGED, function()
            MOD.QueueScan()
        end)
    end

    if EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED ~= nil then
        EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_SlotsAll", EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED, function()
            MOD.QueueScan()
        end)
    end

    if EVENT_ACTION_SLOT_UPDATED ~= nil then
        EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_Slot", EVENT_ACTION_SLOT_UPDATED, function()
            MOD.QueueScan()
        end)
    end

    if EVENT_INVENTORY_SINGLE_SLOT_UPDATE ~= nil then
        EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_Gear", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(_, bagId)
            if bagId == BAG_WORN then
                MOD.QueueScan()
            end
        end)
    end

    if EVENT_ACTIVE_WEAPON_PAIR_CHANGED ~= nil then
        EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_WeaponPair", EVENT_ACTIVE_WEAPON_PAIR_CHANGED, function()
            MOD.QueueScan()
        end)
    end

    if EVENT_GROUP_UPDATE ~= nil then
        EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_Group", EVENT_GROUP_UPDATE, function()
            MOD.QueueScan()
        end)
    end

    if EVENT_PLAYER_COMBAT_STATE ~= nil then
        EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_Combat", EVENT_PLAYER_COMBAT_STATE, function(_, inCombat)
            if inCombat ~= true then
                MOD.QueueScan()
            end
        end)
    end

    if SCENE_MANAGER and type(SCENE_MANAGER.RegisterCallback) == "function" then
        SCENE_MANAGER:RegisterCallback("SceneStateChanged", function()
            MOD.QueueScan()
        end)
    end

    MOD.QueueScan()
end
