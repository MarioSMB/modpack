void ClientObituary(entity targ, entity attacker);

void T_RadiusDamage(entity inflictor, entity attacker, float damage, entity ignore, string dtype);
/*SERVER
void monster_death_use(entity this);
*/

entity damage_inflictor;
float rj = 1;

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
// bmodels need special checking because their origin is 0,0,0
	if(targ.movetype == MOVETYPE_PUSH)
	{
		traceline(inflictor.origin, 0.5 *(targ.absmin + targ.absmax), true, targ);
		if(trace_fraction == 1)
			return true;
		if(trace_ent == targ)
			return true;
		return false;
	}
	
	traceline(inflictor.origin, targ.origin, true, targ);
	if(trace_fraction == 1)
		return true;
	traceline(inflictor.origin, targ.origin + '15 15 0', true, targ);
	if(trace_fraction == 1)
		return true;
	traceline(inflictor.origin, targ.origin + '-15 -15 0', true, targ);
	if(trace_fraction == 1)
		return true;
	traceline(inflictor.origin, targ.origin + '-15 15 0', true, targ);
	if(trace_fraction == 1)
		return true;
	traceline(inflictor.origin, targ.origin + '15 -15 0', true, targ);
	if(trace_fraction == 1)
		return true;

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
		targ.health = -99;		// don't let sbar look bad if a player

	if(targ.movetype == MOVETYPE_PUSH || targ.movetype == MOVETYPE_NONE)
	{	// doors, triggers, etc
		targ.th_die(targ, attacker);
		return;
	}

	targ.enemy = attacker;

// bump the monster counter
	if(IS_MONSTER(targ))
	{
		killed_monsters = killed_monsters + 1;
		WriteByte(MSG_ALL, SVC_KILLEDMONSTER);
	}

	ClientObituary(targ, attacker);
	
	targ.takedamage = DAMAGE_NO;
	settouch(targ, func_null);
	targ.effects = 0;

/*SERVER
	monster_death_use(targ);
*/
	targ.th_die(targ, attacker);
}


/*
============
T_Damage

The damage is coming from inflictor, but get mad at attacker
This should be the only function that ever reduces health.
============
*/
void T_Damage(entity targ, entity inflictor, entity attacker, float damage)
{
	if(!targ.takedamage)
		return;

// check for quad damage powerup on the attacker
	if(attacker.super_damage_finished > time && inflictor.classname != "door")
	if(deathmatch == 4)
		damage = damage * 8;
	else
		damage = damage * 4;

// save damage based on the target's armor level

	float save = ceil(targ.armortype*damage);
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

	damage_inflictor = inflictor;

// figure momentum add
	if((inflictor != NULL) &&(targ.movetype == MOVETYPE_WALK) )
	{
		vector dir = targ.origin -(inflictor.absmin + inflictor.absmax) * 0.5;
		dir = normalize(dir);
		// Set kickback for smaller weapons
//Zoid -- use normal NQ kickback
//		// Read: only if it's not yourself doing the damage
//		if ( (damage < 60) & (IS_PLAYER(attacker) & IS_PLAYER(targ)) & ( attacker.netname != targ.netname)) 
//			targ.velocity = targ.velocity + dir * damage * 11;
//		else                        
		// Otherwise, these rules apply to rockets and grenades                        
		// for blast velocity
			targ.velocity = targ.velocity + dir * damage * 8;
		
		// Rocket Jump modifiers
		if ( (rj > 1) & (IS_PLAYER(attacker) & IS_PLAYER(targ)) & ( attacker.netname == targ.netname)) 
			targ.velocity = targ.velocity + dir * damage * rj;
	}

// check for godmode or invincibility
	if(targ.flags & FL_GODMODE)
		return;
	if(targ.invincible_finished >= time)
	{
		if(targ.invincible_sound < time)
		{
			_sound(targ, CHAN_ITEM, "items/protect3.wav", 1, ATTN_NORM);
			targ.invincible_sound = time + 2;
		}
		return;
	}

// team play damage avoidance
//ZOID 12-13-96: self.team doesn't work in QW.  Use keys
	if ((teamplay == 1) && (targ.team == attacker.team) &&
		IS_PLAYER(attacker) && (attacker.team) &&
		inflictor.classname !="door")
		return;

	if ((teamplay == 3) && (targ.team == attacker.team) &&
		IS_PLAYER(attacker) && (attacker.team) &&
		(targ != attacker)&& inflictor.classname !="door")
		return;
		
// do the damage
	targ.health = targ.health - take;
			
	if(targ.health <= 0)
	{
		Killed(targ, attacker);
		return;
	}

// react to the damage
/*SERVER
	if(IS_MONSTER(targ) && attacker != NULL)
	{
	// get mad unless of the same class(except for soldiers)
		if(targ != attacker && attacker != targ.enemy)
		{
			if((targ.classname != attacker.classname) 
			||(targ.classname == "monster_army" ) )
			{
				if(IS_PLAYER(targ.enemy))
					targ.oldenemy = targ.enemy;
				targ.enemy = attacker;
				FoundTarget(targ);
			}
		}
	}
*/

	if(targ.th_pain)
		targ.th_pain(targ, attacker, take);	
}

/*
============
T_RadiusDamage
============
*/
void T_RadiusDamage(entity inflictor, entity attacker, float damage, entity ignore, string dtype)
{
	entity head = findradius(inflictor.origin, damage+40);
	
	while(head)
	{
		if(head != ignore)
		{
			if(head.takedamage)
			{
				vector org = head.origin +(head.mins + head.maxs)*0.5;
				float points = 0.5*vlen(inflictor.origin - org);
				if(points < 0)
					points = 0;
				points = damage - points;
				if(head == attacker)
					points = points * 0.5;
				if(points > 0)
				{
					if(CanDamage(head, inflictor))
					{
						head.deathtype = dtype;
						T_Damage(head, inflictor, attacker, points);
					}
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
	entity head = findradius(attacker.origin, damage+40);
	
	while(head)
	{
		if(head.takedamage)
		{
			float points = 0.5*vlen(attacker.origin - head.origin);
			if(points < 0)
				points = 0;
			points = damage - points;
			if(head == attacker)
				points = points * 0.5;
			if(points > 0)
			{
				if(CanDamage(head, attacker))
					T_Damage(head, attacker, attacker, points);
			}
		}
		head = head.chain;
	}
}

