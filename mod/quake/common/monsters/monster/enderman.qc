#include "enderman.qh"

#ifdef SVQC
// 0 is a dead frame
const int anim_enderman_stand = 1;
const int anim_enderman_walk = 57;
const int anim_enderman_attack = 71;
const int anim_enderman_death = 85;

.float idle_finished;
.float enderman_particletime;

void enderman_idlesound(entity this)
{
	if(time >= this.enderman_particletime)
	{
		this.enderman_particletime = time + 0.1;
		vector offset = '0 0 1';
		offset.z *= (random() * 64);
		if(this.enemy)
			Send_Effect(EFFECT_ENDERMAN_ANGRY, this.origin + offset + randomvec() * 12, '0 0 64', 1);
		else
			Send_Effect(EFFECT_ENDERMAN, this.origin + offset + randomvec() * 12, '0 0 0', 1);
	}

	if(time < this.pain_finished)
		return;

	if(random() < 0.2 && time >= this.idle_finished)
	{
		this.idle_finished = time + 2;
		if(this.enemy)
		{
			float r = random();
			if(r < 0.25)
				_sound(this, CH_VOICE, "enderman/scream1.wav", 1, ATTN_NORM);
			else if(r < 0.5)
				_sound(this, CH_VOICE, "enderman/scream2.wav", 1, ATTN_NORM);
			else if(r < 0.75)
				_sound(this, CH_VOICE, "enderman/scream3.wav", 1, ATTN_NORM);
			else
				_sound(this, CH_VOICE, "enderman/scream4.wav", 1, ATTN_NORM);
		}
		else
		{
			float r = random();
			if(r < 0.25)
				_sound(this, CH_VOICE, "enderman/idle1.wav", 1, ATTN_IDLE);
			else if(r < 0.5)
				_sound(this, CH_VOICE, "enderman/idle2.wav", 1, ATTN_IDLE);
			else if(r < 0.75)
				_sound(this, CH_VOICE, "enderman/idle3.wav", 1, ATTN_IDLE);
			else
				_sound(this, CH_VOICE, "enderman/idle4.wav", 1, ATTN_IDLE);
		}
	}
}

void enderman_stand(entity this)
{
	this.walkframe += 1;
	if(this.walkframe < anim_enderman_stand || this.walkframe > 54)
		this.walkframe = anim_enderman_stand;

	enderman_idlesound(this);
	set_anim(this, this.walkframe, enderman_stand);

	ai_stand(this);
}

void enderman_moveframe(entity this)
{
	this.walkframe += 1;
	if(this.walkframe < anim_enderman_walk || this.walkframe >= 70)
		this.walkframe = anim_enderman_walk;

	enderman_idlesound(this);
}

void enderman_walk(entity this)
{
	enderman_moveframe(this);
	set_anim(this, this.walkframe, enderman_walk);

	ai_walk(this, 8);
}

void enderman_run(entity this)
{
	enderman_moveframe(this);
	set_anim(this, this.walkframe, enderman_run);
	this.nextthink = time + 0.05;

	ai_run(this, 15);
}

void enderman_melee(entity this)
{
	set_anim(this, anim_enderman_attack, enderman_run);
	this.nextthink = time + 0.5;
	ai_face(this);
	ai_melee(this, DEATH_MONSTER_ENDERMAN.m_id, 110, false);
	this.attack_finished = time + 0.5;
}

//===========================================================================

void enderman_teleport(entity this)
{
	vector extrasize = '1 1 1' * 600;
	vector from = this.origin;
	if(MoveToRandomLocationWithinBounds(this, this.absmin - extrasize, this.absmax + extrasize,
											DPCONTENTS_SOLID | DPCONTENTS_CORPSE | DPCONTENTS_PLAYERCLIP, DPCONTENTS_SLIME | DPCONTENTS_LAVA | DPCONTENTS_SKY | DPCONTENTS_BODY | DPCONTENTS_DONOTENTER, 
											Q3SURFACEFLAG_SKY, 20, 64, 256, true))
	{
		// no special treatment needed, we're just using it as a position!
		this.mangle = '0 1 0' * this.angles_y;
		this.angles = '0 0 0';
		soundat(NULL, from, CH_TRIGGER, "enderman/portal.wav", 1, ATTEN_NORM);
		soundat(NULL, this.origin, CH_TRIGGER, "enderman/portal2.wav", 1, ATTEN_NORM);
		te_teleport(this.origin);
		te_teleport(from);
		UNSET_ONGROUND(this);

		if(random() < 0.5)
			minion_spawn(this, from, new(monster), MON_ENDERMITE);
	}
}

void enderman_pain6(entity this) { set_anim(this, anim_enderman_stand, enderman_run); this.colormod = (this.charmed) ? '0 1 0' : '1 1 1'; }
void enderman_pain5(entity this) { set_anim(this, anim_enderman_stand, enderman_pain6); }
void enderman_pain4(entity this) { set_anim(this, anim_enderman_stand, enderman_pain5); this.colormod = '1 0.8 0.8'; }
void enderman_pain3(entity this) { set_anim(this, anim_enderman_stand, enderman_pain4);}
void enderman_pain2(entity this) { set_anim(this, anim_enderman_stand, enderman_pain3); ai_pain(this, 6); this.colormod = '1 0.6 0.6'; }
void enderman_pain1(entity this) { set_anim(this, anim_enderman_stand, enderman_pain2); ai_pain(this, 6); }

void enderman_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;

	float r = random();
	if(r < 0.25)
		_sound(this, CH_VOICE, "enderman/hit1.wav", 1, ATTN_NORM);
	else if(r < 0.5)
		_sound(this, CH_VOICE, "enderman/hit2.wav", 1, ATTN_NORM);
	else if(r < 0.75)
		_sound(this, CH_VOICE, "enderman/hit3.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_VOICE, "enderman/hit4.wav", 1, ATTN_NORM);

	this.pain_finished = time + 1;
	this.colormod = '1 0.9 0.9';

	// always tries, doesn't often succeed
	enderman_teleport(this);

	enderman_pain1(this);
}

//===========================================================================

void enderman_vanish(entity this)
{
	Send_Effect(EFFECT_SMOKE_RING, this.origin, '0 0 80', 1);
	delete(this);
}

void enderman_die7(entity this) { set_animofs(this, anim_enderman_death, 7, enderman_vanish); this.nextthink = time + 0.7; }
void enderman_die6(entity this) { set_animofs(this, anim_enderman_death, 6, enderman_die7); }
void enderman_die5(entity this) { set_animofs(this, anim_enderman_death, 5, enderman_die6); }
void enderman_die4(entity this) { set_animofs(this, anim_enderman_death, 4, enderman_die5); }
void enderman_die3(entity this) { set_animofs(this, anim_enderman_death, 3, enderman_die4); }
void enderman_die2(entity this) { set_animofs(this, anim_enderman_death, 2, enderman_die3); }
void enderman_die1(entity this) { set_animofs(this, anim_enderman_death, 1, enderman_die2); this.solid = SOLID_NOT; }

void enderman_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	_sound(this, CH_VOICE, "enderman/death.wav", 1, ATTN_NORM);

	int killed_type = Death_SpecialType(this, inflictor, attacker, deathtype);
	switch(killed_type)
	{
		case KILLED_NORMAL: break; // normal death
		case KILLED_GIBBED:
		{
			this.colormod = '1 1 1';
			ThrowGib(this, inflictor, "progs/h_enderman.mdl", this.health);
			// fall through to special handling
		}
		default: Death_SpecialHandle(this, attacker, killed_type); return;
	}

	this.colormod = '1 0.6 0.6';
	enderman_die1(this);
}

/*QUAKED monster_enderman (1 0 0) (-16 -16 -24) (16 16 40) Ambush
*/
spawnfunc(monster_enderman) { monster_start(this, true, MON_ENDERMAN); }
#endif // SVQC

#ifdef SVQC
METHOD(Enderman, mr_setup, bool(Enderman this, entity actor))
{
    TC(Enderman, this);

    precache_model("progs/h_enderman.mdl");
	precache_sound("enderman/death.wav");
	precache_sound("enderman/portal.wav");
	precache_sound("enderman/portal2.wav");

	precache_sound("enderman/hit1.wav");
	precache_sound("enderman/hit2.wav");
	precache_sound("enderman/hit3.wav");
	precache_sound("enderman/hit4.wav");

	precache_sound("enderman/scream1.wav");
	precache_sound("enderman/scream2.wav");
	precache_sound("enderman/scream3.wav");
	precache_sound("enderman/scream4.wav");

	precache_sound("enderman/idle1.wav");
	precache_sound("enderman/idle2.wav");
	precache_sound("enderman/idle3.wav");
	precache_sound("enderman/idle4.wav");

	precache_sound("enderman/stare.wav");

	actor.spawnflags |= SPAWNFLAG_NEARSIGHTED;

	actor.yaw_speed = 90;

    actor.health = 200;
    actor.gibhealth = -55;
    actor.th_stand = enderman_stand;
	actor.th_walk = enderman_walk;
	actor.th_run = enderman_run;
	actor.th_pain = enderman_pain;
	actor.th_die = enderman_die;
	actor.th_melee = enderman_melee;

    return true;
}
METHOD(Enderman, mr_sight, bool(Enderman this, entity actor))
{
    TC(Enderman, this);

    if(random() < 0.25)
		_sound(actor, CH_VOICE, "enderman/stare.wav", 1, ATTN_NORM);

    return true;
}
#endif
