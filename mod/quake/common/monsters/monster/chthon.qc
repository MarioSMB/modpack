#include "chthon.qh"

#include "../../../server/triggers/triggers.qh"
#include "../../../server/triggers/func/door.qh"

#ifdef SVQC
const int anim_boss_rise = 0; //'0 16 0'
const int anim_boss_walk = 17; //'17 47 0'
const int anim_boss_death = 48; //'48 56 0'
const int anim_boss_attack = 57; //'57 79 0'
const int anim_boss_shocka = 80; //'80 89 0'
const int anim_boss_shockb = 90; //'90 95 0'
const int anim_boss_shockc = 96; //'96 105 0'

const int BOSS_KILLABLE = 2;

void boss_pain(entity targ, entity attacker, float damage); // Yoder add, September 9 2020
void SUB_Freeze(entity this); // Yoder add, Dec 16 2020
void SUB_Unfreeze(entity this);
void SUB_Unfreeze_use(entity this, entity actor, entity trigger); // Yoder add, Dec 16 2020
void boss_missile1(entity this); // yoder add, Jan 20 2020

void boss_face(entity this)
{
	// go for another player if multi player
	if(this.enemy.health <= 0 || (coop && random() < 0.02))
		this.enemy = NULL;

	if(!this.enemy)
	{
		RandomSelection_Init();
		FOREACH_CLIENT(IS_PLAYER(it) && this.enemy != it && it.health > 0,
		{
			RandomSelection_AddEnt(it, 1, 1);
		});
		this.enemy = RandomSelection_chosen_ent;

		setthink(this, boss_missile1); // return to attack state
	}

	if(this.enemy && this.enemy.health > 0) // yoder add Jan 20 2020 to stop Chthon from twitching each idle step.
		ai_face(this);
}

void boss_rise17(entity this) { set_animofs(this, anim_boss_rise, 17, boss_missile1); }
void boss_rise16(entity this) { set_animofs(this, anim_boss_rise, 16, boss_rise17); }
void boss_rise15(entity this) { set_animofs(this, anim_boss_rise, 15, boss_rise16); }
void boss_rise14(entity this) { set_animofs(this, anim_boss_rise, 14, boss_rise15); }
void boss_rise13(entity this) { set_animofs(this, anim_boss_rise, 13, boss_rise14); }
void boss_rise12(entity this) { set_animofs(this, anim_boss_rise, 12, boss_rise13); }
void boss_rise11(entity this) { set_animofs(this, anim_boss_rise, 11, boss_rise12); }
void boss_rise10(entity this) { set_animofs(this, anim_boss_rise, 10, boss_rise11); }
void boss_rise9(entity this) { set_animofs(this, anim_boss_rise, 9, boss_rise10); }
void boss_rise8(entity this) { set_animofs(this, anim_boss_rise, 8, boss_rise9); }
void boss_rise7(entity this) { set_animofs(this, anim_boss_rise, 7, boss_rise8); }
void boss_rise6(entity this) { set_animofs(this, anim_boss_rise, 6, boss_rise7); }
void boss_rise5(entity this) { set_animofs(this, anim_boss_rise, 5, boss_rise6); }
void boss_rise4(entity this) { set_animofs(this, anim_boss_rise, 4, boss_rise5); }
void boss_rise3(entity this) { set_animofs(this, anim_boss_rise, 3, boss_rise4); }
void boss_rise2(entity this)
{
	set_animofs(this, anim_boss_rise, 2, boss_rise3);
	_sound(this, CH_VOICE, "boss1/sight1.wav", 1, ATTN_NORM);
}
void boss_rise1(entity this)
{
	set_animofs(this, anim_boss_rise, 1, boss_rise2);
	_sound(this, CH_SHOTS, "boss1/out1.wav", 1, ATTN_NORM);
}

void boss_idle1(entity this);
void boss_idle31(entity this)
{
	set_animofs(this, anim_boss_walk, 31, boss_idle1);
	boss_face(this);
	// [QuakeEX] If boss_face found a new target, start throwing stuff at them.
	if(this.enemy && this.enemy.health > 0)
		boss_missile1(this);
	else
		boss_idle1(this);
}
void boss_idle30(entity this) { set_animofs(this, anim_boss_walk, 30, boss_idle31); boss_face(this); }
void boss_idle29(entity this) { set_animofs(this, anim_boss_walk, 29, boss_idle30); boss_face(this); }
void boss_idle28(entity this) { set_animofs(this, anim_boss_walk, 28, boss_idle29); boss_face(this); }
void boss_idle27(entity this) { set_animofs(this, anim_boss_walk, 27, boss_idle28); boss_face(this); }
void boss_idle26(entity this) { set_animofs(this, anim_boss_walk, 26, boss_idle27); boss_face(this); }
void boss_idle25(entity this) { set_animofs(this, anim_boss_walk, 25, boss_idle26); boss_face(this); }
void boss_idle24(entity this) { set_animofs(this, anim_boss_walk, 24, boss_idle25); boss_face(this); }
void boss_idle23(entity this) { set_animofs(this, anim_boss_walk, 23, boss_idle24); boss_face(this); }
void boss_idle22(entity this) { set_animofs(this, anim_boss_walk, 22, boss_idle23); boss_face(this); }
void boss_idle21(entity this) { set_animofs(this, anim_boss_walk, 21, boss_idle22); boss_face(this); }
void boss_idle20(entity this) { set_animofs(this, anim_boss_walk, 20, boss_idle21); boss_face(this); }
void boss_idle19(entity this) { set_animofs(this, anim_boss_walk, 19, boss_idle20); boss_face(this); }
void boss_idle18(entity this) { set_animofs(this, anim_boss_walk, 18, boss_idle19); boss_face(this); }
void boss_idle17(entity this) { set_animofs(this, anim_boss_walk, 17, boss_idle18); boss_face(this); }
void boss_idle16(entity this) { set_animofs(this, anim_boss_walk, 16, boss_idle17); boss_face(this); }
void boss_idle15(entity this) { set_animofs(this, anim_boss_walk, 15, boss_idle16); boss_face(this); }
void boss_idle14(entity this) { set_animofs(this, anim_boss_walk, 14, boss_idle15); boss_face(this); }
void boss_idle13(entity this) { set_animofs(this, anim_boss_walk, 13, boss_idle14); boss_face(this); }
void boss_idle12(entity this) { set_animofs(this, anim_boss_walk, 12, boss_idle13); boss_face(this); }
void boss_idle11(entity this) { set_animofs(this, anim_boss_walk, 11, boss_idle12); boss_face(this); }
void boss_idle10(entity this) { set_animofs(this, anim_boss_walk, 10, boss_idle11); boss_face(this); }
void boss_idle9(entity this) { set_animofs(this, anim_boss_walk, 9, boss_idle10); boss_face(this); }
void boss_idle8(entity this) { set_animofs(this, anim_boss_walk, 8, boss_idle9); boss_face(this); }
void boss_idle7(entity this) { set_animofs(this, anim_boss_walk, 7, boss_idle8); boss_face(this); }
void boss_idle6(entity this) { set_animofs(this, anim_boss_walk, 6, boss_idle7); boss_face(this); }
void boss_idle5(entity this) { set_animofs(this, anim_boss_walk, 5, boss_idle6); boss_face(this); }
void boss_idle4(entity this) { set_animofs(this, anim_boss_walk, 4, boss_idle5); boss_face(this); }
void boss_idle3(entity this) { set_animofs(this, anim_boss_walk, 3, boss_idle4); boss_face(this); }
void boss_idle2(entity this) { set_animofs(this, anim_boss_walk, 2, boss_idle3); boss_face(this); }
void boss_idle1(entity this) { set_animofs(this, anim_boss_walk, 1, boss_idle2); boss_face(this); }

void boss_missile23(entity this) { set_animofs(this, anim_boss_attack, 23, boss_missile1); boss_face(this); }
void boss_missile22(entity this) { set_animofs(this, anim_boss_attack, 22, boss_missile23); boss_face(this); }
void boss_missile21(entity this) { set_animofs(this, anim_boss_attack, 21, boss_missile22); boss_face(this); }
void boss_missile20(entity this) { set_animofs(this, anim_boss_attack, 20, boss_missile21); boss_missile(this, '100 -100 200'); }
void boss_missile19(entity this) { set_animofs(this, anim_boss_attack, 19, boss_missile20); boss_face(this); }
void boss_missile18(entity this) { set_animofs(this, anim_boss_attack, 18, boss_missile19); boss_face(this); }
void boss_missile17(entity this) { set_animofs(this, anim_boss_attack, 17, boss_missile18); boss_face(this); }
void boss_missile16(entity this) { set_animofs(this, anim_boss_attack, 16, boss_missile17); boss_face(this); }
void boss_missile15(entity this) { set_animofs(this, anim_boss_attack, 15, boss_missile16); boss_face(this); }
void boss_missile14(entity this) { set_animofs(this, anim_boss_attack, 14, boss_missile15); boss_face(this); }
void boss_missile13(entity this) { set_animofs(this, anim_boss_attack, 13, boss_missile14); boss_face(this); }
void boss_missile12(entity this) { set_animofs(this, anim_boss_attack, 12, boss_missile13); boss_face(this); }
void boss_missile11(entity this) { set_animofs(this, anim_boss_attack, 11, boss_missile12); boss_face(this); }
void boss_missile10(entity this) { set_animofs(this, anim_boss_attack, 10, boss_missile11); boss_face(this); }
void boss_missile9(entity this) { set_animofs(this, anim_boss_attack, 9, boss_missile10); boss_missile(this, '100 100 200'); }
void boss_missile8(entity this) { set_animofs(this, anim_boss_attack, 8, boss_missile9); boss_face(this); }
void boss_missile7(entity this) { set_animofs(this, anim_boss_attack, 7, boss_missile8); boss_face(this); }
void boss_missile6(entity this) { set_animofs(this, anim_boss_attack, 6, boss_missile7); boss_face(this); }
void boss_missile5(entity this) { set_animofs(this, anim_boss_attack, 5, boss_missile6); boss_face(this); }
void boss_missile4(entity this) { set_animofs(this, anim_boss_attack, 4, boss_missile5); boss_face(this); }
void boss_missile3(entity this) { set_animofs(this, anim_boss_attack, 3, boss_missile4); boss_face(this); }
void boss_missile2(entity this) { set_animofs(this, anim_boss_attack, 2, boss_missile3); boss_face(this); }
void boss_missile1(entity this) { set_animofs(this, anim_boss_attack, 1, boss_missile2); boss_face(this); }

// Yoder add, Jan 05 2021
// this is a version of shock a but without doing the Freeze
void boss_shockz10(entity this) { set_animofs(this, anim_boss_shocka, 10, boss_missile1); }
void boss_shockz9(entity this) { set_animofs(this, anim_boss_shocka, 9, boss_shockz10); }
void boss_shockz8(entity this) { set_animofs(this, anim_boss_shocka, 8, boss_shockz9); }
void boss_shockz7(entity this) { set_animofs(this, anim_boss_shocka, 7, boss_shockz8); }
void boss_shockz6(entity this) { set_animofs(this, anim_boss_shocka, 6, boss_shockz7); }
void boss_shockz5(entity this) { set_animofs(this, anim_boss_shocka, 5, boss_shockz6); }
void boss_shockz4(entity this) { set_animofs(this, anim_boss_shocka, 4, boss_shockz5); }
void boss_shockz3(entity this) { set_animofs(this, anim_boss_shocka, 3, boss_shockz4); }
void boss_shockz2(entity this) { set_animofs(this, anim_boss_shocka, 2, boss_shockz3); }
void boss_shockz1(entity this) { set_animofs(this, anim_boss_shocka, 1, boss_shockz2); }

void boss_shocka10(entity this)
{
	set_animofs(this, anim_boss_shocka, 10, boss_missile1);
	if(MP_MG && (this.spawnflags & BOSS_KILLABLE))
	{
		SUB_Freeze(this);
		this.use = SUB_Unfreeze_use;
	}
}
void boss_shocka9(entity this) { set_animofs(this, anim_boss_shocka, 9, boss_shocka10); }
void boss_shocka8(entity this) { set_animofs(this, anim_boss_shocka, 8, boss_shocka9); }
void boss_shocka7(entity this) { set_animofs(this, anim_boss_shocka, 7, boss_shocka8); }
void boss_shocka6(entity this) { set_animofs(this, anim_boss_shocka, 6, boss_shocka7); }
void boss_shocka5(entity this) { set_animofs(this, anim_boss_shocka, 5, boss_shocka6); }
void boss_shocka4(entity this) { set_animofs(this, anim_boss_shocka, 4, boss_shocka5); }
void boss_shocka3(entity this) { set_animofs(this, anim_boss_shocka, 3, boss_shocka4); }
void boss_shocka2(entity this) { set_animofs(this, anim_boss_shocka, 2, boss_shocka3); }
void boss_shocka1(entity this) { set_animofs(this, anim_boss_shocka, 1, boss_shocka2); }

void boss_shockb10(entity this)
{
	set_animofs(this, anim_boss_shockb, 4, boss_missile1);
	if(MP_MG && (this.spawnflags & BOSS_KILLABLE))
	{
		SUB_Freeze(this);
		this.use = SUB_Unfreeze_use;
	}
}
void boss_shockb9(entity this) { set_animofs(this, anim_boss_shockb, 3, boss_shockb10); }
void boss_shockb8(entity this) { set_animofs(this, anim_boss_shockb, 2, boss_shockb9); }
void boss_shockb7(entity this) { set_animofs(this, anim_boss_shockb, 1, boss_shockb8); }
void boss_shockb6(entity this) { set_animofs(this, anim_boss_shockb, 6, boss_shockb7); }
void boss_shockb5(entity this) { set_animofs(this, anim_boss_shockb, 5, boss_shockb6); }
void boss_shockb4(entity this) { set_animofs(this, anim_boss_shockb, 4, boss_shockb5); }
void boss_shockb3(entity this) { set_animofs(this, anim_boss_shockb, 3, boss_shockb4); }
void boss_shockb2(entity this) { set_animofs(this, anim_boss_shockb, 2, boss_shockb3); }
void boss_shockb1(entity this) { set_animofs(this, anim_boss_shockb, 1, boss_shockb2); }

void boss_death1(entity this);

void boss_shockc10(entity this) { set_animofs(this, anim_boss_shockc, 10, boss_death1); }
void boss_shockc9(entity this) { set_animofs(this, anim_boss_shockc, 9, boss_shockc10); }
void boss_shockc8(entity this) { set_animofs(this, anim_boss_shockc, 8, boss_shockc9); }
void boss_shockc7(entity this) { set_animofs(this, anim_boss_shockc, 7, boss_shockc8); }
void boss_shockc6(entity this) { set_animofs(this, anim_boss_shockc, 6, boss_shockc7); }
void boss_shockc5(entity this) { set_animofs(this, anim_boss_shockc, 5, boss_shockc6); }
void boss_shockc4(entity this) { set_animofs(this, anim_boss_shockc, 4, boss_shockc5); }
void boss_shockc3(entity this) { set_animofs(this, anim_boss_shockc, 3, boss_shockc4); }
void boss_shockc2(entity this) { set_animofs(this, anim_boss_shockc, 2, boss_shockc3); }
void boss_shockc1(entity this) { set_animofs(this, anim_boss_shockc, 1, boss_shockc2); }

void boss_death10(entity this)
{
	// being removed, don't need new frame
	//set_animofs(this, anim_boss_death, 9, boss_death10);
	monsters_killed += 1;
	SUB_UseTargets(this, this.enemy, NULL);
	delete(this);
}
void boss_death9(entity this)
{
	set_animofs(this, anim_boss_death, 9, boss_death10);
	_sound(this, CH_PAIN, "boss1/out1.wav", 1, ATTN_NORM);

	te_lavasplash(this.origin);
}
void boss_death8(entity this) { set_animofs(this, anim_boss_death, 8, boss_death9); }
void boss_death7(entity this) { set_animofs(this, anim_boss_death, 7, boss_death8); }
void boss_death6(entity this) { set_animofs(this, anim_boss_death, 6, boss_death7); }
void boss_death5(entity this) { set_animofs(this, anim_boss_death, 5, boss_death6); }
void boss_death4(entity this) { set_animofs(this, anim_boss_death, 4, boss_death5); }
void boss_death3(entity this) { set_animofs(this, anim_boss_death, 3, boss_death4); }
void boss_death2(entity this) { set_animofs(this, anim_boss_death, 2, boss_death3); }
void boss_death1(entity this)
{
	set_animofs(this, anim_boss_death, 1, boss_death2);
	_sound(this, CH_VOICE, "boss1/death.wav", 1, ATTN_NORM);
}

void boss_die(entity this, entity inflictor, entity attacker)
{
	boss_death1(this);
}

void boss_missile(entity this, vector p)
{
	vector vec, d;

	vector offang = vectoangles(this.enemy.origin - this.origin);	
	makevectors(offang);

	vector org = this.origin + p_x*v_forward + p_y*v_right + p_z*'0 0 1';
	
// lead the player on hard mode
	if(autocvar_skill > 1)
	{
		float t = vlen(this.enemy.origin - org) / 300;
		vec = this.enemy.velocity;
		vec_z = 0;
		d = this.enemy.origin + t * vec;		
	}
	else
	{
		d = this.enemy.origin;
	}
	
	vec = normalize(d - org);

	entity newmis = launch_spike(this, org, vec);
	newmis.classname = "chthon_lavaball";
	_setmodel(newmis, "progs/lavaball.mdl");
	newmis.owner = this;
	newmis.avelocity = '200 100 300';
	setsize(newmis, '0 0 0', '0 0 0');		
	newmis.velocity = vec*300;
	settouch(newmis, T_MissileTouch); // rocket explosion
	_sound(this, CH_SHOTS, "boss1/throw.wav", 1, ATTN_NORM);

// check for dead enemy
	if(this.enemy.health <= 0)
		boss_idle1(this);
}

void boss_awake(entity this, entity actor, entity trigger)
{
	this.solid = SOLID_SLIDEBOX;
	set_movetype(this, MOVETYPE_STEP);
	this.takedamage = DAMAGE_NO;
	
	_setmodel(this, "progs/boss.mdl");
	setsize(this, '-128 -128 -24', '128 128 256');
	
	if(autocvar_skill == 0)
		this.health = 1;
	else
		this.health = 3;

	this.max_health = this.health;
	this.enemy = actor;

	// Yoder add, June 14, 2020
	// Checking a spawnflag to see if chthon is killable
	if(MP_MG && (this.spawnflags & BOSS_KILLABLE))
	{
		this.takedamage = DAMAGE_AIM;
		this.th_die = boss_die;
		this.health = 4000;
		this.max_health = this.health;
		this.use = monster_use; // prevent from being re-triggered into boss_awake state
		this.th_pain = boss_pain; // Yoder add, September 9 2020
	}
	// end of Yoder add

	te_lavasplash(this.origin);

	this.yaw_speed = 20;
	boss_rise1(this);
}

string boss_deathmessage(entity this) { return "becomes one with Chthon"; }

/*QUAKED monster_boss(1 0 0)(-128 -128 -24)(128 128 256)
*/
spawnfunc(monster_boss)
{
	if(deathmatch) { delete(this); return; }

	precache_model("progs/boss.mdl");
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

	this.deathmessage = boss_deathmessage;

	this.use = boss_awake;
	this.monsterdef = MON_CHTHON; // for monster lookups
}

//===========================================================================

entity le1, le2;
float lightning_end;

void lightning_fire(entity this)
{
	if(time >= lightning_end)
	{	// done here, put the terminals back up
		door_go_down(le1);
		door_go_down(le2);
		return;
	}
	
	vector p1 =(le1.mins + le1.maxs) * 0.5;
	p1.z = le1.absmin_z - 16;
	
	vector p2 =(le2.mins + le2.maxs) * 0.5;
	p2.z = le2.absmin_z - 16;
	
	// compensate for length of bolt
	p2 = p2 - normalize(p2-p1)*100;

	this.nextthink = time + 0.1;
	setthink(this, lightning_fire);

	// was MSG_ALL (TODO?)
	//te_lightning3(NULL, p1, p2);
	SendCSQCLightningBeam(p1, p2);
}

void lightning_use(entity this, entity actor, entity trigger)
{
	if(lightning_end >= time + 1)
		return;

	le1 = find(NULL, target, "lightning");
	le2 = find(le1, target, "lightning");
	if(!le1 || !le2)
	{
		dprint("missing lightning targets\n");
		return;
	}
	
	if(
	(le1.state != STATE_TOP && le1.state != STATE_BOTTOM)
	||(le2.state != STATE_TOP && le2.state != STATE_BOTTOM)
	||(le1.state != le2.state) )
	{
//		dprint("not aligned\n");
		return;
	}

// don't let the electrodes go back up until the bolt is done
	le1.nextthink = -1;
	le2.nextthink = -1;
	if(MP_MG)
		lightning_end = time + 2;
	else
		lightning_end = time + 1;

	_sound(this, CH_VOICE, "misc/power.wav", 1, ATTN_NORM);
	lightning_fire(this);		

// advance the boss pain if down
	entity e = findentity(NULL, monsterdef, MON_CHTHON);
	if(!e)
		return;
	e.enemy = actor;
	if(le1.state == STATE_TOP && e.health > 0)
	{
		_sound(e, CH_VOICE, "boss1/pain.wav", 1, ATTN_NORM);
		e.health = e.health - 1;
		if(e.health >= 2)
			boss_shocka1(e);
		else if(e.health == 1)
			boss_shockb1(e);
		else if(e.health == 0)
			boss_shockc1(e);
	}	
}


/*QUAKED event_lightning(0 1 1)(-16 -16 -16)(16 16 16)
Just for boss level.
*/
spawnfunc(event_lightning)
{
	this.use = lightning_use;
}

/* boss_pain
Play the pain animations when health drops below a certain percent

Yoder add, September 9, 2020
*/
void boss_pain(entity this, entity attacker, float damage)
{
	if(!(this.spawnflags & BOSS_KILLABLE))
		return;
	
	float priorhealth = this.health + damage;
	LOG_DEBUGF("prior health: %d\ncurrent health: %d", priorhealth, this.health);
	
	// check if first hit
	if(priorhealth == this.max_health && this.health < this.max_health)
	{
		LOG_DEBUG("FIRST HIT!");
		boss_shockz1(this);
		SUB_UseTargets(this, NULL, NULL);
	}
	// check if crossed 1/3 threshold
	if((this.health < (this.max_health/3)) && (priorhealth > (this.max_health/3)))
	{
		LOG_DEBUG("CROSSED 1/3 MARK!");
		boss_shockb1(this);
		SUB_UseTargets(this, NULL, NULL); // Yoder add, Dec 16 2020
		return;
	}
	
	// check if crossed 2/3 threshold
	if((this.health < (this.max_health * 2/3)) && (priorhealth > this.max_health * 2/3))
	{
		LOG_DEBUG("CROSSED 2/3 MARK!");
		boss_shocka1(this);
		SUB_UseTargets(this, NULL, NULL); // Yoder add, Dec 16 2020
		return;
	}
	
}
#endif
