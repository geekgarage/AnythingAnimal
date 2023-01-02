# AnythingAnimal [WIP]

Fully standalone script, is not dependant on any framework

The goal of this script is to allow players to be animals. This is especially great to include people with some sort of disabillity who can't, for some reason, play RP where they need to talk to people.

The current script does the following
- Health regen (Enable/Disable in config)
- Unlimited stamina (Enable/Disable in config)
- Animals won't die instantly in water
- Disable ragdoll of animals in water
- "Run" in MLO and in underground
- Adjust movement speed using command:
  * /aaws x.yz (walk)
  * /aais x.yz (run inside)
  * /aaos x.yz (run outside)
  * /aass x.yz (swim)
  * Or while moving using NUM+/- or mouse scroll
  * Adjust limits in config
- Option to disable Idlecam (preferred) as it will mess with voice when activated and you could miss out of important conversation

Add to server and 'ensure AnythingAnimal' in server config. 
If running QB-Core just place the script in [standalone] category folder

In clients side scripts check using 'exports['AnythingAnimal']:getIsPlayerAnimal()' It will return true or false!