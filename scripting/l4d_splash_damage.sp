#pragma semicolon 1
#include <sourcemod>
#include <sdktools>

#define PLUGIN_VERSION "1.0.6"
#define CVAR_FLAGS FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_NOTIFY


static Handle:SplashEnabled = INVALID_HANDLE;
static Handle:SplashRadius = INVALID_HANDLE;
static Handle:SplashDamage = INVALID_HANDLE;
static Handle:DisplayDamageMessage = INVALID_HANDLE;
static bool:IsSwappingTeam[MAXPLAYERS+1];

public Plugin:myinfo = 
{
	name = "L4D_Splash_Damage",
	author = " AtomicStryker",
	description = "Left 4 Dead Boomer Splash Damage",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/showthread.php?t=98794"
}

public OnPluginStart()
{
	HookEvent("player_death", PlayerDeath);
	HookEvent("player_team", PlayerTeam);
	
	CreateConVar("l4d_splash_damage_version", PLUGIN_VERSION, " Version of L4D Boomer Splash Damage on this server ", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_DONTRECORD);
	SplashEnabled = CreateConVar("l4d_splash_damage_enabled", "1", " Enable/Disable the Splash Damage plugin ", CVAR_FLAGS);
	SplashDamage = CreateConVar("l4d_splash_damage_damage", "10.0", " Amount of damage the Boomer Explosion deals ", CVAR_FLAGS);
	SplashRadius = CreateConVar("l4d_splash_damage_radius", "200", " Radius of Splash damage ", CVAR_FLAGS);
	DisplayDamageMessage = CreateConVar("l4d_splash_damage_notification", "1", " 0 - Disabled; 1 - small HUD Hint; 2 - big HUD Hint; 3 - Chat Notification ", CVAR_FLAGS);
	
	AutoExecConfig(true, "L4D_Splash_Damage");
}

public Action:PlayerTeam(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!client || !IsClientInGame(client)) return;
	
	IsSwappingTeam[client] = true;
	CreateTimer(2.0, EraseGhostExploit, client);
}

public Action:PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!client || !IsClientInGame(client)) return;
	
	if (GetClientTeam(client)!=3) return;
	if (IsSwappingTeam[client]) return;

	CreateTimer(0.1, Splashdamage, client);
}

public Action:Splashdamage(Handle:timer, any:client)
{		
	decl String:class[100];
	GetClientModel(client, class, sizeof(class));
	
	if (StrContains(class, "boomer", false) != -1)
	{
		if (GetConVarInt(SplashEnabled))
		{
			//PrintToChatAll("Boomerdeath caught, Plugin running");
			decl Float:g_pos[3];
			GetClientEyePosition(client,g_pos);
			
			for (new target = 1; target <= MaxClients; target++)
			{
				if (IsClientInGame(target))
				{
					if (IsPlayerAlive(target))
					{
						if (GetClientTeam(client) != GetClientTeam(target))
						{
							decl Float:targetVector[3];
							GetClientEyePosition(target, targetVector);
							
							new Float:distance = GetVectorDistance(targetVector, g_pos);
							
							if (distance < GetConVarFloat(SplashRadius))
							{							
								switch (GetConVarInt(DisplayDamageMessage))
								{
									case 1:
									PrintCenterText(target, "You've taken Damage from a Boomer Splash!");
									
									case 2:
									PrintHintText(target, "You've taken Damage from a Boomer Splash!");
									
									case 3:
									PrintToChat(target, "You've taken Damage from a Boomer Splash!");
								}
								
								DamageEffect(target);
								
								new damage = GetConVarInt(SplashDamage);
								if (!damage) return Plugin_Stop;
								
								new hardhp = GetEntProp(target, Prop_Data, "m_iHealth") - 1;
								
								if (damage < hardhp || IsPlayerIncapped(target))
								{
									SetEntityHealth(target, hardhp - damage);
								}
								
								else if (damage > hardhp)
								{
									new Float:temphp = GetEntPropFloat(target, Prop_Send, "m_healthBuffer");
									
									if (damage < temphp)
									{
										SetEntPropFloat(target, Prop_Send, "m_healthBuffer", FloatSub(temphp, GetConVarFloat(SplashDamage)));
									}
								}
							}
						}
					}
				}
			}
		}
	}
	return Plugin_Stop;
}

stock DamageEffect(target)
{
	new pointHurt = CreateEntityByName("point_hurt");			// Create point_hurt
	DispatchKeyValue(target, "targetname", "hurtme");			// mark target
	DispatchKeyValue(pointHurt, "Damage", "0");					// No Damage, just HUD display. Does stop Reviving though
	DispatchKeyValue(pointHurt, "DamageTarget", "hurtme");		// Target Assignment
	DispatchKeyValue(pointHurt, "DamageType", "65536");			// Type of damage
	DispatchSpawn(pointHurt);									// Spawn descriped point_hurt
	AcceptEntityInput(pointHurt, "Hurt"); 						// Trigger point_hurt execute
	AcceptEntityInput(pointHurt, "Kill"); 						// Remove point_hurt
	DispatchKeyValue(target, "targetname",	"cake");			// Clear target's mark
}

public Action:EraseGhostExploit(Handle:timer, Handle:client)
{	
	IsSwappingTeam[client] = false;
	return Plugin_Handled;
}

stock bool:IsPlayerIncapped(client)
{
	if (GetEntProp(client, Prop_Send, "m_isIncapacitated", 1)) return true;
	return false;
}