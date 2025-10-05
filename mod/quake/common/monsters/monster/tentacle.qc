#include "tentacle.qh"

#ifdef SVQC
const int anim_tentacle_idle = 0; //'0 5 0'
const int anim_tentacle_attack = 6; //'6 26 0'
const int anim_tentacle_death = 27; //'27 43 0'

void tentacle_stand1(entity this);
void tentacle_stand6(entity this) { set_animofs(this, anim_tentacle_idle, 6, tentacle_stand1); ai_stand(this); }
void tentacle_stand5(entity this) { set_animofs(this, anim_tentacle_idle, 5, tentacle_stand6); ai_stand(this); }
void tentacle_stand4(entity this) { set_animofs(this, anim_tentacle_idle, 4, tentacle_stand5); ai_stand(this); }
void tentacle_stand3(entity this) { set_animofs(this, anim_tentacle_idle, 3, tentacle_stand4); ai_stand(this); }
void tentacle_stand2(entity this) { set_animofs(this, anim_tentacle_idle, 2, tentacle_stand3); ai_stand(this); }
void tentacle_stand1(entity this) { set_animofs(this, anim_tentacle_idle, 1, tentacle_stand2); ai_stand(this); }

void tentacle_atta1(entity this);
void tentacle_aim1(entity this);
void tentacle_aim6(entity this) { set_animofs(this, anim_tentacle_idle, 6, tentacle_aim1); }
void tentacle_aim5(entity this) { set_animofs(this, anim_tentacle_idle, 5, tentacle_aim6); }
void tentacle_aim4(entity this) { set_animofs(this, anim_tentacle_idle, 4, tentacle_aim5); }
void tentacle_aim3(entity this) { set_animofs(this, anim_tentacle_idle, 3, tentacle_aim4); }
void tentacle_aim2(entity this) { set_animofs(this, anim_tentacle_idle, 2, tentacle_aim3); }
void tentacle_aim1(entity this)
{
	set_animofs(this, anim_tentacle_idle, 1, tentacle_aim2);
	if(!this.enemy || this.enemy.health < 1 || (this.enemy.flags & FL_NOTARGET))
	{
		setthink(this, tentacle_stand1);
		return;
	}

	if(random() < 0.4)
		tentacle_atta1(this);
}

//----------------------------------------------------------------------------
void gug_screen_shake(entity this, float stime, entity eshake);
void groundSmash(entity this)
{
	FOREACH_ENTITY_RADIUS(this.origin, 550, IS_PLAYER(it) && IS_ONGROUND(it),
	{
		gug_screen_shake(this, 0.3, it);
	});
	
	_sound(this, CH_WEAPON_SINGLE, "shambler/fall.wav", 1, ATTN_NORM);
	
	T_RadiusDamage(this, this.owner, 50, DEATH_MONSTER_TENTACLE.m_id, this.owner);
	setthink(this, SUB_Remove);
	this.nextthink = time;
	settouch(this, func_null);
}

void groundSmash_touch(entity this, entity toucher)
{
	groundSmash(this);
}

void tentacle_attack(entity this, vector org, vector vec)
{
	vector dir = normalize(vec);

	entity newmis = spawn();
	newmis.classname = "tentacle_groundsmash";
	newmis.owner = this;
	newmis.realowner = this;
	set_movetype(newmis, MOVETYPE_FLY);
	newmis.solid = SOLID_BBOX;

	setorigin(newmis, org);

	newmis.velocity = dir * 3600;
	newmis.angles = vectoangles(newmis.velocity);

	newmis.velocity_z = 0;

	newmis.nextthink = time + 0.05;
	setthink(newmis, groundSmash);
	settouch(newmis, groundSmash_touch);
}

void tentacle_atta21(entity this) { set_animofs(this, anim_tentacle_attack, 21, tentacle_aim1); ai_face(this); }
void tentacle_atta20(entity this) { set_animofs(this, anim_tentacle_attack, 20, tentacle_atta21); ai_face(this); this.solid = SOLID_BBOX; }
void tentacle_atta19(entity this) { set_animofs(this, anim_tentacle_attack, 19, tentacle_atta20); ai_face(this); }
void tentacle_atta18(entity this) { set_animofs(this, anim_tentacle_attack, 18, tentacle_atta19); ai_face(this); }
void tentacle_atta17(entity this) { set_animofs(this, anim_tentacle_attack, 17, tentacle_atta18); }
void tentacle_atta16(entity this)
{
	set_animofs(this, anim_tentacle_attack, 16, tentacle_atta17);
	tentacle_attack(this, this.origin, this.enemy.origin - this.origin);
}
void tentacle_atta15(entity this) { set_animofs(this, anim_tentacle_attack, 15, tentacle_atta16); this.solid = SOLID_NOT; }
void tentacle_atta14(entity this) { set_animofs(this, anim_tentacle_attack, 14, tentacle_atta15); ai_face(this); }
void tentacle_atta13(entity this) { set_animofs(this, anim_tentacle_attack, 13, tentacle_atta14); ai_face(this); }
void tentacle_atta12(entity this) { set_animofs(this, anim_tentacle_attack, 12, tentacle_atta13); ai_face(this); }
void tentacle_atta11(entity this) { set_animofs(this, anim_tentacle_attack, 11, tentacle_atta12); ai_face(this); }
void tentacle_atta10(entity this) { set_animofs(this, anim_tentacle_attack, 10, tentacle_atta11); ai_face(this); }
void tentacle_atta9(entity this) { set_animofs(this, anim_tentacle_attack, 9, tentacle_atta10); ai_face(this); }
void tentacle_atta8(entity this) { set_animofs(this, anim_tentacle_attack, 8, tentacle_atta9); ai_face(this); }
void tentacle_atta7(entity this) { set_animofs(this, anim_tentacle_attack, 7, tentacle_atta8); ai_face(this); }
void tentacle_atta6(entity this) { set_animofs(this, anim_tentacle_attack, 6, tentacle_atta7); ai_face(this); }
void tentacle_atta5(entity this) { set_animofs(this, anim_tentacle_attack, 5, tentacle_atta6); ai_face(this); }
void tentacle_atta4(entity this) { set_animofs(this, anim_tentacle_attack, 4, tentacle_atta5); ai_face(this); }
void tentacle_atta3(entity this) { set_animofs(this, anim_tentacle_attack, 3, tentacle_atta4); ai_face(this); }
void tentacle_atta2(entity this) { set_animofs(this, anim_tentacle_attack, 2, tentacle_atta3); ai_face(this); }
void tentacle_atta1(entity this) { set_animofs(this, anim_tentacle_attack, 1, tentacle_atta2); ai_face(this); }

void tentacle_die17(entity this) { set_animofs(this, anim_tentacle_death, 17, tentacle_die17); CorpseThink(this); }
void tentacle_die16(entity this) { set_animofs(this, anim_tentacle_death, 16, tentacle_die17); }
void tentacle_die15(entity this) { set_animofs(this, anim_tentacle_death, 15, tentacle_die16); }
void tentacle_die14(entity this) { set_animofs(this, anim_tentacle_death, 14, tentacle_die15); }
void tentacle_die13(entity this) { set_animofs(this, anim_tentacle_death, 13, tentacle_die14); }
void tentacle_die12(entity this) { set_animofs(this, anim_tentacle_death, 12, tentacle_die13); }
void tentacle_die11(entity this) { set_animofs(this, anim_tentacle_death, 11, tentacle_die12); }
void tentacle_die10(entity this) { set_animofs(this, anim_tentacle_death, 10, tentacle_die11); }
void tentacle_die9(entity this) { set_animofs(this, anim_tentacle_death, 9, tentacle_die10); }
void tentacle_die8(entity this) { set_animofs(this, anim_tentacle_death, 8, tentacle_die9); }
void tentacle_die7(entity this) { set_animofs(this, anim_tentacle_death, 7, tentacle_die8); }
void tentacle_die6(entity this) { set_animofs(this, anim_tentacle_death, 6, tentacle_die7); }
void tentacle_die5(entity this) { set_animofs(this, anim_tentacle_death, 5, tentacle_die6); }
void tentacle_die4(entity this) { set_animofs(this, anim_tentacle_death, 4, tentacle_die5); }
void tentacle_die3(entity this) { set_animofs(this, anim_tentacle_death, 3, tentacle_die4); }
void tentacle_die2(entity this) { set_animofs(this, anim_tentacle_death, 2, tentacle_die3); }
void tentacle_die1(entity this) { set_animofs(this, anim_tentacle_death, 1, tentacle_die2); }

//----------------------------------------------------------------------
void tentacle_pain(entity this, entity attacker, float damage, int deathtype)
{
	_sound(this, CH_VOICE, "boss1/pain.wav", 1, ATTN_NORM);
}

void tentacle_die(entity this, entity inflictor, entity attacker, int deathtype)
{
// check for gib
	if(this.health < -135)
	{
		_sound(this, CH_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowGib(this, inflictor, "progs/gib3.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib3.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib3.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib3.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib3.mdl", this.health);
		delete(this);
		return;
	}

// regular death
	_sound(this, CH_VOICE, "boss1/death.wav", 1, ATTN_NORM);
	this.solid = SOLID_NOT;

	tentacle_die1(this);
}

void tentacle_riseshake(entity this)
{
	FOREACH_ENTITY_RADIUS(this.origin, 550, IS_PLAYER(it) && IS_ONGROUND(it),
	{
		gug_screen_shake(this, 0.2, it);
	});
}

void tentacle_rise6(entity this) { set_animofs(this, anim_tentacle_death, 12, tentacle_aim1); if(!this.enemy) setthink(this, tentacle_stand1); }
void tentacle_rise5(entity this) { set_animofs(this, anim_tentacle_death, 13, tentacle_rise6); }
void tentacle_rise4(entity this) { set_animofs(this, anim_tentacle_death, 14, tentacle_rise5); }
void tentacle_rise3(entity this) { set_animofs(this, anim_tentacle_death, 15, tentacle_rise4); }
void tentacle_rise2(entity this) { set_animofs(this, anim_tentacle_death, 16, tentacle_rise3); tentacle_riseshake(this); }
void tentacle_rise1(entity this) { set_animofs(this, anim_tentacle_death, 17, tentacle_rise2); this.solid = SOLID_BBOX; }

void tentacle_rise(entity this, entity actor, entity trigger)
{
	this.enemy = actor;
	tentacle_rise1(this);
	this.use = func_null;
}

/*======================================================================
QUAKED monster_tentacle (1 0.2 0) (-16 -16 -24) (16 16 24)
======================================================================*/
spawnfunc(monster_tentacle) { monster_start(this, true, MON_TENTACLE); }
#endif // SVQC

#ifdef SVQC
METHOD(Tentacle, mr_setup, bool(Tentacle this, entity actor))
{
	TC(Tentacle, this);

	precache_sound("player/udeath.wav");
	precache_sound("boss1/pain.wav");
	precache_sound("boss1/death.wav");
	precache_sound("shambler/fall.wav");

	set_movetype(actor, MOVETYPE_NONE);

	actor.health = 135;
	actor.scale = 0.5;

	actor.th_run = tentacle_aim1;
	actor.th_pain = tentacle_pain;
	actor.th_die = tentacle_die;
	actor.th_melee = tentacle_atta1;
	actor.th_stand = tentacle_stand1;

	if(actor.targetname && actor.targetname != "")
	{
		actor.solid = SOLID_NOT;
		actor.frame = anim_tentacle_death + 16; //$death17
		actor.use = tentacle_rise;
	}
	else
		tentacle_rise(actor, actor.enemy, NULL);

	return true;
}
#endif
