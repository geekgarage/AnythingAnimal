# AnythingAnimal [WIP]

Fully standalone script, is not dependant on any framework

The goal of this script is to allow players to be animals. This is especially great to include people with some sort of disabillity who cant for some reason play normal RP where they need to talk to people

The current script doeas the following
- Health regen
- Unlimited stamina
- Make animals faster on land
- Animals won't die instantly in water
- Disable ragdoll of animals in water
- Give animals human speed in water (can't go below 1.0 or it will be ignored by native function) - This is currently bugged and won't apply

Add to server and 'ensure AnythingAnimal' in server config. 
If running QB-Core just place the script in [standalone] category folder

In clients side scripts check using 'exports['AnythingAnimal']:getIsPlayerAnimal()' It will return true or false!
