#include "spawn.qh"

#include "parms.qh"
#include "../quests/rq_npcs.qh"
#include "../stats/stats.qh"
#include "../subs/_mod.qh"

// Player Starts
spawnfunc(info_player_start) 
{
	this.solid = SOLID_TRIGGER;
	set_movetype(this, MOVETYPE_TOSS);
	setsize(this, VEC_HULL_MIN, VEC_HULL_MAX);
	if(RequirementsMet(this, NULL))
		rq_spawnnpc(this);

	IL_PUSH(g_spawnpoints, this);
}

entity find_spawn(entity this)
{
	entity spawn_spot = find(NULL, classname, "info_player_start");
	if(cvar("developer") && spawn_spot)
		return spawn_spot;
	while(spawn_spot && (!RequirementsMet(spawn_spot, this) || spawn_spot.worldtype == 0))
	{
		spawn_spot = find(spawn_spot, classname, "info_player_start");
	}
	if(!spawn_spot)
	{
		// 0 should accept all, but should only be used as a last resort
		spawn_spot = find(NULL, classname, "info_player_start");
		while(spawn_spot && ((spawn_spot.worldtype != 0)))
			spawn_spot = find(spawn_spot, classname, "info_player_start");

	}
	if(spawn_spot)
	{
		if(spawn_spot.target)
			Trigger(spawn_spot, this, this, 0);

		tracebox(spawn_spot.origin, spawn_spot.mins, spawn_spot.maxs, spawn_spot.origin, MOVE_NOMONSTERS, spawn_spot);
		if(trace_startsolid)
		{
			spawn_spot = find_spot(spawn_spot);
			spawn_spot.angles = this.angles;
			setthink(spawn_spot, SUB_Remove);
			spawn_spot.nextthink = time;
		}
	}
	else
		error("No valid starts. Coming from the correct map?");
	return spawn_spot;
}

void ClientSpawn(entity this)
{
	entity spawn_spot = find_spawn(this);

	setorigin(this, spawn_spot.origin);
	this.testorg = this.origin;
	this.rotang = spawn_spot.angles + '0 90 0';
	this.altaction = SP_FIGHT_MELEE;
	if(!this.rotang_x)
		this.rotang_x = 60;
	if(!this.rotang_z)
		this.rotang_z = 194;
		
	if(!this.player)
		this.player = spawn();
	this.player.angles = spawn_spot.angles;
	this.player.owner = this;
	this.leftarm = this.rightarm = IV_NULL;
	_setmodel(this.player, "progs/human.mdl");
	this.player.solid = SOLID_SLIDEBOX;
	set_movetype(this.player, MOVETYPE_STEP);
	setsize(this.player, VEC_HULL_MIN, VEC_HULL_MAX);
	this.player.classname = "dummy";
	this.player.effects = EF_SELECTABLE;
	
	setthink(this.player, AnimatePlayer);
	this.player.nextthink = time;
	//CSQCMODEL_AUTOINIT(this.player);
	this.player.use = playertrigger;
	this.player.targetname = "player";
	this.player.takedamage = DAMAGE_AIM;
	this.takedamage = DAMAGE_AIM;
	this.player.noise = "player/swing.wav";
	this.player.noise1 = "player/step1.wav";
	this.player.noise2 = "player/step2.wav";
	this.player.noise3 = "player/axhit1.wav";
	this.player.noise4 = "player/death1.wav";
	this.player.die = PlayerDie;
	this.player.speed = 1;
	this.player.player = this.player;
	setorigin(this.player, spawn_spot.origin + '0 0 1');
	set_frames(this.player);
	this.player.colormap = this.colormap;
	if(this.misc & MISC_RESPAWN)
	{
		this.misc -= MISC_RESPAWN;	
		Unstat(this);
		Restat(this);
	}
	else
	{
		DecodeLevelParms(this);
		averagelvl += this.lvl;
	}
}

void prydon_PutClientInServer(entity this) 
{
	if(world.map)
	{
		DecodeLevelParms(this);
		if(!mplayer)
			localcmd("v_cshift 0 0 0 0\n");
		return;
	}
	this.gotstuff = time + 0.1;

	this.classname = STR_PLAYER;
	this.solid = SOLID_NOT;
	set_movetype(this, MOVETYPE_NOCLIP);
	this.flags = FL_CLIENT;
	if(!this.health)
		this.health = 1;
	
	_setmodel(this, "progs/null.spr");
	this.weapon = 0;
	this.items = 0;
	this.owner = this;
	this.weaponframe = 0;
	this.view_ofs = '0 0 0';
	this.velocity = '0 0 0';
	this.quest_time = 0;
	setsize(this, '0 0 0', '0 0 0');
	this.effects = EF_FULLBRIGHT;

	if(secure)
	{
		if(this.authed >= AUTH_YES)
			ClientSpawn(this);
		else
		{
			entity e = find_spawn(this);
			setorigin(this, e.origin + '0 0 22');
			this.testorg = this.origin;
		}
	}
	else
		ClientSpawn(this);
}
