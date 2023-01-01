local animalHashList = {}
local isPlayerAnimal = false
local pedMaxHealth = 200
local pedRunOnce = false
local walkSpeed = GetResourceKvpFloat('AnythingAnimal_Speed_Float')
local canRequest = true
local adjustDirection = "both"

for _, v in ipairs(AnimalPed) do
    table.insert(animalHashList, GetHashKey(v))
end
listToNil(AnimalPed)

-- Is Player Animal
CreateThread(function()
    while true do
        Wait(1000)

        local ped = PlayerPedId()
        local PlayerPedHash = GetEntityModel(ped)
        local tempAnimalStatus = false

        for _, ListedPedHash in ipairs(animalHashList) do
            if ListedPedHash == PlayerPedHash then
                tempAnimalStatus = true
                break
            end
        end
        isPlayerAnimal = tempAnimalStatus
        if isPlayerAnimal then
            local player = PlayerId()
            SetPlayerLockonRangeOverride(player, 50.0)
            SetPedCombatRange(ped, 2)
            ResetPlayerStamina(player)
        end
    end
end)

-- Health Fixes
CreateThread(function()
    while Config.UseHealthRegen do
        Wait(Config.HealthPointsTimer)
        if isPlayerAnimal then
            local ped = PlayerPedId()
            local pedCurrentHealth = GetEntityHealth(ped)
            if pedCurrentHealth < pedMaxHealth and not IsEntityDead(ped) then
                local tempHealth = pedCurrentHealth + Config.HealthPointsRegenerated
                if tempHealth > pedMaxHealth then
                    tempHealth = pedMaxHealth
                end
                SetEntityHealth(ped, tempHealth)
            end
        end
    end
end)

-- Idlecam
CreateThread(function()
    while Config.DisableIdleCamera do
        Wait(10000)
        if isPlayerAnimal then
            InvalidateIdleCam()
            InvalidateVehicleIdleCam()
        end
    end
end)


CreateThread(function()
    if not walkSpeed then
        walkSpeed = 1.0
    end
    while true do
        -- Land and Water fixes
        if isPlayerAnimal then
            local ped = PlayerPedId()
            local player = PlayerId()
            local xyz = GetEntityCoords(ped)

            SetPedDiesInWater(ped, false) -- Disable animal dies in water instantly

            if IsEntityInWater(ped) == 1 then -- If In Water
                if not pedRunOnce then
                    --SetPlayerSprint(player, false)
                    SetPedCanRagdoll(ped, false) -- Disable ragdoll of animals in water
                    SetSwimMultiplierForPlayer(player, Config.SpeedMultiplierWater)
                    ForcePedMotionState(ped, -1855028596, 0, 0, 0)
                    pedRunOnce = true
                end
            else
                if pedRunOnce then
                    --SetPlayerSprint(player, true)
                    SetPedCanRagdoll(ped, true) -- Enable ragdoll again
                    SetRunSprintMultiplierForPlayer(player, Config.SpeedMultiplierLand) -- Make animals normal speed in water
                    --ClearPedTasks(ped)
                    pedRunOnce = false
                end
            end
            -- MLO and underground run speed fix
            if not IsCollisionMarkedOutside(xyz) and IsControlPressed(0, 21) then
                SetPedMoveRateOverride(ped, Config.MloRunSpeed)
            end
            -- Use / adjust general walk speed
            if IsPedWalking(ped) and IsPedOnFoot(ped) and (IsControlPressed(0, 32) or IsControlPressed(0, 33) or IsControlPressed(0, 34) or IsControlPressed(0, 35)) then
                SetPedMoveRateOverride(ped, walkSpeed)
                if IsControlPressed(0, 96) then
                    if canRequest and adjustDirection ~= "NotMax" and walkSpeed <= Config.WalkSpeedMax then
                        canRequest = false
                        walkSpeed += 0.01
                        TriggerServerEvent('VerifyEmoteSpeed', walkSpeed, isPlayerAnimal)
                    end
                elseif IsControlPressed(0, 97) then
                    if canRequest and adjustDirection ~= "NotMin" and walkSpeed >= Config.WalkSpeedMin then
                        canRequest = false
                        walkSpeed -= 0.01
                        TriggerServerEvent('VerifyEmoteSpeed', walkSpeed, isPlayerAnimal)
                    end
                end
            end
            Wait(0)
        else
            Wait(5000)
        end
    end
end)

-- Add Chat command
RegisterCommand('aaws', function(source, args, raw)
    TriggerServerEvent('VerifyEmoteSpeed', tonumber(args[1]), isPlayerAnimal)
end, false)

TriggerEvent("chat:addSuggestion", "/aaws", "Set walk speed " .. Config.WalkSpeedMin .. " to " .. Config.WalkSpeedMax)


-- CB from server
RegisterNetEvent('UpdWalkSpeed', function(speed, adjDir, allowReq)
    walkSpeed = speed
    adjustDirection = adjDir
    SetResourceKvpFloat("AnythingAnimal_Speed_Float", walkSpeed)
    canRequest = allowReq
end)

-- DEBUG COMMAND
RegisterCommand('aadebug', function(source, args, raw)
    local player = PlayerId()
    local ped = PlayerPedId()
    local xyz = GetEntityCoords(ped)
    print(isPlayerAnimal)
    print(IsCollisionMarkedOutside(xyz))
    print(GetPedMovementClipset(ped))
    print(GetEntityLodDist(ped))
    print(HasCollisionLoadedAroundEntity())
    print(IsPedOnFoot(ped))
    print(IsPedUsingAnyScenario(ped))
    print(GetWaterHeight(xyz.x,xyz.y,xyz.z,args[1]))
    print(GetWaterHeightNoWaves(xyz.x,xyz.y,xyz.z,args[1]))
    print("-------------------------")
end, false)

exports('getIsPlayerAnimal', function() return isPlayerAnimal end)
-- DEBUG: print(exports['AnythingAnimal']:getIsPlayerAnimal())