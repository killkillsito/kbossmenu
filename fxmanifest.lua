fx_version 'cerulean'
game 'gta5'
version '1.0.0'
author 'discord.gg/codem'

shared_scripts {
	'shared/*.lua',
}

client_scripts {
	'shared/locales.lua',
	'client/*.lua',
}

server_scripts {
	-- '@mysql-async/lib/MySQL.lua', --:warning:PLEASE READ:warning:; Uncomment this line if you use 'mysql-async'.:warning:
	'@oxmysql/lib/MySQL.lua', --:warning:PLEASE READ:warning:; Uncomment this line if you use 'oxmysql'.:warning:
	'shared/locales.lua',
	'server/*.lua',
}

ui_page "html/index.html"

files {
	'html/index.html',
	'html/index.css',
	'html/responsive.css',

	'html/*.js',
	'html/assets/**/*.png',
	'html/assets/**/**/*.png',
	'html/assets/**/*.otf',
	'html/assets/**/*.svg',
	'html/util/**/*.js',
	'html/components/**/*.js',
	'html/components/**/*.css',
	'html/components/**/*.html',
}

escrow_ignore{
	'shared/*.lua',
	'client/editable.lua',
	'client/util.lua',
	'server/util.lua',
	'server/botToken.lua',
}

lua54 'yes'