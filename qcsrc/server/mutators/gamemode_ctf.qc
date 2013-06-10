// ================================================================
//  Official capture the flag game mode coding, reworked by Samual
//  Last updated: September, 2012
// ================================================================

void ctf_FakeTimeLimit(entity e, float t)
{
	msg_entity = e;
	WriteByte(MSG_ONE, 3); // svc_updatestat
	WriteByte(MSG_ONE, 236); // STAT_TIMELIMIT
	if(t < 0)
		WriteCoord(MSG_ONE, autocvar_timelimit);
	else
		WriteCoord(MSG_ONE, (t + 1) / 60);
}

void ctf_EventLog(string mode, float flagteam, entity actor) // use an alias for easy changing and quick editing later
{
	if(autocvar_sv_eventlog)
		GameLogEcho(strcat(":ctf:", mode, ":", ftos(flagteam), ((actor != world) ? (strcat(":", ftos(actor.playerid))) : "")));
}

void ctf_CaptureRecord(entity flag, entity player)
{
	entity tmp_entity;
	float cap_record = ctf_captimerecord;
	float cap_time = (time - flag.ctf_pickuptime);
	string refername = db_get(ServerProgsDB, strcat(GetMapname(), "/captimerecord/netname"));
	
	// notify about shit
	FOR_EACH_REALCLIENT(tmp_entity)
	{
		if(tmp_entity.CAPTURE_VERBOSE)
		{
			if(!ctf_captimerecord) { Send_Notification(NOTIF_ONE_ONLY, tmp_entity, MSG_INFO, APP_TEAM_ENT_4(flag, INFO_CTF_CAPTURE_TIME_), player.netname, (cap_time * 100)); }
			else if(cap_time < cap_record) { Send_Notification(NOTIF_ONE_ONLY, tmp_entity, MSG_INFO, APP_TEAM_ENT_4(flag, INFO_CTF_CAPTURE_BROKEN_), player.netname, refername, (cap_time * 100), (cap_record * 100)); }
			else { Send_Notification(NOTIF_ONE_ONLY, tmp_entity, MSG_INFO, APP_TEAM_ENT_4(flag, INFO_CTF_CAPTURE_UNBROKEN_), player.netname, refername, (cap_time * 100), (cap_record * 100)); }
		}
		else { Send_Notification(NOTIF_ONE_ONLY, tmp_entity, MSG_INFO, APP_TEAM_ENT_4(flag, INFO_CTF_CAPTURE_), player.netname); }
	}

	// the previous notification broadcast is only sent to real clients, this will notify server log too
	if(server_is_dedicated)
	{
		if(autocvar_notification_ctf_capture_verbose)
		{
			if(!ctf_captimerecord) { Local_Notification(MSG_INFO, APP_TEAM_ENT_4(flag, INFO_CTF_CAPTURE_TIME_), player.netname, (cap_time * 100)); }
			else if(cap_time < cap_record) { Local_Notification(MSG_INFO, APP_TEAM_ENT_4(flag, INFO_CTF_CAPTURE_BROKEN_), player.netname, refername, (cap_time * 100), (cap_record * 100)); }
			else { Local_Notification(MSG_INFO, APP_TEAM_ENT_4(flag, INFO_CTF_CAPTURE_UNBROKEN_), player.netname, refername, (cap_time * 100), (cap_record * 100)); }
		}
		else { Local_Notification(MSG_INFO, APP_TEAM_ENT_4(flag, INFO_CTF_CAPTURE_), player.netname); }
	}
	
	// write that shit in the database
	if((!ctf_captimerecord) || (cap_time < cap_record))
	{
		ctf_captimerecord = cap_time;
		db_put(ServerProgsDB, strcat(GetMapname(), "/captimerecord/time"), ftos(cap_time));
		db_put(ServerProgsDB, strcat(GetMapname(), "/captimerecord/netname"), player.netname);
		write_recordmarker(player, (time - cap_time), cap_time); 
	} 
}

void ctf_FlagcarrierWaypoints(entity player)
{
	WaypointSprite_Spawn("flagcarrier", 0, 0, player, FLAG_WAYPOINT_OFFSET, world, player.team, player, wps_flagcarrier, TRUE, RADARICON_FLAG, WPCOLOR_FLAGCARRIER(player.team));
	WaypointSprite_UpdateMaxHealth(player.wps_flagcarrier, '1 0 0' * healtharmor_maxdamage(start_health, start_armorvalue, autocvar_g_balance_armor_blockpercent) * 2);
	WaypointSprite_UpdateHealth(player.wps_flagcarrier, '1 0 0' * healtharmor_maxdamage(player.health, player.armorvalue, autocvar_g_balance_armor_blockpercent));
	WaypointSprite_UpdateTeamRadar(player.wps_flagcarrier, RADARICON_FLAGCARRIER, WPCOLOR_FLAGCARRIER(player.team));
}

void ctf_CalculatePassVelocity(entity flag, vector to, vector from, float turnrate)
{
	float current_distance = vlen((('1 0 0' * to_x) + ('0 1 0' * to_y)) - (('1 0 0' * from_x) + ('0 1 0' * from_y))); // for the sake of this check, exclude Z axis
	float initial_height = min(autocvar_g_ctf_pass_arc_max, (flag.pass_distance * tanh(autocvar_g_ctf_pass_arc)));
	float current_height = (initial_height * min(1, (current_distance / flag.pass_distance)));
	//print("current_height = ", ftos(current_height), ", initial_height = ", ftos(initial_height), ".\n");

	vector targpos;
	if(current_height) // make sure we can actually do this arcing path
	{
		targpos = (to + ('0 0 1' * current_height));
		WarpZone_TraceLine(flag.origin, targpos, MOVE_NOMONSTERS, flag);
		if(trace_fraction < 1)
		{
			//print("normal arc line failed, trying to find new pos...");
			WarpZone_TraceLine(to, targpos, MOVE_NOMONSTERS, flag);
			targpos = (trace_endpos + FLAG_PASS_ARC_OFFSET);
			WarpZone_TraceLine(flag.origin, targpos, MOVE_NOMONSTERS, flag);
			if(trace_fraction < 1) { targpos = to; /* print(" ^1FAILURE^7, reverting to original direction.\n"); */ }
			/*else { print(" ^3SUCCESS^7, using new arc line.\n"); } */
		}
	}
	else { targpos = to; }

	//flag.angles = normalize(('0 1 0' * to_y) - ('0 1 0' * from_y));

	vector desired_direction = normalize(targpos - from);
	if(turnrate) { flag.velocity = (normalize(normalize(flag.velocity) + (desired_direction * autocvar_g_ctf_pass_turnrate)) * autocvar_g_ctf_pass_velocity); }
	else { flag.velocity = (desired_direction * autocvar_g_ctf_pass_velocity); }
}

float ctf_CheckPassDirection(vector head_center, vector passer_center, vector passer_angle, vector nearest_to_passer)
{
	if(autocvar_g_ctf_pass_directional_max || autocvar_g_ctf_pass_directional_min)
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

		spreadlimit = (autocvar_g_ctf_pass_radius ? min(1, (vlen(passer_center - nearest_on_line) / autocvar_g_ctf_pass_radius)) : 1);
		spreadlimit = (autocvar_g_ctf_pass_directional_min * (1 - spreadlimit) + autocvar_g_ctf_pass_directional_max * spreadlimit);

		if(spreadlimit && (distance_from_line <= spreadlimit) && ((vlen(normalize(head_center - passer_center) - v_forward) * RAD2DEG) <= 90))
			{ return TRUE; }
		else
			{ return FALSE; }
	}
	else { return TRUE; }
}


// =======================
// CaptureShield Functions 
// =======================

float ctf_CaptureShield_CheckStatus(entity p) 
{
	float s, se;
	entity e;
	float players_worseeq, players_total;

	if(ctf_captureshield_max_ratio <= 0)
		return FALSE;

	s = PlayerScore_Add(p, SP_SCORE, 0);
	if(s >= -ctf_captureshield_min_negscore)
		return FALSE;

	players_total = players_worseeq = 0;
	FOR_EACH_PLAYER(e)
	{
		if(IsDifferentTeam(e, p))
			continue;
		se = PlayerScore_Add(e, SP_SCORE, 0);
		if(se <= s)
			++players_worseeq;
		++players_total;
	}

	// player is in the worse half, if >= half the players are better than him, or consequently, if < half of the players are worse
	// use this rule here
	
	if(players_worseeq >= players_total * ctf_captureshield_max_ratio)
		return FALSE;

	return TRUE;
}

void ctf_CaptureShield_Update(entity player, float wanted_status)
{
	float updated_status = ctf_CaptureShield_CheckStatus(player);
	if((wanted_status == player.ctf_captureshielded) && (updated_status != wanted_status)) // 0: shield only, 1: unshield only
	{
		Send_Notification(NOTIF_ONE, player, MSG_CENTER, ((updated_status) ? CENTER_CTF_CAPTURESHIELD_SHIELDED : CENTER_CTF_CAPTURESHIELD_FREE));
		player.ctf_captureshielded = updated_status;
	}
}

float ctf_CaptureShield_Customize()
{
	if(!other.ctf_captureshielded) { return FALSE; }
	if(!IsDifferentTeam(self, other)) { return FALSE; }
	
	return TRUE;
}

void ctf_CaptureShield_Touch()
{
	if(!other.ctf_captureshielded) { return; }
	if(!IsDifferentTeam(self, other)) { return; }
	
	vector mymid = (self.absmin + self.absmax) * 0.5;
	vector othermid = (other.absmin + other.absmax) * 0.5;

	Damage(other, self, self, 0, DEATH_HURTTRIGGER, mymid, normalize(othermid - mymid) * ctf_captureshield_force);
	Send_Notification(NOTIF_ONE, other, MSG_CENTER, CENTER_CTF_CAPTURESHIELD_SHIELDED);
}

void ctf_CaptureShield_Spawn(entity flag)
{
	entity shield = spawn();
	
	shield.enemy = self;
	shield.team = self.team;
	shield.touch = ctf_CaptureShield_Touch;
	shield.customizeentityforclient = ctf_CaptureShield_Customize;
	shield.classname = "ctf_captureshield";
	shield.effects = EF_ADDITIVE;
	shield.movetype = MOVETYPE_NOCLIP;
	shield.solid = SOLID_TRIGGER;
	shield.avelocity = '7 0 11';
	shield.scale = 0.5;
	
	setorigin(shield, self.origin);
	setmodel(shield, "models/ctf/shield.md3");
	setsize(shield, shield.scale * shield.mins, shield.scale * shield.maxs);
}


// ====================
// Drop/Pass/Throw Code
// ====================

void ctf_Handle_Drop(entity flag, entity player, float droptype)
{
	// declarations
	player = (player ? player : flag.pass_sender);

	// main
	flag.movetype = MOVETYPE_TOSS;
	flag.takedamage = DAMAGE_YES;
	flag.angles = '0 0 0';
	flag.health = flag.max_flag_health;
	flag.ctf_droptime = time;
	flag.ctf_dropper = player;
	flag.ctf_status = FLAG_DROPPED;
	
	// messages and sounds
	Send_Notification(NOTIF_ALL, world, MSG_INFO, APP_TEAM_ENT_4(flag, INFO_CTF_LOST_), player.netname);
	sound(flag, CH_TRIGGER, flag.snd_flag_dropped, VOL_BASE, ATTN_NONE);
	ctf_EventLog("dropped", player.team, player);

	// scoring
	PlayerTeamScore_AddScore(player, -autocvar_g_ctf_score_penalty_drop);	
	PlayerScore_Add(player, SP_CTF_DROPS, 1);
	
	// waypoints
	if(autocvar_g_ctf_flag_dropped_waypoint)
		WaypointSprite_Spawn("flagdropped", 0, 0, flag, FLAG_WAYPOINT_OFFSET, world, ((autocvar_g_ctf_flag_dropped_waypoint == 2) ? 0 : player.team), flag, wps_flagdropped, TRUE, RADARICON_FLAG, WPCOLOR_DROPPEDFLAG(flag.team));

	if(autocvar_g_ctf_flag_return_time || (autocvar_g_ctf_flag_return_damage && autocvar_g_ctf_flag_health))
	{
		WaypointSprite_UpdateMaxHealth(flag.wps_flagdropped, flag.max_flag_health);
		WaypointSprite_UpdateHealth(flag.wps_flagdropped, flag.health);
	}
	
	player.throw_antispam = time + autocvar_g_ctf_pass_wait;
	
	if(droptype == DROP_PASS)
	{
		flag.pass_distance = 0;
		flag.pass_sender = world;
		flag.pass_target = world;
	}
}

void ctf_Handle_Retrieve(entity flag, entity player)
{
	entity tmp_player; // temporary entity which the FOR_EACH_PLAYER loop uses to scan players
	entity sender = flag.pass_sender;
	
	// transfer flag to player
	flag.owner = player;
	flag.owner.flagcarried = flag;
	
	// reset flag
	setattachment(flag, player, "");
	setorigin(flag, FLAG_CARRY_OFFSET);
	flag.movetype = MOVETYPE_NONE;
	flag.takedamage = DAMAGE_NO;
	flag.solid = SOLID_NOT;
	flag.angles = '0 0 0';
	flag.ctf_status = FLAG_CARRY;

	// messages and sounds
	sound(player, CH_TRIGGER, flag.snd_flag_pass, VOL_BASE, ATTN_NORM);
	ctf_EventLog("receive", flag.team, player);
	
	FOR_EACH_REALPLAYER(tmp_player)
	{
		if(tmp_player == sender)
			Send_Notification(NOTIF_ONE, tmp_player, MSG_CENTER, APP_TEAM_ENT_4(flag, CENTER_CTF_PASS_SENT_), player.netname);
		else if(tmp_player == player)
			Send_Notification(NOTIF_ONE, tmp_player, MSG_CENTER, APP_TEAM_ENT_4(flag, CENTER_CTF_PASS_RECEIVED_), sender.netname);
		else if(!IsDifferentTeam(tmp_player, sender))
			Send_Notification(NOTIF_ONE, tmp_player, MSG_CENTER, APP_TEAM_ENT_4(flag, CENTER_CTF_PASS_OTHER_), sender.netname, player.netname);
	}
	
	// create new waypoint
	ctf_FlagcarrierWaypoints(player);
	
	sender.throw_antispam = time + autocvar_g_ctf_pass_wait;
	player.throw_antispam = sender.throw_antispam;

	flag.pass_distance = 0;
	flag.pass_sender = world;
	flag.pass_target = world;
}

void ctf_Handle_Throw(entity player, entity receiver, float droptype)
{
	entity flag = player.flagcarried;
	vector targ_origin, flag_velocity;
	
	if(!flag) { return; }
	if((droptype == DROP_PASS) && !receiver) { return; }
	
	if(flag.speedrunning) { ctf_RespawnFlag(flag); return; }
	
	// reset the flag
	setattachment(flag, world, "");
	setorigin(flag, player.origin + FLAG_DROP_OFFSET);
	flag.owner.flagcarried = world;
	flag.owner = world;
	flag.solid = SOLID_TRIGGER;
	flag.ctf_dropper = player;
	flag.ctf_droptime = time;
	
	flag.flags = FL_ITEM | FL_NOTARGET; // clear FL_ONGROUND for MOVETYPE_TOSS
	
	switch(droptype)
	{
		case DROP_PASS:
		{
			// warpzone support:
			// for the examples, we assume player -> wz1 -> ... -> wzn -> receiver
			// findradius has already put wzn ... wz1 into receiver's warpzone parameters!
			WarpZone_RefSys_Copy(flag, receiver);
			WarpZone_RefSys_AddInverse(flag, receiver); // wz1^-1 ... wzn^-1 receiver
			targ_origin = WarpZone_RefSys_TransformOrigin(receiver, flag, (0.5 * (receiver.absmin + receiver.absmax))); // this is target origin as seen by the flag

			flag.pass_distance = vlen((('1 0 0' * targ_origin_x) + ('0 1 0' * targ_origin_y)) - (('1 0 0' *  player.origin_x) + ('0 1 0' *  player.origin_y))); // for the sake of this check, exclude Z axis
			ctf_CalculatePassVelocity(flag, targ_origin, player.origin, FALSE);

			// main
			flag.movetype = MOVETYPE_FLY;
			flag.takedamage = DAMAGE_NO;
			flag.pass_sender = player;
			flag.pass_target = receiver;
			flag.ctf_status = FLAG_PASSING;
			
			// other
			sound(player, CH_TRIGGER, flag.snd_flag_touch, VOL_BASE, ATTN_NORM);
			WarpZone_TrailParticles(world, particleeffectnum(flag.passeffect), player.origin, targ_origin);
			ctf_EventLog("pass", flag.team, player);
			break;
		}
		
		case DROP_THROW:
		{
			makevectors((player.v_angle_y * '0 1 0') + (bound(autocvar_g_ctf_throw_angle_min, player.v_angle_x, autocvar_g_ctf_throw_angle_max) * '1 0 0'));
				
			flag_velocity = (('0 0 1' * autocvar_g_ctf_throw_velocity_up) + ((v_forward * autocvar_g_ctf_throw_velocity_forward) * ((player.items & IT_STRENGTH) ? autocvar_g_ctf_throw_strengthmultiplier : 1)));
			flag.velocity = W_CalculateProjectileVelocity(player.velocity, flag_velocity, FALSE);
			ctf_Handle_Drop(flag, player, droptype);
			break;
		}
		
		case DROP_RESET:
		{
			flag.velocity = '0 0 0'; // do nothing
			break;
		}
		
		default:
		case DROP_NORMAL:
		{
			flag.velocity = W_CalculateProjectileVelocity(player.velocity, (('0 0 1' * autocvar_g_ctf_drop_velocity_up) + ((('0 1 0' * crandom()) + ('1 0 0' * crandom())) * autocvar_g_ctf_drop_velocity_side)), FALSE);
			ctf_Handle_Drop(flag, player, droptype);
			break;
		}
	}

	// kill old waypointsprite
	WaypointSprite_Ping(player.wps_flagcarrier);
	WaypointSprite_Kill(player.wps_flagcarrier);
	
	if(player.wps_enemyflagcarrier)
		WaypointSprite_Kill(player.wps_enemyflagcarrier);
	
	// captureshield
	ctf_CaptureShield_Update(player, 0); // shield player from picking up flag
}


// ==============
// Event Handlers
// ==============

void ctf_Handle_Capture(entity flag, entity toucher, float capturetype)
{
	entity enemy_flag = ((capturetype == CAPTURE_NORMAL) ? toucher.flagcarried : toucher);
	entity player = ((capturetype == CAPTURE_NORMAL) ? toucher : enemy_flag.ctf_dropper);
	float old_time, new_time; 
	
	if not(player) { return; } // without someone to give the reward to, we can't possibly cap
	if(player.fc_waskilled) { return; } // player died, so don't cap
	if(IsDifferentTeam(player, flag)) { return; }
	
	player.throw_prevtime = time;
	player.throw_count = 0;
	
	// messages and sounds
	Send_Notification(NOTIF_ONE, player, MSG_CENTER, APP_TEAM_ENT_4(enemy_flag, CENTER_CTF_CAPTURE_));
	ctf_CaptureRecord(enemy_flag, player);
	sound(player, CH_TRIGGER, flag.snd_flag_capture, VOL_BASE, ATTN_NONE);
	
	switch(capturetype)
	{
		case CAPTURE_NORMAL: ctf_EventLog("capture", enemy_flag.team, player); break;
		case CAPTURE_DROPPED: ctf_EventLog("droppedcapture", enemy_flag.team, player); break;
		default: break;
	}
	
	// scoring
	PlayerTeamScore_AddScore(player, autocvar_g_ctf_score_capture);
	PlayerTeamScore_Add(player, SP_CTF_CAPS, ST_CTF_CAPS, 1);

	old_time = PlayerScore_Add(player, SP_CTF_CAPTIME, 0);
	new_time = TIME_ENCODE(time - enemy_flag.ctf_pickuptime);
	if(!old_time || new_time < old_time)
		PlayerScore_Add(player, SP_CTF_CAPTIME, new_time - old_time);

	// effects
	pointparticles(particleeffectnum(flag.capeffect), flag.origin, '0 0 0', 1);
	//shockwave_spawn("models/ctf/shockwavetransring.md3", flag.origin - '0 0 15', -0.8, 0, 1);

	// other
	if(capturetype == CAPTURE_NORMAL)
	{
		WaypointSprite_Kill(player.wps_flagcarrier);
		if(flag.speedrunning) { ctf_FakeTimeLimit(player, -1); }
		
		if((enemy_flag.ctf_dropper) && (player != enemy_flag.ctf_dropper))
			{ PlayerTeamScore_AddScore(enemy_flag.ctf_dropper, autocvar_g_ctf_score_capture_assist); }
	}
	
	// reset the flag
	player.next_take_time = time + autocvar_g_ctf_flag_collect_delay;
	ctf_RespawnFlag(enemy_flag);
}

void ctf_Handle_Return(entity flag, entity player)
{
	// messages and sounds
	if(IS_PLAYER(player))
		Send_Notification(NOTIF_ONE, player, MSG_CENTER, APP_TEAM_ENT_4(flag, CENTER_CTF_RETURN_));
		
	Send_Notification(NOTIF_ALL, world, MSG_INFO, APP_TEAM_ENT_4(flag, INFO_CTF_RETURN_), player.netname);
	sound(player, CH_TRIGGER, flag.snd_flag_returned, VOL_BASE, ATTN_NONE);
	ctf_EventLog("return", flag.team, player);

	// scoring
	if(IS_PLAYER(player))
	{
		PlayerTeamScore_AddScore(player, autocvar_g_ctf_score_return); // reward for return
		PlayerScore_Add(player, SP_CTF_RETURNS, 1); // add to count of returns
	}

	TeamScore_AddToTeam(flag.team, ST_SCORE, -autocvar_g_ctf_score_penalty_returned); // punish the team who was last carrying it
	
	if(flag.ctf_dropper) 
	{
		PlayerScore_Add(flag.ctf_dropper, SP_SCORE, -autocvar_g_ctf_score_penalty_returned); // punish the player who dropped the flag
		ctf_CaptureShield_Update(flag.ctf_dropper, 0); // shield player from picking up flag 
		flag.ctf_dropper.next_take_time = time + autocvar_g_ctf_flag_collect_delay; // set next take time
	}
	
	// reset the flag
	ctf_RespawnFlag(flag);
}

void ctf_Handle_Pickup(entity flag, entity player, float pickuptype)
{
	// declarations
	entity tmp_player; // temporary entity which the FOR_EACH_PLAYER loop uses to scan players
	float pickup_dropped_score; // used to calculate dropped pickup score
	
	// attach the flag to the player
	player.fc_waskilled = FALSE;
	flag.owner = player;
	player.flagcarried = flag;
	setattachment(flag, player, "");
	setorigin(flag, FLAG_CARRY_OFFSET);
	
	// flag setup
	flag.movetype = MOVETYPE_NONE;
	flag.takedamage = DAMAGE_NO;
	flag.solid = SOLID_NOT;
	flag.angles = '0 0 0';
	flag.ctf_status = FLAG_CARRY;
	
	switch(pickuptype)
	{
		case PICKUP_BASE: flag.ctf_pickuptime = time; break; // used for timing runs
		case PICKUP_DROPPED: flag.health = flag.max_flag_health; break; // reset health/return timelimit
		default: break;
	}

	// messages and sounds
	Send_Notification(NOTIF_ALL, world, MSG_INFO, APP_TEAM_ENT_4(flag, INFO_CTF_PICKUP_), player.netname);
	sound(player, CH_TRIGGER, flag.snd_flag_taken, VOL_BASE, ATTN_NONE);

	FOR_EACH_REALPLAYER(tmp_player)
	{
		if(tmp_player == player)
		{
			Send_Notification(NOTIF_ONE, tmp_player, MSG_CENTER, APP_TEAM_ENT_4(flag, CENTER_CTF_PICKUP_));
			if(ctf_stalemate) { Send_Notification(NOTIF_ONE, player, MSG_CENTER, CENTER_CTF_STALEMATE_CARRIER); }
		}
		else if(!IsDifferentTeam(tmp_player, player) && tmp_player != player)
		{
			if(tmp_player.PICKUP_TEAM_VERBOSE)
				Send_Notification(NOTIF_ONE, tmp_player, MSG_CENTER, CENTER_CTF_PICKUP_TEAM_VERBOSE, Team_ColorCode(player.team), player.netname);
			else
				Send_Notification(NOTIF_ONE, tmp_player, MSG_CENTER, CENTER_CTF_PICKUP_TEAM, Team_ColorCode(player.team));
		}
		else if(IsDifferentTeam(tmp_player, player))
		{
			if(tmp_player.PICKUP_ENEMY_VERBOSE)
				Send_Notification(NOTIF_ONE, tmp_player, MSG_CENTER, CENTER_CTF_PICKUP_ENEMY_VERBOSE, Team_ColorCode(player.team), player.netname);
			else
				Send_Notification(NOTIF_ONE, tmp_player, MSG_CENTER, CENTER_CTF_PICKUP_ENEMY, Team_ColorCode(player.team));
		}
	}
	
	// scoring
	PlayerScore_Add(player, SP_CTF_PICKUPS, 1);
	switch(pickuptype)
	{		
		case PICKUP_BASE:
		{
			PlayerTeamScore_AddScore(player, autocvar_g_ctf_score_pickup_base);
			ctf_EventLog("steal", flag.team, player);
			break;
		}
		
		case PICKUP_DROPPED:
		{
			pickup_dropped_score = (autocvar_g_ctf_flag_return_time ? bound(0, ((flag.ctf_droptime + autocvar_g_ctf_flag_return_time) - time) / autocvar_g_ctf_flag_return_time, 1) : 1);
			pickup_dropped_score = floor((autocvar_g_ctf_score_pickup_dropped_late * (1 - pickup_dropped_score) + autocvar_g_ctf_score_pickup_dropped_early * pickup_dropped_score) + 0.5);
			dprint("pickup_dropped_score is ", ftos(pickup_dropped_score), "\n");
			PlayerTeamScore_AddScore(player, pickup_dropped_score);
			ctf_EventLog("pickup", flag.team, player);
			break;
		}
		
		default: break;
	}
	
	// speedrunning
	if(pickuptype == PICKUP_BASE)
	{
		flag.speedrunning = player.speedrunning; // if speedrunning, flag will flag-return and teleport the owner back after the record
		if((player.speedrunning) && (ctf_captimerecord))
			ctf_FakeTimeLimit(player, time + ctf_captimerecord);
	}
		
	// effects
	pointparticles(particleeffectnum(flag.toucheffect), player.origin, '0 0 0', 1);
	
	// waypoints 
	if(pickuptype == PICKUP_DROPPED) { WaypointSprite_Kill(flag.wps_flagdropped); }
	ctf_FlagcarrierWaypoints(player);
	WaypointSprite_Ping(player.wps_flagcarrier);
}


// ===================
// Main Flag Functions
// ===================

void ctf_CheckFlagReturn(entity flag, float returntype)
{
	if((flag.ctf_status == FLAG_DROPPED) || (flag.ctf_status == FLAG_PASSING))
	{
		if(flag.wps_flagdropped) { WaypointSprite_UpdateHealth(flag.wps_flagdropped, flag.health); }
		
		if((flag.health <= 0) || (time >= flag.ctf_droptime + autocvar_g_ctf_flag_return_time))
		{
			switch(returntype)
			{
				case RETURN_DROPPED: Send_Notification(NOTIF_ALL, world, MSG_INFO, APP_TEAM_ENT_4(flag, INFO_CTF_FLAGRETURN_DROPPED_)); break;
				case RETURN_DAMAGE: Send_Notification(NOTIF_ALL, world, MSG_INFO, APP_TEAM_ENT_4(flag, INFO_CTF_FLAGRETURN_DAMAGED_)); break;
				case RETURN_SPEEDRUN: Send_Notification(NOTIF_ALL, world, MSG_INFO, APP_TEAM_ENT_4(flag, INFO_CTF_FLAGRETURN_SPEEDRUN_), ctf_captimerecord); break;
				case RETURN_NEEDKILL: Send_Notification(NOTIF_ALL, world, MSG_INFO, APP_TEAM_ENT_4(flag, INFO_CTF_FLAGRETURN_NEEDKILL_)); break;
				
				default:
				case RETURN_TIMEOUT:
					{ Send_Notification(NOTIF_ALL, world, MSG_INFO, APP_TEAM_ENT_4(flag, INFO_CTF_FLAGRETURN_TIMEOUT_)); break; }
			}
			sound(flag, CH_TRIGGER, flag.snd_flag_respawn, VOL_BASE, ATTN_NONE);
			ctf_EventLog("returned", flag.team, world);
			ctf_RespawnFlag(flag);
		}
	}
}

void ctf_CheckStalemate(void)
{
	// declarations
	float stale_red_flags = 0, stale_blue_flags = 0;
	entity tmp_entity;

	entity ctf_staleflaglist = world; // reset the list, we need to build the list each time this function runs

	// build list of stale flags
	for(tmp_entity = ctf_worldflaglist; tmp_entity; tmp_entity = tmp_entity.ctf_worldflagnext)
	{
		if(autocvar_g_ctf_stalemate)
		if(tmp_entity.ctf_status != FLAG_BASE)
		if(time >= tmp_entity.ctf_pickuptime + autocvar_g_ctf_stalemate_time)
		{
			tmp_entity.ctf_staleflagnext = ctf_staleflaglist; // link flag into staleflaglist
			ctf_staleflaglist = tmp_entity;
			
			switch(tmp_entity.team)
			{
				case NUM_TEAM_1: ++stale_red_flags; break;
				case NUM_TEAM_2: ++stale_blue_flags; break;
			}
		}
	}

	if(stale_red_flags && stale_blue_flags)
		ctf_stalemate = TRUE;
	else if((!stale_red_flags && !stale_blue_flags) && autocvar_g_ctf_stalemate_endcondition == 2)
		{ ctf_stalemate = FALSE; wpforenemy_announced = FALSE; }
	else if((!stale_red_flags || !stale_blue_flags) && autocvar_g_ctf_stalemate_endcondition == 1)
		{ ctf_stalemate = FALSE; wpforenemy_announced = FALSE; }
		
	// if sufficient stalemate, then set up the waypointsprite and announce the stalemate if necessary
	if(ctf_stalemate)
	{
		for(tmp_entity = ctf_staleflaglist; tmp_entity; tmp_entity = tmp_entity.ctf_staleflagnext)
		{
			if((tmp_entity.owner) && (!tmp_entity.owner.wps_enemyflagcarrier))
				WaypointSprite_Spawn("enemyflagcarrier", 0, 0, tmp_entity.owner, FLAG_WAYPOINT_OFFSET, world, tmp_entity.team, tmp_entity.owner, wps_enemyflagcarrier, TRUE, RADARICON_FLAG, WPCOLOR_ENEMYFC(tmp_entity.owner.team));
		}
		
		if not(wpforenemy_announced)
		{
			FOR_EACH_REALPLAYER(tmp_entity)
				Send_Notification(NOTIF_ONE, tmp_entity, MSG_CENTER, ((tmp_entity.flagcarried) ? CENTER_CTF_STALEMATE_CARRIER : CENTER_CTF_STALEMATE_OTHER));
			
			wpforenemy_announced = TRUE;
		}
	}
}

void ctf_FlagDamage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if(ITEM_DAMAGE_NEEDKILL(deathtype))
	{
		// automatically kill the flag and return it
		self.health = 0;
		ctf_CheckFlagReturn(self, RETURN_NEEDKILL);
		return;
	}
	if(autocvar_g_ctf_flag_return_damage) 
	{
		// reduce health and check if it should be returned
		self.health = self.health - damage;
		ctf_CheckFlagReturn(self, RETURN_DAMAGE);
		return;
	}
}

void ctf_FlagThink()
{
	// declarations
	entity tmp_entity;

	self.nextthink = time + FLAG_THINKRATE; // only 5 fps, more is unnecessary.

	// captureshield
	if(self == ctf_worldflaglist) // only for the first flag
		FOR_EACH_CLIENT(tmp_entity)
			ctf_CaptureShield_Update(tmp_entity, 1); // release shield only

	// sanity checks
	if(self.mins != FLAG_MIN || self.maxs != FLAG_MAX) { // reset the flag boundaries in case it got squished
		dprint("wtf the flag got squashed?\n");
		tracebox(self.origin, FLAG_MIN, FLAG_MAX, self.origin, MOVE_NOMONSTERS, self);
		if(!trace_startsolid) // can we resize it without getting stuck?
			setsize(self, FLAG_MIN, FLAG_MAX); }
			
	switch(self.ctf_status) // reset flag angles in case warpzones adjust it
	{
		case FLAG_DROPPED:
		{
			self.angles = '0 0 0';
			break;
		}
		
		default: break;
	}

	// main think method
	switch(self.ctf_status)
	{	
		case FLAG_BASE:
		{
			if(autocvar_g_ctf_dropped_capture_radius)
			{
				for(tmp_entity = ctf_worldflaglist; tmp_entity; tmp_entity = tmp_entity.ctf_worldflagnext)
					if(tmp_entity.ctf_status == FLAG_DROPPED)
					if(vlen(self.origin - tmp_entity.origin) < autocvar_g_ctf_dropped_capture_radius)
					if(time > tmp_entity.ctf_droptime + autocvar_g_ctf_dropped_capture_delay)
						ctf_Handle_Capture(self, tmp_entity, CAPTURE_DROPPED);
			}
			return;
		}
		
		case FLAG_DROPPED:
		{
			if(autocvar_g_ctf_flag_dropped_floatinwater)
			{
				vector midpoint = ((self.absmin + self.absmax) * 0.5);
				if(pointcontents(midpoint) == CONTENT_WATER)
				{
					self.velocity = self.velocity * 0.5;
					
					if(pointcontents(midpoint + FLAG_FLOAT_OFFSET) == CONTENT_WATER)
						{ self.velocity_z = autocvar_g_ctf_flag_dropped_floatinwater; }
					else
						{ self.movetype = MOVETYPE_FLY; }
				}
				else if(self.movetype == MOVETYPE_FLY) { self.movetype = MOVETYPE_TOSS; }
			}
			if(autocvar_g_ctf_flag_return_dropped)
			{
				if((vlen(self.origin - self.ctf_spawnorigin) <= autocvar_g_ctf_flag_return_dropped) || (autocvar_g_ctf_flag_return_dropped == -1))
				{
					self.health = 0;
					ctf_CheckFlagReturn(self, RETURN_DROPPED);
					return;
				}
			}
			if(autocvar_g_ctf_flag_return_time)
			{
				self.health -= ((self.max_flag_health / autocvar_g_ctf_flag_return_time) * FLAG_THINKRATE);
				ctf_CheckFlagReturn(self, RETURN_TIMEOUT);
				return;
			} 
			return;
		}
			
		case FLAG_CARRY:
		{
			if(self.speedrunning && ctf_captimerecord && (time >= self.ctf_pickuptime + ctf_captimerecord)) 
			{
				self.health = 0;
				ctf_CheckFlagReturn(self, RETURN_SPEEDRUN);

				tmp_entity = self;
				self = self.owner;
				self.impulse = CHIMPULSE_SPEEDRUN; // move the player back to the waypoint they set
				ImpulseCommands();
				self = tmp_entity;
			}
			if(autocvar_g_ctf_stalemate)
			{
				if(time >= wpforenemy_nextthink)
				{
					ctf_CheckStalemate();
					wpforenemy_nextthink = time + WPFE_THINKRATE; // waypoint for enemy think rate (to reduce unnecessary spam of this check)
				}
			}
			return;
		}
		
		case FLAG_PASSING:
		{
			vector targ_origin = ((self.pass_target.absmin + self.pass_target.absmax) * 0.5);
			targ_origin = WarpZone_RefSys_TransformOrigin(self.pass_target, self, targ_origin); // origin of target as seen by the flag (us)
			WarpZone_TraceLine(self.origin, targ_origin, MOVE_NOMONSTERS, self);
			
			if((self.pass_target == world)
				|| (self.pass_target.deadflag != DEAD_NO)
				|| (vlen(self.origin - targ_origin) > autocvar_g_ctf_pass_radius)
				|| ((trace_fraction < 1) && (trace_ent != self.pass_target))
				|| (time > self.ctf_droptime + autocvar_g_ctf_pass_timelimit))
			{
				// give up, pass failed
				ctf_Handle_Drop(self, world, DROP_PASS);
			}
			else
			{
				// still a viable target, go for it
				ctf_CalculatePassVelocity(self, targ_origin, self.origin, TRUE);
			}
			return;
		}

		default: // this should never happen
		{
			dprint("ctf_FlagThink(): Flag exists with no status?\n");
			return;
		}
	}
}

void ctf_FlagTouch()
{
	if(gameover) { return; }
	
	entity toucher = other;
	
	if(toucher.frozen) { return; }
	
	// automatically kill the flag and return it if it touched lava/slime/nodrop surfaces
	if(ITEM_TOUCH_NEEDKILL())
	{
		self.health = 0;
		ctf_CheckFlagReturn(self, RETURN_NEEDKILL);
		return;
	}
	
	// special touch behaviors
	if(toucher.vehicle_flags & VHF_ISVEHICLE)
	{
		if(autocvar_g_ctf_allow_vehicle_touch)
			toucher = toucher.owner; // the player is actually the vehicle owner, not other
		else
			return; // do nothing
	}
	else if(toucher.flags & FL_MONSTER)
	{
		if not(autocvar_g_ctf_allow_monster_touch)
			return; // do nothing
	}
	else if not(IS_PLAYER(toucher)) // The flag just touched an object, most likely the world
	{
		if(time > self.wait) // if we haven't in a while, play a sound/effect
		{
			pointparticles(particleeffectnum(self.toucheffect), self.origin, '0 0 0', 1);
			sound(self, CH_TRIGGER, self.snd_flag_touch, VOL_BASE, ATTN_NORM);
			self.wait = time + FLAG_TOUCHRATE;
		}
		return;
	}
	else if(toucher.deadflag != DEAD_NO) { return; }

	switch(self.ctf_status) 
	{	
		case FLAG_BASE:
		{
			if(!IsDifferentTeam(toucher, self) && (toucher.flagcarried) && IsDifferentTeam(toucher.flagcarried, self) && !(toucher.flags & FL_MONSTER))
				ctf_Handle_Capture(self, toucher, CAPTURE_NORMAL); // toucher just captured the enemies flag to his base
			else if(IsDifferentTeam(toucher, self) && (!toucher.flagcarried) && (!toucher.ctf_captureshielded) && (time > toucher.next_take_time) && !(toucher.flags & FL_MONSTER))
				ctf_Handle_Pickup(self, toucher, PICKUP_BASE); // toucher just stole the enemies flag
			break;
		}
		
		case FLAG_DROPPED:
		{
			if(!IsDifferentTeam(toucher, self))
				ctf_Handle_Return(self, toucher); // toucher just returned his own flag
			else if(!(toucher.flags & FL_MONSTER) && (!toucher.flagcarried) && ((toucher != self.ctf_dropper) || (time > self.ctf_droptime + autocvar_g_ctf_flag_collect_delay)))
				ctf_Handle_Pickup(self, toucher, PICKUP_DROPPED); // toucher just picked up a dropped enemy flag
			break;
		}
			
		case FLAG_CARRY:
		{
			dprint("Someone touched a flag even though it was being carried?\n");
			break;
		}
		
		case FLAG_PASSING:
		{
			if((IS_PLAYER(toucher)) && (toucher.deadflag == DEAD_NO) && (toucher != self.pass_sender))
			{
				if(IsDifferentTeam(toucher, self.pass_sender))
					ctf_Handle_Return(self, toucher);
				else
					ctf_Handle_Retrieve(self, toucher);
			}
			break;
		}
	}
}

.float last_respawn;
void ctf_RespawnFlag(entity flag)
{
	// check for flag respawn being called twice in a row
	if(flag.last_respawn > time - 0.5)
		{ backtrace("flag respawn called twice quickly! please notify Samual about this..."); }

	flag.last_respawn = time;
	
	// reset the player (if there is one)
	if((flag.owner) && (flag.owner.flagcarried == flag))
	{
		if(flag.owner.wps_enemyflagcarrier)
			WaypointSprite_Kill(flag.owner.wps_enemyflagcarrier);
			
		WaypointSprite_Kill(flag.wps_flagcarrier);
		
		flag.owner.flagcarried = world;

		if(flag.speedrunning)
			ctf_FakeTimeLimit(flag.owner, -1);
	}

	if((flag.ctf_status == FLAG_DROPPED) && (flag.wps_flagdropped))
		{ WaypointSprite_Kill(flag.wps_flagdropped); }

	// reset the flag
	setattachment(flag, world, "");
	setorigin(flag, flag.ctf_spawnorigin);
	
	flag.movetype = ((flag.noalign) ? MOVETYPE_NONE : MOVETYPE_TOSS);
	flag.takedamage = DAMAGE_NO;
	flag.health = flag.max_flag_health;
	flag.solid = SOLID_TRIGGER;
	flag.velocity = '0 0 0';
	flag.angles = flag.mangle;
	flag.flags = FL_ITEM | FL_NOTARGET;
	
	flag.ctf_status = FLAG_BASE;
	flag.owner = world;
	flag.pass_distance = 0;
	flag.pass_sender = world;
	flag.pass_target = world;
	flag.ctf_dropper = world;
	flag.ctf_pickuptime = 0;
	flag.ctf_droptime = 0;
}

void ctf_Reset()
{
	if(self.owner)
		if(IS_PLAYER(self.owner))
			ctf_Handle_Throw(self.owner, world, DROP_RESET);
			
	ctf_RespawnFlag(self);
}

void ctf_DelayedFlagSetup(void) // called after a flag is placed on a map by ctf_FlagSetup()
{
	// bot waypoints
	waypoint_spawnforitem_force(self, self.origin);
	self.nearestwaypointtimeout = 0; // activate waypointing again
	self.bot_basewaypoint = self.nearestwaypoint;

	// waypointsprites
	string basename = "base";
	
	switch(self.team)
	{
		case NUM_TEAM_1: basename = "redbase"; break;
		case NUM_TEAM_2: basename = "bluebase"; break;
		case NUM_TEAM_3: basename = "yellowbase"; break;
		case NUM_TEAM_4: basename = "pinkbase"; break;
	}
	
	WaypointSprite_SpawnFixed(basename, self.origin + FLAG_WAYPOINT_OFFSET, self, wps_flagbase, RADARICON_FLAG, colormapPaletteColor(self.team - 1, FALSE));
	WaypointSprite_UpdateTeamRadar(self.wps_flagbase, RADARICON_FLAG, colormapPaletteColor(self.team - 1, FALSE));

	// captureshield setup
	ctf_CaptureShield_Spawn(self);
}

void ctf_FlagSetup(float teamnumber, entity flag) // called when spawning a flag entity on the map as a spawnfunc 
{
	// declarations
	//teamnumber = fabs(teamnumber - bound(0, autocvar_g_ctf_reverse, 1)); // if we were originally 1, this will become 0. If we were originally 0, this will become 1. 
	self = flag; // for later usage with droptofloor()
	
	switch(teamnumber)
	{
		case 0: // blue
			teamnumber = ((autocvar_g_ctf_reverse) ? NUM_TEAM_1 : NUM_TEAM_2);
			break;
		case 1: // red
			teamnumber = ((autocvar_g_ctf_reverse) ? NUM_TEAM_2 : NUM_TEAM_1);
			break;
		case 2: // yellow
			teamnumber = ((autocvar_g_ctf_reverse) ? NUM_TEAM_4 : NUM_TEAM_3);
			break;
		case 3: // pink
			teamnumber = ((autocvar_g_ctf_reverse) ? NUM_TEAM_3 : NUM_TEAM_4);
			break;
	}
	
	// main setup
	flag.ctf_worldflagnext = ctf_worldflaglist; // link flag into ctf_worldflaglist
	ctf_worldflaglist = flag;

	setattachment(flag, world, "");

	flag.netname = ((teamnumber) ? "^1RED^7 flag" : "^4BLUE^7 flag"); // Primarily only used for debugging or when showing nearby item name
	//flag.team = ((teamnumber) ? NUM_TEAM_1 : NUM_TEAM_2); // NUM_TEAM_1: color 4 team (red) - NUM_TEAM_2: color 13 team (blue)
	flag.team = teamnumber;
	flag.items = ((teamnumber) ? IT_KEY2 : IT_KEY1); // IT_KEY2: gold key (redish enough) - IT_KEY1: silver key (bluish enough)
	flag.classname = "item_flag_team";
	flag.target = "###item###"; // wut?
	flag.flags = FL_ITEM | FL_NOTARGET;
	flag.solid = SOLID_TRIGGER;
	flag.takedamage = DAMAGE_NO;
	flag.damageforcescale = autocvar_g_ctf_flag_damageforcescale;	
	flag.max_flag_health = ((autocvar_g_ctf_flag_return_damage && autocvar_g_ctf_flag_health) ? autocvar_g_ctf_flag_health : 100);
	flag.health = flag.max_flag_health;
	flag.event_damage = ctf_FlagDamage;
	flag.pushable = TRUE;
	flag.teleportable = TELEPORT_NORMAL;
	flag.damagedbytriggers = autocvar_g_ctf_flag_return_when_unreachable;
	flag.damagedbycontents = autocvar_g_ctf_flag_return_when_unreachable;
	flag.velocity = '0 0 0';
	flag.mangle = flag.angles;
	flag.reset = ctf_Reset;
	flag.touch = ctf_FlagTouch;
	flag.think = ctf_FlagThink;
	flag.nextthink = time + FLAG_THINKRATE;
	flag.ctf_status = FLAG_BASE;

	// appearence
	if(!flag.scale)				{ flag.scale = FLAG_SCALE; }
	if(flag.model == "") 		{ flag.model = strzone(cvar_string(strcat("g_ctf_flag_", strtolower(Static_Team_ColorName(teamnumber)), "_model"))); }
	if(flag.toucheffect == "") 	{ flag.toucheffect = strzone(strcat(strtolower(Static_Team_ColorName(teamnumber)), "_touch")); }
	if(flag.passeffect == "") 	{ flag.passeffect = strzone(strcat(strtolower(Static_Team_ColorName(teamnumber)), "_pass")); }
	if(flag.capeffect == "") 	{ flag.capeffect = strzone(strcat(strtolower(Static_Team_ColorName(teamnumber)), "_cap")); }
	if(!flag.skin) 				{ flag.skin = cvar(strcat("g_ctf_flag_", strtolower(Static_Team_ColorName(teamnumber)), "_skin")); }
	
	// sound 
	if(flag.snd_flag_taken == "")    { flag.snd_flag_taken  = strzone(strcat("ctf/", strtolower(Static_Team_ColorName(teamnumber)), "_taken.wav")); }
	if(flag.snd_flag_returned == "") { flag.snd_flag_returned = strzone(strcat("ctf/", strtolower(Static_Team_ColorName(teamnumber)), "_returned.wav")); }
	if(flag.snd_flag_capture == "")  { flag.snd_flag_capture = strzone(strcat("ctf/", strtolower(Static_Team_ColorName(teamnumber)), "_capture.wav")); } // blue team scores by capturing the red flag
	if(flag.snd_flag_respawn == "")  { flag.snd_flag_respawn = "ctf/flag_respawn.wav"; } // if there is ever a team-based sound for this, update the code to match.
	if(flag.snd_flag_dropped == "")  { flag.snd_flag_dropped = strzone(strcat("ctf/", strtolower(Static_Team_ColorName(teamnumber)), "_dropped.wav")); }
	if(flag.snd_flag_touch == "")    { flag.snd_flag_touch = "ctf/touch.wav"; } // again has no team-based sound
	if(flag.snd_flag_pass == "")     { flag.snd_flag_pass = "ctf/pass.wav"; } // same story here
	
	// precache
	precache_sound(flag.snd_flag_taken);
	precache_sound(flag.snd_flag_returned);
	precache_sound(flag.snd_flag_capture);
	precache_sound(flag.snd_flag_respawn);
	precache_sound(flag.snd_flag_dropped);
	precache_sound(flag.snd_flag_touch);
	precache_sound(flag.snd_flag_pass);
	precache_model(flag.model);
	precache_model("models/ctf/shield.md3");
	precache_model("models/ctf/shockwavetransring.md3");

	// appearence
	setmodel(flag, flag.model); // precision set below
	setsize(flag, FLAG_MIN, FLAG_MAX);
	setorigin(flag, (flag.origin + FLAG_SPAWN_OFFSET));
	
	if(autocvar_g_ctf_flag_glowtrails)
	{
		flag.glow_color = ((teamnumber) ? 251 : 210); // 251: red - 210: blue
		flag.glow_size = 25;
		flag.glow_trail = 1;
	}
	
	flag.effects |= EF_LOWPRECISION;
	if(autocvar_g_ctf_fullbrightflags) { flag.effects |= EF_FULLBRIGHT; }
	if(autocvar_g_ctf_dynamiclights)   { flag.effects |= ((teamnumber) ? EF_RED : EF_BLUE); }
	
	// flag placement
	if((flag.spawnflags & 1) || flag.noalign) // don't drop to floor, just stay at fixed location
	{ 	
		flag.dropped_origin = flag.origin; 
		flag.noalign = TRUE;
		flag.movetype = MOVETYPE_NONE;
	}
	else // drop to floor, automatically find a platform and set that as spawn origin
	{ 
		flag.noalign = FALSE;
		self = flag;
		droptofloor();
		flag.movetype = MOVETYPE_TOSS; 
	}	
	
	InitializeEntity(flag, ctf_DelayedFlagSetup, INITPRIO_SETLOCATION);
}


// ================
// Bot player logic
// ================

// NOTE: LEGACY CODE, needs to be re-written!

void havocbot_calculate_middlepoint()
{
	entity f;
	vector s = '0 0 0';
	vector fo = '0 0 0';
	float n = 0;

	f = ctf_worldflaglist;
	while (f)
	{
		fo = f.origin;
		s = s + fo;
		f = f.ctf_worldflagnext;
	}
	if(!n)
		return;
	havocbot_ctf_middlepoint = s * (1.0 / n);
	havocbot_ctf_middlepoint_radius	 = vlen(fo - havocbot_ctf_middlepoint);
}


entity havocbot_ctf_find_flag(entity bot)
{
	entity f;
	f = ctf_worldflaglist;
	while (f)
	{
		if (bot.team == f.team)
			return f;
		f = f.ctf_worldflagnext;
	}
	return world;
}

entity havocbot_ctf_find_enemy_flag(entity bot)
{
	entity f;
	f = ctf_worldflaglist;
	while (f)
	{
		if (bot.team != f.team)
			return f;
		f = f.ctf_worldflagnext;
	}
	return world;
}

float havocbot_ctf_teamcount(entity bot, vector org, float tc_radius)
{
	if not(teamplay)
		return 0;

	float c = 0;
	entity head;

	FOR_EACH_PLAYER(head)
	{
		if(head.team!=bot.team || head.deadflag != DEAD_NO || head == bot)
			continue;

		if(vlen(head.origin - org) < tc_radius)
			++c;
	}

	return c;
}

void havocbot_goalrating_ctf_ourflag(float ratingscale)
{
	entity head;
	head = ctf_worldflaglist;
	while (head)
	{
		if (self.team == head.team)
			break;
		head = head.ctf_worldflagnext;
	}
	if (head)
		navigation_routerating(head, ratingscale, 10000);
}

void havocbot_goalrating_ctf_ourbase(float ratingscale)
{
	entity head;
	head = ctf_worldflaglist;
	while (head)
	{
		if (self.team == head.team)
			break;
		head = head.ctf_worldflagnext;
	}
	if not(head)
		return;

	navigation_routerating(head.bot_basewaypoint, ratingscale, 10000);
}

void havocbot_goalrating_ctf_enemyflag(float ratingscale)
{
	entity head;
	head = ctf_worldflaglist;
	while (head)
	{
		if (self.team != head.team)
			break;
		head = head.ctf_worldflagnext;
	}
	if (head)
		navigation_routerating(head, ratingscale, 10000);
}

void havocbot_goalrating_ctf_enemybase(float ratingscale)
{
	if not(bot_waypoints_for_items)
	{
		havocbot_goalrating_ctf_enemyflag(ratingscale);
		return;
	}

	entity head;

	head = havocbot_ctf_find_enemy_flag(self);

	if not(head)
		return;

	navigation_routerating(head.bot_basewaypoint, ratingscale, 10000);
}

void havocbot_goalrating_ctf_ourstolenflag(float ratingscale)
{
	entity mf;

	mf = havocbot_ctf_find_flag(self);

	if(mf.ctf_status == FLAG_BASE)
		return;

	if(mf.tag_entity)
		navigation_routerating(mf.tag_entity, ratingscale, 10000);
}

void havocbot_goalrating_ctf_droppedflags(float ratingscale, vector org, float df_radius)
{
	entity head;
	head = ctf_worldflaglist;
	while (head)
	{
		// flag is out in the field
		if(head.ctf_status != FLAG_BASE)
		if(head.tag_entity==world)	// dropped
		{
			if(df_radius)
			{
				if(vlen(org-head.origin)<df_radius)
					navigation_routerating(head, ratingscale, 10000);
			}
			else
				navigation_routerating(head, ratingscale, 10000);
		}

		head = head.ctf_worldflagnext;
	}
}

void havocbot_goalrating_ctf_carrieritems(float ratingscale, vector org, float sradius)
{
	entity head;
	float t;
	head = findchainfloat(bot_pickup, TRUE);
	while (head)
	{
		// gather health and armor only
		if (head.solid)
		if (head.health || head.armorvalue)
		if (vlen(head.origin - org) < sradius)
		{
			// get the value of the item
			t = head.bot_pickupevalfunc(self, head) * 0.0001;
			if (t > 0)
				navigation_routerating(head, t * ratingscale, 500);
		}
		head = head.chain;
	}
}

void havocbot_ctf_reset_role(entity bot)
{
	float cdefense, cmiddle, coffense;
	entity mf, ef, head;
	float c;

	if(bot.deadflag != DEAD_NO)
		return;

	if(vlen(havocbot_ctf_middlepoint)==0)
		havocbot_calculate_middlepoint();

	// Check ctf flags
	if (bot.flagcarried)
	{
		havocbot_role_ctf_setrole(bot, HAVOCBOT_CTF_ROLE_CARRIER);
		return;
	}

	mf = havocbot_ctf_find_flag(bot);
	ef = havocbot_ctf_find_enemy_flag(bot);

	// Retrieve stolen flag
	if(mf.ctf_status!=FLAG_BASE)
	{
		havocbot_role_ctf_setrole(bot, HAVOCBOT_CTF_ROLE_RETRIEVER);
		return;
	}

	// If enemy flag is taken go to the middle to intercept pursuers
	if(ef.ctf_status!=FLAG_BASE)
	{
		havocbot_role_ctf_setrole(bot, HAVOCBOT_CTF_ROLE_MIDDLE);
		return;
	}

	// if there is only me on the team switch to offense
	c = 0;
	FOR_EACH_PLAYER(head)
	if(head.team==bot.team)
		++c;

	if(c==1)
	{
		havocbot_role_ctf_setrole(bot, HAVOCBOT_CTF_ROLE_OFFENSE);
		return;
	}

	// Evaluate best position to take
	// Count mates on middle position
	cmiddle = havocbot_ctf_teamcount(bot, havocbot_ctf_middlepoint, havocbot_ctf_middlepoint_radius * 0.5);

	// Count mates on defense position
	cdefense = havocbot_ctf_teamcount(bot, mf.dropped_origin, havocbot_ctf_middlepoint_radius * 0.5);

	// Count mates on offense position
	coffense = havocbot_ctf_teamcount(bot, ef.dropped_origin, havocbot_ctf_middlepoint_radius);

	if(cdefense<=coffense)
		havocbot_role_ctf_setrole(bot, HAVOCBOT_CTF_ROLE_DEFENSE);
	else if(coffense<=cmiddle)
		havocbot_role_ctf_setrole(bot, HAVOCBOT_CTF_ROLE_OFFENSE);
	else
		havocbot_role_ctf_setrole(bot, HAVOCBOT_CTF_ROLE_MIDDLE);
}

void havocbot_role_ctf_carrier()
{
	if(self.deadflag != DEAD_NO)
	{
		havocbot_ctf_reset_role(self);
		return;
	}

	if (self.flagcarried == world)
	{
		havocbot_ctf_reset_role(self);
		return;
	}

	if (self.bot_strategytime < time)
	{
		self.bot_strategytime = time + autocvar_bot_ai_strategyinterval;

		navigation_goalrating_start();
		havocbot_goalrating_ctf_ourbase(50000);

		if(self.health<100)
			havocbot_goalrating_ctf_carrieritems(1000, self.origin, 1000);

		navigation_goalrating_end();

		if (self.navigation_hasgoals)
			self.havocbot_cantfindflag = time + 10;
		else if (time > self.havocbot_cantfindflag)
		{
			// Can't navigate to my own base, suicide!
			// TODO: drop it and wander around
			Damage(self, self, self, 100000, DEATH_KILL, self.origin, '0 0 0');
			return;
		}
	}
}

void havocbot_role_ctf_escort()
{
	entity mf, ef;

	if(self.deadflag != DEAD_NO)
	{
		havocbot_ctf_reset_role(self);
		return;
	}

	if (self.flagcarried)
	{
		havocbot_role_ctf_setrole(self, HAVOCBOT_CTF_ROLE_CARRIER);
		return;
	}

	// If enemy flag is back on the base switch to previous role
	ef = havocbot_ctf_find_enemy_flag(self);
	if(ef.ctf_status==FLAG_BASE)
	{
		self.havocbot_role = self.havocbot_previous_role;
		self.havocbot_role_timeout = 0;
		return;
	}

	// If the flag carrier reached the base switch to defense
	mf = havocbot_ctf_find_flag(self);
	if(mf.ctf_status!=FLAG_BASE)
	if(vlen(ef.origin - mf.dropped_origin) < 300)
	{
		havocbot_role_ctf_setrole(self, HAVOCBOT_CTF_ROLE_DEFENSE);
		return;
	}

	// Set the role timeout if necessary
	if (!self.havocbot_role_timeout)
	{
		self.havocbot_role_timeout = time + random() * 30 + 60;
	}

	// If nothing happened just switch to previous role
	if (time > self.havocbot_role_timeout)
	{
		self.havocbot_role = self.havocbot_previous_role;
		self.havocbot_role_timeout = 0;
		return;
	}

	// Chase the flag carrier
	if (self.bot_strategytime < time)
	{
		self.bot_strategytime = time + autocvar_bot_ai_strategyinterval;
		navigation_goalrating_start();
		havocbot_goalrating_ctf_enemyflag(30000);
		havocbot_goalrating_ctf_ourstolenflag(40000);
		havocbot_goalrating_items(10000, self.origin, 10000);
		navigation_goalrating_end();
	}
}

void havocbot_role_ctf_offense()
{
	entity mf, ef;
	vector pos;

	if(self.deadflag != DEAD_NO)
	{
		havocbot_ctf_reset_role(self);
		return;
	}

	if (self.flagcarried)
	{
		havocbot_role_ctf_setrole(self, HAVOCBOT_CTF_ROLE_CARRIER);
		return;
	}

	// Check flags
	mf = havocbot_ctf_find_flag(self);
	ef = havocbot_ctf_find_enemy_flag(self);

	// Own flag stolen
	if(mf.ctf_status!=FLAG_BASE)
	{
		if(mf.tag_entity)
			pos = mf.tag_entity.origin;
		else
			pos = mf.origin;

		// Try to get it if closer than the enemy base
		if(vlen(self.origin-ef.dropped_origin)>vlen(self.origin-pos))
		{
			havocbot_role_ctf_setrole(self, HAVOCBOT_CTF_ROLE_RETRIEVER);
			return;
		}
	}

	// Escort flag carrier
	if(ef.ctf_status!=FLAG_BASE)
	{
		if(ef.tag_entity)
			pos = ef.tag_entity.origin;
		else
			pos = ef.origin;

		if(vlen(pos-mf.dropped_origin)>700)
		{
			havocbot_role_ctf_setrole(self, HAVOCBOT_CTF_ROLE_ESCORT);
			return;
		}
	}

	// About to fail, switch to middlefield
	if(self.health<50)
	{
		havocbot_role_ctf_setrole(self, HAVOCBOT_CTF_ROLE_MIDDLE);
		return;
	}

	// Set the role timeout if necessary
	if (!self.havocbot_role_timeout)
		self.havocbot_role_timeout = time + 120;

	if (time > self.havocbot_role_timeout)
	{
		havocbot_ctf_reset_role(self);
		return;
	}

	if (self.bot_strategytime < time)
	{
		self.bot_strategytime = time + autocvar_bot_ai_strategyinterval;
		navigation_goalrating_start();
		havocbot_goalrating_ctf_ourstolenflag(50000);
		havocbot_goalrating_ctf_enemybase(20000);
		havocbot_goalrating_items(5000, self.origin, 1000);
		havocbot_goalrating_items(1000, self.origin, 10000);
		navigation_goalrating_end();
	}
}

// Retriever (temporary role):
void havocbot_role_ctf_retriever()
{
	entity mf;

	if(self.deadflag != DEAD_NO)
	{
		havocbot_ctf_reset_role(self);
		return;
	}

	if (self.flagcarried)
	{
		havocbot_role_ctf_setrole(self, HAVOCBOT_CTF_ROLE_CARRIER);
		return;
	}

	// If flag is back on the base switch to previous role
	mf = havocbot_ctf_find_flag(self);
	if(mf.ctf_status==FLAG_BASE)
	{
		havocbot_ctf_reset_role(self);
		return;
	}

	if (!self.havocbot_role_timeout)
		self.havocbot_role_timeout = time + 20;

	if (time > self.havocbot_role_timeout)
	{
		havocbot_ctf_reset_role(self);
		return;
	}

	if (self.bot_strategytime < time)
	{
		float rt_radius;
		rt_radius = 10000;

		self.bot_strategytime = time + autocvar_bot_ai_strategyinterval;
		navigation_goalrating_start();
		havocbot_goalrating_ctf_ourstolenflag(50000);
		havocbot_goalrating_ctf_droppedflags(40000, self.origin, rt_radius);
		havocbot_goalrating_ctf_enemybase(30000);
		havocbot_goalrating_items(500, self.origin, rt_radius);
		navigation_goalrating_end();
	}
}

void havocbot_role_ctf_middle()
{
	entity mf;

	if(self.deadflag != DEAD_NO)
	{
		havocbot_ctf_reset_role(self);
		return;
	}

	if (self.flagcarried)
	{
		havocbot_role_ctf_setrole(self, HAVOCBOT_CTF_ROLE_CARRIER);
		return;
	}

	mf = havocbot_ctf_find_flag(self);
	if(mf.ctf_status!=FLAG_BASE)
	{
		havocbot_role_ctf_setrole(self, HAVOCBOT_CTF_ROLE_RETRIEVER);
		return;
	}

	if (!self.havocbot_role_timeout)
		self.havocbot_role_timeout = time + 10;

	if (time > self.havocbot_role_timeout)
	{
		havocbot_ctf_reset_role(self);
		return;
	}

	if (self.bot_strategytime < time)
	{
		vector org;

		org = havocbot_ctf_middlepoint;
		org_z = self.origin_z;

		self.bot_strategytime = time + autocvar_bot_ai_strategyinterval;
		navigation_goalrating_start();
		havocbot_goalrating_ctf_ourstolenflag(50000);
		havocbot_goalrating_ctf_droppedflags(30000, self.origin, 10000);
		havocbot_goalrating_enemyplayers(10000, org, havocbot_ctf_middlepoint_radius * 0.5);
		havocbot_goalrating_items(5000, org, havocbot_ctf_middlepoint_radius * 0.5);
		havocbot_goalrating_items(2500, self.origin, 10000);
		havocbot_goalrating_ctf_enemybase(2500);
		navigation_goalrating_end();
	}
}

void havocbot_role_ctf_defense()
{
	entity mf;

	if(self.deadflag != DEAD_NO)
	{
		havocbot_ctf_reset_role(self);
		return;
	}

	if (self.flagcarried)
	{
		havocbot_role_ctf_setrole(self, HAVOCBOT_CTF_ROLE_CARRIER);
		return;
	}

	// If own flag was captured
	mf = havocbot_ctf_find_flag(self);
	if(mf.ctf_status!=FLAG_BASE)
	{
		havocbot_role_ctf_setrole(self, HAVOCBOT_CTF_ROLE_RETRIEVER);
		return;
	}

	if (!self.havocbot_role_timeout)
		self.havocbot_role_timeout = time + 30;

	if (time > self.havocbot_role_timeout)
	{
		havocbot_ctf_reset_role(self);
		return;
	}
	if (self.bot_strategytime < time)
	{
		float mp_radius;
		vector org;

		org = mf.dropped_origin;
		mp_radius = havocbot_ctf_middlepoint_radius;

		self.bot_strategytime = time + autocvar_bot_ai_strategyinterval;
		navigation_goalrating_start();

		// if enemies are closer to our base, go there
		entity head, closestplayer = world;
		float distance, bestdistance = 10000;
		FOR_EACH_PLAYER(head)
		{
			if(head.deadflag!=DEAD_NO)
				continue;

			distance = vlen(org - head.origin);
			if(distance<bestdistance)
			{
				closestplayer = head;
				bestdistance = distance;
			}
		}

		if(closestplayer)
		if(closestplayer.team!=self.team)
		if(vlen(org - self.origin)>1000)
		if(checkpvs(self.origin,closestplayer)||random()<0.5)
			havocbot_goalrating_ctf_ourbase(30000);

		havocbot_goalrating_ctf_ourstolenflag(20000);
		havocbot_goalrating_ctf_droppedflags(20000, org, mp_radius);
		havocbot_goalrating_enemyplayers(15000, org, mp_radius);
		havocbot_goalrating_items(10000, org, mp_radius);
		havocbot_goalrating_items(5000, self.origin, 10000);
		navigation_goalrating_end();
	}
}

void havocbot_role_ctf_setrole(entity bot, float role)
{
	dprint(strcat(bot.netname," switched to "));
	switch(role)
	{
		case HAVOCBOT_CTF_ROLE_CARRIER:
			dprint("carrier");
			bot.havocbot_role = havocbot_role_ctf_carrier;
			bot.havocbot_role_timeout = 0;
			bot.havocbot_cantfindflag = time + 10;
			bot.bot_strategytime = 0;
			break;
		case HAVOCBOT_CTF_ROLE_DEFENSE:
			dprint("defense");
			bot.havocbot_role = havocbot_role_ctf_defense;
			bot.havocbot_role_timeout = 0;
			break;
		case HAVOCBOT_CTF_ROLE_MIDDLE:
			dprint("middle");
			bot.havocbot_role = havocbot_role_ctf_middle;
			bot.havocbot_role_timeout = 0;
			break;
		case HAVOCBOT_CTF_ROLE_OFFENSE:
			dprint("offense");
			bot.havocbot_role = havocbot_role_ctf_offense;
			bot.havocbot_role_timeout = 0;
			break;
		case HAVOCBOT_CTF_ROLE_RETRIEVER:
			dprint("retriever");
			bot.havocbot_previous_role = bot.havocbot_role;
			bot.havocbot_role = havocbot_role_ctf_retriever;
			bot.havocbot_role_timeout = time + 10;
			bot.bot_strategytime = 0;
			break;
		case HAVOCBOT_CTF_ROLE_ESCORT:
			dprint("escort");
			bot.havocbot_previous_role = bot.havocbot_role;
			bot.havocbot_role = havocbot_role_ctf_escort;
			bot.havocbot_role_timeout = time + 30;
			bot.bot_strategytime = 0;
			break;
	}
	dprint("\n");
}


// ==============
// Hook Functions
// ==============

MUTATOR_HOOKFUNCTION(ctf_PlayerPreThink)
{
	entity flag;
	
	float t = 0, t2 = 0, t3 = 0;
	
	// initially clear items so they can be set as necessary later.
	self.items &~= (IT_RED_FLAG_CARRYING | IT_RED_FLAG_TAKEN | IT_RED_FLAG_LOST 
		| IT_BLUE_FLAG_CARRYING | IT_BLUE_FLAG_TAKEN | IT_BLUE_FLAG_LOST
		| IT_YELLOW_FLAG_CARRYING | IT_YELLOW_FLAG_TAKEN | IT_YELLOW_FLAG_LOST
		| IT_PINK_FLAG_CARRYING | IT_PINK_FLAG_TAKEN | IT_PINK_FLAG_LOST
		| IT_CTF_SHIELDED);

	// scan through all the flags and notify the client about them 
	for(flag = ctf_worldflaglist; flag; flag = flag.ctf_worldflagnext)
	{
		switch(flag.team)
		{
			case NUM_TEAM_1: t = IT_RED_FLAG_CARRYING; t2 = IT_RED_FLAG_TAKEN; t3 = IT_RED_FLAG_LOST; break;
			case NUM_TEAM_2: t = IT_BLUE_FLAG_CARRYING; t2 = IT_BLUE_FLAG_TAKEN; t3 = IT_BLUE_FLAG_LOST; break;
			case NUM_TEAM_3: t = IT_YELLOW_FLAG_CARRYING; t2 = IT_YELLOW_FLAG_TAKEN; t3 = IT_YELLOW_FLAG_LOST; break;
			case NUM_TEAM_4: t = IT_PINK_FLAG_CARRYING; t2 = IT_PINK_FLAG_TAKEN; t3 = IT_PINK_FLAG_LOST; break;
		}
	
		switch(flag.ctf_status)
		{
			case FLAG_PASSING:
			case FLAG_CARRY:
			{
				if((flag.owner == self) || (flag.pass_sender == self))
					self.items |= t; // carrying: self is currently carrying the flag
				else 
					self.items |= t2; // taken: someone on self's team is carrying the flag
				break;
			}
			case FLAG_DROPPED:
			{
				self.items |= t3; // lost: the flag is dropped somewhere on the map
				break;
			}
		}
	}
	
	// item for stopping players from capturing the flag too often
	if(self.ctf_captureshielded)
		self.items |= IT_CTF_SHIELDED;
	
	// update the health of the flag carrier waypointsprite
	if(self.wps_flagcarrier) 
		WaypointSprite_UpdateHealth(self.wps_flagcarrier, '1 0 0' * healtharmor_maxdamage(self.health, self.armorvalue, autocvar_g_balance_armor_blockpercent));
	
	return FALSE;
}

MUTATOR_HOOKFUNCTION(ctf_PlayerDamage) // for changing damage and force values that are applied to players in g_damage.qc
{
	if(frag_attacker.flagcarried) // if the attacker is a flagcarrier
	{
		if(frag_target == frag_attacker) // damage done to yourself
		{
			frag_damage *= autocvar_g_ctf_flagcarrier_selfdamagefactor;
			frag_force *= autocvar_g_ctf_flagcarrier_selfforcefactor;
		}
		else // damage done to everyone else
		{
			frag_damage *= autocvar_g_ctf_flagcarrier_damagefactor;
			frag_force *= autocvar_g_ctf_flagcarrier_forcefactor;
		}
	}
	else if(frag_target.flagcarried && (frag_target.deadflag == DEAD_NO) && IsDifferentTeam(frag_target, frag_attacker)) // if the target is a flagcarrier
	{
		if(autocvar_g_ctf_flagcarrier_auto_helpme_damage > ('1 0 0' * healtharmor_maxdamage(frag_target.health, frag_target.armorvalue, autocvar_g_balance_armor_blockpercent)))
		if(time > frag_target.wps_helpme_time + autocvar_g_ctf_flagcarrier_auto_helpme_time)
		{
			frag_target.wps_helpme_time = time;
			WaypointSprite_HelpMePing(frag_target.wps_flagcarrier);
		}
		// todo: add notification for when flag carrier needs help?
	}
	return FALSE;
}

MUTATOR_HOOKFUNCTION(ctf_PlayerDies)
{
	if((frag_attacker != frag_target) && (IS_PLAYER(frag_attacker)) && (frag_target.flagcarried))
	{
		PlayerTeamScore_AddScore(frag_attacker, autocvar_g_ctf_score_kill);
		PlayerScore_Add(frag_attacker, SP_CTF_FCKILLS, 1);
	}
				
	if(frag_target.flagcarried)
		{ ctf_Handle_Throw(frag_target, world, DROP_NORMAL); frag_target.fc_waskilled = TRUE; }
		
	return FALSE;
}

MUTATOR_HOOKFUNCTION(ctf_GiveFragsForKill)
{
	frag_score = 0;
	return (autocvar_g_ctf_ignore_frags); // no frags counted in ctf if this is true
}

MUTATOR_HOOKFUNCTION(ctf_RemovePlayer)
{
	entity flag; // temporary entity for the search method
	
	if(self.flagcarried)
		{ ctf_Handle_Throw(self, world, DROP_NORMAL); }
	
	for(flag = ctf_worldflaglist; flag; flag = flag.ctf_worldflagnext)
	{
		if(flag.pass_sender == self) { flag.pass_sender = world; }
		if(flag.pass_target == self) { flag.pass_target = world; }
		if(flag.ctf_dropper == self) { flag.ctf_dropper = world; }
	}
		
	return FALSE;
}

MUTATOR_HOOKFUNCTION(ctf_PortalTeleport)
{
	if(self.flagcarried) 
	if(!autocvar_g_ctf_portalteleport)
		{ ctf_Handle_Throw(self, world, DROP_NORMAL); }

	return FALSE;
}

MUTATOR_HOOKFUNCTION(ctf_PlayerUseKey)
{
	if(MUTATOR_RETURNVALUE || gameover) { return FALSE; }
	
	entity player = self;

	if((time > player.throw_antispam) && (player.deadflag == DEAD_NO) && !player.speedrunning && (!player.vehicle || autocvar_g_ctf_allow_vehicle_touch))
	{
		// pass the flag to a team mate
		if(autocvar_g_ctf_pass)
		{
			entity head, closest_target = world;
			head = WarpZone_FindRadius(player.origin, autocvar_g_ctf_pass_radius, TRUE);
			
			while(head) // find the closest acceptable target to pass to
			{
				if(IS_PLAYER(head) && head.deadflag == DEAD_NO)
				if(head != player && !IsDifferentTeam(head, player))
				if(!head.speedrunning && !head.vehicle)
				{
					// if it's a player, use the view origin as reference (stolen from RadiusDamage functions in g_damage.qc) 
					vector head_center = WarpZone_UnTransformOrigin(head, CENTER_OR_VIEWOFS(head));
					vector passer_center = CENTER_OR_VIEWOFS(player);
					
					if(ctf_CheckPassDirection(head_center, passer_center, player.v_angle, head.WarpZone_findradius_nearest))
					{
						if(autocvar_g_ctf_pass_request && !player.flagcarried && head.flagcarried) 
						{ 
							if(IS_BOT_CLIENT(head))
							{
								Send_Notification(NOTIF_ONE, player, MSG_CENTER, CENTER_CTF_PASS_REQUESTING, head.netname);
								ctf_Handle_Throw(head, player, DROP_PASS);
							}
							else
							{
								Send_Notification(NOTIF_ONE, head, MSG_CENTER, CENTER_CTF_PASS_REQUESTED, player.netname);
								Send_Notification(NOTIF_ONE, player, MSG_CENTER, CENTER_CTF_PASS_REQUESTING, head.netname);
							}
							player.throw_antispam = time + autocvar_g_ctf_pass_wait; 
							return TRUE; 
						}
						else if(player.flagcarried)
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
			
			if(closest_target) { ctf_Handle_Throw(player, closest_target, DROP_PASS); return TRUE; }
		}
		
		// throw the flag in front of you
		if(autocvar_g_ctf_throw && player.flagcarried)
		{
			if(player.throw_count == -1)
			{
				if(time > player.throw_prevtime + autocvar_g_ctf_throw_punish_delay)
				{
					player.throw_prevtime = time;
					player.throw_count = 1;
					ctf_Handle_Throw(player, world, DROP_THROW);
					return TRUE;
				}
				else
				{
					Send_Notification(NOTIF_ONE, player, MSG_CENTER, CENTER_CTF_FLAG_THROW_PUNISH, rint((player.throw_prevtime + autocvar_g_ctf_throw_punish_delay) - time));
					return FALSE;
				}
			}
			else
			{
				if(time > player.throw_prevtime + autocvar_g_ctf_throw_punish_time) { player.throw_count = 1; }
				else { player.throw_count += 1; }
				if(player.throw_count >= autocvar_g_ctf_throw_punish_count) { player.throw_count = -1; }
					
				player.throw_prevtime = time;
				ctf_Handle_Throw(player, world, DROP_THROW);
				return TRUE;
			}
		}
	}
		
	return FALSE;
}

MUTATOR_HOOKFUNCTION(ctf_HelpMePing)
{
	if(self.wps_flagcarrier) // update the flagcarrier waypointsprite with "NEEDING HELP" notification
	{
		self.wps_helpme_time = time;
		WaypointSprite_HelpMePing(self.wps_flagcarrier);
	} 
	else // create a normal help me waypointsprite
	{
		WaypointSprite_Spawn("helpme", waypointsprite_deployed_lifetime, waypointsprite_limitedrange, self, FLAG_WAYPOINT_OFFSET, world, self.team, self, wps_helpme, FALSE, RADARICON_HELPME, '1 0.5 0');
		WaypointSprite_Ping(self.wps_helpme);
	}

	return TRUE;
}

MUTATOR_HOOKFUNCTION(ctf_VehicleEnter)
{
	if(vh_player.flagcarried)
	{
		if(!autocvar_g_ctf_allow_vehicle_carry && !autocvar_g_ctf_allow_vehicle_touch)
		{
			ctf_Handle_Throw(vh_player, world, DROP_NORMAL);
		}
		else
		{            
			setattachment(vh_player.flagcarried, vh_vehicle, ""); 
			setorigin(vh_player.flagcarried, VEHICLE_FLAG_OFFSET);
			vh_player.flagcarried.scale = VEHICLE_FLAG_SCALE;
			//vh_player.flagcarried.angles = '0 0 0';	
		}
		return TRUE;
	}
		
	return FALSE;
}

MUTATOR_HOOKFUNCTION(ctf_VehicleExit)
{
	if(vh_player.flagcarried)
	{
		setattachment(vh_player.flagcarried, vh_player, ""); 
		setorigin(vh_player.flagcarried, FLAG_CARRY_OFFSET);
		vh_player.flagcarried.scale = FLAG_SCALE;
		vh_player.flagcarried.angles = '0 0 0';
		return TRUE;
	}

	return FALSE;
}

MUTATOR_HOOKFUNCTION(ctf_AbortSpeedrun)
{
	if(self.flagcarried)
	{
		Send_Notification(NOTIF_ALL, world, MSG_INFO, APP_TEAM_ENT_4(self.flagcarried, INFO_CTF_FLAGRETURN_ABORTRUN_));
		ctf_RespawnFlag(self.flagcarried);
		return TRUE;
	}
	
	return FALSE;
}

MUTATOR_HOOKFUNCTION(ctf_MatchEnd)
{
	entity flag; // temporary entity for the search method
	
	for(flag = ctf_worldflaglist; flag; flag = flag.ctf_worldflagnext)
	{
		switch(flag.ctf_status)
		{
			case FLAG_DROPPED:
			case FLAG_PASSING:
			{
				// lock the flag, game is over
				flag.movetype = MOVETYPE_NONE;
				flag.takedamage = DAMAGE_NO;
				flag.solid = SOLID_NOT;
				flag.nextthink = FALSE; // stop thinking
				
				//dprint("stopping the ", flag.netname, " from moving.\n");
				break;
			}
			
			default:
			case FLAG_BASE:
			case FLAG_CARRY:
			{
				// do nothing for these flags
				break;
			}
		}
	}
	
	return FALSE;
}

MUTATOR_HOOKFUNCTION(ctf_BotRoles)
{
	havocbot_ctf_reset_role(self);
	return TRUE;
}

MUTATOR_HOOKFUNCTION(ctf_GetCvars)
{
	GetCvars_handleFloat(get_cvars_s, get_cvars_f, CAPTURE_VERBOSE, "notification_ctf_capture_verbose");
	GetCvars_handleFloat(get_cvars_s, get_cvars_f, PICKUP_TEAM_VERBOSE, "notification_ctf_pickup_team_verbose");
	GetCvars_handleFloat(get_cvars_s, get_cvars_f, PICKUP_ENEMY_VERBOSE, "notification_ctf_pickup_enemy_verbose");
	return TRUE;
}

MUTATOR_HOOKFUNCTION(ctf_GetTeamCount)
{
	ret_float = ctf_teams;
	return 0;
}


// ==========
// Spawnfuncs
// ==========

/*QUAKED spawnfunc_info_player_team1 (1 0 0) (-16 -16 -24) (16 16 24)
CTF Starting point for a player in team one (Red).
Keys: "angle" viewing angle when spawning. */
void spawnfunc_info_player_team1()
{
	if(g_assault) { remove(self); return; }
	
	self.team = NUM_TEAM_1; // red
	spawnfunc_info_player_deathmatch();
}


/*QUAKED spawnfunc_info_player_team2 (1 0 0) (-16 -16 -24) (16 16 24)
CTF Starting point for a player in team two (Blue).
Keys: "angle" viewing angle when spawning. */
void spawnfunc_info_player_team2()
{
	if(g_assault) { remove(self); return; }
	
	self.team = NUM_TEAM_2; // blue
	spawnfunc_info_player_deathmatch();
}

/*QUAKED spawnfunc_info_player_team3 (1 0 0) (-16 -16 -24) (16 16 24)
CTF Starting point for a player in team three (Yellow).
Keys: "angle" viewing angle when spawning. */
void spawnfunc_info_player_team3()
{
	if(g_assault) { remove(self); return; }
	
	self.team = NUM_TEAM_3; // yellow
	spawnfunc_info_player_deathmatch();
}


/*QUAKED spawnfunc_info_player_team4 (1 0 0) (-16 -16 -24) (16 16 24)
CTF Starting point for a player in team four (Purple).
Keys: "angle" viewing angle when spawning. */
void spawnfunc_info_player_team4()
{
	if(g_assault) { remove(self); return; }
	
	self.team = NUM_TEAM_4; // purple
	spawnfunc_info_player_deathmatch();
}

/*QUAKED spawnfunc_item_flag_team1 (0 0.5 0.8) (-48 -48 -37) (48 48 37)
CTF flag for team one (Red).
Keys: 
"angle" Angle the flag will point (minus 90 degrees)... 
"model" model to use, note this needs red and blue as skins 0 and 1...
"noise" sound played when flag is picked up...
"noise1" sound played when flag is returned by a teammate...
"noise2" sound played when flag is captured...
"noise3" sound played when flag is lost in the field and respawns itself... 
"noise4" sound played when flag is dropped by a player...
"noise5" sound played when flag touches the ground... */
void spawnfunc_item_flag_team1()
{
	if(!g_ctf) { remove(self); return; }

	ctf_FlagSetup(1, self); // 1 = red
}

/*QUAKED spawnfunc_item_flag_team2 (0 0.5 0.8) (-48 -48 -37) (48 48 37)
CTF flag for team two (Blue).
Keys: 
"angle" Angle the flag will point (minus 90 degrees)... 
"model" model to use, note this needs red and blue as skins 0 and 1...
"noise" sound played when flag is picked up...
"noise1" sound played when flag is returned by a teammate...
"noise2" sound played when flag is captured...
"noise3" sound played when flag is lost in the field and respawns itself... 
"noise4" sound played when flag is dropped by a player...
"noise5" sound played when flag touches the ground... */
void spawnfunc_item_flag_team2()
{
	if(!g_ctf) { remove(self); return; }

	ctf_FlagSetup(0, self); // the 0 is misleading, but -- 0 = blue.
}

/*QUAKED spawnfunc_item_flag_team3 (0 0.5 0.8) (-48 -48 -37) (48 48 37)
CTF flag for team three (Yellow).
Keys: 
"angle" Angle the flag will point (minus 90 degrees)... 
"model" model to use, note this needs red, blue yellow and pink as skins 0, 1, 2 and 3...
"noise" sound played when flag is picked up...
"noise1" sound played when flag is returned by a teammate...
"noise2" sound played when flag is captured...
"noise3" sound played when flag is lost in the field and respawns itself... 
"noise4" sound played when flag is dropped by a player...
"noise5" sound played when flag touches the ground... */
void spawnfunc_item_flag_team3()
{
	if(!g_ctf) { remove(self); return; }

	ctf_FlagSetup(2, self); // 2 = yellow?
}

/*QUAKED spawnfunc_item_flag_team4 (0 0.5 0.8) (-48 -48 -37) (48 48 37)
CTF flag for team two (Pink).
Keys: 
"angle" Angle the flag will point (minus 90 degrees)... 
"model" model to use, note this needs red, blue yellow and pink as skins 0, 1, 2 and 3...
"noise" sound played when flag is picked up...
"noise1" sound played when flag is returned by a teammate...
"noise2" sound played when flag is captured...
"noise3" sound played when flag is lost in the field and respawns itself... 
"noise4" sound played when flag is dropped by a player...
"noise5" sound played when flag touches the ground... */
void spawnfunc_item_flag_team4()
{
	if(!g_ctf) { remove(self); return; }

	ctf_FlagSetup(3, self); // 3 = pink?
}

/*QUAKED spawnfunc_ctf_team (0 .5 .8) (-16 -16 -24) (16 16 32)
Team declaration for CTF gameplay, this allows you to decide what team names and control point models are used in your map.
Note: If you use spawnfunc_ctf_team entities you must define at least 2!  However, unlike domination, you don't need to make a blank one too.
Keys:
"netname" Name of the team (for example Red, Blue, Green, Yellow, Life, Death, Offense, Defense, etc)...
"cnt" Scoreboard color of the team (for example 4 is red and 13 is blue)... */
void spawnfunc_ctf_team()
{
	if(!g_ctf) { remove(self); return; }
	
	self.classname = "ctf_team";
	self.team = self.cnt + 1;
}

// compatibility for quake maps
void spawnfunc_team_CTF_redflag()    { spawnfunc_item_flag_team1();    }
void spawnfunc_team_CTF_blueflag()   { spawnfunc_item_flag_team2();    }
void spawnfunc_team_CTF_redplayer()  { spawnfunc_info_player_team1();  }
void spawnfunc_team_CTF_blueplayer() { spawnfunc_info_player_team2();  }
void spawnfunc_team_CTF_redspawn()   { spawnfunc_info_player_team1();  }
void spawnfunc_team_CTF_bluespawn()  { spawnfunc_info_player_team2();  }


// ==============
// Initialization
// ==============

// scoreboard setup
void ctf_ScoreRules(float teams)
{
	CheckAllowedTeams(world);
	ScoreRules_basics(teams, SFL_SORT_PRIO_PRIMARY, 0, TRUE);
	ScoreInfo_SetLabel_TeamScore  (ST_CTF_CAPS,     "caps",      SFL_SORT_PRIO_PRIMARY);
	ScoreInfo_SetLabel_PlayerScore(SP_CTF_CAPS,     "caps",      SFL_SORT_PRIO_SECONDARY);
	ScoreInfo_SetLabel_PlayerScore(SP_CTF_CAPTIME,  "captime",   SFL_LOWER_IS_BETTER | SFL_TIME);
	ScoreInfo_SetLabel_PlayerScore(SP_CTF_PICKUPS,  "pickups",   0);
	ScoreInfo_SetLabel_PlayerScore(SP_CTF_FCKILLS,  "fckills",   0);
	ScoreInfo_SetLabel_PlayerScore(SP_CTF_RETURNS,  "returns",   0);
	ScoreInfo_SetLabel_PlayerScore(SP_CTF_DROPS,    "drops",     SFL_LOWER_IS_BETTER);
	ScoreRules_basics_end();
}

// code from here on is just to support maps that don't have flag and team entities
void ctf_SpawnTeam (string teamname, float teamcolor)
{
	entity oldself;
	oldself = self;
	self = spawn();
	self.classname = "ctf_team";
	self.netname = teamname;
	self.cnt = teamcolor;

	spawnfunc_ctf_team();

	self = oldself;
}

void ctf_DelayedInit() // Do this check with a delay so we can wait for teams to be set up.
{
	ctf_teams = 2;
	
	entity tmp_entity;
	for(tmp_entity = ctf_worldflaglist; tmp_entity; tmp_entity = tmp_entity.ctf_worldflagnext)
	if(tmp_entity.team == NUM_TEAM_3)
	{
		++ctf_teams;
		break; // found 1 flag for this team
	}
	for(tmp_entity = ctf_worldflaglist; tmp_entity; tmp_entity = tmp_entity.ctf_worldflagnext)
	if(tmp_entity.team == NUM_TEAM_4)
	{
		++ctf_teams;
		break; // found 1 flag for this team
	}
	
	ctf_teams = bound(2, ctf_teams, 4);

	// if no teams are found, spawn defaults
	if(find(world, classname, "ctf_team") == world)
	{
		print("No ""ctf_team"" entities found on this map, creating them anyway.\n");
		ctf_SpawnTeam("Red", NUM_TEAM_1 - 1);
		ctf_SpawnTeam("Blue", NUM_TEAM_2 - 1);
		if(ctf_teams >= 3)
		{
			ctf_SpawnTeam("Yellow", NUM_TEAM_3 - 1);
			if(ctf_teams >= 4)
				ctf_SpawnTeam("Pink", NUM_TEAM_4 - 1);
		}
	}
	
	ret_float = ctf_teams;
	ctf_ScoreRules(ctf_teams);
}

void ctf_Initialize()
{
	ctf_captimerecord = stof(db_get(ServerProgsDB, strcat(GetMapname(), "/captimerecord/time")));

	ctf_captureshield_min_negscore = autocvar_g_ctf_shield_min_negscore;
	ctf_captureshield_max_ratio = autocvar_g_ctf_shield_max_ratio;
	ctf_captureshield_force = autocvar_g_ctf_shield_force;
	
	InitializeEntity(world, ctf_DelayedInit, INITPRIO_GAMETYPE);
}


MUTATOR_DEFINITION(gamemode_ctf)
{
	MUTATOR_HOOK(MakePlayerObserver, ctf_RemovePlayer, CBC_ORDER_ANY);
	MUTATOR_HOOK(ClientDisconnect, ctf_RemovePlayer, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerDies, ctf_PlayerDies, CBC_ORDER_ANY);
	MUTATOR_HOOK(MatchEnd, ctf_MatchEnd, CBC_ORDER_ANY);
	MUTATOR_HOOK(PortalTeleport, ctf_PortalTeleport, CBC_ORDER_ANY);
	MUTATOR_HOOK(GiveFragsForKill, ctf_GiveFragsForKill, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerPreThink, ctf_PlayerPreThink, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerDamage_Calculate, ctf_PlayerDamage, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerUseKey, ctf_PlayerUseKey, CBC_ORDER_ANY);
	MUTATOR_HOOK(HelpMePing, ctf_HelpMePing, CBC_ORDER_ANY);
	MUTATOR_HOOK(VehicleEnter, ctf_VehicleEnter, CBC_ORDER_ANY);
	MUTATOR_HOOK(VehicleExit, ctf_VehicleExit, CBC_ORDER_ANY);
	MUTATOR_HOOK(AbortSpeedrun, ctf_AbortSpeedrun, CBC_ORDER_ANY);
	MUTATOR_HOOK(HavocBot_ChooseRule, ctf_BotRoles, CBC_ORDER_ANY);
	MUTATOR_HOOK(GetCvars, ctf_GetCvars, CBC_ORDER_ANY);
	MUTATOR_HOOK(GetTeamCount, ctf_GetTeamCount, CBC_ORDER_ANY);
	
	MUTATOR_ONADD
	{
		if(time > 1) // game loads at time 1
			error("This is a game type and it cannot be added at runtime.");
		ctf_Initialize();
	}

	MUTATOR_ONROLLBACK_OR_REMOVE
	{
		// we actually cannot roll back ctf_Initialize here
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
