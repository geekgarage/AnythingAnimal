RegisterNetEvent("VerifyEmoteSpeed", function(speed)
    local ped = GetPlayerPed(source)

    if speed > 1.75 then
        speed = 1.75
    elseif speed < 0.0 then
        speed = 0.0
    end

    TriggerClientEvent("updatewalkspeed", ped, speed)
end)