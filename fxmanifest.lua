fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'mri'
version '2.0.0'
description 'Weed Planting System using mriprops'

shared_scripts {
    '@oxmysql/lib/MySQL.lua',
    'locales/locale.lua',
    'locales/en.lua',
    'locales/es.lua',
    'config.lua'
}

client_scripts {
    '@qb-core/shared/locale.lua',
    'locales/locale.lua',
    'locales/*.lua',
    'config.lua',
    'client/main.lua',
    'client/interactions.lua',
    'client/effects.lua'
}

server_scripts {
    'server/main.lua'
}

ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/style.css',
    'ui/script.js',
    'stream/*.ytyp'
}

this_is_a_map 'yes'

file {
      'stream/*.ytyp'
}

data_file 'DLC_ITYP_REQUEST' 'stream/*.ytyp'
dependency '/assetpacks'