#include "ai_ammoresist.qh"

PRECACHE(AmmoResist)
{
	precache_sound("weapons/resist_rocket.wav");
	precache_sound("weapons/plasma_hit.wav");
}

float Resist_Damage(entity targ, int resist_type, float damage)
{
	float ret_damage = damage;
	
	if(resist_type == IT_SHELLS) ret_damage = damage * (1 - targ.resist_shells);
	else if(resist_type == IT_NAILS) ret_damage = damage * (1 - targ.resist_nails);
	else if(resist_type == IT_ROCKETS) ret_damage = damage * (1 - targ.resist_rockets);
	else if(resist_type == IT_CELLS) ret_damage = damage * (1 - targ.resist_cells);

	return ret_damage;
}

//----------------------------------------------------------------------
// Double check that all ammo resistance are within range
//----------------------------------------------------------------------
void Resist_CheckRange(entity targ)
{
	// Check Ammo resistance is within range
	if(targ.resist_shells < -1) targ.resist_shells = -1;
	else if(targ.resist_shells > 1) targ.resist_shells = 1;
	if(targ.resist_nails < -1) targ.resist_nails = -1;
	else if(targ.resist_nails > 1) targ.resist_nails = 1;
	if(targ.resist_rockets < -1) targ.resist_rockets = -1;
	else if(targ.resist_rockets > 1) targ.resist_rockets = 1;
	if(targ.resist_cells < -1) targ.resist_cells = -1;
	else if(targ.resist_cells > 1) targ.resist_cells = 1;
}

//----------------------------------------------------------------------
// Save current ammo resistance to ammo variables
// ** Ammo variables are used for backpack, use with caution
//----------------------------------------------------------------------
void Resist_Save(entity targ)
{
	// Store the ammo resistance for switching later
	targ.save_resist_shells = targ.resist_shells;
	targ.save_resist_nails = targ.resist_nails;
	targ.save_resist_rockets = targ.resist_rockets;
	targ.save_resist_cells = targ.resist_cells;
}

//----------------------------------------------------------------------
// Switch resistance from FULL to monster default
// This works with Resist_Save system, use with caution
// Designed for bosses which don't drop things on death
//----------------------------------------------------------------------
void Resist_ChangeType(entity targ, bool artype)
{
	if(artype)
	{
		// Complete resistance to everything
		targ.resist_shells = targ.resist_nails = 1;
		targ.resist_rockets = targ.resist_cells = 1;
		targ.pain_finished = 99999;
	}
	else
	{
		// Default ammo resist, rocket/cell immunnity
		targ.resist_shells = targ.save_resist_shells;
		targ.resist_nails = targ.save_resist_nails;
		targ.resist_rockets = targ.save_resist_rockets;
		targ.resist_cells = targ.save_resist_cells;
		targ.pain_finished = time + 1;
	}
}

void Resist_Axe(entity targ, vector org)
{
	// Default impact sound - stone
	_sound(targ, CH_WEAPON_SINGLE, "player/axhit2.wav", 1, ATTN_NORM);
	// Particle impact
	if(random() < 0.5)
		te_spike(org);
	else
		te_gunshot(org);
	// Random chance of smoke/dust projectile
	if(random() < 0.5)
		SpawnProjectileSmoke(org, 200, 50, 150);
}

void Resist_Shells(entity targ, vector org, vector vel, float damage)
{
	if(targ.health > 0 && targ.pain_finished < time)
	{
		targ.pain_finished = time + 0.3 + random();
		// All monsters should have a pain sound define, hence no check
		//_sound(targ, CH_VOICE, targ.pain_sound, 1, ATTN_NORM);
	}
	
	// Drastically reduce blood particles
	if(targ.resist_shells < 1)
		SpawnBlood(org, vel*0.2, rint(4*targ.resist_shells), targ);
	if(random() < 0.3)
	{
		if(random() < 0.5)
			te_spike(org);
		else
			te_gunshot(org);
		if(random() < 0.5)
			SpawnProjectileSmoke(org, 200, 50, 150);
	}
}

void Resist_Nails(entity targ, vector org)
{
	if(targ.health > 0 && targ.pain_finished < time && targ.resist_nails < 1)
	{
		targ.pain_finished = time + 0.3 + random();
		// All monsters should have a pain sound define, hence no check
		//_sound(targ, CH_VOICE, targ.pain_sound, 1, ATTN_NORM);
	}	
	if(random() < 0.5)
		te_spike(org);
	else
		te_gunshot(org);
	if(random() < 0.5)
		SpawnProjectileSmoke(org, 200, 50, 150);
}

void Resist_Rockets(entity targ, vector org)
{
	if(targ.health > 0 && targ.pain_finished < time && targ.resist_rockets < 1)
	{
		targ.pain_finished = time + 0.3 + random();
		// All monsters should have a pain sound define, hence no check
		//_sound(targ, CH_VOICE, targ.pain_sound, 1, ATTN_NORM);
	}
	SpawnExplosion(EXPLODE_BURST_SMOKE,org,"weapons/resist_rocket.wav");
	SpawnProjectileSmoke(org, 200, 50, 150);
	SpawnProjectileSmoke(org, 200, 50, 250);
	SpawnProjectileSmoke(org, 300, 50, 150);
	// Can the target bleed?
	if(targ.resist_rockets < 1)
	{
		SpawnProjectileMeat(targ, org, 200, 50, 150);
		SpawnProjectileMeat(targ, org, 300, 50, 150);
	}
}

void Resist_Lightning(entity targ, vector org)
{
	if(targ.health > 0 && targ.pain_finished < time && targ.resist_cells < 1)
	{
		targ.pain_finished = time + 0.3 + random();
		// All monsters should have a pain sound define, hence no check
		//_sound(targ, CH_VOICE, targ.pain_sound, 1, ATTN_NORM);
	}	
	// Don't spawn smoke constantly (let the sprite finish)
	if(targ.lightning_timer < time)
	{
		targ.lightning_timer = time + 0.3;
		SpawnExplosion(EXPLODE_BURST_SMOKE, org, "");
	}
	// Spawn a random smoke particle and chance of blood
	SpawnProjectileSmoke(org, 200, 50, 150);
	if(targ.resist_cells < 1 && random() < 0.4) 
		SpawnProjectileMeat(targ, org, 200, 50, 150);
}

void Resist_Plasma(entity targ, vector org)
{
	if(targ.health > 0 && targ.pain_finished < time && targ.resist_cells < 1)
	{
		targ.pain_finished = time + 0.3 + random();
		// All monsters should have a pain sound define, hence no check
		//_sound(targ, CH_VOICE, targ.pain_sound, 1, ATTN_NORM);
	}	
	SpawnExplosion(EXPLODE_BURST_SMOKE, org, "weapons/plasma_hit.wav");
	SpawnProjectileSmoke(org, 200, 50, 150);
	SpawnProjectileSmoke(org, 200, 50, 250);
	SpawnProjectileSmoke(org, 300, 50, 150);
	// Can the target bleed?
	if(targ.resist_cells < 1 && random() < 0.3) 
		SpawnProjectileMeat(targ,org, 200, 50, 150);
}
