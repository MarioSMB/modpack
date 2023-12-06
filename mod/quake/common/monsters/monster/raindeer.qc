#include "raindeer.qh"

#ifdef SVQC
const int anim_raindeer_rattack = 0;
const int anim_raindeer_idlefeet = 4;
const int anim_raindeer_stand = 11;
const int anim_raindeer_run = 15;
const int anim_raindeer_altar = 23;

/*==============================================================================
XMAS Raindeer - From Twisted Christmas Mod by Twisted Matrix
==============================================================================*/

void raindeer_idlesound(entity this)
{
	if(random() < 0.2)
		_sound(this, CH_VOICE, "xmas/raindeer/idle.wav", 1,  ATTN_IDLE);
}

void raind_idlefeet1(entity this);
void raind_stand1(entity this);
void raind_idlefeet7(entity this) { set_animofs(this, anim_raindeer_idlefeet, 7, raind_stand1); ai_stand(this); }
void raind_idlefeet6(entity this) { set_animofs(this, anim_raindeer_idlefeet, 6, raind_idlefeet7); ai_stand(this); }
void raind_idlefeet5(entity this) { set_animofs(this, anim_raindeer_idlefeet, 5, raind_idlefeet6); ai_stand(this); }
void raind_idlefeet4(entity this) { set_animofs(this, anim_raindeer_idlefeet, 4, raind_idlefeet5); ai_stand(this); }
void raind_idlefeet3(entity this) { set_animofs(this, anim_raindeer_idlefeet, 3, raind_idlefeet4); ai_stand(this); }
void raind_idlefeet2(entity this) { set_animofs(this, anim_raindeer_idlefeet, 2, raind_idlefeet3); ai_stand(this); }
void raind_idlefeet1(entity this) { set_animofs(this, anim_raindeer_idlefeet, 1, raind_idlefeet2); ai_stand(this); }

//----------------------------------------------------------------------
void raind_stand8(entity this)
{
	set_animofs(this, anim_raindeer_stand, 4, raind_stand1); 
	if(random() < 0.2)
		setthink(this, raind_idlefeet1);
}
void raind_stand7(entity this) { set_animofs(this, anim_raindeer_stand, 4, raind_stand8); ai_stand(this); }
void raind_stand6(entity this) { set_animofs(this, anim_raindeer_stand, 3, raind_stand7); ai_stand(this); }
void raind_stand5(entity this) { set_animofs(this, anim_raindeer_stand, 3, raind_stand6); ai_stand(this); }
void raind_stand4(entity this) { set_animofs(this, anim_raindeer_stand, 2, raind_stand5); ai_stand(this); }
void raind_stand3(entity this) { set_animofs(this, anim_raindeer_stand, 2, raind_stand4); ai_stand(this); }
void raind_stand2(entity this) { set_animofs(this, anim_raindeer_stand, 1, raind_stand3); ai_stand(this); }
void raind_stand1(entity this) { set_animofs(this, anim_raindeer_stand, 1, raind_stand2); raindeer_idlesound(this); ai_stand(this); }

//======================================================================
void raind_walk1(entity this);
void raind_walk8(entity this) { set_animofs(this, anim_raindeer_run, 4, raind_walk1); ai_walk(this, 8); }
void raind_walk7(entity this) { set_animofs(this, anim_raindeer_run, 3, raind_walk8); ai_walk(this, 5); }
void raind_walk6(entity this) { set_animofs(this, anim_raindeer_run, 2, raind_walk7); ai_walk(this, 13); }
void raind_walk5(entity this) { set_animofs(this, anim_raindeer_run, 1, raind_walk6); ai_walk(this, 8); }
void raind_walk4(entity this) { set_animofs(this, anim_raindeer_run, 8, raind_walk5); ai_walk(this, 5); }
void raind_walk3(entity this) { set_animofs(this, anim_raindeer_run, 7, raind_walk4); ai_walk(this, 10); }
void raind_walk2(entity this) { set_animofs(this, anim_raindeer_run, 6, raind_walk3); ai_walk(this, 5); }
void raind_walk1(entity this) { set_animofs(this, anim_raindeer_run, 5, raind_walk2); raindeer_idlesound(this); ai_walk(this, 8); }

//======================================================================
void raind_run1(entity this);
void raind_run8(entity this) { set_animofs(this, anim_raindeer_run, 4, raind_run1); ai_run(this, 15); }
void raind_run7(entity this) { set_animofs(this, anim_raindeer_run, 3, raind_run8); ai_run(this, 10); }
void raind_run6(entity this) { set_animofs(this, anim_raindeer_run, 2, raind_run7); ai_run(this, 25); }
void raind_run5(entity this) { set_animofs(this, anim_raindeer_run, 1, raind_run6); ai_run(this, 15); }
void raind_run4(entity this) { set_animofs(this, anim_raindeer_run, 8, raind_run5); ai_run(this, 10); }
void raind_run3(entity this) { set_animofs(this, anim_raindeer_run, 7, raind_run4); ai_run(this, 20); }
void raind_run2(entity this) { set_animofs(this, anim_raindeer_run, 6, raind_run3); ai_run(this, 10); }
void raind_run1(entity this) { set_animofs(this, anim_raindeer_run, 5, raind_run2); raindeer_idlesound(this); ai_run(this, 15); }

void raind_melee(entity this)
{
	if(!this.enemy)
		return;
	if(this.health < 1)
		return;
	if(!this.enemy.takedamage)
		return;
		
	ai_charge(this, 10);
	if(!ai_checkmelee(this, 80, 0))
		return;

	_sound(this, CH_WEAPON_SINGLE, "xmas/raindeer/hit.wav", 1, ATTN_NORM);

	// Sack attack is strong (1-60)
	float ldmg = max(1, (random() + random() + random()) * 3);
	T_Damage(this.enemy, this, this, ldmg, DEATH_MONSTER_RAINDEER.m_id);

	// Spawn blood at sack
	spawn_touchblood(this, ldmg*3, this.enemy);
}

//----------------------------------------------------------------------
void raind_ram1(entity this);
void raind_ram4(entity this)
{
	set_animofs(this, anim_raindeer_rattack, 4, raind_run1);
	// Check if raindeer is within range to attack again
	if(ai_checkmelee(this, 80, 0) && this.enemy.health > 0)
	{
		if(this.health > 0)
			setthink(this, raind_ram1);
	}
}
void raind_ram3(entity this) { set_animofs(this, anim_raindeer_rattack, 3, raind_ram4); ai_charge(this, 5); }
void raind_ram2(entity this) { set_animofs(this, anim_raindeer_rattack, 2, raind_ram3); raind_melee(this); }
void raind_ram1(entity this) { set_animofs(this, anim_raindeer_rattack, 1, raind_ram2); ai_charge(this, 10); }

void raindeer_launch_projectile(entity this, vector org, vector dir)
{
	entity newmis = launch_spike(this, org, dir);
	_setmodel(newmis, "progs/xmas/proj_rdrocket.mdl");
	setsize(newmis, '0 0 0', '0 0 0');
	newmis.dmg = 20;
	newmis.velocity = dir * 575;
	newmis.projectiledeathtype = DEATH_MONSTER_RAINDEER.m_id;
	newmis.noise = "xmas/raindeer/hit.wav";
	settouch(newmis, T_MissileTouch);
}

void raind_attack(entity this, vector sideofs)
{
	if(!this.enemy)
		return;
	if(this.health < 1)
		return;
	
	this.effects |= EF_MUZZLEFLASH;

	// Cycle between attack sounds
	if(this.lefty == 0) 
		_sound(this, CH_WEAPON_SINGLE, "xmas/raindeer/attack1.wav", 1, ATTN_NORM);
	else
		_sound(this, CH_WEAPON_SINGLE, "xmas/raindeer/attack2.wav", 1, ATTN_NORM);
	this.lefty = 1 - this.lefty;

	// turn and face your enemy!
	ai_face(this);
	fixedmakevectors(this.angles);

	vector org = this.origin + attack_vector(sideofs);
	// Fire rocket direction to match raindeer side
	vector vec = v_right * (sideofs.x + (random() * 10));
	vector dir = normalize((this.enemy.origin + vec) - org);
	raindeer_launch_projectile(this, org, dir);
}

//----------------------------------------------------------------------
void raind_shoot8(entity this)
{
	set_animofs(this, anim_raindeer_rattack, 4, raind_run1);
	raind_attack(this, '-2 12 12');
}
void raind_shoot7(entity this) { set_animofs(this, anim_raindeer_rattack, 3, raind_shoot8); ai_face(this);}
void raind_shoot6(entity this) { set_animofs(this, anim_raindeer_rattack, 2, raind_shoot7); }
void raind_shoot5(entity this) { set_animofs(this, anim_raindeer_rattack, 1, raind_shoot6); ai_face(this);}
void raind_shoot4(entity this)
{
	set_animofs(this, anim_raindeer_rattack, 4, raind_shoot5);
	// Skills - EASY/NORMAL = 1 rocket, HARD/NM = 2 rockets
	if(autocvar_skill < 2)
	{
		setthink(this, raind_run1);
		// Randomize upper side (LEFT=-12 RIGHT=12)
		if(random() < 0.5)
			raind_attack(this, '-2 -12 12');
		else
			raind_attack(this, '-2 12 12');
	}
	else
		raind_attack(this, '-2 -12 12');
}
void raind_shoot3(entity this) { set_animofs(this, anim_raindeer_rattack, 3, raind_shoot4); ai_face(this);}
void raind_shoot2(entity this) { set_animofs(this, anim_raindeer_rattack, 2, raind_shoot3); }
void raind_shoot1(entity this) { set_animofs(this, anim_raindeer_rattack, 1, raind_shoot2); ai_face(this);}

void raind_pain4(entity this) { set_animofs(this, anim_raindeer_rattack, 4, raind_run1); }
void raind_pain3(entity this) { set_animofs(this, anim_raindeer_rattack, 3, raind_pain4); }
void raind_pain2(entity this) { set_animofs(this, anim_raindeer_rattack, 2, raind_pain3); ai_pain(this, 4); }
void raind_pain1(entity this) { set_animofs(this, anim_raindeer_rattack, 1, raind_pain2); }

void raind_pain(entity this, entity attacker, float damage, int deathtype)
{
	if(this.pain_finished > time)
		return;
	if(random()*100 > damage)
		return;		// didn't flinch

	_sound(this, CH_VOICE, "xmas/raindeer/hit.wav", 1, ATTN_NORM);

	if(random() < 0.5)
	{
		this.pain_finished = time + 1;
		raind_pain1(this);
	}
	else
	{
		this.axhitme = false;
		this.pain_finished = time + 0.6;
		raind_pain1(this);
	}
}

void raind_explode(entity this)
{
	// Make sure gibs go flying up
	this.health = -100;

	// ID style explosion
	te_explosion(this.origin);
	T_RadiusDamage(this, this, 40, DEATH_MONSTER_RAINDEER.m_id, NULL);
	
	// Sprite + Dust
	SpawnExplosion(EXPLODE_BIG, this.origin, "xmas/raindeer/death.wav");
	SpawnProjectileSmoke(this.origin, 200, 250, 100);
	SpawnProjectileSmoke(this.origin, 200, 250, 100);

	// No blood or guts!
	ThrowHead(this, "progs/xmas/h_raindeer.mdl", this.health);
	ThrowGib(this, "progs/xmas/gib_rdleg1.mdl", this.health);
	ThrowGib(this, "progs/xmas/gib_rdrockpack.mdl", this.health);
	for(int j = 0; j < floor(random() * 8); ++j)
	{
		ThrowGib(this, "progs/xmas/gib_snowball.mdl", this.health);
	}
}

void raind_die(entity this, entity inflictor, entity attacker, int deathtype)
{
	_sound(this, CHAN_BODY, "xmas/raindeer/death.wav", 1, ATTN_NORM);
	// slight delay to avoid recursive explosions
	setthink(this, raind_explode);
	this.nextthink = time;
}

/*
===========
RaindeerCheckAttack

The player is in view, so decide to move or launch an attack
Returns false if movement should continue
============
*/
bool RaindeerCheckAttack(entity this)
{
	entity targ = this.enemy;

	if(MP_IMPEL)
	{
		if(this.enemy_range == RANGE_FAR)
			return false;
		if(time < this.attack_finished)
			return false;
	}

	if(ai_checkmelee(this, 80, 0))
	{
		this.attack_state = AS_MELEE;
		return true;
	}
	
// see if any entities are in the way of the shot
	vector spot1 = this.origin + this.view_ofs;
	vector spot2 = targ.origin + targ.view_ofs;

	traceline(spot1, spot2, MOVE_NORMAL, this);

	if(trace_inopen && trace_inwater)
		return false;			// sight line crossed contents

	if(trace_ent != targ)
		return false;	// don't have a clear shot
			
	
// missile attack
	if(!MP_IMPEL)
	{
		if(time < this.attack_finished)
			return false;
			
		if(this.enemy_range == RANGE_FAR)
			return false;
	}

	float chance = 0;
	if(this.enemy_range == RANGE_MELEE)
		chance = 0.9;
	else if(this.enemy_range == RANGE_NEAR)
		chance = 0.4;
	else if(this.enemy_range == RANGE_MID)
		chance = 0.05;

	if(random() < chance && this.th_missile)
	{
		this.th_missile(this);
		this.attack_finished = time + (2 + 2*random());
		return true;
	}

	return false;
}

//=============================================================================
//QUAKED monster_xmas_raindeer (0.5 0.75 0) (-16 -16 -24) (16 16 40) Ambush
//=============================================================================
spawnfunc(monster_xmas_raindeer) { monster_start(this, true, MON_RAINDEER); }
#endif // SVQC

#ifdef SVQC
METHOD(Raindeer, mr_setup, bool(Raindeer this, entity actor))
{
    TC(Raindeer, this);

	precache_model("progs/xmas/gib_rdleg1.mdl");
	precache_model("progs/xmas/gib_rdrockpack.mdl");

	precache_model("progs/xmas/proj_rdrocket.mdl");

	precache_sound("xmas/raindeer/idle.wav");

	precache_sound("xmas/raindeer/attack1.wav");
	precache_sound("xmas/raindeer/attack2.wav");

	precache_sound("xmas/raindeer/hit.wav");
	precache_sound("xmas/raindeer/death.wav");

	precache_model("progs/xmas/gib_snowball.mdl");

	// NOTE: not included is the MON_RAINDEER_DEAD scene!

    actor.health = 200;
	actor.checkattack = RaindeerCheckAttack;
	actor.th_stand = raind_stand1;
	actor.th_walk = raind_walk1;
	actor.th_run = raind_run1;
	actor.th_melee = raind_ram1;
	actor.th_missile = raind_shoot1;
	actor.th_pain = raind_pain;
	actor.th_die = raind_die;

    return true;
}
#endif
