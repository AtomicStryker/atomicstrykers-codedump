#pragma semicolon 1
#include <sourcemod>
#include <sdktools>

#define PLUGIN_VERSION "1.0.7"

#define DEBUG 0

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

	HookEvent("charger_charge_start", Event_Charge);
	HookEvent("charger_charge_end", Event_ChargeEnd);
	HookEvent("charger_killed", Event_ChargeEnd);
	HookEvent("charger_impact", Event_Impact);
	
	HookEvent("round_end", Event_ChargeEnd);
}

new Handle:ReinCapTimerArray[MAXPLAYERS+1] = INVALID_HANDLE;
new Handle:ChargerTimer = INVALID_HANDLE;
new IncappedHealth[MAXPLAYERS+1];

public Action:Event_Charge(Handle:event, String:event_name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));	
	
	if (ChargerTimer != INVALID_HANDLE)
	{
		CloseHandle(ChargerTimer);
		ChargerTimer = INVALID_HANDLE;
	}
	
	ChargerTimer = CreateTimer(0.4, CheckForIncapped, client, TIMER_REPEAT);
	TriggerTimer(ChargerTimer, true);
	
	#if DEBUG
	PrintToChatAll("Charge caught, starting ChargerTimer");
	#endif
}

public Action:Event_ChargeEnd(Handle:event, String:event_name[], bool:dontBroadcast)
{
	if (ChargerTimer != INVALID_HANDLE)
	{
		CloseHandle(ChargerTimer);
		ChargerTimer = INVALID_HANDLE;
	}
	
	#if DEBUG
	PrintToChatAll("Charge(r) end caught, killing ChargerTimer");
	#endif
	
	CreateTimer(1.0, WipeHealthArray);
}

public OnMapEnd()
{
	if (ChargerTimer != INVALID_HANDLE)
	{
		CloseHandle(ChargerTimer);
		ChargerTimer = INVALID_HANDLE;
	}
}

public Action:Event_Impact(Handle:event, String:event_name[], bool:dontBroadcast)
{
	new target = GetClientOfUserId(GetEventInt(event, "victim"));	
	if (ReinCapTimerArray[target] != INVALID_HANDLE)
	{
		KillTimer(ReinCapTimerArray[target]);
		ReinCapTimerArray[target] = INVALID_HANDLE;
		ReinCapTimerArray[target] = CreateTimer(2.0, Reincap, target);
		
		#if DEBUG
		PrintToChatAll("Charger hit a temporary unincapped, extended timer");
		#endif
	}
}

public Action:CheckForIncapped(Handle:timer, any:client)
{
	decl Float:targetpos[3], Float:chargerpos[3];
	
	for (new target = 1; target <= MaxClients; target++)
	{
		if (target == client) continue;
		if (!IsClientInGame(target)) continue;
		if (GetClientTeam(target) != 2) continue;
		if (!IsPlayerIncapped(target)) continue;
		if (GetEntProp(target, Prop_Send, "m_isHangingFromLedge") || GetEntProp(target, Prop_Send, "m_isFallingFromLedge")) continue;
		
		GetClientAbsOrigin(target, targetpos);
		GetClientAbsOrigin(client, chargerpos);
		
		if (GetVectorDistance(targetpos, chargerpos) < 150)
		{
			#if DEBUG
			PrintToChatAll("Incapped %N found on way, un-incapping", target);
			#endif
			
			if (IncappedHealth[target] == -1)
				IncappedHealth[target] = GetClientHealth(target);
			SetPlayerIncapState(target, false);
			ReinCapTimerArray[target] = CreateTimer(1.0, Reincap, target);
		}
	}
}

public Action:Reincap(Handle:timer, any:client)
{
	SetPlayerIncapState(client, true);
	
	CreateTimer(0.3, SetHealthDelayed, client);
	
	#if DEBUG
	PrintToChatAll("Re-Incapped %N", client);
	#endif
	
	ReinCapTimerArray[client] = INVALID_HANDLE;
}

public Action:SetHealthDelayed(Handle:timer, any:client)
{
	if (IncappedHealth[client] > 2 && IsPlayerIncapped(client))
		SetEntityHealth(client, IncappedHealth[client]);
}

SetPlayerIncapState(client, bool:incap)
{
	if (incap) SetEntProp(client, Prop_Send, "m_isIncapacitated", 1);
	else SetEntProp(client, Prop_Send, "m_isIncapacitated", 0);
}

bool:IsPlayerIncapped(client)
{
	if (GetEntProp(client, Prop_Send, "m_isIncapacitated", 1)) return true;
	else return false;
}

public Action:WipeHealthArray(Handle:timer, any:client)
{
	for (new i = 1; i <= MaxClients; i++)
	{
		IncappedHealth[i] = -1;
	}
}