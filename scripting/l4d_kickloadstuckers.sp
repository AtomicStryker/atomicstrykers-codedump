#include <sourcemod>
#define PLUGIN_VERSION "1.0.5"

public Plugin:myinfo = 
{
	name = "L4D Kick Load Stuckers",
	author = "AtomicStryker",
	description = "Kicks Clients that get stuck in server connecting state",
	version = PLUGIN_VERSION,
	url = "http://forums.alliedmods.net/showthread.php?t=103203"
}

new Handle:LoadingTimer[MAXPLAYERS+1] = INVALID_HANDLE; // one Handle for each client
new Handle:CvarDuration = INVALID_HANDLE;

public OnPluginStart()
{
	RegAdminCmd("sm_kickloading", KickLoaders, ADMFLAG_KICK, "Kicks everyone Connected but not ingame");
	CreateConVar("l4d_kickloadstuckers_version", PLUGIN_VERSION, " Version of L4D Kick Load Stuckers on this server ", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	CvarDuration = CreateConVar("l4d_kickloadstuckers_duration", "60", " How long before a connected but not ingame player is kicked. (default 60) ", FCVAR_PLUGIN|FCVAR_NOTIFY);
}

public OnMapEnd()
{
	KillAllTimers();
}

public OnPluginEnd()
{
	KillAllTimers();
}

public Action:KickLoaders(clients, args)
{
	for (new i = 1; i <= MaxClients; i++)
	{
		if (!IsClientConnected(i)) continue;
		if (!IsClientInGame(i))
		{
			decl String:name[256];
			GetClientName(i, name, sizeof(name));
			PrintToChatAll("%s was admin kicked for being stuck in connecting state", name);
			
			//BanClient(i, 0, BANFLAG_AUTO, "Slowass Loading", "Slowass Loader");
			KickClient(i, "You were stuck Connecting for too long");
		}
	}
	return Plugin_Handled;
}

public OnClientConnected(client)
{
	LoadingTimer[client] = CreateTimer(GetConVarFloat(CvarDuration), CheckClientIngame, client, TIMER_FLAG_NO_MAPCHANGE); //on successfull connect the Timer is set in motion
}

public OnClientDisconnect(client)
{
	if ( !AreHumansConnected() ) return;
	if (LoadingTimer[client] != INVALID_HANDLE) 
	{
		KillTimer(LoadingTimer[client]);
		LoadingTimer[client] = INVALID_HANDLE;
	}
}

public Action:CheckClientIngame(Handle:timer, any:client)
{
	if (!IsClientConnected(client)) return; //onclientdisconnect should handle this, but you never know
	
	if (!IsClientInGame(client))
	{
		decl String:name[256];
		GetClientName(client, name, sizeof(name));
		PrintToChatAll("%s was kicked for being stuck in connecting state for %i seconds", name, RoundToNearest(GetConVarFloat(CvarDuration)));
		
		KickClient(client, "You were stuck Connecting for too long");
			
		//player log file code. name and steamid only
		decl String:file[PLATFORM_MAX_PATH], String:steamid[100];
		
		BuildPath(Path_SM, file, sizeof(file), "logs/stuckplayerlog.log");
		GetClientAuthString(client, steamid, sizeof(steamid));
		
		LogToFileEx(file, "%s - %s", steamid, name); // this logs their steamids and names. to be banned.
	}
	LoadingTimer[client] = INVALID_HANDLE
}

KillAllTimers()
{
	for (new i = 1; i <= MaxClients; i++)
	{
		if (LoadingTimer[i] != INVALID_HANDLE) 
		{
			KillTimer(LoadingTimer[i]);
			LoadingTimer[i] = INVALID_HANDLE;
		}
	}
}

stock bool:AreHumansConnected()
{
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientConnected(i))
			if (!IsFakeClient(i)) return true;
	}
	return false;
}