fx_version 'cerulean'
game 'gta5'

name "nakres_lightbar"
description "Add vehicle ligtbar and siren"
author "NakreS"
version "0.0.1"

shared_scripts {
	'shared/*.lua'
}

client_scripts {
	'client/*.lua'
}

server_scripts {
	'server/*.lua'
}

ui_page 'UI/index.html'

files{
	"UI/*.css",
	"UI/*.html",
	"UI/*.js",
	"UI/**.ttf",
	"shared/*.json"
}

exports {
	'loadLightbarInCar',
	--exports.nakres_lightbar:loadLightbarInCar(vehicle);
}