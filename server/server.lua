RegisterNetEvent('VerifyEmoteSpeed', function(speed, isAnimal)
    if not isAnimal then return end
    if not speed then speed = 0 end

    if speed > Config.WalkSpeedMax then
        speed = Config.WalkSpeedMax
    elseif speed < Config.WalkSpeedMin or not speed then
        speed = Config.WalkSpeedMin
    end

    TriggerClientEvent('UpdWalkSpeed', source, speed)
end)