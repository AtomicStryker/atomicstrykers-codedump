#pragma semicolon 1
#include <sourcemod>
#include <sdktools>

#define TEST_DEBUG 1
#define TEST_DEBUG_LOG 0


static const fatigueAddedOnQuickSwing		= 3; // how much fatigue will be added if a client if he quick swings
static const maxExistingFatigue				= 3; // how much fatigue already on a client will cause this Plugin to abort

static const Float:MELEE_DURATION			= 0.6;
// 

static bool:soundHookDelay[MAXPLAYERS+1] = false;

//static const Float:minimumsoundHookDelay = 1.0;	// how much time must pass between 2 melees so fatigue doesnt get added
//static Float:lastMeleeTime[MAXPLAYERS+1] = 0.0;

public OnPluginStart()
{
	AddNormalSoundHook(NormalSHook:HookSound_Callback);
}

public Action:HookSound_Callback(Clients[64], &NumClients, String:StrSample[PLATFORM_MAX_PATH], &Entity)
{
	//to work only on melee sounds, its 'swish' or 'weaponswing'
	if (StrContains(StrSample, "Swish", false) == -1) return Plugin_Continue;
	//so the client has the melee sound playing. OMG HES MELEEING!
	
	if (Entity > MAXPLAYERS) return Plugin_Continue; // bugfix for some people on L4D2
	
	//add in a delay so this doesnt fire every frame
	if (soundHookDelay[Entity]) return Plugin_Continue; //note 'Entity' means 'client' here
	soundHookDelay[Entity] = true;
	CreateTimer(MELEE_DURATION, ResetsoundHookDelay, Entity);
	
	DebugPrintToAll("New Melee caught by %N", Entity);
	
	new currentfatigue = L4D_GetMeleeFatigue(Entity);
	if (currentfatigue >= maxExistingFatigue)
	{
		DebugPrintToAll("Current Fatigue is %i, aborting", currentfatigue);
		return Plugin_Continue;
	}
	
	L4D_SetMeleeFatigue(Entity, currentfatigue + fatigueAddedOnQuickSwing);
	DebugPrintToAll("Set Fatigue to %i", currentfatigue + fatigueAddedOnQuickSwing);
	
	/*
	new Float:currenttime = GetEngineTime();

	DebugPrintToAll("Engine Time: %f, last Melee time: %f, delta: %f", currenttime, lastMeleeTime[Entity], currenttime - lastMeleeTime[Entity]);
	
	if ((currenttime - lastMeleeTime[Entity]) < minimumsoundHookDelay)
	{
		DebugPrintToAll("Quick Melee detected (delta < %f), adding Fatigue", minimumsoundHookDelay);
		L4D_SetMeleeFatigue(Entity, currentfatigue + fatigueAddedOnQuickSwing);
	}
	
	lastMeleeTime[Entity] = currenttime;
	*/
	return Plugin_Continue;
}

public Action:ResetsoundHookDelay(Handle:timer, any:client)
{
	soundHookDelay[client] = false;
}

stock L4D_GetMeleeFatigue(client)
{
	return GetEntProp(client, Prop_Send, "m_iShovePenalty", 4);
}
	
stock L4D_SetMeleeFatigue(client, value)
{
	SetEntProp(client, Prop_Send, "m_iShovePenalty", value);
}

stock DebugPrintToAll(const String:format[], any:...)
{
	#if TEST_DEBUG	|| TEST_DEBUG_LOG
	decl String:buffer[192];
	
	VFormat(buffer, sizeof(buffer), format, 2);
	
	#if TEST_DEBUG
	PrintToChatAll("[Melee] %s", buffer);
	PrintToConsole(0, "[Melee] %s", buffer);
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