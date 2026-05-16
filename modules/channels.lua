-- Channel dispatcher for screen and group chat alerts.
EZOAlerts_Channels = EZOAlerts_Channels or {}
local MOD = EZOAlerts_Channels

function MOD.Init()
end

local function IsEnabled(channelName)
    local sv = EZOAlerts and EZOAlerts.sv and EZOAlerts.sv.channels
    if not sv then
        return true
    end
    return sv[channelName] == true
end

local function WantsChannel(channels, channelName)
    if channels == nil then
        return channelName == "screen"
    end
    if type(channels) == "string" then
        return channels == channelName
    end
    if type(channels) == "table" then
        return channels[channelName] == true
    end
    return false
end

function MOD.Dispatch(payload, channels)
    if type(payload) ~= "table" then
        return false
    end

    local sent = false

    if WantsChannel(channels, EZOAlerts.CHANNEL_SCREEN) and IsEnabled(EZOAlerts.CHANNEL_SCREEN) then
        local text = payload.screenText or payload.text
        if EZOAlerts_Renderer and EZOAlerts_Renderer.Show then
            sent = EZOAlerts_Renderer.Show(text, payload.kind, payload.options) or sent
        end
    end

    if WantsChannel(channels, EZOAlerts.CHANNEL_GROUP_CHAT) and IsEnabled(EZOAlerts.CHANNEL_GROUP_CHAT) then
        local text = payload.groupText or payload.text
        if EZOAlerts_GroupChat and EZOAlerts_GroupChat.Send then
            sent = EZOAlerts_GroupChat.Send(text, payload.options) or sent
        end
    end

    return sent
end
