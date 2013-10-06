void race_send_recordtime(float msg);
void race_SendRankings(float pos, float prevpos, float del, float msg);

void send_CSQC_teamnagger() {
	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_CSQC_TEAMNAGGER);
}

float ClientData_Send(entity to, float sf)
{
	if(to != self.owner)
	{
		error("wtf");
		return FALSE;
	}

	entity e;

	e = to;
	if(IS_SPEC(to))
		e = to.enemy;

	sf = 0;

	if(e.race_completed)
		sf |= 1; // forced scoreboard
	if(to.spectatee_status)
		sf |= 2; // spectator ent number follows
	if(e.zoomstate)
		sf |= 4; // zoomed
	if(e.porto_v_angle_held)
		sf |= 8; // angles held

	WriteByte(MSG_ENTITY, ENT_CLIENT_CLIENTDATA);
	WriteByte(MSG_ENTITY, sf);

	if(sf & 2)
		WriteByte(MSG_ENTITY, to.spectatee_status);

	if(sf & 8)
	{
		WriteAngle(MSG_ENTITY, e.v_angle_x);
		WriteAngle(MSG_ENTITY, e.v_angle_y);
	}

	return TRUE;
}

void ClientData_Attach()
{
	Net_LinkEntity(self.clientdata = spawn(), FALSE, 0, ClientData_Send);
	self.clientdata.drawonlytoclient = self;
	self.clientdata.owner = self;
}

void ClientData_Detach()
{
	remove(self.clientdata);
	self.clientdata = world;
}

void ClientData_Touch(entity e)
{
	e.clientdata.SendFlags = 1;

	// make it spectatable
	entity e2;
	FOR_EACH_REALCLIENT(e2)
	{
		if(e2 != e)
			if(IS_SPEC(e2))
				if(e2.enemy == e)
					e2.clientdata.SendFlags = 1;
	}
}

.string netname_previous;


/*
=============
CheckPlayerModel

Checks if the argument string can be a valid playermodel.
Returns a valid one in doubt.
=============
*/
string FallbackPlayerModel;
string CheckPlayerModel(string plyermodel) {
	if(FallbackPlayerModel != cvar_defstring("_cl_playermodel"))
	{
		// note: we cannot summon Don Strunzone here, some player may
		// still have the model string set. In case anyone manages how
		// to change a cvar default, we'll have a small leak here.
		FallbackPlayerModel = strzone(cvar_defstring("_cl_playermodel"));
	}
	// only in right path
	if( substring(plyermodel,0,14) != "models/player/")
		return FallbackPlayerModel;
	// only good file extensions
	if(substring(plyermodel,-4,4) != ".zym")
	if(substring(plyermodel,-4,4) != ".dpm")
	if(substring(plyermodel,-4,4) != ".iqm")
	if(substring(plyermodel,-4,4) != ".md3")
	if(substring(plyermodel,-4,4) != ".psk")
		return FallbackPlayerModel;
	// forbid the LOD models
	if(substring(plyermodel, -9,5) == "_lod1")
		return FallbackPlayerModel;
	if(substring(plyermodel, -9,5) == "_lod2")
		return FallbackPlayerModel;
	if(plyermodel != strtolower(plyermodel))
		return FallbackPlayerModel;
	// also, restrict to server models
	if(autocvar_sv_servermodelsonly)
	{
		if(!fexists(plyermodel))
			return FallbackPlayerModel;
	}
	return plyermodel;
}

void setplayermodel(entity e, string modelname)
{
	precache_model(modelname);
	setmodel(e, modelname);
	player_setupanimsformodel();
	UpdatePlayerSounds();
}

/*
=============
PutObserverInServer

putting a client as observer in the server
=============
*/
void FixPlayermodel();
void UpdateSpectators(entity is_spec, entity is_player);
void PutObserverInServer (void)
{
	entity spot;
    self.hud = HUD_NORMAL;
	race_PreSpawnObserver();

	spot = SelectSpawnPoint (TRUE);
	if(!spot)
		error("No spawnpoints for observers?!?\n");
	RemoveGrapplingHook(self); // Wazat's Grappling Hook

	if(IS_REAL_CLIENT(self))
	{
		msg_entity = self;
		WriteByte(MSG_ONE, SVC_SETVIEW);
		WriteEntity(MSG_ONE, self);
	}
	
	UpdateSpectators(self, self); // don't update spectators or spectatees

	if((g_race && g_race_qualifying) || g_cts)
	{
		if(PlayerScore_Add(self, SP_RACE_FASTEST, 0))
			self.frags = FRAGS_LMS_LOSER;
		else
			self.frags = FRAGS_SPECTATOR;
	}
	else
		self.frags = FRAGS_SPECTATOR;

	MUTATOR_CALLHOOK(MakePlayerObserver);

	Portal_ClearAll(self);
	
	Unfreeze(self);
	
	if(self.alivetime)
	{
		if(!warmup_stage)
			PlayerStats_Event(self, PLAYERSTATS_ALIVETIME, time - self.alivetime);
		self.alivetime = 0;
	}

	if(self.vehicle)
		vehicles_exit(VHEF_RELESE);	    

	WaypointSprite_PlayerDead();

	if not(g_ca)  // don't reset teams when moving a ca player to the spectators
		self.team = -1;  // move this as it is needed to log the player spectating in eventlog

	if(self.killcount != -666)
	{
		Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_QUIT_SPECTATE, self.netname);

		if(self.just_joined == FALSE) {
			LogTeamchange(self.playerid, -1, 4);
		} else
			self.just_joined = FALSE;
	}

	PlayerScore_Clear(self); // clear scores when needed

	accuracy_resend(self);

	self.spectatortime = time;
	
	self.classname = "observer";
	self.iscreature = FALSE;
	self.teleportable = TELEPORT_SIMPLE;
	self.damagedbycontents = FALSE;
	self.health = -666;
	self.takedamage = DAMAGE_NO;
	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_FLY_WORLDONLY; // user preference is controlled by playerprethink
	self.flags = FL_CLIENT | FL_NOTARGET;
	self.armorvalue = 666;
	self.effects = 0;
	self.armorvalue = autocvar_g_balance_armor_start;
	self.pauserotarmor_finished = 0;
	self.pauserothealth_finished = 0;
	self.pauseregen_finished = 0;
	self.damageforcescale = 0;
	self.death_time = 0;
	self.respawn_flags = 0;
	self.respawn_time = 0;
	self.stat_respawn_time = 0;
	self.alpha = 0;
	self.scale = 0;
	self.fade_time = 0;
	self.pain_frame = 0;
	self.pain_finished = 0;
	self.strength_finished = 0;
	self.invincible_finished = 0;
	self.superweapons_finished = 0;
	self.pushltime = 0;
	self.istypefrag = 0;
	self.think = func_null;
	self.nextthink = 0;
	self.hook_time = 0;
	self.deadflag = DEAD_NO;
	self.angles = spot.angles;
	self.angles_z = 0;
	self.fixangle = TRUE;
	self.crouch = FALSE;

	setorigin (self, (spot.origin + PL_VIEW_OFS)); // offset it so that the spectator spawns higher off the ground, looks better this way
	self.prevorigin = self.origin;
	self.items = 0;
	self.weapons = '0 0 0';
	self.model = "";
	FixPlayermodel();
	setmodel(self, "null");
	self.drawonlytoclient = self;

	setsize (self, PL_CROUCH_MIN, PL_CROUCH_MAX); // give the spectator some space between walls for MOVETYPE_FLY_WORLDONLY
	self.view_ofs = '0 0 0'; // so that your view doesn't go into the ceiling with MOVETYPE_FLY_WORLDONLY, previously "PL_VIEW_OFS"

	self.weapon = 0;
	self.weaponname = "";
	self.switchingweapon = 0;
	self.weaponmodel = "";
	self.weaponentity = world;
	self.exteriorweaponentity = world;
	self.killcount = -666;
	self.velocity = '0 0 0';
	self.avelocity = '0 0 0';
	self.punchangle = '0 0 0';
	self.punchvector = '0 0 0';
	self.oldvelocity = self.velocity;
	self.fire_endtime = -1;
}

.float model_randomizer;
void FixPlayermodel()
{
	string defaultmodel;
	float defaultskin, chmdl, oldskin, n, i;
	vector m1, m2;

	defaultmodel = "";
	defaultskin = 0;
	chmdl = FALSE;

	if(autocvar_sv_defaultcharacter == 1)
	{
		if(teamplay)
		{
			string s;
			s = Team_ColorName_Lower(self.team);
			if(s != "neutral")
			{
				defaultmodel = cvar_string(strcat("sv_defaultplayermodel_", s));
				defaultskin = cvar(strcat("sv_defaultplayerskin_", s));
			}
		}

		if(defaultmodel == "")
		{
			defaultmodel = autocvar_sv_defaultplayermodel;
			defaultskin = autocvar_sv_defaultplayerskin;
		}

		n = tokenize_console(defaultmodel);
		if(n > 0)
		{
			defaultmodel = argv(floor(n * self.model_randomizer));
			// However, do NOT randomize if the player-selected model is in the list.
			for (i = 0; i < n; ++i)
				if ((argv(i) == self.playermodel && defaultskin == stof(self.playerskin)) || argv(i) == strcat(self.playermodel, ":", self.playerskin))
					defaultmodel = argv(i);
		}

		i = strstrofs(defaultmodel, ":", 0);
		if(i >= 0)
		{
			defaultskin = stof(substring(defaultmodel, i+1, -1));
			defaultmodel = substring(defaultmodel, 0, i);
		}
	}
	
	if(autocvar_sv_allow_customplayermodels)
	if not(cvar("g_overkill"))
	{
		// public hax
		if(self.cvar_cl_pony)
		{
			defaultmodel = "models/player/pony.iqm";
			defaultskin = self.cvar_cl_pony_skin;
		}
		if(self.cvar_cl_robot == 1)
			defaultmodel = "models/player/terminusmale.iqm";
		else if(self.cvar_cl_robot == 2)
			defaultmodel = "models/player/ubot.iqm";
			
		// special hax
		if(checkinlist(self.crypto_idfp, autocvar_sv_allow_customplayermodels_idlist))
		{
			if(self.cvar_cl_damnfurries == 1)
				defaultmodel = "models/player/renamon.iqm";
			if(self.cvar_cl_damnfurries == 2)
				defaultmodel = "models/player/yoshi.dpm";
			if(self.cvar_cl_bikini)
			{
				defaultmodel = "models/player/abyss.zym";
				defaultskin = self.cvar_cl_bikini_skin;
			}
			if(self.cvar_cl_sparkle > 2)
				defaultmodel = "models/player/mario.dpm";
		}
	}

	if(defaultmodel != "")
	{
		if (defaultmodel != self.model)
		{
			m1 = self.mins;
			m2 = self.maxs;
			setplayermodel (self, defaultmodel);
			setsize (self, m1, m2);
			chmdl = TRUE;
		}

		oldskin = self.skin;
		self.skin = defaultskin;
	} else {
		if (self.playermodel != self.model || self.playermodel == "")
		{
			self.playermodel = CheckPlayerModel(self.playermodel); // this is never "", so no endless loop
			m1 = self.mins;
			m2 = self.maxs;
			setplayermodel (self, self.playermodel);
			setsize (self, m1, m2);
			chmdl = TRUE;
		}

		oldskin = self.skin;
		self.skin = stof(self.playerskin);
	}

	if(chmdl || oldskin != self.skin) // model or skin has changed
	{
		self.species = player_getspecies(); // update species
		UpdatePlayerSounds(); // update skin sounds
	}

	if(!teamplay)
		if(strlen(autocvar_sv_defaultplayercolors))
			if(self.clientcolors != stof(autocvar_sv_defaultplayercolors))
				setcolor(self, stof(autocvar_sv_defaultplayercolors));
}

void PlayerTouch (void)
{
	if(other == world)
		return;

	if not(IS_PLAYER(other))
		return;
		
	if not(IS_PLAYER(self))
		return;
	
	if(self.deadflag != DEAD_NO)
		return;

	vector vdir = normalize(other.origin - self.origin);
	
	if(vdir_z > autocvar_g_player_crush_headheight) // adjust this to set how sharp from above players need to hit the player to crush them. 
		Damage (self, other, other, autocvar_g_player_crush_damage, DEATH_CRUSH, self.origin, '0 0 0');
}

/*
=============
PutClientInServer

Called when a client spawns in the server
=============
*/
void UpdateSpectators(entity is_spec, entity is_player);
void PutClientInServer (void)
{
	if(IS_BOT_CLIENT(self))
	{
		self.classname = "player";
		self.cvar_cl_robot = 2; // always make bots ubot?
	}
	else if(IS_REAL_CLIENT(self))
	{
		msg_entity = self;
		WriteByte(MSG_ONE, SVC_SETVIEW);
		WriteEntity(MSG_ONE, self);
	}
	
	// reset player keys
	self.itemkeys = 0;

	MUTATOR_CALLHOOK(PutClientInServer);

	if(gameover)
		self.classname = "observer";

	if(IS_PLAYER(self))
	{
		entity spot, oldself;
		float j;

		accuracy_resend(self);

		if(self.team < 0)
			JoinBestTeam(self, FALSE, TRUE);

		race_PreSpawn();

		spot = SelectSpawnPoint (FALSE);
		if(!spot)
		{
			Send_Notification(NOTIF_ONE_ONLY, self, MSG_CENTER, CENTER_JOIN_NOSPAWNS);
			return; // spawn failed
		}

		RemoveGrapplingHook(self); // Wazat's Grappling Hook

		self.classname = "player";
		self.wasplayer = TRUE;
		self.iscreature = TRUE;
		self.teleportable = TELEPORT_NORMAL;
		self.damagedbycontents = TRUE;
		self.movetype = MOVETYPE_WALK;
		self.solid = SOLID_SLIDEBOX;
		self.dphitcontentsmask = DPCONTENTS_BODY | DPCONTENTS_SOLID;
		if(autocvar_g_playerclip_collisions)
			self.dphitcontentsmask |= DPCONTENTS_PLAYERCLIP;
		if(IS_BOT_CLIENT(self) && autocvar_g_botclip_collisions)
			self.dphitcontentsmask |= DPCONTENTS_BOTCLIP;
		self.frags = FRAGS_PLAYER;
		if(INDEPENDENT_PLAYERS)
			MAKE_INDEPENDENT_PLAYER(self);
		self.flags = FL_CLIENT;
		if(autocvar__notarget)
			self.flags |= FL_NOTARGET;
		self.takedamage = DAMAGE_AIM;
		self.effects = 0;
		self.effects |= EF_TELEPORT_BIT | EF_RESTARTANIM_BIT;
		self.air_finished = time + 12;
		self.dmg = 2;
		if(autocvar_g_balance_nex_charge)
		{
			if(autocvar_g_balance_nex_secondary_chargepool)
				self.nex_chargepool_ammo = 1;
			self.nex_charge = autocvar_g_balance_nex_charge_start;
		}

		if(warmup_stage)
		{
			self.ammo_shells = warmup_start_ammo_shells;
			self.ammo_nails = warmup_start_ammo_nails;
			self.ammo_rockets = warmup_start_ammo_rockets;
			self.ammo_cells = warmup_start_ammo_cells;
			self.ammo_fuel = warmup_start_ammo_fuel;
			self.health = warmup_start_health;
			self.armorvalue = warmup_start_armorvalue;
			self.weapons = warmup_start_weapons;
		}
		else
		{
			self.ammo_shells = start_ammo_shells;
			self.ammo_nails = start_ammo_nails;
			self.ammo_rockets = start_ammo_rockets;
			self.ammo_cells = start_ammo_cells;
			self.ammo_fuel = start_ammo_fuel;
			self.health = start_health;
			self.armorvalue = start_armorvalue;
			self.weapons = start_weapons;
		}

		if(self.weapons & WEPSET_SUPERWEAPONS)
			self.superweapons_finished = time + autocvar_g_balance_superweapons_time;
		else
			self.superweapons_finished = 0;

		if(g_weaponarena_random)
		{
			if(g_weaponarena_random_with_laser)
				self.weapons &= ~WEPSET_LASER;
			W_RandomWeapons(self, g_weaponarena_random);
			if(g_weaponarena_random_with_laser)
				self.weapons |= WEPSET_LASER;
		}

		self.items = start_items;

		self.spawnshieldtime = time + autocvar_g_spawnshieldtime;
		self.pauserotarmor_finished = time + autocvar_g_balance_pause_armor_rot_spawn;
		self.pauserothealth_finished = time + autocvar_g_balance_pause_health_rot_spawn;
		self.pauserotfuel_finished = time + autocvar_g_balance_pause_fuel_rot_spawn;
		self.pauseregen_finished = time + autocvar_g_balance_pause_health_regen_spawn;
		//extend the pause of rotting if client was reset at the beginning of the countdown
		if(!autocvar_sv_ready_restart_after_countdown && time < game_starttime) { // TODO why is this cvar NOTted?
			self.spawnshieldtime += game_starttime - time;
			self.pauserotarmor_finished += game_starttime - time;
			self.pauserothealth_finished += game_starttime - time;
			self.pauseregen_finished += game_starttime - time;
		}
		self.damageforcescale = 2;
		self.death_time = 0;
		self.respawn_flags = 0;
		self.respawn_time = 0;
		self.stat_respawn_time = 0;
		self.scale = 0;
		self.fade_time = 0;
		self.pain_frame = 0;
		self.pain_finished = 0;
		self.strength_finished = 0;
		self.invincible_finished = 0;
		self.pushltime = 0;
		// players have no think function
		self.think = func_null;
		self.nextthink = 0;
		self.hook_time = 0;
		self.dmg_team = 0;
		self.ballistics_density = autocvar_g_ballistics_density_player;

		self.metertime = 0;

		self.deadflag = DEAD_NO;

		self.angles = spot.angles;

		self.angles_z = 0; // never spawn tilted even if the spot says to
		self.fixangle = TRUE; // turn this way immediately
		self.velocity = '0 0 0';
		self.avelocity = '0 0 0';
		self.punchangle = '0 0 0';
		self.punchvector = '0 0 0';
		self.oldvelocity = self.velocity;
		self.fire_endtime = -1;

		entity spawnevent = spawn();
		spawnevent.owner = self;
		Net_LinkEntity(spawnevent, FALSE, 0.5, SpawnEvent_Send);

		self.model = "";
		FixPlayermodel();
		self.drawonlytoclient = world;

		self.crouch = FALSE;
		self.view_ofs = PL_VIEW_OFS;
		setsize (self, PL_MIN, PL_MAX);
		self.spawnorigin = spot.origin;
		setorigin (self, spot.origin + '0 0 1' * (1 - self.mins_z - 24));
		// don't reset back to last position, even if new position is stuck in solid
		self.oldorigin = self.origin;
		self.prevorigin = self.origin;
		self.lastrocket = world; // stop rocket guiding, no revenge from the grave!
		self.lastteleporttime = time; // prevent insane speeds due to changing origin
        self.hud = HUD_NORMAL;

		self.event_damage = PlayerDamage;

		self.bot_attack = TRUE;
		self.monster_attack = TRUE;
		
		if(self.cvar_cl_sparkle >= 1 && checkinlist(self.crypto_idfp, autocvar_sv_allow_customplayermodels_idlist))
			self.effects |= EF_STARDUST;
			
		if(self.cvar_cl_sparkle == 2 && checkinlist(self.crypto_idfp, autocvar_sv_allow_customplayermodels_idlist))
			self.colormap = 1039;

		self.statdraintime = time + 5;
		self.BUTTON_ATCK = self.BUTTON_JUMP = self.BUTTON_ATCK2 = 0;

		if(self.killcount == -666) {
			PlayerScore_Clear(self);
			self.killcount = 0;
		}

		CL_SpawnWeaponentity();
		self.alpha = default_player_alpha;
		self.colormod = '1 1 1' * autocvar_g_player_brightness;
		self.exteriorweaponentity.alpha = default_weapon_alpha;

		self.speedrunning = FALSE;

		race_PostSpawn(spot);

		//stuffcmd(self, "chase_active 0");
	 	//stuffcmd(self, "set viewsize $tmpviewsize \n");
	 	
		target_voicescript_clear(self);

		// reset fields the weapons may use
		for (j = WEP_FIRST; j <= WEP_LAST; ++j)
		{
			weapon_action(j, WR_RESETPLAYER);

			// all weapons must be fully loaded when we spawn
			entity e;
			e = get_weaponinfo(j);
			if(e.spawnflags & WEP_FLAG_RELOADABLE) // prevent accessing undefined cvars
				self.(weapon_load[j]) = cvar(strcat("g_balance_", e.netname, "_reload_ammo"));
		}

		oldself = self;
		self = spot;
			activator = oldself;
				string s;
				s = self.target;
				self.target = string_null;
				SUB_UseTargets();
				self.target = s;
			activator = world;
		self = oldself;
		
		Unfreeze(self);

		spawn_spot = spot;
		MUTATOR_CALLHOOK(PlayerSpawn);

		if(autocvar_spawn_debug)
		{
			sprint(self, strcat("spawnpoint origin:  ", vtos(spot.origin), "\n"));
			remove(spot);	// usefull for checking if there are spawnpoints, that let drop through the floor
		}

		self.switchweapon = w_getbestweapon(self);
		self.cnt = -1; // W_LastWeapon will not complain
		self.weapon = 0;
		self.weaponname = "";
		self.switchingweapon = 0;
		
		if(autocvar_g_player_crush)
			self.touch = PlayerTouch;

		if(!warmup_stage)
			if(!self.alivetime)
				self.alivetime = time;

		antilag_clear(self);
	}
	else if(IS_OBSERVER(self))
	{
		PutObserverInServer ();
	}
	
	UpdateSpectators(((IS_PLAYER(self)) ? world : self), ((IS_SPEC(self) || IS_OBSERVER(self)) ? self : world));
}

.float ebouncefactor, ebouncestop; // electro's values
// TODO do we need all these fields, or should we stop autodetecting runtime
// changes and just have a console command to update this?
float ClientInit_SendEntity(entity to, float sf)
{
	WriteByte(MSG_ENTITY, ENT_CLIENT_INIT);
	WriteByte(MSG_ENTITY, g_nexball_meter_period * 32);
	WriteInt24_t(MSG_ENTITY, compressShotOrigin(hook_shotorigin[0]));
	WriteInt24_t(MSG_ENTITY, compressShotOrigin(hook_shotorigin[1]));
	WriteInt24_t(MSG_ENTITY, compressShotOrigin(hook_shotorigin[2]));
	WriteInt24_t(MSG_ENTITY, compressShotOrigin(hook_shotorigin[3]));
	WriteInt24_t(MSG_ENTITY, compressShotOrigin(electro_shotorigin[0]));
	WriteInt24_t(MSG_ENTITY, compressShotOrigin(electro_shotorigin[1]));
	WriteInt24_t(MSG_ENTITY, compressShotOrigin(electro_shotorigin[2]));
	WriteInt24_t(MSG_ENTITY, compressShotOrigin(electro_shotorigin[3]));
	WriteInt24_t(MSG_ENTITY, compressShotOrigin(gauntlet_shotorigin[0]));
	WriteInt24_t(MSG_ENTITY, compressShotOrigin(gauntlet_shotorigin[1]));
	WriteInt24_t(MSG_ENTITY, compressShotOrigin(gauntlet_shotorigin[2]));
	WriteInt24_t(MSG_ENTITY, compressShotOrigin(gauntlet_shotorigin[3]));
	if(sv_foginterval && world.fog != "")
		WriteString(MSG_ENTITY, world.fog);
	else
		WriteString(MSG_ENTITY, "");
	WriteByte(MSG_ENTITY, self.count * 255.0); // g_balance_armor_blockpercent
	WriteCoord(MSG_ENTITY, self.bouncefactor); // g_balance_grenadelauncher_bouncefactor
	WriteCoord(MSG_ENTITY, self.bouncestop); // g_balance_grenadelauncher_bouncestop
	WriteCoord(MSG_ENTITY, self.ebouncefactor); // g_balance_grenadelauncher_bouncefactor
	WriteCoord(MSG_ENTITY, self.ebouncestop); // g_balance_grenadelauncher_bouncestop
	WriteByte(MSG_ENTITY, autocvar_g_balance_nex_secondary); // client has to know if it should zoom or not
	WriteByte(MSG_ENTITY, autocvar_g_balance_rifle_secondary); // client has to know if it should zoom or not
	WriteByte(MSG_ENTITY, serverflags); // client has to know if it should zoom or not
	WriteByte(MSG_ENTITY, autocvar_g_balance_minelayer_limit); // minelayer max mines
	WriteByte(MSG_ENTITY, autocvar_g_balance_hagar_secondary_load_max); // hagar max loadable rockets
	WriteCoord(MSG_ENTITY, autocvar_g_trueaim_minrange);
	WriteByte(MSG_ENTITY, autocvar_g_balance_porto_secondary);
	WriteByte(MSG_ENTITY, self.minsta_refire * 255.0);
	WriteByte(MSG_ENTITY, self.minsta_range * 255.0);
	WriteByte(MSG_ENTITY, sv_showfps);
	return TRUE;
}

void ClientInit_CheckUpdate()
{
	float mrange = ((autocvar_g_balance_minstanex_distance > 0) ? autocvar_g_balance_minstanex_distance : MAX_SHOT_DISTANCE);
	self.nextthink = time;
	if(self.count != autocvar_g_balance_armor_blockpercent)
	{
		self.count = autocvar_g_balance_armor_blockpercent;
		self.SendFlags |= 1;
	}
	if(self.bouncefactor != autocvar_g_balance_grenadelauncher_bouncefactor)
	{
		self.bouncefactor = autocvar_g_balance_grenadelauncher_bouncefactor;
		self.SendFlags |= 1;
	}
	if(self.bouncestop != autocvar_g_balance_grenadelauncher_bouncestop)
	{
		self.bouncestop = autocvar_g_balance_grenadelauncher_bouncestop;
		self.SendFlags |= 1;
	}
	if(self.ebouncefactor != autocvar_g_balance_electro_secondary_bouncefactor)
	{
		self.ebouncefactor = autocvar_g_balance_electro_secondary_bouncefactor;
		self.SendFlags |= 1;
	}
	if(self.ebouncestop != autocvar_g_balance_electro_secondary_bouncestop)
	{
		self.ebouncestop = autocvar_g_balance_electro_secondary_bouncestop;
		self.SendFlags |= 1;
	}
	if(self.minsta_refire != autocvar_g_balance_minstanex_refire)
	{
		self.minsta_refire = autocvar_g_balance_minstanex_refire;
		self.SendFlags |= 1;
	}
	if(self.minsta_range != mrange)
	{
		self.minsta_range = mrange;
		self.SendFlags |= 1;
	}
}

void ClientInit_Spawn()
{
	entity o;
	entity e;
	e = spawn();
	e.classname = "clientinit";
	e.think = ClientInit_CheckUpdate;
	Net_LinkEntity(e, FALSE, 0, ClientInit_SendEntity);

	o = self;
	self = e;
	ClientInit_CheckUpdate();
	self = o;
}

/*
=============
SetNewParms
=============
*/
void SetNewParms (void)
{
	// initialize parms for a new player
	parm1 = -(86400 * 366);
}

/*
=============
SetChangeParms
=============
*/
void SetChangeParms (void)
{
	// save parms for level change
	parm1 = self.parm_idlesince - time;
}

/*
=============
DecodeLevelParms
=============
*/
void DecodeLevelParms (void)
{
	// load parms
	self.parm_idlesince = parm1;
	if(self.parm_idlesince == -(86400 * 366))
		self.parm_idlesince = time;

	// whatever happens, allow 60 seconds of idling directly after connect for map loading
	self.parm_idlesince = max(self.parm_idlesince, time - sv_maxidle + 60);
}

/*
=============
ClientKill

Called when a client types 'kill' in the console
=============
*/

.float clientkill_nexttime;
void ClientKill_Now_TeamChange()
{
	if(self.killindicator_teamchange == -1)
	{
		JoinBestTeam( self, FALSE, TRUE );
	}
	else if(self.killindicator_teamchange == -2)
	{
		if(blockSpectators)
			Send_Notification(NOTIF_ONE_ONLY, self, MSG_INFO, INFO_SPECTATE_WARNING, autocvar_g_maxplayers_spectator_blocktime);
		PutObserverInServer();
	}
	else
		SV_ChangeTeam(self.killindicator_teamchange - 1);
	self.killindicator_teamchange = 0;
}

void ClientKill_Now()
{
	if(self.vehicle)
	{
	    vehicles_exit(VHEF_RELESE);
	    if(!self.killindicator_teamchange)
	    {
            self.vehicle_health = -1;
            Damage(self, self, self, 1 , DEATH_KILL, self.origin, '0 0 0');	        
	    }
	}

	if(self.killindicator && !wasfreed(self.killindicator))
		remove(self.killindicator);

	self.killindicator = world;

	if(self.killindicator_teamchange)
		ClientKill_Now_TeamChange();

	// in any case:
	Damage(self, self, self, 100000, DEATH_KILL, self.origin, '0 0 0');

	// now I am sure the player IS dead
}
void KillIndicator_Think()
{
	if (gameover)
	{
		self.owner.killindicator = world;
		remove(self);
		return;
	}

	if (self.owner.alpha < 0 && !self.owner.vehicle)
	{
		self.owner.killindicator = world;
		remove(self);
		return;
	}

	if(self.cnt <= 0)
	{
		self = self.owner;
		ClientKill_Now(); // no oldself needed
		return;
	}
    else if(g_cts && self.health == 1) // health == 1 means that it's silent
    {
        self.nextthink = time + 1;
        self.cnt -= 1;
    }
	else
	{
		if(self.cnt <= 10)
			setmodel(self, strcat("models/sprites/", ftos(self.cnt), ".spr32"));
		if(IS_REAL_CLIENT(self.owner))
		{
			if(self.cnt <= 10)
				{ Send_Notification(NOTIF_ONE, self.owner, MSG_ANNCE, Announcer_PickNumber(CNT_KILL, self.cnt)); }
		}
		self.nextthink = time + 1;
		self.cnt -= 1;
	}
}

float clientkilltime;
void ClientKill_TeamChange (float targetteam) // 0 = don't change, -1 = auto, -2 = spec
{
	float killtime;
	float starttime;
	entity e;

	if (gameover)
		return;

	killtime = autocvar_g_balance_kill_delay;

	if(g_race_qualifying || g_cts)
		killtime = 0;

    if(g_cts && self.killindicator && self.killindicator.health == 1) // self.killindicator.health == 1 means that the kill indicator was spawned by CTS_ClientKill
    {
		remove(self.killindicator);
		self.killindicator = world;

        ClientKill_Now(); // allow instant kill in this case
        return;
    }

	self.killindicator_teamchange = targetteam;

    if(!self.killindicator)
	{
		if(self.deadflag == DEAD_NO)
		{
			killtime = max(killtime, self.clientkill_nexttime - time);
			self.clientkill_nexttime = time + killtime + autocvar_g_balance_kill_antispam;
		}

		if(killtime <= 0 || !IS_PLAYER(self) || self.deadflag != DEAD_NO)
		{
			ClientKill_Now();
		}
		else
		{
			starttime = max(time, clientkilltime);

			self.killindicator = spawn();
			self.killindicator.owner = self;
			self.killindicator.scale = 0.5;
			setattachment(self.killindicator, self, "");
			setorigin(self.killindicator, '0 0 52');
			self.killindicator.think = KillIndicator_Think;
			self.killindicator.nextthink = starttime + (self.lip) * 0.05;
			clientkilltime = max(clientkilltime, self.killindicator.nextthink + 0.05);
			self.killindicator.cnt = ceil(killtime);
			self.killindicator.count = bound(0, ceil(killtime), 10);
			//sprint(self, strcat("^1You'll be dead in ", ftos(self.killindicator.cnt), " seconds\n"));

			for(e = world; (e = find(e, classname, "body")) != world; )
			{
				if(e.enemy != self)
					continue;
				e.killindicator = spawn();
				e.killindicator.owner = e;
				e.killindicator.scale = 0.5;
				setattachment(e.killindicator, e, "");
				setorigin(e.killindicator, '0 0 52');
				e.killindicator.think = KillIndicator_Think;
				e.killindicator.nextthink = starttime + (e.lip) * 0.05;
				clientkilltime = max(clientkilltime, e.killindicator.nextthink + 0.05);
				e.killindicator.cnt = ceil(killtime);
			}
			self.lip = 0;
		}
	}
	if(self.killindicator)
	{
		if(targetteam == 0) // just die
		{
			self.killindicator.colormod = '0 0 0';
			if(IS_REAL_CLIENT(self))
			if(self.killindicator.cnt > 0)
				Send_Notification(NOTIF_ONE_ONLY, self, MSG_CENTER, CENTER_TEAMCHANGE_SUICIDE, self.killindicator.cnt);
		}
		else if(targetteam == -1) // auto
		{
			self.killindicator.colormod = '0 1 0';
			if(IS_REAL_CLIENT(self))
			if(self.killindicator.cnt > 0)
				Send_Notification(NOTIF_ONE_ONLY, self, MSG_CENTER, CENTER_TEAMCHANGE_AUTO, self.killindicator.cnt);
		}
		else if(targetteam == -2) // spectate
		{
			self.killindicator.colormod = '0.5 0.5 0.5';
			if(IS_REAL_CLIENT(self))
			if(self.killindicator.cnt > 0)
				Send_Notification(NOTIF_ONE_ONLY, self, MSG_CENTER, CENTER_TEAMCHANGE_SPECTATE, self.killindicator.cnt);
		}
		else
		{
			self.killindicator.colormod = Team_ColorRGB(targetteam);
			if(IS_REAL_CLIENT(self))
			if(self.killindicator.cnt > 0)
				Send_Notification(NOTIF_ONE_ONLY, self, MSG_CENTER, APP_TEAM_NUM_4(targetteam, CENTER_TEAMCHANGE_), self.killindicator.cnt);
		}
	}

}

void ClientKill (void)
{
	if(gameover) return;
	if(self.player_blocked) return;
	if(self.frozen) return;
	
	ClientKill_TeamChange(0);
}

void CTS_ClientKill (entity e) // silent version of ClientKill, used when player finishes a CTS run. Useful to prevent cheating by running back to the start line and starting out with more speed
{
    e.killindicator = spawn();
    e.killindicator.owner = e;
    e.killindicator.think = KillIndicator_Think;
    e.killindicator.nextthink = time + (e.lip) * 0.05;
    e.killindicator.cnt = ceil(autocvar_g_cts_finish_kill_delay);
    e.killindicator.health = 1; // this is used to indicate that it should be silent
    e.lip = 0;
}

void FixClientCvars(entity e)
{
	// send prediction settings to the client
	stuffcmd(e, "\nin_bindmap 0 0\n");
	if(g_race || g_cts)
		stuffcmd(e, "cl_cmd settemp cl_movecliptokeyboard 2\n");
	if(autocvar_g_antilag == 3) // client side hitscan
		stuffcmd(e, "cl_cmd settemp cl_prydoncursor_notrace 0\n");
	if(autocvar_sv_gentle)
		stuffcmd(e, "cl_cmd settemp cl_gentle 1\n");
	/*
	 * we no longer need to stuff this. Remove this comment block if you feel
	 * 2.3 and higher (or was it 2.2.3?) don't need these any more
	stuffcmd(e, strcat("cl_gravity ", ftos(autocvar_sv_gravity), "\n"));
	stuffcmd(e, strcat("cl_movement_accelerate ", ftos(autocvar_sv_accelerate), "\n"));
	stuffcmd(e, strcat("cl_movement_friction ", ftos(autocvar_sv_friction), "\n"));
	stuffcmd(e, strcat("cl_movement_maxspeed ", ftos(autocvar_sv_maxspeed), "\n"));
	stuffcmd(e, strcat("cl_movement_airaccelerate ", ftos(autocvar_sv_airaccelerate), "\n"));
	stuffcmd(e, strcat("cl_movement_maxairspeed ", ftos(autocvar_sv_maxairspeed), "\n"));
	stuffcmd(e, strcat("cl_movement_stopspeed ", ftos(autocvar_sv_stopspeed), "\n"));
	stuffcmd(e, strcat("cl_movement_jumpvelocity ", ftos(autocvar_sv_jumpvelocity), "\n"));
	stuffcmd(e, strcat("cl_movement_stepheight ", ftos(autocvar_sv_stepheight), "\n"));
	stuffcmd(e, strcat("set cl_movement_friction_on_land ", ftos(autocvar_sv_friction_on_land), "\n"));
	stuffcmd(e, strcat("set cl_movement_airaccel_qw ", ftos(autocvar_sv_airaccel_qw), "\n"));
	stuffcmd(e, strcat("set cl_movement_airaccel_sideways_friction ", ftos(autocvar_sv_airaccel_sideways_friction), "\n"));
	stuffcmd(e, "cl_movement_edgefriction 1\n");
	 */
}

float PlayerInIDList(entity p, string idlist)
{
	float n, i;
	string s;

	// NOTE: we do NOT check crypto_keyfp here, an unsigned ID is fine too for this
	if not(p.crypto_idfp)
		return 0;

	// this function allows abbreviated player IDs too!
	n = tokenize_console(idlist);
	for(i = 0; i < n; ++i)
	{
		s = argv(i);
		if(s == substring(p.crypto_idfp, 0, strlen(s)))
			return 1;
	}

	return 0;
}

/*
=============
ClientConnect

Called when a client connects to the server
=============
*/
void DecodeLevelParms (void);
//void dom_player_join_team(entity pl);
void set_dom_state(entity e);
void ClientConnect (void)
{
	float t;

	if(IS_CLIENT(self))
	{
		print("Warning: ClientConnect, but already connected!\n");
		return;
	}

	if(Ban_MaybeEnforceBanOnce(self))
		return;

	DecodeLevelParms();

#ifdef WATERMARK
	Send_Notification(NOTIF_ONE_ONLY, self, MSG_INFO, INFO_WATERMARK, WATERMARK);
#endif

	self.classname = "player_joining";

	self.flags = FL_CLIENT;
	self.version_nagtime = time + 10 + random() * 10;

	if(player_count<0)
	{
		dprint("BUG player count is lower than zero, this cannot happen!\n");
		player_count = 0;
	}

	PlayerScore_Attach(self);
	ClientData_Attach();
	accuracy_init(self);

	bot_clientconnect();

	playerdemo_init();

	anticheat_init();

	race_PreSpawnObserver();

	// identify the right forced team
	if(autocvar_g_campaign)
	{
		if(IS_REAL_CLIENT(self)) // only players, not bots
		{
			switch(autocvar_g_campaign_forceteam)
			{
				case 1: self.team_forced = NUM_TEAM_1; break;
				case 2: self.team_forced = NUM_TEAM_2; break;
				case 3: self.team_forced = NUM_TEAM_3; break;
				case 4: self.team_forced = NUM_TEAM_4; break;
				default: self.team_forced = 0;
			}
		}
	}
	else if(PlayerInIDList(self, autocvar_g_forced_team_red))
		self.team_forced = NUM_TEAM_1;
	else if(PlayerInIDList(self, autocvar_g_forced_team_blue))
		self.team_forced = NUM_TEAM_2;
	else if(PlayerInIDList(self, autocvar_g_forced_team_yellow))
		self.team_forced = NUM_TEAM_3;
	else if(PlayerInIDList(self, autocvar_g_forced_team_pink))
		self.team_forced = NUM_TEAM_4;
	else if(autocvar_g_forced_team_otherwise == "red")
		self.team_forced = NUM_TEAM_1;
	else if(autocvar_g_forced_team_otherwise == "blue")
		self.team_forced = NUM_TEAM_2;
	else if(autocvar_g_forced_team_otherwise == "yellow")
		self.team_forced = NUM_TEAM_3;
	else if(autocvar_g_forced_team_otherwise == "pink")
		self.team_forced = NUM_TEAM_4;
	else if(autocvar_g_forced_team_otherwise == "spectate")
		self.team_forced = -1;
	else if(autocvar_g_forced_team_otherwise == "spectator")
		self.team_forced = -1;
	else
		self.team_forced = 0;

	if(!teamplay)
		if(self.team_forced > 0)
			self.team_forced = 0;

	JoinBestTeam(self, FALSE, FALSE); // if the team number is valid, keep it

	if((autocvar_sv_spectate == 1) || autocvar_g_campaign || self.team_forced < 0) {
		self.classname = "observer";
	} else {
		if(teamplay)
		{
			if(autocvar_g_balance_teams)
			{
				self.classname = "player";
				campaign_bots_may_start = 1;
			}
			else
			{
				self.classname = "observer"; // do it anyway
			}
		}
		else
		{
			self.classname = "player";
			campaign_bots_may_start = 1;
		}
	}

	self.playerid = (playerid_last = playerid_last + 1);

	PlayerStats_AddEvent(sprintf("kills-%d", self.playerid));

    if(IS_BOT_CLIENT(self))
        PlayerStats_AddPlayer(self);

	if(autocvar_sv_eventlog)
		GameLogEcho(strcat(":join:", ftos(self.playerid), ":", ftos(num_for_edict(self)), ":", ((IS_REAL_CLIENT(self)) ? self.netaddress : "bot"), ":", self.netname));

	LogTeamchange(self.playerid, self.team, 1);

	self.just_joined = TRUE;  // stop spamming the eventlog with additional lines when the client connects

	self.netname_previous = strzone(self.netname);

	if(IS_PLAYER(self) && teamplay)
		Send_Notification(NOTIF_ALL, world, MSG_INFO, APP_TEAM_ENT_4(self, INFO_JOIN_CONNECT_TEAM_), self.netname);
	else
		Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_JOIN_CONNECT, self.netname);

	stuffcmd(self, strcat(clientstuff, "\n"));
	stuffcmd(self, "cl_particles_reloadeffects\n"); // TODO do we still need this?

	FixClientCvars(self);

	// spawnfunc_waypoint sprites
	WaypointSprite_InitClient(self);

	// Wazat's grappling hook
	SetGrappleHookBindings();

	// get version info from player
	stuffcmd(self, "cmd clientversion $gameversion\n");

	// get other cvars from player
	GetCvars(0);

	// notify about available teams
	if(teamplay)
	{
		CheckAllowedTeams(self);
		t = 0; if(c1 >= 0) t |= 1; if(c2 >= 0) t |= 2; if(c3 >= 0) t |= 4; if(c4 >= 0) t |= 8;
		stuffcmd(self, strcat("set _teams_available ", ftos(t), "\n"));
	}
	else
		stuffcmd(self, "set _teams_available 0\n");

	attach_entcs();

	bot_relinkplayerlist();

	self.spectatortime = time;
	if(blockSpectators)
	{
		Send_Notification(NOTIF_ONE_ONLY, self, MSG_INFO, INFO_SPECTATE_WARNING, autocvar_g_maxplayers_spectator_blocktime);
	}

	self.jointime = time;
	self.allowed_timeouts = autocvar_sv_timeout_number;

	if(IS_REAL_CLIENT(self))
	{
		if(!autocvar_g_campaign)
		{
			self.motd_actived_time = -1;
			Send_Notification(NOTIF_ONE_ONLY, self, MSG_CENTER, CENTER_MOTD, getwelcomemessage());
		}

		if(autocvar_g_bugrigs || (g_weaponarena_weapons == WEPSET_TUBA))
			stuffcmd(self, "cl_cmd settemp chase_active 1\n");
	}

	if(!sv_foginterval && world.fog != "")
		stuffcmd(self, strcat("\nfog ", world.fog, "\nr_fog_exp2 0\nr_drawfog 1\n"));

	if(autocvar_g_hitplots || strstrofs(strcat(" ", autocvar_g_hitplots_individuals, " "), strcat(" ", self.netaddress, " "), 0) >= 0)
	{
		self.hitplotfh = fopen(strcat("hits-", matchid, "-", self.netaddress, "-", ftos(self.playerid), ".plot"), FILE_WRITE);
		fputs(self.hitplotfh, strcat("#name ", self.netname, "\n"));
	}
	else
		self.hitplotfh = -1;

	if(g_race || g_cts) {
		string rr;
		if(g_cts)
			rr = CTS_RECORD;
		else
			rr = RACE_RECORD;

		msg_entity = self;
		race_send_recordtime(MSG_ONE);
		race_send_speedaward(MSG_ONE);

		speedaward_alltimebest = stof(db_get(ServerProgsDB, strcat(GetMapname(), rr, "speed/speed")));
		speedaward_alltimebest_holder = uid2name(db_get(ServerProgsDB, strcat(GetMapname(), rr, "speed/crypto_idfp")));
		race_send_speedaward_alltimebest(MSG_ONE);

		float i;
		for (i = 1; i <= RANKINGS_CNT; ++i) {
			race_SendRankings(i, 0, 0, MSG_ONE);
		}
	}
	else if(autocvar_sv_teamnagger && !(autocvar_bot_vs_human && (c3==-1 && c4==-1)) && !g_ca) // teamnagger is currently bad for ca
		send_CSQC_teamnagger();

	CheatInitClient();

	CSQCMODEL_AUTOINIT();

	self.model_randomizer = random();

	if(IS_REAL_CLIENT(self))
		sv_notice_join();

	MUTATOR_CALLHOOK(ClientConnect);
}
/*
=============
ClientDisconnect

Called when a client disconnects from the server
=============
*/
.entity chatbubbleentity;
void ReadyCount();
void ClientDisconnect (void)
{
	UpdateSpectators(self, world);

	if(self.vehicle)
	    vehicles_exit(VHEF_RELESE);

	if not(IS_CLIENT(self))
	{
		print("Warning: ClientDisconnect without ClientConnect\n");
		return;
	}
	
	PlayerStats_AddGlobalInfo(self);

	CheatShutdownClient();

	if(self.hitplotfh >= 0)
	{
		fclose(self.hitplotfh);
		self.hitplotfh = -1;
	}

	anticheat_report();
	anticheat_shutdown();

	playerdemo_shutdown();

	bot_clientdisconnect();

	if(self.entcs)
		detach_entcs();

	if(autocvar_sv_eventlog)
		GameLogEcho(strcat(":part:", ftos(self.playerid)));
		
	Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_QUIT_DISCONNECT, self.netname);

	MUTATOR_CALLHOOK(ClientDisconnect);

	Portal_ClearAll(self);
	
	Unfreeze(self);

	RemoveGrapplingHook(self);

	// Here, everything has been done that requires this player to be a client.

	self.flags &= ~FL_CLIENT;

	if (self.chatbubbleentity)
		remove (self.chatbubbleentity);

	if (self.killindicator)
		remove (self.killindicator);

	WaypointSprite_PlayerGone();

	bot_relinkplayerlist();

	accuracy_free(self);
	ClientData_Detach();
	PlayerScore_Detach(self);

	if(self.netname_previous)
		strunzone(self.netname_previous);
	if(self.clientstatus)
		strunzone(self.clientstatus);
	if(self.weaponorder_byimpulse)
		strunzone(self.weaponorder_byimpulse);

	ClearPlayerSounds();

	if(self.personal)
		remove(self.personal);

	self.playerid = 0;
	ReadyCount();

	// free cvars
	GetCvars(-1);
}

.float BUTTON_CHAT;
void ChatBubbleThink()
{
	self.nextthink = time;
	if ((self.owner.alpha < 0) || self.owner.chatbubbleentity != self)
	{
		if(self.owner) // but why can that ever be world?
			self.owner.chatbubbleentity = world;
		remove(self);
		return;
	}
	if ((self.owner.BUTTON_CHAT && !self.owner.deadflag)
#ifdef TETRIS
		|| self.owner.tetris_on
#endif
	)
		self.model = self.mdl;
	else
		self.model = "";
}

void UpdateChatBubble()
{
	if (self.alpha < 0)
		return;
	// spawn a chatbubble entity if needed
	if (!self.chatbubbleentity)
	{
		self.chatbubbleentity = spawn();
		self.chatbubbleentity.owner = self;
		self.chatbubbleentity.exteriormodeltoclient = self;
		self.chatbubbleentity.think = ChatBubbleThink;
		self.chatbubbleentity.nextthink = time;
		setmodel(self.chatbubbleentity, "models/misc/chatbubble.spr"); // precision set below
		//setorigin(self.chatbubbleentity, self.origin + '0 0 15' + self.maxs_z * '0 0 1');
		setorigin(self.chatbubbleentity, '0 0 15' + self.maxs_z * '0 0 1');
		setattachment(self.chatbubbleentity, self, "");  // sticks to moving player better, also conserves bandwidth
		self.chatbubbleentity.mdl = self.chatbubbleentity.model;
		self.chatbubbleentity.model = "";
		self.chatbubbleentity.effects = EF_LOWPRECISION;
	}
}


// LordHavoc: this hack will be removed when proper _pants/_shirt layers are
// added to the model skins
/*void UpdateColorModHack()
{
	float c;
	c = self.clientcolors & 15;
	// LordHavoc: only bothering to support white, green, red, yellow, blue
	     if (!teamplay) self.colormod = '0 0 0';
	else if (c ==  0) self.colormod = '1.00 1.00 1.00';
	else if (c ==  3) self.colormod = '0.10 1.73 0.10';
	else if (c ==  4) self.colormod = '1.73 0.10 0.10';
	else if (c == 12) self.colormod = '1.22 1.22 0.10';
	else if (c == 13) self.colormod = '0.10 0.10 1.73';
	else self.colormod = '1 1 1';
}*/

void respawn(void)
{
	if(self.alpha >= 0 && autocvar_g_respawn_ghosts)
	{
		self.solid = SOLID_NOT;
		self.takedamage = DAMAGE_NO;
		self.movetype = MOVETYPE_FLY;
		self.velocity = '0 0 1' * autocvar_g_respawn_ghosts_speed;
		self.avelocity = randomvec() * autocvar_g_respawn_ghosts_speed * 3 - randomvec() * autocvar_g_respawn_ghosts_speed * 3;
		self.effects |= CSQCMODEL_EF_RESPAWNGHOST;
		pointparticles(particleeffectnum("respawn_ghost"), self.origin, '0 0 0', 1);
		if(autocvar_g_respawn_ghosts_maxtime)
			SUB_SetFade (self, time + autocvar_g_respawn_ghosts_maxtime / 2 + random () * (autocvar_g_respawn_ghosts_maxtime - autocvar_g_respawn_ghosts_maxtime / 2), 1.5);
	}

	CopyBody(1);

	self.effects |= EF_NODRAW; // prevent another CopyBody
	PutClientInServer();
}

void play_countdown(float finished, string samp)
{
	if(IS_REAL_CLIENT(self))
		if(floor(finished - time - frametime) != floor(finished - time))
			if(finished - time < 6)
				sound (self, CH_INFO, samp, VOL_BASE, ATTEN_NORM);
}

void player_powerups (void)
{
	// add a way to see what the items were BEFORE all of these checks for the mutator hook
	olditems = self.items;

	if((self.items & IT_USING_JETPACK) && !self.deadflag)
		self.modelflags |= MF_ROCKET;
	else
		self.modelflags &= ~MF_ROCKET;

	self.effects &= ~(EF_RED | EF_BLUE | EF_ADDITIVE | EF_FULLBRIGHT | EF_FLAME | EF_NODEPTHTEST);

	if((self.alpha < 0 || self.deadflag) && !self.vehicle) // don't apply the flags if the player is gibbed
		return;

	Fire_ApplyDamage(self);
	Fire_ApplyEffect(self);

	if not(g_minstagib)
	{
		if (self.items & IT_STRENGTH)
		{
			play_countdown(self.strength_finished, "misc/poweroff.wav");
			self.effects = self.effects | (EF_BLUE | EF_ADDITIVE | EF_FULLBRIGHT);
			if (time > self.strength_finished)
			{
				self.items = self.items - (self.items & IT_STRENGTH);
				//Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_POWERDOWN_STRENGTH, self.netname);
				Send_Notification(NOTIF_ONE, self, MSG_CENTER, CENTER_POWERDOWN_STRENGTH);
			}
		}
		else
		{
			if (time < self.strength_finished)
			{
				self.items = self.items | IT_STRENGTH;
				Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_POWERUP_STRENGTH, self.netname);
				Send_Notification(NOTIF_ONE, self, MSG_CENTER, CENTER_POWERUP_STRENGTH);
			}
		}
		if (self.items & IT_INVINCIBLE)
		{
			play_countdown(self.invincible_finished, "misc/poweroff.wav");
			self.effects = self.effects | (EF_RED | EF_ADDITIVE | EF_FULLBRIGHT);
			if (time > self.invincible_finished)
			{
				self.items = self.items - (self.items & IT_INVINCIBLE);
				//Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_POWERDOWN_SHIELD, self.netname);
				Send_Notification(NOTIF_ONE, self, MSG_CENTER, CENTER_POWERDOWN_SHIELD);
			}
		}
		else
		{
			if (time < self.invincible_finished)
			{
				self.items = self.items | IT_INVINCIBLE;
				Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_POWERUP_SHIELD, self.netname);
				Send_Notification(NOTIF_ONE, self, MSG_CENTER, CENTER_POWERUP_SHIELD);
			}
		}
		if (self.items & IT_SUPERWEAPON)
		{
			if (!(self.weapons & WEPSET_SUPERWEAPONS))
			{
				self.superweapons_finished = 0;
				self.items = self.items - (self.items & IT_SUPERWEAPON);
				//Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_SUPERWEAPON_LOST, self.netname);
				Send_Notification(NOTIF_ONE, self, MSG_CENTER, CENTER_SUPERWEAPON_LOST);
			}
			else if (self.items & IT_UNLIMITED_SUPERWEAPONS)
			{
				// don't let them run out
			}
			else
			{
				play_countdown(self.superweapons_finished, "misc/poweroff.wav");
				if (time > self.superweapons_finished)
				{
					self.items = self.items - (self.items & IT_SUPERWEAPON);
					self.weapons &= ~WEPSET_SUPERWEAPONS;
					//Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_SUPERWEAPON_BROKEN, self.netname);
					Send_Notification(NOTIF_ONE, self, MSG_CENTER, CENTER_SUPERWEAPON_BROKEN);
				}
			}
		}
		else if(self.weapons & WEPSET_SUPERWEAPONS)
		{
			if (time < self.superweapons_finished || (self.items & IT_UNLIMITED_SUPERWEAPONS))
			{
				self.items = self.items | IT_SUPERWEAPON;
				Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_SUPERWEAPON_PICKUP, self.netname);
				Send_Notification(NOTIF_ONE, self, MSG_CENTER, CENTER_SUPERWEAPON_PICKUP);
			}
			else
			{
				self.superweapons_finished = 0;
				self.weapons &= ~WEPSET_SUPERWEAPONS;
			}
		}
		else
		{
			self.superweapons_finished = 0;
		}
	}
	
	if(autocvar_g_nodepthtestplayers)
		self.effects = self.effects | EF_NODEPTHTEST;

	if(autocvar_g_fullbrightplayers)
		self.effects = self.effects | EF_FULLBRIGHT;

	if (time >= game_starttime)
	if (time < self.spawnshieldtime)
		self.effects = self.effects | (EF_ADDITIVE | EF_FULLBRIGHT);

	MUTATOR_CALLHOOK(PlayerPowerups);
}

float CalcRegen(float current, float stable, float regenfactor, float regenframetime)
{
	if(current > stable)
		return current;
	else if(current > stable - 0.25) // when close enough, "snap"
		return stable;
	else
		return min(stable, current + (stable - current) * regenfactor * regenframetime);
}

float CalcRot(float current, float stable, float rotfactor, float rotframetime)
{
	if(current < stable)
		return current;
	else if(current < stable + 0.25) // when close enough, "snap"
		return stable;
	else
		return max(stable, current + (stable - current) * rotfactor * rotframetime);
}

float CalcRotRegen(float current, float regenstable, float regenfactor, float regenlinear, float regenframetime, float rotstable, float rotfactor, float rotlinear, float rotframetime, float limit)
{
	if(current > rotstable)
	{
		if(rotframetime > 0)
		{
			current = CalcRot(current, rotstable, rotfactor, rotframetime);
			current = max(rotstable, current - rotlinear * rotframetime);
		}
	}
	else if(current < regenstable)
	{
		if(regenframetime > 0)
		{
			current = CalcRegen(current, regenstable, regenfactor, regenframetime);
			current = min(regenstable, current + regenlinear * regenframetime);
		}
	}

	if(current > limit)
		current = limit;

	return current;
}

void player_regen (void)
{
	float minh, mina, minf, maxh, maxa, maxf, limith, limita, limitf, max_mod, regen_mod, rot_mod, limit_mod;
	maxh = autocvar_g_balance_health_rotstable;
	maxa = autocvar_g_balance_armor_rotstable;
	maxf = autocvar_g_balance_fuel_rotstable;
	minh = autocvar_g_balance_health_regenstable;
	mina = autocvar_g_balance_armor_regenstable;
	minf = autocvar_g_balance_fuel_regenstable;
	limith = autocvar_g_balance_health_limit;
	limita = autocvar_g_balance_armor_limit;
	limitf = autocvar_g_balance_fuel_limit;

	max_mod = regen_mod = rot_mod = limit_mod = 1;

	maxh = maxh * max_mod;
	//maxa = maxa * max_mod;
	//maxf = maxf * max_mod;
	minh = minh * max_mod;
	//mina = mina * max_mod;
	//minf = minf * max_mod;
	limith = limith * limit_mod;
	limita = limita * limit_mod;
	//limitf = limitf * limit_mod;

	if(g_ca)
		rot_mod = 0;
	if(g_vip)
	{
		// VIP regens to 200
		if(self.isvip)
		{
			maxh = 200;
			maxa = 200;
			minh = 200;
			mina = 200;
			regen_mod = 0.5; // half regen speed
		}
	}

	if (!g_minstagib && !g_ca && (!g_lms || autocvar_g_lms_regenerate))
	{
		self.armorvalue = CalcRotRegen(self.armorvalue, mina, autocvar_g_balance_armor_regen, autocvar_g_balance_armor_regenlinear, regen_mod * frametime * (time > self.pauseregen_finished), maxa, autocvar_g_balance_armor_rot, autocvar_g_balance_armor_rotlinear, rot_mod * frametime * (time > self.pauserotarmor_finished), limita);
		self.health = CalcRotRegen(self.health, minh, autocvar_g_balance_health_regen, autocvar_g_balance_health_regenlinear, regen_mod * frametime * (time > self.pauseregen_finished), maxh, autocvar_g_balance_health_rot, autocvar_g_balance_health_rotlinear, rot_mod * frametime * (time > self.pauserothealth_finished), limith);
	}
	
	// if player rotted to death...  die!
	if(self.health < 1)
	{
		if(self.vehicle)
			vehicles_exit(VHEF_RELESE);
		self.event_damage(self, self, 1, DEATH_ROT, self.origin, '0 0 0');
	}

	if not(self.items & IT_UNLIMITED_WEAPON_AMMO)
		self.ammo_fuel = CalcRotRegen(self.ammo_fuel, minf, autocvar_g_balance_fuel_regen, autocvar_g_balance_fuel_regenlinear, regen_mod * frametime * (time > self.pauseregen_finished) * ((self.items & IT_FUEL_REGEN) != 0), maxf, autocvar_g_balance_fuel_rot, autocvar_g_balance_fuel_rotlinear, rot_mod * frametime * (time > self.pauserotfuel_finished), limitf);
}

float zoomstate_set;
void SetZoomState(float z)
{
	if(z != self.zoomstate)
	{
		self.zoomstate = z;
		ClientData_Touch(self);
	}
	zoomstate_set = 1;
}

void GetPressedKeys(void) {
	MUTATOR_CALLHOOK(GetPressedKeys);
	if (self.movement_x > 0) // get if movement keys are pressed
	{	// forward key pressed
		self.pressedkeys |= KEY_FORWARD;
		self.pressedkeys &= ~KEY_BACKWARD;
	}
	else if (self.movement_x < 0)
	{	// backward key pressed
		self.pressedkeys |= KEY_BACKWARD;
		self.pressedkeys &= ~KEY_FORWARD;
	}
	else
	{	// no x input
		self.pressedkeys &= ~KEY_FORWARD;
		self.pressedkeys &= ~KEY_BACKWARD;
	}

	if (self.movement_y > 0)
	{	// right key pressed
		self.pressedkeys |= KEY_RIGHT;
		self.pressedkeys &= ~KEY_LEFT;
	}
	else if (self.movement_y < 0)
	{	// left key pressed
		self.pressedkeys |= KEY_LEFT;
		self.pressedkeys &= ~KEY_RIGHT;
	}
	else
	{	// no y input
		self.pressedkeys &= ~KEY_RIGHT;
		self.pressedkeys &= ~KEY_LEFT;
	}

	if (self.BUTTON_JUMP) // get if jump and crouch keys are pressed
		self.pressedkeys |= KEY_JUMP;
	else
		self.pressedkeys &= ~KEY_JUMP;
	if (self.BUTTON_CROUCH)
		self.pressedkeys |= KEY_CROUCH;
	else
		self.pressedkeys &= ~KEY_CROUCH;

	if (self.BUTTON_ATCK)
		self.pressedkeys |= KEY_ATCK;
	else
		self.pressedkeys &= ~KEY_ATCK;
	if (self.BUTTON_ATCK2)
		self.pressedkeys |= KEY_ATCK2;
	else
		self.pressedkeys &= ~KEY_ATCK2;
}

/*
======================
spectate mode routines
======================
*/

void SpectateCopy(entity spectatee) {
	other = spectatee;
	MUTATOR_CALLHOOK(SpectateCopy);
	self.armortype = spectatee.armortype;
	self.armorvalue = spectatee.armorvalue;
	self.ammo_cells = spectatee.ammo_cells;
	self.ammo_shells = spectatee.ammo_shells;
	self.ammo_nails = spectatee.ammo_nails;
	self.ammo_rockets = spectatee.ammo_rockets;
	self.ammo_fuel = spectatee.ammo_fuel;
	self.clip_load = spectatee.clip_load;
	self.clip_size = spectatee.clip_size;
	self.effects = spectatee.effects & EFMASK_CHEAP; // eat performance
	self.health = spectatee.health;
	self.impulse = 0;
	self.items = spectatee.items;
	self.last_pickup = spectatee.last_pickup;
	self.hit_time = spectatee.hit_time;
	self.metertime = spectatee.metertime;
	self.strength_finished = spectatee.strength_finished;
	self.invincible_finished = spectatee.invincible_finished;
	self.pressedkeys = spectatee.pressedkeys;
	self.weapons = spectatee.weapons;
	self.switchweapon = spectatee.switchweapon;
	self.switchingweapon = spectatee.switchingweapon;
	self.weapon = spectatee.weapon;
	self.nex_charge = spectatee.nex_charge;
	self.nex_chargepool_ammo = spectatee.nex_chargepool_ammo;
	self.hagar_load = spectatee.hagar_load;
	self.minelayer_mines = spectatee.minelayer_mines;
	self.punchangle = spectatee.punchangle;
	self.view_ofs = spectatee.view_ofs;
	self.velocity = spectatee.velocity;
	self.dmg_take = spectatee.dmg_take;
	self.dmg_save = spectatee.dmg_save;
	self.dmg_inflictor = spectatee.dmg_inflictor;
	self.v_angle = spectatee.v_angle;
	self.angles = spectatee.v_angle;
	self.frozen = spectatee.frozen;
	self.revive_progress = spectatee.revive_progress;
	if(!self.BUTTON_USE)
		self.fixangle = TRUE;
	setorigin(self, spectatee.origin);
	setsize(self, spectatee.mins, spectatee.maxs);
	SetZoomState(spectatee.zoomstate);
    
    anticheat_spectatecopy(spectatee);
	self.hud = spectatee.hud;
	if(spectatee.vehicle)
    {
        self.fixangle = FALSE;
        //self.velocity = spectatee.vehicle.velocity;
        self.vehicle_health = spectatee.vehicle_health;
        self.vehicle_shield = spectatee.vehicle_shield;
        self.vehicle_energy = spectatee.vehicle_energy;
        self.vehicle_ammo1 = spectatee.vehicle_ammo1;
        self.vehicle_ammo2 = spectatee.vehicle_ammo2;
        self.vehicle_reload1 = spectatee.vehicle_reload1;
        self.vehicle_reload2 = spectatee.vehicle_reload2;

        msg_entity = self;
        
        WriteByte (MSG_ONE, SVC_SETVIEWANGLES);
            WriteAngle(MSG_ONE,  spectatee.v_angle_x);
            WriteAngle(MSG_ONE,  spectatee.v_angle_y);
            WriteAngle(MSG_ONE,  spectatee.v_angle_z);

        //WriteByte (MSG_ONE, SVC_SETVIEW);
        //    WriteEntity(MSG_ONE, self);            
        //makevectors(spectatee.v_angle);
        //setorigin(self, spectatee.origin - v_forward * 400 + v_up * 300);*/    
    }
}

float SpectateUpdate() {
	if(!self.enemy)
	    return 0;		

	if (self == self.enemy)
		return 0;

	if not(IS_PLAYER(self.enemy))
	{
		self.enemy = world;
		return 0;
	}

	SpectateCopy(self.enemy);
	
	//UpdateSpectators(world, world);

	return 1;
}

void UpdateSpectators(entity is_spec, entity is_player)
{
	entity head, spec;
	float specs = 0;
	FOR_EACH_REALCLIENT(head)
	{
		msg_entity = head;
		WriteByte(MSG_ONE, SVC_TEMPENTITY);
		WriteByte(MSG_ONE, TE_CSQC_SPECINFO);
		
		if(IS_PLAYER(head))
			WriteByte(MSG_ONE, head.clientfov);
		else if(head.enemy)
			WriteByte(MSG_ONE, head.enemy.clientfov);
		else
			WriteByte(MSG_ONE, 0);
		
		specs = 0;
		
		FOR_EACH_SPEC(spec) if(spec.enemy == head && is_player != spec && spec != is_player)
			++specs;
	
		if(IS_SPEC(head) || IS_OBSERVER(head) || head == is_spec || !autocvar_sv_showspectators)
		{
			WriteByte(MSG_ONE, 0);
			continue;
		}
		
		WriteByte(MSG_ONE, specs);
		FOR_EACH_SPEC(spec) if(spec.enemy == head && is_player != spec)
			WriteByte(MSG_ONE, num_for_edict(spec));
	}
}

float SpectateSet()
{
	if(!IS_PLAYER(self.enemy))
		return FALSE;
	/*if(self.enemy.vehicle)
	{

		msg_entity = self;
		WriteByte(MSG_ONE, SVC_SETVIEW);
		WriteEntity(MSG_ONE, self.enemy);
		//stuffcmd(self, "set viewsize $tmpviewsize \n");

		self.movetype = MOVETYPE_NONE;
		accuracy_resend(self);
	}
	else
	{*/
		msg_entity = self;
		WriteByte(MSG_ONE, SVC_SETVIEW);
		WriteEntity(MSG_ONE, self.enemy);
		//stuffcmd(self, "set viewsize $tmpviewsize \n");
		self.movetype = MOVETYPE_NONE;
		accuracy_resend(self);

		if(!SpectateUpdate())
			PutObserverInServer();
	//}
	
	return TRUE;
}

float Spectate(entity pl)
{
	if(g_ca && !autocvar_g_ca_spectate_enemies && self.caplayer)
	if(pl.team != self.team)
		return 0;

	self.enemy = pl;
	return SpectateSet();
}

// Returns next available player to spectate if g_ca_spectate_enemies == 0
entity CA_SpectateNext(entity start) {
	if (start.team == self.team) {
		return start;
	}
	
	other = start;
	// continue from current player
	while(other && other.team != self.team) {
		other = find(other, classname, "player");
	}
	
	if (!other) {
		// restart from begining
		other = find(other, classname, "player");
		while(other && other.team != self.team) {
			other = find(other, classname, "player");
		}
	}
	
	return other;
}

float SpectateNext()
{
	other = find(self.enemy, classname, "player");

	if (g_ca && !autocvar_g_ca_spectate_enemies && self.caplayer) {
		// CA and ca players when spectating enemies is forbidden
		other = CA_SpectateNext(other);
	} else {
		// other modes and ca spectators or spectating enemies is allowed
		if (!other)
			other = find(other, classname, "player");
	}

	if (other)
	{
		self.enemy = other;
		UpdateSpectators(world, world);
	}

	return SpectateSet();
}

float SpectatePrev()
{
	// NOTE: chain order is from the highest to the lower entnum (unlike find)
	other = findchain(classname, "player");
	if not(other) // no player
		return FALSE;

	entity first = other;
	// skip players until current spectated player
	if(self.enemy)
	while(other && other != self.enemy)
		other = other.chain;

	if (g_ca && !autocvar_g_ca_spectate_enemies && self.caplayer)
	{
		do { other = other.chain; }
		while(other && other.team != self.team);

		if not(other)
		{
			other = first;
			while(other.team != self.team)
				other = other.chain;
			if(other == self.enemy)
				return TRUE;
		}
	}
	else
	{
		if(other.chain)
			other = other.chain;
		else
			other = first;
	}
	self.enemy = other;
	UpdateSpectators(world, world);
	return SpectateSet();
}

/*
=============
ShowRespawnCountdown()

Update a respawn countdown display.
=============
*/
void ShowRespawnCountdown()
{
	float number;
	if(self.deadflag == DEAD_NO) // just respawned?
		return;
	else
	{
		number = ceil(self.respawn_time - time);
		if(number <= 0)
			return;
		if(number <= self.respawn_countdown)
		{
			self.respawn_countdown = number - 1;
			if(ceil(self.respawn_time - (time + 0.5)) == number) // only say it if it is the same number even in 0.5s; to prevent overlapping sounds
				{ Send_Notification(NOTIF_ONE, self, MSG_ANNCE, Announcer_PickNumber(CNT_RESPAWN, number)); }
		}
	}
}

void LeaveSpectatorMode()
{
	if(self.caplayer)
		return;
	if(nJoinAllowed(self))
	{
		if(!teamplay || autocvar_g_campaign || autocvar_g_balance_teams || (self.wasplayer && autocvar_g_changeteam_banned) || self.team_forced > 0)
		{
			self.classname = "player";

			if(autocvar_g_campaign || autocvar_g_balance_teams)
				{ JoinBestTeam(self, FALSE, TRUE); }

			if(autocvar_g_campaign)
				{ campaign_bots_may_start = 1; }

			Kill_Notification(NOTIF_ONE_ONLY, self, MSG_CENTER_CPID, CPID_PREVENT_JOIN);

			PutClientInServer();

			if(IS_PLAYER(self)) { Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_JOIN_PLAY, self.netname); }
		}
		else
			stuffcmd(self, "menu_showteamselect\n");
	}
	else
	{
		// Player may not join because g_maxplayers is set
		Send_Notification(NOTIF_ONE_ONLY, self, MSG_CENTER, CENTER_JOIN_PREVENT);
	}
}

/**
 * Determines whether the player is allowed to join. This depends on cvar
 * g_maxplayers, if it isn't used this function always return TRUE, otherwise
 * it checks whether the number of currently playing players exceeds g_maxplayers.
 * @return int number of free slots for players, 0 if none
 */
float nJoinAllowed(entity ignore) {
	if(!ignore)
	// this is called that way when checking if anyone may be able to join (to build qcstatus)
	// so report 0 free slots if restricted
	{
		if(autocvar_g_forced_team_otherwise == "spectate")
			return 0;
		if(autocvar_g_forced_team_otherwise == "spectator")
			return 0;
	}

	if(self.team_forced < 0)
		return 0; // forced spectators can never join

	// TODO simplify this
	entity e;
	float totalClients = 0;
	FOR_EACH_CLIENT(e)
		if(e != ignore)
			totalClients += 1;

	if (!autocvar_g_maxplayers)
		return maxclients - totalClients;

	float currentlyPlaying = 0;
	FOR_EACH_REALCLIENT(e)
		if(IS_PLAYER(e) || e.caplayer == 1)
			currentlyPlaying += 1;

	if(currentlyPlaying < autocvar_g_maxplayers)
		return min(maxclients - totalClients, autocvar_g_maxplayers - currentlyPlaying);

	return 0;
}

/**
 * Checks whether the client is an observer or spectator, if so, he will get kicked after
 * g_maxplayers_spectator_blocktime seconds
 */
void checkSpectatorBlock() {
	if(IS_SPEC(self) || IS_OBSERVER(self)) {
		if( time > (self.spectatortime + autocvar_g_maxplayers_spectator_blocktime) ) {
			Send_Notification(NOTIF_ONE_ONLY, self, MSG_INFO, INFO_QUIT_KICK_SPECTATING);
			dropclient(self);
		}
	}
}

void PrintWelcomeMessage()
{
	if(self.motd_actived_time == 0)
	{
		if (autocvar_g_campaign) {
			if ((IS_PLAYER(self) && self.BUTTON_INFO) || (!IS_PLAYER(self))) {
				self.motd_actived_time = time;
				Send_Notification(NOTIF_ONE_ONLY, self, MSG_CENTER, CENTER_MOTD, campaign_message);
			}
		} else {
			if (self.BUTTON_INFO) {
				self.motd_actived_time = time;
				Send_Notification(NOTIF_ONE_ONLY, self, MSG_CENTER, CENTER_MOTD, getwelcomemessage());
			}
		}
	}
	else if(self.motd_actived_time > 0) // showing MOTD or campaign message
	{
		if (autocvar_g_campaign) {
			if (self.BUTTON_INFO)
				self.motd_actived_time = time;
			else if ((time - self.motd_actived_time > 2) && IS_PLAYER(self)) { // hide it some seconds after BUTTON_INFO has been released
				self.motd_actived_time = 0;
				Kill_Notification(NOTIF_ONE_ONLY, self, MSG_CENTER_CPID, CPID_MOTD);
			}
		} else {
			if (self.BUTTON_INFO)
				self.motd_actived_time = time;
			else if (time - self.motd_actived_time > 2) { // hide it some seconds after BUTTON_INFO has been released
				self.motd_actived_time = 0;
				Kill_Notification(NOTIF_ONE_ONLY, self, MSG_CENTER_CPID, CPID_MOTD);
			}
		}
	}
	else //if(self.motd_actived_time < 0) // just connected, motd is active
	{
		if(self.BUTTON_INFO) // BUTTON_INFO hides initial MOTD
			self.motd_actived_time = -2; // wait until BUTTON_INFO gets released
		else if(self.motd_actived_time == -2 || IS_PLAYER(self))
		{
			// instanctly hide MOTD
			self.motd_actived_time = 0;
			Kill_Notification(NOTIF_ONE_ONLY, self, MSG_CENTER_CPID, CPID_MOTD);
		}
	}
}

void ObserverThink()
{
	float prefered_movetype;
	if (self.flags & FL_JUMPRELEASED) {
		if (self.BUTTON_JUMP && !self.version_mismatch) {
			self.flags &= ~FL_JUMPRELEASED;
			self.flags |= FL_SPAWNING;
		} else if(self.BUTTON_ATCK && !self.version_mismatch) {
			self.flags &= ~FL_JUMPRELEASED;
			if(SpectateNext()) {
				self.classname = "spectator";
			}
		} else {
			prefered_movetype = ((!self.BUTTON_USE ? self.cvar_cl_clippedspectating : !self.cvar_cl_clippedspectating) ? MOVETYPE_FLY_WORLDONLY : MOVETYPE_NOCLIP);
			if (self.movetype != prefered_movetype)
				self.movetype = prefered_movetype;
		}
	} else {
		if (!(self.BUTTON_ATCK || self.BUTTON_JUMP)) {
			self.flags |= FL_JUMPRELEASED;
			if(self.flags & FL_SPAWNING)
			{
				self.flags &= ~FL_SPAWNING;
				LeaveSpectatorMode();
				return;
			}
		}
	}
}

void SpectatorThink()
{
	if (self.flags & FL_JUMPRELEASED) {
		if (self.BUTTON_JUMP && !self.version_mismatch) {
			self.flags &= ~FL_JUMPRELEASED;
			self.flags |= FL_SPAWNING;
		} else if(self.BUTTON_ATCK || self.impulse == 10 || self.impulse == 15 || self.impulse == 18 || (self.impulse >= 200 && self.impulse <= 209)) {
			self.flags &= ~FL_JUMPRELEASED;
			if(SpectateNext()) {
				self.classname = "spectator";
			} else {
				self.classname = "observer";
				PutClientInServer();
			}
			self.impulse = 0;
		} else if(self.impulse == 12 || self.impulse == 16  || self.impulse == 19 || (self.impulse >= 220 && self.impulse <= 229)) {
			self.flags &= ~FL_JUMPRELEASED;
			if(SpectatePrev()) {
				self.classname = "spectator";
			} else {
				self.classname = "observer";
				PutClientInServer();
			}
			self.impulse = 0;
		} else if (self.BUTTON_ATCK2) {
			self.flags &= ~FL_JUMPRELEASED;
			self.classname = "observer";
			PutClientInServer();
		} else {
			if(!SpectateUpdate())
				PutObserverInServer();
		}
	} else {
		if (!(self.BUTTON_ATCK || self.BUTTON_ATCK2)) {
			self.flags |= FL_JUMPRELEASED;
			if(self.flags & FL_SPAWNING)
			{
				self.flags &= ~FL_SPAWNING;
				LeaveSpectatorMode();
				return;
			}
		}
		if(!SpectateUpdate())
			PutObserverInServer();
	}

	self.flags |= FL_CLIENT | FL_NOTARGET;
}

void vehicles_enter (entity pl, entity veh);
void PlayerUseKey()
{
	if not(IS_PLAYER(self))
		return;

	if(self.vehicle)
	{
        vehicles_exit(VHEF_NORMAL);
        return;
	}
	else if(autocvar_g_vehicles_enter)
	{
		if not(self.frozen)
		if(self.deadflag == DEAD_NO)
		{
			entity head, closest_target = world;
			head = WarpZone_FindRadius(self.origin, autocvar_g_vehicles_enter_radius, TRUE);
				
			while(head) // find the closest acceptable target to enter
			{
				if(head.vehicle_flags & VHF_ISVEHICLE)
				if(head.deadflag == DEAD_NO)
				if not(head.owner)
				{
					if(closest_target)
					{
						if(vlen(self.origin - head.origin) < vlen(self.origin - closest_target.origin))
						{ closest_target = head; }
					}
					else { closest_target = head; }
				}
				
				head = head.chain;
			}
				
			if(closest_target) { vehicles_enter(self, closest_target); return; }
		}
	}
	
	// a use key was pressed; call handlers
	MUTATOR_CALLHOOK(PlayerUseKey);
}

/*
=============
PlayerPreThink

Called every frame for each client before the physics are run
=============
*/
.float usekeypressed;
void() nexball_setstatus;
.float items_added;
.float last_vehiclecheck;
void PlayerPreThink (void)
{
	WarpZone_PlayerPhysics_FixVAngle();

	self.stat_game_starttime = game_starttime;
	self.stat_round_starttime = round_starttime;
	self.stat_allow_oldnexbeam = autocvar_g_allow_oldnexbeam;
	self.stat_leadlimit = autocvar_leadlimit;

	if(frametime)
	{
		// physics frames: update anticheat stuff
		anticheat_prethink();
	}

	if(blockSpectators && frametime)
		// WORKAROUND: only use dropclient in server frames (frametime set). Never use it in cl_movement frames (frametime zero).
		checkSpectatorBlock();

	zoomstate_set = 0;

	if(self.netname_previous != self.netname)
	{
		if(autocvar_sv_eventlog)
			GameLogEcho(strcat(":name:", ftos(self.playerid), ":", self.netname));
		if(self.netname_previous)
			strunzone(self.netname_previous);
		self.netname_previous = strzone(self.netname);
	}

	// version nagging
	if(self.version_nagtime)
		if(self.cvar_g_xonoticversion)
			if(time > self.version_nagtime)
			{
				// don't notify git users
				if(strstr(self.cvar_g_xonoticversion, "git", 0) < 0 && strstr(self.cvar_g_xonoticversion, "autobuild", 0) < 0)
				{
					if(strstr(autocvar_g_xonoticversion, "git", 0) >= 0 || strstr(autocvar_g_xonoticversion, "autobuild", 0) >= 0)
					{
						// notify release users if connecting to git
						dprint("^1NOTE^7 to ", self.netname, "^7 - the server is running ^3Xonotic ", autocvar_g_xonoticversion, " (beta)^7, you have ^3Xonotic ", self.cvar_g_xonoticversion, "^1\n");
						Send_Notification(NOTIF_ONE_ONLY, self, MSG_INFO, INFO_VERSION_BETA, autocvar_g_xonoticversion, self.cvar_g_xonoticversion);
					}
					else
					{
						float r;
						r = vercmp(self.cvar_g_xonoticversion, autocvar_g_xonoticversion);
						if(r < 0)
						{
							// give users new version
							dprint("^1NOTE^7 to ", self.netname, "^7 - ^3Xonotic ", autocvar_g_xonoticversion, "^7 is out, and you still have ^3Xonotic ", self.cvar_g_xonoticversion, "^1 - get the update from ^4http://www.xonotic.org/^1!\n");
							Send_Notification(NOTIF_ONE_ONLY, self, MSG_INFO, INFO_VERSION_OUTDATED, autocvar_g_xonoticversion, self.cvar_g_xonoticversion);
						}
						else if(r > 0)
						{
							// notify users about old server version
							print("^1NOTE^7 to ", self.netname, "^7 - the server is running ^3Xonotic ", autocvar_g_xonoticversion, "^7, you have ^3Xonotic ", self.cvar_g_xonoticversion, "^1\n");
							Send_Notification(NOTIF_ONE_ONLY, self, MSG_INFO, INFO_VERSION_OLD, autocvar_g_xonoticversion, self.cvar_g_xonoticversion);
						}
					}
				}
				self.version_nagtime = 0;
			}

	// GOD MODE info
	if(!(self.flags & FL_GODMODE)) if(self.max_armorvalue)
	{
		Send_Notification(NOTIF_ONE_ONLY, self, MSG_INFO, INFO_GODMODE_OFF, self.max_armorvalue);
		self.max_armorvalue = 0;
	}

#ifdef TETRIS
	if (TetrisPreFrame())
		return;
#endif

	if(self.frozen == 2)
	{
		self.revive_progress = bound(0, self.revive_progress + frametime * self.revive_speed, 1);
		self.health = max(1, self.revive_progress * autocvar_g_balance_health_start);
		self.iceblock.alpha = bound(0.2, 1 - self.revive_progress, 1);

		if(self.revive_progress >= 1)
			Unfreeze(self);
	}
	else if(self.frozen == 3)
	{
		self.revive_progress = bound(0, self.revive_progress - frametime * self.revive_speed, 1);
		self.health = max(0, autocvar_g_nades_ice_health + (autocvar_g_balance_health_start-autocvar_g_nades_ice_health) * self.revive_progress );
		
		if(self.health < 1)
		{
			if(self.vehicle)
				vehicles_exit(VHEF_RELESE);
			Damage(self,self.frozen_by,self.frozen_by,1,DEATH_NADE_ICE_FREEZE,self.origin,'0 0 0');
		}
		else if ( self.revive_progress <= 0 )
			Unfreeze(self);
	}

	MUTATOR_CALLHOOK(PlayerPreThink);
	
	if(autocvar_g_vehicles_enter)
	if(time > self.last_vehiclecheck)
	if(IS_PLAYER(self))
	if not(self.frozen)
	if not(self.vehicle)
	if(self.deadflag == DEAD_NO)
	{
		entity veh;
		for(veh = world; (veh = findflags(veh, vehicle_flags, VHF_ISVEHICLE)); )
		if(vlen(veh.origin - self.origin) < autocvar_g_vehicles_enter_radius)
		if(veh.deadflag == DEAD_NO)
		if not(veh.owner)
		if(!veh.team || SAME_TEAM(self, veh))
			Send_Notification(NOTIF_ONE, self, MSG_CENTER, CENTER_VEHICLE_ENTER);
		else if(autocvar_g_vehicles_steal)
			Send_Notification(NOTIF_ONE, self, MSG_CENTER, CENTER_VEHICLE_ENTER_STEAL);
			
		self.last_vehiclecheck = time + 1;
	}

	if(!self.cvar_cl_newusekeysupported) // FIXME remove this - it was a stupid idea to begin with, we can JUST use the button
	{
		if(self.BUTTON_USE && !self.usekeypressed)
			PlayerUseKey();
		self.usekeypressed = self.BUTTON_USE;
	}

	if(IS_REAL_CLIENT(self))
		PrintWelcomeMessage();

	if(IS_PLAYER(self))
	{

		CheckRules_Player();

		if (intermission_running)
		{
			IntermissionThink ();	// otherwise a button could be missed between
			return;					// the think tics
		}

		//don't allow the player to turn around while game is paused!
		if(timeout_status == TIMEOUT_ACTIVE) {
			// FIXME turn this into CSQC stuff
			self.v_angle = self.lastV_angle;
			self.angles = self.lastV_angle;
			self.fixangle = TRUE;
		}

		if(frametime)
		{
			if(self.weapon == WEP_NEX && autocvar_g_balance_nex_charge)
			{
				self.weaponentity_glowmod_x = autocvar_g_weapon_charge_colormod_hdrmultiplier * autocvar_g_weapon_charge_colormod_red_half * min(1, self.nex_charge / autocvar_g_balance_nex_charge_animlimit);
				self.weaponentity_glowmod_y = autocvar_g_weapon_charge_colormod_hdrmultiplier * autocvar_g_weapon_charge_colormod_green_half * min(1, self.nex_charge / autocvar_g_balance_nex_charge_animlimit);
				self.weaponentity_glowmod_z = autocvar_g_weapon_charge_colormod_hdrmultiplier * autocvar_g_weapon_charge_colormod_blue_half * min(1, self.nex_charge / autocvar_g_balance_nex_charge_animlimit);

				if(self.nex_charge > autocvar_g_balance_nex_charge_animlimit)
				{
					self.weaponentity_glowmod_x = self.weaponentity_glowmod_x + autocvar_g_weapon_charge_colormod_hdrmultiplier * autocvar_g_weapon_charge_colormod_red_full * (self.nex_charge - autocvar_g_balance_nex_charge_animlimit) / (1 - autocvar_g_balance_nex_charge_animlimit);
					self.weaponentity_glowmod_y = self.weaponentity_glowmod_y + autocvar_g_weapon_charge_colormod_hdrmultiplier * autocvar_g_weapon_charge_colormod_green_full * (self.nex_charge - autocvar_g_balance_nex_charge_animlimit) / (1 - autocvar_g_balance_nex_charge_animlimit);
					self.weaponentity_glowmod_z = self.weaponentity_glowmod_z + autocvar_g_weapon_charge_colormod_hdrmultiplier * autocvar_g_weapon_charge_colormod_blue_full * (self.nex_charge - autocvar_g_balance_nex_charge_animlimit) / (1 - autocvar_g_balance_nex_charge_animlimit);
				}
			}
			else
				self.weaponentity_glowmod = colormapPaletteColor(self.clientcolors & 0x0F, TRUE) * 2;

			player_powerups();
		}

		if (self.deadflag != DEAD_NO)
		{
			if(self.personal && g_race_qualifying)
			{
				if(time > self.respawn_time)
				{
					self.respawn_time = time + 1; // only retry once a second
					self.stat_respawn_time = self.respawn_time;
					respawn();
					self.impulse = 141;
				}
			}
			else
			{
				float button_pressed;
				if(frametime)
					player_anim();
				button_pressed = (self.BUTTON_ATCK || self.BUTTON_JUMP || self.BUTTON_ATCK2 || self.BUTTON_HOOK || self.BUTTON_USE);
				
				if (self.deadflag == DEAD_DYING)
				{
					if(self.respawn_flags & RESPAWN_FORCE && !autocvar_g_respawn_delay_max)
						self.deadflag = DEAD_RESPAWNING;
					else if(!button_pressed)
						self.deadflag = DEAD_DEAD;
				}
				else if (self.deadflag == DEAD_DEAD)
				{
					if(button_pressed)
						self.deadflag = DEAD_RESPAWNABLE;
					else if(time >= self.respawn_time_max && self.respawn_flags & RESPAWN_FORCE)
						self.deadflag = DEAD_RESPAWNING;
				}
				else if (self.deadflag == DEAD_RESPAWNABLE)
				{
					if(!button_pressed)
						self.deadflag = DEAD_RESPAWNING;
				}
				else if (self.deadflag == DEAD_RESPAWNING)
				{
					if(time > self.respawn_time)
					{
						self.respawn_time = time + 1; // only retry once a second
						self.respawn_time_max = self.respawn_time;
						respawn();
					}
				}

				ShowRespawnCountdown();

				if(self.respawn_flags & RESPAWN_SILENT)
					self.stat_respawn_time = 0;
				else if(self.respawn_flags & RESPAWN_FORCE && autocvar_g_respawn_delay_max)
					self.stat_respawn_time = self.respawn_time_max;
				else
					self.stat_respawn_time = self.respawn_time;
			}

			// if respawning, invert stat_respawn_time to indicate this, the client translates it
			if(self.deadflag == DEAD_RESPAWNING && self.stat_respawn_time > 0)
				self.stat_respawn_time *= -1;

			return;
		}

		self.prevorigin = self.origin;

		float do_crouch = self.BUTTON_CROUCH;
		if(self.hook.state)
			do_crouch = 0;
		if(self.vehicle)
			do_crouch = 0;
		if(self.frozen)
			do_crouch = 0;
		if(self.weapon == WEP_SHOTGUN && self.weaponentity.wframe == WFRAME_FIRE2 && time < self.weapon_nextthink)
			do_crouch = 0;

		if (do_crouch)
		{
			if (!self.crouch)
			{
				self.crouch = TRUE;
				self.view_ofs = PL_CROUCH_VIEW_OFS;
				setsize (self, PL_CROUCH_MIN, PL_CROUCH_MAX);
				// setanim(self, self.anim_duck, FALSE, TRUE, TRUE); // this anim is BROKEN anyway
			}
		}
		else
		{
			if (self.crouch)
			{
				tracebox(self.origin, PL_MIN, PL_MAX, self.origin, FALSE, self);
				if (!trace_startsolid)
				{
					self.crouch = FALSE;
					self.view_ofs = PL_VIEW_OFS;
					setsize (self, PL_MIN, PL_MAX);
				}
			}
		}

		FixPlayermodel();

		GrapplingHookFrame();

		// LordHavoc: allow firing on move frames (sub-ticrate), this gives better timing on slow servers
		//if(frametime)
		{
			self.items &= ~self.items_added;

			W_WeaponFrame();

			self.items_added = 0;
			if(self.items & IT_JETPACK)
				if(self.items & IT_FUEL_REGEN || self.ammo_fuel >= 0.01)
					self.items_added |= IT_FUEL;

			self.items |= self.items_added;
		}

		player_regen();

		// rot nex charge to the charge limit
		if(autocvar_g_balance_nex_charge_rot_rate && self.nex_charge > autocvar_g_balance_nex_charge_limit && self.nex_charge_rottime < time)
			self.nex_charge = bound(autocvar_g_balance_nex_charge_limit, self.nex_charge - autocvar_g_balance_nex_charge_rot_rate * frametime / W_TICSPERFRAME, 1);

		if(frametime)
			player_anim();
		
		// secret status
		secrets_setstatus();
		
		// monsters status
		monsters_setstatus();
		
		self.dmg_team = max(0, self.dmg_team - autocvar_g_teamdamage_resetspeed * frametime);

		//self.angles_y=self.v_angle_y + 90;   // temp
	} else if(gameover) {
		if (intermission_running)
			IntermissionThink ();	// otherwise a button could be missed between
		return;
	} else if(IS_OBSERVER(self)) {
		ObserverThink();
	} else if(IS_SPEC(self)) {
		SpectatorThink();
	}

	if(!zoomstate_set)
		SetZoomState(self.BUTTON_ZOOM || self.BUTTON_ZOOMSCRIPT || (self.BUTTON_ATCK2 && self.weapon == WEP_NEX) || (self.BUTTON_ATCK2 && self.weapon == WEP_RIFLE && autocvar_g_balance_rifle_secondary == 0));

	float oldspectatee_status;
	oldspectatee_status = self.spectatee_status;
	if(IS_SPEC(self))
		self.spectatee_status = num_for_edict(self.enemy);
	else if(IS_OBSERVER(self))
		self.spectatee_status = num_for_edict(self);
	else
		self.spectatee_status = 0;
	if(self.spectatee_status != oldspectatee_status)
	{
		ClientData_Touch(self);
		if(g_race || g_cts)
			race_InitSpectator();
	}

	if(self.teamkill_soundtime)
	if(time > self.teamkill_soundtime)
	{
		self.teamkill_soundtime = 0;

		entity oldpusher, oldself;

		oldself = self; self = self.teamkill_soundsource;
		oldpusher = self.pusher; self.pusher = oldself;

		PlayerSound(playersound_teamshoot, CH_VOICE, VOICETYPE_LASTATTACKER_ONLY);

		self.pusher = oldpusher;
		self = oldself;
	}

	if(self.taunt_soundtime)
	if(time > self.taunt_soundtime)
	{
		self.taunt_soundtime = 0;
		PlayerSound(playersound_taunt, CH_VOICE, VOICETYPE_AUTOTAUNT);
	}

	target_voicescript_next(self);

	// if a player goes unarmed after holding a loaded weapon, empty his clip size and remove the crosshair ammo ring
	if(!self.weapon)
		self.clip_load = self.clip_size = 0;
}

float isInvisibleString(string s)
{
	float i, n, c;
	s = strdecolorize(s);
	for((i = 0), (n = strlen(s)); i < n; ++i)
	{
		c = str2chr(s, i);
		switch(c)
		{
			case 0:
			case 32: // space
				break;
			case 192: // charmap space
				if (!autocvar_utf8_enable)
					break;
				return FALSE;
			case 160: // space in unicode fonts
			case 0xE000 + 192: // utf8 charmap space
				if (autocvar_utf8_enable)
					break;
			default:
				return FALSE;
		}
	}
	return TRUE;
}

/*
=============
PlayerPostThink

Called every frame for each client after the physics are run
=============
*/
.float idlekick_lasttimeleft;
void PlayerPostThink (void)
{
	// Savage: Check for nameless players
	if (isInvisibleString(self.netname)) {
		self.netname = "Player";
		stuffcmd(self, strcat("name ", self.netname, substring(ftos(random()), 2, -1), "\n"));
	}

	if(sv_maxidle > 0 && frametime) // WORKAROUND: only use dropclient in server frames (frametime set). Never use it in cl_movement frames (frametime zero).
	if(IS_PLAYER(self) || sv_maxidle_spectatorsareidle)
	{
		if (time - self.parm_idlesince < 1) // instead of (time == self.parm_idlesince) to support sv_maxidle <= 10
		{
			if(self.idlekick_lasttimeleft)
			{
				self.idlekick_lasttimeleft = 0;
				Kill_Notification(NOTIF_ONE_ONLY, self, MSG_CENTER_CPID, CPID_IDLING);
			}
		}
		else
		{
			float timeleft;
			timeleft = ceil(sv_maxidle - (time - self.parm_idlesince));
			if(timeleft == min(10, sv_maxidle - 1)) // - 1 to support sv_maxidle <= 10
			{
				if(!self.idlekick_lasttimeleft)
					Send_Notification(NOTIF_ONE_ONLY, self, MSG_CENTER, CENTER_DISCONNECT_IDLING, timeleft);
			}
			if(timeleft <= 0)
			{
				Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_QUIT_KICK_IDLING, self.netname);
				dropclient(self);
				return;
			}
			else if(timeleft <= 10)
			{
				if(timeleft != self.idlekick_lasttimeleft)
					{ Send_Notification(NOTIF_ONE, self, MSG_ANNCE, Announcer_PickNumber(CNT_IDLE, timeleft)); }
				self.idlekick_lasttimeleft = timeleft;
			}
		}
	}

#ifdef TETRIS
	if(self.impulse == 100)
		ImpulseCommands();
	if (!TetrisPostFrame())
	{
#endif

	CheatFrame();

	//CheckPlayerJump();

	if(IS_PLAYER(self)) {
		CheckRules_Player();
		UpdateChatBubble();
		if (self.impulse)
			ImpulseCommands();
		if (intermission_running)
			return;		// intermission or finale
		GetPressedKeys();
	}
	
#ifdef TETRIS
	}
#endif

	/*
	float i;
	for(i = 0; i < 1000; ++i)
	{
		vector end;
		end = self.origin + '0 0 1024' + 512 * randomvec();
		tracebox(self.origin, self.mins, self.maxs, end, MOVE_NORMAL, self);
		if(trace_fraction < 1)
		if(!(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT))
		{
			print("I HIT SOLID: ", vtos(self.origin), " -> ", vtos(end), "\n");
			break;
		}
	}
	*/

	//pointparticles(particleeffectnum("machinegun_impact"), self.origin + self.view_ofs + '0 0 7', '0 0 0', 1);

	if(self.waypointsprite_attachedforcarrier)
		WaypointSprite_UpdateHealth(self.waypointsprite_attachedforcarrier, '1 0 0' * healtharmor_maxdamage(self.health, self.armorvalue, autocvar_g_balance_armor_blockpercent, DEATH_WEAPON));

	playerdemo_write();

	if((g_cts || g_race) && self.cvar_cl_allow_uidtracking == 1 && self.cvar_cl_allow_uid2name == 1)
	{
		if not(self.stored_netname)
			self.stored_netname = strzone(uid2name(self.crypto_idfp));
		if(self.stored_netname != self.netname)
		{
			db_put(ServerProgsDB, strcat("/uid2name/", self.crypto_idfp), self.netname);
			strunzone(self.stored_netname);
			self.stored_netname = strzone(self.netname);
		}
	}

	/*
	if(g_race)
		dprint(sprintf("%f %.6f\n", time, race_GetFractionalLapCount(self)));
	*/

	CSQCMODEL_AUTOUPDATE();
}
