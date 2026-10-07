#include "redstone_cube.qh"

#ifdef SVQC
const int anim_rcube_stand = 0;
const int anim_rcube_walk = 21;
const int anim_rcube_attack = 31;

void rcube_stand1(entity this)
{
	set_animofs(this, anim_rcube_stand, this.walkframe + 1, rcube_stand1);
	this.walkframe += 1;
	if(this.walkframe >= 21)
		this.walkframe = 0;

	ai_stand(this);
}

void rcube_walk1(entity this);
void rcube_walk10(entity this) { set_animofs(this, anim_rcube_walk, 10, rcube_walk1); ai_walk(this, 4); }
void rcube_walk9(entity this) { set_animofs(this, anim_rcube_walk, 9, rcube_walk10); ai_walk(this, 3); }
void rcube_walk8(entity this) { set_animofs(this, anim_rcube_walk, 8, rcube_walk9); ai_walk(this, 3); monster_footstep(this, false); }
void rcube_walk7(entity this) { set_animofs(this, anim_rcube_walk, 7, rcube_walk8); ai_walk(this, 8); }
void rcube_walk6(entity this) { set_animofs(this, anim_rcube_walk, 6, rcube_walk7); ai_walk(this, 6); }
void rcube_walk5(entity this) { set_animofs(this, anim_rcube_walk, 5, rcube_walk6); ai_walk(this, 4); monster_footstep(this, false); }
void rcube_walk4(entity this) { set_animofs(this, anim_rcube_walk, 4, rcube_walk5); ai_walk(this, 3); }
void rcube_walk3(entity this) { set_animofs(this, anim_rcube_walk, 3, rcube_walk4); ai_walk(this, 6); monster_footstep(this, false); }
void rcube_walk2(entity this) { set_animofs(this, anim_rcube_walk, 2, rcube_walk3); ai_walk(this, 8); }
void rcube_walk1(entity this) { set_animofs(this, anim_rcube_walk, 1, rcube_walk2); ai_walk(this, 4); }

void rcube_run1(entity this);
void rcube_run10(entity this) { set_animofs(this, anim_rcube_walk, 10, rcube_run1); ai_run(this, 20); }
void rcube_run9(entity this) { set_animofs(this, anim_rcube_walk, 9, rcube_run10); ai_run(this, 26); }
void rcube_run8(entity this) { set_animofs(this, anim_rcube_walk, 8, rcube_run9); ai_run(this, 26); monster_footstep(this, false); }
void rcube_run7(entity this) { set_animofs(this, anim_rcube_walk, 7, rcube_run8); ai_run(this, 23); }
void rcube_run6(entity this) { set_animofs(this, anim_rcube_walk, 6, rcube_run7); ai_run(this, 20); }
void rcube_run5(entity this) { set_animofs(this, anim_rcube_walk, 5, rcube_run6); ai_run(this, 16); monster_footstep(this, false); }
void rcube_run4(entity this) { set_animofs(this, anim_rcube_walk, 4, rcube_run5); ai_run(this, 23); }
void rcube_run3(entity this) { set_animofs(this, anim_rcube_walk, 3, rcube_run4); ai_run(this, 13); monster_footstep(this, false); }
void rcube_run2(entity this) { set_animofs(this, anim_rcube_walk, 2, rcube_run3); ai_run(this, 20); }
void rcube_run1(entity this) { set_animofs(this, anim_rcube_walk, 1, rcube_run2); ai_run(this, 16); }

void rcube_atk15(entity this) { set_animofs(this, anim_rcube_attack, 15, rcube_run1); }
void rcube_atk14(entity this) { set_animofs(this, anim_rcube_attack, 14, rcube_atk15); }
void rcube_atk13(entity this) { set_animofs(this, anim_rcube_attack, 13, rcube_atk14); }
void rcube_atk12(entity this) { set_animofs(this, anim_rcube_attack, 12, rcube_atk13); }
void rcube_atk11(entity this) { set_animofs(this, anim_rcube_attack, 11, rcube_atk12); }
void rcube_atk10(entity this) { set_animofs(this, anim_rcube_attack, 10, rcube_atk11); }
void rcube_atk9(entity this) { set_animofs(this, anim_rcube_attack, 9, rcube_atk10); ai_charge(this, 1); }
void rcube_atk8(entity this) { set_animofs(this, anim_rcube_attack, 8, rcube_atk9); ai_charge(this, 3); }
void rcube_atk7(entity this) { set_animofs(this, anim_rcube_attack, 7, rcube_atk8); ai_charge(this, 1); }
void rcube_atk6(entity this) { set_animofs(this, anim_rcube_attack, 6, rcube_atk7); ai_charge(this, 4); ai_melee(this, DEATH_MONSTER_REDSTONE_CUBE.m_id, 60, true); }
void rcube_atk5(entity this) { set_animofs(this, anim_rcube_attack, 5, rcube_atk6); ai_charge(this, 2); ai_melee(this, DEATH_MONSTER_REDSTONE_CUBE.m_id, 60, true); }
void rcube_atk4(entity this) { set_animofs(this, anim_rcube_attack, 4, rcube_atk5); ai_charge(this, 3); W_Parry_Trigger(this, 0); monster_footstep(this, false); }
void rcube_atk3(entity this) { set_animofs(this, anim_rcube_attack, 3, rcube_atk4); ai_charge(this, 4); }
void rcube_atk2(entity this) { set_animofs(this, anim_rcube_attack, 2, rcube_atk3); ai_charge(this, 7); }
void rcube_atk1(entity this) { set_animofs(this, anim_rcube_attack, 1, rcube_atk2); ai_charge(this, 0); }

void rcube_pain(entity this, entity attacker, float damage, int deathtype)
{
	// TODO: nothing?
}

void rcube_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	int killed_type = Death_SpecialType(this, inflictor, attacker, deathtype);
	switch(killed_type)
	{
		case KILLED_NORMAL: break; // normal death
		case KILLED_GIBBED:
		{
			SpawnExplosion(EXPLODE_BIG, CENTER_OR_VIEWOFS(this), "weapons/r_exp3b.wav");
			// fall through to special handling
		}
		default: Death_SpecialHandle(this, attacker, killed_type); return;
	}

	// throw ourselves as a giblet, remove the original
	float r = random();
	if(r < 0.33)
		_sound(this, CH_VOICE, "redstone_cube/lavaburst1.wav", 1, ATTN_NORM);
	else if(r < 0.66)
		_sound(this, CH_VOICE, "redstone_cube/lavaburst2.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_VOICE, "redstone_cube/lavaburst3.wav", 1, ATTN_NORM);
	entity gib = ThrowGib(this, inflictor, "progs/redstone_cube.mdl", this.health);
	setsize(gib, this.mins, this.maxs);
	gib.skin = 1;
	delete(this);
}

/*QUAKED monster_redstone_cube(1 0 0)(-16 -16 -24)(16 16 40) Ambush
*/
spawnfunc(monster_redstone_cube) { monster_start(this, true, MON_REDSTONE_CUBE); }
#endif // SVQC

#ifdef SVQC
METHOD(RedstoneCube, mr_setup, bool(RedstoneCube this, entity actor))
{
	TC(RedstoneCube, this);

	precache_sound("weapons/r_exp3b.wav");
	precache_sound("redstone_cube/lavaburst1.wav");
	precache_sound("redstone_cube/lavaburst2.wav");
	precache_sound("redstone_cube/lavaburst3.wav");

	actor.health = 80;
	actor.gibhealth = -40;
	actor.th_stand = rcube_stand1;
	actor.th_walk = rcube_walk1;
	actor.th_run = rcube_run1;
	actor.th_melee = rcube_atk1;
	actor.th_pain = rcube_pain;
	actor.th_die = rcube_die;
	actor.skin = 0;

	// Custom feet sounds
	actor.stepc1 = "redstone_cube/walk1.wav";
	actor.stepc2 = "redstone_cube/walk2.wav";
	actor.stepc3 = "redstone_cube/walk3.wav";
	actor.stepc4 = "redstone_cube/walk4.wav";
	actor.stepc5 = "redstone_cube/walk1.wav";
	precache_sound(actor.stepc1);
	precache_sound(actor.stepc2);
	precache_sound(actor.stepc3);
	precache_sound(actor.stepc4);
	actor.steptype = FS_TYPECUSTOM;

	return true;
}
#endif
