#include "lightning_enforcer.qh"

#ifdef SVQC
void lenforcer_fire(entity this)
{
	int cont = Mod_Q1BSP_SuperContentsFromNativeContents(pointcontents(this.origin));
	if(cont & DPCONTENTS_LIQUIDSMASK)
	{
		T_RadiusDamage(this, this, 35 * 4, DEATH_DISCHARGE.m_id, NULL);
		return;
	}

	this.effects |= EF_MUZZLEFLASH;
	ai_face(this);
	_sound(this, CHAN_WEAPON, "weapons/light2/lghit2.wav", 1, ATTN_NORM);
	vector org = ((this.origin + '0 0 12') - (v_right * 8));
	vector dir = normalize((this.enemy.origin + '0 0 16') - org);
	traceline(org, (this.origin + (dir * 350)), true, this);
	//te_lightning2(NULL, org, trace_endpos); // should be this
	SendCSQCLightningBeam(org, trace_endpos);
	LightningDamage(this.origin, trace_endpos + (v_forward * 4), this, 3, DEATH_MONSTER_LENFORCER.m_id);
}

void lenf_stand1(entity this);
void lenf_stand7(entity this) { set_anim(this, 6, lenf_stand1); ai_stand(this); }
void lenf_stand6(entity this) { set_anim(this, 5, lenf_stand7); ai_stand(this); }
void lenf_stand5(entity this) { set_anim(this, 4, lenf_stand6); ai_stand(this); }
void lenf_stand4(entity this) { set_anim(this, 3, lenf_stand5); ai_stand(this); }
void lenf_stand3(entity this) { set_anim(this, 2, lenf_stand4); ai_stand(this); }
void lenf_stand2(entity this) { set_anim(this, 1, lenf_stand3); ai_stand(this); }
void lenf_stand1(entity this) { set_anim(this, 0, lenf_stand2); ai_stand(this); }

void lenf_walk1(entity this);
void lenf_walk16(entity this) { set_anim(this, 22, lenf_walk1); ai_walk(this, 2); }
void lenf_walk15(entity this) { set_anim(this, 21, lenf_walk16); ai_walk(this, 4); }
void lenf_walk14(entity this) { set_anim(this, 20, lenf_walk15); ai_walk(this, 3); }
void lenf_walk13(entity this) { set_anim(this, 19, lenf_walk14); ai_walk(this, 2); }
void lenf_walk12(entity this) { set_anim(this, 18, lenf_walk13); ai_walk(this, 1); }
void lenf_walk11(entity this) { set_anim(this, 17, lenf_walk12); ai_walk(this, 4); }
void lenf_walk10(entity this) { set_anim(this, 16, lenf_walk11); ai_walk(this, 4); }
void lenf_walk9(entity this) { set_anim(this, 15, lenf_walk10); ai_walk(this, 2); }
void lenf_walk8(entity this) { set_anim(this, 14, lenf_walk9); ai_walk(this, 1); }
void lenf_walk7(entity this) { set_anim(this, 13, lenf_walk8); ai_walk(this, 2); }
void lenf_walk6(entity this) { set_anim(this, 12, lenf_walk7); ai_walk(this, 2); }
void lenf_walk5(entity this) { set_anim(this, 11, lenf_walk6); ai_walk(this, 1); }
void lenf_walk4(entity this) { set_anim(this, 10, lenf_walk5); ai_walk(this, 3); }
void lenf_walk3(entity this) { set_anim(this, 9, lenf_walk4); ai_walk(this, 4); }
void lenf_walk2(entity this) { set_anim(this, 8, lenf_walk3); ai_walk(this, 4); }
void lenf_walk1(entity this)
{
	set_anim(this, 7, lenf_walk2);
	if(random() < 0.2)
		_sound(this, CHAN_AUTO, "monsters/lenforce/leidle1.wav", 1, ATTN_IDLE);
	ai_walk(this, 2);
}

void lenf_run1(entity this);
void lenf_atk1(entity this);
void lenf_atk14(entity this)
{
	set_anim(this, 40, lenf_run1);
	ai_face(this);
}
void lenf_atk13(entity this) { set_anim(this, 39, lenf_atk14); ai_face(this); }
void lenf_atk12(entity this) { set_anim(this, 38, lenf_atk13); ai_face(this); }
void lenf_atk11(entity this) { set_anim(this, 37, lenf_atk12); ai_face(this); }
void lenf_atk10(entity this) { set_anim(this, 36, lenf_atk11); lenforcer_fire(this); }
void lenf_atk9(entity this) { set_anim(this, 35, lenf_atk10); lenforcer_fire(this); }
void lenf_atk8(entity this) { set_anim(this, 38, lenf_atk9); lenforcer_fire(this); }
void lenf_atk7(entity this) { set_anim(this, 37, lenf_atk8); lenforcer_fire(this); }
void lenf_atk6(entity this) { set_anim(this, 36, lenf_atk7); lenforcer_fire(this); }
void lenf_atk5(entity this) { set_anim(this, 35, lenf_atk6); ai_face(this); }
void lenf_atk4(entity this) { set_anim(this, 34, lenf_atk5); ai_face(this); }
void lenf_atk3(entity this) { set_anim(this, 33, lenf_atk4); ai_face(this); }
void lenf_atk2(entity this) { set_anim(this, 32, lenf_atk3); ai_face(this); }
void lenf_atk1(entity this) { set_anim(this, 31, lenf_atk2); ai_face(this); }

void lenf_run8(entity this) { set_anim(this, 30, lenf_run1); ai_run(this, 11); }
void lenf_run7(entity this) { set_anim(this, 29, lenf_run8); ai_run(this, 7); }
void lenf_run6(entity this) { set_anim(this, 28, lenf_run7); ai_run(this, 14); }
void lenf_run5(entity this) { set_anim(this, 27, lenf_run6); ai_run(this, 14); }
void lenf_run4(entity this) { set_anim(this, 26, lenf_run5); ai_run(this, 12); }
void lenf_run3(entity this) { set_anim(this, 25, lenf_run4); ai_run(this, 7); }
void lenf_run2(entity this) { set_anim(this, 24, lenf_run3); ai_run(this, 14); }
void lenf_run1(entity this)
{
	set_anim(this, 23, lenf_run2);
	if(random() < 0.2)
		_sound(this, CHAN_AUTO, "monsters/lenforce/leidle1.wav", 1, ATTN_IDLE);
	ai_run(this, 18);
}

void lenf_paina4(entity this) { set_anim(this, 69, lenf_run1); }
void lenf_paina3(entity this) { set_anim(this, 68, lenf_paina4); }
void lenf_paina2(entity this) { set_anim(this, 67, lenf_paina3); }
void lenf_paina1(entity this) { set_anim(this, 66, lenf_paina2); }

void lenf_painb5(entity this) { set_anim(this, 74, lenf_run1); }
void lenf_painb4(entity this) { set_anim(this, 73, lenf_painb5); }
void lenf_painb3(entity this) { set_anim(this, 72, lenf_painb4); }
void lenf_painb2(entity this) { set_anim(this, 71, lenf_painb3); }
void lenf_painb1(entity this) { set_anim(this, 70, lenf_painb2); }

void lenf_painc8(entity this) { set_anim(this, 82, lenf_run1); }
void lenf_painc7(entity this) { set_anim(this, 81, lenf_painc8); }
void lenf_painc6(entity this) { set_anim(this, 80, lenf_painc7); }
void lenf_painc5(entity this) { set_anim(this, 79, lenf_painc6); }
void lenf_painc4(entity this) { set_anim(this, 78, lenf_painc5); }
void lenf_painc3(entity this) { set_anim(this, 77, lenf_painc4); }
void lenf_painc2(entity this) { set_anim(this, 76, lenf_painc3); }
void lenf_painc1(entity this) { set_anim(this, 75, lenf_painc2); }

void lenf_paind19(entity this) { set_anim(this, 101, lenf_run1); }
void lenf_paind18(entity this) { set_anim(this, 100, lenf_paind19); }
void lenf_paind17(entity this) { set_anim(this, 99, lenf_paind18); ai_pain(this, 1); }
void lenf_paind16(entity this) { set_anim(this, 98, lenf_paind17); ai_pain(this, 1); }
void lenf_paind15(entity this) { set_anim(this, 97, lenf_paind16); }
void lenf_paind14(entity this) { set_anim(this, 96, lenf_paind15); }
void lenf_paind13(entity this) { set_anim(this, 95, lenf_paind14); ai_painforward(this, 1); }
void lenf_paind12(entity this) { set_anim(this, 94, lenf_paind13); ai_painforward(this, 1); }
void lenf_paind11(entity this) { set_anim(this, 93, lenf_paind12); ai_painforward(this, 1); }
void lenf_paind10(entity this) { set_anim(this, 92, lenf_paind11); }
void lenf_paind9(entity this) { set_anim(this, 91, lenf_paind10); }
void lenf_paind8(entity this) { set_anim(this, 90, lenf_paind9); }
void lenf_paind7(entity this) { set_anim(this, 89, lenf_paind8); }
void lenf_paind6(entity this) { set_anim(this, 88, lenf_paind7); }
void lenf_paind5(entity this) { set_anim(this, 87, lenf_paind6); ai_painforward(this, 1); }
void lenf_paind4(entity this) { set_anim(this, 86, lenf_paind5); ai_painforward(this, 2); }
void lenf_paind3(entity this) { set_anim(this, 85, lenf_paind4); }
void lenf_paind2(entity this) { set_anim(this, 84, lenf_paind3); }
void lenf_paind1(entity this) { set_anim(this, 83, lenf_paind2); }

void lenf_pain(entity this, entity attacker, float damage, int deathtype)
{
	float r = random();
	if(this.pain_finished > time)
		return;
	if(r < 0.2)
	{
		_sound(this, CHAN_BODY, "monsters/lenforce/lepain1.wav", 1, ATTN_NORM);
		lenf_paina1(this);
		this.pain_finished = time + 1;
	}
	else if(r < 0.4)
	{
		_sound(this, CHAN_BODY, "monsters/lenforce/lepain2.wav", 1, ATTN_NORM);
		lenf_painb1(this);
		this.pain_finished = time + 1;
	}
	else if(r < 0.7)
	{
		_sound(this, CHAN_BODY, "monsters/lenforce/lepain3.wav", 1, ATTN_NORM);
		lenf_painc1(this);
		this.pain_finished = time + 1;
	}
	else
	{
		_sound(this, CHAN_BODY, "monsters/lenforce/lepain4.wav", 1, ATTN_NORM);
		lenf_paind1(this);
		this.pain_finished = time + 2;
	}
}

void lenf_die14(entity this) { set_anim(this, 54, lenf_die14); CorpseThink(this); }
void lenf_die13(entity this) { set_anim(this, 53, lenf_die14); }
void lenf_die12(entity this) { set_anim(this, 52, lenf_die13); ai_forward(this, 5); }
void lenf_die11(entity this) { set_anim(this, 51, lenf_die12); ai_forward(this, 5); }
void lenf_die10(entity this) { set_anim(this, 50, lenf_die11); ai_forward(this, 5); }
void lenf_die9(entity this) { set_anim(this, 49, lenf_die10); ai_forward(this, 3); }
void lenf_die8(entity this) { set_anim(this, 48, lenf_die9); }
void lenf_die7(entity this) { set_anim(this, 47, lenf_die8); }
void lenf_die6(entity this) { set_anim(this, 46, lenf_die7); }
void lenf_die5(entity this) { set_anim(this, 45, lenf_die6); ai_forward(this, 2); }
void lenf_die4(entity this) { set_anim(this, 44, lenf_die5); ai_forward(this, 14); }
void lenf_die3(entity this)
{
	set_anim(this, 43, lenf_die4);
	this.ammo_cells = 5;
	DropBackpack(this);
}
void lenf_die2(entity this) { set_anim(this, 42, lenf_die3); }
void lenf_die1(entity this) { set_anim(this, 41, lenf_die2); this.solid = SOLID_NOT; }

void lenf_fdie11(entity this) { set_anim(this, 65, lenf_fdie11); CorpseThink(this); }
void lenf_fdie10(entity this) { set_anim(this, 64, lenf_fdie11); }
void lenf_fdie9(entity this) { set_anim(this, 63, lenf_fdie10); }
void lenf_fdie8(entity this) { set_anim(this, 62, lenf_fdie9); }
void lenf_fdie7(entity this) { set_anim(this, 61, lenf_fdie8); }
void lenf_fdie6(entity this) { set_anim(this, 60, lenf_fdie7); }
void lenf_fdie5(entity this) { set_anim(this, 59, lenf_fdie6); }
void lenf_fdie4(entity this) { set_anim(this, 58, lenf_fdie5); }
void lenf_fdie3(entity this)
{
	set_anim(this, 57, lenf_fdie4);
	this.ammo_cells = 5;
	DropBackpack(this);
}
void lenf_fdie2(entity this) { set_anim(this, 56, lenf_fdie3); }
void lenf_fdie1(entity this) { set_anim(this, 55, lenf_fdie2); this.solid = SOLID_NOT; }

void lenf_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	if(this.health < -35)
	{
		_sound(this, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead(this, inflictor, "progs/h_mega.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib1.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib2.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib3.mdl", this.health);
		return;
	}
	if(random() > 0.5)
	{
		_sound(this, CHAN_AUTO, "monsters/lenforce/ledeath1.wav", 1, ATTN_NORM);
		lenf_die1(this);
	}
	else
	{
		_sound(this, CHAN_AUTO, "monsters/lenforce/ledeath2.wav", 1, ATTN_NORM);
		lenf_fdie1(this);
	}
}

spawnfunc(monster_lenforcer)
{
	if(!MP_IMPEL) { delete(this); return; }
	monster_start(this, true, MON_LIGHTNING_ENFORCER);
}

// lol why
spawnfunc(monster_x)
{
	delete(this);
	return;
}
#endif // SVQC

#ifdef SVQC
METHOD(LightningEnforcer, mr_setup, bool(LightningEnforcer this, entity actor))
{
    TC(LightningEnforcer, this);

	precache_sound("monsters/lenforce/ledeath1.wav");
	precache_sound("monsters/lenforce/ledeath2.wav");
	precache_sound("monsters/lenforce/leidle1.wav");
	precache_sound("monsters/lenforce/lepain1.wav");
	precache_sound("monsters/lenforce/lepain2.wav");
	precache_sound("monsters/lenforce/lepain3.wav");
	precache_sound("monsters/lenforce/lepain4.wav");

    actor.health = 120;
	actor.th_stand = lenf_stand1;
	actor.th_walk = lenf_walk1;
	actor.th_run = lenf_run1;
	actor.th_pain = lenf_pain;
	actor.th_die = lenf_die;
	actor.th_missile = lenf_atk1;

	actor.skin = 1;

    return true;
}
METHOD(LightningEnforcer, mr_sight, bool(LightningEnforcer this, entity actor))
{
    TC(LightningEnforcer, this);

	sound(actor, CH_VOICE, SND_MON_LENFORCER_SIGHT_RANDOM(), 1, ATTN_NORM);

    return true;
}
#endif
