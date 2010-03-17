#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define PLUGIN_VERSION "1.0.4"

#define DEBUG 0

public Plugin:myinfo =
{
	name = "L4D2 Spawn Uncommons",
	author = "AtomicStryker",
	description = "Let's you spawn Uncommon Zombies",
	version = PLUGIN_VERSION,
	url = ""
}

new RemainingZombiesToSpawn;
new HordeNumber;
new Handle:HordeAmountCVAR = INVALID_HANDLE;


public OnPluginStart()
{
	CreateConVar("l4d2_spawn_uncommons_version", PLUGIN_VERSION, "L4D2 Spawn Uncommons Version", FCVAR_PLUGIN | FCVAR_SPONLY | FCVAR_DONTRECORD | FCVAR_NOTIFY);
	
	HordeAmountCVAR = CreateConVar("l4d2_spawn_uncommons_hordecount", "25", "How many Zombies do you mean by 'horde'", FCVAR_PLUGIN | FCVAR_NOTIFY);

	RegAdminCmd("sm_spawnuncommon", Command_Uncommon, ADMFLAG_CHEATS, "Spawn uncommon infected, ANYTIME");
	RegAdminCmd("sm_spawnuncommonhorde", Command_UncommonHorde, ADMFLAG_CHEATS, "Spawn an uncommon infected horde, ANYTIME");
	
	PrecacheModel("models/infected/common_male_riot.mdl", true);
	PrecacheModel("models/infected/common_male_ceda.mdl", true);
	PrecacheModel("models/infected/common_male_clown.mdl", true);
	PrecacheModel("models/infected/common_male_mud.mdl", true);
	PrecacheModel("models/infected/common_male_roadcrew.mdl", true);
	PrecacheModel("models/infected/common_male_jimmy.mdl", true);
	PrecacheModel("models/infected/common_male_fallen_survivor.mdl", true);
}

public OnMapStart()
{
	PrecacheModel("models/infected/common_male_riot.mdl", true);
	PrecacheModel("models/infected/common_male_ceda.mdl", true);
	PrecacheModel("models/infected/common_male_clown.mdl", true);
	PrecacheModel("models/infected/common_male_mud.mdl", true);
	PrecacheModel("models/infected/common_male_roadcrew.mdl", true);
	PrecacheModel("models/infected/common_male_jimmy.mdl", true);
	PrecacheModel("models/infected/common_male_fallen_survivor.mdl", true);
}

public OnMapEnd()
{
	RemainingZombiesToSpawn = 0;
}

public Action:Command_Uncommon(client, args)
{
	if (!client) return Plugin_Handled;
	
	if (args < 1)
	{
		ReplyToCommand(client, "Usage: sm_spawnuncommon <riot|ceda|clown|mud|roadcrew|jimmy|fallen|random>");
		return Plugin_Handled;
	}
	
	decl String:cmd[56];
	GetCmdArg(1, cmd, sizeof(cmd));
	new number;
	
	if (StrEqual(cmd, "riot", false)) number = 1;
	else if (StrEqual(cmd, "ceda", false)) number = 2;
	else if (StrEqual(cmd, "clown", false)) number = 3;
	else if (StrEqual(cmd, "mud", false)) number = 4;
	else if (StrEqual(cmd, "roadcrew", false)) number = 5;
	else if (StrEqual(cmd, "jimmy", false)) number = 6;
	else if (StrEqual(cmd, "fallen", false)) number = 7;
	else if (StrEqual(cmd, "random", false)) number = 8;
	
	if (!number)
	{
		ReplyToCommand(client, "Usage: sm_spawnuncommon <riot|ceda|clown|mud|roadcrew|jimmy|fallen|random>");
		return Plugin_Handled;
	}
	
	#if DEBUG
	PrintToChatAll("Spawning Uncommon command: number: %i", number);
	#endif
	
	
	decl Float:location[3], Float:ang[3], Float:location2[3];
	GetClientAbsOrigin(client, location);
	GetClientEyeAngles(client, ang);
	
	location2[0] = (location[0]+(50*(Cosine(DegToRad(ang[1])))));
	location2[1] = (location[1]+(50*(Sine(DegToRad(ang[1])))));
	location2[2] = location[2] + 30.0;
	
	SpawnUncommonInf(number, location2);
	
	return Plugin_Handled;
}

public Action:Command_UncommonHorde(client, args)
{
	if (!client) return Plugin_Handled;
	
	if (args < 1)
	{
		ReplyToCommand(client, "Usage: sm_spawnuncommonhorde <riot|ceda|clown|mud|roadcrew|jimmy|random>");
		return Plugin_Handled;
	}
	
	decl String:cmd[56];
	new number;
	
	GetCmdArg(1, cmd, sizeof(cmd));
	
	if (StrEqual(cmd, "riot", false)) number = 1;
	else if (StrEqual(cmd, "ceda", false)) number = 2;
	else if (StrEqual(cmd, "clown", false)) number = 3;
	else if (StrEqual(cmd, "mud", false)) number = 4;
	else if (StrEqual(cmd, "roadcrew", false)) number = 5;
	else if (StrEqual(cmd, "jimmy", false)) number = 6;
	else if (StrEqual(cmd, "fallen", false)) number = 7;
	else if (StrEqual(cmd, "random", false)) number = 8;
	
	if (!number)
	{
		ReplyToCommand(client, "Usage: sm_spawnuncommonhorde <riot|ceda|clown|mud|roadcrew|jimmy|fallen|random>");
		return Plugin_Handled;
	}
	
	#if DEBUG
	PrintToChatAll("Spawning Uncommon Horde command: number: %i", number);	
	#endif
	
	HordeNumber = number;
	RemainingZombiesToSpawn = GetConVarInt(HordeAmountCVAR);
	CheatCommand(GetAnyClient(), "z_spawn", "mob");
	
	return Plugin_Handled;
}

public OnEntityCreated(entity, const String:classname[])
{
	if (RemainingZombiesToSpawn <= 0 || !HordeNumber) return;
	
	if (StrEqual(classname, "infected", false))
	{
		decl String:model[256];
		new number = HordeNumber;
		
		if (number == 8) number = GetRandomInt(1,5);
		
		switch (number)
		{
			case 1:
			{
				Format(model, sizeof(model), "models/infected/common_male_riot.mdl");
			}
			case 2:
			{
				Format(model, sizeof(model), "models/infected/common_male_ceda.mdl");
			}
			case 3:
			{
				Format(model, sizeof(model), "models/infected/common_male_clown.mdl");
			}
			case 4:
			{
				Format(model, sizeof(model), "models/infected/common_male_mud.mdl");
			}
			case 5:
			{
				Format(model, sizeof(model), "models/infected/common_male_roadcrew.mdl");
			}
			case 6:
			{
				Format(model, sizeof(model), "models/infected/common_male_jimmy.mdl");
			}
			case 7:
			{
				Format(model, sizeof(model), "models/infected/common_male_fallen_survivor.mdl");
			}
		}
		SetEntityModel(entity, model);
		RemainingZombiesToSpawn--;
	}
}

public Action:SpawnUncommonInf(number, Float:location[3])
{
	new zombie = CreateEntityByName("infected");
	decl String:model[256];
	
	if (number ==8) number = GetRandomInt(1,5);
	
	switch (number)
	{
		case 1:
		{
			Format(model, sizeof(model), "models/infected/common_male_riot.mdl");
		}
		case 2:
		{
			Format(model, sizeof(model), "models/infected/common_male_ceda.mdl");
		}
		case 3:
		{
			Format(model, sizeof(model), "models/infected/common_male_clown.mdl");
		}
		case 4:
		{
			Format(model, sizeof(model), "models/infected/common_male_mud.mdl");
		}
		case 5:
		{
			Format(model, sizeof(model), "models/infected/common_male_roadcrew.mdl");
		}
		case 6:
		{
			Format(model, sizeof(model), "models/infected/common_male_jimmy.mdl");
		}
		case 7:
		{
			Format(model, sizeof(model), "models/infected/common_male_fallen_survivor.mdl");
		}
	}
	
	SetEntityModel(zombie, model);
	new ticktime = RoundToNearest( FloatDiv( GetGameTime() , GetTickInterval() ) ) + 5;
	SetEntProp(zombie, Prop_Data, "m_nNextThinkTick", ticktime);

	DispatchSpawn(zombie);
	ActivateEntity(zombie);
	
	location[2] -= 25.0; //reduce the 'drop' effect
	TeleportEntity(zombie, location, NULL_VECTOR, NULL_VECTOR);
	
	#if DEBUG
	PrintToChatAll("Spawned uncommon inf %i", number);	
	#endif
}

GetAnyClient()
{
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			return i;
		}
	}
	return 0;
}

CheatCommand(client, const String:command[], const String:arguments[]="")
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