RegisterNetEvent('VerifyEmoteSpeed', function(speed, isAnimal)
    if not isAnimal then return end
    local ped = GetPlayerPed(source)

    speed = tonumber(speed)

    if speed > 1.75 then
        speed = 1.75
    elseif speed < 0.0 then
        speed = 0.0
    end
    print(source)
    print(speed)
    TriggerClientEvent('updatewalkspeed', ped, speed)
end)