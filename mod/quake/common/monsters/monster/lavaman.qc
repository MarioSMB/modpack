#include "lavaman.qh"

#include "../../../server/triggers/triggers.qh"
#include "../../../server/triggers/func/door.qh"

#ifdef SVQC
const int anim_lavaman_rise1 = 0;
const int anim_lavaman_walk1 = 17;
const int anim_lavaman_death1 = 48;
const int anim_lavaman_attack1 = 57;
const int anim_lavaman_shocka1 = 80;

/*
===========
LavaManCheckAttack

The player is in view, so decide to move or launch an attack
Returns false if movement should continue
============
*/
bool LavaManCheckAttack(entity this)
{
	ai_face(this);

	entity targ = this.enemy;

// see if any entities are in the way of the shot
	vector spot1 = this.origin + '0 0 64';

	traceline(spot1, targ.origin, false, this);

	if(trace_inopen && trace_inwater)
		return false;			// sight line crossed contents
	if(trace_ent != targ)
		return false;			// don't have a clear shot
			
// missile attack
	if(time < this.attack_finished)
		return false;

	this.th_missile(this);
	SUB_AttackFinished(this, 1 + random());
	return true;
}

// ============
// ============
void lavaman_hunt(entity this)
{
// go for another player if multi player
	if(this.enemy.health <= 0)
	{
		vector viewPoint = this.origin + '0 0 96';
		entity possibleEnemy = find(this.enemy, classname, "player");
		traceline(viewPoint, possibleEnemy.origin, true, NULL);
		if(trace_fraction == 1)
			this.enemy = possibleEnemy;
	}
	if(this.enemy)
	{
		ai_face(this);
		this.movetarget = this.enemy;
		this.goalentity = this.enemy;
	}
}

void lavaman_fire1(entity this);
void lavaman_rise17(entity this) { set_animofs(this, anim_lavaman_rise1, 17, lavaman_fire1); }
void lavaman_rise16(entity this) { set_animofs(this, anim_lavaman_rise1, 16, lavaman_rise17); }
void lavaman_rise15(entity this) { set_animofs(this, anim_lavaman_rise1, 15, lavaman_rise16); }
void lavaman_rise14(entity this) { set_animofs(this, anim_lavaman_rise1, 14, lavaman_rise15); }
void lavaman_rise13(entity this) { set_animofs(this, anim_lavaman_rise1, 13, lavaman_rise14); }
void lavaman_rise12(entity this) { set_animofs(this, anim_lavaman_rise1, 12, lavaman_rise13); }
void lavaman_rise11(entity this) { set_animofs(this, anim_lavaman_rise1, 11, lavaman_rise12); }
void lavaman_rise10(entity this) { set_animofs(this, anim_lavaman_rise1, 10, lavaman_rise11); }
void lavaman_rise9(entity this) { set_animofs(this, anim_lavaman_rise1, 9, lavaman_rise10); }
void lavaman_rise8(entity this) { set_animofs(this, anim_lavaman_rise1, 8, lavaman_rise9); }
void lavaman_rise7(entity this) { set_animofs(this, anim_lavaman_rise1, 7, lavaman_rise8); }
void lavaman_rise6(entity this) { set_animofs(this, anim_lavaman_rise1, 6, lavaman_rise7); }
void lavaman_rise5(entity this) { set_animofs(this, anim_lavaman_rise1, 5, lavaman_rise6); }
void lavaman_rise4(entity this) { set_animofs(this, anim_lavaman_rise1, 4, lavaman_rise5); }
void lavaman_rise3(entity this) { set_animofs(this, anim_lavaman_rise1, 3, lavaman_rise4); }
void lavaman_rise2(entity this) { set_animofs(this, anim_lavaman_rise1, 2, lavaman_rise3); _sound(this, CH_VOICE, "boss1/sight1.wav", 1, ATTN_NORM); }
void lavaman_rise1(entity this) { set_animofs(this, anim_lavaman_rise1, 1, lavaman_rise2); _sound(this, CH_WEAPON_SINGLE, "boss1/out1.wav", 1, ATTN_NORM); }

// ============
// ============
void lavaman_stand(entity this)
{
	if(this.enemy)
		LavaManCheckAttack(this);
	else
		lavaman_hunt(this);

	ai_stand(this);		
}

void lavaman_idle1(entity this);
void lavaman_idle9(entity this) { set_animofs(this, anim_lavaman_walk1, 1, lavaman_idle1); lavaman_stand(this); }
void lavaman_idle8(entity this) { set_animofs(this, anim_lavaman_walk1, 2, lavaman_idle9); lavaman_stand(this); }
void lavaman_idle7(entity this) { set_animofs(this, anim_lavaman_walk1, 3, lavaman_idle8); lavaman_stand(this); }
void lavaman_idle6(entity this) { set_animofs(this, anim_lavaman_walk1, 4, lavaman_idle7); lavaman_stand(this); }
void lavaman_idle5(entity this) { set_animofs(this, anim_lavaman_walk1, 5, lavaman_idle6); lavaman_stand(this); }
void lavaman_idle4(entity this) { set_animofs(this, anim_lavaman_walk1, 4, lavaman_idle5); lavaman_stand(this); }
void lavaman_idle3(entity this) { set_animofs(this, anim_lavaman_walk1, 3, lavaman_idle4); lavaman_stand(this); }
void lavaman_idle2(entity this) { set_animofs(this, anim_lavaman_walk1, 2, lavaman_idle3); lavaman_stand(this); }
void lavaman_idle1(entity this)
{
	set_animofs(this, anim_lavaman_walk1, 1, lavaman_idle2);

	if(random() < 0.2)
		_sound(this, CH_VOICE, "boss1/sight1.wav", 1, ATTN_NORM);
	// look for other players
}

// ============
// ============
void lavaman_walk(entity this)
{
	if(this.enemy)
		LavaManCheckAttack(this);
	else
		lavaman_hunt(this);
	ai_walk(this, 2);
}

void lavaman_walk1(entity this);
void lavaman_walk31(entity this) { set_animofs(this, anim_lavaman_walk1, 31, lavaman_walk1); }
void lavaman_walk30(entity this) { set_animofs(this, anim_lavaman_walk1, 30, lavaman_walk31); lavaman_walk(this); }
void lavaman_walk29(entity this) { set_animofs(this, anim_lavaman_walk1, 29, lavaman_walk30); lavaman_walk(this); }
void lavaman_walk28(entity this) { set_animofs(this, anim_lavaman_walk1, 28, lavaman_walk29); lavaman_walk(this); }
void lavaman_walk27(entity this) { set_animofs(this, anim_lavaman_walk1, 27, lavaman_walk28); lavaman_walk(this); }
void lavaman_walk26(entity this) { set_animofs(this, anim_lavaman_walk1, 26, lavaman_walk27); lavaman_walk(this); }
void lavaman_walk25(entity this) { set_animofs(this, anim_lavaman_walk1, 25, lavaman_walk26); lavaman_walk(this); }
void lavaman_walk24(entity this) { set_animofs(this, anim_lavaman_walk1, 24, lavaman_walk25); lavaman_walk(this); }
void lavaman_walk23(entity this) { set_animofs(this, anim_lavaman_walk1, 23, lavaman_walk24); lavaman_walk(this); }
void lavaman_walk22(entity this) { set_animofs(this, anim_lavaman_walk1, 22, lavaman_walk23); lavaman_walk(this); }
void lavaman_walk21(entity this) { set_animofs(this, anim_lavaman_walk1, 21, lavaman_walk22); lavaman_walk(this); }
void lavaman_walk20(entity this) { set_animofs(this, anim_lavaman_walk1, 20, lavaman_walk21); lavaman_walk(this); }
void lavaman_walk19(entity this) { set_animofs(this, anim_lavaman_walk1, 19, lavaman_walk20); lavaman_walk(this); }
void lavaman_walk18(entity this) { set_animofs(this, anim_lavaman_walk1, 18, lavaman_walk19); lavaman_walk(this); }
void lavaman_walk17(entity this) { set_animofs(this, anim_lavaman_walk1, 17, lavaman_walk18); lavaman_walk(this); }
void lavaman_walk16(entity this) { set_animofs(this, anim_lavaman_walk1, 16, lavaman_walk17); lavaman_walk(this); }
void lavaman_walk15(entity this) { set_animofs(this, anim_lavaman_walk1, 15, lavaman_walk16); lavaman_walk(this); }
void lavaman_walk14(entity this) { set_animofs(this, anim_lavaman_walk1, 14, lavaman_walk15); lavaman_walk(this); }
void lavaman_walk13(entity this) { set_animofs(this, anim_lavaman_walk1, 13, lavaman_walk14); lavaman_walk(this); }
void lavaman_walk12(entity this) { set_animofs(this, anim_lavaman_walk1, 12, lavaman_walk13); lavaman_walk(this); }
void lavaman_walk11(entity this) { set_animofs(this, anim_lavaman_walk1, 11, lavaman_walk12); lavaman_walk(this); }
void lavaman_walk10(entity this) { set_animofs(this, anim_lavaman_walk1, 10, lavaman_walk11); lavaman_walk(this); }
void lavaman_walk9(entity this) { set_animofs(this, anim_lavaman_walk1, 9, lavaman_walk10); lavaman_walk(this); }
void lavaman_walk8(entity this) { set_animofs(this, anim_lavaman_walk1, 8, lavaman_walk9); lavaman_walk(this); }
void lavaman_walk7(entity this) { set_animofs(this, anim_lavaman_walk1, 7, lavaman_walk8); lavaman_walk(this); }
void lavaman_walk6(entity this) { set_animofs(this, anim_lavaman_walk1, 6, lavaman_walk7); lavaman_walk(this); }
void lavaman_walk5(entity this) { set_animofs(this, anim_lavaman_walk1, 5, lavaman_walk6); lavaman_walk(this); }
void lavaman_walk4(entity this) { set_animofs(this, anim_lavaman_walk1, 4, lavaman_walk5); lavaman_walk(this); }
void lavaman_walk3(entity this) { set_animofs(this, anim_lavaman_walk1, 3, lavaman_walk4); lavaman_walk(this); }
void lavaman_walk2(entity this) { set_animofs(this, anim_lavaman_walk1, 2, lavaman_walk3); lavaman_walk(this); }
void lavaman_walk1(entity this) { set_animofs(this, anim_lavaman_walk1, 1, lavaman_walk2); lavaman_walk(this); }

void lavaman_run(entity this)
{
	if(this.enemy)
		LavaManCheckAttack(this);
	else
		lavaman_hunt(this);
	ai_run(this, 2);		
}

void lavaman_run1(entity this);
void lavaman_run31(entity this) { set_animofs(this, anim_lavaman_walk1, 31, lavaman_run1); }
void lavaman_run30(entity this) { set_animofs(this, anim_lavaman_walk1, 30, lavaman_run31); lavaman_run(this);}
void lavaman_run29(entity this) { set_animofs(this, anim_lavaman_walk1, 29, lavaman_run30); lavaman_run(this);}
void lavaman_run28(entity this) { set_animofs(this, anim_lavaman_walk1, 28, lavaman_run29); lavaman_run(this);}
void lavaman_run27(entity this) { set_animofs(this, anim_lavaman_walk1, 27, lavaman_run28); lavaman_run(this);}
void lavaman_run26(entity this) { set_animofs(this, anim_lavaman_walk1, 26, lavaman_run27); lavaman_run(this);}
void lavaman_run25(entity this) { set_animofs(this, anim_lavaman_walk1, 25, lavaman_run26); lavaman_run(this);}
void lavaman_run24(entity this) { set_animofs(this, anim_lavaman_walk1, 24, lavaman_run25); lavaman_run(this);}
void lavaman_run23(entity this) { set_animofs(this, anim_lavaman_walk1, 23, lavaman_run24); lavaman_run(this);}
void lavaman_run22(entity this) { set_animofs(this, anim_lavaman_walk1, 22, lavaman_run23); lavaman_run(this);}
void lavaman_run21(entity this) { set_animofs(this, anim_lavaman_walk1, 21, lavaman_run22); lavaman_run(this);}
void lavaman_run20(entity this) { set_animofs(this, anim_lavaman_walk1, 20, lavaman_run21); lavaman_run(this);}
void lavaman_run19(entity this) { set_animofs(this, anim_lavaman_walk1, 19, lavaman_run20); lavaman_run(this);}
void lavaman_run18(entity this) { set_animofs(this, anim_lavaman_walk1, 18, lavaman_run19); lavaman_run(this);}
void lavaman_run17(entity this) { set_animofs(this, anim_lavaman_walk1, 17, lavaman_run18); lavaman_run(this);}
void lavaman_run16(entity this) { set_animofs(this, anim_lavaman_walk1, 16, lavaman_run17); lavaman_run(this);}
void lavaman_run15(entity this) { set_animofs(this, anim_lavaman_walk1, 15, lavaman_run16); lavaman_run(this);}
void lavaman_run14(entity this) { set_animofs(this, anim_lavaman_walk1, 14, lavaman_run15); lavaman_run(this);}
void lavaman_run13(entity this) { set_animofs(this, anim_lavaman_walk1, 13, lavaman_run14); lavaman_run(this);}
void lavaman_run12(entity this) { set_animofs(this, anim_lavaman_walk1, 12, lavaman_run13); lavaman_run(this);}
void lavaman_run11(entity this) { set_animofs(this, anim_lavaman_walk1, 11, lavaman_run12); lavaman_run(this);}
void lavaman_run10(entity this) { set_animofs(this, anim_lavaman_walk1, 10, lavaman_run11); lavaman_run(this);}
void lavaman_run9(entity this) { set_animofs(this, anim_lavaman_walk1, 9, lavaman_run10); lavaman_run(this);}
void lavaman_run8(entity this) { set_animofs(this, anim_lavaman_walk1, 8, lavaman_run9); lavaman_run(this);}
void lavaman_run7(entity this) { set_animofs(this, anim_lavaman_walk1, 7, lavaman_run8); lavaman_run(this);}
void lavaman_run6(entity this) { set_animofs(this, anim_lavaman_walk1, 6, lavaman_run7); lavaman_run(this);}
void lavaman_run5(entity this) { set_animofs(this, anim_lavaman_walk1, 5, lavaman_run6); lavaman_run(this);}
void lavaman_run4(entity this) { set_animofs(this, anim_lavaman_walk1, 4, lavaman_run5); lavaman_run(this);}
void lavaman_run3(entity this) { set_animofs(this, anim_lavaman_walk1, 3, lavaman_run4); lavaman_run(this);}
void lavaman_run2(entity this) { set_animofs(this, anim_lavaman_walk1, 2, lavaman_run3); lavaman_run(this);}
void lavaman_run1(entity this) { set_animofs(this, anim_lavaman_walk1, 1, lavaman_run2); lavaman_run(this);}

void lavaman_fire23(entity this) { set_animofs(this, anim_lavaman_attack1, 23, lavaman_run1); }
void lavaman_fire22(entity this) { set_animofs(this, anim_lavaman_attack1, 22, lavaman_fire23); ai_charge(this, 1);}
void lavaman_fire21(entity this) { set_animofs(this, anim_lavaman_attack1, 21, lavaman_fire22); ai_face(this);}
void lavaman_fire20(entity this) { set_animofs(this, anim_lavaman_attack1, 20, lavaman_fire21); ai_face(this);}
void lavaman_fire19(entity this) { set_animofs(this, anim_lavaman_attack1, 19, lavaman_fire20); ai_face(this);}
void lavaman_fire18(entity this) { set_animofs(this, anim_lavaman_attack1, 18, lavaman_fire19); lavaman_missile(this, 2);}
void lavaman_fire17(entity this) { set_animofs(this, anim_lavaman_attack1, 17, lavaman_fire18); ai_face(this);}
void lavaman_fire16(entity this) { set_animofs(this, anim_lavaman_attack1, 16, lavaman_fire17); ai_charge(this, 1);}
void lavaman_fire15(entity this) { set_animofs(this, anim_lavaman_attack1, 15, lavaman_fire16); ai_charge(this, 1);}
void lavaman_fire14(entity this) { set_animofs(this, anim_lavaman_attack1, 14, lavaman_fire15); ai_face(this);}
void lavaman_fire13(entity this) { set_animofs(this, anim_lavaman_attack1, 13, lavaman_fire14); ai_face(this);}
void lavaman_fire12(entity this) { set_animofs(this, anim_lavaman_attack1, 12, lavaman_fire13); ai_charge(this, 1);}
void lavaman_fire11(entity this) { set_animofs(this, anim_lavaman_attack1, 11, lavaman_fire12); ai_face(this);}
void lavaman_fire10(entity this) { set_animofs(this, anim_lavaman_attack1, 10, lavaman_fire11); ai_charge(this, 1);}
void lavaman_fire9(entity this) { set_animofs(this, anim_lavaman_attack1, 9, lavaman_fire10); ai_face(this);}
void lavaman_fire8(entity this) { set_animofs(this, anim_lavaman_attack1, 8, lavaman_fire9); ai_face(this);}
void lavaman_fire7(entity this) { set_animofs(this, anim_lavaman_attack1, 7, lavaman_fire8); lavaman_missile(this, 1);}
void lavaman_fire6(entity this) { set_animofs(this, anim_lavaman_attack1, 6, lavaman_fire7); ai_face(this);}
void lavaman_fire5(entity this) { set_animofs(this, anim_lavaman_attack1, 5, lavaman_fire6); ai_charge(this, 1);}
void lavaman_fire4(entity this) { set_animofs(this, anim_lavaman_attack1, 4, lavaman_fire5); ai_face(this);}
void lavaman_fire3(entity this) { set_animofs(this, anim_lavaman_attack1, 3, lavaman_fire4);  ai_face(this);}
void lavaman_fire2(entity this) { set_animofs(this, anim_lavaman_attack1, 2, lavaman_fire3); ai_charge(this, 1);}
void lavaman_fire1(entity this) { set_animofs(this, anim_lavaman_attack1, 1, lavaman_fire2);  ai_face(this);}

void lavaman_shocka10(entity this) { set_animofs(this, anim_lavaman_shocka1, 10, lavaman_run1); }
void lavaman_shocka9(entity this) { set_animofs(this, anim_lavaman_shocka1, 9, lavaman_shocka10); }
void lavaman_shocka8(entity this) { set_animofs(this, anim_lavaman_shocka1, 8, lavaman_shocka9); }
void lavaman_shocka7(entity this) { set_animofs(this, anim_lavaman_shocka1, 7, lavaman_shocka8); }
void lavaman_shocka6(entity this) { set_animofs(this, anim_lavaman_shocka1, 6, lavaman_shocka7); }
void lavaman_shocka5(entity this) { set_animofs(this, anim_lavaman_shocka1, 5, lavaman_shocka6); }
void lavaman_shocka4(entity this) { set_animofs(this, anim_lavaman_shocka1, 4, lavaman_shocka5); }
void lavaman_shocka3(entity this) { set_animofs(this, anim_lavaman_shocka1, 3, lavaman_shocka4); }
void lavaman_shocka2(entity this) { set_animofs(this, anim_lavaman_shocka1, 2, lavaman_shocka3); }
void lavaman_shocka1(entity this) { set_animofs(this, anim_lavaman_shocka1, 1, lavaman_shocka2); }

void lavaman_pain(entity this, entity attacker, float damage)
{
	if(this.pain_finished > time)
		return;

	if(random() < 0.05)
	{
		this.pain_finished = time + 2;
		lavaman_shocka1(this);
	}
}

void lavaman_death10(entity this)
{
	set_animofs(this, anim_lavaman_death1, 9, lavaman_death10);
	delete(this);
}
void lavaman_death9(entity this)
{
	set_animofs(this, anim_lavaman_death1, 9, lavaman_death10);

	_sound(this, CH_PLAYER, "boss1/out1.wav", 1, ATTN_NORM);
	te_lavasplash(this.origin);
}
void lavaman_death8(entity this) { set_animofs(this, anim_lavaman_death1, 8, lavaman_death9); }
void lavaman_death7(entity this) { set_animofs(this, anim_lavaman_death1, 7, lavaman_death8); }
void lavaman_death6(entity this) { set_animofs(this, anim_lavaman_death1, 6, lavaman_death7); }
void lavaman_death5(entity this) { set_animofs(this, anim_lavaman_death1, 5, lavaman_death6); }
void lavaman_death4(entity this) { set_animofs(this, anim_lavaman_death1, 4, lavaman_death5); }
void lavaman_death3(entity this) { set_animofs(this, anim_lavaman_death1, 3, lavaman_death4); }
void lavaman_death2(entity this) { set_animofs(this, anim_lavaman_death1, 2, lavaman_death3); }
void lavaman_death1(entity this, entity inflictor, entity attacker) { set_animofs(this, anim_lavaman_death1, 1, lavaman_death2); _sound(this, CH_VOICE, "boss1/death.wav", 1, ATTN_NORM); }

void lavaman_touch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;		// don't explode on owner

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}

	float damg = 40;
	if(toucher.health)
	{
		if(toucher.monsterdef && (toucher.monsterdef.spawnflags & MON_FLAG_EXPLOSIONRESISTANT))
			damg = damg * 0.5;	// mostly immune
		T_Damage(toucher, this, this.owner, damg );
	}

	// don't do radius damage to the toucher, because all the damage
	// was done in the impact
	T_RadiusDamage(this, this.owner, 40, toucher);

//	sound (this, CH_WEAPON_SINGLE, SND_ROCKET_EXPLOSION, 1, ATTN_NORM);
	this.origin = this.origin - 8*normalize(this.velocity);

// Change to an explosion2!!! Ramp in the non-diminishing reds...
	te_explosion(this.origin);

	BecomeExplosion(this);
}

void lavaman_missile(entity this, int AttackNumber)
{
	makevectors(this.angles);

	vector org = this.origin + v_forward*40 + v_right*65 + v_up*130;
	// Right handed throw
	if(AttackNumber == 1)
	{
//		org = this.origin - v_forward*40 + v_right*90 + v_up*110;
		org = this.origin + v_forward*40 + v_right*65 + v_up*130;
	}
	// Left handed throw
	else if(AttackNumber == 2)
	{
//		org = this.origin - v_forward*40 - v_right*90 + v_up*110;
		org = this.origin + v_forward*40 - v_right*75 + v_up*125;
	}

	vector d = this.enemy.origin;
	float t = vlen(d - org);
	t = t / 380;
	if(t > 1.75) 
		t = 1.75;
	if(t < 1) 
		t = 1;
	
	vector vec = normalize(d - org);

	entity fireball = new(lavaman_ball);
	fireball.owner = this;
//	set_movetype(fireball, MOVETYPE_FLYMISSILE);
	set_movetype(fireball, MOVETYPE_BOUNCE);
	fireball.solid = SOLID_BBOX;
	fireball.angles = vectoangles(vec);
	settouch(fireball, lavaman_touch);
	_setmodel(fireball, "progs/lavaball.mdl");
	setsize(fireball, '0 0 0', '0 0 0');		
	setorigin(fireball, org);

//	fireball.velocity = vec * 600 + '0 0 200';
	fireball.velocity = vec * 600 * t;
	fireball.velocity_z = fireball.velocity_z +(200 * t);

	fireball.avelocity = '200 100 300';
	setthink(fireball, SUB_Remove);
	fireball.nextthink = time + 6;

	_sound(this, CH_WEAPON_SINGLE, "boss1/throw.wav", 1, ATTN_NORM);
	
// check for dead enemy
	if(this.enemy.health <= 0)
		lavaman_idle1(this);
}

void lavaman_awake(entity this, entity actor, entity trigger)
{
	this.solid = SOLID_SLIDEBOX;
	set_movetype(this, MOVETYPE_STEP);
	this.takedamage = DAMAGE_AIM;
	this.flags |= FL_MONSTER;
	this.ideal_yaw = this.angles * '0 1 0';
	if(!this.yaw_speed)
		this.yaw_speed = 20;
	
	_setmodel(this, "progs/lavaman.mdl");
//	setsize(this, '-64 -64 -12', '64 64 128');
//	setsize(this, '-32 -32 0', '32 32 120');
	setsize(this, '-32 -32 -24', '32 32 64');
	this.view_ofs = '0 0 48';

//    this.health = 1500;

	this.health = 1250 +(250 * autocvar_skill);

	this.th_stand = lavaman_idle1;
	this.th_walk = lavaman_walk1;
	this.th_run = lavaman_walk1;
	this.th_missile = lavaman_fire1;
	this.th_pain = lavaman_pain;
	this.th_die = lavaman_death1;
	this.th_melee = lavaman_fire1;

	te_lavasplash(this.origin);

	if(!(actor.powerups & POWERUP_INVISIBILITY))
	{
		if(!(actor.flags & FL_NOTARGET))
		{
			if(IS_PLAYER(actor))
				this.enemy = actor;
		}
	}
	droptofloor(this);

	lavaman_rise1(this);
}

string lavaman_deathmessage(entity this) { return "fries in Hephaestus' fury"; }


//								  (-64 -64 -12) (64 64 128)
/*QUAKED monster_lava_man (1 0 0) (-32 -32 -24) (32 32 64) Ambush Sleeping
*/
spawnfunc(monster_lava_man)
{
	if(!MP_ROGUE) { delete(this); return; }
	if(deathmatch) { delete(this); return; }
	
	precache_model("progs/lavaman.mdl");
	precache_model("progs/lavaball.mdl");

	precache_sound("weapons/rocket1i.wav");
	precache_sound("boss1/out1.wav");
	precache_sound("boss1/sight1.wav");
	precache_sound("misc/power.wav");
	precache_sound("boss1/throw.wav");
	precache_sound("boss1/pain.wav");
	precache_sound("boss1/death.wav");

	// NOTE: this isn't actually handled as a monster
	// however, it does count towards the total monster count!
	monsters_total += 1;

	// cause the lavaman to rise from the lava when triggered.
	if(this.spawnflags & 2)
	{
		this.use = lavaman_awake;
		return;
	}

	this.deathmessage = lavaman_deathmessage;
	this.monsterdef = MON_LAVAMAN;

	lavaman_awake(this, NULL, NULL);
}
#endif
