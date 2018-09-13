#include "rogue/runes.qh"

bool IsExplosionDamage;

void ClientObituary(entity targ, entity attacker);

void FoundTarget(entity this);

//============================================================================

/*
============
CanDamage

Returns true if the inflictor can directly damage the target.  Used for
explosions and melee attacks.
============
*/
bool CanDamage(entity targ, entity inflictor)
{
	if(targ.takedamage == DAMAGE_NO)
		return false;

// bmodels need special checking because their origin is 0,0,0
	if(targ.move_movetype == MOVETYPE_PUSH)
	{
		traceline(inflictor.origin, 0.5 * (targ.absmin + targ.absmax), MOVE_NOMONSTERS, inflictor);
		if(trace_fraction == 1 || trace_ent == targ)
			return true;
		return false;
	}
	
	traceline(inflictor.origin, targ.origin, MOVE_NOMONSTERS, inflictor);
	if(trace_fraction == 1)
		return true;
#if 0
	traceline(inflictor.origin, targ.origin + '15 15 0', MOVE_NOMONSTERS, inflictor);
	if(trace_fraction == 1)
		return true;
	traceline(inflictor.origin, targ.origin + '-15 -15 0', MOVE_NOMONSTERS, inflictor);
	if(trace_fraction == 1)
		return true;
	traceline(inflictor.origin, targ.origin + '-15 15 0', MOVE_NOMONSTERS, inflictor);
	if(trace_fraction == 1)
		return true;
	traceline(inflictor.origin, targ.origin + '15 -15 0', MOVE_NOMONSTERS, inflictor);
	if(trace_fraction == 1)
		return true;
#else
	tracebox(inflictor.origin, '-15 -15 0', '15 15 0', targ.origin, MOVE_NOMONSTERS, inflictor);
	if(trace_fraction == 1)
		return true;
#endif

	return false;
}


/*
============
Killed
============
*/
void Killed(entity targ, entity attacker)
{
	if(targ.health < -99)
		targ.health = -99; // don't let sbar look bad if a player

	if(MP_HIPNOTIC)
	{
		if(targ.charmed)
			targ.effects &= ~EF_DIMLIGHT;
		targ.effects &= ~EF_BRIGHTFIELD;
	}

	if(targ.move_movetype == MOVETYPE_PUSH || targ.move_movetype == MOVETYPE_NONE)
	{	// doors, triggers, etc
		if(targ.th_die)
			targ.th_die(targ, attacker);
		return;
	}

	if(targ.damagedbycontents)
		IL_REMOVE(g_damagedbycontents, targ);
	targ.damagedbycontents = false;

	targ.enemy = attacker;

// bump the monster counter
	if(IS_MONSTER(targ))
		monsters_killed += 1;

	if(MP_ROGUE)
	if(attacker.classname == "buzzsaw" || attacker.classname == "Vengeance" || attacker.classname == "pendulum")
		targ.health = -99;

	if(MP_ROGUE)
		targ.gravity = 1.0;

	targ.takedamage = DAMAGE_NO;
	settouch(targ, func_null);

	// fall to ground
	targ.flags &= ~FL_FLY;
	targ.flags &= ~FL_SWIM;

	if(targ.target && targ.target != "")
		SUB_UseTargets(targ, attacker, NULL); // using attacker here probably negates the need for .enemy to be set, but oh well

	if(targ.th_die)
		targ.th_die(targ, attacker);
}

// ====
// Function prototype for shield impact handler.
// ====
float shield_hit(entity targ, entity inflictor, entity attacker, float damage);


/*
============
T_Damage

The damage is coming from inflictor, but get mad at attacker
This should be the only function that ever reduces health.
============
*/
bool empathyused; // hipnotic
bool TeamArmorDam(entity targ, entity inflictor, entity attacker, float damage); // also rogue
bool TeamHealthDam(entity targ, entity inflictor, entity attacker, float damage);
void T_Damage(entity targ, entity inflictor, entity attacker, float damage)
{
	if(!targ.takedamage)
		return;

	if(MP_HIPNOTIC && discharged && targ.wetsuit_finished)
		return;
	if(MP_ROGUE && targ.classname == "trigger_explosion" && !IsExplosionDamage)
		return;
	IsExplosionDamage = false;

	if(MP_ROGUE && (targ.items & IT_SHIELD))
	{
		// allow some damage to pass through
		damage = shield_hit(targ, inflictor, attacker, damage);
		if(damage == 0)
			return;
	}

// check for quad damage powerup on the attacker
	if(attacker.super_damage_finished > time)
		damage = damage * 4;

	if(MP_HIPNOTIC)
	{
		if ((targ.items & IT_EMPATHY_SHIELDS) && !(inflictor.items & IT_EMPATHY_SHIELDS) && (targ != attacker))
		{
			empathyused = true;
			damage = damage/2;
			T_Damage (attacker,targ,targ,damage);
			empathyused = false;
		}
	}

	damage_inflictor = inflictor; // hipnotic

	if(MP_ROGUE && deathmatch)
		damage = RuneApplyBlack(damage, attacker);

// save damage based on the target's armor level

	float save = ceil(targ.armortype * damage);
	if(MP_ROGUE && !TeamArmorDam(targ, inflictor, attacker, damage))
		save = 0;

	if(save >= targ.armorvalue)
	{
		save = targ.armorvalue;
		targ.armortype = 0;	// lost all armor
		targ.items &= ~(IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3);
	}
	
	targ.armorvalue = targ.armorvalue - save;
	float take = ceil(damage-save);

// add to the damage total for clients, which will be sent as a single
// message at the end of the frame
// FIXME: remove after combining shotgun blasts?
	if(IS_CLIENT(targ))
	{
		targ.dmg_take = targ.dmg_take + take;
		targ.dmg_save = targ.dmg_save + save;
		targ.dmg_inflictor = inflictor;
	}

// figure momentum add
	if((inflictor != NULL) &&(targ.move_movetype == MOVETYPE_WALK) )
	{
		vector dir = targ.origin -(inflictor.absmin + inflictor.absmax) * 0.5;
		dir = normalize(dir);
		targ.velocity = targ.velocity + dir*damage*8;
	}

// check for godmode or invincibility
	if(targ.flags & FL_GODMODE)
		return;
	if(targ.invincible_finished >= time)
	{
		if(targ.invincible_sound < time)
		{
			_sound(targ, CH_TRIGGER_SINGLE, "items/protect3.wav", 1, ATTN_NORM);
			targ.invincible_sound = time + 2;
		}
		return;
	}

	if(MP_HIPNOTIC)
	{
		if(targ.items & IT_EMPATHY_SHIELDS)
		{
			if(targ.empathy_sound < time)
			{
				_sound(targ, CH_TRIGGER_SINGLE, "hipitems/empathy2.wav", 1, ATTN_NORM);
				targ.empathy_sound = time + 0.5;
			}
		}
	}

// team play damage avoidance
	if((teamplay == 1) &&(targ.team > 0)&&(targ.team == attacker.team) )
		return;

	if(MP_ROGUE && !TeamHealthDam(targ, inflictor, attacker, damage))
		return; // same team

	if(MP_ROGUE && deathmatch)
		take = RuneApplyEarth(take, targ);

// coop damage avoidance (if enabled)
	if(coop && attacker != targ && IS_CLIENT(attacker) && IS_CLIENT(targ))
	{
		if(autocvar_g_friendlyfire_virtual)
			return;
		take *= autocvar_g_friendlyfire;
	}
		
// do the damage
	targ.health = targ.health - take;
			
	if(targ.health <= 0)
	{
		Killed(targ, attacker);
		return;
	}

// react to the damage

	if(IS_MONSTER(targ) && attacker != NULL)
	{
	// get mad unless of the same class(except for soldiers)
		if(targ != attacker && attacker != targ.enemy && targ.charmer != attacker)
		{
			if(targ.classname != attacker.classname || targ.classname == "monster_army" || targ.classname == "monster_armagon")
			{
				if(targ.classname != "monster_dragon")
				{
					if(IS_PLAYER(targ.enemy))
						targ.oldenemy = targ.enemy;
					targ.enemy = attacker;
					FoundTarget(targ);
				}
			}
		}
	}

	if(targ.th_pain)
	{
		targ.th_pain(targ, attacker, take);
	// nightmare mode monsters don't go into pain frames often
		if(skill == 3)
			targ.pain_finished = time + 5;		
	}
}

/*
============
T_RadiusDamage
============
*/
void T_RadiusDamage(entity inflictor, entity attacker, float damage, entity ignore)
{
	entity head = findradius(inflictor.origin, damage + 40);
	
	while(head)
	{
		if(head != ignore)
		{
			if(head.takedamage)
			{
				vector org = head.origin +(head.mins + head.maxs) * 0.5;
				float points = max(0, 0.5 * vlen(inflictor.origin - org));
				points = damage - points;
				if(head == attacker || head.classname == "monster_shambler")
					points *= 0.5; // shambler takes half damage from all explosions
				if(points > 0)
				{
					if(CanDamage(head, inflictor))
						T_Damage(head, inflictor, attacker, points);
				}
			}
		}
		head = head.chain;
	}
}

/*
============
T_BeamDamage
============
*/
void T_BeamDamage(entity attacker, float damage)
{
	entity head = findradius(attacker.origin, damage + 40);
	IsExplosionDamage = true;
	
	while(head)
	{
		if(head.takedamage)
		{
			float points = max(0, 0.5 * vlen(attacker.origin - head.origin));
			points = damage - points;
			if(head == attacker || head.classname == "monster_shambler")
				points *= 0.5;
			if(points > 0)
			{
				if(CanDamage(head, attacker))
					T_Damage(head, attacker, attacker, points);
			}
		}
		head = head.chain;
	}
}
