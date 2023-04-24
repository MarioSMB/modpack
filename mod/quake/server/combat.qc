#include "combat.qh"

#include "monsters/ai.qh"
#include "rogue/runes.qh"
#include "rogue/teamplay.qh"
#include "triggers/triggers.qh"

bool IsExplosionDamage;

//============================================================================


/*
=============
VM_SV_aim

Pick a vector for the player to shoot along
vector aim(entity, missilespeed)
=============
*/
vector qc_aim(entity this, float missilespeed)
{
	// assume failure if it returns early
	return = v_forward;
	// if sv_aim is so high it can't possibly accept anything, skip out early
	if (autocvar_sv_aim >= 1)
		return;

	if(!this || wasfreed(this))
		return; // can not use free/world entity

	//speed = PRVM_G_FLOAT(OFS_PARM1);

	vector start = this.origin;
	start.z += 20;

	// try sending a trace straight
	vector dir = v_forward;
	vector end = start + 2048 * dir;

	traceline(start, end, MOVE_NORMAL, this);

	if(trace_ent && trace_ent.takedamage == DAMAGE_AIM && (!teamplay || this.team <= 0 || this.team != trace_ent.team))
	{
		return v_forward;
	}

	// try all possible entities
	vector bestdir = dir;
	float dist;
	float bestdist = autocvar_sv_aim;
	entity bestent = NULL;

	FOREACH_ENTITY_FLOAT(takedamage, DAMAGE_AIM,
	{
		if(it == this)
			continue;
		if(teamplay && this.team > 0 && this.team == it.team)
			continue; // don't aim at teammates
		end.x = it.origin.x + 0.5 * (it.mins.x + it.maxs.x);
		end.y = it.origin.y + 0.5 * (it.mins.y + it.maxs.y);
		end.z = it.origin.z + 0.5 * (it.mins.z + it.maxs.z);
		dir = normalize(end - start);
		dist = (dir * v_forward);
		if(dist < bestdist)
			continue; // too far to turn
		traceline(start, end, MOVE_NORMAL, this);
		if(trace_ent == it)
		{
			// can shoot at this one
			bestdist = dist;
			bestent = it;
		}
	});

	if(bestent)
	{
		dir = bestent.origin - this.origin;
		dist = (dir * v_forward);
		end = v_forward * dist;
		end.z = dir.z;
		end = normalize(end);
		return end;
	}
	else
	{
		return bestdir;
	}
}

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
void Killed(entity targ, entity inflictor, entity attacker)
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
			targ.th_die(targ, inflictor, attacker);
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

	if(MP_IMPEL && inflictor.classname == "impaler")
		impale(targ);
	else if(targ.th_die)
		targ.th_die(targ, inflictor, attacker);
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
void T_Damage(entity targ, entity inflictor, entity attacker, float damage)
{
	float r = random();
	bool showpain = true;
	if(!targ.takedamage)
		return;

	if(MP_HIPNOTIC && discharged && targ.wetsuit_finished)
		return;
	if(MP_ROGUE && targ.classname == "trigger_explosion" && !IsExplosionDamage)
		return;
	IsExplosionDamage = false;

	if(MP_ROGUE && (targ.powerups & POWERUP_SHIELD))
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
		if ((targ.powerups & POWERUP_EMPATHY_SHIELDS) && !(inflictor.powerups & POWERUP_EMPATHY_SHIELDS) && (targ != attacker))
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
		if(targ.powerups & POWERUP_EMPATHY_SHIELDS)
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
	if(MP_IMPEL && targ.field_generator_finished > time
		&& inflictor.classname != "grenade" && inflictor.classname != "missile" && inflictor.classname != "juggy_rocket" && inflictor.classname != "explo_box"
		&& !(!inflictor && targ.watertype == CONTENT_WATER) && !(!inflictor && targ.jump_flag < -650))
	{
		if(r < 0.3)
			_sound(targ, CHAN_ITEM, "weapons/field/genhit1.wav", 1, ATTN_NORM);
		else if (r < 0.6)
			_sound(targ, CHAN_ITEM, "weapons/field/genhit2.wav", 1, ATTN_NORM);
		else
			_sound(targ, CHAN_ITEM, "weapons/field/genhit3.wav", 1, ATTN_NORM);
		targ.field_generator_health = targ.field_generator_health - take;
		showpain = false;
		take = 0;
		targ.effects |= EF_BRIGHTFIELD;
		if(targ.field_generator_health < 0)
		{
			take = 0 - targ.field_generator_health;
			showpain = true;
		}
	}

	targ.health = targ.health - take;
	targ.armorvalue = targ.armorvalue - save;

	if(save >= targ.armorvalue)
	{
		save = targ.armorvalue;
		targ.armortype = 0;	// lost all armor
		targ.items &= ~(IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3);
	}
			
	if(targ.health <= 0)
	{
		Killed(targ, inflictor, attacker);
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

	if(targ.th_pain && (!MP_IMPEL || showpain))
	{
		targ.th_pain(targ, attacker, take);
	// nightmare mode monsters don't go into pain frames often
		if(autocvar_skill == 3)
			targ.pain_finished = time + 5;		
	}
}

/*
============
T_RadiusDamage
============
*/
bool inside_radius = false;
void T_RadiusDamage(entity inflictor, entity attacker, float damage, entity ignore)
{
	if(MP_IMPEL && inside_radius)
	{
		error("T_RadiusDamage: recursive");
		return;
	}
	inside_radius = true;

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
				if(head == attacker || head.classname == "monster_shambler" || head.classname == "monster_legond")
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
	inside_radius = false;
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
