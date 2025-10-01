#include "enforcer.qh"

#ifdef SVQC
const int anim_norb_stand = 0; //'0 20 0'
const int anim_norb_walk = 21; //'21 32 0'
const int anim_norb_run = 33; //'33 41 0'
const int anim_norb_bckrun = 42; //'42 50 0'
const int anim_norb_roll = 51; //'51 61 0'
const int anim_norb_sneak = 62; //'62 69 0'
const int anim_norb_jump = 70; //'70 93 0'
const int anim_norb_die = 94; //'94 126 0'
const int anim_norb_diea = 127; //'127 156 0'
const int anim_norb_dieb = 157; //'157 186 0'

void Orb_Touch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;		// don't explode on owner

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}
	
	if(!(this.spawnflags & SPAWNFLAG_SILENT))
		_sound(this, CH_WEAPON_SINGLE, "enforcer/enfstop.wav", 1, ATTN_STATIC);
	vector org = this.origin - 8*normalize(this.velocity);

	if(toucher.health)
	{
		//SpawnBlood(org, this.velocity*0.2, 15, toucher);
		T_Damage(toucher, this, this.owner, 10, this.projectiledeathtype);
	}
	else
		te_gunshot(org);
	
	delete(this);	
}

entity OrbLaunch(entity this, vector org, vector vec)
{
	if(this.monsterdef == MON_NORB)
		_sound(this, CH_WEAPON_SINGLE, "enforcer/enfire.wav", 1, ATTN_NORM);

	vector vec2 = normalize(vec);
	
	entity newmis = new(enforcer_laser);
	newmis.flags = FL_PROJECTILE;
	newmis.owner = this;
	newmis.projectiledeathtype = DEATH_MONSTER_NORB.m_id;
	newmis.clipgroup = this.clipgroup;
	set_movetype(newmis, MOVETYPE_FLY);
	newmis.solid = SOLID_BBOX;
	newmis.effects = EF_DIMLIGHT;

	_setmodel(newmis, "progs/laser.mdl");
	setsize(newmis, '0 0 0', '0 0 0');

	setorigin(newmis, org);

	newmis.velocity = vec2 * 600;
	newmis.angles = vectoangles(newmis.velocity);

	newmis.nextthink = time + 5;
	setthink(newmis, SUB_Remove);
	settouch(newmis, Orb_Touch);

	IL_PUSH(g_projectiles, newmis);

	return newmis;
}

void orb_fire(entity this)
{
	this.effects |= EF_MUZZLEFLASH;
	fixedmakevectors(this.angles);
	
	vector org = this.origin + '0 0 16';

	OrbLaunch(this, org, this.enemy.origin - this.origin);
}

//============================================================================

void orb_stand1(entity this);
void orb_stand21(entity this) { set_animofs(this, anim_norb_stand, 21, orb_stand1); ai_stand(this);}
void orb_stand20(entity this) { set_animofs(this, anim_norb_stand, 20, orb_stand21); ai_stand(this);}
void orb_stand19(entity this) { set_animofs(this, anim_norb_stand, 19, orb_stand20); ai_stand(this);}
void orb_stand18(entity this) { set_animofs(this, anim_norb_stand, 18, orb_stand19); ai_stand(this);}
void orb_stand17(entity this) { set_animofs(this, anim_norb_stand, 17, orb_stand18); ai_stand(this);}
void orb_stand16(entity this) { set_animofs(this, anim_norb_stand, 16, orb_stand17); ai_stand(this);}
void orb_stand15(entity this) { set_animofs(this, anim_norb_stand, 15, orb_stand16); ai_stand(this);}
void orb_stand14(entity this) { set_animofs(this, anim_norb_stand, 14, orb_stand15); ai_stand(this);}
void orb_stand13(entity this) { set_animofs(this, anim_norb_stand, 13, orb_stand14); ai_stand(this);}
void orb_stand12(entity this) { set_animofs(this, anim_norb_stand, 12, orb_stand13); ai_stand(this);}
void orb_stand11(entity this) { set_animofs(this, anim_norb_stand, 11, orb_stand12); ai_stand(this);}
void orb_stand10(entity this) { set_animofs(this, anim_norb_stand, 10, orb_stand11); ai_stand(this);}
void orb_stand9(entity this) { set_animofs(this, anim_norb_stand, 9, orb_stand10); ai_stand(this);}
void orb_stand8(entity this) { set_animofs(this, anim_norb_stand, 8, orb_stand9); ai_stand(this);}
void orb_stand7(entity this) { set_animofs(this, anim_norb_stand, 7, orb_stand8); ai_stand(this);}
void orb_stand6(entity this) { set_animofs(this, anim_norb_stand, 6, orb_stand7); ai_stand(this);}
void orb_stand5(entity this) { set_animofs(this, anim_norb_stand, 5, orb_stand6); ai_stand(this);}
void orb_stand4(entity this) { set_animofs(this, anim_norb_stand, 4, orb_stand5); ai_stand(this);}
void orb_stand3(entity this) { set_animofs(this, anim_norb_stand, 3, orb_stand4); ai_stand(this);}
void orb_stand2(entity this) { set_animofs(this, anim_norb_stand, 2, orb_stand3); ai_stand(this);}
void orb_stand1(entity this)
{
	set_animofs(this, anim_norb_stand, 1, orb_stand2);
	if(random() < 0.2)
		_sound(this, CH_VOICE, "orb/sight2.wav", 1, ATTN_IDLE);
	ai_stand(this);
}

void orb_walk1(entity this);
void orb_walk12(entity this) { set_animofs(this, anim_norb_walk, 12, orb_walk1); ai_walk(this, 2); }
void orb_walk11(entity this) { set_animofs(this, anim_norb_walk, 11, orb_walk12); ai_walk(this, 2); }
void orb_walk10(entity this) { set_animofs(this, anim_norb_walk, 10, orb_walk11); ai_walk(this, 3); }
void orb_walk9(entity this) { set_animofs(this, anim_norb_walk, 9, orb_walk10); ai_walk(this, 3); }
void orb_walk8(entity this) { set_animofs(this, anim_norb_walk, 8, orb_walk9); ai_walk(this, 4); }
void orb_walk7(entity this) { set_animofs(this, anim_norb_walk, 7, orb_walk8); ai_walk(this, 3); }
void orb_walk6(entity this) { set_animofs(this, anim_norb_walk, 6, orb_walk7); ai_walk(this, 2); }
void orb_walk5(entity this) { set_animofs(this, anim_norb_walk, 5, orb_walk6); ai_walk(this, 3); }
void orb_walk4(entity this) { set_animofs(this, anim_norb_walk, 4, orb_walk5); ai_walk(this, 4); }
void orb_walk3(entity this) { set_animofs(this, anim_norb_walk, 3, orb_walk4); ai_walk(this, 5); }
void orb_walk2(entity this) { set_animofs(this, anim_norb_walk, 2, orb_walk3); ai_walk(this, 4); }
void orb_walk1(entity this)
{
	set_animofs(this, anim_norb_walk, 1, orb_walk2);
	if(random() < 0.2)
		_sound(this, CH_VOICE, "orb/idle1.wav", 1, ATTN_IDLE);
	ai_walk(this, 3);
}

void orb_run1(entity this);
void orb_run9(entity this) { set_animofs(this, anim_norb_run, 9, orb_run1); ai_run(this, 9); }
void orb_run8(entity this) { set_animofs(this, anim_norb_run, 8, orb_run9); ai_run(this, 14); }
void orb_run7(entity this) { set_animofs(this, anim_norb_run, 7, orb_run8); ai_run(this, 20); }
void orb_run6(entity this) { set_animofs(this, anim_norb_run, 6, orb_run7); ai_run(this, 14); }
void orb_run5(entity this) { set_animofs(this, anim_norb_run, 5, orb_run6); ai_run(this, 9); }
void orb_run4(entity this) { set_animofs(this, anim_norb_run, 4, orb_run5); ai_run(this, 7); }
void orb_run3(entity this) { set_animofs(this, anim_norb_run, 3, orb_run4); ai_run(this, 9); }
void orb_run2(entity this) { set_animofs(this, anim_norb_run, 2, orb_run3); ai_run(this, 13); }
void orb_run1(entity this)
{
	set_animofs(this, anim_norb_run, 1, orb_run2);
	if(random() < 0.2)
		_sound(this, CH_VOICE, "orb/sight4.wav", 1, ATTN_IDLE);
	ai_run(this, 20);
}

void orb_bkrun5(entity this) { set_animofs(this, anim_norb_bckrun, 5, orb_run1); ai_pain(this, 4); }
void orb_bkrun4(entity this) { set_animofs(this, anim_norb_bckrun, 4, orb_bkrun5); ai_pain(this, 5); }
void orb_bkrun3(entity this) { set_animofs(this, anim_norb_bckrun, 3, orb_bkrun4); ai_pain(this, 8); }
void orb_bkrun2(entity this) { set_animofs(this, anim_norb_bckrun, 2, orb_bkrun3); ai_pain(this, 5); }
void orb_bkrun1(entity this) { set_animofs(this, anim_norb_bckrun, 1, orb_bkrun2); ai_pain(this, 4); }

void orb_bckrun9(entity this) { set_animofs(this, anim_norb_bckrun, 9, orb_run1); ai_face(this); }
void orb_bckrun8(entity this) { set_animofs(this, anim_norb_bckrun, 8, orb_bckrun9); ai_pain(this, 8); }
void orb_bckrun7(entity this) { set_animofs(this, anim_norb_bckrun, 7, orb_bckrun8); ai_pain(this, 16); }
void orb_bckrun6(entity this) { set_animofs(this, anim_norb_bckrun, 6, orb_bckrun7); ai_pain(this, 10); }
void orb_bckrun5(entity this) { set_animofs(this, anim_norb_bckrun, 5, orb_bckrun6); ai_pain(this, 8); }
void orb_bckrun4(entity this) { set_animofs(this, anim_norb_bckrun, 4, orb_bckrun5); ai_pain(this, 10); }
void orb_bckrun3(entity this) { set_animofs(this, anim_norb_bckrun, 3, orb_bckrun4); ai_pain(this, 16); }
void orb_bckrun2(entity this) { set_animofs(this, anim_norb_bckrun, 2, orb_bckrun3); ai_pain(this, 10); }
void orb_bckrun1(entity this) { set_animofs(this, anim_norb_bckrun, 1, orb_bckrun2); ai_pain(this, 8); }

void orb_roll11(entity this) { set_animofs(this, anim_norb_roll, 11, orb_run1); ai_painforward(this, 7); }
void orb_roll10(entity this) { set_animofs(this, anim_norb_roll, 10, orb_roll11); ai_painforward(this, 6); }
void orb_roll9(entity this) { set_animofs(this, anim_norb_roll, 9, orb_roll10); ai_painforward(this, 8); }
void orb_roll8(entity this) { set_animofs(this, anim_norb_roll, 8, orb_roll9); ai_painforward(this, 10); }
void orb_roll7(entity this) { set_animofs(this, anim_norb_roll, 7, orb_roll8); ai_painforward(this, 12); }
void orb_roll6(entity this) { set_animofs(this, anim_norb_roll, 6, orb_roll7); ai_painforward(this, 14); }
void orb_roll5(entity this) { set_animofs(this, anim_norb_roll, 5, orb_roll6); ai_painforward(this, 18); }
void orb_roll4(entity this) { set_animofs(this, anim_norb_roll, 4, orb_roll5); ai_painforward(this, 16); }
void orb_roll3(entity this) { set_animofs(this, anim_norb_roll, 3, orb_roll4); ai_painforward(this, 14); }
void orb_roll2(entity this) { set_animofs(this, anim_norb_roll, 2, orb_roll3); ai_painforward(this, 12); }
void orb_roll1(entity this) { set_animofs(this, anim_norb_roll, 1, orb_roll2); ai_painforward(this, 8); }

void orb_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;

	float r = random();
	if(r < 0.33)
		_sound(this, CH_VOICE, "orb/pain1.wav", 1, ATTN_NORM);
	else if(r < 0.66)
		_sound(this, CH_VOICE, "orb/pain2.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_VOICE, "orb/pain3.wav", 1, ATTN_NORM);

	// NOTE: delays are needed to prevent an infinite loop as norb steps backward!
	if(r < 0.4)
	{
		this.pain_finished = time + 1;
		setthink(this, orb_bkrun1);
		this.nextthink = time;
	}
	else if(r < 0.7)
	{
		this.pain_finished = time + 1;
		setthink(this, orb_bckrun1);
		this.nextthink = time;
	}
	else
	{
		this.pain_finished = time + 1;
		setthink(this, orb_roll1);
		this.nextthink = time;
	}
}

void orb_sneak8(entity this) { set_animofs(this, anim_norb_sneak, 8, orb_run1); ai_face(this); }
void orb_sneak7(entity this) { set_animofs(this, anim_norb_sneak, 7, orb_sneak8); orb_fire(this); this.effects |= EF_MUZZLEFLASH; }
void orb_sneak6(entity this) { set_animofs(this, anim_norb_sneak, 6, orb_sneak7); ai_face(this); }
void orb_sneak5(entity this) { set_animofs(this, anim_norb_sneak, 5, orb_sneak6); ai_face(this); }
void orb_sneak4(entity this) { set_animofs(this, anim_norb_sneak, 4, orb_sneak5); orb_fire(this); this.effects |= EF_MUZZLEFLASH; }
void orb_sneak3(entity this) { set_animofs(this, anim_norb_sneak, 3, orb_sneak4); ai_face(this); }
void orb_sneak2(entity this) { set_animofs(this, anim_norb_sneak, 2, orb_sneak3); ai_face(this); }
void orb_sneak1(entity this) { set_animofs(this, anim_norb_sneak, 1, orb_sneak2); ai_face(this); }

void orb_runatk9(entity this) { set_animofs(this, anim_norb_run, 9, orb_run1); ai_face(this); }
void orb_runatk8(entity this) { set_animofs(this, anim_norb_run, 8, orb_runatk9); orb_fire(this); this.effects |= EF_MUZZLEFLASH; }
void orb_runatk7(entity this) { set_animofs(this, anim_norb_run, 7, orb_runatk8); ai_face(this); }
void orb_runatk6(entity this) { set_animofs(this, anim_norb_run, 6, orb_runatk7); ai_face(this); }
void orb_runatk5(entity this) { set_animofs(this, anim_norb_run, 5, orb_runatk6); ai_face(this); }
void orb_runatk4(entity this) { set_animofs(this, anim_norb_run, 4, orb_runatk5); orb_fire(this); this.effects |= EF_MUZZLEFLASH; }
void orb_runatk3(entity this) { set_animofs(this, anim_norb_run, 3, orb_runatk4); ai_face(this); }
void orb_runatk2(entity this) { set_animofs(this, anim_norb_run, 2, orb_runatk3); ai_face(this); }
void orb_runatk1(entity this)
{
	set_animofs(this, anim_norb_run, 1, orb_runatk2); 
	if(random() < 0.2)
		_sound(this, CH_VOICE, "orb/sight4.wav", 1, ATTN_IDLE);
	ai_face(this);
}

void orb_jump1(entity this);
void orb_attack(entity this)
{
	float r = random();
	if(r < 0.65)
		orb_sneak1(this);
	else
	{
//		if((vlen (delta) <= 300) && (random () < 0.5))
		if(r < 0.90)
			orb_runatk1(this);
		else
			orb_jump1(this);
	}
}

//============================================================================

void Orb_JumpTouch(entity this, entity toucher)
{
	if(this.health <= 0 || (!this.takedamage))
		return;

	if(toucher.takedamage && this.attack_finished < time)
	{
		if(vdist(this.velocity, >, 400))
		{
			float ldmg = 20 + 10*random();
			T_Damage(toucher, this, this, ldmg, DEATH_MONSTER_NORB.m_id);
			this.attack_finished = time + 0.5;
		}
	}

	if(!t_checkbottom(this))
	{
		if(IS_ONGROUND(this) && this.exptime == 0)
		{	// jump randomly to not get hung up
			//dprint("popjump\n");
			settouch(this, func_null);
			setthink(this, orb_jump1);
			this.nextthink = time + 0.1;
		}
		return;	// not on ground yet
	}
}

void orb_jump24(entity this) { set_animofs(this, anim_norb_jump, 24, orb_run1); ai_face(this); }
void orb_jump23(entity this) { set_animofs(this, anim_norb_jump, 23, orb_jump24); ai_face(this); }
void orb_jump22(entity this) { set_animofs(this, anim_norb_jump, 22, orb_jump23); ai_face(this); }
void orb_jump21(entity this) { set_animofs(this, anim_norb_jump, 21, orb_jump22); ai_face(this); }
void orb_jump20(entity this) { set_animofs(this, anim_norb_jump, 20, orb_jump21); ai_face(this); }
void orb_jump19(entity this) { set_animofs(this, anim_norb_jump, 19, orb_jump20); ai_face(this); }
void orb_jump18(entity this) { set_animofs(this, anim_norb_jump, 18, orb_jump19); ai_face(this); }
void orb_jump17(entity this) { set_animofs(this, anim_norb_jump, 17, orb_jump18); ai_face(this); }
void orb_jump16(entity this) { set_animofs(this, anim_norb_jump, 16, orb_jump17); ai_face(this); }
void orb_jump15(entity this) { set_animofs(this, anim_norb_jump, 15, orb_jump16); ai_face(this); }
void orb_jump14(entity this) { set_animofs(this, anim_norb_jump, 14, orb_jump15); ai_face(this); }
void orb_jump13(entity this) { set_animofs(this, anim_norb_jump, 13, orb_jump14); ai_face(this); }
void orb_jump12(entity this) { set_animofs(this, anim_norb_jump, 12, orb_jump13); ai_face(this); }
void orb_jump11(entity this) { set_animofs(this, anim_norb_jump, 11, orb_jump12); ai_face(this); }
void orb_jump10(entity this)
{
	set_animofs(this, anim_norb_jump, 10, orb_jump1);
	if(this.exptime != 0)
		return;
	if(IS_ONGROUND(this))
	{
		settouch(this, func_null);
		setthink(this, orb_jump11);
		return;
	}
	// still jumping
	setthink(this, orb_jump1);
}
void orb_jump9(entity this) { set_animofs(this, anim_norb_jump, 9, orb_jump10); ai_face(this); }
void orb_jump8(entity this) { set_animofs(this, anim_norb_jump, 8, orb_jump9); ai_face(this); }
void orb_jump7(entity this) { set_animofs(this, anim_norb_jump, 7, orb_jump8); ai_face(this); }
void orb_jump6(entity this) { set_animofs(this, anim_norb_jump, 6, orb_jump7); ai_face(this); }
void orb_jump5(entity this)
{
	set_animofs(this, anim_norb_jump, 5, orb_jump6);
	ai_face(this);

	settouch(this, Orb_JumpTouch);
	makevectors(this.angles);
	this.origin_z = this.origin_z + 1;
	this.velocity = v_forward * 200 + '0 0 200';
	UNSET_ONGROUND(this);
}
void orb_jump4(entity this) { set_animofs(this, anim_norb_jump, 4, orb_jump5); ai_face(this); }
void orb_jump3(entity this) { set_animofs(this, anim_norb_jump, 3, orb_jump4); ai_face(this); }
void orb_jump2(entity this) { set_animofs(this, anim_norb_jump, 2, orb_jump3); ai_face(this); }
void orb_jump1(entity this)
{
	set_animofs(this, anim_norb_jump, 1, orb_jump2);
	if(random() < 0.2)
		_sound(this, CH_VOICE, "orb/sight1.wav", 1, ATTN_IDLE);
	ai_face(this);
}

void orb_die33(entity this) { set_animofs(this, anim_norb_die, 33, orb_die33); CorpseThink(this); }
void orb_die32(entity this) { set_animofs(this, anim_norb_die, 32, orb_die33); }
void orb_die31(entity this) { set_animofs(this, anim_norb_die, 31, orb_die32); }
void orb_die30(entity this) { set_animofs(this, anim_norb_die, 30, orb_die31); }
void orb_die29(entity this) { set_animofs(this, anim_norb_die, 29, orb_die30); }
void orb_die28(entity this) { set_animofs(this, anim_norb_die, 28, orb_die29); }
void orb_die27(entity this) { set_animofs(this, anim_norb_die, 27, orb_die28); }
void orb_die26(entity this) { set_animofs(this, anim_norb_die, 26, orb_die27); }
void orb_die25(entity this) { set_animofs(this, anim_norb_die, 25, orb_die26); }
void orb_die24(entity this) { set_animofs(this, anim_norb_die, 24, orb_die25); }
void orb_die23(entity this) { set_animofs(this, anim_norb_die, 23, orb_die24); }
void orb_die22(entity this) { set_animofs(this, anim_norb_die, 22, orb_die23); }
void orb_die21(entity this) { set_animofs(this, anim_norb_die, 21, orb_die22); }
void orb_die20(entity this) { set_animofs(this, anim_norb_die, 20, orb_die21); }
void orb_die19(entity this) { set_animofs(this, anim_norb_die, 19, orb_die20); }
void orb_die18(entity this) { set_animofs(this, anim_norb_die, 18, orb_die19); }
void orb_die17(entity this) { set_animofs(this, anim_norb_die, 17, orb_die18); }
void orb_die16(entity this) { set_animofs(this, anim_norb_die, 16, orb_die17); }
void orb_die15(entity this) { set_animofs(this, anim_norb_die, 15, orb_die16); }
void orb_die14(entity this) { set_animofs(this, anim_norb_die, 14, orb_die15); }
void orb_die13(entity this) { set_animofs(this, anim_norb_die, 13, orb_die14); }
void orb_die12(entity this) { set_animofs(this, anim_norb_die, 12, orb_die13); }
void orb_die11(entity this) { set_animofs(this, anim_norb_die, 11, orb_die12); }
void orb_die10(entity this) { set_animofs(this, anim_norb_die, 10, orb_die11); }
void orb_die9(entity this) { set_animofs(this, anim_norb_die, 9, orb_die10); }
void orb_die8(entity this) { set_animofs(this, anim_norb_die, 8, orb_die9); }
void orb_die7(entity this) { set_animofs(this, anim_norb_die, 7, orb_die8); }
void orb_die6(entity this) { set_animofs(this, anim_norb_die, 6, orb_die7); }
void orb_die5(entity this) { set_animofs(this, anim_norb_die, 5, orb_die6); }
void orb_die4(entity this) { set_animofs(this, anim_norb_die, 4, orb_die5); }
void orb_die3(entity this) { set_animofs(this, anim_norb_die, 3, orb_die4); }
void orb_die2(entity this) { set_animofs(this, anim_norb_die, 2, orb_die3); }
void orb_die1(entity this) { set_animofs(this, anim_norb_die, 1, orb_die2); this.solid = SOLID_NOT; }

void orb_diea30(entity this) { set_animofs(this, anim_norb_diea, 30, orb_diea30); CorpseThink(this); }
void orb_diea29(entity this) { set_animofs(this, anim_norb_diea, 29, orb_diea30); }
void orb_diea28(entity this) { set_animofs(this, anim_norb_diea, 28, orb_diea29); }
void orb_diea27(entity this) { set_animofs(this, anim_norb_diea, 27, orb_diea28); }
void orb_diea26(entity this) { set_animofs(this, anim_norb_diea, 26, orb_diea27); }
void orb_diea25(entity this) { set_animofs(this, anim_norb_diea, 25, orb_diea26); }
void orb_diea24(entity this) { set_animofs(this, anim_norb_diea, 24, orb_diea25); }
void orb_diea23(entity this) { set_animofs(this, anim_norb_diea, 23, orb_diea24); }
void orb_diea22(entity this) { set_animofs(this, anim_norb_diea, 22, orb_diea23); }
void orb_diea21(entity this) { set_animofs(this, anim_norb_diea, 21, orb_diea22); }
void orb_diea20(entity this) { set_animofs(this, anim_norb_diea, 20, orb_diea21); }
void orb_diea19(entity this) { set_animofs(this, anim_norb_diea, 19, orb_diea20); }
void orb_diea18(entity this) { set_animofs(this, anim_norb_diea, 18, orb_diea19); }
void orb_diea17(entity this) { set_animofs(this, anim_norb_diea, 17, orb_diea18); }
void orb_diea16(entity this) { set_animofs(this, anim_norb_diea, 16, orb_diea17); }
void orb_diea15(entity this) { set_animofs(this, anim_norb_diea, 15, orb_diea16); }
void orb_diea14(entity this) { set_animofs(this, anim_norb_diea, 14, orb_diea15); }
void orb_diea13(entity this) { set_animofs(this, anim_norb_diea, 13, orb_diea14); }
void orb_diea12(entity this) { set_animofs(this, anim_norb_diea, 12, orb_diea13); }
void orb_diea11(entity this) { set_animofs(this, anim_norb_diea, 11, orb_diea12); }
void orb_diea10(entity this) { set_animofs(this, anim_norb_diea, 10, orb_diea11); }
void orb_diea9(entity this) { set_animofs(this, anim_norb_diea, 9, orb_diea10); }
void orb_diea8(entity this) { set_animofs(this, anim_norb_diea, 8, orb_diea9); }
void orb_diea7(entity this) { set_animofs(this, anim_norb_diea, 7, orb_diea8); }
void orb_diea6(entity this) { set_animofs(this, anim_norb_diea, 6, orb_diea7); }
void orb_diea5(entity this) { set_animofs(this, anim_norb_diea, 5, orb_diea6); }
void orb_diea4(entity this) { set_animofs(this, anim_norb_diea, 4, orb_diea5); }
void orb_diea3(entity this) { set_animofs(this, anim_norb_diea, 3, orb_diea4); }
void orb_diea2(entity this) { set_animofs(this, anim_norb_diea, 2, orb_diea3); }
void orb_diea1(entity this) { set_animofs(this, anim_norb_diea, 1, orb_diea2); this.solid = SOLID_NOT; }

void orb_dieb30(entity this) { set_animofs(this, anim_norb_dieb, 30, orb_dieb30); CorpseThink(this); }
void orb_dieb29(entity this) { set_animofs(this, anim_norb_dieb, 29, orb_dieb30); }
void orb_dieb28(entity this) { set_animofs(this, anim_norb_dieb, 28, orb_dieb29); }
void orb_dieb27(entity this) { set_animofs(this, anim_norb_dieb, 27, orb_dieb28); }
void orb_dieb26(entity this) { set_animofs(this, anim_norb_dieb, 26, orb_dieb27); }
void orb_dieb25(entity this) { set_animofs(this, anim_norb_dieb, 25, orb_dieb26); }
void orb_dieb24(entity this) { set_animofs(this, anim_norb_dieb, 24, orb_dieb25); }
void orb_dieb23(entity this) { set_animofs(this, anim_norb_dieb, 23, orb_dieb24); }
void orb_dieb22(entity this) { set_animofs(this, anim_norb_dieb, 22, orb_dieb23); }
void orb_dieb21(entity this) { set_animofs(this, anim_norb_dieb, 21, orb_dieb22); }
void orb_dieb20(entity this) { set_animofs(this, anim_norb_dieb, 20, orb_dieb21); }
void orb_dieb19(entity this) { set_animofs(this, anim_norb_dieb, 19, orb_dieb20); }
void orb_dieb18(entity this) { set_animofs(this, anim_norb_dieb, 18, orb_dieb19); }
void orb_dieb17(entity this) { set_animofs(this, anim_norb_dieb, 17, orb_dieb18); }
void orb_dieb16(entity this) { set_animofs(this, anim_norb_dieb, 16, orb_dieb17); }
void orb_dieb15(entity this) { set_animofs(this, anim_norb_dieb, 15, orb_dieb16); }
void orb_dieb14(entity this) { set_animofs(this, anim_norb_dieb, 14, orb_dieb15); }
void orb_dieb13(entity this) { set_animofs(this, anim_norb_dieb, 13, orb_dieb14); }
void orb_dieb12(entity this) { set_animofs(this, anim_norb_dieb, 12, orb_dieb13); }
void orb_dieb11(entity this) { set_animofs(this, anim_norb_dieb, 11, orb_dieb12); }
void orb_dieb10(entity this) { set_animofs(this, anim_norb_dieb, 10, orb_dieb11); }
void orb_dieb9(entity this) { set_animofs(this, anim_norb_dieb, 9, orb_dieb10); }
void orb_dieb8(entity this) { set_animofs(this, anim_norb_dieb, 8, orb_dieb9); }
void orb_dieb7(entity this) { set_animofs(this, anim_norb_dieb, 7, orb_dieb8); }
void orb_dieb6(entity this) { set_animofs(this, anim_norb_dieb, 6, orb_dieb7); }
void orb_dieb5(entity this) { set_animofs(this, anim_norb_dieb, 5, orb_dieb6); }
void orb_dieb4(entity this) { set_animofs(this, anim_norb_dieb, 4, orb_dieb5); }
void orb_dieb3(entity this) { set_animofs(this, anim_norb_dieb, 3, orb_dieb4); }
void orb_dieb2(entity this) { set_animofs(this, anim_norb_dieb, 2, orb_dieb3); }
void orb_dieb1(entity this) { set_animofs(this, anim_norb_dieb, 1, orb_dieb2); this.solid = SOLID_NOT; }

void orb_die(entity this, entity inflictor, entity attacker, int deathtype)
{
// check for gib
	if(this.health < -35)
	{
		_sound(this, CH_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead(this, inflictor, "progs/h_mega.mdl", this.health);
		ThrowGib(this, inflictor, "progs/h_orb.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib2.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib3.mdl", this.health);
		return;
	}

// regular death
	_sound(this, CH_VOICE, "orb/death1.wav", 1, ATTN_NORM);
	if(random() > 0.65)
		orb_die1(this);
	else if(random() > 0.9)
		orb_diea1(this);
	else
		orb_dieb1(this);
}

void orb_melee(entity this)
{
	if(this.attack_finished > time)
		return;

	if(random() > 0.5)
	{
		orb_sneak1(this);
		this.pain_finished = time + 1;
	}
	else 
	{
		orb_runatk1(this);
		this.pain_finished = time + 1;
	}
}

/*QUAKED monster_orb(1 0 0)(-16 -16 -24)(16 16 40) Ambush
*/
spawnfunc(monster_orb) { monster_start(this, true, MON_NORB); }
#endif // SVQC

#ifdef SVQC
METHOD(Norb, mr_setup, bool(Norb this, entity actor))
{
	TC(Norb, this);

	precache_model("progs/h_orb.mdl");
	precache_model("progs/laser.mdl");

	precache_sound("orb/death1.wav");
	precache_sound("enforcer/enfire.wav");
	precache_sound("enforcer/enfstop.wav");
	precache_sound("orb/idle1.wav");
	precache_sound("orb/pain1.wav");
	precache_sound("orb/pain2.wav");
	precache_sound("orb/pain3.wav");
	precache_sound("orb/sight1.wav");
	precache_sound("orb/sight2.wav");
	precache_sound("orb/sight3.wav");
	precache_sound("orb/sight4.wav");
	precache_sound("soldier/sattck1.wav");

	actor.health = 150;
	actor.th_stand = orb_stand1;
	actor.th_walk = orb_walk1;
	actor.th_run = orb_run1;
	actor.th_pain = orb_pain;
	actor.th_die = orb_die;
	actor.th_missile = orb_attack;
	actor.th_melee = orb_melee;

	return true;
}
METHOD(Norb, mr_sight, bool(Norb this, entity actor))
{
    TC(Norb, this);

	sound(actor, CH_VOICE, SND_MON_NORB_SIGHT_RANDOM(), 1, ATTN_NORM);

    return true;
}
#endif
