-- Group chat output channel for EZOAlerts.
EZOAlerts_GroupChat = EZOAlerts_GroupChat or {}
local MOD = EZOAlerts_GroupChat

function MOD.Init()
end

local function CanSendToGroup()
    if type(IsUnitGrouped) == "function" and IsUnitGrouped("player") then
        return true
    end
    if type(GetGroupSize) == "function" and (tonumber(GetGroupSize()) or 0) > 1 then
        return true
    end
    return false
end

function MOD.Send(text, options)
    text = tostring(text or "")
    if text == "" then
        return false
    end

    if options and options.requireGroup == false then
        -- Allow explicit future system/local tests to bypass the group guard.
    elseif not CanSendToGroup() then
        return false
    end

    if type(StartChatInput) == "function" then
        StartChatInput(text, CHAT_CHANNEL_PARTY)
        return true
    end

    return false
end
