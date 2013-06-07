#define MAX_CHECKPOINTS 255

void spawnfunc_target_checkpoint();

.float race_penalty;
.float race_penalty_accumulator;
.string race_penalty_reason;
.float race_checkpoint; // player: next checkpoint that has to be reached
.float race_laptime;
.entity race_lastpenalty;

.entity sprite;

float race_checkpoint_records[MAX_CHECKPOINTS];
string race_checkpoint_recordholders[MAX_CHECKPOINTS];
float race_checkpoint_lasttimes[MAX_CHECKPOINTS];
float race_checkpoint_lastlaps[MAX_CHECKPOINTS];
entity race_checkpoint_lastplayers[MAX_CHECKPOINTS];

float race_highest_checkpoint;
float race_timed_checkpoint;

float defrag_ents;
float defragcpexists;

float race_NextCheckpoint(float f)
{
	if(f >= race_highest_checkpoint)
		return 0;
	else
		return f + 1;
}

float race_PreviousCheckpoint(float f)
{
	if(f == -1)
		return 0;
	else if(f == 0)
		return race_highest_checkpoint;
	else
		return f - 1;
}

// encode as:
//   0 = common start/finish
// 254 = start
// 255 = finish
float race_CheckpointNetworkID(float f)
{
	if(race_timed_checkpoint)
	{
		if(f == 0)
			return 254; // start
		else if(f == race_timed_checkpoint)
			return 255; // finish
	}
	return f;
}

void race_SendNextCheckpoint(entity e, float spec) // qualifying only
{
	float recordtime;
	string recordholder;
	float cp;

	if(!e.race_laptime)
		return;

	cp = e.race_checkpoint;
	recordtime = race_checkpoint_records[cp];
	recordholder = race_checkpoint_recordholders[cp];
	if(recordholder == e.netname)
		recordholder = "";

	if(!spec)
		msg_entity = e;
	WRITESPECTATABLE_MSG_ONE({
		WriteByte(MSG_ONE, SVC_TEMPENTITY);
		WriteByte(MSG_ONE, TE_CSQC_RACE);
		if(spec)
		{
			WriteByte(MSG_ONE, RACE_NET_CHECKPOINT_NEXT_SPEC_QUALIFYING);
			//WriteCoord(MSG_ONE, e.race_laptime - e.race_penalty_accumulator);
			WriteCoord(MSG_ONE, time - e.race_movetime - e.race_penalty_accumulator);
		}
		else
			WriteByte(MSG_ONE, RACE_NET_CHECKPOINT_NEXT_QUALIFYING);
		WriteByte(MSG_ONE, race_CheckpointNetworkID(cp)); // checkpoint the player will be at next
		WriteInt24_t(MSG_ONE, recordtime);
		WriteString(MSG_ONE, recordholder);
	});
}

void race_InitSpectator()
{
	if(g_race_qualifying)
		if(msg_entity.enemy.race_laptime)
			race_SendNextCheckpoint(msg_entity.enemy, 1);
}

void race_send_recordtime(float msg)
{
	// send the server best time
	WriteByte(msg, SVC_TEMPENTITY);
	WriteByte(msg, TE_CSQC_RACE);
	WriteByte(msg, RACE_NET_SERVER_RECORD);
	WriteInt24_t(msg, race_readTime(GetMapname(), 1));
}

void race_SendRankings(float pos, float prevpos, float del, float msg)
{
	WriteByte(msg, SVC_TEMPENTITY);
	WriteByte(msg, TE_CSQC_RACE);
	WriteByte(msg, RACE_NET_SERVER_RANKINGS);
	WriteShort(msg, pos);
	WriteShort(msg, prevpos);
	WriteShort(msg, del);
	WriteString(msg, race_readName(GetMapname(), pos));
	WriteInt24_t(msg, race_readTime(GetMapname(), pos));
}

void race_SendStatus(float id, entity e)
{
	float msg;
	if (id == 0)
		msg = MSG_ONE;
	else
		msg = MSG_ALL;
	msg_entity = e;
	WRITESPECTATABLE_MSG_ONE_VARNAME(dummy3, {
		WriteByte(msg, SVC_TEMPENTITY);
		WriteByte(msg, TE_CSQC_RACE);
		WriteByte(msg, RACE_NET_SERVER_STATUS);
		WriteShort(msg, id);
		WriteString(msg, e.netname);
	});
}

void race_setTime(string map, float t, string myuid, string mynetname, entity e) { // netname only used TEMPORARILY for printing
	float newpos, player_prevpos;
	newpos = race_readPos(map, t);

	float i;
	player_prevpos = 0;
	for(i = 1; i <= RANKINGS_CNT; ++i)
	{
		if(race_readUID(map, i) == myuid)
			player_prevpos = i;
	}

	float oldrec;
	string oldrec_holder;
	if (player_prevpos && (player_prevpos < newpos || !newpos))
	{
		oldrec = race_readTime(GetMapname(), player_prevpos);
		race_SendStatus(0, e); // "fail"
		Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_RACE_FAIL_RANKED, mynetname, player_prevpos, t, oldrec);
		return;
	} else if (!newpos) { // no ranking, time worse than the worst ranked
		oldrec = race_readTime(GetMapname(), RANKINGS_CNT);
		race_SendStatus(0, e); // "fail"
		Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_RACE_FAIL_UNRANKED, mynetname, RANKINGS_CNT, t, oldrec);
		return;
	}

	// if we didn't hit a return yet, we have a new record!

	// if the player does not have a UID we can unfortunately not store the record, as the rankings system relies on UIDs
	if(myuid == "")
	{
		Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_RACE_NEW_MISSING_UID, mynetname, t);
		return;
	}

	oldrec = race_readTime(GetMapname(), newpos);
	oldrec_holder = race_readName(GetMapname(), newpos);
	
	// store new ranking
	race_writeTime(GetMapname(), t, myuid);

	if (newpos == 1) {
		write_recordmarker(e, time - TIME_DECODE(t), TIME_DECODE(t));
		race_send_recordtime(MSG_ALL);
	}

	race_SendRankings(newpos, player_prevpos, 0, MSG_ALL);
	if(rankings_reply)
		strunzone(rankings_reply);
	rankings_reply = strzone(getrankings());
	
	if(newpos == player_prevpos)
	{
		Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_RACE_NEW_IMPROVED, mynetname, newpos, t, oldrec);
		if(newpos == 1) { race_SendStatus(3, e); } // "new server record"
		else { race_SendStatus(1, e); } // "new time"
	}
	else if(oldrec == 0)
	{
		Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_RACE_NEW_SET, mynetname, newpos, t);
		if(newpos == 1) { race_SendStatus(3, e); } // "new server record"
		else { race_SendStatus(2, e); } // "new rank"
	}
	else
	{
		Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_RACE_NEW_BROKEN, mynetname, oldrec_holder, newpos, t, oldrec);
		if(newpos == 1) { race_SendStatus(3, e); } // "new server record"
		else { race_SendStatus(2, e); } // "new rank"
	}
}

void race_deleteTime(string map, float pos) {
	string rr;
	if(g_cts)
		rr = CTS_RECORD;
	else
		rr = RACE_RECORD;

	float i;
	for (i = pos; i <= RANKINGS_CNT; ++i) {
		if (i == RANKINGS_CNT) {
			db_put(ServerProgsDB, strcat(map, rr, "time", ftos(i)), string_null);
			db_put(ServerProgsDB, strcat(map, rr, "crypto_idfp", ftos(i)), string_null);
		}
		else {
			db_put(ServerProgsDB, strcat(map, rr, "time", ftos(i)), ftos(race_readTime(GetMapname(), i+1)));
			db_put(ServerProgsDB, strcat(map, rr, "crypto_idfp", ftos(i)), race_readUID(GetMapname(), i+1));
		}
	}

	race_SendRankings(pos, 0, 1, MSG_ALL);
	if(pos == 1)
		race_send_recordtime(MSG_ALL);

	if(rankings_reply)
		strunzone(rankings_reply);
	rankings_reply = strzone(getrankings());
}

void race_SendTime(entity e, float cp, float t, float tvalid)
{
	float snew, l;
	entity p;

	if(g_race_qualifying)
		t += e.race_penalty_accumulator;

	t = TIME_ENCODE(t); // make integer
	// adding just 0.4 so it rounds down in the .5 case (matching the timer display)

	if(tvalid)
	if(cp == race_timed_checkpoint) // finish line
	if not(e.race_completed)
	{
		float s;
		if(g_race_qualifying)
		{
			s = PlayerScore_Add(e, SP_RACE_FASTEST, 0);
			if(!s || t < s)
				PlayerScore_Add(e, SP_RACE_FASTEST, t - s);
		}
		else
		{
			s = PlayerScore_Add(e, SP_RACE_FASTEST, 0);
			if(!s || t < s)
				PlayerScore_Add(e, SP_RACE_FASTEST, t - s);

			s = PlayerScore_Add(e, SP_RACE_TIME, 0);
			snew = TIME_ENCODE(time - game_starttime);
			PlayerScore_Add(e, SP_RACE_TIME, snew - s);
			l = PlayerTeamScore_Add(e, SP_RACE_LAPS, ST_RACE_LAPS, 1);

			if(autocvar_fraglimit)
				if(l >= autocvar_fraglimit)
					race_StartCompleting();

			if(race_completing)
			{
				e.race_completed = 1;
				MAKE_INDEPENDENT_PLAYER(e);
				Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_RACE_FINISHED, e.netname);
				ClientData_Touch(e);
			}
		}
	}

	float recordtime;
	string recordholder;
	if(g_race_qualifying)
	{
		if(tvalid)
		{
			recordtime = race_checkpoint_records[cp];
			recordholder = strcat1(race_checkpoint_recordholders[cp]); // make a tempstring copy, as we'll possibly strunzone it!
			if(recordholder == e.netname)
				recordholder = "";

			if(t != 0) {
				if(cp == race_timed_checkpoint)
				{
					race_setTime(GetMapname(), t, e.crypto_idfp, e.netname, e);
					if(g_cts && autocvar_g_cts_finish_kill_delay)
					{
						CTS_ClientKill(e);
					}
				}
				if(t < recordtime || recordtime == 0)
				{
					race_checkpoint_records[cp] = t;
					if(race_checkpoint_recordholders[cp])
						strunzone(race_checkpoint_recordholders[cp]);
					race_checkpoint_recordholders[cp] = strzone(e.netname);
					if(g_race_qualifying)
					{
						FOR_EACH_REALPLAYER(p)
							if(p.race_checkpoint == cp)
								race_SendNextCheckpoint(p, 0);
					}
				}
			}
		}
		else
		{
			// dummies
			t = 0;
			recordtime = 0;
			recordholder = "";
		}

		msg_entity = e;
		if(g_race_qualifying)
		{
			WRITESPECTATABLE_MSG_ONE_VARNAME(dummy1, {
				WriteByte(MSG_ONE, SVC_TEMPENTITY);
				WriteByte(MSG_ONE, TE_CSQC_RACE);
				WriteByte(MSG_ONE, RACE_NET_CHECKPOINT_HIT_QUALIFYING);
				WriteByte(MSG_ONE, race_CheckpointNetworkID(cp)); // checkpoint the player now is at
				WriteInt24_t(MSG_ONE, t); // time to that intermediate
				WriteInt24_t(MSG_ONE, recordtime); // previously best time
				WriteString(MSG_ONE, recordholder); // record holder
			});
		}
	}
	else // RACE! Not Qualifying
	{
		float lself, lother, othtime;
		entity oth;
		oth = race_checkpoint_lastplayers[cp];
		if(oth)
		{
			lself = PlayerScore_Add(e, SP_RACE_LAPS, 0);
			lother = race_checkpoint_lastlaps[cp];
			othtime = race_checkpoint_lasttimes[cp];
		}
		else
			lself = lother = othtime = 0;

		msg_entity = e;
		WRITESPECTATABLE_MSG_ONE_VARNAME(dummy2, {
			WriteByte(MSG_ONE, SVC_TEMPENTITY);
			WriteByte(MSG_ONE, TE_CSQC_RACE);
			WriteByte(MSG_ONE, RACE_NET_CHECKPOINT_HIT_RACE);
			WriteByte(MSG_ONE, race_CheckpointNetworkID(cp)); // checkpoint the player now is at
			if(e == oth)
			{
				WriteInt24_t(MSG_ONE, 0);
				WriteByte(MSG_ONE, 0);
				WriteString(MSG_ONE, "");
			}
			else
			{
				WriteInt24_t(MSG_ONE, TIME_ENCODE(time - race_checkpoint_lasttimes[cp]));
				WriteByte(MSG_ONE, lself - lother);
				WriteString(MSG_ONE, oth.netname); // record holder
			}
		});

		race_checkpoint_lastplayers[cp] = e;
		race_checkpoint_lasttimes[cp] = time;
		race_checkpoint_lastlaps[cp] = lself;

		msg_entity = oth;
		WRITESPECTATABLE_MSG_ONE_VARNAME(dummy3, {
			WriteByte(MSG_ONE, SVC_TEMPENTITY);
			WriteByte(MSG_ONE, TE_CSQC_RACE);
			WriteByte(MSG_ONE, RACE_NET_CHECKPOINT_HIT_RACE_BY_OPPONENT);
			WriteByte(MSG_ONE, race_CheckpointNetworkID(cp)); // checkpoint the player now is at
			if(e == oth)
			{
				WriteInt24_t(MSG_ONE, 0);
				WriteByte(MSG_ONE, 0);
				WriteString(MSG_ONE, "");
			}
			else
			{
				WriteInt24_t(MSG_ONE, TIME_ENCODE(time - othtime));
				WriteByte(MSG_ONE, lother - lself);
				WriteString(MSG_ONE, e.netname); // record holder
			}
		});
	}
}

void race_ClearTime(entity e)
{
	e.race_checkpoint = 0;
	e.race_laptime = 0;
	e.race_movetime = e.race_movetime_frac = e.race_movetime_count = 0;
	e.race_penalty_accumulator = 0;
	e.race_lastpenalty = world;

	msg_entity = e;
	WRITESPECTATABLE_MSG_ONE({
		WriteByte(MSG_ONE, SVC_TEMPENTITY);
		WriteByte(MSG_ONE, TE_CSQC_RACE);
		WriteByte(MSG_ONE, RACE_NET_CHECKPOINT_CLEAR); // next
	});
}

void dumpsurface(entity e)
{
	float n, si, ni;
	vector norm, vec;
	print("Surfaces of ", etos(e), ":\n");

	print("TEST = ", ftos(getsurfacenearpoint(e, '0 0 0')), "\n");

	for(si = 0; ; ++si)
	{
		n = getsurfacenumpoints(e, si);
		if(n <= 0)
			break;
		print("  Surface ", ftos(si), ":\n");
		norm = getsurfacenormal(e, si);
		print("    Normal = ", vtos(norm), "\n");
		for(ni = 0; ni < n; ++ni)
		{
			vec = getsurfacepoint(e, si, ni);
			print("    Point ", ftos(ni), " = ", vtos(vec), " (", ftos(norm * vec), ")\n");
		}
	}
}

void checkpoint_passed()
{
	string oldmsg;
	entity cp;

	if(other.classname == "porto")
	{
		// do not allow portalling through checkpoints
		trace_plane_normal = normalize(-1 * other.velocity);
		self = other;
		W_Porto_Fail(0);
		return;
	}

	/*
	 * Trigger targets
	 */
	if not((self.spawnflags & 2) && (IS_PLAYER(other)))
	{
		activator = other;
		oldmsg = self.message;
		self.message = "";
		SUB_UseTargets();
		self.message = oldmsg;
	}

	if not(IS_PLAYER(other))
		return;

	/*
	 * Remove unauthorized equipment
	 */
	Portal_ClearAll(other);

	other.porto_forbidden = 2; // decreased by 1 each StartFrame

	if(defrag_ents) {
		if(self.race_checkpoint == -2) 
		{
			self.race_checkpoint = other.race_checkpoint;
		}

		float largest_cp_id = 0;
		float cp_amount = 0;
		for(cp = world; (cp = find(cp, classname, "target_checkpoint"));) {
			cp_amount += 1;
			if(cp.race_checkpoint > largest_cp_id) // update the finish id if someone hit a new checkpoint
			{
				largest_cp_id = cp.race_checkpoint;
				for(cp = world; (cp = find(cp, classname, "target_stopTimer"));)
					cp.race_checkpoint = largest_cp_id + 1; // finish line
				race_highest_checkpoint = largest_cp_id + 1;
				race_timed_checkpoint = largest_cp_id + 1;

				for(cp = world; (cp = find(cp, classname, "target_checkpoint"));) {
					if(cp.race_checkpoint == -2) // set defragcpexists to -1 so that the cp id file will be rewritten when someone finishes
						defragcpexists = -1;
				}	
			}
		}
		if(cp_amount == 0) {
			for(cp = world; (cp = find(cp, classname, "target_stopTimer"));)
				cp.race_checkpoint = 1;
			race_highest_checkpoint = 1;
			race_timed_checkpoint = 1;
		}
	}

	if((other.race_checkpoint == -1 && self.race_checkpoint == 0) || (other.race_checkpoint == self.race_checkpoint))
	{
		if(self.race_penalty)
		{
			if(other.race_lastpenalty != self)
			{
				other.race_lastpenalty = self;
				race_ImposePenaltyTime(other, self.race_penalty, self.race_penalty_reason);
			}
		}

		if(other.race_penalty)
			return;

		/*
		 * Trigger targets
		 */
		if(self.spawnflags & 2)
		{
			activator = other;
			oldmsg = self.message;
			self.message = "";
			SUB_UseTargets();
			self.message = oldmsg;
		}

		if(other.race_respawn_checkpoint != self.race_checkpoint || !other.race_started)
			other.race_respawn_spotref = self; // this is not a spot but a CP, but spawnpoint selection will deal with that
		other.race_respawn_checkpoint = self.race_checkpoint;
		other.race_checkpoint = race_NextCheckpoint(self.race_checkpoint);
		other.race_started = 1;

		race_SendTime(other, self.race_checkpoint, other.race_movetime, !!other.race_laptime);

		if(!self.race_checkpoint) // start line
		{
			other.race_laptime = time;
			other.race_movetime = other.race_movetime_frac = other.race_movetime_count = 0;
			other.race_penalty_accumulator = 0;
			other.race_lastpenalty = world;
		}

		if(g_race_qualifying)
			race_SendNextCheckpoint(other, 0);

		if(defrag_ents && defragcpexists < 0 && self.classname == "target_stopTimer")
		{
			float fh;
			defragcpexists = fh = fopen(strcat("maps/", GetMapname(), ".defragcp"), FILE_WRITE);
			if(fh >= 0)
			{
				for(cp = world; (cp = find(cp, classname, "target_checkpoint"));)
				fputs(fh, strcat(cp.targetname, " ", ftos(cp.race_checkpoint), "\n"));
			}
			fclose(fh);
		}
	}
	else if(other.race_checkpoint == race_NextCheckpoint(self.race_checkpoint))
	{
		// ignored
	}
	else
	{
		if(self.spawnflags & 4)
			Damage (other, self, self, 10000, DEATH_HURTTRIGGER, other.origin, '0 0 0');
	}
}

void checkpoint_touch()
{
	EXACTTRIGGER_TOUCH;
	checkpoint_passed();
}

void checkpoint_use()
{
	if(other.classname == "info_player_deathmatch") // a spawn, a spawn
		return;

	other = activator;
	checkpoint_passed();
}

float race_waypointsprite_visible_for_player(entity e)
{
	if(e.race_checkpoint == -1 || self.owner.race_checkpoint == -2)
		return TRUE;
	else if(e.race_checkpoint == self.owner.race_checkpoint)
		return TRUE;
	else
		return FALSE;
}

float have_verified;
void trigger_race_checkpoint_verify()
{
	entity oldself, cp;
	float i, p;
	float qual;

	if(have_verified)
		return;
	have_verified = 1;
	
	qual = g_race_qualifying;

	oldself = self;
	self = spawn();
	self.classname = "player";

	if(g_race)
	{
		for(i = 0; i <= race_highest_checkpoint; ++i)
		{
			self.race_checkpoint = race_NextCheckpoint(i);

			// race only (middle of the race)
			g_race_qualifying = 0;
			self.race_place = 0;
			if(!Spawn_FilterOutBadSpots(findchain(classname, "info_player_deathmatch"), 0, FALSE))
				error(strcat("Checkpoint ", ftos(i), " misses a spawnpoint with race_place==", ftos(self.race_place), " (used for respawning in race) - bailing out"));

			if(i == 0)
			{
				// qualifying only
				g_race_qualifying = 1;
				self.race_place = race_lowest_place_spawn;
				if(!Spawn_FilterOutBadSpots(findchain(classname, "info_player_deathmatch"), 0, FALSE))
					error(strcat("Checkpoint ", ftos(i), " misses a spawnpoint with race_place==", ftos(self.race_place), " (used for qualifying) - bailing out"));
				
				// race only (initial spawn)
				g_race_qualifying = 0;
				for(p = 1; p <= race_highest_place_spawn; ++p)
				{
					self.race_place = p;
					if(!Spawn_FilterOutBadSpots(findchain(classname, "info_player_deathmatch"), 0, FALSE))
						error(strcat("Checkpoint ", ftos(i), " misses a spawnpoint with race_place==", ftos(self.race_place), " (used for initially spawning in race) - bailing out"));
				}
			}
		}
	}
	else if(!defrag_ents)
	{
		// qualifying only
		self.race_checkpoint = race_NextCheckpoint(0);
		g_race_qualifying = 1;
		self.race_place = race_lowest_place_spawn;
		if(!Spawn_FilterOutBadSpots(findchain(classname, "info_player_deathmatch"), 0, FALSE))
			error(strcat("Checkpoint 0 misses a spawnpoint with race_place==", ftos(self.race_place), " (used for qualifying) - bailing out"));
	}
	else
	{
		self.race_checkpoint = race_NextCheckpoint(0);
		g_race_qualifying = 1;
		self.race_place = 0; // there's only one spawn on defrag maps
 
		// check if a defragcp file already exists, then read it and apply the checkpoint order
		float fh;
		float len;
		string l;

		defragcpexists = fh = fopen(strcat("maps/", GetMapname(), ".defragcp"), FILE_READ);
		if(fh >= 0)
		{
			while((l = fgets(fh)))
			{
				len = tokenize_console(l);
				if(len != 2) {
					defragcpexists = -1; // something's wrong in the defrag cp file, set defragcpexists to -1 so that it will be rewritten when someone finishes
					continue;
				}
				for(cp = world; (cp = find(cp, classname, "target_checkpoint"));)
					if(argv(0) == cp.targetname)
						cp.race_checkpoint = stof(argv(1));
			}
			fclose(fh);
		}
	}

	g_race_qualifying = qual;

	if(race_timed_checkpoint) {
		if(defrag_ents) {
			for(cp = world; (cp = find(cp, classname, "target_startTimer"));)
				WaypointSprite_UpdateSprites(cp.sprite, "race-start", "", "");
			for(cp = world; (cp = find(cp, classname, "target_stopTimer"));)
				WaypointSprite_UpdateSprites(cp.sprite, "race-finish", "", "");

			for(cp = world; (cp = find(cp, classname, "target_checkpoint"));) {
				if(cp.race_checkpoint == -2) // something's wrong with the defrag cp file or it has not been written yet, set defragcpexists to -1 so that it will be rewritten when someone finishes
					defragcpexists = -1;
			}

			if(defragcpexists != -1){
				float largest_cp_id = 0;
				for(cp = world; (cp = find(cp, classname, "target_checkpoint"));)
					if(cp.race_checkpoint > largest_cp_id)
						largest_cp_id = cp.race_checkpoint;
				for(cp = world; (cp = find(cp, classname, "target_stopTimer"));)
					cp.race_checkpoint = largest_cp_id + 1; // finish line
				race_highest_checkpoint = largest_cp_id + 1;
				race_timed_checkpoint = largest_cp_id + 1;
			} else {
				for(cp = world; (cp = find(cp, classname, "target_stopTimer"));)
					cp.race_checkpoint = 255; // finish line
				race_highest_checkpoint = 255;
				race_timed_checkpoint = 255;
			}
		}
		else {
			for(cp = world; (cp = find(cp, classname, "trigger_race_checkpoint")); )
				if(cp.sprite)
				{
					if(cp.race_checkpoint == 0)
						WaypointSprite_UpdateSprites(cp.sprite, "race-start", "", "");
					else if(cp.race_checkpoint == race_timed_checkpoint)
						WaypointSprite_UpdateSprites(cp.sprite, "race-finish", "", "");
				}
		}
	}

	if(defrag_ents) {
		entity trigger, targ;
		for(trigger = world; (trigger = find(trigger, classname, "trigger_multiple")); )
			for(targ = world; (targ = find(targ, targetname, trigger.target)); )
				if (targ.classname == "target_checkpoint" || targ.classname == "target_startTimer" || targ.classname == "target_stopTimer") {
					trigger.wait = 0;
					trigger.delay = 0;
					targ.wait = 0;
					targ.delay = 0;

                    // These just make the game crash on some maps with oddly shaped triggers. 
                    // (on the other hand they used to fix the case when two players ran through a checkpoint at once, 
                    // and often one of them just passed through without being registered. Hope it's fixed  in a better way now.
                    // (happened on item triggers too)
                    //
					//targ.wait = -2;
					//targ.delay = 0;

					//setsize(targ, trigger.mins, trigger.maxs);
					//setorigin(targ, trigger.origin);
					//remove(trigger);
				}
	}
	remove(self);
	self = oldself;
}

vector trigger_race_checkpoint_spawn_evalfunc(entity player, entity spot, vector current)
{
	if(g_race_qualifying)
	{
		// spawn at first
		if(self.race_checkpoint != 0)
			return '-1 0 0';
		if(spot.race_place != race_lowest_place_spawn)
			return '-1 0 0';
	}
	else
	{
		if(self.race_checkpoint != player.race_respawn_checkpoint)
			return '-1 0 0';
		// try reusing the previous spawn
		if(self == player.race_respawn_spotref || spot == player.race_respawn_spotref)
			current_x += SPAWN_PRIO_RACE_PREVIOUS_SPAWN;
		if(self.race_checkpoint == 0)
		{
			float pl;
			pl = player.race_place;
			if(pl > race_highest_place_spawn)
				pl = 0;
			if(pl == 0 && !player.race_started)
				pl = race_highest_place_spawn; // use last place if he has not even touched finish yet
			if(spot.race_place != pl)
				return '-1 0 0';
		}
	}
	return current;
}

void spawnfunc_trigger_race_checkpoint()
{
	vector o;
	if(!g_race && !g_cts)
	{
		remove(self);
		return;
	}

	EXACTTRIGGER_INIT;

	self.use = checkpoint_use;
	if not(self.spawnflags & 1)
		self.touch = checkpoint_touch;

	o = (self.absmin + self.absmax) * 0.5;
	tracebox(o, PL_MIN, PL_MAX, o - '0 0 1' * (o_z - self.absmin_z), MOVE_NORMAL, self);
	waypoint_spawnforitem_force(self, trace_endpos);
	self.nearestwaypointtimeout = time + 1000000000;

	if(self.message == "")
		self.message = "went backwards";
	if (self.message2 == "")
		self.message2 = "was pushed backwards by";
	if (self.race_penalty_reason == "")
		self.race_penalty_reason = "missing a checkpoint";
	
	self.race_checkpoint = self.cnt;

	if(self.race_checkpoint > race_highest_checkpoint)
	{
		race_highest_checkpoint = self.race_checkpoint;
		if(self.spawnflags & 8)
			race_timed_checkpoint = self.race_checkpoint;
		else
			race_timed_checkpoint = 0;
	}

	if(!self.race_penalty)
	{
		if(self.race_checkpoint)
			WaypointSprite_SpawnFixed("race-checkpoint", o, self, sprite, RADARICON_NONE, '1 0.5 0');
		else
			WaypointSprite_SpawnFixed("race-start-finish", o, self, sprite, RADARICON_NONE, '1 0.5 0');
	}

	self.sprite.waypointsprite_visible_for_player = race_waypointsprite_visible_for_player;
	self.spawn_evalfunc = trigger_race_checkpoint_spawn_evalfunc;

	InitializeEntity(self, trigger_race_checkpoint_verify, INITPRIO_FINDTARGET);
}

void spawnfunc_target_checkpoint() // defrag entity
{
	vector o;
	if(!g_race && !g_cts)
	{
		remove(self);
		return;
	}
	defrag_ents = 1;

	EXACTTRIGGER_INIT;

	self.use = checkpoint_use;
	if not(self.spawnflags & 1)
		self.touch = checkpoint_touch;

	o = (self.absmin + self.absmax) * 0.5;
	tracebox(o, PL_MIN, PL_MAX, o - '0 0 1' * (o_z - self.absmin_z), MOVE_NORMAL, self);
	waypoint_spawnforitem_force(self, trace_endpos);
	self.nearestwaypointtimeout = time + 1000000000;

	if(self.message == "")
		self.message = "went backwards";
	if (self.message2 == "")
		self.message2 = "was pushed backwards by";
	if (self.race_penalty_reason == "")
		self.race_penalty_reason = "missing a checkpoint";

	if(self.classname == "target_startTimer")
		self.race_checkpoint = 0;
	else
		self.race_checkpoint = -2;

	race_timed_checkpoint = 1;

	if(self.race_checkpoint == 0)
		WaypointSprite_SpawnFixed("race-start", o, self, sprite, RADARICON_NONE, '1 0.5 0');
	else
		WaypointSprite_SpawnFixed("race-checkpoint", o, self, sprite, RADARICON_NONE, '1 0.5 0');

	self.sprite.waypointsprite_visible_for_player = race_waypointsprite_visible_for_player;

	InitializeEntity(self, trigger_race_checkpoint_verify, INITPRIO_FINDTARGET);
}

void spawnfunc_target_startTimer() { spawnfunc_target_checkpoint(); }
void spawnfunc_target_stopTimer() { spawnfunc_target_checkpoint(); }

void race_AbandonRaceCheck(entity p)
{
	if(race_completing && !p.race_completed)
	{
		p.race_completed = 1;
		MAKE_INDEPENDENT_PLAYER(p);
		Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_RACE_ABANDONED, p.netname);
		ClientData_Touch(p);
	}
}

void race_StartCompleting()
{
	entity p;
	race_completing = 1;
	FOR_EACH_PLAYER(p)
		if(p.deadflag != DEAD_NO)
			race_AbandonRaceCheck(p);
}

void race_PreparePlayer()
{
	race_ClearTime(self);
	self.race_place = 0;
	self.race_started = 0;
	self.race_respawn_checkpoint = 0;
	self.race_respawn_spotref = world;
}

void race_RetractPlayer()
{
	if(!g_race && !g_cts)
		return;
	if(self.race_respawn_checkpoint == 0 || self.race_respawn_checkpoint == race_timed_checkpoint)
		race_ClearTime(self);
	self.race_checkpoint = self.race_respawn_checkpoint;
}

void race_PreDie()
{
	if(!g_race && !g_cts)
		return;

	race_AbandonRaceCheck(self);
}

void race_PreSpawn()
{
	if(!g_race && !g_cts)
		return;
	if(self.killcount == -666 /* initial spawn */ || g_race_qualifying) // spawn
		race_PreparePlayer();
	else // respawn
		race_RetractPlayer();

	race_AbandonRaceCheck(self);
}

void race_PostSpawn(entity spot)
{
	if(!g_race && !g_cts)
		return;

	if(spot.target == "")
		// Emergency: this wasn't a real spawnpoint. Can this ever happen?
		race_PreparePlayer();

	// if we need to respawn, do it right
	self.race_respawn_checkpoint = self.race_checkpoint;
	self.race_respawn_spotref = spot;

	self.race_place = 0;
}

void race_PreSpawnObserver()
{
	if(!g_race && !g_cts)
		return;
	race_PreparePlayer();
	self.race_checkpoint = -1;
}

void spawnfunc_info_player_race (void)
{
	if(!g_race && !g_cts)
	{
		remove(self);
		return;
	}
	++race_spawns;
	spawnfunc_info_player_deathmatch();

	if(self.race_place > race_highest_place_spawn)
		race_highest_place_spawn = self.race_place;
	if(self.race_place < race_lowest_place_spawn)
		race_lowest_place_spawn = self.race_place;
}

void race_ClearRecords()
{
	float i;
	entity e;

	for(i = 0; i < MAX_CHECKPOINTS; ++i)
	{
		race_checkpoint_records[i] = 0;
		if(race_checkpoint_recordholders[i])
			strunzone(race_checkpoint_recordholders[i]);
		race_checkpoint_recordholders[i] = string_null;
	}

	e = self;
	FOR_EACH_CLIENT(self)
	{
		float p;
		p = self.race_place;
		race_PreparePlayer();
		self.race_place = p;
	}
	self = e;
}

void race_ReadyRestart()
{
	float s;

	Score_NicePrint(world);

	race_ClearRecords();
	PlayerScore_Sort(race_place, 0, 1, 0);

	entity e;
	FOR_EACH_CLIENT(e)
	{
		if(e.race_place)
		{
			s = PlayerScore_Add(e, SP_RACE_FASTEST, 0);
			if(!s)
				e.race_place = 0;
		}
		print(e.netname, " = ", ftos(e.race_place), "\n");
	}

	if(g_race_qualifying == 2)
	{
		g_race_qualifying = 0;
		independent_players = 0;
		cvar_set("fraglimit", ftos(race_fraglimit));
		cvar_set("leadlimit", ftos(race_leadlimit));
		cvar_set("timelimit", ftos(race_timelimit));
		ScoreRules_race();
	}
}

void race_ImposePenaltyTime(entity pl, float penalty, string reason)
{
	if(g_race_qualifying)
	{
		pl.race_penalty_accumulator += penalty;
		msg_entity = pl;
		WRITESPECTATABLE_MSG_ONE({
			WriteByte(MSG_ONE, SVC_TEMPENTITY);
			WriteByte(MSG_ONE, TE_CSQC_RACE);
			WriteByte(MSG_ONE, RACE_NET_PENALTY_QUALIFYING);
			WriteShort(MSG_ONE, TIME_ENCODE(penalty));
			WriteString(MSG_ONE, reason);
		});
	}
	else
	{
		pl.race_penalty = time + penalty;
		msg_entity = pl;
		WRITESPECTATABLE_MSG_ONE_VARNAME(dummy, {
			WriteByte(MSG_ONE, SVC_TEMPENTITY);
			WriteByte(MSG_ONE, TE_CSQC_RACE);
			WriteByte(MSG_ONE, RACE_NET_PENALTY_RACE);
			WriteShort(MSG_ONE, TIME_ENCODE(penalty));
			WriteString(MSG_ONE, reason);
		});
	}
}

void penalty_touch()
{
	EXACTTRIGGER_TOUCH;
	if(other.race_lastpenalty != self)
	{
		other.race_lastpenalty = self;
		race_ImposePenaltyTime(other, self.race_penalty, self.race_penalty_reason);
	}
}

void penalty_use()
{
	race_ImposePenaltyTime(activator, self.race_penalty, self.race_penalty_reason);
}

void spawnfunc_trigger_race_penalty()
{
	EXACTTRIGGER_INIT;

	self.use = penalty_use;
	if not(self.spawnflags & 1)
		self.touch = penalty_touch;

	if (self.race_penalty_reason == "")
		self.race_penalty_reason = "missing a checkpoint";
	if (!self.race_penalty)
		self.race_penalty = 5;
}

float race_GetFractionalLapCount(entity e)
{
	// interesting metrics (idea by KrimZon) to maybe sort players in the
	// scoreboard, immediately updates when overtaking
	//
	// requires the track to be built so you never get farther away from the
	// next checkpoint, though, and current Xonotic race maps are not built that
	// way
	//
	// also, this code is slow and would need optimization (i.e. "next CP"
	// links on CP entities)

	float l;
	l = PlayerScore_Add(e, SP_RACE_LAPS, 0);
	if(e.race_completed)
		return l; // not fractional
	
	vector o0, o1;
	float bestfraction, fraction;
	entity lastcp, cp0, cp1;
	float nextcpindex, lastcpindex;

	nextcpindex = max(e.race_checkpoint, 0);
	lastcpindex = e.race_respawn_checkpoint;
	lastcp = e.race_respawn_spotref;

	if(nextcpindex == lastcpindex)
		return l; // finish
	
	bestfraction = 1;
	for(cp0 = world; (cp0 = find(cp0, classname, "trigger_race_checkpoint")); )
	{
		if(cp0.race_checkpoint != lastcpindex)
			continue;
		if(lastcp)
			if(cp0 != lastcp)
				continue;
		o0 = (cp0.absmin + cp0.absmax) * 0.5;
		for(cp1 = world; (cp1 = find(cp1, classname, "trigger_race_checkpoint")); )
		{
			if(cp1.race_checkpoint != nextcpindex)
				continue;
			o1 = (cp1.absmin + cp1.absmax) * 0.5;
			if(o0 == o1)
				continue;
			fraction = bound(0.0001, vlen(e.origin - o1) / vlen(o0 - o1), 1);
			if(fraction < bestfraction)
				bestfraction = fraction;
		}
	}

	// we are at CP "nextcpindex - bestfraction"
	// race_timed_checkpoint == 4: then nextcp==4 means 0.9999x, nextcp==0 means 0.0000x
	// race_timed_checkpoint == 0: then nextcp==0 means 0.9999x
	float c, nc;
	nc = race_highest_checkpoint + 1;
	c = (mod(nextcpindex - race_timed_checkpoint + nc + nc - 1, nc) + 1) - bestfraction;

	return l + c / nc;
}
