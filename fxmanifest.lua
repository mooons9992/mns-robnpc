fx_version 'cerulean'
game 'gta5'

author 'Mooons'
description 'NPC Robbery script with target system integration'
version '2.0.0' -- Updated version number to reflect enhancements

shared_scripts {
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua',
    'server/sv_version.lua'  -- Added version check script
}

dependencies {
    'qb-core'
}

lua54 'yes'

escrow_ignore {
    'config.lua',
    'README.md',
    'version.json'  -- Added to escrow ignore
}