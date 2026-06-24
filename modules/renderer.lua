-- Aviso visual en pantalla.
EZOAlerts_Renderer = EZOAlerts_Renderer or {}
local MOD = EZOAlerts_Renderer

local CONTROL_NAME = "EZOAlerts_Container"
local UPDATE_NAME = "EZOAlerts_AutoHide"

local colors = {
    info = { 0.25, 0.70, 1.00, 1 },
    warning = { 1.00, 0.72, 0.20, 1 },
    error = { 1.00, 0.25, 0.25, 1 },
}

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

    MOD.sceneFragmentsRegistered = true
end

local function EnsureControl()
    if MOD.control then
        return MOD.control
    end

    local wm = WINDOW_MANAGER
    local control = wm:CreateTopLevelWindow(CONTROL_NAME)
    control:SetDimensions(720, 86)
    control:SetMouseEnabled(false)
    control:SetHidden(true)

    local backdrop = wm:CreateControl(CONTROL_NAME .. "Backdrop", control, CT_BACKDROP)
    backdrop:SetAnchorFill(control)
    backdrop:SetCenterColor(0, 0, 0, 0.82)
    backdrop:SetEdgeColor(1, 1, 1, 0.35)
    backdrop:SetEdgeTexture("", 1, 1, 1)

    local label = wm:CreateControl(CONTROL_NAME .. "Label", control, CT_LABEL)
    label:SetAnchor(CENTER, control, CENTER, 0, 0)
    label:SetDimensions(680, 56)
    label:SetFont("ZoFontWinH2")
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    MOD.control = control
    MOD.backdrop = backdrop
    MOD.label = label
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
    EnsureControl()
    ApplyPlacement()
    MOD.RefreshVisibility()
end

function MOD.Refresh()
    ApplyPlacement()
    MOD.RefreshVisibility()
end

function MOD.Hide()
    EVENT_MANAGER:UnregisterForUpdate(UPDATE_NAME)
    MOD.isShowing = false
    if MOD.control then
        MOD.control:SetHidden(true)
    end
end

function MOD.RefreshVisibility()
    if not MOD.control then
        return
    end

    if not IsHudScene() then
        MOD.control:SetHidden(true)
        return
    end

    MOD.control:SetHidden(MOD.isShowing ~= true)
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

    if not IsHudScene() then
        MOD.Hide()
        return false
    end

    local control = EnsureControl()
    ApplyPlacement()

    kind = tostring(kind or "info")
    local color = colors[kind] or colors.info
    MOD.label:SetText(text)
    MOD.label:SetColor(color[1], color[2], color[3], color[4])
    MOD.isShowing = true
    MOD.RefreshVisibility()

    local durationMs = options and tonumber(options.durationMs) or (sv and tonumber(sv.durationMs)) or 2500
    if durationMs > 0 then
        EVENT_MANAGER:UnregisterForUpdate(UPDATE_NAME)
        EVENT_MANAGER:RegisterForUpdate(UPDATE_NAME, durationMs, function()
            MOD.Hide()
        end)
    end

    return true
end
