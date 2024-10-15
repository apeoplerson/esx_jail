fx_version 'cerulean'

game 'gta5'

description 'ESX Jail'

version '1.1.0'

shared_script '@es_extended/imports.lua'

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'@es_extended/locale.lua',
	'locales/en.lua',
	'locales/br.lua',
	'locales/sv.lua',
	'locales/dk.lua',
	'config.lua',
	'server/main.lua'
}

client_scripts {
	'@es_extended/locale.lua',
	'locales/en.lua',
	'locales/br.lua',
	'locales/sv.lua',
	'locales/dk.lua',
	'config.lua',
	'client/main.lua'
}

dependencies {
	'es_extended',
	'oxmysql'
}
