#include "boil.qh"

#ifdef SVQC
const int anim_boil_stand = 0; //'0 15 0'
const int anim_boil_walk = 16; //'16 31 0'
const int anim_boil_run = 32; //'32 39 0'
const int anim_boil_explode = 40; //'40 48 0'
const int anim_boil_hobA = 49; //'49 58 0'
const int anim_boil_hobB = 59; //'59 68 0'

const int MON_BOIL_HANGING = 2; // Hanging on wall upside down by spikes
const int MON_BOIL_HOBBLED = 4; // Hobbled on the floor, random A/B position

.vector brkvelbase;
.float waitmin;

/*==============================================================================
BOIL/BOMB model by Ijed, QC/Gameplay by Sock
==============================================================================*/

void boil_suicide(entity this, entity actor, entity trigger);

void boil_idle_sound(entity this)
{
	if(random() < 0.2)
	{
		if(random() < 0.5)
			_sound(this, CH_VOICE, "zombie/boil_idle1.wav", 1, ATTN_NORM);
		else
			_sound(this, CH_VOICE, "zombie/boil_idle2.wav", 1, ATTN_NORM);
	}
}

void boil_stand1(entity this);
void boil_stand16(entity this) { set_animofs(this, anim_boil_stand, 16, boil_stand1); ai_stand(this); }
void boil_stand15(entity this) { set_animofs(this, anim_boil_stand, 15, boil_stand16); ai_stand(this); }
void boil_stand14(entity this) { set_animofs(this, anim_boil_stand, 14, boil_stand15); ai_stand(this); }
void boil_stand13(entity this) { set_animofs(this, anim_boil_stand, 13, boil_stand14); ai_stand(this); }
void boil_stand12(entity this) { set_animofs(this, anim_boil_stand, 12, boil_stand13); ai_stand(this); }
void boil_stand11(entity this) { set_animofs(this, anim_boil_stand, 11, boil_stand12); ai_stand(this); }
void boil_stand10(entity this) { set_animofs(this, anim_boil_stand, 10, boil_stand11); ai_stand(this); }
void boil_stand9(entity this) { set_animofs(this, anim_boil_stand, 9, boil_stand10); ai_stand(this); }
void boil_stand8(entity this) { set_animofs(this, anim_boil_stand, 8, boil_stand9); ai_stand(this); }
void boil_stand7(entity this) { set_animofs(this, anim_boil_stand, 7, boil_stand8); ai_stand(this); }
void boil_stand6(entity this) { set_animofs(this, anim_boil_stand, 6, boil_stand7); ai_stand(this); }
void boil_stand5(entity this) { set_animofs(this, anim_boil_stand, 5, boil_stand6); ai_stand(this); }
void boil_stand4(entity this) { set_animofs(this, anim_boil_stand, 4, boil_stand5); ai_stand(this); }
void boil_stand3(entity this) { set_animofs(this, anim_boil_stand, 3, boil_stand4); ai_stand(this); }
void boil_stand2(entity this) { set_animofs(this, anim_boil_stand, 2, boil_stand3); ai_stand(this); }
void boil_stand1(entity this) { set_animofs(this, anim_boil_stand, 1, boil_stand2); boil_idle_sound(this); ai_stand(this); }

void boil_walk1(entity this);
void boil_walk16(entity this) { set_animofs(this, anim_boil_walk, 16, boil_walk1); ai_walk(this, 2); }
void boil_walk15(entity this) { set_animofs(this, anim_boil_walk, 15, boil_walk16); ai_walk(this, 2); }
void boil_walk14(entity this) { set_animofs(this, anim_boil_walk, 14, boil_walk15); ai_walk(this, 3); }
void boil_walk13(entity this) { set_animofs(this, anim_boil_walk, 13, boil_walk14); ai_walk(this, 3); }
void boil_walk12(entity this) { set_animofs(this, anim_boil_walk, 12, boil_walk13); ai_walk(this, 2); }
void boil_walk11(entity this) { set_animofs(this, anim_boil_walk, 11, boil_walk12); ai_walk(this, 1); }
void boil_walk10(entity this) { set_animofs(this, anim_boil_walk, 10, boil_walk11); ai_walk(this, 3); monster_footstep(this, true); }
void boil_walk9(entity this) { set_animofs(this, anim_boil_walk, 9, boil_walk10); ai_walk(this, 0); }
void boil_walk8(entity this) { set_animofs(this, anim_boil_walk, 8, boil_walk9); ai_walk(this, 2); }
void boil_walk7(entity this) { set_animofs(this, anim_boil_walk, 7, boil_walk8); ai_walk(this, 1); }
void boil_walk6(entity this) { set_animofs(this, anim_boil_walk, 6, boil_walk7); ai_walk(this, 2); }
void boil_walk5(entity this) { set_animofs(this, anim_boil_walk, 5, boil_walk6); ai_walk(this, 3); }
void boil_walk4(entity this) { set_animofs(this, anim_boil_walk, 4, boil_walk5); ai_walk(this, 3); }
void boil_walk3(entity this) { set_animofs(this, anim_boil_walk, 3, boil_walk4); ai_walk(this, 4); }
void boil_walk2(entity this) { set_animofs(this, anim_boil_walk, 2, boil_walk3); ai_walk(this, 3); monster_footstep(this, true); }
void boil_walk1(entity this) { set_animofs(this, anim_boil_walk, 1, boil_walk2); boil_idle_sound(this); ai_walk(this, 0); }

void boil_run1(entity this);
void boil_run8(entity this) { set_animofs(this, anim_boil_run, 8, boil_run1); ai_run(this, 4); }
void boil_run7(entity this) { set_animofs(this, anim_boil_run, 7, boil_run8); ai_run(this, 8); }
void boil_run6(entity this) { set_animofs(this, anim_boil_run, 6, boil_run7); ai_run(this, 16); }
void boil_run5(entity this) { set_animofs(this, anim_boil_run, 5, boil_run6); ai_run(this, 4); monster_footstep(this, true); }
void boil_run4(entity this) { set_animofs(this, anim_boil_run, 4, boil_run5); ai_run(this, 4); }
void boil_run3(entity this) { set_animofs(this, anim_boil_run, 3, boil_run4); ai_run(this, 8); }
void boil_run2(entity this)
{
	set_animofs(this, anim_boil_run, 2, boil_run3);
	boil_idle_sound(this);
	ai_run(this, 16);
}
void boil_run1(entity this) { set_animofs(this, anim_boil_run, 1, boil_run2); ai_run(this, 4); monster_footstep(this, true); }

// Running Boil Explosive Attack
void boil_expl9(entity this) { set_animofs(this, anim_boil_explode, 9, boil_expl9); T_Damage(this, this, this, this.health + 1, DEATH_MONSTER_BOIL.m_id); }
void boil_expl8(entity this) { set_animofs(this, anim_boil_explode, 8, boil_expl9); ai_face(this); }
void boil_expl7(entity this) { set_animofs(this, anim_boil_explode, 7, boil_expl8); ai_face(this); }
void boil_expl6(entity this) { set_animofs(this, anim_boil_explode, 6, boil_expl7); ai_face(this); }
void boil_expl5(entity this) { set_animofs(this, anim_boil_explode, 5, boil_expl6); ai_face(this); }
void boil_expl4(entity this) { set_animofs(this, anim_boil_explode, 4, boil_expl5); ai_face(this); }
void boil_expl3(entity this) { set_animofs(this, anim_boil_explode, 3, boil_expl4); ai_face(this); }
void boil_expl2(entity this) { set_animofs(this, anim_boil_explode, 2, boil_expl3); ai_face(this); }
void boil_expl1(entity this)
{
	set_animofs(this, anim_boil_explode, 1, boil_expl2);
	ai_face(this);
	_sound(this, CH_VOICE, "zombie/boil_windup.wav", 1, ATTN_NORM);
}

void boil_checktarget(entity this)
{
	this.enemy = NULL;

	if(this.health < 1 || intermission_running)
		return;

	RandomSelection_Init();
	if(this.charmed)
	{
		FOREACH_ENTITY_FLAGS(flags, FL_MONSTER,
		{
			if(it != this && this.enemy != it && it.health > 0 && !(it.flags & FL_NOTARGET) && !StatusEffects_active(STATUSEFFECT_Invisibility, it) && !it.charmed)
			{
				traceline(CENTER_OR_VIEWOFS(this), it.origin, true, this);
				if(trace_fraction != 1)
					continue;
				RandomSelection_AddEnt(it, 1, 1);
			}
		});
	}
	else
	{
		FOREACH_CLIENT(IS_PLAYER(it) && it.health > 0 && !(it.flags & FL_NOTARGET) && !StatusEffects_active(STATUSEFFECT_Invisibility, it),
		{
			// enable for line of sight
			//traceline(this.origin + '0 0 16', it.origin, true, this);
			//if(trace_fraction != 1)
				//continue;
			RandomSelection_AddEnt(it, 1, 1);
		});
	}
			
	this.enemy = RandomSelection_chosen_ent;

	if(this.enemy && this.th_melee && vdist(this.enemy.origin - this.origin, <, 120))
		this.th_melee(this);
}

void boil_squirtblood(entity this)
{
	if(this.waitmin < time)
	{
		this.waitmin = time + this.wait + random() * this.wait;
		_sound(this, CH_WEAPON_SINGLE, "zombie/boil_squirt.wav", 1, ATTN_IDLE);
		
		SpawnProjectileMeat(this, this.origin, this.brkvelbase_x, this.brkvelbase_y, this.brkvelbase_z);
		// Randomly spawn an extra gib of flesh
		if(random() < 0.25)
			SpawnProjectileMeat(this, this.origin, this.brkvelbase_x, this.brkvelbase_y, this.brkvelbase_z);
	}
}

void boil_hoba1(entity this);
void boil_hoba4(entity this) { set_animofs(this, anim_boil_hobA, 2, boil_hoba1); boil_checktarget(this); }
void boil_hoba3(entity this) { set_animofs(this, anim_boil_hobA, 3, boil_hoba4); this.nextthink += random() * 0.2; boil_checktarget(this); }
void boil_hoba2(entity this) { set_animofs(this, anim_boil_hobA, 2, boil_hoba3); boil_checktarget(this); }
void boil_hoba1(entity this)
{
	set_animofs(this, anim_boil_hobA, 1, boil_hoba2);
	this.nextthink += random() * 0.2;
	boil_idle_sound(this);
	boil_squirtblood(this);
	boil_checktarget(this);
}

//----------------------------------------------------------------------
void boil_HexpA9(entity this) { set_animofs(this, anim_boil_hobA, 10, boil_HexpA9); boil_suicide(this, this.enemy, this.enemy); }
void boil_HexpA8(entity this) { set_animofs(this, anim_boil_hobA, 9, boil_HexpA9); }
void boil_HexpA7(entity this) { set_animofs(this, anim_boil_hobA, 8, boil_HexpA8); }
void boil_HexpA6(entity this) { set_animofs(this, anim_boil_hobA, 7, boil_HexpA7); }
void boil_HexpA5(entity this) { set_animofs(this, anim_boil_hobA, 6, boil_HexpA6); }
void boil_HexpA4(entity this) { set_animofs(this, anim_boil_hobA, 5, boil_HexpA5); }
void boil_HexpA3(entity this) { set_animofs(this, anim_boil_hobA, 4, boil_HexpA4); }
void boil_HexpA2(entity this) { set_animofs(this, anim_boil_hobA, 3, boil_HexpA3); }
void boil_HexpA1(entity this) { set_animofs(this, anim_boil_hobA, 2, boil_HexpA2); _sound(this, CH_VOICE, "zombie/boil_windup.wav", 1, ATTN_NORM); }

//----------------------------------------------------------------------
void boil_hobb1(entity this);
void boil_hobb4(entity this) { set_animofs(this, anim_boil_hobB, 2, boil_hobb1); boil_checktarget(this); }
void boil_hobb3(entity this) { set_animofs(this, anim_boil_hobB, 3, boil_hobb4); this.nextthink += random() * 0.2; boil_checktarget(this); }
void boil_hobb2(entity this) { set_animofs(this, anim_boil_hobB, 2, boil_hobb3); boil_checktarget(this); }
void boil_hobb1(entity this)
{
	set_animofs(this, anim_boil_hobB, 1, boil_hobb2);
	this.nextthink += random() * 0.2;
	boil_idle_sound(this);
	boil_squirtblood(this);
	boil_checktarget(this);
}

//----------------------------------------------------------------------
void boil_HexpB9(entity this) { set_animofs(this, anim_boil_hobB, 10, boil_HexpB9); boil_suicide(this, this.enemy, this.enemy); }
void boil_HexpB8(entity this) { set_animofs(this, anim_boil_hobB, 9, boil_HexpB9); }
void boil_HexpB7(entity this) { set_animofs(this, anim_boil_hobB, 8, boil_HexpB8); }
void boil_HexpB6(entity this) { set_animofs(this, anim_boil_hobB, 7, boil_HexpB7); }
void boil_HexpB5(entity this) { set_animofs(this, anim_boil_hobB, 6, boil_HexpB6); }
void boil_HexpB4(entity this) { set_animofs(this, anim_boil_hobB, 5, boil_HexpB5); }
void boil_HexpB3(entity this) { set_animofs(this, anim_boil_hobB, 4, boil_HexpB4); }
void boil_HexpB2(entity this) { set_animofs(this, anim_boil_hobB, 3, boil_HexpB3); }
void boil_HexpB1(entity this) { set_animofs(this, anim_boil_hobB, 2, boil_HexpB2); _sound(this, CH_VOICE, "zombie/boil_windup.wav", 1, ATTN_NORM); }

void boil_pain(entity this, entity attacker, float damage, int deathtype)
{
	// Spawn some grey particles and chunk of meat
	SpawnProjectileSmoke(this.origin, this.brkvelbase_x, this.brkvelbase_y, this.brkvelbase_z);
	SpawnProjectileMeat(this,this.origin, this.brkvelbase_x, this.brkvelbase_y, this.brkvelbase_z);
	// Random chance of more smokey meat
	if(random() < 0.5)
	{
		SpawnProjectileSmoke(this.origin, this.brkvelbase_x, this.brkvelbase_y, this.brkvelbase_z);
		SpawnProjectileMeat(this,this.origin, this.brkvelbase_x, this.brkvelbase_y, this.brkvelbase_z);
	}

	// No special animation 
}

void boil_explode(entity this)
{
	T_RadiusDamage(this, this, 75, DEATH_MONSTER_BOIL.m_id, this);
	
	if(this.poisonous)
		te_explosion2(this.origin, 51, 8); // Switch explosions effect based on poison flag
	else
		te_explosion(this.origin); // Show classic grenade explosion effect

	_sound(this, CH_VOICE, "player/udeath.wav", 1, ATTN_NORM);

	int gibcnt = 0;
	gibcnt = 1 + rint(random() * 2);
	for(int j = 0; j < gibcnt; ++j)
	{
		if(this.poisonous)
			ThrowGib(this, this, "progs/gib_p3.mdl", this.health);
		else
			ThrowGib(this, this, "progs/gib_3.mdl", this.health);
	}
	gibcnt = 4 + rint(random() * 2);
	for(int j = 0; j < gibcnt; ++j)
	{
		if(this.poisonous)
			ThrowGib(this, this, "progs/gib_p4.mdl", this.health);
		else
			ThrowGib(this, this, "progs/gib_4.mdl", this.health);
	}
	gibcnt = 5 + rint(random() * 3);
	for(int j = 0; j < gibcnt; ++j)
	{
		if(this.poisonous)
			ThrowGib(this, this, "progs/gib_p4.mdl", this.health);
		else
			ThrowGib(this, this, "progs/gib_4.mdl", this.health);
	}

	delete(this);
}

void boil_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	_sound(this, CH_VOICE, "zombie/boil_explode.wav", 1, ATTN_NORM);

	// Delay the t_radius explosion for one frame
	// Just in case several are standing next to each other
	// otherwise there will be a runaway crash loop
	setthink(this, boil_explode);
	this.nextthink = time + 0.1;
}

//======================================================================
// Stationary Boil - Nailed to the floor or wall
//======================================================================
void boil_suicide(entity this, entity actor, entity trigger)
{ 
	if(this.health < 1)
		return;
	this.use = func_null;
	// Make sure current enemy is the cause of the damage
	T_Damage(this, this, this.enemy, this.health + 1, DEATH_MONSTER_BOIL.m_id);
}

/*======================================================================
 BoilCheckAttack (Has no range attack)
 The player is in view, so blow up!
======================================================================*/
bool BoilCheckAttack(entity this)
{
	entity targ = this.enemy;

	if(this.enemy_range == RANGE_FAR)
		return false;
	if(!this.enemy_visible)
		return false;

	if(vdist(targ.origin - this.origin, <=, 80))
	{
		this.attack_state = AS_MELEE;
		return true;
	}

	return false;
}

/*======================================================================
 QUAKED monster_boil (1 0 0) (-16 -16 -24) (16 16 32)
======================================================================*/
spawnfunc(monster_boil) { monster_start(this, true, MON_BOIL); }
#endif // SVQC

#ifdef SVQC
METHOD(Boil, mr_setup, bool(Boil this, entity actor))
{
	TC(Boil, this);

	precache_model("progs/gib_3.mdl");
	precache_model("progs/gib_p3.mdl");
	precache_model("progs/gib_4.mdl");
	precache_model("progs/gib_p4.mdl");

	precache_sound("zombie/boil_idle1.wav");
	precache_sound("zombie/boil_idle2.wav");

	precache_sound("zombie/boil_squirt.wav");
	precache_sound("zombie/boil_windup.wav");
	precache_sound("zombie/boil_explode.wav");

	actor.skin = floor(random() * 5);
	actor.brkvelbase = '200 50 150';

	// Setup timer for flesh gib squirting from body
	if(actor.wait < 1)
		actor.wait = 4;
	actor.waitmin = time + actor.wait + random() * actor.wait;

	if(actor.health < 1)
    	actor.health = 40;
	actor.th_pain = boil_pain;
	actor.th_die = boil_die;
	actor.checkattack = BoilCheckAttack;

	actor.steptype = FS_TYPESLOW;

	// Setup random hobble animation
	if(actor.spawnflags & (MON_BOIL_HOBBLED | MON_BOIL_HANGING))
	{
		// A = Crossed legs, B = Straight legs
		if(random() < 0.5)
		{		
			actor.th_stand = actor.th_walk = actor.th_run = boil_hoba1;
			actor.th_melee = boil_HexpA1;
		}
		else
		{
			actor.th_stand = actor.th_walk = actor.th_run = boil_hobb1;
			actor.th_melee = boil_HexpB1;
		}

		actor.use = boil_suicide;
	}

	// Hobbled hanging upside down on wall?
	if(actor.spawnflags & MON_BOIL_HANGING)
	{
		// Make sure angle is within range (0-360)
		if(actor.angles_y < 0)
			actor.angles_y = 360;

		vector dir = '0 0 0';
		dir.y = ANGLEMOD(actor.angles_y + 180);
		// Calculate upward vector and rotate monster
		makevectors(actor.angles);
		actor.angles = dir + vectoangles(v_up);
		// Pull monster away from wall
		// TODO: wouldn't this maybe put monsters inside floors?
		actor.origin += v_forward * 10;
		actor.flags |= FL_FLY; // doing this just to prevent onground checks?
		// Setup squirt distance for blood
		actor.brkvelbase = '100 50 150';
	}
	// Hobbled legs with spikes (ground pose)
	else if(actor.spawnflags & MON_BOIL_HOBBLED)
	{
		// Check for random floor rotation and setup no movment
		if(actor.angles_y < 0)
			actor.angles_y = rint(random() * 360);
		// Setup squirt distance for blood
		actor.brkvelbase = '100 300 100';
	}
	else
	{
		// Default stand, walk & run
		actor.th_stand = boil_stand1;
		actor.th_walk = boil_walk1;
		actor.th_run = boil_run1;
		actor.th_melee = boil_expl1;
	}

    return true;
}
#endif
