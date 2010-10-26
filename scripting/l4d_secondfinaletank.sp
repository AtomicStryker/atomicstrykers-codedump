#include <sourcemod>
#define DEBUG 0

#define PLUGIN_VERSION "1.0.8"
#define PLUGIN_NAME "L4D Second Finale Tank"


new bool:IsFinale = false;
new bool:SecondTankUnderway = false;
new Handle:HealthDecrease = INVALID_HANDLE;
new Handle:SpawnTimer = INVALID_HANDLE;
new Handle:CooldownTimer = INVALID_HANDLE;
new Handle:hMaxZombies = INVALID_HANDLE;
new DefaultMaxZombies;

public Plugin:myinfo = {
	name = PLUGIN_NAME,
	author = " AtomicStryker ",
	description = " Spawns 2 weaker Tanks instead of 1 during Finale waves ",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/showthread.php?t=98721"
};

public OnPluginStart()
{
	HookEvent("tank_spawn", ATankSpawns, EventHookMode_PostNoCopy);
	HookEvent("finale_start", FinaleBegins, EventHookMode_PostNoCopy);
	HookEvent("round_end", FinaleEnds);
	HookEvent("round_start", FinaleEnds);
	HookEvent("map_transition", FinaleEnds);
	HookEvent("mission_lost", FinaleEnds);
	HookEvent("finale_win", FinaleEnds);
	HookEvent("player_death", Event_PlayerDeath, EventHookMode_Pre);
	
	HealthDecrease = CreateConVar("l4d_secondfinaletank_hpsetting","0.60"," How much Health each of the two Tanks have compared to a standard one. '1.0' would be full health ", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_NOTIFY, true, 0.01, true, 1.00);
	CreateConVar("l4d_secondfinaletank_version", PLUGIN_VERSION, " Version of L4D Double Tank on this server ", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	
	AutoExecConfig(true, "l4d_secondfinaletank");
	
	hMaxZombies = FindConVar("z_max_player_zombies")
	DefaultMaxZombies = GetConVarInt(hMaxZombies);
}

public OnMapStart()
{
	ResetStuff()
}

public OnMapEnd()
{
	ResetStuff()
}

public Action:ATankSpawns(Handle:event, const String:name[], bool:dontBroadcast)
{
	#if DEBUG
	if(!IsFinale) PrintToChatAll("[Doubletank Plugin] Its not a Finale yet");
	#endif

	if(!IsFinale) return Plugin_Continue;
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	// This reduces the Tanks Health. Two Tanks with full power are ownage
	new TankHealth = RoundFloat((GetEntProp(client,Prop_Send,"m_iHealth")*(GetConVarFloat(HealthDecrease))));
	if(TankHealth>65535) TankHealth=65535;
	SetEntProp(client,Prop_Send,"m_iHealth",TankHealth);
	SetEntProp(client,Prop_Send,"m_iMaxHealth",TankHealth);
	
	if (SecondTankUnderway) return Plugin_Continue;
	SecondTankUnderway = true;
	
	new Float:TankDelay = GetConVarFloat(FindConVar("director_tank_lottery_selection_time")) + 2.0;  
	// this to avoid 'disappearing' tanks. After Lottery strange things happen
	
	SpawnTimer = CreateTimer(TankDelay, SpawnSecondTank, client);
	
	// this to avoid other dual tank related oddities. We silently raise max Infected count before spawning a second tank	
	SetConVarInt(hMaxZombies, DefaultMaxZombies+2);
	
	CooldownTimer = CreateTimer(60.0, CanSpawnAgain, client, TIMER_FLAG_NO_MAPCHANGE);
	
	#if DEBUG
	PrintToChatAll("[Doubletank Plugin] Spawning Second Tank with Delay %f!", TankDelay);
	#endif	
	
	return Plugin_Continue;
}

public Action:SpawnSecondTank(Handle:timer, any:client)
{
	if (client == 0 || !IsClientConnected(client)) // If this was the Bot Tank Client which has left the game already, or else false
	{
		#if DEBUG
		PrintToChatAll("[Doubletank Plugin] Event Client was found invalid, finding a new one!");
		#endif
		
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientConnected(i) && IsClientInGame(i))
			{
				client = i
				break;
			}
		}
	}
	PrintToChatAll("\x04[Doubletank Plugin] \x01Spawning Dual Tanks with %i percent Health each!", RoundFloat(100*GetConVarFloat(HealthDecrease)));

	new flags = GetCommandFlags("z_spawn");
	SetCommandFlags("z_spawn", flags & ~FCVAR_CHEAT);
	FakeClientCommand(client, "z_spawn tank auto")
	SetCommandFlags("z_spawn", flags);
	
	CreateTimer(3.0, CheckSpawn, 0);
	
	if (timer != INVALID_HANDLE)
	{
		KillTimer(timer);
		timer = INVALID_HANDLE;
	}
	return Plugin_Continue;
}

public Action:CheckSpawn(Handle:timer) // A Backup function should a spawned tank go amiss somehow.
{
	if (CountTanks() < 2)
	{
		SecondTankUnderway = false;
		CreateTimer(0.5, SpawnSecondTank, 0);
	}
}

public Action:FinaleBegins(Handle:event, const String:name[], bool:dontBroadcast)
{
	IsFinale = true;
	DefaultMaxZombies = GetConVarInt(hMaxZombies);
	PrintToChatAll("\x04[Doubletank Plugin] \x01Finale begins!");
	return Plugin_Continue;
}

public Action:FinaleEnds(Handle:event, const String:name[], bool:dontBroadcast)
{
	ResetStuff()
	
	#if DEBUG
	PrintToChatAll("\x04[Doubletank Plugin] \x01Finale has ended!");
	#endif

	return Plugin_Continue;
}

public Action:Event_PlayerDeath (Handle:event, const String:name[], bool:dontBroadcast)
{
	if(!IsFinale) return Plugin_Continue;
	new client = GetClientOfUserId(GetEventInt(event,"userid"));
	if (client == 0) return Plugin_Continue;
	
	decl String:stringclass[32];
	GetClientModel(client, stringclass, 32);
	
	if (StrContains(stringclass, "hulk", false) != -1)
	{
		CreateTimer(3.0, PrintLivingTanks, client);
	}
	return Plugin_Continue;
}

public Action:PrintLivingTanks(Handle:timer, Handle:client)
{
	new Tanks = CountTanks();
	
	PrintToChatAll("\x03[Double Tank] Tanks left alive: %i", Tanks);
	
	if (Tanks<=0)
	{
		SetConVarInt(hMaxZombies, DefaultMaxZombies);
	}
}

public CountTanks()
{
	new TanksCount = 0;	
	decl String:stringclass[32];
	for (new i=1 ; i<=MaxClients ; i++)
	{
		if (IsClientInGame(i) == true && IsPlayerAlive(i) == true && GetClientTeam(i) == 3)
		{
			GetClientModel(i, stringclass, 32);
			if (StrContains(stringclass, "hulk", false) != -1) TanksCount++;
		}
	}
	return TanksCount;
}

public Action:CanSpawnAgain(Handle:timer, any:client)
{
	SecondTankUnderway = false;
	return Plugin_Continue;
}

public Action:ResetStuff()
{
	if 	(IsFinale)
	{
		#if DEBUG
		PrintToChatAll("\x04[Doubletank Plugin] \x01Resetting Plugin!");
		#endif
	
		SetConVarInt(hMaxZombies, DefaultMaxZombies);
		
		if (CooldownTimer != INVALID_HANDLE)
		{
			KillTimer(CooldownTimer);
			CooldownTimer = INVALID_HANDLE;
		}
		if (SpawnTimer != INVALID_HANDLE)
		{
			KillTimer(SpawnTimer);
			SpawnTimer = INVALID_HANDLE;
		}
		IsFinale = false;
		SecondTankUnderway = false;
	}
}