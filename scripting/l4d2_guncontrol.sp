#pragma semicolon 1
#include <sourcemod>
#include <sdktools>

/*

Datamap m_iAmmo
offset to add - gun(s) - control cvar

+12: M4A1, AK74, Desert Rifle, also SG552 - ammo_assaultrifle_max
+20: both SMGs, also the MP5 - ammo_smg_max
+24: both Pump Shotguns - ammo_shotgun_max
+28: both autoshotguns - ammo_autoshotgun_max
+32: Hunting Rifle - ammo_huntingrifle_max
+36: Military Sniper, AWP, Scout - ammo_sniperrifle_max
+64: Grenade Launcher - ammo_grenadelauncher_max


Further info:

On a dropped or carried weapon Prop_Send "m_iClip1" contains the primary ammo amount
On dropped weapons (only!) Prop_Send "m_iExtraPrimaryAmmo" contains the reserve ammo amount 


*/

#define PLUGIN_VERSION "1.0.6"

new Handle:AssaultAmmoCVAR = INVALID_HANDLE;
new Handle:SMGAmmoCVAR = INVALID_HANDLE;
new Handle:ShotgunAmmoCVAR = INVALID_HANDLE;
new Handle:AutoShotgunAmmoCVAR = INVALID_HANDLE;
new Handle:HRAmmoCVAR = INVALID_HANDLE;
new Handle:SniperRifleAmmoCVAR = INVALID_HANDLE;
new Handle:GrenadeLauncherAmmoCVAR = INVALID_HANDLE;

new Handle:GrenadeResupplyCVAR = INVALID_HANDLE;
new Handle:IncendAmmoMultiplier = INVALID_HANDLE;
new Handle:SplosiveAmmoMultiplier = INVALID_HANDLE;

new bool:buttondelay[MAXPLAYERS+1];

public Plugin:myinfo = 
{
	name = "L4D2 Gun Control",
	author = "AtomicStryker",
	description = " Allows Customization of some gun related game mechanics ",
	version = PLUGIN_VERSION,
	url = "http://forums.alliedmods.net/showthread.php?p=1020236"
}

public OnPluginStart()
{
	// Requires Left 4 Dead 2
	decl String:game_name[64];
	GetGameFolderName(game_name, sizeof(game_name));
	if (!StrEqual(game_name, "left4dead2", false))
		SetFailState("Plugin supports Left 4 Dead 2 only.");
	
	CreateConVar("l4d2_guncontrol_version", PLUGIN_VERSION, " Version of L4D2 Gun Control on this server ", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	
	AssaultAmmoCVAR = CreateConVar("l4d2_guncontrol_assaultammo", "360", " How much Ammo for Assault Rifles ", FCVAR_PLUGIN|FCVAR_NOTIFY);
	SMGAmmoCVAR = CreateConVar("l4d2_guncontrol_smgammo", "650", " How much Ammo for SMG gun types ", FCVAR_PLUGIN|FCVAR_NOTIFY);
	ShotgunAmmoCVAR = CreateConVar("l4d2_guncontrol_shotgunammo", "56", " How much Ammo for Shotgun and Chrome Shotgun ", FCVAR_PLUGIN|FCVAR_NOTIFY);
	AutoShotgunAmmoCVAR = CreateConVar("l4d2_guncontrol_autoshotgunammo", "90", " How much Ammo for Autoshottie and SPAS ", FCVAR_PLUGIN|FCVAR_NOTIFY);
	HRAmmoCVAR = CreateConVar("l4d2_guncontrol_huntingrifleammo", "150", " How much Ammo for the Hunting Rifle ", FCVAR_PLUGIN|FCVAR_NOTIFY);
	SniperRifleAmmoCVAR = CreateConVar("l4d2_guncontrol_sniperrifleammo", "180", " How much Ammo for the Military Sniper Rifle, AWP, and Scout ", FCVAR_PLUGIN|FCVAR_NOTIFY);	
	GrenadeLauncherAmmoCVAR = CreateConVar("l4d2_guncontrol_grenadelauncherammo", "30", " How much Ammo for the Grenade Launcher ", FCVAR_PLUGIN|FCVAR_NOTIFY);	
	
	GrenadeResupplyCVAR = CreateConVar("l4d2_guncontrol_allowgrenadereplenish", "1", " Do you allow Players to resupply the Grenadelauncher off ammospots ", FCVAR_PLUGIN|FCVAR_NOTIFY);
	IncendAmmoMultiplier = CreateConVar("l4d2_guncontrol_incendammomulti", "3", " Multiplier for Incendiary Ammo Pickup Amount ", FCVAR_PLUGIN|FCVAR_NOTIFY);
	SplosiveAmmoMultiplier = CreateConVar("l4d2_guncontrol_explosiveammomulti", "1", " Multiplier for Explosive Ammo Pickup Amount ", FCVAR_PLUGIN|FCVAR_NOTIFY);
	
	HookConVarChange(AssaultAmmoCVAR, CVARChanged);
	HookConVarChange(SMGAmmoCVAR, CVARChanged);
	HookConVarChange(ShotgunAmmoCVAR, CVARChanged);
	HookConVarChange(AutoShotgunAmmoCVAR, CVARChanged);
	HookConVarChange(HRAmmoCVAR, CVARChanged);
	HookConVarChange(SniperRifleAmmoCVAR, CVARChanged);
	HookConVarChange(GrenadeLauncherAmmoCVAR, CVARChanged);
	
	HookEvent("upgrade_pack_added", Event_SpecialAmmo);
	
	RegConsoleCmd("give_ammo", Cmd_GiveAmmo, "Gives the Player you look at your current ammo clip");
	
	AutoExecConfig(true, "l4d2_guncontrol");
	
	UpdateConVars();
}

public OnMapStart()
{
	UpdateConVars();
}

public CVARChanged(Handle:convar, const String:oldValue[], const String:newValue[])
{
	UpdateConVars();
}

UpdateConVars()
{
	SetConVarInt(FindConVar("ammo_assaultrifle_max"), GetConVarInt(AssaultAmmoCVAR));
	SetConVarInt(FindConVar("ammo_smg_max"), GetConVarInt(SMGAmmoCVAR));
	SetConVarInt(FindConVar("ammo_shotgun_max"), GetConVarInt(ShotgunAmmoCVAR));
	SetConVarInt(FindConVar("ammo_autoshotgun_max"), GetConVarInt(AutoShotgunAmmoCVAR));
	SetConVarInt(FindConVar("ammo_huntingrifle_max"), GetConVarInt(HRAmmoCVAR));
	SetConVarInt(FindConVar("ammo_sniperrifle_max"), GetConVarInt(SniperRifleAmmoCVAR));
	SetConVarInt(FindConVar("ammo_grenadelauncher_max"), GetConVarInt(GrenadeLauncherAmmoCVAR));
}

public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{
	if (buttons & IN_USE && !buttondelay[client])
	{
		CreateTimer(2.0, ResetDelay, client); //add a button delay to prevent multiple firings
		
		new gun = GetClientAimTarget(client, false); //get the entity player is looking at
		if (gun < 32) return Plugin_Continue; //below 32 is a player or null, invalid
		if (!IsValidEdict(gun)) return Plugin_Continue; //lets check for validity anyhow
		
		decl String:ent_name[64];
		GetEdictClassname(gun, ent_name, sizeof(ent_name)); //get the entities name
		
		new oldgun = GetPlayerWeaponSlot(client, 0); //get the players primary weapon
		if (!IsValidEdict(oldgun)) return Plugin_Continue; //check for validity
		
		decl String:currentgunname[64];
		GetEdictClassname(oldgun, currentgunname, sizeof(currentgunname)); //get the primary weapon name
		
		// later added grenade launcher remunition code, where "gun" actually is an ammopile.
		if (StrEqual(ent_name, "weapon_ammo_spawn", false) && StrEqual(currentgunname, "weapon_grenade_launcher", false) && GetConVarBool(GrenadeResupplyCVAR))
		{
			new iAmmoOffset = FindDataMapOffs(client, "m_iAmmo");
			SetEntData(client, iAmmoOffset+64, GetConVarInt(GrenadeLauncherAmmoCVAR));
			PrintHintText(client, "You remunitioned your Grenade Launcher!");
		}
		
		if (!StrEqual(ent_name, currentgunname)) return Plugin_Continue; //if entity and primary weapon dont have the same name theyre incompatible
		
		new iAmmoOffset = FindDataMapOffs(client, "m_iAmmo"); //get the iAmmo Offset
		decl offsettoadd, maxammo;
		
		if (StrEqual(ent_name, "weapon_rifle", false) || StrEqual(ent_name, "weapon_rifle_ak47", false) || StrEqual(ent_name, "weapon_rifle_desert", false) || StrEqual(ent_name, "weapon_rifle_sg552", false))
		{ //case: Assault rifles
			offsettoadd = 12; //gun type specific offset
			maxammo = GetConVarInt(AssaultAmmoCVAR); //get max ammo as set
		}
		else if (StrEqual(ent_name, "weapon_smg", false) || StrEqual(ent_name, "weapon_smg_silenced", false) || StrEqual(ent_name, "weapon_smg_mp5", false))
		{ //case: SMGS
			offsettoadd = 20; //gun type specific offset
			maxammo = GetConVarInt(SMGAmmoCVAR); //get max ammo as set
		}		
		else if (StrEqual(ent_name, "weapon_pumpshotgun", false) || StrEqual(ent_name, "weapon_shotgun_chrome", false))
		{ //case: Pump Shotguns
			offsettoadd = 24; //gun type specific offset
			maxammo = GetConVarInt(ShotgunAmmoCVAR); //get max ammo as set
		}
		else if (StrEqual(ent_name, "weapon_autoshotgun", false) || StrEqual(ent_name, "weapon_shotgun_spas", false))
		{ //case: Auto Shotguns
			offsettoadd = 28; //gun type specific offset
			maxammo = GetConVarInt(AutoShotgunAmmoCVAR); //get max ammo as set
		}
		else if (StrEqual(ent_name, "weapon_hunting_rifle", false))
		{ //case: Hunting Rifle
			offsettoadd = 32; //gun type specific offset
			maxammo = GetConVarInt(HRAmmoCVAR); //get max ammo as set
		}
		else if (StrEqual(ent_name, "weapon_sniper_military", false) || StrEqual(ent_name, "weapon_sniper_awp", false) || StrEqual(ent_name, "weapon_sniper_scout", false))
		{ //case: Military Sniper Rifle or CSS Snipers
			offsettoadd = 36; //gun type specific offset
			maxammo = GetConVarInt(SniperRifleAmmoCVAR); //get max ammo as set
		}
		else
		{ //case: no gun this plugin recognizes
			return Plugin_Continue;
		}
		
		new currentammo = GetEntData(client, (iAmmoOffset + offsettoadd)); //get current ammo
		
		if (currentammo >= maxammo) return Plugin_Continue; //if youre full, do nothing
		
		new foundgunammo = GetEntProp(gun, Prop_Send, "m_iExtraPrimaryAmmo", 4); //get the lying around guns contained ammo
		if (!foundgunammo) //if its zero
		{
			PrintHintText(client, "That gun is empty"); //the gun is empty, bug out
			return Plugin_Continue;
		}
		
		if ((currentammo + foundgunammo) <= maxammo) //if contained ammo is less than youd need to be full
		{
			SetEntData(client, (iAmmoOffset + offsettoadd), (currentammo + foundgunammo), 4, true); //add bullets to your supply
			SetEntProp(gun, Prop_Send, "m_iExtraPrimaryAmmo",0 ,4); //empty the gun
			PrintHintText(client, "You scavenged %i bullets off that gun", foundgunammo); //imform the client
		}
		else //if contained ammo exceeds your needs
		{
			new neededammo = (maxammo - currentammo); //find out how much exactly you need
			SetEntData(client, (iAmmoOffset + offsettoadd), maxammo, 4, true); //fill you up
			SetEntProp(gun, Prop_Send, "m_iExtraPrimaryAmmo",(foundgunammo - neededammo) ,4); //take needed ammo from gun
			PrintHintText(client, "You scavenged %i bullets off that gun", neededammo); //inform the client
		}
	}
	
	return Plugin_Continue;
}

public Action:ResetDelay(Handle:timer, any:client)
{
	buttondelay[client] = false;
}

public Action:Cmd_GiveAmmo(client, args)
{
	if (!client) client=1;
	new target = GetClientAimTarget(client, true); //get the player our client is looking at
	if (!target || !IsClientInGame(target)) return Plugin_Handled; //invalid
	
	new targetgun = GetPlayerWeaponSlot(target, 0); //get the players primary weapon
	if (!IsValidEdict(targetgun)) return Plugin_Handled; //check for validity
	
	decl String:targetgunname[64];
	GetEdictClassname(targetgun, targetgunname, sizeof(targetgunname));
	
	new oldgun = GetPlayerWeaponSlot(client, 0); //get the players primary weapon
	if (!IsValidEdict(oldgun)) return Plugin_Handled; //check for validity
	
	decl String:currentgunname[64];
	GetEdictClassname(oldgun, currentgunname, sizeof(currentgunname)); //get the primary weapon name
	
	if (!StrEqual(targetgunname, currentgunname))
	{
		PrintToChat(client, "\x01You can only give \x04%N\x01 ammo if you got \x04the same weapon", target);
		return Plugin_Handled; //if targets and your weapon dont have the same name theyre incompatible
	}
	
	if (GetEntProp(oldgun, Prop_Send, "m_iClip1", 1)<2) 
	{
		PrintToChat(client, "\x01You can only give \x04%N\x01 ammo if you got \x04a clip with bullets in your gun", target);
		return Plugin_Handled;
	}
	
	new iAmmoOffset = FindDataMapOffs(target, "m_iAmmo"); //get the iAmmo Offset
	decl offsettoadd, maxammo;
	
	if (StrEqual(currentgunname, "weapon_rifle", false) || StrEqual(currentgunname, "weapon_rifle_ak47", false) || StrEqual(currentgunname, "weapon_rifle_desert", false) || StrEqual(currentgunname, "weapon_rifle_sg552", false))
	{ //case: Assault rifles
		offsettoadd = 12; //gun type specific offset
		maxammo = GetConVarInt(AssaultAmmoCVAR); //get max ammo as set
	}
	else if (StrEqual(currentgunname, "weapon_smg", false) || StrEqual(currentgunname, "weapon_smg_silenced", false) || StrEqual(currentgunname, "weapon_smg_mp5", false))
	{ //case: SMGS
		offsettoadd = 20; //gun type specific offset
		maxammo = GetConVarInt(SMGAmmoCVAR); //get max ammo as set
	}		
	else if (StrEqual(currentgunname, "weapon_pumpshotgun", false) || StrEqual(currentgunname, "weapon_shotgun_chrome", false))
	{ //case: Pump Shotguns
		offsettoadd = 24; //gun type specific offset
		maxammo = GetConVarInt(ShotgunAmmoCVAR); //get max ammo as set
	}
	else if (StrEqual(currentgunname, "weapon_autoshotgun", false) || StrEqual(currentgunname, "weapon_shotgun_spas", false))
	{ //case: Auto Shotguns
		offsettoadd = 28; //gun type specific offset
		maxammo = GetConVarInt(AutoShotgunAmmoCVAR); //get max ammo as set
	}
	else if (StrEqual(currentgunname, "weapon_hunting_rifle", false))
	{ //case: Hunting Rifle
		offsettoadd = 32; //gun type specific offset
		maxammo = GetConVarInt(HRAmmoCVAR); //get max ammo as set
	}
	else if (StrEqual(currentgunname, "weapon_sniper_military", false) || StrEqual(currentgunname, "weapon_sniper_awp", false) || StrEqual(currentgunname, "weapon_sniper_scout", false))
	{ //case: Military Sniper Rifle or CSS Snipers
		offsettoadd = 36; //gun type specific offset
		maxammo = GetConVarInt(SniperRifleAmmoCVAR); //get max ammo as set
	}
	else
	{ //case: no gun this plugin recognizes
		PrintToChat(client, "Error: WTF what gun is that");
		return Plugin_Handled;
	}
	
	new currentammo = GetEntData(target, (iAmmoOffset + offsettoadd)); //get targets current ammo
	
	if (currentammo >= maxammo) //if hes full, do nothing
	{
		PrintToChat(client, "\x01That guy \x04has full\x01 ammo");
		return Plugin_Handled;
	}
	
	new donateammo = GetEntProp(oldgun, Prop_Send, "m_iClip1", 1)-1; //you give your current gun clip minus the bullet thats in the barrel
	
	if ((currentammo + donateammo) <= maxammo) //if clips ammo is less than hed need to be full
	{
		SetEntData(target, (iAmmoOffset + offsettoadd), (currentammo + donateammo), 4, true); //add bullets to his supply
		SetEntProp(oldgun, Prop_Send, "m_iClip1",1 ,1); //empty your gun
		PrintToChat(client, "\x01You gave your clip of \x04%i bullets\x01 to \x04%N\x01", donateammo, target);
	}
	else //if given ammo exceeds his needs
	{
		new neededammo = (maxammo - currentammo); //find out how much exactly he needs
		SetEntData(target, (iAmmoOffset + offsettoadd), maxammo, 4, true); //fill him up
		SetEntProp(oldgun, Prop_Send, "m_iClip1",(donateammo - neededammo) ,1); //take needed ammo from your clip
		PrintToChat(client, "\x01You gave \x04%i bullets\x01 off your clip to \x04%N\x01", neededammo, target);
	}	
	return Plugin_Handled;
}

public Action:Event_SpecialAmmo(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	new upgradeid = GetEventInt(event, "upgradeid");
	decl String:class[256];
	GetEdictClassname(upgradeid, class, sizeof(class));
	//PrintToChatAll("Upgrade caught, entity = %i, entclass: %s", upgradeid, class);
	
	if (StrEqual(class, "upgrade_laser_sight"))
		return;
	
	new ammo = GetSpecialAmmoInPlayerGun(client);
	new newammo;
	
	if (StrEqual(class, "upgrade_ammo_incendiary"))	
		newammo = ammo * GetConVarInt(IncendAmmoMultiplier);
	else if (StrEqual(class, "upgrade_ammo_explosive"))	
		newammo = ammo * GetConVarInt(SplosiveAmmoMultiplier);
	
	if (newammo > 1)
		SetSpecialAmmoInPlayerGun(client, newammo);
	else return;

	PrintToChat(client, "\x01You receive \x04%i clips\x01 of Special Ammo!", newammo/ammo);
}

stock GetSpecialAmmoInPlayerGun(client) //returns the amount of special rounds in your gun
{
	if (!client) client = 1;
	new gunent = GetPlayerWeaponSlot(client, 0);
	if (IsValidEdict(gunent))
		return GetEntProp(gunent, Prop_Send, "m_nUpgradedPrimaryAmmoLoaded", 1);
	else return 0;
}

stock SetSpecialAmmoInPlayerGun(client, amount)
{
	if (!client) client = 1;
	new gunent = GetPlayerWeaponSlot(client, 0);
	if (IsValidEdict(gunent))
		SetEntProp(gunent, Prop_Send, "m_nUpgradedPrimaryAmmoLoaded", amount, 1);
}