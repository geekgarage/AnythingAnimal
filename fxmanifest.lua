fx_version 'cerulean'
game 'gta5'

author 'GeekGarage <info@geekgarage.dk>'
description 'AnythingAnimal'
version '1.3.0'

--dependency 'oxmysql'

shared_scripts {
    'config.lua',
    'shared/*.lua'
}
server_scripts {
    --'@oxmysql/lib/MySQL.lua'
    'server/*.lua'
}
client_script 'client/*.lua'

lua54 'yes'