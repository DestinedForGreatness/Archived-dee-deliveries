fx_version 'adamant'

game 'gta5'

description 'Dee Scripts Deliveries'

version '1.0'

shared_scripts {
    'shared/*'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/*'
}

client_scripts {
	'client/*'
}

dependencies {
    'oxmysql',
}