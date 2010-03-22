#define PLUGIN_VERSION    "1.0.0"
#define PLUGIN_NAME       "L4D2 Testing"

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define TEST_DEBUG 0
#define TEST_DEBUG_LOG 0



public OnPluginStart()
{
	RegAdminCmd("sm_takeover", Cmd1, ADMFLAG_CHEATS, "Take Over Zombie Bot <player>");
	
	RegAdminCmd("sm_botify", Cmd2, ADMFLAG_CHEATS, "ReplaceWithBot <player> <bool>");
	
	RegAdminCmd("sm_cull", Cmd3, ADMFLAG_CHEATS, "CullZombie <player>");
	
	RegAdminCmd("sm_replacetank", Cmd4, ADMFLAG_CHEATS, "ReplaceTank <player> <player>");
}

public Action:Cmd1(client, args)
{
	if (!client || !args) return Plugin_Handled;
	
	if (args < 2)
	{
		ReplyToCommand(client, "Usage: sm_takeover <player> <bot>");
		return Plugin_Handled;
	}
	
	decl String:arg[256];
	GetCmdArg(1, arg, sizeof(arg));
	new target1 = FindTarget(client, arg, false, false);
	
	if (target1 < 1)
	{
		ReplyToCommand(client, "Invalid target 1 specified");
		return Plugin_Handled;
	}
	
	GetCmdArg(2, arg, sizeof(arg));
	new target2 = FindTarget(client, arg, false, false);
	
	if (target2 < 1)
	{
		ReplyToCommand(client, "Invalid target 2 specified");
		return Plugin_Handled;
	}
	
	L4D2_TakeOverZombieBot(target1, target2);
	return Plugin_Handled;
}

public Action:Cmd2(client, args)
{
	if (!client || !args) return Plugin_Handled;
	
	if (args < 2)
	{
		ReplyToCommand(client, "Usage: sm_botify <player> <bool>");
		return Plugin_Handled;
	}
	
	decl String:arg[256];
	GetCmdArg(1, arg, sizeof(arg));
	new target = FindTarget(client, arg, false, false);
	
	if (target < 1)
	{
		ReplyToCommand(client, "Invalid target specified");
		return Plugin_Handled;
	}
	
	GetCmdArg(2, arg, sizeof(arg));
	new boolean = StringToInt(arg);
	
	L4D2_ReplaceWithBot(target, boolean);
	return Plugin_Handled;
}

public Action:Cmd3(client, args)
{
	if (!client || !args) return Plugin_Handled;
	
	if (args < 1)
	{
		ReplyToCommand(client, "Usage: sm_cull <player>");
		return Plugin_Handled;
	}
	
	decl String:arg[256];
	GetCmdArg(1, arg, sizeof(arg));
	new target = FindTarget(client, arg, false, false);
	
	if (target < 1)
	{
		ReplyToCommand(client, "Invalid target specified");
		return Plugin_Handled;
	}
	
	L4D2_CullZombie(target);
	return Plugin_Handled;
}

public Action:Cmd4(client, args)
{
	if (!client || !args) return Plugin_Handled;
	
	if (args < 2)
	{
		ReplyToCommand(client, "Usage: sm_replacetank <player> <player>");
		return Plugin_Handled;
	}
	
	decl String:arg[256];
	GetCmdArg(1, arg, sizeof(arg));
	new target1 = FindTarget(client, arg, false, false);
	
	if (target1 < 1)
	{
		ReplyToCommand(client, "Invalid target 1 specified");
		return Plugin_Handled;
	}
	
	GetCmdArg(2, arg, sizeof(arg));
	new target2 = FindTarget(client, arg, false, false);
	
	if (target2 < 1)
	{
		ReplyToCommand(client, "Invalid target 2 specified");
		return Plugin_Handled;
	}
	
	L4D2_ReplaceTank(target1, target2);
	return Plugin_Handled;
}

// CTerrorPlayer::TakeOverZombieBot(CTerrorPlayer*)
// Client takes control of an Infected Bot - Tank included. Causes odd shit to happen if client current SI class doesnt match the taken over one, exception tank
L4D2_TakeOverZombieBot(client, target)
{
	DebugPrintToAll("TakeOverZombieBot being called, client %N target %N", client, target);

	new Handle:MySDKCall = INVALID_HANDLE;
	new Handle:ConfigFile = LoadGameConfigFile("l4d2addresses");
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(ConfigFile, SDKConf_Signature, "TakeOverZombieBot");
	PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
	MySDKCall = EndPrepSDKCall();
	CloseHandle(ConfigFile);
	
	if (MySDKCall == INVALID_HANDLE)
	{
		LogError("Cant initialize TakeOverZombieBot SDKCall");
		return;
	}
	
	SDKCall(MySDKCall, client, target);
}

// CTerrorPlayer::ReplaceWithBot(bool)
// causes a perfect 'clone' of you as bot to appear in your place. you do not(!) disappear or die by this function alone
// boolean has no obvious effect
// intended for use directly before CullZombie or ReplaceTank
L4D2_ReplaceWithBot(client, boolean)
{
	DebugPrintToAll("ReplaceWithBot being called, client %N boolean %b", client, boolean);

	new Handle:MySDKCall = INVALID_HANDLE;
	new Handle:ConfigFile = LoadGameConfigFile("l4d2addresses");
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(ConfigFile, SDKConf_Signature, "ReplaceWithBot");
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
	MySDKCall = EndPrepSDKCall();
	CloseHandle(ConfigFile);
	
	if (MySDKCall == INVALID_HANDLE)
	{
		LogError("Cant initialize ReplaceWithBot SDKCall");
		return;
	}
	
	SDKCall(MySDKCall, client, boolean);
}

// CTerrorPlayer::CullZombie(void)
// causes instant respawn as spawnready ghost, new class - but only when you were alive in the first place (ghost included)
L4D2_CullZombie(target)
{
	DebugPrintToAll("CullZombie being called, target %N", target);

	new Handle:MySDKCall = INVALID_HANDLE;
	new Handle:ConfigFile = LoadGameConfigFile("l4d2addresses");
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(ConfigFile, SDKConf_Signature, "CullZombie");
	MySDKCall = EndPrepSDKCall();
	CloseHandle(ConfigFile);
	
	if (MySDKCall == INVALID_HANDLE)
	{
		LogError("Cant initialize CullZombie SDKCall");
		return;
	}
	
	SDKCall(MySDKCall, target);
}


// ZombieManager::ReplaceTank(CTerrorPlayer *, CTerrorPlayer *)
// causes Tank control to instantly shift from target 1 to target 2. Frustration is reset, target 1 may become tank again if target 2 gets frustrated.
// if target 2 was alive and spawned at calling this, it disappears.
// do not use with bots. Use L4D2_TakeOverZombieBot instead.
L4D2_ReplaceTank(client, target)
{
	DebugPrintToAll("ReplaceTank being called, client %N target %N", client, target);

	new Handle:ConfigFile = LoadGameConfigFile("l4d2addresses");
	new Address:g_pZombieManager = GameConfGetAddress(ConfigFile, "CZombieManager");
	if(g_pZombieManager == Address_Null)
	{
		LogError("Could not load the ZombieManager pointer");
		DebugPrintToAll("Could not load the ZombieManager pointer");
		return;
	}
	
	DebugPrintToAll("ZombieManager pointer: 0x%x", g_pZombieManager);
	
	new Handle:MySDKCall = INVALID_HANDLE;
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(ConfigFile, SDKConf_Signature, "ReplaceTank");
	PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
	MySDKCall = EndPrepSDKCall();
	CloseHandle(ConfigFile);
	
	if (MySDKCall == INVALID_HANDLE)
	{
		LogError("Cant initialize ReplaceTank SDKCall");
		DebugPrintToAll("Cant initialize ReplaceTank SDKCall");
		return;
	}
	
	SDKCall(MySDKCall, g_pZombieManager, client, target);
}

stock DebugPrintToAll(const String:format[], any:...)
{
	#if TEST_DEBUG	|| TEST_DEBUG_LOG
	decl String:buffer[192];
	
	VFormat(buffer, sizeof(buffer), format, 2);
	
	#if TEST_DEBUG
	PrintToChatAll("[TEST] %s", buffer);
	PrintToConsole(0, "[TEST] %s", buffer);
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

//entity abs origin code from here
//http://forums.alliedmods.net/showpost.php?s=e5dce96f11b8e938274902a8ad8e75e9&p=885168&postcount=3
stock GetEntityAbsOrigin(entity,Float:origin[3])
{
	if (entity > 0 && IsValidEntity(entity))
	{
		decl Float:mins[3], Float:maxs[3];
		GetEntPropVector(entity,Prop_Send,"m_vecOrigin",origin);
		GetEntPropVector(entity,Prop_Send,"m_vecMins",mins);
		GetEntPropVector(entity,Prop_Send,"m_vecMaxs",maxs);
		
		origin[0] += (mins[0] + maxs[0]) * 0.5;
		origin[1] += (mins[1] + maxs[1]) * 0.5;
		origin[2] += (mins[2] + maxs[2]) * 0.5;
	}
}

stock CheatCommand(client = 0, String:command[], String:arguments[]="")
{
	if (!client || !IsClientInGame(client))
	{
		for (new target = 1; target <= MaxClients; target++)
		{
			if (IsClientInGame(target))
			{
				client = target;
				break;
			}
		}
		
		if (!IsClientInGame(client)) return;
	}
	
	new userflags = GetUserFlagBits(client);
	SetUserFlagBits(client, ADMFLAG_ROOT);
	new flags = GetCommandFlags(command);
	SetCommandFlags(command, flags & ~FCVAR_CHEAT);
	FakeClientCommand(client, "%s %s", command, arguments);
	SetCommandFlags(command, flags);
	SetUserFlagBits(client, userflags);
}