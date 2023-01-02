local animalHashList = {}
local isPlayerAnimal = false
local pedMaxHealth = 200
local pedRunOnce = false
local walkSpeed = GetResourceKvpFloat('AnythingAnimal_WalkSpeed_Float')
local insideRunSpeed = GetResourceKvpFloat('AnythingAnimal_InsideRunSpeed_Float')
local outsideRunSpeed = GetResourceKvpFloat('AnythingAnimal_OutsideRunSpeed_Float')
local canRequestSpeedWalk = true
local canRequestSpeedInsideRun = true
local canRequestSpeedOutsideRun = true
local adjustDirectionWalk = "Both"
local adjustDirectionInsideRun = "Both"
local adjustDirectionOutsideRun = "Both"
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
        Wait(Config.HealthPointsTimer*1000)
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

-- Main Thread
CreateThread(function()
    if not walkSpeed then
        walkSpeed = Config.WalkSpeedMin
    end
    if not insideRunSpeed then
        insideRunSpeed = Config.InsideRunSpeedMin
    end
    if not outsideRunSpeed then
        outsideRunSpeed = Config.OutsideRunSpeedMin
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
                    print("in water")
                    --SetPlayerSprint(player, false)
                    SetPedCanRagdoll(ped, false) -- Disable ragdoll of animals in water
                    --SetSwimMultiplierForPlayer(player, Config.SwimMultiplier) -- Make animals normal speed in water
                    --dogSwimAnim()
                    pedRunOnce = true
                end
            else
                if pedRunOnce then -- If Not In Water
                    --SetPlayerSprint(player, true)
                    SetPedCanRagdoll(ped, true) -- Enable ragdoll again
                    --SetRunSprintMultiplierForPlayer(player, Config.RunSprintMultiplier) -- Make animals normal speed in water
                    --ClearPedTasks(ped)
                    pedRunOnce = false
                end
                -- If inside (in MLO/underground) and shift (sprint) is pressed
                if not IsCollisionMarkedOutside(xyz) and IsControlPressed(0, 21) then
                    SetPedMoveRateOverride(ped, insideRunSpeed)
                    if IsControlPressed(0, 96) then
                        if canRequestSpeedInsideRun and adjustDirectionInsideRun ~= "NotMax" and insideRunSpeed <= Config.InsideRunSpeedMax then
                            canRequestSpeedInsideRun = false
                            insideRunSpeed += 0.01
                            TriggerServerEvent('VerifyEmoteSpeed', insideRunSpeed, isPlayerAnimal, "inrun")
                        end
                    elseif IsControlPressed(0, 97) then
                        if canRequestSpeedInsideRun and adjustDirectionInsideRun ~= "NotMin" and insideRunSpeed >= Config.InsideRunSpeedMin then
                            canRequestSpeedInsideRun = false
                            insideRunSpeed -= 0.01
                            TriggerServerEvent('VerifyEmoteSpeed', insideRunSpeed, isPlayerAnimal, "inrun")
                        end
                    end
                -- If outside and shift (sprint) is pressed
                elseif IsCollisionMarkedOutside(xyz) and IsControlPressed(0, 21) then
                    SetPedMoveRateOverride(ped, outsideRunSpeed)
                    if IsControlPressed(0, 96) then
                        if canRequestSpeedOutsideRun and adjustDirectionOutsideRun ~= "NotMax" and outsideRunSpeed <= Config.OutsideRunSpeedMax then
                            canRequestSpeedOutsideRun = false
                            outsideRunSpeed += 0.01
                            TriggerServerEvent('VerifyEmoteSpeed', outsideRunSpeed, isPlayerAnimal, "outrun")
                        end
                    elseif IsControlPressed(0, 97) then
                        if canRequestSpeedOutsideRun and adjustDirectionOutsideRun ~= "NotMin" and outsideRunSpeed >= Config.OutsideRunSpeedMin then
                            canRequestSpeedOutsideRun = false
                            outsideRunSpeed -= 0.01
                            TriggerServerEvent('VerifyEmoteSpeed', outsideRunSpeed, isPlayerAnimal, "outrun")
                        end
                    end
                elseif IsPedWalking(ped) and IsPedOnFoot(ped) and (IsControlPressed(0, 32) or IsControlPressed(0, 33) or IsControlPressed(0, 34) or IsControlPressed(0, 35)) then
                    -- Use / adjust general walk speed
                    SetPedMoveRateOverride(ped, walkSpeed)
                    if IsControlPressed(0, 96) then
                        if canRequestSpeedWalk and adjustDirectionWalk ~= "NotMax" and walkSpeed <= Config.WalkSpeedMax then
                            canRequestSpeedWalk = false
                            walkSpeed += 0.01
                            TriggerServerEvent('VerifyEmoteSpeed', walkSpeed, isPlayerAnimal, "walk")
                        end
                    elseif IsControlPressed(0, 97) then
                        if canRequestSpeedWalk and adjustDirectionWalk ~= "NotMin" and walkSpeed >= Config.WalkSpeedMin then
                            canRequestSpeedWalk = false
                            walkSpeed -= 0.01
                            TriggerServerEvent('VerifyEmoteSpeed', walkSpeed, isPlayerAnimal, "walk")
                        end
                    end
                end
            end
            Wait(0)
        else
            Wait(5000)
        end
    end
end)

-- Add Chat commands
RegisterCommand('aaws', function(source, args, raw)
    TriggerServerEvent('VerifyEmoteSpeed', tonumber(args[1]), isPlayerAnimal, "walk")
end, false)
TriggerEvent("chat:addSuggestion", "/aaws", "Set walk speed " .. Config.WalkSpeedMin .. " to " .. Config.WalkSpeedMax)

RegisterCommand('aais', function(source, args, raw)
    TriggerServerEvent('VerifyEmoteSpeed', tonumber(args[1]), isPlayerAnimal, "inrun")
end, false)
TriggerEvent("chat:addSuggestion", "/aais", "Set inside run speed " .. Config.InsideRunSpeedMin .. " to " .. Config.InsideRunSpeedMax)

RegisterCommand('aars', function(source, args, raw)
    TriggerServerEvent('VerifyEmoteSpeed', tonumber(args[1]), isPlayerAnimal, "inrun")
end, false)
TriggerEvent("chat:addSuggestion", "/aars", "Set outside run speed " .. Config.OutsideRunSpeedMin .. " to " .. Config.OutsideRunSpeedMax)

-- CB from server
RegisterNetEvent('UpdMovementSpeed', function(speed, adjDir, typeAdjust, allowReq)
    if typeAdjust == "walk" then
        walkSpeed = speed
        adjustDirectionWalk = adjDir
        SetResourceKvpFloat("AnythingAnimal_WalkSpeed_Float", walkSpeed)
        canRequestSpeedWalk = allowReq
    elseif typeAdjust == "inrun" then
        insideRunSpeed = speed
        adjustDirectionInsideRun = adjDir
        SetResourceKvpFloat("AnythingAnimal_InsideRunSpeed_Float", insideRunSpeed)
        canRequestSpeedInsideRun = allowReq
    elseif typeAdjust == "outrun" then
        outsideRunSpeed = speed
        adjustDirectionOutsideRun = adjDir
        SetResourceKvpFloat("AnythingAnimal_OutsideRunSpeed_Float", outsideRunSpeed)
        canRequestSpeedOutsideRun = allowReq
    end
end)

-- Exports
exports('getIsPlayerAnimal', function() return isPlayerAnimal end)
    -- print(exports['AnythingAnimal']:getIsPlayerAnimal())

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
    print(GetWaterHeight(xyz.x,xyz.y,xyz.z))
    print(GetWaterHeightNoWaves(xyz.x,xyz.y,xyz.z))
    print("-------------------------")
    RenderFakePickupGlow(xyz.x,xyz.y,xyz.z,(args[1] or 0))
end, false)
TriggerEvent("chat:addSuggestion", "/aadebug", "RenderFakePickupGlow [int]")