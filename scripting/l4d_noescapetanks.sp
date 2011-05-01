#pragma semicolon 1
#include <sourcemod>
#include <sdktools>

static bool:isVehicleReady = false;

public OnPluginStart()
{
	HookEvent("round_start", Event_RoundStart);
	HookEvent("tank_spawn", Event_TankSpawn);
	HookEvent("finale_vehicle_start", Event_RescueVehicle);
}

public Action:Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	isVehicleReady = false;
}

public Action:Event_RescueVehicle(Handle:event, const String:name[], bool:dontBroadcast)
{
	isVehicleReady = true;
}

public Action:Event_TankSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!isVehicleReady) continue;
	
	new tank = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (tank && IsClientInGame(tank))
	{
		ForcePlayerSuicide(tank);
	}
}