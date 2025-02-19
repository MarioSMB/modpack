#include "blaze.qh"

#ifdef SVQC
const int anim_blaze = 0; // no actual animations!

.entity blaze_body;
.float idle_finished;

void blaze_idlesound(entity this)
{
	if(time < this.pain_finished)
		return;

	if(random() < 0.1 && time >= this.idle_finished)
	{
		this.idle_finished = time + 2;
		sound(this, CH_VOICE, SND_MON_BLAZE_IDLE_RANDOM(), 1, ATTN_NORM);
	}
}

void blaze_stand(entity this) { set_anim(this, anim_blaze, blaze_stand); ai_stand(this); blaze_idlesound(this); }

void blaze_walk(entity this) { set_anim(this, anim_blaze, blaze_walk); ai_walk(this, 1); blaze_idlesound(this); }

void blaze_run(entity this) { set_anim(this, anim_blaze, blaze_run); ai_run(this, 2); blaze_idlesound(this); }

//===========================================================================

void blaze_fireball_touch(entity this, entity toucher)
{
	if(toucher == this.owner)
		return;

	if(toucher.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	if(pointcontents(this.origin) == CONTENT_SKY)
	{
		delete(this);
		return;
	}
	
// hit something that bleeds
	if(toucher.takedamage) // yoder mod, jan 05 2021
	{
		float damg = ((this.dmg) ? this.dmg : 9);
		T_Damage(toucher, this, this.owner, damg, this.projectiledeathtype);

		float burntime = floor(autocvar_skill + 3 + 2*random());
		// only add more burn time if there isn't already a longer timer running!
		float curtime = StatusEffects_gettime(STATUSEFFECT_Burning, toucher);
		if((time + burntime) > curtime)
			StatusEffects_apply(STATUSEFFECT_Burning, toucher, time + burntime, 0);
	}

	delete(this);
}

void blaze_fireball_launch(entity this)
{
	vector offang = vectoangles(this.enemy.origin - this.origin);
	
	makevectors(offang);

	vector org = this.origin + this.mins + this.size*0.5 + v_forward * 20;

// set missile speed
	vector vec = normalize(v_forward);
	vec_z = 0 - vec_z +(random() - 0.5)*0.1;
	
	entity newmis = launch_spike(this, org, vec);
	newmis.projectiledeathtype = DEATH_MONSTER_BLAZE.m_id;
	newmis.classname = "knight_spike";
	newmis.scale = 0.7;
	newmis.modelflags |= MF_ROCKET;
	settouch(newmis, blaze_fireball_touch);
	_setmodel(newmis, "progs/lavaball.mdl");
	setsize(newmis, '0 0 0', '0 0 0');		
	newmis.velocity = vec*300;
	_sound(this, CH_WEAPON_SINGLE, "blaze/fireball4.wav", 1, ATTN_NORM);
}

void blaze_shoot7(entity this) { set_anim(this, anim_blaze, blaze_run); ai_face(this); blaze_fireball_launch(this); this.attack_finished = time + 5; }
void blaze_shoot6(entity this) { set_anim(this, anim_blaze, blaze_shoot7); ai_face(this); }
void blaze_shoot5(entity this) { set_anim(this, anim_blaze, blaze_shoot6); ai_face(this); }
void blaze_shoot4(entity this) { set_anim(this, anim_blaze, blaze_shoot5); ai_face(this); blaze_fireball_launch(this); }
void blaze_shoot3(entity this) { set_anim(this, anim_blaze, blaze_shoot4); ai_face(this); }
void blaze_shoot2(entity this) { set_anim(this, anim_blaze, blaze_shoot3); ai_face(this); }
void blaze_shoot1(entity this) { set_anim(this, anim_blaze, blaze_shoot2); ai_face(this); blaze_fireball_launch(this); }

void blaze_shoot(entity this)
{
	blaze_shoot1(this);
}

//===========================================================================

void blaze_pain6(entity this) { set_anim(this, anim_blaze, blaze_run); this.colormod = (this.charmed) ? '0 1 0' : '1 1 1'; }
void blaze_pain5(entity this) { set_anim(this, anim_blaze, blaze_pain6); }
void blaze_pain4(entity this) { set_anim(this, anim_blaze, blaze_pain5); this.colormod = '1 0.8 0.8'; }
void blaze_pain3(entity this) { set_anim(this, anim_blaze, blaze_pain4);}
void blaze_pain2(entity this) { set_anim(this, anim_blaze, blaze_pain3); ai_pain(this, 6); this.colormod = '1 0.6 0.6'; }
void blaze_pain1(entity this) { set_anim(this, anim_blaze, blaze_pain2); ai_pain(this, 6); }

void blaze_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;

	sound(this, CH_VOICE, SND_MON_BLAZE_PAIN_RANDOM(), 1, ATTN_NORM);

	this.pain_finished = time + 0.5;
	this.colormod = '1 0.9 0.9';

	blaze_pain1(this);
}

/*
=================
BlazeCheckAttack
=================
*/
bool BlazeCheckAttack(entity this)
{
	if(time < this.attack_finished)
		return false;
	if(!this.enemy_visible)
		return false;

	if(this.enemy_range == RANGE_FAR)
	{
		if(this.attack_state != AS_STRAIGHT)
		{
			this.attack_state = AS_STRAIGHT;
			blaze_run(this);
		}
		return false;
	}
		
	entity targ = this.enemy;
	
// see if any entities are in the way of the shot
	vector spot1 = this.origin + this.view_ofs;
	vector spot2 = targ.origin + targ.view_ofs;

	traceline(spot1, spot2, false, this);

	if(trace_ent != targ)
	{	// don't have a clear shot, so move to a side
		if(this.attack_state != AS_STRAIGHT)
		{
			this.attack_state = AS_STRAIGHT;
			blaze_run(this);
		}
		return false;
	}

	float chance;	
	if(this.enemy_range == RANGE_MELEE)
		chance = 0.9;
	else if(this.enemy_range == RANGE_NEAR)
		chance = 0.6;
	else if(this.enemy_range == RANGE_MID)
		chance = 0.2;
	else
		chance = 0;

	if(random() < chance)
	{
		this.attack_state = AS_MISSILE;
		return true;
	}
	
	return false;
}

//===========================================================================

void blaze_vanish(entity this)
{
	if(this.blaze_body)
		delete(this.blaze_body);

	Send_Effect(EFFECT_SMOKE_RING, this.origin, '0 0 80', 1);
	delete(this);
}

void blaze_die1(entity this)
{
	set_anim(this, anim_blaze, blaze_vanish);
	this.nextthink = time + 1;
	this.solid = SOLID_NOT;
	set_movetype(this, MOVETYPE_TOSS);
	this.velocity_x = -200 + 400*random();
	this.velocity_y = -200 + 400*random();
	this.velocity_z = 100 + 100*random();
	UNSET_ONGROUND(this);
}

void blaze_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	_sound(this, CH_VOICE, "blaze/death.wav", 1, ATTN_NORM);

	if(this.health < -55)
	{
		this.effects &= ~EF_FLAME;
		if(this.blaze_body)
		{
			delete(this.blaze_body);
			this.blaze_body = NULL;
		}
		ThrowHead(this, inflictor, MDL_MON_BLAZE_HEAD.model_str(), this.health);
		return;
	}

	this.colormod = '1 0.6 0.6';
	blaze_die1(this);
}

void blaze_body_think(entity this)
{
	if(!this.owner || this.owner.blaze_body != this)
	{
		delete(this);
		return;
	}
	this.colormod = this.owner.colormod;
	this.nextthink = time;
}

void blaze_body_create(entity this)
{
	if(this.blaze_body)
		delete(this.blaze_body);

	entity body = spawn();
	body.classname = "blaze_body";
	body.owner = this;
	body.solid = SOLID_NOT; // main monster handles hitbox
	setmodel(body, MDL_MON_BLAZE_BODY);
	setsize(body, '0 0 0', '0 0 0');
	set_movetype(body, MOVETYPE_NONE);
	setattachment(body, this, "");
	setthink(body, blaze_body_think);
	body.nextthink = time;

	this.blaze_body = body;
}

void blaze_touch(entity this, entity toucher)
{
	if(this.health <= 0 || (!this.takedamage))
		return;
	if(!Damage_ValidTarget(toucher, this))
		return;

	if(toucher.takedamage && toucher.pain_finished < time)
	{
		float ldmg = 10*random();
		T_Damage(toucher, this, this, ldmg, DEATH_MONSTER_BLAZE.m_id);	
	}
}

/*QUAKED monster_blaze (1 0 0) (-16 -16 -24) (16 16 40) Ambush
*/
spawnfunc(monster_blaze) { monster_start(this, true, MON_BLAZE); }
#endif // SVQC

#ifdef SVQC
METHOD(Blaze, mr_setup, bool(Blaze this, entity actor))
{
    TC(Blaze, this);

	precache_sound("blaze/death.wav");
	precache_sound("blaze/fireball4.wav");

	precache_model("progs/lavaball.mdl");

	actor.yaw_speed = 180;

    actor.health = 200;
    actor.th_stand = blaze_stand;
	actor.th_walk = blaze_walk;
	actor.th_run = blaze_run;
	actor.th_pain = blaze_pain;
	actor.th_die = blaze_die;
	actor.th_missile = blaze_shoot;
	actor.checkattack = BlazeCheckAttack;

	actor.effects |= EF_FLAME;

	settouch(actor, blaze_touch);

	blaze_body_create(actor);

    return true;
}
#endif
