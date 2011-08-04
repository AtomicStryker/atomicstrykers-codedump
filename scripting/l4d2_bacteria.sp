#pragma semicolon 1
#include <sourcemod>
#include <sdktools>

#define PLUGIN_VERSION					"1.0.2"

#define TEST_DEBUG								0
#define TEST_DEBUG_LOG						 	0

static const 		TEAM_INFECTED		= 3;
static const String:CONVAR_GAMEMODE[]	= "mp_gamemode";
static const String:MODEL_PREFIX[]		= "models/infected/";
static const String:MODEL_SUFFIX[]		= ".mdl";
static const String:SOUND_PREFIX[]		= "music/bacteria/";
static const String:SOUND_SUFFIX_A[]	= "bacteria.wav";
static const String:SOUND_SUFFIX_B[]	= "bacterias.wav";

static Handle:cvarGameModeActive		= INVALID_HANDLE;
static bool:isAllowedGameMode			= false;


public Plugin:myinfo = 
{
	name = "L4D2 Bacteria Sounds",
	author = "AtomicStryker",
	description = " Brings back Infected Spawning music ",
	version = PLUGIN_VERSION,
	url = "http://forums.alliedmods.net/showthread.php?p=1352581"
}

public OnPluginStart()
{
	CreateConVar("l4d2_bacteria_version", PLUGIN_VERSION, " Version of L4D2 Bacteria Sounds on this server ", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	cvarGameModeActive = CreateConVar("l4d2_bacteria_gamemodesactive", "versus,teamversus,scavenge,realism,mutation12", " Set the gamemodes for which the plugin should be activated (same usage as sv_gametypes, i.e. add all game modes where you want it active separated by comma) ");

	HookConVarChange(FindConVar(CONVAR_GAMEMODE), GameModeChanged);
	HookConVarChange(cvarGameModeActive, GameModeChanged);
	CheckGamemode();
	
	HookEvent("item_pickup", Event_ItemPickup);
	HookEvent("round_start", Event_RoundStart);
}

public Action:Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	CheckGamemode();
}

public GameModeChanged(Handle:convar, const String:oldValue[], const String:newValue[])
{
	CheckGamemode();
}

static CheckGamemode()
{
	decl String:gamemode[PLATFORM_MAX_PATH];
	GetConVarString(FindConVar(CONVAR_GAMEMODE), gamemode, sizeof(gamemode));
	decl String:convarsetting[PLATFORM_MAX_PATH];
	GetConVarString(cvarGameModeActive, convarsetting, sizeof(convarsetting));
	
	DebugPrintToAll("gamemode check: setting [%s] gamemode [%s]", convarsetting, gamemode);
	isAllowedGameMode = (StrContains(convarsetting, gamemode, false) != -1);
	DebugPrintToAll("StrContains(setting, gamemode, false) != -1) = %b", isAllowedGameMode);
}

public Action:Event_ItemPickup(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	DebugPrintToAll("client %i, mode %b, ingame %b, team %i", client, isAllowedGameMode, IsClientInGame(client), GetClientTeam(client));
	
	if (!isAllowedGameMode
	|| !client
	|| !IsClientInGame(client)
	|| GetClientTeam(client) != TEAM_INFECTED)
	{
		return;
	}

	decl String:buffer[PLATFORM_MAX_PATH];
	GetClientModel(client, buffer, sizeof(buffer)); // example output: models/infected/boomer.mdl
	
	DebugPrintToAll("client model: [%s]", buffer);
	
	// replace the model directory with the bacteria directory (emitsound works relative to sound folder)
	ReplaceString(buffer, sizeof(buffer), MODEL_PREFIX, SOUND_PREFIX);
	
	// replace the model ending with the filename and ending of bacteria files, note there is 2 versions, randomize
	if (GetRandomInt(0, 1) == 0)
	{
		ReplaceString(buffer, sizeof(buffer), MODEL_SUFFIX, SOUND_SUFFIX_A);
	}
	else
	{
		ReplaceString(buffer, sizeof(buffer), MODEL_SUFFIX, SOUND_SUFFIX_B);
	}
	
	DebugPrintToAll("resulting sound name: [%s]", buffer);
	
	// playback!
	EmitSoundToAll(buffer);
}

stock DebugPrintToAll(const String:format[], any:...)
{
	#if TEST_DEBUG	|| TEST_DEBUG_LOG
	decl String:buffer[192];
	
	VFormat(buffer, sizeof(buffer), format, 2);
	
	#if TEST_DEBUG
	PrintToChatAll("[DAMAGE] %s", buffer);
	PrintToConsole(0, "[DAMAGE] %s", buffer);
	#endif
	
	LogMessage("%s", buffer);
	#else
	//suppress "format" never used warning
	if(format[0])
		return;
	else
		return;
	#endif
}