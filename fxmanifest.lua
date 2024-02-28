----------------------------------
--<!>-- BOII | DEVELOPMENT --<!>--
----------------------------------

fx_version 'cerulean'
game {'gta5'}

author 'boiidevelopment'

description 'BOII | Development - Utility: Job Center'

version '0.0.1'

lua54 'yes'

ui_page 'html/index.html'

files {
    'html/**/**/**',
}

shared_scripts {
    'shared/language/en.lua',
    'shared/config.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/framework.lua',
    'server/main.lua',
}

client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/CircleZone.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/ComboZone.lua',
    'client/framework.lua',
    'client/main.lua',
}

escrow_ignore {
    'shared/**/*',
    'client/*',
    'server/*'
}
dependency '/assetpacks'