name "Jim-DJBooth"
author "Jimathy"
version "1.4"
description 'Music player script'
fx_version "cerulean"
game "gta5"
lua54 'yes'

server_script '@oxmysql/lib/MySQL.lua'

shared_scripts {
    'locales/*.lua*',
    'config.lua',

    --Jim Bridge - https://github.com/jimathy/jim-bridge
    '@jim_bridge/starter.lua',

    'shared/*.lua'
}

client_scripts {
    'client.lua',
}

server_script 'server.lua'

dependency 'xsound'
dependency 'jim_bridge'