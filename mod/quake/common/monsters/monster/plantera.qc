#include "plantera.qh"

#ifdef SVQC
const int anim_plantera = 0; // no actual animations!

.int bosswave;

.float idle_finished;

void plantera_secondary(entity this);

const int PLANTERA_CLAW = 1; // grappling hook
const int PLANTERA_GRABBER = 2; // attached mouthy thing

/*
=================
PlanteraCheckAttack
=================
*/
bool PlanteraCheckAttack(entity this)
{
	if(time < this.attack_finished)
		return false;
	if(!this.enemy_visible)
		return false;

	if(this.enemy_range == RANGE_FAR)
		return false;
		
	entity targ = this.enemy;
	
// see if any entities are in the way of the shot
	vector spot1 = this.origin + this.view_ofs;
	vector spot2 = targ.origin + targ.view_ofs;

	traceline(spot1, spot2, false, this);

	if(trace_ent != targ)
	{	// don't have a clear shot, so move to a side
		return false;
	}

	float chance = 0;	
	if(this.enemy_range == RANGE_MELEE)
		chance = 0;
	else if(this.enemy_range == RANGE_NEAR)
		chance = 0.2;
	else if(this.enemy_range == RANGE_MID)
		chance = 0.6;

	if(time > this.attack2_finished && random() < chance)
	{
		// doesn't cancel out movement, just fire at will!
		this.attack2_finished = time + 3 + (random() * 3);
		plantera_secondary(this);
	}

	if(time > this.attack_finished && this.th_missile)
	{
		// seeds look dumb coming out of the bum
		if(infront(this, targ))
			this.th_missile(this);
	}

	return false;
}

void plantera_spike_touch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;

	if(time >= this.pain_finished && !toucher.takedamage)
	{
		this.pain_finished = time + 0.1; // no spam
		_sound(this, CH_SHOTS, "break/wood_i4.wav", 1, ATTN_NORM);
	}
}

.float plantera_spike_dmgtime;
void plantera_spike_think(entity this)
{
	if(time > this.count)
	{
		Send_Effect(EFFECT_TE_WIZSPIKE, this.origin, '0 0 0', 1);
		delete(this);
		return;
	}

	this.nextthink = time;

	bool didhit = false;
	FOREACH_ENTITY_RADIUS(this.origin, this.cnt, it.takedamage && it != this.owner,
	{
		if(it.clipgroup && it.clipgroup == this.clipgroup)
			continue;
		if(time < it.plantera_spike_dmgtime)
			continue;
		float damg = ((this.dmg) ? this.dmg : 30);
		spawn_touchblood(this, damg, it);
		T_Damage(it, this, this.owner, damg, this.projectiledeathtype);

		didhit = true;
		it.plantera_spike_dmgtime = time + 1; // prevent instant death
	});

	if(didhit)
		_sound(this, CH_SHOTS, "break/wood_i3.wav", 1, ATTN_NORM);
}

entity plantera_spike_attack(entity this, vector org, vector dir)
{
	//_sound(this, CH_WEAPON_SINGLE, "plantera/seed_fire.wav", 1, ATTN_BOSS);

	entity missile = spawn();
	missile.flags = FL_PROJECTILE;
	missile.owner = this;
	missile.realowner = this;
	set_movetype(missile, MOVETYPE_BOUNCE);
	missile.solid = SOLID_TRIGGER;
	missile.projectiledeathtype = DEATH_MONSTER_PLANTERA.m_id;
	missile.cnt = 20; // rough area of effect during travel
	missile.clipgroup = this.clipgroup;
	missile.classname = "thornball";
	missile.dmg = 40;
	missile.bouncefactor = 0.7;
	missile.bouncestop = 0.075;

// set missile speed	

	missile.velocity = dir * 200;
	missile.velocity_z += 200;

	missile.avelocity = '300 300 300';

	missile.angles = vectoangles(missile.velocity);

	settouch(missile, plantera_spike_touch);
	missile.count = time + 10;
	missile.nextthink = time;
	setthink(missile, plantera_spike_think);
	setsize(missile, '-10 -10 -10', '10 10 10');		
	setorigin(missile, org);

	IL_PUSH(g_projectiles, missile);

	CSQCProjectile(missile, true, PROJECTILE_THORNBALL, true);

	return missile;
}

void plantera_spore_touch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;

	if(toucher.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	int contents = pointcontents(this.origin);
	if(contents == CONTENT_SKY || contents == CONTENT_WATER)
	{
		delete(this);
		return;
	}

	if(toucher.takedamage)
	{
		float damg = ((this.dmg) ? this.dmg : 9);
		T_Damage(toucher, this, this.owner, damg, this.projectiledeathtype);
	}

	Send_Effect(EFFECT_TE_WIZSPIKE, this.origin, '0 0 0', 1);
	delete(this);
}

void plantera_spore_think(entity this)
{
	if(time >= this.count)
	{
		delete(this);
		return;
	}

	entity targ = this.owner.enemy;
	if(targ && vdist(this.velocity, >, 0))
	{
		float oldz = this.velocity_z;
		float vel = vlen(vec2(this.velocity));
		vector vtemp = CENTER_OR_VIEWOFS(targ);
		vector dir = normalize(vtemp - this.origin);
		if(vel > 250)
			vel -= 0.25 * PHYS_INPUT_TIMELENGTH;
		this.velocity = dir * max(vel, 250);
		this.velocity_z = oldz;
	}

	this.nextthink = time;
}

void plantera_spore_attack(entity this)
{
	_sound(this, CH_WEAPON_SINGLE, "plantera/seed_fire.wav", 1, ATTN_BOSS);

	vector org = CENTER_OR_VIEWOFS(this);

	vector dir = normalize(this.enemy.origin - this.origin);

	int maxflames = 1; // per fire frame
	for(int j = 0; j < maxflames; ++j)
	{
		entity newmis = launch_spike(this, org, '0 0 0');
		newmis.projectiledeathtype = DEATH_MONSTER_PLANTERA.m_id;
		newmis.dmg = 50;
		newmis.classname = "spore";
		settouch(newmis, plantera_spore_touch);
		_setmodel(newmis, "progs/plantera_spore.mdl");
		setsize(newmis, '0 0 0', '0 0 0');
		setthink(newmis, plantera_spore_think);
		newmis.nextthink = time;
		newmis.count = time + 7;
		newmis.gravity = 0.3;
		set_movetype(newmis, MOVETYPE_TOSS);
		newmis.angles = '0 0 0';
		newmis.avelocity = '0 120 0';
		//newmis.angles_y = random() * 180;

		newmis.velocity = dir * 1000 + randomvec() * 200;
		newmis.velocity_z = 300;
	}	
}

void plantera_secondary(entity this)
{
	if(this.bosswave >= 1)
		plantera_spore_attack(this);
	else
	{
		vector org = this.origin + '0 0 70';
		vector dir = normalize(this.enemy.origin - this.origin);
		plantera_spike_attack(this, org, dir);
	}
}

void plantera_hook(entity this)
{
	RandomSelection_Init();

	IL_EACH(g_planteraparts, it.state == PLANTERA_CLAW && it.hook_out && it.on_hook && time >= it.wait,
	{
		RandomSelection_AddEnt(it, 1, 1);
	});

	entity targ = RandomSelection_chosen_ent;
	if(targ)
		targ.hook_out = false;
}

.float last_enemycheck;
void boss_FindTarget(entity this)
{
	if(time < this.last_enemycheck)
		return;
	this.last_enemycheck = time + 0.5;

	// go for another player if multi player
	if(this.enemy.health <= 0 || (this.enemy.flags & FL_NOTARGET) || (coop && random() < 0.1))
		this.enemy = NULL;

	if(!this.enemy)
	{
		RandomSelection_Init();
		if(this.charmed)
		{
			FOREACH_ENTITY_FLAGS(flags, FL_MONSTER,
			{
				if(it != this && this.enemy != it && it.health > 0 && !(it.flags & FL_NOTARGET) && !it.charmed)
				{
					// enable for line of sight
					//traceline(CENTER_OR_VIEWOFS(this), it.origin, true, this);
					//if(trace_fraction != 1)
						//continue;
					RandomSelection_AddEnt(it, 1, 1);
				}
			});
		}
		else
		{
			FOREACH_CLIENT(IS_PLAYER(it) && it.health > 0 && !(it.flags & FL_NOTARGET),
			{
				// enable for line of sight
				//traceline(this.origin + '0 0 16', it.origin, true, this);
				//if(trace_fraction != 1)
					//continue;
				RandomSelection_AddEnt(it, 1, 1);
			});
		}
			
		this.enemy = RandomSelection_chosen_ent;
	}
}

/*================
	MOVEMENT
==================*/
void plantera_setangle(entity this)
{
	if(!this.goalentity)
		return;

	vector myorg = CENTER_OR_VIEWOFS(this);
	vector targorg = CENTER_OR_VIEWOFS(this.goalentity);
	vector ideal = vectoangles(normalize(targorg - myorg));
	if(this.angles == ideal)
		return;

	float angspeed = this.yaw_speed;
	ideal -= this.angles;

	this.angles_x += bound(-angspeed, shortangle_f(ideal_x, this.angles_x), angspeed);
	this.angles_y += bound(-angspeed, shortangle_f(ideal_y, this.angles_y), angspeed);
	this.angles_z += bound(-angspeed, shortangle_f(ideal_z, this.angles_z), angspeed);
}

void plantera_movetogoal(entity this, float movespeed, bool dobrake)
{
	plantera_setangle(this);

	vector ang = this.angles;
	ang.x = -ang.x;
	makevectors(ang);

	// TODO: strafe/avoid wall?
	vector dir = v_forward;

	if(dobrake)
		movespeed = max(0, vlen(this.velocity) - movespeed);

	this.velocity = dir * movespeed;
}

void plantera_move_loop(entity this)
{
	setthink(this, plantera_move_loop);
	this.nextthink = time;

	boss_FindTarget(this);

	if(this.enemy)
		this.goalentity = this.enemy;
	else if(this.charmer)
		this.goalentity = this.charmer;
	else if(this.goalentity.classname != "path_corner")
		this.goalentity = NULL;

	if(this.enemy)
	{
		this.show_hostile = time + 1; // wake up other monsters

		// check knowledge of enemy
		this.enemy_visible = visible(this, this.enemy);
		this.enemy_range = range(this, this.enemy);
		if(this.enemy_visible)
			this.search_time = time + 5;

		// look for other coop players
		if(coop && this.search_time < time && !this.charmed)
			this.enemy = NULL;
	}

	if(this.enemy)
		CheckAnyAttack(this);

	float movespeed = 80;
	if(this.enemy)
		movespeed = (this.bosswave >= 1) ? 240 : 160;

	if(time >= this.idle_finished)
	{
		this.idle_finished = time + 2;
		plantera_hook(this);

		if(!this.goalentity)
			this.state = false;
		else if(this.bosswave >= 1)
			this.state = true;
		else
			this.state = (this.state) ? false : true;
	}

	plantera_movetogoal(this, movespeed, !this.state);
}

void plantera_transform(entity this)
{
	vector oldmin = this.mins;
	vector oldmax = this.maxs;
	_setmodel(this, "progs/plantera_phase2.mdl");
	setsize(this, oldmin, oldmax);

	_sound(this, CH_VOICE, "plantera/death.wav", 1, ATTN_NORM);

	this.th_missile = func_null; // no more seeds!
	this.bosswave += 1;
	this.idle_finished = time; // stop stopping right now!

	// TODO
	int channel = MSG_ALL;
	WriteHeader(channel, eoc_gibsplash);
	WriteVector(channel, this.origin);
	WriteFloat(channel, this.health);
	//WriteFloat(channel, this.scale);
	//WriteVector(channel, inflictor.origin);
	//WriteShort(channel, compressShortVector(normalize(this.origin - inflictor.origin)));
	//WriteShort(channel, compressShortVector(inflictor.velocity));

	for(int j = 0; j < 9; ++j)
	{
		plantera_spawnpart(this, this, "progs/plantera_grabber.mdl", PLANTERA_GRABBER);
	}

	// no additional grabbers on easy and normal
	if(autocvar_skill <= 1)
		return;

	IL_EACH(g_planteraparts, it.owner == this && it.state == PLANTERA_CLAW,
	{
		plantera_spawnpart(this, it, "progs/plantera_grabber.mdl", PLANTERA_GRABBER);
		plantera_spawnpart(this, it, "progs/plantera_grabber.mdl", PLANTERA_GRABBER);
		plantera_spawnpart(this, it, "progs/plantera_grabber.mdl", PLANTERA_GRABBER);
	});
}

//===========================================================================

void plantera_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.bosswave == 0 && this.health <= (this.max_health * 0.5))
	{
		plantera_transform(this);
		return;
	}

	if(time < this.pain_finished)
		return;
	this.pain_finished = time + 0.1;
	_sound(this, CH_VOICE, "plantera/pain.wav", 1, ATTN_BOSS);
}

//===========================================================================

void plantera_clearparts(entity this)
{
	IL_EACH(g_planteraparts, it.owner == this,
	{
		if(it.tether_ent)
			tether_remove(it.tether_ent);
		delete(it);
	});
}

void plantera_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	this.velocity = '0 0 0';

	_sound(this, CH_VOICE, "plantera/death.wav", 1, ATTN_BOSS);
	spawn_touchblood(this, 60, inflictor);
	ThrowGib(this, this, "progs/gib1.mdl", -100);
	ThrowGib(this, this, "progs/gib2.mdl", -100);
	ThrowGib(this, this, "progs/gib3.mdl", -100);
	ThrowGib(this, this, "progs/gib1.mdl", -100);
	ThrowGib(this, this, "progs/gib2.mdl", -100);
	ThrowGib(this, this, "progs/gib3.mdl", -100);
	ThrowGib(this, this, "progs/gib1.mdl", -100);
	ThrowGib(this, this, "progs/gib2.mdl", -100);
	ThrowGib(this, this, "progs/gib3.mdl", -100);

	plantera_clearparts(this);
	delete(this);
}

void plantera_seed_touch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;

	if(toucher.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}
	
// hit something that bleeds
	if(toucher.takedamage) // yoder mod, jan 05 2021
	{
		float damg = ((this.dmg) ? this.dmg : 9);
		spawn_touchblood(this, damg, toucher);
		T_Damage(toucher, this, this.owner, damg, this.projectiledeathtype);
	}
	else
		Send_Effect(EFFECT_TE_WIZSPIKE, this.origin, '0 0 0', 1);

	delete(this);
}

void plantera_seed_attack(entity this)
{
	_sound(this, CH_WEAPON_SINGLE, "plantera/seed_fire.wav", 1, ATTN_NORM);

	entity missile = new(plantera_seed);
	missile.flags = FL_PROJECTILE;
	missile.owner = this;
	missile.realowner = this;
	missile.clipgroup = this.clipgroup;
	set_movetype(missile, MOVETYPE_FLYMISSILE);
	missile.solid = SOLID_BBOX;
	missile.projectiledeathtype = DEATH_MONSTER_PLANTERA.m_id;
	missile.dmg = 20;

	float bullet_speed = 400;
	vector org = this.origin + '0 0 16';
	vector dir = ai_shotlead(org, CENTER_OR_VIEWOFS(this.enemy), this.enemy.velocity, bullet_speed);
	dir = normalize(dir - org);
	missile.velocity = dir * bullet_speed;

	if(random() <= 0.25)
		missile.poisonous = true;

	missile.angles = vectoangles(missile.velocity);
	//missile.angles_z = (random() > 0.5) ? 30 : -30;

	settouch(missile, plantera_seed_touch);

	missile.nextthink = time + 8;
	setthink(missile, SUB_Remove);

	setsize(missile, '0 0 0', '0 0 0');
	setorigin(missile, this.origin);

	IL_PUSH(g_projectiles, missile);

	if(missile.poisonous)
		CSQCProjectile(missile, true, PROJECTILE_SEED_POISON, true);
	else
		CSQCProjectile(missile, true, PROJECTILE_SEED, true);
}

void plantera_seed(entity this)
{
	plantera_seed_attack(this);

	// high chance for spam!
	if(random() < 0.9)
		this.attack_finished = time + 0.1;
	else
		this.attack_finished = time + 2 + (random() * 2);
}

.float plantera_hurttime;
void plantera_part_hit(entity this, entity toucher)
{
	entity own = (IS_MONSTER(this)) ? this : this.realowner;

	if(toucher.flags & FL_PROJECTILE)
		return;
	if(time < toucher.plantera_hurttime)
		return;

	if(!toucher.takedamage || !Damage_ValidTarget(toucher, own))
		return;
	
	if(toucher == this.owner || toucher.owner == own)
		return;

	toucher.plantera_hurttime = time + 0.2; // no spam please

	float damage = (this.dmg) ? this.dmg : 40;
	
	T_Damage(toucher, own, own, damage, DEATH_MONSTER_PLANTERA.m_id);
}

void plantera_part_checkdamage(entity this, float dmgradius)
{
	if(time < this.delay)
		return;
	this.delay = time + 0.1;

	FOREACH_ENTITY_RADIUS(this.origin, dmgradius, it != this,
	{
		if (it.move_nomonsters != MOVE_NOMONSTERS && it.move_nomonsters != MOVE_WORLDONLY)
			plantera_part_hit(this, it);
	});
}

void plantera_part_think(entity this)
{
	this.nextthink = time;

	if(this.owner.health <= 0 || wasfreed(this.owner))
	{
		if(this.tether_ent)
			tether_remove(this.tether_ent);
		delete(this);
		return;
	}

	switch(this.state)
	{
		case PLANTERA_CLAW:
		{
			if(!this.hook_out)
			{
				float maxdist = (this.bosswave >= 1) ? 1000 : 2000;
				traceline(this.owner.origin, this.owner.origin + randomvec() * maxdist, MOVE_NOMONSTERS, this.owner);
				this.pos1 = trace_endpos;
				vector dir = normalize(trace_endpos - this.origin);
				this.velocity = dir * 500;
				this.angles = vectoangles(this.velocity);
				this.hook_out = true;
				this.on_hook = false; // unlatch as well!
				this.frame = 0;
			}
			else if(!this.on_hook)
			{
				if(vdist(this.origin - this.pos1, <=, 20))
				{
					this.velocity = '0 0 0';
					this.on_hook = true;
					this.frame = 1;
					this.wait = time + 1;
				}
			}

			plantera_part_checkdamage(this, 24);
			break;
		}
		case PLANTERA_GRABBER:
		{
			vector dir;
			// TODO: let them look at nearby enemies instead?
			//if(this.owner.enemy)
				//dir = normalize(this.owner.enemy.origin - this.origin);
			//else
				dir = normalize(this.origin - this.goalentity.origin);
			this.angles = vectoangles(dir);

			if(time >= this.wait)
			{
				this.t_length = max(50, random() * 360);
				this.wait = time + 1 + (random() * 1);
			}
			vector org = this.goalentity.origin + this.pos2 * this.t_length;
			dir = normalize(org - this.origin);
			this.velocity = dir * 300;

			if(time >= this.idle_finished)
			{
				this.idle_finished = time + 0.2;
				this.frame = (this.frame) ? 0 : 1;
			}

			plantera_part_checkdamage(this, 32);
			break;
		}
	}
}

entity plantera_spawnpart(entity this, entity attach, string partmdl, int parttype)
{
	entity part = new(plantera_part);
	part.solid = SOLID_TRIGGER;
	_setmodel(part, partmdl);
	setsize(part, '-16 -16 -16', '16 16 16');
	set_movetype(part, MOVETYPE_NOCLIP);
	part.clipgroup = this.clipgroup;
	part.projectiledeathtype = DEATH_MONSTER_PLANTERA.m_id;
	part.owner = this;
	part.realowner = this;
	setthink(part, plantera_part_think);
	part.nextthink = time;
	part.dmg = 40;
	part.health = 1; // for the tether TODO
	part.attack_finished = time + 1 + (2 * random());
	part.cnt = 0;
	part.goalentity = attach;
	part.state = parttype;
	part.on_hook = false; // whether we're latched onto something
	part.hook_out = false; // when false hook will look for a new target to latch onto
	part.pos1 = attach.origin;

	//setattachment(part, attach, "");
	setorigin(part, attach.origin);
	//part.angles = this.angles;

	switch(parttype)
	{
		case PLANTERA_CLAW:
		{
			tether_setup(part, attach, TETHER_VINE_BIG, 12);
			break;
		}
		case PLANTERA_GRABBER:
		{
			part.wait = time + 3;
			part.t_length = max(50, random() * 360);
			part.pos2 = randomvec(); // give it a random consistent direction
			tether_setup(part, attach, TETHER_VINE_SMALL, 6);
			break;
		}
	}

	IL_PUSH(g_planteraparts, part);
	
	return part;
}

void plantera_spawnparts(entity this)
{
	// initial 3 grappling hooks
	plantera_spawnpart(this, this, "progs/plantera_claw.mdl", PLANTERA_CLAW);
	plantera_spawnpart(this, this, "progs/plantera_claw.mdl", PLANTERA_CLAW);
	plantera_spawnpart(this, this, "progs/plantera_claw.mdl", PLANTERA_CLAW);
}

/*QUAKED monster_plantera (1 0 0) (-16 -16 -24) (16 16 40) Ambush
*/
spawnfunc(monster_plantera) { monster_start(this, true, MON_PLANTERA); }
#endif // SVQC

#ifdef SVQC
METHOD(Plantera, mr_setup, bool(Plantera this, entity actor))
{
	TC(Plantera, this);

	precache_model("progs/plantera_phase2.mdl");
	precache_model("progs/plantera_claw.mdl");
	precache_model("progs/plantera_grabber.mdl");
	precache_model("progs/plantera_seed.mdl");
	precache_model("progs/plantera_spore.mdl");
	precache_model("progs/plantera_thornball.mdl");
	precache_sound("plantera/death.wav");
	precache_sound("plantera/pain.wav");
	precache_sound("plantera/seed_fire.wav");
	precache_sound("break/wood_i3.wav");
	precache_sound("break/wood_i4.wav");

	actor.yaw_speed = 20;
	settouch(actor, plantera_part_hit);
	set_movetype(actor, MOVETYPE_FLY);

	actor.health = 5000;
	actor.th_stand = plantera_move_loop;
	actor.th_walk = plantera_move_loop;
	actor.th_run = plantera_move_loop;
	actor.th_pain = plantera_pain;
	actor.th_die = plantera_die;
	actor.th_missile = plantera_seed;

	actor.checkattack = PlanteraCheckAttack;

	plantera_spawnparts(actor);

	return true;
}
#endif
