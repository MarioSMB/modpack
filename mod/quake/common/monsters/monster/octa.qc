#include "grunt.qh"

#ifdef SVQC
const int anim_octa_stand = 0;
const int anim_octa_walk = 20;
const int anim_octa_run = 44;
const int anim_octa_atk = 53;
const int anim_octa_rush = 63;
const int anim_octa_pain = 76;
const int anim_octa_paina = 85;
const int anim_octa_painc = 91;
const int anim_octa_die = 99;
const int anim_octa_dieb = 115;

// LITTLE CUTY

void octaflame_touch(entity this, entity toucher)
{
	if(toucher == this.owner || toucher.solid == SOLID_TRIGGER || toucher.health < 1 || toucher.takedamage == DAMAGE_NO || toucher.tank)
		return;
	// special rule: no collisions with owner
	// TODO: clip group?
	if(toucher.monsterdef == this.owner.monsterdef)
		return;
	if(time < this.attack_finished)
		return;

	// Stop still if hit world, carry on if burning something
	if(!toucher)
		//this.velocity = this.movedir;
	//else
		this.velocity = '0 0 0';

	// Block sprite burst from damage again
	this.attack_finished = time + 1;

	if(IS_PLAYER(toucher))
	{
		// poison the player if they aren't already, damage them if they are!
		if(StatusEffects_active(STATUSEFFECT_Poisoned, toucher))
			T_Damage(toucher, this, this.owner, 2, this.projectiledeathtype);
		else
		{
			float poisontime = floor(8 + 2*random());
			StatusEffects_apply(STATUSEFFECT_Poisoned, toucher, time + poisontime, 0);
		}
	}
	else
		T_Damage(toucher, this, this.owner, 20, this.projectiledeathtype);
}

void octaflame_think(entity this)
{
	this.cnt += 1;
	if(this.cnt > 6)
	{
		delete(this);
		return;
	}

	this.frame = this.cnt;
	// Randomly drift upwards and slow down forward movement
	if(this.velocity != '0 0 0')
	{
		this.velocity_z += 10 + (random() * 20);
		this.velocity -= (this.movedir * 0.125);
	}
	this.nextthink = time + 0.1;
}

void octaflame_spawn(entity this, vector org, vector dir)
{
	entity newmis = spawn();
	newmis.classname = "PBurst";
	newmis.owner = this;

	set_movetype(newmis, MOVETYPE_FLYMISSILE);
	newmis.solid = SOLID_TRIGGER;
	newmis.projectiledeathtype = DEATH_MONSTER_OCTA.m_id;

	_setmodel(newmis, "progs/madfox/wink.spr");
	setsize(newmis, '0 0 0', '0 0 0');
	setorigin(newmis, org);

	vector variance = randomvec() * 10;
	float aspeed = 250 + 3 * 50;
	newmis.movedir = (dir * aspeed) + '0 0 -50' + variance;
	newmis.velocity = newmis.movedir;

	// Roll the flames from side to side towards the target
	float roll = 350 + random() * 20;
	newmis.angles_z = ANGLEMOD(roll);

	newmis.effects |= EF_NOSHADOW;
	newmis.alpha = 0.75;
	float ink_color = 0.25;
	newmis.colormod = '1 1 1' * ink_color;

	newmis.nextthink = time + 0.1;
	setthink(newmis, octaflame_think);
	settouch(newmis, octaflame_touch);
}

void octa_fire(entity this)
{
	if(this.health < 1)
		return;

	fixedmakevectors(this.angles);
	vector org = this.origin + attack_vector('0 0 0');
	vector targ_org = this.enemy.origin;
#if 0
	// point the flames at the feet of the player
	if(IS_PLAYER(this.enemy))
		targ_org = this.enemy.origin - '0 0 20';
	else
		targ_org = this.enemy.origin - this.enemy.view_ofs;
#endif
	vector dir = normalize(targ_org - this.origin);
	octaflame_spawn(this, org, dir);
}

void octa_atk6(entity this);
void octa_atka6(entity this);
void octa_stand1(entity this);
void octa_walk1(entity this);
void octa_run1(entity this);

void octa_stand20(entity this) { set_animofs(this, anim_octa_stand, 20, octa_stand1); ai_stand(this); }
void octa_stand19(entity this) { set_animofs(this, anim_octa_stand, 19, octa_stand20); ai_stand(this); }
void octa_stand18(entity this) { set_animofs(this, anim_octa_stand, 18, octa_stand19); ai_stand(this); }
void octa_stand17(entity this) { set_animofs(this, anim_octa_stand, 17, octa_stand18); ai_stand(this); }
void octa_stand16(entity this) { set_animofs(this, anim_octa_stand, 16, octa_stand17); ai_stand(this); }
void octa_stand15(entity this) { set_animofs(this, anim_octa_stand, 15, octa_stand16); ai_stand(this); }
void octa_stand14(entity this) { set_animofs(this, anim_octa_stand, 14, octa_stand15); ai_stand(this); }
void octa_stand13(entity this) { set_animofs(this, anim_octa_stand, 13, octa_stand14); ai_stand(this); }
void octa_stand12(entity this) { set_animofs(this, anim_octa_stand, 12, octa_stand13); ai_stand(this); }
void octa_stand11(entity this) { set_animofs(this, anim_octa_stand, 11, octa_stand12); ai_stand(this); }
void octa_stand10(entity this) { set_animofs(this, anim_octa_stand, 10, octa_stand11); ai_stand(this); }
void octa_stand9(entity this) { set_animofs(this, anim_octa_stand, 9, octa_stand10); ai_stand(this); }
void octa_stand8(entity this) { set_animofs(this, anim_octa_stand, 8, octa_stand9); ai_stand(this); }
void octa_stand7(entity this) { set_animofs(this, anim_octa_stand, 7, octa_stand8); ai_stand(this); }
void octa_stand6(entity this) { set_animofs(this, anim_octa_stand, 6, octa_stand7); ai_stand(this); }
void octa_stand5(entity this) { set_animofs(this, anim_octa_stand, 5, octa_stand6); ai_stand(this); }
void octa_stand4(entity this) { set_animofs(this, anim_octa_stand, 4, octa_stand5); ai_stand(this); }
void octa_stand3(entity this) { set_animofs(this, anim_octa_stand, 3, octa_stand4); ai_stand(this); }
void octa_stand2(entity this) { set_animofs(this, anim_octa_stand, 2, octa_stand3); ai_stand(this); }
void octa_stand1(entity this)
{
	set_animofs(this, anim_octa_stand, 1, octa_stand2);
	ai_stand(this);
	if(random() < 0.2)
	{
		if(random() < 0.5)
			_sound(this, CH_VOICE, "tronyn/mon_seahorse_swim1.wav", 1, ATTN_IDLE);
		else
			_sound(this, CH_VOICE, "tronyn/mon_seahorse_swim2.wav", 1, ATTN_IDLE);
	}
}

void octa_walk24(entity this) { set_animofs(this, anim_octa_walk, 24, octa_walk1); ai_walk(this, 3); }
void octa_walk23(entity this) { set_animofs(this, anim_octa_walk, 23, octa_walk24); ai_walk(this, 2); }
void octa_walk22(entity this) { set_animofs(this, anim_octa_walk, 22, octa_walk23); ai_walk(this, 1); }
void octa_walk21(entity this) { set_animofs(this, anim_octa_walk, 21, octa_walk22); ai_walk(this, 4); }
void octa_walk20(entity this) { set_animofs(this, anim_octa_walk, 20, octa_walk21); ai_walk(this, 4); }
void octa_walk19(entity this) { set_animofs(this, anim_octa_walk, 19, octa_walk20); ai_walk(this, 2); }
void octa_walk18(entity this) { set_animofs(this, anim_octa_walk, 18, octa_walk19); ai_walk(this, 1); }
void octa_walk17(entity this) { set_animofs(this, anim_octa_walk, 17, octa_walk18); ai_walk(this, 2); }
void octa_walk16(entity this) { set_animofs(this, anim_octa_walk, 16, octa_walk17); ai_walk(this, 2); }
void octa_walk15(entity this) { set_animofs(this, anim_octa_walk, 15, octa_walk16); ai_walk(this, 4); }
void octa_walk14(entity this) { set_animofs(this, anim_octa_walk, 14, octa_walk15); ai_walk(this, 3); }
void octa_walk13(entity this) { set_animofs(this, anim_octa_walk, 13, octa_walk14); ai_walk(this, 2); }
void octa_walk12(entity this) { set_animofs(this, anim_octa_walk, 12, octa_walk13); ai_walk(this, 1); }
void octa_walk11(entity this) { set_animofs(this, anim_octa_walk, 11, octa_walk12); ai_walk(this, 4); }
void octa_walk10(entity this) { set_animofs(this, anim_octa_walk, 10, octa_walk11); ai_walk(this, 4); }
void octa_walk9(entity this) { set_animofs(this, anim_octa_walk, 9, octa_walk10); ai_walk(this, 2); }
void octa_walk8(entity this) { set_animofs(this, anim_octa_walk, 8, octa_walk9); ai_walk(this, 1); }
void octa_walk7(entity this) { set_animofs(this, anim_octa_walk, 7, octa_walk8); ai_walk(this, 2); }
void octa_walk6(entity this) { set_animofs(this, anim_octa_walk, 6, octa_walk7); ai_walk(this, 2); }
void octa_walk5(entity this) { set_animofs(this, anim_octa_walk, 5, octa_walk6); ai_walk(this, 1); }
void octa_walk4(entity this) { set_animofs(this, anim_octa_walk, 4, octa_walk5); ai_walk(this, 3); }
void octa_walk3(entity this) { set_animofs(this, anim_octa_walk, 3, octa_walk4); ai_walk(this, 4); }
void octa_walk2(entity this) { set_animofs(this, anim_octa_walk, 2, octa_walk3); ai_walk(this, 4); }
void octa_walk1(entity this)
{
	set_animofs(this, anim_octa_walk, 1, octa_walk2);
	ai_walk(this, 2);
	if(random() < 0.2)
	{
		if(random() < 0.5)
			_sound(this, CH_VOICE, "tronyn/mon_seahorse_swim1.wav", 1, ATTN_IDLE);
		else
			_sound(this, CH_VOICE, "tronyn/mon_seahorse_swim2.wav", 1, ATTN_IDLE);
	}
}

void octa_run9(entity this)
{
	set_animofs(this, anim_octa_run, 9, octa_run1);
	ai_run(this, 12);
	_sound(this, CH_VOICE, "tronyn/mon_bigfish_swim1.wav", 1, ATTN_NORM);
}
void octa_run8(entity this)
{
	set_animofs(this, anim_octa_run, 8, octa_run9);
	ai_run(this, 11);
	if(random() < 0.2)
	{
		if(vdist(this.enemy.origin - this.origin, >, 256))
			octa_atk6(this);
	}
}
void octa_run7(entity this) { set_animofs(this, anim_octa_run, 7, octa_run8); ai_run(this, 7); }
void octa_run6(entity this) { set_animofs(this, anim_octa_run, 6, octa_run7); ai_run(this, 14); }
void octa_run5(entity this) { set_animofs(this, anim_octa_run, 5, octa_run6); ai_run(this, 14); }
void octa_run4(entity this) { set_animofs(this, anim_octa_run, 4, octa_run5); ai_run(this, 12); }
void octa_run3(entity this) { set_animofs(this, anim_octa_run, 3, octa_run4); ai_run(this, 7); }
void octa_run2(entity this) { set_animofs(this, anim_octa_run, 2, octa_run3); ai_run(this, 14); }
void octa_run1(entity this)
{
	set_animofs(this, anim_octa_run, 1, octa_run2); ai_run(this, 18);
	if(random() < 0.2)
	{
		if(random() < 0.5)
			_sound(this, CH_VOICE, "tronyn/mon_seahorse_swim1.wav", 1, ATTN_IDLE);
		else
			_sound(this, CH_VOICE, "tronyn/mon_seahorse_swim2.wav", 1, ATTN_IDLE);
	}
}

void octa_atk10(entity this) { set_animofs(this, anim_octa_atk, 10, octa_run1); ai_face(this); }
void octa_atk9(entity this) { set_animofs(this, anim_octa_atk, 9, octa_atk10); ai_face(this); }
void octa_atk8(entity this) { set_animofs(this, anim_octa_atk, 8, octa_atk9); ai_face(this); }
void octa_atk7(entity this)
{
	set_animofs(this, anim_octa_atk, 7, octa_atk8);
	ai_face(this);
	if(vdist(this.enemy.origin - this.origin, <=, 100))
		ai_melee(this, DEATH_MONSTER_OCTA.m_id, 100, false);
}
void octa_atk5(entity this)
{
	set_animofs(this, anim_octa_atk, 5, octa_atk6);
	ai_face(this);
	if(vdist(this.enemy.origin - this.origin, <=, 100))
		ai_melee(this, DEATH_MONSTER_OCTA.m_id, 100, false);
	else if(vdist(this.enemy.origin - this.origin, <, 384))
		octa_fire(this);
}
void octa_atk6(entity this)
{
	set_animofs(this, anim_octa_atk, 6, octa_atk7);
	ai_face(this);
	if(vdist(this.enemy.origin - this.origin, <=, 100))
		ai_melee(this, DEATH_MONSTER_OCTA.m_id, 100, false);
}
void octa_atk4(entity this) { set_animofs(this, anim_octa_atk, 4, octa_atk5); ai_face(this); }
void octa_atk3(entity this) { set_animofs(this, anim_octa_atk, 3, octa_atk4); ai_face(this); }
void octa_atk2(entity this) { set_animofs(this, anim_octa_atk, 2, octa_atk3); ai_face(this); }
void octa_atk1(entity this) { set_animofs(this, anim_octa_atk, 1, octa_atk2); ai_face(this); }

void octa_atka13(entity this)
{
	set_animofs(this, anim_octa_rush, 13, octa_run1);
	ai_run(this, 22);
	if(vdist(this.enemy.origin - this.origin, <=, 100))
		ai_melee(this, DEATH_MONSTER_OCTA.m_id, 100, false);
	_sound(this, CH_VOICE, "tronyn/mon_bigfish_swim2.wav", 1, ATTN_NORM);
}
void octa_atka12(entity this)
{
	set_animofs(this, anim_octa_rush, 12, octa_atka13);
	ai_run(this, 16);
	if(vdist(this.enemy.origin - this.origin, <=, 100))
		ai_melee(this, DEATH_MONSTER_OCTA.m_id, 100, false);
}
void octa_atka11(entity this) { set_animofs(this, anim_octa_rush, 11, octa_atka12); ai_run(this, 8); }
void octa_atka10(entity this) { set_animofs(this, anim_octa_rush, 10, octa_atka11); ai_run(this, 8); }
void octa_atka9(entity this) { set_animofs(this, anim_octa_rush, 9, octa_atka10); ai_run(this, 6); }
void octa_atka8(entity this) { set_animofs(this, anim_octa_rush, 8, octa_atka9); ai_run(this, 4); }
void octa_atka7(entity this) { set_animofs(this, anim_octa_rush, 7, octa_atka8); ai_run(this, 2); }
void octa_atka6(entity this) { set_animofs(this, anim_octa_rush, 6, octa_atka7); ai_run(this, 2); }
void octa_atka5(entity this)
{
	set_animofs(this, anim_octa_rush, 5, octa_atka6);
	ai_run(this, 2);
	if(vdist(this.enemy.origin - this.origin, <, 256))
		octa_run8(this);
}
void octa_atka4(entity this) { set_animofs(this, anim_octa_rush, 4, octa_atka5); ai_run(this, 6); }
void octa_atka3(entity this)
{
	set_animofs(this, anim_octa_rush, 3, octa_atka4); ai_run(this, 8);
	if(vdist(this.enemy.origin - this.origin, <=, 100))
		ai_melee(this, DEATH_MONSTER_OCTA.m_id, 100, false);
}
void octa_atka2(entity this)
{
	set_animofs(this, anim_octa_rush, 2, octa_atka3);
	ai_run(this, 16);
	if(vdist(this.enemy.origin - this.origin, <=, 100))
		ai_melee(this, DEATH_MONSTER_OCTA.m_id, 100, false);
}
void octa_atka1(entity this)
{
	set_animofs(this, anim_octa_rush, 1, octa_atka2);
	ai_run(this, 18);
	if(vdist(this.enemy.origin - this.origin, <=, 100))
		ai_melee(this, DEATH_MONSTER_OCTA.m_id, 100, false);
}

void octa_attack(entity this)
{
	_sound(this, CH_WEAPON_SINGLE, "tronyn/mon_anglerfish_bite.wav", 1, ATTN_NORM);
	octa_atk1(this);
}

void octa_pain9(entity this) { set_animofs(this, anim_octa_pain, 9, octa_run1); }
void octa_pain8(entity this) { set_animofs(this, anim_octa_pain, 8, octa_pain9); }
void octa_pain7(entity this) { set_animofs(this, anim_octa_pain, 7, octa_pain8); }
void octa_pain6(entity this) { set_animofs(this, anim_octa_pain, 6, octa_pain7); }
void octa_pain5(entity this) { set_animofs(this, anim_octa_pain, 5, octa_pain6); }
void octa_pain4(entity this) { set_animofs(this, anim_octa_pain, 4, octa_pain5); }
void octa_pain3(entity this) { set_animofs(this, anim_octa_pain, 3, octa_pain4); }
void octa_pain2(entity this) { set_animofs(this, anim_octa_pain, 2, octa_pain3); }
void octa_pain1(entity this) { set_animofs(this, anim_octa_pain, 1, octa_pain2); }

void octa_paina6(entity this) { set_animofs(this, anim_octa_paina, 6, octa_run1); }
void octa_paina5(entity this) { set_animofs(this, anim_octa_paina, 5, octa_paina6); }
void octa_paina4(entity this) { set_animofs(this, anim_octa_paina, 4, octa_paina5); }
void octa_paina3(entity this) { set_animofs(this, anim_octa_paina, 3, octa_paina4); }
void octa_paina2(entity this) { set_animofs(this, anim_octa_paina, 2, octa_paina3); }
void octa_paina1(entity this) { set_animofs(this, anim_octa_paina, 1, octa_paina2); }

void octa_painc8(entity this) { set_animofs(this, anim_octa_painc, 8, octa_run1); }
void octa_painc7(entity this) { set_animofs(this, anim_octa_painc, 7, octa_painc8); }
void octa_painc6(entity this) { set_animofs(this, anim_octa_painc, 6, octa_painc7); }
void octa_painc5(entity this) { set_animofs(this, anim_octa_painc, 5, octa_painc6); }
void octa_painc4(entity this) { set_animofs(this, anim_octa_painc, 4, octa_painc5); }
void octa_painc3(entity this) { set_animofs(this, anim_octa_painc, 3, octa_painc4); }
void octa_painc2(entity this) { set_animofs(this, anim_octa_painc, 2, octa_painc3); }
void octa_painc1(entity this) { set_animofs(this, anim_octa_painc, 1, octa_painc2); }

void octa_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;

	// Any pain animation/sound required?
	_sound(this, CH_VOICE, "tronyn/mon_bigfish_pain.wav", 1, ATTN_NORM);
	this.pain_finished = time + 1.5;
	float r = random();
	if(r < 0.333)
		octa_pain1(this);
	else if(r < 0.666)
		octa_paina1(this);
	else
		octa_painc1(this);
}

void octa_die16(entity this) { set_animofs(this, anim_octa_die, 16, octa_die16); CorpseThink(this); }
void octa_die15(entity this) { set_animofs(this, anim_octa_die, 15, octa_die16); }
void octa_die14(entity this) { set_animofs(this, anim_octa_die, 14, octa_die15); }
void octa_die13(entity this) { set_animofs(this, anim_octa_die, 13, octa_die14); }
void octa_die12(entity this) { set_animofs(this, anim_octa_die, 12, octa_die13); ai_forward(this, 5); }
void octa_die11(entity this) { set_animofs(this, anim_octa_die, 11, octa_die12); ai_forward(this, 5); }
void octa_die10(entity this) { set_animofs(this, anim_octa_die, 10, octa_die11); ai_forward(this, 5); }
void octa_die9(entity this) { set_animofs(this, anim_octa_die, 9, octa_die10); ai_forward(this, 3); }
void octa_die8(entity this) { set_animofs(this, anim_octa_die, 8, octa_die9); }
void octa_die7(entity this) { set_animofs(this, anim_octa_die, 7, octa_die8); }
void octa_die6(entity this) { set_animofs(this, anim_octa_die, 6, octa_die7); }
void octa_die5(entity this) { set_animofs(this, anim_octa_die, 5, octa_die6); ai_forward(this, 2); }
void octa_die4(entity this) { set_animofs(this, anim_octa_die, 4, octa_die5); ai_forward(this, 14); }
void octa_die3(entity this) { set_animofs(this, anim_octa_die, 3, octa_die4); }
void octa_die2(entity this) { set_animofs(this, anim_octa_die, 2, octa_die3); }
void octa_die1(entity this) { set_animofs(this, anim_octa_die, 1, octa_die2); this.solid = SOLID_NOT; }

void octa_dieb16(entity this) { set_animofs(this, anim_octa_dieb, 16, octa_dieb16); CorpseThink(this); }
void octa_dieb15(entity this) { set_animofs(this, anim_octa_dieb, 15, octa_dieb16); }
void octa_dieb14(entity this) { set_animofs(this, anim_octa_dieb, 14, octa_dieb15); }
void octa_dieb13(entity this) { set_animofs(this, anim_octa_dieb, 13, octa_dieb14); }
void octa_dieb12(entity this) { set_animofs(this, anim_octa_dieb, 12, octa_dieb13); ai_forward(this, 5); }
void octa_dieb11(entity this) { set_animofs(this, anim_octa_dieb, 11, octa_dieb12); ai_forward(this, 5); }
void octa_dieb10(entity this) { set_animofs(this, anim_octa_dieb, 10, octa_dieb11); ai_forward(this, 5); }
void octa_dieb9(entity this) { set_animofs(this, anim_octa_dieb, 9, octa_dieb10); ai_forward(this, 3); }
void octa_dieb8(entity this) { set_animofs(this, anim_octa_dieb, 8, octa_dieb9); }
void octa_dieb7(entity this) { set_animofs(this, anim_octa_dieb, 7, octa_dieb8); }
void octa_dieb6(entity this) { set_animofs(this, anim_octa_dieb, 6, octa_dieb7); }
void octa_dieb5(entity this) { set_animofs(this, anim_octa_dieb, 5, octa_dieb6); ai_forward(this, 2); }
void octa_dieb4(entity this) { set_animofs(this, anim_octa_dieb, 4, octa_dieb5); ai_forward(this, 14); }
void octa_dieb3(entity this) { set_animofs(this, anim_octa_dieb, 3, octa_dieb4); }
void octa_dieb2(entity this) { set_animofs(this, anim_octa_dieb, 2, octa_dieb3); }
void octa_dieb1(entity this) { set_animofs(this, anim_octa_dieb, 1, octa_dieb2); this.solid = SOLID_NOT; }

void octa_die(entity this, entity inflictor, entity attacker, int deathtype)
{
// check for gib
	if(this.health < -35)
	{
		_sound(this, CH_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead(this, inflictor, "progs/gib1.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib1.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib2.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib3.mdl", this.health);
		return;
	}

// regular death
	set_movetype(this, MOVETYPE_TOSS);
	this.velocity_x = -200 + 400*random();
	this.velocity_y = -200 + 400*random();
	this.velocity_z = 100 + 100*random();
	UNSET_ONGROUND(this);
	_sound(this, CH_VOICE, "tronyn/mon_bigfish_death.wav", 1, ATTN_NORM);
	if(random() < 0.5)
		octa_die1(this);
	else
		octa_dieb1(this);
}

// QUAKED monster_octa (1 0 0) (-16 -16 -24) (16 16 40) Ambush
spawnfunc(monster_octa) { monster_start(this, true, MON_OCTA); }
#endif // SVQC

#ifdef SVQC
METHOD(Octa, mr_setup, bool(Octa this, entity actor))
{
    TC(Octa, this);

	precache_model("progs/gib1.mdl");
	precache_model("progs/gib2.mdl");
	precache_model("progs/gib3.mdl");

	precache_model("progs/madfox/wink.spr");
	precache_sound("tronyn/mon_anglerfish_bite.wav");
	//precache_sound("tronyn/mon_bigfish_bite.wav");
	precache_sound("tronyn/mon_bigfish_swim1.wav");
	precache_sound("tronyn/mon_bigfish_swim2.wav");
	precache_sound("tronyn/mon_seahorse_swim1.wav");
	precache_sound("tronyn/mon_seahorse_swim2.wav");
	precache_sound("tronyn/mon_bigfish_pain.wav");
	precache_sound("tronyn/mon_bigfish_death.wav");

	precache_sound("player/udeath.wav");		// gib death

    actor.health = 120;
    actor.th_stand = octa_stand1;
	actor.th_walk = octa_walk1;
	actor.th_run = octa_run1;
	actor.th_melee = octa_attack;
	actor.th_missile = octa_attack;
	actor.th_pain = octa_pain;
	actor.th_die = octa_die;

    return true;
}
#endif
