#include "warden.qh"

#ifdef SVQC
// 0 is a dead frame
const int anim_warden_stand = 1;
const int anim_warden_walk = 182;
const int anim_warden_melee = 243;
const int anim_warden_sonic = 243;
const int anim_warden_death = 0;

const float ATTN_WARDEN = 0.2;

.float idle_finished;
.float warden_heartbeat;

void warden_darkness(entity this)
{
	float drange = 250;
	if(this.enemy)
		drange = 600;
	FOREACH_ENTITY_RADIUS(this.origin, drange, IS_PLAYER(it) && Damage_ValidTarget(it, this),
	{
		float efftime = 6;
		// only add more time if there isn't already a longer timer running!
		float curtime = StatusEffects_gettime(STATUSEFFECT_Darkness, it);
		if((time + efftime) > curtime)
			StatusEffects_apply(STATUSEFFECT_Darkness, it, time + efftime, 0);
	});
}

void warden_idlesound(entity this)
{
	warden_darkness(this);

	if(time >= this.warden_heartbeat)
	{
		this.warden_heartbeat = time + 2 + random();
		sound(this, CH_VOICE, SND_MON_WARDEN_HEARTBEAT_RANDOM(), 1, 0.2);
	}

	if(time < this.pain_finished)
		return;

	if(random() < 0.2 && time >= this.idle_finished)
	{
		this.idle_finished = time + 2 + (random() * 2);
		if(this.enemy)
			sound(this, CH_VOICE, SND_MON_WARDEN_IDLE_ANGRY_RANDOM(), 1, ATTN_WARDEN);
		else if(random() < 0.5)
			sound(this, CH_VOICE, SND_MON_WARDEN_IDLE_RANDOM(), 1, ATTN_WARDEN);
		else
			sound(this, CH_VOICE, SND_MON_WARDEN_CLICK_RANDOM(), 1, ATTN_WARDEN);
	}
}

void warden_stand(entity this)
{
	this.walkframe += 1;
	if(this.walkframe < anim_warden_stand || this.walkframe > 181)
		this.walkframe = anim_warden_stand;

	set_anim(this, this.walkframe, warden_stand);
	ai_stand(this);

	warden_idlesound(this);
}

void warden_moveframe(entity this)
{
	if(this.enemy)
		this.walkframe += 10;
	else
		this.walkframe += 1;
	if(this.walkframe <= anim_warden_walk || this.walkframe > 242)
		this.walkframe = anim_warden_walk;

	if(time >= this.footstep && IS_ONGROUND(this))
	{
		this.footstep = time + 1 + random();
		sound(this, CH_VOICE, SND_MON_WARDEN_STEP_RANDOM(), 1, ATTN_WARDEN);
	}

	warden_idlesound(this);
}

void warden_walk(entity this)
{
	warden_moveframe(this);
	set_anim(this, this.walkframe, warden_walk);

	ai_walk(this, 4);
}

void warden_run(entity this)
{
	warden_moveframe(this);
	set_anim(this, this.walkframe, warden_run);
	this.nextthink = time + 0.05; // double run speed

	ai_run(this, 6);
}

void ai_melee_warden(entity this, int deathtype, int melee_range, bool check_parry)
{
	if(!this.enemy)
		return;		// removed before stroke

	if(!ai_checkmelee(this, melee_range, false))
		return; // Too far away

	float ldmg = (random() + random() + random()) * 20;
	T_Damage(this.enemy, this, this, ldmg, deathtype);

	if(random() < 0.5)
		_sound(this, CH_VOICE, "warden/attack_impact_1.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_VOICE, "warden/attack_impact_2.wav", 1, ATTN_NORM);
}

void warden_melee10(entity this) { set_animofs(this, anim_warden_melee, 2, warden_run); ai_charge(this, 3); this.attack_finished = time + 1.5; }
void warden_melee9(entity this) { set_animofs(this, anim_warden_melee, 3, warden_melee10); ai_charge(this, 3); }
void warden_melee8(entity this) { set_animofs(this, anim_warden_melee, 4, warden_melee9); ai_charge(this, 3); }
void warden_melee7(entity this) { set_animofs(this, anim_warden_melee, 5, warden_melee8); ai_charge(this, 3); }
void warden_melee6(entity this) { set_animofs(this, anim_warden_melee, 6, warden_melee7); ai_charge(this, 3); }
void warden_melee5(entity this)
{
	set_animofs(this, anim_warden_melee, 5, warden_melee6);
	ai_charge(this, 3);

	ai_melee_warden(this, DEATH_MONSTER_WARDEN.m_id, 100, false);
}
void warden_melee4(entity this) { set_animofs(this, anim_warden_melee, 4, warden_melee5); ai_charge(this, 3); }
void warden_melee3(entity this) { set_animofs(this, anim_warden_melee, 3, warden_melee4); ai_charge(this, 3); }
void warden_melee2(entity this) { set_animofs(this, anim_warden_melee, 2, warden_melee3); ai_charge(this, 3); }
void warden_melee1(entity this) { set_animofs(this, anim_warden_melee, 1, warden_melee2); ai_charge(this, 3); }

//===========================================================================

void warden_shriek_touch(entity this, entity toucher)
{
	if(toucher == this.owner || toucher.solid == SOLID_TRIGGER || toucher.health < 1 || toucher.takedamage == DAMAGE_NO)
		return;
	// special rule: no collisions with owner
	// TODO: clip group?
	if(toucher.monsterdef == this.owner.monsterdef)
		return;
	if(time < this.attack_finished)
		return;

	// Block sprite burst from damage again
	this.attack_finished = time + 1;

	if(toucher)
		T_Damage(toucher, this, this.owner, 20, this.projectiledeathtype);
}

void warden_shriek_think(entity this)
{
	if(time > this.cnt)
	{
		delete(this);
		return;
	}

	entity newmis = spawn();
	newmis.classname = "sonic_boom";
	newmis.owner = this;
	newmis.solid = SOLID_NOT;
	set_movetype(newmis, MOVETYPE_NONE);
	// Roll the sonic boom from side to side towards the target
	float roll = 350 + random() * 20;
	newmis.angles = this.angles;
	newmis.angles_z = ANGLEMOD(roll);
	newmis.effects |= EF_NOSHADOW;
	_setmodel(newmis, "progs/sonic_boom.spr");
	setsize(newmis, '0 0 0', '0 0 0');
	setorigin(newmis, this.origin);
	SUB_SetFade(newmis, time, 0.5);
	newmis.scale = this.scale;

	this.scale += 0.1;
	setsize(this, -this.pos1 * this.scale, this.pos1 * this.scale);

	this.nextthink = time + 0.1;
}

void warden_shriek_spawn(entity this, vector org, vector dir)
{
	entity newmis = spawn();
	newmis.classname = "sonic_shriek";
	newmis.owner = this;

	set_movetype(newmis, MOVETYPE_NOCLIP);
	newmis.dphitcontentsmask = DPCONTENTS_BODY | DPCONTENTS_CORPSE;
	newmis.solid = SOLID_TRIGGER;
	newmis.pos1 = '48 48 48';
	newmis.projectiledeathtype = DEATH_MONSTER_WARDEN.m_id;
	newmis.cnt = time + 1.5;
	newmis.scale = 0.2;
	setsize(newmis, -newmis.pos1 * newmis.scale, newmis.pos1 * newmis.scale);
	setorigin(newmis, org);

	float aspeed = 500;
	newmis.velocity = dir * aspeed;

	newmis.nextthink = time + 0.1;
	setthink(newmis, warden_shriek_think);
	settouch(newmis, warden_shriek_touch);
}

void warden_sonicboom(entity this)
{
	if(!this.enemy)
		return;

	sound(this, CH_VOICE, SND_MON_WARDEN_BOOM_RANDOM(), 1, ATTN_WARDEN);

	vector org = this.origin + '0 0 32';
	vector dir = normalize(this.enemy.origin - this.origin);

	warden_shriek_spawn(this, org, dir);
}

void warden_sonicframe(entity this)
{
	this.walkframe += 1;

	if(this.walkframe > 288)
	{
		warden_run(this);
		this.attack_finished = time + 3 + random();
		return;
	}
	if(this.walkframe == 257)
		warden_sonicboom(this);

	set_anim(this, this.walkframe, warden_sonicframe);
}

void warden_sonic(entity this)
{
	this.walkframe = anim_warden_sonic;
	set_anim(this, this.walkframe, warden_sonicframe);
	sound(this, CH_VOICE, SND_MON_WARDEN_CHARGE_RANDOM(), 1, ATTN_WARDEN);
}

/*
===========
WardenCheckAttack

The player is in view, so decide to move or launch an attack
Returns false if movement should continue
============
*/
bool WardenCheckAttack(entity this)
{
	if(this.enemy_range == RANGE_MELEE)
	{
		if(CanDamage(this.enemy, this))
		{
			this.attack_state = AS_MELEE;
			return true;
		}
	}

	if(this.enemy_range == RANGE_FAR)
		return false;
	if(time < this.attack_finished)
		return false;

	// only shoot sometimes
	if(random() < 0.9)
		return false;
		
	entity targ = this.enemy;
	
// see if any entities are in the way of the shot
	vector spot1 = this.origin + this.view_ofs;
	vector spot2 = targ.origin + targ.view_ofs;

	if(vdist(spot1 - spot2, >, 600))
		return false;

	// TODO: ONLY shoot when we don't have a clear shot?!
#if 0
	traceline(spot1, spot2, false, this);

	if(trace_inopen && trace_inwater)
		return false;			// sight line crossed contents

	if(trace_ent != targ)
	{
		return false;	// don't have a clear shot
	}
#endif
			
// missile attack
		
	this.attack_state = AS_MISSILE;
	this.attack_finished = time + (2 * 2 * random());
	return true;
}


//===========================================================================

void warden_pain6(entity this) { set_anim(this, anim_warden_stand, warden_run); this.colormod = (this.charmed) ? '0 1 0' : '1 1 1'; }
void warden_pain5(entity this) { set_anim(this, anim_warden_stand, warden_pain6); }
void warden_pain4(entity this) { set_anim(this, anim_warden_stand, warden_pain5); this.colormod = '1 0.8 0.8'; }
void warden_pain3(entity this) { set_anim(this, anim_warden_stand, warden_pain4);}
void warden_pain2(entity this) { set_anim(this, anim_warden_stand, warden_pain3); ai_pain(this, 6); this.colormod = '1 0.6 0.6'; }
void warden_pain1(entity this) { set_anim(this, anim_warden_stand, warden_pain2); ai_pain(this, 6); }

void warden_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;
	if(random()*400 > damage)
		return;		// didn't flinch

	sound(this, CH_VOICE, SND_MON_WARDEN_PAIN_RANDOM(), 1, ATTN_WARDEN);

	this.pain_finished = time + 2;
	this.colormod = '1 0.9 0.9';

	warden_pain1(this);
}

//===========================================================================

void warden_vanish(entity this)
{
	Send_Effect(EFFECT_SMOKE_RING, this.origin, '0 0 80', 1);
	delete(this);
}

void warden_die6(entity this) { set_anim(this, anim_warden_death, warden_vanish); this.angles_z = 90; this.nextthink = time + 0.6; }
void warden_die5(entity this) { set_anim(this, anim_warden_death, warden_die6); this.angles_z = 75; }
void warden_die4(entity this) { set_anim(this, anim_warden_death, warden_die5); this.angles_z = 60; }
void warden_die3(entity this) { set_anim(this, anim_warden_death, warden_die4); this.angles_z = 45; }
void warden_die2(entity this) { set_anim(this, anim_warden_death, warden_die3); this.angles_z = 30; }
void warden_die1(entity this) { set_anim(this, anim_warden_death, warden_die2); this.angles_z = 15; this.solid = SOLID_NOT; }

void warden_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	if(random() < 0.5)
		_sound(this, CH_VOICE, "warden/death_1.wav", 1, ATTN_WARDEN);
	else
		_sound(this, CH_VOICE, "warden/death_2.wav", 1, ATTN_WARDEN);

	this.colormod = '1 0.6 0.6';
	this.angles_z = 0;
	warden_die1(this);
}

/*QUAKED monster_warden (1 0 0) (-16 -16 -24) (16 16 40) Ambush
*/
spawnfunc(monster_warden) { monster_start(this, true, MON_WARDEN); }
#endif // SVQC

#ifdef SVQC
METHOD(Warden, mr_setup, bool(Warden this, entity actor))
{
    TC(Warden, this);

    precache_model("progs/sonic_boom.spr");
	precache_sound("warden/death_1.wav");
	precache_sound("warden/death_2.wav");
	precache_sound("warden/attack_impact_1.wav");
	precache_sound("warden/attack_impact_2.wav");

	actor.yaw_speed = 70;

    actor.health = 600;
    actor.th_stand = warden_stand;
	actor.th_walk = warden_walk;
	actor.th_run = warden_run;
	actor.th_pain = warden_pain;
	actor.th_die = warden_die;
	actor.th_melee = warden_melee1;
	actor.th_missile = warden_sonic;

	actor.checkattack = WardenCheckAttack;

    return true;
}
METHOD(Warden, mr_sight, bool(Warden this, entity actor))
{
    TC(Warden, this);

    sound(actor, CH_VOICE, SND_MON_WARDEN_SIGHT_RANDOM(), 1, ATTN_WARDEN);

    return true;
}
#endif
