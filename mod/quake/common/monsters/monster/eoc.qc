#include "eoc.qh"

REGISTER_NET_TEMP(eoc_gibsplash)

#ifdef SVQC
.int bosswave;
.float anim_finished;

void eoc_anim(entity this)
{
	if(time < this.anim_finished)
		return;
	this.anim_finished = time + FRAME_TIME;

	// FIXME: the old model was cooler...
	int framecount = 19;
	if(this.bosswave >= 1)
		framecount = 3;

	this.walkframe += 1;
	if(this.walkframe > framecount)
		this.walkframe = 0;
	this.frame = this.walkframe;
}

bool EOCFireBaby(entity this, vector dir)
{
	if(query_minionactive(this) <= 0)
		return false;

	vector org = CENTER_OR_VIEWOFS(this) + dir * 64;
	bool have_space = find_minionspace(org);
	
	// If the spawn location all clear, spawn something!
	if(have_space)
	{
		// special "servant" variant of demon eye
		entity pet = minion_spawn(this, org, new(monster), MON_DEMON_EYE);
		pet.velocity = dir * (random() * 400) + randomvec() * 70;
		pet.angles = vectoangles(dir);
		pet.health = min(pet.health, 10);
		pet.max_health = pet.health;
		pet.skin = 5; // unique servant skin
		pet.scale = 0.5;
		setsize(pet, pet.mins * pet.scale, pet.maxs * pet.scale);
		return true;
	}
	return false;
}

void eoc_transform(entity this)
{
	vector oldmin = this.mins;
	vector oldmax = this.maxs;
	_setmodel(this, "progs/eoc_p2.mdl");
	setsize(this, oldmin, oldmax);

	_sound(this, CH_VOICE, "eoc/sight.wav", 1, ATTN_BOSS);

	this.bosswave = 1;

	if(autocvar_skill >= 1)
	{
		vector myorg = CENTER_OR_VIEWOFS(this);
		float petcount = rint(random() * 6);
		for(int j = 1; j < petcount; ++j)
		{
			vector targ_org = randomvec() * 200;
			EOCFireBaby(this, normalize(targ_org - myorg));
		}
	}

	int channel = MSG_ALL;
	WriteHeader(channel, eoc_gibsplash);
	WriteVector(channel, this.origin);
	WriteFloat(channel, this.health);
	//WriteFloat(channel, this.scale);
	//WriteVector(channel, inflictor.origin);
	//WriteShort(channel, compressShortVector(normalize(this.origin - inflictor.origin)));
	//WriteShort(channel, compressShortVector(inflictor.velocity));
}

void eoc_setangle(entity this, vector goal)
{
	vector myorg = CENTER_OR_VIEWOFS(this);
	vector ideal = vectoangles(normalize(goal - myorg));
	if(this.angles == ideal)
		return;

	float angspeed = this.yaw_speed;
	ideal -= this.angles;

	this.angles_x += bound(-angspeed, shortangle_f(ideal_x, this.angles_x), angspeed);
	this.angles_y += bound(-angspeed, shortangle_f(ideal_y, this.angles_y), angspeed);
	this.angles_z += bound(-angspeed, shortangle_f(ideal_z, this.angles_z), angspeed);
}

.int eoc_attackcount;
.vector moveto;

entity eoc_pickmovegoal(entity this)
{
	if(this.enemy)
		return this.enemy;
	else if(this.charmer)
		return this.charmer;
	else if(this.movetarget)
		return this.movetarget;
	else if(this.goalentity.classname != "path_corner")
		return NULL;
	return this.goalentity;
}

void eoc_attackframe(entity this)
{
	switch(this.attack_state)
	{
		default:
		case AS_STRAIGHT: // passive phase
		{
			if(this.bosswave < 1)
			{
				this.eoc_attackcount -= 1;
				this.attack_finished = time + 1.5;
				vector myorg = CENTER_OR_VIEWOFS(this);
				vector targ_org = CENTER_OR_VIEWOFS(this.enemy);
				vector dir = normalize(targ_org - myorg);
				if(EOCFireBaby(this, dir))
					_sound(this, CH_VOICE, "eoc/spit.wav", 1, ATTN_BOSS);
			}
			if(this.eoc_attackcount <= 0)
			{
				this.attack_finished = time + 5;
				this.attack_state = AS_DODGING;
				this.eoc_attackcount = 3;
			}
			break;
		}
		case AS_DODGING:
		{
			this.eoc_attackcount -= 1;
			vector myorg = CENTER_OR_VIEWOFS(this);
			vector targ_org = CENTER_OR_VIEWOFS(this.enemy);
			vector dir = normalize(targ_org - myorg);
			this.moveto = targ_org + dir * 200;
			this.velocity = dir * 600; // push us towards the target! TODO
			if(this.bosswave >= 1)
				_sound(this, CH_VOICE, "eoc/sight.wav", 1, ATTN_BOSS);

			this.attack_finished = time + 2;

			if(this.eoc_attackcount <= 0)
			{
				this.attack_finished = time + 5;
				if(this.bosswave < 1)
					this.attack_state = AS_STRAIGHT;
				else if(autocvar_skill >= 2)
				{
					// do an "instant" charge to scare them!
					this.attack_state = AS_MISSILE;
					this.attack_finished = time + 2;
				}
				else
					this.attack_state = AS_DODGING; // keep charging, but not too often
				this.eoc_attackcount = 3;
			}
			break;
		}
		case AS_MISSILE:
		{
			this.eoc_attackcount -= 1;
			vector myorg = CENTER_OR_VIEWOFS(this);
			vector targ_org = CENTER_OR_VIEWOFS(this.enemy);
			targ_org += randomvec() * 250; // pick a random position near the enemy

			vector dir = normalize(targ_org - myorg);
			this.moveto = targ_org + dir * 150;
			this.velocity = dir * 1200;

			float chargerate = 0.7 * bound(0.4, 3 * (this.health / this.max_health), 1);
			this.attack_finished = time + (2 * chargerate);

			_sound(this, CH_VOICE, "eoc/charge.wav", 1, ATTN_BOSS);

			if(this.eoc_attackcount <= 0)
			{
				this.eoc_attackcount = 3;
				if(this.health > (this.max_health * 0.30))
				{
					this.attack_state = AS_DODGING;
					this.attack_finished = time + 3;
				}
				else
				{
					this.attack_state = AS_MISSILE;
					this.attack_finished = time + (3 * chargerate);
				}
			}
		}
	}
}

void eoc_touch(entity this, entity toucher)
{
	if(toucher.flags & FL_PROJECTILE)
		return;
	if(this.clipgroup && this.clipgroup == toucher.clipgroup)
		return;
	if(time < toucher.hurt_antispam)
		return;

	if(!toucher.takedamage || !Damage_ValidTarget(toucher, this))
		return;
	
	if(toucher == this.owner || toucher.owner == this)
		return;

	toucher.hurt_antispam = time + 0.5; // no spam please

	float damage = 15 + (random() * 4) + (random() * 2);
	if(this.bosswave >= 1)
		damage *= 2;
	
	T_Damage(toucher, this, this, damage, DEATH_MONSTER_EOC.m_id);
}

void eoc_touchframe(entity this)
{
	// since we use noclip, touching must be handled manually
	vector emin = this.absmin, emax = this.absmax;
	emin -= '1 1 1';
	emax += '1 1 1';

	FOREACH_ENTITY_BOX_ORDERED(emin, emax, it != this,
	{
		if (it.move_nomonsters != MOVE_NOMONSTERS && it.move_nomonsters != MOVE_WORLDONLY)
			eoc_touch(this, it);
	});
}

void eoc_move(entity this, vector goal, float velmax, float turnrate)
{
	float vel = vlen(this.velocity);
	if(vel == 0)
		vel = 1; // hack to make sure avelocity never divs by 0

	// gently home in
	vector newdir = ai_steerto(this, goal, turnrate);
	this.velocity = newdir * vel;

	ai_accelerate(this, PHYS_INPUT_TIMELENGTH, normalize(this.velocity), vel, velmax, 0.25);
}

void eoc_brake(entity this, float brakespeed)
{
	vector dir = normalize(this.velocity);

	brakespeed = max(0, vlen(this.velocity) - brakespeed);

	this.velocity = dir * brakespeed;
}

void eoc_think(entity this);
void eoc_spin(entity this)
{
	this.nextthink = time;

	eoc_anim(this);

	if(time >= this.attack_finished)
	{
		if(this.bosswave == 0)
		{
			eoc_transform(this);
			this.attack_finished = time + 2;
		}
		else
		{
			this.attack_finished = time + 3;
			this.attack_state = AS_DODGING;
			this.avelocity = '0 0 0';
			this.angles_x = anglemods(this.angles_x); // ???
			setthink(this, eoc_think);
			return;
		}
	}

	if(vdist(this.velocity, >, 0))
		eoc_brake(this, 5);

	if(this.bosswave < 1)
		this.avelocity_x = min(this.avelocity_x + 360 * PHYS_INPUT_TIMELENGTH, 540);
	else
		this.avelocity_x = max(0, this.avelocity_x - 420 * PHYS_INPUT_TIMELENGTH);
}

void eoc_think(entity this)
{
	this.nextthink = time;
	setthink(this, eoc_think);

	eoc_anim(this);

	float threshold = (autocvar_skill >= 2) ? 0.65 : 0.5;
	if(this.bosswave == 0 && this.health <= (this.max_health * threshold))
	{
		this.attack_finished = time + 3; // time it takes to transform
		setthink(this, eoc_spin);
		this.nextthink = time;
		return;
	}

	eoc_touchframe(this);

	bool had_enemy = (this.enemy != NULL);

	boss_FindTarget(this);

	if(this.enemy && !had_enemy)
		this.attack_finished = time + 5; // initial delay before attacking

	this.goalentity = eoc_pickmovegoal(this);

	if(this.moveto != '0 0 0' && vdist(this.origin - this.moveto, <=, 64))
		this.moveto = '0 0 0';

	if(this.enemy && time >= this.attack_finished)
		eoc_attackframe(this);

	vector goal = '0 0 0';
	if(this.moveto != '0 0 0')
		goal = this.moveto;
	else if(this.enemy)
	{
		// circle the target
		goal = CENTER_OR_VIEWOFS(this.enemy);

		float orbit_radius = 128;

		goal.x += (cos(time * 2) * orbit_radius);
		goal.y += (sin(time * 2) * orbit_radius);
		goal.z += 200;
	}
	else if(this.goalentity)
		goal = CENTER_OR_VIEWOFS(this.goalentity);
	else if(this.pos1 != '0 0 0')
		goal = this.pos1; // return home otherwise, so we're not left in the void

	if(goal != '0 0 0')
	{
		float myspeed = (this.enemy) ? 200 : 100;
		if(autocvar_skill >= 1)
			myspeed *= 1.5;
		if(StatusEffects_active(STATUSEFFECT_Slowness, this))
			myspeed *= 0.5;

		if(vdist(this.velocity, <=, myspeed))
			eoc_move(this, goal, myspeed, 0.05);
		else
			eoc_brake(this, 20);

		vector look_goal = '0 0 0';
		if(this.moveto != '0 0 0')
			look_goal = this.moveto;
		else if(this.goalentity)
			look_goal = CENTER_OR_VIEWOFS(this.goalentity);
		else
			look_goal = goal;
		eoc_setangle(this, look_goal);
	}
	else
		eoc_brake(this, 1.5);
}

void eoc_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;
	if(this.health <= 0)
		return;
	_sound(this, CH_VOICE, "eoc/pain.wav", 1, ATTN_BOSS);
	this.pain_finished = time + 0.2;
}

void gib_eoc(entity this)
{
	_sound(this, CH_VOICE, "eoc/death.wav", 1, ATTN_BOSS);
	settouch(this, func_null);

	int channel = MSG_ALL;
	WriteHeader(channel, eoc_gibsplash);
	WriteVector(channel, this.origin);
	WriteFloat(channel, this.health);

	ThrowGib(this, this, "progs/rawbone.mdl", this.health);
}

void eoc_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	int killed_type = Death_SpecialType(this, inflictor, attacker, deathtype);
	switch(killed_type)
	{
		case KILLED_NORMAL: break; // normal death
		case KILLED_GIBBED:
		{
			gib_eoc(this);
			// fall through to special handling
		}
		default: Death_SpecialHandle(this, attacker, killed_type); return;
	}

	gib_eoc(this);
	delete(this);
}

spawnfunc(monster_eoc) { monster_start(this, true, MON_EOC); }
#endif // SVQC

#ifdef SVQC
METHOD(EyeOfCthulhu, mr_setup, bool(EyeOfCthulhu this, entity actor))
{
    TC(EyeOfCthulhu, this);

    precache_model("progs/gib1.mdl");
	precache_model("progs/xtragib.mdl");
	precache_model("progs/bone.mdl");
	precache_model("progs/rawbone.mdl");
	precache_model("progs/eoc_p2.mdl");
	precache_sound("eoc/death.wav");
	precache_sound("eoc/pain.wav");
	precache_sound("eoc/charge.wav"); // TODO: unused for now, need a hard mode attack!
	precache_sound("eoc/spit.wav");
	precache_sound("eoc/sight.wav");

	if(!actor.minion_maxcount)
		actor.minion_maxcount = 9;

	actor.bosswave = 0;
	actor.skin = 0;

	actor.yaw_speed = 10;
	actor.eoc_attackcount = 3; // cycles in threes

	actor.pos1 = actor.origin;

	set_movetype(actor, MOVETYPE_NOCLIP);

    actor.health = 3640;
	actor.th_stand = eoc_think;
	actor.th_walk = eoc_think;
	actor.th_run = eoc_think;
	actor.th_pain = eoc_pain;
	actor.th_die = eoc_die;

    return true;
}
METHOD(EyeOfCthulhu, mr_sight, bool(EyeOfCthulhu this, entity actor))
{
	TC(EyeOfCthulhu, this);

	_sound(actor, CH_VOICE, "eoc/sight.wav", 1, ATTN_BOSS);

	return true;
}
#endif

#ifdef CSQC
PRECACHE(EOC)
{
	precache_model("progs/gib1.mdl");
	precache_model("progs/gib2.mdl");
	precache_model("progs/gib3.mdl");
	precache_model("progs/xtragib.mdl");
	precache_model("progs/bone.mdl");
	precache_model("progs/bone2.mdl");
	precache_model("progs/rawbone.mdl");
}

NET_HANDLE(eoc_gibsplash, bool isnew)
{
	vector org = ReadVector();
	float mhealth = ReadFloat();
	//float myscale = ReadFloat();
	//vector targorg = ReadVector();
	//vector targnorm = decompressShortVector(ReadShort());
	//vector targvel = decompressShortVector(ReadShort());
	vector targvel = '0 0 0';

	return = true;

	TossGib ("progs/xtragib.mdl", org, org, VelocityForDamage(org, '0 0 0', targvel, mhealth), '0 0 0', 0, false, false);
	TossGib ("progs/gib1.mdl", org, org, VelocityForDamage(org, '0 0 0', targvel, mhealth), '0 0 0', 0, false, false);
	TossGib ("progs/bone.mdl", org, org, VelocityForDamage(org, '0 0 0', targvel, mhealth), '0 0 0', 0, false, false);
	TossGib ("progs/gib2.mdl", org, org, VelocityForDamage(org, '0 0 0', targvel, mhealth), '0 0 0', 0, false, false);
	TossGib ("progs/xtragib.mdl", org, org, VelocityForDamage(org, '0 0 0', targvel, mhealth), '0 0 0', 0, false, false);
	TossGib ("progs/bone2.mdl", org, org, VelocityForDamage(org, '0 0 0', targvel, mhealth), '0 0 0', 0, false, false);
	TossGib ("progs/gib1.mdl", org, org, VelocityForDamage(org, '0 0 0', targvel, mhealth), '0 0 0', 0, false, false);
	TossGib ("progs/xtragib.mdl", org, org, VelocityForDamage(org, '0 0 0', targvel, mhealth), '0 0 0', 0, false, false);
	TossGib ("progs/gib2.mdl", org, org, VelocityForDamage(org, '0 0 0', targvel, mhealth), '0 0 0', 0, false, false);
	TossGib ("progs/xtragib.mdl", org, org, VelocityForDamage(org, '0 0 0', targvel, mhealth), '0 0 0', 0, false, false);
	TossGib ("progs/rawbone.mdl", org, org, VelocityForDamage(org, '0 0 0', targvel, mhealth), '0 0 0', 0, false, false);
	TossGib ("progs/gib3.mdl", org, org, VelocityForDamage(org, '0 0 0', targvel, mhealth), '0 0 0', 0, false, false);
}
#endif
