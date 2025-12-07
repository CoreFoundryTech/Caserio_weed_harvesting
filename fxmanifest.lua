fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Caserio RP'
description 'Caserio Weed Harvesting'
version '1.0.0'

-- UI React Build
ui_page 'web/dist/index.html'

files {
    'web/dist/index.html',
    'web/dist/assets/*.js',
    'web/dist/assets/*.css',
    'stream/*.ytyp'
}

shared_scripts {
    'config.lua',
    'locales/locale.lua',
    'locales/en.lua',
    'locales/es.lua'
}

client_scripts {
    'client/growth_logic.lua',
    'client/effects.lua',
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

this_is_a_map 'yes'

data_file 'DLC_ITYP_REQUEST' 'stream/*.ytyp'

dependency '/assetpacks'