/*
	Created by DJ_WEST
	
	Web: http://amx-x.ru
	AMX Mod X and SourceMod Russian Community
*/

#include <sourcemod>
#include <sdktools>
#pragma semicolon 1

#define PLUGIN_NAME							"Chainsaw Refuelling"
#define PLUGIN_VERSION						"1.3"
#define PLUGIN_AUTHOR						"DJ_WEST"
#define PLUGIN_FLAGS						FCVAR_PLUGIN|FCVAR_NOTIFY

static const String:CHAINSAW[]				= "chainsaw";
static const String:CHAINSAW_CLASS[]		= "weapon_chainsaw";
static const String:CHAINSAW_SPAWN_CLASS[]	= "weapon_chainsaw_spawn";
static const String:GASCAN_CLASS[]			= "weapon_gascan";
static const Float:CHAINSAW_DISTANCE		= 50.0;
static const GASCAN_SKIN					= 0;

static Handle:g_Timer[MAXPLAYERS+1]			= INVALID_HANDLE;
static Handle:h_CvarEnabled					= INVALID_HANDLE;
static Handle:h_CvarRemove					= INVALID_HANDLE;
static Handle:h_CvarMode					= INVALID_HANDLE;
static Handle:h_CvarDrop					= INVALID_HANDLE;

static g_ActiveWeaponOffset					= 0;
static g_ShotsFiredOffset					= 0;
static g_ClientPour[MAXPLAYERS+1]			= 0;
static bool:g_ClientInfo[MAXPLAYERS+1]		= false;
static bool:g_b_AllowChecking[MAXPLAYERS+1]	= false;
static g_PlayerPistol[MAXPLAYERS+1]			= 0;

public Plugin:myinfo = 
{
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = "Allow refuelling of a chainsaw",
	version = PLUGIN_VERSION,
	url = "http://amx-x.ru"
}

public OnPluginStart()
{
	decl String:s_Game[12];
	
	GetGameFolderName(s_Game, sizeof(s_Game));
	if (!StrEqual(s_Game, "left4dead2"))
		SetFailState("Chainsaw Refuelling will only work with Left 4 Dead 2!");
	
	LoadTranslations("chainsaw_refuelling.phrases");
	
	new Handle:h_Version = CreateConVar("refuelchainsaw_version", PLUGIN_VERSION, "Chainsaw Refuelling version", PLUGIN_FLAGS|FCVAR_SPONLY|FCVAR_REPLICATED);
	SetConVarString(h_Version, PLUGIN_VERSION);
	h_CvarEnabled = CreateConVar("l4d2_refuelchainsaw_enabled", "1", "Chainsaw Refuelling plugin status (0 - disable, 1 - enable)", PLUGIN_FLAGS, true, 0.0, true, 1.0);
	h_CvarRemove = CreateConVar("l4d2_refuelchainsaw_remove", "0", "Remove a chainsaw if it empty (0 - don't remove, 1 - remove)", PLUGIN_FLAGS, true, 0.0, true, 1.0);
	h_CvarMode = CreateConVar("l4d2_refuelchainsaw_mode", "2", "Allow refuelling of a chainsaw (0 - on the ground, 1 - on players, 2 - both)", PLUGIN_FLAGS, true, 0.0, true, 2.0);
	h_CvarDrop = CreateConVar("l4d2_refuelchainsaw_drop", "1", "Enable dropping a chainsaw (0 - disable, 1 - enable)", PLUGIN_FLAGS, true, 0.0, true, 1.0);

	g_ActiveWeaponOffset = FindSendPropInfo("CBasePlayer", "m_hActiveWeapon");
	g_ShotsFiredOffset = FindSendPropOffs("CCSPlayer", "m_iShotsFired");
	
	HookEvent("gascan_pour_completed", EventPourCompleted);
	HookEvent("item_pickup", EventItemPickup);
	
	HookConVarChange(h_CvarEnabled, CvarEnabledPlugin);
	
	HookEvent("player_incapacitated", EventNotAllowChecking);
	HookEvent("lunge_pounce", EventNotAllowChecking);
	HookEvent("jockey_ride", EventNotAllowChecking);
	HookEvent("tongue_grab", EventNotAllowChecking);
	HookEvent("charger_carry_start", EventNotAllowChecking);
	HookEvent("charger_pummel_start", EventNotAllowChecking);
	HookEvent("player_ledge_grab", EventNotAllowChecking);
	HookEvent("player_death", EventNotAllowChecking);
	HookEvent("revive_success", EventAllowChecking);
	HookEvent("defibrillator_used", EventAllowChecking);
	HookEvent("pounce_stopped", EventAllowChecking);
	HookEvent("jockey_ride_end", EventAllowChecking);
	HookEvent("tongue_release", EventAllowChecking);
	HookEvent("charger_carry_end", EventAllowChecking);
	HookEvent("charger_pummel_end", EventAllowChecking);
}

public CvarEnabledPlugin(Handle:h_Cvar, const String:s_OldValue[], const String:s_NewValue[])
{
	if (StrEqual(s_NewValue, "0") && StrEqual(s_OldValue, "1"))
	{	
		UnhookEvent("gascan_pour_completed", EventPourCompleted);
		UnhookEvent("item_pickup", EventItemPickup);
	}
	else if (StrEqual(s_OldValue, "0") && StrEqual(s_NewValue, "1"))
	{
		HookEvent("gascan_pour_completed", EventPourCompleted);
		HookEvent("item_pickup", EventItemPickup);
	}
}

public Action:EventNotAllowChecking(Handle:h_Event, const String:s_Name[], bool:b_DontBroadcast)
{
	decl client;
	new i_UserID = GetEventInt(h_Event, "victim");
	if (i_UserID)
		client = GetClientOfUserId(i_UserID);
	else
	{
		i_UserID = GetEventInt(h_Event, "userid");
		client = GetClientOfUserId(i_UserID);
	}
	
	if (!client || !IsClientInGame(client)) return;

	if (GetClientTeam(client) == 2)
		g_b_AllowChecking[client] = false;
}

public Action:EventAllowChecking(Handle:h_Event, const String:s_Name[], bool:b_DontBroadcast)
{
	decl i_UserID;
	if (GetEventInt(h_Event, "victim"))
		i_UserID = GetEventInt(h_Event, "victim");
	else if (GetEventInt(h_Event, "subject"))
		i_UserID = GetEventInt(h_Event, "subject");
	else
		i_UserID = GetEventInt(h_Event, "userid");
	
	new client = GetClientOfUserId(i_UserID);
	if (!client || !IsClientInGame(client)) return;
	if (GetClientTeam(client) == 2)
		g_b_AllowChecking[client] = true;
}

public Action:EventItemPickup(Handle:h_Event, const String:s_Name[], bool:b_DontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(h_Event, "userid"));
	if (!client || !IsClientInGame(client) || IsFakeClient(client)) return;

	decl String:s_Weapon[16];
	GetEventString(h_Event, "item", s_Weapon, sizeof(s_Weapon));

	if (StrEqual(s_Weapon, CHAINSAW))
	{
		new i_Pistol = g_PlayerPistol[client];
		if (i_Pistol && IsValidEnt(i_Pistol))
		{
			RemoveEdict(i_Pistol);
			g_PlayerPistol[client] = 0;
		}
			
		if (!g_ClientInfo[client])
		{
			PrintToChat(client, "\x03[%t]\x01 %t.", "Information", "Refuelling");
			PrintToChat(client, "\x03[%t]\x01 %t.", "Information", "Drop");
			g_ClientInfo[client] = true;
		}
	}
}

public Action:EventPourCompleted(Handle:h_Event, const String:s_Name[], bool:b_DontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(h_Event, "userid"));
	if (!client || !IsClientInGame(client) || IsFakeClient(client)) return;
	
	new i_Ent = g_ClientPour[client];
	if (i_Ent && IsValidEnt(i_Ent))
	{
		SetEntProp(i_Ent, Prop_Data, "m_iClip1", 30);
	}
}

public OnClientPostAdminCheck(client)
{
	g_ClientPour[client] = 0;
	g_PlayerPistol[client] = 0;
	g_ClientInfo[client] = false;
	g_b_AllowChecking[client] = true;
}

public OnMapStart()
{
	for (new client=1; client <= MaxClients; client++)
	{
		g_ClientPour[client] = 0;
		g_PlayerPistol[client] = 0;
		g_ClientInfo[client] = false;
		g_b_AllowChecking[client] = true;
	}
}

static CheckTarget(client)
{
	new i_Ent = GetClientAimTarget(client, false);
	new i_Mode = GetConVarInt(h_CvarMode);
	decl String:s_Class[64];
	
	if (IsValidEnt(i_Ent))
	{
		GetEdictClassname(i_Ent, s_Class, sizeof(s_Class));
		
		if (StrEqual(s_Class, CHAINSAW_SPAWN_CLASS) && i_Mode != 1)
		{
			PrintToChat(client, "\x03[%t]\x01 %t.", "Information", "Full");
			return;
		}
		else if (StrEqual(s_Class, CHAINSAW_CLASS) && i_Mode != 1)
		{
			CheckChainsaw(client, i_Ent, -1);
		}
		else if (StrEqual(s_Class, "player") && i_Mode != 0)
		{
			new i_Weapon = GetEntDataEnt2(i_Ent, g_ActiveWeaponOffset);
			if (!IsValidEnt(i_Weapon)) return;
			
			GetEdictClassname(i_Weapon, s_Class, sizeof(s_Class));
			if (StrEqual(s_Class, CHAINSAW_CLASS))
			{
				CheckChainsaw(client, i_Weapon, i_Ent);
			}
		}
	}
}

static CheckChainsaw(client, i_Weapon, i_Ent)
{
	decl Float:f_EntPos[3], Float:f_ClientPos[3];
	
	GetEntPropVector(i_Ent == -1 ? i_Weapon : i_Ent, Prop_Send, "m_vecOrigin", f_EntPos);
	GetClientAbsOrigin(client, f_ClientPos);
	
	if (GetVectorDistance(f_EntPos, f_ClientPos) <= CHAINSAW_DISTANCE)
	{
		new i_Clip = GetEntProp(i_Weapon, Prop_Data, "m_iClip1");
		
		if (i_Clip == 30)
		{
			PrintToChat(client, "\x03[%t]\x01 %t.", "Information", "Full");
			return;
		}
		
		new i_ChainsawPointEnt = GetEntProp(i_Weapon, Prop_Data, "m_iClip2");
		
		if (i_ChainsawPointEnt == -1)
		{
			new i_PointEnt = (i_Ent == -1) ? CreatePointEntity(i_Weapon, 10.0) : CreatePointEntity(i_Ent, 50.0);
			
			if (IsValidEnt(i_PointEnt))
			{
				SetEntProp(i_Weapon, Prop_Data, "m_iClip2", i_PointEnt);
				g_ClientPour[client] = i_Weapon;
				
				new Handle:h_Pack = CreateDataPack();
				WritePackCell(h_Pack, client);
				WritePackCell(h_Pack, i_Weapon);
				g_Timer[client] = CreateTimer(0.1, CheckPourGascan, h_Pack, TIMER_REPEAT);
			}
		}
	}
}

public Action:CheckPourGascan(Handle:h_Timer, Handle:h_Pack)
{
	ResetPack(h_Pack, false);
	new client = ReadPackCell(h_Pack);
	new i_Ent = ReadPackCell(h_Pack);
	
	new i_PointEnt = GetEntProp(i_Ent, Prop_Data, "m_iClip2");
	new i_ShotsFired = GetEntData(client, g_ShotsFiredOffset);
	
	if (i_ShotsFired == 0)
	{
		CloseHandle(h_Pack);
		RemoveEdict(i_PointEnt);
		SetEntProp(i_Ent, Prop_Data, "m_iClip2", -1);
		
		if (g_Timer[client] != INVALID_HANDLE)
		{
			KillTimer(g_Timer[client]);
			g_Timer[client] = INVALID_HANDLE;
		}	
		
		g_ClientPour[client] = 0;
	}
}

public CreatePointEntity(i_Ent, Float:f_Add)
{
	decl Float:f_Position[3];
	
	GetEntPropVector(i_Ent, Prop_Send, "m_vecOrigin", f_Position);
	f_Position[2] += f_Add;
	
	new i_PointEnt = CreateEntityByName("point_prop_use_target");
	DispatchKeyValueVector(i_PointEnt, "origin", f_Position);
	DispatchKeyValue(i_PointEnt, "nozzle", "gas_nozzle");
	DispatchSpawn(i_PointEnt);
	
	return i_PointEnt;
}

public Action:OnPlayerRunCmd(client, &i_Buttons, &i_Impulse, Float:f_Velocity[3], Float:f_Angles[3], &i_Weapon)
{
	if (!GetConVarBool(h_CvarEnabled))
		return Plugin_Continue;
		
	if (!g_b_AllowChecking[client] || GetClientTeam(client) != 2 || IsFakeClient(client) || !IsPlayerAlive(client))
		return Plugin_Continue;
		
	if (g_ClientPour[client])
		return Plugin_Continue;
	
	if (i_Buttons & IN_ATTACK)
	{
		decl String:s_Weapon[32];
		i_Weapon = GetEntDataEnt2(client, g_ActiveWeaponOffset);
		
		if (!IsValidEnt(i_Weapon)) return Plugin_Continue;

		GetEdictClassname(i_Weapon, s_Weapon, sizeof(s_Weapon));
		new i_Skin = GetEntProp(i_Weapon, Prop_Send, "m_nSkin");

		if (StrEqual(s_Weapon, GASCAN_CLASS) && i_Skin == GASCAN_SKIN)
		{
			CheckTarget(client);
		}
		else if (StrEqual(s_Weapon, CHAINSAW_CLASS) && !GetConVarBool(h_CvarRemove))
		{
			if (GetEntProp(i_Weapon, Prop_Data, "m_iClip1") <= 1)
			{
				i_Buttons &= ~IN_ATTACK;
			}
		}
	}
	
	else if (i_Buttons & IN_USE)
	{
		i_Weapon = GetClientAimTarget(client, false);
		
		for (new i = 1; i <= MaxClients; i++)
		{
			if (g_ClientPour[i] == i_Weapon)
			{
				i_Buttons &= ~IN_USE;
				break;
			}
		}
		
		return Plugin_Continue;
	}
	
	else if (i_Buttons & IN_RELOAD)
	{
		decl String:s_Weapon[32];
		i_Weapon = GetEntDataEnt2(client, g_ActiveWeaponOffset);
		
		if (IsValidEnt(i_Weapon))
			GetEdictClassname(i_Weapon, s_Weapon, sizeof(s_Weapon));
		
		if (StrEqual(s_Weapon, CHAINSAW_CLASS) && GetConVarBool(h_CvarDrop))
		{
			new i_Ent = CreateEntityByName("weapon_pistol");
			DispatchSpawn(i_Ent);
			EquipPlayerWeapon(client, i_Ent);
			g_PlayerPistol[client] = i_Ent;
		}
	}
	return Plugin_Continue;
}

stock IsValidEnt(i_Ent)
{
	return (IsValidEdict(i_Ent) && IsValidEntity(i_Ent));
}