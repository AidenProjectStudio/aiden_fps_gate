local blocked = false
local currentFps = 0
local violationSince = nil
local okSince = nil

local frozenPed = nil
local frozenVeh = nil
local playerControlDisabled = false

local function round(number)
    return math.floor(number + 0.5)
end

local function drawText(x, y, scale, text, r, g, b, a, center)
    SetTextFont(4)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextCentre(center or false)
    SetTextOutline()
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(x, y)
end

local function freezePlayer(player)
    player = player or PlayerId()

    if not playerControlDisabled then
        SetPlayerControl(player, false, 0)
        playerControlDisabled = true
    end

    local ped = PlayerPedId()
    if not ped or ped == 0 then return end

    frozenPed = ped

    if IsPedInAnyVehicle(ped, false) then
        local veh = GetVehiclePedIsIn(ped, false)

        if veh and veh ~= 0 then
            frozenVeh = veh
            FreezeEntityPosition(veh, true)
            SetVehicleUndriveable(veh, true)
            SetEntityVelocity(veh, 0.0, 0.0, 0.0)
        end
    end

    FreezeEntityPosition(ped, true)
    SetEntityVelocity(ped, 0.0, 0.0, 0.0)
end

local function unfreezePlayer()
    if playerControlDisabled then
        SetPlayerControl(PlayerId(), true, 0)
        playerControlDisabled = false
    end

    if frozenVeh and DoesEntityExist(frozenVeh) then
        FreezeEntityPosition(frozenVeh, false)
        SetVehicleUndriveable(frozenVeh, false)
    end

    if frozenPed and DoesEntityExist(frozenPed) then
        FreezeEntityPosition(frozenPed, false)
    end

    frozenPed = nil
    frozenVeh = nil
end

local function drawBlockedScreen()
    DrawRect(0.5, 0.5, 1.0, 1.0, 0, 0, 0, 190)
    DrawRect(0.5, 0.5, 0.72, 0.30, 15, 15, 15, 235)

    drawText(0.5, 0.38, 0.85, Config.MessageTitle, 255, 60, 60, 255, true)
    drawText(0.5, 0.48, 0.45, Config.MessageSubtitle, 255, 255, 255, 255, true)

    local fpsText = ("FPS actuel : %s / Limite serveur : %s FPS"):format(round(currentFps), Config.MaxFPS)
    drawText(0.5, 0.56, 0.38, fpsText, 255, 220, 80, 255, true)

    drawText(0.5, 0.63, 0.32, "Active la V-Sync ou limite tes FPS dans NVIDIA / AMD / RivaTuner.", 220, 220, 220, 255, true)
end

local function readFpsSample()
    local sampleFrames = Config.SampleFrames or 5
    local acc = 0.0
    local count = 0

    for _ = 1, sampleFrames do
        Wait(0)

        local frameTime = GetFrameTime()
        if frameTime and frameTime > 0.0 then
            local fps = 1.0 / frameTime

            if fps > 0 and fps < 2000 then
                acc = acc + fps
                count = count + 1
            end
        end
    end

    if count > 0 then
        return acc / count
    end

    return currentFps
end

local function checkFpsLimit(now)
    local maxAllowed = Config.MaxFPS + Config.Tolerance

    if currentFps > maxAllowed then
        okSince = nil
        violationSince = violationSince or now

        if not blocked and now - violationSince >= Config.BlockAfterMs then
            blocked = true
        end

        return
    end

    violationSince = nil

    if blocked then
        okSince = okSince or now

        if now - okSince >= Config.UnlockAfterMs then
            blocked = false
            okSince = nil
            unfreezePlayer()
        end
    end
end

CreateThread(function()
    while true do
        currentFps = readFpsSample()
        checkFpsLimit(GetGameTimer())
        Wait(Config.SampleMs)
    end
end)

CreateThread(function()
    local lastFreeze = -1000

    while true do
        if blocked then
            Wait(0)

            local player = PlayerId()
            local now = GetGameTimer()

            DisableAllControlActions(0)
            DisableAllControlActions(1)
            DisableAllControlActions(2)
            DisablePlayerFiring(player, true)

            if not playerControlDisabled or now - lastFreeze >= 250 then
                freezePlayer(player)
                lastFreeze = now
            end

            drawBlockedScreen()
        else
            lastFreeze = -1000
            Wait(500)
        end
    end
end)

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName == GetCurrentResourceName() then
        blocked = false
        unfreezePlayer()
    end
end)
