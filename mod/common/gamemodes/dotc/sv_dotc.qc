//FEATURE: DotC (Defense of the Core) gamemode, a highly ambitious and unfinished mode based on the DotA series

/** DotC - Defense Of The Core. Xonotic's version of DotA

Summary
	Mode has two teams, each has a Core which the other team needs to destroy to win the match.
	Players (re)spawn at their core.
	Each base sends 'drone squads', groups of AI units that move toward the enemy base and attack the other team's units.

Key concepts
	1 - The core
		Each team has a Core, if this core is destroyed the team is defeated.
		* Players spawn by their team's Core.
		* The Core is upgraded by collecting credits.
		* The Core's level determines the player's spawn items, health and armour.
		* The Core's level determines the strength of its team's drone squads.

	2 - The drone factories
		Each Core has one or more drone factories.
		* Factories automatically produce squads of autonomous drones.
		* Factories only produce up to a set number of squads.
		* A factory will not produce a new squad until an old one is totally destroyed.
		* The factories can be destroyed, rendering them inert for the duration of the match.

	3 - Drone squads
		Drone squads are a collection of AI units that will follow a predefined path towards the enemy's Core.
		* Drone squads will stop and engage any unit of the other team it may come across.
		* Drones will NOT engage neutrals (see bullet 5). Nor will neutrals engage them.
		* Drones will, when destroyed by a human player, drop a 'credit token' (see 4).
		* Drone's strength are determined by team's Core level.

	4 - Credits
		* When a player destroys an enemy drone, the drone drops a credit token.
		* If this token is picked up by a player, their team gains some credits.
		* Once enough credits are aquired by a team, their core is upgraded (see 1)

	5 - Neutrals (not implemented)
		Around the map there can be 'neutral' units.
		* Neutrals do not attack drones, nor do drones attack them.
		* Neutrals will attack players.
		* Neutrals are generally much harder to defeat then normal drones or turrets (see 6)
		* If a player defeats a neutral and picks up its token, their team gets a bonus
		* Bonus can be:
			* A large sum of credits
			* A powerful item (like a vehicle)
			* Unlocking an item at spawn time for all teammemebers (e.g. a weapon or armour boost)

	6 - Turrets
		Each team can have turrets placed around the map.
		* Turrets are very tough to kill and deal much damage.
		* Turrets do not respawn once destroyed
**/

#ifndef GAMEMODE_DOTC_H
#define GAMEMODE_DOTC_H

.float aim_maxrot;

int dotc_teams;

// score stuff
const int ST_DOTC_DESTROYED	  	= 1;
//#define SP_DOTC_NEUTRAL_KILLS 8

#define DOTC_FFCHECK(otr,me) ((SAME_TEAM(otr, me)) ? !autocvar_g_dotc_apply_friendlyfire : false)

void dotc_Initialize();
REGISTER_MUTATOR(dotc, false)
{
	MUTATOR_STATIC();
	MUTATOR_ONADD
	{
		GameRules_teams(true);
		GameRules_limit_score(autocvar_g_dotc_point_limit);

		dotc_Initialize();
	}

	return false;
}

#endif

#ifdef IMPLEMENTATION

float bbox_radius(vector mi, vector ma)
{
	ma_x = max(-mi_x, ma_x);
	ma_y = max(-mi_y, ma_y);
	ma_z = max(-mi_z, ma_z);
	return vlen(ma);
}

void fix_mins_maxs_for_rotating(entity e)
{
	float r = bbox_radius(e.mins, e.maxs);
	setsize(e, '-1 -1 -1' * r, '1 1 1' * r);
}

// Round handler
void dotc_count_cores()
{
	total_players = redalive = bluealive = yellowalive = pinkalive = 0;
	for(entity tmp_entity = dotc_worldcorelist; tmp_entity; tmp_entity = tmp_entity.dotc_worldcorenext)
	{
		switch(tmp_entity.team)
		{
			case NUM_TEAM_1: ++total_players; if(GetResourceAmount(tmp_entity, RESOURCE_HEALTH) >= 1) ++redalive; break;
			case NUM_TEAM_2: ++total_players; if(GetResourceAmount(tmp_entity, RESOURCE_HEALTH) >= 1) ++bluealive; break;
			case NUM_TEAM_3: ++total_players; if(GetResourceAmount(tmp_entity, RESOURCE_HEALTH) >= 1) ++yellowalive; break;
			case NUM_TEAM_4: ++total_players; if(GetResourceAmount(tmp_entity, RESOURCE_HEALTH) >= 1) ++pinkalive; break;
		}
	}
}

int dotc_GetWinnerTeam()
{
	int winner_team = 0;
	if(redalive >= 1)
		winner_team = NUM_TEAM_1;
	if(bluealive >= 1)
	{
		if(winner_team) return 0;
		winner_team = NUM_TEAM_2;
	}
	if(yellowalive >= 1)
	{
		if(winner_team) return 0;
		winner_team = NUM_TEAM_3;
	}
	if(pinkalive >= 1)
	{
		if(winner_team) return 0;
		winner_team = NUM_TEAM_4;
	}
	if(winner_team)
		return winner_team;
	return -1; // no player left
}

#define DOTC_ALIVE_TEAMS() ((redalive > 0) + (bluealive > 0) + (yellowalive > 0) + (pinkalive > 0))
#define DOTC_ALIVE_TEAMS_OK() (DOTC_ALIVE_TEAMS() == NumTeams(dotc_teams))
bool dotc_CheckWinner()
{
	dotc_count_cores();
	if(DOTC_ALIVE_TEAMS() > 1)
		return 0;

	int winner_team = dotc_GetWinnerTeam();
	if(winner_team > 0)
	{
		Send_Notification(NOTIF_ALL, NULL, MSG_CENTER, APP_TEAM_NUM(winner_team, CENTER_ROUND_TEAM_WIN));
		Send_Notification(NOTIF_ALL, NULL, MSG_INFO, APP_TEAM_NUM(winner_team, INFO_ROUND_TEAM_WIN));
		TeamScore_AddToTeam(winner_team, ST_DOTC_DESTROYED, +1);
	}
	else if(winner_team == -1)
	{
		Send_Notification(NOTIF_ALL, NULL, MSG_CENTER, CENTER_ROUND_TIED);
		Send_Notification(NOTIF_ALL, NULL, MSG_INFO, INFO_ROUND_TIED);
	}

	round_handler_Init(5, autocvar_g_dotc_warmup, 0);

	FOREACH_CLIENT(IS_PLAYER(it),
	{
		nades_Clear(it);
	});

	game_stopped = true;
	return 1;
}

void dotc_RoundStart()
{
	entity tmp_entity;
	for(tmp_entity = dotc_worldfactorylist; tmp_entity; tmp_entity = tmp_entity.dotc_worldfactorynext)
		tmp_entity.nextthink = time + tmp_entity.wait;

	for(tmp_entity = dotc_worldcorelist; tmp_entity; tmp_entity = tmp_entity.dotc_worldcorenext)
		tmp_entity.dotc_status = CORE_ACTIVE;
}

bool dotc_CheckTeams()
{
	allowed_to_spawn = true;
	return true; // always allow
}


// =============
// Mutator hooks
// =============

MUTATOR_HOOKFUNCTION(dotc, PlayerPreThink)
{
	entity player = M_ARGV(0, entity);

	// stats
	for(entity core = dotc_worldcorelist; core; core = core.dotc_worldcorenext)
	{
		switch(core.team)
		{
			case NUM_TEAM_1:
			{
				STAT(DOTC_CORE_LEVEL_RED, player) = core.dotc_corelevel;
				STAT(DOTC_CORE_CREDITS_RED_MAX, player) = core.dotc_nextlevel;
				STAT(DOTC_CORE_CREDITS_RED, player) = core.dotc_credits;
				break;
			}
			case NUM_TEAM_2:
			{
				STAT(DOTC_CORE_LEVEL_BLUE, player) = core.dotc_corelevel;
				STAT(DOTC_CORE_CREDITS_BLUE_MAX, player) = core.dotc_nextlevel;
				STAT(DOTC_CORE_CREDITS_BLUE, player) = core.dotc_credits;
				break;
			}
			case NUM_TEAM_3:
			{
				STAT(DOTC_CORE_LEVEL_YELLOW, player) = core.dotc_corelevel;
				STAT(DOTC_CORE_CREDITS_YELLOW_MAX, player) = core.dotc_nextlevel;
				STAT(DOTC_CORE_CREDITS_YELLOW, player) = core.dotc_credits;
				break;
			}
			case NUM_TEAM_4:
			{
				STAT(DOTC_CORE_LEVEL_PINK, player) = core.dotc_corelevel;
				STAT(DOTC_CORE_CREDITS_PINK_MAX, player) = core.dotc_nextlevel;
				STAT(DOTC_CORE_CREDITS_PINK, player) = core.dotc_credits;
				break;
			}
		}
	}
}

MUTATOR_HOOKFUNCTION(dotc, PlayerSpawn)
{
	entity player = M_ARGV(0, entity);

	dotc_ItemSpawn_Give(player);
}

MUTATOR_HOOKFUNCTION(dotc, PlayerDamage_SplitHealthArmor)
{
	entity frag_attacker = M_ARGV(1, entity);
	entity frag_target = M_ARGV(2, entity);

	// if g_dotc_guarddog != 0 every friendly AI will in range engage the attacker of another player.
	// FIXME - make turrets understand this, maybe make squads "stick" to target for X secs.
	if(autocvar_g_dotc_guarddog)
	if(IS_PLAYER(frag_attacker))
	{
		// reasoning: only squads have player targeting enabled, so this should work
		IL_EACH(g_dotc_squads, it.team == frag_target.team,
		{
			if(it.target_validate_flags & DOTC_TARGET_PLAYERS)
			if(dotc_ai_valid_target(it, frag_attacker) > 0)
				it.enemy = frag_attacker;
		});
	}
}

MUTATOR_HOOKFUNCTION(dotc, PlayHitsound)
{
	entity frag_victim = M_ARGV(0, entity);
	entity frag_attacker = M_ARGV(1, entity);

	// team checks done by main code
	if(frag_victim.takedamage)
	if(startsWith(frag_victim.classname, "dotc_") && (DIFF_TEAM(frag_victim, frag_attacker) || frag_victim.classname == "dotc_drone"))
		return true;
}

MUTATOR_HOOKFUNCTION(dotc, reset_map_global)
{
	FOREACH_CLIENT(IS_PLAYER(it),
	{
		PutClientInServer(it);
	});
}

MUTATOR_HOOKFUNCTION(dotc, CheckAllowedTeams)
{
	M_ARGV(0, float) = dotc_teams;
	return false;
}

MUTATOR_HOOKFUNCTION(dotc, ForbidDropCurrentWeapon)
{
	// no weapon drop on death
	return true;
}

MUTATOR_HOOKFUNCTION(dotc, ForbidThrowCurrentWeapon)
{
	// no weapon tossing
	return true;
}

MUTATOR_HOOKFUNCTION(dotc, TurretSpawn)
{
	entity turret = M_ARGV(0, entity);

	if(autocvar_g_dotc_turrets_norespawn && !(turret.damage_flags & TFL_DMG_DEATH_NORESPAWN))
		turret.damage_flags |= TFL_DMG_DEATH_NORESPAWN;

	if(autocvar_g_dotc_turrets_healthabs)
	{
		turret.max_health = autocvar_g_dotc_turrets_healthabs;
		SetResourceAmountExplicit(turret, RESOURCE_HEALTH, autocvar_g_dotc_turrets_healthabs);
	}
	else if(autocvar_g_dotc_turrets_healthmod)
	{
		turret.max_health *= autocvar_g_dotc_turrets_healthmod;
		SetResourceAmountExplicit(turret, RESOURCE_HEALTH, GetResourceAmount(turret, RESOURCE_HEALTH) * autocvar_g_dotc_turrets_healthmod);
	}

	turret.dotc_targetflags |= DOTC_TARGET_DRONES;
}

// scoreboard setup
void dotc_ScoreRules(int teams)
{
	GameRules_scoring(teams, 0, 0, {
		field_team(ST_DOTC_DESTROYED, "destroyed", SFL_SORT_PRIO_PRIMARY);
		field(SP_DOTC_DESTROYED, "destroyed", SFL_SORT_PRIO_PRIMARY);
		field(SP_DOTC_CREDITS_TAKEN, "credits", 0);
		field(SP_DOTC_DRONE_KILLS, "credits", 0);
		field(SP_DOTC_TURRET_KILLS, "credits", 0);
		field(SP_DOTC_FACTORY_KILLS, "credits", 0);
	});
}

void dotc_DelayedInit(entity this)
{
	for(entity tmp_entity = dotc_worldcorelist; tmp_entity; tmp_entity = tmp_entity.dotc_worldcorenext)
	{
		switch(tmp_entity.team)
		{
			case NUM_TEAM_1: BITSET_ASSIGN(dotc_teams, BIT(0)); break;
			case NUM_TEAM_2: BITSET_ASSIGN(dotc_teams, BIT(1)); break;
			case NUM_TEAM_3: BITSET_ASSIGN(dotc_teams, BIT(2)); break;
			case NUM_TEAM_4: BITSET_ASSIGN(dotc_teams, BIT(3)); break;
		}
	}

	dotc_ScoreRules(dotc_teams);
	round_handler_Spawn(dotc_CheckTeams, dotc_CheckWinner, dotc_RoundStart);
	round_handler_Init(5, autocvar_g_dotc_warmup, 0); // infinite time limit
}

void dotc_Initialize()
{
	InitializeEntity(NULL, dotc_DelayedInit, INITPRIO_GAMETYPE);
}

#endif

#ifdef CSQC

#endif
