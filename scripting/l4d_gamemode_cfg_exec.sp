#include <sourcemod>

static Handle:g_hGameMode;

public OnPluginStart()
{
	g_hGameMode = FindConVar("mp_gamemode");
	HookConVarChange(g_hGameMode, ConVarChange_GameMode);
}

public OnMapStart()
{
	ExecuteGamemodeConfig();
}

public ConVarChange_GameMode(Handle:convar, const String:oldValue[], const String:newValue[])
{
	ExecuteGamemodeConfig();
}

static ExecuteGamemodeConfig()
{
	decl String:sGameMode[16];
	GetConVarString(g_hGameMode, sGameMode, sizeof(sGameMode))
	ServerCommand("exec %s", sGameMode);
}