//FEATURE: VIP gamemode, a mode in which one player becomes the team's VIP (very important player), when they die the round is over

#ifndef IMPLEMENTATION
#ifdef SVQC
AUTOCVAR_NOREF(g_vip, bool, false, "");
#endif
#include "vip.qh"
#endif

#ifdef IMPLEMENTATION

#ifdef SVQC
AUTOCVAR_NOREF(g_vip_soulgems, bool, true, "");
AUTOCVAR(g_vip_warmup, float, 10, "");
AUTOCVAR(g_vip_round_timelimit, float, 180, "");
AUTOCVAR(g_vip_point_limit, int, -1, "VIP point limit overriding the mapinfo specified one (use 0 to play without limit, and -1 to use mapinfo's limit)");
AUTOCVAR(g_vip_point_leadlimit, int, -1, "VIP point lead limit overriding the mapinfo specified one (use 0 to play without limit, and -1 to use mapinfo's limit)");
AUTOCVAR(g_vip_drop, bool, true, "allow dropping the soul gem before the round has started");
AUTOCVAR(g_vip_drop_punish_delay, float, 30, "");
AUTOCVAR(g_vip_drop_punish_count, int, 2, "");
AUTOCVAR(g_vip_drop_punish_time, float, 5, "");
AUTOCVAR(g_vip_pickup_wait, float, 2, "");

void vip_Initialize();

REGISTER_MUTATOR(vip, false)
{
	MUTATOR_STATIC();
	MUTATOR_ONADD
	{
		GameRules_teams(true);
		GameRules_limit_score(autocvar_g_vip_point_limit);
		GameRules_limit_lead(autocvar_g_vip_point_leadlimit);

		vip_Initialize();
	}

	return false;
}

int red_players, blue_players, yellow_players, pink_players;
void VIP_count_players()
{
	total_players = red_players = blue_players = yellow_players = pink_players = 0;

	FOREACH_CLIENT(IS_PLAYER(it),
	{
		++total_players;
		red_players += (it.team == NUM_TEAM_1);
		blue_players += (it.team == NUM_TEAM_2);
		yellow_players += (it.team == NUM_TEAM_3);
		pink_players += (it.team == NUM_TEAM_4);
	});
}

void vip_ClearVIPs()
{
	FOREACH_CLIENT(IS_PLAYER(it),
	{
		if(it.wps_vip)
		{
			WaypointSprite_Ping(it.wps_vip);
			WaypointSprite_Kill(it.wps_vip);
		}
		STAT(VIP, it) = false;
		GameRules_scoring_vip(it, false);
		it.gem_dropped = false;
	});

	for(int j = 0; j < 4; ++j)
		vip_count[j] = 0;
}

#define VIP_TEAMS_COUNT() ((red_players > 0) + (blue_players > 0) + (yellow_players > 0) + (pink_players > 0))
#define VIP_TEAMS_OK() (VIP_TEAMS_COUNT() == NumTeams(vip_teams))
#define VIP_COUNT() ((vip_count[0] > 0) + (vip_count[1] > 0) + (vip_count[2] > 0) + (vip_count[3] > 0))

int VIP_GetWinnerTeam()
{
	float winner_team = 0;
	if(vip_count[0] > 0)
		winner_team = NUM_TEAM_1;
	if(vip_count[1] > 0)
	{
		if(winner_team) return 0;
		winner_team = NUM_TEAM_2;
	}
	if(vip_count[2] > 0)
	{
		if(winner_team) return 0;
		winner_team = NUM_TEAM_3;
	}
	if(vip_count[3] > 0)
	{
		if(winner_team) return 0;
		winner_team = NUM_TEAM_4;
	}
	if(winner_team)
		return winner_team;
	return -1; // no player left
}

bool VIP_CheckWinner()
{
	if(round_handler_GetEndTime() > 0 && round_handler_GetEndTime() - time <= 0)
	{
		Send_Notification(NOTIF_ALL, NULL, MSG_CENTER, CENTER_ROUND_OVER);
		Send_Notification(NOTIF_ALL, NULL, MSG_INFO, INFO_ROUND_OVER);

		FOREACH_CLIENT(IS_PLAYER(it),
		{
			nades_Clear(it);
			if(STAT(VIP, it) && GetResourceAmount(it, RESOURCE_HEALTH) > 0)
				GameRules_scoring_add(it, VIP_SURVIVALS, 1);
		});

		vip_ClearVIPs();
		allowed_to_spawn = false;
		round_handler_Init(5, autocvar_g_vip_warmup, autocvar_g_vip_round_timelimit);
		return true;
	}

	VIP_count_players();
	if(VIP_COUNT() > 1)
		return false;

	float winner_team = VIP_GetWinnerTeam();
	if(winner_team > 0)
	{
		Send_Notification(NOTIF_ALL, NULL, MSG_CENTER, APP_TEAM_NUM(winner_team, CENTER_ROUND_TEAM_WIN));
		Send_Notification(NOTIF_ALL, NULL, MSG_INFO, APP_TEAM_NUM(winner_team, INFO_ROUND_TEAM_WIN));
		TeamScore_AddToTeam(winner_team, ST_VIP_SCORE, +1);

		FOREACH_CLIENT(IS_PLAYER(it),
		{
			if(STAT(VIP, it) && GetResourceAmount(it, RESOURCE_HEALTH) > 0 && it.team == winner_team)
				GameRules_scoring_add(it, VIP_SURVIVALS, 1);
		});

		play2all(SND(VIP_WIN(winner_team)));
	}
	else if(winner_team == -1)
	{
		Send_Notification(NOTIF_ALL, NULL, MSG_CENTER, CENTER_ROUND_TIED);
		Send_Notification(NOTIF_ALL, NULL, MSG_INFO, INFO_ROUND_TIED);

		FOREACH_CLIENT(IS_PLAYER(it),
		{
			if(STAT(VIP, it) && GetResourceAmount(it, RESOURCE_HEALTH) > 0)
				GameRules_scoring_add(it, VIP_SURVIVALS, 1);
		});
	}

	vip_ClearVIPs();

	allowed_to_spawn = false;

	FOREACH_CLIENT(IS_PLAYER(it),
	{
		nades_Clear(it);
	});

	round_handler_Init(5, autocvar_g_vip_warmup, autocvar_g_vip_round_timelimit);
	return true;
}

void VIP_RoundStart()
{
	FOREACH_CLIENT(IS_PLAYER(it),
	{
		if(STAT(VIP, it))
			Send_Notification(NOTIF_ONE, it, MSG_CENTER, APP_TEAM_NUM(it.team, CENTER_VIP_BEGIN));
		PutClientInServer(it);
	});
}

void vip_SelectVIPs()
{
	bool usegems = g_vip_soulgems;
	RandomSelection_Init();
	FOREACH_CLIENT(IS_PLAYER(it) && GetResourceAmount(it, RESOURCE_HEALTH) > 0,
	{
		if((redgem_count < 1 || !usegems) && it.team == NUM_TEAM_1 && vip_count[0] < 1)
			RandomSelection_AddEnt(it, 1, ((IS_REAL_CLIENT(it) && !it.gem_dropped) ? 1 : 0.5));
	});
	vip_SetVIP(RandomSelection_chosen_ent, NUM_TEAM_1);

	RandomSelection_Init();
	FOREACH_CLIENT(IS_PLAYER(it) && GetResourceAmount(it, RESOURCE_HEALTH) > 0,
	{
		if((bluegem_count < 1 || !usegems) && it.team == NUM_TEAM_2 && vip_count[1] < 1)
			RandomSelection_AddEnt(it, 1, ((IS_REAL_CLIENT(it) && !it.gem_dropped) ? 1 : 0.5));
	});
	vip_SetVIP(RandomSelection_chosen_ent, NUM_TEAM_2);
	
	RandomSelection_Init();
	FOREACH_CLIENT(IS_PLAYER(it) && GetResourceAmount(it, RESOURCE_HEALTH) > 0,
	{
		if((yellowgem_count < 1 || !usegems) && it.team == NUM_TEAM_3 && vip_count[2] < 1)
			RandomSelection_AddEnt(it, 1, ((IS_REAL_CLIENT(it) && !it.gem_dropped) ? 1 : 0.5));
	});
	vip_SetVIP(RandomSelection_chosen_ent, NUM_TEAM_3);
	
	RandomSelection_Init();
	FOREACH_CLIENT(IS_PLAYER(it) && GetResourceAmount(it, RESOURCE_HEALTH) > 0,
	{
		if((pinkgem_count < 1 || !usegems) && it.team == NUM_TEAM_4 && vip_count[3] < 1)
			RandomSelection_AddEnt(it, 1, ((IS_REAL_CLIENT(it) && !it.gem_dropped) ? 1 : 0.5));
	});
	vip_SetVIP(RandomSelection_chosen_ent, NUM_TEAM_4);
}
bool VIP_CheckTeams()
{
	static int prev_missing_teams_mask;
	int rc, bc, yc, pc;
	rc = ((redgem_count) ? redgem_count : 1);
	bc = ((bluegem_count) ? bluegem_count : 1);
	yc = ((yellowgem_count) ? yellowgem_count : 1);
	pc = ((pinkgem_count) ? pinkgem_count : 1);
	allowed_to_spawn = true;
	VIP_count_players();
	if(vip_count[0] < rc || vip_count[1] < bc || (NumTeams(vip_teams) >= 3 && vip_count[2] < yc) || (NumTeams(vip_teams) >= 4 && vip_count[3] < pc))
	{
		if(!g_vip_soulgems || redgem_count < 1 || bluegem_count < 1 || (NumTeams(vip_teams) >= 3 && yellowgem_count < 1) || (NumTeams(vip_teams) >= 4 && pinkgem_count < 1))
			vip_SelectVIPs();

		FOREACH_CLIENT(IS_PLAYER(it),
		{
			if((it.team == NUM_TEAM_1 && vip_count[0] > 0) || (it.team == NUM_TEAM_2 && vip_count[1] > 0)
				|| (NumTeams(vip_teams) >= 3 && it.team == NUM_TEAM_3 && vip_count[2] > 0) || (NumTeams(vip_teams) >= 4 && it.team == NUM_TEAM_4 && vip_count[3] > 0))
				Send_Notification(NOTIF_ONE, it, MSG_CENTER, CENTER_VIP_MISSING_ENEMY);
			else
				Send_Notification(NOTIF_ONE, it, MSG_CENTER, CENTER_VIP_MISSING);
		});
		return false;
	}
	if(VIP_TEAMS_OK())
	{
		if(prev_missing_teams_mask > 0)
			Kill_Notification(NOTIF_ALL, NULL, MSG_CENTER, CPID_MISSING_TEAMS);
		prev_missing_teams_mask = -1;
		return true;
	}
	if(total_players == 0)
	{
		if(prev_missing_teams_mask > 0)
			Kill_Notification(NOTIF_ALL, NULL, MSG_CENTER, CPID_MISSING_TEAMS);
		prev_missing_teams_mask = -1;
		return false;
	}
	int missing_teams_mask = (!redalive) + (!bluealive) * 2;
	if(NumTeams(vip_teams) >= 3) missing_teams_mask += (!yellowalive) * 4;
	if(NumTeams(vip_teams) >= 4) missing_teams_mask += (!pinkalive) * 8;
	if(prev_missing_teams_mask != missing_teams_mask)
	{
		Send_Notification(NOTIF_ALL, NULL, MSG_CENTER, CENTER_MISSING_TEAMS, missing_teams_mask);
		prev_missing_teams_mask = missing_teams_mask;
	}
	return false;
}

void vip_DropSoulGem(entity player)
{
	if(!STAT(VIP, player))
		return;

	if(player.wps_vip)
	{
		WaypointSprite_Ping(player.wps_vip);
		WaypointSprite_Kill(player.wps_vip);
	}

	SetResourceAmount(player, RESOURCE_HEALTH, 100); // reset these now?
	SetResourceAmount(player, RESOURCE_ARMOR, 0);
	STAT(VIP, player) = false;
	GameRules_scoring_vip(player, false);
	player.gem_dropped = true;
	int theirteam = Team_TeamToNumber(player.team);
	theirteam = ((theirteam == -1) ? 0 : theirteam - 1);
	vip_count[theirteam] -= 1;

	if(IS_REAL_CLIENT(player))
		Send_Notification(NOTIF_ONE, player, MSG_CENTER, CENTER_VIP_DROP_SELF);

	Send_Notification(NOTIF_ALL_EXCEPT, player, MSG_CENTER, CENTER_VIP_DROP, player.netname);
	Send_Notification(NOTIF_ALL, NULL, MSG_INFO, INFO_VIP_DROP, player.netname);

	play2all(SND(VIP_GEM_DROPPED));
}

MUTATOR_HOOKFUNCTION(vip, PlayerDies)
{
	entity frag_attacker = M_ARGV(1, entity);
	entity frag_target = M_ARGV(2, entity);

	if(STAT(VIP, frag_target))
	{
		if(IS_PLAYER(frag_attacker))
		{
			GameRules_scoring_add(frag_attacker, VIP_VIPKILLS, 1);
			GameRules_scoring_add(frag_attacker, SCORE, 1);
		}

		int theirteam = Team_TeamToNumber(frag_target.team);
		theirteam = ((theirteam == -1) ? 0 : theirteam - 1);
		vip_count[theirteam] -= 1;
		STAT(VIP, frag_target) = false;
		GameRules_scoring_vip(frag_target, false);

		play2all(SND(VIP_GEM_DROPPED));

		WaypointSprite_Ping(frag_target.wps_vip);
		WaypointSprite_Kill(frag_target.wps_vip);
	}
}

void vip_RemovePlayer(entity this)
{
	if(STAT(VIP, this))
	{
		int theirteam = Team_TeamToNumber(this.team);
		theirteam = ((theirteam == -1) ? 0 : theirteam - 1);
		vip_count[theirteam] -= 1;
		STAT(VIP, this) = false;
		GameRules_scoring_vip(this, false);
		WaypointSprite_Kill(this.wps_vip);
	}
}

MUTATOR_HOOKFUNCTION(vip, MakePlayerObserver)
{
	entity player = M_ARGV(0, entity);

	vip_RemovePlayer(player);
}

MUTATOR_HOOKFUNCTION(vip, ClientDisconnect)
{
	entity player = M_ARGV(0, entity);

	vip_RemovePlayer(player);
}

MUTATOR_HOOKFUNCTION(vip, PlayerPreThink)
{
	entity player = M_ARGV(0, entity);

	if(player.wps_vip)
	{
		WaypointSprite_UpdateHealth(player.wps_vip, 
			((autocvar_g_instagib) ? GetResourceAmount(player, RESOURCE_ARMOR) 
				: '1 0 0' * healtharmor_maxdamage(GetResourceAmount(player, RESOURCE_HEALTH), GetResourceAmount(player, RESOURCE_ARMOR), autocvar_g_balance_armor_blockpercent, DEATH_WEAPON.m_id)));
	}

	STAT(VIP_RED, player) = vip_count[0];
	STAT(VIP_BLUE, player) = vip_count[1];
	STAT(VIP_YELLOW, player) = vip_count[2];
	STAT(VIP_PINK, player) = vip_count[3];
}

MUTATOR_HOOKFUNCTION(vip, reset_map_players)
{
	FOREACH_CLIENT(IS_PLAYER(it),
	{
		PutClientInServer(it);
	});
}

MUTATOR_HOOKFUNCTION(vip, PlayerSpawn)
{
	entity player = M_ARGV(0, entity);

	if(STAT(VIP, player))
	{
		if(!autocvar_g_instagib)
			SetResourceAmount(player, RESOURCE_HEALTH, 200);
		SetResourceAmount(player, RESOURCE_ARMOR, ((autocvar_g_instagib) ? 5 : 200)); // 5 lives in instagib
	}
}

MUTATOR_HOOKFUNCTION(vip, PlayerRegen)
{
	entity player = M_ARGV(0, entity);

	// VIP regens to 200
	if(STAT(VIP, player))
	{
		M_ARGV(1, float) *= 2; // max_mod
		M_ARGV(2, float) = 0.7; // but with slower regen
	}
}

MUTATOR_HOOKFUNCTION(vip, SpectateCopy)
{
	entity spectatee = M_ARGV(0, entity);
	entity client = M_ARGV(1, entity);

	STAT(VIP, client) = STAT(VIP, spectatee); // make spectators see it too
}

MUTATOR_HOOKFUNCTION(vip, PlayerUseKey)
{
	if(MUTATOR_RETURNVALUE || game_stopped || round_handler_IsRoundStarted()) { return; }

	entity player = M_ARGV(0, entity);

	if((time > player.pickup_antispam) && (player.deadflag == DEAD_NO) && !player.vehicle) //&& (!player.vehicle || autocvar_g_vip_allow_vehicle_touch)) vehicle support coming soon(?)
	{
		if(autocvar_g_vip_drop && STAT(VIP, player))
		{
			if(player.drop_count == -1)
			{
				if(time > player.drop_prevtime + autocvar_g_vip_drop_punish_delay)
				{
					player.drop_prevtime = time;
					player.drop_count = 1;
					vip_DropSoulGem(player);
					return true;
				}
				else
				{
					Send_Notification(NOTIF_ONE, player, MSG_CENTER, CENTER_VIP_DROP_PUNISH, rint((player.drop_prevtime + autocvar_g_vip_drop_punish_delay) - time));
					return false;
				}
			}
			else
			{
				if(time > player.drop_prevtime + autocvar_g_vip_drop_punish_time) { player.drop_count = 1; }
				else { player.drop_count += 1; }
				if(player.drop_count >= autocvar_g_vip_drop_punish_count) { player.drop_count = -1; }

				player.drop_prevtime = time;
				vip_DropSoulGem(player);
				return true;
			}
		}
	}

	return true;
}

MUTATOR_HOOKFUNCTION(vip, OnEntityPreSpawn)
{
	if(!g_vip_soulgems)
		return;

	entity ent = M_ARGV(0, entity);

	if(ent.classname == "item_flag_team1")
	{
		vip_SpawnSoulGem(ent.origin, NUM_TEAM_1);
		return true;
	}

	if(ent.classname == "item_flag_team2")
	{
		vip_SpawnSoulGem(ent.origin, NUM_TEAM_2);
		return true;
	}
	
	if(ent.classname == "item_flag_team3")
	{
		vip_SpawnSoulGem(ent.origin, NUM_TEAM_3);
		return true;
	}
	
	if(ent.classname == "item_flag_team4")
	{
		vip_SpawnSoulGem(ent.origin, NUM_TEAM_4);
		return true;
	}
}

MUTATOR_HOOKFUNCTION(vip, CheckAllowedTeams)
{
	M_ARGV(0, float) = vip_teams;
}

vector vip_SoulGemColormod(int theteam, bool iseffect)
{
	if(iseffect)
	{
		switch(theteam)
		{
			case NUM_TEAM_1: return '1 0.4 0.4';
			case NUM_TEAM_2: return '0.4 0.4 1';
			case NUM_TEAM_3: return '1 1 0.4';
			case NUM_TEAM_4: return '1 0.4 1';
		}
	}
	else
	{
		switch(theteam)
		{
			case NUM_TEAM_1: return '1 0.8 0.8';
			case NUM_TEAM_2: return '0.8 0.8 1';
			case NUM_TEAM_3: return '1 1 0.8';
			case NUM_TEAM_4: return '1 0.8 1';
		}
	}

	return (iseffect) ? '0.2 0.2 0.2' : '0.1 0.1 0.1';
}

void vip_VIPWaypoints(entity player)
{
	WaypointSprite_Spawn(WP_VIP, 0, 0, player, FLAG_WAYPOINT_OFFSET, NULL, 0, player, wps_vip, true, RADARICON_FLAG);
	WaypointSprite_UpdateMaxHealth(player.wps_vip, ((autocvar_g_instagib) ? 5 : '1 0 0' * healtharmor_maxdamage(start_health, start_armorvalue, autocvar_g_balance_armor_blockpercent, DEATH_WEAPON.m_id) * 2));
	WaypointSprite_UpdateHealth(player.wps_vip, ((autocvar_g_instagib) ? GetResourceAmount(player, RESOURCE_HEALTH) : '1 0 0' * healtharmor_maxdamage(GetResourceAmount(player, RESOURCE_HEALTH), 
																		GetResourceAmount(player, RESOURCE_HEALTH), autocvar_g_balance_armor_blockpercent, DEATH_WEAPON.m_id)));
	WaypointSprite_UpdateTeamRadar(player.wps_vip, RADARICON_FLAGCARRIER, Team_ColorRGB(player.team));
}

void vip_SetVIP(entity player, float tm)
{
	if(!IS_PLAYER(player) || player == NULL || STAT(VIP, player))
		return; // TODO: check how this can be called at all for non players
	STAT(VIP, player) = true;
	GameRules_scoring_vip(player, true);
	if(!autocvar_g_instagib)
		SetResourceAmount(player, RESOURCE_HEALTH, 200);
	SetResourceAmount(player, RESOURCE_ARMOR, ((autocvar_g_instagib) ? 5 : 200));
	player.pickup_antispam = time + autocvar_g_vip_pickup_wait;

	int theirteam = Team_TeamToNumber(tm);
	theirteam = ((theirteam == -1) ? 0 : theirteam - 1);
	vip_count[theirteam] += 1;

	vip_VIPWaypoints(player);

	if(IS_REAL_CLIENT(player))
		Send_Notification(NOTIF_ONE, player, MSG_CENTER, CENTER_VIP_PICKUP_SELF);

	Send_Notification(NOTIF_ALL_EXCEPT, player, MSG_CENTER, CENTER_VIP_PICKUP, player.netname);
	Send_Notification(NOTIF_ALL, NULL, MSG_INFO, INFO_VIP_PICKUP, player.netname);
}

void vip_SoulGem_touch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher))
		return;

	if(this.gem_pickedup)
		return;

	if(STAT(VIP, toucher))
		return;

	if(STAT(FROZEN, toucher))
		return;

	if(!allowed_to_spawn)
		return;

	if(toucher.deadflag != DEAD_NO)
		return;

	if(DIFF_TEAM(toucher, this))
		return;
		
	if(round_handler_IsRoundStarted())
		return;

	this.gem_pickedup = true;
	this.owner = toucher;
	this.alpha = 0;
	this.enemy.alpha = 0;
	this.colormod = vip_SoulGemColormod(-this.team, false);
	this.enemy.colormod = vip_SoulGemColormod(-this.team, true);

	WaypointSprite_Kill(this.waypointsprite_attached);

	play2all(SND(VIP_GEM_PICKUP));

	vip_SetVIP(toucher, toucher.team);
}

void vip_SoulGem_think(entity this)
{
	this.glow_size = 256 + cos(time * 2) * 64;
	this.nextthink = time + 0.1;

	int theirteam = Team_TeamToNumber(this.team);
	theirteam = ((theirteam == -1) ? 0 : theirteam - 1);
	if(vip_count[theirteam] < 1 && this.gem_pickedup && allowed_to_spawn && this.owner && !STAT(VIP, this.owner) && !round_handler_IsRoundStarted())
		this.reset(this);
}

void vip_SoulGem_reset(entity this)
{
	this.gem_pickedup = false;
	this.alpha = this.enemy.alpha = 0.8;
	this.colormod = vip_SoulGemColormod(this.team, false);
	this.enemy.colormod = vip_SoulGemColormod(this.team, true);
	this.owner = NULL;

	// "run here" waypoint
	if(!this.waypointsprite_attached)
		WaypointSprite_Spawn(WP_KeyCarrierFinish, 0, 0, this, FLAG_WAYPOINT_OFFSET, NULL, this.team, this, waypointsprite_attached, true, RADARICON_FLAG);
}

void vip_DelayedGemSetup(entity this) // called after a gem is placed on a map
{
	// waypointsprites
	WaypointSprite_Spawn(WP_KeyCarrierFinish, 0, 0, this, FLAG_WAYPOINT_OFFSET, NULL, this.team, this, waypointsprite_attached, true, RADARICON_FLAG);
}

void vip_SpawnSoulGem(vector orig, float theteam)
{
	entity e = spawn();
	e.classname = "vip_soulgem";
	e.target = "###item###";
	e.team = theteam;
	e.movetype = MOVETYPE_NONE;
	settouch(e, vip_SoulGem_touch);
	setthink(e, vip_SoulGem_think);
	e.nextthink = time + random();
	e.solid = SOLID_TRIGGER;
	e.flags = FL_ITEM;
	IL_PUSH(g_items, e);
	e.reset = vip_SoulGem_reset;
	setmodel(e, MDL_VIP_GEM);
	setsize(e, '0 0 -35', '0 0 0');

	e.glow_size = 256;
	e.glow_color = (theteam == NUM_TEAM_1) ? 251 : 250;
	e.glow_trail = 1;

	e.enemy = spawn();
	e.enemy.enemy = e;
	e.enemy.classname = "vip_soulgem_effect";
	setmodel(e.enemy, MDL_VIP_GEM_RING);
	e.origin = orig;
	e.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_PLAYERCLIP;
	setorigin (e, e.origin);
	setattachment(e.enemy, e, "");

	move_out_of_solid(e);

	droptofloor(e);

	e.colormod = vip_SoulGemColormod(theteam, false);
	e.enemy.colormod = vip_SoulGemColormod(theteam, true);

	e.alpha = e.enemy.alpha = 0.8;
	e.effects = e.enemy.effects = (EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION);

	// update gem counts
	switch(theteam)
	{
		case NUM_TEAM_1: redgem_count += 1; break;
		case NUM_TEAM_2: bluegem_count += 1; break;
		case NUM_TEAM_3: yellowgem_count += 1; break;
		case NUM_TEAM_4: pinkgem_count += 1; break;
	}

	InitializeEntity(e, vip_DelayedGemSetup, INITPRIO_SETLOCATION);
}

// for maps without flags
spawnfunc(item_soulgem_team1)
{
	if(!g_vip || !g_vip_soulgems) { delete(this); return; }

	vip_SpawnSoulGem(this.origin, NUM_TEAM_1);

	setthink(this, SUB_Remove);
	this.nextthink = time + 0.1;
}

spawnfunc(item_soulgem_team2)
{
	if(!g_vip || !g_vip_soulgems) { delete(this); return; }

	vip_SpawnSoulGem(this.origin, NUM_TEAM_2);

	setthink(this, SUB_Remove);
	this.nextthink = time + 0.1;
}

spawnfunc(item_soulgem_team3)
{
	if(!g_vip || !g_vip_soulgems) { delete(this); return; }

	vip_SpawnSoulGem(this.origin, NUM_TEAM_3);

	setthink(this, SUB_Remove);
	this.nextthink = time + 0.1;
}

spawnfunc(item_soulgem_team4)
{
	if(!g_vip || !g_vip_soulgems) { delete(this); return; }

	vip_SpawnSoulGem(this.origin, NUM_TEAM_4);

	setthink(this, SUB_Remove);
	this.nextthink = time + 0.1;
}

// scoreboard setup
void vip_ScoreRules(int teams)
{
	GameRules_scoring(teams, SFL_SORT_PRIO_PRIMARY, 0, {
		field_team(ST_VIP_SCORE, "scores", SFL_SORT_PRIO_PRIMARY);
		field(SP_VIP_SURVIVALS, "survivals", 0);
		field(SP_VIP_VIPKILLS, "vipkills", SFL_SORT_PRIO_SECONDARY);
	});
}

void vip_DelayedInit(entity this) // Do this check with a delay so we can wait for teams to be set up.
{
	vip_teams = 0;

	if(redgem_count > 0) 	vip_teams |= BIT(0);
	if(bluegem_count > 0) 	vip_teams |= BIT(1);
	if(yellowgem_count > 0) vip_teams |= BIT(2);
	if(pinkgem_count > 0) 	vip_teams |= BIT(3);

	if(NumTeams(vip_teams) < 2) // not enough teams? fall back!
	{
		vip_teams = 0;
		vip_teams |= BIT(0);
		vip_teams |= BIT(1);
	}

	vip_ScoreRules(vip_teams);
}

void vip_Initialize()
{
	allowed_to_spawn = true;

	g_vip_soulgems = cvar("g_vip_soulgems");

	round_handler_Spawn(VIP_CheckTeams, VIP_CheckWinner, VIP_RoundStart);
	round_handler_Init(5, autocvar_g_vip_warmup, autocvar_g_vip_round_timelimit);

	InitializeEntity(NULL, vip_DelayedInit, INITPRIO_GAMETYPE);
}
#endif

#ifdef CSQC
// VIP mod icons
float redvip_prevframe, bluevip_prevframe, yellowvip_prevframe, pinkvip_prevframe; // status during previous frame
float redvip_prevstatus, bluevip_prevstatus, yellowvip_prevstatus, pinkvip_prevstatus; // last remembered status
float redvip_statuschange_time, bluevip_statuschange_time, yellowvip_statuschange_time, pinkvip_statuschange_time; // time when the status changed
void HUD_Mod_VIP_Reset(void)
{
	redvip_prevstatus = bluevip_prevstatus = yellowvip_prevstatus = pinkvip_prevstatus = redvip_prevframe = bluevip_prevframe = yellowvip_prevframe = pinkvip_prevframe = redvip_statuschange_time = bluevip_statuschange_time = yellowvip_statuschange_time = pinkvip_statuschange_time = 0;
}
void HUD_Mod_VIP(vector pos, vector mySize)
{
	vector redvip_pos, bluevip_pos, yellowvip_pos, pinkvip_pos;
	vector vip_size;
	vector e1, e2;
	float size1, size2;
	float fs, fs2, fs3;
	float f; // every function should have that

	float redvip, bluevip, yellowvip, pinkvip, is_vip; // current status
	float redvip_statuschange_elapsedtime, bluevip_statuschange_elapsedtime, yellowvip_statuschange_elapsedtime, pinkvip_statuschange_elapsedtime; // time since the status changed
	
	redvip = (STAT(VIP_RED) != 0);
	bluevip = (STAT(VIP_BLUE) != 0);
	yellowvip = (STAT(VIP_YELLOW) != 0);
	pinkvip = (STAT(VIP_PINK) != 0);
	is_vip = (STAT(VIP) != 0);
	
	if(redvip || bluevip || yellowvip || pinkvip)
		mod_active = 1;
	else
		mod_active = 0;

	// when status CHANGES, set old status into prevstatus and current status into status
	if (redvip != redvip_prevframe)
	{
		redvip_statuschange_time = time;
		redvip_prevstatus = redvip_prevframe;
		redvip_prevframe = redvip;
	}

	if (bluevip != bluevip_prevframe)
	{
		bluevip_statuschange_time = time;
		bluevip_prevstatus = bluevip_prevframe;
		bluevip_prevframe = bluevip;
	}
	
	if (yellowvip != yellowvip_prevframe)
	{
		yellowvip_statuschange_time = time;
		yellowvip_prevstatus = yellowvip_prevframe;
		yellowvip_prevframe = yellowvip;
	}
	
	if (pinkvip != pinkvip_prevframe)
	{
		pinkvip_statuschange_time = time;
		pinkvip_prevstatus = pinkvip_prevframe;
		pinkvip_prevframe = pinkvip;
	}

	redvip_statuschange_elapsedtime = time - redvip_statuschange_time;
	bluevip_statuschange_elapsedtime = time - bluevip_statuschange_time;
	yellowvip_statuschange_elapsedtime = time - yellowvip_statuschange_time;
	pinkvip_statuschange_elapsedtime = time - pinkvip_statuschange_time;
	
	switch(team_count)
	{
		default:
		case 2: fs = 0.5; fs2 = 0.5; fs3 = 0.5; break;
		case 3: fs = 1; fs2 = 0.35; fs3 = 0.35; break;
		case 4: fs = 0.75; fs2 = 0.25; fs3 = 0.5; break;
	}
	
	if(mySize_x > mySize_y)
	{
		size1 = mySize_x;
		size2 = mySize_y;
		e1 = eX;
		e2 = eY;
	}
	else
	{
		size1 = mySize_y;
		size2 = mySize_x;
		e1 = eY;
		e2 = eX;
	}
	
	switch(myteam)
	{
		default:
		case NUM_TEAM_1:
		{
			redvip_pos = pos;
			bluevip_pos = pos + eX * fs2 * size1;
			yellowvip_pos = pos - eX * fs2 * size1;
			pinkvip_pos = pos + eX * fs3 * size1;
			break;
		}
		case NUM_TEAM_2:
		{
			redvip_pos = pos + eX * fs2 * size1;
			bluevip_pos = pos;
			yellowvip_pos = pos - eX * fs2 * size1;
			pinkvip_pos = pos + eX * fs3 * size1;
			break;
		}
		case NUM_TEAM_3:
		{
			redvip_pos = pos + eX * fs3 * size1;
			bluevip_pos = pos - eX * fs2 * size1;
			yellowvip_pos = pos;
			pinkvip_pos = pos + eX * fs2 * size1;
			break;
		}
		case NUM_TEAM_4:
		{
			redvip_pos = pos - eX * fs2 * size1;
			bluevip_pos = pos + eX * fs3 * size1;
			yellowvip_pos = pos + eX * fs2 * size1;
			pinkvip_pos = pos;
			break;
		}
	}
	vip_size = e1 * fs * size1 + e2 * size2;
	
	string red_icon = "", red_icon_prevstatus = "";
	string blue_icon = "", blue_icon_prevstatus = "";
	string yellow_icon = "", yellow_icon_prevstatus = "";
	string pink_icon = "", pink_icon_prevstatus = "";
	
	if(redvip) { red_icon = "player_red"; }
	if(bluevip) { blue_icon = "player_blue"; }
	if(yellowvip) { yellow_icon = "player_yellow"; }
	if(pinkvip) { pink_icon = "player_pink"; }

	if(redvip_prevframe) { red_icon_prevstatus = "player_red"; }
	if(bluevip_prevframe) { blue_icon_prevstatus = "player_blue"; }
	if(yellowvip_prevframe) { yellow_icon_prevstatus = "player_yellow"; }
	if(pinkvip_prevframe) { pink_icon_prevstatus = "player_pink"; }

	if(is_vip)
	switch(myteam)
	{
		case NUM_TEAM_1: red_icon = "notify_balldropped"; break;
		case NUM_TEAM_2: blue_icon = "notify_balldropped"; break;
		case NUM_TEAM_3: yellow_icon = "notify_balldropped"; break;
		case NUM_TEAM_4: pink_icon = "notify_balldropped"; break;
	}

	f = bound(0, redvip_statuschange_elapsedtime*2, 1);
	if(red_icon_prevstatus && f < 1)
		drawpic_aspect_skin_expanding(redvip_pos, red_icon_prevstatus, vip_size, '1 1 1', panel_fg_alpha * 1, DRAWFLAG_NORMAL, f);
	if(red_icon)
		drawpic_aspect_skin(redvip_pos, red_icon, vip_size, '1 1 1', panel_fg_alpha * 1 * f, DRAWFLAG_NORMAL);

	f = bound(0, bluevip_statuschange_elapsedtime*2, 1);
	if(blue_icon_prevstatus && f < 1)
		drawpic_aspect_skin_expanding(bluevip_pos, blue_icon_prevstatus, vip_size, '1 1 1', panel_fg_alpha * 1, DRAWFLAG_NORMAL, f);
	if(blue_icon)
		drawpic_aspect_skin(bluevip_pos, blue_icon, vip_size, '1 1 1', panel_fg_alpha * 1 * f, DRAWFLAG_NORMAL);
		
	f = bound(0, yellowvip_statuschange_elapsedtime*2, 1);
	if(yellow_icon_prevstatus && f < 1)
		drawpic_aspect_skin_expanding(yellowvip_pos, yellow_icon_prevstatus, vip_size, '1 1 1', panel_fg_alpha * 1, DRAWFLAG_NORMAL, f);
	if(yellow_icon)
		drawpic_aspect_skin(yellowvip_pos, yellow_icon, vip_size, '1 1 1', panel_fg_alpha * 1 * f, DRAWFLAG_NORMAL);
		
	f = bound(0, pinkvip_statuschange_elapsedtime*2, 1);
	if(pink_icon_prevstatus && f < 1)
		drawpic_aspect_skin_expanding(pinkvip_pos, pink_icon_prevstatus, vip_size, '1 1 1', panel_fg_alpha * 1, DRAWFLAG_NORMAL, f);
	if(pink_icon)
		drawpic_aspect_skin(pinkvip_pos, pink_icon, vip_size, '1 1 1', panel_fg_alpha * 1 * f, DRAWFLAG_NORMAL);
}
#endif

#endif
