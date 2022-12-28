RegisterNetEvent('VerifyEmoteSpeed', function(speed, isAnimal)
    if not isAnimal then return end
    
    if speed > 1.75 then
        speed = 1.75
    elseif speed < 0.0 then
        speed = 0.0
    end

    TriggerClientEvent('UpdWalkSpeed', source, speed)
end)

--[[ RegisterNetEvent('aaping', function(args)
    print("ping" .. args[1])
    TriggerClientEvent('aapong', source)
end) ]]