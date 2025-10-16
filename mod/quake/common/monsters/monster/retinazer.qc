#include "retinazer.qh"

#ifdef SVQC
.int bosswave;

void ret_run1(entity this);

/*
=================
RetinazerCheckAttack
=================
*/
bool RetinazerCheckAttack(entity this)
{
	if(time < this.attack_finished)
		return false;
	if(!this.enemy_visible)
		return false;

	if(this.enemy_range == RANGE_FAR)
	{
		if(this.attack_state != AS_STRAIGHT)
		{
			this.attack_state = AS_STRAIGHT;
			ret_run1(this);
		}
		return false;
	}
		
	entity targ = this.enemy;
	
// see if any entities are in the way of the shot
	vector spot1 = this.origin + this.view_ofs;
	vector spot2 = targ.origin + targ.view_ofs;

	traceline(spot1, spot2, false, this);

	if(trace_ent != targ)
	{	// don't have a clear shot, so move to a side
		if(this.attack_state != AS_SLIDING)
		{
			this.attack_state = AS_SLIDING;
			ret_run1(this);
		}
		return false;
	}

	float chance;	
	if(this.enemy_range == RANGE_MELEE)
		chance = 0.3;
	else if(this.enemy_range == RANGE_NEAR)
		chance = 0.6;
	else if(this.enemy_range == RANGE_MID)
		chance = 0.9;
	else
		chance = 0;

	if(random() < chance)
	{
		this.attack_state = AS_MISSILE;
		return true;
	}

	if(this.enemy_range == RANGE_MID)
	{
		if(this.attack_state != AS_SLIDING)
		{
			this.attack_state = AS_SLIDING;
			ret_run1(this);
		}
	}
	else
	{
		if(random() < 0.5)
		{
			if(this.attack_state != AS_DODGING)
			{
				this.attack_state = AS_DODGING;
				ret_run1(this);
			}
		}
		else
		{
			if(this.attack_state != AS_SLIDING)
			{
				this.attack_state = AS_SLIDING;
				ret_run1(this);
			}
		}
	}
	
	return false;
}

void ret_anim(entity this, void(entity) tnk)
{
	this.walkframe += 1;
	if(this.walkframe > 3)
		this.walkframe = 0;
	this.frame = this.walkframe;
	this.nextthink = time + 0.1;
	setthink(this, tnk);
}

void ret_stand1(entity this);
void ret_stand6(entity this) { ret_anim(this, ret_stand1); ai_stand(this); }
void ret_stand5(entity this) { ret_anim(this, ret_stand6); ai_stand(this); }
void ret_stand4(entity this) { ret_anim(this, ret_stand5); ai_stand(this); }
void ret_stand3(entity this) { ret_anim(this, ret_stand4); ai_stand(this); }
void ret_stand2(entity this) { ret_anim(this, ret_stand3); ai_stand(this); }
void ret_stand1(entity this) { ret_anim(this, ret_stand2); ai_stand(this); }

void ret_walk1(entity this);
void ret_walk6(entity this) { ret_anim(this, ret_walk1); ai_walk(this, 3); }
void ret_walk5(entity this) { ret_anim(this, ret_walk6); ai_walk(this, 3); }
void ret_walk4(entity this) { ret_anim(this, ret_walk5); ai_walk(this, 4); }
void ret_walk3(entity this) { ret_anim(this, ret_walk4); ai_walk(this, 3); }
void ret_walk2(entity this) { ret_anim(this, ret_walk3); ai_walk(this, 2); }
void ret_walk1(entity this) { ret_anim(this, ret_walk2); ai_walk(this, 3); }

void ret_attackframe(entity this)
{
	//ai_face(this);
	this.enemy_yaw = vectoyaw(this.enemy.origin - this.origin);
	ai_run_slide(this, 32);
}

void ret_run1(entity this);
void ret_laser(entity this);
void ret_atkd15(entity this) { ret_anim(this, ret_run1); this.attack_state = AS_DODGING; }
void ret_atkd14(entity this) { ret_anim(this, ret_atkd15); ret_attackframe(this); ret_laser(this); }
void ret_atkd13(entity this) { ret_anim(this, ret_atkd14); ret_attackframe(this); }
void ret_atkd12(entity this) { ret_anim(this, ret_atkd13); ret_attackframe(this); ret_laser(this); }
void ret_atkd11(entity this) { ret_anim(this, ret_atkd12); ret_attackframe(this); }
void ret_atkd10(entity this) { ret_anim(this, ret_atkd11); ret_attackframe(this); ret_laser(this); }
void ret_atkd9(entity this) { ret_anim(this, ret_atkd10); ret_attackframe(this); }
void ret_atkd8(entity this) { ret_anim(this, ret_atkd9); ret_attackframe(this); ret_laser(this); }
void ret_atkd7(entity this) { ret_anim(this, ret_atkd8); ret_attackframe(this); }
void ret_atkd6(entity this) { ret_anim(this, ret_atkd7); ret_attackframe(this); ret_laser(this); }
void ret_atkd5(entity this) { ret_anim(this, ret_atkd6); ret_attackframe(this); }
void ret_atkd4(entity this) { ret_anim(this, ret_atkd5); ret_attackframe(this); ret_laser(this); }
void ret_atkd3(entity this) { ret_anim(this, ret_atkd4); ret_attackframe(this); }
void ret_atkd2(entity this) { ret_anim(this, ret_atkd3); ret_attackframe(this); ret_laser(this); }
void ret_atkd1(entity this) { ret_anim(this, ret_atkd2); ret_attackframe(this); this.attack_finished = time + 2 + (random() * 2); }

void ret_spin(entity this, bool increase)
{
	if(increase)
		this.avelocity_x += 15;
	else
		this.avelocity_x -= 30;

	this.angles = this.angles + 0.1 * this.avelocity;
}

void ret_transform(entity this)
{
	vector oldmin = this.mins;
	vector oldmax = this.maxs;
	_setmodel(this, "progs/retinazer.mdl");
	setsize(this, oldmin, oldmax);

	sound(this, CH_VOICE, SND_MON_RETINAZER_SIGHT, 1, ATTN_BOSS);

	this.th_missile = ret_atkd1; // speedy attacks!
	this.bosswave += 1;

	ThrowGib(this, this, "progs/xtragib.mdl", this.health);
	ThrowGib(this, this, "progs/gib1.mdl", this.health);
	ThrowGib(this, this, "progs/bone.mdl", this.health);
	ThrowGib(this, this, "progs/gib2.mdl", this.health);
	ThrowGib(this, this, "progs/xtragib.mdl", this.health);
	ThrowGib(this, this, "progs/bone2.mdl", this.health);
	ThrowGib(this, this, "progs/gib1.mdl", this.health);
	ThrowGib(this, this, "progs/xtragib.mdl", this.health);
	ThrowGib(this, this, "progs/gib2.mdl", this.health);
	ThrowGib(this, this, "progs/xtragib.mdl", this.health);
	ThrowGib(this, this, "progs/rawbone.mdl", this.health);
	ThrowGib(this, this, "progs/gib3.mdl", this.health);

	if(this.tether_ent)
		tether_remove(this.tether_ent);
}

void ret_rise32(entity this) { ret_anim(this, ret_run1); this.avelocity = '0 0 0'; this.angles_x = 0; }
void ret_rise31(entity this) { ret_anim(this, ret_rise32); ret_spin(this, false); }
void ret_rise30(entity this) { ret_anim(this, ret_rise31); ret_spin(this, false); }
void ret_rise29(entity this) { ret_anim(this, ret_rise30); ret_spin(this, false); }
void ret_rise28(entity this) { ret_anim(this, ret_rise29); ret_spin(this, false); }
void ret_rise27(entity this) { ret_anim(this, ret_rise28); ret_transform(this); ret_spin(this, false); }
void ret_rise26(entity this) { ret_anim(this, ret_rise27); ret_spin(this, true); }
void ret_rise25(entity this) { ret_anim(this, ret_rise26); ret_spin(this, true); }
void ret_rise24(entity this) { ret_anim(this, ret_rise25); ret_spin(this, true); }
void ret_rise23(entity this) { ret_anim(this, ret_rise24); ret_spin(this, true); }
void ret_rise22(entity this) { ret_anim(this, ret_rise23); ret_spin(this, true); }
void ret_rise21(entity this) { ret_anim(this, ret_rise22); ret_spin(this, true); }
void ret_rise20(entity this) { ret_anim(this, ret_rise21); ret_spin(this, true); }
void ret_rise19(entity this) { ret_anim(this, ret_rise20); ret_spin(this, true); }
void ret_rise18(entity this) { ret_anim(this, ret_rise19); ret_spin(this, true); }
void ret_rise17(entity this) { ret_anim(this, ret_rise18); ret_spin(this, true); }
void ret_rise16(entity this) { ret_anim(this, ret_rise17); ret_spin(this, true); }
void ret_rise15(entity this) { ret_anim(this, ret_rise16); ret_spin(this, true); }
void ret_rise14(entity this) { ret_anim(this, ret_rise15); ret_spin(this, true); }
void ret_rise13(entity this) { ret_anim(this, ret_rise14); ret_spin(this, true); }
void ret_rise12(entity this) { ret_anim(this, ret_rise13); ret_spin(this, true); }
void ret_rise11(entity this) { ret_anim(this, ret_rise12); ret_spin(this, true); }
void ret_rise10(entity this) { ret_anim(this, ret_rise11); ret_spin(this, true); }
void ret_rise9(entity this) { ret_anim(this, ret_rise10); ret_spin(this, true); }
void ret_rise8(entity this) { ret_anim(this, ret_rise9); ret_spin(this, true); }
void ret_rise7(entity this) { ret_anim(this, ret_rise8); ret_spin(this, true); }
void ret_rise6(entity this) { ret_anim(this, ret_rise7); ret_spin(this, true); }
void ret_rise5(entity this) { ret_anim(this, ret_rise6); ret_spin(this, true); }
void ret_rise4(entity this) { ret_anim(this, ret_rise5); ret_spin(this, true); }
void ret_rise3(entity this) { ret_anim(this, ret_rise4); ret_spin(this, true); }
void ret_rise2(entity this) { ret_anim(this, ret_rise3); ret_spin(this, true); }
void ret_rise1(entity this)
{
	ret_anim(this, ret_rise2);
	settouch(this, func_null);
	//this.pain_finished = time + 4;
	this.avelocity = '0 0 0';
	ThrowGib(this, this, "progs/xtragib.mdl", this.health);
	ThrowGib(this, this, "progs/gib1.mdl", this.health);
	ThrowGib(this, this, "progs/bone.mdl", this.health);
}

void ret_run6(entity this) { ret_anim(this, ret_run1); ai_run(this, 36); }
void ret_run5(entity this) { ret_anim(this, ret_run6); ai_run(this, 39); }
void ret_run4(entity this) { ret_anim(this, ret_run5); ai_run(this, 38); }
void ret_run3(entity this) { ret_anim(this, ret_run4); ai_run(this, 39); }
void ret_run2(entity this) { ret_anim(this, ret_run3); ai_run(this, 36); }
void ret_run1(entity this)
{
	if(this.bosswave == 0 && this.health <= (this.max_health * 0.5))
	{
		ret_rise1(this);
		return;
	}

	ret_anim(this, ret_run2);
	ai_run(this, 32);
}

void ret_suck(entity this)
{
	if(!this.enemy)
		return;
	ai_charge(this, 0);
	if(vdist(this.enemy.origin - this.origin, >, 100))
		return;
	if(!CanDamage(this.enemy, this))
		return;
	float ldmg = (((random() + random()) + random()) * 10);
	T_Damage(this.enemy, this, this, ldmg, DEATH_MONSTER_RETINAZER.m_id);
	SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
	SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
	SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
	SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
	SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
	SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
}

void ret_laser(entity this)
{
	if(!this.enemy || this.enemy.health <= 0)
		return;

	entity targ = this.enemy;
	entity newmis = LaunchLaser(this, this.origin, targ.origin - this.origin);
	newmis.projectiledeathtype = DEATH_MONSTER_RETINAZER.m_id;
	_sound(this, CH_WEAPON_SINGLE, "twins/laser_fire.wav", 1, ATTN_NORM);
}

void ret_atk17(entity this) { ret_anim(this, ret_run1); ai_charge(this, 18); }
void ret_atk16(entity this) { ret_anim(this, ret_atk17); ai_charge(this, 19); ret_suck(this); }
void ret_atk15(entity this) { ret_anim(this, ret_atk16); ai_charge(this, 20); }
void ret_atk14(entity this) { ret_anim(this, ret_atk15); ai_charge(this, 21); }
void ret_atk13(entity this) { ret_anim(this, ret_atk14); ai_charge(this, 22); }
void ret_atk12(entity this) { ret_anim(this, ret_atk13); ai_charge(this, 23); ret_suck(this); }
void ret_atk11(entity this) { ret_anim(this, ret_atk12); ai_charge(this, 24); }
void ret_atk10(entity this) { ret_anim(this, ret_atk11); ai_charge(this, 25); }
void ret_atk9(entity this) { ret_anim(this, ret_atk10); ai_charge(this, 26); }
void ret_atk8(entity this) { ret_anim(this, ret_atk9); ai_charge(this, 27); ret_suck(this); }
void ret_atk7(entity this) { ret_anim(this, ret_atk8); ai_charge(this, 26); }
void ret_atk6(entity this) { ret_anim(this, ret_atk7); ai_charge(this, 25); }
void ret_atk5(entity this) { ret_anim(this, ret_atk6); ai_charge(this, 24); }
void ret_atk4(entity this) { ret_anim(this, ret_atk5); ai_charge(this, 23); ret_suck(this); }
void ret_atk3(entity this) { ret_anim(this, ret_atk4); ai_charge(this, 22); }
void ret_atk2(entity this) { ret_anim(this, ret_atk3); ai_charge(this, 21); }
void ret_atk1(entity this) { ret_anim(this, ret_atk2); ai_charge(this, 20); ret_suck(this); }

void ret_atkb10(entity this) { ret_anim(this, ret_run1); ret_attackframe(this); this.attack_state = AS_DODGING; }
void ret_atkb9(entity this) { ret_anim(this, ret_atkb10); ret_attackframe(this); ret_laser(this); }
void ret_atkb8(entity this) { ret_anim(this, ret_atkb9); ret_attackframe(this); }
void ret_atkb7(entity this) { ret_anim(this, ret_atkb8); ret_attackframe(this); }
void ret_atkb6(entity this) { ret_anim(this, ret_atkb7); ret_attackframe(this); }
void ret_atkb5(entity this) { ret_anim(this, ret_atkb6); ret_attackframe(this); ret_laser(this); }
void ret_atkb4(entity this) { ret_anim(this, ret_atkb5); ret_attackframe(this); }
void ret_atkb3(entity this) { ret_anim(this, ret_atkb4); ret_attackframe(this); }
void ret_atkb2(entity this) { ret_anim(this, ret_atkb3); ret_attackframe(this); }
void ret_atkb1(entity this) { ret_anim(this, ret_atkb2); ret_attackframe(this); this.attack_finished = time + 2 + (random() * 2); ret_laser(this); }

void ret_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;
	if(this.health <= 0)
		return;
	if(this.bosswave >= 1)
		_sound(this, CH_VOICE, "twins/hit.wav", 1, ATTN_BOSS);
	else
		_sound(this, CH_VOICE, "eoc/pain.wav", 1, ATTN_BOSS);
	this.pain_finished = time + 0.2;
}

void gib_ret(entity this)
{
	_sound(this, CH_VOICE, "twins/explode.wav", 1, ATTN_BOSS);
	settouch(this, func_null);

	Send_Effect(EFFECT_EXPLOSION_SMALL, CENTER_OR_VIEWOFS(this), '0 0 0', 1);
	ThrowHead(this, this, "progs/rawbone.mdl", this.health);
}

void ret_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	gib_ret(this);
}

//spawnfunc(monster_retinazer) { monster_start(this, true, MON_RETINAZER); }
#endif // SVQC

#ifdef SVQC
METHOD(Retinazer, mr_setup, bool(Retinazer this, entity actor))
{
    TC(Retinazer, this);

	precache_model("progs/retinazer.mdl");
	precache_model("progs/xtragib.mdl");
	precache_model("progs/bone.mdl");
	precache_model("progs/bone2.mdl");
	precache_model("progs/rawbone2.mdl");
	precache_sound("eoc/death.wav");
	precache_sound("eoc/pain.wav");
	precache_sound("twins/explode.wav");
	precache_sound("twins/laser_fire.wav");
	precache_sound("twins/hit.wav");

	actor.bosswave = 0;
	actor.skin = 1;

    actor.health = 3000;
	actor.th_stand = ret_stand1;
	actor.th_walk = ret_walk1;
	actor.th_run = ret_run1;
	actor.th_melee = ret_atk1;
	actor.th_missile = ret_atkb1;
	actor.th_pain = ret_pain;
	actor.th_die = ret_die;

	actor.checkattack = RetinazerCheckAttack;

    return true;
}
#endif
