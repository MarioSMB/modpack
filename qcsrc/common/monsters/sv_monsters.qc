// ==========
//	Monsters
// ==========


void monsters_setstatus()
{
	self.stat_monsters_total = monsters_total;
	self.stat_monsters_killed = monsters_killed;
}

void monster_dropitem()
{
	if(!self.candrop || !self.monster_loot)
		return;

	vector org = self.origin + ((self.mins + self.maxs) * 0.5);
	entity e = spawn(), oldself = self;

	e.monster_loot = self.monster_loot;

	other = e;
	MUTATOR_CALLHOOK(MonsterDropItem);
	e = other;

	if(e && e.monster_loot)
	{
		self = e;
		e.noalign = TRUE;
		e.monster_loot();
		e.gravity = 1;
		e.movetype = MOVETYPE_TOSS;
		e.reset = SUB_Remove;
		setorigin(e, org);
		e.velocity = randomvec() * 175 + '0 0 325';
		e.item_spawnshieldtime = time + 0.7;
		e.classname = "droppedweapon"; // use weapon handling to remove it on touch
		SUB_SetFade(e, time + autocvar_g_monsters_drop_time, 1);
		self = oldself;
	}
}

void monster_makevectors(entity e)
{
	vector v;

	v = e.origin + (e.mins + e.maxs) * 0.5;
	self.v_angle = vectoangles(v - (self.origin + self.view_ofs));
	self.v_angle_x = -self.v_angle_x;

	makevectors(self.v_angle);
}

// ===============
// Target handling
// ===============

float Monster_ValidTarget(entity mon, entity player)
{
	// ensure we're not checking nonexistent monster/target
	if(!mon || !player) { return FALSE; }

	if((player == mon)
	|| (autocvar_g_monsters_lineofsight && !checkpvs(mon.origin + mon.view_ofs, player)) // enemy cannot be seen
	|| (IS_VEHICLE(player) && !((get_monsterinfo(mon.monsterid)).spawnflags & MON_FLAG_RANGED)) // melee vs vehicle is useless
	|| (time < game_starttime) // monsters do nothing before match has started
	|| (player.takedamage == DAMAGE_NO)
	|| (player.items & IT_INVISIBILITY)
	|| (IS_SPEC(player) || IS_OBSERVER(player)) // don't attack spectators
	|| (!IS_VEHICLE(player) && (player.deadflag != DEAD_NO || mon.deadflag != DEAD_NO || player.health <= 0 || mon.health <= 0))
	|| (mon.monster_follow == player || player.monster_follow == mon)
	|| (!IS_VEHICLE(player) && (player.flags & FL_NOTARGET))
	|| (!autocvar_g_monsters_typefrag && player.BUTTON_CHAT)
	|| (SAME_TEAM(player, mon))
	|| (player.frozen)
	|| (player.alpha != 0 && player.alpha < 0.5)
	)
	{
		// if any of the above checks fail, target is not valid
		return FALSE;
	}

	traceline(mon.origin + self.view_ofs, player.origin, 0, mon);

	if((trace_fraction < 1) && (trace_ent != player))
		return FALSE;

	if(autocvar_g_monsters_target_infront || (mon.spawnflags & MONSTERFLAG_INFRONT))
	if(mon.enemy != player)
	{
		float dot;

		makevectors (mon.angles);
		dot = normalize (player.origin - mon.origin) * v_forward;

		if(dot <= 0.3) { return FALSE; }
	}

	return TRUE; // this target is valid!
}

entity Monster_FindTarget(entity mon)
{
	if(MUTATOR_CALLHOOK(MonsterFindTarget)) { return mon.enemy; } // Handled by a mutator

	entity head, closest_target = world;
	head = findradius(mon.origin, mon.target_range);

	while(head) // find the closest acceptable target to pass to
	{
		if(head.monster_attack)
		if(Monster_ValidTarget(mon, head))
		{
			// if it's a player, use the view origin as reference (stolen from RadiusDamage functions in g_damage.qc)
			vector head_center = CENTER_OR_VIEWOFS(head);
			vector ent_center = CENTER_OR_VIEWOFS(mon);

			if(closest_target)
			{
				vector closest_target_center = CENTER_OR_VIEWOFS(closest_target);
				if(vlen(ent_center - head_center) < vlen(ent_center - closest_target_center))
					{ closest_target = head; }
			}
			else { closest_target = head; }
		}

		head = head.chain;
	}

	return closest_target;
}

void monster_setupcolors(entity mon)
{
	if(IS_PLAYER(mon.realowner))
		mon.colormap = mon.realowner.colormap;
	else if(teamplay && mon.team)
		mon.colormap = 1024 + (mon.team - 1) * 17;
	else
	{
		if(mon.monster_skill <= MONSTER_SKILL_EASY)
			mon.colormap = 1029;
		else if(mon.monster_skill <= MONSTER_SKILL_MEDIUM)
			mon.colormap = 1027;
		else if(mon.monster_skill <= MONSTER_SKILL_HARD)
			mon.colormap = 1038;
		else if(mon.monster_skill <= MONSTER_SKILL_INSANE)
			mon.colormap = 1028;
		else if(mon.monster_skill <= MONSTER_SKILL_NIGHTMARE)
			mon.colormap = 1032;
		else
			mon.colormap = 1024;
	}
}

void monster_changeteam(entity ent, float newteam)
{
	if(!teamplay) { return; }
	
	ent.team = newteam;
	ent.monster_attack = TRUE; // new team, activate attacking
	monster_setupcolors(ent);
	
	if(ent.sprite)
	{
		WaypointSprite_UpdateTeamRadar(ent.sprite, RADARICON_DANGER, ((newteam) ? Team_ColorRGB(newteam) : '1 0 0'));

		ent.sprite.team = newteam;
		ent.sprite.SendFlags |= 1;
	}
}

void Monster_Delay_Action()
{
	entity oldself = self;
	self = self.owner;
	if(Monster_ValidTarget(self, self.enemy)) { oldself.use(); }

	if(oldself.cnt > 0)
	{
		oldself.cnt -= 1;
		oldself.think = Monster_Delay_Action;
		oldself.nextthink = time + oldself.respawn_time;
	}
	else
	{
		oldself.think = SUB_Remove;
		oldself.nextthink = time;
	}
}

void Monster_Delay(float repeat_count, float repeat_defer, float defer_amnt, void() func)
{
	// deferred attacking, checks if monster is still alive and target is still valid before attacking
	entity e = spawn();

	e.think = Monster_Delay_Action;
	e.nextthink = time + defer_amnt;
	e.count = defer_amnt;
	e.owner = self;
	e.use = func;
	e.cnt = repeat_count;
	e.respawn_time = repeat_defer;
}


// ==============
// Monster sounds
// ==============

string get_monster_model_datafilename(string m, float sk, string fil)
{
	if(m)
		m = strcat(m, "_");
	else
		m = "models/monsters/*_";
	if(sk >= 0)
		m = strcat(m, ftos(sk));
	else
		m = strcat(m, "*");
	return strcat(m, ".", fil);
}

void Monster_Sound_Precache(string f)
{
	float fh;
	string s;
	fh = fopen(f, FILE_READ);
	if(fh < 0)
		return;
	while((s = fgets(fh)))
	{
		if(tokenize_console(s) != 3)
		{
			dprint("Invalid sound info line: ", s, "\n");
			continue;
		}
		PrecacheGlobalSound(strcat(argv(1), " ", argv(2)));
	}
	fclose(fh);
}

void Monster_Sounds_Precache()
{
	string m = (get_monsterinfo(self.monsterid)).model;
	float globhandle, n, i;
	string f;

	globhandle = search_begin(strcat(m, "_*.sounds"), TRUE, FALSE);
	if (globhandle < 0)
		return;
	n = search_getsize(globhandle);
	for (i = 0; i < n; ++i)
	{
		//print(search_getfilename(globhandle, i), "\n");
		f = search_getfilename(globhandle, i);
		Monster_Sound_Precache(f);
	}
	search_end(globhandle);
}

void Monster_Sounds_Clear()
{
#define _MSOUND(m) if(self.monstersound_##m) { strunzone(self.monstersound_##m); self.monstersound_##m = string_null; }
	ALLMONSTERSOUNDS
#undef _MSOUND
}

.string Monster_Sound_SampleField(string type)
{
	GetMonsterSoundSampleField_notFound = 0;
	switch(type)
	{
#define _MSOUND(m) case #m: return monstersound_##m;
		ALLMONSTERSOUNDS
#undef _MSOUND
	}
	GetMonsterSoundSampleField_notFound = 1;
	return string_null;
}

float Monster_Sounds_Load(string f, float first)
{
	float fh;
	string s;
	var .string field;
	fh = fopen(f, FILE_READ);
	if(fh < 0)
	{
		dprint("Monster sound file not found: ", f, "\n");
		return FALSE;
	}
	while((s = fgets(fh)))
	{
		if(tokenize_console(s) != 3)
			continue;
		field = Monster_Sound_SampleField(argv(0));
		if(GetMonsterSoundSampleField_notFound)
			continue;
		if(self.field)
			strunzone(self.field);
		self.field = strzone(strcat(argv(1), " ", argv(2)));
	}
	fclose(fh);
	return TRUE;
}

.float skin_for_monstersound;
void Monster_Sounds_Update()
{
	if(self.skin == self.skin_for_monstersound) { return; }

	self.skin_for_monstersound = self.skin;
	Monster_Sounds_Clear();
	if(!Monster_Sounds_Load(get_monster_model_datafilename(self.model, self.skin, "sounds"), 0))
		Monster_Sounds_Load(get_monster_model_datafilename(self.model, 0, "sounds"), 0);
}

void Monster_Sound(.string samplefield, float sound_delay, float delaytoo, float chan)
{
	if(!autocvar_g_monsters_sounds) { return; }

	if(delaytoo)
	if(time < self.msound_delay)
		return; // too early
	GlobalSound(self.samplefield, chan, VOICETYPE_PLAYERSOUND);

	self.msound_delay = time + sound_delay;
}


// =======================
// Monster attack handlers
// =======================

float Monster_Attack_Melee(entity targ, float damg, float anim, float er, float anim_finished, float deathtype, float dostop)
{
	if(dostop) { self.state = MONSTER_ATTACK_MELEE; }

	self.frame = anim;

	if(anim_finished > 0) { self.attack_finished_single = time + anim_finished; }

	monster_makevectors(targ);

	traceline(self.origin + self.view_ofs, self.origin + v_forward * er, 0, self);

	if(trace_ent.takedamage)
		Damage(trace_ent, self, self, damg * MONSTER_SKILLMOD(self), deathtype, trace_ent.origin, normalize(trace_ent.origin - self.origin));

	return TRUE;
}

float Monster_Attack_Leap_Check(vector vel)
{
	if(self.state)
		return FALSE; // already attacking
	if(!(self.flags & FL_ONGROUND))
		return FALSE; // not on the ground
	if(self.health <= 0)
		return FALSE; // called when dead?
	if(time < self.attack_finished_single)
		return FALSE; // still attacking

	vector old = self.velocity;

	self.velocity = vel;
	tracetoss(self, self);
	self.velocity = old;
	if (trace_ent != self.enemy)
		return FALSE;

	return TRUE;
}

float Monster_Attack_Leap(float anm, void() touchfunc, vector vel, float anim_finished)
{
	if(!Monster_Attack_Leap_Check(vel))
		return FALSE;

	self.frame = anm;
	self.state = MONSTER_ATTACK_RANGED;
	self.touch = touchfunc;
	self.origin_z += 1;
	self.velocity = vel;
	self.flags &= ~FL_ONGROUND;

	self.attack_finished_single = time + anim_finished;

	return TRUE;
}

void Monster_Attack_Check(entity e, entity targ)
{
	if((e == world || targ == world)
	|| (!e.monster_attackfunc)
	|| (time < e.attack_finished_single)
	) { return; }

	if(vlen(targ.origin - e.origin) <= e.attack_range)
	if(e.monster_attackfunc(MONSTER_ATTACK_MELEE) == 1)
	{
		Monster_Sound(monstersound_melee, 0, FALSE, CH_VOICE);
		return;
	}

	if(vlen(targ.origin - e.origin) > e.attack_range)
	if(e.monster_attackfunc(MONSTER_ATTACK_RANGED) == 1)
	{
		Monster_Sound(monstersound_ranged, 0, FALSE, CH_VOICE);
		return;
	}
}


// ======================
// Main monster functions
// ======================

void Monster_Skin_Check()
{
	vector oldmin = self.mins, oldmax = self.maxs;
	entity mon = get_monsterinfo(self.monsterid);
	string trymodel = sprintf("%s_%d.mdl", substring(mon.model, 0, strlen(mon.model) - 4), self.skin);

	if(fexists(trymodel))
	{
		precache_model(trymodel);
		setmodel(self, trymodel);
		setsize(self, oldmin, oldmax);
		CSQCMODEL_AUTOUPDATE(); // do a quick update
	}

	self.oldskin = self.skin;
}

void Monster_Touch()
{
	if(other == world) { return; }

	if(self.enemy != other)
	if(!IS_MONSTER(other))
	if(Monster_ValidTarget(self, other))
		self.enemy = other;
}

void Monster_Miniboss_Check()
{
	if(MUTATOR_CALLHOOK(MonsterCheckBossFlag))
		return;

	float chance = random() * 100;

	// g_monsters_miniboss_chance cvar or spawnflags 64 causes a monster to be a miniboss
	if ((self.spawnflags & MONSTERFLAG_MINIBOSS) || (chance < autocvar_g_monsters_miniboss_chance))
	{
		self.health += autocvar_g_monsters_miniboss_healthboost;
		self.effects |= EF_RED;
		if(!self.weapon)
			self.weapon = WEP_NEX;
	}
}

float Monster_Respawn_Check()
{
	if(self.spawnflags & MONSTERFLAG_NORESPAWN) { return FALSE; }
	if(!autocvar_g_monsters_respawn) { return FALSE; }

	return TRUE;
}

void Monster_Respawn() { Monster_Spawn(self.monsterid); }

void Monster_Dead_Fade()
{
	if(Monster_Respawn_Check())
	{
		self.spawnflags |= MONSTERFLAG_RESPAWNED;
		self.think = Monster_Respawn;
		self.nextthink = time + self.respawntime;
		self.monster_lifetime = 0;
		self.deadflag = DEAD_RESPAWNING;
		if(self.spawnflags & MONSTER_RESPAWN_DEATHPOINT)
		{
			self.pos1 = self.origin;
			self.pos2 = self.angles;
		}
		self.event_damage = func_null;
		self.takedamage = DAMAGE_NO;
		setorigin(self, self.pos1);
		self.angles = self.pos2;
		self.health = self.max_health;
		setmodel(self, "null");
	}
	else
	{
		// number of monsters spawned with mobspawn command
		totalspawned -= 1;

		SUB_SetFade(self, time + 3, 1);
	}
}

void Monster_Use()
{
	if(Monster_ValidTarget(self, activator)) { self.enemy = activator; }
}

vector Monster_Move_Target(entity targ)
{
	// enemy is always preferred target
	if(self.enemy)
	{
		vector targ_origin = ((self.enemy.absmin + self.enemy.absmax) * 0.5);
		targ_origin = WarpZone_RefSys_TransformOrigin(self.enemy, self, targ_origin); // origin of target as seen by the monster (us)
		WarpZone_TraceLine(self.origin, targ_origin, MOVE_NOMONSTERS, self);
		
		if(    (self.enemy == world)
			|| (self.enemy.deadflag != DEAD_NO || self.enemy.health < 1)
			|| (self.enemy.frozen)
			|| (self.enemy.jb_isprisoned)
			|| (self.enemy.flags & FL_NOTARGET)
			|| (self.enemy.alpha < 0.5)
			|| (self.enemy.takedamage == DAMAGE_NO)
			|| (vlen(self.origin - targ_origin) > self.target_range)
			|| ((trace_fraction < 1) && (trace_ent != self.enemy)))
			//|| (time > self.ctf_droptime + autocvar_g_ctf_pass_timelimit)) // TODO: chase timelimit?
		{
			self.enemy = world;
			self.pass_distance = 0;
		}
		
		if(self.enemy)
		{
			/*WarpZone_TrailParticles(world, particleeffectnum("red_pass"), self.origin, targ_origin);
			print("Trace origin: ", vtos(targ_origin), "\n");
			print("Target origin: ", vtos(self.enemy.origin), "\n");
			print("My origin: ", vtos(self.origin), "\n"); */
			
			self.monster_movestate = MONSTER_MOVE_ENEMY;
			self.last_trace = time + 1.2;
			return targ_origin;
		}
	
		/*makevectors(self.angles);
		self.monster_movestate = MONSTER_MOVE_ENEMY;
		self.last_trace = time + 1.2;
		return self.enemy.origin; */
	}

	switch(self.monster_moveflags)
	{
		case MONSTER_MOVE_FOLLOW:
		{
			self.monster_movestate = MONSTER_MOVE_FOLLOW;
			self.last_trace = time + 0.3;
			return (self.monster_follow) ? self.monster_follow.origin : self.origin;
		}
		case MONSTER_MOVE_SPAWNLOC:
		{
			self.monster_movestate = MONSTER_MOVE_SPAWNLOC;
			self.last_trace = time + 2;
			return self.pos1;
		}
		case MONSTER_MOVE_NOMOVE:
		{
			self.monster_movestate = MONSTER_MOVE_NOMOVE;
			self.last_trace = time + 2;
			return self.origin;
		}
		default:
		case MONSTER_MOVE_WANDER:
		{
			vector pos;
			self.monster_movestate = MONSTER_MOVE_WANDER;
			
			if(targ)
			{
				self.last_trace = time + 0.5;
				pos = targ.origin;
			}
			else
			{
				self.last_trace = time + self.wander_delay;

				self.angles_y = rint(random() * 500);
				makevectors(self.angles);
				pos = self.origin + v_forward * self.wander_distance;

				if(((self.flags & FL_FLY) && (self.spawnflags & MONSTERFLAG_FLY_VERTICAL)) || (self.flags & FL_SWIM))
				{
					pos_z = random() * 200;
					if(random() >= 0.5)
						pos_z *= -1;
				}
			}

			return pos;
		}
	}
}

void Monster_CalculateVelocity(entity mon, vector to, vector from, float turnrate, float movespeed)
{
	float current_distance = vlen((('1 0 0' * to_x) + ('0 1 0' * to_y)) - (('1 0 0' * from_x) + ('0 1 0' * from_y))); // for the sake of this check, exclude Z axis
	float initial_height = 0; //min(50, (targ_distance * tanh(20)));
	float current_height = (initial_height * min(1, (self.pass_distance) ? (current_distance / self.pass_distance) : current_distance));
	//print("current_height = ", ftos(current_height), ", initial_height = ", ftos(initial_height), ".\n");

	vector targpos;
	if(current_height) // make sure we can actually do this arcing path
	{
		targpos = (to + ('0 0 1' * current_height));
		WarpZone_TraceLine(mon.origin, targpos, MOVE_NOMONSTERS, mon);
		if(trace_fraction < 1)
		{
			//print("normal arc line failed, trying to find new pos...");
			WarpZone_TraceLine(to, targpos, MOVE_NOMONSTERS, mon);
			targpos = (trace_endpos + '0 0 -10');
			WarpZone_TraceLine(mon.origin, targpos, MOVE_NOMONSTERS, mon);
			if(trace_fraction < 1) { targpos = to; /* print(" ^1FAILURE^7, reverting to original direction.\n"); */ }
			/*else { print(" ^3SUCCESS^7, using new arc line.\n"); } */
		}
	}
	else { targpos = to; }

	//mon.angles = normalize(('0 1 0' * to_y) - ('0 1 0' * from_y));

	vector desired_direction = normalize(targpos - from);
	if(turnrate) { mon.velocity = (normalize(normalize(mon.velocity) + (desired_direction * 50)) * movespeed); }
	else { mon.velocity = (desired_direction * movespeed); }

	//mon.steerto = steerlib_attract2(targpos, 0.5, 500, 0.95);
	//mon.angles = vectoangles(mon.velocity);
}

void Monster_Move(float runspeed, float walkspeed, float stpspeed, float manim_run, float manim_walk, float manim_idle)
{
	if(self.target2) { self.goalentity = find(world, targetname, self.target2); }

	entity targ;

	if(self.frozen == 2)
	{
		self.revive_progress = bound(0, self.revive_progress + self.ticrate * self.revive_speed, 1);
		self.health = max(1, self.revive_progress * self.max_health);
		self.iceblock.alpha = bound(0.2, 1 - self.revive_progress, 1);

		if(!(self.spawnflags & MONSTERFLAG_INVINCIBLE) && self.sprite)
			WaypointSprite_UpdateHealth(self.sprite, self.health);

		movelib_beak_simple(stpspeed);
		self.frame = manim_idle;

		self.enemy = world;
		self.nextthink = time + self.ticrate;

		if(self.revive_progress >= 1)
			Unfreeze(self);

		return;
	}
	else if(self.frozen == 3)
	{
		self.revive_progress = bound(0, self.revive_progress - self.ticrate * self.revive_speed, 1);
		self.health = max(0, autocvar_g_nades_ice_health + (self.max_health-autocvar_g_nades_ice_health) * self.revive_progress );

		if(!(self.spawnflags & MONSTERFLAG_INVINCIBLE) && self.sprite)
			WaypointSprite_UpdateHealth(self.sprite, self.health);

		movelib_beak_simple(stpspeed);
		self.frame = manim_idle;

		self.enemy = world;
		self.nextthink = time + self.ticrate;

		if(self.health < 1)
		{
			Unfreeze(self);
			self.health = 0;
			self.event_damage(self, self.frozen_by, 1, DEATH_NADE_ICE_FREEZE, self.origin, '0 0 0');
		}

		else if ( self.revive_progress <= 0 )
			Unfreeze(self);

		return;
	}

	if(self.flags & FL_SWIM)
	{
		if(self.waterlevel < WATERLEVEL_WETFEET)
		{
			if(time >= self.last_trace)
			{
				self.last_trace = time + 0.4;

				Damage (self, world, world, 2, DEATH_DROWN, self.origin, '0 0 0');
				self.angles = '90 90 0';
				if(random() < 0.5)
				{
					self.velocity_y += random() * 50;
					self.velocity_x -= random() * 50;
				}
				else
				{
					self.velocity_y -= random() * 50;
					self.velocity_x += random() * 50;
				}
				self.velocity_z += random() * 150;
			}


			self.movetype = MOVETYPE_BOUNCE;
			//self.velocity_z = -200;

			return;
		}
		else if(self.movetype == MOVETYPE_BOUNCE)
		{
			self.angles_x = 0;
			self.movetype = MOVETYPE_WALK;
		}
	}

	targ = self.goalentity;

	monster_target = targ;
	monster_speed_run = runspeed;
	monster_speed_walk = walkspeed;

	if((MUTATOR_CALLHOOK(MonsterMove))
	|| (gameover)
	|| (self.draggedby != world)
	|| (round_handler_IsActive() && !round_handler_IsRoundStarted())
	|| (time < game_starttime)
	|| (autocvar_g_campaign && !campaign_bots_may_start)
	|| (time < self.spawn_time)
	)
	{
		runspeed = walkspeed = 0;
		if(time >= self.spawn_time)
			self.frame = manim_idle;
		movelib_beak_simple(stpspeed);
		return;
	}

	targ = monster_target;
	runspeed = bound(0, monster_speed_run * MONSTER_SKILLMOD(self), runspeed * 2.5); // limit maxspeed to prevent craziness
	walkspeed = bound(0, monster_speed_walk * MONSTER_SKILLMOD(self), walkspeed * 2.5); // limit maxspeed to prevent craziness

	if(time < self.spider_slowness)
	{
		runspeed *= 0.5;
		walkspeed *= 0.5;
	}

	if(teamplay)
	if(autocvar_g_monsters_teams)
	if(DIFF_TEAM(self.monster_follow, self))
		self.monster_follow = world;

	if(time >= self.last_enemycheck)
	{
		if(!self.enemy)
		{
			self.enemy = Monster_FindTarget(self);
			if(self.enemy)
			{
				WarpZone_RefSys_Copy(self.enemy, self);
				WarpZone_RefSys_AddInverse(self.enemy, self); // wz1^-1 ... wzn^-1 receiver
				self.moveto = WarpZone_RefSys_TransformOrigin(self.enemy, self, (0.5 * (self.enemy.absmin + self.enemy.absmax)));
				
				self.pass_distance = vlen((('1 0 0' * self.enemy.origin_x) + ('0 1 0' * self.enemy.origin_y)) - (('1 0 0' *  self.origin_x) + ('0 1 0' *  self.origin_y)));
				Monster_Sound(monstersound_sight, 0, FALSE, CH_VOICE);
			}
		}

		self.last_enemycheck = time + 1; // check for enemies every second
	}

	if(self.state == MONSTER_ATTACK_RANGED && (self.flags & FL_ONGROUND))
	{
		self.state = 0;
		self.touch = Monster_Touch;
	}

	if(self.state && time >= self.attack_finished_single)
		self.state = 0; // attack is over

	if(self.state != MONSTER_ATTACK_MELEE) // don't move if set
	if(time >= self.last_trace || self.enemy) // update enemy instantly
		self.moveto = Monster_Move_Target(targ);

	if(!self.enemy)
		Monster_Sound(monstersound_idle, 7, TRUE, CH_VOICE);

	if(self.state == MONSTER_ATTACK_MELEE)
		self.moveto = self.origin;

	if(self.enemy && self.enemy.vehicle)
		runspeed = 0;

	if(!(((self.flags & FL_FLY) && (self.spawnflags & MONSTERFLAG_FLY_VERTICAL)) || (self.flags & FL_SWIM)))
		//v_forward = normalize(self.moveto - self.origin);
	//else
		self.moveto_z = self.origin_z;

	if(vlen(self.origin - self.moveto) > 64)
	{
		if((self.flags & FL_ONGROUND) || ((self.flags & FL_FLY) || (self.flags & FL_SWIM)))
			Monster_CalculateVelocity(self, self.moveto, self.origin, TRUE, ((self.enemy) ? runspeed : walkspeed));

		if(time > self.pain_finished)
		if(!self.state)
		//if(time > self.attack_finished_single)
		if(vlen(self.velocity) > 10)
			self.frame = ((self.enemy) ? manim_run : manim_walk);
		else
			self.frame = manim_idle;
	}
	else
	{
		entity e = find(world, targetname, self.target2);
		if(e.target2)
			self.target2 = e.target2;
		else if(e.target)
			self.target2 = e.target;

		movelib_beak_simple(stpspeed);
		//if(time > self.attack_finished_single)
		if(time > self.pain_finished)
		if(!self.state)
		if (vlen(self.velocity) <= 30)
			self.frame = manim_idle;
	}
	
	self.steerto = steerlib_attract2(self.moveto, 0.5, 500, 0.95);
	
	vector real_angle = vectoangles(self.steerto) - self.angles;
	float turny = 25;
	if(self.state == MONSTER_ATTACK_MELEE)
		turny = 0;
	if(turny)
	{
		turny = bound(turny * -1, shortangle_f(real_angle_y, self.angles_y), turny);
		self.angles_y += turny;
	}

	Monster_Attack_Check(self, self.enemy);
}

void Monster_Remove(entity mon)
{
	if(!mon) { return; }

	if(!MUTATOR_CALLHOOK(MonsterRemove))
		pointparticles(particleeffectnum("spawn_event_neutral"), mon.origin, '0 0 0', 1);

	if(mon.weaponentity) { remove(mon.weaponentity); }
	if(mon.iceblock) { remove(mon.iceblock); }
	WaypointSprite_Kill(mon.sprite);
	remove(mon);
}

void Monster_Dead_Think()
{
	self.nextthink = time + self.ticrate;

	CSQCMODEL_AUTOUPDATE();

	if(self.monster_lifetime != 0)
	if(time >= self.monster_lifetime)
	{
		Monster_Dead_Fade();
		return;
	}
}

void Monster_Appear()
{
	self.enemy = activator;
	self.spawnflags &= ~MONSTERFLAG_APPEAR; // otherwise, we get an endless loop
	Monster_Spawn(self.monsterid);
}

float Monster_Appear_Check(entity ent, float monster_id)
{
	if(!(ent.spawnflags & MONSTERFLAG_APPEAR))
		return FALSE;

	ent.think = func_null;
	ent.monsterid = monster_id; // set so this monster is properly registered (otherwise, normal initialization is used)
	ent.nextthink = 0;
	ent.use = Monster_Appear;
	ent.flags = FL_MONSTER; // set so this monster can get butchered

	return TRUE;
}

void Monster_Reset()
{
	setorigin(self, self.pos1);
	self.angles = self.pos2;

	Unfreeze(self); // remove any icy remains

	self.health = self.max_health;
	self.velocity = '0 0 0';
	self.enemy = world;
	self.goalentity = world;
	self.attack_finished_single = 0;
	self.moveto = self.origin;
}

void Monster_Dead_Damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	self.health -= damage;

	Violence_GibSplash_At(hitloc, force, 2, bound(0, damage, 200) / 16, self, attacker);

	if(self.health <= -100) // 100 health until gone?
	{
		Violence_GibSplash_At(hitloc, force, 2, bound(0, damage, 200) / 16, self, attacker);

		// number of monsters spawned with mobspawn command
		totalspawned -= 1;

		self.think = SUB_Remove;
		self.nextthink = time + 0.1;
		self.event_damage = func_null;
	}
}

void Monster_Dead(entity attacker, float gibbed)
{
	self.think = Monster_Dead_Think;
	self.nextthink = time;
	self.monster_lifetime = time + 5;

	if(self.frozen)
	{
		Unfreeze(self); // remove any icy remains
		self.health = 0; // reset by Unfreeze
	}

	monster_dropitem();

	Monster_Sound(monstersound_death, 0, FALSE, CH_VOICE);

	if(!(self.spawnflags & MONSTERFLAG_SPAWNED) && !(self.spawnflags & MONSTERFLAG_RESPAWNED))
		monsters_killed += 1;

	if(IS_PLAYER(attacker))
	if(autocvar_g_monsters_score_spawned || !((self.spawnflags & MONSTERFLAG_SPAWNED) || (self.spawnflags & MONSTERFLAG_RESPAWNED)))
		PlayerScore_Add(attacker, SP_SCORE, +autocvar_g_monsters_score_kill);

	if(gibbed)
	{
		// number of monsters spawned with mobspawn command
		totalspawned -= 1;
	}

	self.event_damage	= ((gibbed) ? func_null : Monster_Dead_Damage);
	self.solid			= SOLID_CORPSE;
	self.takedamage		= DAMAGE_AIM;
	self.deadflag		= DEAD_DEAD;
	self.enemy			= world;
	self.movetype		= MOVETYPE_TOSS;
	self.moveto			= self.origin;
	self.touch			= Monster_Touch; // reset incase monster was pouncing
	self.reset			= func_null;
	self.state			= 0;
	self.attack_finished_single = 0;
	self.effects = 0;

	if(!((self.flags & FL_FLY) || (self.flags & FL_SWIM)))
		self.velocity = '0 0 0';

	MON_ACTION(self.monsterid, MR_DEATH);

	if(self.candrop && self.weapon)
		W_ThrowNewWeapon(self, self.weapon, 0, self.origin, randomvec() * 150 + '0 0 325');
}

void Monster_Damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if((self.spawnflags & MONSTERFLAG_INVINCIBLE) && deathtype != DEATH_KILL)
		return;

	if(self.frozen && deathtype != DEATH_KILL && deathtype != DEATH_NADE_ICE_FREEZE)
		return;

	//if(time < self.pain_finished && deathtype != DEATH_KILL)
		//return;

	if(time < self.spawnshieldtime && deathtype != DEATH_KILL)
		return;

	if(deathtype == DEATH_FALL && self.draggedby != world)
		return;

	vector v;
	float take, save;

	v = healtharmor_applydamage(100, self.armorvalue / 100, deathtype, damage, autocvar_g_balance_armor_block_bycount);
	take = v_x;
	save = v_y;

	damage_take = take;
	frag_attacker = attacker;
	frag_deathtype = deathtype;
	MON_ACTION(self.monsterid, MR_PAIN);
	take = damage_take;

	if(take)
	{
		self.health -= take;
		Monster_Sound(monstersound_pain, 1.2, TRUE, CH_PAIN);
	}

	if(self.sprite)
		WaypointSprite_UpdateHealth(self.sprite, self.health);

	self.dmg_time = time;

	if(sound_allowed(MSG_BROADCAST, attacker) && deathtype != DEATH_DROWN)
		spamsound (self, CH_PAIN, "misc/bodyimpact1.wav", VOL_BASE, ATTEN_NORM);  // FIXME: PLACEHOLDER

	self.velocity += force * self.damageforcescale;

	if(deathtype != DEATH_DROWN && take)
	{
		Violence_GibSplash_At(hitloc, force, 2, bound(0, take, 200) / 16, self, attacker);
		if (take > 50)
			Violence_GibSplash_At(hitloc, force * -0.1, 3, 1, self, attacker);
		if (take > 100)
			Violence_GibSplash_At(hitloc, force * -0.2, 3, 1, self, attacker);
	}

	if(self.health <= 0)
	{
		if(deathtype == DEATH_KILL)
			self.candrop = FALSE; // killed by mobkill command

		// TODO: fix this?
		activator = attacker;
		other = self.enemy;
		SUB_UseTargets();
		self.target2 = self.oldtarget2; // reset to original target on death, incase we respawn

		Monster_Dead(attacker, (self.health <= -100 || deathtype == DEATH_KILL));

		WaypointSprite_Kill(self.sprite);

		frag_attacker = attacker;
		frag_target = self;
		MUTATOR_CALLHOOK(MonsterDies);

		if(self.health <= -100 || deathtype == DEATH_KILL) // check if we're already gibbed
		{
			Violence_GibSplash(self, 1, 0.5, attacker);

			self.think = SUB_Remove;
			self.nextthink = time + 0.1;
		}
	}
}

void Monster_Think()
{
	self.think = Monster_Think;
	self.nextthink = self.ticrate;

	if(self.monster_lifetime)
	if(time >= self.monster_lifetime)
	{
		Damage(self, self, self, self.health + self.max_health, DEATH_KILL, self.origin, self.origin);
		return;
	}

	if(self.skin != self.oldskin) { Monster_Skin_Check(); }

	MON_ACTION(self.monsterid, MR_THINK);

	Monster_Move(self.speed2, self.speed, self.stopspeed, self.m_anim_run, self.m_anim_walk, self.m_anim_idle);

	CSQCMODEL_AUTOUPDATE();
}

float Monster_Spawn_Setup()
{
	MON_ACTION(self.monsterid, MR_SETUP);

	// ensure some basic needs are met
	if(!self.health) { self.health = 100; }
	if(!self.armorvalue) { self.armorvalue = bound(0.2, 0.5 * MONSTER_SKILLMOD(self), 0.9); }
	if(!self.target_range) { self.target_range = autocvar_g_monsters_target_range; }
	if(!self.respawntime) { self.respawntime = autocvar_g_monsters_respawn_delay; }
	if(!self.monster_moveflags) { self.monster_moveflags = MONSTER_MOVE_WANDER; }
	if(!self.attack_range) { self.attack_range = autocvar_g_monsters_attack_range; }

	if(!(self.spawnflags & MONSTERFLAG_RESPAWNED))
	{
		Monster_Miniboss_Check();
		self.health *= MONSTER_SKILLMOD(self);

		if(!self.skin)
			self.skin = rint(random() * 4);

		Monster_Skin_Check();
	}

	self.max_health = self.health;
	self.pain_finished = self.nextthink;

	if(IS_PLAYER(self.monster_follow))
		self.effects |= EF_DIMLIGHT;
		
	if(!self.wander_delay) { self.wander_delay = 2; }
	if(!self.wander_distance) { self.wander_distance = 600; }

	Monster_Sounds_Precache();
	Monster_Sounds_Update();

	if(teamplay)
		self.monster_attack = TRUE; // we can have monster enemies in team games

	Monster_Sound(monstersound_spawn, 0, FALSE, CH_VOICE);

	if(autocvar_g_monsters_healthbars)
	{
		WaypointSprite_Spawn(self.monster_name, 0, 1024, self, '0 0 1' * (self.maxs_z + 15), world, self.team, 
							 self, sprite, TRUE, RADARICON_DANGER, ((self.team) ? Team_ColorRGB(self.team) : '1 0 0'));

		if(!(self.spawnflags & MONSTERFLAG_INVINCIBLE))
		{
			WaypointSprite_UpdateMaxHealth(self.sprite, self.max_health);
			WaypointSprite_UpdateHealth(self.sprite, self.health);
		}
	}

	self.think = Monster_Think;
	self.nextthink = time + self.ticrate;

	if(MUTATOR_CALLHOOK(MonsterSpawn))
		return FALSE;

	return TRUE;
}

float Monster_Spawn(float mon_id)
{
	// setup the basic required properties for a monster
	entity mon = get_monsterinfo(mon_id);
	if(!mon.monsterid) { return FALSE; } // invalid monster

	if(!autocvar_g_monsters) { Monster_Remove(self); return FALSE; }

	self.mdl = mon.model;
	if(!(self.spawnflags & MONSTERFLAG_RESPAWNED)) { precache_model(self.mdl); }
	if(!(self.spawnflags & MONSTERFLAG_RESPAWNED)) { MON_ACTION(mon_id, MR_PRECACHE); }
	if(Monster_Appear_Check(self, mon_id)) { return TRUE; } // return true so the monster isn't removed

	if(!self.monster_skill)
		self.monster_skill = cvar("g_monsters_skill");

	// support for quake style removing monsters based on skill
	if(self.monster_skill == MONSTER_SKILL_EASY) if(self.spawnflags & MONSTERSKILL_NOTEASY) { Monster_Remove(self); return FALSE; }
	if(self.monster_skill == MONSTER_SKILL_MEDIUM) if(self.spawnflags & MONSTERSKILL_NOTMEDIUM) { Monster_Remove(self); return FALSE; }
	if(self.monster_skill == MONSTER_SKILL_HARD) if(self.spawnflags & MONSTERSKILL_NOTHARD) { Monster_Remove(self); return FALSE; }

	if(self.team && !teamplay)
		self.team = 0;

	if(!(self.spawnflags & MONSTERFLAG_SPAWNED)) // naturally spawned monster
	if(!(self.spawnflags & MONSTERFLAG_RESPAWNED)) // don't count re-spawning monsters either
		monsters_total += 1;

	setmodel(self, self.mdl);
	self.flags				= FL_MONSTER;
	self.classname			= "monster";
	self.takedamage			= DAMAGE_AIM;
	self.bot_attack			= TRUE;
	self.iscreature			= TRUE;
	self.teleportable		= TRUE;
	self.damagedbycontents	= TRUE;
	self.monsterid			= mon_id;
	self.damageforcescale	= 0;
	self.event_damage		= Monster_Damage;
	self.touch				= Monster_Touch;
	self.use				= Monster_Use;
	self.solid				= SOLID_BBOX;
	self.movetype			= MOVETYPE_WALK;
	self.spawnshieldtime	= time + autocvar_g_monsters_spawnshieldtime;
	self.enemy				= world;
	self.velocity			= '0 0 0';
	self.moveto				= self.origin;
	self.pos1				= self.origin;
	self.pos2				= self.angles;
	self.reset				= Monster_Reset;
	self.netname			= mon.netname;
	self.monster_attackfunc	= mon.monster_attackfunc;
	self.monster_name		= mon.monster_name;
	self.candrop			= TRUE;
	self.view_ofs			= '0 0 0.7' * (self.maxs_z * 0.5);
	self.oldtarget2			= self.target2;
	self.pass_distance		= 0;
	self.deadflag			= DEAD_NO;
	self.noalign			= ((mon.spawnflags & MONSTER_TYPE_FLY) || (mon.spawnflags & MONSTER_TYPE_SWIM));
	self.spawn_time			= time;
	self.spider_slowness	= 0;
	self.gravity			= 1;
	self.dphitcontentsmask	= DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_BOTCLIP | DPCONTENTS_MONSTERCLIP;
	
	if(!self.scale) { self.scale = 1; }
	if(autocvar_g_monsters_edit) { self.grab = 1; }
	if(autocvar_g_fullbrightplayers) { self.effects |= EF_FULLBRIGHT; }
	if(autocvar_g_nodepthtestplayers) { self.effects |= EF_NODEPTHTEST; }
	if(mon.spawnflags & MONSTER_TYPE_SWIM) { self.flags |= FL_SWIM; }

	if(mon.spawnflags & MONSTER_TYPE_FLY)
	{
		self.flags |= FL_FLY;
		self.movetype = MOVETYPE_FLY;
	}

	if(mon.spawnflags & MONSTER_SIZE_BROKEN)
	if(!(self.spawnflags & MONSTERFLAG_RESPAWNED))
		self.scale *= 1.3;
		
	setsize(self, mon.mins * self.scale, mon.maxs * self.scale);

	self.ticrate = bound(sys_frametime, ((!self.ticrate) ? autocvar_g_monsters_think_delay : self.ticrate), 60);

	if(!self.noalign)
	{
		setorigin(self, self.origin + '0 0 20');
		tracebox(self.origin + '0 0 64', self.mins, self.maxs, self.origin - '0 0 10000', MOVE_WORLDONLY, self);
		setorigin(self, trace_endpos);
	}

	if(!Monster_Spawn_Setup())
	{
		Monster_Remove(self);
		return FALSE;
	}

	if(!(self.spawnflags & MONSTERFLAG_RESPAWNED))
		monster_setupcolors(self);

	CSQCMODEL_AUTOINIT();

	return TRUE;
}
