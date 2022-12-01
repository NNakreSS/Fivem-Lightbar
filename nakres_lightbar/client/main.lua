Vec = vector3
SirenCar, Veh, MainVehiclePlate = 0, 0, ""
Xrot, Yrot, Zrot = 0.0, 0.0, 0.0
XCoord, YCoord, ZCoord = 0, 0, 0
LightbarVehicles, CurrentVehicleLightBars, ToggleLightbarAudio, Identifiers, VehiclesSoundId = {}, {}, {}, {}, {}
_Tse, _Rne, _On = TriggerServerEvent, RegisterNetEvent, AddEventHandler
local SelectLightBar

_Rne('nakres_lightbar:client:getVehicleData')
_Rne('nakres_lightbar:client:toggleLightbars')
_Rne('nakres_lightbar:client:toggleLightbarAudio')
_Rne('nakres_lightbar:client:TogglesirenHorn')
_Rne('nakres_lightbar:client:getIdentifier')
_Rne('nakres_lightbar:client:addPermission')
_Rne('nakres_lightbar:client:getSirenData')
_Rne('nakres_lightbar:client:spawnLightbarVeh')

_On('nakres_lightbar:client:getVehicleData', function(data)
    LightbarVehicles = data
end)

_On('nakres_lightbar:client:spawnLightbarVeh', function(veh, model, isloads, cdata, pdata)
    spawnLightbarVeh(veh, model, isloads, cdata, pdata)
end)

_On('nakres_lightbar:client:getIdentifier', function(data, perms)
    Identifiers = data
    PermData = perms
end)

_On('nakres_lightbar:client:toggleLightbars', function(veh, plate, bool)
    if ToggleLightbarAudio[plate] ~= nil then
        ToggleLightbarAudio[plate].lightbar = bool
    end
    setSirenStatus(veh, plate, bool)
end)

_On('nakres_lightbar:client:toggleLightbarAudio', function(vehicle, plate, bool, sirenTon)
    if ToggleLightbarAudio[plate] ~= nil then
        ToggleLightbarAudio[plate].siren = bool
        ToggleLightbarAudio[plate].sirenTon = sirenTon
    end
    setSirenAudioStatus(vehicle, plate, bool)
end)

_On('nakres_lightbar:client:TogglesirenHorn', function(vehicle, bool)
    setSirenHorn(vehicle, bool)
end)

_On('nakres_lightbar:client:addPermission', function(data)
    PermData = data
end)

_On('nakres_lightbar:client:getSirenData', function(data)
    ToggleLightbarAudio = data
end)


RegisterNUICallback("addLightbar", function(data, cb)
    local lModel = data.modelName
    createLightbarCar(lModel)
end)

RegisterNUICallback("selectLightbar", function(data, cb)
    SelectLightBar = NetToVeh(tonumber(data.lightbar))
    Coord, Rotation = Vec(0, 0, 0), Vec(0.0, 0.0, 0.0)
    for key, value in pairs(CurrentVehicleLightBars) do
        if NetToVeh(value.lbEntity) == SelectLightBar then
            local coord = (value.coordData.coord)
            local rotation = (value.coordData.rotation)
            Xrot, Yrot, Zrot = rotation.x, rotation.y, rotation.z
            XCoord, YCoord, ZCoord = coord.x, coord.y, coord.z
            break
        end
    end
end)

RegisterNUICallback("clickButton", function(data, cb)
    local typ = data.typ
    local speed = data.speed
    local dt = data.dt
    if speed ~= nil then
        moveLightbar(SelectLightBar, speed, typ, dt)
    elseif typ == "save" then
        saveNewLightbars()
        displayNui(false)
    elseif typ == "cancel" then
        deleteNewLightbars()
        displayNui(false)
    elseif typ == "delete" then
        deleteLightbar(data.lightbarId)
    end
end)

Citizen.CreateThread(function()
    local jsonData = json.decode(LoadResourceFile(ResourceName, jsonPath))
    if jsonData ~= nil then
        print(('^1[nakres] ^0 json data loaded.'))
        LightbarVehicles = jsonData
    end
    _Tse("nakres_lightbar:server:getIdentifier")
    _Tse("nakres_lightbar:server:getSirenData")
    while true do
        for plate, value in pairs(LightbarVehicles) do
            if ToggleLightbarAudio[plate] == nil then ToggleLightbarAudio[plate] = {} end
            if ToggleLightbarAudio[plate].siren and ToggleLightbarAudio[plate].lightbar then
                if NetworkDoesNetworkIdExist(value[1].vehicle) then
                    local vehicle = NetToVeh(value[1].vehicle)
                    local pl = GetVehicleNumberPlateText(vehicle)
                    if plate == pl then
                        if (HasSoundFinished(VehiclesSoundId[plate]) or VehiclesSoundId[plate] == nil) and
                            DoesEntityExist(vehicle) then
                            if VehiclesSoundId[plate] == nil then VehiclesSoundId[plate] = GetSoundId() end
                            if ToggleLightbarAudio[plate].sirenTon == nil then ToggleLightbarAudio[plate].sirenTon = "VEHICLES_HORNS_SIREN_1" end
                            PlaySoundFromEntity(VehiclesSoundId[plate], ToggleLightbarAudio[plate].sirenTon,
                                vehicle, 0, 0, 0)
                        elseif IsEntityDead(vehicle) or not IsVehicleSirenOn(NetToVeh(value[1].lbEntity)) then
                            ToggleLightbarAudio[plate].siren = false
                            ToggleLightbarAudio[plate].lightbar = false
                            setSirenAudioStatus(vehicle, plate, false)
                        end
                    end
                end
            end
        end
        Citizen.Wait(500)
    end
end)
