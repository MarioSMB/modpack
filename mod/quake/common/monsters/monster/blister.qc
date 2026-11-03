#include "blister.qh"

#ifdef SVQC
const int anim_blister_run = 0; //'0 10 0'
const int anim_blister_walk = 11; //'11 23 0'
const int anim_blister_stand = 24; //'24 48 0'
const int anim_blister_stunned_a = 49; //'49 58 0'
const int anim_blister_stunned_b = 59; //'59 68 0'
const int anim_blister_stunned_c = 69; //'69 78 0'

.float rad_time;

void AmalGoop_Touch(entity this, entity toucher);
void AmalGoop_Die(entity this);

void BlisterGoop_Drop(entity this)
{
	entity item = spawn();

	item.velocity_z = 300 + (random() * 100);
	item.velocity_x = crandom() * 300;
	item.velocity_y = crandom() * 300;
	item.avelocity = '100 100 100';
	
	item.flags = FL_ITEM; // TODO: make this a proper projectile
	item.solid = SOLID_TRIGGER;
	setorigin(item, this.origin + '0 0 24');
	set_movetype(item, MOVETYPE_TOSS);
	item.classname = "BlisterGoop";
	_setmodel(item, "progs/proj_amalgoop.mdl");
	setsize(item, '0 0 0', '0 0 0');
	//item.angles_y = (random() * (random() * 256));
	
	vector goop_spin = '0 0 0';
	goop_spin.y = (300 + random() * 600);
	item.avelocity = goop_spin;

	item.skin = this.skin;

	item.dmg = 8;
	item.projectiledeathtype = DEATH_MONSTER_BLISTER.m_id;
	settouch(item, AmalGoop_Touch);
	
	//item.think = SUB_Remove;
	setthink(item, AmalGoop_Die);
	
	//item.nextthink = time + 20;
	float r = 12 + (random() * 3);
	item.nextthink = time + r;
}

void BlisterGoop_Spam(entity this, int drop_count)
{
	for(int j = 0; j < drop_count; ++j)
	{
		BlisterGoop_Drop(this);
	}
}

void SploderIdleNoise(entity this)
{
	if (random() > 0.2)
		return;

	float r = random();
	if(r > 0.66)
		_sound(this, CH_VOICE, "sploder/sploder_idle1.wav", 1, ATTN_IDLE);
	else if(r > 0.33)
		_sound(this, CH_VOICE, "sploder/sploder_idle2.wav", 1, ATTN_IDLE);
	else
		_sound(this, CH_VOICE, "sploder/sploder_idle3.wav", 1, ATTN_IDLE);
}

bool sploder_visible(entity this, entity e)
{
	return (!StatusEffects_active(STATUSEFFECT_Invisibility, e) && visible(this, e));
}

void Sploder_Forget(entity this)
{
	if(!this.rad_time)	// time to be RAD
	{
		// we just woke up, don't forget right away, because if we were awoken
		// by another monster waking we'll just stay here.
		this.rad_time = time + 30;
	}
	
	if(time < this.rad_time)
		return;
		
	if(!sploder_visible(this, this.enemy))
	{
		if(sploder_visible(this, this.oldenemy))
			this.enemy = this.oldenemy;
		else
			this.enemy = NULL;
		this.oldenemy = NULL;
	}
	if(!this.enemy)
	{
		this.rad_time = 0;	// reset the clock
		ai_stand(this);
	}
}

void sploder_stand1(entity this)
{
	monster_animate(this, anim_blister_stand, 25, sploder_stand1, sploder_stand1);

	ai_stand(this);

	switch(this.walkframe + 1)
	{
		case 14: SploderIdleNoise(this); break;
	}
}

void sploder_run1(entity this);
void sploder_stunned_a1(entity this)
{
	monster_animate(this, anim_blister_stunned_a, 9, sploder_stunned_a1, sploder_run1);
}

void sploder_stunned_b1(entity this)
{
	monster_animate(this, anim_blister_stunned_b, 9, sploder_stunned_b1, sploder_run1);
}

void sploder_stunned_c1(entity this)
{
	monster_animate(this, anim_blister_stunned_c, 9, sploder_stunned_c1, sploder_run1);
}

void sploder_walk1(entity this)
{
	monster_animate(this, anim_blister_walk, 13, sploder_walk1, sploder_walk1);

	int mspeed = 3;
	switch(this.walkframe + 1)
	{
		case 2: mspeed = 2; break;
		case 3: mspeed = 4; break;
		case 5: SploderIdleNoise(this); break;
		case 8: mspeed = 2; break;
		case 9: mspeed = 4; break;
		case 12: SploderIdleNoise(this); break;
	}

	ai_walk(this, mspeed);
}

void nmfast(entity this, float frate)
{
	if(autocvar_skill >= 2 && this.health > 0 && this.nextthink > 0)
		this.nextthink = time + frate;
}

bool SploderCheckDistance(entity this)
{
	vector offset = '1 1 1';
	if(boxesoverlap(this.enemy.absmin, this.enemy.absmax, this.absmin - offset, this.absmax + offset))
		return true;
	
	if(vdist((this.enemy.origin + this.enemy.view_ofs) - (this.origin + this.view_ofs), <, 80))
		return true;
	return false;
}

void SploderScream(entity this)
{
	if(this.cnt <= 0)
	{
		if(this.style > 0)
			_sound(this, CH_VOICE, "sploder/sploder_scream.wav", 1, ATTN_NORM);
		else
			_sound(this, CH_VOICE, "sploder/sploder_scream2.wav", 1, ATTN_NORM);
		this.cnt = 6; // not too often
	}
	else
		this.cnt -= 1;
}

void sploder_run(entity this, float dist)
{
	if(!SploderCheckDistance(this))
	{
		ai_run(this, dist);
		SploderScream(this);
	}
	else
	{
		this.health = 0;
		Killed(this, this, this, DEATH_MONSTER_BLISTER.m_id);
	}
}

void sploder_run1(entity this)
{
	monster_animate(this, anim_blister_run, 11, sploder_run1, sploder_run1);

	nmfast(this, 0.075);
	sploder_run(this, 28);
}

void sploder_pain(entity this, entity attacker, float damage, int deathtype)
{
	this.rad_time = time + 60;

	if(this.pain_finished > time)
		return;
	
	this.pain_finished = time + 1.5;

	if(autocvar_skill >= 2)
		BlisterGoop_Spam(this, 2);

	if(this.frame == 1 || this.frame == 5 || this.frame == 6 || this.frame == 11)
		sploder_stunned_a1(this);
	else if(this.frame == 3 || this.frame == 8 || this.frame == 9)
		sploder_stunned_b1(this);
	else if(this.frame == 2 || this.frame == 4 || this.frame == 7 || this.frame == 10)
		sploder_stunned_c1(this);
	else if(this.frame >= 11 && this.frame <= 49)
		sploder_stunned_a1(this);

	_sound(this, CH_VOICE, "sploder/sploder_pain.wav", 1, ATTN_NORM);
}

void x_blood_01(entity this); // defined elsewhere
void GibBloodBath(entity this, float bloodsize)
{
	entity blood = spawn();
	setthink(blood, x_blood_01);
	blood.nextthink = time;

	switch(bloodsize)
	{
		case 3: _setmodel(blood, "progs/s_blood_128x.spr"); setorigin(blood, this.origin + '0 0 40'); break;
		case 2: _setmodel(blood, "progs/s_blood_96x.spr"); setorigin(blood, this.origin + '0 0 32'); break;
		case 1: _setmodel(blood, "progs/s_blood_64x.spr"); setorigin(blood, this.origin + '0 0 24'); break;
		default: _setmodel(blood, "progs/null.mdl"); setorigin(blood, this.origin); break; // TODO: 32x exists
	}
	setsize(blood, '0 0 0', '0 0 0');
}

void sploder_explode(entity this)
{
	_sound(this, CH_VOICE, "zombie/z_gib.wav", 1, ATTN_NORM);

	ThrowGib(this, this, "progs/gib3.mdl", this.health);
	ThrowGib(this, this, "progs/gibs/gib_gen_1.mdl", this.health);
	ThrowGib(this, this, "progs/gibs/gib_gen_2.mdl", this.health);
	if(random() > 0.5)
		ThrowGib(this, this, "progs/gibs/gib_gen_3.mdl", this.health);
	else
		ThrowGib(this, this, "progs/gibs/gib_gen_4.mdl", this.health);
	if(random() > 0.5)
		ThrowGib(this, this, "progs/gibs/gib_gen_5.mdl", this.health);
	else
		ThrowGib(this, this, "progs/gibs/gib_gen_6.mdl", this.health);

	T_RadiusDamage(this, this, 100, DEATH_MONSTER_BLISTER.m_id, this);

	_sound(this, CHAN_BODY, "weapons/r_exp3.wav", 1, ATTN_NORM);
	GibBloodBath(this, 1);

	te_tarexplosion(this.origin);

	delete(this);
}

void sploder_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	if(autocvar_skill >= 2)
		BlisterGoop_Spam(this, 2);

	if(getthink(this) == sploder_explode)
		return;	// already exploding

	int killed_type = Death_SpecialType(this, inflictor, attacker, deathtype);
	switch(killed_type)
	{
		case KILLED_NORMAL: break; // normal death
		case KILLED_GIBBED:
		{
			this.enemy = attacker;
			setthink(this, sploder_explode);
			this.nextthink = time + 0.05; // infini-sploder crash fixed
			return; // handled separately
		}
		default: Death_SpecialHandle(this, attacker, killed_type); return;
	}

	this.enemy = attacker;
	setthink(this, sploder_explode);
	this.nextthink = time + 0.05; // infini-sploder crash fixed
	settouch(this, func_null);
	this.takedamage = DAMAGE_NO;
}

/*======================================================================
 QUAKED monster_sploder (1 0 0) (-16 -16 -24) (16 16 32)
======================================================================*/
spawnfunc(monster_sploder) { monster_start(this, true, MON_BLISTER); }
#endif // SVQC

#ifdef SVQC
METHOD(Blister, mr_setup, bool(Blister this, entity actor))
{
	TC(Blister, this);

	precache_sound("sploder/sploder_idle1.wav");
	precache_sound("sploder/sploder_idle2.wav");
	precache_sound("sploder/sploder_idle3.wav");
	precache_sound("sploder/sploder_scream.wav");
	precache_sound("sploder/sploder_scream2.wav");
	precache_sound("sploder/sploder_pain.wav");
	precache_sound("zombie/z_gib.wav");

	//required for Nightmare additions
	precache_model("progs/proj_amalgoop.mdl");
	precache_model("progs/proj_amalgoop_explo.mdl");
	precache_model("progs/proj_amalgoop_pop.mdl");
	precache_model("progs/proj_amalgoop_explo_pop.mdl");
	precache_sound("amalg/amalg_goop1.wav");
	precache_sound("amalg/amalg_goop2.wav");
	precache_sound("amalg/amalgshoot.wav");
	precache_model("progs/s_blood_128x.spr");
	precache_model("progs/s_blood_96x.spr");
	precache_model("progs/s_blood_64x.spr");
	precache_model("progs/gib3.mdl");

	precache_model("progs/gibs/gib_gen_1.mdl");
	precache_model("progs/gibs/gib_gen_2.mdl");
	precache_model("progs/gibs/gib_gen_3.mdl");
	precache_model("progs/gibs/gib_gen_4.mdl");
	precache_model("progs/gibs/gib_gen_5.mdl");
	precache_model("progs/gibs/gib_gen_6.mdl");

	if(actor.health < 1)
    	actor.health = 40;
	actor.th_stand = sploder_stand1;
	actor.th_walk = sploder_walk1;
	actor.th_run = sploder_run1;
	actor.th_die = sploder_die;
	actor.th_pain = sploder_pain;

    return true;
}
#endif

// kirby power
#ifdef SVQC
METHOD(Blister, star_fire, void(Blister this, entity actor, .entity weaponentity))
{
	Monster mon = MON_BOIL; // shared attack
	if(mon.star_fire)
		mon.star_fire(mon, actor, weaponentity);
}
#endif
