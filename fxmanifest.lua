fx_version 'cerulean'
game 'gta5'
lua54 'yes'

description 'Caserio Weed Harvesting Next-Gen'
version '2.0.0'

-- UI React Build
ui_page 'web/dist/index.html'

files {
    'web/dist/index.html',
    'web/dist/assets/*.js',
    'web/dist/assets/*.css',
    'locales/*.lua',
    'stream/*.ydr',
    'stream/*.ytyp'
}

shared_scripts {
    'config.lua',
    'locales/locale.lua',
    'locales/*.lua' 
}

client_scripts {
    '@PolyZone/client.lua',
    '@qb-core/shared/init.lua',
    'client/growth_logic.lua',
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

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