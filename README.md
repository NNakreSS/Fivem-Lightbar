# Fivem-Lightbar
Add lightbar to tools, manage them, manage lights and sounds

start by adding two files named lightbar and nakres_lightbar to the server.

By adding your steam, discord, or fivem id to admin via Cofig, you can authorize players to "add_lightbar_perm id number" in the game, if you leave the bool blank, you can only access the lightbar menu by typing 1 instead of number, authorizing the player to use the "add_lightbar_perm" command.
    bkz: adminIdentities = { "fivem:1082143", "discord:668001028939055124" }, --admin fivem id, discrod id or lisans id

After you have been authorized to add lightbar to the vehicle, use /addlb, go to the vehicle and press E to access the menu.

Left CONTROL to turn on the siren lights, use the H key to turn on the sounds and the Left ALT key to change the tone, and you can change the keys from the game to the keybinds settings

**Features**

1.You can use the built-in authorization system to access the menu or disable the authorization system via config
2.You can add lightbar to any tool, set or remove locations at any time
3.exports.nakres_lightbar:loadLightbarInCar(vehicle); you can add the code to the vehicle spawned function of your garage script to reproduce the created lightbars
4.Fully optimized 0.0 to 0.1 resmons
