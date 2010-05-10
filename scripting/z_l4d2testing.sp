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
	
	RegAdminCmd("sm_spawnas", Cmd5, ADMFLAG_CHEATS, "sm_spawnas <player> <infectedclass>");
	
	RegAdminCmd("sm_vocalize", Cmd6, ADMFLAG_CHEATS, "sm_vocalize <command>");
	
	RegAdminCmd("sm_getvscomp", Cmd7, ADMFLAG_CHEATS, "sm_getvscomp <charint> <int>");
	
	RegAdminCmd("sm_readscores", Cmd8, ADMFLAG_CHEATS, " sm_readscores ");
	
	RegAdminCmd("sm_setscore", Cmd9, ADMFLAG_CHEATS, " sm_setscore <score table id> <score> ");
	
	RegConsoleCmd("sm_soundtest", Cmd10, "");
}

public Action:Cmd10(client, args)
{
	if (!client) return Plugin_Handled;

	CheatClientCommand(client, "stopsound", "music/flu/concert/midnightride.wav");
	PrintToChat(client, "midnightride.wav Sound stopped");

	return Plugin_Handled;
}

public Action:Cmd8(client, args)
{
	new managerent = FindEntityByClassname(-1, "terror_player_manager");
	
	if (!IsValidEdict(managerent))
	{
		ReplyToCommand(client, "Could not find terror_player_manager entity");
		return Plugin_Handled;
	}
	
	new scoreoffset = FindSendPropInfo("CTerrorPlayerResource", "m_iScore");
	
	for (new i = 0; i <= 32; i++)
	{
		PrintToConsole(client, "m_iScore offset %i, id %i: %i", i*4, i, GetEntData(managerent, scoreoffset+(i*4), 2));
	}
	return Plugin_Handled;
}

public Action:Cmd9(client, args)
{
	if (!client) return Plugin_Handled;
	
	if (args < 2)
	{
		ReplyToCommand(client, "Usage: sm_setscore <score table id> <score>");
		return Plugin_Handled;
	}
	
	new managerent = FindEntityByClassname(-1, "terror_player_manager");
	
	if (!IsValidEdict(managerent))
	{
		ReplyToCommand(client, "Could not find terror_player_manager entity");
		return Plugin_Handled;
	}
	
	new scoreoffset = FindSendPropInfo("CTerrorPlayerResource", "m_iScore");
	
	decl String:arg[64];
	GetCmdArg(1, arg, sizeof(arg));
	
	new idoffset = StringToInt(arg);
	
	if (!idoffset || idoffset > 32)
	{
		ReplyToCommand(client, "Valid ID range is 1 to 32");
		return Plugin_Handled;
	}

	GetCmdArg(2, arg, sizeof(arg));
	
	SetEntData(managerent, scoreoffset+(idoffset*4), StringToInt(arg), 2, true);
	
	PrintToChat(client, "Set Score OffsetID %i, ID %i score to %i", idoffset*4, idoffset, StringToInt(arg));
	// has no effect. need extension ... sigh
	
	return Plugin_Handled;
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

public Action:Cmd5(client, args)
{
	if (!client || !args) return Plugin_Handled;
	
	if (args < 2)
	{
		ReplyToCommand(client, "Usage: sm_spawnas <player> <infectedclass>");
		return Plugin_Handled;
	}
	
	decl String:arg[256];
	new bool:targetall;
	GetCmdArg(1, arg, sizeof(arg));
	new target = FindTarget(client, arg, false, false);
	
	if (target < 1)
	{
		if (StrContains(arg, "inf", false) == -1)
		{
			ReplyToCommand(client, "Invalid target specified");
			return Plugin_Handled;
		}
		else
		{
			targetall = true;
		}
	}
	
	/*
	#define ZOMBIECLASS_SMOKER	1
	#define ZOMBIECLASS_BOOMER	2
	#define ZOMBIECLASS_HUNTER	3
	#define ZOMBIECLASS_SPITTER	4
	#define ZOMBIECLASS_JOCKEY	5
	#define ZOMBIECLASS_CHARGER	6
	#define ZOMBIECLASS_TANK	8
	*/
	GetCmdArg(2, arg, sizeof(arg));
	decl class;
	if (StrContains(arg, "smo", false) != -1) class = 1;
	else if (StrContains(arg, "b", false) != -1) class = 2;
	else if (StrContains(arg, "h", false) != -1) class = 3;
	else if (StrContains(arg, "sp", false) != -1) class = 4;
	else if (StrContains(arg, "j", false) != -1) class = 5;
	else if (StrContains(arg, "c", false) != -1) class = 6;
	else if (StrContains(arg, "ta", false) != -1) class = 8;
	else
	{
		ReplyToCommand(client, "Invalid class specified");
		return Plugin_Handled;
	}
	
	if (!targetall)
	{
		L4D2_RespawnAsClassGhost(client, class)
	}
	else
	{
		for (new i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i) || GetClientTeam(i) != 3 || IsFakeClient(i)) continue;
			L4D2_RespawnAsClassGhost(i, class)
		}
	}
	return Plugin_Handled;
}

public Action:Cmd6(client, args)
{
	if (!client || !args) return Plugin_Handled;
	
	if (args < 3)
	{
		ReplyToCommand(client, "Usage: sm_vocalize <command> <float> <float>");
		return Plugin_Handled;
	}
	
	decl String:arg[256], String:floatstring[24];
	GetCmdArg(1, arg, sizeof(arg));
	
	GetCmdArg(2, floatstring, sizeof(floatstring));
	new Float:floatA = StringToFloat(floatstring);

	GetCmdArg(3, floatstring, sizeof(floatstring));
	new Float:floatB = StringToFloat(floatstring);
	
	L4D2_Vocalize(client, arg, floatA, floatB);
	
	return Plugin_Continue;
}

public Action:Cmd7(client, args)
{
	if (!client || !args) return Plugin_Handled;
	
	if (args < 2)
	{
		ReplyToCommand(client, "Usage: sm_getvscomp <charint> <int>");
		return Plugin_Handled;
	}
	
	decl String:arg[256];
	GetCmdArg(1, arg, sizeof(arg));
	new A = StringToInt(arg);
	
	GetCmdArg(2, arg, sizeof(arg));
	new B = StringToInt(arg);
	
	ReplyToCommand(client, "GetVSCompletionPerChar Output: %i", L4D2_GetVSCompletionPerChar(A, B));
	
	return Plugin_Continue;
}


// CTerrorPlayer::Vocalize(char const *, float, float)
L4D2_Vocalize(client, const String:Vocalize[], Float:floatA, Float:floatB)
{
	DebugPrintToAll("Vocalize being called, client %N command %s floatA %f floatB %f", client, Vocalize, floatA, floatB);

	new Handle:MySDKCall = INVALID_HANDLE;
	new Handle:ConfigFile = LoadGameConfigFile("l4d2addresses");
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(ConfigFile, SDKConf_Signature, "Vocalize");
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
	MySDKCall = EndPrepSDKCall();
	CloseHandle(ConfigFile);
	
	if (MySDKCall == INVALID_HANDLE)
	{
		LogError("Cant initialize Vocalize SDKCall");
		return;
	}
	
	SDKCall(MySDKCall, client, Vocalize, floatA, floatB);
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

// CTerrorGameRules::GetVersusCompletionPerCharacter(SurvivorCharacterType, int)const
L4D2_GetVSCompletionPerChar(SurvivorCharacterType, int)
{
	DebugPrintToAll("GetVersusCompletionPerCharacter being called, SurvivorCharacterType %i int %i", SurvivorCharacterType, int);

	new Handle:MySDKCall = INVALID_HANDLE;
	new Handle:ConfigFile = LoadGameConfigFile("l4d2addresses");
	StartPrepSDKCall(SDKCall_GameRules);
	PrepSDKCall_SetFromConf(ConfigFile, SDKConf_Signature, "GetVersusCompletionPerCharacter");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	MySDKCall = EndPrepSDKCall();
	CloseHandle(ConfigFile);
	
	if (MySDKCall == INVALID_HANDLE)
	{
		LogError("Cant initialize GetVersusCompletionPerCharacter SDKCall");
		return -1;
	}
	
	return SDKCall(MySDKCall, SurvivorCharacterType, int);
}

L4D2_RespawnAsClassGhost(client, class)
{
	DebugPrintToAll("RespawnAsClassGhost being called, client %N targetclass %d", client, class);

	new Handle:ConfigFile = LoadGameConfigFile("l4d2addresses");
	
	new Handle:SDK_BecomeGhost = INVALID_HANDLE;
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(ConfigFile, SDKConf_Signature, "BecomeGhost");
	PrepSDKCall_AddParameter(SDKType_PlainOldData , SDKPass_Plain);
	SDK_BecomeGhost = EndPrepSDKCall();
	if (SDK_BecomeGhost == INVALID_HANDLE)
	{
		LogError("BecomeGhost Signature missing or broken");
		return;
	}
	
	new Handle:SDK_State_Transition = INVALID_HANDLE;
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(ConfigFile, SDKConf_Signature, "State_Transition");
	PrepSDKCall_AddParameter(SDKType_PlainOldData , SDKPass_Plain);
	SDK_State_Transition = EndPrepSDKCall();
	if (SDK_State_Transition == INVALID_HANDLE)
	{
		LogError("State_Transition Signature missing or broken");
		return;
	}
	
	SDKCall(SDK_State_Transition, client, 8);
	SDKCall(SDK_BecomeGhost, client, 1);
	SDKCall(SDK_State_Transition, client, 6);
	SDKCall(SDK_BecomeGhost, client, 1);
	
	new Handle:data = CreateDataPack();
	WritePackCell(data, client);
	WritePackCell(data, class);
	CreateTimer(0.1, TEST_DelayedClassChange, data);
}

public Action:TEST_DelayedClassChange(Handle:timer, Handle:data)
{
	ResetPack(data);
	new client = ReadPackCell(data);
	new class = ReadPackCell(data);
	CloseHandle(data);

	new Handle:ConfigFile = LoadGameConfigFile("l4d2addresses");
	
	new Platform = GameConfGetOffset(ConfigFile, "Platform");
	new AbilityOffset;
	if (Platform == 1) // WINDOWS
	{
		AbilityOffset = 0x390;
	}
	else if (Platform == 2) // LINUX
	{
		AbilityOffset = 0x3a4;
	}
	else
	{
		LogError("Unsupported Platform or missing gamedata file, FAIL");
		return Plugin_Stop;
	}
	
	new Handle:SDK_SetClass = INVALID_HANDLE;
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(ConfigFile, SDKConf_Signature, "SetClass");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	SDK_SetClass = EndPrepSDKCall();
	if (SDK_SetClass == INVALID_HANDLE)
	{
		LogError("SetClass Signature missing or broken");
		return Plugin_Stop;
	}
	
	SDKCall(SDK_SetClass, client, class);
	
	new Handle:SDK_CreateAbility = INVALID_HANDLE;
	StartPrepSDKCall(SDKCall_Static);
	PrepSDKCall_SetFromConf(ConfigFile, SDKConf_Signature, "CreateAbility");
	PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
	PrepSDKCall_SetReturnInfo(SDKType_CBaseEntity, SDKPass_Pointer);
	SDK_CreateAbility = EndPrepSDKCall();
	if (SDK_CreateAbility == INVALID_HANDLE)
	{
		LogError("CreateAbility Signature missing or broken");
		return Plugin_Stop;
	}
	
	new WeaponIndex;
	while ((WeaponIndex = GetPlayerWeaponSlot(client, 0)) != -1)
	{
		RemovePlayerItem(client, WeaponIndex);
		RemoveEdict(WeaponIndex);
	}
	
	AcceptEntityInput(MakeCompatEntRef(GetEntProp(client, Prop_Send, "m_customAbility")), "Kill");
	SetEntProp(client, Prop_Send, "m_customAbility", GetEntData(SDKCall(SDK_CreateAbility, client), AbilityOffset));
	return Plugin_Stop;
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

stock CheatClientCommand(client = 0, String:command[], String:arguments[]="")
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
	ClientCommand(client, "%s %s", command, arguments);
	SetCommandFlags(command, flags);
	SetUserFlagBits(client, userflags);
}