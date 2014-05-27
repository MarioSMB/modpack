void CreatureFrame (void)
{
	entity oldself;
	float dm;

	oldself = self;
	for(self = world; (self = findfloat(self, damagedbycontents, TRUE)); )
	{
		if (self.movetype == MOVETYPE_NOCLIP) { continue; }

		float vehic = IS_VEHICLE(self);
		float projectile = (self.flags & FL_PROJECTILE);
		float monster = IS_MONSTER(self);

		if (self.watertype <= CONTENT_WATER && self.waterlevel > 0) // workaround a retarded bug made by id software :P (yes, it's that old of a bug)
		{
			if (!(self.flags & FL_INWATER))
			{
				self.flags |= FL_INWATER;
				self.dmgtime = 0;
			}

			if(!vehic && !projectile && !monster && (!IS_PLAYER(self) || !autocvar_g_status_effects)) // vehicles, monsters and projectiles don't drown
			{
				if (self.waterlevel != WATERLEVEL_SUBMERGED)
				{
					if(self.air_finished < time)
						PlayerSound(playersound_gasp, CH_PLAYER, VOICETYPE_PLAYERSOUND);
					self.air_finished = time + autocvar_g_balance_contents_drowndelay;
					self.dmg = 2;
				}
				else if (self.air_finished < time)
				{	// drown!
					if (!self.deadflag)
					if (self.pain_finished < time)
					{
						Damage (self, world, world, autocvar_g_balance_contents_playerdamage_drowning * autocvar_g_balance_contents_damagerate, DEATH_DROWN, self.origin, '0 0 0');
						self.pain_finished = time + 0.5;
					}
				}
			}

			if (self.dmgtime < time)
			{
				self.dmgtime = time + autocvar_g_balance_contents_damagerate;

				if (projectile)
				{
					if (self.watertype == CONTENT_LAVA)
					{
						Damage (self, world, world, autocvar_g_balance_contents_projectiledamage * autocvar_g_balance_contents_damagerate * self.waterlevel, DEATH_LAVA, self.origin, '0 0 0');
					}
					else if (self.watertype == CONTENT_SLIME)
					{
						Damage (self, world, world, autocvar_g_balance_contents_projectiledamage * autocvar_g_balance_contents_damagerate * self.waterlevel, DEATH_SLIME, self.origin, '0 0 0');
					}
				}
				else
				{
					if (self.watertype == CONTENT_LAVA)
					{
						if (self.watersound_finished < time)
						{
							self.watersound_finished = time + 2.9;
							sound (self, CH_PLAYER, "player/lava.wav", VOL_BASE, ATTEN_NORM);
						}
						Damage (self, world, world, autocvar_g_balance_contents_playerdamage_lava * autocvar_g_balance_contents_damagerate * self.waterlevel, DEATH_LAVA, self.origin, '0 0 0');
					}
					else if (self.watertype == CONTENT_SLIME)
					{
						if (self.watersound_finished < time)
						{
							self.watersound_finished = time + 4.9;
							sound (self, CH_PLAYER, "player/slime.wav", VOL_BASE, ATTEN_NORM);
						}
						Damage (self, world, world, autocvar_g_balance_contents_playerdamage_slime * autocvar_g_balance_contents_damagerate * self.waterlevel, DEATH_SLIME, self.origin, '0 0 0');
					}
				}
			}
		}
		else
		{
			if (self.flags & FL_INWATER)
			{
				// play leave water sound
				self.flags &= ~FL_INWATER;
				self.dmgtime = 0;
			}
			self.air_finished = time + 12;
			self.dmg = 2;
		}

		if(!vehic && !projectile) // vehicles don't get falling damage
		{
			// check for falling damage
			float velocity_len = vlen(self.velocity);
			if(!self.hook.state)
			{
				dm = vlen(self.oldvelocity) - velocity_len; // dm is now the velocity DECREASE. Velocity INCREASE should never cause a sound or any damage.
				if (self.deadflag)
					dm = (dm - autocvar_g_balance_falldamage_deadminspeed) * autocvar_g_balance_falldamage_factor;
				else
					dm = min((dm - autocvar_g_balance_falldamage_minspeed) * autocvar_g_balance_falldamage_factor, autocvar_g_balance_falldamage_maxdamage);
				if (dm > 0)
					Damage (self, world, world, dm, DEATH_FALL, self.origin, '0 0 0');
			}

			if(autocvar_g_maxspeed > 0 && velocity_len > autocvar_g_maxspeed)
				Damage (self, world, world, 100000, DEATH_SHOOTING_STAR, self.origin, '0 0 0');
			// play stupid sounds
			if (g_footsteps)
			if (!gameover)
			if (self.flags & FL_ONGROUND)
			if (velocity_len > autocvar_sv_maxspeed * 0.6)
			if (!self.deadflag)
			if (time < self.lastground + 0.2)
			{
				if((time > self.nextstep) || (time < (self.nextstep - 10.0)))
				{
					self.nextstep = time + 0.3 + random() * 0.1;
					trace_dphitq3surfaceflags = 0;
					tracebox(self.origin, self.mins, self.maxs, self.origin - '0 0 1', MOVE_NOMONSTERS, self);
					/*
					if(trace_fraction == 1)
						dprint("nohit\n");
					else
						dprint(ftos(trace_dphitq3surfaceflags), "\n");
					*/
					if (!(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOSTEPS))
					{
						if(trace_dphitq3surfaceflags & Q3SURFACEFLAG_METALSTEPS)
							GlobalSound(globalsound_metalstep, CH_PLAYER, VOICETYPE_PLAYERSOUND);
						else
							GlobalSound(globalsound_step, CH_PLAYER, VOICETYPE_PLAYERSOUND);
					}
				}
			}
		}

        self.oldvelocity = self.velocity;
	}
	self = oldself;
}


/*
=============
StartFrame

Called before each frame by the server
=============
*/

float game_delay;
float game_delay_last;

float RedirectionThink();
void StartFrame (void)
{
	execute_next_frame();

	remove = remove_unsafely; // not during spawning!
	serverprevtime = servertime;
	servertime = time;
	serverframetime = frametime;

#ifdef PROFILING
	if(time > client_cefc_accumulatortime + 1)
	{
		float t, pp, c_seeing, c_seen;
		entity cl;
		t = client_cefc_accumulator / (time - client_cefc_accumulatortime);
		print("CEFC time: ", ftos(t * 1000), "ms; ");
		c_seeing = 0;
		c_seen = 0;
		FOR_EACH_CLIENT(cl)
		{
			if(IS_REAL_CLIENT(cl))
				++c_seeing;
			if(IS_PLAYER(cl))
				++c_seen;
		}
		print("CEFC calls per second: ", ftos(c_seeing * (c_seen - 1) / t), "; ");
		print("CEFC 100% load at: ", ftos(solve_quadratic(t, -t, -1) * '0 1 0'), "\n");

		client_cefc_accumulatortime = time;
		client_cefc_accumulator = 0;
	}
#endif

	entity e;
	for(e = world; (e = findfloat(e, csqcprojectile_clientanimate, 1)); )
		CSQCProjectile_Check(e);

	if(RedirectionThink())
		return;

	UncustomizeEntitiesRun();
	InitializeEntitiesRun();

	WarpZone_StartFrame();

	sys_frametime = autocvar_sys_ticrate * autocvar_slowmo;
	if(sys_frametime <= 0)
		sys_frametime = 1.0 / 60.0; // somewhat safe fallback

	if (timeout_status == TIMEOUT_LEADTIME) // just before the timeout (when timeout_status will be TIMEOUT_ACTIVE)
		orig_slowmo = autocvar_slowmo; // slowmo will be restored after the timeout

	skill = autocvar_skill;

	// detect when the pre-game countdown (if any) has ended and the game has started
	game_delay = (time < game_starttime) ? TRUE : FALSE;

	if(game_delay_last == TRUE)
	if(game_delay == FALSE)
	if(autocvar_sv_eventlog)
		GameLogEcho(":startdelay_ended");

	game_delay_last = game_delay;

	CreatureFrame ();
	CheckRules_World ();

	// if in warmup stage and limit for warmup is hit start match
	if(warmup_stage)
	if(!gameover)
	if((g_warmup_limit > 0 && time >= g_warmup_limit)
	 || (g_warmup_limit == 0 && autocvar_timelimit != 0 && time >= autocvar_timelimit * 60))
	{
		ReadyRestart();
		return;
	}

	bot_serverframe();

	FOR_EACH_PLAYER(self)
		self.porto_forbidden = max(0, self.porto_forbidden - 1);

	anticheat_startframe();

	MUTATOR_CALLHOOK(SV_StartFrame);
}

.vector originjitter;
.vector anglesjitter;
.float anglejitter;
.string gametypefilter;
.string cvarfilter;
float DoesQ3ARemoveThisEntity();
void SV_OnEntityPreSpawnFunction()
{
	if (self)
	if (self.gametypefilter != "")
	if (!isGametypeInFilter(MapInfo_LoadedGametype, teamplay, have_team_spawns, self.gametypefilter))
	{
		remove(self);
		return;
	}
	if(self.cvarfilter != "")
	{
		float n, i, o, inv;
		string s, k, v;
		inv = 0;

		s = self.cvarfilter;
		if(substring(s, 0, 1) == "+")
		{
			s = substring(s, 1, -1);
		}
		else if(substring(s, 0, 1) == "-")
		{
			inv = 1;
			s = substring(s, 1, -1);
		}

		n = tokenize_console(s);
		for(i = 0; i < n; ++i)
		{
			s = argv(i);
			// syntax:
			// var>x
			// var<x
			// var>=x
			// var<=x
			// var==x
			// var!=x
			// var===x
			// var!==x
			if((o = strstrofs(s, ">=", 0)) >= 0)
			{
				k = substring(s, 0, o);
				v = substring(s, o+2, -1);
				if(cvar(k) < stof(v))
					goto cvar_fail;
			}
			else if((o = strstrofs(s, "<=", 0)) >= 0)
			{
				k = substring(s, 0, o);
				v = substring(s, o+2, -1);
				if(cvar(k) > stof(v))
					goto cvar_fail;
			}
			else if((o = strstrofs(s, ">", 0)) >= 0)
			{
				k = substring(s, 0, o);
				v = substring(s, o+1, -1);
				if(cvar(k) <= stof(v))
					goto cvar_fail;
			}
			else if((o = strstrofs(s, "<", 0)) >= 0)
			{
				k = substring(s, 0, o);
				v = substring(s, o+1, -1);
				if(cvar(k) >= stof(v))
					goto cvar_fail;
			}
			else if((o = strstrofs(s, "==", 0)) >= 0)
			{
				k = substring(s, 0, o);
				v = substring(s, o+2, -1);
				if(cvar(k) != stof(v))
					goto cvar_fail;
			}
			else if((o = strstrofs(s, "!=", 0)) >= 0)
			{
				k = substring(s, 0, o);
				v = substring(s, o+2, -1);
				if(cvar(k) == stof(v))
					goto cvar_fail;
			}
			else if((o = strstrofs(s, "===", 0)) >= 0)
			{
				k = substring(s, 0, o);
				v = substring(s, o+2, -1);
				if(cvar_string(k) != v)
					goto cvar_fail;
			}
			else if((o = strstrofs(s, "!==", 0)) >= 0)
			{
				k = substring(s, 0, o);
				v = substring(s, o+2, -1);
				if(cvar_string(k) == v)
					goto cvar_fail;
			}
			else if(substring(s, 0, 1) == "!")
			{
				k = substring(s, 1, -1);
				if(cvar(k))
					goto cvar_fail;
			}
			else
			{
				k = s;
				if (!cvar(k))
					goto cvar_fail;
			}
		}
		inv = !inv;
:cvar_fail
		// now inv is 1 if we want to keep the item, and 0 if we want to get rid of it
		if (!inv)
		{
			//print("cvarfilter fail\n");
			remove(self);
			return;
		}
	}

	if(DoesQ3ARemoveThisEntity())
	{
		remove(self);
		return;
	}

	// support special -1 and -2 angle from radiant
	if (self.angles == '0 -1 0')
		self.angles = '-90 0 0';
	else if (self.angles == '0 -2 0')
		self.angles = '+90 0 0';

	if(self.originjitter_x != 0)
		self.origin_x = self.origin_x + (random() * 2 - 1) * self.originjitter_x;
	if(self.originjitter_y != 0)
		self.origin_y = self.origin_y + (random() * 2 - 1) * self.originjitter_y;
	if(self.originjitter_z != 0)
		self.origin_z = self.origin_z + (random() * 2 - 1) * self.originjitter_z;
	if(self.anglesjitter_x != 0)
		self.angles_x = self.angles_x + (random() * 2 - 1) * self.anglesjitter_x;
	if(self.anglesjitter_y != 0)
		self.angles_y = self.angles_y + (random() * 2 - 1) * self.anglesjitter_y;
	if(self.anglesjitter_z != 0)
		self.angles_z = self.angles_z + (random() * 2 - 1) * self.anglesjitter_z;
	if(self.anglejitter != 0)
		self.angles_y = self.angles_y + (random() * 2 - 1) * self.anglejitter;

	if(MUTATOR_CALLHOOK(OnEntityPreSpawn))
	{
		remove(self);
		return;
	}
}

void WarpZone_PostInitialize_Callback(void)
{
	// create waypoint links for warpzones
	entity e;
	for(e = world; (e = find(e, classname, "trigger_warpzone")); )
	{
		vector src, dst;
		src = (e.absmin + e.absmax) * 0.5;
		makevectors(e.warpzone_angles);
		src = src + ((e.warpzone_origin - src) * v_forward) * v_forward + 16 * v_right;
		dst = (e.enemy.absmin + e.enemy.absmax) * 0.5;
		makevectors(e.enemy.warpzone_angles);
		dst = dst + ((e.enemy.warpzone_origin - dst) * v_forward) * v_forward - 16 * v_right;
		waypoint_spawnforteleporter_v(e, src, dst, 0);
	}
}
