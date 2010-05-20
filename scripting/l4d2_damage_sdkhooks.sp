/*

Example excerpt l4d2damagemod.cfg


"L4D2 Damage Mods"
{
	"MP5"
	{
		"weapon_class"			"weapon_smg_mp5"
		"modifier_friendly"		"1.0"
		"modifier_enemy"		"1.2"
	}
	
	"AWP Sniper"
	{
		"weapon_class"			"weapon_sniper_awp"
		"modifier_friendly"		"1.75"
		"modifier_enemy"		"1.75"
	}
}

You require a target String behind "weapon_class", and then you can set your modifiers behind "modifier_friendly" and "modifier_enemy"
The header Strings, in this case "MP5" and "AWP Sniper" are arbitrary and for your information only

Damage gets multiplied with the Modifiers, 0 would STOP any damage from that source, 1.0 would be default, 2.0 is twice the damage


Target Strings:

normal guns - by their entity class, e.g. "weapon_smg_silenced"
melee weapons - by their string, e.g. "katana"

common infected - "infected"
witch - "witch"

Special Infected: by their string, e.g. "hunter", "charger" and so on

The car Mr. Tank just put into Ellis:    "prop_physics"

*/

#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#define PLUGIN_VERSION						"1.0.0"

#define TEST_DEBUG							 0
#define TEST_DEBUG_LOG						 0

#define				MAX_MODDED_WEAPONS		32
#define				CLASS_STRINGLENGHT		32

#define 		ZOMBIECLASS_SMOKER			1
#define 		ZOMBIECLASS_BOOMER			2
#define 		ZOMBIECLASS_HUNTER			3
#define 		ZOMBIECLASS_SPITTER			4
#define 		ZOMBIECLASS_JOCKEY			5
#define 		ZOMBIECLASS_CHARGER 		6
#define 		ZOMBIECLASS_TANK 			8

static const	L4D2_TEAM_INFECTED		  =  3;
static const	L4D2_MAX_HUMAN_PLAYERS	  = 32;
static const	L4D2_INFLICTOR_INFECTED	  = 4095;

static const String:ENTPROP_OWNER_ENT[]	  = "m_hOwnerEntity";
static const String:ENTPROP_MELEE_STRING[]= "m_strMapSetScriptName";
static const String:ENTPROP_ZOMBIE_CLASS[]= "m_zombieClass";
static const String:CLASSNAME_INFECTED[]  = "infected";
static const String:CLASSNAME_WITCH[]	  = "witch";
static const String:CLASSNAME_MELEE_WPN[] = "melee_weapon";
static const String:CLASSNAME_PLAYER[]	  = "player";
static const String:CLASSNAME_SMOKER[]	  = "smoker";
static const String:CLASSNAME_BOOMER[]	  = "boomer";
static const String:CLASSNAME_HUNTER[]	  = "hunter";
static const String:CLASSNAME_SPITTER[]	  = "spitter";
static const String:CLASSNAME_JOCKEY[]	  = "jockey";
static const String:CLASSNAME_CHARGER[]	  = "charger";
static const String:CLASSNAME_TANK[]	  = "tank";


static String:damageModConfigFile[PLATFORM_MAX_PATH]	= "";
static Handle:keyValueHolder							= INVALID_HANDLE;
static Handle:weaponIndexTrie							= INVALID_HANDLE;

enum weaponModData
{
	Float:damageModifierFriendly,
	Float:damageModifierEnemy
}

static damageModArray[MAX_MODDED_WEAPONS][weaponModData];


public Plugin:myinfo =
{
	name = "L4D2 Damage Mod SDKHooks",
	author = "AtomicStryker",
	description = "Modify damage",
	version = PLUGIN_VERSION,
	url = "http://forums.alliedmods.net/showthread.php?p=1184761"
};

public OnPluginStart()
{
	decl String:game_name[CLASS_STRINGLENGHT];
	GetGameFolderName(game_name, sizeof(game_name));
	if (StrContains(game_name, "left4dead", false) < 0)
	{
		SetFailState("Plugin supports L4D2 only.");
	}

	CreateConVar("l4d2_damage_mod_version", PLUGIN_VERSION, "L4D2 Damage Mod Version", FCVAR_PLUGIN|FCVAR_REPLICATED|FCVAR_DONTRECORD);
}

public OnClientPostAdminCheck(client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public OnEntityCreated(entity, const String:classname[])
{
	if (StrEqual(classname, CLASSNAME_INFECTED, false) || StrEqual(classname, CLASSNAME_WITCH, false))
	{
		SDKHook(entity, SDKHook_OnTakeDamage, OnTakeDamage);
	}
}

public OnMapStart()
{
	if (weaponIndexTrie != INVALID_HANDLE)
	{
		CloseHandle(weaponIndexTrie);
	}
	weaponIndexTrie = CreateTrie();

	BuildPath(Path_SM, damageModConfigFile, sizeof(damageModConfigFile), "configs/l4d2damagemod.cfg");
	if(!FileExists(damageModConfigFile)) 
	{
		SetFailState("l4d2damagemod.cfg cannot be read ... FATAL ERROR!");
	}
	
	if (keyValueHolder != INVALID_HANDLE)
	{
		CloseHandle(keyValueHolder);
	}
	keyValueHolder = CreateKeyValues("l4d2damagemod");
	FileToKeyValues(keyValueHolder, damageModConfigFile);
	KvRewind(keyValueHolder);
	
	if (KvGotoFirstSubKey(keyValueHolder))
	{
		new i = 0;
		decl String:buffer[CLASS_STRINGLENGHT], Float:value;
		do
		{
			KvGetString(keyValueHolder, "weapon_class", buffer, sizeof(buffer), "1.0");
			SetTrieValue(weaponIndexTrie, buffer, i);
			DebugPrintToAll("Dataset %i, weapon_class %s read and saved", i, buffer);
			
			KvGetString(keyValueHolder, "modifier_friendly", buffer, sizeof(buffer), "1.0");
			value = StringToFloat(buffer);
			damageModArray[i][damageModifierFriendly] = value;
			DebugPrintToAll("Dataset %i, modifier_friendly %f read and saved", i, value);
			
			KvGetString(keyValueHolder, "modifier_enemy", buffer, sizeof(buffer), "1.0");
			value = StringToFloat(buffer);
			damageModArray[i][damageModifierEnemy] = value;
			DebugPrintToAll("Dataset %i, modifier_enemy %f read and saved", i, value);
			
			i++;
		}
		while (KvGotoNextKey(keyValueHolder));
	}
	else
	{
		SetFailState("l4d2damagemod.cfg cannnot be parsed ... No subkeys found!");
	}
}

public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if (!IsValidEdict(victim) || !IsValidEdict(attacker)) return Plugin_Continue;
	
	decl String:classname[CLASS_STRINGLENGHT], i;
	if (inflictor != L4D2_INFLICTOR_INFECTED) // case Survivor attack
	{
		GetEdictClassname(inflictor, classname, sizeof(classname));
		
		if (StrEqual(classname, CLASSNAME_MELEE_WPN)) // subcase melee weapon
		{
			new humanattacker = GetEntPropEnt(inflictor, Prop_Send, ENTPROP_OWNER_ENT);
			GetEntPropString(GetPlayerWeaponSlot(humanattacker, 1), Prop_Data, ENTPROP_MELEE_STRING, classname, sizeof(classname));
		}
	}
	else // case infected attack
	{
		GetEdictClassname(attacker, classname, sizeof(classname));
		
		if (StrEqual(classname, CLASSNAME_PLAYER)) // subcase Special Infected attack
		{
			switch (GetEntProp(attacker, Prop_Send, ENTPROP_ZOMBIE_CLASS))
			{
				case ZOMBIECLASS_SMOKER: 	Format(classname, sizeof(classname), CLASSNAME_SMOKER);
				case ZOMBIECLASS_BOOMER: 	Format(classname, sizeof(classname), CLASSNAME_BOOMER);
				case ZOMBIECLASS_HUNTER: 	Format(classname, sizeof(classname), CLASSNAME_HUNTER);
				case ZOMBIECLASS_SPITTER: 	Format(classname, sizeof(classname), CLASSNAME_SPITTER);
				case ZOMBIECLASS_JOCKEY: 	Format(classname, sizeof(classname), CLASSNAME_JOCKEY);
				case ZOMBIECLASS_CHARGER: 	Format(classname, sizeof(classname), CLASSNAME_CHARGER);
				case ZOMBIECLASS_TANK: 		Format(classname, sizeof(classname), CLASSNAME_TANK);
			}
		}
	}
	
	DebugPrintToAll("attacker %i, inflictor %i dealt [%f] damage to victim %i, class %s", attacker, inflictor, damage, victim, classname);
	
	if (!GetTrieValue(weaponIndexTrie, classname, i)) return Plugin_Continue;
	
	decl teamattacker, teamvictim, Float:damagemod;
	
	if (attacker < L4D2_MAX_HUMAN_PLAYERS) // case: attacker human player
	{
		teamattacker = GetClientTeam(attacker);
		
		if (victim < L4D2_MAX_HUMAN_PLAYERS) // case: victim also human player
		{
			teamvictim = GetClientTeam(victim);
			if (teamattacker == teamvictim)
			{
				damagemod = damageModArray[i][damageModifierFriendly];
			}
			else
			{
				damagemod = damageModArray[i][damageModifierEnemy];
			}
		}
		else // case: victim is witch or common
		{
			if (teamattacker == L4D2_TEAM_INFECTED)
			{
				damagemod = damageModArray[i][damageModifierFriendly];
			}
			else
			{
				damagemod = damageModArray[i][damageModifierEnemy];
			}
		}
	}
	else if (victim < L4D2_MAX_HUMAN_PLAYERS) // case: attacker witch or common, victim human player
	{
		teamvictim = GetClientTeam(victim);
		if (teamvictim == L4D2_TEAM_INFECTED)
		{
			damagemod = damageModArray[i][damageModifierFriendly];
		}
		else
		{
			damagemod = damageModArray[i][damageModifierEnemy];
		}
	}
	
	damage = damage * damagemod;
	DebugPrintToAll("Damage modded by [%f] to [%f]", damagemod, damage);
	
	return Plugin_Continue;
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