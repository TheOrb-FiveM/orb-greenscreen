fx_version 'cerulean'
game 'gta5'

author 'Bentix (original) / TheOrb Scripts (fork)'
description 'orb-greenscreen — companion tool for orb_clothing. Based on Bentix fivem-greenscreener (GPL-3.0). See LICENSE and CHANGES.md.'
version '1.0.2'

this_is_a_map 'yes'

ui_page 'html/index.html'


files {
    'config.json',
    'html/*',
    'images/**/*.png',
}

client_scripts {
    '@ox_lib/init.lua',
    'capture_bridge.lua',
    'client.js',
    'menu.lua',
}

server_script 'server.js'

dependencies {
	'screencapture',
    'yarn',
    'ox_lib'
}
