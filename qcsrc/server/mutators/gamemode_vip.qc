void VIP_count_players()
{
	total_players = red_players = blue_players = yellow_players = pink_players = 0;
	entity head;

	for(head = world; (head = find(head, classname, "player")); )
	{
		++total_players;
		red_players += (head.team == NUM_TEAM_1);
		blue_players += (head.team == NUM_TEAM_2);
		yellow_players += (head.team == NUM_TEAM_3);
		pink_players += (head.team == NUM_TEAM_4);
	}
}

void vip_ClearVIPs()
{
	entity head;
	float i;

	FOR_EACH_PLAYER(head)
	{
		if(head.wps_vip)
		{
			WaypointSprite_Ping(head.wps_vip);
			WaypointSprite_Kill(head.wps_vip);
		}
		head.isvip = FALSE;
		head.gem_dropped = FALSE;
	}

	for(i = 0; i < VIP_TEAMS; ++i)
		vip_count[i] = 0;
}

#define VIP_TEAMS_COUNT() ((red_players > 0) + (blue_players > 0) + (yellow_players > 0) + (pink_players > 0))
#define VIP_TEAMS_OK() (VIP_TEAMS_COUNT() == vip_teams)
#define VIP_COUNT() ((vip_count[NUM_TEAM_1] > 0) + (vip_count[NUM_TEAM_2] > 0) + (vip_count[NUM_TEAM_3] > 0) + (vip_count[NUM_TEAM_4] > 0))

float VIP_GetWinnerTeam()
{
	float winner_team = 0;
	if(vip_count[NUM_TEAM_1] > 0)
		winner_team = NUM_TEAM_1;
	if(vip_count[NUM_TEAM_2] > 0)
	{
		if(winner_team) return 0;
		winner_team = NUM_TEAM_2;
	}
	if(vip_count[NUM_TEAM_3] > 0)
	{
		if(winner_team) return 0;
		winner_team = NUM_TEAM_3;
	}
	if(vip_count[NUM_TEAM_4] > 0)
	{
		if(winner_team) return 0;
		winner_team = NUM_TEAM_4;
	}
	if(winner_team)
		return winner_team;
	return -1; // no player left
}

float VIP_CheckWinner()
{
	entity head;
	if(round_handler_GetEndTime() > 0 && round_handler_GetEndTime() - time <= 0)
	{
		Send_Notification(NOTIF_ALL, world, MSG_CENTER, CENTER_ROUND_OVER);
		Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_ROUND_OVER);
		
		nades_Clear(world);

		FOR_EACH_PLAYER(head) if(head.isvip && head.health > 0)
			PlayerScore_Add(head, SP_VIP_SURVIVALS, 1);

		vip_ClearVIPs();
		allowed_to_spawn = FALSE;
		round_handler_Init(5, autocvar_g_vip_warmup, autocvar_g_vip_round_timelimit);
		return 1;
	}

	VIP_count_players();
	if(VIP_COUNT() > 1)
		return 0;

	float winner_team = VIP_GetWinnerTeam();
	if(winner_team > 0)
	{
		Send_Notification(NOTIF_ALL, world, MSG_CENTER, APP_TEAM_NUM_4(winner_team, CENTER_ROUND_TEAM_WIN_));
		Send_Notification(NOTIF_ALL, world, MSG_INFO, APP_TEAM_NUM_4(winner_team, INFO_ROUND_TEAM_WIN_));
		TeamScore_AddToTeam(winner_team, ST_VIP_SCORE, +1);

		entity head;
		FOR_EACH_PLAYER(head)
		if(head.isvip && head.health > 0 && head.team == winner_team)
			PlayerScore_Add(head, SP_VIP_SURVIVALS, 1);

		switch(winner_team)
		{
			case NUM_TEAM_1: play2all("ctf/red_capture.wav"); break;
			case NUM_TEAM_2: play2all("ctf/blue_capture.wav"); break;
			case NUM_TEAM_3: play2all("ctf/yellow_capture.wav"); break;
			case NUM_TEAM_4: play2all("ctf/pink_capture.wav"); break;
		}
	}
	else if(winner_team == -1)
	{
		Send_Notification(NOTIF_ALL, world, MSG_CENTER, CENTER_ROUND_TIED);
		Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_ROUND_TIED);

		entity head;
		FOR_EACH_PLAYER(head)
		if(head.isvip && head.health > 0)
			PlayerScore_Add(head, SP_VIP_SURVIVALS, 1);
	}

	vip_ClearVIPs();

	allowed_to_spawn = FALSE;

	round_handler_Init(5, autocvar_g_vip_warmup, autocvar_g_vip_round_timelimit);

	nades_Clear(world);

	return 1;
}

void VIP_RoundStart()
{
	entity oldself = self;
	FOR_EACH_PLAYER(self)
	{
		if(self.isvip)
			Send_Notification(NOTIF_ONE, self, MSG_CENTER, APP_TEAM_ENT_4(self, CENTER_VIP_BEGIN_));
		PutClientInServer();
	}
	self = oldself;
}

void vip_SelectVIPs()
{
	float usegems = g_vip_soulgems;
	entity head;
	RandomSelection_Init();
	FOR_EACH_PLAYER(head) if(head.health > 0)
	if((redgem_count < 1 || !usegems) && head.team == NUM_TEAM_1 && vip_count[NUM_TEAM_1] < 1)
		RandomSelection_Add(head, 0, string_null, 1, ((IS_REAL_CLIENT(head) && !head.gem_dropped) ? 1 : 0.5));

	vip_SetVIP(RandomSelection_chosen_ent, NUM_TEAM_1);

	RandomSelection_Init();
	FOR_EACH_PLAYER(head) if(head.health > 0)
	if((bluegem_count < 1 || !usegems) && head.team == NUM_TEAM_2 && vip_count[NUM_TEAM_2] < 1)
		RandomSelection_Add(head, 0, string_null, 1, ((IS_REAL_CLIENT(head) && !head.gem_dropped) ? 1 : 0.5));

	vip_SetVIP(RandomSelection_chosen_ent, NUM_TEAM_2);
	
	RandomSelection_Init();
	FOR_EACH_PLAYER(head) if(head.health > 0)
	if((yellowgem_count < 1 || !usegems) && head.team == NUM_TEAM_3 && vip_count[NUM_TEAM_3] < 1)
		RandomSelection_Add(head, 0, string_null, 1, ((IS_REAL_CLIENT(head) && !head.gem_dropped) ? 1 : 0.5));

	vip_SetVIP(RandomSelection_chosen_ent, NUM_TEAM_3);
	
	RandomSelection_Init();
	FOR_EACH_PLAYER(head) if(head.health > 0)
	if((pinkgem_count < 1 || !usegems) && head.team == NUM_TEAM_4 && vip_count[NUM_TEAM_4] < 1)
		RandomSelection_Add(head, 0, string_null, 1, ((IS_REAL_CLIENT(head) && !head.gem_dropped) ? 1 : 0.5));

	vip_SetVIP(RandomSelection_chosen_ent, NUM_TEAM_4);
}

float VIP_CheckTeams()
{
	float rc, bc, yc, pc;
	rc = ((redgem_count) ? redgem_count : 1);
	bc = ((bluegem_count) ? bluegem_count : 1);
	yc = ((yellowgem_count) ? yellowgem_count : 1);
	pc = ((pinkgem_count) ? pinkgem_count : 1);
	allowed_to_spawn = TRUE;
	VIP_count_players();
	if(vip_count[NUM_TEAM_1] < rc || vip_count[NUM_TEAM_2] < bc || (vip_teams >= 3 && vip_count[NUM_TEAM_3] < yc) || (vip_teams >= 4 && vip_count[NUM_TEAM_4] < pc))
	{
		entity head;
		if(!g_vip_soulgems || redgem_count < 1 || bluegem_count < 1 || (vip_teams >= 3 && yellowgem_count < 1) || (vip_teams >= 4 && pinkgem_count < 1))
			vip_SelectVIPs();

		FOR_EACH_PLAYER(head)
		{
			if((head.team == NUM_TEAM_1 && vip_count[NUM_TEAM_1] > 0) || (head.team == NUM_TEAM_2 && vip_count[NUM_TEAM_2] > 0) || (vip_teams >= 3 && head.team == NUM_TEAM_3 && vip_count[NUM_TEAM_3] > 0) || (vip_teams >= 4 && head.team == NUM_TEAM_4 && vip_count[NUM_TEAM_4] > 0))
				Send_Notification(NOTIF_ONE, head, MSG_CENTER, CENTER_VIP_MISSING_ENEMY);
			else
				Send_Notification(NOTIF_ONE, head, MSG_CENTER, CENTER_VIP_MISSING);
		}
		return 0;
	}
	if(VIP_TEAMS_OK())
	{
		if(prev_total_players > 0)
			Kill_Notification(NOTIF_ALL, world, MSG_CENTER_CPID, CPID_MISSING_TEAMS);
		prev_total_players = -1;
		return 1;
	}
	if(prev_total_players != total_players)
	{
		float p1 = 0, p2 = 0, p3 = 0, p4 = 0;
		if(!red_players) p1 = NUM_TEAM_1;
		if(!blue_players) p2 = NUM_TEAM_2;
		if(!yellow_players) p3 = NUM_TEAM_3;
		if(!pink_players) p4 = NUM_TEAM_4;
		if(vip_teams < 3)
			p3 = 1; // don't count them
		if(vip_teams < 4)
			p4 = 1; // don't count them
		Send_Notification(NOTIF_ALL, world, MSG_CENTER, CENTER_MISSING_TEAMS, p1, p2, p3, p4);
		prev_total_players = total_players;
	}
	return 0;
}

void vip_DropSoulGem(entity player)
{
	if(!player.isvip)
		return;

	if(player.wps_vip)
	{
		WaypointSprite_Ping(player.wps_vip);
		WaypointSprite_Kill(player.wps_vip);
	}

	player.health = 100; // reset these now?
	player.armorvalue = 0;
	player.isvip = FALSE;
	player.gem_dropped = TRUE;
	vip_count[player.team] -= 1;

	if(IS_REAL_CLIENT(player))
		Send_Notification(NOTIF_ONE, player, MSG_CENTER, CENTER_VIP_DROP_SELF);

	Send_Notification(NOTIF_ALL_EXCEPT, player, MSG_CENTER, CENTER_VIP_DROP, player.netname);
	Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_VIP_DROP, player.netname);

	play2all("kh/destroy.wav");
}

MUTATOR_HOOKFUNCTION(vip_PlayerDies)
{
	if(frag_target.isvip)
	{
		if(IS_PLAYER(frag_attacker))
		{
			PlayerScore_Add(frag_attacker, SP_VIP_VIPKILLS, 1);
			PlayerScore_Add(frag_attacker, SP_SCORE, 1);
		}

		vip_count[frag_target.team] -= 1;
		frag_target.isvip = FALSE;

		play2all("kh/destroy.wav");

		WaypointSprite_Ping(frag_target.wps_vip);
		WaypointSprite_Kill(frag_target.wps_vip);
	}

	return FALSE;
}

MUTATOR_HOOKFUNCTION(vip_RemovePlayer)
{
	if(self.isvip)
	{
		vip_count[self.team] -= 1;
		self.isvip = FALSE;
		WaypointSprite_Kill(self.wps_vip);
	}

	return FALSE;
}

MUTATOR_HOOKFUNCTION(vip_PlayerThink)
{
	if(self.wps_vip)
		WaypointSprite_UpdateHealth(self.wps_vip, ((g_minstagib) ? self.armorvalue : '1 0 0' * healtharmor_maxdamage(self.health, self.armorvalue, autocvar_g_balance_armor_blockpercent, DEATH_WEAPON)));

	self.stat_vip_red = vip_count[NUM_TEAM_1];
	self.stat_vip_blue = vip_count[NUM_TEAM_2];
	self.stat_vip_yellow = vip_count[NUM_TEAM_3];
	self.stat_vip_pink = vip_count[NUM_TEAM_4];

	return FALSE;
}

MUTATOR_HOOKFUNCTION(vip_ResetMap)
{
	FOR_EACH_PLAYER(self)
		PutClientInServer();

	return TRUE;
}

MUTATOR_HOOKFUNCTION(vip_PlayerSpawn)
{
	if(self.isvip)
	{
		if(!g_minstagib)
			self.health = 200;
		self.armorvalue = ((g_minstagib) ? 5 : 200); // 5 lives in minstagib
	}

	return FALSE;
}

MUTATOR_HOOKFUNCTION(vip_PlayerRegen)
{
	// VIP regens to 200
	if(self.isvip)
	{
		regen_mod_max *= 2;
		regen_mod_regen = 0.7; // but with slower regen speed
	}

	return FALSE;
}

MUTATOR_HOOKFUNCTION(vip_PlayerUseKey)
{
	if(MUTATOR_RETURNVALUE || gameover || round_handler_IsRoundStarted()) { return FALSE; }

	entity player = self;

	if((time > player.pickup_antispam) && (player.deadflag == DEAD_NO) && !player.vehicle) //&& (!player.vehicle || autocvar_g_vip_allow_vehicle_touch)) vehicle support coming soon(?)
	{
		if(autocvar_g_vip_drop && player.isvip)
		{
			if(player.drop_count == -1)
			{
				if(time > player.drop_prevtime + autocvar_g_vip_drop_punish_delay)
				{
					player.drop_prevtime = time;
					player.drop_count = 1;
					vip_DropSoulGem(player);
					return TRUE;
				}
				else
				{
					Send_Notification(NOTIF_ONE, player, MSG_CENTER, CENTER_VIP_DROP_PUNISH, rint((player.drop_prevtime + autocvar_g_vip_drop_punish_delay) - time));
					return FALSE;
				}
			}
			else
			{
				if(time > player.drop_prevtime + autocvar_g_vip_drop_punish_time) { player.drop_count = 1; }
				else { player.drop_count += 1; }
				if(player.drop_count >= autocvar_g_vip_drop_punish_count) { player.drop_count = -1; }

				player.drop_prevtime = time;
				vip_DropSoulGem(player);
				return TRUE;
			}
		}
	}

	return TRUE;
}

MUTATOR_HOOKFUNCTION(vip_OnEntityPreSpawn)
{
	if(!g_vip_soulgems)
		return FALSE;

	if(self.classname == "item_flag_team1")
	{
		vip_SpawnSoulGem(self.origin, NUM_TEAM_1);
		return TRUE;
	}

	if(self.classname == "item_flag_team2")
	{
		vip_SpawnSoulGem(self.origin, NUM_TEAM_2);
		return TRUE;
	}
	
	if(self.classname == "item_flag_team3")
	{
		vip_SpawnSoulGem(self.origin, NUM_TEAM_3);
		return TRUE;
	}
	
	if(self.classname == "item_flag_team4")
	{
		vip_SpawnSoulGem(self.origin, NUM_TEAM_4);
		return TRUE;
	}

	return FALSE;
}

MUTATOR_HOOKFUNCTION(vip_GetTeamCount)
{
	ret_float = vip_teams;
	return FALSE;
}

vector vip_SoulGemColormod(float theteam, float iseffect)
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
	WaypointSprite_Spawn("vip", 0, 0, player, FLAG_WAYPOINT_OFFSET, world, 0, player, wps_vip, TRUE, RADARICON_FLAG, Team_ColorRGB(player.team));
	WaypointSprite_UpdateMaxHealth(player.wps_vip, ((g_minstagib) ? 5 : '1 0 0' * healtharmor_maxdamage(start_health, start_armorvalue, autocvar_g_balance_armor_blockpercent, DEATH_WEAPON) * 2));
	WaypointSprite_UpdateHealth(player.wps_vip, ((g_minstagib) ? self.armorvalue : '1 0 0' * healtharmor_maxdamage(player.health, player.armorvalue, autocvar_g_balance_armor_blockpercent, DEATH_WEAPON)));
	WaypointSprite_UpdateTeamRadar(player.wps_vip, RADARICON_FLAGCARRIER, Team_ColorRGB(player.team));
}

void vip_SetVIP(entity player, float tm)
{
	if(!IS_PLAYER(player) || player == world || player.isvip)
		return; // TODO: check how this can be called at all for non players
	player.isvip = TRUE;
	if(!g_minstagib)
		player.health = 200;
	player.armorvalue = ((g_minstagib) ? 5 : 200);
	player.pickup_antispam = time + autocvar_g_vip_pickup_wait;

	vip_count[tm] += 1;

	vip_VIPWaypoints(player);

	if(IS_REAL_CLIENT(player))
		Send_Notification(NOTIF_ONE, player, MSG_CENTER, CENTER_VIP_PICKUP_SELF);

	Send_Notification(NOTIF_ALL_EXCEPT, player, MSG_CENTER, CENTER_VIP_PICKUP, player.netname);
	Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_VIP_PICKUP, player.netname);
}

void vip_SoulGem_touch()
{
	if(!IS_PLAYER(other))
		return;

	if(self.gem_pickedup)
		return;

	if(other.isvip)
		return;

	if(!allowed_to_spawn)
		return;

	if(other.deadflag != DEAD_NO)
		return;

	if(DIFF_TEAM(other, self))
		return;
		
	if(round_handler_IsRoundStarted())
		return;

	self.gem_pickedup = 1;
	self.owner = other;
	self.alpha = 0;
	self.enemy.alpha = 0;
	self.colormod = vip_SoulGemColormod(-self.team, FALSE);
	self.enemy.colormod = vip_SoulGemColormod(-self.team, TRUE);

	WaypointSprite_Kill(self.waypointsprite_attached);

	play2all("kh/capture.wav");

	vip_SetVIP(other, other.team);
}

void vip_SoulGem_think()
{
	self.glow_size = 256 + cos(time * 2) * 64;
	self.nextthink = time + 0.1;

	if(vip_count[self.team] < 1 && self.gem_pickedup && allowed_to_spawn && self.owner && !self.owner.isvip && !round_handler_IsRoundStarted())
		self.reset();
}

void vip_SoulGem_reset()
{
	self.gem_pickedup = 0;
	self.alpha = self.enemy.alpha = 0.8;
	self.colormod = vip_SoulGemColormod(self.team, FALSE);
	self.enemy.colormod = vip_SoulGemColormod(self.team, TRUE);
	self.owner = world;

	// "run here" waypoint
	if(!self.waypointsprite_attached)
		WaypointSprite_Spawn("keycarrier-finish", 0, 0, self, FLAG_WAYPOINT_OFFSET, world, self.team, self, waypointsprite_attached, TRUE, RADARICON_FLAG, '0 1 1');
}

void vip_DelayedGemSetup() // called after a gem is placed on a map
{
	// waypointsprites
	WaypointSprite_Spawn("keycarrier-finish", 0, 0, self, FLAG_WAYPOINT_OFFSET, world, self.team, self, waypointsprite_attached, TRUE, RADARICON_FLAG, '0 1 1');
}

void vip_SpawnSoulGem(vector orig, float theteam)
{
	entity e = spawn();
	e.classname = "vip_soulgem";
	e.target = "###item###";
	e.team = theteam;
	e.movetype = MOVETYPE_NONE;
	e.touch = vip_SoulGem_touch;
	e.think = vip_SoulGem_think;
	e.nextthink = time + random();
	e.solid = SOLID_TRIGGER;
	e.flags = FL_ITEM;
	e.reset = vip_SoulGem_reset;
	setmodel(e, "models/runematch/rune.mdl");
	setsize(e, '0 0 -35', '0 0 0');

	e.glow_size = 256;
	e.glow_color = (theteam == NUM_TEAM_1) ? 251 : 250;
	e.glow_trail = 1;

	e.enemy = spawn();
	e.enemy.enemy = e;
	e.enemy.classname = "vip_soulgem_effect";
	setmodel(e.enemy, "models/runematch/curse.mdl");
	e.origin = orig;
	e.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_PLAYERCLIP;
	setorigin (e, e.origin);
	setattachment(e.enemy, e, "");

	if (!move_out_of_solid(e))
		bprint("\x01^!WARNING: ^7failed to move soulgem out of solid\n");

	entity oldself;
	oldself = self;
	self = e;
	droptofloor();
	self = oldself;

	e.colormod = vip_SoulGemColormod(theteam, FALSE);
	e.enemy.colormod = vip_SoulGemColormod(theteam, TRUE);

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
void spawnfunc_item_soulgem_team1()
{
	if(!g_vip || !g_vip_soulgems) { remove(self); return; }

	vip_SpawnSoulGem(self.origin, NUM_TEAM_1);

	self.think = SUB_Remove;
	self.nextthink = time + 0.1;
}

void spawnfunc_item_soulgem_team2()
{
	if(!g_vip || !g_vip_soulgems) { remove(self); return; }

	vip_SpawnSoulGem(self.origin, NUM_TEAM_2);

	self.think = SUB_Remove;
	self.nextthink = time + 0.1;
}

void spawnfunc_item_soulgem_team3()
{
	if(!g_vip || !g_vip_soulgems) { remove(self); return; }

	vip_SpawnSoulGem(self.origin, NUM_TEAM_3);

	self.think = SUB_Remove;
	self.nextthink = time + 0.1;
}

void spawnfunc_item_soulgem_team4()
{
	if(!g_vip || !g_vip_soulgems) { remove(self); return; }

	vip_SpawnSoulGem(self.origin, NUM_TEAM_4);

	self.think = SUB_Remove;
	self.nextthink = time + 0.1;
}

// scoreboard setup
void vip_ScoreRules()
{
	CheckAllowedTeams(world);
	ScoreRules_basics(vip_teams, SFL_SORT_PRIO_PRIMARY, 0, TRUE);
	ScoreInfo_SetLabel_PlayerScore(SP_VIP_SURVIVALS,	"survivals",	0);
	ScoreInfo_SetLabel_PlayerScore(SP_VIP_VIPKILLS,		"vipkills",		SFL_SORT_PRIO_SECONDARY);
	ScoreInfo_SetLabel_TeamScore(  ST_VIP_SCORE,		"scores",		SFL_SORT_PRIO_PRIMARY);
	ScoreRules_basics_end();
}

void vip_DelayedInit() // Do this check with a delay so we can wait for teams to be set up.
{
	vip_teams = 2;
	
	if(yellowgem_count > 0) vip_teams = max(3, vip_teams);
	if(pinkgem_count > 0) vip_teams = max(4, vip_teams);
	
	if(autocvar_g_vip_teams >= 2)
		vip_teams = autocvar_g_vip_teams;

	vip_teams = bound(2, vip_teams, 4);
	
	vip_ScoreRules();
}

void vip_Initialize()
{
	allowed_to_spawn = TRUE;

	g_vip_soulgems = cvar("g_vip_soulgems");

	round_handler_Spawn(VIP_CheckTeams, VIP_CheckWinner, VIP_RoundStart);
	round_handler_Init(5, autocvar_g_vip_warmup, autocvar_g_vip_round_timelimit);

	precache_sound("kh/capture.wav");
	precache_sound("kh/destroy.wav");
	precache_sound("ctf/red_capture.wav");
	precache_sound("ctf/blue_capture.wav");
	precache_sound("ctf/yellow_capture.wav");
	precache_sound("ctf/pink_capture.wav");
	
	precache_model("models/runematch/rune.mdl");
	precache_model("models/runematch/curse.mdl");

	addstat(STAT_VIP, AS_INT, isvip);
	addstat(STAT_VIP_RED, AS_FLOAT, stat_vip_red);
	addstat(STAT_VIP_BLUE, AS_FLOAT, stat_vip_blue);
	addstat(STAT_VIP_YELLOW, AS_FLOAT, stat_vip_yellow);
	addstat(STAT_VIP_PINK, AS_FLOAT, stat_vip_pink);

	InitializeEntity(world, vip_DelayedInit, INITPRIO_GAMETYPE);
}

MUTATOR_DEFINITION(gamemode_vip)
{
	MUTATOR_HOOK(PlayerDies, vip_PlayerDies, CBC_ORDER_ANY);
	MUTATOR_HOOK(ClientDisconnect, vip_RemovePlayer, CBC_ORDER_ANY);
	MUTATOR_HOOK(MakePlayerObserver, vip_RemovePlayer, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerPreThink, vip_PlayerThink, CBC_ORDER_ANY);
	MUTATOR_HOOK(reset_map_players, vip_ResetMap, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerSpawn, vip_PlayerSpawn, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerRegen, vip_PlayerRegen, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerUseKey, vip_PlayerUseKey, CBC_ORDER_ANY);
	MUTATOR_HOOK(OnEntityPreSpawn, vip_OnEntityPreSpawn, CBC_ORDER_FIRST);
	MUTATOR_HOOK(GetTeamCount, vip_GetTeamCount, CBC_ORDER_ANY);

	MUTATOR_ONADD
	{
		if(time > 1) // game loads at time 1
			error("This is a game type and it cannot be added at runtime.");
		vip_Initialize();
	}

	MUTATOR_ONROLLBACK_OR_REMOVE
	{
		// we actually cannot roll back vip_Initialize here
		// BUT: we don't need to! If this gets called, adding always
		// succeeds.
	}

	MUTATOR_ONREMOVE
	{
		print("This is a game type and it cannot be removed at runtime.");
		return -1;
	}

	return 0;
}
