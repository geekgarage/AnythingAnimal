RegisterNetEvent('VerifyEmoteSpeed', function(speed, isAnimal)
    if not isAnimal then return end

    if speed > Config.WalkSpeedMax then
        speed = Config.WalkSpeedMax
    elseif speed > 0.01 or speed < Config.WalkSpeedMin then
        speed = Config.WalkSpeedMin
    end

    TriggerClientEvent('UpdWalkSpeed', source, speed)
end)