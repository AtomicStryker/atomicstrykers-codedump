#pragma semicolon 1
#include <sourcemod>
#include <sdktools>

#define PLUGIN_VERSION "2.14"
#define CVAR_FLAGS          FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_NOTIFY

#define DEBUG 0


new Handle:CloudEnabled = INVALID_HANDLE;
new Handle:CloudDuration = INVALID_HANDLE;
new Handle:CloudRadius = INVALID_HANDLE;
new Handle:CloudDamage = INVALID_HANDLE;
new Handle:CloudShake = INVALID_HANDLE;
new Handle:SoundPath = INVALID_HANDLE;
new Handle:CloudMeleeSlowEnabled = INVALID_HANDLE;
new Handle:DisplayDamageMessage = INVALID_HANDLE;
new Handle:ReviveBlocking = INVALID_HANDLE;

new Handle:timer_handle[MAXPLAYERS+1][5];
new Handle:hurtdata[MAXPLAYERS+1][5];
new meleeentinfo;
new bool:isincloud[MAXPLAYERS+1];
new bool:MeleeDelay[MAXPLAYERS+1];
new propinfoghost;

public Plugin:myinfo = 
{
	name = "L4D_Cloud_Damage",
	author = " AtomicStryker",
	description = "Left 4 Dead Cloud Damage",
	version = PLUGIN_VERSION,
	url = "http://forums.alliedmods.net/showthread.php?t=96665"
}


public OnPluginStart()
{
	HookEvent("player_death", PlayerDeath, EventHookMode_Pre);
	AddNormalSoundHook(NormalSHook:HookSound_Callback); //my melee hook since they didnt include an event for it
	HookEvent("player_team", PlayerTeam);
	
	CloudEnabled = CreateConVar("l4d_cloud_damage_enabled", "1", " Enable/Disable the Cloud Damage plugin ", CVAR_FLAGS);
	CloudDamage = CreateConVar("l4d_cloud_damage_damage", "2.0", " Amount of damage the cloud deals every 2 seconds ", CVAR_FLAGS);
	CloudDuration = CreateConVar("l4d_cloud_damage_time", "17.0", "How long the cloud damage persists ", CVAR_FLAGS);
	CloudRadius = CreateConVar("l4d_cloud_damage_radius", "250", " Radius of gas cloud damage ", CVAR_FLAGS);
	SoundPath = CreateConVar("l4d_cloud_damage_sound", "player/survivor/voice/choke_5.wav", "Path to the Soundfile being played on each damaging Interval", CVAR_FLAGS);
	CloudMeleeSlowEnabled = CreateConVar("l4d_cloud_meleeslow_enabled", "1", " Enable/Disable the Cloud Melee Slow Effect ", CVAR_FLAGS);
	DisplayDamageMessage = CreateConVar("l4d_cloud_message_enabled", "1", " 0 - Disabled; 1 - small HUD Hint; 2 - big HUD Hint; 3 - Chat Notification ", CVAR_FLAGS);
	CloudShake = CreateConVar("l4d_cloud_shake_enabled", "1", " Enable/Disable the Cloud Damage Shake ", CVAR_FLAGS);
	ReviveBlocking = CreateConVar("l4d_cloud_damage_revive_blocking_enabled", "0", " Enable/Disable Cloud damage stopping Survivor Revival ", CVAR_FLAGS);
	
	CreateConVar("l4d_cloud_damage_version", PLUGIN_VERSION, " Version of L4D Cloud Damage on this server ", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_DONTRECORD);

	// Autoexec config
	AutoExecConfig(true, "L4D_Cloud_Damage");
	
	meleeentinfo = FindSendPropInfo("CTerrorPlayer", "m_iShovePenalty");
	propinfoghost = FindSendPropInfo("CTerrorPlayer", "m_isGhost");
}

public Action:PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	// We get the client id
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	// If client is valid
	if (client == 0) return Plugin_Continue;
	if (!IsClientInGame(client)) return Plugin_Continue;
	
	// If player wasn't on infected team, we ignore this ...
	if (GetClientTeam(client)!=3) return Plugin_Continue;
	// To fix the ghost Smoker cloud exploit
	if (IsPlayerSpawnGhost(client)) return Plugin_Continue;
	
	// Dead classtype ...
	decl String:class[100];
	GetClientModel(client, class, sizeof(class));
	
	if (StrContains(class, "smoker", false) != -1)
	{
		
		if (GetConVarInt(CloudEnabled) == 1)
		{
			//PrintToChatAll("Smokerdeath caught, Plugin running");
			decl Float:g_pos[3];
			GetClientEyePosition(client,g_pos);
			
			new Handle:gasdata = CreateDataPack();
			CreateTimer(1.0, GasCloud, gasdata);
			WritePackCell(gasdata, client);
			WritePackFloat(gasdata, g_pos[0]);
			WritePackFloat(gasdata, g_pos[1]);
			WritePackFloat(gasdata, g_pos[2]);
		}
	}
	return Plugin_Continue;
}

public Action:GasCloud(Handle:timer, Handle:gasdata)
{
	#if DEBUG
	PrintToChatAll("Action GasCloud running");
	#endif
	
	ResetPack(gasdata);
	new client = ReadPackCell(gasdata);
	decl Float:g_pos[3];
	g_pos[0] = ReadPackFloat(gasdata);
	g_pos[1] = ReadPackFloat(gasdata);
	g_pos[2] = ReadPackFloat(gasdata);
	CloseHandle(gasdata);
	
	// For Bot Smokers. They all have the same client, and multiple Clouds bugged it out
	// Im sure this can be coded nicer. But i dont want to.
	
	decl cloudindex;
	if (timer_handle[client][0] != INVALID_HANDLE)
	{
		if (timer_handle[client][1] != INVALID_HANDLE)
		{
			if (timer_handle[client][2] != INVALID_HANDLE)
			{
				if (timer_handle[client][3] != INVALID_HANDLE)
				{
					cloudindex = 4;
				}
				else 
				{
					cloudindex = 3;
				}
			}
			else
			{
				cloudindex = 2;
			}
		}
		else
		{
			cloudindex = 1;
		}
	}
	else
	{
		cloudindex = 0;
	}
	
	decl Float:duration;
	duration = GetConVarFloat(CloudDuration);
	
	hurtdata[client][cloudindex] = CreateDataPack();
	WritePackCell(hurtdata[client][cloudindex], client);
	WritePackFloat(hurtdata[client][cloudindex], g_pos[0]);
	WritePackFloat(hurtdata[client][cloudindex], g_pos[1]);
	WritePackFloat(hurtdata[client][cloudindex], g_pos[2]);
	timer_handle[client][cloudindex] = CreateTimer(2.0, Point_Hurt, hurtdata[client][cloudindex], TIMER_REPEAT);
	
	new Handle:entitypack = CreateDataPack();
	CreateTimer(duration, RemoveGas, entitypack);
	duration = duration + 1.0;
	CreateTimer(duration, ClearHandle, entitypack);
	WritePackCell(entitypack, client);
	WritePackCell(entitypack, cloudindex);
	
	return Plugin_Continue;
}


public Action:RemoveGas(Handle:timer, Handle:entitypack)
{
	#if DEBUG
	PrintToChatAll("Action Remover running");
	#endif
	
	ResetPack(entitypack);
	
	new client = ReadPackCell(entitypack);
	new cloudindex = ReadPackCell(entitypack);
	
	if (timer_handle[client][cloudindex] != INVALID_HANDLE)
	{
		KillTimer(timer_handle[client][cloudindex]);
		timer_handle[client][cloudindex] = INVALID_HANDLE;
		CloseHandle(hurtdata[client][cloudindex]);
	}
}

public Action:ClearHandle(Handle:timer, Handle:entitypack)
{
	#if DEBUG
	PrintToChatAll("Action HandleCleaner running");
	#endif
	
	ResetPack(entitypack);
	CloseHandle(entitypack);
}

public Action:PlayerTeam(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	CreateTimer(1.0, EraseGhostExploit, client);
	return Plugin_Continue;
}

public Action:EraseGhostExploit(Handle:timer, Handle:client)
{	
	for (new i = 0; i <= 4; i++)
	{
		if (timer_handle[client][i] != INVALID_HANDLE)
		{
			KillTimer(timer_handle[client][i]);
			timer_handle[client][i] = INVALID_HANDLE;
			CloseHandle(hurtdata[client][i]);
		}
	}
}

public Action:Point_Hurt(Handle:timer, Handle:hurt)
{
	ResetPack(hurt);
	new client = ReadPackCell(hurt);
	decl Float:g_pos[3];
	g_pos[0] = ReadPackFloat(hurt);
	g_pos[1] = ReadPackFloat(hurt);
	g_pos[2] = ReadPackFloat(hurt);
	
	#if DEBUG
	PrintToChatAll("Action PointHurter running");
	#endif
	
	if (!IsClientInGame(client)) client = -1;
	// dummy line to prevent compiling errors. the client data has to be read or the datapack becomes corrupted
	
	for (new target = 1; target <= MaxClients; target++)
	{
		if (target > 0 && IsClientInGame(target))
		{
		if (IsPlayerAlive(target) && GetClientTeam(target) == 2)
		{

			decl Float:targetVector[3];
			GetClientEyePosition(target, targetVector);
					
			new Float:distance = GetVectorDistance(targetVector, g_pos);
					
			if (distance < GetConVarFloat(CloudRadius))
			{							
						
				decl String:soundFilePath[256];
				GetConVarString(SoundPath, soundFilePath,256);
				EmitSoundToClient(target, soundFilePath);
				
				switch (GetConVarInt(DisplayDamageMessage))
				{
					case 1:
					PrintCenterText(target, "You're suffering from a Smoker Cloud!");
					
					case 2:
					PrintHintText(target, "You're suffering from a Smoker Cloud!");
					
					case 3:
					PrintToChat(target, "You're suffering from a Smoker Cloud!");
				}
				
				new IsIncapped = GetEntProp(target, Prop_Send, "m_isIncapacitated");
				if (IsIncapped && GetConVarInt(ReviveBlocking) == 1) DamageEffect(target);
				if (!IsIncapped) DamageEffect(target);
				
				if (GetConVarBool(CloudShake))
				{
					decl String:gamename[128];
					GetGameFolderName(gamename, sizeof(gamename));
					if (StrEqual(gamename, "left4dead"))
					{
						new Handle:hBf = StartMessageOne("Shake", target);
						BfWriteByte(hBf, 0);
						BfWriteFloat(hBf,6.0);
						BfWriteFloat(hBf,1.0);
						BfWriteFloat(hBf,1.0);
						EndMessage();
						CreateTimer(1.0, StopShake, target);
					}
					else if (StrEqual(gamename, "left4dead2"))
					{
						new array[1];
						array[0] = target;
						new Handle:hBf = StartMessageEx(11, array, 1);
						if (hBf != INVALID_HANDLE)
						{
							BfWriteByte(hBf, 0);
							BfWriteFloat(hBf,6.0);
							BfWriteFloat(hBf,1.0);
							BfWriteFloat(hBf,1.0);
							EndMessage();
						}
						else CloseHandle(hBf);
					}
				}
					
				new damage = GetConVarInt(CloudDamage);
				new hardhp = GetClientHealth(target) + 2; //i dont know why 2 are missing here.
				
				if (GetConVarInt(CloudMeleeSlowEnabled) == 1)
				{
					if (IsFakeClient(target)) continue;
					isincloud[target] = true;
					CreateTimer(2.0, ClearMeleeBlock, target);
				}
				
				#if DEBUG
				PrintToChatAll("HardHP: %i", hardhp);
				#endif
				
				if (damage == 0) return Plugin_Continue;
				
				if (damage < hardhp || IsPlayerIncapped(target))
				{
					#if DEBUG
					PrintToChatAll("Hard Damage IF applied, applying hard damage");
					PrintToChatAll("DMG: %i HARDHP: %i NEWHP: %i", damage, hardhp, hardhp - damage);
					#endif
					
					SetEntityHealth(target, hardhp - damage);
				}
				
				else
				{
					new Float:temphp = GetEntPropFloat(target, Prop_Send, "m_healthBuffer") +2.0; //here 2 missing, again.
					new Float:damagefloat = GetConVarFloat(CloudDamage);
					
					#if DEBUG
					PrintToChatAll("TempHP: %f", temphp);
					PrintToChatAll("DMG: %f TEMPHP: %f NEWT-HP: %f", damagefloat, temphp, FloatSub(temphp,damagefloat));
					#endif
					
					if (FloatCompare(damagefloat,temphp) == -1)
					{
						#if DEBUG
						PrintToChatAll("Temp Damage IF applied, applying temp damage");
						#endif
						
						SetEntPropFloat(target, Prop_Send, "m_healthBuffer", FloatSub(temphp,damagefloat));
					}
				}
			}
		}
		}
	}
	return Plugin_Continue;
}

public Action:HookSound_Callback(Clients[64], &NumClients, String:StrSample[PLATFORM_MAX_PATH], &Entity)
{
	//to work only on melee sounds, its 'swish' or 'weaponswing'
	if (StrContains(StrSample, "Swish", false) == -1) return Plugin_Continue;
	//so the client has the melee sound playing. OMG HES MELEEING!
	
	if (Entity > MAXPLAYERS) return Plugin_Continue; // bugfix for some people on L4D2
	
	//add in a 1 second delay so this doesnt fire every frame
	if (MeleeDelay[Entity]) return Plugin_Continue; //note 'Entity' means 'client' here
	MeleeDelay[Entity] = true;
	CreateTimer(1.0, ResetMeleeDelay, Entity);
	
	#if DEBUG
	PrintToChatAll("Melee detected via soundhook.");
	#endif
	
	if (isincloud[Entity]) SetEntData(Entity, meleeentinfo, 1.5, 4);	
	
	return Plugin_Continue;
}

public Action:ResetMeleeDelay(Handle:timer, any:client)
{
	MeleeDelay[client] = false;
}

public Action:ClearMeleeBlock(Handle:timer, Handle:target)
{
	isincloud[target] = false;
}

public Action:DamageEffect(target)
{
	new pointHurt = CreateEntityByName("point_hurt");			// Create point_hurt
	DispatchKeyValue(target, "targetname", "hurtme");				// mark target
	DispatchKeyValue(pointHurt, "Damage", "0");					// No Damage, just HUD display. Does stop Reviving though
	DispatchKeyValue(pointHurt, "DamageTarget", "hurtme");		// Target Assignment
	DispatchKeyValue(pointHurt, "DamageType", "65536");			// Type of damage
	DispatchSpawn(pointHurt);										// Spawn descriped point_hurt
	AcceptEntityInput(pointHurt, "Hurt"); 						// Trigger point_hurt execute
	AcceptEntityInput(pointHurt, "Kill"); 						// Remove point_hurt
	DispatchKeyValue(target, "targetname",	"cake");			// Clear target's mark
}

public Action:StopShake(Handle:timer, any:target)
{
	if (target <= 0) return;
	if (!IsClientInGame(target)) return;
	
	new Handle:hBf=StartMessageOne("Shake", target);
	BfWriteByte(hBf, 0);
	BfWriteFloat(hBf,0.0);
	BfWriteFloat(hBf,0.0);
	BfWriteFloat(hBf,0.0);
	EndMessage();
}

bool:IsPlayerSpawnGhost(client)
{
	if (GetEntData(client, propinfoghost, 1)) return true;
	return false;
}

bool:IsPlayerIncapped(client)
{
	if (GetEntProp(client, Prop_Send, "m_isIncapacitated", 1)) return true;
	return false;
}