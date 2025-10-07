#include "vindicator.qh"

#ifdef SVQC
const int anim_vindicator_stand = 0;
const int anim_vindicator_atk = 41;
const int anim_vindicator_walk = 57;
const int anim_vindicator_run = 69;
const int anim_vindicator_pain = 81;

.float idle_finished;

void vindicator_idlesound(entity this)
{
	if(time < this.pain_finished)
		return;

	if(random() < 0.2 && time >= this.idle_finished)
	{
		this.idle_finished = time + 2 + (random() * 2);
		sound(this, CH_VOICE, SND_MON_VINDICATOR_IDLE_RANDOM(), 1, ATTN_NORM);
	}
}

void vindicator_moveframe(entity this, int startframe, int endframe)
{
	this.walkframe += 1;
	if(this.walkframe < startframe || this.walkframe > endframe)
		this.walkframe = startframe;

	vindicator_idlesound(this);
}

void vindicator_stand(entity this)
{
	vindicator_moveframe(this, anim_vindicator_stand, 40);
	set_anim(this, this.walkframe, vindicator_stand);
	// not needed for idling!
	//this.nextthink = time + 0.05; // slow animation needs fixing

	ai_stand(this);
}

void vindicator_walk(entity this)
{
	vindicator_moveframe(this, anim_vindicator_walk, 68);
	set_anim(this, this.walkframe, vindicator_walk);
	this.nextthink = time + 0.05; // slow animation needs fixing

	ai_walk(this, 8);
}

void vindicator_run(entity this)
{
	vindicator_moveframe(this, anim_vindicator_run, 80);
	set_anim(this, this.walkframe, vindicator_run);
	this.nextthink = time + 0.05; // slow animation needs fixing

	ai_run(this, 16);
}

void vin_atkfrm(entity this)
{
	this.nextthink = time + 0.05; // speed it up thank you!
}

void vindicator_atk16(entity this) { set_animofs(this, anim_vindicator_atk, 16, vindicator_run); vin_atkfrm(this); }
void vindicator_atk15(entity this) { set_animofs(this, anim_vindicator_atk, 15, vindicator_atk16); vin_atkfrm(this); }
void vindicator_atk14(entity this) { set_animofs(this, anim_vindicator_atk, 14, vindicator_atk15); vin_atkfrm(this); }
void vindicator_atk13(entity this) { set_animofs(this, anim_vindicator_atk, 13, vindicator_atk14); vin_atkfrm(this); }
void vindicator_atk12(entity this) { set_animofs(this, anim_vindicator_atk, 12, vindicator_atk13); vin_atkfrm(this); }
void vindicator_atk11(entity this) { set_animofs(this, anim_vindicator_atk, 11, vindicator_atk12); vin_atkfrm(this); }
void vindicator_atk10(entity this) { set_animofs(this, anim_vindicator_atk, 10, vindicator_atk11); vin_atkfrm(this); }
void vindicator_atk9(entity this) { set_animofs(this, anim_vindicator_atk, 9, vindicator_atk10); ai_charge(this, 1); vin_atkfrm(this); }
void vindicator_atk8(entity this) { set_animofs(this, anim_vindicator_atk, 8, vindicator_atk9); ai_charge(this, 3); ai_melee(this, DEATH_MONSTER_VINDICATOR.m_id, 60, true); vin_atkfrm(this); }
void vindicator_atk7(entity this) { set_animofs(this, anim_vindicator_atk, 7, vindicator_atk8); ai_charge(this, 1); ai_melee(this, DEATH_MONSTER_VINDICATOR.m_id, 60, true); vin_atkfrm(this); }
void vindicator_atk6(entity this) { set_animofs(this, anim_vindicator_atk, 6, vindicator_atk7); ai_charge(this, 4); ai_melee(this, DEATH_MONSTER_VINDICATOR.m_id, 60, true); vin_atkfrm(this); }
void vindicator_atk5(entity this) { set_animofs(this, anim_vindicator_atk, 5, vindicator_atk6); ai_charge(this, 3); W_Parry_Trigger(this, 0); vin_atkfrm(this); }
void vindicator_atk4(entity this) { set_animofs(this, anim_vindicator_atk, 4, vindicator_atk5); ai_charge(this, 0); vin_atkfrm(this); }
void vindicator_atk3(entity this) { set_animofs(this, anim_vindicator_atk, 3, vindicator_atk4); _sound(this, CH_WEAPON_SINGLE, "knight/sword1.wav", 1, ATTN_NORM); ai_charge(this, 4); vin_atkfrm(this); }
void vindicator_atk2(entity this) { set_animofs(this, anim_vindicator_atk, 2, vindicator_atk3); ai_charge(this, 7); vin_atkfrm(this); }
void vindicator_atk1(entity this) { set_animofs(this, anim_vindicator_atk, 1, vindicator_atk2);  ai_charge(this, 0); vin_atkfrm(this); }

//===========================================================================

void vindicator_pain12(entity this) { set_animofs(this, anim_vindicator_pain, 12, vindicator_run); }
void vindicator_pain11(entity this) { set_animofs(this, anim_vindicator_pain, 11, vindicator_pain12); }
void vindicator_pain10(entity this) { set_animofs(this, anim_vindicator_pain, 10, vindicator_pain11); }
void vindicator_pain9(entity this) { set_animofs(this, anim_vindicator_pain, 9, vindicator_pain10); }
void vindicator_pain8(entity this) { set_animofs(this, anim_vindicator_pain, 8, vindicator_pain9); }
void vindicator_pain7(entity this) { set_animofs(this, anim_vindicator_pain, 7, vindicator_pain8); }
void vindicator_pain6(entity this) { set_animofs(this, anim_vindicator_pain, 6, vindicator_pain7); this.colormod = (this.charmed) ? '0 1 0' : '1 1 1'; }
void vindicator_pain5(entity this) { set_animofs(this, anim_vindicator_pain, 5, vindicator_pain6); }
void vindicator_pain4(entity this) { set_animofs(this, anim_vindicator_pain, 4, vindicator_pain5); this.colormod = '1 0.8 0.8'; }
void vindicator_pain3(entity this) { set_animofs(this, anim_vindicator_pain, 3, vindicator_pain4); }
void vindicator_pain2(entity this) { set_animofs(this, anim_vindicator_pain, 2, vindicator_pain3); ai_pain(this, 6); this.colormod = '1 0.6 0.6'; }
void vindicator_pain1(entity this) { set_animofs(this, anim_vindicator_pain, 1, vindicator_pain2); ai_pain(this, 6); }

void vindicator_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;
	if(random()*200 > damage)
		return;		// didn't flinch

	sound(this, CH_VOICE, SND_MON_VINDICATOR_PAIN_RANDOM(), 1, ATTN_NORM);

	this.pain_finished = time + 1.1;
	this.colormod = '1 0.9 0.9';
	this.scale = 1;

	vindicator_pain1(this);
}

//===========================================================================

void vindicator_vanish(entity this)
{
	Send_Effect(EFFECT_SMOKE_RING, this.origin, '0 0 80', 1);
	delete(this);
}

void vindicator_die7(entity this) { set_anim(this, this.frame, vindicator_vanish); this.nextthink = time + 0.7; this.angles_z = 90; }
void vindicator_die6(entity this) { set_anim(this, this.frame, vindicator_die7); this.angles_z = 75; }
void vindicator_die5(entity this) { set_anim(this, this.frame, vindicator_die6); this.angles_z = 60; }
void vindicator_die4(entity this) { set_anim(this, this.frame, vindicator_die5); this.angles_z = 45; }
void vindicator_die3(entity this) { set_anim(this, this.frame, vindicator_die4); this.angles_z = 30; }
void vindicator_die2(entity this) { set_anim(this, this.frame, vindicator_die3); this.angles_z = 15; }
void vindicator_die1(entity this) { set_anim(this, this.frame, vindicator_die2); this.solid = SOLID_NOT; this.angles_z = 0; }

void vindicator_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	if(random() < 0.5)
		_sound(this, CH_VOICE, "vindicator/death1.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_VOICE, "vindicator/death2.wav", 1, ATTN_NORM);

	if(this.health < -55)
	{
		this.colormod = '1 1 1';
		ThrowHead(this, inflictor, MDL_MON_VINDICATOR_HEAD.model_str(), this.health);
		return;
	}

	this.colormod = '1 0.6 0.6';
	vindicator_die1(this);
}

/*QUAKED monster_vindicator (1 0 0) (-16 -16 -24) (16 16 40) Ambush
*/
spawnfunc(monster_vindicator) { monster_start(this, true, MON_VINDICATOR); }
#endif // SVQC

#ifdef SVQC
METHOD(Vindicator, mr_setup, bool(Vindicator this, entity actor))
{
    TC(Vindicator, this);

	precache_sound("vindicator/death1.wav");
	precache_sound("vindicator/death2.wav");
	precache_sound("knight/sword1.wav");

	actor.spawnflags |= SPAWNFLAG_NEARSIGHTED;

	actor.yaw_speed = 180;

    actor.health = 150;
    actor.th_stand = vindicator_stand;
	actor.th_walk = vindicator_walk;
	actor.th_run = vindicator_run;
	actor.th_pain = vindicator_pain;
	actor.th_die = vindicator_die;
	actor.th_melee = vindicator_atk1;

    return true;
}
#endif
