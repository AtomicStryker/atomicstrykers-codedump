/*

	Created by DJ_WEST
	
	Web: http://amx-x.ru
	AMX Mod X and SourceMod Russian Community
	
*/

#include <sourcemod>
#include <sdktools>

#define PLUGIN_VERSION "1.1"

#define MODEL_V_PIPEBOMB "models/v_models/v_pipebomb.mdl"
#define MODEL_V_MOLOTOV "models/v_models/v_molotov.mdl"
#define MODEL_V_VOMITJAR "models/v_models/v_bile_flask.mdl"
#define MODEL_GASCAN "models/props_junk/gascan001a.mdl"
#define MODEL_PROPANE "models/props_junk/propanecanister001a.mdl"
#define MODEL_W_PIPEBOMB "models/w_models/weapons/w_eq_pipebomb.mdl"
#define MODEL_W_MOLOTOV "models/w_models/weapons/w_eq_molotov.mdl"
#define MODEL_W_VOMITJAR "models/w_models/weapons/w_eq_bile_flask.mdl"
#define SOUND_PIPEBOMB "weapons/hegrenade/beep.wav"
#define SOUND_VOMITJAR ")weapons/ceda_jar/ceda_jar_explode.wav"
#define SOUND_MOLOTOV "weapons/molotov/fire_ignite_2.wav"
#define SOUND_PISTOL "weapons/pistol/gunfire/pistol_fire.wav"
#define SOUND_DUAL_PISTOL ")weapons/pistol/gunfire/pistol_dual_fire.wav"
#define SOUND_MAGNUM ")weapons/magnum/gunfire/magnum_shoot.wav"

#define BOUNCE_TIME 10
#define TEAM_SURVIVOR 2

new const String:g_VoicePipebombNick[7][] =
{
	"grenade01",
	"grenade02",
	"grenade05",
	"grenade07",
	"grenade09",
	"grenade11",
	"grenade13"
}

new const String:g_VoiceMolotovNick[4][] =
{
	"grenade03",
	"grenade04",
	"grenade06",
	"grenade08"
}

new const String:g_VoiceVomitjarNick[][] =
{
	"boomerjar08",
	"boomerjar09",
	"boomerjar10"
}

new const String:g_VoicePipebombRochelle[4][] =
{
	"grenade01",
	"grenade02",
	"grenade05",
	"grenade07"
}

new const String:g_VoiceMolotovRochelle[3][] =
{
	"grenade03",
	"grenade04",
	"grenade06"
}

new const String:g_VoiceVomitjarRochelle[3][] =
{
	"boomerjar07",
	"boomerjar08",
	"boomerjar09"
}

new const String:g_VoicePipebombCoach[6][] =
{
	"grenade01",
	"grenade03",
	"grenade06",
	"grenade07",
	"grenade11",
	"grenade12"
}

new const String:g_VoiceMolotovCoach[3][] =
{
	"grenade02",
	"grenade04",
	"grenade05"
}

new const String:g_VoiceVomitjarCoach[3][] =
{
	"boomerjar09",
	"boomerjar10",
	"boomerjar11"
}

new const String:g_VoicePipebombEllis[8][] =
{
	"grenade01",
	"grenade02",
	"grenade03",
	"grenade07",
	"grenade09",
	"grenade11",
	"grenade12",
	"grenade13"
}

new const String:g_VoiceMolotovEllis[4][] =
{
	"grenade05",
	"grenade06",
	"grenade08",
	"grenade10"
}

new const String:g_VoiceVomitjarEllis[6][] =
{
	"boomerjar08",
	"boomerjar09",
	"boomerjar10",
	"boomerjar12",
	"boomerjar13",
	"boomerjar14"
}

new const String:g_VoiceFrancisBill[6][] =
{
	"grenade01",
	"grenade02",
	"grenade03",
	"grenade04",
	"grenade05",
	"grenade06"
}

new const String:g_VoiceZoey[6][] =
{
	"grenade02",
	"grenade04",
	"grenade09",
	"grenade10",
	"grenade12",
	"grenade13"
}

new const String:g_VoiceLouis[7][] =
{
	"grenade01",
	"grenade02",
	"grenade03",
	"grenade04",
	"grenade05",
	"grenade06",
	"grenade07"
}

enum GRENADE_TYPE
{
	NONE,
	PIPEBOMB,
	MOLOTOV,
	VOMITJAR
}

enum GAME_MOD
{
	LEFT4DEAD,
	LEFT4DEAD2
}

new g_ActiveWeaponOffset, g_PipebombModel, g_MolotovModel, g_VomitjarModel, GRENADE_TYPE:g_PlayerIncapacitated[MAXPLAYERS+1], 
	g_PlayerWeaponModel[MAXPLAYERS+1], Float:g_PlayerGameTime[MAXPLAYERS+1], bool:g_b_Info[MAXPLAYERS+1], GAME_MOD:g_Mod, 
	g_ThrewGrenade[MAXPLAYERS+1], g_PipebombBounce[MAXPLAYERS+1], bool:g_b_InAction[MAXPLAYERS+1], Handle:g_h_GrenadeTimer[MAXPLAYERS+1],
	bool:g_b_AllowThrow[MAXPLAYERS+1], Handle:g_t_PipeTicks, Handle:h_CvarVomitjarSpeed, Handle:h_CvarPipebombSpeed, Handle:h_CvarMolotovSpeed,
	Handle:h_CvarPipebombDuration, Handle:h_CvarVomitjarDuration, Handle:h_CvarVomitjarGlowDuration, Handle:h_CvarVomitjarRadius

public Plugin:myinfo =
{
	name = "Incapped Grenade (Pipe, Molotov, Vomitjar)",
	author = "DJ_WEST",
	description = "Throw a pipebomb/molotov/vomitjar while the player is incapacitated",
	version = PLUGIN_VERSION,
	url = "http://amx-x.ru"
}

public OnPluginStart()
{
	decl String:s_Game[12], Handle:h_Version
	
	GetGameFolderName(s_Game, sizeof(s_Game))
	if (StrEqual(s_Game, "left4dead"))
		g_Mod = LEFT4DEAD
	else if (StrEqual(s_Game, "left4dead2"))
		g_Mod = LEFT4DEAD2
	else
		SetFailState("Incapped Grenade supports Left 4 Dead and Left 4 Dead 2 only!")
		
	LoadTranslations("incapped_grenade.phrases")
	
	g_ActiveWeaponOffset = FindSendPropInfo("CBasePlayer", "m_hActiveWeapon")
		
	h_Version = CreateConVar("incapped_grenade_version", PLUGIN_VERSION, "Incapped Grenade version", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY)
	h_CvarPipebombSpeed = CreateConVar("l4d_incapped_pipebomb_speed", "600.0", "Pipebomb speed", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 300.0, true, 1000.0)
	h_CvarMolotovSpeed = CreateConVar("l4d_incapped_molotov_speed", "700.0", "Molotov speed", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 300.0, true, 1000.0)
	h_CvarPipebombDuration = CreateConVar("l4d_incapped_pipebomb_duration", "6.0", "Pipebomb duration", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 0.0, true, 30.0)
	
	HookEvent("player_incapacitated", EventPlayerIncapacitated)
	HookEvent("revive_success", EventReviveSuccess)
	HookEvent("revive_begin", EventReviveBegin)
	HookEvent("revive_end", EventReviveEnd)
	HookEvent("player_death", EventPlayerDeath)
	HookEvent("grenade_bounce", EventGrenadeBounce)
	HookEvent("player_team", EventPlayerTeam)
	
	HookEvent("round_end", EventRoundEnd)
	HookEvent("pounce_stopped", EventAllowThrow)
	HookEvent("tongue_release", EventAllowThrow)
	
	if (g_Mod == LEFT4DEAD2)
	{
		HookEvent("charger_pummel_end", EventAllowThrow)
		HookEvent("defibrillator_used", EventAllowThrow)
		h_CvarVomitjarDuration = CreateConVar("l4d_incapped_vomitjar_duration", "15.0", "Vomitjar duration", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 0.0, true, 30.0)
		h_CvarVomitjarSpeed = CreateConVar("l4d_incapped_vomitjar_speed", "700.0", "Vomitjar speed", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 300.0, true, 1000.0)
		h_CvarVomitjarGlowDuration = CreateConVar("l4d_incapped_vomitjar_glowduration", "20.0", "Vomitjar glow duration", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 0.0, true, 50.0)
		h_CvarVomitjarRadius = CreateConVar("l4d_incapped_vomitjar_radius", "110.0", "Vomitjar radius", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 0.0, true, 500.0)
	}
			
	g_t_PipeTicks = CreateTrie()
	
	SetConVarString(h_Version, PLUGIN_VERSION)
}

public Action:EventRoundEnd(Handle:h_Event, const String:s_Name[], bool:b_DontBroadcast)
{
	for (new i = 1; i <= MaxClients; i++)
		if (g_h_GrenadeTimer[i] != INVALID_HANDLE)
		{
			KillTimer(g_h_GrenadeTimer[i])
			g_h_GrenadeTimer[i] = INVALID_HANDLE
		}	
}

public Action:EventPlayerTeam(Handle:h_Event, const String:s_Name[], bool:b_DontBroadcast)
{
	if (!GetEventBool(h_Event, "isbot"))
	{
		decl i_UserID, client
	
		i_UserID = GetEventInt(h_Event, "userid")
		client = GetClientOfUserId(i_UserID)
		
		if (!client || !IsClientInGame(client)) return;
		
		if (GetEventInt(h_Event, "team") == TEAM_SURVIVOR)
			CreateTimer(0.2, DelayCheckPlayer, client)
	}
}

public Action:DelayCheckPlayer(Handle:h_Timer, any:client)
{
	if (!client || !IsClientInGame(client)) return;

	if (GetEntProp(client, Prop_Send, "m_isIncapacitated") && GetGrenadeOnIncap(client) > 0)
		g_b_AllowThrow[client] = true
	else
		g_b_AllowThrow[client] = false

	GetModelIndex(INVALID_HANDLE, client)
}

public Action:EventReviveBegin(Handle:h_Event, const String:s_Name[], bool:b_DontBroadcast)
{
	decl i_UserID, client, i_Viewmodel
	
	i_UserID = GetEventInt(h_Event, "subject")
	client = GetClientOfUserId(i_UserID)
	
	if (!client || !IsClientInGame(client)) return;
	
	i_Viewmodel = GetEntPropEnt(client, Prop_Send, "m_hViewModel") 
	SetEntProp(i_Viewmodel, Prop_Send, "m_nModelIndex", g_PlayerWeaponModel[client], 2)
	SetEntProp(i_Viewmodel, Prop_Send, "m_nLayerSequence", 1)
	
	g_b_InAction[client] = false
	new i_Weapon = GetEntDataEnt2(client, g_ActiveWeaponOffset)
	SetEntPropFloat(i_Weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime())
	g_b_AllowThrow[client] = false
}

public Action:EventReviveEnd(Handle:h_Event, const String:s_Name[], bool:b_DontBroadcast)
{
	decl i_UserID, client
	
	i_UserID = GetEventInt(h_Event, "subject")
	client = GetClientOfUserId(i_UserID)
	
	if (!client || !IsClientInGame(client)) return;
	
	g_b_AllowThrow[client] = true
}


public Action:EventReviveSuccess(Handle:h_Event, const String:s_Name[], bool:b_DontBroadcast)
{
	decl i_UserID, client, i_Viewmodel
	
	i_UserID = GetEventInt(h_Event, "subject")
	client = GetClientOfUserId(i_UserID)
	
	if (!client || !IsClientInGame(client)) return;

	i_Viewmodel = GetEntPropEnt(client, Prop_Send, "m_hViewModel") 
	SetEntProp(i_Viewmodel, Prop_Send, "m_nModelIndex", g_PlayerWeaponModel[client], 2)
	SetEntProp(i_Viewmodel, Prop_Send, "m_nLayerSequence", 1)
	
	g_PlayerIncapacitated[client] = NONE
	g_b_AllowThrow[client] = false
}

public Action:EventAllowThrow(Handle:h_Event, const String:s_Name[], bool:b_DontBroadcast)
{
	decl i_UserID, client
	
	if (GetEventInt(h_Event, "victim"))
		i_UserID = GetEventInt(h_Event, "victim")
	else if (GetEventInt(h_Event, "subject"))
		i_UserID = GetEventInt(h_Event, "subject")
		
	client = GetClientOfUserId(i_UserID)
	if (!client || !IsClientInGame(client)) return;

	if (g_PlayerIncapacitated[client])
		g_b_AllowThrow[client] = true
	else
		g_b_AllowThrow[client] = false
}

public ThrowMolotov(client)
{
	decl i_Ent, Float:f_Origin[3], Float:f_Speed[3], Float:f_Angles[3], String:s_TargetName[32], Float:f_CvarSpeed
	
	i_Ent = CreateEntityByName("molotov_projectile")
	
	if (IsValidEntity(i_Ent))
	{
		SetEntPropEnt(i_Ent, Prop_Data, "m_hOwnerEntity", client)
		SetEntityModel(i_Ent, MODEL_W_MOLOTOV)
		FormatEx(s_TargetName, sizeof(s_TargetName), "molotov%d", i_Ent)
		DispatchKeyValue(i_Ent, "targetname", s_TargetName)
		DispatchSpawn(i_Ent)
	}
	
	g_ThrewGrenade[client] = i_Ent

	GetClientEyePosition(client, f_Origin)
	GetClientEyeAngles(client, f_Angles)
	GetAngleVectors(f_Angles, f_Speed, NULL_VECTOR, NULL_VECTOR)
	f_CvarSpeed = GetConVarFloat(h_CvarMolotovSpeed)
	
	f_Speed[0] *= f_CvarSpeed
	f_Speed[1] *= f_CvarSpeed
	f_Speed[2] *= f_CvarSpeed
	
	GetRandomAngles(f_Angles)
	TeleportEntity(i_Ent, f_Origin, f_Angles, f_Speed)
	EmitSoundToAll(SOUND_MOLOTOV, 0, SNDCHAN_WEAPON, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, f_Origin, NULL_VECTOR, false, 0.0)

	g_h_GrenadeTimer[client] = CreateTimer(0.1, MolotovThink, i_Ent, TIMER_REPEAT)
}

public Action:MolotovThink(Handle:h_Timer, any:i_Ent)
{
	decl Float:f_Origin[3]

	GetEntPropVector(i_Ent, Prop_Send, "m_vecOrigin", f_Origin)
	
	if (0.0 < OnGroundUnits(i_Ent) <= 10.0)
	{
		new client = GetEntPropEnt(i_Ent, Prop_Data, "m_hOwnerEntity")
		
		if (g_h_GrenadeTimer[client] != INVALID_HANDLE)
		{
			KillTimer(g_h_GrenadeTimer[client])
			g_h_GrenadeTimer[client] = INVALID_HANDLE
		}	
		
		g_ThrewGrenade[client] = 0
		RemoveEdict(i_Ent)
		
		i_Ent = CreateEntityByName("prop_physics")
		DispatchKeyValue(i_Ent, "physdamagescale", "0.0")
		DispatchKeyValue(i_Ent, "model", MODEL_GASCAN)
		DispatchSpawn(i_Ent)
		TeleportEntity(i_Ent, f_Origin, NULL_VECTOR, NULL_VECTOR)
		SetEntityMoveType(i_Ent, MOVETYPE_VPHYSICS)
		AcceptEntityInput(i_Ent, "Break")
		
		return Plugin_Continue
	}
	else
	{
		decl Float:f_Angles[3]
		
		GetRandomAngles(f_Angles)
		TeleportEntity(i_Ent, NULL_VECTOR, f_Angles, NULL_VECTOR)
	}
	
	return Plugin_Continue
}

public ThrowVomitjar(client)
{
	decl i_Ent, Float:f_Position[3], Float:f_Speed[3], Float:f_Angles[3], String:s_TargetName[32], Float:f_CvarSpeed
	
	i_Ent = CreateEntityByName("vomitjar_projectile")
	
	if (IsValidEntity(i_Ent))
	{
		SetEntPropEnt(i_Ent, Prop_Data, "m_hOwnerEntity", client)
		SetEntityModel(i_Ent, MODEL_W_VOMITJAR)
		FormatEx(s_TargetName, sizeof(s_TargetName), "vomitjar%d", i_Ent)
		DispatchKeyValue(i_Ent, "targetname", s_TargetName)
		DispatchSpawn(i_Ent)
	}
	
	g_ThrewGrenade[client] = i_Ent

	GetClientEyePosition(client, f_Position)
	GetClientEyeAngles(client, f_Angles)
	GetAngleVectors(f_Angles, f_Speed, NULL_VECTOR, NULL_VECTOR)
	f_CvarSpeed = GetConVarFloat(h_CvarVomitjarSpeed)
	
	f_Speed[0] *= f_CvarSpeed
	f_Speed[1] *= f_CvarSpeed
	f_Speed[2] *= f_CvarSpeed
	
	GetRandomAngles(f_Angles)
	TeleportEntity(i_Ent, f_Position, f_Angles, f_Speed)

	g_h_GrenadeTimer[client] = CreateTimer(0.1, VomitjarThink, i_Ent, TIMER_REPEAT)
}

public Action:VomitjarThink(Handle:h_Timer, any:i_Ent)
{
	decl Float:f_Origin[3]

	GetEntPropVector(i_Ent, Prop_Send, "m_vecOrigin", f_Origin)
	
	if (0.0 < OnGroundUnits(i_Ent) <= 15.0)
	{
		decl Float:f_EntOrigin[3], i_MaxEntities, String:s_ClassName[32], i_InfoEnt, client, Float:f_CvarDuration, i
		
		client = GetEntPropEnt(i_Ent, Prop_Data, "m_hOwnerEntity")
		
		if (g_h_GrenadeTimer[client] != INVALID_HANDLE)
		{
			KillTimer(g_h_GrenadeTimer[client])
			g_h_GrenadeTimer[client] = INVALID_HANDLE
		}	
		
		g_ThrewGrenade[client] = 0
		EmitSoundToAll(SOUND_VOMITJAR, 0, SNDCHAN_WEAPON, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, f_Origin, NULL_VECTOR, false, 0.0)
		f_CvarDuration = GetConVarFloat(h_CvarVomitjarDuration)
		RemoveEdict(i_Ent)
		DisplayParticle(f_Origin, "vomit_jar", f_CvarDuration)
		
		i_InfoEnt = CreateEntityByName("info_goal_infected_chase")
		DispatchKeyValueVector(i_InfoEnt, "origin", f_Origin)
		DispatchSpawn(i_InfoEnt)
		AcceptEntityInput(i_InfoEnt, "Enable")
		CreateTimer(f_CvarDuration, DeleteEntity, i_InfoEnt)
		
		i_MaxEntities = GetMaxEntities()
		for (i = 1; i <= i_MaxEntities; i++)
		{
			if (IsValidEdict(i) && IsValidEntity(i))
			{
				GetEdictClassname(i, s_ClassName, sizeof(s_ClassName))

				if (StrEqual(s_ClassName, "infected"))
				{
					GetEntPropVector(i, Prop_Send, "m_vecOrigin", f_EntOrigin)
					
					if (GetVectorDistance(f_Origin, f_EntOrigin) <= GetConVarFloat(h_CvarVomitjarRadius))
					{
						SetEntProp(i, Prop_Send, "m_iGlowType", 3)
						SetEntProp(i, Prop_Send, "m_glowColorOverride", -4713783)
						CreateTimer(GetConVarFloat(h_CvarVomitjarGlowDuration), DisableGlow, i)
					}
				}
			}
		}
		
		return Plugin_Continue
	}
	else
	{
		decl Float:f_Angles[3]
		
		GetRandomAngles(f_Angles)
		TeleportEntity(i_Ent, NULL_VECTOR, f_Angles, NULL_VECTOR)
	}
	
	return Plugin_Continue
}

public ThrowPipebomb(client)
{
	decl i_Ent, Float:f_Position[3], Float:f_Angles[3], Float:f_Speed[3], String:s_Ent[4], String:s_TargetName[32],
		Float:f_CvarSpeed
	
	i_Ent = CreateEntityByName("pipe_bomb_projectile")
	
	if (IsValidEntity(i_Ent))
	{
		SetEntPropEnt(i_Ent, Prop_Data, "m_hOwnerEntity", client)
		SetEntityModel(i_Ent, MODEL_W_PIPEBOMB)
		FormatEx(s_TargetName, sizeof(s_TargetName), "pipebomb%d", i_Ent)
		DispatchKeyValue(i_Ent, "targetname", s_TargetName)
		DispatchSpawn(i_Ent)
	}
	
	g_ThrewGrenade[client] = i_Ent

	GetClientEyePosition(client, f_Position)
	GetClientEyeAngles(client, f_Angles)
	GetAngleVectors(f_Angles, f_Speed, NULL_VECTOR, NULL_VECTOR)
	f_CvarSpeed = GetConVarFloat(h_CvarPipebombSpeed)
	
	f_Speed[0] *= f_CvarSpeed
	f_Speed[1] *= f_CvarSpeed
	f_Speed[2] *= f_CvarSpeed
	
	GetRandomAngles(f_Angles)
	TeleportEntity(i_Ent, f_Position, f_Angles, f_Speed)
	AttachParticle(i_Ent, "weapon_pipebomb_blinking_light", f_Position)
	AttachParticle(i_Ent, "weapon_pipebomb_fuse", f_Position)
	AttachInfected(i_Ent, f_Position)
	
	IntToString(i_Ent, s_Ent, sizeof(s_Ent))
	SetTrieValue(g_t_PipeTicks, s_Ent, 0)
	
	g_h_GrenadeTimer[client] = CreateTimer(0.1, PipebombThink, i_Ent, TIMER_REPEAT)
}

public Action:PipebombThink(Handle:h_Timer, any:i_Ent)
{
	decl i_Count, String:s_Ent[5], Float:f_Angles[3], Float:f_Origin[3], Float:f_Units, Float:f_CvarDuration

	IntToString(i_Ent, s_Ent, sizeof(s_Ent))
	GetTrieValue(g_t_PipeTicks, s_Ent, i_Count)
	GetEntPropVector(i_Ent, Prop_Send, "m_vecOrigin", f_Origin)
	f_CvarDuration = GetConVarFloat(h_CvarPipebombDuration) * 10
	
	if (i_Count >= f_CvarDuration)
	{
		new client = GetEntPropEnt(i_Ent, Prop_Data, "m_hOwnerEntity")
		
		if (g_h_GrenadeTimer[client] != INVALID_HANDLE)
		{
			KillTimer(g_h_GrenadeTimer[client])
			g_h_GrenadeTimer[client] = INVALID_HANDLE
		}	
		
		g_ThrewGrenade[client] = 0
		g_PipebombBounce[client] = 0
		RemoveFromTrie(g_t_PipeTicks, s_Ent)
		RemoveEdict(i_Ent)
		
		i_Ent = CreateEntityByName("prop_physics")
		DispatchKeyValue(i_Ent, "physdamagescale", "0.0")
		DispatchKeyValue(i_Ent, "model", MODEL_PROPANE)
		DispatchSpawn(i_Ent)
		TeleportEntity(i_Ent, f_Origin, NULL_VECTOR, NULL_VECTOR)
		SetEntityMoveType(i_Ent, MOVETYPE_VPHYSICS)
		AcceptEntityInput(i_Ent, "Break")
		
		return Plugin_Continue
	}
	
	if (i_Count >= BOUNCE_TIME)
	{
		f_Angles[0] = 90.0
		f_Angles[1] = 0.0
		f_Angles[2] = 0.0
			
		TeleportEntity(i_Ent, NULL_VECTOR, f_Angles, NULL_VECTOR)
		
		f_Units = OnGroundUnits(i_Ent)
		
		if (0.0 < f_Units <= 7.0)
		{
			f_Origin[2] -= f_Units - 2.0
			SetEntPropVector(i_Ent, Prop_Send, "m_vecOrigin", f_Origin)
			SetEntityMoveType(i_Ent, MOVETYPE_NONE)
		}
	}
	else
	{
		GetRandomAngles(f_Angles)
		TeleportEntity(i_Ent, NULL_VECTOR, f_Angles, NULL_VECTOR)
	}
	
	switch (i_Count)
	{
		case 4,8,12,16,20,23,26,29,32,35,37,39,41,43,45:
			EmitSoundToAll(SOUND_PIPEBOMB, 0, SNDCHAN_WEAPON, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, f_Origin, NULL_VECTOR, false, 0.0)
	}
	
	if (i_Count > 45)
		EmitSoundToAll(SOUND_PIPEBOMB, 0, SNDCHAN_WEAPON, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, f_Origin, NULL_VECTOR, false, 0.0)
	
	i_Count++
	SetTrieValue(g_t_PipeTicks, s_Ent, i_Count)
	
	return Plugin_Continue
}

public Action:DisableGlow(Handle:h_Timer, any:i_Ent)
{
	if (IsValidEdict(i_Ent) && IsValidEntity(i_Ent))
	{
		SetEntProp(i_Ent, Prop_Send, "m_iGlowType", 0)
		SetEntProp(i_Ent, Prop_Send, "m_glowColorOverride", 0)
	}
}

public Float:OnGroundUnits(i_Ent)
{
	if (!(GetEntityFlags(i_Ent) & (FL_ONGROUND)))
	{ 
		decl Handle:h_Trace, Float:f_Origin[3], Float:f_Position[3], Float:f_Down[3] = { 90.0, 0.0, 0.0 }
		
		GetEntPropVector(i_Ent, Prop_Send, "m_vecOrigin", f_Origin)
		h_Trace = TR_TraceRayFilterEx(f_Origin, f_Down, CONTENTS_SOLID|CONTENTS_MOVEABLE, RayType_Infinite, TraceFilterClients, i_Ent)

		if (TR_DidHit(h_Trace))
		{
			decl Float:f_Units
			TR_GetEndPosition(f_Position, h_Trace)
			
			f_Units = f_Origin[2] - f_Position[2]

			CloseHandle(h_Trace)
			
			return f_Units
		} 
	
		CloseHandle(h_Trace)
	} 
	
	return 0.0
}

public bool:TraceFilterClients(i_Entity, i_Mask, any:i_Data)
{
	if (i_Entity == i_Data)
		return false
	if (i_Entity >= 1 && i_Entity <= MaxClients)
		return false
		
	return true
}

public OnMapStart()
{
	g_PipebombModel = PrecacheModel(MODEL_V_PIPEBOMB, true)
	g_MolotovModel = PrecacheModel(MODEL_V_MOLOTOV, true)
	
	if (!IsModelPrecached(MODEL_PROPANE))
		PrecacheModel(MODEL_PROPANE, true)
	if (!IsModelPrecached(MODEL_GASCAN))
		PrecacheModel(MODEL_GASCAN, true)
	if (!IsModelPrecached(MODEL_W_PIPEBOMB))
		PrecacheModel(MODEL_W_PIPEBOMB, true)
	if (!IsModelPrecached(MODEL_W_MOLOTOV))
		PrecacheModel(MODEL_W_MOLOTOV, true)
		
	if (!IsSoundPrecached(SOUND_PIPEBOMB))
		PrecacheSound(SOUND_PIPEBOMB, true)
	if (!IsSoundPrecached(SOUND_MOLOTOV))
			PrecacheSound(SOUND_MOLOTOV, true)
					
	if (g_Mod == LEFT4DEAD2)
	{
		g_VomitjarModel = PrecacheModel(MODEL_V_VOMITJAR, true)
		
		if (!IsModelPrecached(MODEL_W_VOMITJAR))
			PrecacheModel(MODEL_W_VOMITJAR, true)
			
		if (!IsSoundPrecached(SOUND_VOMITJAR))
			PrecacheSound(SOUND_VOMITJAR, true)
	}
}

public OnClientPutInServer(client)
{
	if (IsFakeClient(client))
		return
		
	g_PlayerIncapacitated[client] = NONE
	g_b_Info[client] = false
	g_b_InAction[client] = false
	g_b_AllowThrow[client] = false
	g_PlayerWeaponModel[client] = 0
	g_PlayerGameTime[client] = 0.0
	g_ThrewGrenade[client] = 0
	g_PipebombBounce[client] = 0
}

public Action:EventPlayerIncapacitated(Handle:h_Event, const String:s_Name[], bool:b_DontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(h_Event, "userid"))
	if (!client || !IsClientInGame(client)) return Plugin_Continue
	
	if (IsFakeClient(client))
		return Plugin_Continue
		
	if (GetClientTeam(client) == TEAM_SURVIVOR)
	{	
		if (GetGrenadeOnIncap(client) > 0)
		{
			if (!g_b_Info[client])
			{
				PrintToChat(client, "\x03[%t]\x01 %t.", "Information", "Throw a grenade")
				g_b_Info[client] = true
			}
			
			CreateTimer(0.2, GetModelIndex, client)
		}
	}
	
	return Plugin_Continue
}

public GetGrenadeOnIncap(client)
{
	decl i_Grenade, String:s_ModelName[64]
	
	if (GetEntProp(client, Prop_Send, "m_pounceAttacker") > 0 || GetEntProp(client, Prop_Send, "m_tongueOwner") > 0 || (g_Mod == LEFT4DEAD2 && GetEntProp(client, Prop_Send, "m_pummelAttacker") > 0))
		g_b_AllowThrow[client] = false
		else
		g_b_AllowThrow[client] = true

	i_Grenade = GetPlayerWeaponSlot(client, 2)
		
	if (IsValidEntity(i_Grenade))
	{
		GetEntPropString(i_Grenade, Prop_Data, "m_ModelName", s_ModelName, sizeof(s_ModelName))
		
		if (StrEqual(s_ModelName, MODEL_V_PIPEBOMB))
			g_PlayerIncapacitated[client] = PIPEBOMB
		else if (StrEqual(s_ModelName, MODEL_V_MOLOTOV))
			g_PlayerIncapacitated[client] = MOLOTOV
		else if (StrEqual(s_ModelName, MODEL_V_VOMITJAR))
			g_PlayerIncapacitated[client] = VOMITJAR
	}

	return i_Grenade
}


public Action:GetModelIndex(Handle:h_Timer, any:client)
{
	decl i_Viemodel
	
	i_Viemodel = GetEntPropEnt(client, Prop_Send, "m_hViewModel") 
	g_PlayerWeaponModel[client] = GetEntProp(i_Viemodel, Prop_Send, "m_nModelIndex")
}

public Action:EventGrenadeBounce(Handle:h_Event, const String:s_Name[], bool:b_DontBroadcast)
{
	decl i_UserID, client, i_Ent
	
	i_UserID = GetEventInt(h_Event, "userid")
	client = GetClientOfUserId(i_UserID)
	if (!client || !IsClientInGame(client)) return;
	i_Ent = g_ThrewGrenade[client]
	
	if (i_Ent)
	{
		decl Float:f_Speed[3], String:s_ClassName[32]
		
		GetEdictClassname(i_Ent, s_ClassName, sizeof(s_ClassName))
		GetEntPropVector(i_Ent, Prop_Send, "m_vecVelocity", f_Speed)
		
		if (StrEqual(s_ClassName, "pipe_bomb_projectile"))
			g_PipebombBounce[client]++
			
		if (g_PipebombBounce[client] >= 2)
		{
			f_Speed[0] /= 1.3
			f_Speed[1] /= 1.3
			f_Speed[2] /= 1.3
		}
		else if (!g_PipebombBounce[client])
		{
			f_Speed[0] /= 3.0
			f_Speed[1] /= 3.0
			f_Speed[2] /= 3.0
		}
		
		TeleportEntity(i_Ent, NULL_VECTOR, NULL_VECTOR, f_Speed)
	}
}

public Action:EventPlayerDeath(Handle:h_Event, const String:s_Name[], bool:b_DontBroadcast)
{
	decl i_UserID, client
	
	i_UserID = GetEventInt(h_Event, "userid")
	client = GetClientOfUserId(i_UserID)
	if (!client || !IsClientInGame(client)) return;
	
	if (client >= 1 && client <= MaxClients)
		if (GetClientTeam(client) == TEAM_SURVIVOR)
			g_PlayerIncapacitated[client] = NONE
}

public Action:OnPlayerRunCmd(client, &i_Buttons, &i_Impulse, Float:f_Velocity[3], Float:f_Angles[3], &i_Weapon)
{
	if (IsFakeClient(client))
		return Plugin_Continue
		
	if (!g_b_AllowThrow[client])
		return Plugin_Continue

	if (!g_PlayerIncapacitated[client])
		return Plugin_Continue
	
	if (g_b_InAction[client] && (i_Buttons & IN_ATTACK))
	{
		decl i_Viewmodel
		
		i_Viewmodel = GetEntPropEnt(client, Prop_Send, "m_hViewModel")
		g_Mod == LEFT4DEAD ? SetEntProp(i_Viewmodel, Prop_Send, "m_nLayerSequence", 7) : SetEntProp(i_Viewmodel, Prop_Send, "m_nLayerSequence", 5)
		
		i_Buttons &= ~IN_FORWARD
		
		return Plugin_Continue
	}
	else if (g_b_InAction[client])
	{
		g_b_InAction[client] = false
		decl i_Viewmodel, i_Grenade

		i_Viewmodel = GetEntPropEnt(client, Prop_Send, "m_hViewModel")
		g_Mod == LEFT4DEAD ? SetEntProp(i_Viewmodel, Prop_Send, "m_nLayerSequence", 9) : SetEntProp(i_Viewmodel, Prop_Send, "m_nLayerSequence", 6)
		SetEntPropFloat(i_Viewmodel, Prop_Send, "m_flLayerStartTime", GetGameTime())
		
		PlayScene(client)
		
		switch (g_PlayerIncapacitated[client])
		{
			case PIPEBOMB: ThrowPipebomb(client)
			case MOLOTOV: ThrowMolotov(client)
			case VOMITJAR: ThrowVomitjar(client)
		}
		
		i_Grenade = GetPlayerWeaponSlot(client, 2)
		RemoveEdict(i_Grenade)
		g_PlayerIncapacitated[client] = NONE
		
		i_Weapon = GetEntDataEnt2(client, g_ActiveWeaponOffset)
		SetEntPropFloat(i_Weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + 2.0)	
		CreateTimer(1.0, ReturnPistolDelay, client)
			
		return Plugin_Continue
	}
	
	decl i_GrenadeType
	i_GrenadeType = 0
	
	switch (g_PlayerIncapacitated[client])
	{
		case PIPEBOMB: i_GrenadeType = g_PipebombModel
		case MOLOTOV: i_GrenadeType = g_MolotovModel
		case VOMITJAR: i_GrenadeType = g_VomitjarModel
	}
	
	if (i_GrenadeType && !(i_Buttons & IN_FORWARD))
	{
		decl i_Viewmodel, i_Model
		
		i_Viewmodel = GetEntPropEnt(client, Prop_Send, "m_hViewModel")
		i_Model = GetEntProp(i_Viewmodel, Prop_Send, "m_nModelIndex")
		
		if (i_Model == i_GrenadeType)
			g_Mod == LEFT4DEAD ? SetEntProp(i_Viewmodel, Prop_Send, "m_nLayerSequence", 3) : SetEntProp(i_Viewmodel, Prop_Send, "m_nLayerSequence", 1)
			
		if (i_Buttons & IN_ATTACK)
		{
			if (i_Model != i_GrenadeType)
				return Plugin_Continue
			
			g_Mod == LEFT4DEAD ? SetEntProp(i_Viewmodel, Prop_Send, "m_nLayerSequence", 7) : SetEntProp(i_Viewmodel, Prop_Send, "m_nLayerSequence", 5)
			SetEntPropFloat(i_Viewmodel, Prop_Send, "m_flLayerStartTime", GetGameTime())
			i_Weapon = GetEntDataEnt2(client, g_ActiveWeaponOffset)
			SetEntPropFloat(i_Weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + 100.0)
			
			g_b_InAction[client] = true
			
			decl String:s_Sound[64]
			if (g_Mod == LEFT4DEAD)
			{
				FormatEx(s_Sound, sizeof(s_Sound), "^%s", SOUND_PISTOL)
				StopSound(client, SNDCHAN_WEAPON, s_Sound)
			}
			else if (g_Mod == LEFT4DEAD2)
			{
				FormatEx(s_Sound, sizeof(s_Sound), ")%s", SOUND_PISTOL)
				StopSound(client, SNDCHAN_WEAPON, s_Sound)
				StopSound(client, SNDCHAN_WEAPON, SOUND_DUAL_PISTOL)
				StopSound(client, SNDCHAN_WEAPON, SOUND_MAGNUM)
			}
		}
		else if (i_Buttons & IN_ATTACK2)
		{
			if ((GetGameTime() - g_PlayerGameTime[client]) < 1.0)
				return Plugin_Continue
			
			i_Weapon = GetEntDataEnt2(client, g_ActiveWeaponOffset)
			
			if (GetEntProp(i_Weapon, Prop_Data, "m_bInReload"))
				return Plugin_Continue
		
			if (i_Model != i_GrenadeType)
			{
				SetEntProp(i_Viewmodel, Prop_Send, "m_nModelIndex", i_GrenadeType, 2)
				g_Mod == LEFT4DEAD ? SetEntProp(i_Viewmodel, Prop_Send, "m_nLayerSequence", 3) : SetEntProp(i_Viewmodel, Prop_Send, "m_nLayerSequence", 1)
				g_PlayerGameTime[client] = GetGameTime()
			}
			else
			{
				SetEntProp(i_Viewmodel, Prop_Send, "m_nModelIndex", g_PlayerWeaponModel[client], 2)
				SetEntProp(i_Viewmodel, Prop_Send, "m_nLayerSequence", 1)
				g_PlayerGameTime[client] = GetGameTime()
			}
		}
		else if (i_Buttons & IN_RELOAD)
		{
			if (i_Model == i_GrenadeType)
				i_Buttons &= ~IN_RELOAD
		}
	}
	
	return Plugin_Continue
}

public Action:ReturnPistolDelay(Handle:h_Timer, any:client)
{
	new i_Viewmodel = GetEntPropEnt(client, Prop_Send, "m_hViewModel")
	g_Mod == LEFT4DEAD ? SetEntProp(i_Viewmodel, Prop_Send, "m_nLayerSequence", 15) : SetEntProp(i_Viewmodel, Prop_Send, "m_nLayerSequence", 2)
	SetEntProp(i_Viewmodel, Prop_Send, "m_nModelIndex", g_PlayerWeaponModel[client], 2)
	SetEntPropFloat(i_Viewmodel, Prop_Send, "m_flLayerStartTime", GetGameTime())	
}

public AttachParticle(i_Ent, String:s_Effect[], Float:f_Origin[3])
{
	decl i_Particle, String:s_TargetName[32]
	
	i_Particle = CreateEntityByName("info_particle_system")
	
	if (IsValidEdict(i_Particle))
	{
		if (StrEqual(s_Effect, "weapon_pipebomb_fuse"))
		{
			f_Origin[0] += 0.3
			f_Origin[1] += 1.7
			f_Origin[2] += 7.5
		}
		TeleportEntity(i_Particle, f_Origin, NULL_VECTOR, NULL_VECTOR)
		FormatEx(s_TargetName, sizeof(s_TargetName), "particle%d", i_Ent)
		DispatchKeyValue(i_Particle, "targetname", s_TargetName)
		GetEntPropString(i_Ent, Prop_Data, "m_iName", s_TargetName, sizeof(s_TargetName))
		DispatchKeyValue(i_Particle, "parentname", s_TargetName)
		DispatchKeyValue(i_Particle, "effect_name", s_Effect)
		DispatchSpawn(i_Particle)
		SetVariantString(s_TargetName)
		AcceptEntityInput(i_Particle, "SetParent", i_Particle, i_Particle, 0)
		ActivateEntity(i_Particle)
		AcceptEntityInput(i_Particle, "Start")
	}

	return i_Particle
}

public AttachInfected(i_Ent, Float:f_Origin[3])
{
	decl i_InfoEnt, String:s_TargetName[32]
	
	i_InfoEnt = CreateEntityByName("info_goal_infected_chase")
	
	if (IsValidEdict(i_InfoEnt))
	{
		f_Origin[2] += 20.0
		DispatchKeyValueVector(i_InfoEnt, "origin", f_Origin)
		FormatEx(s_TargetName, sizeof(s_TargetName), "goal_infected%d", i_Ent)
		DispatchKeyValue(i_InfoEnt, "targetname", s_TargetName)
		GetEntPropString(i_Ent, Prop_Data, "m_iName", s_TargetName, sizeof(s_TargetName))
		DispatchKeyValue(i_InfoEnt, "parentname", s_TargetName)
		DispatchSpawn(i_InfoEnt)
		SetVariantString(s_TargetName)
		AcceptEntityInput(i_InfoEnt, "SetParent", i_InfoEnt, i_InfoEnt, 0)
		ActivateEntity(i_InfoEnt)
		AcceptEntityInput(i_InfoEnt, "Enable")
	}

	return i_InfoEnt
}

public DisplayParticle(Float:f_Position[3], String:s_Name[], Float:f_Time)
{
	decl i_Particle
	
	i_Particle = CreateEntityByName("info_particle_system")
	if (IsValidEdict(i_Particle))
	{
		TeleportEntity(i_Particle, f_Position, NULL_VECTOR, NULL_VECTOR)
		DispatchKeyValue(i_Particle, "effect_name", s_Name)
		DispatchSpawn(i_Particle)
		ActivateEntity(i_Particle)
		AcceptEntityInput(i_Particle, "Start")
		CreateTimer(f_Time, DeleteEntity, i_Particle)
	}
}

public PlayScene(client)
{
	decl i_Ent, String:s_Model[128], String:s_SceneFile[32], i_Random
	
	GetEntPropString(client, Prop_Data, "m_ModelName", s_Model, sizeof(s_Model))
	
	if (g_Mod == LEFT4DEAD)
	{
		if (StrContains(s_Model, "biker") != -1)
		{
			if (g_PlayerIncapacitated[client] != NONE)
			{
				i_Random = GetRandomInt(0, sizeof(g_VoiceFrancisBill)-1)
				FormatEx(s_SceneFile, sizeof(s_SceneFile), "scenes/biker/%s.vcd", g_VoiceFrancisBill[i_Random])
			}	
		}
		else if (StrContains(s_Model, "manager") != -1)
		{
			if (g_PlayerIncapacitated[client] != NONE)
			{
				i_Random = GetRandomInt(0, sizeof(g_VoiceLouis)-1)
				FormatEx(s_SceneFile, sizeof(s_SceneFile), "scenes/manager/%s.vcd", g_VoiceLouis[i_Random])
			}	
		}
		else if (StrContains(s_Model, "namvet") != -1)
		{
			if (g_PlayerIncapacitated[client] != NONE)
			{
				i_Random = GetRandomInt(0, sizeof(g_VoiceFrancisBill)-1)
				FormatEx(s_SceneFile, sizeof(s_SceneFile), "scenes/namvet/%s.vcd", g_VoiceFrancisBill[i_Random])
			}	
		}
		else if (StrContains(s_Model, "teenangst") != -1)
		{
			if (g_PlayerIncapacitated[client] != NONE)
			{
				i_Random = GetRandomInt(0, sizeof(g_VoiceZoey)-1)
				FormatEx(s_SceneFile, sizeof(s_SceneFile), "scenes/teengirl/%s.vcd", g_VoiceZoey[i_Random])
			}	
		}	
	}
	else if (g_Mod == LEFT4DEAD2)
	{
		if (StrContains(s_Model, "gambler") != -1)
		{
			switch (g_PlayerIncapacitated[client])
			{
				case PIPEBOMB:
				{
					i_Random = GetRandomInt(0, sizeof(g_VoicePipebombNick)-1)
					FormatEx(s_SceneFile, sizeof(s_SceneFile), "scenes/gambler/%s.vcd", g_VoicePipebombNick[i_Random])
				}
				case MOLOTOV:
				{
					i_Random = GetRandomInt(0, sizeof(g_VoiceMolotovNick)-1)
					FormatEx(s_SceneFile, sizeof(s_SceneFile), "scenes/gambler/%s.vcd", g_VoiceMolotovNick[i_Random])
				}
				case VOMITJAR:
				{
					i_Random = GetRandomInt(0, sizeof(g_VoiceVomitjarNick)-1)
					FormatEx(s_SceneFile, sizeof(s_SceneFile), "scenes/gambler/%s.vcd", g_VoiceVomitjarNick[i_Random])
				}
			}
		}
		else if (StrContains(s_Model, "coach") != -1)
		{
			switch (g_PlayerIncapacitated[client])
			{
				case PIPEBOMB:
				{
					i_Random = GetRandomInt(0, sizeof(g_VoicePipebombCoach)-1)
					FormatEx(s_SceneFile, sizeof(s_SceneFile), "scenes/coach/%s.vcd", g_VoicePipebombCoach[i_Random])
				}
				case MOLOTOV:
				{
					i_Random = GetRandomInt(0, sizeof(g_VoiceMolotovCoach)-1)
					FormatEx(s_SceneFile, sizeof(s_SceneFile), "scenes/coach/%s.vcd", g_VoiceMolotovCoach[i_Random])
				}
				case VOMITJAR:
				{
					i_Random = GetRandomInt(0, sizeof(g_VoiceVomitjarCoach)-1)
					FormatEx(s_SceneFile, sizeof(s_SceneFile), "scenes/coach/%s.vcd", g_VoiceVomitjarCoach[i_Random])
				}
			}	
		}
		else if (StrContains(s_Model, "mechanic") != -1)
		{
			switch (g_PlayerIncapacitated[client])
			{
				case PIPEBOMB:
				{
					i_Random = GetRandomInt(0, sizeof(g_VoicePipebombEllis)-1)
					FormatEx(s_SceneFile, sizeof(s_SceneFile), "scenes/mechanic/%s.vcd", g_VoicePipebombEllis[i_Random])
				}
				case MOLOTOV:
				{
					i_Random = GetRandomInt(0, sizeof(g_VoiceMolotovEllis)-1)
					FormatEx(s_SceneFile, sizeof(s_SceneFile), "scenes/mechanic/%s.vcd", g_VoiceMolotovEllis[i_Random])
				}
				case VOMITJAR:
				{
					i_Random = GetRandomInt(0, sizeof(g_VoiceVomitjarEllis)-1)
					FormatEx(s_SceneFile, sizeof(s_SceneFile), "scenes/mechanic/%s.vcd", g_VoiceVomitjarEllis[i_Random])
				}
			}	
		}
		else if (StrContains(s_Model, "producer") != -1)
		{
			switch (g_PlayerIncapacitated[client])
			{
				case PIPEBOMB:
				{
					i_Random = GetRandomInt(0, sizeof(g_VoicePipebombRochelle)-1)
					FormatEx(s_SceneFile, sizeof(s_SceneFile), "scenes/producer/%s.vcd", g_VoicePipebombRochelle[i_Random])
				}
				case MOLOTOV:
				{
					i_Random = GetRandomInt(0, sizeof(g_VoiceMolotovRochelle)-1)
					FormatEx(s_SceneFile, sizeof(s_SceneFile), "scenes/producer/%s.vcd", g_VoiceMolotovRochelle[i_Random])
				}
				case VOMITJAR:
				{
					i_Random = GetRandomInt(0, sizeof(g_VoiceVomitjarRochelle)-1)
					FormatEx(s_SceneFile, sizeof(s_SceneFile), "scenes/producer/%s.vcd", g_VoiceVomitjarRochelle[i_Random])
				}
			}	
		}
	}
		
	i_Ent = CreateEntityByName("instanced_scripted_scene")
	DispatchKeyValue(i_Ent, "SceneFile", s_SceneFile)
	DispatchSpawn(i_Ent)
	SetEntPropEnt(i_Ent, Prop_Data, "m_hOwner", client)
	ActivateEntity(i_Ent)
	AcceptEntityInput(i_Ent, "Start", client, client)
	HookSingleEntityOutput(i_Ent, "OnCompletion", EntityOutput:OnSceneCompletion, true)
}

stock GetRandomAngles(Float:f_Angles[3])
{
	f_Angles[0] = GetRandomFloat(-180.0, 180.0)
	f_Angles[1] = GetRandomFloat(-180.0, 180.0)
	f_Angles[2] = GetRandomFloat(-180.0, 180.0)
}

public OnSceneCompletion(const String:s_Output[], i_Caller, i_Activator, Float:f_Delay)
	RemoveEdict(i_Caller)

public Action:DeleteEntity(Handle:h_Timer, any:i_Ent)
{
	if (IsValidEntity(i_Ent))
			RemoveEdict(i_Ent)
}