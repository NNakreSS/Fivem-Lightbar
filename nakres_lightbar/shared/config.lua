jsonPath = ("/shared/data.json")
permPath = ("/shared/permission.json")
ResourceName = GetCurrentResourceName()
AddValue = table.insert

NakreS = {
    useSirenHorn = true, --set true if you want a lightbar to have a police horn when a vehicle is added
    GivepermCommand = "add_lightbar_perm", --[[If NoNeedPerm false, 
    those with admin authority can use this command to authorize players , bkz: /add_lightbar_perm id bool ,
    if the bool part is entered as 1, it recognizes the user as admin so that lightbar can authorize it (applicable only to this script)]]
    addLightbarCommand = "addlb", -- command to start the lightbar installation
    adminIdentities = { "fivem:1221**1", "discord:68866******9699" }, --admin fivem id, discrod id or lisans id
    NoNeedPerm = false, -- if set true, all players can add lightbar,
    BlacklistVehicle = {"drafter","adder"}-- vehicle name for blacklisted vehicle  , built-in police tools are automatically in blacklist , example:"police"
}
