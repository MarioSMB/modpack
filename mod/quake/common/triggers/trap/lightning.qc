#ifdef SVQC

const int LIGHTNING_RANDOM = BIT(0);
const int LIGHTNING_BOOM = BIT(1);

// copper flags
const int SF_LSHOOT_ONESHOT = BIT(0);
const int SF_LSHOOT_TRACKME = BIT(1);

.float nextmovesound;

bool trap_iscopper(entity this)
{
	// TODO: better check for copper traps
	return (this.strength >= 1);
}

void SpawnLightningThink(entity this)
{
	if(time > this.delay)
	{
		delete(this);
		return;
	}
	setthink(this, SpawnLightningThink);
	if(t_checkclient(this))
	{
		//te_lightning2(NULL, this.origin, this.oldorigin); // should be this
		SendCSQCLightningBeam(this.origin, this.oldorigin);
	}
	LightningDamage(this.origin, this.oldorigin, this.lastvictim, this.dmg, DEATH_TRAP.m_id);
	this.nextthink = time + 0.1;
}

void trap_lightning_copper_fire(entity this);
void trap_lightning_proxy(entity this)
{
	if(this.realowner.spawnflags & SF_LSHOOT_TRACKME)
		this.realowner.enemy = this.enemy;
	trap_lightning_copper_fire(this.realowner);
	_sound(this, CH_WEAPON_SINGLE, "weapons/lstart.wav", this.volume, ATTN_NORM);
	delete(this);
}

void trap_lightning_copper_fire(entity this)
{
	vector org, tgt;

	if(!this.enemy)	// might already be activator
		this.enemy = findunlockedtarget(this, NULL);
	if(!this.enemy)
	{
		if((this.target && this.target != "")  || (this.target2 && this.target2 != "")  || 
			(this.target3 && this.target3 != "")  || (this.target4 && this.target4 != "") )
		{
			return;	// has targets, but none are unlocked
		}
		else
		{
			tgt = this.origin + this.movedir;	// has no targets
		}
	}
	else
	{
		tgt = (this.enemy.absmin + this.enemy.absmax) * 0.5;	// for aiming at trains or bobboes
	}
		
	//this.enemy = world;	
	vector nudge = normalize(tgt - this.origin) * 8;
	
	if(!(this.spawnflags & SF_LSHOOT_ONESHOT) || this.strength == 3)
	{
		if(time >= this.nextmovesound)
		{
			_sound(this, CH_VOICE, "misc/power.wav", this.volume, ATTN_NORM);
			this.nextmovesound = time + 1.2;
		}
	}
	
	if(this.strength == 1)
	{
		// do 10 dmg every think
		traceline(this.origin, tgt, MOVE_NORMAL, this);	// hit one target and stop
		tgt = trace_endpos;
		if(trace_ent.takedamage)
		{
			T_Damage(trace_ent, this, this, 10, DEATH_TRAP.m_id);
			particle(trace_endpos + nudge, nudge * -8, 225, 40);
			_sound(trace_ent, CHAN_BODY, "weapons/lhit.wav", 1, ATTN_NORM);
		}
	}
	else
	{
		// str 2 and 3 lightnings pierce creatures to world
		traceline(this.origin, tgt, MOVE_NOMONSTERS, this);
		tgt = trace_endpos;
		int i = 0;
		
		if(!(this.spawnflags & SF_LSHOOT_ONESHOT) || 	// always dmg on think in continuous mode
			(this.strength == 2 && this.count == 3) ||	// dmg on first think only in oneshot mode
			this.strength == 3 )	// fatbeam is instakill so do it either way
		{
			vector org = this.origin;
			entity last = this;
			do {
				i++;
				traceline(org, tgt, MOVE_NORMAL, last);
				
				// end on buttons and shootable bmodels 
				if( (trace_ent.solid != SOLID_BBOX && trace_ent.solid != SOLID_SLIDEBOX) && 
					(!trace_ent.movetype || trace_ent.movetype == MOVETYPE_PUSH) )
				{
					i = 8;
					tgt = trace_endpos;
				}
				org = trace_endpos + nudge;
			
				if(trace_ent.takedamage)
				{
					last = trace_ent;
					if(this.strength == 2)
					{
						T_Damage(trace_ent, this, this, 30, DEATH_TRAP.m_id);
						particle(org, nudge * -8, 225, 120);
					}
					else
					{
						// handle chthons and shubs intelligently
						if((trace_ent.monsterdef.spawnflags & MONSTER_TYPE_BOSS))
						{
							if(this.count == 10)	// first tic only so we don't melt the boss
								T_Damage(trace_ent, this, this, 1000, DEATH_TRAP.m_id);
						}
						else
						{
							T_Damage(trace_ent, this, this, trace_ent.health + min(trace_ent.armorvalue, trace_ent.health / trace_ent.armortype) + 50, DEATH_TRAP.m_id);
						}
					}
					_sound(trace_ent, CHAN_BODY, "weapons/lhit.wav", 1, ATTN_NORM);
				}
				
			} while(i < 8 && trace_ent);
		}
	}
	if(this.strength == 3)
		tgt -= nudge * 12;	// fatbeams are extra long
	SendCSQCLightningBeam(this.origin, tgt);
	
	if(this.spawnflags & SF_LSHOOT_ONESHOT)
	{
		this.count -= 1;
		if(this.count <= 0)
			return;
	}
	setthink(this, trap_lightning_copper_fire); 
	this.nextthink = time + 0.1;
}

void trap_lightning_copper_use(entity this, entity actor, entity trigger)
{
	if(this.spawnflags & SF_LSHOOT_TRACKME)
		this.enemy = actor;

	if(this.spawnflags & SF_LSHOOT_ONESHOT)
	{
		if(time < this.attack_finished)
			return;
		this.attack_finished = time + 0.1;

		if(this.strength == 3)
			this.count = 10;
		else if(this.strength == 2)
			this.count = 3;
		else
			this.count = 1;

		if(this.delay > 0)
		{
			entity proxy = new(trap_lightning_proxy);
			setthink(proxy, trap_lightning_proxy);
			this.nextthink = time + this.delay;
			proxy.realowner = this;
			proxy.enemy = actor;
			return;
		}

		_sound(this, CH_WEAPON_SINGLE, "weapons/lstart.wav", this.volume, ATTN_NORM);
		trap_lightning_copper_fire(this);
		return;
	}

	// is a toggle zapper
	this.state = !this.state;
	this.nextmovesound = 0;
	if(this.state)
	{
		_sound(this, CH_WEAPON_SINGLE, "weapons/lstart.wav", this.volume, ATTN_NORM);
		trap_lightning_copper_fire(this);
	}
	else
	{
		stopsound(this, CH_WEAPON_SINGLE);
		this.nextthink = 0;
	}
}

void trap_lightning_use(entity this, entity actor, entity trigger)
{
	vector p1, p2;

	if(this.pausetime != -1 && time >= this.pausetime)
	{
		if(this.spawnflags & LIGHTNING_BOOM)
			_sound(this, CHAN_AUTO, "weapons/lstart.wav", 1, ATTN_NORM);
		else
			_sound(this, CHAN_AUTO, "weapons/lhit.wav", 1, ATTN_NORM);
		if(this.classname == "trap_lightning_triggered")
			this.pausetime = time + 0.1;
	}
	if(this.target && this.target != "")
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
	else if(t_checkclient(this))
	{
		//te_lightning2(NULL, p1, p2); // should be this
		SendCSQCLightningBeam(p1, p2);
		LightningDamage(p1, p2, this, this.dmg, DEATH_TRAP.m_id);
	}
	else
		LightningDamage(p1, p2, this, this.dmg, DEATH_TRAP.m_id);
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
		if(this.pausetime < time + 0.3)
			this.pausetime = time + 0.3;
		if(timedelay < this.duration)
			timedelay = this.duration;
		this.t_width = time + timedelay;
	}
	setthink(this, lightning_think);
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
	if(this.target && this.target != "")
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

void lightning_init(entity this)
{
	if(!this.wait)
		this.wait = 1.0;
	if(!this.dmg)
		this.dmg = 30;
	if(!this.duration)
		this.duration = 0.1;
	this.cnt = 0;
	this.use = trap_lightning_use;
	precache_sound("weapons/lhit.wav");
	precache_sound("weapons/lstart.wav");
	this.huntingcharmer = this.save_nextthink;
	setthink(this, lightning_firstthink);
	this.nextthink = time + 0.25;

	// hacked in version for copper
	if(this.classname == "trap_lightning" && trap_iscopper(this))
	{
		SetMovedir(this);
		if(vdist(this.movedir, <, 32))
			this.movedir = normalize(this.movedir) * 768;
		this.state = 0;
		this.strength = bound(1, this.strength, 3);
		this.volume = zeroconvertdefault(this.volume, 1);
		this.use = trap_lightning_copper_use;
		setthink(this, func_null);
		this.nextthink = 0;
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
	this.classname = "trap_lightning_triggered";

	lightning_init(this);
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
	this.classname = "trap_lightning";

	lightning_init(this);
	this.state = 1;
}

void trap_lightning_switched_use(entity this, entity actor, entity trigger)
{
	this.state = 1 - this.state;
	if(this.state == 1)
	{
		this.nextthink = this.huntingcharmer;
		setthink(this, lightning_think);
	}
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
	this.classname = "trap_lightning_switched";

	lightning_init(this);
	this.use = trap_lightning_switched_use;
}

#endif
