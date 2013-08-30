#define FOR_EACH_KH_KEY(v) for(v = kh_worldkeylist; v; v = v.kh_worldkeynext )

// #define KH_PLAYER_USE_ATTACHMENT
// #define KH_PLAYER_USE_CARRIEDMODEL

#ifdef KH_PLAYER_USE_ATTACHMENT
const vector KH_PLAYER_ATTACHMENT_DIST_ROTATED = '0 -4 0';
const vector KH_PLAYER_ATTACHMENT_DIST = '4 0 0';
const vector KH_PLAYER_ATTACHMENT = '0 0 0';
const vector KH_PLAYER_ATTACHMENT_ANGLES = '0 0 0';
const string KH_PLAYER_ATTACHMENT_BONE = "";
#else
const float KH_KEY_ZSHIFT = 22;
const float KH_KEY_XYDIST = 24;
const float KH_KEY_XYSPEED = 45;
#endif
const float KH_KEY_WP_ZSHIFT = 20;

const vector KH_KEY_MIN = '-10 -10 -46';
const vector KH_KEY_MAX = '10 10 3';
const float KH_KEY_BRIGHTNESS = 2;

float kh_no_radar_circles;

// kh_state
//     bits  0- 4: team of key 1, or 0 for no such key, or 30 for dropped, or 31 for self
//     bits  5- 9: team of key 2, or 0 for no such key, or 30 for dropped, or 31 for self
//     bits 10-14: team of key 3, or 0 for no such key, or 30 for dropped, or 31 for self
//     bits 15-19: team of key 4, or 0 for no such key, or 30 for dropped, or 31 for self
.float kh_state;
.float siren_time;  //  time delay the siren
//.float stuff_time;  //  time delay to stuffcmd a cvar

float kh_keystatus[17];
//kh_keystatus[0] = status of dropped keys, kh_keystatus[1 - 16] = player #
//replace 17 with cvar("maxplayers") or similar !!!!!!!!!
//for(i = 0; i < maxplayers; ++i)
//	kh_keystatus[i] = "0";

float kh_Team_ByID(float t)
{
	if(t == 0) return NUM_TEAM_1;
	if(t == 1) return NUM_TEAM_2;
	if(t == 2) return NUM_TEAM_3;
	if(t == 3) return NUM_TEAM_4;
	return 0;
}

entity kh_worldkeylist;
.entity kh_worldkeynext;
entity kh_controller;
float kh_tracking_enabled;
float kh_teams;
float kh_interferemsg_time, kh_interferemsg_team;
.entity kh_next, kh_prev; // linked list
.float kh_droptime;
.float kh_dropperteam;
.entity kh_previous_owner;
.float kh_previous_owner_playerid;
.float kh_cp_duration;

string kh_sound_capture = "kh/capture.wav";
string kh_sound_destroy = "kh/destroy.wav";
string kh_sound_drop = "kh/drop.wav";
string kh_sound_collect = "kh/collect.wav";
string kh_sound_alarm = "kh/alarm.wav";  // the new siren/alarm

float kh_key_dropped, kh_key_carried;

float kh_KeyCarrier_waypointsprite_visible_for_player(entity e)  // runs all the time
{
	if(!IS_PLAYER(e) || self.team != e.team)
		if(!kh_tracking_enabled)
			return FALSE;

	return TRUE;
}

float kh_Key_waypointsprite_visible_for_player(entity e) // ??
{
	if(!kh_tracking_enabled)
		return FALSE;
	if(!self.owner)
		return TRUE;
	if(!self.owner.owner)
		return TRUE;
	return FALSE;  // draw only when key is not owned
}

void kh_update_state()
{
	entity player;
	entity key;
	float s;
	float f;

	s = 0;
	FOR_EACH_KH_KEY(key)
	{
		if(key.owner)
			f = key.team;
		else
			f = 30;
		s |= pow(32, key.count) * f;
	}

	FOR_EACH_CLIENT(player)
	{
		player.kh_state = s;
	}

	FOR_EACH_KH_KEY(key)
	{
		if(key.owner)
			key.owner.kh_state |= pow(32, key.count) * 31;
	}
	//print(ftos((nextent(world)).kh_state), "\n");
}




var kh_Think_t kh_Controller_Thinkfunc;
void kh_Controller_SetThink(float t, kh_Think_t func)  // runs occasionaly
{
	kh_Controller_Thinkfunc = func;
	kh_controller.cnt = ceil(t);
	if(t == 0)
		kh_controller.nextthink = time; // force
}
void kh_WaitForPlayers();
void kh_Controller_Think()  // called a lot
{
	if(intermission_running)
		return;
	if(self.cnt > 0)
	{ if(self.think != kh_WaitForPlayers) { self.cnt -= 1; } }
	else if(self.cnt == 0)
	{
		self.cnt -= 1;
		kh_Controller_Thinkfunc();
	}
	self.nextthink = time + 1;
}

// frags f: take from cvar * f
// frags 0: no frags
void kh_Scores_Event(entity player, entity key, string what, float frags_player, float frags_owner)  // update the score when a key is captured
{
	string s;
	if(intermission_running)
		return;

	if(frags_player)
		UpdateFrags(player, frags_player);

	if(key && key.owner && frags_owner)
		UpdateFrags(key.owner, frags_owner);

	if(!autocvar_sv_eventlog)  //output extra info to the console or text file
		return;

	s = strcat(":keyhunt:", what, ":", ftos(player.playerid), ":", ftos(frags_player));

	if(key && key.owner)
		s = strcat(s, ":", ftos(key.owner.playerid));
	else
		s = strcat(s, ":0");

	s = strcat(s, ":", ftos(frags_owner), ":");

	if(key)
		s = strcat(s, key.netname);

	GameLogEcho(s);
}

vector kh_AttachedOrigin(entity e)  // runs when a team captures the flag, it can run 2 or 3 times.
{
	if(e.tag_entity)
	{
		makevectors(e.tag_entity.angles);
		return e.tag_entity.origin + e.origin_x * v_forward - e.origin_y * v_right + e.origin_z * v_up;
	}
	else
		return e.origin;
}

void kh_Key_Attach(entity key)  // runs when a player picks up a key and several times when a key is assigned to a player at the start of a round
{
#ifdef KH_PLAYER_USE_ATTACHMENT
	entity first;
	first = key.owner.kh_next;
	if(key == first)
	{
		setattachment(key, key.owner, KH_PLAYER_ATTACHMENT_BONE);
		if(key.kh_next)
		{
			setattachment(key.kh_next, key, "");
			setorigin(key, key.kh_next.origin - 0.5 * KH_PLAYER_ATTACHMENT_DIST);
			setorigin(key.kh_next, KH_PLAYER_ATTACHMENT_DIST_ROTATED);
			key.kh_next.angles = '0 0 0';
		}
		else
			setorigin(key, KH_PLAYER_ATTACHMENT);
		key.angles = KH_PLAYER_ATTACHMENT_ANGLES;
	}
	else
	{
		setattachment(key, key.kh_prev, "");
		if(key.kh_next)
			setattachment(key.kh_next, key, "");
		setorigin(key, KH_PLAYER_ATTACHMENT_DIST_ROTATED);
		setorigin(first, first.origin - 0.5 * KH_PLAYER_ATTACHMENT_DIST);
		key.angles = '0 0 0';
	}
#else
	setattachment(key, key.owner, "");
	setorigin(key, '0 0 1' * KH_KEY_ZSHIFT);  // fixing x, y in think
	key.angles_y -= key.owner.angles_y;
#endif
	key.flags = 0;
	key.solid = SOLID_NOT;
	key.movetype = MOVETYPE_NONE;
	key.team = key.owner.team;
	key.nextthink = time;
	key.damageforcescale = 0;
	key.takedamage = DAMAGE_NO;
	key.modelindex = kh_key_carried;
}

void kh_Key_Detach(entity key) // runs every time a key is dropped or lost. Runs several times times when all the keys are captured
{
#ifdef KH_PLAYER_USE_ATTACHMENT
	entity first;
	first = key.owner.kh_next;
	if(key == first)
	{
		if(key.kh_next)
		{
			setattachment(key.kh_next, key.owner, KH_PLAYER_ATTACHMENT_BONE);
			setorigin(key.kh_next, key.origin + 0.5 * KH_PLAYER_ATTACHMENT_DIST);
			key.kh_next.angles = KH_PLAYER_ATTACHMENT_ANGLES;
		}
	}
	else
	{
		if(key.kh_next)
			setattachment(key.kh_next, key.kh_prev, "");
		setorigin(first, first.origin + 0.5 * KH_PLAYER_ATTACHMENT_DIST);
	}
	// in any case:
	setattachment(key, world, "");
	setorigin(key, key.owner.origin + '0 0 1' * (PL_MIN_z - KH_KEY_MIN_z));
	key.angles = key.owner.angles;
#else
	setorigin(key, key.owner.origin + key.origin_z * '0 0 1');
	setattachment(key, world, "");
	key.angles_y += key.owner.angles_y;
#endif
	key.flags = FL_ITEM;
	key.solid = SOLID_TRIGGER;
	key.movetype = MOVETYPE_TOSS;
	key.pain_finished = time + autocvar_g_balance_keyhunt_delay_return;
	key.damageforcescale = autocvar_g_balance_keyhunt_damageforcescale;
	key.takedamage = DAMAGE_YES;
	// let key.team stay
	key.modelindex = kh_key_dropped;
	key.kh_previous_owner = key.owner;
	key.kh_previous_owner_playerid = key.owner.playerid;
}

void kh_Key_AssignTo(entity key, entity player)  // runs every time a key is picked up or assigned. Runs prior to kh_key_attach
{
	entity k;
	float ownerteam0, ownerteam;
	if(key.owner == player)
		return;

	ownerteam0 = kh_Key_AllOwnedByWhichTeam();

	if(key.owner)
	{
		kh_Key_Detach(key);

		// remove from linked list
		if(key.kh_next)
			key.kh_next.kh_prev = key.kh_prev;
		key.kh_prev.kh_next = key.kh_next;
		key.kh_next = world;
		key.kh_prev = world;

		if(key.owner.kh_next == world)
		{
			// No longer a key carrier
			if(!kh_no_radar_circles)
				WaypointSprite_Ping(key.owner.waypointsprite_attachedforcarrier);
			WaypointSprite_DetachCarrier(key.owner);
		}
	}

	key.owner = player;

	if(player)
	{
		// insert into linked list
		key.kh_next = player.kh_next;
		key.kh_prev = player;
		player.kh_next = key;
		if(key.kh_next)
			key.kh_next.kh_prev = key;

		float i;
		i = kh_keystatus[key.owner.playerid];
			if(key.netname == "^1red key")
				i += 1;
			if(key.netname == "^4blue key")
				i += 2;
			if(key.netname == "^3yellow key")
				i += 4;
			if(key.netname == "^6pink key")
				i += 8;
		kh_keystatus[key.owner.playerid] = i;

		kh_Key_Attach(key);

		if(key.kh_next == world)
		{
			// player is now a key carrier
			WaypointSprite_AttachCarrier("", player, RADARICON_FLAGCARRIER, colormapPaletteColor(player.team - 1, 0));
			player.waypointsprite_attachedforcarrier.waypointsprite_visible_for_player = kh_KeyCarrier_waypointsprite_visible_for_player;
			WaypointSprite_UpdateRule(player.waypointsprite_attachedforcarrier, player.team, SPRITERULE_TEAMPLAY);
			if(player.team == NUM_TEAM_1)
				WaypointSprite_UpdateSprites(player.waypointsprite_attachedforcarrier, "keycarrier-red", "keycarrier-friend", "keycarrier-red");
			else if(player.team == NUM_TEAM_2)
				WaypointSprite_UpdateSprites(player.waypointsprite_attachedforcarrier, "keycarrier-blue", "keycarrier-friend", "keycarrier-blue");
			else if(player.team == NUM_TEAM_3)
				WaypointSprite_UpdateSprites(player.waypointsprite_attachedforcarrier, "keycarrier-yellow", "keycarrier-friend", "keycarrier-yellow");
			else if(player.team == NUM_TEAM_4)
				WaypointSprite_UpdateSprites(player.waypointsprite_attachedforcarrier, "keycarrier-pink", "keycarrier-friend", "keycarrier-pink");
			if(!kh_no_radar_circles)
				WaypointSprite_Ping(player.waypointsprite_attachedforcarrier);
		}
	}

	// moved that here, also update if there's no player
	kh_update_state();

	key.pusher = world;

	ownerteam = kh_Key_AllOwnedByWhichTeam();
	if(ownerteam != ownerteam0)
	{
		if(ownerteam != -1)
		{
			kh_interferemsg_time = time + 0.2;
			kh_interferemsg_team = player.team;

			// audit all key carrier sprites, update them to RUN HERE
			FOR_EACH_KH_KEY(k)
			{
				if(k.owner)
					WaypointSprite_UpdateSprites(k.owner.waypointsprite_attachedforcarrier, k.owner.waypointsprite_attachedforcarrier.model1, "keycarrier-finish", k.owner.waypointsprite_attachedforcarrier.model3);
			}
		}
		else
		{
			kh_interferemsg_time = 0;

			// audit all key carrier sprites, update them to RUN HERE
			FOR_EACH_KH_KEY(k)
			{
				if(k.owner)
					WaypointSprite_UpdateSprites(k.owner.waypointsprite_attachedforcarrier, k.owner.waypointsprite_attachedforcarrier.model1, "keycarrier-friend", k.owner.waypointsprite_attachedforcarrier.model3);
			}
		}
	}
}

void kh_Key_Damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if(self.owner)
		return;
	if(ITEM_DAMAGE_NEEDKILL(deathtype))
	{
		// touching lava, or hurt trigger
		// what shall we do?
		// immediately return is bad
		// maybe start a shorter countdown?
	}
	if(vlen(force) <= 0)
		return;
	if(time > self.pushltime)
		if(IS_PLAYER(attacker))
			self.team = attacker.team;
}

void kh_Key_Collect(entity key, entity player)  //a player picks up a dropped key
{
	sound(player, CH_TRIGGER, kh_sound_collect, VOL_BASE, ATTEN_NORM);

	if(key.kh_dropperteam != player.team)
	{
		kh_Scores_Event(player, key, "collect", autocvar_g_balance_keyhunt_score_collect, 0);
		PlayerScore_Add(player, SP_KH_PICKUPS, 1);
	}
	key.kh_dropperteam = 0;
	Send_Notification(NOTIF_ALL, world, MSG_INFO, APP_TEAM_ENT_4(key, INFO_KEYHUNT_PICKUP_), player.netname);

	kh_Key_AssignTo(key, player); // this also updates .kh_state
}

void kh_Key_Touch()  // runs many, many times when a key has been dropped and can be picked up
{
	if(intermission_running)
		return;

	if(self.owner) // already carried
		return;

	if(ITEM_TOUCH_NEEDKILL())
	{
		// touching sky, or nodrop
		// what shall we do?
		// immediately return is bad
		// maybe start a shorter countdown?
	}

	if not(IS_PLAYER(other))
		return;
	if(other.deadflag != DEAD_NO)
		return;
	if(other == self.enemy)
		if(time < self.kh_droptime + autocvar_g_balance_keyhunt_delay_collect)
			return;  // you just dropped it!
	kh_Key_Collect(self, other);
}

void kh_Key_Remove(entity key)  // runs after when all the keys have been collected or when a key has been dropped for more than X seconds
{
	entity o;
	o = key.owner;
	kh_Key_AssignTo(key, world);
	if(o) // it was attached
		WaypointSprite_Kill(key.waypointsprite_attachedforcarrier);
	else // it was dropped
		WaypointSprite_DetachCarrier(key);

	// remove key from key list
	if (kh_worldkeylist == key)
		kh_worldkeylist = kh_worldkeylist.kh_worldkeynext;
	else
	{
		o = kh_worldkeylist;
		while (o)
		{
			if (o.kh_worldkeynext == key)
			{
				o.kh_worldkeynext = o.kh_worldkeynext.kh_worldkeynext;
				break;
			}
			o = o.kh_worldkeynext;
		}
	}

	remove(key);

	kh_update_state();
}

void kh_FinishRound()  // runs when a team captures the keys
{
	// prepare next round
	kh_interferemsg_time = 0;
	entity key;

	kh_no_radar_circles = TRUE;
	FOR_EACH_KH_KEY(key)
		kh_Key_Remove(key);
	kh_no_radar_circles = FALSE;

	Send_Notification(NOTIF_ALL, world, MSG_CENTER, CENTER_KEYHUNT_ROUNDSTART, autocvar_g_balance_keyhunt_delay_round);
	kh_Controller_SetThink(autocvar_g_balance_keyhunt_delay_round, kh_StartRound);
}

void kh_WinnerTeam(float teem)  // runs when a team wins // Samual: Teem?.... TEEM?!?! what the fuck is wrong with you people
{
	// all key carriers get some points
	vector firstorigin, lastorigin, midpoint;
	float first;
	entity key;
	float score;
	score = (kh_teams - 1) * autocvar_g_balance_keyhunt_score_capture;
	DistributeEvenly_Init(score, kh_teams);
	// twice the score for 3 team games, three times the score for 4 team games!
	// note: for a win by destroying the key, this should NOT be applied
	FOR_EACH_KH_KEY(key)
	{
		float f;
		f = DistributeEvenly_Get(1);
		kh_Scores_Event(key.owner, key, "capture", f, 0);
		PlayerTeamScore_Add(key.owner, SP_KH_CAPS, ST_KH_CAPS, 1);
	}

	first = TRUE;
	string keyowner = "";
	FOR_EACH_KH_KEY(key)
		if(key.owner.kh_next == key)
		{
			if(!first)
				keyowner = strcat(keyowner, ", ");
			keyowner = key.owner.netname;
			first = FALSE;
		}

	Send_Notification(NOTIF_ALL, world, MSG_INFO, APP_TEAM_NUM_4(teem, INFO_KEYHUNT_CAPTURE_), keyowner);

	first = TRUE;
	midpoint = '0 0 0';
	firstorigin = '0 0 0';
	lastorigin = '0 0 0';
	FOR_EACH_KH_KEY(key)
	{
		vector thisorigin;

		thisorigin = kh_AttachedOrigin(key);
		//dprint("Key origin: ", vtos(thisorigin), "\n");
		midpoint += thisorigin;

		if(!first)
			te_lightning2(world, lastorigin, thisorigin);
		lastorigin = thisorigin;
		if(first)
			firstorigin = thisorigin;
		first = FALSE;
	}
	if(kh_teams > 2)
	{
		te_lightning2(world, lastorigin, firstorigin);
	}
	midpoint = midpoint * (1 / kh_teams);
	te_customflash(midpoint, 1000, 1, Team_ColorRGB(teem) * 0.5 + '0.5 0.5 0.5');  // make the color >=0.5 in each component

	play2all(kh_sound_capture);
	kh_FinishRound();
}

void kh_LoserTeam(float teem, entity lostkey)  // runs when a player pushes a flag carrier off the map
{
	entity player, key, attacker;
	float players;
	float keys;
	float f;

	attacker = world;
	if(lostkey.pusher)
		if(lostkey.pusher.team != teem)
			if(IS_PLAYER(lostkey.pusher))
				attacker = lostkey.pusher;

	players = keys = 0;

	if(attacker)
	{
		if(lostkey.kh_previous_owner)
			kh_Scores_Event(lostkey.kh_previous_owner, world, "pushed", 0, -autocvar_g_balance_keyhunt_score_push);
			// don't actually GIVE him the -nn points, just log
		kh_Scores_Event(attacker, world, "push", autocvar_g_balance_keyhunt_score_push, 0);
		PlayerScore_Add(attacker, SP_KH_PUSHES, 1);
		//centerprint(attacker, "Your push is the best!"); // does this really need to exist?
	}
	else
	{
		float of, fragsleft, i, j, thisteam;
		of = autocvar_g_balance_keyhunt_score_destroyed_ownfactor;

		FOR_EACH_PLAYER(player)
			if(player.team != teem)
				++players;

		FOR_EACH_KH_KEY(key)
			if(key.owner && key.team != teem)
				++keys;

		if(lostkey.kh_previous_owner)
			kh_Scores_Event(lostkey.kh_previous_owner, world, "destroyed", 0, -autocvar_g_balance_keyhunt_score_destroyed);
			// don't actually GIVE him the -nn points, just log

		if(lostkey.kh_previous_owner.playerid == lostkey.kh_previous_owner_playerid)
			PlayerScore_Add(lostkey.kh_previous_owner, SP_KH_DESTROYS, 1);

		DistributeEvenly_Init(autocvar_g_balance_keyhunt_score_destroyed, keys * of + players);

		FOR_EACH_KH_KEY(key)
			if(key.owner && key.team != teem)
			{
				f = DistributeEvenly_Get(of);
				kh_Scores_Event(key.owner, world, "destroyed_holdingkey", f, 0);
			}

		fragsleft = DistributeEvenly_Get(players);

		// Now distribute these among all other teams...
		j = kh_teams - 1;
		for(i = 0; i < kh_teams; ++i)
		{
			thisteam = kh_Team_ByID(i);
			if(thisteam == teem) // bad boy, no cookie - this WILL happen
				continue;

			players = 0;
			FOR_EACH_PLAYER(player)
				if(player.team == thisteam)
					++players;

			DistributeEvenly_Init(fragsleft, j);
			fragsleft = DistributeEvenly_Get(j - 1);
			DistributeEvenly_Init(DistributeEvenly_Get(1), players);

			FOR_EACH_PLAYER(player)
				if(player.team == thisteam)
				{
					f = DistributeEvenly_Get(1);
					kh_Scores_Event(player, world, "destroyed", f, 0);
				}

			--j;
		}
	}
	
	Send_Notification(NOTIF_ALL, world, MSG_INFO, APP_TEAM_ENT_4(lostkey, INFO_KEYHUNT_LOST_), lostkey.kh_previous_owner.netname);
	
	play2all(kh_sound_destroy);
	te_tarexplosion(lostkey.origin);

	kh_FinishRound();
}

void kh_Key_Think()  // runs all the time
{
	entity head;
	//entity player;  // needed by FOR_EACH_PLAYER

	if(intermission_running)
		return;

	if(self.owner)
	{
#ifndef KH_PLAYER_USE_ATTACHMENT
		makevectors('0 1 0' * (self.cnt + mod(time, 360) * KH_KEY_XYSPEED));
		setorigin(self, v_forward * KH_KEY_XYDIST + '0 0 1' * self.origin_z);
#endif
	}

	// if in nodrop or time over, end the round
	if(!self.owner)
		if(time > self.pain_finished)
			kh_LoserTeam(self.team, self);

	if(self.owner)
	if(kh_Key_AllOwnedByWhichTeam() != -1)
	{
		if(self.siren_time < time)
		{
			sound(self.owner, CH_TRIGGER, kh_sound_alarm, VOL_BASE, ATTEN_NORM);  // play a simple alarm
			self.siren_time = time + 2.5;  // repeat every 2.5 seconds
		}

		entity key;
		vector p;
		p = self.owner.origin;
		FOR_EACH_KH_KEY(key)
			if(vlen(key.owner.origin - p) > autocvar_g_balance_keyhunt_maxdist)
				goto not_winning;
		kh_WinnerTeam(self.team);
:not_winning
	}

	if(kh_interferemsg_time && time > kh_interferemsg_time)
	{
		kh_interferemsg_time = 0;
		FOR_EACH_PLAYER(head)
		{
			if(head.team == kh_interferemsg_team)
				if(head.kh_next)
					Send_Notification(NOTIF_ONE, head, MSG_CENTER, CENTER_KEYHUNT_MEET);
				else
					Send_Notification(NOTIF_ONE, head, MSG_CENTER, CENTER_KEYHUNT_HELP);
			else
				Send_Notification(NOTIF_ONE, head, MSG_CENTER, APP_TEAM_NUM_4(kh_interferemsg_team, CENTER_KEYHUNT_INTERFERE_));
		}
	}

	self.nextthink = time + 0.05;
}

void key_reset()
{
	kh_Key_AssignTo(self, world);
	kh_Key_Remove(self);
}

const string STR_ITEM_KH_KEY = "item_kh_key";
void kh_Key_Spawn(entity initial_owner, float angle, float i)  // runs every time a new flag is created, ie after all the keys have been collected
{
	entity key;
	key = spawn();
	key.count = i;
	key.classname = STR_ITEM_KH_KEY;
	key.touch = kh_Key_Touch;
	key.think = kh_Key_Think;
	key.nextthink = time;
	key.items = IT_KEY1 | IT_KEY2;
	key.cnt = angle;
	key.angles = '0 360 0' * random();
	key.event_damage = kh_Key_Damage;
	key.takedamage = DAMAGE_YES;
	key.modelindex = kh_key_dropped;
	key.model = "key";
	key.kh_dropperteam = 0;
	key.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_PLAYERCLIP | DPCONTENTS_BOTCLIP;
	setsize(key, KH_KEY_MIN, KH_KEY_MAX);
	key.colormod = Team_ColorRGB(initial_owner.team) * KH_KEY_BRIGHTNESS;
	key.reset = key_reset;

	switch(initial_owner.team)
	{
		case NUM_TEAM_1:
			key.netname = "^1red key";
			break;
		case NUM_TEAM_2:
			key.netname = "^4blue key";
			break;
		case NUM_TEAM_3:
			key.netname = "^3yellow key";
			break;
		case NUM_TEAM_4:
			key.netname = "^6pink key";
			break;
		default:
			key.netname = "NETGIER key";
			break;
	}

	// link into key list
	key.kh_worldkeynext = kh_worldkeylist;
	kh_worldkeylist = key;

	Send_Notification(NOTIF_ONE, initial_owner, MSG_CENTER, APP_TEAM_NUM_4(initial_owner.team, CENTER_KEYHUNT_START_));

	WaypointSprite_Spawn("key-dropped", 0, 0, key, '0 0 1' * KH_KEY_WP_ZSHIFT, world, key.team, key, waypointsprite_attachedforcarrier, FALSE, RADARICON_FLAG, '0 1 1');
	key.waypointsprite_attachedforcarrier.waypointsprite_visible_for_player = kh_Key_waypointsprite_visible_for_player;

	kh_Key_AssignTo(key, initial_owner);
}

// -1 when no team completely owns all keys yet
float kh_Key_AllOwnedByWhichTeam()  // constantly called. check to see if all the keys are owned by the same team
{
	entity key;
	float teem;
	float keys;

	teem = -1;
	keys = kh_teams;
	FOR_EACH_KH_KEY(key)
	{
		if(!key.owner)
			return -1;
		if(teem == -1)
			teem = key.team;
		else if(teem != key.team)
			return -1;
		--keys;
	}
	if(keys != 0)
		return -1;
	return teem;
}

void kh_Key_DropOne(entity key)
{
	// prevent collecting this one for some time
	entity player;
	player = key.owner;

	key.kh_droptime = time;
	key.enemy = player;

	kh_Scores_Event(player, key, "dropkey", 0, 0);
	PlayerScore_Add(player, SP_KH_LOSSES, 1);
	Send_Notification(NOTIF_ALL, world, MSG_INFO, APP_TEAM_ENT_4(key, INFO_KEYHUNT_DROP_), player.netname);
	
	kh_Key_AssignTo(key, world);
	makevectors(player.v_angle);
	key.velocity = W_CalculateProjectileVelocity(player.velocity, autocvar_g_balance_keyhunt_throwvelocity * v_forward, FALSE);
	key.pusher = world;
	key.pushltime = time + autocvar_g_balance_keyhunt_protecttime;
	key.kh_dropperteam = key.team;

	sound(player, CH_TRIGGER, kh_sound_drop, VOL_BASE, ATTEN_NORM);
}

void kh_Key_DropAll(entity player, float suicide) // runs whenever a player dies
{
	entity key;
	entity mypusher;
	if(player.kh_next)
	{
		mypusher = world;
		if(player.pusher)
			if(time < player.pushltime)
				mypusher = player.pusher;
		while((key = player.kh_next))
		{
			kh_Scores_Event(player, key, "losekey", 0, 0);
			PlayerScore_Add(player, SP_KH_LOSSES, 1);
			Send_Notification(NOTIF_ALL, world, MSG_INFO, APP_TEAM_ENT_4(key, INFO_KEYHUNT_LOST_), player.netname);
			kh_Key_AssignTo(key, world);
			makevectors('-1 0 0' * (45 + 45 * random()) + '0 360 0' * random());
			key.velocity = W_CalculateProjectileVelocity(player.velocity, autocvar_g_balance_keyhunt_dropvelocity * v_forward, FALSE);
			key.pusher = mypusher;
			key.pushltime = time + autocvar_g_balance_keyhunt_protecttime;
			if(suicide)
				key.kh_dropperteam = player.team;
		}
		sound(player, CH_TRIGGER, kh_sound_drop, VOL_BASE, ATTEN_NORM);
	}
}

float kh_CheckPlayers(float num)
{
	if(num < kh_teams)
	{
		float t_team = kh_Team_ByID(num);
		float players = 0;
		entity tmp_player;
		FOR_EACH_PLAYER(tmp_player)
			if(tmp_player.deadflag == DEAD_NO)
				if(!tmp_player.BUTTON_CHAT)
					if(tmp_player.team == t_team)
						++players;
		
		if not(players) { return t_team; }
	}
	return 0;
}

void kh_WaitForPlayers()  // delay start of the round until enough players are present
{
	if(time < game_starttime)
	{
		kh_Controller_SetThink(game_starttime - time + 0.1, kh_WaitForPlayers);
		return;
	}

	float p1 = kh_CheckPlayers(0), p2 = kh_CheckPlayers(1), p3 = kh_CheckPlayers(2), p4 = kh_CheckPlayers(3);
	if not(p1 || p2 || p3 || p4)
	{
		Send_Notification(NOTIF_ALL, world, MSG_CENTER, CENTER_KEYHUNT_ROUNDSTART, autocvar_g_balance_keyhunt_delay_round);
		kh_Controller_SetThink(autocvar_g_balance_keyhunt_delay_round, kh_StartRound);
	}
	else
	{
		Send_Notification(NOTIF_ALL, world, MSG_CENTER, CENTER_KEYHUNT_WAIT, p1, p2, p3, p4);
		kh_Controller_SetThink(1, kh_WaitForPlayers);
	}
}

void kh_EnableTrackingDevice()  // runs after each round
{
	Kill_Notification(NOTIF_ALL, world, MSG_CENTER_CPID, CPID_KEYHUNT);
	Kill_Notification(NOTIF_ALL, world, MSG_CENTER_CPID, CPID_KEYHUNT_OTHER);

	kh_tracking_enabled = TRUE;
}

void kh_StartRound()  // runs at the start of each round
{
	float i, players, teem;
	entity player;

	if(time < game_starttime)
	{
		kh_Controller_SetThink(game_starttime - time + 0.1, kh_WaitForPlayers);
		return;
	}

	float p1 = kh_CheckPlayers(0), p2 = kh_CheckPlayers(1), p3 = kh_CheckPlayers(2), p4 = kh_CheckPlayers(3);
	if(p1 || p2 || p3 || p4)
	{
		kh_Controller_SetThink(1, kh_WaitForPlayers);
		Send_Notification(NOTIF_ALL, world, MSG_CENTER, CENTER_KEYHUNT_WAIT, p1, p2, p3, p4);
		return;
	}
	
	Kill_Notification(NOTIF_ALL, world, MSG_CENTER_CPID, CPID_KEYHUNT);
	Kill_Notification(NOTIF_ALL, world, MSG_CENTER_CPID, CPID_KEYHUNT_OTHER);

	for(i = 0; i < kh_teams; ++i)
	{
		teem = kh_Team_ByID(i);
		players = 0;
		entity my_player = world;
		FOR_EACH_PLAYER(player)
			if(player.deadflag == DEAD_NO)
				if(!player.BUTTON_CHAT)
					if(player.team == teem)
					{
						++players;
						if(random() * players <= 1)
							my_player = player;
					}
		kh_Key_Spawn(my_player, 360 * i / kh_teams, i);
	}

	kh_tracking_enabled = FALSE;
	Send_Notification(NOTIF_ALL, world, MSG_CENTER, CENTER_KEYHUNT_SCAN, autocvar_g_balance_keyhunt_delay_tracking);
	kh_Controller_SetThink(autocvar_g_balance_keyhunt_delay_tracking, kh_EnableTrackingDevice);
}

float kh_HandleFrags(entity attacker, entity targ, float f)  // adds to the player score
{
	if(attacker == targ)
		return f;

	if(targ.kh_next)
	{
		if(attacker.team == targ.team)
		{
			entity k;
			float nk;
			nk = 0;
			for(k = targ.kh_next; k != world; k = k.kh_next)
				++nk;
			kh_Scores_Event(attacker, targ.kh_next, "carrierfrag", -nk * autocvar_g_balance_keyhunt_score_collect, 0);
		}
		else
		{
			kh_Scores_Event(attacker, targ.kh_next, "carrierfrag", autocvar_g_balance_keyhunt_score_carrierfrag-1, 0);
			PlayerScore_Add(attacker, SP_KH_KCKILLS, 1);
			// the frag gets added later
		}
	}

	return f;
}

void kh_Initialize()  // sets up th KH environment
{
	precache_sound(kh_sound_capture);
	precache_sound(kh_sound_destroy);
	precache_sound(kh_sound_drop);
	precache_sound(kh_sound_collect);
	precache_sound(kh_sound_alarm);  // the new siren

#ifdef KH_PLAYER_USE_CARRIEDMODEL
	precache_model("models/keyhunt/key-carried.md3");
#endif
	precache_model("models/keyhunt/key.md3");

	// setup variables
	kh_teams = autocvar_g_keyhunt_teams_override;
	if(kh_teams < 2)
		kh_teams = autocvar_g_keyhunt_teams;
	kh_teams = bound(2, kh_teams, 4);

	// make a KH entity for controlling the game
	kh_controller = spawn();
	kh_controller.think = kh_Controller_Think;
	kh_Controller_SetThink(0, kh_WaitForPlayers);

	setmodel(kh_controller, "models/keyhunt/key.md3");
	kh_key_dropped = kh_controller.modelindex;
	/*
	dprint(vtos(kh_controller.mins));
	dprint(vtos(kh_controller.maxs));
	dprint("\n");
	*/
#ifdef KH_PLAYER_USE_CARRIEDMODEL
	setmodel(kh_controller, "models/keyhunt/key-carried.md3");
	kh_key_carried = kh_controller.modelindex;
#else
	kh_key_carried = kh_key_dropped;
#endif

	kh_controller.model = "";
	kh_controller.modelindex = 0;

	addstat(STAT_KH_KEYS, AS_INT, kh_state);

	ScoreRules_kh(kh_teams);
}

void kh_finalize()
{
	// to be called before intermission
	kh_FinishRound();
	remove(kh_controller);
	kh_controller = world;
}

// register this as a mutator

MUTATOR_HOOKFUNCTION(kh_Key_DropAll)
{
	kh_Key_DropAll(self, TRUE);
	return 0;
}

MUTATOR_HOOKFUNCTION(kh_PlayerDies)
{
	if(self == other)
		kh_Key_DropAll(self, TRUE);
	else if(IS_PLAYER(other))
		kh_Key_DropAll(self, FALSE);
	else
		kh_Key_DropAll(self, TRUE);
	return 0;
}

MUTATOR_HOOKFUNCTION(kh_GiveFragsForKill)
{
	frag_score = kh_HandleFrags(frag_attacker, frag_target, frag_score);
	return 0;
}

MUTATOR_HOOKFUNCTION(kh_finalize)
{
	kh_finalize();
	return 0;
}

MUTATOR_HOOKFUNCTION(kh_GetTeamCount)
{
	ret_float = kh_teams;
	return 0;
}

MUTATOR_HOOKFUNCTION(kh_SpectateCopy)
{
	self.kh_state = other.kh_state;
	return 0;
}

MUTATOR_HOOKFUNCTION(kh_PlayerUseKey)
{
	if(MUTATOR_RETURNVALUE == 0)
	{
		entity k;
		k = self.kh_next;
		if(k)
		{
			kh_Key_DropOne(k);
			return 1;
		}
	}
	return 0;
}

MUTATOR_DEFINITION(gamemode_keyhunt)
{
	MUTATOR_HOOK(MakePlayerObserver, kh_Key_DropAll, CBC_ORDER_ANY);
	MUTATOR_HOOK(ClientDisconnect, kh_Key_DropAll, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerDies, kh_PlayerDies, CBC_ORDER_ANY);
	MUTATOR_HOOK(GiveFragsForKill, kh_GiveFragsForKill, CBC_ORDER_FIRST);
	MUTATOR_HOOK(MatchEnd, kh_finalize, CBC_ORDER_ANY);
	MUTATOR_HOOK(GetTeamCount, kh_GetTeamCount, CBC_ORDER_EXCLUSIVE);
	MUTATOR_HOOK(SpectateCopy, kh_SpectateCopy, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerUseKey, kh_PlayerUseKey, CBC_ORDER_ANY);

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
