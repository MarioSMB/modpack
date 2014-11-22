// =========================================================
//  Unofficial key hunt game mode coding, reworked by Mario
// =========================================================

void kh_EventLog(string mode, float keyteam, entity actor) // use an alias for easy changing and quick editing later
{
	if(autocvar_sv_eventlog)
		GameLogEcho(sprintf(":keyhunt:%s:%d:%d:%s", mode, keyteam, actor.team, ((actor != world) ? ftos(actor.playerid) : "")));
}

void kh_KeycarrierWaypoints(entity player)
{
	WaypointSprite_Spawn("keycarrier", 0, 0, player, KEY_WAYPOINT_OFFSET, world, 0, player, wps_keycarrier, TRUE, RADARICON_FLAG, WPCOLOR_ENEMYKC(player.team));
	WaypointSprite_UpdateMaxHealth(player.wps_keycarrier, '1 0 0' * healtharmor_maxdamage(start_health, start_armorvalue, autocvar_g_balance_armor_blockpercent, DEATH_WEAPON) * 2);
	WaypointSprite_UpdateHealth(player.wps_keycarrier, '1 0 0' * healtharmor_maxdamage(player.health, player.armorvalue, autocvar_g_balance_armor_blockpercent, DEATH_WEAPON));
	WaypointSprite_UpdateTeamRadar(player.wps_keycarrier, RADARICON_FLAGCARRIER, WPCOLOR_ENEMYKC(player.team));
}

void kh_CalculatePassVelocity(entity key, vector to, vector from, float turnrate)
{
	float current_distance = vlen((('1 0 0' * to_x) + ('0 1 0' * to_y)) - (('1 0 0' * from_x) + ('0 1 0' * from_y))); // for the sake of this check, exclude Z axis
	float initial_height = min(autocvar_g_keyhunt_pass_arc_max, (key.pass_distance * tanh(autocvar_g_keyhunt_pass_arc)));
	float current_height = (initial_height * min(1, (current_distance / key.pass_distance)));
	//print("current_height = ", ftos(current_height), ", initial_height = ", ftos(initial_height), ".\n");

	vector targpos;
	if(current_height) // make sure we can actually do this arcing path
	{
		targpos = (to + ('0 0 1' * current_height));
		WarpZone_TraceLine(key.origin, targpos, MOVE_NOMONSTERS, key);
		if(trace_fraction < 1)
		{
			//print("normal arc line failed, trying to find new pos...");
			WarpZone_TraceLine(to, targpos, MOVE_NOMONSTERS, key);
			targpos = (trace_endpos + KEY_PASS_ARC_OFFSET);
			WarpZone_TraceLine(key.origin, targpos, MOVE_NOMONSTERS, key);
			if(trace_fraction < 1) { targpos = to; /* print(" ^1FAILURE^7, reverting to original direction.\n"); */ }
			/*else { print(" ^3SUCCESS^7, using new arc line.\n"); } */
		}
	}
	else { targpos = to; }

	//key.angles = normalize(('0 1 0' * to_y) - ('0 1 0' * from_y));

	vector desired_direction = normalize(targpos - from);
	if(turnrate) { key.velocity = (normalize(normalize(key.velocity) + (desired_direction * autocvar_g_keyhunt_pass_turnrate)) * autocvar_g_keyhunt_pass_velocity); }
	else { key.velocity = (desired_direction * autocvar_g_keyhunt_pass_velocity); }
}

float kh_CheckPassDirection(vector head_center, vector passer_center, vector passer_angle, vector nearest_to_passer)
{
	if(autocvar_g_keyhunt_pass_directional_max || autocvar_g_keyhunt_pass_directional_min)
	{
		// directional tracing only
		float spreadlimit;
		makevectors(passer_angle);

		// find the closest point on the enemy to the center of the attack
		float ang; // angle between shotdir and h
		float h; // hypotenuse, which is the distance between attacker to head
		float a; // adjacent side, which is the distance between attacker and the point on w_shotdir that is closest to head.origin

		h = vlen(head_center - passer_center);
		ang = acos(dotproduct(normalize(head_center - passer_center), v_forward));
		a = h * cos(ang);

		vector nearest_on_line = (passer_center + a * v_forward);
		float distance_from_line = vlen(nearest_to_passer - nearest_on_line);

		spreadlimit = (autocvar_g_keyhunt_pass_radius ? min(1, (vlen(passer_center - nearest_on_line) / autocvar_g_keyhunt_pass_radius)) : 1);
		spreadlimit = (autocvar_g_keyhunt_pass_directional_min * (1 - spreadlimit) + autocvar_g_keyhunt_pass_directional_max * spreadlimit);

		if(spreadlimit && (distance_from_line <= spreadlimit) && ((vlen(normalize(head_center - passer_center) - v_forward) * RAD2DEG) <= 90))
			{ return TRUE; }
		else
			{ return FALSE; }
	}
	else { return TRUE; }
}

vector kh_AttachedOrigin(entity e)
{
	if(e.tag_entity)
	{
		makevectors(e.tag_entity.angles);
		return e.tag_entity.origin + e.origin_x * v_forward - e.origin_y * v_right + e.origin_z * v_up;
	}
	else
		return e.origin;
}


// ================
//  Round Handling
// ================

float KH_GetWinnerTeam()
{
	float winner_team = 0;
	entity key;
	
	KH_FOR_EACH_KEY(key)
	{
		if(!key.owner) { return 0; } // no carriers, no winners
		if(winner_team && winner_team != key.owner.team) { return 0; }
		winner_team = key.owner.team;
	}
	
	if(winner_team) { return winner_team; }
	
	return -1; // no winner?
}

void kh_Handle_Capture(float capturetype);
void kh_RemoveKey(entity key);
float KH_CheckWinner()
{
	entity e, key;
	if(round_handler_GetEndTime() > 0 && round_handler_GetEndTime() - time <= 0)
	{
		Send_Notification(NOTIF_ALL, world, MSG_CENTER, CENTER_ROUND_OVER);
		Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_ROUND_OVER);
		round_handler_Init(5, autocvar_g_keyhunt_warmup, autocvar_g_keyhunt_round_timelimit);
		FOR_EACH_CLIENT(e)
		{
			e.stat_kh_redkey_team = e.stat_kh_bluekey_team = e.stat_kh_yellowkey_team = e.stat_kh_pinkkey_team = 0;
			e.kh_lastkiller = world;
		}
		nades_Clear(world, TRUE);
		KH_FOR_EACH_KEY(key) { if(!wasfreed(key)) kh_RemoveKey(key); }
		kh_worldkeylist = world; // reset key list
		return 1;
	}
	
	float winner_team = KH_GetWinnerTeam();

	float key_count = 0;
	KH_FOR_EACH_KEY(key) { if(!wasfreed(key)) ++key_count; }
	if(key_count >= kh_teams && winner_team == 0) { return 0; }
	
	if(winner_team > 0)
	{
		float largest_dist = 0;
		KH_FOR_EACH_KEY(key)
		{
			if(!key.owner) { return 0; }
			if(key.kh_worldkeynext)
			if(vlen(kh_AttachedOrigin(key) - kh_AttachedOrigin(key.kh_worldkeynext)) >= largest_dist || largest_dist == 0)
				largest_dist = vlen(kh_AttachedOrigin(key) - kh_AttachedOrigin(key.kh_worldkeynext));
		}
		if(largest_dist >= autocvar_g_keyhunt_capture_radius)
		{
			entity head;
			if(time >= kh_alarm_time)
			FOR_EACH_PLAYER(head)
			{
				float head_iscarrier = FALSE;
				KH_FOR_EACH_KEY(key)
				if(key.owner == head)
				{
					head_iscarrier = TRUE;
					break;
				}
				
				if(head_iscarrier) { Send_Notification(NOTIF_ONE, head, MSG_CENTER, CENTER_KEYHUNT_MEET); }
				else if(head.team == winner_team) { Send_Notification(NOTIF_ONE, head, MSG_CENTER, CENTER_KEYHUNT_HELP); }
				else { Send_Notification(NOTIF_ONE, head, MSG_CENTER, APP_TEAM_NUM_4(winner_team, CENTER_KEYHUNT_INTERFERE_)); }
				
				kh_alarm_time = time + 2;
			}
			if(time >= kh_siren_time)
			{
				KH_FOR_EACH_KEY(key)
					sound(key.owner, CH_TRIGGER, "kh/alarm.wav", VOL_BASE, ATTEN_NORM);
				kh_siren_time = time + 3;
			}
			return 0;
		}

		kh_Handle_Capture(CAPTURE_NORMAL);
		TeamScore_AddToTeam(winner_team, ST_KH_CAPS, 1);
		
		kh_EventLog("capture", winner_team, world);
	}

	round_handler_Init(5, autocvar_g_keyhunt_warmup, autocvar_g_keyhunt_round_timelimit);

	FOR_EACH_CLIENT(e)
	{
		e.stat_kh_redkey_team = e.stat_kh_bluekey_team = e.stat_kh_yellowkey_team = e.stat_kh_pinkkey_team = 0;
		e.kh_lastkiller = world;
	}
	
	nades_Clear(world, TRUE);

	KH_FOR_EACH_KEY(key) { if(!wasfreed(key)) kh_RemoveKey(key); }
	kh_worldkeylist = world; // reset key list

	return 1;
}

entity KH_ChooseCarrier(float teamnumber)
{
	entity head;
	RandomSelection_Init();
	FOR_EACH_PLAYER(head)
	if(head.health > 0)
	if(!head.vehicle || autocvar_g_keyhunt_allow_vehicle_carry)
	if(head.frozen == 0)
	if(head.team == teamnumber)
		RandomSelection_Add(head, 0, string_null, 1, ((IS_REAL_CLIENT(head)) ? 1 : 0.5));
		
	return RandomSelection_chosen_ent;
}

void kh_KeySetup(float teamnumber, entity key, entity player);
void KH_RoundStart()
{
	entity tmp_entity;
	kh_KeySetup(NUM_TEAM_1, (tmp_entity = spawn()), KH_ChooseCarrier(NUM_TEAM_1));
	kh_KeySetup(NUM_TEAM_2, (tmp_entity = spawn()), KH_ChooseCarrier(NUM_TEAM_2));
	if(kh_teams >= 3) { kh_KeySetup(NUM_TEAM_3, (tmp_entity = spawn()), KH_ChooseCarrier(NUM_TEAM_3)); }
	if(kh_teams >= 4) { kh_KeySetup(NUM_TEAM_4, (tmp_entity = spawn()), KH_ChooseCarrier(NUM_TEAM_4)); }
	
	FOR_EACH_PLAYER(tmp_entity) { tmp_entity.spawnshieldtime = time + autocvar_g_spawnshieldtime; }
}

float total_players;
float redalive, bluealive, yellowalive, pinkalive;
void KH_count_alive_players()
{
	entity e;
	total_players = redalive = bluealive = yellowalive = pinkalive = 0;
	FOR_EACH_PLAYER(e)
	{
		switch(e.team)
		{
			case NUM_TEAM_1: ++total_players; if(e.health > 0 && e.frozen == 0 && (!e.vehicle || autocvar_g_keyhunt_allow_vehicle_carry)) ++redalive; break;
			case NUM_TEAM_2: ++total_players; if(e.health > 0 && e.frozen == 0 && (!e.vehicle || autocvar_g_keyhunt_allow_vehicle_carry)) ++bluealive; break;
			case NUM_TEAM_3: ++total_players; if(e.health > 0 && e.frozen == 0 && (!e.vehicle || autocvar_g_keyhunt_allow_vehicle_carry)) ++yellowalive; break;
			case NUM_TEAM_4: ++total_players; if(e.health > 0 && e.frozen == 0 && (!e.vehicle || autocvar_g_keyhunt_allow_vehicle_carry)) ++pinkalive; break;
		}
	}
}

#define KH_ALIVE_TEAMS() ((redalive > 0) + (bluealive > 0) + (yellowalive > 0) + (pinkalive > 0))
#define KH_ALIVE_TEAMS_OK() (KH_ALIVE_TEAMS() == kh_teams)

float prev_total_players;
float KH_CheckTeams()
{
	KH_count_alive_players();
	if(KH_ALIVE_TEAMS_OK())
	{
		if(prev_total_players > 0)
			Kill_Notification(NOTIF_ALL, world, MSG_CENTER_CPID, CPID_MISSING_TEAMS);
		prev_total_players = -1;
		return 1;
	}
	if(prev_total_players != total_players)
	{
		float p1 = 0, p2 = 0, p3 = 0, p4 = 0;
		if(!redalive) p1 = NUM_TEAM_1;
		if(!bluealive) p2 = NUM_TEAM_2;
		if(kh_teams >= 3)
		if(!yellowalive) p3 = NUM_TEAM_3;
		if(kh_teams >= 4)
		if(!pinkalive) p4 = NUM_TEAM_4;
		Send_Notification(NOTIF_ALL, world, MSG_CENTER, CENTER_MISSING_TEAMS, p1, p2, p3, p4);
		prev_total_players = total_players;
	}
	return 0;
}

entity kh_ChooseNewCarrier(entity key)
{
	entity tmp_entity, player = key.kh_dropper;

	RandomSelection_Init();
	FOR_EACH_PLAYER(tmp_entity)
	if(tmp_entity != player)
	if(!tmp_entity.frozen)
	if(!tmp_entity.vehicle || autocvar_g_keyhunt_allow_vehicle_carry)
	if(tmp_entity.health > 0)
	if(DIFF_TEAM(tmp_entity, player))
		RandomSelection_Add(tmp_entity, 0, string_null, 1, ((IS_REAL_CLIENT(tmp_entity)) ? 1 : 0.5));

	return RandomSelection_chosen_ent;
}


// ====================
// Drop/Pass/Throw Code
// ====================

void kh_Handle_Drop(entity key, entity player, float droptype)
{
	//print("Drop called for ", key.netname, " by player ", player, ", droptype: ", ftos(droptype), "\n");
	// declarations
	player = (player ? player : key.pass_sender);

	// main
	key.movetype = MOVETYPE_TOSS;
	key.takedamage = DAMAGE_YES;
	key.angles = '0 0 0';
	key.health = key.max_key_health;
	key.kh_droptime = time;
	key.kh_dropper = player;
	key.kh_status = KEY_DROPPED;

	// messages and sounds
	Send_Notification(NOTIF_ALL, world, MSG_INFO, APP_TEAM_ENT_4(key, INFO_KEYHUNT_LOST_), player.netname);
	sound(key, CH_TRIGGER, key.snd_key_dropped, VOL_BASE, ATTEN_NONE);
	kh_EventLog("dropped", player.team, player);

	// scoring
	PlayerTeamScore_AddScore(player, -autocvar_g_keyhunt_score_penalty_drop);
	PlayerScore_Add(player, SP_KH_DROPS, 1);

	// waypoints
	if(autocvar_g_keyhunt_key_dropped_waypoint)
		WaypointSprite_Spawn("keydropped", 0, 0, key, KEY_DROP_OFFSET, world, ((autocvar_g_keyhunt_key_dropped_waypoint == 2) ? 0 : player.team), key, wps_keydropped, TRUE, RADARICON_FLAG, WPCOLOR_DROPPEDKEY(key.team));

	if(autocvar_g_keyhunt_key_return_time || (autocvar_g_keyhunt_key_return_damage && autocvar_g_keyhunt_key_health))
	{
		WaypointSprite_UpdateMaxHealth(key.wps_keydropped, key.max_key_health);
		WaypointSprite_UpdateHealth(key.wps_keydropped, key.health);
	}

	player.throw_antispam = time + autocvar_g_keyhunt_pass_wait;

	if(droptype == DROP_PASS)
	{
		key.pass_distance = 0;
		key.pass_sender = world;
		key.pass_target = world;
	}
}

void kh_Handle_Retrieve(entity key, entity player)
{
	entity tmp_player; // temporary entity which the FOR_EACH_PLAYER loop uses to scan players
	entity sender = key.pass_sender;

	// transfer key to player
	key.owner = player;

	// reset key
	if(player.vehicle)
	{
		setattachment(key, player.vehicle, "");
		setorigin(key, VEHICLE_KEY_OFFSET);
		key.scale = VEHICLE_KEY_SCALE;
	}
	else
	{
		setattachment(key, player, "");
		setorigin(key, KEY_CARRY_OFFSET);
	}
	key.movetype = MOVETYPE_NONE;
	key.takedamage = DAMAGE_NO;
	key.solid = SOLID_NOT;
	key.angles = '0 0 0';
	key.kh_status = KEY_CARRY;

	// messages and sounds
	sound(player, CH_TRIGGER, key.snd_key_pass, VOL_BASE, ATTEN_NORM);
	kh_EventLog("receive", key.team, player);

	FOR_EACH_REALPLAYER(tmp_player)
	{
		if(tmp_player == sender)
			Send_Notification(NOTIF_ONE, tmp_player, MSG_CENTER, APP_TEAM_ENT_4(key, CENTER_KEYHUNT_PASS_SENT_), player.netname);
		else if(tmp_player == player)
			Send_Notification(NOTIF_ONE, tmp_player, MSG_CENTER, APP_TEAM_ENT_4(key, CENTER_KEYHUNT_PASS_RECEIVED_), sender.netname);
		else if(SAME_TEAM(tmp_player, sender))
			Send_Notification(NOTIF_ONE, tmp_player, MSG_CENTER, APP_TEAM_ENT_4(key, CENTER_KEYHUNT_PASS_OTHER_), sender.netname, player.netname);
	}

	// create new waypoint
	kh_KeycarrierWaypoints(player);

	sender.throw_antispam = time + autocvar_g_keyhunt_pass_wait;
	player.throw_antispam = sender.throw_antispam;

	key.pass_distance = 0;
	key.pass_sender = world;
	key.pass_target = world;
}

void kh_Handle_Throw(entity player, entity receiver, entity key, float droptype)
{
	vector targ_origin, key_velocity;

	if(!key) { return; }
	if((droptype == DROP_PASS) && !receiver) { return; }

	// reset the key
	setattachment(key, world, "");
	setorigin(key, player.origin + KEY_DROP_OFFSET);
	key.angles_y += key.owner.angles_y;
	key.owner = world;
	key.solid = SOLID_TRIGGER;
	key.kh_droptime = time;
	key.kh_dropper = player;

	key.flags = FL_ITEM | FL_NOTARGET; // clear FL_ONGROUND for MOVETYPE_TOSS

	switch(droptype)
	{
		case DROP_PASS:
		{
			// warpzone support:
			// for the examples, we assume player -> wz1 -> ... -> wzn -> receiver
			// findradius has already put wzn ... wz1 into receiver's warpzone parameters!
			WarpZone_RefSys_Copy(key, receiver);
			WarpZone_RefSys_AddInverse(key, receiver); // wz1^-1 ... wzn^-1 receiver
			targ_origin = WarpZone_RefSys_TransformOrigin(receiver, key, (0.5 * (receiver.absmin + receiver.absmax))); // this is target origin as seen by the key

			key.pass_distance = vlen((('1 0 0' * targ_origin_x) + ('0 1 0' * targ_origin_y)) - (('1 0 0' *  player.origin_x) + ('0 1 0' *  player.origin_y))); // for the sake of this check, exclude Z axis
			kh_CalculatePassVelocity(key, targ_origin, player.origin, FALSE);

			// main
			key.movetype = MOVETYPE_FLY;
			key.takedamage = DAMAGE_NO;
			key.pass_sender = player;
			key.pass_target = receiver;
			key.kh_status = KEY_PASSING;

			// other
			sound(player, CH_TRIGGER, key.snd_key_touch, VOL_BASE, ATTEN_NORM);
			Send_Effect(key.passeffectnum, player.origin, targ_origin, 0);
			kh_EventLog("pass", key.team, player);
			break;
		}

		case DROP_THROW:
		{
			makevectors((player.v_angle_y * '0 1 0') + (bound(autocvar_g_keyhunt_throw_angle_min, player.v_angle_x, autocvar_g_keyhunt_throw_angle_max) * '1 0 0'));

			key_velocity = (('0 0 1' * autocvar_g_keyhunt_throw_velocity_up) + ((v_forward * autocvar_g_keyhunt_throw_velocity_forward)));
			key.velocity = W_CalculateProjectileVelocity(player.velocity, key_velocity, FALSE);
			kh_Handle_Drop(key, player, droptype);
			break;
		}

		case DROP_RESET:
		{
			key.velocity = '0 0 0'; // do nothing
			break;
		}

		default:
		case DROP_NORMAL:
		{
			key.velocity = W_CalculateProjectileVelocity(player.velocity, (('0 0 1' * autocvar_g_keyhunt_drop_velocity_up) + ((('0 1 0' * crandom()) + ('1 0 0' * crandom())) * autocvar_g_keyhunt_drop_velocity_side)), FALSE);
			kh_Handle_Drop(key, player, droptype);
			break;
		}
	}

	// kill old waypointsprite
	if(player.wps_keycarrier)
	{
		WaypointSprite_Ping(player.wps_keycarrier);
		WaypointSprite_Kill(player.wps_keycarrier);
	}

	if(player.wps_enemykeycarrier)
		WaypointSprite_Kill(player.wps_enemykeycarrier);
}


// ==============
// Event Handlers
// ==============

void kh_RemoveKey(entity key);
void kh_Handle_Capture(float capturetype)
{
	entity key;
	KH_FOR_EACH_KEY(key)
	{
		entity player = key.owner;
		
		if(!player) { continue; } // without someone to give the reward to, we can't possibly cap

		nades_GiveBonus(player, autocvar_g_nades_bonus_score_high);
		
		player.throw_prevtime = time;
		player.throw_count = 0;
		
		Send_Notification(NOTIF_ONE, player, MSG_CENTER, CENTER_KEYHUNT_CAPTURE);
		Send_Notification(NOTIF_ALL, world, MSG_INFO, APP_TEAM_ENT_4(key, INFO_KEYHUNT_CAPTURE_), player.netname);

		PlayerTeamScore_AddScore(player, autocvar_g_keyhunt_score_capture);
		PlayerScore_Add(player, SP_KH_CAPS, 1);

		Send_Effect(key.capeffectnum, kh_AttachedOrigin(key), '0 0 0', 1);
		
		if(key.kh_worldkeynext)
			te_lightning2(world, kh_AttachedOrigin(key), kh_AttachedOrigin(key.kh_worldkeynext));
			
		// kill old waypointsprite
		WaypointSprite_Kill(player.wps_keycarrier);
		WaypointSprite_Kill(player.wps_enemykeycarrier);
		
		if(capturetype == CAPTURE_NORMAL)
		{
			if((key.kh_dropper) && (player != key.kh_dropper))
				{ PlayerTeamScore_AddScore(key.kh_dropper, autocvar_g_keyhunt_score_capture_assist); }
		}
		
		player.next_take_time = time + autocvar_g_keyhunt_key_collect_delay;
		kh_RemoveKey(key); // when all is done, it should be safe to kill the key here
	}
	
	play2all("kh/capture.wav");
}

void kh_Handle_Pickup(entity key, entity player, float pickuptype)
{
	// declarations
	float pickup_dropped_score; // used to calculate dropped pickup score

	// attach the key to the player
	key.owner = player;
	if(player.vehicle)
	{
		setattachment(key, player.vehicle, "");
		//setorigin(key, VEHICLE_KEY_OFFSET);
		key.scale = VEHICLE_KEY_SCALE;
		setorigin(key, '0 0 1' * KH_VEHICLE_KEY_ZSHIFT); // fixing x, y in think
		key.angles_y -= player.angles_y;
	}
	else
	{
		setattachment(key, player, "");
		//setorigin(key, KEY_CARRY_OFFSET);
		setorigin(key, '0 0 1' * KH_KEY_ZSHIFT); // fixing x, y in think
		key.angles_y -= player.angles_y;
	}

	// key setup
	key.movetype = MOVETYPE_NONE;
	key.takedamage = DAMAGE_NO;
	key.solid = SOLID_NOT;
	key.angles = '0 0 0';
	key.kh_status = KEY_CARRY;
	
	//if(pickuptype != PICKUP_KILLED)
	if(key.kh_dropper)
	{
		entity tmp_entity;
		float key_count = 0;
		KH_FOR_EACH_KEY(tmp_entity) if(tmp_entity.kh_dropper == key.kh_dropper && tmp_entity != key) { ++key_count; }
		if(key_count < 1) // player dropped no other keys
			key.kh_dropper.kh_lastkiller = world; // reset when picked up
	}

	switch(pickuptype)
	{
		case PICKUP_KILLED:
		case PICKUP_DROPPED: key.health = key.max_key_health; break; // reset health/return timelimit
		default: break;
	}

	// messages and sounds
	if(pickuptype == PICKUP_START)
	{
		Send_Notification(NOTIF_ALL, world, MSG_INFO, APP_TEAM_ENT_4(key, INFO_KEYHUNT_START_), player.netname);
		Send_Notification(NOTIF_ONE, player, MSG_CENTER, APP_TEAM_ENT_4(key, CENTER_KEYHUNT_START_));
		Send_Notification(NOTIF_TEAM_EXCEPT, player, MSG_CHOICE, APP_TEAM_ENT_4(key, CHOICE_KEYHUNT_START_TEAM_), Team_ColorCode(player.team), player.netname);
	}
	else
	{
		Send_Notification(NOTIF_ALL, world, MSG_INFO, APP_TEAM_ENT_4(key, INFO_KEYHUNT_PICKUP_), player.netname);
		Send_Notification(NOTIF_ONE, player, MSG_CENTER, APP_TEAM_ENT_4(key, CENTER_KEYHUNT_PICKUP_));
		Send_Notification(NOTIF_TEAM_EXCEPT, player, MSG_CHOICE, APP_TEAM_ENT_4(key, CHOICE_KEYHUNT_PICKUP_TEAM_), Team_ColorCode(player.team), player.netname);

		sound(player, CH_TRIGGER, key.snd_key_taken, VOL_BASE, ATTEN_NONE);
	}

	// scoring
	PlayerScore_Add(player, SP_KH_PICKUPS, 1);
	nades_GiveBonus(player, autocvar_g_nades_bonus_score_minor);
	switch(pickuptype)
	{
		case PICKUP_KILLED:
		case PICKUP_DROPPED:
		{
			pickup_dropped_score = (autocvar_g_keyhunt_key_return_time ? bound(0, ((key.kh_droptime + autocvar_g_keyhunt_key_return_time) - time) / autocvar_g_keyhunt_key_return_time, 1) : 1);
			pickup_dropped_score = floor((autocvar_g_keyhunt_score_pickup_dropped_late * (1 - pickup_dropped_score) + autocvar_g_keyhunt_score_pickup_dropped_early * pickup_dropped_score) + 0.5);
			dprint("pickup_dropped_score is ", ftos(pickup_dropped_score), "\n");
			PlayerTeamScore_AddScore(player, pickup_dropped_score);
			kh_EventLog("pickup", key.team, player);
			break;
		}

		default: break;
	}

	// effects
	Send_Effect(key.toucheffectnum, player.origin, '0 0 0', 1);

	// waypoints
	if(pickuptype == PICKUP_DROPPED || pickuptype == PICKUP_KILLED) { WaypointSprite_Kill(key.wps_keydropped); }
	kh_KeycarrierWaypoints(player);
	WaypointSprite_Ping(player.wps_keycarrier);
}


// ===================
// Main Key Functions
// ===================

void kh_CheckKeyReturn(entity key, float returntype)
{
	if((key.kh_status == KEY_DROPPED) || (key.kh_status == KEY_PASSING))
	{
		if(key.wps_keydropped) { WaypointSprite_UpdateHealth(key.wps_keydropped, key.health); }

		if((key.health <= 0) || (time >= key.kh_droptime + autocvar_g_keyhunt_key_return_time))
		{
			switch(returntype)
			{
				case RETURN_DAMAGE: Send_Notification(NOTIF_ALL, world, MSG_INFO, APP_TEAM_ENT_4(key, INFO_KEYHUNT_KEYRETURN_DAMAGED_)); break;
				case RETURN_NEEDKILL:
				{
					entity killer = key.kh_dropper.kh_lastkiller;
					if(autocvar_g_keyhunt_key_return_tokiller && IS_PLAYER(killer) && killer.health > 0 && !killer.frozen)
					{
						kh_Handle_Pickup(key, killer, PICKUP_KILLED);
						return;
					}
					else
					{
						entity newcarrier = kh_ChooseNewCarrier(key);
						if(autocvar_g_keyhunt_key_return_toenemy && newcarrier)
						{
							kh_Handle_Pickup(key, newcarrier, PICKUP_KILLED);
							return;
						}
						Send_Notification(NOTIF_ALL, world, MSG_INFO, APP_TEAM_ENT_4(key, INFO_KEYHUNT_KEYRETURN_NEEDKILL_));
						break;
					}
				}

				default:
				case RETURN_TIMEOUT:
					{ Send_Notification(NOTIF_ALL, world, MSG_INFO, APP_TEAM_ENT_4(key, INFO_KEYHUNT_KEYRETURN_TIMEOUT_)); break; }
			}
			sound(key, CH_TRIGGER, key.snd_key_respawn, VOL_BASE, ATTEN_NONE);
			kh_EventLog("returned", key.team, world);
			kh_RemoveKey(key);
		}
	}
}

void kh_KeyDamage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if(ITEM_DAMAGE_NEEDKILL(deathtype))
	{
		self.health = 0;
		kh_CheckKeyReturn(self, RETURN_NEEDKILL);
		return;
	}
	if(autocvar_g_keyhunt_key_return_damage)
	{
		// reduce health and check if it should be returned
		self.health = self.health - damage;
		kh_CheckKeyReturn(self, RETURN_DAMAGE);
		return;
	}
}

void kh_KeyThink()
{
	self.nextthink = time + KEY_THINKRATE; // only 5 fps, more is unnecessary.

	// sanity checks
	if(self.mins != KEY_MIN || self.maxs != KEY_MAX) { // reset the key boundaries in case it got squished
		dprint("wtf the key got squashed?\n");
		tracebox(self.origin, KEY_MIN, KEY_MAX, self.origin, MOVE_NOMONSTERS, self);
		if(!trace_startsolid) // can we resize it without getting stuck?
			setsize(self, KEY_MIN, KEY_MAX); }

	switch(self.kh_status) // reset key angles in case warpzones adjust it
	{
		case KEY_DROPPED:
		{
			self.angles = '0 0 0';
			break;
		}

		default: break;
	}

	// main think method
	switch(self.kh_status)
	{
		case KEY_DROPPED:
		{
			if(autocvar_g_keyhunt_key_dropped_floatinwater)
			{
				vector midpoint = ((self.absmin + self.absmax) * 0.5);
				if(pointcontents(midpoint) == CONTENT_WATER)
				{
					self.velocity = self.velocity * 0.5;

					if(pointcontents(midpoint + KEY_FLOAT_OFFSET) == CONTENT_WATER)
						{ self.velocity_z = autocvar_g_keyhunt_key_dropped_floatinwater; }
					else
						{ self.movetype = MOVETYPE_FLY; }
				}
				else if(self.movetype == MOVETYPE_FLY) { self.movetype = MOVETYPE_TOSS; }
			}
			if(autocvar_g_keyhunt_key_return_time)
			{
				self.health -= ((self.max_key_health / autocvar_g_keyhunt_key_return_time) * KEY_THINKRATE);
				kh_CheckKeyReturn(self, RETURN_TIMEOUT);
				return;
			}
			return;
		}

		case KEY_CARRY:
		{
			makevectors('0 1 0' * (self.cnt + mod(time, 360) * KH_KEY_XYSPEED));
			setorigin(self, v_forward * ((self.owner.vehicle) ? KH_VEHICLE_KEY_XYDIST : KH_KEY_XYDIST) + '0 0 1' * self.origin_z);
			return;
		}

		case KEY_PASSING:
		{
			vector targ_origin = ((self.pass_target.absmin + self.pass_target.absmax) * 0.5);
			targ_origin = WarpZone_RefSys_TransformOrigin(self.pass_target, self, targ_origin); // origin of target as seen by the key (us)
			WarpZone_TraceLine(self.origin, targ_origin, MOVE_NOMONSTERS, self);

			if((self.pass_target == world)
				|| (self.pass_target.deadflag != DEAD_NO)
				|| (vlen(self.origin - targ_origin) > autocvar_g_keyhunt_pass_radius)
				|| ((trace_fraction < 1) && (trace_ent != self.pass_target))
				|| (time > self.kh_droptime + autocvar_g_keyhunt_pass_timelimit))
			{
				// give up, pass failed
				kh_Handle_Drop(self, world, DROP_PASS);
			}
			else
			{
				// still a viable target, go for it
				kh_CalculatePassVelocity(self, targ_origin, self.origin, TRUE);
			}
			return;
		}

		default: // this should never happen
		{
			dprint("kh_KeyThink(): Key exists with no status?\n");
			return;
		}
	}
}

float kh_Customize()
{
	entity e = WaypointSprite_getviewentity(other);

	if(self.owner == e)
		self.glow_trail = 0;
	else if(autocvar_g_keyhunt_key_glowtrails)
		self.glow_trail = 1;

	return TRUE;
}

void kh_KeyTouch()
{
	if(gameover) { return; }

	entity toucher = other;

	// automatically kill the key and return it if it touched lava/slime/nodrop surfaces
	if(ITEM_TOUCH_NEEDKILL())
	{
		self.health = 0;
		kh_CheckKeyReturn(self, RETURN_NEEDKILL);
		return;
	}

	// special touch behaviors
	if(toucher.frozen) { return; }
	else if(IS_VEHICLE(toucher))
	{
		if(autocvar_g_keyhunt_allow_vehicle_touch && toucher.owner)
			toucher = toucher.owner; // the player is actually the vehicle owner, not other
		else
			return; // do nothing
	}
	else if (!IS_PLAYER(toucher)) // The key just touched an object, most likely the world
	{
		if(time > self.wait) // if we haven't in a while, play a sound/effect
		{
			Send_Effect(self.toucheffectnum, self.origin, '0 0 0', 1);
			sound(self, CH_TRIGGER, self.snd_key_touch, VOL_BASE, ATTEN_NORM);
			self.wait = time + KEY_TOUCHRATE;
		}
		return;
	}
	else if(toucher.deadflag != DEAD_NO) { return; }

	switch(self.kh_status)
	{
		case KEY_DROPPED:
		{
			if(((toucher != self.kh_dropper) || (time > self.kh_droptime + autocvar_g_keyhunt_key_collect_delay)))
				kh_Handle_Pickup(self, toucher, PICKUP_DROPPED); // toucher just picked up a dropped enemy key
			break;
		}

		case KEY_CARRY:
		{
			dprint("Someone touched a key even though it was being carried?\n");
			break;
		}

		case KEY_PASSING:
		{
			if((IS_PLAYER(toucher)) && (toucher.deadflag == DEAD_NO) && (toucher != self.pass_sender))
				kh_Handle_Retrieve(self, toucher);
			break;
		}
	}
}

void kh_RemoveKey(entity key)
{
	// kill old waypointsprite
	WaypointSprite_Kill(key.owner.wps_keycarrier);
	WaypointSprite_Kill(key.owner.wps_enemykeycarrier);

	if(key.kh_status == KEY_DROPPED)
		{ WaypointSprite_Kill(key.wps_keydropped); }

	// reset the key
	setattachment(key, world, "");

	key.think = SUB_Remove;
	key.nextthink = time;
}

void kh_Reset()
{
	if(self.owner)
		if(IS_PLAYER(self.owner))
			kh_Handle_Throw(self.owner, world, self, DROP_RESET);

	kh_RemoveKey(self);
}

void kh_KeySetup(float teamnumber, entity key, entity player) // called when spawning a key entity
{
	// declarations
	self = key; // for later usage with droptofloor()

	// main setup
	key.kh_worldkeynext = kh_worldkeylist; // link key into kh_worldkeylist
	kh_worldkeylist = key;

	setattachment(key, world, "");

	key.netname = sprintf("%s%s^7 key", Team_ColorCode(teamnumber), Team_ColorName_Upper(teamnumber));
	key.team = teamnumber;
	key.classname = "item_key_team";
	key.target = "###item###"; // wut?
	key.flags = FL_ITEM | FL_NOTARGET;
	key.solid = SOLID_TRIGGER;
	key.takedamage = DAMAGE_NO;
	key.customizeentityforclient = kh_Customize;
	key.damageforcescale = autocvar_g_keyhunt_key_damageforcescale;
	key.max_key_health = ((autocvar_g_keyhunt_key_return_damage && autocvar_g_keyhunt_key_health) ? autocvar_g_keyhunt_key_health : 100);
	key.health = key.max_key_health;
	key.event_damage = kh_KeyDamage;
	key.pushable = TRUE;
	key.teleportable = TELEPORT_NORMAL;
	key.damagedbytriggers = autocvar_g_keyhunt_key_return_when_unreachable;
	key.damagedbycontents = autocvar_g_keyhunt_key_return_when_unreachable;
	key.velocity = '0 0 0';
	key.mangle = key.angles;
	key.cnt = 360 * Team_TeamToNumber(teamnumber) / kh_teams;
	key.reset = kh_Reset;
	key.touch = kh_KeyTouch;
	key.think = kh_KeyThink;
	key.nextthink = time + KEY_THINKRATE;
	key.kh_status = KEY_CARRY;
	key.colormod = Team_ColorRGB(teamnumber) * KEY_BRIGHTNESS;

	// appearence
	key.model = "models/keyhunt/key.md3";
	key.scale = KEY_SCALE;
	key.toucheffectnum = ((teamnumber == NUM_TEAM_1) ? EFFECT_FLAG_RED_TOUCH : ((teamnumber == NUM_TEAM_2) ? EFFECT_FLAG_BLUE_TOUCH : ((teamnumber == NUM_TEAM_3) ? EFFECT_FLAG_YELLOW_TOUCH : EFFECT_FLAG_PINK_TOUCH)));
	key.passeffectnum = ((teamnumber == NUM_TEAM_1) ? EFFECT_RED_PASS : ((teamnumber == NUM_TEAM_2) ? EFFECT_BLUE_PASS : ((teamnumber == NUM_TEAM_3) ? EFFECT_YELLOW_PASS : EFFECT_PINK_PASS)));
	key.capeffectnum = ((teamnumber == NUM_TEAM_1) ? EFFECT_RED_CAP : ((teamnumber == NUM_TEAM_2) ? EFFECT_BLUE_CAP : ((teamnumber == NUM_TEAM_3) ? EFFECT_YELLOW_CAP : EFFECT_PINK_CAP)));

	// sound
	key.snd_key_taken = "kh/collect.wav";
	key.snd_key_capture = "kh/capture.wav";
	key.snd_key_dropped = "kh/drop.wav";
	key.snd_key_touch = "ctf/touch.wav";
	key.snd_key_pass = "ctf/pass.wav";

	// appearence
	setmodel(key, key.model); // precision set below
	setsize(key, KEY_MIN, KEY_MAX);
	setorigin(key, (key.origin + KEY_SPAWN_OFFSET));

	if(autocvar_g_keyhunt_key_glowtrails)
	{
		key.glow_color = ((teamnumber == NUM_TEAM_1) ? 251 : ((teamnumber == NUM_TEAM_2) ? 210 : ((teamnumber == NUM_TEAM_3) ? 110 : 145)));
		key.glow_size = 25;
		key.glow_trail = 1;
	}

	key.effects |= EF_LOWPRECISION;
	if(autocvar_g_keyhunt_fullbrightkeys) { key.effects |= EF_FULLBRIGHT; }
	if(autocvar_g_keyhunt_dynamiclights)
	{
		switch(teamnumber)
		{
			case NUM_TEAM_1: key.effects |= EF_RED; break;
			case NUM_TEAM_2: key.effects |= EF_BLUE; break;
			case NUM_TEAM_3: key.effects |= EF_DIMLIGHT; break;
			case NUM_TEAM_4: key.effects |= EF_RED; break;
		}
	}

	kh_Handle_Pickup(key, player, PICKUP_START);
}


// ==================
//  Legacy Bot Logic
// ==================

void() havocbot_role_kh_carrier;
void() havocbot_role_kh_defense;
void() havocbot_role_kh_offense;
void() havocbot_role_kh_freelancer;
void havocbot_goalrating_kh(float ratingscale_team, float ratingscale_dropped, float ratingscale_enemy)
{
	entity head;
	for (head = kh_worldkeylist; head && !wasfreed(head); head = head.kh_worldkeynext)
	{
		if(head.owner == self)
			continue;
		if(!head.owner)
			navigation_routerating(head, ratingscale_dropped * BOT_PICKUP_RATING_HIGH, 100000);
		else if(head.team == self.team)
			navigation_routerating(head.owner, ratingscale_team * BOT_PICKUP_RATING_HIGH, 100000);
		else
			navigation_routerating(head.owner, ratingscale_enemy * BOT_PICKUP_RATING_HIGH, 100000);
	}

	havocbot_goalrating_items(1, self.origin, 10000);
}

void havocbot_role_kh_carrier()
{
	if(self.deadflag != DEAD_NO)
		return;
		
	entity key;
	float is_carrier = FALSE;
	KH_FOR_EACH_KEY(key)
	if(key.owner == self)
	{
		is_carrier = TRUE;
		break;
	}

	if (!is_carrier)
	{
		dprint("changing role to freelancer\n");
		self.havocbot_role = havocbot_role_kh_freelancer;
		self.havocbot_role_timeout = 0;
		return;
	}

	if (self.bot_strategytime < time)
	{
		self.bot_strategytime = time + autocvar_bot_ai_strategyinterval;
		navigation_goalrating_start();
		
		float key_count = 0;
		KH_FOR_EACH_KEY(key) { if(!wasfreed(key) && SAME_TEAM(key, self)) ++key_count; }
		
		if(key_count >= kh_teams)
			havocbot_goalrating_kh(10, 0.1, 0.1); // bring home
		else
			havocbot_goalrating_kh(4, 4, 1); // play defensively

		navigation_goalrating_end();
	}
}

void havocbot_role_kh_defense()
{
	if(self.deadflag != DEAD_NO)
		return;
		
	entity key;
	float is_carrier = FALSE;
	KH_FOR_EACH_KEY(key)
	if(key.owner == self)
	{
		is_carrier = TRUE;
		break;
	}

	if (is_carrier)
	{
		dprint("changing role to carrier\n");
		self.havocbot_role = havocbot_role_kh_carrier;
		self.havocbot_role_timeout = 0;
		return;
	}

	if (!self.havocbot_role_timeout)
		self.havocbot_role_timeout = time + random() * 10 + 20;
	if (time > self.havocbot_role_timeout)
	{
		dprint("changing role to freelancer\n");
		self.havocbot_role = havocbot_role_kh_freelancer;
		self.havocbot_role_timeout = 0;
		return;
	}

	if (self.bot_strategytime < time)
	{
		self.bot_strategytime = time + autocvar_bot_ai_strategyinterval;
		navigation_goalrating_start();
		
		float key_count = 0;
		KH_FOR_EACH_KEY(key) { if(!wasfreed(key) && SAME_TEAM(key, self)) ++key_count; }
		
		if(key_count >= kh_teams)
			havocbot_goalrating_kh(10, 0.1, 0.1); // defend key carriers
		else if(key_count == 0)
			havocbot_goalrating_kh(4, 1, 0.1); // play defensively
		else
			havocbot_goalrating_kh(0.1, 0.1, 10); // ATTACK ANYWAY

		navigation_goalrating_end();
	}
}

void havocbot_role_kh_offense()
{
	if(self.deadflag != DEAD_NO)
		return;
		
	entity key;
	float is_carrier = FALSE;
	KH_FOR_EACH_KEY(key)
	if(key.owner == self)
	{
		is_carrier = TRUE;
		break;
	}

	if (is_carrier)
	{
		dprint("changing role to carrier\n");
		self.havocbot_role = havocbot_role_kh_carrier;
		self.havocbot_role_timeout = 0;
		return;
	}

	if (!self.havocbot_role_timeout)
		self.havocbot_role_timeout = time + random() * 10 + 20;
	if (time > self.havocbot_role_timeout)
	{
		dprint("changing role to freelancer\n");
		self.havocbot_role = havocbot_role_kh_freelancer;
		self.havocbot_role_timeout = 0;
		return;
	}

	if (self.bot_strategytime < time)
	{
		self.bot_strategytime = time + autocvar_bot_ai_strategyinterval;
		navigation_goalrating_start();
		
		float key_count = 0;
		KH_FOR_EACH_KEY(key) { if(!wasfreed(key) && SAME_TEAM(key, self)) ++key_count; }
		
		if(key_count >= kh_teams)
			havocbot_goalrating_kh(10, 0.1, 0.1); // defend key carriers
		else if(key_count == 0)
			havocbot_goalrating_kh(4, 1, 0.1); // play defensively
		else
			havocbot_goalrating_kh(0.1, 0.1, 10); // ATTACK ANYWAY

		navigation_goalrating_end();
	}
}

void havocbot_role_kh_freelancer()
{
	if(self.deadflag != DEAD_NO)
		return;
		
	entity key;
	float is_carrier = FALSE;
	KH_FOR_EACH_KEY(key)
	if(key.owner == self)
	{
		is_carrier = TRUE;
		break;
	}

	if (is_carrier)
	{
		dprint("changing role to carrier\n");
		self.havocbot_role = havocbot_role_kh_carrier;
		self.havocbot_role_timeout = 0;
		return;
	}

	if (!self.havocbot_role_timeout)
		self.havocbot_role_timeout = time + random() * 10 + 10;
	if (time > self.havocbot_role_timeout)
	{
		if (random() < 0.5)
		{
			dprint("changing role to offense\n");
			self.havocbot_role = havocbot_role_kh_offense;
		}
		else
		{
			dprint("changing role to defense\n");
			self.havocbot_role = havocbot_role_kh_defense;
		}
		self.havocbot_role_timeout = 0;
		return;
	}

	if (self.bot_strategytime < time)
	{
		self.bot_strategytime = time + autocvar_bot_ai_strategyinterval;
		navigation_goalrating_start();

		float key_count = 0;
		KH_FOR_EACH_KEY(key) { if(!wasfreed(key) && SAME_TEAM(key, self)) ++key_count; }
		
		if(key_count >= kh_teams)
			havocbot_goalrating_kh(10, 0.1, 0.1); // defend key carriers
		else if(key_count == 0)
			havocbot_goalrating_kh(4, 1, 0.1); // play defensively
		else
			havocbot_goalrating_kh(0.1, 0.1, 10); // ATTACK ANYWAY

		navigation_goalrating_end();
	}
}


// ==============
// Hook Functions
// ==============

MUTATOR_HOOKFUNCTION(kh_PlayerPreThink)
{
	entity key;

	float t = 0, t2 = 0, t3 = 0;

	// initially clear items so they can be set as necessary later.
	self.kh_keystatus &= ~(KH_RED_KEY_CARRYING 		| KH_RED_KEY_TAKEN		| KH_RED_KEY_LOST 
						 | KH_BLUE_KEY_CARRYING 	| KH_BLUE_KEY_TAKEN 	| KH_BLUE_KEY_LOST
						 | KH_YELLOW_KEY_CARRYING	| KH_YELLOW_KEY_TAKEN 	| KH_YELLOW_KEY_LOST
						 | KH_PINK_KEY_CARRYING 	| KH_PINK_KEY_TAKEN 	| KH_PINK_KEY_LOST);

	// scan through all the keys and notify the client about them
	KH_FOR_EACH_KEY(key)
	{
		if(key.team == NUM_TEAM_1) { t = KH_RED_KEY_CARRYING;		t2 = KH_RED_KEY_TAKEN;		t3 = KH_RED_KEY_LOST; }
		if(key.team == NUM_TEAM_2) { t = KH_BLUE_KEY_CARRYING;		t2 = KH_BLUE_KEY_TAKEN;		t3 = KH_BLUE_KEY_LOST; }
		if(key.team == NUM_TEAM_3) { t = KH_YELLOW_KEY_CARRYING; 	t2 = KH_YELLOW_KEY_TAKEN; 	t3 = KH_YELLOW_KEY_LOST; }
		if(key.team == NUM_TEAM_4) { t = KH_PINK_KEY_CARRYING;		t2 = KH_PINK_KEY_TAKEN;		t3 = KH_PINK_KEY_LOST; }

		switch(key.kh_status)
		{
			case KEY_PASSING:
			case KEY_CARRY:
			{
				if((key.owner == self) || (key.pass_sender == self))
					self.kh_keystatus |= t; // carrying: self is currently carrying the key
				else 
					self.kh_keystatus |= t2; // taken: someone else is carrying the key
				break;
			}
			case KEY_DROPPED:
			{
				self.kh_keystatus |= t3; // lost: the key is dropped somewhere on the map
				break;
			}
		}
		
		switch(key.team)
		{
			case NUM_TEAM_1: self.stat_kh_redkey_team = Team_TeamToNumber(key.owner.team); break;
			case NUM_TEAM_2: self.stat_kh_bluekey_team = Team_TeamToNumber(key.owner.team); break;
			case NUM_TEAM_3: self.stat_kh_yellowkey_team = Team_TeamToNumber(key.owner.team); break;
			case NUM_TEAM_4: self.stat_kh_pinkkey_team = Team_TeamToNumber(key.owner.team); break;
		}
	}

	// update the health of the key carrier waypointsprite
	if(self.wps_keycarrier)
		WaypointSprite_UpdateHealth(self.wps_keycarrier, '1 0 0' * healtharmor_maxdamage(self.health, self.armorvalue, autocvar_g_balance_armor_blockpercent, DEATH_WEAPON));

	return FALSE;
}

MUTATOR_HOOKFUNCTION(kh_PlayerDamage) // for changing damage and force values that are applied to players in g_damage.qc
{
	entity key;
	float targ_iscarrier = FALSE, attacker_iscarrier = FALSE;
	KH_FOR_EACH_KEY(key)
	{
		if(key.owner == frag_attacker) { attacker_iscarrier = TRUE; }
		if(key.owner == frag_target) { targ_iscarrier = TRUE; }
	}

	if(attacker_iscarrier) // if the attacker is a keycarrier
	{
		if(frag_target == frag_attacker) // damage done to yourself
		{
			frag_damage *= autocvar_g_keyhunt_keycarrier_selfdamagefactor;
			frag_force *= autocvar_g_keyhunt_keycarrier_selfforcefactor;
		}
		else // damage done to everyone else
		{
			frag_damage *= autocvar_g_keyhunt_keycarrier_damagefactor;
			frag_force *= autocvar_g_keyhunt_keycarrier_forcefactor;
		}
	}
	else if(targ_iscarrier && (frag_target.deadflag == DEAD_NO) && DIFF_TEAM(frag_target, frag_attacker)) // if the target is a keycarrier
	{
		if(autocvar_g_keyhunt_keycarrier_auto_helpme_damage > ('1 0 0' * healtharmor_maxdamage(frag_target.health, frag_target.armorvalue, autocvar_g_balance_armor_blockpercent, DEATH_WEAPON)))
		if(time > frag_target.wps_helpme_time + autocvar_g_keyhunt_keycarrier_auto_helpme_time)
		{
			frag_target.wps_helpme_time = time;
			WaypointSprite_HelpMePing(frag_target.wps_keycarrier);
		}
		// todo: add notification for when key carrier needs help?
	}
	return FALSE;
}

MUTATOR_HOOKFUNCTION(kh_PlayerDies)
{
	entity tmp_entity;
	float targ_iscarrier = FALSE;

	KH_FOR_EACH_KEY(tmp_entity) if(tmp_entity.owner == frag_target) { targ_iscarrier = TRUE; break; }

	if((frag_attacker != frag_target) && (IS_PLAYER(frag_attacker)) && targ_iscarrier)
	{
		PlayerTeamScore_AddScore(frag_attacker, autocvar_g_keyhunt_score_kill);
		PlayerScore_Add(frag_attacker, SP_KH_KCKILLS, 1);
	}

	KH_FOR_EACH_KEY(tmp_entity) if(tmp_entity.owner == frag_target) { kh_Handle_Throw(frag_target, world, tmp_entity, DROP_NORMAL); }
	
	if(targ_iscarrier)
	if(IS_PLAYER(frag_attacker))
	if(frag_attacker != frag_target)
		frag_target.kh_lastkiller = frag_attacker;

	FOR_EACH_PLAYER(tmp_entity) if(tmp_entity.kh_lastkiller == frag_target) { tmp_entity.kh_lastkiller = frag_attacker; }

	return FALSE;
}

MUTATOR_HOOKFUNCTION(kh_GiveFragsForKill)
{
	frag_score = 0;
	return (autocvar_g_keyhunt_ignore_frags); // no frags counted in keyhunt if this is true
}

MUTATOR_HOOKFUNCTION(kh_RemovePlayer)
{
	entity key; // temporary entity for the search method

	KH_FOR_EACH_KEY(key) if(key.owner == self) { kh_Handle_Throw(self, world, key, DROP_NORMAL); }

	KH_FOR_EACH_KEY(key) // handle this separately, as the above may reset them
	{
		if(key.pass_sender == self) { key.pass_sender = world; }
		if(key.pass_target == self) { key.pass_target = world; }
		if(key.kh_dropper == self) { key.kh_dropper = world; }
	}

	return FALSE;
}

MUTATOR_HOOKFUNCTION(kh_PortalTeleport)
{
	entity key;

	if(!autocvar_g_keyhunt_portalteleport)
	KH_FOR_EACH_KEY(key)
	if(key.owner == self) { kh_Handle_Throw(self, world, key, DROP_NORMAL); }

	return FALSE;
}

MUTATOR_HOOKFUNCTION(kh_PlayerUseKey)
{
	if(MUTATOR_RETURNVALUE || gameover) { return FALSE; }

	entity player = self, key, player_key = world;
	
	KH_FOR_EACH_KEY(key)
	if(key.owner == player) { player_key = key; }

	if((time > player.throw_antispam) && (player.deadflag == DEAD_NO) && (!player.vehicle || autocvar_g_keyhunt_allow_vehicle_touch))
	{
		// pass the key to a team mate
		if(autocvar_g_keyhunt_pass)
		{
			entity head, closest_target = world;
			head = WarpZone_FindRadius(player.origin, autocvar_g_keyhunt_pass_radius, TRUE);

			while(head) // find the closest acceptable target to pass to
			{
				if(IS_PLAYER(head) && head.deadflag == DEAD_NO)
				if(head != player && SAME_TEAM(head, player))
				if(!head.vehicle)
				{
					// if it's a player, use the view origin as reference (stolen from RadiusDamage functions in g_damage.qc)
					vector head_center = WarpZone_UnTransformOrigin(head, CENTER_OR_VIEWOFS(head));
					vector passer_center = CENTER_OR_VIEWOFS(player);
					entity head_key = world;
					
					KH_FOR_EACH_KEY(key)
					if(key.owner == head) { head_key = key; break; }

					if(kh_CheckPassDirection(head_center, passer_center, player.v_angle, head.WarpZone_findradius_nearest))
					{
						if(autocvar_g_keyhunt_pass_request && !player_key && head_key)
						{
							if(IS_BOT_CLIENT(head))
							{
								Send_Notification(NOTIF_ONE, player, MSG_CENTER, CENTER_KEYHUNT_PASS_REQUESTING, head.netname);
								kh_Handle_Throw(head, player, head_key, DROP_PASS);
							}
							else
							{
								Send_Notification(NOTIF_ONE, head, MSG_CENTER, CENTER_KEYHUNT_PASS_REQUESTED, player.netname);
								Send_Notification(NOTIF_ONE, player, MSG_CENTER, CENTER_KEYHUNT_PASS_REQUESTING, head.netname);
							}
							player.throw_antispam = time + autocvar_g_keyhunt_pass_wait;
							return TRUE;
						}
						else if(player_key)
						{
							if(closest_target)
							{
								vector closest_target_center = WarpZone_UnTransformOrigin(closest_target, CENTER_OR_VIEWOFS(closest_target));
								if(vlen(passer_center - head_center) < vlen(passer_center - closest_target_center))
									{ closest_target = head; }
							}
							else { closest_target = head; }
						}
					}
				}
				head = head.chain;
			}

			if(closest_target) { kh_Handle_Throw(player, closest_target, player_key, DROP_PASS); return TRUE; }
		}

		// throw the key in front of you
		if(autocvar_g_keyhunt_throw && player_key)
		{
			if(player.throw_count == -1)
			{
				if(time > player.throw_prevtime + autocvar_g_keyhunt_throw_punish_delay)
				{
					player.throw_prevtime = time;
					player.throw_count = 1;
					kh_Handle_Throw(player, world, player_key, DROP_THROW);
					return TRUE;
				}
				else
				{
					Send_Notification(NOTIF_ONE, player, MSG_CENTER, CENTER_KEYHUNT_KEY_THROW_PUNISH, rint((player.throw_prevtime + autocvar_g_keyhunt_throw_punish_delay) - time));
					return FALSE;
				}
			}
			else
			{
				if(time > player.throw_prevtime + autocvar_g_keyhunt_throw_punish_time) { player.throw_count = 1; }
				else { player.throw_count += 1; }
				if(player.throw_count >= autocvar_g_keyhunt_throw_punish_count) { player.throw_count = -1; }

				player.throw_prevtime = time;
				kh_Handle_Throw(player, world, player_key, DROP_THROW);
				return TRUE;
			}
		}
	}

	return FALSE;
}

MUTATOR_HOOKFUNCTION(kh_ResetMapGlobal)
{
	entity e, key;
	FOR_EACH_CLIENT(e)
	{
		e.stat_kh_redkey_team = e.stat_kh_bluekey_team = e.stat_kh_yellowkey_team = e.stat_kh_pinkkey_team = 0;
		e.kh_lastkiller = world;
	}
	KH_FOR_EACH_KEY(key) { if(!wasfreed(key)) kh_RemoveKey(key); }
	kh_worldkeylist = world; // reset key list
	return FALSE;
}

MUTATOR_HOOKFUNCTION(kh_ResetMap)
{
	// don't reset players
	return TRUE;
}

MUTATOR_HOOKFUNCTION(kh_HelpMePing)
{
	if(self.wps_keycarrier) // update the keycarrier waypointsprite with "NEEDING HELP" notification
	{
		self.wps_helpme_time = time;
		WaypointSprite_HelpMePing(self.wps_keycarrier);
	}
	else // create a normal help me waypointsprite
	{
		WaypointSprite_Spawn("helpme", waypointsprite_deployed_lifetime, waypointsprite_limitedrange, self, KEY_WAYPOINT_OFFSET, world, self.team, self, wps_helpme, FALSE, RADARICON_HELPME, '1 0.5 0');
		WaypointSprite_Ping(self.wps_helpme);
	}

	return TRUE;
}

MUTATOR_HOOKFUNCTION(kh_VehicleEnter)
{
	entity key;
	if(!autocvar_g_keyhunt_allow_vehicle_carry && !autocvar_g_keyhunt_allow_vehicle_touch)
	{
		KH_FOR_EACH_KEY(key)
		if(key.owner == vh_player) { kh_Handle_Throw(vh_player, world, key, DROP_NORMAL); }
	}
	else
	{
		KH_FOR_EACH_KEY(key)
		if(key.owner == vh_player)
		{
			setattachment(key, vh_vehicle, "");
			setorigin(key, VEHICLE_KEY_OFFSET);
			key.scale = VEHICLE_KEY_SCALE;
			//key.angles = '0 0 0';
		}
	}

	return FALSE;
}

MUTATOR_HOOKFUNCTION(kh_VehicleExit)
{
	entity key;
	KH_FOR_EACH_KEY(key)
	if(key.owner == vh_player)
	{
		setattachment(key, vh_player, "");
		setorigin(key, KEY_CARRY_OFFSET);
		key.scale = KEY_SCALE;
		key.angles = '0 0 0';
	}

	return FALSE;
}

MUTATOR_HOOKFUNCTION(kh_MatchEnd)
{
	entity key; // temporary entity for the search method

	KH_FOR_EACH_KEY(key)
	{
		switch(key.kh_status)
		{
			case KEY_DROPPED:
			case KEY_PASSING:
			{
				// lock the key, game is over
				key.movetype = MOVETYPE_NONE;
				key.takedamage = DAMAGE_NO;
				key.solid = SOLID_NOT;
				key.nextthink = FALSE; // stop thinking

				//dprint("stopping the ", key.netname, " from moving.\n");
				break;
			}

			default:
			case KEY_CARRY:
			{
				// do nothing for these keys
				break;
			}
		}
	}

	return FALSE;
}

MUTATOR_HOOKFUNCTION(kh_BotRoles)
{
	float r = random() * 3;
	if (r < 1)
		self.havocbot_role = havocbot_role_kh_offense;
	else if (r < 2)
		self.havocbot_role = havocbot_role_kh_defense;
	else
		self.havocbot_role = havocbot_role_kh_freelancer;
	return TRUE;
}

MUTATOR_HOOKFUNCTION(kh_GetTeamCount)
{
	ret_float = kh_teams;
	return FALSE;
}


// ==============
// Initialization
// ==============

// scoreboard setup
void kh_ScoreRules(float teams)
{
	CheckAllowedTeams(world);
	ScoreRules_basics(teams, SFL_SORT_PRIO_PRIMARY, 0, TRUE);
	ScoreInfo_SetLabel_TeamScore  (ST_KH_CAPS,     "caps",      SFL_SORT_PRIO_PRIMARY);
	ScoreInfo_SetLabel_PlayerScore(SP_KH_CAPS,     "caps",      SFL_SORT_PRIO_SECONDARY);
	ScoreInfo_SetLabel_PlayerScore(SP_KH_CAPTIME,  "captime",   SFL_LOWER_IS_BETTER | SFL_TIME);
	ScoreInfo_SetLabel_PlayerScore(SP_KH_PICKUPS,  "pickups",   0);
	ScoreInfo_SetLabel_PlayerScore(SP_KH_KCKILLS,  "kckills",   0);
	ScoreInfo_SetLabel_PlayerScore(SP_KH_DROPS,    "drops",     SFL_LOWER_IS_BETTER);
	ScoreRules_basics_end();
}

void kh_DelayedInit() // Do this check with a delay so we can wait for teams to be set up.
{
	kh_teams = autocvar_g_keyhunt_teams_override;
	if(kh_teams < 2 || kh_teams > 4)
		kh_teams = autocvar_g_keyhunt_teams;
	kh_teams = bound(2, kh_teams, 4);

	kh_ScoreRules(kh_teams);
	
	round_handler_Spawn(KH_CheckTeams, KH_CheckWinner, KH_RoundStart);
	round_handler_Init(5, autocvar_g_keyhunt_warmup, autocvar_g_keyhunt_round_timelimit);
}

void kh_Initialize()
{
	precache_model("models/keyhunt/key.md3");
	
	precache_sound("kh/collect.wav");
	precache_sound("kh/capture.wav");
	precache_sound("kh/drop.wav");
	precache_sound("ctf/touch.wav");
	precache_sound("ctf/pass.wav");

	addstat(STAT_KH_KEYSTATUS, AS_INT, kh_keystatus);
	addstat(STAT_KH_REDKEY_TEAM, AS_INT, stat_kh_redkey_team);
	addstat(STAT_KH_BLUEKEY_TEAM, AS_INT, stat_kh_bluekey_team);
	addstat(STAT_KH_YELLOWKEY_TEAM, AS_INT, stat_kh_yellowkey_team);
	addstat(STAT_KH_PINKKEY_TEAM, AS_INT, stat_kh_pinkkey_team);

	InitializeEntity(world, kh_DelayedInit, INITPRIO_GAMETYPE);
}


MUTATOR_DEFINITION(gamemode_keyhunt)
{
	MUTATOR_HOOK(MakePlayerObserver, kh_RemovePlayer, CBC_ORDER_ANY);
	MUTATOR_HOOK(ClientDisconnect, kh_RemovePlayer, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerDies, kh_PlayerDies, CBC_ORDER_ANY);
	MUTATOR_HOOK(MatchEnd, kh_MatchEnd, CBC_ORDER_ANY);
	MUTATOR_HOOK(PortalTeleport, kh_PortalTeleport, CBC_ORDER_ANY);
	MUTATOR_HOOK(GiveFragsForKill, kh_GiveFragsForKill, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerPreThink, kh_PlayerPreThink, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerDamage_Calculate, kh_PlayerDamage, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerUseKey, kh_PlayerUseKey, CBC_ORDER_ANY);
	MUTATOR_HOOK(reset_map_global, kh_ResetMapGlobal, CBC_ORDER_ANY);
	MUTATOR_HOOK(reset_map_players, kh_ResetMap, CBC_ORDER_ANY);
	MUTATOR_HOOK(HelpMePing, kh_HelpMePing, CBC_ORDER_ANY);
	MUTATOR_HOOK(VehicleEnter, kh_VehicleEnter, CBC_ORDER_ANY);
	MUTATOR_HOOK(VehicleExit, kh_VehicleExit, CBC_ORDER_ANY);
	MUTATOR_HOOK(HavocBot_ChooseRole, kh_BotRoles, CBC_ORDER_ANY);
	MUTATOR_HOOK(GetTeamCount, kh_GetTeamCount, CBC_ORDER_ANY);

	MUTATOR_ONADD
	{
		if(time > 1) // game loads at time 1
			error("This is a game type and it cannot be added at runtime.");
		kh_Initialize();
	}

	MUTATOR_ONROLLBACK_OR_REMOVE
	{
		// we actually cannot roll back kh_Initialize here
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
