RegisterKeyMapping("nakres_lightbar:toggleLightbars","On/Of vehicle lightbar","KEYBOARD","LCONTROL")
RegisterKeyMapping("nakres_lightbar:toggleLightbarAudio","On/Of vehicle siren Audio","KEYBOARD","H")
RegisterKeyMapping("nakres_lightbar:changeLightbarAudio","Change vehicle siren Audio","KEYBOARD","LMENU")
RegisterKeyMapping('+nakres_lightbar:sirenHorn', 'turn on Siren Horn', 'keyboard', 'E')

RegisterCommand("nakres_lightbar:toggleLightbars", function() toggleLightbars() end)
RegisterCommand("nakres_lightbar:toggleLightbarAudio", function() toggleLightbarAudio() end)
RegisterCommand("nakres_lightbar:changeLightbarAudio", function() changeLightbarAudio() end)
RegisterCommand('+nakres_lightbar:sirenHorn', function() toggleSirenHorn(true) end)
RegisterCommand('-nakres_lightbar:sirenHorn', function() toggleSirenHorn(false) end)
RegisterCommand(NakreS.addLightbarCommand, function() searchNearVehicle() end)
RegisterCommand(NakreS.GivepermCommand, function(source, args)
    local tId = tonumber(args[1])
    local admin = tonumber(args[2])
    local isAdmin = isPermission("admin")
    while isAdmin == nil do Citizen.Wait(0) end
    if isAdmin then
        _Tse("nakres_lightbar:server:addUserPermission",tId,admin)
    end
end)