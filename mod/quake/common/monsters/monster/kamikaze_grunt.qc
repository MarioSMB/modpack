#include "kamikaze_grunt.qh"

#ifdef SVQC
const int anim_kamikaze_stand = 0;
const int anim_kamikaze_death = 8;
const int anim_kamikaze_deathc = 18;
const int anim_kamikaze_load = 29;
const int anim_kamikaze_pain = 40;
const int anim_kamikaze_painb = 46;
const int anim_kamikaze_painc = 60;
const int anim_kamikaze_run = 73;
const int anim_kamikaze_shoot = 81;
const int anim_kamikaze_prowl = 90;

const float kamispd = 0.08;

.entity kamikaze_box;

void kami_stand1(entity this);
void kami_stand8(entity this) { set_animofs(this, anim_kamikaze_stand, 8, kami_stand1); this.pos1 = '8 2 32'; ai_stand(this); }
void kami_stand7(entity this) { set_animofs(this, anim_kamikaze_stand, 7, kami_stand8); this.pos1 = '8 2 32'; ai_stand(this); }
void kami_stand6(entity this) { set_animofs(this, anim_kamikaze_stand, 6, kami_stand7); this.pos1 = '8 2 32'; ai_stand(this); }
void kami_stand5(entity this) { set_animofs(this, anim_kamikaze_stand, 5, kami_stand6); this.pos1 = '8 2 32'; ai_stand(this); }
void kami_stand4(entity this) { set_animofs(this, anim_kamikaze_stand, 4, kami_stand5); this.pos1 = '8 2 32'; ai_stand(this); }
void kami_stand3(entity this) { set_animofs(this, anim_kamikaze_stand, 3, kami_stand4); this.pos1 = '8 2 32'; ai_stand(this); }
void kami_stand2(entity this) { set_animofs(this, anim_kamikaze_stand, 2, kami_stand3); this.pos1 = '8 2 32'; ai_stand(this); }
void kami_stand1(entity this) { set_animofs(this, anim_kamikaze_stand, 1, kami_stand2); this.pos1 = '8 2 32'; ai_stand(this); }

void kami_walk1(entity this);
void kami_walk24(entity this) { set_animofs(this, anim_kamikaze_prowl, 24, kami_walk1); this.pos1 = '4 -2 36'; ai_walk(this, 1); }
void kami_walk23(entity this) { set_animofs(this, anim_kamikaze_prowl, 23, kami_walk24); this.pos1 = '2 0 36'; ai_walk(this, 1); }
void kami_walk22(entity this) { set_animofs(this, anim_kamikaze_prowl, 22, kami_walk23); this.pos1 = '4 0 38'; ai_walk(this, 1); }
void kami_walk21(entity this) { set_animofs(this, anim_kamikaze_prowl, 21, kami_walk22); this.pos1 = '6 0 38'; ai_walk(this, 2); }
void kami_walk20(entity this) { set_animofs(this, anim_kamikaze_prowl, 20, kami_walk21); this.pos1 = '8 0 38'; ai_walk(this, 3); }
void kami_walk19(entity this) { set_animofs(this, anim_kamikaze_prowl, 19, kami_walk20); this.pos1 = '8 0 38'; ai_walk(this, 3); }
void kami_walk18(entity this) { set_animofs(this, anim_kamikaze_prowl, 18, kami_walk19); this.pos1 = '8 0 36'; ai_walk(this, 3); }
void kami_walk17(entity this) { set_animofs(this, anim_kamikaze_prowl, 17, kami_walk18); this.pos1 = '8 0 34'; ai_walk(this, 3); }
void kami_walk16(entity this) { set_animofs(this, anim_kamikaze_prowl, 16, kami_walk17); this.pos1 = '6 0 34'; ai_walk(this, 1); }
void kami_walk15(entity this) { set_animofs(this, anim_kamikaze_prowl, 15, kami_walk16); this.pos1 = '6 -2 34'; ai_walk(this, 1); }
void kami_walk14(entity this) { set_animofs(this, anim_kamikaze_prowl, 14, kami_walk15); this.pos1 = '6 -2 34'; ai_walk(this, 1); }
void kami_walk13(entity this) { set_animofs(this, anim_kamikaze_prowl, 13, kami_walk14); this.pos1 = '6 -2 34'; ai_walk(this, 0); }
void kami_walk12(entity this) { set_animofs(this, anim_kamikaze_prowl, 12, kami_walk13); this.pos1 = '6 -4 34'; ai_walk(this, 1); }
void kami_walk11(entity this) { set_animofs(this, anim_kamikaze_prowl, 11, kami_walk12); this.pos1 = '8 -4 34'; ai_walk(this, 2); }
void kami_walk10(entity this) { set_animofs(this, anim_kamikaze_prowl, 10, kami_walk11); this.pos1 = '8 -4 34'; ai_walk(this, 2); }
void kami_walk9(entity this) { set_animofs(this, anim_kamikaze_prowl, 9, kami_walk10); this.pos1 = '10 -4 34'; ai_walk(this, 2); }
void kami_walk8(entity this) { set_animofs(this, anim_kamikaze_prowl, 8, kami_walk9); this.pos1 = '10 -4 34'; ai_walk(this, 4); }
void kami_walk7(entity this) { set_animofs(this, anim_kamikaze_prowl, 7, kami_walk8); this.pos1 = '12 -4 34'; ai_walk(this, 4); }
void kami_walk6(entity this) { set_animofs(this, anim_kamikaze_prowl, 6, kami_walk7); this.pos1 = '12 -4 34'; ai_walk(this, 3); }
void kami_walk5(entity this) { set_animofs(this, anim_kamikaze_prowl, 5, kami_walk6); this.pos1 = '10 -4 32'; ai_walk(this, 2); }
void kami_walk4(entity this) { set_animofs(this, anim_kamikaze_prowl, 4, kami_walk5); this.pos1 = '10 -2 32'; ai_walk(this, 1); }
void kami_walk3(entity this) { set_animofs(this, anim_kamikaze_prowl, 3, kami_walk4); this.pos1 = '8 -2 32'; ai_walk(this, 1); }
void kami_walk2(entity this) { set_animofs(this, anim_kamikaze_prowl, 2, kami_walk3); this.pos1 = '6 -2 34'; ai_walk(this, 1); }
void kami_walk1(entity this)
{
	set_animofs(this, anim_kamikaze_prowl, 1, kami_walk2);
	this.pos1 = '6 -2 36';
	if(random() < 0.2)
		_sound(this, CH_VOICE, "soldier/idle.wav", 1, ATTN_IDLE);
	ai_walk(this, 1);
}

void kami_load1(entity this);
void kami_run(entity this, float dist)
{
	if(vdist(this.origin - this.enemy.origin, <=, 100) && visible(this, this.enemy) && infront(this, this.enemy))
	{
		_sound(this, CH_VOICE, "kamikaze/load.wav", 1, ATTN_NORM);
		kami_load1(this);
		return;
	}
	ai_run(this, dist);
}

void kami_run1(entity this);
void kami_run8(entity this) { set_animofs(this, anim_kamikaze_run, 8, kami_run1); this.pos1 = '0 0 34'; this.nextthink = time + kamispd; kami_run(this, 12); }
void kami_run7(entity this) { set_animofs(this, anim_kamikaze_run, 7, kami_run8); this.pos1 = '0 2 34'; this.nextthink = time + kamispd; kami_run(this, 18); }
void kami_run6(entity this) { set_animofs(this, anim_kamikaze_run, 6, kami_run7); this.pos1 = '0 4 34'; this.nextthink = time + kamispd; kami_run(this, 25); }
void kami_run5(entity this) { set_animofs(this, anim_kamikaze_run, 5, kami_run6); this.pos1 = '0 6 34'; this.nextthink = time + kamispd; kami_run(this, 12); }
void kami_run4(entity this) { set_animofs(this, anim_kamikaze_run, 4, kami_run5); this.pos1 = '0 6 34'; this.nextthink = time + kamispd; kami_run(this, 18); }
void kami_run3(entity this) { set_animofs(this, anim_kamikaze_run, 3, kami_run4); this.pos1 = '0 4 34'; this.nextthink = time + kamispd; kami_run(this, 18); }
void kami_run2(entity this) { set_animofs(this, anim_kamikaze_run, 2, kami_run3); this.pos1 = '0 0 34'; this.nextthink = time + kamispd; kami_run(this, 25); }
void kami_run1(entity this)
{
	set_animofs(this, anim_kamikaze_run, 1, kami_run2);
	this.pos1 = '0 0 34';
	this.nextthink = time + kamispd;
	if(random() < 0.2)
		_sound(this, CH_VOICE, "soldier/idle.wav", 1, ATTN_IDLE);
	kami_run(this, 14);
}


//===========================================================================


void kami_pain6(entity this) { set_animofs(this, anim_kamikaze_pain, 6, kami_run1); this.pos1 = '2 2 34'; ai_pain(this, 1); }
void kami_pain5(entity this) { set_animofs(this, anim_kamikaze_pain, 5, kami_pain6); this.pos1 = '6 8 34'; }
void kami_pain4(entity this) { set_animofs(this, anim_kamikaze_pain, 4, kami_pain5); this.pos1 = '0 10 32'; }
void kami_pain3(entity this) { set_animofs(this, anim_kamikaze_pain, 3, kami_pain4); this.pos1 = '-8 14 32'; }
void kami_pain2(entity this) { set_animofs(this, anim_kamikaze_pain, 2, kami_pain3); this.pos1 = '-6 10 34'; }
void kami_pain1(entity this) { set_animofs(this, anim_kamikaze_pain, 1, kami_pain2); this.pos1 = '4 4 30'; }

void kami_painb14(entity this) { set_animofs(this, anim_kamikaze_painb, 14, kami_run1); this.pos1 = '8 6 30'; }
void kami_painb13(entity this) { set_animofs(this, anim_kamikaze_painb, 13, kami_painb14); this.pos1 = '14 8 24'; }
void kami_painb12(entity this) { set_animofs(this, anim_kamikaze_painb, 12, kami_painb13); this.pos1 = '22 6 12'; ai_pain(this, 2); }
void kami_painb11(entity this) { set_animofs(this, anim_kamikaze_painb, 11, kami_painb12); this.pos1 = '20 10 2'; }
void kami_painb10(entity this) { set_animofs(this, anim_kamikaze_painb, 10, kami_painb11); this.pos1 = '20 10 -4'; }
void kami_painb9(entity this) { set_animofs(this, anim_kamikaze_painb, 9, kami_painb10); this.pos1 = '16 14 -6'; }
void kami_painb8(entity this) { set_animofs(this, anim_kamikaze_painb, 8, kami_painb9); this.pos1 = '16 16 -6'; }
void kami_painb7(entity this) { set_animofs(this, anim_kamikaze_painb, 7, kami_painb8); this.pos1 = '16 16 -6'; }
void kami_painb6(entity this) { set_animofs(this, anim_kamikaze_painb, 6, kami_painb7); this.pos1 = '18 14 -8'; }
void kami_painb5(entity this) { set_animofs(this, anim_kamikaze_painb, 5, kami_painb6); this.pos1 = '22 12 4'; }
void kami_painb4(entity this) { set_animofs(this, anim_kamikaze_painb, 4, kami_painb5); this.pos1 = '6 8 20'; }
void kami_painb3(entity this) { set_animofs(this, anim_kamikaze_painb, 3, kami_painb4); this.pos1 = '-2 8 22'; ai_painforward(this, 9); }
void kami_painb2(entity this) { set_animofs(this, anim_kamikaze_painb, 2, kami_painb3); this.pos1 = '2 8 28'; ai_painforward(this, 13); }
void kami_painb1(entity this) { set_animofs(this, anim_kamikaze_painb, 1, kami_painb2); this.pos1 = '4 8 32'; }

void kami_painc13(entity this) { set_animofs(this, anim_kamikaze_painc, 13, kami_run1); this.pos1 = '12 2 30'; }
void kami_painc12(entity this) { set_animofs(this, anim_kamikaze_painc, 12, kami_painc13); this.pos1 = '14 2 30';ai_painforward(this, 8); }
void kami_painc11(entity this) { set_animofs(this, anim_kamikaze_painc, 11, kami_painc12); this.pos1 = '20 0 24';ai_painforward(this, 6); }
void kami_painc10(entity this) { set_animofs(this, anim_kamikaze_painc, 10, kami_painc11); this.pos1 = '22 0 24';ai_painforward(this, 3); }
void kami_painc9(entity this) { set_animofs(this, anim_kamikaze_painc, 9, kami_painc10); this.pos1 = '24 0 20';ai_painforward(this, 4); }
void kami_painc8(entity this) { set_animofs(this, anim_kamikaze_painc, 8, kami_painc9); this.pos1 = '24 6 20'; ai_pain(this, 1); }
void kami_painc7(entity this) { set_animofs(this, anim_kamikaze_painc, 7, kami_painc8); this.pos1 = '24 6 16'; }
void kami_painc6(entity this) { set_animofs(this, anim_kamikaze_painc, 6, kami_painc7); this.pos1 = '22 6 20';ai_painforward(this, 1); }
void kami_painc5(entity this) { set_animofs(this, anim_kamikaze_painc, 5, kami_painc6); this.pos1 = '22 6 16';ai_painforward(this, 1); }
void kami_painc4(entity this) { set_animofs(this, anim_kamikaze_painc, 4, kami_painc5); this.pos1 = '12 2 28'; }
void kami_painc3(entity this) { set_animofs(this, anim_kamikaze_painc, 3, kami_painc4); this.pos1 = '0 -2 34'; }
void kami_painc2(entity this) { set_animofs(this, anim_kamikaze_painc, 2, kami_painc3); this.pos1 = '-4 -4 36'; ai_pain(this, 1); }
void kami_painc1(entity this) { set_animofs(this, anim_kamikaze_painc, 1, kami_painc2); this.pos1 = '0 2 34'; }

void kami_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;

	float r = random();

	if(r < 0.2)
	{
		this.pain_finished = time + 0.6;
		kami_pain1(this);
		_sound(this, CH_VOICE, "soldier/pain1.wav", 1, ATTN_NORM);
	}
	else if(r < 0.6)
	{
		this.pain_finished = time + 1.1;
		kami_painb1(this);
		_sound(this, CH_VOICE, "soldier/pain2.wav", 1, ATTN_NORM);
	}
	else
	{
		this.pain_finished = time + 1.1;
		kami_painc1(this);
		_sound(this, CH_VOICE, "soldier/pain2.wav", 1, ATTN_NORM);
	}
}

//===========================================================================

void kami_die10(entity this) { set_animofs(this, anim_kamikaze_death, 10, kami_die10); this.pos1 = '-48 -6 -16'; CorpseThink(this); }
void kami_die9(entity this) { set_animofs(this, anim_kamikaze_death, 9, kami_die10); this.pos1 = '-48 -4 -16'; }
void kami_die8(entity this) { set_animofs(this, anim_kamikaze_death, 8, kami_die9); this.pos1 = '-48 -6 -16'; }
void kami_die7(entity this) { set_animofs(this, anim_kamikaze_death, 7, kami_die8); this.pos1 = '-46 4 -10'; }
void kami_die6(entity this) { set_animofs(this, anim_kamikaze_death, 6, kami_die7); this.pos1 = '-42 4 4'; }
void kami_die5(entity this) { set_animofs(this, anim_kamikaze_death, 5, kami_die6); this.pos1 = '-36 4 20'; }
void kami_die4(entity this) { set_animofs(this, anim_kamikaze_death, 4, kami_die5); this.pos1 = '-28 6 32'; }
void kami_die3(entity this) { set_animofs(this, anim_kamikaze_death, 3, kami_die4); this.pos1 = '-20 4 38'; }
void kami_die2(entity this) { set_animofs(this, anim_kamikaze_death, 2, kami_die3); this.pos1 = '-14 4 40'; }
void kami_die1(entity this) { set_animofs(this, anim_kamikaze_death, 1, kami_die2); this.pos1 = '-6 4 40'; this.solid = SOLID_NOT; }

void kami_cdie11(entity this) { set_animofs(this, anim_kamikaze_deathc, 11, kami_cdie11); this.pos1 = '-50 8 -16'; CorpseThink(this); }
void kami_cdie10(entity this) { set_animofs(this, anim_kamikaze_deathc, 10, kami_cdie11); this.pos1 = '-50 8 -16'; }
void kami_cdie9(entity this) { set_animofs(this, anim_kamikaze_deathc, 9, kami_cdie10); this.pos1 = '-50 8 -16'; }
void kami_cdie8(entity this) { set_animofs(this, anim_kamikaze_deathc, 8, kami_cdie9); this.pos1 = '-40 6 -4'; }
void kami_cdie7(entity this) { set_animofs(this, anim_kamikaze_deathc, 7, kami_cdie8); this.pos1 = '-30 0 6'; }
void kami_cdie6(entity this) { set_animofs(this, anim_kamikaze_deathc, 6, kami_cdie7); this.pos1 = '-26 -8 14'; ai_back(this, 4); }
void kami_cdie5(entity this) { set_animofs(this, anim_kamikaze_deathc, 5, kami_cdie6); this.pos1 = '-32 -12 16'; ai_back(this, 3); }
void kami_cdie4(entity this) { set_animofs(this, anim_kamikaze_deathc, 4, kami_cdie5); this.pos1 = '-34 -10 18';ai_back(this, 13); }
void kami_cdie3(entity this) { set_animofs(this, anim_kamikaze_deathc, 3, kami_cdie4); this.pos1 = '-36 -6 22'; ai_back(this, 4); }
void kami_cdie2(entity this) { set_animofs(this, anim_kamikaze_deathc, 2, kami_cdie3); this.pos1 = '-34 -2 26'; ai_back(this, 5); }
void kami_cdie1(entity this) { set_animofs(this, anim_kamikaze_deathc, 1, kami_cdie2); this.pos1 = '-26 -4 32'; this.solid = SOLID_NOT; }

void kami_gib(entity this, entity inflictor)
{
	_sound(this, CH_VOICE, "player/udeath.wav", 1, ATTN_NORM);
	ThrowHead(this, inflictor, "progs/h_guard.mdl", this.health);
	ThrowGib(this, inflictor, "progs/gib1.mdl", this.health);
	ThrowGib(this, inflictor, "progs/gib2.mdl", this.health);
	ThrowGib(this, inflictor, "progs/gib3.mdl", this.health);
	ThrowGib(this, inflictor, "progs/gib3.mdl", this.health);
	if(random() < 0.2)
		ThrowGib(this, inflictor, "progs/arm_foot.mdl", this.health);
}

void kamikaze_detonate(entity this);
void kami_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	if(this.health < -35)
	{
		kami_gib(this, inflictor);

		if(this.kamikaze_box && !wasfreed(this.kamikaze_box))
		{
			setthink(this.kamikaze_box, kamikaze_detonate);
			this.kamikaze_box.nextthink = time;
		}
		return;
	}

	_sound(this, CH_VOICE, "soldier/death1.wav", 1, ATTN_NORM);
	
	if(random() < 0.5)
		kami_die1(this);
	else
		kami_cdie1(this);
}

void kamikaze_explosivethink(entity this)
{
	if(!this.owner || wasfreed(this.owner) || this.owner.kamikaze_box != this)
	{
		delete(this);
		return;
	}
	this.nextthink = time + 0.05;

	if(this.owner.pos1 == this.pos1)
		return; // save resources
	this.pos1 = this.owner.pos1;

	vector ang;
	ang.x = -this.owner.angles_x;
	ang.y = this.owner.angles_y;
	ang.z = this.owner.angles_z;
	makevectors(ang);
	vector offset = this.owner.pos1;
	setorigin(this, this.owner.origin + v_forward * offset.x - v_right * offset.y + v_up * offset.z);
}

void kamikaze_explodethink(entity this)
{
	T_RadiusDamage(this, this.enemy, 160, DEATH_MONSTER_KAMIKAZEGRUNT.m_id, this.owner);

	Send_Effect(EFFECT_EXPLOSION, this.origin, '0 0 0', 1);

	BecomeExplosion(this);
}

void kamikaze_explosiveboom(entity this, entity inflictor, entity attacker, int deathtype)
{
	// already exploding
	if(this.state == 1)
		return;
	
	this.state = 1; // exploding

	this.solid = SOLID_NOT;

	if(this.owner && !wasfreed(this.owner))
	{
		// hacky gib check
		if(this.owner.move_movetype != MOVETYPE_BOUNCE)
		{
			if(this.owner.health <= 0 && this.owner.health > -35)
			{
				this.owner.health = -50;
				kami_gib(this.owner, inflictor);
			}
			else if(this.owner.health > 0)
				Killed(this.owner, this, this.enemy, DEATH_CRUSH.m_id);
		}
	}

	this.enemy = attacker;

	setthink(this, kamikaze_explodethink);
	this.nextthink = time;
}

void kamikaze_detonate(entity this)
{
	if(this && !wasfreed(this))
		kamikaze_explosiveboom(this, this.owner, this.owner.enemy, DEATH_MONSTER_KAMIKAZEGRUNT.m_id);
}

void kami_load8(entity this) { set_animofs(this, anim_kamikaze_load, 8, kami_load8); }
void kami_load7(entity this) { set_animofs(this, anim_kamikaze_load, 7, kami_load8); }
void kami_load6(entity this) { set_animofs(this, anim_kamikaze_load, 6, kami_load7); }
void kami_load5(entity this) { set_animofs(this, anim_kamikaze_load, 5, kami_load6); kamikaze_detonate(this.kamikaze_box); }
void kami_load4(entity this) { set_animofs(this, anim_kamikaze_load, 4, kami_load5); }
void kami_load3(entity this) { set_animofs(this, anim_kamikaze_load, 3, kami_load4); }
void kami_load2(entity this) { set_animofs(this, anim_kamikaze_load, 2, kami_load3); }
void kami_load1(entity this) { set_animofs(this, anim_kamikaze_load, 1, kami_load2); this.state = 0; this.attack_finished = time + 2; }

void kami_spawnbox(entity this)
{
	if(this.kamikaze_box)
		delete(this.kamikaze_box);

	entity box = spawn();
	box.classname = "kamikaze_explosive";
	box.solid = SOLID_BBOX;
	set_movetype(box, MOVETYPE_NOCLIP);
	setsize(box, '-8 -8 -8', '8 8 8');
	box.owner = this;
	box.health = 15;
	box.takedamage = DAMAGE_YES;
	setthink(box, kamikaze_explosivethink);
	box.nextthink = time + 0.05;
	box.th_die = kamikaze_explosiveboom;

	this.kamikaze_box = box;
}

/*QUAKED monster_kamikazegrunt (1 0 0) (-16 -16 -24) (16 16 40) Ambush
*/
spawnfunc(monster_kamikaze) { monster_start(this, true, MON_KAMIKAZEGRUNT); }
#endif // SVQC

#ifdef SVQC
METHOD(KamikazeGrunt, mr_setup, bool(KamikazeGrunt this, entity actor))
{
    TC(KamikazeGrunt, this);

	precache_model("progs/gib1.mdl");
	precache_model("progs/gib2.mdl");
	precache_model("progs/gib3.mdl");
	precache_model("progs/arm_foot.mdl");
	precache_model("progs/shelcase.mdl");

	precache_sound("soldier/death1.wav");
	precache_sound("soldier/idle.wav");
	precache_sound("soldier/pain1.wav");
	precache_sound("soldier/pain2.wav");
	precache_sound("soldier/sattck1.wav");
	precache_sound("soldier/sight1.wav");

	precache_sound("kamikaze/load.wav");

	precache_sound("player/udeath.wav");		// gib death

	// for box positioning
	actor.pos1 = '8 0 32';

    actor.health = 40;
    actor.th_stand = kami_stand1;
	actor.th_walk = kami_walk1;
	actor.th_run = kami_run1;
	actor.th_pain = kami_pain;
	actor.th_die = kami_die;

	kami_spawnbox(actor);

    return true;
}
#endif
