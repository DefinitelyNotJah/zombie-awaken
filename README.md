Zombie Awaken | CSO Mod.
This is a standalone Zombie-Apocalypse mod for Counter Strike 1.6 written in AMXMODX by me. This is NOT based in other mods such as Zombie Plague 4.2 or Zombie Plague 5.0.8.
Features :
	* Classic Infection Mod
	* Yaksha Infection Mod
	* Buy-menu with a variety of weapons
	* Level-up system
	* Knife Menu
	* Multiple Zombie Classes
This gameplay mod was heavily inspired by Zombie Engine (2016) and SISA Mod.
Recommended Environment :
	* HLDS Build 7882
	* Metamod v1.20
	* AMXMODX v1.8.2
	* MySQL 5.7
Recommended Settings :
	* 2GB of RAM
	* 1c 1.8Ghz
	* 5GB of Storage
	* 100MB/s Internet Speeed
Gameplay (pretty old) :
	* https://www.youtube.com/watch?v=0viFub9P_tw
	* https://www.youtube.com/watch?v=l-CgdKA64MU
	* https://www.youtube.com/watch?v=EsMs8JqNDAw
	* https://www.youtube.com/watch?v=JyLVyPm1R90
I started working on this mod back in 2016-2017 when I was active in the Counter-Strike 1.6 modding community. 
I did pretty good progress on it then left for around 3-4 years. and I picked it again in Early 2020.
-> It is written in a crude method with no optimization or programming-ethics whatsoever to speak of, so please excuse me if you get triggered looking at the source code. I wrote it when I was 14 years old and I never got around it to re-write/optimize/improve it so...
So, enough introduction. Here is some important key notes :
- Main Core and Weapons Buy Menu
```
in /addons/amxmodx/scripting, you will find :
	cso_main.sma
	cso_buy_menu.sma
They are pretty self explanatory, Main Core and Weapons Buy Menu (B), it is the latest version I worked on and it is pretty stable. 
```
- All Weapons that are tested with the mod
```
/addons/amxmodx/scripting/Weapons, are the weapons, check cso_buy_menu and use the weapons accordingly, if you don't want to go through all that hassle. in /addons/amxmodx/configs/, there is plugins-cso.ini, just compile the files that are mentioned there.
```
- 3rd Party Modules that are obligated/recommended to be run with the mod
```
/addons/amxmodx/scripting/3rd-party modules got an important file that is necessary to run this mod. make sure you don't miss cs_player_models_api because the core is using it, buy zone got some bugs so use buyzonerange as well.
```
- SuppyBox
```
/addons/amxmodx/scripting/Supplybox got the supplybox stuff, pretty necessary.. Use it.
```
- Plugins to fix the precache limit issue
```
/addons/amxmodx/scripting/Unprecache plugins, are where unprecache plugins found that are confirmed to work just fine with this mod. Just so you won't meet the precache limit issue.
Precache_Manager is the best that I've found, I can not find it for some reason so it is not there.
```
- Chat plugins such as level ranks & admin tiers
```
/addons/amxmodx/scripting/Chat Plugins, got the chat plugins that I used. Just saying.
```
- Useless Crystal Plugin, do not recommend
```
/addons/amxmodx/scripting/Crystal Plugin, got a crystal plugin - There is a chance when a zombie dies, a crystal with random loot in it will spawn. I used to use it but not anymore.
```
- IMPORTANT | Progress over the years
```
/addons/amxmodx/scripting/Old backup do not use, is the progress for the mod, including weapons and buy menu.
I usually save the files whenever I modify/add/remove something. So all the changes and progress that I've made these past years are saved there. Some are stable and some are riddled with bugs and issues.
If there is any issue with the latest core or buy menu, just scrap some code from there.
```
- Credits 
```
Crock / =) (Poprogun4ik) / LARS-DAY[BR]EAKER - For 90% of the weapons
Dias Bladefield/Pendragon - For Supplybox and rest of the weapons
ZP Dev Team - Scrapped some functions from their ZP4.2 mod
Mohamed Alaa / Night Fury / Jack Gameplay - Help with some issues
Counter-Strike : Nexon Zombies Team - Resources and ideas
```

P.S : There may be missing files, source codes or anything of the sort. Please notify me if that's the case.