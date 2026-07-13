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

void sploder_stand1(entity this);
void sploder_stand25(entity this) { set_animofs(this, anim_blister_stand, 25, sploder_stand1); ai_stand(this); }
void sploder_stand24(entity this) { set_animofs(this, anim_blister_stand, 24, sploder_stand25); ai_stand(this); }
void sploder_stand23(entity this) { set_animofs(this, anim_blister_stand, 23, sploder_stand24); ai_stand(this); }
void sploder_stand22(entity this) { set_animofs(this, anim_blister_stand, 22, sploder_stand23); ai_stand(this); }
void sploder_stand21(entity this) { set_animofs(this, anim_blister_stand, 21, sploder_stand22); ai_stand(this); }
void sploder_stand20(entity this) { set_animofs(this, anim_blister_stand, 20, sploder_stand21); ai_stand(this); }
void sploder_stand19(entity this) { set_animofs(this, anim_blister_stand, 19, sploder_stand20); ai_stand(this); }
void sploder_stand18(entity this) { set_animofs(this, anim_blister_stand, 18, sploder_stand19); ai_stand(this); }
void sploder_stand17(entity this) { set_animofs(this, anim_blister_stand, 17, sploder_stand18); ai_stand(this); }
void sploder_stand16(entity this) { set_animofs(this, anim_blister_stand, 16, sploder_stand17); ai_stand(this); }
void sploder_stand15(entity this) { set_animofs(this, anim_blister_stand, 15, sploder_stand16); ai_stand(this); }
void sploder_stand14(entity this) { set_animofs(this, anim_blister_stand, 14, sploder_stand15); ai_stand(this); SploderIdleNoise(this); }
void sploder_stand13(entity this) { set_animofs(this, anim_blister_stand, 13, sploder_stand14); ai_stand(this); }
void sploder_stand12(entity this) { set_animofs(this, anim_blister_stand, 12, sploder_stand13); ai_stand(this); }
void sploder_stand11(entity this) { set_animofs(this, anim_blister_stand, 11, sploder_stand12); ai_stand(this); }
void sploder_stand10(entity this) { set_animofs(this, anim_blister_stand, 10, sploder_stand11); ai_stand(this); }
void sploder_stand9(entity this) { set_animofs(this, anim_blister_stand, 9, sploder_stand10); ai_stand(this); }
void sploder_stand8(entity this) { set_animofs(this, anim_blister_stand, 8, sploder_stand9); ai_stand(this); }
void sploder_stand7(entity this) { set_animofs(this, anim_blister_stand, 7, sploder_stand8); ai_stand(this); }
void sploder_stand6(entity this) { set_animofs(this, anim_blister_stand, 6, sploder_stand7); ai_stand(this); }
void sploder_stand5(entity this) { set_animofs(this, anim_blister_stand, 5, sploder_stand6); ai_stand(this); }
void sploder_stand4(entity this) { set_animofs(this, anim_blister_stand, 4, sploder_stand5); ai_stand(this); }
void sploder_stand3(entity this) { set_animofs(this, anim_blister_stand, 3, sploder_stand4); ai_stand(this); }
void sploder_stand2(entity this) { set_animofs(this, anim_blister_stand, 2, sploder_stand3); ai_stand(this); }
void sploder_stand1(entity this) { set_animofs(this, anim_blister_stand, 1, sploder_stand2); ai_stand(this); }

void sploder_run1(entity this);
void sploder_stunned_a9(entity this) { set_animofs(this, anim_blister_stunned_a, 9, sploder_run1); }
void sploder_stunned_a8(entity this) { set_animofs(this, anim_blister_stunned_a, 8, sploder_stunned_a9); }
void sploder_stunned_a7(entity this) { set_animofs(this, anim_blister_stunned_a, 7, sploder_stunned_a8); }
void sploder_stunned_a6(entity this) { set_animofs(this, anim_blister_stunned_a, 6, sploder_stunned_a7); }
void sploder_stunned_a5(entity this) { set_animofs(this, anim_blister_stunned_a, 5, sploder_stunned_a6); }
void sploder_stunned_a4(entity this) { set_animofs(this, anim_blister_stunned_a, 4, sploder_stunned_a5); }
void sploder_stunned_a3(entity this) { set_animofs(this, anim_blister_stunned_a, 3, sploder_stunned_a4); }
void sploder_stunned_a2(entity this) { set_animofs(this, anim_blister_stunned_a, 2, sploder_stunned_a3); }
void sploder_stunned_a1(entity this) { set_animofs(this, anim_blister_stunned_a, 1, sploder_stunned_a2); }

void sploder_stunned_b9(entity this) { set_animofs(this, anim_blister_stunned_b, 9, sploder_run1); }
void sploder_stunned_b8(entity this) { set_animofs(this, anim_blister_stunned_b, 8, sploder_stunned_b9); }
void sploder_stunned_b7(entity this) { set_animofs(this, anim_blister_stunned_b, 7, sploder_stunned_b8); }
void sploder_stunned_b6(entity this) { set_animofs(this, anim_blister_stunned_b, 6, sploder_stunned_b7); }
void sploder_stunned_b5(entity this) { set_animofs(this, anim_blister_stunned_b, 5, sploder_stunned_b6); }
void sploder_stunned_b4(entity this) { set_animofs(this, anim_blister_stunned_b, 4, sploder_stunned_b5); }
void sploder_stunned_b3(entity this) { set_animofs(this, anim_blister_stunned_b, 3, sploder_stunned_b4); }
void sploder_stunned_b2(entity this) { set_animofs(this, anim_blister_stunned_b, 2, sploder_stunned_b3); }
void sploder_stunned_b1(entity this) { set_animofs(this, anim_blister_stunned_b, 1, sploder_stunned_b2); }

void sploder_stunned_c9(entity this) { set_animofs(this, anim_blister_stunned_c, 9, sploder_run1); }
void sploder_stunned_c8(entity this) { set_animofs(this, anim_blister_stunned_c, 8, sploder_stunned_c9); }
void sploder_stunned_c7(entity this) { set_animofs(this, anim_blister_stunned_c, 7, sploder_stunned_c8); }
void sploder_stunned_c6(entity this) { set_animofs(this, anim_blister_stunned_c, 6, sploder_stunned_c7); }
void sploder_stunned_c5(entity this) { set_animofs(this, anim_blister_stunned_c, 5, sploder_stunned_c6); }
void sploder_stunned_c4(entity this) { set_animofs(this, anim_blister_stunned_c, 4, sploder_stunned_c5); }
void sploder_stunned_c3(entity this) { set_animofs(this, anim_blister_stunned_c, 3, sploder_stunned_c4); }
void sploder_stunned_c2(entity this) { set_animofs(this, anim_blister_stunned_c, 2, sploder_stunned_c3); }
void sploder_stunned_c1(entity this) { set_animofs(this, anim_blister_stunned_c, 1, sploder_stunned_c2); }

void sploder_walk1(entity this);
void sploder_walk13(entity this) { set_animofs(this, anim_blister_walk, 13, sploder_walk1); ai_walk(this, 3); }
void sploder_walk12(entity this) { set_animofs(this, anim_blister_walk, 12, sploder_walk13); ai_walk(this, 3); SploderIdleNoise(this); }
void sploder_walk11(entity this) { set_animofs(this, anim_blister_walk, 11, sploder_walk12); ai_walk(this, 3); }
void sploder_walk10(entity this) { set_animofs(this, anim_blister_walk, 10, sploder_walk11); ai_walk(this, 3); }
void sploder_walk9(entity this) { set_animofs(this, anim_blister_walk, 9, sploder_walk10); ai_walk(this, 4); }
void sploder_walk8(entity this) { set_animofs(this, anim_blister_walk, 8, sploder_walk9); ai_walk(this, 2); }
void sploder_walk7(entity this) { set_animofs(this, anim_blister_walk, 7, sploder_walk8); ai_walk(this, 3); }
void sploder_walk6(entity this) { set_animofs(this, anim_blister_walk, 6, sploder_walk7); ai_walk(this, 3); }
void sploder_walk5(entity this) { set_animofs(this, anim_blister_walk, 5, sploder_walk6); ai_walk(this, 3); SploderIdleNoise(this); }
void sploder_walk4(entity this) { set_animofs(this, anim_blister_walk, 4, sploder_walk5); ai_walk(this, 3); }
void sploder_walk3(entity this) { set_animofs(this, anim_blister_walk, 3, sploder_walk4); ai_walk(this, 4); }
void sploder_walk2(entity this) { set_animofs(this, anim_blister_walk, 2, sploder_walk3); ai_walk(this, 2); }
void sploder_walk1(entity this) { set_animofs(this, anim_blister_walk, 1, sploder_walk2); ai_walk(this, 3); }

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

void sploder_run11(entity this) { set_animofs(this, anim_blister_run, 11, sploder_run1); nmfast(this, 0.075); sploder_run(this, 28); }
void sploder_run10(entity this) { set_animofs(this, anim_blister_run, 10, sploder_run11); nmfast(this, 0.075); sploder_run(this, 28); }
void sploder_run9(entity this) { set_animofs(this, anim_blister_run, 9, sploder_run10); nmfast(this, 0.075); sploder_run(this, 28); }
void sploder_run8(entity this) { set_animofs(this, anim_blister_run, 8, sploder_run9); nmfast(this, 0.075); sploder_run(this, 28); }
void sploder_run7(entity this) { set_animofs(this, anim_blister_run, 7, sploder_run8); nmfast(this, 0.075); sploder_run(this, 28); }
void sploder_run6(entity this) { set_animofs(this, anim_blister_run, 6, sploder_run7); nmfast(this, 0.075); sploder_run(this, 28); }
void sploder_run5(entity this) { set_animofs(this, anim_blister_run, 5, sploder_run6); nmfast(this, 0.075); sploder_run(this, 28); }
void sploder_run4(entity this) { set_animofs(this, anim_blister_run, 4, sploder_run5); nmfast(this, 0.075); sploder_run(this, 28); }
void sploder_run3(entity this) { set_animofs(this, anim_blister_run, 3, sploder_run4); nmfast(this, 0.075); sploder_run(this, 28); }
void sploder_run2(entity this) { set_animofs(this, anim_blister_run, 2, sploder_run3); nmfast(this, 0.075); sploder_run(this, 28); }
void sploder_run1(entity this)
{
	set_animofs(this, anim_blister_run, 1, sploder_run2);
	nmfast(this, 0.075);
	sploder_run(this, 28);
	//Sploder_Forget(this);
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
