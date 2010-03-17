#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#define PLUGIN_VERSION						"1.0.3"

#define TEST_DEBUG							0
#define TEST_DEBUG_LOG						0

new Handle:modifyDamageEnabled			=	INVALID_HANDLE;
new Handle:modifyMeleeDamageCommons		=	INVALID_HANDLE;

new Handle:trieModdedWeapons			=	INVALID_HANDLE;
new Handle:trieModdedWeaponsTank		=	INVALID_HANDLE;

new static damageModEnabled				=	1;
new static damageModEnabledForCI		=	1;

public Plugin:myinfo =
{
	name = "L4D Weapon Damage Mod",
	author = "AtomicStryker",
	description = "Modify damage for each Weapon",
	version = PLUGIN_VERSION,
	url = ""
};

public OnPluginStart()
{
	decl String:game_name[64];
	GetGameFolderName(game_name, sizeof(game_name));
	if (StrContains(game_name, "left4dead", false) < 0)
		SetFailState("Plugin supports Left 4 Dead or L4D2 only.");

	CreateConVar("l4d_damage_mod_version", PLUGIN_VERSION, "L4D Weapon Damage Mod Version", FCVAR_PLUGIN|FCVAR_REPLICATED|FCVAR_DONTRECORD);
	
	modifyDamageEnabled = CreateConVar("l4d_damage_enabled", "1", "Enable or Disable the L4D Damage Plugin", FCVAR_PLUGIN|FCVAR_NOTIFY);
	modifyMeleeDamageCommons = CreateConVar("l4d_damage_melee_commons_enabled", "0", "Enable or Disable modifying melee weapon damage on Common Infected (CAUTION)", FCVAR_PLUGIN|FCVAR_NOTIFY);
	
	RegAdminCmd("sm_damage_weaponmulti", CmdSetWeaponMultiplier, ADMFLAG_CHEATS);
	RegAdminCmd("sm_damage_tank_weaponmulti", CmdSetWeaponMultiplierTank, ADMFLAG_CHEATS);
	RegAdminCmd("sm_damage_reset", CmdClearWeaponsTrie, ADMFLAG_CHEATS);
	
	trieModdedWeapons = CreateTrie();
	trieModdedWeaponsTank = CreateTrie();
	
	HookConVarChange(modifyDamageEnabled, _DM_ConVarChange);
	HookConVarChange(modifyMeleeDamageCommons, _DM_ConVarChange);
	
	_DM_OnModuleEnabled();
}

public _DM_ConVarChange(Handle:convar, const String:oldValue[], const String:newValue[])
{
	if (GetConVarBool(modifyDamageEnabled))
	{
		_DM_OnModuleEnabled();
		damageModEnabled = 1;
	}
	else
	{
		_DM_OnModuleDisabled();
		damageModEnabled = 0;
	}
	
	damageModEnabledForCI = GetConVarBool(modifyMeleeDamageCommons);
}

_DM_OnModuleEnabled()
{
	HookEvent("player_hurt",_DM_PlayerHurt_Event, EventHookMode_Pre);
	HookEvent("infected_hurt", _DM_InfectedHurt_Event);
}

_DM_OnModuleDisabled()
{
	UnhookEvent("player_hurt",_DM_PlayerHurt_Event, EventHookMode_Pre);
	UnhookEvent("infected_hurt", _DM_InfectedHurt_Event);
}

public OnPluginEnd()
{
	CloseHandle(trieModdedWeapons);
	CloseHandle(trieModdedWeaponsTank);
}

public Action:_DM_PlayerHurt_Event(Handle:event, const String:name[], bool:dontBroadcast)
{
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (!client || !attacker) return Plugin_Continue; // both must be valid players.
	
	decl Float:multiplierWeapon, String:weaponname[64];
	
	new dmg_health = GetEventInt(event,"dmg_health");	 // get the amount of damage done
	new eventhealth = GetEventInt(event,"health");	// get the health after damage as the even sees it
	new altereddamage;
	
	if (dmg_health < 1) return Plugin_Continue; // exclude zero damage calculations
	
	GetClientWeapon(attacker, weaponname, sizeof(weaponname)); // get the attacker weapon
	
	if (StrEqual(weaponname, "weapon_melee"))
	{
		GetEntPropString(GetPlayerWeaponSlot(attacker, 1), Prop_Data, "m_strMapSetScriptName", weaponname, sizeof(weaponname));
	}
	
	if (!IsPlayerTank(client))
	{
		if (GetTrieValue(trieModdedWeapons, weaponname, multiplierWeapon)) // check for the weapon multiplier setting
		{
			altereddamage = RoundToNearest(dmg_health * multiplierWeapon);

			if (eventhealth > 1) // dont bother if the player dies
			{
				new health = eventhealth + dmg_health - altereddamage;
				// health calculation: first revert damage done by adding dmg_health, then subtract the changed damage
				
				if (health < 1)
				{
					altereddamage += (health - 1);
					health = 1;
				}
				
				SetEntityHealth(client, health);
				SetEventInt(event,"dmg_health", altereddamage); // for correct stats.	
				
				DebugPrintToAll("Changed weapon %s damage used by %N on %N, was %i, is now %i, oldhealth %i, newhealth %i", weaponname, attacker, client, dmg_health, altereddamage, eventhealth, health);
			}
		}
	}
	else
	{
		if (GetTrieValue(trieModdedWeaponsTank, weaponname, multiplierWeapon)) // check for the weapon tank multiplier setting
		{
			altereddamage = RoundToNearest(dmg_health * multiplierWeapon);

			if (eventhealth > 1) // dont bother if the player dies
			{
				new health = eventhealth + dmg_health - altereddamage;
				// health calculation: first revert damage done by adding dmg_health, then subtract the changed damage
				
				if (health < 1)
				{
					altereddamage += (health - 1);
					health = 1;
				}
				
				SetEntityHealth(client, health);
				SetEventInt(event,"dmg_health", altereddamage); // for correct stats.
				
				DebugPrintToAll("Changed weapon %s damage used by %N on Tank %N, was %i, is now %i, oldhealth %i, newhealth %i", weaponname, attacker, client, dmg_health, altereddamage, eventhealth, health);
			}
		}
	}
	
	return Plugin_Continue;
}

public Action:_DM_InfectedHurt_Event(Handle:event, const String:name[], bool:dontBroadcast)
{
	decl Float:multiplierWeapon, String:weaponname[64];
	
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	new entity = (GetEventInt(event, "entityid"));
	
	if (!attacker || !IsValidEntity(entity)) return; //both must be valid
	
	decl String:entname[32];
	GetEdictClassname(entity, entname, sizeof(entname));
	
	new dmg_health = GetEventInt(event,"amount");	 // get the amount of damage done
	new eventhealth = GetEntProp(entity, Prop_Data, "m_iHealth");	// get the health after damage was applied (its a POST hook)
	new altereddamage;
	
	if (dmg_health < 1) return; // exclude zero damage calculations
	
	GetClientWeapon(attacker, weaponname, sizeof(weaponname));
	
	if (StrEqual(weaponname, "weapon_melee"))
	{
		if (StrEqual(entname, "infected", false) && !damageModEnabledForCI) return; // melee weapon mods against commons is tricky business
	
		GetEntPropString(GetPlayerWeaponSlot(attacker, 1), Prop_Data, "m_strMapSetScriptName", weaponname, sizeof(weaponname));
	}
	
	if(GetTrieValue(trieModdedWeapons, weaponname, multiplierWeapon))
	{
		altereddamage = RoundToNearest(dmg_health * multiplierWeapon);
	
		new health = eventhealth + dmg_health - altereddamage; // else use the multiplier.
			
		if (health < 1)
		{
			altereddamage += (health - 1);
			health = 1;
		}
		
		SetEntProp(entity, Prop_Data, "m_iHealth", health); // apply the new calculated health value if its over 1
		SetEventInt(event, "amount", altereddamage); // for correct stats.
			
		DebugPrintToAll("Changed weapon %s damage used by %N on a Witch, was %i, is now %i, oldhealth %i, newhealth %i", weaponname, attacker, dmg_health, altereddamage, eventhealth, health);
		
	}
}

public Action:CmdSetWeaponMultiplier(client, args)
{
	if (!damageModEnabled) return Plugin_Handled;
	
	decl String:weapon[64], String:multiplier[20];
	
	if (args == 2)
	{
		GetCmdArg(1, weapon, sizeof(weapon));
		GetCmdArg(2, multiplier, sizeof(multiplier));
		
		SetTrieValue(trieModdedWeapons, weapon, StringToFloat(multiplier));
		ReplyToCommand(client, "Successfully set damage of weapon: %s to %.2f!", weapon, StringToFloat(multiplier));
	}
	else if (client)
	{
		decl String:weaponname[64];
		GetClientWeapon(client, weaponname, sizeof(weaponname));
		
		if (StrEqual(weaponname, "weapon_melee"))
		{
			GetEntPropString(GetPlayerWeaponSlot(client, 1), Prop_Data, "m_strMapSetScriptName", weaponname, sizeof(weaponname));
		}
		
		ReplyToCommand(client,"Usage: sm_damage_weapon <weapon> <multiplier> - your current weapon is %s", weaponname);
	}
	else ReplyToCommand(client,"Usage: sm_damage_weapon <weapon> <multiplier>");
	
	return Plugin_Handled;
}

public Action:CmdSetWeaponMultiplierTank(client, args)
{
	if (!damageModEnabled) return Plugin_Handled;
	
	decl String:weapon[64], String:multiplier[20];
	
	if (args == 2)
	{
		GetCmdArg(1, weapon, sizeof(weapon));
		GetCmdArg(2, multiplier, sizeof(multiplier));
		
		SetTrieValue(trieModdedWeaponsTank, weapon, StringToFloat(multiplier));
		ReplyToCommand(client, "Successfully set tank damage of weapon: %s to %.2f!", weapon, StringToFloat(multiplier));
	}
	else if (client)
	{
		decl String:weaponname[64];
		GetClientWeapon(client, weaponname, sizeof(weaponname));
		
		if (StrEqual(weaponname, "weapon_melee"))
		{
			GetEntPropString(GetPlayerWeaponSlot(client, 1), Prop_Data, "m_strMapSetScriptName", weaponname, sizeof(weaponname));
		}
		
		ReplyToCommand(client,"Usage: sm_damage_tank_weapon <weapon> <multiplier> - your current weapon is %s", weaponname);
	}
	else ReplyToCommand(client,"Usage: sm_damage_tank_weapon <weapon> <multiplier>");
	
	return Plugin_Handled;
}

public Action:CmdClearWeaponsTrie(client, args)
{
	if (!damageModEnabled) return Plugin_Handled;
	
	ClearTrie(trieModdedWeapons);
	ClearTrie(trieModdedWeaponsTank);
	ReplyToCommand(client, "Cleared the stored damage multipliers of all weapons!");
	
	return Plugin_Handled;
}

stock IsPlayerTank(client)
{
	decl String:playermodel[96];
	GetClientModel(client, playermodel, sizeof(playermodel));
	return (StrContains(playermodel, "hulk", false) > -1);
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