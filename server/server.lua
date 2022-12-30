RegisterNetEvent('VerifyEmoteSpeed', function(speed, isAnimal)
    if not isAnimal then return end
    local adjDir = "both"

    if speed > Config.WalkSpeedMax then
        speed = Config.WalkSpeedMax
        adjDir = "NotMax"
    elseif speed < 0 then
        speed = 0
        adjDir = "NotMin"
    elseif speed < Config.WalkSpeedMin then
        speed = Config.WalkSpeedMin
        adjDir = "NotMin"
    end

    TriggerClientEvent('UpdWalkSpeed', source, speed, adjDir, true)
end)