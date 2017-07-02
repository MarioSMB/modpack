#include "combat.qh"

void logfrag(entity attacker, entity targ)
{
	// report?
}

// prototypes
void W_WeaponFrame(entity this);
void W_SetCurrentAmmo(entity this);
void player_pain(entity this, entity attacker, float damage);
void player_stand1(entity this);
void spawn_tfog(vector org);
void spawn_tdeath(vector org, entity death_owner);

int modelindex_eyes, modelindex_player;

/*
=============================================================================

				LEVEL CHANGING / INTERMISSION

=============================================================================
*/

string nextmap;

float intermission_exittime;

/*QUAKED info_intermission(1 0.5 0.5)(-16 -16 -16)(16 16 16)
This is the camera point for the intermission.
Use mangle instead of angle, so you can set pitch or roll as well as yaw.  'pitch roll yaw'
*/
spawnfunc(info_intermission)
{
	this.angles = this.mangle; // so C can get at it
}

void SetChangeParms(entity this)
{
	if(this.health <= 0)
	{
		SetNewParms();
		return;
	}

// remove items
	this.items &= ~(IT_KEY1 | IT_KEY2 | IT_INVISIBILITY | IT_INVULNERABILITY | IT_SUIT | IT_QUAD);

	this.health = bound(50, this.health, 100); // cap super health
	parm1 = this.items;
	parm2 = this.health;
	parm3 = this.armorvalue;
	parm4 = max(25, this.ammo_shells);
	parm5 = this.ammo_nails;
	parm6 = this.ammo_rockets;
	parm7 = this.ammo_cells;
	parm8 = this.weapon;
	parm9 = this.armortype * 100;
	parm10 = this.prevweapon;
}

void SetNewParms()
{
	parm1 = IT_SHOTGUN | IT_AXE;
	parm2 = 100;
	parm3 = 0;
	parm4 = 25;
	parm5 = 0;
	parm6 = 0;
	parm7 = 0;
	parm8 = IT_SHOTGUN;
	parm9 = 0;
	parm10 = IT_AXE;
}

void DecodeLevelParms(entity this)
{
	if(serverflags)
	{
		if(world.model == "maps/start.bsp")
			SetNewParms();		// take away all stuff on starting new episode
	}
	
	this.items = parm1;
	this.health = parm2;
	this.armorvalue = parm3;
	this.ammo_shells = parm4;
	this.ammo_nails = parm5;
	this.ammo_rockets = parm6;
	this.ammo_cells = parm7;
	this.weapon = parm8;
	this.armortype = parm9 * 0.01;
	this.prevweapon = parm10;
}

/*
============
FindIntermission

Returns the entity to view from
============
*/
entity FindIntermission(entity this)
{
// look for info_intermission first
	RandomSelection_Init();
	bool found = false;
	FOREACH_ENTITY_CLASS("info_intermission", true,
	{
		found = true;
		RandomSelection_AddEnt(it, 1, 1);
	});
	if(found)
		return RandomSelection_chosen_ent;

// then look for the start position
	entity spot = find(NULL, classname, "info_player_start");
	if(!spot)
		objerror(this, "FindIntermission: no spot");

	return spot;
}

void GotoNextMap()
{
	//ZOID: 12-13-96, samelevel is overloaded, only 1 works for same level
	if(autocvar_samelevel == 1)	// if samelevel is set, stay on same level
		changelevel(mapname);
	else
	{
		// configurable map lists, see if the current map exists as a
		// serverinfo/localinfo var
		string newmap = mapname;
		if(newmap != "")
			changelevel(newmap);
		else
			changelevel(nextmap);
	}
}

string getcdtrack(int numb);
void SendCDTrack(entity to, int numb)
{
	if(!to)
	{
		// TODO: doesn't support play/loop
		string thetrack = getcdtrack(numb);
		string tostuff = strcat("cd loop ", thetrack, "\n");
		FOREACH_CLIENT(IS_REAL_CLIENT(it),
		{
			stuffcmd(it, tostuff);
		});

		if(current_cdtrack)
			strunzone(current_cdtrack);
		current_cdtrack = strzone(thetrack);

		return;
	}

	stuffcmd(to, strcat("cd loop ", getcdtrack(numb), "\n"));
}

/*
============
IntermissionThink

When the player presses attack or jump, change to the next level
============
*/
void IntermissionThink(entity this)
{
	if(time < intermission_exittime)
		return;

	if(!this.button0 && !this.button1 && !this.button2)
		return;
	
	GotoNextMap();
}

/*
============
execute_changelevel

The global "nextmap" has been set previously.
Take the players to the intermission spot
============
*/
void execute_changelevel(entity this)
{
	intermission_running = 1;
	
// enforce a wait time before allowing changelevel
	intermission_exittime = time + 5;
	entity pos = FindIntermission(this);

	// play intermission music
#if 0
	WriteByte(MSG_ALL, SVC_CDTRACK);
	WriteByte(MSG_ALL, 3);
	//WriteByte(MSG_ALL, 3);
#else
	SendCDTrack(NULL, 3);
#endif

	WriteByte(MSG_ALL, SVC_INTERMISSION);
	/*WriteCoord(MSG_ALL, pos.origin_x);
	WriteCoord(MSG_ALL, pos.origin_y);
	WriteCoord(MSG_ALL, pos.origin_z);
	WriteAngle(MSG_ALL, pos.mangle_x);
	WriteAngle(MSG_ALL, pos.mangle_y);
	WriteAngle(MSG_ALL, pos.mangle_z);*/

	if(pos)
	{
		FOREACH_CLIENT(IS_PLAYER(it),
		{
			it.takedamage = DAMAGE_NO;
			it.solid = SOLID_NOT;
			set_movetype(it, MOVETYPE_NONE);
			//it.modelindex = 0;
			setmodel(it, MDL_Null);
			//it.clientcamera = pos;
		});
	};
}

.entity chlevel_targ;
void changelevel_touch(entity this, entity toucher)
{
	// simply don't react if a non-player triggers it
	if(!IS_PLAYER(toucher))
		return;

// if "noexit" is set, blow up the player trying to leave
//ZOID, 12-13-96, noexit isn't supported in QW.  Overload samelevel
//  if((cvar("noexit") == 1) || ((cvar("noexit") == 2) && (mapname != "start")))
	if((autocvar_samelevel == 2) || ((autocvar_samelevel == 3) && (mapname != "start")))
	{
		T_Damage(toucher, this, this, 50000);
		return;
	}

	toucher.chlevel_targ = this;

	int plnum = 0;
	int realplnum = 0;
	// let's not count bots
	FOREACH_CLIENT(IS_REAL_CLIENT(it),
	{
		++realplnum;
		if(it.chlevel_targ == this)
			++plnum;
	});
	float themin = min(1.0, this.count);
	if(plnum < ceil(realplnum * themin)) // 70% of players
		return;

	bprintf("%s exited the level\n", toucher.netname);
	
	nextmap = this.map;

	SUB_UseTargets(this, toucher, NULL);
	
	settouch(this, func_null);

// we can't move people right now, because touch functions are called
// in the middle of C movement code, so set a think time to do it
	setthink(this, execute_changelevel);
	this.nextthink = time + 0.1;
}

/*QUAKED trigger_changelevel(0.5 0.5 0.5) ? NO_INTERMISSION
When the player touches this, he gets sent to the map listed in the "map" variable.  Unless the NO_INTERMISSION flag is set, the view will go to the info_intermission spot and display stats.
*/
spawnfunc(trigger_changelevel)
{
	if(!this.map)
		objerror(this, "chagnelevel trigger doesn't have map");
	
	InitTrigger(this);
	settouch(this, changelevel_touch);
	if(!this.count) { this.count = 0.7; }
}


/*
=============================================================================

				PLAYER GAME EDGE FUNCTIONS

=============================================================================
*/

void set_suicide_frame(entity this);

// make a body que entry for the given ent so the ent can be
// respawned elsewhere
void CopyToBodyQue(entity ent)
{
	entity body = new(bodyque);
	body.angles = ent.angles;
	body.model = ent.model;
	body.modelindex = ent.modelindex;
	body.frame = ent.frame;
	body.colormap = ent.colormap;
	set_movetype(body, ent.move_movetype);
	body.velocity = ent.velocity;
	body.move_qcphysics = false; // not for clones
	body.flags = 0;
	setorigin(body, ent.origin);
	setsize(body, ent.mins, ent.maxs);

	if(coop)
	{
		setthink(body, SUB_Remove);
		body.nextthink = time + 10;
	}
}

// called by ClientKill and DeadThink
void respawn(entity this)
{
	// make a copy of the dead body for appearances sake
	CopyToBodyQue(this);
	// set default spawn parms
	SetNewParms();
	// respawn		
	PutClientInServer(this);
}


/*
============
ClientKill

Player entered the suicide command
============
*/
void ClientKill(entity this)
{
	bprintf("%s suicides\n", this.netname);
	set_suicide_frame(this);
	this.modelindex = modelindex_player;
	logfrag(this, this);
	this.frags = this.frags - 2;	// extra penalty
	respawn(this);
}

bool CheckSpawnPoint(vector v)
{
	return false;
}

/*
============
SelectSpawnPoint

Returns the entity to spawn at
============
*/
entity SelectSpawnPoint()
{
	int numspots = 0, totalspots = 0;

// testinfo_player_start is only found in regioned levels
	entity spot = find(NULL, classname, "testplayerstart");
	if(spot)
		return spot;
		
// choose a info_player_deathmatch point

// ok, find all spots that don't have players nearby

	entity spots = NULL;
	spot = find(NULL, classname, "info_player_deathmatch");       
	while(spot)
	{
		totalspots = totalspots + 1;

		entity thing = findradius(spot.origin, 84);
		int pcount = 0;               
		while(thing)
		{
			if(IS_PLAYER(thing))
				pcount = pcount + 1;                      
			thing = thing.chain;      
		}
		if(pcount == 0)
		{
			spot.goalentity = spots;
			spots = spot;
			numspots = numspots + 1;
		}

		// Get the next spot in the chain
		spot = find(spot, classname, "info_player_deathmatch");                
	}
	totalspots = totalspots - 1;
	if(!numspots)
	{
		// ack, they are all full, just pick one at random
//		bprint("Ackk! All spots are full. Selecting random spawn spot\n");
		totalspots = rint((random() * totalspots));
		spot = find(NULL, classname, "info_player_deathmatch");       
		while(totalspots > 0)
		{
			totalspots = totalspots - 1;
			spot = find(spot, classname, "info_player_deathmatch");
		}
		return spot;
	}
		
// We now have the number of spots available on the map in numspots

	// Generate a random number between 1 and numspots

	numspots = numspots - 1;
	
	numspots = rint((random() * numspots));

	spot = spots;
	while(numspots > 0)
	{
		spot = spot.goalentity;
		numspots = numspots - 1;
	}
	return spot;
}


/*
===========
PutClientInServer

called each time a player enters a new level
============
*/
void DecodeLevelParms(entity this);
void PlayerDie(entity this, entity attacker);

void PutClientInServer(entity this)
{
	if(IS_SPEC(this))
	{
		entity spot = SelectSpawnPoint();
		setorigin(this, spot.origin + '0 0 1');
		this.angles = vec2(spot.angles);
		this.fixangle = true;
		return;
	}

	this.classname = STR_PLAYER;
	this.health = 100;
	this.takedamage = DAMAGE_AIM;
	this.solid = SOLID_SLIDEBOX;
	set_movetype(this, MOVETYPE_WALK);
	this.show_hostile = 0;
	this.max_health = 100;
	this.flags = FL_CLIENT;
	this.air_finished = time + 12;
	this.dmg = 2;   		// initial water damage
	this.super_damage_finished = 0;
	this.radsuit_finished = 0;
	this.invisible_finished = 0;
	this.invincible_finished = 0;
	this.effects = EF_TELEPORT_BIT;
	this.invincible_time = 0;

	this.dphitcontentsmask = DPCONTENTS_BODY | DPCONTENTS_SOLID;
	if (autocvar_g_playerclip_collisions)
		this.dphitcontentsmask |= DPCONTENTS_PLAYERCLIP;

	DecodeLevelParms(this);
	
	W_SetCurrentAmmo(this);

	this.attack_finished = time;
	this.th_pain = player_pain;
	this.th_die = PlayerDie;
	
	this.deadflag = DEAD_NO;
// paustime is set by teleporters to keep the player from moving a while
	this.pausetime = 0;

	entity spot = SelectSpawnPoint();

	this.origin = spot.origin + '0 0 1';
	this.angles = vec2(spot.angles);
	this.fixangle = true;		// turn this way immediately

	//JIM
	// Clear out velocity so you're not launched into the air
	// when you respawn.
	this.velocity = '0 0 0';

// oh, this is a hack!
	_setmodel(this, "progs/eyes.mdl");
	modelindex_eyes = this.modelindex;

	_setmodel(this, "progs/player.mdl");
	modelindex_player = this.modelindex;

	setsize(this, VEC_HULL_MIN, VEC_HULL_MAX);
	
	this.view_ofs = '0 0 22';

	// Mod - Xian (May.20.97)
	// Bug where player would have velocity from their last kill
	this.velocity = '0 0 0';

	player_stand1(this);

	makevectors(this.angles);
	spawn_tfog(this.origin + v_forward*20);

	spawn_tdeath(this.origin, this);

	if(deathmatch == 4)
	{
		this.ammo_shells = 0;
		/*if(stof(infokey(world, "axe")) == 0)
		{
			this.ammo_nails = 255;
			this.ammo_shells = 255;
			this.ammo_rockets = 255;
			this.ammo_cells = 255;
			this.items |= IT_NAILGUN;
			this.items |= IT_SUPER_NAILGUN;
			this.items |= IT_SUPER_SHOTGUN;
			this.items |= IT_ROCKET_LAUNCHER;
//		this.items |= IT_GRENADE_LAUNCHER;
			this.items |= IT_LIGHTNING;
		}
		*/
		this.items &= ~(IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3);
		this.armorvalue = 200;
		this.armortype = 0.8;
		this.health = 250;
		this.items |= IT_INVULNERABILITY;
		this.invincible_time = 1;
		this.invincible_finished = time + 3;
	}

	if(deathmatch == 5)
	{
		this.ammo_nails = 80;
		this.ammo_shells = 30;
		this.ammo_rockets = 10;
		this.ammo_cells = 30;
		this.items |= IT_NAILGUN;
		this.items |= IT_SUPER_NAILGUN;
		this.items |= IT_SUPER_SHOTGUN;
		this.items |= IT_ROCKET_LAUNCHER;
		this.items |= IT_GRENADE_LAUNCHER;
		this.items |= IT_LIGHTNING;
		this.items &= ~(IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3);
		this.armorvalue = 200;
		this.armortype = 0.8;
		this.health = 200;
		this.items |= IT_INVULNERABILITY;
		this.invincible_time = 1;
		this.invincible_finished = time + 3;
	}
}


/*
=============================================================================

				QUAKED FUNCTIONS

=============================================================================
*/


/*QUAKED info_player_start(1 0 0)(-16 -16 -24)(16 16 24)
The normal starting point for a level.
*/
spawnfunc(info_player_start)
{
}


/*QUAKED info_player_start2(1 0 0)(-16 -16 -24)(16 16 24)
Only used on start map for the return point from an episode.
*/
spawnfunc(info_player_start2)
{
}


/*QUAKED info_player_deathmatch(1 0 1)(-16 -16 -24)(16 16 24)
potential spawning position for deathmatch games
*/
spawnfunc(info_player_deathmatch)
{
}

/*QUAKED info_player_coop(1 0 1)(-16 -16 -24)(16 16 24)
potential spawning position for coop games
*/
spawnfunc(info_player_coop)
{
}

/*
===============================================================================

RULES

===============================================================================
*/

/*
go to the next level for deathmatch
*/
void NextLevel()
{
	entity o = NULL;

	if(nextmap != "")
		return; // already done

	if(mapname == "start")
	{
		if(!autocvar_registered)
		{
			mapname = "e1m1";
		}
		else if(!(serverflags & BIT(0)))
		{
			mapname = "e1m1";
			serverflags |= BIT(0);
		}
		else if(!(serverflags & BIT(1)))
		{
			mapname = "e2m1";
			serverflags |= BIT(1);
		}
		else if(!(serverflags & BIT(2)))
		{
			mapname = "e3m1";
			serverflags |= BIT(2);
		}
		else if(!(serverflags & BIT(3)))
		{
			mapname = "e4m1";
			serverflags &= ~7;
		}

		o = spawn();
		o.map = mapname;
	}
	else
	{
		// find a trigger changelevel
		o = find(NULL, classname, "trigger_changelevel");

		// go back to same map if no trigger_changelevel
		if(!o || mapname == "start")
		{
			o = spawn();
			o.map = mapname;
		}
	}

	nextmap = o.map;
	
	if(o.nextthink < time)
	{
		setthink(o, execute_changelevel);
		o.nextthink = time + 0.1;
	}
}

//============================================================================

void PlayerDeathThink(entity this)
{
	if(IS_ONGROUND(this))
	{
		float forward = vlen(this.velocity);
		forward = forward - 20;
		if(forward <= 0)
			this.velocity = '0 0 0';
		else	
			this.velocity = forward * normalize(this.velocity);
	}

// wait for all buttons released
	if(this.deadflag == DEAD_DEAD)
	{
		if(this.button2 || this.button1 || this.button0)
			return;
		this.deadflag = DEAD_RESPAWNABLE;
		return;
	}

// wait for any button down
	if(!this.button2 && !this.button1 && !this.button0)
		return;

	this.button0 = 0;
	this.button1 = 0;
	this.button2 = 0;
	respawn(this);
}

/*
================
PlayerPreThink

Called every frame before physics are run
================
*/
.string netname_previous;
void PlayerPreThink(entity this)
{
	// Check for nameless players
	if(this.netname != this.netname_previous)
	{
		if(isInvisibleString(this.netname))
		{
			this.netname = strzone(sprintf("Player#%d", this.playerid));
			// stuffcmd(this, strcat("name ", this.netname, "\n")); // maybe?
		}
		if(autocvar_sv_eventlog) {
			GameLogEcho(strcat(":name:", ftos(this.playerid), ":", this.netname));
        }
		if(this.netname_previous) strunzone(this.netname_previous);
		this.netname_previous = strzone(this.netname);
	}

	this.disableclientprediction = ((intermission_running || this.deadflag != DEAD_NO) ? 1 : -1);

	if(intermission_running)
	{
		IntermissionThink(this);	// otherwise a button could be missed between
		return;					// the think tics
	}

	if(this.view_ofs == '0 0 0')
		return;		// intermission or finale

	//makevectors(this.v_angle);		// is this still used

	this.deathtype = "";

	if(this.deadflag >= DEAD_DEAD)
	{
		PlayerDeathThink(this);
		return;
	}

	if(this.deadflag == DEAD_DYING)
		return;	// dying, so do nothing

// teleporters can force a non-moving pause time	
	if(time < this.pausetime)
		this.velocity = '0 0 0';

	if(time > this.attack_finished && this.currentammo == 0 && this.weapon != IT_AXE)
		W_SwitchWeapon(this, W_BestWeapon(this, 0));
}
	
/*
================
CheckPowerups

Check for turning off powerups
================
*/
void CheckPowerups(entity this)
{
	if(this.health <= 0)
		return;

// invisibility
	if(this.invisible_finished)
	{
// sound and screen flash when items starts to run out
		if(this.invisible_sound < time)
		{
			_sound(this, CHAN_AUTO, "items/inv3.wav", 0.5, ATTN_IDLE);
			this.invisible_sound = time +((random() * 3) + 1);
		}


		if(this.invisible_finished < time + 3)
		{
			if(this.invisible_time == 1)
			{
				sprint(this, "Ring of Shadows magic is fading\n");
				stuffcmd(this, "bf\n");
				_sound(this, CHAN_AUTO, "items/inv2.wav", 1, ATTN_NORM);
				this.invisible_time = time + 1;
			}
			
			if(this.invisible_time < time)
			{
				this.invisible_time = time + 1;
				stuffcmd(this, "bf\n");
			}
		}

		if(this.invisible_finished < time)
		{	// just stopped
			this.items &= ~IT_INVISIBILITY;
			this.invisible_finished = 0;
			this.invisible_time = 0;
		}
		
	// use the eyes
		this.frame = 0;
		this.modelindex = modelindex_eyes;
	}
	else
		this.modelindex = modelindex_player;	// don't use eyes

// invincibility
	if(this.invincible_finished)
	{
// sound and screen flash when items starts to run out
		if(this.invincible_finished < time + 3)
		{
			if(this.invincible_time == 1)
			{
				sprint(this, "Protection is almost burned out\n");
				stuffcmd(this, "bf\n");
				_sound(this, CHAN_AUTO, "items/protect2.wav", 1, ATTN_NORM);
				this.invincible_time = time + 1;
			}
			
			if(this.invincible_time < time)
			{
				this.invincible_time = time + 1;
				stuffcmd(this, "bf\n");
			}
		}
		
		if(this.invincible_finished < time)
		{	// just stopped
			this.items &= ~IT_INVULNERABILITY;
			this.invincible_time = 0;
			this.invincible_finished = 0;
		}
		if(this.invincible_finished > time)
		{
			this.effects |= EF_DIMLIGHT;
			this.effects |= EF_RED;
		}
		else
		{
			this.effects &= ~EF_DIMLIGHT;
			this.effects &= ~EF_RED;
		}
	}

// super damage
	if(this.super_damage_finished)
	{
// sound and screen flash when items starts to run out

		if(this.super_damage_finished < time + 3)
		{
			if(this.super_time == 1)
			{
				if(deathmatch == 4)
					sprint(this, "OctaPower is wearing off\n");
				else
					sprint(this, "Quad Damage is wearing off\n");
				stuffcmd(this, "bf\n");
				_sound(this, CHAN_AUTO, "items/damage2.wav", 1, ATTN_NORM);
				this.super_time = time + 1;
			}
			
			if(this.super_time < time)
			{
				this.super_time = time + 1;
				stuffcmd(this, "bf\n");
			}
		}

		if(this.super_damage_finished < time)
		{	// just stopped
			this.items &= ~IT_QUAD;
			if(deathmatch == 4)
			{
				this.ammo_cells = 255;
				this.armorvalue = 1;
				this.armortype = 0.8;
				this.health = 100;
			}
			this.super_damage_finished = 0;
			this.super_time = 0;
		}
		if(this.super_damage_finished > time)
		{
			this.effects |= EF_DIMLIGHT;
			this.effects |= EF_RED;
		}
		else
		{
			this.effects &= ~EF_DIMLIGHT;
			this.effects &= ~EF_RED;
		}
	}	

// suit	
	if(this.radsuit_finished)
	{
		this.air_finished = time + 12;		// don't drown

// sound and screen flash when items starts to run out
		if(this.radsuit_finished < time + 3)
		{
			if(this.rad_time == 1)
			{
				sprint(this, "Air supply in Biosuit expiring\n");
				stuffcmd(this, "bf\n");
				_sound(this, CHAN_AUTO, "items/suit2.wav", 1, ATTN_NORM);
				this.rad_time = time + 1;
			}
			
			if(this.rad_time < time)
			{
				this.rad_time = time + 1;
				stuffcmd(this, "bf\n");
			}
		}

		if(this.radsuit_finished < time)
		{	// just stopped
			this.items &= ~IT_SUIT;
			this.rad_time = 0;
			this.radsuit_finished = 0;
		}
	}	

}

void Player_Physics(entity this)
{
	set_movetype(this, this.move_movetype);

	if(!this.move_qcphysics)
		return;

	if(!frametime && !this.pm_frametime)
		return;

	Movetype_Physics_NoMatchTicrate(this, this.pm_frametime, true);

	this.pm_frametime = 0;
}


/*
================
PlayerPostThink

Called every frame after physics are run
================
*/
void SpectatorThink(entity this);
void PlayerPostThink(entity this)
{
	Player_Physics(this);

	if(IS_SPEC(this))
	{
		SpectatorThink(this);
		CSQCMODEL_AUTOUPDATE(this);
		return;
	}

	if(this.view_ofs == '0 0 0')
	{
		CSQCMODEL_AUTOUPDATE(this);
		return;		// intermission or finale
	}
	if(this.deadflag == DEAD_NO)
	{
		// check to see if player landed and play landing sound	
		if((this.jump_flag < -300) && IS_ONGROUND(this) && (this.health > 0))
		{
			if(this.watertype == CONTENT_WATER)
				_sound(this, CHAN_BODY, "player/h2ojump.wav", 1, ATTN_NORM);
			else if(this.jump_flag < -650)
			{
				T_Damage(this, NULL, NULL, 5); 
				_sound(this, CHAN_VOICE, "player/land2.wav", 1, ATTN_NORM);
				this.deathtype = "falling";
			}
			else
				_sound(this, CHAN_VOICE, "player/land.wav", 1, ATTN_NORM);

			this.jump_flag = 0;
		}

		if(!IS_ONGROUND(this))
			this.jump_flag = this.velocity_z;

		CheckPowerups(this);

		W_WeaponFrame(this);
	}

	CSQCMODEL_AUTOUPDATE(this);
}

string getcdtrack(int numb)
{
	switch(numb)
	{
		default:
		case 1: return "track001";
		case 2: return "track002";
		case 3: return "track003";
		case 4: return "track004";
		case 5: return "track005";
		case 6: return "track006";
		case 7: return "track007";
		case 8: return "track008";
		case 9: return "track009";
		case 10: return "track010";
		case 11: return "track011";
	}

	return "track001"; // because gmqcc
}


/*
===========
ClientConnect

called when a player connects to a server
============
*/
void SpectatorConnect(entity this);
void ClientConnect(entity this)
{
	bprintf("%s entered the game\n", this.netname);

	static int playerid_last;
	this.playerid = ++playerid_last;

	this.flags |= FL_CLIENT;

	this.netname_previous = strzone(this.netname);

	this.disableclientprediction = -1;

	string thetrack = ((current_cdtrack) ? current_cdtrack : getcdtrack(world.sounds));
	stuffcmd(this, strcat("cd loop ", thetrack, "\n"));

	if(autocvar_sv_eventlog)
		GameLogEcho(strcat(":join:", ftos(this.playerid), ":", ftos(etof(this)), ":", this.netaddress, ":", this.netname));
	
// a client connecting during an intermission can cause problems
	if(intermission_running)
		GotoNextMap();

	CSQCMODEL_AUTOINIT(this);

	Physics_UpdateStats(this);

	if(IS_SPEC(this))
		SpectatorConnect(this);
}


/*
===========
ClientDisconnect

called when a player disconnects from a server
============
*/
void SpectatorDisconnect(entity this);
void ClientDisconnect(entity this)
{
	if(IS_SPEC(this))
	{
		SpectatorDisconnect(this);
		return;
	}

	// let everyone else know
	bprintf("%s left the game with %d frags\n", this.netname, this.frags);
	if(autocvar_sv_eventlog)
		GameLogEcho(strcat(":part:", ftos(this.playerid)));
	_sound(this, CHAN_BODY, "player/tornoff2.wav", 1, ATTN_NONE);
	set_suicide_frame(this);
}

/*
===========
ClientObituary

called when a player dies
============
*/
void ClientObituary(entity targ, entity attacker)
{
	string deathstring = "", deathstring2 = "";
	int attackerteam = attacker.team, targteam = targ.team;
	float rnum = random();

	if(IS_PLAYER(targ))
	{
		if(deathmatch > 3)
		{
			if(targ.deathtype == "selfwater")
			{
				bprintf("%s electrocutes themself\n", targ.netname);
				targ.frags = targ.frags - 1;
				return;
			}
		}
		if(attacker.classname == "teledeath")
		{
			bprintf("%s was telefragged by %s\n", targ.netname, attacker.owner.netname);
			logfrag(attacker.owner, targ);

			attacker.owner.frags = attacker.owner.frags + 1;
			return;
		}

		if(attacker.classname == "teledeath2")
		{
			bprintf("Satan's power deflects %s's telefrag\n", targ.netname);

			targ.frags = targ.frags - 1;
			logfrag(targ, targ);
			return;
		}

		// double 666 telefrag (can happen often in deathmatch 4)
		if(attacker.classname == "teledeath3")
		{
			bprintf("%s was telefragged by %s's Satan's power\n", targ.netname, attacker.owner.netname);
			targ.frags = targ.frags - 1;
			logfrag(targ, targ);
			return;
		}

		if(targ.deathtype == "squish")
		{
			if(teamplay && targteam == attackerteam && attackerteam && targ != attacker)
			{
				logfrag(attacker, attacker);
				attacker.frags = attacker.frags - 1;
				bprintf("%s squished teammate %s\n", attacker, targ);
				return;
			}
			else if(IS_PLAYER(attacker) && attacker != targ)
			{
				bprintf("%s squishes %s\n", attacker, targ);
				logfrag(attacker, targ);
				attacker.frags = attacker.frags + 1;
				return;
			}
			else
			{
				logfrag(targ, targ);
				targ.frags = targ.frags - 1; // killed self
				bprintf("%s was squished\n", targ.netname);
				return;
			}
		}

		if(IS_PLAYER(attacker))
		{
			if(targ == attacker)
			{
				// killed self
				logfrag(attacker, attacker);
				attacker.frags = attacker.frags - 1;
				bprint(targ.netname);
				if(targ.deathtype == "grenade")
					bprint(" tries to put the pin back in\n");
				else if(targ.deathtype == "rocket")
					bprint(" becomes bored with life\n");
				else if(targ.weapon == 64 && targ.waterlevel > 1)
				{
					if(targ.watertype == CONTENT_SLIME)
						bprint(" discharges into the slime\n");
					else if(targ.watertype == CONTENT_LAVA)
						bprint(" discharges into the lava\n");
					else
						bprint(" discharges into the water\n");
				}
				return;
			}
			else if((teamplay == 2) &&(targteam > 0)&&(targteam == attackerteam) && attackerteam)
			{
				if(rnum < 0.25)
					deathstring = " mows down a teammate\n";
				else if(rnum < 0.50)
					deathstring = " checks their glasses\n";
				else if(rnum < 0.75)
					deathstring = " gets a frag for the other team\n";
				else
					deathstring = " loses another friend\n";
				bprint(attacker.netname);
				bprint(deathstring);
				attacker.frags = attacker.frags - 1;
				//ZOID 12-13-96:  killing a teammate logs as suicide
				logfrag(attacker, attacker);
				return;
			}
			else
			{
				logfrag(attacker, targ);
				attacker.frags = attacker.frags + 1;

				rnum = attacker.weapon;
				if(targ.deathtype == "nail")
				{
					deathstring = " was nailed by ";
					deathstring2 = "\n";
				}
				else if(targ.deathtype == "supernail")
				{
					deathstring = " was punctured by ";
					deathstring2 = "\n";
				}
				else if(targ.deathtype == "grenade")
				{
					deathstring = " eats ";
					deathstring2 = "'s pineapple\n";
					if(targ.health < -40)
					{
						deathstring = " was gibbed by ";
						deathstring2 = "'s grenade\n";
					}
				}
				else if(targ.deathtype == "rocket")
				{
					if(attacker.super_damage_finished > 0 && targ.health < -40)
					{
						rnum = random();
						if(rnum < 0.3)
							deathstring = " was brutalized by ";
						else if(rnum < 0.6)
							deathstring = " was smeared by ";
						else
						{
							bprintf("%s rips %s a new one\n", attacker.netname, targ.netname);
							return;
						}
						deathstring2 = "'s quad rocket\n";
					}
					else
					{
						deathstring = " rides ";
						deathstring2 = "'s rocket\n";
						if(targ.health < -40)
						{
							deathstring = " was gibbed by ";
							deathstring2 = "'s rocket\n" ;
						}
					}
				}
				else if(rnum == IT_AXE)
				{
					deathstring = " was ax-murdered by ";
					deathstring2 = "\n";
				}
				else if(rnum == IT_SHOTGUN)
				{
					deathstring = " chewed on ";
					deathstring2 = "'s boomstick\n";
				}
				else if(rnum == IT_SUPER_SHOTGUN)
				{
					deathstring = " ate 2 loads of ";
					deathstring2 = "'s buckshot\n";
				}
				else if(rnum == IT_LIGHTNING)
				{
					deathstring = " accepts ";
					if(attacker.waterlevel > 1)
						deathstring2 = "'s discharge\n";
					else
						deathstring2 = "'s shaft\n";
				}
				bprint(targ.netname);
				bprint(deathstring);
				bprint(attacker.netname);
				bprint(deathstring2);
			}
			return;
		}
		else
		{
			logfrag(targ, targ);
			targ.frags = targ.frags - 1; // killed self
			rnum = targ.watertype;
			bprint(targ.netname);
			if(rnum == -3)
			{
				if(random() < 0.5)
					bprint(" sleeps with the fishes\n");
				else
					bprint(" sucks it down\n");
				return;
			}
			else if(rnum == -4)
			{
				if(random() < 0.5)
					bprint(" gulped a load of slime\n");
				else
					bprint(" can't exist on slime alone\n");
				return;
			}
			else if(rnum == -5)
			{
				if(targ.health < -15)
				{
					bprint(" burst into flames\n");
					return;
				}
				if(random() < 0.5)
					bprint(" turned into hot slag\n");
				else
					bprint(" visits the Volcano God\n");
				return;
			}

			if(attacker.classname == "explo_box")
			{
				bprint(" blew up\n");
				return;
			}
			if(targ.deathtype == "falling")
			{
				bprint(" fell to his death\n");
				return;
			}
			if(targ.deathtype == "nail" || targ.deathtype == "supernail")
			{
				bprint(" was spiked\n");
				return;
			}
			if(targ.deathtype == "laser")
			{
				bprint(" was zapped\n");
				return;
			}
			if(attacker.classname == "fireball")
			{
				bprint(" ate a lavaball\n");
				return;
			}
			if(attacker.classname == "trigger_changelevel")
			{
				bprint(" tried to leave\n");
				return;
			}

			bprint(" died\n");
		}
	}
}

int Say(entity source, int teamsay, entity privatesay, string msgin, bool floodcontrol);
void SV_ParseClientCommand(entity this, string command)
{
	// If invalid UTF-8, don't even parse it
	string command2 = "";
	float len = strlen(command);
	float i;
	for (i = 0; i < len; ++i)
		command2 = strcat(command2, chr2str(str2chr(command, i)));
	if(command != command2) return;

	float argc = tokenize_console(command);

	// Guide for working with argc arguments by example:
	// argc:   1    - 2      - 3     - 4
	// argv:   0    - 1      - 2     - 3
	// cmd     vote - master - login - password

	string cmd_name = strtolower(argv(0));

	// for floodcheck
	switch (cmd_name)
	{
		// exempt commands which are not subject to floodcheck
		case "begin": break;                               // handled by engine in host_cmd.c
		case "download": break;                            // handled by engine in cl_parse.c
		case "mv_getpicture": break;                       // handled by server in this file
		case "pause": break;                               // handled by engine in host_cmd.c
		case "prespawn": break;                            // handled by engine in host_cmd.c
		case "sentcvar": break;                            // handled by server in this file
		case "spawn": break;                               // handled by engine in host_cmd.c
		case "c2s": Net_ClientCommand(this, command); return; // handled by net.qh
	}

	if(cmd_name == "cvar_purechanges")
	{
		sprint(this, strcat(cvar_purechanges, "\n"));
		return;
	}

	if(cmd_name == "cvar_changes")
	{
		sprint(this, strcat(cvar_changes, "\n"));
		return;
	}

	if(cmd_name == "say" || cmd_name == "say_team")
	{
		if(argc >= 2) Say(this, false, NULL, substring(command, argv_start_index(1), argv_end_index(-1) - argv_start_index(1)), 1);
		return;
	}

	clientcommand(this, command);
}

void setcolor(entity this, int clr)
{
#if 0
	this.clientcolors = clr;
	this.team = (clr & 15) + 1;
#else
	builtin_setcolor(this, clr);
#endif
}

void SetPlayerColors(entity pl, float _color)
{
	/*string s;
	s = ftos(cl);
	stuffcmd(pl, strcat("color ", s, " ", s, "\n")  );
	pl.team = cl + 1;
	//pl.clientcolors = pl.clientcolors - (pl.clientcolors & 15) + cl;
	pl.clientcolors = 16*cl + cl;*/

	int pants = _color & 0x0F;
	int shirt = _color & 0xF0;

	setcolor(pl, shirt + pants);
}

void SV_ChangeTeam(entity this, float _color)
{
	SetPlayerColors(this, _color);

	if(!IS_CLIENT(this))
	{
		// since this is an engine function, and gamecode doesn't have any calls earlier than this, do the connecting message here
		bprintf("%s is connecting...\n", this.netname);
		return;
	}
}

/**
 * Determines whether the player is allowed to join. This depends on cvar
 * g_maxplayers, if it isn't used this function always return true, otherwise
 * it checks whether the number of currently playing players exceeds g_maxplayers.
 * @return int number of free slots for players, 0 if none
 */
int nJoinAllowed(entity this, entity ignore)
{
	// TODO simplify this
	int totalClients = 0;
	int currentlyPlaying = 0;
	FOREACH_CLIENT(true, LAMBDA(
		if(it != ignore)
			++totalClients;
		if(IS_REAL_CLIENT(it) && IS_PLAYER(it))
			++currentlyPlaying;
	));

	int free_slots = maxclients - totalClients;

	return free_slots;
}
