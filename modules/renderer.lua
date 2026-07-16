-- Aviso visual en pantalla.
EZOAlerts_Renderer = EZOAlerts_Renderer or {}
local MOD = EZOAlerts_Renderer

local CONTROL_NAME = "EZOAlerts_Container"
local UPDATE_NAME = "EZOAlerts_AutoHide"
local EVENT_NAMESPACE = "EZOAlerts_Renderer"
local MAX_ACTIONS = 2

local colors = {
    info = {
        title = { 0.70, 0.88, 1.00, 1 },
        body = { 0.94, 0.96, 1.00, 1 },
        backdrop = { 0.02, 0.03, 0.04, 0.88 },
        edge = { 0.20, 0.50, 0.75, 0.85 },
        accent = { 0.20, 0.62, 0.95, 1 },
        button = { 0.08, 0.12, 0.15, 0.92 },
        primary = { 0.20, 0.62, 0.95, 1 },
    },
    warning = {
        title = { 1.00, 0.80, 0.32, 1 },
        body = { 0.96, 0.92, 0.84, 1 },
        backdrop = { 0.05, 0.04, 0.03, 0.92 },
        edge = { 0.70, 0.46, 0.12, 0.92 },
        accent = { 1.00, 0.62, 0.14, 1 },
        button = { 0.16, 0.11, 0.04, 0.94 },
        primary = { 1.00, 0.68, 0.18, 1 },
    },
    error = {
        title = { 1.00, 0.54, 0.48, 1 },
        body = { 0.98, 0.90, 0.88, 1 },
        backdrop = { 0.06, 0.03, 0.03, 0.94 },
        edge = { 0.72, 0.16, 0.12, 0.95 },
        accent = { 1.00, 0.24, 0.18, 1 },
        button = { 0.16, 0.06, 0.05, 0.94 },
        primary = { 1.00, 0.34, 0.28, 1 },
    },
}

local function IsGamepadMode()
    if type(IsInGamepadPreferredMode) == "function" and IsInGamepadPreferredMode() == true then
        return true
    end
    if type(IsInputStyleGamepad) == "function" and IsInputStyleGamepad() == true then
        return true
    end
    if type(IsInputPreferredSettingGamepad) == "function" and IsInputPreferredSettingGamepad() == true then
        return true
    end
    return false
end

local function GetKeyText(keyCode, fallback)
    if keyCode ~= nil and type(ZO_Keybindings_GetKeyText) == "function" then
        local text = ZO_Keybindings_GetKeyText(keyCode)
        if text ~= nil and text ~= "" then
            return text
        end
    end
    return fallback
end

local function GetActionHint(action, index)
    if type(action) ~= "table" then
        return nil
    end

    local useGamepad = IsGamepadMode()
    local fallback = useGamepad and action.gamepadHint or action.keyboardHint
    local keyCode = useGamepad and action.gamepadKey or action.keyboardKey

    if fallback == nil and type(action.hints) == "table" then
        fallback = useGamepad and action.hints.gamepad or action.hints.keyboard
    end

    if fallback == nil then
        fallback = useGamepad and (index == 1 and "A" or "X") or (index == 1 and "E" or "X")
    end

    local hint = tostring(GetKeyText(keyCode, fallback) or "")
    if hint == "" then
        return nil
    end
    return hint
end

local function ResolveAnchor(anchorName)
    anchorName = tostring(anchorName or "CENTER")
    if anchorName == "TOP" then return TOP end
    if anchorName == "BOTTOM" then return BOTTOM end
    return CENTER
end

local function IsHudScene()
    if not SCENE_MANAGER or type(SCENE_MANAGER.GetCurrentScene) ~= "function" then
        return false
    end

    local scene = SCENE_MANAGER:GetCurrentScene()
    if not scene or type(scene.GetName) ~= "function" then
        return false
    end

    local sceneName = scene:GetName()
    return sceneName == "hud" or sceneName == "hudui"
end

local function IsInCombat()
    if type(IsUnitInCombat) == "function" then
        return IsUnitInCombat("player") == true
    end
    return MOD.inCombat == true
end

local function CanShowWindow()
    return IsHudScene()
end

local function ShouldHideInCombat(options)
    if type(options) ~= "table" then
        return false
    end
    return options.hideInCombat == true or options.blockInCombat == true or options.suppressInCombat == true
end

local function GetStyle(kind)
    return colors[tostring(kind or "info")] or colors.info
end

local function ApplyStyle(kind)
    local style = GetStyle(kind)
    if MOD.backdrop then
        MOD.backdrop:SetCenterColor(style.backdrop[1], style.backdrop[2], style.backdrop[3], style.backdrop[4])
        MOD.backdrop:SetEdgeColor(style.edge[1], style.edge[2], style.edge[3], style.edge[4])
    end
    if MOD.accent then
        MOD.accent:SetCenterColor(style.accent[1], style.accent[2], style.accent[3], style.accent[4])
        MOD.accent:SetEdgeColor(style.accent[1], style.accent[2], style.accent[3], 0)
    end
    if MOD.marker then
        MOD.marker:SetColor(style.accent[1], style.accent[2], style.accent[3], style.accent[4])
    end
    return style
end

local function UpdateTextLayout(hasActions, hasTitle)
    local control = MOD.control
    local titleLabel = MOD.titleLabel
    local bodyLabel = MOD.label
    if not control or not titleLabel or not bodyLabel then
        return
    end

    titleLabel:ClearAnchors()
    bodyLabel:ClearAnchors()

    if hasActions then
        control:SetDimensions(560, hasTitle and 148 or 124)
        if hasTitle then
            titleLabel:SetAnchor(TOPLEFT, control, TOPLEFT, 56, 13)
            titleLabel:SetDimensions(470, 26)
            bodyLabel:SetAnchor(TOPLEFT, control, TOPLEFT, 56, 39)
            bodyLabel:SetDimensions(470, 52)
        else
            bodyLabel:SetAnchor(TOPLEFT, control, TOPLEFT, 56, 18)
            bodyLabel:SetDimensions(470, 62)
        end
    else
        control:SetDimensions(520, hasTitle and 98 or 78)
        if hasTitle then
            titleLabel:SetAnchor(TOPLEFT, control, TOPLEFT, 52, 12)
            titleLabel:SetDimensions(440, 24)
            bodyLabel:SetAnchor(TOPLEFT, control, TOPLEFT, 52, 36)
            bodyLabel:SetDimensions(440, 42)
        else
            bodyLabel:SetAnchor(LEFT, control, LEFT, 52, 0)
            bodyLabel:SetDimensions(440, 52)
        end
    end

    titleLabel:SetHidden(not hasTitle)
end

local function RegisterSceneFragments(control)
    if MOD.sceneFragmentsRegistered then
        return
    end

    if ZO_SimpleSceneFragment and HUD_SCENE and HUD_UI_SCENE then
        local fragment = ZO_SimpleSceneFragment:New(control)
        HUD_SCENE:AddFragment(fragment)
        HUD_UI_SCENE:AddFragment(fragment)
        MOD.sceneFragment = fragment
    end

    if SCENE_MANAGER and type(SCENE_MANAGER.RegisterCallback) == "function" then
        SCENE_MANAGER:RegisterCallback("SceneStateChanged", function()
            if EZOAlerts_Renderer and EZOAlerts_Renderer.RefreshVisibility then
                EZOAlerts_Renderer.RefreshVisibility()
            end
        end)
    end

    if EVENT_GAMEPAD_PREFERRED_MODE_CHANGED ~= nil then
        EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_GamepadMode", EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, function()
            if EZOAlerts_Renderer and EZOAlerts_Renderer.RefreshActionHints then
                EZOAlerts_Renderer.RefreshActionHints()
            end
        end)
    end

    if EVENT_INPUT_TYPE_CHANGED ~= nil then
        EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_InputType", EVENT_INPUT_TYPE_CHANGED, function()
            if EZOAlerts_Renderer and EZOAlerts_Renderer.RefreshActionHints then
                EZOAlerts_Renderer.RefreshActionHints()
            end
        end)
    end

    MOD.sceneFragmentsRegistered = true
end

local function SaveCurrentPosition()
    local control = MOD.control
    local sv = EZOAlerts and EZOAlerts.sv and EZOAlerts.sv.alerts
    if not control or not sv then
        return
    end

    local x, y = control:GetCenter()
    local rootX, rootY = GuiRoot:GetCenter()
    if not x or not y or not rootX or not rootY then
        return
    end

    sv.anchor = "CENTER"
    sv.offsetX = zo_round(x - rootX)
    sv.offsetY = zo_round(y - rootY)
end

local function ApplyMoveState()
    local control = MOD.control
    if not control then
        return
    end

    local canMove = MOD.moveMode == true and CanShowWindow() and not IsInCombat()
    MOD.canMove = canMove
    if MOD.dragActive and not canMove then
        control:StopMovingOrResizing()
        MOD.dragActive = false
    end
    control:SetMouseEnabled(canMove or MOD.hasActions == true)
    control:SetMovable(false)
    control:SetClampedToScreen(true)
end

local function HideActions()
    MOD.hasActions = false
    MOD.currentActions = nil
    if not MOD.actionButtons then
        return
    end

    for _, button in ipairs(MOD.actionButtons) do
        button:SetHidden(true)
        button:SetHandler("OnClicked", nil)
    end
end

local function ApplyActionButtons(actions)
    local control = MOD.control
    local label = MOD.label
    if not control or not label then
        return
    end

    actions = type(actions) == "table" and actions or nil
    local hasActions = actions and #actions > 0
    MOD.hasActions = hasActions == true
    MOD.currentActions = actions

    UpdateTextLayout(hasActions, MOD.hasTitle == true)
    if not hasActions then
        HideActions()
        return
    end

    MOD.actionButtons = MOD.actionButtons or {}
    for index = 1, MAX_ACTIONS do
        local button = MOD.actionButtons[index]
        if not button then
            button = WINDOW_MANAGER:CreateControl(CONTROL_NAME .. "Action" .. tostring(index), control, CT_BUTTON)
            button:SetMouseEnabled(true)

            button.backdrop = WINDOW_MANAGER:CreateControl(CONTROL_NAME .. "ActionBackdrop" .. tostring(index), button, CT_BACKDROP)
            button.backdrop:SetAnchorFill(button)
            button.backdrop:SetEdgeTexture("", 1, 1, 1)

            button.keyBackdrop = WINDOW_MANAGER:CreateControl(CONTROL_NAME .. "ActionKeyBackdrop" .. tostring(index), button, CT_BACKDROP)
            button.keyBackdrop:SetEdgeTexture("", 1, 1, 1)

            button.keyLabel = WINDOW_MANAGER:CreateControl(CONTROL_NAME .. "ActionKey" .. tostring(index), button, CT_LABEL)
            button.keyLabel:SetFont("ZoFontWinH4")
            button.keyLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
            button.keyLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)

            button.textLabel = WINDOW_MANAGER:CreateControl(CONTROL_NAME .. "ActionText" .. tostring(index), button, CT_LABEL)
            button.textLabel:SetFont("ZoFontWinH4")
            button.textLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
            button.textLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
            MOD.actionButtons[index] = button
        end

        local action = actions[index]
        if action then
            local isPrimary = action.primary == true or index == 1
            local style = GetStyle(MOD.currentKind)
            local width = isPrimary and 222 or 210
            local height = 34
            local x = (index == 1) and -120 or 116
            local hint = GetActionHint(action, index) or ""
            button:ClearAnchors()
            button:SetAnchor(BOTTOM, control, BOTTOM, x, -12)
            button:SetDimensions(width, height)

            button.backdrop:SetCenterColor(style.button[1], style.button[2], style.button[3], style.button[4])
            if isPrimary then
                button.backdrop:SetEdgeColor(style.primary[1], style.primary[2], style.primary[3], 0.88)
                button.keyBackdrop:SetCenterColor(style.primary[1], style.primary[2], style.primary[3], 1)
                button.keyBackdrop:SetEdgeColor(1, 1, 1, 0.32)
                button.keyLabel:SetColor(0.08, 0.08, 0.08, 1)
                button.textLabel:SetColor(style.primary[1], style.primary[2], style.primary[3], style.primary[4])
            else
                button.backdrop:SetEdgeColor(0.58, 0.58, 0.58, 0.48)
                button.keyBackdrop:SetCenterColor(0.72, 0.72, 0.72, 0.92)
                button.keyBackdrop:SetEdgeColor(1, 1, 1, 0.22)
                button.keyLabel:SetColor(0.08, 0.08, 0.08, 1)
                button.textLabel:SetColor(0.86, 0.86, 0.86, 1)
            end

            button.keyBackdrop:ClearAnchors()
            button.keyBackdrop:SetAnchor(LEFT, button, LEFT, 8, 0)
            button.keyBackdrop:SetDimensions(34, 22)

            button.keyLabel:ClearAnchors()
            button.keyLabel:SetAnchorFill(button.keyBackdrop)
            button.keyLabel:SetDimensions(34, 22)
            button.keyLabel:SetText(hint)

            button.textLabel:ClearAnchors()
            button.textLabel:SetAnchor(LEFT, button.keyLabel, RIGHT, 8, 0)
            button.textLabel:SetDimensions(width - 54, height)
            button.textLabel:SetText(tostring(action.text or "OK"))

            button:SetHandler("OnClicked", function()
                if type(action.callback) == "function" then
                    action.callback()
                end
            end)
            button:SetHidden(false)
        else
            button:SetHidden(true)
            button:SetHandler("OnClicked", nil)
        end
    end
end

local function EnsureControl()
    if MOD.control then
        return MOD.control
    end

    local wm = WINDOW_MANAGER
    local control = wm:CreateTopLevelWindow(CONTROL_NAME)
    control:SetDimensions(720, 86)
    control:SetMouseEnabled(false)
    control:SetMovable(false)
    control:SetClampedToScreen(true)
    control:SetHidden(true)
    if type(control.SetDrawTier) == "function" and DT_HIGH ~= nil then
        control:SetDrawTier(DT_HIGH)
    end
    if type(control.SetDrawLayer) == "function" and DL_OVERLAY ~= nil then
        control:SetDrawLayer(DL_OVERLAY)
    end
    if type(control.SetDrawLevel) == "function" then
        control:SetDrawLevel(100)
    end
    control:SetHandler("OnMouseDown", function(_, button)
        if button ~= MOUSE_BUTTON_INDEX_LEFT or MOD.canMove ~= true then
            return
        end
        MOD.dragActive = true
        control:SetMovable(true)
        control:StartMoving()
    end)
    control:SetHandler("OnMouseUp", function(_, button)
        if button ~= MOUSE_BUTTON_INDEX_LEFT or MOD.dragActive ~= true then
            return
        end
        control:StopMovingOrResizing()
        MOD.dragActive = false
        control:SetMovable(false)
    end)
    control:SetHandler("OnMoveStop", function()
        MOD.dragActive = false
        control:SetMovable(false)
        SaveCurrentPosition()
    end)

    local backdrop = wm:CreateControl(CONTROL_NAME .. "Backdrop", control, CT_BACKDROP)
    backdrop:SetAnchorFill(control)
    backdrop:SetCenterColor(0, 0, 0, 0.82)
    backdrop:SetEdgeColor(1, 1, 1, 0.35)
    backdrop:SetEdgeTexture("", 1, 1, 1)

    local accent = wm:CreateControl(CONTROL_NAME .. "Accent", control, CT_BACKDROP)
    accent:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
    accent:SetAnchor(BOTTOMLEFT, control, BOTTOMLEFT, 0, 0)
    accent:SetDimensions(6, 0)
    accent:SetEdgeTexture("", 1, 1, 1)

    local marker = wm:CreateControl(CONTROL_NAME .. "Marker", control, CT_LABEL)
    marker:SetAnchor(TOPLEFT, control, TOPLEFT, 22, 17)
    marker:SetDimensions(22, 28)
    marker:SetFont("ZoFontWinH2")
    marker:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    marker:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    marker:SetText("!")

    local label = wm:CreateControl(CONTROL_NAME .. "Label", control, CT_LABEL)
    label:SetFont("ZoFontWinH3")
    label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    local titleLabel = wm:CreateControl(CONTROL_NAME .. "Title", control, CT_LABEL)
    titleLabel:SetFont("ZoFontWinH2")
    titleLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    titleLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    titleLabel:SetHidden(true)

    MOD.control = control
    MOD.backdrop = backdrop
    MOD.accent = accent
    MOD.marker = marker
    MOD.label = label
    MOD.titleLabel = titleLabel
    ApplyActionButtons(nil)
    RegisterSceneFragments(control)
    return control
end

local function ApplyPlacement()
    local sv = EZOAlerts and EZOAlerts.sv and EZOAlerts.sv.alerts or {}
    local control = EnsureControl()
    control:ClearAnchors()
    control:SetAnchor(ResolveAnchor(sv.anchor), GuiRoot, ResolveAnchor(sv.anchor), tonumber(sv.offsetX) or 0, tonumber(sv.offsetY) or 0)
    control:SetScale(tonumber(sv.scale) or 1)
end

function MOD.Init()
    MOD.moveMode = false
    MOD.inCombat = false
    EnsureControl()
    ApplyPlacement()
    MOD.RefreshVisibility()

    if EVENT_PLAYER_COMBAT_STATE ~= nil then
        EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_COMBAT_STATE, function(_, inCombat)
            MOD.inCombat = inCombat == true
            if MOD.inCombat then
                MOD.SetMoveMode(false)
                if MOD.isPreview == true or MOD.hideInCombat == true then
                    MOD.Hide()
                else
                    MOD.RefreshVisibility()
                end
            else
                MOD.RefreshVisibility()
            end
        end)
    end
end

function MOD.Refresh()
    ApplyPlacement()
    MOD.RefreshVisibility()
end

function MOD.Hide()
    EVENT_MANAGER:UnregisterForUpdate(UPDATE_NAME)
    MOD.isShowing = false
    MOD.isPreview = false
    MOD.hideInCombat = false
    MOD.currentKey = nil
    MOD.currentKind = nil
    MOD.hasTitle = false
    HideActions()
    if MOD.control then
        MOD.control:SetHidden(true)
    end
end

function MOD.HideByKey(key)
    if key == nil or MOD.currentKey == key then
        MOD.Hide()
    end
end

function MOD.RefreshVisibility()
    if not MOD.control then
        return
    end

    if not CanShowWindow() then
        MOD.control:SetHidden(true)
        ApplyMoveState()
        return
    end

    if IsInCombat() and (MOD.isPreview == true or MOD.hideInCombat == true) then
        MOD.control:SetHidden(true)
        ApplyMoveState()
        return
    end

    ApplyMoveState()
    MOD.control:SetHidden(MOD.isShowing ~= true)
end

function MOD.RefreshActionHints()
    if MOD.hasActions == true and MOD.currentActions then
        ApplyActionButtons(MOD.currentActions)
        MOD.RefreshVisibility()
    end
end

function MOD.SetMoveMode(enabled)
    MOD.moveMode = enabled == true and not IsInCombat()
    EnsureControl()
    ApplyPlacement()

    if MOD.moveMode then
        EVENT_MANAGER:UnregisterForUpdate(UPDATE_NAME)
        MOD.currentKind = EZOAlerts.ALERT_KIND_INFO
        MOD.hasTitle = false
        ApplyActionButtons(nil)
        local style = ApplyStyle(EZOAlerts.ALERT_KIND_INFO)
        MOD.label:SetText(GetString(EZOA_ALERT_MOVE_PREVIEW))
        MOD.label:SetColor(style.body[1], style.body[2], style.body[3], style.body[4])
        MOD.isShowing = true
        MOD.isPreview = true
    elseif MOD.isPreview == true then
        MOD.Hide()
        return
    end

    MOD.RefreshVisibility()
end

function MOD.IsMoveMode()
    return MOD.moveMode == true
end

function MOD.Show(text, kind, options)
    local sv = EZOAlerts and EZOAlerts.sv and EZOAlerts.sv.alerts
    if sv and sv.enabled == false then
        return false
    end

    text = tostring(text or "")
    if text == "" then
        return false
    end

    options = options or {}
    if MOD.moveMode == true and MOD.isPreview == true and options.allowDuringMove ~= true then
        return false
    end

    local hideInCombat = ShouldHideInCombat(options)

    if not CanShowWindow() then
        MOD.Hide()
        return false
    end

    if hideInCombat and IsInCombat() then
        return false
    end

    local control = EnsureControl()
    ApplyPlacement()

    kind = tostring(kind or "info")
    local style = ApplyStyle(kind)
    local title = options.title
    local body = options.body or text
    MOD.currentKind = kind
    MOD.hasTitle = title ~= nil and tostring(title or "") ~= ""
    ApplyActionButtons(options.actions)
    if MOD.titleLabel then
        MOD.titleLabel:SetText(tostring(title or ""))
        MOD.titleLabel:SetColor(style.title[1], style.title[2], style.title[3], style.title[4])
    end
    MOD.label:SetText(tostring(body or ""))
    MOD.label:SetColor(style.body[1], style.body[2], style.body[3], style.body[4])
    MOD.isShowing = true
    MOD.isPreview = false
    MOD.hideInCombat = hideInCombat
    MOD.currentKey = options.key
    MOD.RefreshVisibility()

    local durationMs = tonumber(options.durationMs) or (sv and tonumber(sv.durationMs)) or 2500
    if durationMs > 0 then
        EVENT_MANAGER:UnregisterForUpdate(UPDATE_NAME)
        EVENT_MANAGER:RegisterForUpdate(UPDATE_NAME, durationMs, function()
            MOD.Hide()
        end)
    end

    return true
end
