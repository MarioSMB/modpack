//FEATURE: Runematch gamemode, another mode from the days of old making its return, in which random 'runes' appear on the map, and the player needs to collect and hold all of them

#ifndef IMPLEMENTATION
#ifdef SVQC
AUTOCVAR_NOREF(g_runematch, bool, false, "");
#endif
#include "runematch.qh"
#endif

#ifdef IMPLEMENTATION

#ifdef SVQC
//float autocvar_g_runematch_allow_same; // TODO: re-implement this?
AUTOCVAR(g_runematch_fixedspawns, bool, true, "Use fixed runematch spawns if available");
AUTOCVAR(g_runematch_frags_killed_runeholder, float, 4, "");
AUTOCVAR(g_runematch_frags_killedby_runeholder, float, 5, "");
AUTOCVAR(g_runematch_frags_norune, float, 0, "");
AUTOCVAR(g_runematch_point_leadlimit, float, -1, "Runematch point lead limit overriding the mapinfo specified one (use 0 to play without limit, and -1 to use the mapinfo's limit)");
AUTOCVAR(g_runematch_point_limit, float, -1, "Runematch point limit overriding the mapinfo specified one (use 0 to play without limit, and -1 to use the mapinfo's limit)");
AUTOCVAR(g_runematch_pointamt, float, 1, "");
AUTOCVAR(g_runematch_pointrate, float, 5, "");
AUTOCVAR(g_runematch_points_bykill, bool, true, "Count scores by kills instead of giving them over time");
AUTOCVAR(g_runematch_respawntime, float, 15, "How soon after being dropped to respawn");
AUTOCVAR(g_runematch_rune_alpha, float, 0.78, "");
AUTOCVAR(g_runematch_rune_color_strength, float, 1.0, "");
AUTOCVAR(g_runematch_rune_effects, int, 544, "EF_ADDITIVE + EF_FULLBRIGHT = 544");
AUTOCVAR(g_runematch_shuffletime, float, 30, "How often runes change position");

void rune_Initialize();

REGISTER_MUTATOR(rune, false)
{
	MUTATOR_STATIC();
	MUTATOR_ONADD
	{
		GameRules_limit_score(autocvar_g_runematch_point_limit);
		GameRules_limit_lead(autocvar_g_runematch_point_leadlimit);

		rune_Initialize();
	}

	return false;
}

AUTOCVAR_NOREF(g_rune_respawn_delay_small, float, 0, "");
AUTOCVAR_NOREF(g_rune_respawn_delay_small_count, float, 0, "");
AUTOCVAR_NOREF(g_rune_respawn_delay_large, float, 0, "");
AUTOCVAR_NOREF(g_rune_respawn_delay_large_count, float, 0, "");
AUTOCVAR_NOREF(g_rune_respawn_delay_max, float, 0, "");
AUTOCVAR_NOREF(g_rune_respawn_waves, float, 0, "");
AUTOCVAR_NOREF(g_rune_weapon_stay, float, 0, "");

AUTOCVAR(g_balance_rune_defense_combo_takedamage, float, 1.0, "");
AUTOCVAR(g_balance_rune_defense_takedamage, float, 0.5, "");
AUTOCVAR(g_balance_rune_regen_combo_hpmod, float, 0.9, "");
AUTOCVAR(g_balance_rune_regen_combo_limitmod, float, 1, "");
AUTOCVAR(g_balance_rune_regen_combo_regenrate, float, 0.5, "");
AUTOCVAR(g_balance_rune_regen_combo_rotrate, float, 1.5, "");
AUTOCVAR(g_balance_rune_regen_hpmod, float, 1.75, "");
AUTOCVAR(g_balance_rune_regen_limitmod, float, 1, "");
AUTOCVAR(g_balance_rune_regen_regenrate, float, 3.0, "");
AUTOCVAR(g_balance_rune_speed_atkrate, float, 0.66, "");
AUTOCVAR(g_balance_rune_speed_combo_atkrate, float, 1.2, "");
AUTOCVAR(g_balance_rune_speed_combo_highspeed, float, 0.9, "");
AUTOCVAR(g_balance_rune_speed_highspeed, float, 1.5, "");
AUTOCVAR(g_balance_rune_strength_combo_damage, float, 0.9, "");
AUTOCVAR(g_balance_rune_strength_combo_force, float, 1.0, "");
AUTOCVAR(g_balance_rune_strength_damage, float, 2.0, "");
AUTOCVAR(g_balance_rune_strength_force, float, 1.5, "");
AUTOCVAR(g_balance_rune_vampire_absorb, float, 0.4, "");
AUTOCVAR(g_balance_rune_vampire_combo_absorb, float, -0.1, "");
AUTOCVAR(g_balance_rune_vampire_maxhealth, float, 500, "");

AUTOCVAR(g_balance_curse_empathy_minhealth, float, 20, "");
AUTOCVAR(g_balance_curse_empathy_takedamage, float, -0.4, "");
AUTOCVAR(g_balance_curse_slow_atkrate, float, 1.5, "");
AUTOCVAR(g_balance_curse_slow_highspeed, float, 0.6, "");
AUTOCVAR(g_balance_curse_venom_hpmod, float, 0.6, "");
AUTOCVAR(g_balance_curse_venom_limitmod, float, 1, "");
AUTOCVAR(g_balance_curse_venom_rotrate, float, 3.0, "");
AUTOCVAR(g_balance_curse_vulner_takedamage, float, 2.0, "");
AUTOCVAR(g_balance_curse_weak_damage, float, 0.5, "");
AUTOCVAR(g_balance_curse_weak_force, float, 0.6, "");

// spawnfuncs
spawnfunc(runematch_spawn_point)
{
	if(!autocvar_g_runematch_fixedspawns) { delete(this); return; }

	IL_PUSH(g_runematch_spawnpoints, this);

	setsize(this, '0 0 -35', '0 0 0');
	droptofloor(this);
	++rune_numspawns;
}

// main functions
entity rune_find_spawnpoint()
{
	if(rune_numspawns < RUNE_MINSPAWNS)
		return NULL;

	RandomSelection_Init();

	IL_EACH(g_runematch_spawnpoints, it.classname == "runematch_spawn_point" && !it.owner,
	{
		RandomSelection_AddEnt(it, it.cnt, 0);
	});

	return RandomSelection_chosen_ent;
}

void RuneCarriedThink(entity this)
{
	int rcount = 0, rnum = -1;

	if(!IS_PLAYER(this.owner) || time < game_starttime)
	{
		rune_respawn(this);
		return;
	}

	this.nextthink = time + 0.1;

	// count runes my owner holds
	IL_EACH(g_runematch_runes, it.classname == "rune",
	{
		if(it.owner == this.owner)
			rcount += 1;
		if(it == this)
			rnum = rcount;
	});

	vector ang = vec2(0, rnum * (360 / rcount) + (time % 360) * 45);

	makevectors(ang);

	setorigin(this, v_forward * 32);
}

void rune_unmark_spot(entity e)
{
	if(e.owner.classname == "runematch_spawn_point")
	{
		e.owner.owner = NULL;
		e.owner = NULL;
	}
}

void rune_touch(entity this, entity toucher)
{
	if(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT)
	{
		setthink(this, rune_respawn);
		this.nextthink = time;
		return;
	}

	if(!IS_PLAYER(toucher) || IS_DEAD(toucher))
		return;
	if(this.wait > time)
		return; // "notouch" time isn't finished

	// detach from the spawn point you're on
	rune_unmark_spot(this);

	this.owner = toucher;
	this.enemy.owner = toucher;
	setattachment(this, toucher, "");

	toucher.runes |= this.runes | this.enemy.runes;

	setthink(this, RuneCarriedThink);
	this.nextthink = time;
	settouch(this, func_null);

	this.solid = SOLID_NOT;
	setorigin(this, this.origin);

	sound(toucher, CH_TRIGGER, SND_BUFF_LOST, VOL_BASE, ATTN_NORM);

	Send_Notification(NOTIF_ALL, NULL, MSG_INFO, INFO_RUNEMATCH_PICKUP, toucher.netname, this.netname, this.enemy.netname);
}

bool rune_spawn_somewhere(entity this)
{
	entity spot = rune_find_spawnpoint();
	vector oldloc = this.origin;
	if(spot)
	{
		spot.owner = this;
		setorigin(this, spot.origin);

		Send_Effect(EFFECT_ELECTRO_BALLEXPLODE, oldloc, '0 0 0', 1);
		Send_Effect(EFFECT_ELECTRO_BALLEXPLODE, this.origin, '0 0 0', 1);

		this.owner = spot;
		spot.owner = this;
		return true;
	}
	else
	{
		if(MoveToRandomMapLocation(this, DPCONTENTS_SOLID | DPCONTENTS_CORPSE | DPCONTENTS_PLAYERCLIP, DPCONTENTS_SLIME | DPCONTENTS_LAVA | DPCONTENTS_SKY | DPCONTENTS_BODY | DPCONTENTS_DONOTENTER, Q3SURFACEFLAG_SKY, 10, 1024, 256))
		{
			Send_Effect(EFFECT_ELECTRO_BALLEXPLODE, oldloc, '0 0 0', 1);
			Send_Effect(EFFECT_ELECTRO_BALLEXPLODE, this.origin, '0 0 0', 1);
			// great
			makevectors(this.angles),
			this.velocity = v_forward * 250;
			this.angles = '0 0 0';
			UNSET_ONGROUND(this);
			return true;
		}
		else
		{
			// sorry, can't spawn, better luck next frame
			return false;
		}
	}
}

void rune_respawn(entity this)
{
	rune_unmark_spot(this);
	if(rune_spawn_somewhere(this))
	{
		this.solid = SOLID_TRIGGER;
		settouch(this, rune_touch);
		setthink(this, rune_respawn);
		this.nextthink = time + autocvar_g_runematch_shuffletime;
	}
	else
	{
		// try again later
		setthink(this, rune_respawn);
		this.nextthink = time;
	}
}

void rune_Setup(entity e, float r)
{
	switch(r)
	{
		// Runes
		case RUNE_STRENGTH:
			e.colormod = '255 0 0';
			e.netname = "^1Strength^7";
			break;
		case RUNE_DEFENSE:
			e.colormod = '0 0 255';
			e.netname = "^4Defense^7";
			break;
		case RUNE_REGEN:
			e.colormod = '0 204 0';
			e.netname = "^2Vitality^7";
			break;
		case RUNE_SPEED:
			e.colormod = 0.35 * '185 185 0';
			e.netname = "^3Speed^7";
			break;
		case RUNE_VAMPIRE:
			e.colormod = '64 0 128';
			e.netname = "^6Vampire^7";
			break;
		// Curses
		case CURSE_WEAK:
			e.colormod = '255 0 0';
			e.netname = "^1Weakness^7";
			break;
		case CURSE_VULNER:
			e.colormod = '0 0 255';
			e.netname = "^4Vulnerability^7";
			break;
		case CURSE_VENOM:
			e.colormod = '0 204 0';
			e.netname = "^2Venom^7";
			break;
		case CURSE_SLOW:
			e.colormod = 0.5*'185 185 0';
			e.netname = "^3Slow^7";
			break;
		case CURSE_EMPATHY:
			e.colormod = '179 0 204';
			e.netname = "^6Empathy^7";
			break;
		default:
			e.colormod = '255 0 255';
			e.netname = strzone(strcat("^8[unnamed", ftos(r), "]^7"));
			break;
	}

	e.colormod *= (1 / 255) * autocvar_g_runematch_rune_color_strength;
}

void rune_ChooseCurse(entity e)
{
	RandomSelection_Init();
	IL_EACH(g_runematch_runes, it.classname == "curse" && !it.owner,
	{
		RandomSelection_AddEnt(it, 1, 1);
	});
	e.enemy = RandomSelection_chosen_ent;
	e.enemy.owner = e;
	setattachment(e.enemy, e, "");
}

void DropAllRunes(entity pl)
{
	IL_EACH(g_runematch_runes, it.classname == "rune" && it.owner == pl,
	{
		Send_Notification(NOTIF_ALL, NULL, MSG_INFO, INFO_RUNEMATCH_LOST, pl.netname, it.netname, it.enemy.netname);
		
		setattachment(it, NULL, "");
		
		// toss from player
		setorigin(it, pl.origin + '0 0 10');
		it.velocity = vec3(100 * crandom(), 100 * crandom(), 200);
		
		// don't instantly touch player again
		it.wait = time + 1; // "notouch" time
		set_movetype(it, MOVETYPE_TOSS);
		it.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY;
		it.gravity = 0.8;
		it.solid = SOLID_TRIGGER;
		settouch(it, rune_touch);

		UNSET_ONGROUND(it);
		
		it.owner = NULL;
		it.enemy.owner = NULL;
		
		setthink(it, rune_respawn);
		it.nextthink = time + autocvar_g_runematch_respawntime;
	});
}

void rune_reset(entity this)
{
	if(this.owner && IS_PLAYER(this.owner))
		DropAllRunes(this.owner);

	rune_respawn(this);
}

void rune_SpawnRunes(entity this)
{
	entity e;
	
	for(int cs = CURSE_FIRST; cs <= CURSE_LAST; cs *= 2)
	{
		e = spawn();
		e.runes = cs;
		e.classname = "curse";
		e.alpha = autocvar_g_runematch_rune_alpha;
		e.effects = autocvar_g_runematch_rune_effects | EF_LOWPRECISION;

		IL_PUSH(g_runematch_runes, e);
		
		rune_Setup(e, cs);
		
		setmodel(e, MDL_RUNEMATCH_CURSE); // precision set below
		setsize(e, '0 0 -35', '0 0 0');
	}
	
	for(int rn = RUNE_FIRST; rn <= RUNE_LAST; rn *= 2)
	{
		e = spawn();
		e.runes = rn;
		e.classname = "rune";
		settouch(e, rune_touch);
		setthink(e, rune_respawn);
		e.nextthink = time;
		set_movetype(e, MOVETYPE_TOSS);
		e.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY;
		e.gravity = 0.8;
		e.solid = SOLID_TRIGGER;
		e.flags = FL_ITEM;
		IL_PUSH(g_items, e);
		e.reset = rune_reset;
		e.alpha = autocvar_g_runematch_rune_alpha;
		e.effects = autocvar_g_runematch_rune_effects | EF_LOWPRECISION;

		IL_PUSH(g_runematch_runes, e);
		
		rune_ChooseCurse(e);
		rune_Setup(e, rn);
		
		setmodel(e, MDL_RUNEMATCH_RUNE); // precision set below
		setsize(e, '0 0 -35', '0 0 0');
	}
}

float RunematchHandleFrags(entity attacker, entity targ, float f)
{
	if(autocvar_g_runematch_points_bykill)
		return 0;

	if(f <= 0 || attacker == targ)
		return f;
		
	if(!attacker.runes && !targ.runes)
		return f - 1 + autocvar_g_runematch_frags_norune; // don't give points to players when no runes are involved.
		
	float newfrags = 0;
	if(attacker.runes)
		newfrags += autocvar_g_runematch_frags_killedby_runeholder;

	if(targ.runes)
		newfrags += autocvar_g_runematch_frags_killed_runeholder;

	if(newfrags)
		f -= 1 + newfrags;

	return f;
}

MUTATOR_HOOKFUNCTION(rune, SV_StartFrame)
{
	if(game_stopped || !autocvar_g_runematch_pointamt || autocvar_g_runematch_points_bykill)
		return false;
	if(runematch_point_time > time)
		return false;
		
	runematch_point_time = time + autocvar_g_runematch_pointrate;

	IL_EACH(g_runematch_runes, it.classname == "rune" && IS_PLAYER(it.owner),
	{
		UpdateFrags(it.owner, autocvar_g_runematch_pointamt);
	});
}

MUTATOR_HOOKFUNCTION(rune, PlayerPhysics_UpdateStats)
{
	entity player = M_ARGV(0, entity);

	if(player.runes & RUNE_SPEED)
	{
		if(player.runes & CURSE_SLOW)
			STAT(MOVEVARS_HIGHSPEED, player) *= autocvar_g_balance_rune_speed_combo_highspeed;
		else
			STAT(MOVEVARS_HIGHSPEED, player) *= autocvar_g_balance_rune_speed_highspeed;
	}
	else if(player.runes & CURSE_SLOW)
		STAT(MOVEVARS_HIGHSPEED, player) *= autocvar_g_balance_curse_slow_highspeed;
}

MUTATOR_HOOKFUNCTION(rune, GiveFragsForKill)
{
	entity frag_attacker = M_ARGV(0, entity);
	entity frag_target = M_ARGV(1, entity);
	float frag_score = M_ARGV(2, float);
	frag_score = RunematchHandleFrags(frag_attacker, frag_target, frag_score);
	M_ARGV(2, float) = frag_score;
	
	return true;
}

MUTATOR_HOOKFUNCTION(rune, WeaponRateFactor)
{
	entity player = M_ARGV(1, entity);

	if(player.runes & RUNE_SPEED)
	{
		if(player.runes & CURSE_SLOW)
			M_ARGV(0, float) *= autocvar_g_balance_rune_speed_combo_atkrate;
		else
			M_ARGV(0, float) *= autocvar_g_balance_rune_speed_atkrate;
	}
	else if(player.runes & CURSE_SLOW)
		M_ARGV(0, float) *= autocvar_g_balance_curse_slow_atkrate;
}

MUTATOR_HOOKFUNCTION(rune, Damage_Calculate)
{
	entity frag_attacker = M_ARGV(1, entity);
	entity frag_target = M_ARGV(2, entity);
	float frag_damage = M_ARGV(4, float);
	vector frag_force = M_ARGV(6, vector);

	// apply strength rune
	if (frag_attacker.runes & RUNE_STRENGTH)
	{
		if(frag_attacker.runes & CURSE_WEAK) // have both curse & rune
		{
			frag_damage *= autocvar_g_balance_rune_strength_combo_damage;
			frag_force *= autocvar_g_balance_rune_strength_combo_force;
		}
		else
		{
			frag_damage *= autocvar_g_balance_rune_strength_damage;
			frag_force *= autocvar_g_balance_rune_strength_force;
		}
	}
	else if (frag_attacker.runes & CURSE_WEAK)
	{
		frag_damage *= autocvar_g_balance_curse_weak_damage;
		frag_force *= autocvar_g_balance_curse_weak_force;
	}

	// apply defense rune
	if (frag_target.runes & RUNE_DEFENSE)
	{
		if (frag_target.runes & CURSE_VULNER) // have both curse & rune
			frag_damage *= autocvar_g_balance_rune_defense_combo_takedamage;
		else
			frag_damage *= autocvar_g_balance_rune_defense_takedamage;
	}
	else if (frag_target.runes & CURSE_VULNER)
		frag_damage *= autocvar_g_balance_curse_vulner_takedamage;
		
	if(IS_PLAYER(frag_target) && IS_PLAYER(frag_attacker) && frag_attacker != frag_target && frag_attacker.health > 2)
	{
		if (frag_attacker.runes & RUNE_VAMPIRE)
		{
			// apply vampire rune
			if (frag_attacker.runes & CURSE_EMPATHY) // have the curse too
			{
				frag_attacker.health = bound(
											 autocvar_g_balance_curse_empathy_minhealth,
											 frag_attacker.health + frag_damage * autocvar_g_balance_rune_vampire_combo_absorb,
											 autocvar_g_balance_rune_vampire_maxhealth);
			}
			else
			{
				frag_attacker.health = bound(
											 frag_attacker.health,
											 frag_attacker.health + frag_damage * autocvar_g_balance_rune_vampire_absorb,
											 autocvar_g_balance_rune_vampire_maxhealth);
			}
		}
		else if (frag_attacker.runes & CURSE_EMPATHY)
		{
			// apply empathy curse
			frag_attacker.health = bound(
										 autocvar_g_balance_curse_empathy_minhealth,
										 frag_attacker.health + frag_damage * autocvar_g_balance_curse_empathy_takedamage,
										 frag_attacker.health);
		}
	}

	M_ARGV(4, float) = frag_damage;
	M_ARGV(6, vector) = frag_force;
}

MUTATOR_HOOKFUNCTION(rune, ClientDisconnect)
{
	entity player = M_ARGV(0, entity);
	DropAllRunes(player);
	player.runes = 0;
}

MUTATOR_HOOKFUNCTION(rune, PlayerDies)
{
	entity frag_attacker = M_ARGV(1, entity);
	entity frag_target = M_ARGV(2, entity);
	if(autocvar_g_runematch_points_bykill && (frag_attacker != frag_target) && IS_PLAYER(frag_attacker))
	{
		float runes_score = 0;
		IL_EACH(g_runematch_runes, it.classname == "rune" && it.owner == frag_attacker,
		{
			runes_score += autocvar_g_runematch_pointamt;
		});
		if(runes_score)
			GameRules_scoring_add(frag_attacker, SCORE, runes_score);
	}

	DropAllRunes(frag_target);
	frag_target.runes = 0;
}

MUTATOR_HOOKFUNCTION(rune, MakePlayerObserver)
{
	entity player = M_ARGV(0, entity);
	DropAllRunes(player);
	player.runes = 0;
}

MUTATOR_HOOKFUNCTION(rune, PlayerSpawn)
{
	entity player = M_ARGV(0, entity);
	player.runes = 0;
}

MUTATOR_HOOKFUNCTION(rune, PlayerRegen)
{
	entity player = M_ARGV(0, entity);

	if(player.runes & RUNE_REGEN)
	{
		if(player.runes & CURSE_VENOM) // do we have both rune/curse?
		{
			M_ARGV(2, float) = autocvar_g_balance_rune_regen_combo_regenrate; // regen_mod
			M_ARGV(1, float) = autocvar_g_balance_rune_regen_combo_hpmod; // max_mod
			M_ARGV(4, float) = autocvar_g_balance_rune_regen_combo_limitmod; // limit_mod
		}
		else
		{
			M_ARGV(2, float) = autocvar_g_balance_rune_regen_regenrate; // regen_mod
			M_ARGV(1, float) = autocvar_g_balance_rune_regen_hpmod; // max_mod
			M_ARGV(4, float) = autocvar_g_balance_rune_regen_limitmod; // limit_mod
		}
	}
	else if(player.runes & CURSE_VENOM)
	{
		M_ARGV(1, float) = autocvar_g_balance_curse_venom_hpmod; // max_mod
		M_ARGV(4, float) = autocvar_g_balance_curse_venom_limitmod; // limit_mod
		if(player.runes & RUNE_REGEN) // how?
			M_ARGV(2, float) = autocvar_g_balance_rune_regen_combo_rotrate; // rot_mod
		else
			M_ARGV(2, float) = autocvar_g_balance_curse_venom_rotrate; // rot_mod
	}
}

#if 0
// TODO: currently not implemented!
MUTATOR_HOOKFUNCTION(rune, ItemCodes)
{
	if(other.runes)
		item_string = strcat(item_string, "|", ftos(other.runes));
	
	return false;
}
#endif

void rune_Initialize()
{
	warmup_stage = 0;
	
	InitializeEntity(NULL, rune_SpawnRunes, INITPRIO_SETLOCATION);
}
#endif

#endif
