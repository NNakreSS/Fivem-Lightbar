local sirenTon, cam, activeSirenAudio = "VEHICLES_HORNS_SIREN_1", nil, nil
local newLightbars, sirenHornAudio, currentVehicle, attachedPropPerm = {}, {}, 0, 0
local camCoord, camx, camy, camz, pcamx, pcamy, pcamz
PermData = {}
function createLightbarCar(modelName)
    Xrot, Yrot, Zrot = 0.0, 0.0, 0.0
    XCoord, YCoord, ZCoord = 0, 0, 0
    if currentVehicle == 0 then return print("[nakres_lightbar] ~~ VEHİCLE NİL ~~") end
    local ped = PlayerPedId()
    local model, coord, heading = modelName, GetEntityCoords(currentVehicle), -GetEntityHeading(ped)
    loadModel(model)
    _Tse("nakres_lightbar:server:spawnLightbarVeh", model, Vec(0.0,0.0,0.0), heading,false,nil)
end

function spawnLightbarVeh(veh, model, load,data,pt)
    if data == nil then data = {} end
    local coord = data.coords or Vec(0,0,0)
    local rot = data.rotation  or Vec(0,0,0)
    local lightbar = NetToVeh(veh)
    SetEntityCollision(lightbar, false, false)
    SetVehicleDoorsLocked(lightbar, 2)
    SetEntityAsMissionEntity(lightbar, true, true)
    if not load then
        AttachEntityToEntity(lightbar, currentVehicle, 0, coord,rot, true, true, false, false, 3, true)
        local vehicleIdentity = getNewIdendity()
        local newLightbarData = { model = model,
        coordData = { coord = Vec(XCoord, YCoord, ZCoord), rotation = Vec(Xrot, Yrot, Zrot) },
        lbEntity = VehToNet(lightbar), vehIdentity = vehicleIdentity, vehicle = VehToNet(currentVehicle) }
        AddValue(CurrentVehicleLightBars, newLightbarData)
        AddValue(newLightbars, newLightbarData)
        displayNui(true)
    else
        AttachEntityToEntity(lightbar, pt.vehicle, 0, coord,rot, true, true, false, false, 3, true)
        LightbarVehicles[pt.plate][pt.key].lbEntity = VehToNet(lightbar)
        LightbarVehicles[pt.plate][pt.key].vehicle = VehToNet(pt.vehicle)
        _Tse("nakres_lighbar:server:attackLightbar", pt.plate, LightbarVehicles[pt.plate])
    end
end

function saveNewLightbars()
    newLightbars = {}
    _Tse("nakres_lighbar:server:attackLightbar", MainVehiclePlate, CurrentVehicleLightBars)
end

function deleteNewLightbars()
    if #newLightbars > 0 then
        for index, value in ipairs(CurrentVehicleLightBars) do
            for _index, _value in ipairs(newLightbars) do
                if value.vehIdentity == _value.vehIdentity then
                    local entity = NetToVeh(_value.lbEntity)
                    DetachEntity(entity, false, false)
                    DeleteVehicle(entity)
                    DeleteEntity(entity)
                    table.remove(CurrentVehicleLightBars, index)
                end
            end
        end
        newLightbars = {}
        CurrentVehicleLightBars = {}
    end
end

function deleteLightbar(identity)
    for key, currenVeh in pairs(CurrentVehicleLightBars) do
        if currenVeh.vehIdentity == identity then
            local entity = NetToVeh(currenVeh.lbEntity)
            DetachEntity(entity, false, false)
            DeleteVehicle(entity)
            DeleteEntity(entity)
            table.remove(CurrentVehicleLightBars, key)
            _Tse("nakres_lighbar:server:attackLightbar", MainVehiclePlate, CurrentVehicleLightBars)
            for _index, _value in ipairs(newLightbars) do
                if identity == _value.vehIdentity then
                    table.remove(newLightbars, _index)
                end
            end
            break
        end
    end
    if #CurrentVehicleLightBars == 0 then
        if ToggleLightbarAudio[MainVehiclePlate] ~= nil and ToggleLightbarAudio[MainVehiclePlate].lightbar then
            toggleLightbars(currentVehicle)
        end
        ToggleLightbarAudio[MainVehiclePlate] = nil
        LightbarVehicles[MainVehiclePlate] = nil
        SetHornEnabled(currentVehicle, true)
    end
    displayNui(true)
end

function loadLightbarInCar(vehicle)
    local plate = GetVehicleNumberPlateText(vehicle)
    local lightbars = LightbarVehicles[plate]
    if lightbars == nil then return end
    for key, value in ipairs(lightbars) do
        local model = value.model
        local coord = (value.coordData.coord)
        local rotation = (value.coordData.rotation)
        coord = Vec(coord.x, coord.y, coord.z)
        rotation = Vec(rotation.x, rotation.y, rotation.z)
        local coords = {coords = coord, rotation = rotation}
        local pc = {plate = plate , key = key,vehicle = vehicle}
        loadModel(model)
        _Tse("nakres_lightbar:server:spawnLightbarVeh", model, GetEntityCoords(vehicle), GetEntityHeading(vehicle),true,coords,pc)
    end
end

function searchNearVehicle()
    if not isPermission("user") and not NakreS.NoNeedPerm then return end
    Citizen.CreateThread(function()
        local player = PlayerPedId()
        createprop("prop_cs_cardbox_01", 28422, 0.01, 0.01, 0.0, -255.0, -120.0, 40.0)
        PropCarryAnim()
        while true do
            local sleep = 1000
            local pCoord = GetEntityCoords(player)
            local nearveh = GetClosestVehicle(pCoord, 2.5, 0, 70)
            local vCoords, plate = GetEntityCoords(nearveh), GetVehicleNumberPlateText(nearveh)
            local class = GetVehicleClass(nearveh)
            local isVehicle = (class ~= 8 and class ~= 13) and true or false
            local vehicleName = GetDisplayNameFromVehicleModel(GetEntityModel(nearveh))
            local blackListVeh = controlBlackList(vehicleName)
            if nearveh ~= 0 and isVehicle and not blackListVeh then
                sleep = 5
                ShowFloatingHelpNotificationsc("[E] Lightbars Menu", vCoords, plate)
                if IsControlJustReleased(1, 51) then
                    getNearVehicleLightbars(plate)
                    openLightbarMenu(nearveh)
                    currentVehicle = nearveh
                    toggleCam()
                    break
                end
                if IsControlJustReleased(1, 73) then
                    removeAttachedPropPerm()
                    break
                end
            end
            Citizen.Wait(sleep)
        end
    end)
end

function controlBlackList(vehName)
    for index, name in ipairs(NakreS.BlacklistVehicle) do
        if vehName == name then
            return true    
        end
    end
    return false
end

function getNearVehicleLightbars(plate)
    if LightbarVehicles[plate] ~= nil then
        CurrentVehicleLightBars = LightbarVehicles[plate]
    end
end

function moveLightbar(selectLb, sepeed, typ, dt)
    if dt ~= "move-cam" then
        DetachEntity(selectLb, true, false)
        if typ == "left" then
            YCoord = YCoord + sepeed
        elseif typ == "right" then
            YCoord = YCoord - sepeed
        elseif typ == "forward" then
            XCoord = XCoord + sepeed
        elseif typ == "backward" then
            XCoord = XCoord - sepeed
        elseif typ == "up" then
            ZCoord = ZCoord + sepeed
        elseif typ == "down" then
            ZCoord = ZCoord - sepeed
        elseif typ == "+Xrot" then
            Xrot = Xrot + sepeed * 10
        elseif typ == "+Yrot" then
            Yrot = Yrot + sepeed * 10
        elseif typ == "-Xrot" then
            Xrot = Xrot - sepeed * 10
        elseif typ == "-Yrot" then
            Yrot = Yrot - sepeed * 10
        elseif typ == "+Zrot" then
            Zrot = Zrot + sepeed * 10
        elseif typ == "-Zrot" then
            Zrot = Zrot - sepeed * 10
        end
        AttachEntityToEntity(selectLb, currentVehicle, 0, XCoord, YCoord, ZCoord, Xrot, Yrot, Zrot, true, true, false,
            false, 3, true)
        for index, value in pairs(CurrentVehicleLightBars) do
            if NetToVeh(value.lbEntity) == selectLb then
                value.coordData.rotation = Vec(Xrot, Yrot, Zrot)
                value.coordData.coord = Vec(XCoord, YCoord, ZCoord)
            end
        end
    else
        moveCam(sepeed, typ)
    end
end

function moveCam(sepeed, typ)
    sepeed = sepeed * 10
    if typ == "left" then
        camy = camy + sepeed
    elseif typ == "right" then
        camy = camy - sepeed
    elseif typ == "forward" then
        camx = camx + sepeed
    elseif typ == "backward" then
        camx = camx - sepeed
    elseif typ == "up" then
        camz = camz + sepeed
    elseif typ == "down" then
        camz = camz - sepeed
    elseif typ == "pleft" then
        pcamx = pcamx + sepeed
        PointCamAtCoord(cam, GetOffsetFromEntityInWorldCoords(currentVehicle, Vec(pcamx, pcamy, pcamz)))
    elseif typ == "pright" then
        pcamx = pcamx - sepeed
        PointCamAtCoord(cam, GetOffsetFromEntityInWorldCoords(currentVehicle, Vec(pcamx, pcamy, pcamz)))
    elseif typ == "pup" then
        pcamz = pcamz + sepeed
        PointCamAtCoord(cam, GetOffsetFromEntityInWorldCoords(currentVehicle, Vec(pcamx, pcamy, pcamz)))
    elseif typ == "pdown" then
        pcamz = pcamz - sepeed
        PointCamAtCoord(cam, GetOffsetFromEntityInWorldCoords(currentVehicle, Vec(pcamx, pcamy, pcamz)))
    end
    SetCamCoord(cam, camx, camy, camz)
end

function openLightbarMenu(nearveh)
    displayNui(true)
    MainVehiclePlate = GetVehicleNumberPlateText(nearveh)
end

function displayNui(bool)
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        typ = "UI",
        status = bool,
        lbData = bool and CurrentVehicleLightBars or nil,
    })
    if not bool then
        MainVehiclePlate, CurrentVehicleLightBars , currentVehicle = "", {} , 0
        removeAttachedPropPerm()
        toggleCam()
    end
end

function toggleLightbars(veh)
    local player = PlayerPedId()
    local sirenCar = GetVehiclePedIsIn(player, false)
    local isDriver = (GetPedInVehicleSeat(sirenCar, -1) == player) and true or false
    if veh ~= nil then isDriver = true
        sirenCar = veh
    end
    if not isDriver then return end
    local plate = GetVehicleNumberPlateText(sirenCar)
    local isLightbarCar = (LightbarVehicles[plate] ~= nil and #LightbarVehicles[plate] > 0) and true or false
    if ToggleLightbarAudio[plate] == nil then ToggleLightbarAudio[plate] = {} end
    if isDriver and isLightbarCar or veh ~= nil then
        _Tse("nakres_lightbar:server:toggleLightbars", VehToNet(sirenCar), plate)
    end
end

function toggleLightbarAudio()
    local player = PlayerPedId()
    local sirenCar = GetVehiclePedIsIn(player, false)
    local isDriver = (GetPedInVehicleSeat(sirenCar, -1) == player) and true or false
    if not isDriver then return end
    local plate = GetVehicleNumberPlateText(sirenCar)
    local isLightbarCar = (LightbarVehicles[plate] ~= nil and #LightbarVehicles[plate] > 0) and true or false
    if ToggleLightbarAudio[plate] == nil then ToggleLightbarAudio[plate] = {} end
    local lightStatus = ToggleLightbarAudio[plate].lightbar or false
    if isDriver and isLightbarCar then
        if not lightStatus then
            toggleLightbars()
        end
        _Tse("nakres_lightbar:server:toggleLightbarAudio", VehToNet(sirenCar), plate, sirenTon)
    end
end

function changeLightbarAudio()
    local player = PlayerPedId()
    local sirenCar = GetVehiclePedIsIn(player, false)
    local isDriver = (GetPedInVehicleSeat(sirenCar, -1) == player) and true or false
    if not isDriver then return end
    local plate = GetVehicleNumberPlateText(sirenCar)
    local isLightbarCar = (LightbarVehicles[plate] ~= nil and #LightbarVehicles[plate] > 0) and true or false
    if ToggleLightbarAudio[plate] == nil then ToggleLightbarAudio[plate] = {} end
    local sirenStatus = ToggleLightbarAudio[plate].siren or false
    if not sirenStatus then toggleLightbarAudio() return end
    if isDriver and isLightbarCar and sirenStatus then
        if sirenTon == "VEHICLES_HORNS_SIREN_1" then
            sirenTon = "VEHICLES_HORNS_SIREN_2"
        elseif sirenTon == "VEHICLES_HORNS_SIREN_2" then
            sirenTon = "VEHICLES_HORNS_POLICE_WARNING"
        elseif sirenTon == "VEHICLES_HORNS_POLICE_WARNING" then
            sirenTon = "VEHICLES_HORNS_SIREN_1"
        end
        toggleLightbarAudio()
        toggleLightbarAudio()
    end
end

function toggleSirenHorn(bool)
    if not NakreS.useSirenHorn then return end
    local player = PlayerPedId()
    local sirenCar = GetVehiclePedIsIn(player, false)
    local isDriver = (GetPedInVehicleSeat(sirenCar, -1) == player) and true or false
    if not isDriver then return end
    local plate = GetVehicleNumberPlateText(sirenCar)
    local isLightbarCar = (LightbarVehicles[plate] ~= nil and #LightbarVehicles[plate] > 0) and true or false
    if ToggleLightbarAudio[plate] == nil then ToggleLightbarAudio[plate] = {} end
    local sirenStatus = ToggleLightbarAudio[plate].siren or false
    if isDriver and isLightbarCar then
        if bool then
            if sirenStatus then activeSirenAudio = true toggleLightbarAudio() end
            _Tse("nakres_lightbar:server:TogglesirenHorn", VehToNet(sirenCar), bool)
        else
            _Tse("nakres_lightbar:server:TogglesirenHorn", VehToNet(sirenCar), bool)
            if activeSirenAudio then activeSirenAudio = false toggleLightbarAudio() end
        end
    end
end

function setSirenStatus(veh, plate, bool)
    veh = NetToVeh(veh)
    if LightbarVehicles[plate] ~= nil then
        for index, lightbar in ipairs(LightbarVehicles[plate]) do
            local sirenCar = lightbar.lbEntity
            sirenCar = NetToVeh(sirenCar)
            SetVehicleSiren(sirenCar, bool)
        end
    end
end

function setSirenAudioStatus(vehicle, plate, bool)
    vehicle = NetToVeh(vehicle)
    if bool then
        if VehiclesSoundId[plate] ~= nil then return end
        VehiclesSoundId[plate] = GetSoundId()
        if ToggleLightbarAudio[plate] == nil then ToggleLightbarAudio[plate] = {} end
        if ToggleLightbarAudio[plate].sirenTon == nil then ToggleLightbarAudio[plate].sirenTon = "VEHICLES_HORNS_SIREN_1" end
        PlaySoundFromEntity(VehiclesSoundId[plate], ToggleLightbarAudio[plate].sirenTon, vehicle, 0, 0, 0)
    elseif VehiclesSoundId[plate] ~= nil then
        StopSound(VehiclesSoundId[plate])
        ReleaseSoundId(VehiclesSoundId[plate])
        VehiclesSoundId[plate] = nil
    end
end

function setSirenHorn(vehicle, bool)
    vehicle = NetToVeh(vehicle)
    SetHornEnabled(vehicle, false)
    local plate = GetVehicleNumberPlateText(vehicle)
    if bool then
        sirenHornAudio[plate] = GetSoundId()
        PlaySoundFromEntity(sirenHornAudio[plate], "SIRENS_AIRHORN", vehicle, 0, 0, 0)
    else
        StopSound(sirenHornAudio[plate])
        ReleaseSoundId(sirenHornAudio[plate])
        sirenHornAudio[plate] = nil
    end
end

function isPermission(perm)
    if PermData ~= nil then
        for i, player in ipairs(PermData) do
            for key, identity in pairs(Identifiers) do
                if player.identifier == identity then
                    local bool = ((perm == "admin" and player.admin == true) or perm == "user") and true or false
                    return bool
                end
            end
        end
    end
    return false
end

function getNewIdendity()
    local result = ''
    local characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
    local charactersLength = #characters
    for i = 1, 8, 1 do
        local randomNumber = math.floor(math.random(charactersLength))
        result = result .. characters:sub(randomNumber, randomNumber)
    end
    return result
end

function toggleCam()
    if not IsCamActive(cam) then
        FreezeEntityPosition(PlayerPedId(), true)
        cam, CamName = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
        startCam()
    else
        resetCam()
    end
end

function startCam()
    camCoord = nil
    pcamx, pcamy, pcamz = 0.0, 0.0, 0.0
    local entity = currentVehicle
    SetCamActive(cam, true)
    camCoord = (GetOffsetFromEntityInWorldCoords(entity, -1.0, 3.0, 1.0))
    while camCoord == nil do Citizen.Wait(0) end
    camx, camy, camz = table.unpack(camCoord)
    SetCamCoord(cam, camCoord)
    PointCamAtCoord(cam, GetOffsetFromEntityInWorldCoords(entity, Vec(pcamx, pcamy, pcamz)))
    RenderScriptCams(1, 1, 1500, 0, 0)
end

function resetCam()
    SetCamActive(cam, false)
    DestroyCam(cam, true)
    RenderScriptCams(false, false, 1, true, true)
    FreezeEntityPosition(PlayerPedId(), false)
end

function createprop(attachModelSent, boneNumberSent, x, y, z, xR, yR, zR)
    removeAttachedPropPerm()
    local attachModel = GetHashKey(attachModelSent)
    SetCurrentPedWeapon(PlayerPedId(), 0xA2719263)
    local bone = GetPedBoneIndex(PlayerPedId(), boneNumberSent)
    loadModel(attachModel)
    attachedPropPerm = CreateObject(attachModel, 1.0, 1.0, 1.0, 1, 1, 0)
    AttachEntityToEntity(attachedPropPerm, PlayerPedId(), bone, x, y, z, xR, yR, zR, 1, 1, 0, 0, 2, 1)
end

function removeAttachedPropPerm()
    if DoesEntityExist(attachedPropPerm) then
        DetachEntity(attachedPropPerm, false, false)
        DeleteEntity(attachedPropPerm)
        attachedPropPerm = 0
    end
    ClearPedTasks(PlayerPedId())
end

function PropCarryAnim()
    RequestAnimDict("anim@heists@box_carry@")
    while (not HasAnimDictLoaded("anim@heists@box_carry@")) do
        RequestAnimDict("anim@heists@box_carry@")
        Citizen.Wait(5)
    end
    TaskPlayAnim(PlayerPedId(), "anim@heists@box_carry@", "idle", 4.0, 1.0, -1, 49, 0, 0, 0, 0)
end

function loadModel(model)
    if not HasModelLoaded(model) then
        RequestModel(model)
        while not HasModelLoaded(model) do
            print("~~ WAİTİNG MODEL LOADED ~~")
            Citizen.Wait(1)
        end
    end
end

function ShowFloatingHelpNotificationsc(msg, coords, name)
    AddTextEntry('FloatingHelpNotificationsc' .. name, msg)
    SetFloatingHelpTextWorldPosition(1, coords + Vec(0, 0, 1.0))
    SetFloatingHelpTextStyle(1, 1, 2, -1, 3, 0)
    BeginTextCommandDisplayHelp('FloatingHelpNotificationsc' .. name)
    EndTextCommandDisplayHelp(2, 0, 0, -1)
end
