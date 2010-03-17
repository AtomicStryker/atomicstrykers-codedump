#define PLUGIN_VERSION    "1.0.1"
#define PLUGIN_NAME       "L4D2 Laser Sights"

#include <sourcemod>

new bool:bHasLaser[MAXPLAYERS+1];

public Plugin:myinfo =
{
	name = PLUGIN_NAME,
	author = "AtomicStryker",
	description = "L4D2 Laser Sights",
	version = PLUGIN_VERSION,
	url = "http://forums.alliedmods.net/showthread.php?p=877908"
};

public OnPluginStart()
{
	CreateConVar("l4d2_lasersight_version", PLUGIN_VERSION, "Lasersight plugin version", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_NOTIFY|FCVAR_DONTRECORD);

	RegConsoleCmd("sm_laseron", CmdLaserOn);
	RegConsoleCmd("sm_laseroff", CmdLaserOff);
	RegConsoleCmd("sm_laser", CmdLaserToggle);
}

public Action:CmdLaserOn(client, args)
{ 
	CheatCommand(client, "upgrade_add", "LASER_SIGHT");
	bHasLaser[client] = true;
	return Plugin_Handled;
}

public Action:CmdLaserOff(client, args)
{ 
	CheatCommand(client, "upgrade_remove", "LASER_SIGHT");
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

CheatCommand(client, const String:command[], const String:arguments[])
{
    if (!client) return;
    new admindata = GetUserFlagBits(client);
    SetUserFlagBits(client, ADMFLAG_ROOT);
    new flags = GetCommandFlags(command);
    SetCommandFlags(command, flags & ~FCVAR_CHEAT);
    FakeClientCommand(client, "%s %s", command, arguments);
    SetCommandFlags(command, flags);
    SetUserFlagBits(client, admindata);
}