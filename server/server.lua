RegisterNetEvent("VerifyEmoteSpeed", function(speed, isAnimal)
    if not isAnimal then return end
    local ped = GetPlayerPed(source)

    if speed > 1.75 then
        speed = 1.75
    elseif speed < 0.0 then
        speed = 0.0
    end

    TriggerClientEvent("updatewalkspeed", ped, speed)
end)

RegisterCommand('setwalkspeed', function(source, args, rawCommand)
    print(source)
    print(args)
    print(rawCommand)
    if source > 0 then
        --TriggerEvent('VerifyEmoteSpeed', args[1], isPlayerAnimal)
    end
end, false)