#include "dalek.qh"

#ifdef SVQC
const int anim_dalek_stand = 0; //'0 8 0'
const int anim_dalek_die = 9; //'9 12 0'

/*
==============================================================================

DALEK

==============================================================================
*/

void dalek_do_shot(entity this)
{
	this.effects |= EF_MUZZLEFLASH;
	fixedmakevectors(this.angles);

	vector org = this.origin + v_forward * 30 + v_right * (-8.5) + '0 0 16';

	LaunchLaser(this, org, this.enemy.origin - this.origin);
	_sound(this, CH_WEAPON_SINGLE, "enforcer/enfire.wav", 1, ATTN_NORM);
}

void ai_dalek_walk(entity this)
{
	if(this.movetarget.classname != "path_corner")
		ai_walk(this, 3);
	else
		t_movetogoal(this, 3);
}

void dalek_stand1(entity this);
void dalek_stand16(entity this) { set_animofs(this, anim_dalek_stand, 6, dalek_stand1); ai_stand(this); }
void dalek_stand15(entity this) { set_animofs(this, anim_dalek_stand, 7, dalek_stand16); ai_stand(this); }
void dalek_stand14(entity this) { set_animofs(this, anim_dalek_stand, 8, dalek_stand15); ai_stand(this); }
void dalek_stand13(entity this) { set_animofs(this, anim_dalek_stand, 9, dalek_stand14); ai_stand(this); }
void dalek_stand12(entity this) { set_animofs(this, anim_dalek_stand, 8, dalek_stand13); ai_stand(this); }
void dalek_stand11(entity this) { set_animofs(this, anim_dalek_stand, 7, dalek_stand12); ai_stand(this); }
void dalek_stand10(entity this) { set_animofs(this, anim_dalek_stand, 6, dalek_stand11); ai_stand(this); }
void dalek_stand9(entity this) { set_animofs(this, anim_dalek_stand, 1, dalek_stand10); ai_stand(this); }
void dalek_stand8(entity this) { set_animofs(this, anim_dalek_stand, 2, dalek_stand9); ai_stand(this); }
void dalek_stand7(entity this) { set_animofs(this, anim_dalek_stand, 3, dalek_stand8); ai_stand(this); }
void dalek_stand6(entity this) { set_animofs(this, anim_dalek_stand, 4, dalek_stand7); ai_stand(this); }
void dalek_stand5(entity this) { set_animofs(this, anim_dalek_stand, 5, dalek_stand6); ai_stand(this); }
void dalek_stand4(entity this) { set_animofs(this, anim_dalek_stand, 4, dalek_stand5); ai_stand(this); }
void dalek_stand3(entity this) { set_animofs(this, anim_dalek_stand, 3, dalek_stand4); ai_stand(this); }
void dalek_stand2(entity this) { set_animofs(this, anim_dalek_stand, 2, dalek_stand3); ai_stand(this); }
void dalek_stand1(entity this) { set_animofs(this, anim_dalek_stand, 1, dalek_stand2); ai_stand(this); }

void dalek_walk1(entity this);
void dalek_walk16(entity this) { set_animofs(this, anim_dalek_stand, 6, dalek_walk1); ai_dalek_walk(this); }
void dalek_walk15(entity this) { set_animofs(this, anim_dalek_stand, 7, dalek_walk16); ai_dalek_walk(this); }
void dalek_walk14(entity this) { set_animofs(this, anim_dalek_stand, 8, dalek_walk15); ai_dalek_walk(this); }
void dalek_walk13(entity this) { set_animofs(this, anim_dalek_stand, 9, dalek_walk14); ai_dalek_walk(this); }
void dalek_walk12(entity this) { set_animofs(this, anim_dalek_stand, 8, dalek_walk13); ai_dalek_walk(this); }
void dalek_walk11(entity this) { set_animofs(this, anim_dalek_stand, 7, dalek_walk12); ai_dalek_walk(this); }
void dalek_walk10(entity this) { set_animofs(this, anim_dalek_stand, 6, dalek_walk11); ai_dalek_walk(this); }
void dalek_walk9(entity this) { set_animofs(this, anim_dalek_stand, 1, dalek_walk10); ai_dalek_walk(this); }
void dalek_walk8(entity this) { set_animofs(this, anim_dalek_stand, 2, dalek_walk9); ai_dalek_walk(this); }
void dalek_walk7(entity this) { set_animofs(this, anim_dalek_stand, 3, dalek_walk8); ai_dalek_walk(this); }
void dalek_walk6(entity this) { set_animofs(this, anim_dalek_stand, 4, dalek_walk7); ai_dalek_walk(this); }
void dalek_walk5(entity this) { set_animofs(this, anim_dalek_stand, 5, dalek_walk6); ai_dalek_walk(this); }
void dalek_walk4(entity this) { set_animofs(this, anim_dalek_stand, 4, dalek_walk5); ai_dalek_walk(this); }
void dalek_walk3(entity this) { set_animofs(this, anim_dalek_stand, 3, dalek_walk4); ai_dalek_walk(this); }
void dalek_walk2(entity this) { set_animofs(this, anim_dalek_stand, 2, dalek_walk3); ai_dalek_walk(this); }
void dalek_walk1(entity this) { set_animofs(this, anim_dalek_stand, 1, dalek_walk2); ai_dalek_walk(this); }

void dalek_run1(entity this);
void dalek_run16(entity this) { set_animofs(this, anim_dalek_stand, 6, dalek_run1); ai_run(this, 5); }
void dalek_run15(entity this) { set_animofs(this, anim_dalek_stand, 7, dalek_run16); ai_run(this, 5); }
void dalek_run14(entity this) { set_animofs(this, anim_dalek_stand, 8, dalek_run15); ai_run(this, 5); }
void dalek_run13(entity this) { set_animofs(this, anim_dalek_stand, 9, dalek_run14); ai_run(this, 5); }
void dalek_run12(entity this) { set_animofs(this, anim_dalek_stand, 8, dalek_run13); ai_run(this, 5); }
void dalek_run11(entity this) { set_animofs(this, anim_dalek_stand, 7, dalek_run12); ai_run(this, 5); }
void dalek_run10(entity this) { set_animofs(this, anim_dalek_stand, 6, dalek_run11); ai_run(this, 5); }
void dalek_run9(entity this) { set_animofs(this, anim_dalek_stand, 1, dalek_run10); ai_run(this, 5); }
void dalek_run8(entity this) { set_animofs(this, anim_dalek_stand, 2, dalek_run9); ai_run(this, 5); }
void dalek_run7(entity this) { set_animofs(this, anim_dalek_stand, 3, dalek_run8); ai_run(this, 5); }
void dalek_run6(entity this) { set_animofs(this, anim_dalek_stand, 4, dalek_run7); ai_run(this, 5); }
void dalek_run5(entity this) { set_animofs(this, anim_dalek_stand, 5, dalek_run6); ai_run(this, 5); }
void dalek_run4(entity this) { set_animofs(this, anim_dalek_stand, 4, dalek_run5); ai_run(this, 5); }
void dalek_run3(entity this) { set_animofs(this, anim_dalek_stand, 3, dalek_run4); ai_run(this, 5); }
void dalek_run2(entity this) { set_animofs(this, anim_dalek_stand, 2, dalek_run3); ai_run(this, 5); }
void dalek_run1(entity this) { set_animofs(this, anim_dalek_stand, 1, dalek_run2); ai_run(this, 5); }

void dalek_fire3(entity this)
{
	ai_face(this);
	dalek_do_shot(this);
	this.nextthink = time + 0.1;
	setthink(this, dalek_run1);
}

void dalek_fire2(entity this)
{
	ai_face(this);
	dalek_do_shot(this);
	this.nextthink = time + 0.5;
	setthink(this, dalek_fire3);
}

void dalek_fire1(entity this)
{
	ai_face(this);
	dalek_do_shot(this);
	this.nextthink = time + 0.5;
	setthink(this, dalek_fire2);
}

void dalek_fire(entity this)
{
	_sound(this, CH_VOICE, "dalek/dalek.wav", 1, ATTN_NORM);
	this.frame = 1;
	ai_face(this);
	this.nextthink = time + 0.5;
	setthink(this, dalek_fire1);
}

void dalek_die5(entity this) { set_animofs(this, anim_dalek_die, 4, dalek_die5); CorpseThink(this); }
void dalek_die4(entity this) { set_animofs(this, anim_dalek_die, 4, dalek_die5); ai_back(this, 9); }
void dalek_die3(entity this) { set_animofs(this, anim_dalek_die, 3, dalek_die4); ai_back(this, 14); }
void dalek_die2(entity this) { set_animofs(this, anim_dalek_die, 2, dalek_die3); ai_back(this, 16); }
void dalek_die1(entity this) { set_animofs(this, anim_dalek_die, 1, dalek_die2); ai_back(this, 14); this.solid = SOLID_NOT; }

void dalek_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	if(random() < 0.5)
	{
		_sound(this, CH_VOICE, "dalek/daldie.wav", 1, ATTN_NORM);
		dalek_die1(this);
	}
	else
	{
		entity boom = spawn();
		setorigin(boom, this.origin + '0 0 30');

		set_movetype(boom, MOVETYPE_NONE);
		boom.velocity = '0 0 0';
		settouch(boom, func_null);
		_setmodel(boom, "progs/s_explod.spr");
		boom.solid = SOLID_NOT;
		boom.nextthink = time + 0.1;
		setthink(boom, s_explode1);

		te_explosion(this.origin);

		_sound(this, CH_VOICE, "weapons/r_exp3.wav", 1, ATTN_NORM);

		ThrowGib(this, inflictor, "progs/daltop.mdl", -50);
		ThrowGib(this, inflictor, "progs/dalmid.mdl", -48);

		_setmodel(this, "progs/dalskrt.mdl");

		this.frame = 0;
		this.nextthink = -1;
		set_movetype(this, MOVETYPE_NONE);
		this.takedamage = DAMAGE_NO;
		this.solid = SOLID_NOT;
		this.view_ofs = '0 0 8';
		setsize(this, '-16 -16 -24', '16 16 20');
		this.velocity = '0 0 0';
		UNSET_ONGROUND(this);

		CorpseThink(this);
	}
}

/*QUAKED monster_dalek(1 0 0)(-16 -16 -24)(16 16 40) Ambush
*/
spawnfunc(monster_dalek) { monster_start(this, true, MON_DALEK); }
#endif // SVQC

#ifdef SVQC
METHOD(Dalek, mr_setup, bool(Dalek this, entity actor))
{
    TC(Dalek, this);

	precache_model("progs/daltop.mdl");
	precache_model("progs/dalmid.mdl");
	precache_model("progs/dalskrt.mdl");

	precache_sound("dalek/daldie.wav");

	precache_model("progs/laser.mdl");
	precache_sound("enforcer/enfire.wav");

    actor.health = 200;
    actor.th_stand = dalek_stand1;
	actor.th_walk = dalek_walk1;
	actor.th_run = dalek_run1;
	actor.th_missile = dalek_fire;
	actor.th_die = dalek_die;

    return true;
}
#endif
