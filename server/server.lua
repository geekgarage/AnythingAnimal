RegisterNetEvent('VerifyEmoteSpeed', function(speed, isAnimal)
    if not isAnimal then return end

    if speed > Config.WalkSpeedMax then
        speed = Config.WalkSpeedMax
    elseif speed < Config.WalkSpeedMin or not speed then
        if not speed then
            speed = 0.000000000000001
        else
            speed = Config.WalkSpeedMin
        end
    end

    TriggerClientEvent('UpdWalkSpeed', source, speed)
end)