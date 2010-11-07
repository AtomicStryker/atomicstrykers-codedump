#define PLUGIN_VERSION    "1.0.7"
#define PLUGIN_NAME       "L4D Laser Sights Pure"

#include <sourcemod>
#include <sdktools>

new Handle:AddUpgrade = INVALID_HANDLE;
new Handle:RemoveUpgrade = INVALID_HANDLE;
new bool:bHasLaser[MAXPLAYERS+1];
new UserMsg:sayTextMsgId;

public Plugin:myinfo =
{
	name = PLUGIN_NAME,
	author = "AtomicStryker",
	description = "Just Laser Sights",
	version = PLUGIN_VERSION,
	url = "http://forums.alliedmods.net/showthread.php?p=877908"
};

public OnPluginStart()
{
	new Handle:CVAR = FindConVar("survivor_upgrades");
	SetConVarInt(CVAR, 1);

	LoadTranslations("common.phrases");

	StartPrepSDKCall(SDKCall_Player);
	if (!PrepSDKCall_SetSignature(SDKLibrary_Server, "\xA1****\x83***\x57\x8B\xF9\x0F*****\x8B***\x56\x51\xE8****\x8B\xF0\x83\xC4\x04", 34))
	{
		//PrepSDKCall_SetSignature(SDKLibrary_Server, "@_ZN13CTerrorPlayer10AddUpgradeE19SurvivorUpgradeType", 0);
		PrepSDKCall_SetSignature(SDKLibrary_Server, "\x55\x89\xE5\x57\x56\x53\x83\xEC\x2A\xE8\x2A\x2A\x2A\x2A\x81\xC3\x2A\x2A\x2A\x2A\x8B\x7D\x2A\x8B\x83\x2A\x2A\x2A\x2A\x8B\x40\x2A\x8B\x48\x2A\x85\xC9\x75\x2A\x83\xC4\x2A\x5B\x5E\x5F\x5D\xC3\x8B\x45\x2A\x89\x2A\x2A\xE8", 54);
	}
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_ByValue);
	AddUpgrade = EndPrepSDKCall();

	StartPrepSDKCall(SDKCall_Player);
	if (!PrepSDKCall_SetSignature(SDKLibrary_Server, "\x51\x53\x55\x8B***\x8B\xD9\x56\x8B\xCD\x83\xE1\x1F\xBE\x01\x00\x00\x00\x57\xD3\xE6\x8B\xFD\xC1\xFF\x05\x89***", 32))
	{
		//PrepSDKCall_SetSignature(SDKLibrary_Server, "@_ZN13CTerrorPlayer13RemoveUpgradeE19SurvivorUpgradeType", 0);
		PrepSDKCall_SetSignature(SDKLibrary_Server, "\x55\x89\xE5\x57\x56\x53\x83\xEC\x2A\xE8\x2A\x2A\x2A\x2A\x81\xC3\x2A\x2A\x2A\x2A\x8B\x75\x2A\x8B\x55\x2A\xC1\xFA\x2A\x81", 30);
	}
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_ByValue);
	RemoveUpgrade = EndPrepSDKCall();

	
	CreateConVar("l4d_lasersight_version", PLUGIN_VERSION, "Lasersight plugin version", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_NOTIFY|FCVAR_DONTRECORD);

	RegConsoleCmd("sm_laseron", CmdLaserOn);
	RegConsoleCmd("sm_laseroff", CmdLaserOff);
	RegConsoleCmd("sm_laser", CmdLaserToggle);
	
	HookEvent("round_end", RoundHasEnded);
	HookEvent("map_transition", RoundHasEnded);
	HookEvent("mission_lost", RoundHasEnded);
	
	sayTextMsgId = GetUserMessageId("SayText");
	HookUserMessage(sayTextMsgId, SayCommandExecuted, true);
}

public OnMapStart()
{
	new String:gamemode[64];
	GetConVarString(FindConVar("mp_gamemode"), gamemode, 64);
	if (strcmp(gamemode, "versus") != 0)
	{
	new Handle:CVAR = FindConVar("survivor_upgrades");
	SetConVarInt(CVAR, 0);
	SetFailState("[Laser] Is for Versus Mode only.");
	}
}

public Action:CmdLaserOn(client, args)
{ 
	SDKCall(AddUpgrade, client, 17);
	bHasLaser[client] = true;
	return Plugin_Handled;
}

public Action:CmdLaserOff(client, args)
{ 
	SDKCall(RemoveUpgrade, client, 17);
	bHasLaser[client] = false;
	return Plugin_Handled;
}

public Action:CmdLaserToggle(client, args)
{

	if (bHasLaser[client])
	{
		CmdLaserOff(client, 0);
	}
	else
	{
		CmdLaserOn(client, 0);
	}
	return Plugin_Handled;
}

// this here blocks pesky L4D status messages ... that are broken

public Action:SayCommandExecuted(UserMsg:msg_id, Handle:bf, const players[], playersNum, bool:reliable, bool:init)
{
	new String:containedtext[1024];
	BfReadByte(bf);
	BfReadByte(bf);
	BfReadString(bf, containedtext, 1024);

	if(StrContains(containedtext, "laser_sight_expire")!= -1)
	{
		return Plugin_Handled;
	}

	if(StrContains(containedtext, "_expire")!= -1)
	{
		return Plugin_Handled;
	}

	if(StrContains(containedtext, "#L4D_Upgrade_")!=-1)
	{
		if(StrContains(containedtext, "description")!=-1)
		{
			return Plugin_Handled;
		}
	}

	return Plugin_Continue;
}

public Action:RoundHasEnded(Handle:event, const String:name[], bool:dontBroadcast)
{
	// One Function to control them all, one function to find them,
	// one function to find them all and in the dark null reset them
	// in the land of Sourcepawn where the memoryleaks lie
	
	for(new i=1; i<=MaxClients; ++i)
	{
		if(IsClientInGame(i)) SDKCall(RemoveUpgrade, i, 17);
	}
	return Plugin_Continue;
}