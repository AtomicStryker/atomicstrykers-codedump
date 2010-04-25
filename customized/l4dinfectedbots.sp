/********************************************************************************************
* Plugin	: L4D/L4D2 InfectedBots with Coop/Survival playable SI spawns
* Version	: 1.9.2
* Game		: Left 4 Dead 1 & 2
* Author	: djromero (SkyDavid, David) and MI 5
* Testers	: Myself, MI 5
* Website	: www.sky.zebgames.com
* 
* Purpose	: This plugins spawns infected bots to fill up infected's team on vs mode when
* 			  there isn't enough real players. Also allows playable special infected on coop/survival modes.
* 
* WARNING	: Please use sourcemod's latest 1.3 branch snapshot.
* 
* Version 1.9.2
* 	   - Fixed bug with clients joining infected automatically when l4d_infectedbots_admins_only was set to 1
* 	   - Fixed some error messages that pop up from certain events
* 	   - Re-added feature: Bots in versus or scavenger will now ghost before they spawn completely
* 	   - Added cvar: l4d_infectedbots_ghost_time
*	   - Renamed cvar: l4d_infectedbots_idle_time_before_slay to l4d_infectedbots_lifespan 
* 	   - Removed cvar: l4d_infectedbots_timer_hurt_before_slay (it's now apart of l4d_infectedbots_lifespan)
* 	   - l4d_infectedbots_lifespan timer now kicks instead of slaying the infected
* 	   - If an infected sees the survivors when his lifespan timer is up, the timer will be made anew (prevents infected being kicked while they are attacking or nearby)
* 	   - (for coop/survival only) When a tank spawns and then kicked for a player to take over, there is now a check to see if the tank for the player to take over actually spawned successfully
* 	   - Plugin is now compatible with the new mutation gamemode and any further mutations
* 
* Version 1.9.1 V3
* 	   - Fixed bug with bot spawns (especially with 4+ infected bots)
* 	   - Fixed an error that was caused when the plugin was unloaded
* 
* Version 1.9.1 V2
* 	   - Fixed bug with server hibernation that was caused by rewrite of round start code (thanks Lexantis)
* 
* Version 1.9.1
* 	   - Changed Round start code which fixed a bug with survival (and possibly other gamemodes)
* 	   - Changed how the class limit cvars work, they can now be used to alter director spawning cvars (z_smoker_limit, z_hunter_limit, etc.)
* 	   - l4d_infectedbots_hunter_limit cvar added to L4D
* 	   - Added cvar l4d_infectedbots_instant_spawns, allows the plugin to instantly spawn the infected at the start of a map and the start of finales
* 	   - Fixed bug where survivors were slayed for no reason
* 	   - Fixed bug where Valve's bots would still spawn on certain maps
* 	   - Added cvar l4d_infectedbots_human_coop_survival_limit
* 	   - Added cvar l4d_infectedbots_admins_only
* 	   - Changed how the "!js" function worked, no longer uses jointeam (NEW GAMEDATA FILE BECAUSE OF THIS)
* 	   - Class limit cvars by this plugin no longer affect z_versus class player limits (l4d_infectedbots_smoker_limit for example no longer affects z_versus_smoker_limit)
*	   - Altered descriptions of the class limit cvars
* 
* Version 1.9.0
*      - Workaround implemented to get around Coop Limit (L4D2)
* 	   - REALLY fixed the 4+1 bug now
* 	   - REALLY fixed the survivor bots running out of the safe room bug
* 	   - Fixed bug where setting l4d_infectedbots_spawn_time to 5 or below would not spawn bots
* 	   - Removed cvar l4d_infectedbots_spawn_time and added cvars l4d_infectedbots_spawn_max_time and l4dinfectedbots_spawn_min_time
*	   - Changed code on how the game is detected on startup
* 	   - Removed FCVAR_NOTIFY from all cvars except the version cvar
* 	   - If l4d_infectedbots_infected_team_joinable is 0, plugin will not set sb_all_bot_team to 1
* 	   - Infected HUD can now display multiple tanks on fire along with the tank's health
* 	   - Coop tank takeover now supports multiple tanks
* 	   - Fixed bug where some players would not ghost in coop when they first spawn in a map
* 	   - Removed most instances where the plugin would cause a BotType error
* 	   - L4D bot spawning changed, now random like L4D2 instead of prioritized classes
* 	   - Fixed bug where players would be stuck at READY and never spawn
* 
* Version 1.8.9
* 	   - Gamedata file uses Signatures instead of offsets
* 	   - Enabling Director Spawning in Versus will activate Valve's bots
* 	   - Reverted back to original way of joining survivors (jointeam instead of sb_takecontrol)
* 	   - Bots no longer run out of the safe room before a player joins into the game
* 	   - Fixed bug when a tank spawned and its special infected taken over by a bot, would be able to spawn again if it died such as 4+1 bot
* 
* Version 1.8.8
* 	   - Disables Valve's versus bots automatically
* 	   - Based on AtomicStryker's version (fixes z_spawn bug along with gamemode bug)
* 	   - Removed L4D seperate plugin, this one plugin supports both
* 	   - Fixed strange ghost speed bug
* 	   - Added Flashlights and FreeSpawning for both L4D and L4D2 without resorting to changing gamemodes
* 	   - Now efficiently unlocks a versus start door when there are no players on infected (L4D 1 only)
* 
* Version 1.8.7
* 	   - Fixed Infected players not spawning correctly
* 
* Version 1.8.6
* 	   - Added a timer to the Gamemode ConVarHook to ensure compatitbilty with other gamemode changing plugins
* 	   - Fight or die code added by AtomicStryker (kills idle bots, very useful for coordination cvar) along with two new cvars: l4d2_infectedbots_idle_time_before_slay and l4d2_infectedbots_timer_hurt_before_slay
* 	   - Fixed bug where the plugin would return the BotType error even though the sum of the class limits matched that of the cvar max specials
* 	   - When the plugin is unloaded, it resets the convars that it changed
* 	   - Fixed bug where if Free Spawning and Director Spawning were on, it would cause the gamemode to stay on versus
* 
* Version 1.8.5
* 	   - Optimizations by AtomicStryker
* 	   - Removed "Multiple tanks" code from plugin
* 	   - Redone tank kicking code
* 	   - Redone tank health fix (Thanks AtomicStryker!)
* 
* Version 1.8.4
* 	   - Adapted plugin to new gamemode "teamversus" (4x4 versus matchmaking)
*	   - Fixed bug where Survivor bots didn't have their health bonuses count 
* 	   - Added FCVAR_SPONLY to cvars to prevent clients from changing server cvars
* 
* Version 1.8.3
* 	   - Enhanced Hunter AI (Hunter bots pounce farther, versus only)
* 	   - Model detection methods have been replaced with class detections (Compatible with Character Select Menu)
* 	   - Fixed VersusDoorUnlocker not working on the second round
* 	   - Added cvar l4d_infectedbots_coordination (bots will wait until all other bot spawn timers are 0 and then spawn at once)
* 
* Version 1.8.2
* 	   - Added Flashlights to the infected
* 	   - Prevented additional music from playing when spawning as an infected
* 	   - Redid the free spawning system, more robust and effective
* 	   - Fixed bug where human tanks would break z_max_player_zombies (Now prevents players from joining a full infected team in versus when a tank spawns)
* 	   - Redid the VersusDoorUnlocker, now activates without restrictions
* 	   - Fixed bug where tanks would keep spawning over and over
* 	   - Fixed bug where the HUD would display the tank on fire even though it's not
* 	   - Increased default spawn time to 30 seconds
* 
* Version 1.8.1 Fix V1
* 	   - Changed safe room detection (fixes Crash Course and custom maps) (Thanks AtomicStryker!)
* 
* Version 1.8.1
* 	   - Reverted back to the old kicking system
* 	   - Fixed Tank on fire timer for survival
* 	   - Survivor players can no longer join a full infected team in versus when theres a tank in play
* 	   - When a tank spawns in coop, they are not taken over by a player instantly; instead they are stationary until the tank moves, and then a player takes over (Thanks AtomicStryker!)
* 
* Version 1.8.0
* 	   - Fixed bug where the sphere bubbles would come back after the player dies
* 	   - Fixed additional bugs coming from the "mp_gamemode/server.cfg" bug
* 	   - Now checks if the admincheats plugin is installed and adapts
* 	   - Fixed Free spawn bug that prevent players from spawning as ghosts on the third map (or higher) on a campaign
* 	   - Fixed bug with spawn restrictions (was counting dead players as alive)
* 	   - Added ConVarHooks to Infected HUD cvars (will take effect immediately after being changed)
* 	   - Survivor Bots won't move out of the safe room until the player is fully in game
* 	   - Bots will not be shown on the infected HUD when they are not supposed to be (being replaced by a player on director spawn mode, or a tank being kicked for a player tank to take over)
* 
* Version 1.7.9
* 	   - Fixed a rare bug where if a map changed and director spawning is on, it would not allow the infected to be playable
* 	   - Removed Sphere bubbles for infected and spectators
* 	   - Modified Spawn restriction system
* 	   - Fixed bug where changing class limits on the spot would not take effect immediately
* 	   - Removed infected bot ghosts in versus, caused too many bugs
* 	   - Director spawn can now be changed in-game without a restart
* 	   - The Gamemode being changed no longer needs a restart
* 	   - Fixed bug where if admincheats is installed and an admin picked to spawn infected did not have root, would not spawn the infected
* 	   - Fixed bug where players could not spawn as ghosts in versus if the gamemode was set in a server.cfg instead of the l4d dedicated server tool (which still has adverse effects, plugin or not)
* 
* Version 1.7.8
* 	   - Removed The Dedibots, Director and The Spawner, from spec, the bots still spawn and is still compatible with admincheats (fixes 7/8 human limit reached problem)
* 	   - Changed the format of some of the announcements
* 	   - Reduced size of HUD
* 	   - HUD will NOT show infected players unless there are more than 5 infected players on the team (Versus only)
* 	   - KillInfected function now only applies to survival at round start
* 	   - Fixed Tank turning into hunter problem
* 	   - Fixed Special Smoker bug and other ghost related problems
* 	   - Fixed music glitch where certain pieces of music would keep playing over and over
* 	   - Fixed bug when a SI bot dies in versus with director spawning on, it would keep spawning that bot
* 	   - Fixed 1 health point bug in director spawning mode
* 	   - Fixed Ghost spawning bug in director spawning mode where all ghosts would spawn at once
* 	   - Fixed Coop Tank lottery starting for versus
* 	   - Fixed Client 0 error with the Versus door unlocker
* 	   - Added cvar: l4d_infectedbots_jointeams_announce
* 
* Version 1.7.7
* 	   - Support for admincheats (Thanks Whosat for this!)
* 	   - Reduced Versus checkpoint door unlocker timer to 10 seconds (no longer shows the message)
* 	   - Redone Versus door buster, now it simply unlocks the door
* 	   - Fixed Director Spawning bug when free spawn is turned on
* 	   - Added spawn timer to Director Spawning mode to prevent one player from taking all the bots
* 	   - Now shows respawn timers for bots in Versus
* 	   - When a player takes over a tank in coop/survival, the SI no longer disappears
* 	   - Redone Tank Lottery (Thanks AtomicStryker!)
* 	   - There is no limit on player tanks now
* 	   - Entity errors should be fixed, valid checks implemented
* 	   - Cvars that were changed by the plugin can now be changed with a server.cfg
*      - Director Spawning now works correctly when the value is changed from being 0 or 1
* 	   - Infected HUD now shows the health of the infected, rather than saying "ALIVE"
* 	   - Fixed Ghost bug on Survival start after a round (Kills all ghosts)
* 	   - Tank Health now shown properly in infected HUD
* 	   - Changed details of the infected HUD when Director Spawning is on
* 	   - Reduced the chances of the stats board appearing
* 
* Version 1.7.6
* 	   - Finale Glitch is fixed completely, no longer runs on timers
* 	   - Fixed bug with spawning when Director Spawning is on
* 	   - Added cvar: l4d_infectedbots_stats_board, can turn the stats board on or off after an infected dies
* 	   - Optimizations here and there
* 	   - Added a random system where the tank can go to anyone, rather than to the first person on the infected team
* 	   - Fixed bug where 4 specials would spawn when the tank is playable and on the field
* 	   - Fixed Free spawn bug where laggy players would not be ghosted
* 	   - Errors related to "SetEntData" have been fixed
* 	   - MaxSpecials is no longer linked to Director Spawning
* 
* Version 1.7.5
* 	   - Added command to join survivors (!js)
* 	   - Removed cvars: l4d_infectedbots_allow_boomer, l4d_infectedbots_allow_smoker and l4d_infectedbots_allow_hunter (redundent with new cvars)
* 	   - Added cvars: l4d_infectedbots_boomer_limit and l4d_infectedbots_smoker_limit
*	   - Added cvar: l4d_infectedbots_infected_team_joinable, cvar that can either allow or disallow players from joining the infected team on coop/survival
* 	   - Cvars renamed:  l4d_infectedbots_max_player_zombies to l4d_infectedbots_max_specials, l4d_infectedbots_tank_playable to l4d_infectedbots_coop_survival_tank_playable
* 	   - Bug fix with l4d_infectedbots_max_specials and l4d_infectedbots_director_spawn not setting correctly when the server first starts up
* 	   - Improved Boomer AI in versus (no longer sits there for a second when he is seen)
* 	   - Autoconfig (was applied in 1.7.4, just wasn't shown in the changelog) Be sure to delete your old one
* 	   - Reduced the chances of the director misplacing a bot
* 	   - If the tank is playable in coop or survival, a player will be picked as the tank, regardless of the player's status
* 	   - Fixed bug where the plugin may return "[L4D] Infected Bots: CreateFakeClient returned 0 -- Infected bot was not spawned"
* 	   - Removed giving health to infected when they spawn, they no longer need this as Valve fixed this bug
* 	   - Tank_killed game event was not firing due to the tank not being spawned by the director, this has been fixed by setting it in the player_death event and checking to see if it was a tank
* 	   - Fixed human infected players causing problems with infected bot spawning
* 	   - Added cvar: l4d_infectedbots_free_spawn which allows the spawning in coop/survival to be like versus (Thanks AtomicStryker for using some of your code from your infected ghost everywhere plugin!)
*	   - If there is only one survivor player in versus, the safe room door will be UTTERLY DESTROYED.    
* 	   - Open slots will be available to tanks by automatically increasing the max infected limit and decreasing when the tanks are killed
*	   - Bots were not spawning during a finale. This bug has been fixed.
* 	   - Fixed Survivor death finale glitch which would cause all player infected to freeze and not spawn
* 	   - Added a HUD that shows stats about Infected Players of when they spawn (from Durzel's Infected HUD plugin)
* 	   - Priority system added to the spawning in coop/survival, no longer does the first infected player always get the first infected bot that spawns
* 	   - Modified Spawn Restrictions
* 	   - Infected bots in versus now spawn as ghosts, and fully spawn two seconds later
* 	   - Removed commands that kicked with ServerCommand, this was causing crashes
* 	   - Added a check in coop/survival to put players on infected when they first join if the survivor team is full
* 	   - Removed cvar: l4d_infectedbots_hunter_limit
* 
* Version 1.7.4
* 	   - Fixed bots spawning too fast
* 	   - Completely fixed Ghost bug (Ghosts will stay ghosts until the play spawns them)
* 	   - New cvar "l4d_infectedbots_tank_playable" that allows tanks to be playable on coop/survival
* 
* Version 1.7.3
* 	   - Removed timers altogether and implemented the "old" system
* 	   - Fixed server hibernation problem
* 	   - Fixed error messages saying "Could not use ent_fire without cheats"
* 	   - Fixed Ghost spawning infront of survivors
* 	   - Set the spawn time to 25 seconds as default
* 	   - Fixed Checking bot mechanism
* 
* Version 1.7.2a
* 	   - Fixed bots not spawning after a checkpoint
* 	   - Fixed handle error
* 
* Version 1.7.2
*      - Removed autoconfig for plugin (delete your autoconfig for this plugin if you have one)
*      - Reintroduced coop/survival playable spawns
*      - spawns at conistent intervals of 20 seconds
*      - Overhauled coop special infected cvar dectection, use z_versus_boomer_limit, z_versus_smoker_limit, and l4d_infectedbots_versus_hunter_limit to alter amount of SI in coop (DO NOT USE THESE CVARS IF THE DIRECTOR IS SPAWNING THE BOTS! USE THE STANDARD COOP CVARS)
*      - Timers implemented for preventing the SI from spawning right at the start
*      - Fixed bug in 1.7.1 where the improved SI AI would reset to old after a map change
* 	   - Added a check on game start to prevent survivor bots from leaving the safe room too early when a player connects
* 	   - Added cvar to control the spawn time of the infected bots (can change at anytime and will take effect at the moment of change)
* 	   - Added cvar to have the director control the spawns (much better coop experience when max zombie players is set above 4), this however removes the option to play as those spawned infected
*	   - Removed l4d_infectedbots_coop_enabled cvar, l4d_infectedbots_director_spawn now replaces it. You can still use l4d_infectedbots_max_players_zombies
* 	   - New kicking mechanism added, there shouldn't be a problem with bots going over the limit
* 	   - Easier to join infected in coop/survival with the sm command "!ji"
* 	   - Introduced a new kicking mechanism, there shouldn't be more than the max infected unless there is a tank
* 
* Version 1.7.1
*      - Fixed Hunter AI where the hunter would run away and around in circles after getting hit
*      - Fixed Hunter Spawning where the hunter would spawn normally for 5 minutes into the map and then suddenly won't respawn at all
*      - An all Survivor Bot team can now pass the areas where they got stuck in (they can move throughout the map on their own now)     
*      - Changed l4d_versus_hunter_limit to l4d_infectedbots_versus_hunter_limit with a new default of 4
*      - It is now possible to change l4d_infectedbots_versus_hunter_limit and l4d_infectedbots_max_player_zombies in-game, just be sure to restart the map after change
*      - Overhauled the plugin, removed coop/survival infected spawn code, code clean up
* 
* Version 1.7.0
*      - Fixed sb_all_bot_team 1 is now set at all times until there are no players in the server.
*      - Survival/Coop now have playable Special Infected spawns.
*      - l4d_infectedbots_enabled_on_coop cvar created for those who want control over the plugin during coop/survival maps.
*      - Able to spectate AI Special Infected in Coop/Survival.
*      - Better AI (Smoker and Boomer don't sit there for a second and then attack a survivor when its within range).
*      - Set the number of VS team changes to 99 if its survival or coop, 2 for versus
*      - Safe Room timer added to coop/survival
*      - l4d_versus_hunter_limit added to control the amount of hunters in versus
*      - l4d_infectedbots_max_player_zombies added to increase the max special infected on the map (Bots and players)
*      - Autoexec created for this plugin
* 
* Version 1.6.1
* 		- Changed some routines to prevent crash on round end.
* 
* Version 1.6
* 		- Finally fixed issue of server hanging on mapchange or when last player leaves.
* 		  Thx to AcidTester for his help testing this.
* 		- Added cvar to disable infected bots HUD
* 
* Version 1.6
* 		- Fixed issue of HUD's timer not beign killed after each round.
* Version 1.5.8
* 		- Removed the "kickallbots" routine. Used a different method.
* 
* Version 1.5.6
* 		- Rollback on method for detecting if map is VS
* 
* Version 1.5.5
* 		- Fixed some issues with infected boomer bots spawning just after human boomer is killed.
* 		- Changed method of detecting VS maps to allow non-vs maps to use this plugin.
* 
* Version 1.5.4
* 		- Fixed (now) issue when all players leave and server would keep playing with only
* 		  survivor/infected bots.
* 
* Version 1.5.3
* 		- Fixed issue when boomer/smoker bots would spawn just after human boomer/smoker was
* 		  killed. (I had to hook the player_death event as pre, instead of post to be able to
* 		  check for some info).
* 		- Added new cvar to control the way you want infected spawn times handled:
* 			l4d_infectedbots_normalize_spawntime:
* 				0 (default): Human zombies will use default spawn times (min time if less 
* 							 than 3 players in team) (min default is 20)
* 				1		   : Bots and human zombies will have the same spawn time.
* 							 (max default is 30).
* 		- Fixed issue when all players leave and server would keep playing with only
* 	 	  survivor/infected bots.
* 
* Version 1.5.2
* 		- Normalized spawn times for human zombies (min = max).
* 		- Fixed spawn of extra bot when someone dead becomes a tank. If player was alive, his
* 		  bot will still remain if he gets a tank.
* 		- Added 2 new cvars to disallow boomer and/or smoker bots:
* 			l4d_infectedbots_allow_boomer = 1 (allow, default) / 0 (disallow)
* 			l4d_infectedbots_allow_smoker = 1 (allow, default) / 0 (disallow)
* 
* Version 1.5.1
* 		- Major bug fixes that caused server to hang (infite loops and threading problems).
* 
* Version 1.5
* 		- Added HUD panel for infected bots. Original idea from: Durzel's Infected HUD plugin.
* 		- Added validations so that boomers and smokers do not spawn too often. A boomer can
* 		  only spawn (as a bot) after XX seconds have elapsed since the last one died.
* 		- Added/fixed some routines/validations to prevent memory leaks.
* 
* Version 1.4
* 		- Infected bots can spawn when a real player is dead or in ghost mode without forcing
* 		  them (real players) to spawn.
* 		- Since real players won't be forced to spawn, they won't spawn outside the map or
* 		  in places they can't get out (where only bots can get out).
* 
* Version 1.3
* 		- No infected bots are spawned if at least one player is in ghost mode. If a bot is 
* 		  scheduled to spawn but a player is in ghost mode, the bot will spawn no more than
* 		  5 seconds after the player leaves ghost mode (spawns).
* 		- Infected bots won't stay AFK if they spawn far away. They will always search for
* 		  survivors even if they're far from them.
* 		- Allows survivor's team to be all bots, since we can have all bots on infected's team.
* 
* Version 1.2
* 		- Fixed several bugs while counting players.
* 		- Added chat message to inform infected players (only) that a new bot has been spawned
* 
* Version 1.1.2
* 		- Fixed crash when counting 
* 
* Version 1.1.1
* 		- Fixed survivor's quick HUD refresh when spawning infected bots
* 
* Version 1.1
* 		- Implemented "give health" command to fix infected's hud & pounce (hunter) when spawns
* 
* Version 1.0
* 		- Initial release.
* 
* 
**********************************************************************************************/

#include <sourcemod>
#include <sdktools>

#pragma semicolon 1

#define PLUGIN_VERSION "1.9.2"

#define DEBUG 0
#define DEBUGTANK 0
#define DEBUGHUD 0
#define DEVELOPER 0

#define TEAM_SPECTATOR		1
#define TEAM_SURVIVORS 		2
#define TEAM_INFECTED 		3

#define ZOMBIECLASS_SMOKER	1
#define ZOMBIECLASS_BOOMER	2
#define ZOMBIECLASS_HUNTER	3
#define ZOMBIECLASS_SPITTER	4
#define ZOMBIECLASS_JOCKEY	5
#define ZOMBIECLASS_CHARGER	6

// Variables
new InfectedRealCount; // Holds the amount of real infected players
new InfectedBotCount; // Holds the amount of infected bots in any gamemode
new InfectedBotQueue; // Holds the amount of bots that are going to spawn

new GameMode; // Holds the GameMode, 1 for coop and realism, 2 for versus, teamversus, scavenge and teamscavenge, 3 for survival

new TanksPlaying; // Holds the amount of tanks on the playing field
new BoomerLimit; // Sets the Boomer Limit, related to the boomer limit cvar
new SmokerLimit; // Sets the Smoker Limit, related to the smoker limit cvar
new HunterLimit; // Sets the Hunter Limit, related to the hunter limit cvar
new SpitterLimit; // Sets the Spitter Limit, related to the Spitter limit cvar
new JockeyLimit; // Sets the Jockey Limit, related to the Jockey limit cvar
new ChargerLimit; // Sets the Charger Limit, related to the Charger limit cvar

new MaxPlayerZombies; // Holds the amount of the maximum amount of special zombies on the field
new MaxPlayerTank; // Used for setting an additional slot for each tank that spawns
new BotReady; // Used to determine how many bots are ready, used only for the coordination feature
new ZOMBIECLASS_TANK; // This value varies depending on which L4D game it is, holds the the tank class value
new GetSpawnTime[MAXPLAYERS+1]; // Used for the HUD on getting spawn times of players


// Booleans
new bool:b_HasRoundStarted; // Used to state if the round started or not
new bool:b_HasRoundEnded; // States if the round has ended or not
new bool:b_LeftSaveRoom; // States if the survivors have left the safe room
new bool:canSpawnBoomer; // States if we can spawn a boomer (releated to spawn restrictions)
new bool:canSpawnSmoker; // States if we can spawn a smoker (releated to spawn restrictions)
new bool:canSpawnHunter; // States if we can spawn a hunter (releated to spawn restrictions)
new bool:canSpawnSpitter; // States if we can spawn a spitter (releated to spawn restrictions)
new bool:canSpawnJockey; // States if we can spawn a jockey (releated to spawn restrictions)
new bool:canSpawnCharger; // States if we can spawn a charger (releated to spawn restrictions)
new bool:DirectorSpawn; // Can allow either the director to spawn the infected (normal l4d behavior), or allow the plugin to spawn them
new bool:SpecialHalt; // Loop Breaker, prevents specials spawning, while Director is spawning, from spawning again
new bool:TankFrustStop; // Prevents the tank frustration event from firing as it counts as a tank spawn
new bool:FinaleStarted; // States whether the finale has started or not
new bool:WillBeTank[MAXPLAYERS+1]; // States whether that player will be the tank
//new bool:TankHalt; // Loop Breaker, prevents player tanks from spawning over and over
new bool:TankWasSeen[MAXPLAYERS+1]; // Used only in coop, prevents the Sound hook event from triggering over and over again
new bool:PlayerLifeState[MAXPLAYERS+1]; // States whether that player has the lifestate changed from switching the gamemode
new bool:InitialSpawn; // Related to the coordination feature, tells the plugin to let the infected spawn when the survivors leave the safe room
new bool:L4DVersion; // Holds the version of L4D; false if its L4D, true if its L4D2
new bool:FreeSpawnReset[MAXPLAYERS+1]; // Tells the plugin to reset the FreeSpawn convar, used for the finale glitch only
new bool:TempBotSpawned; // Tells the plugin that the tempbot has spawned
new bool:AlreadyGhosted[MAXPLAYERS+1]; // Loop Breaker, prevents a player from spawning into a ghost over and over again
new bool:AlreadyGhostedBot[MAXPLAYERS+1]; // Prevents bots taking over a player from ghosting


// Handles
new Handle:h_BoomerLimit; // Related to the Boomer limit cvar
new Handle:h_SmokerLimit; // Related to the Smoker limit cvar
new Handle:h_HunterLimit; // Related to the Hunter limit cvar
new Handle:h_SpitterLimit; // Related to the Spitter limit cvar
new Handle:h_JockeyLimit; // Related to the Jockey limit cvar
new Handle:h_ChargerLimit; // Related to the Charger limit cvar
new Handle:h_MaxPlayerZombies; // Related to the max specials cvar
new Handle:h_InfectedSpawnTimeMax; // Related to the spawn time cvar
new Handle:h_InfectedSpawnTimeMin; // Related to the spawn time cvar
new Handle:h_DirectorSpawn; // yeah you're getting the idea
new Handle:h_CoopPlayableTank; // yup, same thing again
new Handle:h_GameMode; // uh huh
new Handle:h_JoinableTeams; // Can you guess this one?
new Handle:h_FreeSpawn; // We're done now, so be excited
new Handle:h_StatsBoard; // Oops, now we are
new Handle:h_Difficulty; // Ok, maybe not
new Handle:h_JoinableTeamsAnnounce;
new Handle:h_Coordination;
new Handle:h_idletime_b4slay;
new Handle:h_InstantSpawn;
new Handle:h_HumanCoopLimit;
new Handle:h_AdminJoinInfected;
new Handle:FightOrDieTimer[MAXPLAYERS+1]; // kill idle bots
new Handle:h_BotGhostTime;

// Stuff related to Durzel's HUD (Panel was redone)
new respawnDelay[MAXPLAYERS+1]; 			// Used to store individual player respawn delays after death
new hudDisabled[MAXPLAYERS+1];				// Stores the client preference for whether HUD is shown
new clientGreeted[MAXPLAYERS+1]; 			// Stores whether or not client has been shown the mod commands/announce
new zombieHP[7];					// Stores special infected max HP
new Handle:cvarZombieHP[7];				// Array of handles to the 4 cvars we have to hook to monitor HP changes
new bool:isTankOnFire[MAXPLAYERS+1]		= false; 		// Used to store whether tank is on fire
new burningTankTimeLeft[MAXPLAYERS+1]		= 0; 			// Stores number of seconds Tank has left before he dies
new bool:roundInProgress 		= false;		// Flag that marks whether or not a round is currently in progress
new Handle:infHUDTimer 		= INVALID_HANDLE;	// The main HUD refresh timer
new Handle:respawnTimer 	= INVALID_HANDLE;	// Respawn countdown timer
new Handle:doomedTankTimer 	= INVALID_HANDLE;	// "Tank on Fire" countdown timer
new Handle:delayedDmgTimer 	= INVALID_HANDLE;	// Delayed damage update timer
new Handle:pInfHUD 		= INVALID_HANDLE;	// The panel shown to all infected users
new Handle:usrHUDPref 		= INVALID_HANDLE;	// Stores the client HUD preferences persistently

// Console commands
new Handle:h_InfHUD		= INVALID_HANDLE;
new Handle:h_Announce 	= INVALID_HANDLE;

public Plugin:myinfo = 
{
	name = "[L4D/L4D2] Infected Bots",
	author = "djromero (SkyDavid), MI 5",
	description = "Spawns infected bots in versus, allows playable special infected in coop/survival, and changable z_max_player_zombies limit",
	version = PLUGIN_VERSION,
	url = "www.alliedmods.net"
}

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max) 
{
	// Checks to see if the game is a L4D game. If it is, check if its the sequel. L4DVersion is L4D if false, L4D2 if true.
	decl String:GameName[64];
	GetGameFolderName(GameName, sizeof(GameName));
	if (StrContains("left4dead", "left4dead", false) == -1)
		return APLRes_Failure; 
	else if (StrEqual(GameName, "left4dead2", false))
		L4DVersion = true;
	
	return APLRes_Success; 
}

public OnPluginStart()
{
	// Tank Class value is different in L4D2
	if (L4DVersion)
		ZOMBIECLASS_TANK = 8;
	else
		ZOMBIECLASS_TANK = 5;
	
	// Notes on the offsets: altough m_isGhost is used to check or set a player's ghost status, for some weird reason this disallowed the player from spawning.
	// So I found and used m_isCulling to allow the player to press use and spawn as a ghost (which in this case, I forced the client to press use)
	
	// m_lifeState is an alternative to the "switching to spectator and back" method when a bot spawns. This was used to prevent players from taking over those bots, but
	// this provided weird movements when a player was spectating on the infected team.
	
	// ScrimmageType is interesting as it was used in the beta. The scrimmage code was abanonded and replaced with versus, but some of it is still left over in the final.
	// In the previous versions of this plugin (or not using this plugin at all), you might have seen giant bubbles or spheres around the map. Those are scrimmage spawn
	// spheres that were used to prevent infected from spawning within there. It was bothering me, and a whole lot of people who saw them. Thanks to AtomicStryker who
	// URGED me to remove the spheres, I began looking for a solution. He told me to use various source handles like m_scrimmageType and others. I experimented with it,
	// and found out that it removed the spheres, and implemented it into the plugin. The spheres are no longer shown, and they were useless anyway as infected still spawn 
	// within it.
	
	
	// Notes on the sourcemod commands:
	// JoinSpectator is actually a developer command I used to see if the bots spawn correctly with and without a player. It was incredibly useful for this purpose, but it
	// will not be in the final versions.
	
	// Add a sourcemod command so players can easily join infected in coop/survival
	RegConsoleCmd("sm_ji", JoinInfected);
	RegConsoleCmd("sm_js", JoinSurvivors);
	#if DEVELOPER
	RegConsoleCmd("sm_sp", JoinSpectator);
	RegConsoleCmd("sm_gamemode", CheckGameMode);
	RegConsoleCmd("sm_count", CheckQueue);
	#endif
	
	// Hook "say" so clients can toggle HUD on/off for themselves
	RegConsoleCmd("sm_infhud", Command_Say);
	
	// We register the version cvar
	CreateConVar("l4d_infectedbots_version", PLUGIN_VERSION, "Version of L4D Infected Bots", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	
	h_GameMode = FindConVar("mp_gamemode");
	h_Difficulty = FindConVar("z_difficulty");
	
	// console variables
	h_BoomerLimit = CreateConVar("l4d_infectedbots_boomer_limit", "1", "Sets the limit for boomers spawned by the plugin and those spawned by the director", FCVAR_PLUGIN|FCVAR_SPONLY);
	h_SmokerLimit = CreateConVar("l4d_infectedbots_smoker_limit", "1", "Sets the limit for smokers spawned by the plugin and and those spawned by the director", FCVAR_PLUGIN|FCVAR_SPONLY);
	if (L4DVersion)
	{
		h_SpitterLimit = CreateConVar("l4d_infectedbots_spitter_limit", "1", "Sets the limit for spitters spawned by the plugin and those spawned by the director", FCVAR_PLUGIN|FCVAR_SPONLY);
		h_JockeyLimit = CreateConVar("l4d_infectedbots_jockey_limit", "1", "Sets the limit for jockeys spawned by the plugin and those spawned by the director", FCVAR_PLUGIN|FCVAR_SPONLY);
		h_ChargerLimit = CreateConVar("l4d_infectedbots_charger_limit", "1", "Sets the limit for chargers spawned by the plugin and those spawned by the director", FCVAR_PLUGIN|FCVAR_SPONLY);
		h_HunterLimit = CreateConVar("l4d_infectedbots_hunter_limit", "1", "Sets the limit for hunters spawned by the plugin and those spawned by the director", FCVAR_PLUGIN|FCVAR_SPONLY);
	}
	else
	{
		h_HunterLimit = CreateConVar("l4d_infectedbots_hunter_limit", "2", "Sets the limit for hunters spawned by the plugin and those spawned by the director", FCVAR_PLUGIN|FCVAR_SPONLY);
	}
	h_MaxPlayerZombies = CreateConVar("l4d_infectedbots_max_specials", "4", "Defines how many special infected can be on the map on all gamemodes", FCVAR_PLUGIN|FCVAR_SPONLY); 
	h_InfectedSpawnTimeMax = CreateConVar("l4d_infectedbots_spawn_time_max", "30", "Sets the max spawn time for special infected spawned by the plugin in seconds", FCVAR_PLUGIN|FCVAR_SPONLY);
	h_InfectedSpawnTimeMin = CreateConVar("l4d_infectedbots_spawn_time_min", "25", "Sets the minimum spawn time for special infected spawned by the plugin in seconds", FCVAR_PLUGIN|FCVAR_SPONLY);
	h_DirectorSpawn = CreateConVar("l4d_infectedbots_director_spawn", "0", "If 1, the plugin will use the director's timing of the spawns, if versus it will use Valve's bots", FCVAR_PLUGIN|FCVAR_SPONLY, true, 0.0, true, 1.0);
	h_CoopPlayableTank = CreateConVar("l4d_infectedbots_coop_survival_tank_playable", "0", "If 1, tank will be playable in coop/survival", FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_SPONLY, true, 0.0, true, 1.0);
	h_JoinableTeams = CreateConVar("l4d_infectedbots_infected_team_joinable", "1", "If 1, players can join the infected team in coop/survival", FCVAR_PLUGIN|FCVAR_SPONLY, true, 0.0, true, 1.0);
	if (!L4DVersion)
	{
		h_StatsBoard = CreateConVar("l4d_infectedbots_stats_board", "1", "If 1, the stats board will show up after an infected player dies", FCVAR_PLUGIN|FCVAR_SPONLY, true, 0.0, true, 1.0);
	}
	h_FreeSpawn = CreateConVar("l4d_infectedbots_free_spawn", "0", "If 1, infected players in coop/survival will spawn as ghosts", FCVAR_PLUGIN|FCVAR_SPONLY, true, 0.0, true, 1.0);
	h_JoinableTeamsAnnounce = CreateConVar("l4d_infectedbots_jointeams_announce", "1", "If 1, clients will be announced to about joining the infected team", FCVAR_PLUGIN|FCVAR_SPONLY, true, 0.0, true, 1.0);
	h_Coordination = CreateConVar("l4d_infectedbots_coordination", "0", "If 1, bots will only spawn when all other bot timers are at zero", FCVAR_PLUGIN|FCVAR_SPONLY, true, 0.0, true, 1.0);
	h_InfHUD = CreateConVar("l4d_infectedbots_infhud_enable", "1", "Toggle whether L4D Infected HUD is active or not.", FCVAR_PLUGIN|FCVAR_SPONLY, true, 0.0, true, 1.0);
	h_Announce = CreateConVar("l4d_infectedbots_infhud_announce", "1", "Toggle whether L4D Infected HUD announces itself to clients.", FCVAR_PLUGIN|FCVAR_SPONLY, true, 0.0, true, 1.0);
	h_idletime_b4slay = CreateConVar("l4d_infectedbots_lifespan", "40", "Amount of seconds before a special infected bot is kicked", FCVAR_PLUGIN|FCVAR_SPONLY);
	h_InstantSpawn = CreateConVar("l4d_infectedbots_instant_spawns", "1", "If 1, plugin will instantly spawn infected when necessary (start of map, start of finales)", FCVAR_PLUGIN|FCVAR_SPONLY, true, 0.0, true, 1.0);
	h_HumanCoopLimit = CreateConVar("l4d_infectedbots_human_coop_survival_limit", "4", "Sets the limit for the amount of humans that can join the infected team in coop/survival", FCVAR_PLUGIN|FCVAR_SPONLY);
	h_AdminJoinInfected = CreateConVar("l4d_infectedbots_admins_only", "0", "If 1, only admins can join the infected team in coop/survival", FCVAR_PLUGIN|FCVAR_SPONLY, true, 0.0, true, 1.0);
	h_BotGhostTime = CreateConVar("l4d_infectedbots_ghost_time", "2", "If higher than zero, the plugin will ghost bots before they fully spawn on versus/scavenge", FCVAR_PLUGIN|FCVAR_SPONLY);
	
	HookConVarChange(h_BoomerLimit, ConVarBoomerLimit);
	BoomerLimit = GetConVarInt(h_BoomerLimit);
	HookConVarChange(h_SmokerLimit, ConVarSmokerLimit);
	SmokerLimit = GetConVarInt(h_SmokerLimit);
	HookConVarChange(h_HunterLimit, ConVarHunterLimit);
	HunterLimit = GetConVarInt(h_HunterLimit);
	if (L4DVersion)
	{
		HookConVarChange(h_SpitterLimit, ConVarSpitterLimit);
		SpitterLimit = GetConVarInt(h_SpitterLimit);
		HookConVarChange(h_JockeyLimit, ConVarJockeyLimit);
		JockeyLimit = GetConVarInt(h_JockeyLimit);
		HookConVarChange(h_ChargerLimit, ConVarChargerLimit);
		ChargerLimit = GetConVarInt(h_ChargerLimit);
	}
	HookConVarChange(h_MaxPlayerZombies, ConVarMaxPlayerZombies);
	MaxPlayerZombies = GetConVarInt(h_MaxPlayerZombies);
	HookConVarChange(h_DirectorSpawn, ConVarDirectorSpawn);
	DirectorSpawn = GetConVarBool(h_DirectorSpawn);
	HookConVarChange(h_GameMode, ConVarGameMode);
	HookConVarChange(h_Difficulty, ConVarDifficulty);
	
	// Some of these events are being used multiple times. Although I copied Durzel's code, I felt this would make it more organized as there is a ton of code in events 
	// Such as PlayerDeath, PlayerSpawn and others.
	
	// We hook the round_start (and round_end) event on plugin start, since it occurs before map_start
	HookEvent("item_pickup", evtRoundStart);
	HookEvent("round_end", evtRoundEnd, EventHookMode_Pre);
	// We hook some events ...
	HookEvent("player_death", evtPlayerDeath, EventHookMode_Pre);
	HookEvent("player_team", evtPlayerTeam);
	HookEvent("player_spawn", evtPlayerSpawn);
	HookEvent("create_panic_event", evtSurvivalStart);
	HookEvent("tank_frustrated", evtTankFrustrated);
	HookEvent("finale_start", evtFinaleStart);
	HookEvent("mission_lost", evtMissionLost);
	HookEvent("player_death", evtInfectedDeath);
	HookEvent("player_spawn", evtInfectedSpawn);
	HookEvent("player_hurt", evtInfectedHurt);
	HookEvent("player_team", evtTeamSwitch);
	HookEvent("player_death", evtInfectedWaitSpawn);
	HookEvent("ghost_spawn_time", evtInfectedWaitSpawn);
	HookEvent("spawner_give_item", evtUnlockVersusDoor);
	HookEvent("player_bot_replace", evtBotReplacedPlayer);
	
	// Hook a sound
	AddNormalSoundHook(NormalSHook:HookSound_Callback);
	//AddNormalSoundHook(NormalSHook:HookSound_Callback2);
	
	// We set some variables
	b_HasRoundStarted = false;
	b_HasRoundEnded = false;
	
	//Autoconfig for plugin
	AutoExecConfig(true, "l4dinfectedbots");
	
	//----- Zombie HP hooks ---------------------	
	//We store the special infected max HP values in an array and then hook the cvars used to modify them
	//just in case another plugin (or an admin) decides to modify them.  Whilst unlikely if we don't do
	//this then the HP percentages on the HUD will end up screwy, and since it's a one-time initialisation
	//when the plugin loads there's a trivial overhead.
	cvarZombieHP[0] = FindConVar("z_hunter_health");
	cvarZombieHP[1] = FindConVar("z_gas_health");
	cvarZombieHP[2] = FindConVar("z_exploding_health");
	if (L4DVersion)
	{
		cvarZombieHP[3] = FindConVar("z_spitter_health");
		cvarZombieHP[4] = FindConVar("z_jockey_health");
		cvarZombieHP[5] = FindConVar("z_charger_health");
	}
	cvarZombieHP[6] = FindConVar("z_tank_health");
	zombieHP[0] = 250;	// Hunter default HP
	if (cvarZombieHP[0] != INVALID_HANDLE)
	{
		zombieHP[0] = GetConVarInt(cvarZombieHP[0]); 
		HookConVarChange(cvarZombieHP[0], cvarZombieHPChanged);
	}
	zombieHP[1] = 250;	// Smoker default HP
	if (cvarZombieHP[1] != INVALID_HANDLE)
	{
		zombieHP[1] = GetConVarInt(cvarZombieHP[1]); 
		HookConVarChange(cvarZombieHP[1], cvarZombieHPChanged);
	}
	zombieHP[2] = 50;	// Boomer default HP
	if (cvarZombieHP[2] != INVALID_HANDLE)
	{
		zombieHP[2] = GetConVarInt(cvarZombieHP[2]);
		HookConVarChange(cvarZombieHP[2], cvarZombieHPChanged);
	}
	if (L4DVersion)
	{
		zombieHP[3] = 100;	// Spitter default HP
		if (cvarZombieHP[3] != INVALID_HANDLE) 
		{
			zombieHP[3] = GetConVarInt(cvarZombieHP[3]);
			HookConVarChange(cvarZombieHP[3], cvarZombieHPChanged);
		}
		zombieHP[4] = 325;	// Jockey default HP
		if (cvarZombieHP[4] != INVALID_HANDLE) 
		{
			zombieHP[4] = GetConVarInt(cvarZombieHP[4]);
			HookConVarChange(cvarZombieHP[4], cvarZombieHPChanged);
		}
		zombieHP[5] = 600;	// Charger default HP
		if (cvarZombieHP[5] != INVALID_HANDLE) 
		{
			zombieHP[5] = GetConVarInt(cvarZombieHP[5]);
			HookConVarChange(cvarZombieHP[5], cvarZombieHPChanged);
		}
	}
	
	
	
	// Create persistent storage for client HUD preferences 
	usrHUDPref = CreateTrie();
}

public ConVarBoomerLimit(Handle:convar, const String:oldValue[], const String:newValue[])
{
	BoomerLimit = GetConVarInt(h_BoomerLimit);
	//SetConVarInt(FindConVar("z_versus_boomer_limit"), BoomerLimit);
	if (DirectorSpawn)
	{
		if (L4DVersion)
			SetConVarInt(FindConVar("z_boomer_limit"), BoomerLimit);
		else
		SetConVarInt(FindConVar("z_exploding_limit"), BoomerLimit);
	}
}
public ConVarSmokerLimit(Handle:convar, const String:oldValue[], const String:newValue[])
{
	SmokerLimit = GetConVarInt(h_SmokerLimit);
	//SetConVarInt(FindConVar("z_versus_smoker_limit"), SmokerLimit);
	if (DirectorSpawn)
	{
		if (L4DVersion)
			SetConVarInt(FindConVar("z_smoker_limit"), SmokerLimit);
		else
		SetConVarInt(FindConVar("z_gas_limit"), SmokerLimit);
	}
}

public ConVarHunterLimit(Handle:convar, const String:oldValue[], const String:newValue[])
{
	HunterLimit = GetConVarInt(h_HunterLimit);
	//if (L4DVersion)
	//SetConVarInt(FindConVar("z_versus_hunter_limit"), HunterLimit);
	if (DirectorSpawn)
		SetConVarInt(FindConVar("z_hunter_limit"), HunterLimit);
}

public ConVarSpitterLimit(Handle:convar, const String:oldValue[], const String:newValue[])
{
	SpitterLimit = GetConVarInt(h_SpitterLimit);
	//SetConVarInt(FindConVar("z_versus_spitter_limit"), SpitterLimit);
	if (DirectorSpawn)
		SetConVarInt(FindConVar("z_spitter_limit"), SpitterLimit);
}

public ConVarJockeyLimit(Handle:convar, const String:oldValue[], const String:newValue[])
{
	JockeyLimit = GetConVarInt(h_JockeyLimit);
	//SetConVarInt(FindConVar("z_versus_jockey_limit"), JockeyLimit);
	if (DirectorSpawn)
		SetConVarInt(FindConVar("z_jockey_limit"), JockeyLimit);
}

public ConVarChargerLimit(Handle:convar, const String:oldValue[], const String:newValue[])
{
	ChargerLimit = GetConVarInt(h_ChargerLimit);
	//SetConVarInt(FindConVar("z_versus_charger_limit"), ChargerLimit);
	if (DirectorSpawn)
		SetConVarInt(FindConVar("z_charger_limit"), ChargerLimit);
}

public ConVarMaxPlayerZombies(Handle:convar, const String:oldValue[], const String:newValue[])
{
	MaxPlayerZombies = GetConVarInt(h_MaxPlayerZombies);
	CreateTimer(0.1, MaxSpecialsSet);
}

public ConVarDirectorSpawn(Handle:convar, const String:oldValue[], const String:newValue[])
{
	DirectorSpawn = GetConVarBool(h_DirectorSpawn);
	if (!DirectorSpawn)
	{
		//ResetCvars();
		TweakSettings();
		if (GetConVarBool(h_InstantSpawn))
			CheckIfBotsNeeded(true);
		else
		CheckIfBotsNeeded(false);
	}
	else
	{
		//ResetCvarsDirector();
		DirectorStuff();
	}
}

public ConVarGameMode(Handle:convar, const String:oldValue[], const String:newValue[])
{
	GameModeCheck();
	
	if (!DirectorSpawn)
	{
		//ResetCvars();
		TweakSettings();
	}
	else
	{
		//ResetCvarsDirector();
		DirectorStuff();
	}
}

public ConVarDifficulty(Handle:convar, const String:oldValue[], const String:newValue[])
{
	TankHealthCheck();
}

TweakSettings()
{
	// We tweak some settings ...
	
	// Some interesting things about this. There was a bug I discovered that in versions 1.7.8 and below, infected players would not spawn as ghosts in VERSUS. This was
	// due to the fact that the coop class limits were not being reset (I didn't think they were linked at all, but I should have known better). This bug has been fixed
	// with the coop class limits being reset on every gamemode except coop of course.
	
	switch (GameMode)
	{
		case 1: // Coop, We turn off the ability for the director to spawn the bots, and have the plugin do it while allowing the director to spawn tanks and witches, 
		// MI 5
		{
			// Reset Special Infected AI
			ResetConVar(FindConVar("boomer_vomit_delay"), true, true);
			ResetConVar(FindConVar("smoker_tongue_delay"), true, true);
			ResetConVar(FindConVar("hunter_leap_away_give_up_range"), true, true);
			ResetConVar(FindConVar("boomer_exposed_time_tolerance"), true, true);
			ResetConVar(FindConVar("z_hunter_lunge_distance"), true, true);
			ResetConVar(FindConVar("hunter_pounce_ready_range"), true, true);
			ResetConVar(FindConVar("hunter_pounce_loft_rate"), true, true);
			ResetConVar(FindConVar("z_hunter_lunge_stagger_time"), true, true);
			// If the game is L4D 2...
			if (L4DVersion)
			{
				SetConVarInt(FindConVar("z_smoker_limit"), 0);
				SetConVarInt(FindConVar("z_boomer_limit"), 0);
				SetConVarInt(FindConVar("z_hunter_limit"), 0);
				SetConVarInt(FindConVar("z_spitter_limit"), 0);
				SetConVarInt(FindConVar("z_jockey_limit"), 0);
				SetConVarInt(FindConVar("z_charger_limit"), 0);
			}
			else
			{
				SetConVarInt(FindConVar("z_gas_limit"), 0);
				SetConVarInt(FindConVar("z_exploding_limit"), 0);
				SetConVarInt(FindConVar("z_hunter_limit"), 0);
			}
		}
		case 2: // Versus, Better Versus Infected AI, reset if not versus, MI 5
		{
			// If the game is L4D 2...
			if (L4DVersion)
			{
				SetConVarInt(FindConVar("z_smoker_limit"), 0);
				SetConVarInt(FindConVar("z_boomer_limit"), 0);
				SetConVarInt(FindConVar("z_hunter_limit"), 0);
				SetConVarInt(FindConVar("z_spitter_limit"), 0);
				SetConVarInt(FindConVar("z_jockey_limit"), 0);
				SetConVarInt(FindConVar("z_charger_limit"), 0);
			}
			else
			{
				SetConVarInt(FindConVar("z_gas_limit"), 999);
				SetConVarInt(FindConVar("z_exploding_limit"), 999);
				SetConVarInt(FindConVar("z_hunter_limit"), 999);
			}
			// Enhance Special Infected AI
			SetConVarFloat(FindConVar("smoker_tongue_delay"), 0.0);
			SetConVarFloat(FindConVar("boomer_vomit_delay"), 0.0);
			SetConVarFloat(FindConVar("boomer_exposed_time_tolerance"), 0.0);
			SetConVarInt(FindConVar("hunter_leap_away_give_up_range"), 0);
			SetConVarInt(FindConVar("z_hunter_lunge_distance"), 5000);
			SetConVarInt(FindConVar("hunter_pounce_ready_range"), 1500);
			SetConVarFloat(FindConVar("hunter_pounce_loft_rate"), 0.055);
			SetConVarFloat(FindConVar("z_hunter_lunge_stagger_time"), 0.0);
		}
		case 3: // Survival, Turns off the ability for the director to spawn infected bots in survival, MI 5
		{
			// Reset Special Infected AI
			ResetConVar(FindConVar("boomer_vomit_delay"), true, true);
			ResetConVar(FindConVar("smoker_tongue_delay"), true, true);
			ResetConVar(FindConVar("hunter_leap_away_give_up_range"), true, true);
			ResetConVar(FindConVar("boomer_exposed_time_tolerance"), true, true);
			ResetConVar(FindConVar("z_hunter_lunge_distance"), true, true);
			ResetConVar(FindConVar("hunter_pounce_ready_range"), true, true);
			ResetConVar(FindConVar("hunter_pounce_loft_rate"), true, true);
			ResetConVar(FindConVar("z_hunter_lunge_stagger_time"), true, true);
			if (L4DVersion)
			{
				SetConVarInt(FindConVar("survival_max_smokers"), 0);
				SetConVarInt(FindConVar("survival_max_boomers"), 0);
				SetConVarInt(FindConVar("survival_max_hunters"), 0);
				SetConVarInt(FindConVar("survival_max_spitters"), 0);
				SetConVarInt(FindConVar("survival_max_jockeys"), 0);
				SetConVarInt(FindConVar("survival_max_chargers"), 0);
				SetConVarInt(FindConVar("survival_max_specials"), MaxPlayerZombies);
				SetConVarInt(FindConVar("z_smoker_limit"), 0);
				SetConVarInt(FindConVar("z_boomer_limit"), 0);
				SetConVarInt(FindConVar("z_hunter_limit"), 0);
				SetConVarInt(FindConVar("z_spitter_limit"), 0);
				SetConVarInt(FindConVar("z_jockey_limit"), 0);
				SetConVarInt(FindConVar("z_charger_limit"), 0);
			}
			else
			{
				SetConVarInt(FindConVar("holdout_max_smokers"), 0);
				SetConVarInt(FindConVar("holdout_max_boomers"), 0);
				SetConVarInt(FindConVar("holdout_max_hunters"), 0);
				SetConVarInt(FindConVar("holdout_max_specials"), MaxPlayerZombies);
				SetConVarInt(FindConVar("z_gas_limit"), 0);
				SetConVarInt(FindConVar("z_exploding_limit"), 0);
				SetConVarInt(FindConVar("z_hunter_limit"), 0);
			}
		}
	}
	
	//Some cvar tweaks
	SetConVarInt(FindConVar("z_attack_flow_range"), 50000);
	SetConVarInt(FindConVar("director_spectate_specials"), 1);
	SetConVarInt(FindConVar("z_spawn_safety_range"), 0);
	SetConVarInt(FindConVar("z_spawn_flow_limit"), 50000);
	//SetConVarInt(FindConVar("z_versus_boomer_limit"), BoomerLimit);
	//SetConVarInt(FindConVar("z_versus_smoker_limit"), SmokerLimit);
	if (L4DVersion)
	{
		//SetConVarInt(FindConVar("z_versus_hunter_limit"), HunterLimit);
		//SetConVarInt(FindConVar("z_versus_spitter_limit"), SpitterLimit);
		//SetConVarInt(FindConVar("z_versus_jockey_limit"), JockeyLimit);
		//SetConVarInt(FindConVar("z_versus_charger_limit"), ChargerLimit);
		SetConVarInt(FindConVar("versus_special_respawn_interval"), 99999999);
	}
	#if DEBUG
	LogMessage("Tweaking Settings");
	#endif
	
}
/*
ResetCvars()
{
#if DEBUG
LogMessage("Plugin Cvars Reset");
#endif
if (GameMode == 1)
{
ResetConVar(FindConVar("director_no_specials"), true, true);
ResetConVar(FindConVar("boomer_vomit_delay"), true, true);
ResetConVar(FindConVar("smoker_tongue_delay"), true, true);
ResetConVar(FindConVar("hunter_leap_away_give_up_range"), true, true);
ResetConVar(FindConVar("boomer_exposed_time_tolerance"), true, true);
ResetConVar(FindConVar("z_hunter_lunge_distance"), true, true);
ResetConVar(FindConVar("hunter_pounce_ready_range"), true, true);
ResetConVar(FindConVar("hunter_pounce_loft_rate"), true, true);
ResetConVar(FindConVar("z_hunter_lunge_stagger_time"), true, true);
if (L4DVersion)
{
ResetConVar(FindConVar("survival_max_smokers"), true, true);
ResetConVar(FindConVar("survival_max_boomers"), true, true);
ResetConVar(FindConVar("survival_max_hunters"), true, true);
ResetConVar(FindConVar("survival_max_spitters"), true, true);
ResetConVar(FindConVar("survival_max_jockeys"), true, true);
ResetConVar(FindConVar("survival_max_chargers"), true, true);
ResetConVar(FindConVar("survival_max_specials"), true, true);
}
else
{
ResetConVar(FindConVar("holdout_max_smokers"), true, true);
ResetConVar(FindConVar("holdout_max_boomers"), true, true);
ResetConVar(FindConVar("holdout_max_hunters"), true, true);
ResetConVar(FindConVar("holdout_max_specials"), true, true);
}
}
else if (GameMode == 2)
{
if (L4DVersion)
{
ResetConVar(FindConVar("survival_max_smokers"), true, true);
ResetConVar(FindConVar("survival_max_boomers"), true, true);
ResetConVar(FindConVar("survival_max_hunters"), true, true);
ResetConVar(FindConVar("survival_max_spitters"), true, true);
ResetConVar(FindConVar("survival_max_jockeys"), true, true);
ResetConVar(FindConVar("survival_max_chargers"), true, true);
ResetConVar(FindConVar("survival_max_specials"), true, true);
}
else
{
ResetConVar(FindConVar("holdout_max_smokers"), true, true);
ResetConVar(FindConVar("holdout_max_boomers"), true, true);
ResetConVar(FindConVar("holdout_max_hunters"), true, true);
ResetConVar(FindConVar("holdout_max_specials"), true, true);
}
}
else if (GameMode == 3)
{
if (L4DVersion)
{
ResetConVar(FindConVar("z_smoker_limit"), true, true);
ResetConVar(FindConVar("z_boomer_limit"), true, true);
ResetConVar(FindConVar("z_hunter_limit"), true, true);
ResetConVar(FindConVar("z_spitter_limit"), true, true);
ResetConVar(FindConVar("z_jockey_limit"), true, true);
ResetConVar(FindConVar("z_charger_limit"), true, true);
}
else
{
ResetConVar(FindConVar("z_gas_limit"), true, true);
ResetConVar(FindConVar("z_exploding_limit"), true, true);
ResetConVar(FindConVar("z_hunter_limit"), true, true);
}
ResetConVar(FindConVar("boomer_vomit_delay"), true, true);
ResetConVar(FindConVar("director_no_specials"), true, true);
ResetConVar(FindConVar("smoker_tongue_delay"), true, true);
ResetConVar(FindConVar("hunter_leap_away_give_up_range"), true, true);
ResetConVar(FindConVar("boomer_exposed_time_tolerance"), true, true);
ResetConVar(FindConVar("z_hunter_lunge_distance"), true, true);
ResetConVar(FindConVar("hunter_pounce_ready_range"), true, true);
ResetConVar(FindConVar("hunter_pounce_loft_rate"), true, true);
ResetConVar(FindConVar("z_hunter_lunge_stagger_time"), true, true);
}
}


ResetCvarsDirector()
{
#if DEBUG
LogMessage("Director Cvars Reset");
#endif
if (GameMode != 2)
{
if (L4DVersion)
{
ResetConVar(FindConVar("z_smoker_limit"), true, true);
ResetConVar(FindConVar("z_boomer_limit"), true, true);
ResetConVar(FindConVar("z_hunter_limit"), true, true);
ResetConVar(FindConVar("z_spitter_limit"), true, true);
ResetConVar(FindConVar("z_jockey_limit"), true, true);
ResetConVar(FindConVar("z_charger_limit"), true, true);
ResetConVar(FindConVar("survival_max_smokers"), true, true);
ResetConVar(FindConVar("survival_max_boomers"), true, true);
ResetConVar(FindConVar("survival_max_hunters"), true, true);
ResetConVar(FindConVar("survival_max_spitters"), true, true);
ResetConVar(FindConVar("survival_max_jockeys"), true, true);
ResetConVar(FindConVar("survival_max_chargers"), true, true);
ResetConVar(FindConVar("survival_max_specials"), true, true);
}
else
{
ResetConVar(FindConVar("z_hunter_limit"), true, true);
ResetConVar(FindConVar("z_exploding_limit"), true, true);
ResetConVar(FindConVar("z_gas_limit"), true, true);
ResetConVar(FindConVar("holdout_max_smokers"), true, true);
ResetConVar(FindConVar("holdout_max_boomers"), true, true);
ResetConVar(FindConVar("holdout_max_hunters"), true, true);
ResetConVar(FindConVar("holdout_max_specials"), true, true);
}
}
else
{
if (L4DVersion)
{
//ResetConVar(FindConVar("z_smoker_limit"), true, true);
SetConVarInt(FindConVar("z_smoker_limit"), 2);
ResetConVar(FindConVar("z_boomer_limit"), true, true);
//ResetConVar(FindConVar("z_hunter_limit"), true, true);
SetConVarInt(FindConVar("z_hunter_limit"), 2);
ResetConVar(FindConVar("z_spitter_limit"), true, true);
ResetConVar(FindConVar("z_jockey_limit"), true, true);
ResetConVar(FindConVar("z_charger_limit"), true, true);
}
else
{
ResetConVar(FindConVar("z_hunter_limit"), true, true);
ResetConVar(FindConVar("z_exploding_limit"), true, true);
ResetConVar(FindConVar("z_gas_limit"), true, true);
}
}
}
*/

public Action:evtRoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	// If round has started ...
	if (b_HasRoundStarted)
		return;
	
	//Check the GameMode
	GameModeCheck();
	
	if (GameMode == 0)
		return;
	
	#if DEBUG
	PrintToChatAll("Round Started");
	LogMessage("Round Started");
	#endif
	
	// Removes the boundaries for z_max_player_zombies and notify flag
	new flags = GetConVarFlags(FindConVar("z_max_player_zombies"));
	SetConVarBounds(FindConVar("z_max_player_zombies"), ConVarBound_Upper, false);
	SetConVarFlags(FindConVar("z_max_player_zombies"), flags & ~FCVAR_NOTIFY);
	
	b_LeftSaveRoom = false;
	b_HasRoundEnded = false;
	b_HasRoundStarted = true;
	
	// Added a delay to setting MaxSpecials so that it would set correctly when the server first starts up
	CreateTimer(0.4, MaxSpecialsSet);
	
	//reset some variables
	InfectedBotQueue = 0;
	TanksPlaying = 0;
	BotReady = 0;
	TankFrustStop = false;
	FinaleStarted = false;
	SpecialHalt = false;
	InitialSpawn = false;
	TempBotSpawned = false;
	
	// Zero all respawn times ready for the next round and any other arrays
	for (new i = 1; i <= MaxClients; i++)
	{
		respawnDelay[i] = 0;
		PlayerLifeState[i] = false;
		isTankOnFire[i] = false;
		burningTankTimeLeft[i] = 0;
		TankWasSeen[i] = false;
		AlreadyGhosted[i] = false;
	}
	// Show the HUD to the connected clients.
	roundInProgress = true;
	if (infHUDTimer == INVALID_HANDLE)
	{
		infHUDTimer = CreateTimer(5.0, showInfHUD, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	}
	TankHealthCheck();
	// Start up TweakSettings or Director Stuff
	if (!DirectorSpawn)
		TweakSettings();
	else
	DirectorStuff();
	
	// Kill all infected ghosts at start if it isn't versus
	if (GameMode != 2)
	{
		CreateTimer(0.1, KillInfected);
	}
	
	if (GameMode != 3)
	{
		#if DEBUG
		LogMessage("Starting the Coop/Versus PlayerLeft Start Timer");
		#endif
		CreateTimer(1.0, PlayerLeftStart, _, TIMER_FLAG_NO_MAPCHANGE);
	}
}

GameModeCheck()
{
	#if DEBUG
	LogMessage("Checking Gamemode");
	#endif
	//MI 5, We determine what the gamemode is
	decl String:GameName[16];
	GetConVarString(h_GameMode, GameName, sizeof(GameName));
	if (StrEqual(GameName, "survival", false))
		GameMode = 3;
	else if (StrEqual(GameName, "versus", false) || StrEqual(GameName, "teamversus", false) || StrEqual(GameName, "scavenge", false) || StrEqual(GameName, "teamscavenge", false) || StrEqual(GameName, "mutation12", false) || StrEqual(GameName, "mutation13", false))
		GameMode = 2;
	else if (StrEqual(GameName, "coop", false) || StrEqual(GameName, "realism", false) || StrEqual(GameName, "mutation3", false) || StrEqual(GameName, "mutation9", false))
		GameMode = 1;
	else
	{
		GameMode = 0;
		CreateTimer(30.0, IncorrectGameMode, _, TIMER_FLAG_NO_MAPCHANGE);
	}
	
	TankHealthCheck();
}

TankHealthCheck()
{
	decl String:difficulty[100];
	GetConVarString(h_Difficulty, difficulty, sizeof(difficulty));
	
	if (GameMode == 2)
	{
		zombieHP[6] = 4000;	// Tank default HP
		if (cvarZombieHP[6] != INVALID_HANDLE)
		{
			zombieHP[6] = RoundToFloor(GetConVarInt(cvarZombieHP[6]) * 1.5);	// Tank health is multiplied by 1.5x in VS	
			HookConVarChange(cvarZombieHP[6], cvarZombieHPChanged);
		}
	}
	else if (StrContains(difficulty, "Easy", false) != -1)  
	{
		zombieHP[6] = 4000;	// Tank default HP
		if (cvarZombieHP[6] != INVALID_HANDLE)
		{
			zombieHP[6] = RoundToFloor(GetConVarInt(cvarZombieHP[6]) * 0.75);
			HookConVarChange(cvarZombieHP[6], cvarZombieHPChanged);
		}
	}
	else if (StrContains(difficulty, "Normal", false) != -1)
	{
		zombieHP[6] = 4000;	// Tank default HP
		if (cvarZombieHP[6] != INVALID_HANDLE)
		{
			zombieHP[6] = GetConVarInt(cvarZombieHP[6]);
			HookConVarChange(cvarZombieHP[6], cvarZombieHPChanged);
		}
	}
	else if (StrContains(difficulty, "Hard", false) != -1 || StrContains(difficulty, "Impossible", false) != -1)
	{
		zombieHP[6] = 4000;	// Tank default HP
		if (cvarZombieHP[6] != INVALID_HANDLE)
		{
			zombieHP[6] = RoundToFloor(GetConVarInt(cvarZombieHP[6]) * 2.0);
			HookConVarChange(cvarZombieHP[6], cvarZombieHPChanged);
		}
	}
}

public Action:IncorrectGameMode(Handle:Timer)
{
	// Show this to everyone when the gamemode has been set incorrectly
	PrintToChatAll("\x04[SM] \x03INFECTED BOTS: \x03mp_gamemode \x04has been set \x03INCORRECTLY! PLUGIN WILL NOT START!");
}

public Action:KillInfected(Handle:Timer)
{
	for (new i=1; i<=MaxClients; i++)
	{
		// We check if player is in game
		if (!IsClientInGame(i)) continue;
		
		// Check if client is infected ...
		if (GetClientTeam(i)==TEAM_INFECTED)
		{
			if (!IsFakeClient(i) && IsPlayerGhost(i))
			{
				ForcePlayerSuicide(i);
			}
		}
	}
}

public Action:MaxSpecialsSet(Handle:Timer)
{
	SetConVarInt(FindConVar("z_max_player_zombies"), MaxPlayerZombies);
	#if DEBUG
	LogMessage("Max Player Zombies Set");
	#endif
}

DirectorStuff()
{	
	SpecialHalt = false;
	SetConVarInt(FindConVar("z_spawn_safety_range"), 0);
	SetConVarInt(FindConVar("director_spectate_specials"), 1);
	
	if (L4DVersion)
	{
		SetConVarInt(FindConVar("z_smoker_limit"), SmokerLimit);
		SetConVarInt(FindConVar("z_boomer_limit"), BoomerLimit);
		SetConVarInt(FindConVar("z_hunter_limit"), HunterLimit);
		SetConVarInt(FindConVar("z_spitter_limit"), SpitterLimit);
		SetConVarInt(FindConVar("z_jockey_limit"), JockeyLimit);
		SetConVarInt(FindConVar("z_charger_limit"), ChargerLimit);
		SetConVarInt(FindConVar("survival_max_hunters"), HunterLimit);
		SetConVarInt(FindConVar("survival_max_smokers"), SmokerLimit);
		SetConVarInt(FindConVar("survival_max_boomers"), BoomerLimit);
		SetConVarInt(FindConVar("survival_max_spitters"), SpitterLimit);
		SetConVarInt(FindConVar("survival_max_jockeys"), JockeyLimit);
		SetConVarInt(FindConVar("survival_max_chargers"), ChargerLimit);
	}
	else
	{
		SetConVarInt(FindConVar("z_gas_limit"), SmokerLimit);
		SetConVarInt(FindConVar("z_exploding_limit"), BoomerLimit);
		SetConVarInt(FindConVar("z_hunter_limit"), HunterLimit);
		SetConVarInt(FindConVar("holdout_max_hunters"), HunterLimit);
		SetConVarInt(FindConVar("holdout_max_smokers"), SmokerLimit);
		SetConVarInt(FindConVar("holdout_max_boomers"), BoomerLimit);
	}
	
	#if DEBUG
	LogMessage("Director Stuff has been executed");
	#endif
	
}

public Action:evtRoundEnd (Handle:event, const String:name[], bool:dontBroadcast)
{
	// If round has not been reported as ended ..
	if (!b_HasRoundEnded)
	{
		
		// we mark the round as ended
		b_HasRoundEnded = true;
		b_HasRoundStarted = false;
		b_LeftSaveRoom = false;
		roundInProgress = false;
		
		// This I set in because the panel was never originally designed for multiple gamemodes.
		CreateTimer(5.0, HUDReset);
		
		// This spawns a Survivor Bot so that the health bonus for the bots count (L4D only)
		if (!L4DVersion && GameMode == 2 && !RealPlayersOnSurvivors() && !AllSurvivorsDeadOrIncapacitated())
		{
			new bot = CreateFakeClient("Fake Survivor");
			ChangeClientTeam(bot,2);
			DispatchKeyValue(bot,"classname","SurvivorBot");
			DispatchSpawn(bot);
			
			CreateTimer(0.1,kickbot,bot);
		}
		
		for (new i = 1; i <= MaxClients; i++)
		{
			if (FightOrDieTimer[i] != INVALID_HANDLE)
			{
				KillTimer(FightOrDieTimer[i]);
				FightOrDieTimer[i] = INVALID_HANDLE;
			}
		}
		
		#if DEBUG
		LogMessage("Round Ended");
		#endif
	}
	
}

public OnMapEnd()
{
	#if DEBUG
	LogMessage("Map has ended");
	#endif
	
	b_HasRoundStarted = false;
	b_HasRoundEnded = true;
	b_LeftSaveRoom = false;
	roundInProgress = false;
	
	for (new i = 1; i <= MaxClients; i++)
	{
		if (FightOrDieTimer[i] != INVALID_HANDLE)
		{
			KillTimer(FightOrDieTimer[i]);
			FightOrDieTimer[i] = INVALID_HANDLE;
		}
	}
}

public Action:PlayerLeftStart(Handle:Timer)
{
	if (LeftStartArea())
	{	
		// We don't care who left, just that at least one did
		if (!b_LeftSaveRoom)
		{
			#if DEBUG
			LogMessage("A player left the start area, spawning bots");
			PrintToChatAll("A player left the start area, spawning bots");
			#endif
			b_LeftSaveRoom = true;
			
			// We reset some settings
			canSpawnBoomer = true;
			canSpawnSmoker = true;
			canSpawnHunter = true;
			if (L4DVersion)
			{
				canSpawnSpitter = true;
				canSpawnJockey = true;
				canSpawnCharger = true;
			}
			InitialSpawn = true;
			
			// We check if we need to spawn bots
			if (GetConVarBool(h_InstantSpawn))
				CheckIfBotsNeeded(true);
			else
			CheckIfBotsNeeded(false);
			#if DEBUG
			LogMessage("Checking to see if we need bots");
			#endif
			CreateTimer(3.0, InitialSpawnReset, _, TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	else
	{
		CreateTimer(1.0, PlayerLeftStart, _, TIMER_FLAG_NO_MAPCHANGE);
	}
	return Plugin_Continue;
}



// This is hooked to the panic event, but only starts if its survival. This is what starts up the bots in survival.

public Action:evtSurvivalStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (GameMode == 3)
	{  
		// We don't care who left, just that at least one did
		if (!b_LeftSaveRoom)
		{
			#if DEBUG
			LogMessage("A player triggered the survival event, spawning bots");
			PrintToChatAll("A player triggered the survival event, spawning bots");
			#endif
			b_LeftSaveRoom = true;
			
			// We reset some settings
			canSpawnBoomer = true;
			canSpawnSmoker = true;
			canSpawnHunter = true;
			if (L4DVersion)
			{
				canSpawnSpitter = true;
				canSpawnJockey = true;
				canSpawnCharger = true;
			}
			InitialSpawn = true;
			
			// We check if we need to spawn bots
			if (GetConVarBool(h_InstantSpawn))
				CheckIfBotsNeeded(true);
			else
			CheckIfBotsNeeded(false);
			#if DEBUG
			LogMessage("Checking to see if we need bots");
			#endif
			CreateTimer(3.0, InitialSpawnReset, _, TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	return Plugin_Continue;
}

public Action:InitialSpawnReset(Handle:Timer)
{
	InitialSpawn = false;
}

public Action:BotReadyReset(Handle:Timer)
{
	BotReady = 0;
}

public Action:InfectedPlayerJoiner(Handle:Timer, any:client)
{
	// This code puts players on the infected after the survivor team has been filled.
	// set variables
	new SurvivorRealCount;
	new SurvivorLimit = GetConVarInt(FindConVar("survivor_limit"));
	
	// reset counters
	SurvivorRealCount = 0;
	
	// First we count the ammount of survivor real players
	for (new i=1; i<=MaxClients; i++)
	{
		// We check if player is in game
		if (!IsClientInGame(i)) continue;
		// Check if client is survivor ...
		if (GetClientTeam(i)==TEAM_SURVIVORS)
		{
			// If player is a real player ... 
			if (!IsFakeClient(i))
			{
				SurvivorRealCount++;
				#if DEBUG
				LogMessage("Found a survivor player");
				#endif
			}
		}
	}
	
	if (IsClientInGame(client) && GetClientTeam(client) == TEAM_SPECTATOR && !IsFakeClient(client))
	{
		// If the survivor team is full
		if  (SurvivorRealCount >= SurvivorLimit)
		{
			ChangeClientTeam(client, TEAM_INFECTED);
			PrintHintText(client, "IBP: Placing you on the Infected team due to survivor team being full");
		}
		else
		{
			SwitchToSurvivors(client);
			PrintHintText(client, "IBP: Placing you on the Survivor team");
		}
	}
}

public Action:evtUnlockVersusDoor(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (L4DVersion || b_LeftSaveRoom || GameMode != 2 || RealPlayersOnInfected() || TempBotSpawned)
		return Plugin_Continue;
	
	//PrintToChatAll("Attempting to spawn tempbot");
	
	new bot = CreateFakeClient("tempbot");
	if (bot != 0)
	{
		ChangeClientTeam(bot,TEAM_INFECTED);
		CreateTimer(0.1,kickbot,bot);
		TempBotSpawned = true;
	}
	else
	{
		LogError("Temperory Infected Bot was not spawned for the Versus Door Unlocker!");
	}
	
	return Plugin_Continue;
}

public Action:InfectedBotBooterVersus(Handle:Timer)
{
	//This is to check if there are any extra bots and boot them if necessary, excluding tanks, versus only
	if (GameMode == 2)
	{
		// current count ...
		new total;
		
		for (new i=1; i<=MaxClients; i++)
		{
			// if player is ingame ...
			if (IsClientInGame(i))
			{
				// if player is on infected's team
				if (GetClientTeam(i) == TEAM_INFECTED)
				{
					// We count depending on class ...
					if (!IsPlayerTank(i) || (IsPlayerTank(i) && GetClientHealth(i) <= 1))
					{
						total++;
					}
				}
			}
		}
		if (total + InfectedBotQueue > MaxPlayerZombies)
		{
			new kick = total + InfectedBotQueue - MaxPlayerZombies; 
			new kicked = 0;
			
			// We kick any extra bots ....
			for (new i=1;(i<=MaxClients)&&(kicked < kick);i++)
			{
				// If player is infected and is a bot ...
				if (IsClientInGame(i) && IsFakeClient(i))
				{
					//  If bot is on infected ...
					if (GetClientTeam(i) == TEAM_INFECTED)
					{
						// If player is not a tank
						if (!IsPlayerTank(i) || ((IsPlayerTank(i) && GetClientHealth(i) <= 1)))
						{
							// timer to kick bot
							CreateTimer(0.1,kickbot,i);
							
							// increment kicked count ..
							kicked++;
							#if DEBUG
							LogMessage("Kicked a Bot");
							#endif
						}
					}
				}
			}
		}
	}
}

// This code, combined with Durzel's code, announce certain messages to clients when they first enter the server

public OnClientPutInServer(client)
{
	// If is a bot, skip this function
	if (IsFakeClient(client))
		return;
	
	// Durzel's code ***********************************************************************************
	decl String:clientSteamID[32];
	new doHideHUD;
	
	GetClientAuthString(client, clientSteamID, 32);
	
	// Try and find their HUD visibility preference
	new foundKey = GetTrieValue(Handle:usrHUDPref, clientSteamID, doHideHUD);
	if (foundKey)
	{
		if (doHideHUD)
		{
			// This user chose not to view the HUD at some point in the game
			hudDisabled[client] = 1;
		}
	}
	else hudDisabled[client] = 1;
	// End Durzel's code **********************************************************************************
	
	if ((client) && (GameMode != 2) && (GetConVarBool(h_JoinableTeams)) && !GetConVarBool(h_AdminJoinInfected))
	{
		CreateTimer(30.0, AnnounceJoinInfected, client, TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(15.0, InfectedPlayerJoiner, client, TIMER_FLAG_NO_MAPCHANGE);
	}
	
	// This sets sb_all_bot_team to 1 when a player comes into the server, and stop the bots from moving so that they don't run out of the safe room
	if (!b_LeftSaveRoom && GetConVarBool(h_JoinableTeams))
	{
		SetConVarInt(FindConVar("sb_all_bot_team"), 1);
		SetConVarInt(FindConVar("sb_stop"), 1);
		CreateTimer(0.1, CheckForPlayers);
	}
	
	#if DEBUG
	LogMessage("OnClientPutInServer has started");
	#endif
}

public Action:CheckForPlayers(Handle:timer)
{
	if (RealPlayersOnSurvivors() || RealPlayersOnInfected())
	{
		SetConVarInt(FindConVar("sb_stop"), 0);
	}
	else
	CreateTimer(1.0, CheckForPlayers, _, TIMER_FLAG_NO_MAPCHANGE);
}

public Action:CheckGameMode(client, args)
{
	if (client)
	{
		PrintToChat(client, "GameMode = %i", GameMode);
	}
}

public Action:CheckQueue(client, args)
{
	if (client)
	{
		if (GameMode == 2)
			CountInfected();
		else
		CountInfected_Coop();
		
		PrintToChat(client, "InfectedBotQueue = %i, InfectedBotCount = %i, InfectedRealCount = %i", InfectedBotQueue, InfectedBotCount, InfectedRealCount);
	}
}

public Action:JoinInfected(client, args)
{
	if (client && (GameMode == 1 || GameMode == 3) && GetConVarBool(h_JoinableTeams))
	{
		if (GetConVarBool(h_AdminJoinInfected))
		{
			if (GetUserFlagBits(client) > 0)
				ChangeClientTeam(client, TEAM_INFECTED);
			else
			{
				PrintHintText(client, "Only admins can join the infected.");
			}
		}
		else
		{
			if (HumansOnInfected() < GetConVarInt(h_HumanCoopLimit))
				ChangeClientTeam(client, TEAM_INFECTED);
			else
			PrintHintText(client, "The Infected Team is full.");
		}
	}
	else
	{
		if (client && GetClientTeam(client)==1 && GameMode == 2)
		{
			ChangeClientTeam(client, TEAM_INFECTED);
		}
	}
}

public Action:JoinSurvivors(client, args)
{
	if (client && (GameMode == 1 || GameMode == 3))
	{
		SwitchToSurvivors(client);
	}
	else
	{
		if (client && GetClientTeam(client)==1 && GameMode == 2)
		{
			SwitchToSurvivors(client);
		}
	}
}

// Joining spectators is for developers only, commented in the final

public Action:JoinSpectator(client, args)
{
	if ((client) && (GetConVarBool(h_JoinableTeams)))
	{
		ChangeClientTeam(client, TEAM_SPECTATOR);
	}
}

public Action:AnnounceJoinInfected(Handle:timer, any:client)
{
	if (IsClientInGame(client) && (!IsFakeClient(client)))
	{
		if ((GetConVarBool(h_JoinableTeamsAnnounce)) && (GetConVarBool(h_JoinableTeams)) && ((GameMode == 1) || (GameMode == 3)))
		{
			PrintHintText(client, "IBP: Type !ji in chat to join the infected team or type !js to join the survivors!");
		}
	}
}

public Action:evtPlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	// If round has ended .. we ignore this
	if (b_HasRoundEnded || !b_LeftSaveRoom) return Plugin_Continue;
	
	// We get the client id and time
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	// If client is valid
	if (!client || !IsClientInGame(client)) return Plugin_Continue;
	
	if (GetClientTeam(client) != TEAM_INFECTED)
		return Plugin_Continue;
	
	if (DirectorSpawn && GameMode != 2)
	{
		if (IsPlayerSmoker(client))
		{
			if (IsFakeClient(client))
			{
				if (!SpecialHalt)
				{
					CreateTimer(0.1, kickbot, client);
					
					#if DEBUG
					LogMessage("Smoker kicked");
					#endif
					
					new BotNeeded = 1;
					
					CreateTimer(0.2, Spawn_InfectedBot_Director, BotNeeded);
					
					
					#if DEBUG
					LogMessage("Spawned Smoker");
					#endif
				}
			}
		}
		else if (IsPlayerBoomer(client))
		{
			if (IsFakeClient(client))
			{
				if (!SpecialHalt)
				{
					CreateTimer(0.1, kickbot, client);
					
					#if DEBUG
					LogMessage("Boomer kicked");
					#endif
					
					new BotNeeded = 2;
					CreateTimer(0.2, Spawn_InfectedBot_Director, BotNeeded);
					
					
					#if DEBUG
					LogMessage("Spawned Booomer");
					#endif
				}
			}
		}
		else if (IsPlayerHunter(client))
		{
			if (IsFakeClient(client))
			{
				if (!SpecialHalt)
				{
					CreateTimer(0.1, kickbot, client);
					
					#if DEBUG
					LogMessage("Hunter Kicked");
					#endif
					
					new BotNeeded = 3;
					
					CreateTimer(0.2, Spawn_InfectedBot_Director, BotNeeded);
					
					
					#if DEBUG
					LogMessage("Hunter Spawned");
					#endif
				}
			}
		}
		else if (IsPlayerSpitter(client) && L4DVersion)
		{
			if (IsFakeClient(client))
			{
				if (!SpecialHalt)
				{
					CreateTimer(0.1, kickbot, client);
					
					#if DEBUG
					LogMessage("Spitter Kicked");
					#endif
					
					new BotNeeded = 4;
					
					CreateTimer(0.2, Spawn_InfectedBot_Director, BotNeeded);
					
					
					#if DEBUG
					LogMessage("Spitter Spawned");
					#endif
				}
			}
		}
		else if (IsPlayerJockey(client) && L4DVersion)
		{
			if (IsFakeClient(client))
			{
				if (!SpecialHalt)
				{
					CreateTimer(0.1, kickbot, client);
					
					#if DEBUG
					LogMessage("Jockey Kicked");
					#endif
					
					new BotNeeded = 5;
					
					CreateTimer(0.2, Spawn_InfectedBot_Director, BotNeeded);
					
					
					#if DEBUG
					LogMessage("Jockey Spawned");
					#endif
				}
			}
		}
		else if (IsPlayerCharger(client) && L4DVersion)
		{
			if (IsFakeClient(client))
			{
				if (!SpecialHalt)
				{
					CreateTimer(0.1, kickbot, client);
					
					#if DEBUG
					LogMessage("Charger Kicked");
					#endif
					
					new BotNeeded = 6;
					
					CreateTimer(0.2, Spawn_InfectedBot_Director, BotNeeded);
					
					
					#if DEBUG
					LogMessage("Charger Spawned");
					#endif
				}
			}
		}
	}
	
	if (IsPlayerTank(client))
	{
		if (b_LeftSaveRoom)
		{
			#if DEBUG
			LogMessage("Tank Event Triggered");
			#endif
			if (!TankFrustStop)
			{
				TanksPlaying = 0;
				MaxPlayerTank = 0;
				for (new i=1;i<=MaxClients;i++)
				{
					// We check if player is in game
					if (!IsClientInGame(i)) continue;
					
					// Check if client is infected ...
					if (GetClientTeam(i)==TEAM_INFECTED)
					{
						// If player is a tank
						if (IsPlayerTank(i) && GetClientHealth(i) > 1)
						{
							TanksPlaying++;
							MaxPlayerTank++;
						}
					}
				}
				
				MaxPlayerTank = MaxPlayerTank + MaxPlayerZombies;
				SetConVarInt(FindConVar("z_max_player_zombies"), MaxPlayerTank);
				#if DEBUG
				LogMessage("Incremented Max Zombies from Tank Spawn EVENT");
				#endif
				
				if (GameMode == 3)
				{
					if (IsFakeClient(client) && RealPlayersOnInfected() && GetConVarBool(h_CoopPlayableTank))
					{
						CreateTimer(0.5, TankSpawner, client);
						CreateTimer(0.6, kickbot, client);
					}
				}
				else
				{
					MaxPlayerTank = MaxPlayerZombies;
					SetConVarInt(FindConVar("z_max_player_zombies"), MaxPlayerZombies);
				}
			}
		}
	}
	else if (IsFakeClient(client))
	{
		if (FightOrDieTimer[client] != INVALID_HANDLE)
		{
			KillTimer(FightOrDieTimer[client]);
			FightOrDieTimer[client] = INVALID_HANDLE;
		}
		FightOrDieTimer[client] = CreateTimer(GetConVarFloat(h_idletime_b4slay), DisposeOfCowards, client, TIMER_FLAG_NO_MAPCHANGE);
	}
	
	// Turn infected player into a ghost if Free Spawning is on
	
	if (L4DVersion && !AlreadyGhosted[client])
	{
		AlreadyGhosted[client] = true;
		InfectedForceGhost(client);
	}
	else if (!L4DVersion && GameMode != 2 && !IsFakeClient(client) && !IsPlayerTank(client) && (GetConVarBool(h_FreeSpawn) && !AlreadyGhosted[client] || FreeSpawnReset[client]))
	{
		AlreadyGhosted[client] = true;
		SetEntProp(client,Prop_Send,"m_isCulling",1);
		ClientCommand(client, "+use");
		CreateTimer(0.1, FreeSpawnEnsure, client, TIMER_FLAG_NO_MAPCHANGE);
		if (FreeSpawnReset[client] == true)
			FreeSpawnReset[client] = false;
	}
	
	// Turn on Flashlight for Infected player
	TurnFlashlightOn(client);
	
	// If its Versus and the bot is not a tank, make the bot into a ghost
	if (IsFakeClient(client) && GameMode == 2 && !IsPlayerTank(client))
		CreateTimer(0.1, Timer_SetUpBotGhost, client, TIMER_FLAG_NO_MAPCHANGE);
	
	// This fixes the music glitch thats been bothering me and many players for a long time. The music keeps playing over and over when it shouldn't. Doesn't execute
	// on versus.
	if (!L4DVersion && GameMode != 2 && !IsFakeClient(client))
	{
		ClientCommand(client, "music_dynamic_stop_playing Event.MissionStart_BaseLoop_Hospital");
		ClientCommand(client, "music_dynamic_stop_playing Event.MissionStart_BaseLoop_Airport");
		ClientCommand(client, "music_dynamic_stop_playing Event.MissionStart_BaseLoop_Farm");
		ClientCommand(client, "music_dynamic_stop_playing Event.MissionStart_BaseLoop_Small_Town");
		ClientCommand(client, "music_dynamic_stop_playing Event.MissionStart_BaseLoop_Garage");
		ClientCommand(client, "music_dynamic_stop_playing Event.CheckPointBaseLoop_Hospital");
		ClientCommand(client, "music_dynamic_stop_playing Event.CheckPointBaseLoop_Airport");
		ClientCommand(client, "music_dynamic_stop_playing Event.CheckPointBaseLoop_Small_Town");
		ClientCommand(client, "music_dynamic_stop_playing Event.CheckPointBaseLoop_Farm");
		ClientCommand(client, "music_dynamic_stop_playing Event.CheckPointBaseLoop_Garage");
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat");
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat_A2");
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat_A3");
		ClientCommand(client, "music_dynamic_stop_playing Event.Tank");
		ClientCommand(client, "music_dynamic_stop_playing Event.TankMidpoint");
		ClientCommand(client, "music_dynamic_stop_playing Event.TankBrothers");
		ClientCommand(client, "music_dynamic_stop_playing Event.WitchAttack");
		ClientCommand(client, "music_dynamic_stop_playing Event.WitchBurning");
		ClientCommand(client, "music_dynamic_stop_playing Event.WitchRage");
		ClientCommand(client, "music_dynamic_stop_playing Event.HunterPounce");
		ClientCommand(client, "music_dynamic_stop_playing Event.SmokerChoke");
		ClientCommand(client, "music_dynamic_stop_playing Event.SmokerDrag");
		ClientCommand(client, "music_dynamic_stop_playing Event.VomitInTheFace");
		ClientCommand(client, "music_dynamic_stop_playing Event.LedgeHangTwoHands");
		ClientCommand(client, "music_dynamic_stop_playing Event.LedgeHangOneHand");
		ClientCommand(client, "music_dynamic_stop_playing Event.LedgeHangFingers");
		ClientCommand(client, "music_dynamic_stop_playing Event.LedgeHangAboutToFall");
		ClientCommand(client, "music_dynamic_stop_playing Event.LedgeHangFalling");
		ClientCommand(client, "music_dynamic_stop_playing Event.Down");
		ClientCommand(client, "music_dynamic_stop_playing Event.BleedingOut");
		ClientCommand(client, "music_dynamic_stop_playing Event.Down");
	}
	else if (L4DVersion && GameMode != 2 && !IsFakeClient(client))
	{
		// Music when Mission Starts
		ClientCommand(client, "music_dynamic_stop_playing Event.MissionStart_BaseLoop_Mall");
		ClientCommand(client, "music_dynamic_stop_playing Event.MissionStart_BaseLoop_Fairgrounds");
		ClientCommand(client, "music_dynamic_stop_playing Event.MissionStart_BaseLoop_Plankcountry");
		ClientCommand(client, "music_dynamic_stop_playing Event.MissionStart_BaseLoop_Milltown");
		ClientCommand(client, "music_dynamic_stop_playing Event.MissionStart_BaseLoop_BigEasy");
		
		// Checkpoints
		ClientCommand(client, "music_dynamic_stop_playing Event.CheckPointBaseLoop_Mall");
		ClientCommand(client, "music_dynamic_stop_playing Event.CheckPointBaseLoop_Fairgrounds");
		ClientCommand(client, "music_dynamic_stop_playing Event.CheckPointBaseLoop_Plankcountry");
		ClientCommand(client, "music_dynamic_stop_playing Event.CheckPointBaseLoop_Milltown");
		ClientCommand(client, "music_dynamic_stop_playing Event.CheckPointBaseLoop_BigEasy");
		
		// Zombat
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat_1");
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat_A_1");
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat_B_1");
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat_2");
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat_A_2");
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat_B_2");
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat_3");
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat_A_3");
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat_B_3");
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat_4");
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat_A_4");
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat_B_4");
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat_5");
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat_A_5");
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat_B_5");
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat_6");
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat_A_6");
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat_B_6");
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat_7");
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat_A_7");
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat_B_7");
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat_8");
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat_A_8");
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat_B_8");
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat_9");
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat_A_9");
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat_B_9");
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat_10");
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat_A_10");
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat_B_10");
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat_11");
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat_A_11");
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat_B_11");
		
		// Zombat specific maps
		
		// C1 Mall
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat2_Intro_Mall");
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat3_Intro_Mall");
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat3_A_Mall");
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat3_B_Mall");
		
		// A2 Fairgrounds
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat_Intro_Fairgrounds");
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat_Fairgrounds");
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat_A_Fairgrounds");
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat_B_Fairgrounds");
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat_B_Fairgrounds");
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat2_Intro_Fairgrounds");
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat3_Intro_Fairgrounds");
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat3_A_Fairgrounds");
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat3_B_Fairgrounds");
		
		// C3 Plankcountry
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat_PlankCountry");
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat_A_PlankCountry");
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat_B_PlankCountry");
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat2_Intro_Plankcountry");
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat3_Intro_Plankcountry");
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat3_A_Plankcountry");
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat3_B_Plankcountry");
		
		// A2 Milltown
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat2_Intro_Milltown");
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat3_Intro_Milltown");
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat3_A_Milltown");
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat3_B_Milltown");
		
		// C5 BigEasy
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat2_Intro_BigEasy");
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat3_Intro_BigEasy");
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat3_A_BigEasy");
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat3_B_BigEasy");
		
		// A2 Clown
		ClientCommand(client, "music_dynamic_stop_playing Event.Zombat3_Intro_Clown");
		
		// Death
		
		// ledge hang
		ClientCommand(client, "music_dynamic_stop_playing Event.LedgeHangTwoHands");
		ClientCommand(client, "music_dynamic_stop_playing Event.LedgeHangOneHand");
		ClientCommand(client, "music_dynamic_stop_playing Event.LedgeHangFingers");
		ClientCommand(client, "music_dynamic_stop_playing Event.LedgeHangAboutToFall");
		ClientCommand(client, "music_dynamic_stop_playing Event.LedgeHangFalling");
		
		// Down
		// Survivor is down and being beaten by infected
		
		ClientCommand(client, "music_dynamic_stop_playing Event.Down");
		ClientCommand(client, "music_dynamic_stop_playing Event.BleedingOut");
		
		// Survivor death
		// This is for the death of an individual survivor to be played after the health meter has reached zero
		
		ClientCommand(client, "music_dynamic_stop_playing Event.SurvivorDeath");
		ClientCommand(client, "music_dynamic_stop_playing Event.ScenarioLose");
		
		// Bosses
		
		// Tank
		ClientCommand(client, "music_dynamic_stop_playing Event.Tank");
		ClientCommand(client, "music_dynamic_stop_playing Event.TankMidpoint");
		ClientCommand(client, "music_dynamic_stop_playing Event.TankBrothers");
		ClientCommand(client, "music_dynamic_stop_playing C2M5.RidinTank1");
		ClientCommand(client, "music_dynamic_stop_playing C2M5.RidinTank2");
		ClientCommand(client, "music_dynamic_stop_playing C2M5.BadManTank1");
		ClientCommand(client, "music_dynamic_stop_playing C2M5.BadManTank2");
		
		// Witch
		ClientCommand(client, "music_dynamic_stop_playing Event.WitchAttack");
		ClientCommand(client, "music_dynamic_stop_playing Event.WitchBurning");
		ClientCommand(client, "music_dynamic_stop_playing Event.WitchRage");
		ClientCommand(client, "music_dynamic_stop_playing Event.WitchDead");
		
		// mobbed
		ClientCommand(client, "music_dynamic_stop_playing Event.Mobbed");
		
		// Hunter
		ClientCommand(client, "music_dynamic_stop_playing Event.HunterPounce");
		
		// Smoker
		ClientCommand(client, "music_dynamic_stop_playing Event.SmokerChoke");
		ClientCommand(client, "music_dynamic_stop_playing Event.SmokerDrag");
		
		// Boomer
		ClientCommand(client, "music_dynamic_stop_playing Event.VomitInTheFace");
		
		// Charger
		ClientCommand(client, "music_dynamic_stop_playing Event.ChargerSlam");
		
		// Jockey
		ClientCommand(client, "music_dynamic_stop_playing Event.JockeyRide");
		
		// Spitter
		ClientCommand(client, "music_dynamic_stop_playing Event.SpitterSpit");
		ClientCommand(client, "music_dynamic_stop_playing Event.SpitterBurn");
	}
	
	return Plugin_Continue;
}

public Action:evtBotReplacedPlayer(Handle:event, const String:name[], bool:dontBroadcast)
{
	// The purpose of using this event, is to prevent a bot from ghosting after the player leaves or joins another team
	
	new bot = GetClientOfUserId(GetEventInt(event, "bot"));
	AlreadyGhostedBot[bot] = true;
}

public Action:DisposeOfCowards(Handle:timer, any:coward)
{
	if (IsClientInGame(coward) && IsFakeClient(coward) && GetClientTeam(coward) == TEAM_INFECTED && !IsPlayerTank(coward) && GetClientHealth(coward)>1)
	{
		// Check to see if the infected thats about to be slain sees the survivors. If so, kill the timer and make a new one.
		new threats = GetEntData(coward, FindSendPropInfo("CTerrorPlayer", "m_hasVisibleThreats"));
		
		if (threats)
		{
			FightOrDieTimer[coward] = INVALID_HANDLE;
			FightOrDieTimer[coward] = CreateTimer(GetConVarFloat(h_idletime_b4slay), DisposeOfCowards, coward);
			#if DEBUG
			PrintToChatAll("%N saw survivors after timer is up, creating new timer", coward);
			#endif
			return;
		}
		else
		{
			CreateTimer(0.1, kickbot, coward);
			if (!DirectorSpawn)
			{
				new SpawnTime = GetURandomIntRange(GetConVarInt(h_InfectedSpawnTimeMin), GetConVarInt(h_InfectedSpawnTimeMax));
				CreateTimer(float(SpawnTime), Spawn_InfectedBot, _, 0);
				InfectedBotQueue++;
				
				#if DEBUG
				PrintToChatAll("Kicked bot %N for not attacking", coward);
				PrintToChatAll("An infected bot has been added to the spawn queue due to lifespan timer expiring");
				#endif
			}
		}
	}
	FightOrDieTimer[coward] = INVALID_HANDLE;
}

public Action:Timer_SetUpBotGhost(Handle:timer, any:client)
{
	// This will set the bot a ghost, stop the bot's movement, and waits until it can spawn
	if (IsValidEntity(client))
	{
		if (!AlreadyGhostedBot[client])
		{
			SetGhostStatus(client, true);
			SetEntityMoveType(client, MOVETYPE_NONE);
			CreateTimer(GetConVarFloat(h_BotGhostTime), Timer_RestoreBotGhost, client, TIMER_FLAG_NO_MAPCHANGE);
		}
		else
		AlreadyGhostedBot[client] = false;
	}
}

public Action:Timer_RestoreBotGhost(Handle:timer, any:client)
{
	if (IsValidEntity(client))
	{
		SetGhostStatus(client, false);
		SetEntityMoveType(client, MOVETYPE_WALK);
	}
}

// The FreeSpawn ensure actions make sure that players spawn into ghosts (L4D 1 only)

public Action:FreeSpawnEnsure(Handle:timer, any:client)
{
	ClientCommand(client, "+use");
	ClientCommand(client, "-use");
	
	if (!IsPlayerGhost(client))
		CreateTimer(0.1, FreeSpawnEnsure2, client, TIMER_FLAG_NO_MAPCHANGE);
	
}

public Action:FreeSpawnEnsure2(Handle:timer, any:client)
{
	if (IsValidEntity(client))
	{
		SetEntProp(client,Prop_Send,"m_isCulling",1);
		ClientCommand(client, "+use");
		
		CreateTimer(0.1, FreeSpawnEnsure, client, TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action:evtPlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	// If round has ended .. we ignore this
	if (b_HasRoundEnded || !b_LeftSaveRoom) return Plugin_Continue;
	
	// We get the client id and time
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (FightOrDieTimer[client] != INVALID_HANDLE)
	{
		KillTimer(FightOrDieTimer[client]);
		FightOrDieTimer[client] = INVALID_HANDLE;
	}
	
	if (!client || !IsClientInGame(client) || GetClientTeam(client)!=TEAM_INFECTED) return Plugin_Continue;
	
	/*
	if (!DirectorSpawn)
	{
	if (L4DVersion)
	{
	if (IsPlayerBoomer(client))
	{
	canSpawnBoomer = false;
	CreateTimer(float(GetConVarInt(h_InfectedSpawnTimeMin)), ResetSpawnRestriction, 3);
	#if DEBUG
	LogMessage("Boomer died, setting spawn restrictions");
	#endif
	}
	else if (IsPlayerSmoker(client))
	{
	canSpawnSmoker = false;
	CreateTimer(float(GetConVarInt(h_InfectedSpawnTimeMin)), ResetSpawnRestriction, 2);
	}
	else if (IsPlayerHunter(client))
	{
	canSpawnHunter = false;
	CreateTimer(float(GetConVarInt(h_InfectedSpawnTimeMin)), ResetSpawnRestriction, 1);
	}
	else if (IsPlayerSpitter(client))
	{
	canSpawnSpitter = false;
	CreateTimer(float(GetConVarInt(h_InfectedSpawnTimeMin)), ResetSpawnRestriction, 4);
	}
	else if (IsPlayerJockey(client))
	{
	canSpawnJockey = false;
	CreateTimer(float(GetConVarInt(h_InfectedSpawnTimeMin)), ResetSpawnRestriction, 5);
	}
	else if (IsPlayerCharger(client))
	{
	canSpawnCharger = false;
	CreateTimer(float(GetConVarInt(h_InfectedSpawnTimeMin)), ResetSpawnRestriction, 6);
	}
	}
	else
	{
	if (IsPlayerBoomer(client))
	{
	canSpawnBoomer = false;
	CreateTimer(float(GetConVarInt(h_InfectedSpawnTimeMin) * 0), ResetSpawnRestriction, 3);
	#if DEBUG
	LogMessage("Boomer died, setting spawn restrictions");
	#endif
	}
	else if (IsPlayerSmoker(client))
	{
	canSpawnSmoker = false;
	CreateTimer(float(GetConVarInt(h_InfectedSpawnTimeMin) * 0), ResetSpawnRestriction, 2);
	}
	}
	}
	*/
	if (IsPlayerTank(client))
	{
		TankWasSeen[client] = false;
	}
	
	// if victim was a bot, we setup a timer to spawn a new bot ...
	if (GetEventBool(event, "victimisbot") && (GameMode == 2) && (!DirectorSpawn))
	{
		if (!IsPlayerTank(client))
		{
			new SpawnTime = GetURandomIntRange(GetConVarInt(h_InfectedSpawnTimeMin), GetConVarInt(h_InfectedSpawnTimeMax));
			CreateTimer(float(SpawnTime), Spawn_InfectedBot, _, 0);
			InfectedBotQueue++;
		}
		
		#if DEBUG
		PrintToChatAll("An infected bot has been added to the spawn queue...");
		#endif
	}
	// This spawns a bot in coop/survival regardless if the special that died was controlled by a player, MI 5
	else if ((GameMode != 2) && (!DirectorSpawn))
	{
		if (!GetConVarBool(h_CoopPlayableTank) && !IsPlayerTank(client) || GetConVarBool(h_CoopPlayableTank))
		{
			new SpawnTime = GetURandomIntRange(GetConVarInt(h_InfectedSpawnTimeMin), GetConVarInt(h_InfectedSpawnTimeMax));
			CreateTimer(float(SpawnTime), Spawn_InfectedBot, _, 0);
			GetSpawnTime[client] = SpawnTime;
			InfectedBotQueue++;
		}
		
		#if DEBUG
		PrintToChatAll("An infected bot has been added to the spawn queue...");
		#endif
	}
	else if (GameMode != 2 && DirectorSpawn)
	{
		new SpawnTime = GetURandomIntRange(GetConVarInt(h_InfectedSpawnTimeMin), GetConVarInt(h_InfectedSpawnTimeMax));
		GetSpawnTime[client] = SpawnTime;
	}
	
	//This will prevent the stats board from coming up if the cvar was set to 1 (L4D 1 only)
	if (!L4DVersion && !IsFakeClient(client) && !GetConVarBool(h_StatsBoard) && GameMode != 2)
	{
		CreateTimer(1.0, ZombieClassTimer, client, TIMER_FLAG_NO_MAPCHANGE);
	}
	
	// Removes Sphere bubbles in the map when a player dies
	if (GameMode != 2)
	{
		CreateTimer(0.1, ScrimmageTimer, client, TIMER_FLAG_NO_MAPCHANGE);
	}
	
	// This fixes the spawns when the spawn timer is set to 5 or below
	if (IsFakeClient(client))
		CreateTimer(0.1, kickbot, client);
	
	return Plugin_Continue;
}

public Action:Spawn_InfectedBot_Director(Handle:timer, any:BotNeeded)
{
	
	new bool:resetGhost[MAXPLAYERS+1];
	new bool:resetLife[MAXPLAYERS+1];
	
	for (new i=1;i<=MaxClients;i++)
	{
		if (IsClientInGame(i) && (!IsFakeClient(i))) // player is connected and is not fake and it's in game ...
		{
			// If player is on infected's team and is dead ..
			if (GetClientTeam(i)==TEAM_INFECTED)
			{
				// If player is a ghost ....
				if (IsPlayerGhost(i))
				{
					resetGhost[i] = true;
					SetGhostStatus(i, false);
				}
				else if (GetClientHealth(i) <= 1 && respawnDelay[i] > 0 && GameMode != 2)
				{
					resetLife[i] = true;
					SetLifeState(i, false);
					#if DEBUG
					LogMessage("Detected a dead player with a respawn timer, setting restrictions to prevent player from taking a bot");
					#endif
				}
				else if (GetClientHealth(i) <= 1 && respawnDelay[i] <= 0)
				{
					AlreadyGhosted[i] = false;
					SetLifeState(i, true);
				}
			}
		}
	}
	
	new anyclient = GetAnyClient();
	new bool:temp = false;
	if (!anyclient)
	{
		#if DEBUG
		LogMessage("[Infected bots] Creating temp client to fake command");
		#endif
		
		// we create a fake client
		anyclient = CreateFakeClient("Bot");
		if (anyclient == 0)
		{
			LogError("[L4D] Infected Bots: CreateFakeClient returned 0 -- Infected bot was not spawned");
		}
		temp = true;
	}
	
	SpecialHalt = true;
	
	switch (BotNeeded)
	{
		case 1: // Smoker
		CheatCommand(anyclient, "z_spawn", "smoker auto");
		case 2: // Boomer
		CheatCommand(anyclient, "z_spawn", "boomer auto");
		case 3: // Hunter
		CheatCommand(anyclient, "z_spawn", "hunter auto");
		case 4: // Spitter
		CheatCommand(anyclient, "z_spawn", "spitter auto");
		case 5: // Jockey
		CheatCommand(anyclient, "z_spawn", "jockey auto");
		case 6: // Charger
		CheatCommand(anyclient, "z_spawn", "charger auto");
	}
	
	SpecialHalt = false;
	
	// We restore the player's status
	for (new i=1;i<=MaxClients;i++)
	{
		if (resetGhost[i])
			SetGhostStatus(i, true);
		if (resetLife[i])
			SetLifeState(i, true);
	}
	// If client was temp, we setup a timer to kick the fake player
	if (temp) CreateTimer(0.1, kickbot, anyclient);
}

public Action:ZombieClassTimer(Handle:timer, any:client)
{
	if (client)
	{
		SetEntData(client, FindSendPropInfo("CTerrorPlayer", "m_zombieClass"), 0, 1, false);
	}
}

/*
public Action:ResetSpawnRestriction (Handle:timer, any:bottype)
{
#if DEBUG
LogMessage("Resetting spawn restrictions");
#endif
switch (bottype)
{
case 1: // hunter
canSpawnHunter = true;
case 2: // smoker
canSpawnSmoker = true;
case 3: // boomer
canSpawnBoomer = true;
case 4: // spitter
canSpawnSpitter = true;
case 5: // jockey
canSpawnJockey = true;
case 6: // charger
canSpawnCharger = true;
}

}
*/
public Action:evtPlayerTeam(Handle:event, const String:name[], bool:dontBroadcast)
{
	// If player is a bot, we ignore this ...
	if (GetEventBool(event, "isbot")) return Plugin_Continue;
	
	// We get some data needed ...
	new newteam = GetEventInt(event, "team");
	new oldteam = GetEventInt(event, "oldteam");
	
	// We get the client id and time
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	// If player's new/old team is infected, we recount the infected and add bots if needed ...
	if (!b_HasRoundEnded && b_LeftSaveRoom && GameMode == 2)
	{
		if (oldteam == 3||newteam == 3)
		{
			CheckIfBotsNeeded(false);
		}
		if (newteam == 3)
		{
			//Kick Timer
			CreateTimer(1.0, InfectedBotBooterVersus, _, TIMER_FLAG_NO_MAPCHANGE);
			#if DEBUG
			LogMessage("A player switched to infected, attempting to boot a bot");
			#endif
		}
	}
	else if ((newteam == 3 || newteam == 1) && GameMode != 2)
	{
		// Removes Sphere bubbles in the map when a player joins the infected team, or spectator team
		
		CreateTimer(0.1, ScrimmageTimer, client, TIMER_FLAG_NO_MAPCHANGE);
	}
	return Plugin_Continue;
}

public OnClientDisconnect(client)
{
	// If is a bot, skip this function
	if (IsFakeClient(client))
		return;
	
	// When a client disconnects we need to restore their HUD preferences to default for when 
	// a new client joins and fill the space.
	hudDisabled[client] = 0;
	clientGreeted[client] = 0;
	
	// Reset all other arrays
	respawnDelay[client] = 0;
	WillBeTank[client] = false;
	PlayerLifeState[client] = false;
	GetSpawnTime[client] = 0;
	isTankOnFire[client] = false;
	burningTankTimeLeft[client] = 0;
	TankWasSeen[client] = false;
	AlreadyGhosted[client] = false;
	
	// If no real players are left in game ... and we restore sb_all_bot_team, MI 5
	if (!RealPlayersInGame(client))
	{	
		SetConVarInt(FindConVar("sb_all_bot_team"), 0);
		GameEnded();
	}
}

GameEnded()
{
	#if DEBUG
	LogMessage("Game ended");
	#endif
	b_LeftSaveRoom = false;
	b_HasRoundEnded = true;
	b_HasRoundStarted = false;
	roundInProgress = false;
	
	// Zero all respawn times ready for the next round
	for (new i = 1; i <= MaxClients; i++)
	{
		respawnDelay[i] = 0;
		isTankOnFire[i] = false;
		burningTankTimeLeft[i] = 0;
		TankWasSeen[i] = false;
		AlreadyGhosted[i] = false;
	}
	
	for (new i = 1; i <= MaxClients; i++)
	{
		if (FightOrDieTimer[i] != INVALID_HANDLE)
		{
			KillTimer(FightOrDieTimer[i]);
			FightOrDieTimer[i] = INVALID_HANDLE;
		}
	}
	
	// This I set in because the panel was never originally designed for multiple gamemodes.
	CreateTimer(5.0, HUDReset);
}

public Action:ScrimmageTimer (Handle:timer, any:client)
{
	if (client && IsValidEntity(client))
	{
		SetEntData(client, FindSendPropInfo("CTerrorPlayer", "m_scrimmageType"), 0, 1, false);
	}
}

public Action:CheckIfBotsNeededLater (Handle:timer, any:spawn_immediately)
{
	CheckIfBotsNeeded(spawn_immediately);
}

CheckIfBotsNeeded(bool:spawn_immediately)
{
	if (!DirectorSpawn)
	{
		#if DEBUG
		LogMessage("Checking bots");
		#endif
		
		if (b_HasRoundEnded || !b_LeftSaveRoom) return;
		
		// First, we count the infected
		if (GameMode == 2)
		{
			CountInfected();
		}
		else
		{
			CountInfected_Coop();
		}
		
		new diff = MaxPlayerZombies - (InfectedBotCount + InfectedRealCount + InfectedBotQueue);
		
		// If we need more infected bots
		if (diff > 0)
		{
			for (new i;i<diff;i++)
			{
				// If we need them right away ...
				if (spawn_immediately)
				{
					InfectedBotQueue++;
					CreateTimer(0.5, Spawn_InfectedBot, _, 0);
					#if DEBUG
					LogMessage("Setting up the bot now");
					#endif
				}
				else // We use the normal time ..
				{
					InfectedBotQueue++;
					CreateTimer(float(GetConVarInt(h_InfectedSpawnTimeMax)), Spawn_InfectedBot, _, 0);
				}
			}
		}
		
		if (GameMode == 2)
		{
			CountInfected();
		}
	}
}

CountInfected()
{
	// reset counters
	InfectedBotCount = 0;
	InfectedRealCount = 0;
	
	// First we count the ammount of infected real players and bots
	for (new i=1;i<=MaxClients;i++)
	{
		// We check if player is in game
		if (!IsClientInGame(i)) continue;
		
		// Check if client is infected ...
		if (GetClientTeam(i) == TEAM_INFECTED)
		{
			// If player is a bot ...
			if (IsFakeClient(i))
				InfectedBotCount++;
			else
			InfectedRealCount++;
		}
	}
	
}

// Note: This function is also used for survival.
CountInfected_Coop()
{
	#if DEBUG
	LogMessage("Counting Bots for Coop");
	#endif
	
	// reset counters
	InfectedBotCount = 0;
	InfectedRealCount = 0;
	
	// First we count the ammount of infected real players and bots
	
	for (new i=1;i<=MaxClients;i++)
	{
		// We check if player is in game
		if (!IsClientInGame(i)) continue;
		
		// Check if client is infected ...
		if (GetClientTeam(i) == TEAM_INFECTED)
		{
			new String:name[MAX_NAME_LENGTH];
			
			GetClientName(i, name, sizeof(name));
			
			if (StrEqual(name, "Infected Bot", true) && IsFakeClient(i))
				continue;
			
			// If someone is a tank and the tank is playable...count him in play
			if (IsPlayerTank(i) && GetClientHealth(i) > 1 && GetConVarBool(h_CoopPlayableTank) && !IsFakeClient(i))
			{
				InfectedRealCount++;
			}
			
			// If player is not a tank or a dead one
			if (!IsPlayerTank(i) || (IsPlayerTank(i) && GetClientHealth(i) <= 1))
			{
				// If player is a bot ...
				if (IsFakeClient(i))
				{
					InfectedBotCount++;
					#if DEBUG
					LogMessage("Found a bot");
					#endif
				}
				else if (GetClientHealth(i) > 1 || (IsPlayerGhost(i)))
				{
					InfectedRealCount++;
					#if DEBUG
					LogMessage("Found a player");
					#endif
				}
			}
		}
	}
}

public Action:TankFrustratedTimer(Handle:timer)
{
	TankFrustStop = false;
}

/*public Action:TankHaltTimer(Handle:timer)
{
TankHalt = false;
}*/

// This code here is to prevent a loop when the tank gets frustrated. Apparently the game counts a tank being frustrated as a spawned tank, and triggers the tank spawn
// event. That may be why the rescue vehicle sometimes arrives earlier than expected

public Action:evtTankFrustrated(Handle:event, const String:name[], bool:dontBroadcast)
{
	TankFrustStop = true;
	#if DEBUG
	LogMessage("Tank is frustrated!");
	#endif
	CreateTimer(2.0, TankFrustratedTimer, _, TIMER_FLAG_NO_MAPCHANGE);
}

// The main Tank code, it allows a player to take over the tank when if allowed, and adds additional tanks if the tanks per spawn cvar was set.
public Action:TankSpawner(Handle:timer, any:client)
{
	#if DEBUGTANK
	LogMessage("Tank Spawner Triggred");
	#endif
	new Index[8];
	new IndexCount = 0;
	decl Float:position[3];
	new tankhealth;
	new bool:tankonfire;
	
	if (client && IsClientInGame(client))
	{
		tankhealth = GetClientHealth(client);
		GetClientAbsOrigin(client, position);
		if ((GetEntData(client, FindSendPropOffs("CTerrorPlayer", "m_fFlags")) & FL_ONFIRE) && GetClientHealth(client) > 1)
			tankonfire = true;
	}
	
	if (GetConVarBool(h_CoopPlayableTank))
	{
		for (new t=1;t<=MaxClients;t++)
		{
			// We check if player is in game
			if (!IsClientInGame(t)) continue;
			
			// Check if client is infected ...
			if (GetClientTeam(t)!=TEAM_INFECTED) continue;
			
			if (!IsFakeClient(t))
			{
				// If player is not a tank, or a dead one
				if (!IsPlayerTank(t) || (IsPlayerTank(t) && GetClientHealth(t) <= 1))
				{
					IndexCount++; // increase count of valid targets
					Index[IndexCount] = t; //save target to index
					#if DEBUGTANK
					PrintToChatAll("Client %i found to be valid Tank Choice", Index[IndexCount]);
					#endif
				}
			}	
		}
	}
	
	#if DEBUGTANK
	if (GetConVarBool(h_CoopPlayableTank))
	{
		
		PrintToChatAll("Valid Tank Candidates found: %i", IndexCount);
		
	}
	#endif
	
	if (GetConVarBool(h_CoopPlayableTank) && IndexCount != 0 )
	{
		MaxPlayerTank--;
		#if DEBUGTANK
		PrintToChatAll("Tank Kicked");
		#endif
		
		new tank = GetURandomIntRange(1, IndexCount);  // pick someone from the valid targets
		WillBeTank[Index[tank]] = true;
		
		#if DEBUGTANK
		PrintToChatAll("Random Number pulled: %i, from %i", tank, IndexCount);
		PrintToChatAll("Client chosen to be Tank: %i", Index[tank]);
		#endif
		
		if (L4DVersion && IsPlayerJockey(Index[tank]))
		{
			// WE NEED TO DISMOUNT THE JOCKEY OR ELSE BAAAAAAAAAAAAAAAD THINGS WILL HAPPEN
			
			CheatCommand(Index[tank], "dismount");
		}
		
		ChangeClientTeam(Index[tank], TEAM_SPECTATOR);
		ChangeClientTeam(Index[tank], TEAM_INFECTED);
	}
	
	new bool:resetGhost[MAXPLAYERS+1];
	new bool:resetLife[MAXPLAYERS+1];
	
	if (GetConVarBool(h_CoopPlayableTank) && IndexCount != 0)
	{
		for (new i=1;i<=MaxClients;i++)
		{
			if ( IsClientInGame(i) && !IsFakeClient(i)) // player is connected and is not fake and it's in game ...
			{
				// If player is on infected's team and is dead ..
				if ((GetClientTeam(i)==TEAM_INFECTED) && WillBeTank[i] == false)
				{
					// If player is a ghost ....
					if (IsPlayerGhost(i))
					{
						resetGhost[i] = true;
						SetGhostStatus(i, false);
						#if DEBUG
						LogMessage("Player is a ghost, taking preventive measures to prevent the player from taking over the tank");
						#endif
					}
					else if (GetClientHealth(i) <= 1)
					{
						resetLife[i] = true;
						SetLifeState(i, false);
						#if DEBUG
						LogMessage("Dead player found, setting restrictions to prevent the player from taking over the tank");
						#endif
					}
				}
			}
		}
		
		// Find any human client and give client admin rights
		new anyclient = GetAnyClient();
		new bool:temp = false;
		if (!anyclient)
		{
			#if DEBUG
			LogMessage("[Infected bots] Creating temp client to fake command");
			#endif
			// we create a fake client
			anyclient = CreateFakeClient("Bot");
			if (!anyclient)
			{
				LogError("[L4D] Infected Bots: CreateFakeClient returned 0 -- Infected Tank was not spawned");
			}
			temp = true;
		}
		
		CheatCommand(anyclient, "z_spawn", "tank auto");
		
		
		/*if (GetConVarBool(h_CoopPlayableTank))
		{
		TankHalt = true;
		}
		
		// Start the Tank Halt Timer
		CreateTimer(2.0, TankHaltTimer, _, TIMER_FLAG_NO_MAPCHANGE);*/
		
		// We restore the player's status
		for (new i=1;i<=MaxClients;i++)
		{
			if (resetGhost[i] == true)
				SetGhostStatus(i, true);
			if (resetLife[i] == true)
				SetLifeState(i, true);
			if (WillBeTank[i] == true)
			{
				if (client)
				{
					TeleportEntity(i, position, NULL_VECTOR, NULL_VECTOR);
					SetEntityHealth(i, tankhealth);
					if (tankonfire)
						CreateTimer(0.1, PutTankOnFireTimer, i, TIMER_FLAG_NO_MAPCHANGE);
					if (GetConVarBool(h_CoopPlayableTank))
						TankWasSeen[i] = true;
				}
				WillBeTank[i] = false;
				new Handle:datapack = CreateDataPack();
				WritePackCell(datapack, tankhealth);
				WritePackCell(datapack, tankonfire);
				WritePackCell(datapack, i);
				CreateTimer(1.0, TankRespawner, datapack);
			}
		}
		
		// If client was temp, we setup a timer to kick the fake player
		if (temp) CreateTimer(0.1,kickbot,anyclient);
		
		#if DEBUGTANK
		if (IsPlayerTank(client) && IsFakeClient(client))
		{
			PrintToChatAll("Bot Tank Spawn Event Triggered");
		}
		else if (IsPlayerTank(client) && !IsFakeClient(client))
		{
			PrintToChatAll("Human Tank Spawn Event Triggered");
		}
		#endif
	}
	
	MaxPlayerTank = MaxPlayerZombies;
	SetConVarInt(FindConVar("z_max_player_zombies"), MaxPlayerZombies);
}


public Action:TankRespawner(Handle:timer, any:datapack)
{
	// This function is used to check if the tank successfully spawned, and if not, respawn him
	
	// Reset the data pack
	ResetPack(datapack);
	
	new tankhealth = ReadPackCell(datapack);
	new tankonfire = ReadPackCell(datapack);
	new client = ReadPackCell(datapack);
	
	if (IsPlayerTank(client) && PlayerIsAlive(client))
		return;
	
	WillBeTank[client] = true;
	
	new bool:resetGhost[MAXPLAYERS+1];
	new bool:resetLife[MAXPLAYERS+1];
	
	for (new i=1;i<=MaxClients;i++)
	{
		if ( IsClientInGame(i) && !IsFakeClient(i)) // player is connected and is not fake and it's in game ...
		{
			// If player is on infected's team and is dead ..
			if ((GetClientTeam(i)==TEAM_INFECTED) && WillBeTank[i] == false)
			{
				// If player is a ghost ....
				if (IsPlayerGhost(i))
				{
					resetGhost[i] = true;
					SetGhostStatus(i, false);
					#if DEBUG
					LogMessage("Player is a ghost, taking preventive measures to prevent the player from taking over the tank");
					#endif
				}
				else if (GetClientHealth(i) <= 1)
				{
					resetLife[i] = true;
					SetLifeState(i, false);
					#if DEBUG
					LogMessage("Dead player found, setting restrictions to prevent the player from taking over the tank");
					#endif
				}
			}
		}
	}
	
	// Find any human client and give client admin rights
	new anyclient = GetAnyClient();
	new bool:temp = false;
	if (!anyclient)
	{
		#if DEBUG
		LogMessage("[Infected bots] Creating temp client to fake command");
		#endif
		// we create a fake client
		anyclient = CreateFakeClient("Bot");
		if (!anyclient)
		{
			LogError("[L4D] Infected Bots: CreateFakeClient returned 0 -- Infected Tank was not spawned");
		}
		temp = true;
	}
	
	CheatCommand(anyclient, "z_spawn", "tank auto");
	
	
	/*if (GetConVarBool(h_CoopPlayableTank))
	{
	TankHalt = true;
	}
	
	// Start the Tank Halt Timer
	CreateTimer(2.0, TankHaltTimer, _, TIMER_FLAG_NO_MAPCHANGE);*/
	
	// We restore the player's status
	for (new i=1;i<=MaxClients;i++)
	{
		if (resetGhost[i] == true)
			SetGhostStatus(i, true);
		if (resetLife[i] == true)
			SetLifeState(i, true);
		if (WillBeTank[i] == true)
		{
			if (client)
			{
				SetEntityHealth(i, tankhealth);
				if (tankonfire)
					CreateTimer(0.1, PutTankOnFireTimer, i, TIMER_FLAG_NO_MAPCHANGE);
				if (GetConVarBool(h_CoopPlayableTank))
					TankWasSeen[i] = true;
			}
			WillBeTank[i] = false;
			datapack = CreateDataPack();
			WritePackCell(datapack, tankhealth);
			WritePackCell(datapack, tankonfire);
			WritePackCell(datapack, i);
			CreateTimer(1.0, TankRespawner, datapack);
		}
	}
	
	// If client was temp, we setup a timer to kick the fake player
	if (temp) CreateTimer(0.1,kickbot,anyclient);
}

public Action:PutTankOnFireTimer(Handle:Timer, any:client)
{
	IgniteEntity(client, 9999.0);
}

public Action:HookSound_Callback(Clients[64], &NumClients, String:StrSample[PLATFORM_MAX_PATH], &Entity)
{
	if (!b_LeftSaveRoom || GameMode != 1 || !GetConVarBool(h_CoopPlayableTank))
		return Plugin_Continue;
	
	//to work only on tank steps, its Tank_walk
	if (StrContains(StrSample, "Tank_walk", false) == -1) return Plugin_Continue;
	
	for (new i=1;i<=MaxClients;i++)
	{
		// We check if player is in game
		if (!IsClientInGame(i)) continue;
		
		// Check if client is infected ...
		if (GetClientTeam(i)==TEAM_INFECTED)
		{
			// If player is a tank
			if (IsPlayerTank(i) && GetClientHealth(i) > 1 && TankWasSeen[i] == false)
			{
				if (RealPlayersOnInfected() && AreTherePlayersWhoAreNotTanks())
				{
					CreateTimer(0.2, kickbot, i);
					CreateTimer(0.1, TankSpawner, i);
				}
			}
		}
	}
	return Plugin_Continue;
}


// This event serves to make sure the bots spawn at the start of the finale event. The director disallows spawning until the survivors have started the event, so this was
// definitely needed.
public Action:evtFinaleStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	FinaleStarted = true;
	if (GetConVarBool(h_InstantSpawn))
		CreateTimer(1.0, CheckIfBotsNeededLater, true);
	else
	CreateTimer(1.0, CheckIfBotsNeededLater, false);
}

// This code was to fix an unintentional bug in Left 4 Dead. If it is coop, and the finale started with the survivors lost, the screen will stay stuck looking at the 
// finale and would not move at all. The only way to fix this is to either change the map, or spawn the infected as ghosts...which I have done here. However, if free 
// spawning is off, it will make the infected spawn normal again after the first spawn. (L4D 1 only)

// L4D2 Notes: This bug has been fixed.
public Action:evtMissionLost(Handle:event, const String:name[], bool:dontBroadcast)
{
	for (new i=1;i<=MaxClients;i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i)) // player is connected and is not fake and it's in game ...
		{
			// If player is on infected's team
			if (GetClientTeam(i)==TEAM_INFECTED)
			{
				if (!L4DVersion && FinaleStarted)
				{
					PrintToChat(i, "\x04[SM] \x03 Infected Bots: \x04Please wait, you will spawn as a \x03ghost \x04shortly to get by the finale glitch");
					if (!GetConVarBool(h_FreeSpawn))
					{
						FreeSpawnReset[i] = true;
					}
					#if DEBUG
					LogMessage("Mission lost on the finale");
					#endif
				}
				respawnDelay[i] = 0;
			}
		}
	}
}

BotTypeNeeded()
{
	#if DEBUG
	LogMessage("Determining Bot type now");
	#endif
	
	// current count ...
	new boomers=0;
	new smokers=0;
	new hunters=0;
	new spitters=0;
	new jockeys=0;
	new chargers=0;
	
	for (new i=1;i<=MaxClients;i++)
	{
		// if player is connected and ingame ...
		if (IsClientInGame(i))
		{
			// if player is on infected's team
			if (GetClientTeam(i) == TEAM_INFECTED)
			{
				// We count depending on class ...
				if (IsPlayerSmoker(i) && GetClientHealth(i) > 1)
					smokers++;
				else if (IsPlayerBoomer(i) && GetClientHealth(i) > 1)
					boomers++;	
				else if (IsPlayerHunter(i) && GetClientHealth(i) > 1)
					hunters++;	
				else if (L4DVersion && IsPlayerSpitter(i) && GetClientHealth(i) > 1)
					spitters++;	
				else if (L4DVersion && IsPlayerJockey(i) && GetClientHealth(i) > 1)
					jockeys++;	
				else if (L4DVersion && IsPlayerCharger(i) && GetClientHealth(i) > 1)
					chargers++;	
			}
		}
	}
	
	if  (L4DVersion)
	{
		new random = GetURandomIntRange(1, 6);
		
		if (random == 2)
		{
			if ((smokers < SmokerLimit) && (canSpawnSmoker))
			{
				#if DEBUG
				LogMessage("Bot type returned Smoker");
				#endif
				return 2;
			}
		}
		else if (random == 3)
		{
			if ((boomers < BoomerLimit) && (canSpawnBoomer))
			{
				#if DEBUG
				LogMessage("Bot type returned Boomer");
				#endif
				return 3;
			}
		}
		else if (random == 1)
		{
			if ((hunters < HunterLimit) && (canSpawnHunter))
			{
				#if DEBUG
				LogMessage("Bot type returned Hunter");
				#endif
				return 1;
			}
		}
		else if (random == 4)
		{
			if ((spitters < SpitterLimit) && (canSpawnSpitter))
			{
				#if DEBUG
				LogMessage("Bot type returned Spitter");
				#endif
				return 4;
			}
		}
		else if (random == 5)
		{
			if ((jockeys < JockeyLimit) && (canSpawnJockey))
			{
				#if DEBUG
				LogMessage("Bot type returned Jockey");
				#endif
				return 5;
			}
		}
		else if (random == 6)
		{
			if ((chargers < ChargerLimit) && (canSpawnCharger))
			{
				#if DEBUG
				LogMessage("Bot type returned Charger");
				#endif
				return 6;
			}
		}
		
		return BotTypeNeeded();
	}
	else
	{
		new random = GetURandomIntRange(1, 3);
		
		if (random == 2)
		{
			if ((smokers < SmokerLimit) && (canSpawnSmoker)) // we need a smoker ???? can we spawn a smoker ??? is smoker bot allowed ??
			{
				#if DEBUG
				LogMessage("Returning Smoker");
				#endif
				return 2;
			}
		}
		else if (random == 3)
		{
			if ((boomers < BoomerLimit) && (canSpawnBoomer))
			{
				#if DEBUG
				LogMessage("Returning Boomer");
				#endif
				return 3;
			}
		}
		else if (random == 1)
		{
			if (hunters < HunterLimit && canSpawnHunter)
			{
				#if DEBUG
				LogMessage("Returning Hunter");
				#endif
				return 1;
			}
		}
		
		return BotTypeNeeded();
	}
}


public Action:Spawn_InfectedBot(Handle:timer)
{
	// If round has ended, we ignore this request ...
	if (b_HasRoundEnded || !b_HasRoundStarted || !b_LeftSaveRoom) return;
	
	new Infected = MaxPlayerZombies;
	
	if (GetConVarBool(h_Coordination) && !DirectorSpawn && !InitialSpawn && !PlayerReady())
	{
		BotReady++;
		
		for (new i=1;i<=MaxClients;i++)
		{
			// We check if player is in game
			if (!IsClientInGame(i)) continue;
			
			// Check if client is infected ...
			if (GetClientTeam(i)==TEAM_INFECTED)
			{
				// If player is a real player 
				if (!IsFakeClient(i))
					Infected--;
			}
		}
		
		if (BotReady >= Infected)
		{
			CreateTimer(3.0, BotReadyReset, _, TIMER_FLAG_NO_MAPCHANGE);
		}
		else
		{
			InfectedBotQueue--;
			return;
		}
	}
	
	// First we get the infected count
	if (GameMode == 2)
	{
		CountInfected();
	}
	else
	{
		CountInfected_Coop();
	}
	// If infected's team is already full ... we ignore this request (a real player connected after timer started ) ..
	if ((InfectedRealCount + InfectedBotCount) >= MaxPlayerZombies || (InfectedRealCount + InfectedBotCount + InfectedBotQueue) > MaxPlayerZombies) 	
	{
		#if DEBUG
		LogMessage("We found a player, don't spawn a bot");
		#endif
		InfectedBotQueue--;
		return;
	}
	
	// Before spawning the bot, we determine if an real infected player is dead, since the new infected bot will be controlled by this player
	new bool:resetGhost[MAXPLAYERS+1];
	new bool:resetLife[MAXPLAYERS+1];
	
	for (new i=1;i<=MaxClients;i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i)) // player is connected and is not fake and it's in game ...
		{
			// If player is on infected's team and is dead ..
			if (GetClientTeam(i) == TEAM_INFECTED)
			{
				// If player is a ghost ....
				if (IsPlayerGhost(i))
				{
					resetGhost[i] = true;
					SetGhostStatus(i, false);
					#if DEBUG
					LogMessage("Player is a ghost, taking preventive measures for spawning an infected bot");
					#endif
				}
				else if (GetClientHealth(i) <= 1 && GameMode == 2) // if player is just dead
				{
					resetLife[i] = true;
					SetLifeState(i, false);
				}
				else if (GetClientHealth(i) <= 1 && respawnDelay[i] > 0)
				{
					resetLife[i] = true;
					SetLifeState(i, false);
					#if DEBUG
					LogMessage("Found a dead player, spawn time has not reached zero, delaying player to Spawn an infected bot");
					#endif
				}
				else if (GetClientHealth(i) <= 1 && respawnDelay[i] <= 0)
				{
					AlreadyGhosted[i] = false;
					SetLifeState(i, true);
				}
			}
		}
	}
	
	// We get any client ....
	new anyclient = GetAnyClient();
	new bool:temp = false;
	if (!anyclient)
	{
		#if DEBUG
		LogMessage("[Infected bots] Creating temp client to fake command");
		#endif
		// we create a fake client
		anyclient = CreateFakeClient("Bot");
		if (!anyclient)
		{
			LogError("[L4D] Infected Bots: CreateFakeClient returned 0 -- Infected bot was not spawned");
			return;
		}
		temp = true;
	}
	
	if (L4DVersion && GameMode != 2)
	{
		new bot = CreateFakeClient("Infected Bot");
		if (bot != 0)
		{
			ChangeClientTeam(bot,TEAM_INFECTED);
			CreateTimer(0.1,kickbot,bot);
		}
	}
	
	// Determine the bot class needed ...
	new bot_type = BotTypeNeeded();
	
	// We spawn the bot ...
	switch (bot_type)
	{
		case 0: // Nothing
		{
			#if DEBUG
			PrintToChatAll("Bot_type returned NOTHING!");
			#endif
		}
		case 1: // Hunter
		{
			#if DEBUG
			LogMessage("Spawning Hunter");
			#endif
			CheatCommand(anyclient, "z_spawn", "hunter auto");
		}
		case 2: // Smoker
		{	
			#if DEBUG
			LogMessage("Spawning Smoker");
			#endif
			CheatCommand(anyclient, "z_spawn", "smoker auto");
		}
		case 3: // Boomer
		{
			#if DEBUG
			LogMessage("Spawning Boomer");
			#endif
			CheatCommand(anyclient, "z_spawn", "boomer auto");
		}
		case 4: // Spitter
		{
			#if DEBUG
			LogMessage("Spawning Spitter");
			#endif
			CheatCommand(anyclient, "z_spawn", "spitter auto");
		}
		case 5: // Jockey
		{
			#if DEBUG
			LogMessage("Spawning Jockey");
			#endif
			CheatCommand(anyclient, "z_spawn", "jockey auto");
		}
		case 6: // Charger
		{
			#if DEBUG
			LogMessage("Spawning Charger");
			#endif
			CheatCommand(anyclient, "z_spawn", "charger auto");
		}
	}
	
	// We restore the player's status
	for (new i=1;i<=MaxClients;i++)
	{
		if (resetGhost[i] == true)
			SetGhostStatus(i, true);
		if (resetLife[i] == true)
			SetLifeState(i, true);
	}
	
	// If client was temp, we setup a timer to kick the fake player
	if (temp) CreateTimer(0.1,kickbot,anyclient);
	
	// Debug print
	#if DEBUG
	PrintToChatAll("Spawning an infected bot. Type = %i ", bot_type);
	#endif
	
	// We decrement the infected queue
	InfectedBotQueue--;
	
	CreateTimer(1.0, CheckIfBotsNeededLater, true);
}

stock GetAnyClient()
{
	#if DEBUG
	LogMessage("[Infected bots] Looking for any real client to fake command");
	#endif
	for (new i=1;i<=MaxClients;i++)
	{
		if (IsClientInGame(i) && (!IsFakeClient(i)))
		{
			return i;
		}
	}
	return 0;
}

public Action:kickbot(Handle:timer, any:client)
{
	if (IsClientInGame(client) && (!IsClientInKickQueue(client)))
	{
		if (IsFakeClient(client)) KickClient(client);
	}
}

bool:IsPlayerGhost (client)
{
	if (GetEntData(client, FindSendPropInfo("CTerrorPlayer", "m_isGhost"), 1))
		return true;
	return false;
}

bool:PlayerIsAlive (client)
{
	if (GetClientHealth(client) > 1)
		return true;
	return false;
}

bool:IsPlayerSmoker (client)
{
	if(GetEntProp(client,Prop_Send,"m_zombieClass") == ZOMBIECLASS_SMOKER)
		return true;
	return false;
}

bool:IsPlayerBoomer (client)
{
	if(GetEntProp(client,Prop_Send,"m_zombieClass") == ZOMBIECLASS_BOOMER)
		return true;
	return false;
}

bool:IsPlayerHunter (client)
{
	if(GetEntProp(client,Prop_Send,"m_zombieClass") == ZOMBIECLASS_HUNTER)
		return true;
	return false;
}

bool:IsPlayerSpitter (client)
{
	if(GetEntProp(client,Prop_Send,"m_zombieClass") == ZOMBIECLASS_SPITTER)
		return true;
	return false;
}

bool:IsPlayerJockey (client)
{
	if(GetEntProp(client,Prop_Send,"m_zombieClass") == ZOMBIECLASS_JOCKEY)
		return true;
	return false;
}

bool:IsPlayerCharger (client)
{
	if(GetEntProp(client,Prop_Send,"m_zombieClass") == ZOMBIECLASS_CHARGER)
		return true;
	return false;
}

bool:IsPlayerTank (client)
{
	if(GetEntProp(client,Prop_Send,"m_zombieClass") == ZOMBIECLASS_TANK)
		return true;
	return false;
}

SetGhostStatus (client, bool:ghost)
{
	if (ghost)
		SetEntData(client, FindSendPropInfo("CTerrorPlayer", "m_isGhost"), 1, 1, true);
	else
	SetEntData(client, FindSendPropInfo("CTerrorPlayer", "m_isGhost"), 0, 1, false);
}

SetLifeState (client, bool:ready)
{
	if (ready)
		SetEntData(client, FindSendPropInfo("CTerrorPlayer", "m_lifeState"), 1, 1, true);
	else
	SetEntData(client, FindSendPropInfo("CTerrorPlayer", "m_lifeState"), 0, 1, false);
}

bool:RealPlayersInGame (client)
{
	
	for (new i=1;i<=MaxClients;i++)
	{
		if (i != client)
		{
			if (IsClientConnected(i) && IsClientInGame(i) && !IsFakeClient(i))
				return true;
		}
	}
	
	return false;
}

bool:RealPlayersOnSurvivors ()
{
	for (new i=1;i<=MaxClients;i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i))
			if (GetClientTeam(i) == TEAM_SURVIVORS)
				return true;
		}
	return false;
}

TrueNumberOfSurvivors ()
{
	new TotalSurvivors;
	for (new i=1;i<=MaxClients;i++)
	{
		if (IsClientInGame(i))
			if (GetClientTeam(i) == TEAM_SURVIVORS)
				TotalSurvivors++;
		}
	return TotalSurvivors;
}

HumansOnInfected ()
{
	new TotalHumans;
	for (new i=1;i<=MaxClients;i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i) == TEAM_INFECTED && !IsFakeClient(i))
			TotalHumans++;
	}
	return TotalHumans;
}

bool:AllSurvivorsDeadOrIncapacitated ()
{
	new PlayerIncap;
	new PlayerDead;
	
	for (new i=1;i<=MaxClients;i++)
	{
		if (IsClientInGame(i) && IsFakeClient(i))
			if (GetClientTeam(i) == TEAM_SURVIVORS)
		{
			if (GetEntProp(i, Prop_Send, "m_isIncapacitated"))
			{
				PlayerIncap++;
			}
			else if (GetClientHealth(i) <= 1)
			{
				PlayerDead++;
			}
		}
	}
	
	if (PlayerIncap + PlayerDead == TrueNumberOfSurvivors())
	{
		return true;
	}
	return false;
}

bool:RealPlayersOnInfected ()
{
	for (new i=1;i<=MaxClients;i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i))
			if (GetClientTeam(i) == TEAM_INFECTED)
				return true;
		}
	return false;
}

bool:AreTherePlayersWhoAreNotTanks ()
{
	for (new i=1;i<=MaxClients;i++)
	{	
		if (IsClientInGame(i) && !IsFakeClient(i))
		{
			if (GetClientTeam(i) == TEAM_INFECTED)
			{
				if (!IsPlayerTank(i) || IsPlayerTank(i) && GetClientHealth(i) <= 1)
					return true;
			}
		}
	}
	return false;
}

bool:BotsAlive ()
{
	for (new i=1;i<=MaxClients;i++)
	{
		if (IsClientInGame(i) && IsFakeClient(i))
			if (GetClientTeam(i) == TEAM_INFECTED)
				return true;
		}
	return false;
}

MoreThanFivePlayers()
{
	new InfectedReal;
	// First we count the ammount of infected real players and bots
	for (new i=1;i<=MaxClients;i++)
	{
		// We check if player is in game
		if (!IsClientInGame(i)) continue;
		
		// Check if client is infected human...
		if (GetClientTeam(i) == TEAM_INFECTED && !IsFakeClient(i))
		{
			InfectedReal++;
		}
	}
	if (InfectedReal > 5)
	{
		return true;
	}
	return false;
}

PlayerReady()
{
	// First we count the ammount of infected real players
	for (new i=1;i<=MaxClients;i++)
	{
		// We check if player is in game
		if (!IsClientInGame(i)) continue;
		
		// Check if client is infected ...
		if (GetClientTeam(i) == TEAM_INFECTED)
		{
			// If player is a real player and is dead...
			if (!IsFakeClient(i) && GetClientHealth(i) <= 1)
			{
				if (!respawnDelay[i])
				{
					return true;
				}
			}
		}
	}
	return false;
}

FindBotToTakeOver()
{
	// First we find a survivor bot
	for (new i=1;i<=MaxClients;i++)
	{
		// We check if player is in game
		if (!IsClientInGame(i)) continue;
		
		// Check if client is survivor ...
		if (GetClientTeam(i) == TEAM_SURVIVORS)
		{
			// If player is a bot and is alive...
			if (IsFakeClient(i) && GetClientHealth(i) > 1)
			{
				return i;
			}
		}
	}
	return 0;
}

bool:LeftStartArea()
{
	new ent = -1, maxents = GetMaxEntities();
	for (new i = MaxClients+1; i <= maxents; i++)
	{
		if (IsValidEntity(i))
		{
			decl String:netclass[64];
			GetEntityNetClass(i, netclass, sizeof(netclass));
			
			if (StrEqual(netclass, "CTerrorPlayerResource"))
			{
				ent = i;
				break;
			}
		}
	}
	
	if (ent > -1)
	{
		new offset = FindSendPropInfo("CTerrorPlayerResource", "m_hasAnySurvivorLeftSafeArea");
		if (offset > 0)
		{
			if (GetEntData(ent, offset))
			{
				if (GetEntData(ent, offset) == 1) return true;
			}
		}
	}
	return false;
}

//---------------------------------------------Durzel's HUD------------------------------------------

public OnPluginEnd()
{
	if (L4DVersion)
	{
		ResetConVar(FindConVar("survival_max_smokers"), true, true);
		ResetConVar(FindConVar("survival_max_boomers"), true, true);
		ResetConVar(FindConVar("survival_max_hunters"), true, true);
		ResetConVar(FindConVar("survival_max_spitters"), true, true);
		ResetConVar(FindConVar("survival_max_jockeys"), true, true);
		ResetConVar(FindConVar("survival_max_chargers"), true, true);
		ResetConVar(FindConVar("survival_max_specials"), true, true);
		ResetConVar(FindConVar("z_smoker_limit"), true, true);
		ResetConVar(FindConVar("z_boomer_limit"), true, true);
		ResetConVar(FindConVar("z_hunter_limit"), true, true);
		ResetConVar(FindConVar("z_spitter_limit"), true, true);
		ResetConVar(FindConVar("z_jockey_limit"), true, true);
		ResetConVar(FindConVar("z_charger_limit"), true, true);
	}
	else
	{
		ResetConVar(FindConVar("holdout_max_smokers"), true, true);
		ResetConVar(FindConVar("holdout_max_boomers"), true, true);
		ResetConVar(FindConVar("holdout_max_hunters"), true, true);
		ResetConVar(FindConVar("holdout_max_specials"), true, true);
		ResetConVar(FindConVar("z_gas_limit"), true, true);
		ResetConVar(FindConVar("z_exploding_limit"), true, true);
		ResetConVar(FindConVar("z_hunter_limit"), true, true);
	}
	ResetConVar(FindConVar("director_no_specials"), true, true);
	ResetConVar(FindConVar("boomer_vomit_delay"), true, true);
	ResetConVar(FindConVar("smoker_tongue_delay"), true, true);
	ResetConVar(FindConVar("hunter_leap_away_give_up_range"), true, true);
	ResetConVar(FindConVar("boomer_exposed_time_tolerance"), true, true);
	ResetConVar(FindConVar("z_hunter_lunge_distance"), true, true);
	ResetConVar(FindConVar("hunter_pounce_ready_range"), true, true);
	ResetConVar(FindConVar("hunter_pounce_loft_rate"), true, true);
	ResetConVar(FindConVar("z_hunter_lunge_stagger_time"), true, true);
	ResetConVar(FindConVar("z_attack_flow_range"), true, true);
	ResetConVar(FindConVar("director_spectate_specials"), true, true);
	ResetConVar(FindConVar("z_spawn_safety_range"), true, true);
	ResetConVar(FindConVar("z_spawn_flow_limit"), true, true);
	//ResetConVar(FindConVar("z_max_player_zombies"), true, true);
	ResetConVar(FindConVar("sb_all_bot_team"), true, true);
	
	// Destroy the persistent storage for client HUD preferences
	if (usrHUDPref != INVALID_HANDLE)
	{
		CloseHandle(usrHUDPref);
	}
	
	#if DEBUGHUD
	PrintToChatAll("\x01\x04[infhud]\x01 [%f] \x03Infected HUD\x01 stopped.", GetGameTime());
	#endif
}

public Menu_InfHUDPanel(Handle:menu, MenuAction:action, param1, param2) { return; }

public Action:TimerAnnounce(Handle:timer, any:client)
{
	if (IsClientInGame(client))
	{
		if (GetClientTeam(client) == TEAM_INFECTED)
		{
			// Show welcoming instruction message to client
			PrintHintText(client, "This server runs \x03Infected Bots v%s\x01 - say !infhud to toggle HUD on/off", PLUGIN_VERSION);
			
			// This client now knows about the mod, don't tell them again for the rest of the game.
			clientGreeted[client] = 1;
		}
	}
}

public cvarZombieHPChanged(Handle:convar, const String:oldValue[], const String:newValue[])
{
	// Handle a sysadmin modifying the special infected max HP cvars
	decl String:cvarStr[255], String:difficulty[100];
	GetConVarName(convar, cvarStr, sizeof(cvarStr));
	GetConVarString(h_Difficulty, difficulty, sizeof(difficulty));
	
	#if DEBUGHUD
	PrintToChatAll("\x01\x04[infhud]\x01 [%f] cvarZombieHPChanged(): Infected HP cvar '%s' changed from '%s' to '%s'", GetGameTime(), cvarStr, oldValue, newValue);
	#endif
	
	if (StrEqual(cvarStr, "z_hunter_health", false))
	{
		zombieHP[0] = StringToInt(newValue);
	}
	else if (StrEqual(cvarStr, "z_smoker_health", false))
	{
		zombieHP[1] = StringToInt(newValue);
	}
	else if (StrEqual(cvarStr, "z_boomer_health", false))
	{
		zombieHP[2] = StringToInt(newValue);
	}
	else if (L4DVersion && StrEqual(cvarStr, "z_spitter_health", false))
	{
		zombieHP[3] = StringToInt(newValue);
	}
	else if (L4DVersion && StrEqual(cvarStr, "z_jockey_health", false))
	{
		zombieHP[4] = StringToInt(newValue);
	}
	else if (L4DVersion && StrEqual(cvarStr, "z_charger_health", false))
	{
		zombieHP[5] = StringToInt(newValue);
	}
	else if (StrEqual(cvarStr, "z_tank_health", false) && GameMode == 2)
	{
		zombieHP[6] = RoundToFloor(StringToInt(newValue) * 1.5);	// Tank health is multiplied by 1.5x in VS
	}
	else if (StrEqual(cvarStr, "z_tank_health", false) && GameMode != 2 && StrContains(difficulty, "Easy", false) != -1)
	{
		zombieHP[6] = RoundToFloor(StringToInt(newValue) * 0.75);
	}
	else if (StrEqual(cvarStr, "z_tank_health", false) && GameMode != 2 && StrContains(difficulty, "Normal", false) != -1)
	{
		zombieHP[6] = RoundToFloor(StringToInt(newValue) * 1.0);
	}
	else if (StrEqual(cvarStr, "z_tank_health", false) && GameMode != 2 && StrContains(difficulty, "Hard", false) != -1)
	{
		zombieHP[6] = RoundToFloor(StringToInt(newValue) * 2.0);
	}
	else if (StrEqual(cvarStr, "z_tank_health", false) && GameMode != 2 && StrContains(difficulty, "Impossible", false) != -1)
	{
		zombieHP[6] = RoundToFloor(StringToInt(newValue) * 2.0);
	}
}

public Action:monitorRespawn(Handle:timer)
{
	// Counts down any active respawn timers
	new foundActiveRTmr = false;
	
	// If round has ended then end timer gracefully
	if (!roundInProgress)
	{
		respawnTimer = INVALID_HANDLE;
		return Plugin_Stop;
	}
	
	for (new i = 1; i <= MaxClients; i++)
	{
		if (respawnDelay[i] > 0)
		{
			respawnDelay[i]--;
			foundActiveRTmr = true;
		}
	}
	
	if (!foundActiveRTmr && (respawnTimer != INVALID_HANDLE))
	{
		// Being a ghost doesn't trigger an event which we can hook (player_spawn fires when player actually spawns),
		// so as a nasty kludge after the respawn timer expires for at least one player we set a timer for 1 second 
		// to update the HUD so it says "SPAWNING"
		if (delayedDmgTimer == INVALID_HANDLE)
		{
			delayedDmgTimer = CreateTimer(1.0, delayedDmgUpdate, _, TIMER_FLAG_NO_MAPCHANGE);
		}
		
		// We didn't decrement any of the player respawn times, therefore we don't 
		// need to run this timer anymore.
		respawnTimer = INVALID_HANDLE;
		return Plugin_Stop;
	}
	else
	{
		if (doomedTankTimer == INVALID_HANDLE) ShowInfectedHUD(2);
	}
	return Plugin_Continue;
}

public Action:doomedTankCountdown(Handle:timer)
{
	// If round has ended then end timer gracefully
	if (!roundInProgress)
	{
		doomedTankTimer = INVALID_HANDLE;
		return Plugin_Stop;
	}
	
	for (new i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || GetClientTeam(i)!=3 || !IsPlayerTank(i))
			continue;
		
		// Counts down the number of seconds before the Tank will die automatically
		// from fire damage (if not before from gun damage)
		if (isTankOnFire[i] == true)
		{
			if (--burningTankTimeLeft[i] < 1)
			{
				// Tank is dead :(
				#if DEBUGHUD
				PrintToChatAll("\x01\x04[infhud]\x01 [%f] Tank died automatically from fire timer expiry.", GetGameTime());
				#endif
				isTankOnFire[i] = false;
				if (!CheckForTanksOnFire())
				{
					doomedTankTimer = INVALID_HANDLE;
					return Plugin_Stop;
				}
			}
			else
			{
				// This is almost the same as the respawnTimer code (which only updates the HUD in one of the two 1-second update
				// timer functions, however there may well be an instance in the game where both the Tank is on fire, and people are
				// respawning - therefore we need to make sure *at least one* of the 1-second timers updates the HUD, so we choose this
				// one (as it's rarer in game and therefore more optimal to do two extra code checks to achieve the same result).
				if (respawnTimer == INVALID_HANDLE || (doomedTankTimer != INVALID_HANDLE && respawnTimer != INVALID_HANDLE))
				{
					ShowInfectedHUD(4);
				}
			}
		}
	}
	
	return Plugin_Continue;
}

public Action:delayedDmgUpdate(Handle:timer) 
{
	delayedDmgTimer = INVALID_HANDLE;
	ShowInfectedHUD(3);
	return Plugin_Handled;
}

public queueHUDUpdate(src)
{
	// queueHUDUpdate basically ensures that we're not constantly refreshing the HUD when there are one or more
	// timers active.  For example, if we have a respawn countdown timer (which is likely at any given time) then
	// there is no need to refresh 
	
	// Don't bother with infected HUD updates if the round has ended.
	if (!roundInProgress) return;
	
	if (respawnTimer == INVALID_HANDLE && doomedTankTimer == INVALID_HANDLE)
	{
		ShowInfectedHUD(src);
		#if DEBUGHUD
	}
	else
	{
		PrintToChatAll("\x01\x04[infhud]\x01 [%f] queueHUDUpdate(): Instant HUD update ignored, 1-sec timer active.", GetGameTime());
		#endif
	}	
}

public Action:showInfHUD(Handle:timer) 
{
	if (roundInProgress)
	{
		ShowInfectedHUD(1);
		return Plugin_Continue;
	}
	else
	{
		infHUDTimer = INVALID_HANDLE;
		return Plugin_Continue;
	}		
}

public Action:Command_Say(client, args)
{
	decl String:clientSteamID[32];
	GetClientAuthString(client, clientSteamID, 32);
	
	if (GetConVarBool(h_InfHUD))
	{
		if (!hudDisabled[client])
		{
			PrintToChat(client, "\x01\x04[infhud]\x01 Infected HUD DISABLED - say !infhud to re-enable.");
			SetTrieValue(usrHUDPref, clientSteamID, 1);
			hudDisabled[client] = 1;
		}
		else
		{
			PrintToChat(client, "\x01\x04[infhud]\x01 Infected HUD ENABLED - say !infhud to disable.");
			RemoveFromTrie(usrHUDPref, clientSteamID);
			hudDisabled[client] = 0;
		}
	}
	else
	{
		// Server admin has disabled Infected HUD server-wide
		PrintToChat(client, "\x01\x04[infhud]\x01 Infected HUD is currently DISABLED on this server for all players.");
	}	
	return Plugin_Handled;
}

public ShowInfectedHUD(src)
{
	if ((!GetConVarBool(h_InfHUD)) || IsVoteInProgress())
	{
		return;
	}
	
	// If no bots are alive, and if there is 5 or less players, no point in showing the HUD
	if (GameMode == 2 && !BotsAlive() && !MoreThanFivePlayers())
	{
		return;
	}
	
	#if DEBUGHUD
	decl String:calledFunc[255];
	switch (src)
	{
		case 1: strcopy(calledFunc, sizeof(calledFunc), "showInfHUD");
		case 2: strcopy(calledFunc, sizeof(calledFunc), "monitorRespawn");
		case 3: strcopy(calledFunc, sizeof(calledFunc), "delayedDmgUpdate");
		case 4: strcopy(calledFunc, sizeof(calledFunc), "doomedTankCountdown");
		case 10: strcopy(calledFunc, sizeof(calledFunc), "queueHUDUpdate - client join");
		case 11: strcopy(calledFunc, sizeof(calledFunc), "queueHUDUpdate - team switch");
		case 12: strcopy(calledFunc, sizeof(calledFunc), "queueHUDUpdate - spawn");
		case 13: strcopy(calledFunc, sizeof(calledFunc), "queueHUDUpdate - death");
		case 14: strcopy(calledFunc, sizeof(calledFunc), "queueHUDUpdate - menu closed");
		case 15: strcopy(calledFunc, sizeof(calledFunc), "queueHUDUpdate - player kicked");
		case 16: strcopy(calledFunc, sizeof(calledFunc), "evtRoundEnd");
		default: strcopy(calledFunc, sizeof(calledFunc), "UNKNOWN");
	}
	
	PrintToChatAll("\x01\x04[infhud]\x01 [%f] ShowInfectedHUD() called by [\x04%i\x01] '\x03%s\x01'", GetGameTime(), src, calledFunc);
	#endif 
	
	new i, iHP;
	decl String:iClass[100], String:lineBuf[100], String:iStatus[15];
	
	// Display information panel to infected clients
	pInfHUD = CreatePanel(GetMenuStyleHandle(MenuStyle_Radio));
	if (GameMode == 2 && !MoreThanFivePlayers())
		SetPanelTitle(pInfHUD, "INFECTED BOTS:");
	else
	SetPanelTitle(pInfHUD, "INFECTED TEAM:");
	DrawPanelItem(pInfHUD, " ", ITEMDRAW_SPACER|ITEMDRAW_RAWLINE);
	
	if (roundInProgress)
	{
		// Loop through infected players and show their status
		for (i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i)) continue;
			if (( MoreThanFivePlayers() && !IsFakeClient(i)) || IsFakeClient(i) || (GameMode != 2 && !IsFakeClient(i)))
			{
				if (GetClientMenu(i) == MenuSource_RawPanel || GetClientMenu(i) == MenuSource_None)
				{
					if (GetClientTeam(i) == TEAM_INFECTED)
					{
						// Work out what they're playing as
						if (IsPlayerHunter(i))
						{
							strcopy(iClass, sizeof(iClass), "Hunter");
							iHP = RoundFloat((float(GetClientHealth(i)) / zombieHP[0]) * 100);
						}
						else if (IsPlayerSmoker(i))
						{
							strcopy(iClass, sizeof(iClass), "Smoker");
							iHP = RoundFloat((float(GetClientHealth(i)) / zombieHP[1]) * 100);
						}
						else if (IsPlayerBoomer(i))
						{
							strcopy(iClass, sizeof(iClass), "Boomer");
							iHP = RoundFloat((float(GetClientHealth(i)) / zombieHP[2]) * 100);
						}
						else if (L4DVersion && IsPlayerSpitter(i)) 
						{
							strcopy(iClass, sizeof(iClass), "Spitter");
							iHP = RoundFloat((float(GetClientHealth(i)) / zombieHP[3]) * 100);	
						}
						else if (L4DVersion && IsPlayerJockey(i)) 
						{
							strcopy(iClass, sizeof(iClass), "Jockey");
							iHP = RoundFloat((float(GetClientHealth(i)) / zombieHP[4]) * 100);	
						} 
						else if (L4DVersion && IsPlayerCharger(i)) 
						{
							strcopy(iClass, sizeof(iClass), "Charger");
							iHP = RoundFloat((float(GetClientHealth(i)) / zombieHP[5]) * 100);	
						} 
						else if (IsPlayerTank(i))
						{
							strcopy(iClass, sizeof(iClass), "Tank");
							iHP = RoundFloat((float(GetClientHealth(i)) / zombieHP[6]) * 100);	
						}
						
						if (GetClientHealth(i) > 1)
						{
							// Check to see if they are a ghost or not
							if (GetEntData(i, FindSendPropInfo("CTerrorPlayer", "m_isGhost"), 1))
							{
								strcopy(iStatus, sizeof(iStatus), "GHOST");
							}
							else Format(iStatus, sizeof(iStatus), "%i%%", iHP);
						}
						else
						{
							if (respawnDelay[i] > 0 && !DirectorSpawn)
							{
								Format(iStatus, sizeof(iStatus), "DEAD (%i)", respawnDelay[i]);
								strcopy(iClass, sizeof(iClass), "");
								// As a failsafe if they're dead/waiting set HP to 0
								iHP = 0;
							} 
							else if (respawnDelay[i] == 0 && GameMode != 2 && !DirectorSpawn)
							{
								Format(iStatus, sizeof(iStatus), "READY");
								strcopy(iClass, sizeof(iClass), "");
								// As a failsafe if they're dead/waiting set HP to 0
								iHP = 0;
							}
							else if (respawnDelay[i] > 0 && DirectorSpawn && GameMode != 2)
							{
								Format(iStatus, sizeof(iStatus), "DELAY (%i)", respawnDelay[i]);
								strcopy(iClass, sizeof(iClass), "");
								// As a failsafe if they're dead/waiting set HP to 0
								iHP = 0;
							} 
							else if (respawnDelay[i] == 0 && DirectorSpawn && GameMode != 2)
							{
								Format(iStatus, sizeof(iStatus), "WAITING");
								strcopy(iClass, sizeof(iClass), "");
								// As a failsafe if they're dead/waiting set HP to 0
								iHP = 0;
							}
							else
							{
								Format(iStatus, sizeof(iStatus), "DEAD");
								strcopy(iClass, sizeof(iClass), "");
								// As a failsafe if they're dead/waiting set HP to 0
								iHP = 0;
							}
						}
						
						// Special case - if player is Tank and on fire, show the countdown
						if (StrContains(iClass, "Tank", false) != -1 && isTankOnFire[i] && GetClientHealth(i) > 0)
						{
							Format(iStatus, sizeof(iStatus), "%s-FIRE(%i)", iStatus, burningTankTimeLeft[i]);
						}
						
						if (IsFakeClient(i))
						{
							Format(lineBuf, sizeof(lineBuf), "%N-%s", i, iStatus);
							DrawPanelItem(pInfHUD, lineBuf);
						}
						else
						{
							Format(lineBuf, sizeof(lineBuf), "%N-%s-%s", i, iClass, iStatus);
							DrawPanelItem(pInfHUD, lineBuf);
						}
					}
				}
				else
				{
					#if DEBUGHUD
					PrintToChat(i, "x01\x04[infhud]\x01 [%f] Not showing infected HUD as vote/menu (%i) is active", GetClientMenu(i), GetGameTime());
					#endif
				}
			}
		}
	}
	
	// Output the current team status to all infected clients
	// Technically the below is a bit of a kludge but we can't be 100% sure that a client status doesn't change
	// between building the panel and displaying it.
	for (i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i))
		{
			if ((GetClientTeam(i) == TEAM_INFECTED || GetClientTeam(i) == TEAM_SPECTATOR) && (hudDisabled[i] == 0) && (GetClientMenu(i) == MenuSource_RawPanel || GetClientMenu(i) == MenuSource_None))
			{	
				SendPanelToClient(pInfHUD, i, Menu_InfHUDPanel, 5);
			}
		}
	}
	CloseHandle(pInfHUD);
}

public Action:evtTeamSwitch(Handle:event, const String:name[], bool:dontBroadcast)
{
	// Check to see if player joined infected team and if so refresh the HUD
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (client)
	{
		if (GetClientTeam(client) == TEAM_INFECTED)
		{
			queueHUDUpdate(11);
		}
		else
		{
			// If player teamswitched to survivor, remove the HUD from their screen
			// immediately to stop them getting an advantage
			if (GetClientMenu(client) == MenuSource_RawPanel)
			{
				CancelClientMenu(client);
			}
		} 
	}
}

public Action:evtInfectedSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	// Infected player spawned, so refresh the HUD
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (client)
	{
		if (GetClientTeam(client) == TEAM_INFECTED)
		{
			queueHUDUpdate(12); 
			// If player joins server and doesn't have to wait to spawn they might not see the announce
			// until they next die (and have to wait).  As a fallback we check when they spawn if they've 
			// already seen it or not.
			if (!clientGreeted[client] && (GetConVarBool(h_Announce)))
			{		
				CreateTimer(3.0, TimerAnnounce, client);	
			}
		}
	}
}

public Action:evtInfectedDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	// Infected player died, so refresh the HUD
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (client)
	{
		if (GetClientTeam(client) == TEAM_INFECTED)
		{
			// If player is tank and dies before the fire would've killed them, kill the fire timer
			if (IsPlayerTank(client) && isTankOnFire[client] && (doomedTankTimer != INVALID_HANDLE))
			{
				#if DEBUGHUD
				PrintToChatAll("\x01\x04[infhud]\x01 [%f] Tank died naturally before fire timer expired.", GetGameTime());
				#endif
				isTankOnFire[client] = false;
				if (!CheckForTanksOnFire())
				{
					KillTimer(doomedTankTimer);
					doomedTankTimer = INVALID_HANDLE;  
				}
			}
			queueHUDUpdate(13);
		}
	}
}

public Action:evtInfectedHurt(Handle:event, const String:name[], bool:dontBroadcast)
{
	// The life of a regular special infected is pretty transient, they won't take many shots before they 
	// are dead (unlike the survivors) so we can afford to refresh the HUD reasonably quickly when they take damage.
	// The exception to this is the Tank - with 5000 health the survivors could be shooting constantly at it 
	// resulting in constant HUD refreshes which is not efficient.  So, we check to see if the entity being 
	// shot is a Tank or not and adjust the non-repeating timer accordingly.
	
	// Don't bother with infected HUD update if the round has ended
	if (!roundInProgress) return;
	
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	
	if (FightOrDieTimer[client] != INVALID_HANDLE)
	{
		KillTimer(FightOrDieTimer[client]);
		FightOrDieTimer[client] = INVALID_HANDLE;
		FightOrDieTimer[client] = CreateTimer(GetConVarFloat(h_idletime_b4slay), DisposeOfCowards, client);
	}
	
	if (FightOrDieTimer[attacker] != INVALID_HANDLE)
	{
		KillTimer(FightOrDieTimer[attacker]);
		FightOrDieTimer[attacker] = INVALID_HANDLE;
		FightOrDieTimer[attacker] = CreateTimer(GetConVarFloat(h_idletime_b4slay), DisposeOfCowards, attacker);
	}
	
	if (client)
	{
		decl Handle:fireTankExpiry, String:difficulty[100];
		GetConVarString(h_Difficulty, difficulty, sizeof(difficulty));
		
		if (GetClientTeam(client) == TEAM_INFECTED)
		{
			if (IsPlayerTank(client) && isTankOnFire[client] == false)
			{
				// If player is a tank and is on fire, we start the 
				// 30-second guaranteed death timer and let his fellow Infected guys know.
				
				new mFlagsOffset = FindSendPropOffs("CTerrorPlayer", "m_fFlags");
				if ((GetEntData(client, mFlagsOffset) & FL_ONFIRE) && GetClientHealth(client) > 1)
				{
					isTankOnFire[client] = true;
					if ((StrContains(difficulty, "Easy", false) != -1) && (GameMode == 1))
					{
						if (L4DVersion)
							fireTankExpiry = FindConVar("tank_burn_duration");
						else
						fireTankExpiry = FindConVar("tank_burn_duration_normal");
					}
					else if ((StrContains(difficulty, "Normal", false) != -1) && (GameMode == 1))
					{
						if (L4DVersion)
							fireTankExpiry = FindConVar("tank_burn_duration");
						else
						fireTankExpiry = FindConVar("tank_burn_duration_normal");
					}
					else if ((StrContains(difficulty, "Hard", false) != -1) && (GameMode == 1))
					{
						fireTankExpiry = FindConVar("tank_burn_duration_hard");
					}
					else if ((StrContains(difficulty, "Impossible", false) != -1) && (GameMode == 1))
					{
						fireTankExpiry = FindConVar("tank_burn_duration_expert");
					}
					else if (GameMode == 2 || GameMode == 3)
					{
						if (L4DVersion)
							fireTankExpiry = FindConVar("tank_burn_duration");
						else
						fireTankExpiry = FindConVar("tank_burn_duration_normal");
					}
					burningTankTimeLeft[client] = (fireTankExpiry != INVALID_HANDLE) ? GetConVarInt(fireTankExpiry) : 30;
					if (doomedTankTimer == INVALID_HANDLE)
						doomedTankTimer = CreateTimer(1.0, doomedTankCountdown, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);										
				}		
			}
			// If we only have the 5 second timer running then we do a delayed damage update
			// (in reality with 4 players playing it's unlikely all of them will be alive at the same time
			// so we will probably have at least one faster timer running)
			if (delayedDmgTimer == INVALID_HANDLE && respawnTimer == INVALID_HANDLE && doomedTankTimer == INVALID_HANDLE)
			{
				delayedDmgTimer = CreateTimer(2.0, delayedDmgUpdate, _, TIMER_FLAG_NO_MAPCHANGE);
			} 
		}
	}
}

bool:CheckForTanksOnFire ()
{
	for (new i=1;i<=MaxClients;i++)
	{
		if (!IsClientInGame(i) || GetClientTeam(i)!=3 || !IsPlayerTank(i))
			continue;
		
		if (isTankOnFire[i] == true)
			return true;
	}
	return false;
}

public Action:evtInfectedWaitSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	// Don't bother with infected HUD update if the round has ended
	if (!roundInProgress) return;
	
	// Store this players respawn time in an array so we can present it to other clients
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (client)
	{
		decl timetowait;
		if (GameMode == 2 && !IsFakeClient(client))
		{	
			timetowait = GetEventInt(event, "spawntime");
		}
		else if (GameMode != 2 && !IsFakeClient(client))
		{	
			timetowait = GetSpawnTime[client];
		}
		else
		{	
			timetowait = GetSpawnTime[client];
		}
		
		respawnDelay[client] = timetowait;
		// Only start timer if we don't have one already going.
		if (respawnTimer == INVALID_HANDLE) {
			// Note: If we have to start a new timer then there will be a 1 second delay before it starts, so 
			// subtract 1 from the pending spawn time
			respawnDelay[client] = (timetowait-1);
			respawnTimer = CreateTimer(1.0, monitorRespawn, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
		}
		// Send mod details/commands to the client, unless they have seen the announce already.
		// Note: We can't do this in OnClientPutInGame because the client may not be on the infected team
		// when they connect, and we can't put it in evtTeamSwitch because it won't register if the client
		// joins the server already on the Infected team.
		if (!clientGreeted[client] && (GetConVarBool(h_Announce)))
		{
			CreateTimer(8.0, TimerAnnounce, client);	
		}
	}
}

public Action:HUDReset(Handle:timer)
{
	infHUDTimer 		= INVALID_HANDLE;	// The main HUD refresh timer
	respawnTimer 	= INVALID_HANDLE;	// Respawn countdown timer
	doomedTankTimer 	= INVALID_HANDLE;	// "Tank on Fire" countdown timer
	delayedDmgTimer 	= INVALID_HANDLE;	// Delayed damage update timer
	pInfHUD 		= INVALID_HANDLE;	// The panel shown to all infected users
}

stock GetURandomIntRange(min, max)
{
	return (GetURandomInt() % (max-min+1)) + min;
}

stock CheatCommand(client, String:command[], String:arguments[] = "")
{
	if (!client || !IsClientInGame(client))
	{
		for (new target = 1; target <= MaxClients; target++)
		{
			client = target;
			break;
		}
		
		return; // case no valid Client found
	}
	
	new userFlags = GetUserFlagBits(client);
	SetUserFlagBits(client, ADMFLAG_ROOT);
	new flags = GetCommandFlags(command);
	SetCommandFlags(command, flags & ~FCVAR_CHEAT);
	FakeClientCommand(client, "%s %s", command, arguments);
	SetCommandFlags(command, flags);
	SetUserFlagBits(client, userFlags);
}

stock InfectedForceGhost(client)
{
	static Handle:fhZombieAbortControl = INVALID_HANDLE;
	
	if (GameMode == 2) return;
	if (!GetConVarBool(h_FreeSpawn)) return;
	if (!IsClientInGame(client)) return;
	if (GetClientTeam(client) != 3) return;
	if (IsPlayerTank(client)) return;
	if (IsPlayerGhost(client)) return;
	if (IsFakeClient(client)) return;
	
	//Initialize
	if (fhZombieAbortControl == INVALID_HANDLE){
		new Handle:gConf = INVALID_HANDLE;
		gConf = LoadGameConfigFile("l4dinfectedbots");
		//CTerrorPlayer::PlayerZombieAbortControl(client,float=0)
		StartPrepSDKCall(SDKCall_Player);
		PrepSDKCall_SetFromConf(gConf, SDKConf_Signature, "ZombieAbortControl");
		PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
		fhZombieAbortControl = EndPrepSDKCall();
		CloseHandle(gConf);
		if (fhZombieAbortControl == INVALID_HANDLE){
			SetFailState("Infected Bots can't get ZombieAbortControl SDKCall!");
			return;
		}			
	}
	SetEntProp(client,Prop_Send,"m_isCulling",1,1);
	SDKCall(fhZombieAbortControl, client,0.0);	
	return;
}

stock TurnFlashlightOn(client)
{
	if (GameMode == 2) return;
	if (!IsClientInGame(client)) return;
	if (GetClientTeam(client) != 3) return;
	if (!PlayerIsAlive(client)) return;
	if (IsFakeClient(client)) return;
	
	static Handle:hSetFlashlightEnabled;
	if (hSetFlashlightEnabled == INVALID_HANDLE)
	{
		new Handle:hGameConf;
		
		hGameConf = LoadGameConfigFile("l4dinfectedbots");
		
		StartPrepSDKCall(SDKCall_Player);
		PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, "FlashlightTurnOn");
		PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_ByValue);
		hSetFlashlightEnabled = EndPrepSDKCall();
	}
	SetEntData(client, FindSendPropInfo("CTerrorPlayer", "m_iTeamNum"), 2, 1, true);
	new bool:boolean;
	//ReplyToCommand (client, "SDK Enabling your flashlight");
	SDKCall(hSetFlashlightEnabled, client, boolean);
	SetEntData(client, FindSendPropInfo("CTerrorPlayer", "m_iTeamNum"), 3, 1, true);
	return;
}

stock SwitchToSurvivors(client)
{
	if (GameMode == 2) return;
	if (!IsClientInGame(client)) return;
	if (GetClientTeam(client) == 2) return;
	if (IsFakeClient(client)) return;
	
	new bot = FindBotToTakeOver();
	
	if (bot == 0)
	{
		PrintHintText(client, "No survivor bots to take over.");
		return;
	}
	
	static Handle:hSpec;
	if (hSpec == INVALID_HANDLE)
	{
		new Handle:hGameConf;
		
		hGameConf = LoadGameConfigFile("l4dinfectedbots");
		
		StartPrepSDKCall(SDKCall_Player);
		PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, "SetHumanSpec");
		PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
		hSpec = EndPrepSDKCall();
	}
	
	static Handle:hSwitch;
	if (hSwitch == INVALID_HANDLE)
	{
		new Handle:hGameConf;
		
		hGameConf = LoadGameConfigFile("l4dinfectedbots");
		
		StartPrepSDKCall(SDKCall_Player);
		PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, "TakeOverBot");
		PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
		hSwitch = EndPrepSDKCall();
	}
	
	SDKCall(hSpec, bot, client);
	SDKCall(hSwitch, client, true);
	return;
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////