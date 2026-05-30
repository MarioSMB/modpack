#include "combat.qh"

#include "horde.qh"
#include "monsters/ai.qh"
#include "monsters/ai_minions.qh"
#include "monsters/ai_subs.qh"
#include "monsters/monsters.qh"
#include "rogue/sphere.qh"
#include "vote.qh"
#include "../common/td/sv_td.qh"
#include "../common/jumpsdonewell/_mod.qh"
#include "../common/triggers/func/breakable.qh"
#include "../common/triggers/triggers.qh"
#include "weapons/weaponsystem.qh"

bool IsExplosionDamage;

// Yoder Sept24 2021 Horde Merge
void horde_spawn_powerup(entity this, entity attacker);

int autocvar__playerscale_testing; // internal setting for testing purposes
void playerscale_StartFrame()
{
	if(!autocvar_sv_quake_playerscaling || gametype == GAMETYPE_HORDE)
	{
		player_scale = 1;
		return;
	}

	int playercount = 0;
	FOREACH_CLIENT(IS_PLAYER(it),
	{
		playercount += 1;
	});

	if(autocvar__playerscale_testing > 0)
		playercount = autocvar__playerscale_testing;

	if(!playercount)
		playercount = 1; // avoid div0
	if(gametype == GAMETYPE_TD)
		playercount *= 2; // tower defence acts as double player count

	float difficulty = (0.5 + autocvar_skill * ((1.2 - 0.3) / (2 / playercount)));

	player_scale = bound(1, difficulty, PLAYER_SCALE_MAX);
}

//============================================================================

void DelayedExplosionThink(entity this)
{
	float damage = bound(20, this.max_health * 0.7, 100);
	T_RadiusDamage(this, this.enemy, damage, DEATH_EXPLODE.m_id, this.owner);

	// Allow for sound to finish and just remove
	setthink(this, SUB_Remove);
	this.nextthink = time + 4;

	// Play any explosion sounds on temporary entity
	Send_Effect(EFFECT_EXPLOSION, this.origin, '0 0 0', 1);
	_sound(this, CH_WEAPON_SINGLE, "weapons/resist_rocket.wav", 1, ATTN_NORM);
}

void explosion_delayed(entity targ, entity attacker)
{
	entity t = new_pure(DelayedExplosion);
	t.nextthink = time;
	setthink(t, DelayedExplosionThink);
	t.enemy = attacker;
	t.owner = targ;
	t.max_health = targ.max_health;
	t.solid = SOLID_NOT;
	set_movetype(t, MOVETYPE_NONE);
	setsize(t, '0 0 0', '0 0 0');
	setorigin(t, targ.origin);
}

void DelayedElectrifyThink(entity this)
{
	setthink(this, SUB_Remove);
	this.nextthink = time;

	int hitcount = 0;
	FOREACH_ENTITY_RADIUS(this.origin, 200, it != this.owner && it != this.enemy,
	{
		if(it.health <= 0 || !it.takedamage || !Damage_ValidTarget(it, this.enemy))
			continue;
		SendCSQCLightningBeam(this.origin, it.origin);
		T_Damage(it, this.enemy, this.enemy, 40, DEATH_DISCHARGE.m_id);
		hitcount += 1;
	});

	Send_Effect(EFFECT_ELECTRIFY, this.origin, '0 0 0', 1);
}

void electrify_delayed(entity targ, entity attacker)
{
	entity t = new_pure(DelayedElectrify);
	t.nextthink = time;
	setthink(t, DelayedElectrifyThink);
	t.enemy = attacker;
	t.owner = targ;
	t.solid = SOLID_NOT;
	set_movetype(t, MOVETYPE_NONE);
	setsize(t, '0 0 0', '0 0 0');
	setorigin(t, targ.origin);
}

/*
=============
VM_SV_aim

Pick a vector for the player to shoot along
vector aim(entity, missilespeed)
=============
*/
vector qc_aim_fromorg(entity this, vector org, float missilespeed)
{
	// assume failure if it returns early
	return = v_forward;
	if(!IS_PLAYER(this) || W_DualWielding(this))
		return;

	// if sv_aim is so high it can't possibly accept anything, skip out early
	if (autocvar_sv_aim >= 1)
	{
#if 1
		traceline(this.origin + this.view_ofs, this.origin + this.view_ofs + v_forward * missilespeed, MOVE_NOMONSTERS, this);
		vector w_shotend = trace_endpos;
		vector w_shotorg = org;
		return normalize(w_shotend - w_shotorg);
#else
		return;
#endif
	}

	if(!this || wasfreed(this))
		return; // can not use free/world entity

	//speed = PRVM_G_FLOAT(OFS_PARM1);

	vector start = this.origin;
	start.z += 20;

	// try sending a trace straight
	vector dir = v_forward;
	vector end = start + 2048 * dir;

	traceline(start, end, MOVE_NORMAL, this);

	if(trace_ent && trace_ent.takedamage == DAMAGE_AIM)
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

vector qc_aim(entity this, float missilespeed)
{
	return qc_aim_fromorg(this, W_Shotorg(this, weaponentities[0]), missilespeed);
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

	vector inflictor_org = (inflictor.absmin + inflictor.absmax) * 0.5;
	vector targ_org = (targ.absmin + targ.absmax) * 0.5;

// bmodels need special checking because their origin is 0,0,0
	if(targ.move_movetype == MOVETYPE_PUSH)
	{
		traceline(inflictor_org, targ_org, MOVE_NOMONSTERS, inflictor);
		if(trace_fraction == 1 || trace_ent == targ)
			return true;
		return false;
	}
	
	traceline(inflictor_org, targ_org, MOVE_NOMONSTERS, inflictor);
	if(trace_fraction == 1)
		return true;
#if 1
	traceline(inflictor_org, targ_org + '15 15 0', MOVE_NOMONSTERS, inflictor);
	if(trace_fraction == 1)
		return true;
	traceline(inflictor_org, targ_org + '-15 -15 0', MOVE_NOMONSTERS, inflictor);
	if(trace_fraction == 1)
		return true;
	traceline(inflictor_org, targ_org + '-15 15 0', MOVE_NOMONSTERS, inflictor);
	if(trace_fraction == 1)
		return true;
	traceline(inflictor_org, targ_org + '15 -15 0', MOVE_NOMONSTERS, inflictor);
	if(trace_fraction == 1)
		return true;
#else
	tracebox(inflictor_org, '-15 -15 0', '15 15 0', targ_org, MOVE_NOMONSTERS, inflictor);
	if(trace_fraction == 1)
		return true;
#endif

	return false;
}

// checks if a target is a player in PvP or a monster that isn't charmed
// NOTE: accepts an attacker rather than an inflictor, check .owner if a projectile!
bool Damage_ValidTarget(entity targ, entity attacker)
{
	if(targ.classname == "monster_hitbox")
		targ = targ.realowner;
	if(attacker.classname == "monster_hitbox")
		attacker = attacker.realowner;

	// may happen if a projectile lacks an owner, just assume it's valid
	// also never check self-damage here!
	if(!attacker || targ == attacker)
		return true;
	// no PvP thank you very much
	if(coop && IS_PLAYER(targ) && IS_PLAYER(attacker) && gametype != GAMETYPE_DODGEBALL)
		return false;
	// no turret damage to players ever!
	if(gametype == GAMETYPE_TD && IS_PLAYER(targ) && IS_TURRET(attacker))
		return false;
	if(gametype == GAMETYPE_TD && IS_PLAYER(attacker) && IS_TURRET(targ))
		return false;
	// decoys are never valid targets
	if(targ.monsterdef && (targ.monsterdef.spawnflags & MONSTER_TYPE_DECOY))
		return false;
	// in the event of our owner being lost, just treat the target as braindead
	if(targ.charmed && !targ.charmer)
		return false;

	// first verify the target
	if(IS_MONSTER(targ) && targ.charmed)
	{
		// can't hurt our pets
		if(targ.charmer == attacker || targ.charmer == attacker.charmer)
			return false;
		// no friendly fire!
		if(coop && IS_PLAYER(targ.charmer))
			return false;

		// otherwise monsters are not friends even if charmed
		return true;
	}

	// next validate the attacker
	if(IS_MONSTER(attacker) && attacker.charmed)
	{
		// master says no
		if(attacker.charmer == targ || attacker.charmer == targ.charmer)
			return false;
		// no hurt friends
		if(coop && IS_PLAYER(attacker.charmer) && (IS_PLAYER(targ) || IS_PLAYER(targ.charmer)))
			return false;

		// otherwise probably owned by an enemy!
		return true;
	}

	// NOTE: may be a dead target or not technically damageable, do safety checks!
	return true;
}

void HappyDeath(entity this)
{
	soundat(NULL, this.origin, CH_VOICE, SND(CHEER), 1, ATTEN_NORM);
	Send_Effect(EFFECT_CHEER, this.origin, '0 0 0', 1);
}

void ZappyDeath(entity this)
{
	setthink(this, gibhim);
	this.nextthink = time;
}

void SwallowThink(entity this)
{
	this.scale -= PHYS_INPUT_TIMELENGTH * 2;

	if(this.scale <= 0)
	{
		SUB_VanishOrRemove(this);
		return;
	}

	this.nextthink = time;
}

void Swallow(entity this)
{
	setthink(this, SwallowThink);
	this.nextthink = time;

	if(this.scale == 0)
		this.scale = 1;
}

void SimpleGib(entity this)
{
	soundat(NULL, this.origin, CH_VOICE, "player/udeath.wav", 1, ATTEN_NORM);
	Send_Effect(EFFECT_GIB, this.origin, '0 0 0', 1);
}

int Death_SpecialType(entity targ, entity inflictor, entity attacker, int deathtype)
{
	int killed_type = KILLED_NORMAL;

	if(inflictor.classname == "impaler")
	{
		if(IS_PLAYER(targ))
			killed_type = KILLED_IMPALED;
		else
			killed_type = KILLED_GIBBED;
	}
	else if(DEATH_ISWEAPON(deathtype, WEP_INVOKER))
		killed_type = KILLED_INVOKED;
	else if(DEATH_ISWEAPON(deathtype, WEP_LIGHTME) || DEATH_ISWEAPON(deathtype, WEP_LIGHTNING))
		killed_type = KILLED_ZAPPED;
	else if(targ.gibhealth != 0 && targ.health < targ.gibhealth)
		killed_type = KILLED_GIBBED;

	if(attacker.m_champion == CHAMPION_Doom)
		killed_type = KILLED_GIBBED; // force it!!
	else if(DEATH_IS(deathtype, DEATH_GOAT_BONK))
		killed_type = KILLED_HAPPY;

	// override all else
	if(DEATH_IS(deathtype, DEATH_SWALLOW))
		killed_type = KILLED_SWALLOWED;
	else if(inflictor.classname == "cauldron")
		killed_type = KILLED_GIBBED;

	if((gametype == GAMETYPE_TD || gametype == GAMETYPE_HORDE) && killed_type == KILLED_GIBBED)
		killed_type = KILLED_SIMPLEGIB;

	return killed_type;
}

void Death_SpecialHandle(entity targ, int killed_type)
{
	if(killed_type == KILLED_NORMAL)
		return; // not special TODO: warn about this? means the monster will linger!

	// set these first incase the other effects want to override them
	setthink(targ, SUB_VanishOrRemove);
	targ.nextthink = time;
	targ.solid = SOLID_NOT;
	targ.takedamage = DAMAGE_NO;
	settouch(targ, func_null);

	switch(killed_type)
	{
		default:
		case KILLED_GIBBED: break; // effect handled by entity
		case KILLED_INVOKED: FX_Invoked(targ); break;
		case KILLED_IMPALED: impale(targ); break;
		case KILLED_HAPPY: HappyDeath(targ); break;
		case KILLED_ZAPPED: ZappyDeath(targ); break;
		case KILLED_SWALLOWED: Swallow(targ); break;
		case KILLED_SIMPLEGIB: SimpleGib(targ); break;
	}
}

/*
============
Killed
============
*/
void Killed(entity targ, entity inflictor, entity attacker, int deathtype)
{
	if(IS_PLAYER(targ) && targ.health < -99)
		targ.health = -99; // don't let sbar look bad if a player

	if(IS_PLAYER(targ))
		WaypointSprite_PlayerDead(targ);

	if(IS_MONSTER(targ) && targ.sprite)
		WaypointSprite_Kill(targ.sprite);

	StatusEffects_removeall(targ, STATUSEFFECT_REMOVE_CLEAR);

	if(targ.charmed)
		targ.effects &= ~EF_DIMLIGHT;
	targ.effects &= ~EF_BRIGHTFIELD;

	if(!IS_MONSTER(targ) && (targ.move_movetype == MOVETYPE_PUSH || targ.move_movetype == MOVETYPE_NONE))
	{	// doors, triggers, etc
		if(targ.classname == "misc_explobox" || targ.classname == "misc_explobox2")
			targ.enemy = attacker;
		if(targ.th_die)
			targ.th_die(targ, inflictor, attacker, deathtype);
		return;
	}

	if(targ.damagedbycontents)
		IL_REMOVE(g_damagedbycontents, targ);
	targ.damagedbycontents = false;

	targ.enemy = attacker;

	champions_Killed(targ, inflictor, attacker, deathtype);

	vampglobe_Killed(targ, attacker);

	// TODO: better place for this
	if(inflictor.classname == "cauldron")
	{
		if(targ.monsterdef.spawnflags & MONSTER_TYPE_BOSS)
			inflictor.count += 10;
		else
			inflictor.count += 1;
	}

	// Yoder March04 2022, punish team killspree
	if(gametype == GAMETYPE_HORDE && IS_PLAYER(attacker) && IS_PLAYER(targ))
	{
		LOG_DEBUG("punish teamkill");
		attacker.killtime = 0;
		attacker.frags -= 2;
	}

// bump the monster counter
	if(IS_MONSTER(targ))
	{
		// Yoder Sept24, 2021 Horde Merge
		if(gametype == GAMETYPE_HORDE && !targ.charmed)
		{
			if(targ.monsterdef && !(targ.flags & FL_CLONE) && !(targ.monsterdef.spawnflags & MONSTER_TYPE_UNDEAD)) // zombies don't count
				monsters_killed += 1;
			
			// check kill spree
			if(IS_PLAYER(attacker))
			{
				attacker.killspree += 1;
				attacker.killtime = time + KILLSPREE_GAP;
				// disabling to reduce console spam from streaks
				// TODO: implement a HUD element for streaks!
#if 0	
				if(time < attacker.killtime)
				{
					if(attacker.killspree >= 14)
						sprint(attacker, sprintf("^2%d^7 kill streak!\n", attacker.killspree));
					else if(attacker.killspree == 13)
						sprint(attacker, "^113^7 kill streak!\n");
					else if(attacker.killspree == 12)
						sprint(attacker, "^112^7 kill streak!\n");
					else if(attacker.killspree == 11)
						sprint(attacker, "^111^7 kill streak!\n");
					else if(attacker.killspree == 10)
						sprint(attacker, "^110^7 kill streak!\n");
					else if(attacker.killspree == 9)
						sprint(attacker, "^19^7 kill streak!\n");
					else if(attacker.killspree == 8)
						sprint(attacker, "^18^7 kill streak!\n");
					else if(attacker.killspree == 7)
						sprint(attacker, "^17^7 kill streak!\n");
					else if(attacker.killspree == 6)
						sprint(attacker, "^16^7 kill streak!\n");
					else if(attacker.killspree == 5)
						sprint(attacker, "^15^7 kill streak!\n");
					else if(attacker.killspree == 4)
						sprint(attacker, "^34^7 kill streak!\n");
					else if(attacker.killspree == 3)
						sprint(attacker, "^33^7 kill streak!\n");
					else if(attacker.killspree == 2)
						sprint(attacker, "^32^7 kill streak!\n");
				}
#endif
				if(time < attacker.killtime && attacker.killspree >= 4)
					Send_Notification(MSG_CENTER, attacker, MSG_CENTER, CENTER_KILL_STREAK, attacker.killspree);
			}
			
			// check to see about spawning a powerup
			horde_spawn_powerup(targ, attacker);
		}
		else if(!(targ.flags & FL_CLONE) && !targ.charmed)
			monsters_killed += 1;
		if(targ.flags & FL_MINION)
			update_minioncount(targ.owner, -1);
		if(IS_PLAYER(attacker) && !(targ.flags & FL_CLONE) && !targ.charmed)
			attacker.frags += 1;
		if(gametype == GAMETYPE_HORDE && !targ.charmed)
			Horde_GiveScore(HORDE_TEAMSCORE_KILL);
		if(gametype == GAMETYPE_TD && !targ.charmed)
			td_MonsterDies(targ, attacker);

		if(STAT(PASSIVES, attacker) & PASSIVE_BOOMER)
			explosion_delayed(targ, attacker);

		if(STAT(PASSIVES, attacker) & PASSIVE_ELECTRIFYING)
			electrify_delayed(targ, attacker);

		// workaround for potential crashes due to lingering owner
		IL_EACH(g_moveables, it.owner == targ && IS_MONSTER(it) && (it.flags & FL_MINION),
		{
			it.owner = NULL;
		});
	}

	if(attacker.classname == "buzzsaw" || attacker.classname == "Vengeance" || attacker.classname == "pendulum")
		targ.health = -99;

	targ.gravity = 1.0;

	targ.takedamage = DAMAGE_NO;
	settouch(targ, func_null);
	targ.use = func_null;

	// fall to ground
	targ.flags &= ~FL_FLY;
	targ.flags &= ~FL_SWIM;

	if(IS_MONSTER(targ) && gametype == GAMETYPE_HORDE && !targ.charmed && !(targ.monsterdef.spawnflags & MONSTER_TYPE_UNDEAD))
		remote_wavecheck(targ);

	// TODO: reset target? not sure if this is needed!
	//string oldtarg = targ.target;
	if(targ.deathtarget && targ.deathtarget != "")
	{
		entity dtarg = find(NULL, targetname, targ.deathtarget);
		if(dtarg)
			targ.target = targ.deathtarget;
	}

	SUB_UseTargets(targ, attacker, NULL); // using attacker here probably negates the need for .enemy to be set, but oh well

	//targ.target = oldtarg;

	if(targ.th_die)
		targ.th_die(targ, inflictor, attacker, deathtype);

	targ.category = string_null;
}

// ====
// Function prototype for shield impact handler.
// ====
float shield_hit(entity targ, entity inflictor, entity attacker, float damage);

bool NoPushies(entity targ, entity attacker)
{
	return (coop && targ != attacker && IS_PLAYER(targ) && IS_PLAYER(attacker) && (autocvar_sv_quake_nopushing || targ.cvar_cl_quake_donotdisturb));
}


/*
============
T_Damage

The damage is coming from inflictor, but get mad at attacker
This should be the only function that ever reduces health.
============
*/
void SUB_UseTargets_Ex(entity this, entity actor, entity trigger, int skiptargets, bool nomessage);
void T_Damage(entity targ, entity inflictor, entity attacker, float damage, int deathtype)
{
	entity orig = targ;
	// special hack for ithagnal
	if(targ.classname == "monster_hitbox")
		targ = targ.owner;

	float r = random();
	bool showpain = true;
	float force = damage;
	float forcezscale = 1;
	if(!targ.takedamage)
		return;

	// ad disables this in favour of per-projectile handling
	// we however do NOT have per-projectile handling (YET)
	// TODO: needs projectile support!
	if(ai_immunebreakable(attacker, targ))
		return;

	if(gametype == GAMETYPE_TD)
	{
		// players might not have a keybind for it, so let them shoot the tower to start
		if(targ.classname == "td_tower" && IS_PLAYER(attacker) && td_phase == TD_PHASE_BUILD && !attacker.ready && !DEATH_IS(deathtype, DEATH_CRUSH))
		{
			bprintf("%s ^7is ready!\n", attacker.netname);
			Send_Notification(NOTIF_ALL_EXCEPT, attacker, MSG_CENTER, CENTER_READY, attacker.netname);
			attacker.ready = true;
			ReadyCount(NULL);
			return;
		}
		if(targ.classname == "td_tower" && (!IS_MONSTER(attacker) || (attacker.monsterdef.spawnflags & MONSTER_TYPE_BOSS) || (attacker.owner.monsterdef.spawnflags & MONSTER_TYPE_BOSS) || attacker.charmed))
			return;
		if(IS_TURRET(targ) && attacker && (!IS_MONSTER(attacker) || attacker.charmed))
			return;
		if(IS_TURRET(attacker) && (!IS_MONSTER(targ) || targ.charmed))
			return;
		if(IS_MONSTER(targ) && time < targ.invincible_finished)
			return;
	}

	if(gametype == GAMETYPE_JUMPSDONEWELL)
	{
		if(JDW_Damage(attacker, targ, damage))
			return;
	}

	// Yoder add, September 9 2020
	// bosses are immune to damage while frozen (mechanic)
	if(targ.is_frozen)
	{
		if(targ.monsterdef.spawnflags & MONSTER_TYPE_BOSS)
			return;
		showpain = false;
	}

	Weapon awep = DEATH_WEAPONOF(deathtype);
	if(awep.spawnflags & WEP_FLAG_MANA)
		deathtype |= HITTYPE_MAGIC;

	if(DEATH_ISWEAPON(deathtype, WEP_LOOSECANNON) && inflictor.owner == attacker)
		forcezscale *= 4;

	// multiplayer boss health scaling
	// similar to armor but handled separately so bosses can also have armor
	if(targ.monsterdef.spawnflags & MONSTER_TYPE_BOSS)
	{
		// NOTE: avoid reducing by 1.0 as that is invulnerability!
		float dmgcap = 0.8;
		float reduction = min((player_scale / PLAYER_SCALE_MAX), dmgcap);
		//LOG_INFO("Reducing damage by ", ftos(damage * reduction));
		damage -= (damage * reduction);
	}
	
	if(gametype == GAMETYPE_TD && td_ent && td_ent.wave > 0 && td_ent.scale > 0)
	{
		if(IS_MONSTER(attacker) && !(attacker.monsterdef.spawnflags & MONSTER_TYPE_BOSS) && !(attacker.owner.monsterdef.spawnflags & MONSTER_TYPE_BOSS))
		{
			// no cap... good luck
			// scale only by a small amount per wave or things will get impossible fast
			float myscale = td_ent.scale * 0.01;
			float increase = (1 + (myscale * (td_skill + 1)) * td_ent.wave);
			damage *= increase;
		}
	}

	// major hack to keep the high push force
	if(DEATH_IS(deathtype, DEATH_MONSTER_BREEZE))
		damage *= 0.05;

	if(attacker.armortype == ARMOR_MAGE && attacker.armorvalue > 0)
		damage *= 1.2;

	if(!Damage_ValidTarget(targ, attacker))
		damage = 0;

	if(discharged && StatusEffects_active(STATUSEFFECT_Wetsuit, targ))
		return;
	if(targ.classname == "trigger_explosion" && !IsExplosionDamage)
		return;
	if(targ.classname == "mushroom" && attacker == targ.realowner)
		return;
	if(targ.classname == "func_breakable" && !targ.bsporigin) // bsporigin as a hack to see if it's from AD
	{
		if((targ.spawnflags & BREAKABLE_NO_MONSTERS) && IS_MONSTER(attacker))
			return;
		if((targ.spawnflags & BREAKABLE_ONLY_EXPLOSION) && !IsExplosionDamage)
			return;
	}
	if(targ.classname == "vortex" && inflictor.owner != targ.owner)
		return;
	if(IS_PLAYER(targ) && inflictor.classname == "Vengeance")
		return;
	// TODO: why was it doing this?
	//IsExplosionDamage = false;

	if(Pan_CheckDamage(targ, inflictor, attacker))
		return;

	if((STAT(PASSIVES, targ) & PASSIVE_SPONGE) && deathtype != DEATH_KILL.m_id && deathtype != DEATH_HURTTRIGGER.m_id)
		damage = min(damage, 50);

	if(StatusEffects_active(STATUSEFFECT_PowerShield, targ))
	{
		// allow some damage to pass through
		damage = shield_hit(targ, inflictor, attacker, damage);
		if(damage == 0)
			return;
	}

	if(targ.tank)
		damage = Tank_Damage(targ, inflictor, attacker, damage, deathtype);

	if(StatusEffects_active(STATUSEFFECT_Weakness, attacker))
		damage *= 0.7;

	if(STAT(CANNON, targ))
		damage *= 0.5;

	if(StatusEffects_active(STATUSEFFECT_Berserk, targ))
		damage *= 0.5;

	if(targ.m_champion && !DEATH_IS(deathtype, DEATH_GENERIC))
		damage *= targ.m_champion.qcc_damagetaken;

	if(attacker.m_champion && attacker.m_champion.m_dealdamage)
		damage *= attacker.m_champion.m_dealdamage(attacker.m_champion, targ, inflictor, attacker, damage, deathtype);
	if(targ.m_champion && targ.m_champion.m_takedamage)
		damage *= targ.m_champion.m_takedamage(targ.m_champion, targ, inflictor, attacker, damage, deathtype);

	// damage mod for monsters -- dumptruck_ds
	if(attacker.damage_mod)
		damage *= attacker.damage_mod;

// check for quad damage powerup on the attacker
	if(StatusEffects_active(STATUSEFFECT_Quad, attacker))
		damage *= 4;

	if(targ.classname == "block" && !IS_PLAYER(attacker))
	{
		if(gametype == GAMETYPE_TD)
			damage *= 0.5; // only some mitigation so they're not unbreakable
		else
			damage = 1;
	}

	if(StatusEffects_active(STATUSEFFECT_EmpathyShields, targ) && !StatusEffects_active(STATUSEFFECT_EmpathyShields, attacker) && (targ != attacker))
	{
		empathyused = true;
		damage *= 0.5;
		T_Damage(attacker, targ, targ, damage, deathtype);
		empathyused = false;
	}

	// jump boots: half damage from attackers below the target
	if(StatusEffects_active(STATUSEFFECT_JumpBoots, targ) && (targ.origin_z > attacker.origin_z || targ.origin_z > inflictor.origin_z) && targ != attacker)
		damage *= 0.5;

#if 0
	// vengeance sphere handling
	if(targ != attacker && IS_MONSTER(attacker) && time > targ.vsphere_last)
	{
		IL_EACH(g_vspheres, it.owner == targ && !it.enemy,
		{
			sphere_attack(it, attacker);
			targ.vsphere_last = time + 0.5; // prevent firing them all at once!
			break;
		});
	}
#endif

// save damage based on the target's armor level

	float armor = (targ.armorvalue > 0) ? armor_getstrength(targ.armortype) : 0;
	if((deathtype & HITTYPE_MAGIC) && targ.armortype == ARMOR_MAGE)
		armor *= 1.5;
	// in Quake, armor piercing rounds just cut armor strength in half rather than negating it
	if(deathtype & HITTYPE_ARMORPIERCE)
		armor *= 0.5;
	float save = ceil(armor * damage);
	// TODO: status effect deathtype flag?
	if(DEATH_IS(deathtype, DEATH_DROWN) || DEATH_IS(deathtype, DEATH_POISONED) || DEATH_IS(deathtype, DEATH_BURNING) || DEATH_IS(deathtype, DEATH_GENERIC))
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
	else
	{
		if(time - targ.dmg_time > 1)
		{
			targ.dmg_take = 0;
			targ.dmg_time = time;
		}
		targ.dmg_take = targ.dmg_take + take;
	}

	bool nopush = false;
	// optionally no pushing players around
	if(NoPushies(targ, attacker))
		nopush = true;
	// special case: v1's slam doesn't push enemies around
	// TODO: let champions customise this
	if(DEATH_IS(deathtype, DEATH_CRUSH) && attacker.m_champion == CHAMPION_V1)
		nopush = true;

// figure momentum add
	if((inflictor != NULL) && !nopush && inflictor.classname != "vortex" && deathtype != DEATH_HURTTRIGGER.m_id &&
		(targ.move_movetype == MOVETYPE_WALK || (targ.move_movetype == MOVETYPE_STEP && DEATH_ISWEAPON(deathtype, WEP_TUBA) && inflictor == attacker && !(targ.monsterdef.spawnflags & MON_FLAG_STATIONARY))) )
	{
		vector dir = targ.origin - (inflictor.absmin + inflictor.absmax) * 0.5;
		dir = normalize(dir);
		targ.velocity += dir * max(damage, force) * 8;
		targ.velocity_z += 1 * forcezscale;
		UNSET_ONGROUND(targ);
	}

// check for godmode or invincibility
	if(targ.flags & FL_GODMODE)
		return;
	if(damage < 666 && !targ.tank && StatusEffects_active(STATUSEFFECT_Invulnerability, targ))
	{
		if(inflictor.classname == "vortex")
			damage *= 0.5;
		else
		{
			if(targ.invincible_sound < time)
			{
				_sound(targ, CH_TRIGGER_SINGLE, "items/protect3.wav", 1, ATTN_NORM);
				targ.invincible_sound = time + 2;
			}
			return;
		}
	}

	// special case for killable chthon (yoder, december 16 2020)
	if(targ.monsterdef == MON_CHTHON && (targ.spawnflags & 2)) // is killable chthon
	{
		if(DEATH_ISWEAPON(deathtype, WEP_LIGHTNING))
		{
			// TODO: Spawn blood
			//LOG_DEBUG("Player has LG! Damage Chthon!");
			take *= 2;
		}
	}

	if(StatusEffects_active(STATUSEFFECT_EmpathyShields, targ))
	{
		if(targ.empathy_sound < time)
		{
			_sound(targ, CH_TRIGGER_SINGLE, "hipitems/empathy2.wav", 1, ATTN_NORM);
			targ.empathy_sound = time + 0.5;
		}
	}

	if(targ.spell_shield && targ != attacker && (inflictor || attacker))
	{
		// we need a valid enemy here for the effect to work
		makevectors(targ.angles);
		entity from = (inflictor) ? inflictor : attacker;
		vector vec = normalize(from.origin - targ.origin);
		float dot = (vec * v_forward);
		if(dot > 0.3)
			take *= 0.5;
	}

// coop damage avoidance (if enabled)
	if(coop && attacker != targ && IS_PLAYER(attacker) && IS_PLAYER(targ) && gametype != GAMETYPE_DODGEBALL)
	{
		if(autocvar_g_friendlyfire_virtual)
			return;
		take *= autocvar_g_friendlyfire;
	}

	if(gametype == GAMETYPE_DODGEBALL)
	{
		if(targ.team_no > 0 && targ.team_no == attacker.team_no && targ != attacker)
			return;
	}
		
// do the damage
	if(StatusEffects_active(STATUSEFFECT_FieldGen, targ)
		//&& inflictor.classname != "grenade" && inflictor.classname != "ogre_grenade" && inflictor.classname != "missile" && inflictor.classname != "vore_ball" && inflictor.classname != "juggy_rocket" && inflictor.classname != "explo_box"
		&& !(!inflictor && targ.watertype == CONTENT_WATER) && !(!inflictor && targ.jump_flag < -650))
	{
		if(r < 0.3)
			_sound(targ, CHAN_ITEM, "weapons/field/genhit1.wav", 1, ATTN_NORM);
		else if (r < 0.6)
			_sound(targ, CHAN_ITEM, "weapons/field/genhit2.wav", 1, ATTN_NORM);
		else
			_sound(targ, CHAN_ITEM, "weapons/field/genhit3.wav", 1, ATTN_NORM);
		targ.field_generator_health -= take;
		showpain = false;
		take = 0;
		targ.effects |= EF_BRIGHTFIELD;
		if(targ.field_generator_health < 0)
		{
			take = 0 - targ.field_generator_health;
			showpain = true;
		}
	}

	if(attacker == targ)
	{
		// don't reset pushltime for self damage as it may be an attempt to
		// escape a lava pit or similar
		//targ.pushltime = 0;
	}
	else if(IS_PLAYER(attacker))
	{
		targ.pusher = attacker;
		targ.pushltime = time + autocvar_g_maxpushtime;
	}
	else if(time < targ.pushltime)
	{
		attacker = targ.pusher;
		targ.pushltime = max(targ.pushltime, time + 0.6);
	}
	else
	{
		targ.pushltime = 0;
	}

	targ.health -= take;
	targ.armorvalue = max(targ.armorvalue - save, 0);

	targ.armor_regen_pause = time + 5; // TODO: find a good balance for this

	if(save >= targ.armorvalue)
	{
		save = targ.armorvalue;
		if(targ.armortype != ARMOR_TECH)
			targ.armortype = ARMOR_NONE; // lost all armor
	}

	if(targ.tank && targ.health <= 0)
		Tank_Eject(targ, true); // resets health

	if(targ.health <= 0)
		QCC_SavePlayer(targ, inflictor, attacker, deathtype);

	if(targ.clockwork && targ.health <= 0)
	{
		showpain = false;
		Clockwork_Explode(targ);
	}
			
	if(targ.health <= 0)
	{
		Killed(targ, inflictor, attacker, deathtype);
		return;
	}

// react to the damage

	// boss bar
	if(IS_MONSTER(targ) && targ.sprite)
		WaypointSprite_UpdateHealth(targ.sprite, targ.health);

	if(((IS_MONSTER(attacker) && attacker.poisonous) || inflictor.poisonous) && IS_PLAYER(targ) && !targ.tank)
	{
		float poisontime = floor(autocvar_skill + 3 + 2*random());
		// Air tanks help reduce poison debuff duration
		//if(targ.moditems & IT_ARTAIRTANK)
			//poisontime = floor(poisontime * 0.5);
		// only add more poison if there isn't already a longer timer running!
		float curtime = StatusEffects_gettime(STATUSEFFECT_Poisoned, targ);
		if((time + poisontime) > curtime)
			StatusEffects_apply(STATUSEFFECT_Poisoned, targ, time + poisontime, 0);
	}

	// NOTE: using damage as a cheap valid target check, means the effect won't apply if the target is invulnerable!
	if(((IS_MONSTER(attacker) && attacker.confusing) || inflictor.confusing) && ((IS_PLAYER(targ) && !deathmatch) || IS_MONSTER(targ)) && targ != attacker && damage > 0 && !targ.tank)
	{
		float confusetime = floor(autocvar_skill + 3 + 2*random());
		// only add the effect if there isn't already a longer timer running!
		float curtime = StatusEffects_gettime(STATUSEFFECT_Confused, targ);
		if((time + confusetime) > curtime)
			StatusEffects_apply(STATUSEFFECT_Confused, targ, time + confusetime, 0);
	}

	// qbj3 specific hack: trigger on react
	if(IS_MONSTER(targ) && attacker && !targ.is_frozen && (targ.spawnflags & SPAWN_ALT_TARG) && IsQBJMap())
	{
		int bits = BIT(1) | BIT(3) | BIT(4);
		if(IS_PLAYER(attacker) || IS_MONSTER(attacker))
			bits &= ~BIT(1);
		if(targ.health <= floor(targ.max_health * 0.5))
			bits &= ~BIT(3);
		SUB_UseTargets_Ex(targ, attacker, NULL, bits, false);

		if(!(bits & BIT(1)))
			targ.target = string_null;
		if(!(bits & BIT(2)))
			targ.target2 = string_null;
		if(!(bits & BIT(3)))
			targ.target3 = string_null;
	}

	bool is_trap = DEATH_IS(deathtype, DEATH_TRAP);
	if(IS_TURRET(attacker) && !targ.movetarget)
		is_trap = false; // prevent cheese from stationary monsters

	if(IS_MONSTER(targ) && attacker && !(targ.monsterdef.spawnflags & MON_FLAG_NOAGGRO) && !(targ.monsterdef.spawnflags & MON_FLAG_NOTARGET) && !(targ.monsterdef.spawnflags & MONSTER_TYPE_UNDEAD) && !is_trap)
	{
		// make pets focus the target
		FOREACH_ENTITY_ENT(charmer, attacker,
		{
			if(!it.charmed || it.is_frozen || it.health <= 0 || it.enemy == targ)
				continue;

			if(!it.aggro_time || (it.aggro_time + AGGRO_MIN + (random() * AGGRO_ADD) < time))
			{
				if(CanTeleportToTarget(it, targ, 512))
					TeleportToTarget(it, targ, true);

				if(IS_PLAYER(it.enemy))
					it.oldenemy = it.enemy;
				it.enemy = targ;
				it.aggro_time = time;
				FoundTarget(it);
			}
		});

	// get mad unless of the same class(except for soldiers)
		if(attacker && targ != attacker && attacker != targ.enemy && targ.charmer != attacker && !targ.charmed && !targ.is_frozen)
		{
			if(targ.classname != attacker.classname || (targ.monsterdef.spawnflags & MON_FLAG_INFIGHT))
			{
				if(coop || gametype == GAMETYPE_HORDE || (gametype == GAMETYPE_TD && attacker.monster_attack))
				{
					// yoder Sept24, 2021
					// if in horde mode, have enemies obey a reaggro time
					if((IS_PLAYER(targ.enemy) || targ.enemy.monster_attack) && IS_PLAYER(attacker)) // current and new enemy are both players, check reaggro times
					{
						// check reaggro times
						if(!targ.aggro_time || (targ.aggro_time + AGGRO_MIN + (random() * AGGRO_ADD) < time))
						{
							if(IS_PLAYER(targ.enemy))
								targ.oldenemy = targ.enemy;
							targ.enemy = attacker;
							targ.aggro_time = time;
							FoundTarget(targ);
						}
						else
						{
							// ignore new aggro from this hit
							//LOG_DEBUG("ignore new aggro");
						}
					}
					else // immediately aggro, store the player if previous was player
					{
						if(IS_PLAYER(targ.enemy))
							targ.oldenemy = targ.enemy;
						targ.enemy = attacker;
						FoundTarget(targ);
					}
				}
				else
				{
					if(IS_PLAYER(targ.enemy))
						targ.oldenemy = targ.enemy;
					targ.enemy = attacker;
					FoundTarget(targ);
				}
			}
		}
	}

	// HACK: need access to the one that was hurt!
	if(targ.monsterdef == MON_DESTROYER && targ != orig && orig.th_pain)
		orig.th_pain(orig, attacker, take, deathtype);
	else if(targ.th_pain && showpain)
	{
		targ.th_pain(targ, attacker, take, deathtype);
	// nightmare mode monsters don't go into pain frames often
		if(autocvar_skill == 3 && IS_MONSTER(targ))
			targ.pain_finished = time + 5;		
	}
}

/*
============
T_RadiusDamage
============
*/
bool inside_radius = false;
void T_RadiusDamage(entity inflictor, entity attacker, float damage, int deathtype, entity ignore)
{
	if(inside_radius)
	{
		LOG_FATAL("T_RadiusDamage: recursive");
		return;
	}
	inside_radius = true;

	IsExplosionDamage = true;

	vector inflictor_org = (inflictor.absmin + inflictor.absmax) * 0.5;

	entity head = findradius(inflictor_org, damage + 40);
	while(head)
	{
		entity next = head.chain;
		if(head == ignore || ai_immunebreakable(attacker, head))
		{
			head = next;
			continue;
		}
		if(ai_foundbreakable(attacker, head, true) && head.brktrigmissile != 0)
		{
			if(head.use)
				head.use(head, attacker, inflictor);
			head = next;
			continue;
		}
		if(head.takedamage && ((attacker == head || !head.clipgroup) || (head.clipgroup != inflictor.clipgroup && head.clipgroup != attacker.clipgroup)))
		{
			vector org = (head.absmin + head.absmax) * 0.5;
			float points = max(0, 0.5 * vlen(inflictor_org - org));
			points = damage - points;
			if(head == attacker || (head.monsterdef && (head.monsterdef.spawnflags & MON_FLAG_EXPLOSIONRESISTANT)))
				points *= 0.5;
			if(head.monsterdef && (head.monsterdef.spawnflags & MONSTER_TYPE_UNDEAD) && points > (head.health * 0.25))
				points = 120; // always gib zombies
			if(DEATH_IS(deathtype, DEATH_DISCHARGE))
			{
				int cont = Mod_Q1BSP_SuperContentsFromNativeContents(pointcontents(head.origin));
				if(!(cont & DPCONTENTS_LIQUIDSMASK))
					points = 0;
			}
			if(DEATH_IS(deathtype, DEATH_EXPLODE))
			{
				if(IS_PLAYER(head))
					points = 0;
			}
			if(points > 0)
			{
				if(CanDamage(head, inflictor))
				{
					if(DEATH_ISSPECIAL(deathtype))
						T_Damage(head, inflictor, attacker, points, deathtype);
					else
						T_Damage(head, inflictor, attacker, points, deathtype | HITTYPE_SPLASH);
				}
			}
		}
		head = next;
	}
	inside_radius = false;
	IsExplosionDamage = false;
}
