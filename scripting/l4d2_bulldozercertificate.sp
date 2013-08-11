#include <sourcemod>
#include <sdktools>

#define PLUGIN_VERSION		"1.1.2"
#pragma semicolon			1
#define TEST_DEBUG			0
#define TEST_DEBUG_LOG		0
#define STRINGLENGTH_AUTH_ID	32


static const Float:UNINCAP_TIME_ON_IMPACT			= 1.0;
static const Float:CHARGE_CHECKING_INTERVAL			= 0.4;
static const Float:CHARGER_COLLISION_RADIUS			= 150.0;
static const Float:HEALTH_SET_DELAY					= 0.3;

static const String:ENTPROP_HANGING_FROM_LEDGE[]	= "m_isHangingFromLedge";
static const String:ENTPROP_FALLING_FROM_LEDGE[]	= "m_isFallingFromLedge";

static const L4D2_TEAM_SURVIVOR						= 2;


static Handle:ReinCapTimerArray[MAXPLAYERS+1]		= INVALID_HANDLE;
static bool:KillChargerTimer[MAXPLAYERS+1]		= false;
static String:steamIdVictim[MAXPLAYERS+1][STRINGLENGTH_AUTH_ID];
static IncappedHealth[MAXPLAYERS+1]					= 0;


public Plugin:myinfo =
{
	name = "[L4D2] Bulldozer Certification",
	author = "AtomicStryker",
	description = "Lets Chargers hit incapped Survivors",
	version = PLUGIN_VERSION,
	url = "http://forums.alliedmods.net/showthread.php?t=109797"
}

public OnPluginStart()
{
	CreateConVar("l4d2_bulldozercertificate_version", PLUGIN_VERSION, "L4D2 Bulldozer Certification Version on this server", FCVAR_PLUGIN | FCVAR_SPONLY | FCVAR_NOTIFY | FCVAR_DONTRECORD);

	HookEvent("charger_charge_start", BC_Event_Charge);
	HookEvent("charger_impact", BC_Event_Impact);

	HookEvent("charger_charge_end", BC_Event_ChargeEnd);
	HookEvent("charger_killed", BC_Event_ChargeEnd);	
}

public Action:BC_Event_Charge(Handle:event, String:event_name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (client < 1
	|| client > MAXPLAYERS
	|| !IsClientInGame(client))
		return;
	
	KillChargerTimer[client] = false;
	TriggerTimer(CreateTimer(CHARGE_CHECKING_INTERVAL, BC_CheckForIncapped, client, TIMER_REPEAT), true);
	
	DebugPrintToAll("Charge caught, starting ChargerTimer");
}

public Action:BC_Event_ChargeEnd(Handle:event, String:event_name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (client < 1
	|| client > MAXPLAYERS
	|| !IsClientInGame(client))
		return;
	
	KillChargerTimer[client] = true;
	DebugPrintToAll("Charge(r) end caught, killing ChargerTimer");
	CreateTimer(UNINCAP_TIME_ON_IMPACT, BC_WipeHealthArray);
}

public OnMapEnd()
{
	for (new i = 1; i <= MaxClients; i++)
	{
		ReinCapTimerArray[i] = INVALID_HANDLE;
	}
}

public Action:BC_Event_Impact(Handle:event, String:event_name[], bool:dontBroadcast)
{
	new target = GetClientOfUserId(GetEventInt(event, "victim"));	
	if (ReinCapTimerArray[target] != INVALID_HANDLE)
	{
		CloseHandle(ReinCapTimerArray[target]);
		ReinCapTimerArray[target] = INVALID_HANDLE;
		ReinCapTimerArray[target] = CreateTimer(UNINCAP_TIME_ON_IMPACT*2, BC_Reincap, target);
		
		DebugPrintToAll("Charger hit a temporary unincapped, extended timer");
	}
}

public Action:BC_CheckForIncapped(Handle:timer, any:client)
{
	if (!client
	|| !IsClientInGame(client)
	|| KillChargerTimer[client])
	{
		KillChargerTimer[client] = false;
		return Plugin_Stop;
	}
	decl Float:targetpos[3], Float:chargerpos[3];
	
	for (new target = 1; target <= MaxClients; target++)
	{
		if (target == client) continue;
		if (!IsClientInGame(target)) continue;
		if (GetClientTeam(target) != L4D2_TEAM_SURVIVOR) continue;
		if (!IsPlayerIncapped(target)) continue;
		if (GetEntProp(target, Prop_Send, ENTPROP_HANGING_FROM_LEDGE) || GetEntProp(target, Prop_Send, ENTPROP_FALLING_FROM_LEDGE)) continue;
		
		GetClientAbsOrigin(target, targetpos);
		GetClientAbsOrigin(client, chargerpos);
		
		if (GetVectorDistance(targetpos, chargerpos) < CHARGER_COLLISION_RADIUS)
		{
			DebugPrintToAll("Incapped %N found on way, un-incapping", target);
		
			if (IncappedHealth[target] == -1)
			{
				IncappedHealth[target] = GetClientHealth(target);
			}
			
			decl String:auth[STRINGLENGTH_AUTH_ID];
			GetClientAuthString(target, auth, sizeof(auth));
			strcopy(steamIdVictim[target], STRINGLENGTH_AUTH_ID, auth);
			SetPlayerIncapState(target, false);
			ReinCapTimerArray[target] = CreateTimer(UNINCAP_TIME_ON_IMPACT, BC_Reincap, target);
		}
	}
	return Plugin_Continue;
}

public Action:BC_Reincap(Handle:timer, any:client)
{
	ReinCapTimerArray[client] = INVALID_HANDLE;
	
	if (!IsValidEntity(client) || !IsPlayerAlive(client)) return;
	
	decl String:auth[STRINGLENGTH_AUTH_ID];
	GetClientAuthString(client, auth, sizeof(auth));
	if (!StrEqual(auth, steamIdVictim[client])) return;
	
	SetPlayerIncapState(client, true);
	
	CreateTimer(HEALTH_SET_DELAY, BC_SetHealthDelayed, client);
	
	DebugPrintToAll("Re-Incapped %N", client);
}

public Action:BC_SetHealthDelayed(Handle:timer, any:client)
{
	if (IsValidEntity(client) && IncappedHealth[client] > 1 && IsPlayerIncapped(client))
	{
		SetEntityHealth(client, IncappedHealth[client]);
	}
}

public Action:BC_WipeHealthArray(Handle:timer, any:client)
{
	for (new i = 1; i <= MaxClients; i++)
	{
		IncappedHealth[i] = -1;
	}
}

stock SetPlayerIncapState(client, any:incap)
{
	SetEntProp(client, Prop_Send, "m_isIncapacitated", incap);
}

stock bool:IsPlayerIncapped(client)
{
	if (GetEntProp(client, Prop_Send, "m_isIncapacitated", 1)) return true;
	else return false;
}

stock DebugPrintToAll(const String:format[], any:...)
{
	#if (TEST_DEBUG || TEST_DEBUG_LOG)
	decl String:buffer[256];
	
	VFormat(buffer, sizeof(buffer), format, 2);
	
	#if TEST_DEBUG
	PrintToChatAll("[BULLDOZER] %s", buffer);
	PrintToConsole(0, "[BULLDOZER] %s", buffer);
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