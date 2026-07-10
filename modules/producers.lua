-- Productores internos de avisos creados dentro de EZOAlerts.
EZOAlerts_Producers = EZOAlerts_Producers or {}
local MOD = EZOAlerts_Producers

function MOD.Init()
    if EZOAlerts_ProducerChests and EZOAlerts_ProducerChests.Init then
        EZOAlerts_ProducerChests.Init()
    end

    if EZOAlerts_ProducerHeavySacks and EZOAlerts_ProducerHeavySacks.Init then
        EZOAlerts_ProducerHeavySacks.Init()
    end

    if EZOAlerts_ProducerGroupGuilds and EZOAlerts_ProducerGroupGuilds.Init then
        EZOAlerts_ProducerGroupGuilds.Init()
    end

    if EZOAlerts_ProducerGroupLeaderZone and EZOAlerts_ProducerGroupLeaderZone.Init then
        EZOAlerts_ProducerGroupLeaderZone.Init()
    end

    if EZOAlerts_ProducerRoleCheck and EZOAlerts_ProducerRoleCheck.Init then
        EZOAlerts_ProducerRoleCheck.Init()
    end
end
