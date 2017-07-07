/* Items QuickC program
	By Jim Dose'  9/13/96
	Copyright (c)1996 Hipnotic Interactive, Inc.
	All rights reserved.
	Distributed (unsupported) on 3.12.97
*/

const int UNDERWATER = BIT(1);

/*
===============================================================================

HIPNOTIC ITEMS

===============================================================================
*/
//
// hip_powerup_touch function
//
void hip_powerup_touch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher))
		return;
	if(toucher.health <= 0)
		return;

	sprint(toucher, sprintf("You got the %s\n", this.netname));

	if(deathmatch)
	{
		this.mdl = this.model;

//      if((this.classname == "item_artifact_invulnerability") ||
//         (this.classname == "item_artifact_invisibility"))
//         this.nextthink = time + 60*5;
//      else
		this.nextthink = time + 60;

		setthink(this, SUB_regen);
	}

	_sound(toucher, CHAN_VOICE, this.noise, 1, ATTN_NORM);
	stuffcmd(toucher, "bf\n");
	this.solid = SOLID_NOT;
	toucher.items |= this.items;
	this.model = string_null;

// do the apropriate action
	if(this.classname == "item_artifact_wetsuit")
	{
		toucher.wetsuit_time = 1;
		toucher.wetsuit_finished = time + 30;
	}
	if(this.classname == "item_artifact_empathy_shields")
	{
		toucher.empathy_time = 1;
		toucher.empathy_finished = time + 30;
	}

	SUB_UseTargets(this, toucher, toucher); // fire all targets / killtargets
}


/*QUAKED item_artifact_wetsuit (0 .5 .8) (-16 -16 -24) (16 16 32)
Player takes no damage from electrical attacks and swims faster for 30 seconds
*/
spawnfunc(item_artifact_wetsuit)
{
	settouch(this, hip_powerup_touch);

	precache_model("progs/wetsuit.mdl");
	precache_sound("misc/wetsuit.wav");
	precache_sound("misc/weton.wav");
	precache_sound("items/suit2.wav");
	this.noise = "misc/weton.wav";
	_setmodel(this, "progs/wetsuit.mdl");
	this.netname = "Wetsuit";
	this.items = HIP_IT_WETSUIT;
	setsize(this, '-16 -16 -24', '16 16 32');

	StartItem(this);
}

/*
===============================================================================
//
// Horn of Conjuring
//
===============================================================================
*/

void horn_touch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher))
		return;

	if(deathmatch)
	{
		this.mdl = this.model;

		this.nextthink = time + 60;
		setthink(this, SUB_regen);
	}

	this.solid = SOLID_NOT;
	this.model = string_null;
	sprint(toucher, "You got the Horn of Conjuring\n");
	_sound(toucher, CHAN_VOICE, this.noise, 1, ATTN_NONE);
	stuffcmd(toucher, "bf\n");
	horn_active = 1;
	horn_charmer = toucher;
	SUB_UseTargets(this, toucher, toucher); // fire all targets / killtargets
	horn_active = 0;
}

/*QUAKED item_hornofconjuring (0 .5 .8) (-16 -16 0) (16 16 32)
Horn of Conjuring.
You must make func_spawn entities connected to this entity
to spawn the charmed creature.
*/
spawnfunc(item_hornofconjuring)
{
	settouch(this, horn_touch);

	precache_model("progs/horn.mdl");
	precache_sound("hipitems/horn.wav");
	_setmodel(this, "progs/horn.mdl");
	this.noise = "hipitems/horn.wav";
	setsize(this, '-16 -16 0', '16 16 32');
	StartItem(this);
}

/*QUAKED item_artifact_empathy_shields (0 .5 .8) (-16 -16 0) (16 16 32)
Empathy Shield.
*/
spawnfunc(item_artifact_empathy_shields)
{
	settouch(this, hip_powerup_touch);

	precache_model("progs/empathy.mdl");
	precache_sound("hipitems/empathy.wav");
	precache_sound("hipitems/empathy2.wav");
	precache_sound("items/suit2.wav");
	_setmodel(this, "progs/empathy.mdl");
	this.noise = "hipitems/empathy.wav";
	this.netname = "Empathy Shields";
	this.items = HIP_IT_EMPATHY_SHIELDS;
	setsize(this, '-16 -16 0', '16 16 32');
	StartItem(this);
}
/*
===============================================================================

HIPNOTIC WEAPONS

===============================================================================
*/

/*QUAKED weapon_mjolnir (0 .5 .8) (-16 -16 0) (16 16 32)
*/

spawnfunc(weapon_mjolnir)
{
	precache_model ("progs/g_hammer.mdl");
	_setmodel(this, "progs/g_hammer.mdl");
	this.weapon = WEP_MJOLNIR;
	this.netname = "Mjolnir";
	//this.weapons = WEP_MJOLNIR;
	settouch(this, weapon_touch);
	setcefc(this, weapon_customize);
	setsize(this, '-16 -16 0', '16 16 56');
	StartItem(this);
}

/*QUAKED weapon_laser_gun (0 .5 .8) (-16 -16 0) (16 16 32)
*/

spawnfunc(weapon_laser_gun)
{
	precache_model ("progs/g_laserg.mdl");
	_setmodel(this, "progs/g_laserg.mdl");
	this.weapon = WEP_LASER_CANNON;
	this.netname = "Laser Cannon";
	//this.weapons = WEP_LASER_CANNON;
	settouch(this, weapon_touch);
	setcefc(this, weapon_customize);
	setsize(this, '-16 -16 0', '16 16 56');
	StartItem(this);
}

/*QUAKED weapon_proximity_gun (0 .5 .8) (-16 -16 0) (16 16 32)
*/

spawnfunc(weapon_proximity_gun)
{
	precache_model ("progs/g_prox.mdl");
	_setmodel(this, "progs/g_prox.mdl");
	this.weapon = WEP_PROXIMITY_GUN;
	this.netname = "Proximity Gun";
	//this.weapons = WEP_PROXIMITY_GUN;
	settouch(this, weapon_touch);
	setcefc(this, weapon_customize);
	setsize(this, '-16 -16 0', '16 16 56');
	StartItem(this);
}

/*
===============================================================================

HIPNOTIC HAZARDS

===============================================================================
*/

void spikemine_Home(entity this)
{
	this.frame = this.frame + 1;
	if(this.frame == 9) this.frame = 0;
	this.nextthink = time + 0.2;
	setthink(this, spikemine_Home);

// look in our immediate vicinity

	if(this.search_time < time)
	{
		entity selected = NULL;
		float cur_dist = 2000;
		entity head = findradius(this.origin, 2000);
		while(head)
		{
			if(!(head.flags & FL_NOTARGET) && IS_CLIENT(head))
			{
				if(visible(this, head) && (head.health > 0))
				{
					float head_dist = vlen(head.origin-this.origin);
					if(head_dist < cur_dist)
					{
						selected = head;
						cur_dist = head_dist;
					}
				}
			}
			head = head.chain;
		}
//      if(selected != NULL && selected != this.enemy)
		if(selected != NULL)
			_sound(this, CHAN_VOICE, "hipitems/spikmine.wav", 1, ATTN_NORM);
		this.enemy = selected;
		this.search_time = time + 1.3;
		}
	if(this.enemy == NULL)
	{
		_sound(this, CHAN_VOICE, "misc/null.wav", 1, ATTN_NORM);
		this.velocity = '0 0 0';
		return;
	}
	vector vtemp = this.enemy.origin + '0 0 10';
	vector dir = normalize(vtemp - this.origin);
	if(infront(this, this.enemy))
		this.velocity = dir * ((skill*50) + 50);
	else
		this.velocity = dir * ((skill*50) + 150);
}

void spikemine_Touch(entity this, entity toucher)
{
	if(this.health > 0)
	{
		if(toucher.classname == "trap_spike_mine")
			return;
		if(toucher.classname == "missile")
			return;
		if(toucher.classname == "grenade")
			return;
		if(toucher.classname == "hiplaser")
			return;
		if(toucher.classname == "proximity_grenade")
			return;

		T_Damage(this,this,this,this.health+10);
//      killed_monsters = killed_monsters + 1;
//      WriteByte (MSG_ALL, SVC_KILLEDMONSTER);
	}
//   this.effects = this.effects | EF_MUZZLEFLASH;

	T_RadiusDamage (this, this, 110, NULL);
	_sound(this, CHAN_WEAPON, "weapons/r_exp3.wav", 1, ATTN_NORM);

	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord(MSG_BROADCAST, this.origin_x);
	WriteCoord(MSG_BROADCAST, this.origin_y);
	WriteCoord(MSG_BROADCAST, this.origin_z);

	_sound(this, CHAN_VOICE, "misc/null.wav", 1, ATTN_NORM);
	this.velocity = '0 0 0';
	settouch(this, func_null);
	_setmodel(this, "progs/s_explod.spr");
	this.solid = SOLID_NOT;
	s_explode1(this);
}

/*
spike_mine_first_think
*/

void spike_mine_first_think(entity this)
{
	setthink(this, spikemine_Home);
	this.nextthink = time + 0.1;
	this.search_time = 0;
	this.takedamage = DAMAGE_AIM;
	this.use = monster_use;
}

/*QUAKED trap_spike_mine (0 .5 .8) (-16 -16 0) (16 16 32)
*/

spawnfunc(trap_spike_mine)
{
	if(deathmatch) { delete(this); return; }

	precache_model ("progs/spikmine.mdl");
	precache_sound("weapons/r_exp3.wav");
	precache_sound("hipitems/spikmine.wav");
	precache_sound("misc/null.wav");
	_setmodel(this, "progs/spikmine.mdl");
//   _setmodel(this, "progs/spike.mdl");
	setsize(this, this.mins, this.maxs);
	this.classname = "trap_spike_mine";
	this.solid = SOLID_BBOX;
	set_movetype(this, MOVETYPE_FLYMISSILE);
//   setsize(this, '0 0 0', '0 0 0');
//   this.avelocity = '-100 100 -100';
	this.avelocity = '-50 100 150';
	if(cvar("skill") <= 1)
		this.health = 200;
	else
		this.health = 400;
	this.frame = 0;
	setthink(this, spike_mine_first_think);
	settouch(this, spikemine_Touch);
	this.th_die = spikemine_Touch;
	this.th_stand = spikemine_Home;
	this.th_walk = spikemine_Home;
	this.th_run = spikemine_Home;
	this.th_melee = spikemine_Home;
	this.th_missile = spikemine_Home;
	this.nextthink = time + 0.2;
	total_monsters += 1;
	this.flags |= FL_MONSTER;
	this.deathtype = "was blasted by a spike mine";
}

//============================================================================
const int LIGHTNING_RANDOM = BIT(0);
const int LIGHTNING_BOOM = BIT(1);

void SpawnLightningThink(entity this)
{
	if(time > this.delay)
	{
		delete(this);
		return;
	}
	setthink(this, SpawnLightningThink);
	if(checkclient(this))
	{
		WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte(MSG_BROADCAST, TE_LIGHTNING2);
		WriteEntity(MSG_BROADCAST, this);
		WriteCoord(MSG_BROADCAST, this.origin_x);
		WriteCoord(MSG_BROADCAST, this.origin_y);
		WriteCoord(MSG_BROADCAST, this.origin_z);
		WriteCoord(MSG_BROADCAST, this.oldorigin_x);
		WriteCoord(MSG_BROADCAST, this.oldorigin_y);
		WriteCoord(MSG_BROADCAST, this.oldorigin_z);
	}
	LightningDamage(this.origin, this.oldorigin, this.lastvictim, this.dmg);
	this.nextthink = time + 0.1;
}

void trap_lightning_use(entity this, entity actor, entity trigger)
{
	vector p1, p2;

	if(time >= this.pausetime)
	{
		if(this.spawnflags & LIGHTNING_BOOM)
			_sound(this, CHAN_AUTO, "weapons/lstart.wav", 1, ATTN_NORM);
		else
			_sound(this, CHAN_AUTO, "weapons/lhit.wav", 1, ATTN_NORM);
		if(this.classname == "trap_lightning_triggered")
			this.pausetime = time + 0.1;
	}
	if(this.target)
	{
		p1 = this.origin;
		p2 = this.enemy.origin;
	}
	else
	{
		makevectors (this.angles);
		this.movedir = v_forward;
		traceline (this.origin, this.origin + this.movedir*600, true, this);
		p1 = this.origin;
		p2 = trace_endpos;
	}
	// fix up both ends of the lightning
	// lightning bolts are 30 units long each
	vector dir = normalize( p2-p1 );
	float dst = vlen(p2-p1);
	dst = dst / 30.0;
	float remainder = dst - floor(dst);
	if(remainder > 0)
	{
		remainder = remainder - 1;
		// split half the remainder with the front and back
		remainder = remainder * 15;
		p1 = p1 + (remainder*dir);
		p2 = p2 - (remainder*dir);
	}
	if(this.duration > 0.1)
	{
		entity ltning = spawn();
		ltning.origin = p1;
		ltning.oldorigin = p2;
		ltning.lastvictim = this;
		ltning.dmg = this.dmg;
		ltning.delay = time + this.duration;
		SpawnLightningThink(ltning);
	}
	else if(checkclient(this))
	{
		WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte(MSG_BROADCAST, TE_LIGHTNING2);
		WriteEntity(MSG_BROADCAST, this);
		WriteCoord(MSG_BROADCAST, p1_x);
		WriteCoord(MSG_BROADCAST, p1_y);
		WriteCoord(MSG_BROADCAST, p1_z);
		WriteCoord(MSG_BROADCAST, p2_x);
		WriteCoord(MSG_BROADCAST, p2_y);
		WriteCoord(MSG_BROADCAST, p2_z);
		LightningDamage(p1, p2, this, this.dmg);
	}
	else
		LightningDamage(p1, p2, this, this.dmg);
}

void lightning_think(entity this)
{
	float timedelay;

	if(this.state)
		trap_lightning_use(this, NULL, NULL);

	if(this.cnt == 0)
	{
		if(this.spawnflags & LIGHTNING_RANDOM)
			timedelay = this.wait * random();
		else
			timedelay = this.wait;

		this.cnt = 1;
		this.t_length = time + this.duration - 0.1;
		this.pausetime = time + this.duration - 0.1;
		if(this.pausetime  < time + 0.3)
			this.pausetime = time + 0.3;
		if(timedelay < this.duration)
			timedelay = this.duration;
		this.t_width = time + timedelay;
	}
	if(time >= this.t_length)
	{
		this.cnt = 0;
		this.nextthink = this.t_width;
	}
	else
		this.nextthink = time + 0.2;
}

void lightning_firstthink(entity this)
{
	if(this.target)
	{
		entity targ = find(NULL,targetname,this.target);
		this.dest = targ.origin;
		this.enemy = targ;
	}
	setthink(this, func_null);
	this.nextthink = 0;
	if(this.classname != "trap_lightning_triggered")
	{
		this.nextthink = this.huntingcharmer + this.wait + this.ltime;
		setthink(this, lightning_think);
	}
}

/*QUAKED trap_lightning_triggered (0 .5 .8) (-8 -8 -8) (8 8 8) random boom
When triggered, fires lightning in the direction set in QuakeEd.
"wait" how long to wait between blasts (1.0 default)
		 if in random mode wait is multiplied by random
"dmg" how much damage lightning should inflict (30 default)
"duration" how long each lightning attack should last (0.1 default)
*/

spawnfunc(trap_lightning_triggered)
{
	if(this.wait == 0)
		this.wait = 1.0;
	if(this.dmg == 0)
		this.dmg = 30;
	if(this.duration == 0)
		this.duration = 0.1;
	this.cnt = 0;
	this.use = trap_lightning_use;
	precache_sound("weapons/lhit.wav");
	precache_sound("weapons/lstart.wav");
	this.huntingcharmer = this.nextthink;
	setthink(this, lightning_firstthink);
	this.nextthink = time + 0.25;
	this.deathtype = "is electrocuted";
}


/*QUAKED trap_lightning (0 .5 .8) (-8 -8 -8) (8 8 8) random boom
Continuously fire lightning.
"wait" how long to wait between blasts (1.0 default)
		 if in random mode wait is multiplied by random
"nextthink" delay before firing first lightning, so multiple traps can be stagered.
"dmg" how much damage lightning should inflict (30 default)
"duration" how long each lightning attack should last (0.1 default)
*/
spawnfunc(trap_lightning)
{
	spawnfunc_trap_lightning_triggered(this);
	this.state = 1;
}

void trap_lightning_switched_use(entity this, entity actor, entity trigger)
{
	this.state = 1 - this.state;
	if(this.state == 1)
		this.nextthink = this.huntingcharmer;
}
/*QUAKED trap_lightning_switched (0 .5 .8) (-8 -8 -8) (8 8 8) random boom
Continuously fires lightning.
"wait" how long to wait between blasts (1.0 default)
		 if in random mode wait is multiplied by random
"nextthink" delay before firing first lightning, so multiple traps can be stagered.
"dmg" how much damage lightning should inflict (30 default)
"duration" how long each lightning attack should last (0.1 default)
"state" 0 (default) initially off, 1 initially on.
*/
spawnfunc(trap_lightning_switched)
{
	spawnfunc_trap_lightning_triggered(this);
	this.use = trap_lightning_switched_use;
}


entity tesla_target;
float tesla_numtargets;
void trap_tesla_scan(entity this)
{
	entity prev = NULL;

// look in our immediate vicinity

	tesla_numtargets = 0;
	entity head = findradius(this.origin, this.distance);
	while(head)
	{
		if(!(head.flags & FL_NOTARGET) && (head.flags & this.cnt))
		{
			if(visible(this, head) && (head.health > 0) && (head.struck_by_mjolnir == 0))
			{
				if(tesla_numtargets == 0)
					tesla_target = head;
				else
					prev.next_ent = head;
				tesla_numtargets = tesla_numtargets + 1;
				prev = head;
				if(tesla_numtargets == this.count)
					return;
			}
		}
		head = head.chain;
	}
}

void TeslaLightningThink(entity this)
{
	this.owner.attack_state = 2;
	if(time > this.delay)
	{
		this.enemy.struck_by_mjolnir = 0;
		delete(this);
		return;
	}
	traceline(this.origin, this.enemy.origin, true, this);

	if(trace_fraction != 1.0 || this.enemy.health <= 0 || vdist(this.origin - this.enemy.origin, >, (this.distance + 10)))
	{
		this.enemy.struck_by_mjolnir = 0;
		delete(this);
		return;
	}
	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_LIGHTNING2);
	WriteEntity(MSG_BROADCAST, this);
	WriteCoord(MSG_BROADCAST, this.origin_x);
	WriteCoord(MSG_BROADCAST, this.origin_y);
	WriteCoord(MSG_BROADCAST, this.origin_z);
	WriteCoord(MSG_BROADCAST, trace_endpos_x);
	WriteCoord(MSG_BROADCAST, trace_endpos_y);
	WriteCoord(MSG_BROADCAST, trace_endpos_z);
	LightningDamage(this.origin, trace_endpos, this.lastvictim, this.dmg);
	this.nextthink = time + 0.1;
}

void SpawnTeslaLightning(entity this, entity targ)
{
	// spawn actual lightning
	entity lgt = spawn();
	if(this.duration>0)
		lgt.delay = time + this.duration;
	else
		lgt.delay = time + 9999;
	lgt.enemy = targ;
	targ.struck_by_mjolnir = 1;
	lgt.distance = this.distance;
	lgt.owner = this;
	lgt.lastvictim = this.lastvictim;
	lgt.dmg = this.dmg;
	lgt.origin = this.origin;
	setthink(lgt, TeslaLightningThink);
	lgt.nextthink = time;
	lgt.deathtype = this.deathtype;
}

void trap_tesla_think(entity this)
{
	if(this.state == 0)
	{
		this.nextthink = time + 0.25;
		return;
	}
	if(this.attack_state == 0)
	{
		setthink(this, trap_tesla_think);
		trap_tesla_scan(this);
		if(tesla_numtargets > 0)
		{
			if(this.wait > 0)
				_sound(this, CHAN_AUTO, "misc/tesla.wav", 1, ATTN_NORM);
			this.attack_state = 1;
			this.nextthink = time + this.wait;
			return;
		}
		this.nextthink = time + 0.25;
		if(this.delay > 0)
		{
			if(time > this.search_time)
				this.attack_state = 3;
		}
	}
	else if(this.attack_state == 1)
	{
		trap_tesla_scan(this);
		while(tesla_numtargets > 0)
		{
			_sound(this, CHAN_AUTO, "hipweap/mjolhit.wav", 1, ATTN_NORM);
			SpawnTeslaLightning (this, tesla_target);
			tesla_target = tesla_target.next_ent;
			tesla_numtargets = tesla_numtargets - 1;
		}
		this.attack_state = 2;
		this.nextthink = time + 1;
	}
	else if(this.attack_state == 2)
	{
		this.attack_state = 3;
		this.nextthink = time + 0.2;
	}
	else if(this.attack_state == 3)
	{
		this.attack_state = 0;
		this.nextthink = time + 0.1;
		if(this.classname == "trap_gods_wrath")
			this.nextthink = -1;
	}
}

/*QUAKED trap_tesla_coil (0 .5 .8) (-8 -8 -8) (8 8 8) targetenemies
targets enemies in vicinity and fires at them
"wait" how long build up should be (2 second default)
"dmg" how much damage lightning should inflict (2 + 5*skill default)
"duration" how long each lightning attack should last (continuous default)
"distance" how far the tesla coil should reach (600 default)
"state" on/off for the coil (0 default is off)
"count" number of people to target (2 default)
*/
spawnfunc(trap_tesla_coil)
{
	precache_sound("misc/tesla.wav");
	precache_sound("hipweap/mjolhit.wav");   // lightning sound
	if(this.wait == 0)
		this.wait = 2;
	if(this.dmg == 0)
		this.dmg = 2 + (5*cvar("skill"));
	if(this.duration == 0)
		this.duration = -1;
	if(this.distance == 0)
		this.distance = 600;
	if(this.spawnflags & 1)
		this.cnt = FL_CLIENT | FL_MONSTER;
	else
		this.cnt = FL_CLIENT;
	this.use = trap_lightning_switched_use;
	if(this.delay == 0)
		this.delay = -1;
	this.nextthink = time + random();
	setthink(this, trap_tesla_think);
	this.lastvictim = NULL;
	tesla_numtargets = 0;
	this.attack_state = 0;
	this.deathtype = "is electrocuted";
}

void trap_gods_wrath_use(entity this, entity actor, entity trigger)
{
	if(this.attack_state == 0)
	{
		this.search_time = time + this.delay;
		this.lastvictim = actor;
		trap_tesla_think(this);
	}
}

/*QUAKED trap_gods_wrath (0 .5 .8) (-8 -8 -8) (8 8 8) targetenemies
targets enemies in vicinity and fires at them
"dmg" how much damage lightning should inflict (5 default)
"duration" how long each lightning attack should last (continuous default)
"distance" how far god's wrath should reach (600 default)
"delay" how long to wait until god calms down
	this is only needed if no one is targetted (5 seconds default)
"count" number of people to target (2 default)
*/
spawnfunc(trap_gods_wrath)
{
	if(this.delay == 0)
		this.delay = 5;
	spawnfunc_trap_tesla_coil(this);
	this.wait = 0;
	this.state = 1;
	this.nextthink = -1;
	this.deathtype = "suffers the wrath of God";
//   this.attack_state = 1;
	this.use = trap_gods_wrath_use;
}

void trap_gravity_touch(entity this, entity toucher)
{
	if(this.attack_finished > time)
		return;

	if(toucher.takedamage)
	{
		T_Damage(toucher, this, this, this.dmg);
		this.attack_finished = time + 0.2;
	}
}

void trap_gravity_think(entity this)
{
	this.ltime = time;
	trap_tesla_scan(this);
	while (tesla_numtargets > 0)
	{
		vector delta = this.origin - tesla_target.origin;
		vector dir = normalize( delta );
		vector vel = dir * this.speed;
		if( ( tesla_target.wetsuit_finished > time ) &&
			( this.spawnflags & UNDERWATER ) )
		{
			vel = vel * 0.6;
		}

		tesla_target.velocity = tesla_target.velocity + vel;
		tesla_target = tesla_target.next_ent;
		tesla_numtargets = tesla_numtargets - 1;
	}
	this.nextthink = time + 0.1;
}

/*QUAKED trap_gravity_well (.8 .5 0) (-8 -8 -8) (8 8 8) targetenemies UNDERWATER
targets enemies in vicinity and draws them near, gibbing them on contact.

UNDERWATER cuts the pull in half for players wearing the wetsuit

"distance" how far the gravity well should reach (600 default)
"count" number of people to target (2 default)
"speed" is how strong the pull is. (210 default)
"dmg" is how much damage to do each touch. (10000 default)
*/
spawnfunc(trap_gravity_well)
{
	this.solid = SOLID_TRIGGER;
	set_movetype(this, MOVETYPE_NONE);
	setsize( this, '-16 -16 -16','16 16 16');
	if( this.dmg == 0 )
		this.dmg = 10000;
	if( this.speed == 0 )
		this.speed = 210;
	if(this.distance == 0)
		this.distance = 600;
	if(this.spawnflags & 1)
		this.cnt = FL_CLIENT | FL_MONSTER;
	else
		this.cnt = FL_CLIENT;

	this.attack_finished = 0;
	setthink(this, trap_gravity_think);
	settouch(this, trap_gravity_touch);
	this.lastvictim = NULL;
	tesla_numtargets = 0;
	this.nextthink = time + 0.1;
	this.ltime = time;
}
