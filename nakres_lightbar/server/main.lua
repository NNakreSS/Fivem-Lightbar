local vehiclesLightbars = {}
local _Rse = RegisterServerEvent
local _on = AddEventHandler
local _Tce = TriggerClientEvent
local toggleLightbarAudio = {}
local identifiersId = {}

_Rse("nakres_lighbar:server:attackLightbar")
_Rse("nakres_lighbar:server:loadLightbars")
_Rse("nakres_lighbar:server:getVehicleData")
_Rse("nakres_lightbar:server:toggleLightbars")
_Rse("nakres_lightbar:server:toggleLightbarAudio")
_Rse("nakres_lightbar:server:TogglesirenHorn")
_Rse("nakres_lightbar:server:getIdentifier")
_Rse("nakres_lightbar:server:getSirenData")
_Rse("nakres_lightbar:server:addUserPermission")
_Rse("nakres_lightbar:server:spawnLightbarVeh")

_on("nakres_lightbar:server:spawnLightbarVeh", function(model,coord,heading,bool,cdata,pdata)
    local src = source
    local vehicle = CreateVehicle(model, coord, heading, true, true)
    while not DoesEntityExist(vehicle) do Citizen.Wait(0) end
    while NetworkGetEntityOwner(vehicle) ~= src do Citizen.Wait(0) end
    _Tce("nakres_lightbar:client:spawnLightbarVeh", src, NetworkGetNetworkIdFromEntity(vehicle) , model,bool,cdata,pdata)
end)

_on("nakres_lighbar:server:attackLightbar", function(mainCarPlate, lightbarData)
    local jsonData = json.decode(LoadResourceFile(ResourceName, jsonPath))
    if vehiclesLightbars[mainCarPlate] == nil then vehiclesLightbars[mainCarPlate] = {} end
    vehiclesLightbars[mainCarPlate] = lightbarData
    jsonData = vehiclesLightbars
    _Tce("nakres_lightbar:client:getVehicleData", -1, jsonData)
    SaveResourceFile(ResourceName, jsonPath, json.encode(jsonData), -1)
end)

_on("nakres_lightbar:server:toggleLightbars", function(veh, plate)
    if toggleLightbarAudio[plate] == nil then toggleLightbarAudio[plate] = {} end
    if toggleLightbarAudio[plate].lightbar == nil then toggleLightbarAudio[plate].lightbar = false end
    toggleLightbarAudio[plate].lightbar = not toggleLightbarAudio[plate].lightbar
    _Tce("nakres_lightbar:client:toggleLightbars", -1, veh, plate, toggleLightbarAudio[plate].lightbar)
    if not toggleLightbarAudio[plate].lightbar and toggleLightbarAudio[plate].siren then
        toggleLightbarAudio[plate].siren = false
        _Tce("nakres_lightbar:client:toggleLightbarAudio", -1, veh, plate, false)
    end
end)

_on("nakres_lightbar:server:toggleLightbarAudio", function(vehicle, plate, sirenTon)
    if toggleLightbarAudio[plate] == nil then toggleLightbarAudio[plate] = {} end
    if toggleLightbarAudio[plate].lightbar == nil or toggleLightbarAudio[plate].lightbar == false then return end
    if toggleLightbarAudio[plate].siren == nil then toggleLightbarAudio[plate].siren = false end
    toggleLightbarAudio[plate].siren = not toggleLightbarAudio[plate].siren
    toggleLightbarAudio[plate].sirenTon = sirenTon
    _Tce("nakres_lightbar:client:toggleLightbarAudio", -1, vehicle, plate, toggleLightbarAudio[plate].siren, sirenTon)
end)

_on("nakres_lightbar:server:TogglesirenHorn", function(vehicle, bool)
    _Tce("nakres_lightbar:client:TogglesirenHorn", -1, vehicle, bool)
end)

_on("nakres_lightbar:server:getIdentifier", function()
    local _src = source
    local identifiers = GetPlayerIdentifiers(_src)
    local perms = json.decode(LoadResourceFile(ResourceName, permPath))
    identifiersId[_src] = identifiers
    _Tce("nakres_lightbar:client:getIdentifier", _src, identifiers, perms)
end)

_on("nakres_lightbar:server:addUserPermission", function(id, bool)
    if identifiersId[id] == nil then return end
    local permData = json.decode(LoadResourceFile(ResourceName, permPath))
    local ident = identifiersId[id][1]
    local newPerm = {
        identifier = ident,
        admin = (bool == 1) and true or false
    }
    AddValue(permData, newPerm)
    _Tse("nakres_lightbar:client:addPermission", id, permData)
    SaveResourceFile(ResourceName, permPath, json.encode(permData), -1)
end)

_on("nakres_lightbar:server:getSirenData", function()
    local src = source
    _Tce("nakres_lightbar:client:getSirenData", src, toggleLightbarAudio)
end)

Citizen.CreateThread(function()
    local jsonData = json.decode(LoadResourceFile(ResourceName, jsonPath))
    local permData = json.decode(LoadResourceFile(ResourceName, permPath))
    if jsonData == nil then
        SaveResourceFile(ResourceName, jsonPath, json.encode({}), -1)
        print(('^1[nakres] ^0 json data created.'))
    else
        print(('^1[nakres] ^0 json data loaded.'))
        vehiclesLightbars = jsonData
    end
    if permData == nil then
        SaveResourceFile(ResourceName, permPath, json.encode({}), -1)
        print(('^1[nakres] ^0 permission data created.'))
    end
    local findIndex = {}
    permData = json.decode(LoadResourceFile(ResourceName, permPath))
    for key, value in pairs(permData) do
        for index, hex in ipairs(NakreS.adminIdentities) do
            if value.identifier == hex then
                AddValue(findIndex, index)
            end
        end
    end
    for ix, val in ipairs(NakreS.adminIdentities) do
        if #findIndex > 0 then
            for i, v in ipairs(findIndex) do
                if not ix == v then
                    local newPerm = {
                        identifier = val,
                        admin = true
                    }
                    AddValue(permData, newPerm)
                end
            end
        else
            local newPerm = {
                identifier = val,
                admin = true
            }
            AddValue(permData, newPerm)
        end
    end
    SaveResourceFile(ResourceName, permPath, json.encode(permData), -1)
end)
