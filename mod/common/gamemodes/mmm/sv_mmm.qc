#include "sv_mmm.qh"

AUTOCVAR(g_mmm_murderer_count, float, 0.25, "number of players who will become murderers, set between 0 and 0.9 to use a multiplier of the current players, or 1 and above to specify an exact number of players");
AUTOCVAR(g_mmm_detective_count, float, 0.125, "number of players who will become detectives, set between 0 and 0.9 to use a multiplier of the current players, or 1 and above, to specify an exact number of players. 0 = no detectives");
AUTOCVAR(g_mmm_round_timelimit, float, 180, "round time limit in seconds");
AUTOCVAR(g_mmm_warmup, float, 10, "how long the players will have time to run around the map before the round starts");
AUTOCVAR(g_mmm_punish_teamkill, bool, false, "enable option to kill the player when they kill an ally");
AUTOCVAR(g_mmm_reward_civilian, bool, true, "give a point to all civilian players if the round timelimit is reached, in addition to the points given for kills");
AUTOCVAR(g_mmm_reward_detective, bool, true, "give a point to all detective players if investigated corpses");
AUTOCVAR(g_mmm_max_karma_points, float, 1000, "limit of maximum number of karma points will have in the server"); //LegendGuard sets Karma points 21-02-2021
AUTOCVAR(g_mmm_min_karma_points, float, 550, "limit where number of karma points can be reached when are being decreased");
AUTOCVAR(g_mmm_karma_bankick_tool, int, 1, "tool for strict rules when karma is low: '0' nothing does, '1' forces player to spec, '2' kicks player, '3' bans player"); //LegendGuard sets a ban tool for server admins 11-03-2021
AUTOCVAR(g_mmm_karma_bantime, float, 1800, "number of seconds to ban someone with very low karma"); //karma ban seconds
AUTOCVAR(g_mmm_karma_damageactive, bool, true, "enable karma damage rule. If a player's karma is low, they will not do as much damage as a player who has high or full karma"); //LegendGuard sets Karma damage setting if active 20-03-2021
AUTOCVAR(g_mmm_karma_severity, float, 0.25, "how severe karma is to decrease karma points to the players [0.1 - 1.0]");
AUTOCVAR(g_mmm_karma_damagepunishmentdeal, float, 20, "punishment damage points when player kills an ally"); //LegendGuard sets Karma punishment damage setting if player kills an ally 28-03-2021

// Detective is a created team, this team is added inside Civilians team

void mmm_FakeTimeLimit(entity e, float t)
{
	if(!IS_REAL_CLIENT(e))
		return;
#if 0
	msg_entity = e;
	WriteByte(MSG_ONE, 3); // svc_updatestat
	WriteByte(MSG_ONE, 236); // STAT_TIMELIMIT
	if(t < 0)
		WriteCoord(MSG_ONE, autocvar_timelimit);
	else
		WriteCoord(MSG_ONE, (t + 1) / 60);
#else
	STAT(MMM_ROUNDTIMER, e) = t;
#endif
}

void nades_Clear(entity player);

void karma_Control(entity it)
{
	float masksize = autocvar_g_ban_default_masksize;
	float bantime = autocvar_g_mmm_karma_bantime;
	if(it.karmapoints >= autocvar_g_mmm_max_karma_points)
	{
		//Resets karmapoints to maintain the maximum
		//PrintToChatAll("^3REWARD ^1MAXIMUM RESET");
		GameRules_scoring_add(it, MMM_KARMA, autocvar_g_mmm_max_karma_points - it.karmapoints);
		it.karmapoints = autocvar_g_mmm_max_karma_points;
	}
	else if(it.karmapoints <= autocvar_g_mmm_min_karma_points)
	{
		switch (autocvar_g_mmm_karma_bankick_tool)
		{
			//do nothing
			case 0: return;
			//force to spec
			case 1: PutObserverInServer(it, true); return;
			//kick
			case 2: dropclient(it); return;
			//ban and kick
			case 3: Ban_KickBanClient(it, bantime, masksize, "Too low karma"); return;
			default: PutObserverInServer(it, true); return;
		}
	}
}

void karmaLoseDifference(entity attacker, entity target)
{
	if (autocvar_g_mmm_karma_severity <= 0.09)
		autocvar_g_mmm_karma_severity = 0.1;
	else if (autocvar_g_mmm_karma_severity > 1)
		autocvar_g_mmm_karma_severity = 1;
	
	//BASIC MATH THEORY: example: 1000 * 0.3 * (0.1 + 0.4) * 0.25 // karma points reduce when player attacked to other player
	if (target.karmapoints < attacker.karmapoints)
	{
		float decreasekarma = - ( target.karmapoints * random() * ( 0.1 + random() ) * autocvar_g_mmm_karma_severity );
		GameRules_scoring_add(attacker, MMM_KARMA, decreasekarma);
		attacker.karmapoints = attacker.karmapoints + decreasekarma;
	}
	else if (target.karmapoints > attacker.karmapoints)
	{
		float decreasekarma = - ( target.karmapoints * random() * ( 0.1 + random() ) * autocvar_g_mmm_karma_severity );
		GameRules_scoring_add(attacker, MMM_KARMA, decreasekarma);
		attacker.karmapoints = attacker.karmapoints + decreasekarma;
	}
	else
	{
		float decreasekarma = - ( target.karmapoints * random() * ( 0.1 + random() ) * autocvar_g_mmm_karma_severity );
		GameRules_scoring_add(attacker, MMM_KARMA, decreasekarma);
		attacker.karmapoints = attacker.karmapoints + decreasekarma;
	}
}

void karmaWinDifference(entity it)
{
	GameRules_scoring_add(it, SCORE, 1); // reward civilians who make it to the end of the round time limit
	float increasekarma = ( autocvar_g_mmm_min_karma_points * random() * ( 0.1 + random() ) * 0.12 );
	GameRules_scoring_add(it, MMM_KARMA, increasekarma);
	it.karmapoints = it.karmapoints + increasekarma;
	karma_Control(it);
}

void mmm_UpdateScores(bool timed_out)
{
	// give players their hard-earned kills now that the round is over
	FOREACH_CLIENT(true,
	{
		it.totalfrags += it.mmm_validkills;
		if(it.mmm_validkills)
		{
			GameRules_scoring_add(it, SCORE, it.mmm_validkills);
		}
		it.mmm_validkills = 0;
		// player survived the round
		if(IS_PLAYER(it) && !IS_DEAD(it)) // LegendGuard adds something for Karma 21-02-2021
		{
			if((autocvar_g_mmm_reward_civilian && timed_out && it.mmm_status == MMM_STATUS_CIVILIAN) 
			|| (autocvar_g_mmm_reward_civilian && !timed_out && it.mmm_status == MMM_STATUS_CIVILIAN))
			{
				karmaWinDifference(it);
				//PrintToChatAll(sprintf("^2REWARD ^7it.karmapoints: ^1%f", it.karmapoints));
			}

			//Detective reward after investigated a corpse
			if((autocvar_g_mmm_reward_detective && timed_out && it.mmm_status == MMM_STATUS_DETECTIVE) 
			|| (autocvar_g_mmm_reward_detective && !timed_out && it.mmm_status == MMM_STATUS_DETECTIVE))
			{
				if (it.investigated == true)
				{
					karmaWinDifference(it);
					it.investigated = false;
				}
			}

			if(it.mmm_status == MMM_STATUS_MURDERER)
			{
				karmaWinDifference(it);
				//PrintToChatAll(sprintf("^1MURDERER ^7it.karmapoints: ^1%f", it.karmapoints));
			}
		}
	});
}

float mmm_CheckWinner()
{
	if(round_handler_GetEndTime() > 0 && round_handler_GetEndTime() - time <= 0)
	{
		// if the match times out, civilians win too!
		Send_Notification(NOTIF_ALL, NULL, MSG_CENTER, CENTER_MMM_CIVILIAN_WIN);
		Send_Notification(NOTIF_ALL, NULL, MSG_INFO, INFO_MMM_CIVILIAN_WIN);
		FOREACH_CLIENT(true,
		{
			if(IS_PLAYER(it))
				nades_Clear(it);
			mmm_FakeTimeLimit(it, -1);
			karma_Control(it);
		});

		mmm_UpdateScores(true);

		allowed_to_spawn = false;
		game_stopped = true;
		round_handler_Init(5, autocvar_g_mmm_warmup, autocvar_g_mmm_round_timelimit);
		return 1;
	}

	int civilian_count = 0, murderer_count = 0, detective_count = 0;
	FOREACH_CLIENT(IS_PLAYER(it) && !IS_DEAD(it),
	{
		if(it.mmm_status == MMM_STATUS_CIVILIAN)
			civilian_count++;
		else if(it.mmm_status == MMM_STATUS_MURDERER)
			murderer_count++;
		else if(it.mmm_status == MMM_STATUS_DETECTIVE) //LegendGuard adds detective_count 20-02-2021 
			detective_count++;
	});
	if(civilian_count > 0 && murderer_count > 0)
	{
		return 0;
	}

	if(murderer_count > 0) // murderers win
	{
		Send_Notification(NOTIF_ALL, NULL, MSG_CENTER, CENTER_MMM_MURDERER_WIN);
		Send_Notification(NOTIF_ALL, NULL, MSG_INFO, INFO_MMM_MURDERER_WIN);
	}
	else if(civilian_count > 0) // civilians win
	{
		Send_Notification(NOTIF_ALL, NULL, MSG_CENTER, CENTER_MMM_CIVILIAN_WIN);
		Send_Notification(NOTIF_ALL, NULL, MSG_INFO, INFO_MMM_CIVILIAN_WIN);
	}
	else if (detective_count > 0 && civilian_count > 0) // detectives are same as civilians win
	{
		Send_Notification(NOTIF_ALL, NULL, MSG_CENTER, CENTER_MMM_CIVILIAN_WIN);
		Send_Notification(NOTIF_ALL, NULL, MSG_INFO, INFO_MMM_CIVILIAN_WIN);
	}
	else
	{
		Send_Notification(NOTIF_ALL, NULL, MSG_CENTER, CENTER_ROUND_TIED);
		Send_Notification(NOTIF_ALL, NULL, MSG_INFO, INFO_ROUND_TIED);
	}

	mmm_UpdateScores(false);

	allowed_to_spawn = false;
	game_stopped = true;
	round_handler_Init(5, autocvar_g_mmm_warmup, autocvar_g_mmm_round_timelimit);

	FOREACH_CLIENT(true,
	{
		if(IS_PLAYER(it))
		{
			it.respawn_flags = RESPAWN_SILENT; //CSQC print output respawn lib.qh error fix
			nades_Clear(it);
		}
		mmm_FakeTimeLimit(it, -1);
		karma_Control(it);
	});

	return 1;
}

void Karma_WarningCheck(entity it)
{
	float totalmeankarma = ((autocvar_g_mmm_max_karma_points + autocvar_g_mmm_min_karma_points + it.karmapoints) / 3);
	if (it.karmapoints <= totalmeankarma)
	{
		Send_Notification(NOTIF_ONE_ONLY, it, MSG_INFO, INFO_MMM_KARMAWARNING);
		//centerprint(it, strcat(BOLD_OPERATOR, "^1KARMA WARNING!\n^3Here, have the Rifle!"));
		GiveWeapon(it, WEP_RIFLE.m_id, OP_PLUS, 1);
	}
}

void mmm_RoundStart()
{
	allowed_to_spawn = boolean(warmup_stage);
	int playercount = 0;

	FOREACH_CLIENT(true,
	{
		if(IS_PLAYER(it) && !IS_DEAD(it))
		{
			++playercount;
		}
		else
			it.mmm_status = 0; // this is mostly a safety check; if a client manages to somehow maintain a mmm status, clear it before the round starts!
		it.mmm_validkills = 0;
	});
	
	int murderer_count = ((autocvar_g_mmm_murderer_count >= 1) ? autocvar_g_mmm_murderer_count : max(floor(playercount * autocvar_g_mmm_murderer_count), 1)); // There must be at least 1 murderer
	int detective_count = ((autocvar_g_mmm_detective_count >= 1 || autocvar_g_mmm_detective_count == 0) ? autocvar_g_mmm_detective_count : floor(playercount * autocvar_g_mmm_detective_count)); // It's fine if there are no detectives
	
	int total_murderers = 0;
	int total_detectives = 0;
	int total_civilians = 0;

	FOREACH_CLIENT_RANDOM(IS_PLAYER(it) && !IS_DEAD(it),
	{
		if (total_murderers < murderer_count) {
			it.mmm_status = MMM_STATUS_MURDERER;
			total_murderers++;
		} else if (total_detectives < detective_count) {
			it.mmm_status = MMM_STATUS_DETECTIVE;
			total_detectives++;
		} else {
			it.mmm_status = MMM_STATUS_CIVILIAN;
			total_civilians++;
		}
	});
	
	//LOG_INFOF("Total players: %d || Murderers: %d, Detectives: %d, Civilians: %d", playercount, total_murderers, total_detectives, total_civilians);

	FOREACH_CLIENT(IS_PLAYER(it) && !IS_DEAD(it),
	{
		karma_Control(it);
		it.activekillerrole = false;

		if(it.mmm_status == MMM_STATUS_CIVILIAN)
		{
			Karma_WarningCheck(it);
			//Gives Mine Layer weapon to the player
			GiveWeapon(it, WEP_MINE_LAYER.m_id, OP_PLUS, 1);
			Send_Notification(NOTIF_ONE_ONLY, it, MSG_CENTER, CENTER_MMM_CIVILIAN);
			Send_Notification(NOTIF_ONE_ONLY, it, MSG_INFO, INFO_MMM_CIVILIAN);
			//PrintToChatAll(sprintf("^1DEBUG^7: %s is ^2Civilian^7!", it.netname));
		}
		else if(it.mmm_status == MMM_STATUS_MURDERER)
		{
			Karma_WarningCheck(it);
			//Gives Mine Layer weapon to the player
			GiveWeapon(it, WEP_MINE_LAYER.m_id, OP_PLUS, 1);
			Send_Notification(NOTIF_ONE_ONLY, it, MSG_CENTER, CENTER_MMM_MURDERER);
			Send_Notification(NOTIF_ONE_ONLY, it, MSG_INFO, INFO_MMM_MURDERER);
			//PrintToChatAll(sprintf("^1DEBUG^7: %s is ^1Murderer^7!", it.netname));
		}
		else if(it.mmm_status == MMM_STATUS_DETECTIVE)
		{
			Karma_WarningCheck(it);
			//Gives Shockwave and Mine Layer weapon to the player
			GiveWeapon(it, WEP_SHOCKWAVE.m_id, OP_PLUS, 1);
			GiveWeapon(it, WEP_MINE_LAYER.m_id, OP_PLUS, 1);
			Send_Notification(NOTIF_ONE_ONLY, it, MSG_CENTER, CENTER_MMM_DETECTIVE);
			Send_Notification(NOTIF_ONE_ONLY, it, MSG_INFO, INFO_MMM_DETECTIVE);
			Send_Notification(NOTIF_ALL, NULL, MSG_INFO, INFO_MMM_WHOISDETECTIVE, it.netname);
		}
		mmm_FakeTimeLimit(it, round_handler_GetEndTime());
	});
}

bool mmm_CheckPlayers()
{
	static int prev_missing_players;
	allowed_to_spawn = true;
	int playercount = 0;

	FOREACH_CLIENT(IS_PLAYER(it) && !IS_DEAD(it),
	{
		//PrintToChatAll(sprintf("it.karmapoints ^5begin: ^3%f",it.karmapoints));
		karma_Control(it);
		++playercount;
		//PrintToChatAll(sprintf("it.karmapoints ^6end: ^3%f",it.karmapoints));
	});

	if (playercount >= 2)
	{
		if(prev_missing_players > 0)
			Kill_Notification(NOTIF_ALL, NULL, MSG_CENTER, CPID_MISSING_PLAYERS);
		prev_missing_players = -1;
		return true;
	}

	if(playercount == 0)
	{
		if(prev_missing_players > 0)
			Kill_Notification(NOTIF_ALL, NULL, MSG_CENTER, CPID_MISSING_PLAYERS);
		prev_missing_players = -1;
		return false;
	}

	// if we get here, only 1 player is missing
	if(prev_missing_players != 1)
	{
		Send_Notification(NOTIF_ALL, NULL, MSG_CENTER, CENTER_MISSING_PLAYERS, 1);
		prev_missing_players = 1;
	}
	return false;
}

bool mmm_isEliminated(entity e)
{
	if(e.caplayer == 1 && (IS_DEAD(e) || e.frags == FRAGS_PLAYER_OUT_OF_GAME))
		return true;
	if(e.caplayer == 0.5)
		return true;
	return false;
}

void mmm_Initialize() // run at the start of a match, initiates game mode
{
	GameRules_scoring(0, SFL_SORT_PRIO_PRIMARY, 0, {
		field(SP_MMM_KARMA, "karma", SFL_SORT_PRIO_SECONDARY); //LegendGuard adds Karma points in the scoreboard 22-02-2021
	});

	allowed_to_spawn = true;
	round_handler_Spawn(mmm_CheckPlayers, mmm_CheckWinner, mmm_RoundStart);
	round_handler_Init(5, autocvar_g_mmm_warmup, autocvar_g_mmm_round_timelimit);
	EliminatedPlayers_Init(mmm_isEliminated);
}

void checkWeaponDeathtype(entity target, float deathtype)
{
	switch (deathtype)
	{
		case WEP_ARC.m_id: case 276: case 788: target.killedwithweapon = "Impacted by the Arc's electric shock"; return;
		case WEP_BLASTER.m_id: case 513: target.killedwithweapon = "Blasted by the Blaster"; return;
		case WEP_CRYLINK.m_id: case 263: case 519: target.killedwithweapon = "Shot by the Crylink"; return;
		case WEP_DEVASTATOR.m_id: case 522: case 1546: target.killedwithweapon = "Bombarded by the Devastator"; return;
		case WEP_ELECTRO.m_id: case 262: case 518: case 1542: target.killedwithweapon = "Electrocuted by the Electro"; return;
		case WEP_FIREBALL.m_id: case 273: case 529: case 1297: target.killedwithweapon = "Burned by the Fireball"; return;
		case WEP_HAGAR.m_id: case 265: target.killedwithweapon = "Gunned by the Hagar"; return;
		case WEP_HLAC.m_id: case 270: case 526: target.killedwithweapon = "Cut down with the HLAC"; return;
		case WEP_HOOK.m_id: case 1805: target.killedwithweapon = "Caught in Hook gravity bomb"; return;
		case WEP_MACHINEGUN.m_id: target.activekillerrole = true; target.killedwithweapon = "Riddled full of holes by the Machine Gun"; return;
		case WEP_MINE_LAYER.m_id: case 517: case 1541: target.killedwithweapon = "Exploited by the Mine Layer"; return;
		case WEP_MORTAR.m_id: case 516: case 1284: target.killedwithweapon = "Blew up with the Mortar"; return;
		case WEP_OVERKILL_NEX.m_id: target.killedwithweapon = "Sniped by the Overkill Nex"; return;
		case WEP_RIFLE.m_id: case 272: target.activekillerrole = true; target.killedwithweapon = "Sniped by the Rifle"; return;
		case WEP_SEEKER.m_id: case 274: case 786: target.killedwithweapon = "Blasted by the Seeker"; return;
		case WEP_SHOCKWAVE.m_id: target.killedwithweapon = "Gunned down by the Shockwave"; return;
		case 275: target.killedwithweapon = "Knocked by the Shockwave"; return;
		case WEP_SHOTGUN.m_id: target.activekillerrole = true; target.killedwithweapon = "Shot by Shotgun"; return;
		case 258: target.killedwithweapon = "Knocked by the Shotgun"; return;
		case WEP_TUBA.m_id: target.killedwithweapon = "Ear pain by the @!#%'n Tuba"; return;
		case WEP_VAPORIZER.m_id: case 257: case 769: target.killedwithweapon = "Sniped by the Vaporizer"; return;
		case WEP_VORTEX.m_id: target.killedwithweapon = "Sniped by the Vortex"; return;
		case DEATH_FALL.m_id: target.killedwithweapon = "Fall"; return;
		case DEATH_FIRE.m_id: target.killedwithweapon = "Burned with the fire"; return;
		case DEATH_LAVA.m_id: target.killedwithweapon = "Burned in lava"; return;
		case DEATH_MIRRORDAMAGE.m_id: target.killedwithweapon = "Suicide"; return;
		case DEATH_SLIME.m_id: target.killedwithweapon = "Melted in slime"; return;
		case DEATH_TELEFRAG.m_id: target.killedwithweapon = "Telefragged"; return;
		case DEATH_NADE.m_id: target.killedwithweapon = "Blown up by the nade"; return;
		case DEATH_NADE_NAPALM.m_id: target.killedwithweapon = "Burned by the Napalm nade"; return;
		case DEATH_NADE_ICE.m_id: target.killedwithweapon = "Frozen by the Ice nade"; return;
		case DEATH_NADE_HEAL.m_id: target.killedwithweapon = "Sucked by the Heal nade"; return;
		default: target.killedwithweapon = "Unknown"; return;
	}
}

void ReduceKarmaPointsandFrags(entity frag_attacker, entity frag_target, float frag_deathtype, entity wep_ent)
{
	karmaLoseDifference(frag_attacker, frag_target);
	GiveFrags(frag_attacker, frag_target, ((autocvar_g_mmm_punish_teamkill) ? -1 : -2), frag_deathtype, wep_ent.weaponentity_fld);
	frag_target.whokilled = frag_attacker.netname;
}

// ==============
// Hook Functions
// ==============

MUTATOR_HOOKFUNCTION(mmm, FragCenterMessage)
{
	entity attacker = M_ARGV(0, entity);
	entity targ = M_ARGV(1, entity);
	
	// Conditions that count as team kill in MMM
	if((attacker.mmm_status == targ.mmm_status) ||
	   (attacker.mmm_status == MMM_STATUS_DETECTIVE && targ.mmm_status == MMM_STATUS_CIVILIAN) ||
	   (attacker.mmm_status == MMM_STATUS_CIVILIAN  && targ.mmm_status == MMM_STATUS_DETECTIVE)
	)
	{
		Send_Notification(NOTIF_ONE, attacker, MSG_CENTER, CENTER_DEATH_TEAMKILL_FRAG, targ.netname);
		Send_Notification(NOTIF_ONE, targ, MSG_CENTER, CENTER_DEATH_TEAMKILL_FRAGGED, "???");
		return true;
	}
}

MUTATOR_HOOKFUNCTION(mmm, ClientObituary)
{
	// LegendGuard's IDEA: To adjust the grade of severity of karma, 
	// we could add if sentence per weapons and adjust each weapon attack
	// its own grade. Instead doing random decrease grade 22-02-2021
	
	// in mmm, announcing a frag would tell everyone who the murderer is
	entity frag_attacker = M_ARGV(1, entity);
	entity frag_target = M_ARGV(2, entity);
	M_ARGV(5, bool) = true; // anonymous attacker
	
	if(IS_PLAYER(frag_attacker) && frag_attacker != frag_target)
	{
		float frag_deathtype = M_ARGV(3, float);
		entity wep_ent = M_ARGV(4, entity);
		
		//PrintToChatAll(strcat("deathtype var: ", ftos(frag_deathtype)));
		checkWeaponDeathtype(frag_target, frag_deathtype);
		// "team" kill, a point is awarded to the player by default so we must take it away plus an extra one
		// unless the player is going to be punished for suicide, in which case just remove one
		if(frag_attacker.mmm_status == frag_target.mmm_status)
		{
			//PrintToChatAll("^1DEBUG^7: A ^2PLAYER^7 has fragged a ^2PLAYER OF HIS OWN TEAM^7, TOO BAD!");
			ReduceKarmaPointsandFrags(frag_attacker, frag_target, frag_deathtype, wep_ent);
			frag_attacker.killsound -= 1; frag_attacker.typehitsound += 1; // Teamkill sound
			switch (frag_attacker.mmm_status)
			{
				case MMM_STATUS_CIVILIAN: frag_target.killerrole = "\n^3Killer role: ^2Civilian"; return;
				case MMM_STATUS_MURDERER: frag_target.killerrole = "\n^3Killer role: ^1Murderer"; return;
				case MMM_STATUS_DETECTIVE: frag_target.killerrole = "\n^3Killer role: ^4Detective"; return;
				default: return;
			}
			//PrintToChatAll(sprintf("frag_attacker.karmapoints: ^1%f", frag_attacker.karmapoints));
		}

		if(frag_attacker.mmm_status == MMM_STATUS_DETECTIVE)
		{
			if (frag_target.mmm_status == MMM_STATUS_CIVILIAN)
			{	
				//PrintToChatAll("^1DEBUG^7: A ^4Detective^7 fragged an ^2Civilian^7/^4Detective^7, TOO BAD!");
				ReduceKarmaPointsandFrags(frag_attacker, frag_target, frag_deathtype, wep_ent);
				frag_attacker.killsound -= 1; frag_attacker.typehitsound += 1; // Teamkill sound
				frag_target.killerrole = "\n^3Killer role: ^4Detective";
				//PrintToChatAll(sprintf("frag_attacker.karmapoints: ^1%f", frag_attacker.karmapoints));
			}
			else
			{
				frag_target.whokilled = frag_attacker.netname;
				frag_target.killerrole = "\n^3Killer role: ^4Detective";
			}
		}

		if (frag_attacker.mmm_status == MMM_STATUS_CIVILIAN)
		{
			if (frag_target.mmm_status == MMM_STATUS_DETECTIVE)
			{
				//PrintToChatAll("^1DEBUG^7: An ^2Civilian^7 fragged a ^4Detective^7, TOO BAD!");
				ReduceKarmaPointsandFrags(frag_attacker, frag_target, frag_deathtype, wep_ent);
				frag_attacker.killsound -= 1; frag_attacker.typehitsound += 1; // Teamkill sound
				frag_target.killerrole = "\n^3Killer role: ^2Civilian";
			}
			else
			{
				frag_target.whokilled = frag_attacker.netname;
				frag_target.killerrole = "\n^3Killer role: ^2Civilian";
			}
		}
		
		if (frag_attacker.mmm_status == MMM_STATUS_MURDERER)
		{
			if (frag_target.mmm_status == MMM_STATUS_CIVILIAN)
			{
				frag_target.whokilled = frag_attacker.netname;
				frag_target.killerrole = "\n^3Killer role: ^1Murderer";
			}
			else
			{
				frag_target.whokilled = frag_attacker.netname;
				frag_target.killerrole = "\n^3Killer role: ^1Murderer";
			}
		}
		//if mmm_status is 1, means civilian, 2 means murderer, 3 means detective
		//PrintToChatAll(sprintf("^1DEBUG^7: frag_attacker.mmm_status is ^3%s^7",ftos(frag_attacker.mmm_status)));
		//PrintToChatAll(sprintf("^1DEBUG^7: frag_target.mmm_status is ^3%s^7",ftos(frag_target.mmm_status)));
	}
	else
	{
		float frag_deathtype = M_ARGV(3, float);
		checkWeaponDeathtype(frag_target, frag_deathtype);
	}
}

//karma weapon damage, halve the damage attack when player has low karma 20-03-2021
MUTATOR_HOOKFUNCTION(mmm, Damage_Calculate)
{
	entity attacker = M_ARGV(1, entity);
	entity target = M_ARGV(2, entity);
	float deathtype = M_ARGV(3, float);
	float damage = M_ARGV(4, float);
	vector force = M_ARGV(6, vector);
	string corpsemessagestrcat = "";
	string corpsemsginfo = "";

	if (autocvar_g_mmm_karma_damageactive != false)
	{
		if (IS_PLAYER(attacker))
		{
			if(target == attacker) // damage done to yourself
			{
				damage /= autocvar_g_weapondamagefactor / (attacker.karmapoints / autocvar_g_mmm_max_karma_points);
				force /= autocvar_g_weaponforcefactor / (attacker.karmapoints / autocvar_g_mmm_max_karma_points);
			}
			else if (target != attacker)
			{
				damage /= autocvar_g_weapondamagefactor / (attacker.karmapoints / autocvar_g_mmm_max_karma_points);
				force /= autocvar_g_weaponforcefactor / (attacker.karmapoints / autocvar_g_mmm_max_karma_points);
			}
			else
			{
				damage *= autocvar_g_weapondamagefactor;
				force *= autocvar_g_weaponforcefactor;
			}
		}
	}

	//CORPSE DETECTION SKILL 21-03-2021
	if(IS_DEAD(target))
	{
		//Shockwave weapon as radar gun to check the corpses 22-03-2021
		if(DEATH_ISWEAPON(deathtype, WEP_SHOCKWAVE))
		{
			if (target.killedwithweapon == "")
				target.killedwithweapon = "UNKNOWN CAUSE";
			
			if (target.activekillerrole != true)
			{
				target.killerrole = "";
				target.activekillerrole = false;
			}

			string killedbyphrase = strcat("^3Killed by:^7 ", target.whokilled, target.killerrole); 
			string wepkilledphrase = strcat("^3Cause:^7 ", target.killedwithweapon);
			if (target.whokilled == "")
			{
				killedbyphrase = "";
				if (target.killedwithweapon == "")
					wepkilledphrase = "^3Cause:^7 UNKNOWN CAUSE";
			}

			damage = 0;
			force = '0 0 0';
			if (target.mmm_status == MMM_STATUS_CIVILIAN)
			{
				//try to add centerprint message for chat privately if possible
				corpsemessagestrcat = strcat("^5DEAD PLAYER DETAILS^7: \n^3Name:^7 ", target.netname, "\n^3Role: ^2Civilian", "\n", killedbyphrase, "\n", wepkilledphrase);
				corpsemsginfo = strcat("^5DEAD PLAYER DETAILS^7: ^3Name:^7 ", target.netname, "   ^3Role: ^2Civilian", "   ", killedbyphrase, "   ", wepkilledphrase);
				//centerprint(attacker, strcat(BOLD_OPERATOR, corpsemessagestrcat));
				Send_Notification(NOTIF_ONE_ONLY, attacker, MSG_CENTER, CENTER_MMM_CORPSEDETECTION, corpsemessagestrcat);
				Send_Notification(NOTIF_ONE_ONLY, attacker, MSG_INFO, INFO_MMM_CORPSEDETECTION, corpsemsginfo);
			}
			else if (target.mmm_status == MMM_STATUS_MURDERER)
			{
				corpsemessagestrcat = strcat("^5DEAD PLAYER DETAILS^7: \n^3Name:^7 ", target.netname, "\n^3Role: ^1Murderer", "\n", killedbyphrase, "\n", wepkilledphrase);
				corpsemsginfo = strcat("^5DEAD PLAYER DETAILS^7: ^3Name:^7 ", target.netname, "   ^3Role: ^1Murderer", "   ", killedbyphrase, "   ", wepkilledphrase);
				//centerprint(attacker, strcat(BOLD_OPERATOR, corpsemessagestrcat));
				Send_Notification(NOTIF_ONE_ONLY, attacker, MSG_CENTER, CENTER_MMM_CORPSEDETECTION, corpsemessagestrcat);
				Send_Notification(NOTIF_ONE_ONLY, attacker, MSG_INFO, INFO_MMM_CORPSEDETECTION, corpsemsginfo);
			}
			else if (target.mmm_status == MMM_STATUS_DETECTIVE)
			{
				corpsemessagestrcat = strcat("^5DEAD PLAYER DETAILS^7: \n^3Name:^7 ", target.netname, "\n^3Role: ^4Detective", "\n", killedbyphrase, "\n", wepkilledphrase);
				corpsemsginfo = strcat("^5DEAD PLAYER DETAILS^7: ^3Name:^7 ", target.netname, "   ^3Role: ^4Detective", "   ", killedbyphrase, "   ", wepkilledphrase);
				//centerprint(attacker, strcat(BOLD_OPERATOR, corpsemessagestrcat));
				Send_Notification(NOTIF_ONE_ONLY, attacker, MSG_CENTER, CENTER_MMM_CORPSEDETECTION, corpsemessagestrcat);
				Send_Notification(NOTIF_ONE_ONLY, attacker, MSG_INFO, INFO_MMM_CORPSEDETECTION, corpsemsginfo);
			}
			attacker.investigated = true;
		}
	}

	M_ARGV(4, float) = damage;
	M_ARGV(6, vector) = force;
}

MUTATOR_HOOKFUNCTION(mmm, PlayerPreThink)
{
	entity player = M_ARGV(0, entity);
	int playercount = 0;
	bool playercheck = false;

	if (playercheck != true)
	{
		FOREACH_CLIENT(IS_PLAYER(it) && !IS_DEAD(it),
		{
			++playercount;
		});
		playercheck = true;
	}

	//if the murderer is still here around, then avoid illogical winning
	if (playercheck == true)
	{
		FOREACH_CLIENT(IS_PLAYER(it) && !IS_DEAD(it),
		{
			if (playercount == 3)
			{
				if (it.mmm_status == MMM_STATUS_DETECTIVE)
					it.mmm_status = MMM_STATUS_CIVILIAN;
			}
		});
	}

	if(IS_PLAYER(player) || player.caplayer)
	{
		if (player.karmaspectated != true)
		{
			if (CS(player).scorekeeper.(scores(SP_MMM_KARMA)) <= 0) //wtf? Visualization works 100% correct?
				GameRules_scoring_add(player, MMM_KARMA, player.karmapoints);
			player.karmaspectated = true;
		}
		// update the scoreboard colour display to out the real killer at the end of the round
		// running this every frame to avoid cheats
		int plcolor = MMM_COLOR_CIVILIAN;
		if(player.mmm_status == MMM_STATUS_CIVILIAN && game_stopped) //Civilian status by default
			plcolor = MMM_COLOR_CIVILIAN;
		if(player.mmm_status == MMM_STATUS_MURDERER && game_stopped)
			plcolor = MMM_COLOR_MURDERER;
		//LegendGuard adds for Detective 21-02-2021
		if(player.mmm_status == MMM_STATUS_DETECTIVE)// && game_stopped)
			plcolor = MMM_COLOR_DETECTIVE;
		setcolor(player, plcolor);
	}
	if(warmup_stage)
		player.karmastarted = false;

	//CORPSE FEATURE 10-03-2021
	if (IS_DEAD(player))
	{
		player.event_damage = func_null;
		//player.health = 0;
		player.solid = SOLID_CORPSE;
		set_movetype(player, MOVETYPE_STEP); //test with MOVETYPE_TOSS or MOVETYPE_WALK (it's like sliding object) or MOVETYPE_BOUNCE (maybe not good)
	}
}

MUTATOR_HOOKFUNCTION(mmm, PlayerSpawn)
{
	entity player = M_ARGV(0, entity);
	
	//Karma points start
	if (player.karmastarted != true)
	{
		CS(player).scorekeeper.(scores(SP_MMM_KARMA)) = 0; //full karma reset lol
		player.karmapoints = autocvar_g_mmm_max_karma_points;
		GameRules_scoring_add(player, MMM_KARMA, player.karmapoints);
		player.karmastarted = true;
	}

	player.mmm_status = 0;
	player.mmm_validkills = 0;
	player.caplayer = 1;
	if (!warmup_stage)
		eliminatedPlayers.SendFlags |= 1;
}

MUTATOR_HOOKFUNCTION(mmm, ForbidSpawn)
{
	entity player = M_ARGV(0, entity);

	// spectators / observers that weren't playing can join; they are
	// immediately forced to observe in the PutClientInServer hook
	// this way they are put in a team and can play in the next round
	if (!allowed_to_spawn && player.caplayer)
		return true;
	return false;
}

MUTATOR_HOOKFUNCTION(mmm, PutClientInServer)
{
	entity player = M_ARGV(0, entity);

	if (!allowed_to_spawn && IS_PLAYER(player)) // this is true even when player is trying to join
	{
		TRANSMUTE(Observer, player);
		if (CS(player).jointime != time && !player.caplayer) // not when connecting
		{
			player.caplayer = 0.5;
			Send_Notification(NOTIF_ONE_ONLY, player, MSG_INFO, INFO_CA_JOIN_LATE);
		}
	}
}

MUTATOR_HOOKFUNCTION(mmm, reset_map_players)
{
	FOREACH_CLIENT(true, {
		CS(it).killcount = 0;
		it.mmm_status = 0;
		mmm_FakeTimeLimit(it, -1); // restore original timelimit
		if (!it.caplayer && IS_BOT_CLIENT(it))
			it.caplayer = 1;
		if (it.caplayer)
		{
			TRANSMUTE(Player, it);
			it.caplayer = 1;
			it.respawn_flags = RESPAWN_SILENT; //CSQC print output respawn lib.qh error fix
			PutClientInServer(it);
		}
	});
	bot_relinkplayerlist();
	return true;
}

MUTATOR_HOOKFUNCTION(mmm, reset_map_global)
{
	allowed_to_spawn = true;
	return true;
}

entity mmm_LastPlayerForTeam(entity this)
{
	entity last_pl = NULL;
	FOREACH_CLIENT(IS_PLAYER(it) && it != this, {
		if (!IS_DEAD(it) && this.mmm_status == it.mmm_status)
		{
			if (!last_pl)
			{
				last_pl = it;
			}
			else
				return NULL;
		}
	});
	return last_pl;
}

void mmm_LastPlayerForTeam_Notify(entity this)
{
	if (!warmup_stage && round_handler_IsActive() && round_handler_IsRoundStarted())
	{
		entity pl = mmm_LastPlayerForTeam(this);
		if (pl)
			Send_Notification(NOTIF_ONE_ONLY, pl, MSG_CENTER, CENTER_ALONE);
	}
}

MUTATOR_HOOKFUNCTION(mmm, PlayerDies)
{
	entity frag_attacker = M_ARGV(1, entity);
	entity frag_target = M_ARGV(2, entity);
	//float frag_deathtype = M_ARGV(3, float);

	mmm_LastPlayerForTeam_Notify(frag_target);
	if (!allowed_to_spawn)
	{
		frag_target.respawn_flags = RESPAWN_DENY;
		// prevent unwanted sudden rejoin as spectator and movement of spectator camera
		frag_target.respawn_time = time + 2;
	}
	frag_target.respawn_flags |= RESPAWN_DENY;
	frag_target.event_damage = func_null;
	frag_target.health = 0;
	
	if (!warmup_stage)
		eliminatedPlayers.SendFlags |= 1;
	
	//if(frag_attacker.mmm_status == frag_target.mmm_status)
	// killed an ally! punishment is sentenced
	if(frag_attacker.mmm_status == MMM_STATUS_DETECTIVE)
	{
		if (frag_target.mmm_status == MMM_STATUS_CIVILIAN)
		{
			//PrintToChatAll("^1DEBUG^7: ^4DETECTIVE ^1DAMAGE/DEAD^7 HAS TAKEN!");
			Damage(frag_attacker, frag_attacker, frag_attacker, autocvar_g_mmm_karma_damagepunishmentdeal, DEATH_MIRRORDAMAGE.m_id, DMG_NOWEP, frag_attacker.origin, '0 0 0');
		}
	}
	if (frag_attacker.mmm_status == MMM_STATUS_CIVILIAN)
	{
		if (frag_target.mmm_status == MMM_STATUS_DETECTIVE)
		{
			//PrintToChatAll("^1DEBUG^7: ^2CIVILIAN ^1DAMAGE/DEAD^7 HAS TAKEN!");
			Damage(frag_attacker, frag_attacker, frag_attacker, autocvar_g_mmm_karma_damagepunishmentdeal, DEATH_MIRRORDAMAGE.m_id, DMG_NOWEP, frag_attacker.origin, '0 0 0');
		}
	}
	if (frag_attacker.mmm_status == MMM_STATUS_MURDERER)
	{
		if (frag_target.mmm_status == MMM_STATUS_MURDERER)
		{
			//PrintToChatAll("^1DEBUG^7: ^1MURDERER ^1DAMAGE/DEAD^7 HAS TAKEN!");
			Damage(frag_attacker, frag_attacker, frag_attacker, autocvar_g_mmm_karma_damagepunishmentdeal, DEATH_MIRRORDAMAGE.m_id, DMG_NOWEP, frag_attacker.origin, '0 0 0');
		}
	}
	return true;
}

MUTATOR_HOOKFUNCTION(mmm, ClientDisconnect)
{
	entity player = M_ARGV(0, entity);

	if (IS_PLAYER(player) && !IS_DEAD(player))
		mmm_LastPlayerForTeam_Notify(player);
	return true;
}

MUTATOR_HOOKFUNCTION(mmm, MakePlayerObserver)
{
	entity player = M_ARGV(0, entity);

	if (IS_PLAYER(player) && !IS_DEAD(player))
		mmm_LastPlayerForTeam_Notify(player);
	if (player.karmaspectated == true)
		player.karmaspectated = false;
	if (player.killindicator_teamchange == -2) // player wants to spectate
		player.caplayer = 0;
	if (player.caplayer)
		player.frags = FRAGS_PLAYER_OUT_OF_GAME;
	if (!warmup_stage)
		eliminatedPlayers.SendFlags |= 1;
	if (!player.caplayer)
	{
		player.mmm_validkills = 0;
		player.mmm_status = 0;
		mmm_FakeTimeLimit(player, -1); // restore original timelimit
		return false;  // allow team reset
	}
	return true;  // prevent team reset
}

MUTATOR_HOOKFUNCTION(mmm, Scores_CountFragsRemaining)
{
	// announce remaining frags?
	return true;
}

MUTATOR_HOOKFUNCTION(mmm, GiveFragsForKill, CBC_ORDER_FIRST)
{
	entity frag_attacker = M_ARGV(0, entity);
	if(!warmup_stage && round_handler_IsActive() && round_handler_IsRoundStarted()) 
		frag_attacker.mmm_validkills += M_ARGV(2, float);
	M_ARGV(2, float) = 0; // score will be given to the winner when the round ends
	return true;
}

MUTATOR_HOOKFUNCTION(mmm, AddPlayerScore)
{
	// add scorefield for scoreboard here
	entity scorefield = M_ARGV(0, entity);
	if(scorefield == SP_KILLS || scorefield == SP_DEATHS || scorefield == SP_SUICIDES || scorefield == SP_DMG || scorefield == SP_DMGTAKEN)
		M_ARGV(1, float) = 0; // don't report that the player has killed or been killed, that would out them as a murderer!
}

MUTATOR_HOOKFUNCTION(mmm, CalculateRespawnTime)
{
	// no respawn calculations needed, player is forced to spectate anyway
	return true;
}

//if server admin sets "sv_ready_restart_after_countdown 1", will avoid possible visual failure for karma in the scoreboard
MUTATOR_HOOKFUNCTION(mmm, ReadLevelCvars)
{
	sv_ready_restart_after_countdown = 0;
}

MUTATOR_HOOKFUNCTION(mmm, Bot_FixCount, CBC_ORDER_EXCLUSIVE)
{
	FOREACH_CLIENT(IS_REAL_CLIENT(it), {
		if (IS_PLAYER(it) || it.caplayer == 1)
			++M_ARGV(0, int);
		++M_ARGV(1, int);
	});
	return true;
}

MUTATOR_HOOKFUNCTION(mmm, ClientCommand_Spectate)
{
	entity player = M_ARGV(0, entity);

	if (player.caplayer)
	{
		// they're going to spec, we can do other checks
		if (autocvar_sv_spectate && (IS_SPEC(player) || IS_OBSERVER(player)))
			Send_Notification(NOTIF_ONE_ONLY, player, MSG_INFO, INFO_CA_LEAVE);
		return MUT_SPECCMD_FORCE;
	}

	return MUT_SPECCMD_CONTINUE;
}

MUTATOR_HOOKFUNCTION(mmm, GetPlayerStatus)
{
	entity player = M_ARGV(0, entity);

	return player.caplayer == 1;
}

MUTATOR_HOOKFUNCTION(mmm, BotShouldAttack)
{
	entity bot = M_ARGV(0, entity);
	entity targ = M_ARGV(1, entity);

	if(targ.mmm_status == bot.mmm_status)
	{
		return true;
	}
	
	// LegendGuard fixed the problem of Detectives and Civilians attacking each other 26-03-2021
	if(bot.mmm_status == MMM_STATUS_DETECTIVE)
	{
		if(targ.mmm_status == MMM_STATUS_CIVILIAN)
			return true;
	}
}
