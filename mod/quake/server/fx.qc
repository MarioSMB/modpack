/*  Copyright (C) 1996-2022 id Software LLC

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

    See file, 'COPYING', for details.
*/

.float storednextthink;
.void(entity this) storedthink;

//============================================================================
// SCREENSHAKE
//============================================================================
const int SILENT_SHAKE = BIT(0);

void T_Shake(entity this)
{
	float hit;
	float starttime = this.storednextthink - this.wait;
	
	// early out if intermission is running
	if(intermission_running)
		return;
	
	// Completed, cleanup!
	if(time > this.storednextthink)
	{
		if(!(this.spawnflags & SILENT_SHAKE))
			_sound(this, CH_VOICE, this.noise1, 1, ATTN_NORM);

		FOREACH_CLIENT(IS_PLAYER(it),
		{
			it.v_angle_z = 0;
		});
		return;
	}
	
	// Ramp up? 
	if(time < this.delay)
		hit = (time - starttime) / (this.wait/3);
	else
		hit = 1;
	
	hit = this.dmg * hit;

	FOREACH_CLIENT(IS_PLAYER(it),
	{
		it.punchangle_x = random() * hit;
		it.punchangle_y = crandom() * hit;
		it.punchangle_z = random() * hit;
	});

	this.nextthink = time + 0.05;
}

void screenshake_use(entity this, entity actor, entity trigger)
{
	this.storednextthink = time + this.wait; // when to end
	this.delay = time + (this.wait / 3); // how long to ramp up
	
	if(!(this.spawnflags & SILENT_SHAKE))
		_sound(this, CH_VOICE, this.noise, 1, ATTN_NORM);

	setthink(this, T_Shake);
	this.nextthink = time + 0.05;
}

/*QUAKED trigger_screenshake

wait is duration of the shake
dmg is the intensity of the shake
*/
spawnfunc(trigger_screenshake)
{
	if(!MP_MG) { delete(this); return; }
	if(MP_MG && (Inhibit_Coop(this) || RemovedOutsideCoop(this)))
	{
		delete(this);
		return;
	}

	// wait is sustain time
	// dmg is intensity
	if(!(this.spawnflags & SILENT_SHAKE))
	{
		this.noise = "misc/quake.wav";
		this.noise1 = "misc/quakeend.wav";
		precache_sound(this.noise);
		precache_sound(this.noise1);
	}
	
	if(!this.wait) // no duration!
		this.wait = 2;
		
	if(!this.dmg) // no intensity!
		this.dmg = 3;

	this.use = screenshake_use;
}

//============================================================================
// SOUND TRIGGER
//============================================================================

void trigger_sound_play(entity this, entity actor, entity trigger)
{
	if(!this.noise || this.noise == "")
		return;
	
	_sound(this, CH_VOICE, this.noise, 1, ATTN_NORM);
}
/*QUAKED trigger_sound
*/
spawnfunc(trigger_sound) 
{
	if(!MP_MG) { delete(this); return; }
	if(!this.noise || this.noise == "")
		delete(this);
	
	precache_sound(this.noise);
	this.use = trigger_sound_play;
	
}

//============================================================================
// TRIGGER LIGHTNING
//============================================================================

const int LIGHTNING_RANDOM_TARGET = 1;
const int LIGHTNING_TRACE_BACKWARDS = 2;
const int LIGHTNING_NO_ACTIVATE_TARGET = 4;
const int LIGHTNING_TRIGGER_TARGETS_ONCE = 8;

void play_lightning(entity this, entity actor, entity trigger)
{
	if(!this.target || this.target == "")
	{
		LOG_DEBUG("lightning has no target!");
		return;
	}

	float rt = 0;
	if(this.spawnflags & LIGHTNING_RANDOM_TARGET)
	{
		int cnt = 0;
		FOREACH_ENTITY_STRING(targetname, this.target,
		{
			cnt += 1;
		});
		if(cnt == 0)
			return;
		rt = floor(cnt * random());
	}
	float triggertwice = (this.spawnflags & LIGHTNING_TRIGGER_TARGETS_ONCE) ? false : true; //Note boolean reversal
	float activatetargets = (this.spawnflags & LIGHTNING_NO_ACTIVATE_TARGET) ? false : true; //Note boolean reversal
	
	float i = 0;
	entity t = find(NULL, targetname, this.target);
	while(t)
	{
		if(this.spawnflags & LIGHTNING_RANDOM_TARGET)
		{
			if(i < rt){
				t = find(t, targetname, this.target);
				i++;
				continue;
			} 
			if(i > rt) return;
			i++;
		}

		vector endpos, startpos;
		if(this.spawnflags & LIGHTNING_TRACE_BACKWARDS)
		{
			traceline(t.origin, this.origin, true, this);
			endpos = trace_endpos;
			startpos = t.origin;
		}
		else
		{
			traceline(this.origin, t.origin, true, this);
			endpos = trace_endpos;
			startpos = this.origin;
		}
	
		
		_sound(t, CHAN_AUTO, this.noise, this.volume, ATTN_NORM); //Changed to CHAN_AUTO to allow more overlapping sounds

		// create the temp lightning entity
#if 0
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, this.style);
		WriteEntity (MSG_BROADCAST, t);
		WriteCoord (MSG_BROADCAST, startpos_x);
		WriteCoord (MSG_BROADCAST, startpos_y);
		WriteCoord (MSG_BROADCAST, startpos_z);
		WriteCoord (MSG_BROADCAST, endpos_x);
		WriteCoord (MSG_BROADCAST, endpos_y);
		WriteCoord (MSG_BROADCAST, endpos_z);
#endif
		// TODO: style not supported
		//te_lightning2(NULL, startpos, endpos);
		SendCSQCLightningBeam(startpos, endpos);

		if(this.dmg)
			LightningDamage(startpos, endpos, this, this.dmg, DEATH_TRAP.m_id);
		
		//If activatetargets and t has a target, activate it.
		if(activatetargets && t.target)
		{
			SUB_UseTargets(t, NULL, NULL);
			if(triggertwice)
			{
				float odelay = t.delay;
				t.delay = odelay + 0.2;
				SUB_UseTargets(t, NULL, NULL); //Quickly turn on and off
				t.delay = odelay;
			}
		}

		t = find(t, targetname, this.target);
	}
}

spawnfunc(trigger_lightning)
{
	if(!MP_MG) { delete(this); return; }
	if(!this.noise || this.noise == "")
		this.noise = "misc/power.wav";
	precache_sound(this.noise);
	this.use = play_lightning;

	// TODO
#if 0
	switch(this.style)
	{
		default:
		case 0:
			this.style = TE_LIGHTNING3;
			break;
		case 1:
			this.style = TE_LIGHTNING1;
			break;
		case 2:
			this.style = TE_LIGHTNING2;
			break;
	}
#endif

	if(!this.volume)
		this.volume = 1;
}

//============================================================================
// TRIGGER FADE
//============================================================================
/* Checks all targets to see if they are dead. If they are, then it starts a fade
*/
void SUB_FadeTargets(entity this)
{
	entity t;
	int count = 0; // how many entities are being faded
	
	if(this.target && this.target != "")
	{
		if(!this.state)
		{
			t = NULL;
			//Initialize all the targets with alpha = 1.0, so the fade out works.
			t = find(t, targetname, this.target);
			while (t)
			{
				t.alpha = 1.0;
				t = find(t, targetname, this.target);
			}
			this.state = 1; // Don't repeat this initialization after the first think.
		}

		t = NULL;
		t = find(t, targetname, this.target);
		while(t)
		{
			if(t.health <= 0)
			{	
				if(t.alpha > 0)
				{
					t.alpha = t.alpha - (frametime/this.delay);
					count = count + 1;
				}
				else
				{
					LOG_DEBUG("fade complete, removing ", t.classname);
					delete(t);
				}
			}
			else
			{
				LOG_DEBUG("target is still alive");
			}
			t = find(t, targetname, this.target);
		}
	}
	if(count > 0)
		this.nextthink = time;
	else
	{
		delete(this);
		LOG_DEBUG("removed fade manager");
	}
}

void spawn_fade_manager(entity this, entity actor, entity trigger)
{
	entity fademanager = new(fademanager); // TODO: new_pure? will need a think logic hook!
	LOG_DEBUG("spawn fade manager");
	setthink(fademanager, SUB_FadeTargets);
	fademanager.nextthink = time;
	fademanager.target = this.target;
	fademanager.delay = this.delay; // use delay to determine fade time, default to 1
}

spawnfunc(trigger_fade)
{
	if(!MP_MG) { delete(this); return; }
	if(MP_MG && (Inhibit_Coop(this) || RemovedOutsideCoop(this)))
	{
		delete(this);
		return;
	}

	this.use = spawn_fade_manager;
	
	if(!this.delay)
		this.delay = 1; // delay determines fade time
}

//============================================================================
// TRIGGER FREEZE
//============================================================================
// Yoder Jan 14 2021


void SUB_Freeze(entity this)
{
	this.storednextthink = this.nextthink;
	this.storedthink = getthink(this);
	this.nextthink = 0;
	setthink(this, func_null);
	this.is_frozen = true;
}

void SUB_Unfreeze(entity this)
{
	this.nextthink = this.storednextthink;
	setthink(this, this.storedthink);
	this.storednextthink = -1;
	this.storedthink = func_null;
	this.is_frozen = false;
}

void SUB_Unfreeze_use(entity this, entity actor, entity trigger)
{
	SUB_Unfreeze(this);
}

void SUB_FreezeTargets(entity this, entity actor, entity trigger)
{
	if(!this.target || this.target == "")
		return;

	FOREACH_ENTITY_STRING(targetname, this.target,
	{
		// freeze if not frozen, otherwise unfreeze
		// TODO? maybe this should only freeze unfrozen targets?
		if(it.is_frozen)
			SUB_Unfreeze(it);
		else
			SUB_Freeze(it);
	});
}

/* Define the entity, trigger_freeze
	Works like a trigger relay
*/
spawnfunc(trigger_freeze)
{
	if(!MP_MG) { delete(this); return; }
	if(MP_MG && (Inhibit_Coop(this) || RemovedOutsideCoop(this)))
	{
		delete(this);
		return;
	}
	
	this.use = SUB_FreezeTargets;
}

//============================================================================
// particle_embers
//============================================================================
void particle_embers_think(entity this)
{
	vector speed = '0 0 2' * random() + '0 0 2';
	speed.x = crandom() * this.velocity_x;
	speed.y = crandom() * this.velocity_y;
	speed.z = speed_z * this.velocity_z;
	vector pos = this.origin;
	pos.x = pos.x + this.size_x * crandom();
	pos.y = pos.y + this.size_y * crandom();
	//pos = crandom() * this.size + this.origin;
	particle(pos, speed, 234, 2);
	this.nextthink = time + this.wait + this.delay * random();
}

spawnfunc(particle_embers)
{
	if(!MP_MG) { delete(this); return; }
	// size determines the box the particles can spawn within
	if(!this.size)
		this.size = '128 128 0';
	// delay is random time added per loop
	if(!this.delay)
		this.delay = 0.1;
	
	// wait is time always added per loop
	if(!this.wait)
		this.wait = 0.05;
	
	// velocity is used as a scalar on speed
	if(!this.velocity)
		this.velocity = '1 1 1';
	
	setthink(this, particle_embers_think);
	this.nextthink = time + this.wait + this.delay * random();
}

spawnfunc(particle_embers_tall)
{
	if(!MP_MG) { delete(this); return; }
	if(!this.size)
		this.size = '40 40 0';
	if(!this.delay)
		this.delay = 0.1;
	if(!this.wait)
		this.wait = 0.05;
	if(!this.velocity) // scalar for speed
		this.velocity = '1 1 2';
	setthink(this, particle_embers_think);
	this.nextthink = time + this.wait + this.delay * random();
}

//============================================================================
// particle_tele
//============================================================================
void particle_tele_think(entity this)
{
	vector rando;
	rando.x = crandom() * 10;
	rando.y = crandom() * 10;
	rando.z = crandom() * 5;
	rando = normalize(rando);
	
	float dist = 64; // scalar from org, used for speed too
	
	vector pos = this.origin + (rando * dist);
	
	// spawn particle
	particle(pos, rando * dist * -.125, 3, 3);
	this.nextthink = time + this.wait + this.delay * random();
}


spawnfunc(particle_tele)
{
	if(!MP_MG) { delete(this); return; }
	/*
	1. get origin
	2. get a random vector, then normalize it. Save it for later
	3. scale a copy of the vector by distance
	4. spawn the particle at vector + origin
	5. set the particle's velocity to the old normalized vector * -scalar.
	*/
	// size determines the box the particles can spawn within
	if(!this.size)
		this.size = '128 128 0';
	// delay is random time added per loop
	if(!this.delay)
		this.delay = 0.1;
	
	// wait is time always added per loop
	if(!this.wait)
		this.wait = 0;
	
	setthink(this, particle_tele_think);
	this.nextthink = time + this.wait + this.delay * random();
}

void particle_tele_fountain_think(entity this)
{
	vector dir;
	dir.x = crandom() * this.velocity_x;
	dir.y = crandom() * this.velocity_y;
	dir.z = this.velocity_z;
	particle(this.origin, dir, 13, 2);
	this.nextthink = time + this.wait + this.delay * random();
}
void particle_tele_fountain_use(entity this, entity actor, entity trigger)
{
	setthink(this, particle_tele_fountain_think);
	this.nextthink = time + 0.1;
}
spawnfunc(particle_tele_fountain)
{
	if(!MP_MG) { delete(this); return; }
	if(!this.delay)
		this.delay = 0.1;
	
	if(!this.wait)
		this.wait = 0.05;
	
	if(!this.velocity)
		this.velocity = '1 1 6';
	
	if(this.spawnflags & START_OFF)
		this.use = particle_tele_fountain_use;
	else
	{
		setthink(this, particle_tele_fountain_think);
		this.nextthink = time + this.wait + this.delay * random();
	}
}

.float rand;
void target_explosion_go(entity this)
{
	if(this.dmg)
		T_RadiusDamage(this, this.enemy, this.dmg, DEATH_HURTTRIGGER.m_id, this);
	
	if(this.spawnflags & 1)
	{
		_sound(this, CH_TRIGGER_SINGLE, "blob/death1.wav", 1, ATTN_NORM);
		BecomeExplosion(this);
	}
	else if(this.spawnflags & 2)
		BecomeExplosion(this);
	else
		BecomeExplosion(this);
}

void target_explosion_use(entity this, entity actor, entity trigger)
{
	entity bewm;
	vector offset = '0 0 0';
	
	this.enemy = actor;

	playercount_convert(this, count);
	if(this.count == 1 && this.delay == 0 && this.rand == 0)
	{
		bewm = spawn();
		if(this.size != '0 0 0')
			offset = vec3(random() * this.size_x, random() * this.size_y, random() * this.size_z) - this.size * 0.5;
		setorigin(bewm, this.origin + offset);
		setthink(bewm, target_explosion_go);
		bewm.enemy = actor;
		bewm.spawnflags = this.spawnflags;
		bewm.nextthink = time;
		bewm.dmg = this.dmg;
		bewm.message = this.message;
		return;
	}
	
	float tnext = this.delay + this.rand * random();
	for(int i = 0; i < this.count; i++)
	{
		bewm = spawn();
		if(this.size != '0 0 0')
			offset = vec3(random() * this.size_x, random() * this.size_y, random() * this.size_z) - this.size * 0.5;
		setorigin(bewm, this.origin + offset);
		setthink(bewm, target_explosion_go);
		bewm.enemy = actor;
		bewm.spawnflags = this.spawnflags;
		bewm.nextthink = time + tnext;
		bewm.dmg = this.dmg;
		bewm.message = this.message;
		tnext += this.wait + random() * this.rand;
	}
}

/*QUAKED target_explosion (0 .5 .8) (-8 -8 -8) (8 8 8) TARBABY PUFF
Causes explosions, same appearance as a rocket/grenade blast. Set 'TARBABY' for a purple spawn-style explosion or 'PUFF' for the weak anti-shambler-style burst instead.

Keys
"count" number of times to explode after triggering, default 1
"delay" Time to wait before first explode
"wait" Static time to wait between explosions
"rand" Random time to wait before explosions (will sum both)
"dmg" Do splash damage, default 0
"deathtype" death message if the player is killed by your horrible trap
"size" explode somewhere randomly chosen within a box of this size
*/
/*FGD
@Pointclass base(Targetname, Appearflags, Deathtype) color(0 128 224) size(16 16 16) = target_explosion : 
"Causes one or more explosions when triggered, same appearance as a rocket/grenade blast." 
[
	spawnflags(flags) = [
		1 : "Tarbaby blast " : 0
		1 : "Puff blast" : 0
	]
	count(integer) : "Repeat count" : 1
	delay(string) : "Delay before first blast" : "0"
	wait(string) : "Wait between blasts" : "1"
	rand(string) : "Random extra wait before blasts" : "0"
	size(string) : "Explode somewhere randomly chosen within a box of this size (x y z)" : "0 0 0"
	dmg(integer) : "Splash damage" : 0
]
*/
.string deathtype;
spawnfunc(target_explosion)
{
	this.count = zeroconvertdefault(this.count, 1);
	this.use = target_explosion_use;
	if(this.spawnflags & 1)
		precache_sound("blob/death1.wav");
	if(!this.wait)
		this.wait = 1;
	if(this.deathtype && this.deathtype != "")
		this.message = this.deathtype;
	else
		this.message = "joins the smithereens";
}
