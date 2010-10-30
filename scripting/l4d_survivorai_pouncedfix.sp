#include <sourcemod>
#include <sdktools>

#define PLUGIN_VERSION "1.0.2"
#define PLUGIN_NAME "L4D Survivor AI Pounced Fix"


public Plugin:myinfo = {
	name = PLUGIN_NAME,
	author = " AtomicStryker ",
	description = " Fixes Survivor Bots neglecting Pounced Teammates ",
	version = PLUGIN_VERSION,
	url = ""
};

new IsShredding[MAXPLAYERS+1];

public OnPluginStart()
{
	HookEvent("lunge_pounce", Event_Pounced);
	HookEvent("pounce_stopped", Event_PounceStopped);
	HookEvent("player_hurt", Event_PlayerHurtPre, EventHookMode_Pre);
	
	CreateConVar("l4d_survivoraipouncedfix_version", PLUGIN_VERSION, " Version of L4D Survivor AI Pounced Fix on this server ", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_NOTIFY|FCVAR_DONTRECORD);
}


public Event_Pounced (Handle:event, const String:name[], bool:dontBroadcast)
{
	new attacker = GetClientOfUserId(GetEventInt(event, "userid"));
	new victim = GetClientOfUserId(GetEventInt(event, "victim"));

	if (victim == 0 || attacker == 0) return;
	IsShredding[attacker] = 1;
}


public Event_PounceStopped (Handle:event, const String:name[], bool:dontBroadcast)
{
	new attacker = GetClientOfUserId(GetEventInt(event, "userid"));
	new victim = GetClientOfUserId(GetEventInt(event, "victim"));

	if (victim == 0 || attacker == 0) return;
	IsShredding[attacker]=0;
}

public Action:Event_PlayerHurtPre (Handle:event, const String:name[], bool:dontBroadcast)
{
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	new victim = GetClientOfUserId(GetEventInt(event, "userid"));

	if (victim == 0 || attacker == 0) return Plugin_Continue;
	if (GetClientTeam(attacker) == 2) return Plugin_Continue;

	decl String:st_wpn[16];
	GetEventString(event,"weapon",st_wpn,16);

	if (StrEqual(st_wpn,"hunter_claw") && IsShredding[attacker]==1)
	{
		decl Float:position[3];
		GetClientAbsOrigin(attacker, position);

		CallBots(position);
		return Plugin_Continue;
	}
	return Plugin_Continue;
}

public Action:CallBots(Float:position[3])
{
	for (new target = 1; target <= MaxClients; target++)
	{
		if (IsClientInGame(target))
		{
			if (GetClientHealth(target) > 0 && GetClientTeam(target) == 2 && IsFakeClient(target)) // make sure target is a live Survivor Bot
			{

				decl Float:targetPos[3];
				GetClientAbsOrigin(target, targetPos);
				new Float:distance = GetVectorDistance(targetPos, position); // check Survivor Bot Distance from Pouncing Hunter
					
				if (distance < 50)
				{
					decl Float:EyePos[3], Float:AimOnHunter[3], Float:AimAngles[3];
					GetClientEyePosition(target, EyePos);
					MakeVectorFromPoints(EyePos, position, AimOnHunter);
					GetVectorAngles(AimOnHunter, AimAngles);
					TeleportEntity(target, NULL_VECTOR, AimAngles, NULL_VECTOR); // make the Survivor Bot aim on the Victim
					
					ClientCommand(target, "+attack2"); // Melee!!!
				}
				
				else if (distance < 500)
				{
					decl Float:EyePos[3], Float:AimOnHunter[3], Float:AimAngles[3];
					GetClientEyePosition(target, EyePos);
					MakeVectorFromPoints(EyePos, position, AimOnHunter);
					GetVectorAngles(AimOnHunter, AimAngles);
					TeleportEntity(target, NULL_VECTOR, AimAngles, NULL_VECTOR); // make the Survivor Bot aim on the Victim
					
					ClientCommand(target, "+attack"); // Let the gun do the talking
				}
			}
		}
	}
	return Plugin_Continue;
}