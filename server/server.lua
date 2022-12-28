RegisterNetEvent('VerifyEmoteSpeed', function(speed, isAnimal)
    if not isAnimal then return end
    speed = tonumber(speed)

    if speed > 1.75 then
        speed = 1.75
    elseif speed < 0.0 then
        speed = 0.0
    end
    print(source)
    print(speed)
    TriggerClientEvent('updatewalkspeed', source, speed)
end)

RegisterNetEvent('aaping', function(args)
    print("ping" .. args[1])
    TriggerClientEvent('aapong', source)
end)