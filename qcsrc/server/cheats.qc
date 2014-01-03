void CopyBody(float keepvelocity);

#ifdef NOCHEATS

float CheatImpulse(float i) { return 0; }
float CheatCommand(float argc) { return 0; }
float CheatFrame() { return 0; }
void CheatInit() { cheatcount_total = world.cheatcount; }
void CheatShutdown() { }
void CheatInitClient() { }
void CheatShutdownClient() { }
void Drag_MoveDrag(entity from, entity to) { }

#else

.float maycheat;
float gamestart_sv_cheats;

#define CHIMPULSE_SPEEDRUN_INIT 30
#define CHIMPULSE_GIVE_ALL 99
#define CHIMPULSE_CLONE_MOVING 140
#define CHIMPULSE_SPEEDRUN 141
#define CHIMPULSE_CLONE_STANDING 142
#define CHIMPULSE_TELEPORT 143
#define CHIMPULSE_R00T 148

#define CHRAME_DRAG 8

void CheatInit()
{
	gamestart_sv_cheats = autocvar_sv_cheats;
}

void CheatShutdown()
{
}

void CheatInitClient()
{
}

void CheatShutdownClient()
{
}

float CheatsAllowed(float i, float argc, float fr) // the cheat gets passed as argument for possible future ACL checking
{
	// dead people cannot cheat
	if(self.deadflag != DEAD_NO)
		return 0;
	if(gamestart_sv_cheats < 2 && !IS_PLAYER(self))
		return 0;

	// sv_clones
	if(i == CHIMPULSE_CLONE_MOVING || i == CHIMPULSE_CLONE_STANDING)
		if(self.lip < sv_clones)
			return 1;

	// haha
	if(self.maycheat)
		return 1;

	// sv_cheats
	if(gamestart_sv_cheats && autocvar_sv_cheats)
		return 1;

	// if we get here, player is not allowed to cheat. Log it.
	if(i)
		bprintf("Player %s^7 tried to use cheat 'impulse %d'\n", self.netname, i);
	else if(argc)
		bprintf("Player %s^7 tried to use cheat '%s'\n", self.netname, argv(0));
	else if(fr)
		bprintf("Player %s^7 tried to use cheat frame %d\n", self.netname, fr);
	else
		bprintf("Player %s^7 tried to use an unknown cheat\n", self.netname);

	return 0;
}

#define BEGIN_CHEAT_FUNCTION() \
	float cheating, attempting; \
	cheating = 0; attempting = 0
#define DID_CHEAT() \
	++cheating
#define ADD_CHEATS(e,n) \
	cheatcount_total += n; \
	e.cheatcount += n
#define END_CHEAT_FUNCTION() \
	ADD_CHEATS(self,cheating); \
	return attempting
#define IS_CHEAT(i,argc,fr) \
	if((++attempting, !CheatsAllowed(i,argc,fr))) \
		break

float num_autoscreenshot;
void info_autoscreenshot_findtarget()
{
	entity e;
	e = find(world, targetname, self.target);
	if(!e)
	{
		objerror("Missing target. FAIL!");
		return;
	}
	vector a = vectoangles(e.origin - self.origin);
	a_x = -a_x; // don't ask
	self.angles_x = a_x;
	self.angles_y = a_y;
	// we leave Rick Roll alone
}
void spawnfunc_info_autoscreenshot()
{
	if(++num_autoscreenshot > autocvar_g_max_info_autoscreenshot)
	{
		objerror("Too many info_autoscreenshot entitites. FAIL!");
		return;
	}
	if(self.target != "")
		InitializeEntity(self, info_autoscreenshot_findtarget, INITPRIO_FINDTARGET);
	// this one just has to exist
}

float CheatImpulse(float i)
{
	BEGIN_CHEAT_FUNCTION();
	switch(i)
	{
		entity e, e2;

		case CHIMPULSE_SPEEDRUN_INIT: // deploy personal waypoint
			// shared with regular waypoint init, so this is not a cheat by itself
			if(!self.personal)
			{
				self.personal = spawn();
				self.personal.classname = "personal_wp";
			}
			self.personal.origin = self.origin;
			self.personal.v_angle = self.v_angle;
			self.personal.velocity = self.velocity;
			self.personal.ammo_rockets = self.ammo_rockets;
			self.personal.ammo_nails = self.ammo_nails;
			self.personal.ammo_cells = self.ammo_cells;
			self.personal.ammo_supercells = self.ammo_supercells;
			self.personal.ammo_shells = self.ammo_shells;
			self.personal.ammo_fuel = self.ammo_fuel;
			self.personal.health = self.health;
			self.personal.armorvalue = self.armorvalue;
			self.personal.weapons = self.weapons;
			self.personal.items = self.items;
			self.personal.pauserotarmor_finished = self.pauserotarmor_finished;
			self.personal.pauserothealth_finished = self.pauserothealth_finished;
			self.personal.pauserotfuel_finished = self.pauserotfuel_finished;
			self.personal.pauseregen_finished = self.pauseregen_finished;
			self.personal.strength_finished = self.strength_finished;
			self.personal.invincible_finished = self.invincible_finished;
			self.personal.teleport_time = time;
			break; // this part itself doesn't cheat, so let's not count this
		case CHIMPULSE_CLONE_MOVING:
			IS_CHEAT(i, 0, 0);
			makevectors (self.v_angle);
			self.velocity = self.velocity + v_forward * 300;
			CopyBody(1);
			self.lip += 1;
			self.velocity = self.velocity - v_forward * 300;
			DID_CHEAT();
			break;
		case CHIMPULSE_CLONE_STANDING:
			IS_CHEAT(i, 0, 0);
			CopyBody(0);
			self.lip += 1;
			DID_CHEAT();
			break;
		case CHIMPULSE_GIVE_ALL:
			IS_CHEAT(i, 0, 0);
			CheatCommand(tokenize_console("give all"));
			break; // already counted as cheat
		case CHIMPULSE_SPEEDRUN:
			IS_CHEAT(i, 0, 0);
			if(self.personal)
			{
				self.speedrunning = TRUE;
				tracebox(self.personal.origin, self.mins, self.maxs, self.personal.origin, MOVE_WORLDONLY, self);
				if(trace_startsolid)
				{
					sprint(self, "Cannot move there, cheater - only waypoints set using g_waypointsprite_personal work\n");
				}
				else
				{
					// Abort speedrun, teleport back
					setorigin(self, self.personal.origin);
					self.oldvelocity = self.velocity = self.personal.velocity;
					self.angles = self.personal.v_angle;
					self.fixangle = TRUE;

					MUTATOR_CALLHOOK(AbortSpeedrun);
				}

				self.ammo_rockets = self.personal.ammo_rockets;
				self.ammo_nails = self.personal.ammo_nails;
				self.ammo_cells = self.personal.ammo_cells;
				self.ammo_shells = self.personal.ammo_shells;
				self.ammo_fuel = self.personal.ammo_fuel;
				self.health = self.personal.health;
				self.armorvalue = self.personal.armorvalue;
				self.weapons = self.personal.weapons;
				self.items = self.personal.items;
				self.pauserotarmor_finished = time + self.personal.pauserotarmor_finished - self.personal.teleport_time;
				self.pauserothealth_finished = time + self.personal.pauserothealth_finished - self.personal.teleport_time;
				self.pauserotfuel_finished = time + self.personal.pauserotfuel_finished - self.personal.teleport_time;
				self.pauseregen_finished = time + self.personal.pauseregen_finished - self.personal.teleport_time;
				self.strength_finished = time + self.personal.strength_finished - self.personal.teleport_time;
				self.invincible_finished = time + self.personal.invincible_finished - self.personal.teleport_time;

				DID_CHEAT();
				break;
			}
			if(self.deadflag != DEAD_NO)
				sprint(self, "UR DEAD AHAHAH))\n");
			else
				sprint(self, "No waypoint set, cheater (use g_waypointsprite_personal to set one)\n");
			break;
		case CHIMPULSE_TELEPORT:
			IS_CHEAT(i, 0, 0);
			if(self.movetype == MOVETYPE_NOCLIP)
			{
				e = find(world, classname, "info_autoscreenshot");
				if(e)
				{
					sprint(self, "Emergency teleport used info_autoscreenshot location\n");
					setorigin(self, e.origin);
					self.angles = e.angles;
					remove(e);
					// should we? self.angles_x = -self.angles_x;
					self.fixangle = TRUE;
					self.velocity = '0 0 0';
					DID_CHEAT();
					break;
				}
			}
			if(MoveToRandomMapLocation(self, DPCONTENTS_SOLID | DPCONTENTS_CORPSE | DPCONTENTS_PLAYERCLIP, DPCONTENTS_SLIME | DPCONTENTS_LAVA | DPCONTENTS_SKY | DPCONTENTS_BODY | DPCONTENTS_DONOTENTER, Q3SURFACEFLAG_SKY, ((gamestart_sv_cheats < 2) ? 100 : 100000), 384, 384))
			{
				sprint(self, "Emergency teleport used random location\n");
				self.angles_x = -self.angles_x;
				self.fixangle = TRUE;
				self.velocity = '0 0 0';
				DID_CHEAT();
				break;
			}
			sprint(self, "Emergency teleport could not find a good location, forget it!\n");
			break;
		case CHIMPULSE_R00T:
			IS_CHEAT(i, 0, 0);
			RandomSelection_Init();
			FOR_EACH_PLAYER(e)
				if(e.deadflag == DEAD_NO)
					if(DIFF_TEAM(e, self))
						RandomSelection_Add(e, 0, string_null, 1, 1);
			if(RandomSelection_chosen_ent)
				e = RandomSelection_chosen_ent;
			else
				e = self;

			pointparticles(particleeffectnum("rocket_explode"), e.origin, '0 0 0', 1);
			sound(e, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTEN_NORM);

			e2 = spawn();
			setorigin(e2, e.origin);
			RadiusDamage(e2, self, 1000, 0, 128, world, 500, DEATH_CHEAT, e);
			remove(e2);

			print("404 Sportsmanship not found.\n");
			DID_CHEAT();
			break;
	}

	END_CHEAT_FUNCTION();
}

void DragBox_Think();
float drag_lastcnt;
float CheatCommand(float argc)
{
	BEGIN_CHEAT_FUNCTION();
	string cmd;
	cmd = argv(0);
	switch(cmd)
	{
		entity e;
		float effectnum, f;
		vector start, end;
		entity oldself;

		case "pointparticles":
			IS_CHEAT(0, argc, 0);
			if(argc == 5)
			{
				// arguments:
				//   effectname
				//   origin (0..1, on crosshair line)
				//   velocity
				//   howmany
				effectnum = particleeffectnum(argv(1));
				f = stof(argv(2));
				crosshair_trace(self);
				start = (1-f) * self.origin + f * trace_endpos;
				end = stov(argv(3));
				f = stof(argv(4));
				pointparticles(effectnum, start, end, f);
				DID_CHEAT();
				break;
			}
			sprint(self, "Usage: sv_cheats 1; restart; cmd pointparticles effectname position(0..1) velocityvector multiplier\n");
			break;
		case "trailparticles":
			IS_CHEAT(0, argc, 0);
			if(argc == 2)
			{
				// arguments:
				//   effectname
				effectnum = particleeffectnum(argv(1));
				W_SetupShot(self, FALSE, FALSE, "", CH_WEAPON_A, 0, self.weapon);
				traceline(w_shotorg, w_shotorg + w_shotdir * MAX_SHOT_DISTANCE, MOVE_NORMAL, self);
				trailparticles(self, effectnum, w_shotorg, trace_endpos);
				DID_CHEAT();
				break;
			}
			sprint(self, "Usage: sv_cheats 1; restart; cmd trailparticles effectname\n");
			break;
		case "make":
			IS_CHEAT(0, argc, 0);
			if(argc == 3)
			{
				// arguments:
				//   modelname mode
				f = stof(argv(2));
				W_SetupShot(self, FALSE, FALSE, "", CH_WEAPON_A, 0, self.weapon);
				traceline(w_shotorg, w_shotorg + w_shotdir * 2048, MOVE_NORMAL, self);
				if((trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT) || trace_fraction == 1)
				{
					sprint(self, "cannot make stuff there (bad surface)\n");
				}
				else
				{
					e = spawn();
					e.model = strzone(argv(1));
					e.mdl = "rocket_explode";
					e.health = 1000;
					setorigin(e, trace_endpos);
					e.effects = EF_NOMODELFLAGS;
					if(f == 1)
					{
						e.angles = fixedvectoangles2(trace_plane_normal, v_forward);
						e.angles = AnglesTransform_ApplyToAngles(e.angles, '-90 0 0'); // so unrotated models work
					}
					oldself = self;
					self = e;
					spawnfunc_func_breakable();
					self = oldself;
					// now, is it valid?
					if(f == 0)
					{
						tracebox(e.origin, e.mins, e.maxs, e.origin, MOVE_NORMAL, e);
						if(trace_startsolid)
						{
							remove(e);
							sprint(self, "cannot make stuff there (no space)\n");
						}
						else
							DID_CHEAT();
					}
					else
						DID_CHEAT();
				}
			}
			else
				sprint(self, "Usage: sv_cheats 1; restart; cmd make models/... 0/1/2\n");
			break;
		case "penalty":
			IS_CHEAT(0, argc, 0);
			if(argc == 3)
			{
				race_ImposePenaltyTime(self, stof(argv(1)), argv(2));
				DID_CHEAT();
				break;
			}
			sprint(self, "Usage: sv_cheats 1; restart; cmd penalty 5.0 AHAHAHAHAHAHAH))\n");
			break;
		case "dragbox_spawn":
			IS_CHEAT(0, argc, 0);
			e = spawn();
			e.classname = "dragbox_box";
			e.think = DragBox_Think;
			e.nextthink = time;
			e.solid = -1; // black
			setmodel(e, "null"); // network it
			if(argc == 4)
				e.cnt = stof(argv(1));
			else
				e.cnt = max(0, drag_lastcnt);

			e.aiment = spawn();
			e.aiment.classname = "dragbox_corner_1";
			e.aiment.owner = e;
			setmodel(e.aiment, "models/marker.md3");
			e.aiment.skin = 0;
			setsize(e.aiment, '0 0 0', '0 0 0');
			if(argc == 4)
				setorigin(e.aiment, stov(argv(2)));
			else
			{
				crosshair_trace(self);
				setorigin(e.aiment, trace_endpos);
			}

			e.enemy = spawn();
			e.enemy.classname = "dragbox_corner_2";
			e.enemy.owner = e;
			setmodel(e.enemy, "models/marker.md3");
			e.enemy.skin = 1;
			setsize(e.enemy, '0 0 0', '0 0 0');
			end = normalize(self.origin + self.view_ofs - e.aiment.origin);
			end_x = (end_x > 0) * 2 - 1;
			end_y = (end_y > 0) * 2 - 1;
			end_z = (end_z > 0) * 2 - 1;
			if(argc == 4)
				setorigin(e.enemy, stov(argv(3)));
			else
				setorigin(e.enemy, e.aiment.origin + 32 * end);

			e.killindicator = spawn();
			e.killindicator.classname = "drag_digit";
			e.killindicator.owner = e;
			setattachment(e.killindicator, e, "");
			setorigin(e.killindicator, '0 0 -8');
			e.killindicator.killindicator = spawn();
			e.killindicator.killindicator.classname = "drag_digit";
			e.killindicator.killindicator.owner = e;
			setattachment(e.killindicator.killindicator, e, "");
			setorigin(e.killindicator.killindicator, '0 0 8');
			DID_CHEAT();
			break;
		case "dragpoint_spawn":
			IS_CHEAT(0, argc, 0);
			e = spawn();
			e.classname = "dragpoint";
			e.think = DragBox_Think;
			e.nextthink = time;
			e.solid = 0; // nothing special
			setmodel(e, "models/marker.md3");
			setsize(e, PL_MIN, PL_MAX);
			e.skin = 2;
			if(argc == 3)
				e.cnt = stof(argv(1));
			else
				e.cnt = drag_lastcnt;
			if(argc == 3)
				setorigin(e, stov(argv(2)));
			else
			{
				crosshair_trace(self);
				setorigin(e, trace_endpos + normalize(self.origin + self.view_ofs - trace_endpos));
				move_out_of_solid(e);
			}

			e.killindicator = spawn();
			e.killindicator.classname = "drag_digit";
			e.killindicator.owner = e;
			setattachment(e.killindicator, e, "");
			setorigin(e.killindicator, '0 0 40');
			e.killindicator.killindicator = spawn();
			e.killindicator.killindicator.classname = "drag_digit";
			e.killindicator.killindicator.owner = e;
			setattachment(e.killindicator.killindicator, e, "");
			setorigin(e.killindicator.killindicator, '0 0 56');
			DID_CHEAT();
			break;
		case "drag_remove":
			IS_CHEAT(0, argc, 0);
			RandomSelection_Init();
			crosshair_trace(self);
			for(e = world; (e = find(e, classname, "dragbox_box")); )
				RandomSelection_Add(e, 0, string_null, 1, 1 / vlen(e.origin + (e.mins + e.maxs) * 0.5 - trace_endpos));
			for(e = world; (e = find(e, classname, "dragpoint")); )
				RandomSelection_Add(e, 0, string_null, 1, 1 / vlen(e.origin + (e.mins + e.maxs) * 0.5 - trace_endpos));
			if(RandomSelection_chosen_ent)
			{
				remove(RandomSelection_chosen_ent.killindicator.killindicator);
				remove(RandomSelection_chosen_ent.killindicator);
				if(RandomSelection_chosen_ent.aiment)
					remove(RandomSelection_chosen_ent.aiment);
				if(RandomSelection_chosen_ent.enemy)
					remove(RandomSelection_chosen_ent.enemy);
				remove(RandomSelection_chosen_ent);
			}
			DID_CHEAT();
			break;
		case "drag_setcnt":
			IS_CHEAT(0, argc, 0);
			if(argc == 2)
			{
				RandomSelection_Init();
				crosshair_trace(self);
				for(e = world; (e = find(e, classname, "dragbox_box")); )
					RandomSelection_Add(e, 0, string_null, 1, 1 / vlen(e.origin + (e.mins + e.maxs) * 0.5 - trace_endpos));
				for(e = world; (e = find(e, classname, "dragpoint")); )
					RandomSelection_Add(e, 0, string_null, 1, 1 / vlen(e.origin + (e.mins + e.maxs) * 0.5 - trace_endpos));
				if(RandomSelection_chosen_ent)
				{
					if(substring(argv(1), 0, 1) == "*")
						RandomSelection_chosen_ent.cnt = drag_lastcnt = RandomSelection_chosen_ent.cnt + stof(substring(argv(1), 1, -1));
					else
						RandomSelection_chosen_ent.cnt = drag_lastcnt = stof(argv(1));
				}
				DID_CHEAT();
				break;
			}
			sprint(self, "Usage: sv_cheats 1; restart; cmd dragbox_setcnt cnt\n");
			break;
		case "drag_save":
			IS_CHEAT(0, argc, 0);
			if(argc == 2)
			{
				f = fopen(argv(1), FILE_WRITE);
				fputs(f, "cmd drag_clear\n");
				for(e = world; (e = find(e, classname, "dragbox_box")); )
				{
					fputs(f, strcat("cmd dragbox_spawn ", ftos(e.cnt), " \"", vtos(e.aiment.origin), "\" \"", vtos(e.enemy.origin), "\"\n"));
				}
				for(e = world; (e = find(e, classname, "dragpoint")); )
				{
					fputs(f, strcat("cmd dragpoint_spawn ", ftos(e.cnt), " \"", vtos(e.origin), "\"\n"));
				}
				fclose(f);
				DID_CHEAT();
				break;
			}
			sprint(self, "Usage: sv_cheats 1; restart; cmd dragbox_save filename\n");
			break;
		case "drag_saveraceent":
			IS_CHEAT(0, argc, 0);
			if(argc == 2)
			{
				f = fopen(argv(1), FILE_WRITE);
				for(e = world; (e = find(e, classname, "dragbox_box")); )
				{
					fputs(f, "{\n");
					fputs(f, "\"classname\" \"trigger_race_checkpoint\"\n");
					fputs(f, strcat("\"origin\" \"", ftos(e.absmin_x), " ", ftos(e.absmin_y), " ", ftos(e.absmin_z), "\"\n"));
					fputs(f, strcat("\"maxs\" \"", ftos(e.absmax_x - e.absmin_x), " ", ftos(e.absmax_y - e.absmin_y), " ", ftos(e.absmax_z - e.absmin_z), "\"\n"));
					fputs(f, strcat("\"cnt\" \"", ftos(e.cnt), "\"\n"));
					fputs(f, strcat("\"targetname\" \"checkpoint", ftos(e.cnt), "\"\n"));
					fputs(f, "}\n");
				}
				for(e = world; (e = find(e, classname, "dragpoint")); )
				{
					start = '0 0 0';
					effectnum = 0;
					for(oldself = world; (oldself = find(oldself, classname, "dragbox_box")); )
					{
						if(e.cnt <= 0 && oldself.cnt == 0 || e.cnt == oldself.cnt)
						{
							start = start + oldself.origin;
							++effectnum;
						}
					}
					start *= 1 / effectnum;
					fputs(f, "{\n");
					fputs(f, "\"classname\" \"info_player_race\"\n");
					fputs(f, strcat("\"angle\" \"", ftos(vectoyaw(start - e.origin)), "\"\n"));
					fputs(f, strcat("\"origin\" \"", ftos(e.origin_x), " ", ftos(e.origin_y), " ", ftos(e.origin_z), "\"\n"));
					if(e.cnt == -2)
					{
						fputs(f, "\"target\" \"checkpoint0\"\n");
						fputs(f, "\"race_place\" \"0\"\n");
					}
					else if(e.cnt == -1)
					{
						fputs(f, "\"target\" \"checkpoint0\"\n");
						fputs(f, "\"race_place\" \"-1\"\n");
					}
					else
					{
						fputs(f, strcat("\"target\" \"checkpoint", ftos(e.cnt), "\"\n"));
						if(e.cnt == 0)
						{
							// these need race_place
							// counting...
							effectnum = 1;
							for(oldself = world; (oldself = find(oldself, classname, "dragpoint")); )
							if(oldself.cnt == 0)
							{
								if(vlen(oldself.origin - start) < vlen(e.origin - start))
									++effectnum;
								else if(vlen(oldself.origin - start) == vlen(e.origin - start) && num_for_edict(oldself) < num_for_edict(e))
									++effectnum;
							}
							fputs(f, strcat("\"race_place\" \"", ftos(effectnum), "\"\n"));
						}
					}
					fputs(f, "}\n");
				}
				fclose(f);
				DID_CHEAT();
				break;
			}
			sprint(self, "Usage: sv_cheats 1; restart; cmd dragbox_save filename\n");
			break;
		case "drag_clear":
			IS_CHEAT(0, argc, 0);
			for(e = world; (e = find(e, classname, "dragbox_box")); )
				remove(e);
			for(e = world; (e = find(e, classname, "dragbox_corner_1")); )
				remove(e);
			for(e = world; (e = find(e, classname, "dragbox_corner_2")); )
				remove(e);
			for(e = world; (e = find(e, classname, "dragpoint")); )
				remove(e);
			for(e = world; (e = find(e, classname, "drag_digit")); )
				remove(e);
			DID_CHEAT();
			break;
		case "god":
			IS_CHEAT(0, argc, 0);
			BITXOR_ASSIGN(self.flags, FL_GODMODE);
			if(self.flags & FL_GODMODE)
			{
				sprint(self, "godmode ON\n");
				DID_CHEAT();
			}
			else
				sprint(self, "godmode OFF\n");
			break;
		case "notarget":
			IS_CHEAT(0, argc, 0);
			BITXOR_ASSIGN(self.flags, FL_NOTARGET);
			if(self.flags & FL_NOTARGET)
			{
				sprint(self, "notarget ON\n");
				DID_CHEAT();
			}
			else
				sprint(self, "notarget OFF\n");
			break;
		case "noclip":
			IS_CHEAT(0, argc, 0);
			if(self.movetype != MOVETYPE_NOCLIP)
			{
				self.movetype = MOVETYPE_NOCLIP;
				sprint(self, "noclip ON\n");
				DID_CHEAT();
			}
			else
			{
				self.movetype = MOVETYPE_WALK;
				sprint(self, "noclip OFF\n");
			}
			break;
		case "fly":
			IS_CHEAT(0, argc, 0);
			if(self.movetype != MOVETYPE_FLY)
			{
				self.movetype = MOVETYPE_FLY;
				sprint(self, "flymode ON\n");
				DID_CHEAT();
			}
			else
			{
				self.movetype = MOVETYPE_WALK;
				sprint(self, "flymode OFF\n");
			}
			break;
		case "give":
			IS_CHEAT(0, argc, 0);
			if(GiveItems(self, 1, argc))
				DID_CHEAT();
			break;
		case "usetarget":
			IS_CHEAT(0, argc, 0);
			e = self;
			self = spawn();
			self.target = argv(1);
			activator = e;
			SUB_UseTargets();
			remove(self);
			self = e;
			DID_CHEAT();
			break;
		case "killtarget":
			IS_CHEAT(0, argc, 0);
			e = self;
			self = spawn();
			self.killtarget = argv(1);
			activator = e;
			SUB_UseTargets();
			remove(self);
			self = e;
			DID_CHEAT();
			break;
		case "teleporttotarget":
			IS_CHEAT(0, argc, 0);
			e = self;
			self = spawn();
			setorigin(self, self.origin);
			self.classname = "cheattriggerteleport";
			self.target = argv(1);
			teleport_findtarget();
			if(!wasfreed(self))
			{
				Simple_TeleportPlayer(self, e);
				remove(self);
				self = e;
				DID_CHEAT();
			}
			else
				self = e;
			break;
	}

	END_CHEAT_FUNCTION();
}

float Drag(float force_allow_pick, float ischeat);
void Drag_Begin(entity dragger, entity draggee, vector touchpoint);
void Drag_Finish(entity dragger);
float Drag_IsDraggable(entity draggee);
float Drag_MayChangeAngles(entity draggee);
void Drag_MoveForward(entity dragger);
void Drag_SetSpeed(entity dragger, float s);
void Drag_MoveBackward(entity dragger);
void Drag_Update(entity dragger);
float Drag_CanDrag(entity dragger);
float Drag_IsDragging(entity dragger);
void Drag_MoveDrag(entity from, entity to);
.entity dragentity;

float CheatFrame()
{
	BEGIN_CHEAT_FUNCTION();

	// Dragging can be used as either a cheat, or a function for some objects. If sv_cheats is active,
	// the cheat dragging is used (unlimited pickup range and any entity can be carried). If sv_cheats
	// is disabled, normal dragging is used (limited pickup range and only dragable objects can be carried),
	// grabbing itself no longer being accounted as cheating.

	switch(0)
	{
		default:
			if(self.maycheat || (gamestart_sv_cheats && autocvar_sv_cheats))
			{
				// use cheat dragging if cheats are enabled
				crosshair_trace_plusvisibletriggers(self);
				Drag(TRUE, TRUE);
			}
			else
			{
				Drag(FALSE, FALSE); // execute dragging
			}
			break;
	}

	END_CHEAT_FUNCTION();
}





// ENTITY DRAGGING

float Drag(float force_allow_pick, float ischeat)
{
	BEGIN_CHEAT_FUNCTION();

	// returns TRUE when an entity has been picked up
	// If pick is TRUE, the object can also be picked up if it's not being held already
	// If pick is FALSE, only keep dragging the object if it's already being held

	switch(0)
	{
		default:
			if(Drag_IsDragging(self))
			{
				if(self.BUTTON_DRAG)
				{
					if(self.impulse == 10 || self.impulse == 15 || self.impulse == 18)
					{
						Drag_MoveForward(self);
						self.impulse = 0;
					}
					else if(self.impulse == 12 || self.impulse == 16 || self.impulse == 19)
					{
						Drag_MoveBackward(self);
						self.impulse = 0;
					}
					else if(self.impulse >= 1 && self.impulse <= 9)
					{
						Drag_SetSpeed(self, self.impulse - 1);
					}
					else if(self.impulse == 14)
					{
						Drag_SetSpeed(self, 9);
					}

					if(frametime)
						Drag_Update(self);
				}
				else
				{
					Drag_Finish(self);
				}
			}
			else
			{
				if(Drag_CanDrag(self))
					if(self.BUTTON_DRAG)
					{
						crosshair_trace_plusvisibletriggers(self);
						entity e = trace_ent;
						float pick = force_allow_pick;
						if (e && !pick)
						{
							// pick is TRUE if the object can be picked up. While an object is being carried, the Drag() function
							// must execute for it either way, otherwise it would cause bugs if it went out of the player's trace.
							// This also makes sure that an object can only pe picked up if in range, but does not get dropped if
							// it goes out of range while slinging it around.

							if(vlen(self.origin - e.origin) <= autocvar_g_grab_range)
							{
								switch(e.grab)
								{
									case 0: // can't grab
										break;
									case 1: // owner can grab
										if(e.owner == self || e.realowner == self)
											pick = TRUE;
										break;
									case 2: // owner and team mates can grab
										if(SAME_TEAM(e.owner, self) || SAME_TEAM(e.realowner, self) || e.team == self.team)
											pick = TRUE;
										break;
									case 3: // anyone can grab
										pick = TRUE;
										break;
									default:
										break;
								}
							}
						}
						// Find e and pick
						if(e && pick)
							if(Drag_IsDraggable(e))
							{
								if(ischeat)
									IS_CHEAT(0, 0, CHRAME_DRAG);
								if(e.draggedby)
									Drag_Finish(e.draggedby);
								if(e.tag_entity)
									detach_sameorigin(e);
								Drag_Begin(self, e, trace_endpos);
								if(ischeat)
									DID_CHEAT();
								return TRUE;
							}
					}
			}
			break;
	}
	return FALSE;
}

// on dragger:
.float draggravity;
.float dragspeed; // speed of mouse wheel action
.float dragdistance; // distance of dragentity's draglocalvector from view_ofs
.vector draglocalvector; // local attachment vector of the dragentity
.float draglocalangle;
// on draggee:
.entity draggedby;
.float dragmovetype;
void Drag_Begin(entity dragger, entity draggee, vector touchpoint)
{
	float tagscale;

	draggee.dragmovetype = draggee.movetype;
	draggee.draggravity = draggee.gravity;
	draggee.movetype = MOVETYPE_WALK;
	draggee.gravity = 0.00001;
	draggee.flags &= ~FL_ONGROUND;
	draggee.draggedby = dragger;

	dragger.dragentity = draggee;

	dragger.dragdistance = vlen(touchpoint - dragger.origin - dragger.view_ofs);
	dragger.draglocalangle = draggee.angles_y - dragger.v_angle_y;
	touchpoint = touchpoint - gettaginfo(draggee, 0);
	tagscale = pow(vlen(v_forward), -2);
	dragger.draglocalvector_x = touchpoint * v_forward * tagscale;
	dragger.draglocalvector_y = touchpoint * v_right * tagscale;
	dragger.draglocalvector_z = touchpoint * v_up * tagscale;

	dragger.dragspeed = 64;
}

void Drag_Finish(entity dragger)
{
	entity draggee;
	draggee = dragger.dragentity;
	if(dragger)
		dragger.dragentity = world;
	draggee.draggedby = world;
	draggee.movetype = draggee.dragmovetype;
	draggee.gravity = draggee.draggravity;

	switch(draggee.movetype)
	{
		case MOVETYPE_TOSS:
		case MOVETYPE_WALK:
		case MOVETYPE_STEP:
		case MOVETYPE_FLYMISSILE:
		case MOVETYPE_BOUNCE:
		case MOVETYPE_BOUNCEMISSILE:
		case MOVETYPE_PHYSICS:
			break;
		default:
			draggee.velocity = '0 0 0';
			break;
	}

	if((draggee.flags & FL_ITEM) && (vlen(draggee.velocity) < 32))
	{
		draggee.velocity = '0 0 0';
		draggee.flags |= FL_ONGROUND; // floating items are FUN
	}
}

float Drag_IsDraggable(entity draggee)
{
	// TODO add more checks for bad stuff here
	if(draggee == world)
		return FALSE;
	if(draggee.classname == "func_bobbing")
		return FALSE;
	if(draggee.classname == "door") // FIXME find out why these must be excluded, or work around the problem (trying to drag these causes like 4 fps)
		return FALSE;
	if(draggee.classname == "plat")
		return FALSE;
	if(draggee.classname == "func_button")
		return FALSE;
//	if(draggee.model == "")
//		return FALSE;
	if(IS_SPEC(draggee))
		return FALSE;
	if(IS_OBSERVER(draggee))
		return FALSE;
	if(draggee.classname == "exteriorweaponentity")
		return FALSE;
	if(draggee.classname == "weaponentity")
		return FALSE;

	return TRUE;
}

float Drag_MayChangeAngles(entity draggee)
{
	// TODO add more checks for bad stuff here
	if(substring(draggee.model, 0, 1) == "*")
		return FALSE;
	return TRUE;
}

void Drag_MoveForward(entity dragger)
{
	dragger.dragdistance += dragger.dragspeed;
}

void Drag_SetSpeed(entity dragger, float s)
{
	dragger.dragspeed = pow(2, s);
}

void Drag_MoveBackward(entity dragger)
{
	dragger.dragdistance = max(0, dragger.dragdistance - dragger.dragspeed);
}

void Drag_Update(entity dragger)
{
	vector curorigin, neworigin, goodvelocity;
	float f;
	entity draggee;

	draggee = dragger.dragentity;
	draggee.flags &= ~FL_ONGROUND;

	curorigin = gettaginfo(draggee, 0);
	curorigin = curorigin + v_forward * dragger.draglocalvector_x + v_right * dragger.draglocalvector_y + v_up * dragger.draglocalvector_z;
	makevectors(dragger.v_angle);
	neworigin = dragger.origin + dragger.view_ofs + v_forward * dragger.dragdistance;
	goodvelocity = (neworigin - curorigin) * (1 / frametime);

	while(draggee.angles_y - dragger.v_angle_y - dragger.draglocalangle > 180)
		dragger.draglocalangle += 360;
	while(draggee.angles_y - dragger.v_angle_y - dragger.draglocalangle <= -180)
		dragger.draglocalangle -= 360;

	f = min(frametime * 10, 1);
	draggee.velocity = draggee.velocity * (1 - f) + goodvelocity * f;

	if(Drag_MayChangeAngles(draggee))
		draggee.angles_y = draggee.angles_y * (1 - f) + (dragger.v_angle_y + dragger.draglocalangle) * f;

	draggee.ltime = max(servertime + serverframetime, draggee.ltime); // fixes func_train breakage

	te_lightning1(dragger, dragger.origin + dragger.view_ofs, curorigin);
}

float Drag_CanDrag(entity dragger)
{
	return (dragger.deadflag == DEAD_NO) || (IS_PLAYER(dragger));
}

float Drag_IsDragging(entity dragger)
{
	if(!dragger.dragentity)
		return FALSE;
	if(wasfreed(dragger.dragentity) || dragger.dragentity.draggedby != dragger)
	{
		dragger.dragentity = world;
		return FALSE;
	}
	if(!Drag_CanDrag(dragger) || !Drag_IsDraggable(dragger.dragentity))
	{
		Drag_Finish(dragger);
		return FALSE;
	}
	return TRUE;
}

void Drag_MoveDrag(entity from, entity to)
{
	if(from.draggedby)
	{
		to.draggedby = from.draggedby;
		to.draggedby.dragentity = to;
		from.draggedby = world;
	}
}

void DragBox_Think()
{
	if(self.aiment && self.enemy)
	{
		self.origin_x = (self.aiment.origin_x + self.enemy.origin_x) * 0.5;
		self.origin_y = (self.aiment.origin_y + self.enemy.origin_y) * 0.5;
		self.origin_z = (self.aiment.origin_z + self.enemy.origin_z) * 0.5;
		self.maxs_x = fabs(self.aiment.origin_x - self.enemy.origin_x) * 0.5;
		self.maxs_y = fabs(self.aiment.origin_y - self.enemy.origin_y) * 0.5;
		self.maxs_z = fabs(self.aiment.origin_z - self.enemy.origin_z) * 0.5;
		self.mins = -1 * self.maxs;
		setorigin(self, self.origin); setsize(self, self.mins, self.maxs); // link edict
	}

	if(self.cnt == -1) // actually race_place -1
	{
		// show "10 10" for qualifying spawns
		setmodel(self.killindicator, "models/sprites/10.spr32");
		setmodel(self.killindicator.killindicator, "models/sprites/10.spr32");
	}
	else if(self.cnt == -2) // actually race_place 0
	{
		// show "10 0" for loser spawns
		setmodel(self.killindicator, "models/sprites/10.spr32");
		setmodel(self.killindicator.killindicator, "models/sprites/0.spr32");
	}
	else
	{
		setmodel(self.killindicator, strcat("models/sprites/", ftos(mod(self.cnt, 10)), ".spr32"));
		setmodel(self.killindicator.killindicator, strcat("models/sprites/", ftos(floor(self.cnt / 10)), ".spr32"));
	}

	self.nextthink = time;
}

#endif
