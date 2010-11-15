#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define GETVERSION "1.0A"
#define ARRAY_SIZE 5000

#define TEST_DEBUG 		0
#define TEST_DEBUG_LOG 	0

static const String:FIRE_PARTICLE[] = 		"gas_explosion_ground_fire";
static const String:EXPLOSION_PARTICLE[] = 	"weapon_pipebomb";
static const String:EXPLOSION_PARTICLE2[] = "weapon_grenade_explosion";
static const String:EXPLOSION_PARTICLE3[] = "explosion_huge_b";
static const String:EXPLOSION_SOUND[] = 	"ambient/explosions/explode_1.wav";
static const String:EXPLOSION_SOUND2[] = 	"ambient/explosions/explode_2.wav";
static const String:EXPLOSION_SOUND3[] = 	"ambient/explosions/explode_3.wav";
static const String:EXPLOSION_DEBRIS[] = 	"animation/van_inside_debris.wav";
static const String:EXPLOSION_BIRDS[] = 	"animation/crow_flock_farm_05.wav";
static const String:DAMAGE_WHITE_SMOKE[] = 	"minigun_overheat_smoke";
static const String:DAMAGE_BLACK_SMOKE[] = 	"smoke_burning_engine_01";
static const String:DAMAGE_FIRE_SMALL[] = 	"burning_engine_01";
static const String:DAMAGE_FIRE_HUGE[] = 	"fire_window_hotel2";
//static const String:FIRE_SOUND[] = 			"ambient/fire/interior_fire01_stereo.wav";

new bool:g_bLowWreck[ARRAY_SIZE] = false;
new bool:g_bMidWreck[ARRAY_SIZE] = false;
new bool:g_bHighWreck[ARRAY_SIZE] = false;
new bool:g_bCritWreck[ARRAY_SIZE] = false;
new bool:g_bExploded[ARRAY_SIZE] = false;
new g_iEntityDamage[ARRAY_SIZE] = 0;
new g_iParticle[ARRAY_SIZE] = -1;

new Handle:g_hGameConf = INVALID_HANDLE;
new Handle:sdkCallPushPlayer = INVALID_HANDLE;
new Handle:g_cvarMaxHealth = INVALID_HANDLE;
new Handle:g_cvarRadius = INVALID_HANDLE;
new Handle:g_cvarPower = INVALID_HANDLE;
new Handle:g_cvarTrace = INVALID_HANDLE;
new Handle:g_cvarPanic = INVALID_HANDLE;

public Plugin:myinfo = 
{
	name = "[L4D2] Explosive Cars",
	author = "honorcode23, fixed up by AtomicStryker",
	description = "Cars explode after they take some damage",
	version = GETVERSION,
	url = "http://forums.alliedmods.net/showthread.php?t=138644"
}

public OnPluginStart()
{
	//Left 4 dead 2 only
	decl String:sGame[256];
	GetGameFolderName(sGame, sizeof(sGame));
	if (!StrEqual(sGame, "left4dead2", false))
	{
		SetFailState("Explosive Cars supports Left 4 dead 2 only!");
	}
	
	//Convars
	CreateConVar("l4d2_explosive_cars_version", GETVERSION, "Version of the [L4D2] Explosive Cars plugin", FCVAR_SPONLY|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	g_cvarMaxHealth = CreateConVar("l4d2_explosive_cars_health", "3500", "Maximum health of the cars", FCVAR_PLUGIN);
	g_cvarRadius = CreateConVar("l4d2_explosive_cars_radius", "420", "Maximum radius of the explosion", FCVAR_PLUGIN);
	g_cvarPower = CreateConVar("l4d2_explosive_cars_power", "300", "Power of the explosion when the car explodes", FCVAR_PLUGIN);
	g_cvarTrace = CreateConVar("l4d2_explosive_cars_trace", "25", "Time before the fire trace left by the explosion expires", FCVAR_PLUGIN);
	g_cvarPanic = CreateConVar("l4d2_explosive_cars_panic", "1", "Should the car explosion cause a panic event?", FCVAR_PLUGIN);
	
	//AutoExecConfig(true, "l4d2_explosive_cars");
	
	//Events
	HookEvent("round_start_post_nav", Event_RoundStart);
	
	//Signatures
	g_hGameConf = LoadGameConfigFile("l4d2explosivecars");
	if(g_hGameConf == INVALID_HANDLE)
	{
		SetFailState("Unable to find the signatures file. Make sure it is on the 'gamedata' folder");
	}
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(g_hGameConf, SDKConf_Signature, "CTerrorPlayer_Fling");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
	sdkCallPushPlayer = EndPrepSDKCall();
	if(sdkCallPushPlayer == INVALID_HANDLE)
	{
		SetFailState("Unable to find the 'CTerrorPlayer_Fling' signature, check the file version!");
	}
}

public OnMapStart()
{
	PrecacheParticle(EXPLOSION_PARTICLE);
	PrecacheParticle(EXPLOSION_PARTICLE2);
	PrecacheParticle(EXPLOSION_PARTICLE3);
	PrecacheParticle(FIRE_PARTICLE);
	PrecacheParticle(DAMAGE_WHITE_SMOKE);
	PrecacheParticle(DAMAGE_BLACK_SMOKE);
	PrecacheParticle(DAMAGE_FIRE_SMALL);
	PrecacheParticle(DAMAGE_FIRE_HUGE);
	
	FindMapCars();
}

public Event_RoundStart(Handle:event, String:event_name[], bool:dontBroadcast)
{
	for(new i=1; i<ARRAY_SIZE; i++)
	{
		g_iEntityDamage[i] = 0;
		g_bLowWreck[i] = false;
		g_bMidWreck[i] = false;
		g_bHighWreck[i] = false;
		g_bCritWreck[i] = false;
		g_bExploded[i] = false;
		g_iParticle[i] = -1;
	}
}

static FindMapCars()
{
	new maxEnts = GetMaxEntities();
	decl String:classname[128], String:model[256];
	
	for (new i = MaxClients; i < maxEnts; i++)
	{
		if (!IsValidEdict(i)) continue;
		
		GetEdictClassname(i, classname, sizeof(classname));
		
		if(StrEqual(classname, "prop_physics")
		|| StrEqual(classname, "prop_physics_override"))
		{
			GetEntPropString(i, Prop_Data, "m_ModelName", model, sizeof(model))
			if(StrContains(model, "vehicle", false) != -1)
			{
				SDKHook(i, SDKHook_OnTakeDamagePost, OnTakeDamagePost);
				DebugPrintToAll("Activated Explosive Car Damage Hook on entity %i, class %s", i, classname);
			}
		}
	}
}

public OnEntityCreated(entity, const String:classname[])
{
	if(StrEqual(classname, "prop_physics")
	|| StrEqual(classname, "prop_physics_override"))
	{
		decl String:model[256];
		GetEntPropString(entity, Prop_Data, "m_ModelName", model, sizeof(model))
		if(StrContains(model, "vehicle", false) != -1)
		{
			SDKHook(entity, SDKHook_OnTakeDamagePost, OnTakeDamagePost);
			DebugPrintToAll("Activated Explosive Car Damage Hook on entity %i, class %s", entity, classname);
		}
	}
	
	if(StrEqual(classname, "prop_car_alarm"))
	{
		SDKHook(entity, SDKHook_OnTakeDamagePost, OnTakeDamagePost);
		DebugPrintToAll("Activated Explosive Car Damage Hook on entity %i, class %s", entity, classname);
	}
}

public OnTakeDamagePost(victim, attacker, inflictor, Float:damage, damagetype)
{
	decl String:class2[256];
	GetEdictClassname(attacker, class2, sizeof(class2));
	
	new MaxDamageHandle = GetConVarInt(g_cvarMaxHealth)/5;
	
	if(StrEqual(class2, "weapon_melee"))
	{
		damage = 5.0;
	}
	
	g_iEntityDamage[victim]+= RoundToFloor(damage);

	new tdamage = g_iEntityDamage[victim];
	
	if(tdamage >= MaxDamageHandle
	&& tdamage < MaxDamageHandle*2
	&& !g_bLowWreck[victim])
	{
		AttachParticle(victim, DAMAGE_WHITE_SMOKE);
		g_bLowWreck = true;
	}
	
	else if(tdamage >= MaxDamageHandle*2
	&& tdamage < MaxDamageHandle*3
	&& !g_bMidWreck[victim])
	{
		AttachParticle(victim, DAMAGE_BLACK_SMOKE);
		g_bMidWreck = true;
	}
	
	else if(tdamage >= MaxDamageHandle*3
	&& tdamage < MaxDamageHandle*4
	&& !g_bHighWreck[victim])
	{
		AttachParticle(victim, DAMAGE_FIRE_SMALL);
		g_bHighWreck = true;
	}
	
	else if(tdamage >= MaxDamageHandle*4
	&& tdamage < MaxDamageHandle*5
	&& !g_bCritWreck[victim])
	{
		AttachParticle(victim, DAMAGE_FIRE_HUGE);
		g_bCritWreck = true;
	}
	
	else if(tdamage > MaxDamageHandle*5
	&& !g_bExploded[victim])
	{
		g_bExploded[victim] = true;
		decl Float:carPos[3];
		GetEntPropVector(victim, Prop_Data, "m_vecOrigin", carPos);
		CreateExplosion(carPos);
		LaunchCar(victim);
	}
}

stock LaunchCar(car)
{
	decl Float:vel[3];
	GetEntPropVector(car, Prop_Data, "m_vecVelocity", vel);
	vel[0]+= GetRandomFloat(50.0, 300.0);
	vel[1]+= GetRandomFloat(50.0, 300.0);
	vel[2]+= GetRandomFloat(1000.0, 2500.0);
	
	TeleportEntity(car, NULL_VECTOR, NULL_VECTOR, vel);
	CreateTimer(7.0, timerNormalVelocity, car, TIMER_FLAG_NO_MAPCHANGE);
}

public Action:timerNormalVelocity(Handle:timer, any:car)
{
	if(IsValidEntity(car))
	{
		new Float:vel[3];
		SetEntPropVector(car, Prop_Data, "m_vecVelocity", vel);
	}
}

CreateExplosion(Float:carPos[3])
{
	decl String:sRadius[256];
	decl String:sPower[256];
	new Float:flMxDistance = GetConVarFloat(g_cvarRadius);
	new Float:power = GetConVarFloat(g_cvarPower);
	IntToString(GetConVarInt(g_cvarRadius), sRadius, sizeof(sRadius));
	IntToString(GetConVarInt(g_cvarPower), sPower, sizeof(sPower));
	new exParticle2 = CreateEntityByName("info_particle_system");
	new exParticle3 = CreateEntityByName("info_particle_system");
	new exTrace = CreateEntityByName("info_particle_system");
	new exPhys = CreateEntityByName("env_physexplosion");
	new exHurt = CreateEntityByName("point_hurt");
	new exParticle = CreateEntityByName("info_particle_system");
	new exEntity = CreateEntityByName("env_explosion");
	/*new exPush = CreateEntityByName("point_push");*/
	
	//Set up the particle explosion
	DispatchKeyValue(exParticle, "effect_name", EXPLOSION_PARTICLE);
	DispatchSpawn(exParticle);
	ActivateEntity(exParticle);
	TeleportEntity(exParticle, carPos, NULL_VECTOR, NULL_VECTOR);
	
	DispatchKeyValue(exParticle2, "effect_name", EXPLOSION_PARTICLE2);
	DispatchSpawn(exParticle2);
	ActivateEntity(exParticle2);
	TeleportEntity(exParticle2, carPos, NULL_VECTOR, NULL_VECTOR);
	
	DispatchKeyValue(exParticle3, "effect_name", EXPLOSION_PARTICLE3);
	DispatchSpawn(exParticle3);
	ActivateEntity(exParticle3);
	TeleportEntity(exParticle3, carPos, NULL_VECTOR, NULL_VECTOR);
	
	DispatchKeyValue(exTrace, "effect_name", FIRE_PARTICLE);
	DispatchSpawn(exTrace);
	ActivateEntity(exTrace);
	TeleportEntity(exTrace, carPos, NULL_VECTOR, NULL_VECTOR);
	
	
	//Set up explosion entity
	DispatchKeyValue(exEntity, "fireballsprite", "sprites/muzzleflash4.vmt");
	DispatchKeyValue(exEntity, "iMagnitude", sPower);
	DispatchKeyValue(exEntity, "iRadiusOverride", sRadius);
	DispatchKeyValue(exEntity, "spawnflags", "828");
	DispatchSpawn(exEntity);
	TeleportEntity(exEntity, carPos, NULL_VECTOR, NULL_VECTOR);
	
	//Set up physics movement explosion
	DispatchKeyValue(exPhys, "radius", sRadius);
	DispatchKeyValue(exPhys, "magnitude", sPower);
	DispatchSpawn(exPhys);
	TeleportEntity(exPhys, carPos, NULL_VECTOR, NULL_VECTOR);
	
	
	//Set up hurt point
	DispatchKeyValue(exHurt, "DamageRadius", sRadius);
	DispatchKeyValue(exHurt, "DamageDelay", "0.5");
	DispatchKeyValue(exHurt, "Damage", "5");
	DispatchKeyValue(exHurt, "DamageType", "8");
	DispatchSpawn(exHurt);
	TeleportEntity(exHurt, carPos, NULL_VECTOR, NULL_VECTOR);
	
	switch(GetRandomInt(1,3))
	{
		case 1:
		{
			if(!IsSoundPrecached(EXPLOSION_SOUND))
			{
				PrecacheSound(EXPLOSION_SOUND);
			}
			EmitSoundToAll(EXPLOSION_SOUND);
		}
		case 2:
		{
			if(!IsSoundPrecached(EXPLOSION_SOUND2))
			{
				PrecacheSound(EXPLOSION_SOUND2);
			}
			EmitSoundToAll(EXPLOSION_SOUND2);
		}
		case 3:
		{
			if(!IsSoundPrecached(EXPLOSION_SOUND3))
			{
				PrecacheSound(EXPLOSION_SOUND3);
			}
			EmitSoundToAll(EXPLOSION_SOUND3);
		}
	}
	
	if(!IsSoundPrecached(EXPLOSION_DEBRIS))
	{
		PrecacheSound(EXPLOSION_DEBRIS);
	}
	EmitSoundToAll(EXPLOSION_DEBRIS);
	
	if(GetConVarBool(g_cvarPanic))
	{
		PanicEvent();
		if(!IsSoundPrecached(EXPLOSION_BIRDS))
		{
			PrecacheSound(EXPLOSION_BIRDS);
		}
		EmitSoundToAll(EXPLOSION_BIRDS);
	}
	
	//BOOM!
	AcceptEntityInput(exParticle, "Start");
	AcceptEntityInput(exParticle2, "Start");
	AcceptEntityInput(exParticle3, "Start");
	AcceptEntityInput(exTrace, "Start");
	AcceptEntityInput(exEntity, "Explode");
	AcceptEntityInput(exPhys, "Explode");
	AcceptEntityInput(exHurt, "TurnOn");
	
	new Handle:pack2 = CreateDataPack();
	WritePackCell(pack2, exParticle);
	WritePackCell(pack2, exParticle2);
	WritePackCell(pack2, exParticle3);
	WritePackCell(pack2, exTrace);
	WritePackCell(pack2, exEntity);
	WritePackCell(pack2, exPhys);
	WritePackCell(pack2, exHurt);
	CreateTimer(GetConVarFloat(g_cvarTrace)+1.5, timerDeleteParticles, pack2, TIMER_FLAG_NO_MAPCHANGE);
	
	new Handle:pack = CreateDataPack();
	WritePackCell(pack, exTrace);
	WritePackCell(pack, exHurt);
	CreateTimer(GetConVarFloat(g_cvarTrace), timerStopFire, pack, TIMER_FLAG_NO_MAPCHANGE);
	
	decl Float:survivorPos[3], Float:traceVec[3], Float:resultingFling[3], Float:currentVelVec[3];
	for(new i=1; i<=MaxClients; i++)
	{
		if(!IsClientInGame(i) || !IsPlayerAlive(i) || GetClientTeam(i) != 2)
		{
			continue;
		}

		GetEntPropVector(i, Prop_Data, "m_vecOrigin", survivorPos);
		if(GetVectorDistance(carPos, survivorPos) <= flMxDistance)
		{
			MakeVectorFromPoints(carPos, survivorPos, traceVec);				// draw a line from car to Survivor
			GetVectorAngles(traceVec, resultingFling);							// get the angles of that line
			
			resultingFling[0] = Cosine(DegToRad(resultingFling[1])) * power;	// use trigonometric magic
			resultingFling[1] = Sine(DegToRad(resultingFling[1])) * power;
			resultingFling[2] = power;
			
			GetEntPropVector(i, Prop_Data, "m_vecVelocity", currentVelVec);		// add whatever the Survivor had before
			resultingFling[0] += currentVelVec[0];
			resultingFling[1] += currentVelVec[1];
			resultingFling[2] += currentVelVec[2];
			
			FlingPlayer(i, resultingFling, i);
		}
	}
}

public Action:timerStopFire(Handle:timer, Handle:pack)
{
	ResetPack(pack);
	new particle = ReadPackCell(pack);
	new hurt = ReadPackCell(pack);
	CloseHandle(pack);
	
	if(IsValidEntity(particle))
	{
		AcceptEntityInput(particle, "Stop");
	}
	if(IsValidEntity(hurt))
	{
		AcceptEntityInput(hurt, "TurnOff");
	}
}

public Action:timerDeleteParticles(Handle:timer, Handle:pack)
{
	ResetPack(pack);
	
	new entity;
	for (new i = 1; i <= 7; i++)
	{
		entity = ReadPackCell(pack);
		
		if(IsValidEntity(entity))
		{
			AcceptEntityInput(entity, "Kill");
		}
	}
	CloseHandle(pack);
}

stock FlingPlayer(target, Float:vector[3], attacker, Float:stunTime = 3.0)
{
	SDKCall(sdkCallPushPlayer, target, vector, 76, attacker, stunTime);
}

stock PrecacheParticle(const String:ParticleName[])
{
	new Particle = CreateEntityByName("info_particle_system");
	if(IsValidEntity(Particle) && IsValidEdict(Particle))
	{
		DispatchKeyValue(Particle, "effect_name", ParticleName);
		DispatchSpawn(Particle);
		ActivateEntity(Particle);
		AcceptEntityInput(Particle, "start");
		CreateTimer(0.3, timerRemovePrecacheParticle, Particle, TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action:timerRemovePrecacheParticle(Handle:timer, any:Particle)
{
	if(IsValidEdict(Particle))
	{
		AcceptEntityInput(Particle, "Kill");
	}
}

stock AttachParticle(car, const String:Particle_Name[])
{
	decl Float:carPos[3], String:sName[64], String:sTargetName[64];
	new Particle = CreateEntityByName("info_particle_system");
	if(g_iParticle[car] > 0 && IsValidEntity(g_iParticle[car]))
	{
		AcceptEntityInput(g_iParticle[car], "Kill");
		g_iParticle[car] = -1;
	}
	g_iParticle[car] = Particle;
	GetEntPropVector(car, Prop_Data, "m_vecOrigin", carPos);
	TeleportEntity(Particle, carPos, NULL_VECTOR, NULL_VECTOR);
	DispatchKeyValue(Particle, "effect_name", Particle_Name);
	
	new userid = car;
	Format(sName, sizeof(sName), "%d", userid+25);
	DispatchKeyValue(car, "targetname", sName);
	GetEntPropString(car, Prop_Data, "m_iName", sName, sizeof(sName));
	
	Format(sTargetName, sizeof(sTargetName), "%d", userid+1000);
	DispatchKeyValue(Particle, "targetname", sTargetName);
	DispatchKeyValue(Particle, "parentname", sName);
	DispatchSpawn(Particle);
	DispatchSpawn(Particle);
	SetVariantString(sName);
	AcceptEntityInput(Particle, "SetParent", Particle, Particle);
	ActivateEntity(Particle);
	AcceptEntityInput(Particle, "start");
}

stock PanicEvent()
{
	new Director = CreateEntityByName("info_director");
	DispatchSpawn(Director);
	AcceptEntityInput(Director, "ForcePanicEvent");
	AcceptEntityInput(Director, "Kill");
}

stock DebugPrintToAll(const String:format[], any:...)
{
	#if (TEST_DEBUG || TEST_DEBUG_LOG)
	decl String:buffer[256];
	
	VFormat(buffer, sizeof(buffer), format, 2);
	
	#if TEST_DEBUG
	PrintToChatAll("[EC] %s", buffer);
	PrintToConsole(0, "[EC] %s", buffer);
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