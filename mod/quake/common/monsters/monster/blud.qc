#include "blud.qh"

#ifdef SVQC
void blud_stand1(entity this);
void blud_stand6(entity this) { set_anim(this, 6, blud_stand1); ai_stand(this); }
void blud_stand5(entity this) { set_anim(this, 5, blud_stand6); ai_stand(this); }
void blud_stand4(entity this) { set_anim(this, 4, blud_stand5); ai_stand(this); }
void blud_stand3(entity this) { set_anim(this, 3, blud_stand4); ai_stand(this); }
void blud_stand2(entity this) { set_anim(this, 2, blud_stand3); ai_stand(this); }
void blud_stand1(entity this)
{
	set_anim(this, 1, blud_stand2);
	if(random() < 0.2)
		_sound(this, CHAN_AUTO, "monsters/blud/blidle3.wav", 1, ATTN_NORM);
	ai_stand(this);
}

void blud_walk1(entity this);
void blud_walk6(entity this) { set_anim(this, 12, blud_walk1); ai_walk(this, 3); }
void blud_walk5(entity this) { set_anim(this, 11, blud_walk6); ai_walk(this, 3); }
void blud_walk4(entity this) { set_anim(this, 10, blud_walk5); ai_walk(this, 4); }
void blud_walk3(entity this) { set_anim(this, 9, blud_walk4); ai_walk(this, 3); }
void blud_walk2(entity this) { set_anim(this, 8, blud_walk3); ai_walk(this, 2); }
void blud_walk1(entity this)
{
	set_anim(this, 7, blud_walk2);
	if(random() < 0.2)
		_sound(this, CHAN_AUTO, "monsters/blud/blidle4.wav", 1, ATTN_NORM);
	ai_walk(this, 3);
}

void Blud_JumpTouch(entity this, entity toucher)
{
	if(this.health <= 0 || !this.takedamage)
		return;
	if(toucher.takedamage)
	{
		float admg = 20;
		if(this.flags & FL_FLY)
			admg *= 1.5;
		float ldmg = ((random() + random()) + random()) * admg;
		T_Damage(toucher, this, this, ldmg, DEATH_MONSTER_BLUD.m_id);
		_sound(this, CHAN_BODY, "monsters/blud/blood.wav", 1, ATTN_NORM);
		SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
		SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
		SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
		SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
		SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
		SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
	}
	settouch(this, func_null);
}

void blud_run1(entity this);
void blud_die1(entity this);
void blud_atkc6(entity this) { set_anim(this, 28, blud_run1); ai_face(this); settouch(this, func_null); }
void blud_atkc5(entity this) { set_anim(this, 27, blud_atkc6); ai_face(this); }
void blud_atkc4(entity this) { set_anim(this, 26, blud_atkc5); ai_face(this); }
void blud_atkc3(entity this) { set_anim(this, 25, blud_atkc4); ai_face(this); }
void blud_atkc2(entity this) { set_anim(this, 24, blud_atkc3); ai_face(this); }
void blud_atkc1(entity this)
{
	set_anim(this, 23, blud_atkc2);
	if(this.health <= 0)
	{
		LOG_DEBUG("blud_atkc1: dead");
		settouch(this, func_null);
		setthink(this, blud_die1);
		return;
	}
	ai_face(this);
	_sound(this, CHAN_AUTO, "monsters/blud/blatt2.wav", 1, ATTN_NORM);
	makevectors(this.angles);
	settouch(this, Blud_JumpTouch);
	this.origin_z = this.origin_z + 1;
	setorigin(this, this.origin);
	this.attack_finished = time + 1 + (random() * 2);
	this.velocity = ((v_forward * 600) + '0 0 250');
	UNSET_ONGROUND(this);
}

void blud_movetogoal(entity this, float dist)
{
	if(StatusEffects_active(STATUSEFFECT_Slowness, this))
		dist *= 0.5;

	this.enemy_range = range(this, this.enemy);

	if(this.enemy && this.enemy_range == RANGE_MELEE && gettouch(this) && ai_checkmelee(this, 100, false))
		gettouch(this)(this, this.enemy);

	if(!t_stepdirection(this, this.ideal_yaw, dist))
	{
		settouch(this, func_null);
		setthink(this, blud_run1);
	}
}

void blud_run1(entity this);
void blud_die1(entity this);
void blud_atkd15(entity this) { set_anim(this, 28, blud_run1); blud_movetogoal(this, 30); settouch(this, func_null); }
void blud_atkd14(entity this) { set_anim(this, 27, blud_atkd15); blud_movetogoal(this, 60); }
void blud_atkd13(entity this) { set_anim(this, 27, blud_atkd14); blud_movetogoal(this, 60); }
void blud_atkd12(entity this) { set_anim(this, 27, blud_atkd13); blud_movetogoal(this, 60); }
void blud_atkd11(entity this) { set_anim(this, 27, blud_atkd12); blud_movetogoal(this, 60); }
void blud_atkd10(entity this) { set_anim(this, 27, blud_atkd11); blud_movetogoal(this, 60); }
void blud_atkd9(entity this) { set_anim(this, 27, blud_atkd10); blud_movetogoal(this, 60); }
void blud_atkd8(entity this) { set_anim(this, 27, blud_atkd9); blud_movetogoal(this, 60); }
void blud_atkd7(entity this) { set_anim(this, 27, blud_atkd8); blud_movetogoal(this, 60); }
void blud_atkd6(entity this) { set_anim(this, 27, blud_atkd7); blud_movetogoal(this, 60); }
void blud_atkd5(entity this) { set_anim(this, 27, blud_atkd6); }
void blud_atkd4(entity this) { set_anim(this, 26, blud_atkd5); }
void blud_atkd3(entity this) { set_anim(this, 25, blud_atkd4); }
void blud_atkd2(entity this) { set_anim(this, 24, blud_atkd3); }
void blud_atkd1(entity this)
{
	set_anim(this, 23, blud_atkd2);
	if(this.health <= 0)
	{
		LOG_DEBUG("blud_atkc1: dead");
		settouch(this, func_null);
		setthink(this, blud_die1);
		return;
	}
	this.attack_finished = time + 2 + (random() * 2);
	ai_face(this);
	_sound(this, CHAN_AUTO, "monsters/blud/blatt2.wav", 1, ATTN_NORM);
	settouch(this, Blud_JumpTouch);
}

void blud_rise(entity this)
{
	// code copied from t_movestep
	vector neworg = this.origin + '0 0 8';

	tracebox(this.origin, this.mins, this.maxs, neworg, MOVE_NORMAL, this);
	if(trace_fraction == 1)
	{
		this.origin = trace_endpos;
		_Movetype_LinkEdict(this, true);
	}
}

void blud_rise32(entity this) { set_anim(this, 51, blud_run1); }
void blud_rise31(entity this) { set_anim(this, 50, blud_rise32); }
void blud_rise30(entity this) { set_anim(this, 51, blud_rise31); blud_rise(this); }
void blud_rise29(entity this) { set_anim(this, 52, blud_rise30); blud_rise(this); }
void blud_rise28(entity this) { set_anim(this, 53, blud_rise29); blud_rise(this); }
void blud_rise27(entity this) { set_anim(this, 54, blud_rise28); blud_rise(this); }
void blud_rise26(entity this) { set_anim(this, 55, blud_rise27); blud_rise(this); }
void blud_rise25(entity this) { set_anim(this, 56, blud_rise26); blud_rise(this); }
void blud_rise24(entity this) { set_anim(this, 57, blud_rise25); blud_rise(this); }
void blud_rise23(entity this) { set_anim(this, 58, blud_rise24); blud_rise(this); }
void blud_rise22(entity this) { set_anim(this, 59, blud_rise23); blud_rise(this); }
void blud_rise21(entity this) { set_anim(this, 60, blud_rise22); blud_rise(this); }
void blud_rise20(entity this) { set_anim(this, 61, blud_rise21); }
void blud_rise19(entity this) { set_anim(this, 62, blud_rise20); }
void blud_rise18(entity this) { set_anim(this, 63, blud_rise19); }
void blud_rise17(entity this) { set_anim(this, 64, blud_rise18); }
void blud_rise16(entity this) { set_anim(this, 65, blud_rise17); }
void blud_rise15(entity this) { set_anim(this, 64, blud_rise16); }
void blud_rise14(entity this) { set_anim(this, 63, blud_rise15); }
void blud_rise13(entity this) { set_anim(this, 62, blud_rise14); }
void blud_rise12(entity this) { set_anim(this, 61, blud_rise13); }
void blud_rise11(entity this) { set_anim(this, 60, blud_rise12); }
void blud_rise10(entity this) { set_anim(this, 59, blud_rise11); }
void blud_rise9(entity this) { set_anim(this, 58, blud_rise10); }
void blud_rise8(entity this) { set_anim(this, 57, blud_rise9); }
void blud_rise7(entity this) { set_anim(this, 56, blud_rise8); }
void blud_rise6(entity this) { set_anim(this, 55, blud_rise7); }
void blud_rise5(entity this) { set_anim(this, 54, blud_rise6); }
void blud_rise4(entity this) { set_anim(this, 53, blud_rise5); }
void blud_rise3(entity this) { set_anim(this, 52, blud_rise4); }
void blud_rise2(entity this) { set_anim(this, 51, blud_rise3); }
void blud_rise1(entity this)
{
	set_anim(this, 50, blud_rise2);
	this.flags |= FL_FLY;
	settouch(this, func_null);
	this.pain_finished = time + 4;
	set_movetype(this, MOVETYPE_QCENTITY); // NOTE: we don't use MOVETYPE_STEP because of a bug in Xonotic's code; FL_FLY shouldn't apply gravity
	_sound(this, CHAN_AUTO, "monsters/blud/blidle1.wav", 1, ATTN_NORM);
	ThrowGib(this, this, "progs/xtragib.mdl", this.health);
	ThrowGib(this, this, "progs/gib1.mdl", this.health);
	ThrowGib(this, this, "progs/bone.mdl", this.health);

	UNSET_ONGROUND(this);
	this.velocity = '0 0 0';
}

void blud_run6(entity this) { set_anim(this, 12, blud_run1); ai_run(this, 20); }
void blud_run5(entity this) { set_anim(this, 11, blud_run6); ai_run(this, 24); }
void blud_run4(entity this) { set_anim(this, 10, blud_run5); ai_run(this, 22); }
void blud_run3(entity this) { set_anim(this, 9, blud_run4); ai_run(this, 24); }
void blud_run2(entity this) { set_anim(this, 8, blud_run3); ai_run(this, 20); }
void blud_run1(entity this)
{
	// hard skill phase: start flying and dash at target
	if(!(this.flags & FL_FLY) && this.health <= (this.max_health * 0.5) && autocvar_skill >= 2)
	{
		blud_rise1(this);
		return;
	}

	set_anim(this, 7, blud_run2);
	if(this.flags & FL_FLY)
	{
		if(random() < 0.2)
		{
			blud_atkd1(this);
			return;
		}
	}
	else if(random() < 0.6)
	{
		if(random() < 0.1)
			_sound(this, CHAN_AUTO, "monsters/blud/blidle1.wav", 1, ATTN_NORM);
		else if(random() < 0.2)
			_sound(this, CHAN_AUTO, "monsters/blud/blidle2.wav", 1, ATTN_NORM);
		blud_atkc1(this);
		return;
	}
	ai_run(this, 16);
}

void blud_suck(entity this)
{
	if(!this.enemy)
		return;
	ai_charge(this, 0);
	if(vdist(this.enemy.origin - this.origin, >, 100))
		return;
	if(!CanDamage(this.enemy, this))
		return;
	float ldmg = (((random() + random()) + random()) * 10);
	T_Damage(this.enemy, this, this, ldmg, DEATH_MONSTER_BLUD.m_id);
	_sound(this, CHAN_AUTO, "monsters/blud/blidle3.wav", 1, ATTN_NORM);
	SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
	SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
	SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
	SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
	SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
	SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
}

void blud_atk17(entity this) { set_anim(this, 45, blud_run1); ai_charge(this, 18); }
void blud_atk16(entity this) { set_anim(this, 44, blud_atk17); ai_charge(this, 19); blud_suck(this); }
void blud_atk15(entity this) { set_anim(this, 43, blud_atk16); ai_charge(this, 20); }
void blud_atk14(entity this) { set_anim(this, 42, blud_atk15); ai_charge(this, 21); }
void blud_atk13(entity this) { set_anim(this, 41, blud_atk14); ai_charge(this, 22); }
void blud_atk12(entity this) { set_anim(this, 40, blud_atk13); ai_charge(this, 23); blud_suck(this); }
void blud_atk11(entity this) { set_anim(this, 39, blud_atk12); ai_charge(this, 24); }
void blud_atk10(entity this) { set_anim(this, 38, blud_atk11); ai_charge(this, 25); }
void blud_atk9(entity this) { set_anim(this, 37, blud_atk10); ai_charge(this, 26); }
void blud_atk8(entity this) { set_anim(this, 36, blud_atk9); ai_charge(this, 27); blud_suck(this); }
void blud_atk7(entity this) { set_anim(this, 35, blud_atk8); ai_charge(this, 26); }
void blud_atk6(entity this) { set_anim(this, 34, blud_atk7); ai_charge(this, 25); }
void blud_atk5(entity this) { set_anim(this, 33, blud_atk6); ai_charge(this, 24); }
void blud_atk4(entity this) { set_anim(this, 32, blud_atk5); ai_charge(this, 23); blud_suck(this); }
void blud_atk3(entity this) { set_anim(this, 31, blud_atk4); ai_charge(this, 22); }
void blud_atk2(entity this) { set_anim(this, 30, blud_atk3); ai_charge(this, 21); }
void blud_atk1(entity this) { set_anim(this, 29, blud_atk2); ai_charge(this, 20); blud_suck(this); }

void BludGrenadeTouch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;
	if(toucher.takedamage)
	{
		T_Damage(toucher, this, this.owner, 10, DEATH_MONSTER_BLUD.m_id);
		_sound(this, CHAN_WEAPON, "zombie/z_hit.wav", 1, ATTN_NORM);
		SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
		SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
		SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
		delete(this);
		return;
	}
	if(this.velocity == '0 0 0')
		this.avelocity = '0 0 0';
	if(this.cnt != 0)
	{
		_sound(this, CHAN_WEAPON, "zombie/z_miss.wav", 1, ATTN_NORM);
		SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
		SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
		SpawnMeatSpray(this, (this.origin + (v_forward * 16)), ((crandom() * 100) * v_right));
		delete(this);
		return;
	}
	this.cnt = 1;
}

void BludFireGrenade(entity this)
{
	_sound(this, CHAN_AUTO, "monsters/blud/blatt1.wav", 1, ATTN_NORM);
	entity missile = spawn();
	missile.owner = this;
	set_movetype(missile, MOVETYPE_BOUNCE);
	missile.solid = SOLID_BBOX;
	vector org = this.origin;
	makevectors(this.angles);
	missile.velocity = normalize(this.enemy.origin - org);
	missile.velocity = missile.velocity * 900;
	missile.velocity_z = 100;
	missile.avelocity = '3000 1000 2000';
	settouch(missile, BludGrenadeTouch);
	missile.nextthink = time + 2.5;
	setthink(missile, SUB_Remove);
	_setmodel(missile, "progs/bone2.mdl");
	setsize(missile, '0 0 0', '0 0 0');
	setorigin(missile, org);
}

void BludFireGrenade2(entity this)
{
	entity missile = spawn();
	missile.owner = this;
	set_movetype(missile, MOVETYPE_BOUNCE);
	missile.solid = SOLID_BBOX;
	vector org = this.origin;
	makevectors(this.angles);
	missile.velocity = normalize(this.enemy.origin - org);
	missile.velocity = missile.velocity * 700;
	missile.velocity_z = 90;
	missile.avelocity = '3000 1000 2000';
	settouch(missile, BludGrenadeTouch);
	missile.nextthink = time + 2.5;
	setthink(missile, SUB_Remove);
	_setmodel(missile, "progs/gib2.mdl");
	setsize(missile, '0 0 0', '0 0 0');
	setorigin(missile, org);
}

void BludFireGrenade3(entity this)
{
	entity missile = spawn();
	missile.owner = this;
	set_movetype(missile, MOVETYPE_BOUNCE);
	missile.solid = SOLID_BBOX;
	vector org = this.origin;
	makevectors(this.angles);
	missile.velocity = normalize(this.enemy.origin - org);
	missile.velocity = missile.velocity * 500;
	missile.velocity_z = 80;
	missile.avelocity = '3000 1000 2000';
	settouch(missile, BludGrenadeTouch);
	missile.nextthink = time + 2.5;
	setthink(missile, SUB_Remove);
	_setmodel(missile, "progs/gib3.mdl");
	setsize(missile, '0 0 0', '0 0 0');
	setorigin(missile, org);
}

void blud_atkb10(entity this) { set_anim(this, 22, blud_run1); ai_face(this); }
void blud_atkb9(entity this) { set_anim(this, 21, blud_atkb10); ai_face(this); BludFireGrenade3(this); }
void blud_atkb8(entity this) { set_anim(this, 20, blud_atkb9); ai_face(this); }
void blud_atkb7(entity this) { set_anim(this, 19, blud_atkb8); ai_face(this); }
void blud_atkb6(entity this) { set_anim(this, 18, blud_atkb7); ai_face(this); BludFireGrenade2(this); }
void blud_atkb5(entity this) { set_anim(this, 17, blud_atkb6); ai_face(this); }
void blud_atkb4(entity this) { set_anim(this, 16, blud_atkb5); ai_face(this); }
void blud_atkb3(entity this) { set_anim(this, 15, blud_atkb4); ai_face(this); BludFireGrenade(this); }
void blud_atkb2(entity this) { set_anim(this, 14, blud_atkb3); ai_face(this); }
void blud_atkb1(entity this) { set_anim(this, 13, blud_atkb2); ai_face(this); }

void blud_pain4(entity this) { set_anim(this, 49, blud_run1); }
void blud_pain3(entity this) { set_anim(this, 48, blud_pain4); }
void blud_pain2(entity this) { set_anim(this, 47, blud_pain3); }
void blud_pain1(entity this) { set_anim(this, 46, blud_pain2); }

void blud_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;
	if((random() * 400) > damage)
		return;
	if(this.health <= 0)
		return;
	if(random() < 0.2)
		_sound(this, CHAN_AUTO, "monsters/blud/blhurt2.wav", 1, ATTN_NORM);
	else if(random() < 0.4)
		_sound(this, CHAN_AUTO, "monsters/blud/blhurt3.wav", 1, ATTN_NORM);
	else if(random() < 0.6)
		 _sound(this, CHAN_AUTO, "monsters/blud/blhurt1.wav", 1, ATTN_NORM);
	this.pain_finished = time + 2;
	blud_pain1(this);
}

void gib_blud(entity this)
{
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
	ThrowHead(this, this, "progs/rawbone.mdl", this.health);
}

void blud_die46(entity this) { set_anim(this, 65, blud_die46); gib_blud(this); }
void blud_die45(entity this) { set_anim(this, 64, blud_die46); }
void blud_die44(entity this)
{
	set_anim(this, 63, blud_die45);
	ThrowGib(this, this, "progs/rawbone.mdl", this.health);
	ThrowGib(this, this, "progs/xtragib.mdl", this.health);
}
void blud_die43(entity this) { set_anim(this, 62, blud_die44); }
void blud_die42(entity this) { set_anim(this, 61, blud_die43); ThrowGib(this, this, "progs/gib1.mdl", this.health); }
void blud_die41(entity this) { set_anim(this, 60, blud_die42); }
void blud_die40(entity this)
{
	set_anim(this, 59, blud_die41);
	ThrowGib(this, this, "progs/xtragib.mdl", this.health);
	ThrowGib(this, this, "progs/bone.mdl", this.health);
}
void blud_die39(entity this) { set_anim(this, 58, blud_die40); }
void blud_die38(entity this) { set_anim(this, 57, blud_die39); }
void blud_die37(entity this)
{
	set_anim(this, 56, blud_die38);
	ThrowGib(this, this, "progs/xtragib.mdl", this.health);
	ThrowGib(this, this, "progs/gib2.mdl", this.health);
}
void blud_die36(entity this) { set_anim(this, 55, blud_die37); }
void blud_die35(entity this) { set_anim(this, 54, blud_die36); }
void blud_die34(entity this) { set_anim(this, 53, blud_die35); }
void blud_die33(entity this)
{
	set_anim(this, 52, blud_die34);
	ThrowGib(this, this, "progs/xtragib.mdl", this.health);
	ThrowGib(this, this, "progs/gib2.mdl", this.health);
}
void blud_die32(entity this) { set_anim(this, 51, blud_die33); }
void blud_die31(entity this) { set_anim(this, 50, blud_die32); ThrowGib(this, this, "progs/xtragib.mdl", this.health); }
void blud_die30(entity this) { set_anim(this, 51, blud_die31); }
void blud_die29(entity this) { set_anim(this, 52, blud_die30); }
void blud_die28(entity this) { set_anim(this, 53, blud_die29); ThrowGib(this, this, "progs/xtragib.mdl", this.health); }
void blud_die27(entity this) { set_anim(this, 54, blud_die28); }
void blud_die26(entity this) { set_anim(this, 55, blud_die27); }
void blud_die25(entity this) { set_anim(this, 56, blud_die26); ThrowGib(this, this, "progs/bone.mdl", this.health); }
void blud_die24(entity this) { set_anim(this, 57, blud_die25); }
void blud_die23(entity this) { set_anim(this, 58, blud_die24); }
void blud_die22(entity this)
{
	set_anim(this, 59, blud_die23);
	ThrowGib(this, this, "progs/bone.mdl", this.health);
	ThrowGib(this, this, "progs/xtragib.mdl", this.health);
}
void blud_die21(entity this) { set_anim(this, 60, blud_die22); }
void blud_die20(entity this) { set_anim(this, 61, blud_die21); }
void blud_die19(entity this) { set_anim(this, 62, blud_die20); }
void blud_die18(entity this) { set_anim(this, 63, blud_die19); ThrowGib(this, this, "progs/xtragib.mdl", this.health); }
void blud_die17(entity this) { set_anim(this, 64, blud_die18); }
void blud_die16(entity this) { set_anim(this, 65, blud_die17); ThrowGib(this, this, "progs/rawbone.mdl", this.health); }
void blud_die15(entity this) { set_anim(this, 64, blud_die16); }
void blud_die14(entity this) { set_anim(this, 63, blud_die15); ThrowGib(this, this, "progs/xtragib.mdl", this.health); }
void blud_die13(entity this) { set_anim(this, 62, blud_die14); }
void blud_die12(entity this) { set_anim(this, 61, blud_die13); }
void blud_die11(entity this)
{
	set_anim(this, 60, blud_die12);
	ThrowGib(this, this, "progs/xtragib.mdl", this.health);
	ThrowGib(this, this, "progs/gib1.mdl", this.health);
	ThrowGib(this, this, "progs/xtragib.mdl", this.health);
	ThrowGib(this, this, "progs/bone.mdl", this.health);
}
void blud_die10(entity this) { set_anim(this, 59, blud_die11); }
void blud_die9(entity this) { set_anim(this, 58, blud_die10); }
void blud_die8(entity this) { set_anim(this, 57, blud_die9); }
void blud_die7(entity this) { set_anim(this, 56, blud_die8); ThrowGib(this, this, "progs/xtragib.mdl", this.health); }
void blud_die6(entity this) { set_anim(this, 55, blud_die7); }
void blud_die5(entity this) { set_anim(this, 54, blud_die6); }
void blud_die4(entity this) { set_anim(this, 53, blud_die5); ThrowGib(this, this, "progs/xtragib.mdl", this.health); }
void blud_die3(entity this) { set_anim(this, 52, blud_die4); }
void blud_die2(entity this)
{
	set_anim(this, 51, blud_die3);
	ThrowGib(this, this, "progs/xtragib.mdl", this.health);
	ThrowGib(this, this, "progs/gib1.mdl", this.health);
	ThrowGib(this, this, "progs/bone.mdl", this.health);
}
void blud_die1(entity this)
{
	set_anim(this, 50, blud_die2);
	_sound(this, CHAN_AUTO, "monsters/blud/bldie.wav", 1, ATTN_NORM);
	this.th_die = func_null;
}
void blud_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	if(this.health < -150)
	{
		gib_blud(this);
		return;
	}
	blud_die1(this);
}

spawnfunc(monster_blud)
{
	monster_start(this, true, MON_BLUD);
}
#endif // SVQC

#ifdef SVQC
METHOD(Blud, mr_setup, bool(Blud this, entity actor))
{
    TC(Blud, this);

	precache_model("progs/xtragib.mdl");
	precache_model("progs/bone.mdl");
	precache_model("progs/bone2.mdl");
	precache_model("progs/rawbone2.mdl");
	precache_sound("monsters/blud/blatt1.wav");
	precache_sound("monsters/blud/blatt2.wav");
	precache_sound("monsters/blud/bldie.wav");
	precache_sound("monsters/blud/blhurt1.wav");
	precache_sound("monsters/blud/blhurt2.wav");
	precache_sound("monsters/blud/blhurt3.wav");
	precache_sound("monsters/blud/blidle1.wav");
	precache_sound("monsters/blud/blidle2.wav");
	precache_sound("monsters/blud/blidle3.wav");
	precache_sound("monsters/blud/blidle4.wav");
	precache_sound("monsters/blud/blood.wav");
	precache_sound("zombie/z_miss.wav");
	precache_sound("zombie/z_hit.wav");

    actor.health = 3000;
	actor.th_stand = blud_stand1;
	actor.th_walk = blud_walk1;
	actor.th_run = blud_run1;
	actor.th_melee = blud_atk1;
	actor.th_missile = blud_atkb1;
	actor.th_pain = blud_pain;
	actor.th_die = blud_die;

    return true;
}
#endif
