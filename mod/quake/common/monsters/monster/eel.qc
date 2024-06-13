#include "eel.qh"

#ifdef SVQC
const int anim_eel_eelswim1 = 0;
const int anim_eel_eeldth1 = 6;

void T_EELZap(entity inflictor, entity attacker, float damage)
{
	entity head = findradius(inflictor.origin, damage + 40);
	
	while(head)
	{
		if(head.takedamage)
		{
			vector org = head.origin + (head.mins + head.maxs) * 0.5;
			float points = 0.5 * vlen(inflictor.origin - org);
			if(points < 0)
				points = 0;
			points = damage - points;
			if(head == attacker)
				points = points * 0.5;
			if(points > 0)
			{
				if (CanDamage(head, inflictor))
				{	// eels take no damage from this attack
					if (head.monsterdef != MON_EEL && 
						(head.flags & FL_INWATER))					
						T_Damage(head, inflictor, attacker, points, DEATH_MONSTER_EEL.m_id);
				}
			}
		}
		head = head.chain;
	}
}

void eel_pitch_change(entity this)
{
	if(pointcontents(this.origin) != CONTENT_WATER)
	{
		droptofloor(this);
		T_Damage(this, NULL, NULL, 6, DEATH_DROWN.m_id);
		return;
	}
	
	if(time < this.delay)
		return;

	if(this.weapon > 10)
		this.weapon = -10;

	if(this.weapon < 0)
		this.angles_x = this.angles_x - 1.5;
	else if(this.weapon > 0)
		this.angles_x = this.angles_x + 1.5;

	this.weapon = this.weapon + 1;
}

void eel_stand1(entity this);
void eel_stand6(entity this) { set_animofs(this, anim_eel_eelswim1, 6, eel_stand1); ai_stand(this); eel_pitch_change(this); }
void eel_stand5(entity this) { set_animofs(this, anim_eel_eelswim1, 5, eel_stand6); ai_stand(this); eel_pitch_change(this); }
void eel_stand4(entity this) { set_animofs(this, anim_eel_eelswim1, 4, eel_stand5); ai_stand(this); eel_pitch_change(this); }
void eel_stand3(entity this) { set_animofs(this, anim_eel_eelswim1, 3, eel_stand4); ai_stand(this); eel_pitch_change(this); }
void eel_stand2(entity this) { set_animofs(this, anim_eel_eelswim1, 2, eel_stand3); ai_stand(this); eel_pitch_change(this); }
void eel_stand1(entity this) { set_animofs(this, anim_eel_eelswim1, 1, eel_stand2); ai_stand(this); eel_pitch_change(this); }

void eel_walk1(entity this);
void eel_walk6(entity this) { set_animofs(this, anim_eel_eelswim1, 6, eel_walk1); ai_walk(this, 6); eel_pitch_change(this); }
void eel_walk5(entity this) { set_animofs(this, anim_eel_eelswim1, 5, eel_walk6); ai_walk(this, 6); eel_pitch_change(this); }
void eel_walk4(entity this) { set_animofs(this, anim_eel_eelswim1, 4, eel_walk5); ai_walk(this, 6); eel_pitch_change(this); }
void eel_walk3(entity this) { set_animofs(this, anim_eel_eelswim1, 3, eel_walk4); ai_walk(this, 6); eel_pitch_change(this); }
void eel_walk2(entity this) { set_animofs(this, anim_eel_eelswim1, 2, eel_walk3); ai_walk(this, 6); eel_pitch_change(this); }
void eel_walk1(entity this)
{
	set_animofs(this, anim_eel_eelswim1, 1, eel_walk2);

	if(random() < 0.2)
		_sound(this, CH_VOICE, "eel/eactive1.wav", 1, ATTN_IDLE);
	ai_walk(this, 6);
	eel_pitch_change(this);
}

void eel_run1(entity this);
void eel_run6(entity this) { set_animofs(this, anim_eel_eelswim1, 6, eel_run1); ai_run(this, 10); eel_pitch_change(this); }
void eel_run5(entity this) { set_animofs(this, anim_eel_eelswim1, 5, eel_run6); ai_run(this, 10); eel_pitch_change(this); }
void eel_run4(entity this) { set_animofs(this, anim_eel_eelswim1, 4, eel_run5); ai_run(this, 10); eel_pitch_change(this); }
void eel_run3(entity this) { set_animofs(this, anim_eel_eelswim1, 3, eel_run4); ai_run(this, 10); eel_pitch_change(this); }
void eel_run2(entity this) { set_animofs(this, anim_eel_eelswim1, 2, eel_run3); ai_run(this, 10); eel_pitch_change(this); }
void eel_run1(entity this)
{
	set_animofs(this, anim_eel_eelswim1, 1, eel_run2);

	if(random() < 0.4)
		_sound(this, CH_VOICE, "eel/eactive1.wav", 1, ATTN_IDLE);
	ai_run(this, 10);
	eel_pitch_change(this);
}

void eel_melee(entity this)
{
	bool attackOK = true;

	traceline(this.origin, this.enemy.origin, false, this);

	if(trace_ent != this.enemy)
		attackOK = false;       // don't have a clear shot
	if(trace_inopen && trace_inwater)
		attackOK = false;           // sight line crossed contents

	if(attackOK)
		T_EELZap(this, this, 45);
	this.skin = 0;
	this.effects = 0;
}

void eel_attack12(entity this) { set_animofs(this, anim_eel_eelswim1, 6, eel_run1); this.skin=5; eel_melee(this); }
void eel_attack11(entity this) { set_animofs(this, anim_eel_eelswim1, 5, eel_attack12); this.effects = EF_BRIGHTLIGHT; this.skin = 4; ai_charge(this, 8); eel_pitch_change(this); }
void eel_attack10(entity this) { set_animofs(this, anim_eel_eelswim1, 4, eel_attack11); this.skin = 3; ai_charge(this, 8); eel_pitch_change(this); }
void eel_attack9(entity this) { set_animofs(this, anim_eel_eelswim1, 3, eel_attack10); this.skin = 2; ai_charge(this, 8); eel_pitch_change(this); }
void eel_attack8(entity this)
{
	set_animofs(this, anim_eel_eelswim1, 2, eel_attack9);

	this.effects = EF_DIMLIGHT;
	this.skin = 1;
	ai_charge(this, 8);
	eel_pitch_change(this);
	_sound(this, CH_WEAPON_SINGLE, "eel/eatt1.wav", 1, ATTN_NORM);
}
void eel_attack7(entity this) { set_animofs(this, anim_eel_eelswim1, 1, eel_attack8); ai_charge(this, 8); eel_pitch_change(this);}
void eel_attack6(entity this) { set_animofs(this, anim_eel_eelswim1, 6, eel_attack7); ai_charge(this, 8); eel_pitch_change(this);}
void eel_attack5(entity this) { set_animofs(this, anim_eel_eelswim1, 5, eel_attack6); ai_charge(this, 8); eel_pitch_change(this);}
void eel_attack4(entity this) { set_animofs(this, anim_eel_eelswim1, 4, eel_attack5); ai_charge(this, 8); eel_pitch_change(this);}
void eel_attack3(entity this) { set_animofs(this, anim_eel_eelswim1, 3, eel_attack4); ai_charge(this, 8); eel_pitch_change(this);}
void eel_attack2(entity this) { set_animofs(this, anim_eel_eelswim1, 2, eel_attack3); ai_charge(this, 8); eel_pitch_change(this);}
void eel_attack1(entity this) { set_animofs(this, anim_eel_eelswim1, 1, eel_attack2); ai_charge(this, 8); eel_pitch_change(this);}

void eel_death16(entity this) { set_animofs(this, anim_eel_eeldth1, 10, eel_death16); CorpseThink(this); }
void eel_death15(entity this) { set_animofs(this, anim_eel_eeldth1, 9, eel_death16); droptofloor(this); }
void eel_death14(entity this) { set_animofs(this, anim_eel_eeldth1, 8, eel_death15); }
void eel_death13(entity this) { set_animofs(this, anim_eel_eeldth1, 7, eel_death14); }
void eel_death12(entity this) { set_animofs(this, anim_eel_eeldth1, 6, eel_death13); }
void eel_death11(entity this) { set_animofs(this, anim_eel_eeldth1, 5, eel_death12); this.flags &= ~FL_SWIM; }
void eel_death10(entity this) { set_animofs(this, anim_eel_eeldth1, 4, eel_death11); }
void eel_death9(entity this) { set_animofs(this, anim_eel_eeldth1, 3, eel_death10); }
void eel_death8(entity this) { set_animofs(this, anim_eel_eeldth1, 2, eel_death9); }
void eel_death7(entity this) { set_animofs(this, anim_eel_eeldth1, 1, eel_death8); }
void eel_death6(entity this) { set_animofs(this, anim_eel_eeldth1, 2, eel_death7); }
void eel_death5(entity this) { set_animofs(this, anim_eel_eeldth1, 3, eel_death6); }
void eel_death4(entity this) { set_animofs(this, anim_eel_eeldth1, 4, eel_death5); }
void eel_death3(entity this) { set_animofs(this, anim_eel_eeldth1, 3, eel_death4); }
void eel_death2(entity this) { set_animofs(this, anim_eel_eeldth1, 2, eel_death3); }
void eel_death1(entity this)
{
	set_animofs(this, anim_eel_eeldth1, 1, eel_death2);

	this.skin = 0;
	this.effects = 0;
	_sound(this, CH_VOICE, "eel/edie3r.wav", 1, ATTN_NORM);
	this.solid = SOLID_NOT;
}

void eel_death(entity this, entity inflictor, entity attacker, int deathtype)
{
	this.flags |= FL_SWIM;
	setsize(this, '0 0 0', '0 0 0');
	
//	this.skin = 1;		// change to bloody eel skin!
	if(this.health < -12)
	{
		this.skin = 0;
		this.effects = 0;
		ThrowHead(this, inflictor, "progs/eelgib.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib1.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib1.mdl", this.health);
		ThrowGib(this, inflictor, "progs/gib1.mdl", this.health);
		return;
	}
	else
		eel_death1(this);
}

void eel_pain7(entity this) { set_animofs(this, anim_eel_eeldth1, 1, eel_run1); }
void eel_pain6(entity this) { set_animofs(this, anim_eel_eeldth1, 2, eel_pain7); }
void eel_pain5(entity this) { set_animofs(this, anim_eel_eeldth1, 3, eel_pain6); }
void eel_pain4(entity this) { set_animofs(this, anim_eel_eeldth1, 4, eel_pain5); }
void eel_pain3(entity this) { set_animofs(this, anim_eel_eeldth1, 3, eel_pain4); }
void eel_pain2(entity this) { set_animofs(this, anim_eel_eeldth1, 2, eel_pain3); }
void eel_pain1(entity this, entity attacker, float damage, int deathtype)
{
	set_animofs(this, anim_eel_eeldth1, 1, eel_pain2);

	if(this.pain_finished > time)
		return;
	
	this.pain_finished = time + 1;
	_sound(this, CH_VOICE, "eel/epain3.wav", 1, ATTN_NORM); 
	this.skin = 0;
}

/*QUAKED monster_eel (1 0 0) (-16 -16 -24) (16 16 32) Ambush
*/
spawnfunc(monster_eel)
{
	monster_start(this, true, MON_EEL);
}
#endif // SVQC

#ifdef SVQC
METHOD(Eel, mr_setup, bool(Eel this, entity actor))
{
    TC(Eel, this);

	precache_model("progs/gib1.mdl");
	
	precache_sound("eel/edie3r.wav");
	precache_sound("eel/epain3.wav");
	precache_sound("eel/eactive1.wav");
	precache_sound("eel/eatt1.wav");

	actor.delay = time + random() * 6;
	actor.weapon = 0;

	actor.health = 60;
    actor.th_stand = eel_stand1;
	actor.th_walk = eel_walk1;
	actor.th_run = eel_run1;
	actor.th_die = eel_death;
	actor.th_pain = eel_pain1;
	actor.th_melee = eel_attack1;

    return true;
}
#endif
