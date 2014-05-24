// =======================
// CaptureShield Functions
// =======================

float ons_CaptureShield_Customize()
{
	entity e = WaypointSprite_getviewentity(other);

	if(!self.enemy.isshielded && (ons_ControlPoint_Attackable(self.enemy, e.team) > 0 || self.enemy.classname != "onslaught_controlpoint")) { return FALSE; }
	if(SAME_TEAM(self, e)) { return FALSE; }

	return TRUE;
}

void ons_CaptureShield_Touch()
{
	if(!self.enemy.isshielded && (ons_ControlPoint_Attackable(self.enemy, other.team) > 0 || self.enemy.classname != "onslaught_controlpoint")) { return; }
	if(!IS_PLAYER(other)) { return; }
	if(SAME_TEAM(other, self)) { return; }

	vector mymid = (self.absmin + self.absmax) * 0.5;
	vector othermid = (other.absmin + other.absmax) * 0.5;

	Damage(other, self, self, 0, DEATH_HURTTRIGGER, mymid, normalize(othermid - mymid) * ons_captureshield_force);

	if(IS_REAL_CLIENT(other))
	{
		play2(other, "onslaught/damageblockedbyshield.wav");

		if(self.enemy.classname == "onslaught_generator")
			Send_Notification(NOTIF_ONE, other, MSG_CENTER, CENTER_ONS_GENERATOR_SHIELDED);
		else
			Send_Notification(NOTIF_ONE, other, MSG_CENTER, CENTER_ONS_CONTROLPOINT_SHIELDED);
	}
}

void ons_CaptureShield_Reset()
{
	self.colormap = self.enemy.colormap;
	self.team = self.enemy.team;
}

void ons_CaptureShield_Spawn(entity generator, float is_generator)
{
	entity shield = spawn();

	shield.enemy = generator;
	shield.team = generator.team;
	shield.colormap = generator.colormap;
	shield.reset = ons_CaptureShield_Reset;
	shield.touch = ons_CaptureShield_Touch;
	shield.customizeentityforclient = ons_CaptureShield_Customize;
	shield.classname = "ons_captureshield";
	shield.effects = EF_ADDITIVE;
	shield.movetype = MOVETYPE_NOCLIP;
	shield.solid = SOLID_TRIGGER;
	shield.avelocity = '7 0 11';
	shield.scale = 1;
	shield.model = ((is_generator) ? "models/onslaught/generator_shield.md3" : "models/onslaught/controlpoint_shield.md3");
	
	precache_model(shield.model);
	setorigin(shield, generator.origin);
	setmodel(shield, shield.model);
	setsize(shield, shield.scale * shield.mins, shield.scale * shield.maxs);
}


// ==========
// Junk Pile
// ==========

void ons_debug(string input)
{
	switch(autocvar_g_onslaught_debug)
	{
		case 1: dprint(input); break;
		case 2: print(input); break;
	}
}

void onslaught_updatelinks()
{
	entity l;
	// first check if the game has ended
	ons_debug("--- updatelinks ---\n");
	// mark generators as being shielded and networked
	for(l = ons_worldgeneratorlist; l; l = l.ons_worldgeneratornext)
	{
		if (l.iscaptured)
			ons_debug(strcat(etos(l), " (generator) belongs to team ", ftos(l.team), "\n"));
		else
			ons_debug(strcat(etos(l), " (generator) is destroyed\n"));
		l.islinked = l.iscaptured;
		l.isshielded = l.iscaptured;
		l.sprite.SendFlags |= 16;
	}
	// mark points as shielded and not networked
	for(l = ons_worldcplist; l; l = l.ons_worldcpnext)
	{
		l.islinked = FALSE;
		l.isshielded = TRUE;
		float i;
		for(i = 0; i < 17; ++i) { l.isgenneighbor[i] = FALSE; l.iscpneighbor[i] = FALSE; }
		ons_debug(strcat(etos(l), " (point) belongs to team ", ftos(l.team), "\n"));
		l.sprite.SendFlags |= 16;
	}
	// flow power outward from the generators through the network
	float stop = FALSE;
	while (!stop)
	{
		stop = TRUE;
		for(l = ons_worldlinklist; l; l = l.ons_worldlinknext)
		{
			// if both points are captured by the same team, and only one of
			// them is powered, mark the other one as powered as well
			if (l.enemy.iscaptured && l.goalentity.iscaptured)
				if (l.enemy.islinked != l.goalentity.islinked)
					if(SAME_TEAM(l.enemy, l.goalentity))
					{
						if (!l.goalentity.islinked)
						{
							stop = FALSE;
							l.goalentity.islinked = TRUE;
							ons_debug(strcat(etos(l), " (link) is marking ", etos(l.goalentity), " (point) because its team matches ", etos(l.enemy), " (point)\n"));
						}
						else if (!l.enemy.islinked)
						{
							stop = FALSE;
							l.enemy.islinked = TRUE;
							ons_debug(strcat(etos(l), " (link) is marking ", etos(l.enemy), " (point) because its team matches ", etos(l.goalentity), " (point)\n"));
						}
					}
		}
	}
	// now that we know which points are powered we can mark their neighbors
	// as unshielded if team differs
	for(l = ons_worldlinklist; l; l = l.ons_worldlinknext)
	{
		if (l.goalentity.islinked)
		{
			if(DIFF_TEAM(l.goalentity, l.enemy))
			{
				ons_debug(strcat(etos(l), " (link) is unshielding ", etos(l.enemy), " (point) because its team does not match ", etos(l.goalentity), " (point)\n"));
				l.enemy.isshielded = FALSE;
			}
			if(l.goalentity.classname == "onslaught_generator")
				l.enemy.isgenneighbor[l.goalentity.team] = TRUE;
			else
				l.enemy.iscpneighbor[l.goalentity.team] = TRUE;
		}
		if (l.enemy.islinked)
		{
			if(DIFF_TEAM(l.goalentity, l.enemy))
			{
				ons_debug(strcat(etos(l), " (link) is unshielding ", etos(l.goalentity), " (point) because its team does not match ", etos(l.enemy), " (point)\n"));
				l.goalentity.isshielded = FALSE;
			}
			if(l.enemy.classname == "onslaught_generator")
				l.goalentity.isgenneighbor[l.enemy.team] = TRUE;
			else
				l.goalentity.iscpneighbor[l.enemy.team] = TRUE;
		}
	}
	// now update the generators
	for(l = ons_worldgeneratorlist; l; l = l.ons_worldgeneratornext)
	{
		if (l.isshielded)
		{
			ons_debug(strcat(etos(l), " (generator) is shielded\n"));
			l.takedamage = DAMAGE_NO;
			l.bot_attack = FALSE;
		}
		else
		{
			ons_debug(strcat(etos(l), " (generator) is not shielded\n"));
			l.takedamage = DAMAGE_AIM;
			l.bot_attack = TRUE;
		}

		ons_Generator_UpdateSprite(l);
	}
	// now update the takedamage and alpha variables on control point icons
	for(l = ons_worldcplist; l; l = l.ons_worldcpnext)
	{
		if (l.isshielded)
		{
			ons_debug(strcat(etos(l), " (point) is shielded\n"));
			if (l.goalentity)
			{
				l.goalentity.takedamage = DAMAGE_NO;
				l.goalentity.bot_attack = FALSE;
			}
		}
		else
		{
			ons_debug(strcat(etos(l), " (point) is not shielded\n"));
			if (l.goalentity)
			{
				l.goalentity.takedamage = DAMAGE_AIM;
				l.goalentity.bot_attack = TRUE;
			}
		}
		ons_ControlPoint_UpdateSprite(l);
	}
	l = findchain(classname, "ons_captureshield");
	while(l)
	{
		l.team = l.enemy.team;
		l.colormap = l.enemy.colormap;
		l = l.chain;
	}
}


// ===================
// Main Link Functions
// ===================

float ons_Link_Send(entity to, float sendflags)
{
	WriteByte(MSG_ENTITY, ENT_CLIENT_RADARLINK);
	WriteByte(MSG_ENTITY, sendflags);
	if(sendflags & 1)
	{
		WriteCoord(MSG_ENTITY, self.goalentity.origin_x);
		WriteCoord(MSG_ENTITY, self.goalentity.origin_y);
		WriteCoord(MSG_ENTITY, self.goalentity.origin_z);
	}
	if(sendflags & 2)
	{
		WriteCoord(MSG_ENTITY, self.enemy.origin_x);
		WriteCoord(MSG_ENTITY, self.enemy.origin_y);
		WriteCoord(MSG_ENTITY, self.enemy.origin_z);
	}
	if(sendflags & 4)
	{
		WriteByte(MSG_ENTITY, self.clientcolors); // which is goalentity's color + enemy's color * 16
	}
	return TRUE;
}

void ons_Link_CheckUpdate()
{
	// TODO check if the two sides have moved (currently they won't move anyway)
	float cc = 0, cc1 = 0, cc2 = 0;
	
	if(self.goalentity.islinked || self.goalentity.iscaptured) { cc1 = (self.goalentity.team - 1) * 0x01; }
	if(self.enemy.islinked || self.enemy.iscaptured) { cc2 = (self.enemy.team - 1) * 0x10; }
	
	cc = cc1 + cc2;

	if(cc != self.clientcolors)
	{
		self.clientcolors = cc;
		self.SendFlags |= 4;
	}

	self.nextthink = time;
}

void ons_DelayedLinkSetup()
{
	self.goalentity = find(world, targetname, self.target);
	self.enemy = find(world, targetname, self.target2);
	if(!self.goalentity) { objerror("can not find target\n"); }
	if(!self.enemy) { objerror("can not find target2\n"); }

	ons_debug(strcat(etos(self.goalentity), " linked with ", etos(self.enemy), "\n"));
	self.SendFlags |= 3;
	self.think = ons_Link_CheckUpdate;
	self.nextthink = time;
}


// =============================
// Main Control Point Functions
// =============================

float ons_ControlPoint_CanBeLinked(entity cp, float teamnumber)
{
	if(cp.isgenneighbor[teamnumber]) { return 2; }
	if(cp.iscpneighbor[teamnumber]) { return 1; }

	return 0;
}

float ons_ControlPoint_Attackable(entity cp, float teamnumber)
	// -2: SAME TEAM, attackable by enemy!
	// -1: SAME TEAM!
	// 0: off limits
	// 1: attack it
	// 2: touch it
	// 3: attack it (HIGH PRIO)
	// 4: touch it (HIGH PRIO)
{
	float a;

	if(cp.isshielded)
	{
		return 0;
	}
	else if(cp.goalentity)
	{
		// if there's already an icon built, nothing happens
		if(cp.team == teamnumber)
		{
			a = ons_ControlPoint_CanBeLinked(cp, teamnumber);
			if(a) // attackable by enemy?
				return -2; // EMERGENCY!
			return -1;
		}
		// we know it can be linked, so no need to check
		// but...
		a = ons_ControlPoint_CanBeLinked(cp, teamnumber);
		if(a == 2) // near our generator?
			return 3; // EMERGENCY!
		return 1;
	}
	else
	{
		// free point
		if(ons_ControlPoint_CanBeLinked(cp, teamnumber))
		{
			a = ons_ControlPoint_CanBeLinked(cp, teamnumber); // why was this here NUM_TEAM_1 + NUM_TEAM_2 - t
			if(a == 2)
				return 4; // GET THIS ONE NOW!
			else
				return 2; // TOUCH ME
		}
	}
	return 0;
}

void ons_ControlPoint_Icon_Damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	entity oself;
	
	if(damage <= 0) { return; }

	if (self.owner.isshielded)
	{
		// this is protected by a shield, so ignore the damage
		if (time > self.pain_finished)
			if (IS_PLAYER(attacker))
			{
				play2(attacker, "onslaught/damageblockedbyshield.wav");
				self.pain_finished = time + 1;
				attacker.typehitsound += 1; // play both sounds (shield is way too quiet)
			}

		return;
	}

	if(IS_PLAYER(attacker))
	if(time - ons_notification_time[self.team] > 10)
	{
		play2team(self.team, "onslaught/controlpoint_underattack.wav");
		ons_notification_time[self.team] = time;
	}

	self.health = self.health - damage;
	if(self.owner.iscaptured)
		WaypointSprite_UpdateHealth(self.owner.sprite, self.health);
	else
		WaypointSprite_UpdateBuildFinished(self.owner.sprite, time + (self.max_health - self.health) / (self.count / CP_THINKRATE));
	self.pain_finished = time + 1;
	// particles on every hit
	pointparticles(particleeffectnum("sparks"), hitloc, force*-1, 1);
	//sound on every hit
	if (random() < 0.5)
		sound(self, CH_TRIGGER, "onslaught/ons_hit1.wav", VOL_BASE+0.3, ATTEN_NORM);
	else
		sound(self, CH_TRIGGER, "onslaught/ons_hit2.wav", VOL_BASE+0.3, ATTEN_NORM);

	if (self.health < 0)
	{
		sound(self, CH_TRIGGER, "weapons/grenade_impact.wav", VOL_BASE, ATTEN_NORM);
		pointparticles(particleeffectnum("rocket_explode"), self.origin, '0 0 0', 1);
		Send_Notification(NOTIF_ALL, world, MSG_INFO, APP_TEAM_NUM_4(self.team, INFO_ONSLAUGHT_CPDESTROYED_), self.owner.message, attacker.netname);
		
		PlayerScore_Add(attacker, SP_ONS_TAKES, 1);
		PlayerScore_Add(attacker, SP_SCORE, 10);
		
		self.owner.goalentity = world;
		self.owner.islinked = FALSE;
		self.owner.iscaptured = FALSE;
		self.owner.team = 0;
		self.owner.colormap = 1024;

		WaypointSprite_UpdateMaxHealth(self.owner.sprite, 0);

		onslaught_updatelinks();

		// Use targets now (somebody make sure this is in the right place..)
		oself = self;
		self = self.owner;
		activator = self;
		SUB_UseTargets ();
		self = oself;

		self.owner.waslinked = self.owner.islinked;
		if(self.owner.model != "models/onslaught/controlpoint_pad.md3")
			setmodel_fixsize(self.owner, "models/onslaught/controlpoint_pad.md3");
		//setsize(self, '-32 -32 0', '32 32 8');

		remove(self);
	}
	
	self.SendFlags |= CPSF_STATUS;
}

void ons_ControlPoint_Icon_Think()
{
	entity oself;
	self.nextthink = time + CP_THINKRATE;

	if(autocvar_g_onslaught_cp_proxydecap)
	{
        float _enemy_count = 0;
        float _friendly_count = 0;
        float _dist;
        entity _player;

        FOR_EACH_PLAYER(_player)
        {
            if(!_player.deadflag)
            {
                _dist = vlen(_player.origin - self.origin);
                if(_dist < autocvar_g_onslaught_cp_proxydecap_distance)
                {
					if(SAME_TEAM(_player, self))
                        ++_friendly_count;
                    else
                        ++_enemy_count;
                }
            }
        }

        _friendly_count = _friendly_count * (autocvar_g_onslaught_cp_proxydecap_dps * CP_THINKRATE);
        _enemy_count = _enemy_count * (autocvar_g_onslaught_cp_proxydecap_dps * CP_THINKRATE);

        self.health = bound(0, self.health + (_friendly_count - _enemy_count), self.max_health);
		self.SendFlags |= CPSF_STATUS;
        if(self.health <= 0)
        {
            ons_ControlPoint_Icon_Damage(self, self, 1, 0, self.origin, '0 0 0');
            return;
        }
    }

	if (time > self.pain_finished + 5)
	{
		if(self.health < self.max_health)
		{
			self.health = self.health + self.count;
			if (self.health >= self.max_health)
				self.health = self.max_health;
			WaypointSprite_UpdateHealth(self.owner.sprite, self.health);
		}
	}

	if(self.owner.islinked != self.owner.waslinked)
	{
		// unteam the spawnpoint if needed
		float t;
		t = self.owner.team;
		if(!self.owner.islinked)
			self.owner.team = 0;

		oself = self;
		self = self.owner;
		activator = self;
		SUB_UseTargets ();
		self = oself;

		self.owner.team = t;

		self.owner.waslinked = self.owner.islinked;
	}

	// damaged fx
	if(random() < 0.6 - self.health / self.max_health)
	{
		pointparticles(particleeffectnum("electricity_sparks"), self.origin + randompos('-10 -10 -20', '10 10 20'), '0 0 0', 1);

		if(random() > 0.8)
			sound(self, CH_PAIN, "onslaught/ons_spark1.wav", VOL_BASE, ATTEN_NORM);
		else if (random() > 0.5)
			sound(self, CH_PAIN, "onslaught/ons_spark2.wav", VOL_BASE, ATTEN_NORM);
	}
}

void ons_ControlPoint_Icon_BuildThink()
{
	entity oself;
	float a;

	self.nextthink = time + CP_THINKRATE;

	// only do this if there is power
	a = ons_ControlPoint_CanBeLinked(self.owner, self.owner.team);
	if(!a)
		return;

	self.health = self.health + self.count;
	
	self.SendFlags |= CPSF_STATUS;

	if (self.health >= self.max_health)
	{
		self.health = self.max_health;
		self.count = autocvar_g_onslaught_cp_regen * CP_THINKRATE; // slow repair rate from now on
		self.think = ons_ControlPoint_Icon_Think;
		sound(self, CH_TRIGGER, "onslaught/controlpoint_built.wav", VOL_BASE, ATTEN_NORM);
		self.owner.iscaptured = TRUE;
		self.solid = SOLID_BBOX;

		pointparticles(particleeffectnum(sprintf("%s_cap", Static_Team_ColorName_Lower(self.owner.team))), self.owner.origin, '0 0 0', 1);

		WaypointSprite_UpdateMaxHealth(self.owner.sprite, self.max_health);
		WaypointSprite_UpdateHealth(self.owner.sprite, self.health);

		if(IS_PLAYER(self.owner.ons_toucher))
		{
			Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_ONSLAUGHT_CAPTURE, self.owner.ons_toucher.netname, self.owner.message);
			Send_Notification(NOTIF_ALL_EXCEPT, self.owner.ons_toucher, MSG_CENTER, APP_TEAM_ENT_4(self.owner.ons_toucher, CENTER_ONS_CAPTURE_), self.owner.message);
			Send_Notification(NOTIF_ONE, self.owner.ons_toucher, MSG_CENTER, CENTER_ONS_CAPTURE, self.owner.message);
			PlayerScore_Add(self.owner.ons_toucher, SP_ONS_CAPS, 1);
			PlayerTeamScore_AddScore(self.owner.ons_toucher, 10);
		}
		
		self.owner.ons_toucher = world;

		onslaught_updatelinks();

		// Use targets now (somebody make sure this is in the right place..)
		oself = self;
		self = self.owner;
		activator = self;
		SUB_UseTargets ();
		self = oself;
		
		self.SendFlags |= CPSF_SETUP;
	}
	if(self.owner.model != "models/onslaught/controlpoint_pad2.md3")
		setmodel_fixsize(self.owner, "models/onslaught/controlpoint_pad2.md3");
		
	if(random() < 0.9 - self.health / self.max_health)
		pointparticles(particleeffectnum("rage"), self.origin + 10 * randomvec(), '0 0 -1', 1);
}

void ons_ControlPoint_Icon_Spawn(entity cp, entity player)
{
	entity e = spawn();
	
	setsize(e, CPICON_MIN, CPICON_MAX);
	setorigin(e, cp.origin + CPICON_OFFSET);
	
	e.classname = "onslaught_controlpoint_icon";
	e.owner = cp;
	e.max_health = autocvar_g_onslaught_cp_health;
	e.health = autocvar_g_onslaught_cp_buildhealth;
	e.solid = SOLID_NOT;
	e.takedamage = DAMAGE_AIM;
	e.bot_attack = TRUE;
	e.event_damage = ons_ControlPoint_Icon_Damage;
	e.team = player.team;
	e.colormap = 1024 + (e.team - 1) * 17;
	e.count = (e.max_health - e.health) * CP_THINKRATE / autocvar_g_onslaught_cp_buildtime; // how long it takes to build
	
	sound(e, CH_TRIGGER, "onslaught/controlpoint_build.wav", VOL_BASE, ATTEN_NORM);
	
	cp.goalentity = e;
	cp.team = e.team;
	cp.colormap = e.colormap;

	pointparticles(particleeffectnum(sprintf("%sflag_touch", Static_Team_ColorName_Lower(player.team))), e.origin, '0 0 0', 1);

	WaypointSprite_UpdateBuildFinished(cp.sprite, time + (e.max_health - e.health) / (e.count / CP_THINKRATE));
	WaypointSprite_UpdateRule(cp.sprite,cp.team,SPRITERULE_TEAMPLAY);
	cp.sprite.SendFlags |= 16;

	onslaught_controlpoint_icon_link(e, ons_ControlPoint_Icon_BuildThink);
}

string ons_ControlPoint_Waypoint(entity e)
{
	float a;
	if(e.team)
	{
		a = ons_ControlPoint_Attackable(e, e.team);
		
		if(a == -2) { return "ons-cp-dfnd"; } // defend now
		if(a == -1 || a == 1 || a == 2) { return "ons-cp"; } // touch
		if(a == 3 || a == 4) { return "ons-cp-atck"; } // attack
	}
	else
		return "ons-cp";

	return "";
}

void ons_ControlPoint_UpdateSprite(entity e)
{
	string s1;
	s1 = ons_ControlPoint_Waypoint(e);
	WaypointSprite_UpdateSprites(e.sprite, s1, s1, s1);

	float sh;
	sh = !(ons_ControlPoint_CanBeLinked(e, NUM_TEAM_1) || ons_ControlPoint_CanBeLinked(e, NUM_TEAM_2) || ons_ControlPoint_CanBeLinked(e, NUM_TEAM_3) || ons_ControlPoint_CanBeLinked(e, NUM_TEAM_4));

	if(e.lastteam != e.team + 2 || e.lastshielded != sh || e.iscaptured != e.lastcaptured)
	{
		if(e.iscaptured) // don't mess up build bars!
		{
			if(sh)
			{
				WaypointSprite_UpdateMaxHealth(e.sprite, 0);
			}
			else
			{
				WaypointSprite_UpdateMaxHealth(e.sprite, e.goalentity.max_health);
				WaypointSprite_UpdateHealth(e.sprite, e.goalentity.health);
			}
		}
		if(e.lastshielded)
		{
			if(e.team)
				WaypointSprite_UpdateTeamRadar(e.sprite, RADARICON_CONTROLPOINT, 0.5 * colormapPaletteColor(e.team - 1, FALSE));
			else
				WaypointSprite_UpdateTeamRadar(e.sprite, RADARICON_CONTROLPOINT, '0.5 0.5 0.5');
		}
		else
		{
			if(e.team)
				WaypointSprite_UpdateTeamRadar(e.sprite, RADARICON_CONTROLPOINT, colormapPaletteColor(e.team - 1, FALSE));
			else
				WaypointSprite_UpdateTeamRadar(e.sprite, RADARICON_CONTROLPOINT, '0.75 0.75 0.75');
		}
		WaypointSprite_Ping(e.sprite);

		e.lastteam = e.team + 2;
		e.lastshielded = sh;
		e.lastcaptured = e.iscaptured;
	}
}

void ons_ControlPoint_Touch()
{
	entity toucher = other;
	float attackable;
	
	if(IS_VEHICLE(toucher) && toucher.owner)
	if(autocvar_g_onslaught_allow_vehicle_touch)
		toucher = toucher.owner;
	else
		return;
		
	if(!IS_PLAYER(toucher)) { return; }
	if(toucher.frozen) { return; }
	if(toucher.deadflag != DEAD_NO) { return; }
	
	if ( SAME_TEAM(self,other) )
	if ( self.iscaptured )
	{
		Send_Notification(NOTIF_ONE, other, MSG_CENTER, CENTER_ONS_TELEPORT);
	}
		
	attackable = ons_ControlPoint_Attackable(self, toucher.team);
	if(attackable != 2 && attackable != 4)
		return;
	// we've verified that this player has a legitimate claim to this point,
	// so start building the captured point icon (which only captures this
	// point if it successfully builds without being destroyed first)
	ons_ControlPoint_Icon_Spawn(self, toucher);
	
	self.ons_toucher = toucher;

	onslaught_updatelinks();
}

void ons_ControlPoint_Think()
{
	self.nextthink = time + CP_THINKRATE;
	CSQCMODEL_AUTOUPDATE();
}

void ons_ControlPoint_Reset()
{
	if(self.goalentity)
		remove(self.goalentity);

	self.goalentity = world;
	self.team = 0;
	self.colormap = 1024;
	self.iscaptured = FALSE;
	self.islinked = FALSE;
	self.isshielded = TRUE;
	self.think = ons_ControlPoint_Think;
	self.ons_toucher = world;
	self.nextthink = time + CP_THINKRATE;
	setmodel_fixsize(self, "models/onslaught/controlpoint_pad.md3");

	WaypointSprite_UpdateMaxHealth(self.sprite, 0);
	WaypointSprite_UpdateRule(self.sprite,self.team,SPRITERULE_TEAMPLAY);

	onslaught_updatelinks();

	activator = self;
	SUB_UseTargets(); // to reset the structures, playerspawns etc.

	CSQCMODEL_AUTOUPDATE();
}

void ons_DelayedControlPoint_Setup(void)
{
	onslaught_updatelinks();
	
	// captureshield setup
	ons_CaptureShield_Spawn(self, FALSE);

	CSQCMODEL_AUTOINIT();
}

void ons_ControlPoint_Setup(entity cp)
{
	// declarations
	self = cp; // for later usage with droptofloor()
	
	// main setup
	cp.ons_worldcpnext = ons_worldcplist; // link control point into ons_worldcplist
	ons_worldcplist = cp;
	
	cp.netname = "Control point";
	cp.team = 0;
	cp.solid = SOLID_BBOX;
	cp.movetype = MOVETYPE_NONE;
	cp.touch = ons_ControlPoint_Touch;
	cp.think = ons_ControlPoint_Think;
	cp.nextthink = time + CP_THINKRATE;
	cp.reset = ons_ControlPoint_Reset;
	cp.colormap = 1024;
	cp.iscaptured = FALSE;
	cp.islinked = FALSE;
	cp.isshielded = TRUE;
	
	if(cp.message == "") { cp.message = "a"; }

	// precache - TODO: clean up!
	precache_model("models/onslaught/controlpoint_pad.md3");
	precache_model("models/onslaught/controlpoint_pad2.md3");
	precache_model("models/onslaught/controlpoint_shield.md3");
	precache_model("models/onslaught/controlpoint_icon.md3");
	precache_model("models/onslaught/controlpoint_icon_dmg1.md3");
	precache_model("models/onslaught/controlpoint_icon_dmg2.md3");
	precache_model("models/onslaught/controlpoint_icon_dmg3.md3");
	precache_model("models/onslaught/controlpoint_icon_gib1.md3");
	precache_model("models/onslaught/controlpoint_icon_gib2.md3");
	precache_model("models/onslaught/controlpoint_icon_gib4.md3");
	precache_sound("onslaught/controlpoint_build.wav");
	precache_sound("onslaught/controlpoint_built.wav");
	precache_sound("weapons/grenade_impact.wav");
	precache_sound("onslaught/damageblockedbyshield.wav");
	precache_sound("onslaught/controlpoint_underattack.wav");
	precache_sound("onslaught/ons_spark1.wav");
	precache_sound("onslaught/ons_spark2.wav");
	
	// appearence
	setmodel_fixsize(cp, "models/onslaught/controlpoint_pad.md3");
	
	// control point placement
	if((cp.spawnflags & 1) || cp.noalign) // don't drop to floor, just stay at fixed location
	{
		cp.noalign = TRUE;
		cp.movetype = MOVETYPE_NONE;
	}
	else // drop to floor, automatically find a platform and set that as spawn origin
	{
		setorigin(cp, cp.origin + '0 0 20');
		cp.noalign = FALSE;
		self = cp;
		droptofloor();
		cp.movetype = MOVETYPE_TOSS;
	}
	
	// waypointsprites
	WaypointSprite_SpawnFixed(string_null, self.origin + CPGEN_WAYPOINT_OFFSET, self, sprite, RADARICON_NONE, '0 0 0');
	WaypointSprite_UpdateRule(self.sprite, self.team, SPRITERULE_TEAMPLAY);
	
	InitializeEntity(cp, ons_DelayedControlPoint_Setup, INITPRIO_SETLOCATION);
}


// =========================
// Main Generator Functions
// =========================

string ons_Generator_Waypoint(entity e)
{
	if(e.isshielded)
		return "ons-gen-shielded";
	return "ons-gen";
}

void ons_Generator_UpdateSprite(entity e)
{
	string s1;
	s1 = ons_Generator_Waypoint(e);
	WaypointSprite_UpdateSprites(e.sprite, s1, s1, s1);

	if(e.lastteam != e.team + 2 || e.lastshielded != e.isshielded)
	{
		e.lastteam = e.team + 2;
		e.lastshielded = e.isshielded;
		if(e.lastshielded)
		{
			if(e.team)
				WaypointSprite_UpdateTeamRadar(e.sprite, RADARICON_GENERATOR, 0.5 * colormapPaletteColor(e.team - 1, FALSE));
			else
				WaypointSprite_UpdateTeamRadar(e.sprite, RADARICON_GENERATOR, '0.5 0.5 0.5');
		}
		else
		{
			if(e.team)
				WaypointSprite_UpdateTeamRadar(e.sprite, RADARICON_GENERATOR, colormapPaletteColor(e.team - 1, FALSE));
			else
				WaypointSprite_UpdateTeamRadar(e.sprite, RADARICON_GENERATOR, '0.75 0.75 0.75');
		}
		WaypointSprite_Ping(e.sprite);
	}
}

void ons_GeneratorDamage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if(damage <= 0) { return; }
	if(warmup_stage || gameover) { return; }
	if(!round_handler_IsRoundStarted()) { return; }

	if (attacker != self)
	{
		if (self.isshielded)
		{
			// this is protected by a shield, so ignore the damage
			if (time > self.pain_finished)
				if (IS_PLAYER(attacker))
				{
					play2(attacker, "onslaught/damageblockedbyshield.wav");
					attacker.typehitsound += 1;
					self.pain_finished = time + 1;
				}
			return;
		}
		if (time > self.pain_finished)
		{
			self.pain_finished = time + 10;
			entity head;
			FOR_EACH_REALPLAYER(head) if(SAME_TEAM(head, self)) { Send_Notification(NOTIF_ONE, head, MSG_CENTER, CENTER_GENERATOR_UNDERATTACK); }
			play2team(self.team, "onslaught/generator_underattack.wav");
		}
	}
	self.health = self.health - damage;
	WaypointSprite_UpdateHealth(self.sprite, self.health);
	// choose an animation frame based on health
	self.frame = 10 * bound(0, (1 - self.health / self.max_health), 1);
	// see if the generator is still functional, or dying
	if (self.health > 0)
	{
		self.lasthealth = self.health;
	}
	else
	{
		if (attacker == self)
			Send_Notification(NOTIF_ALL, world, MSG_INFO, APP_TEAM_NUM_4(self.team, INFO_ONSLAUGHT_GENDESTROYED_OVERTIME_));
		else
		{
			Send_Notification(NOTIF_ALL, world, MSG_INFO, APP_TEAM_NUM_4(self.team, INFO_ONSLAUGHT_GENDESTROYED_));
			PlayerScore_Add(attacker, SP_SCORE, 100);
		}
		self.iscaptured = FALSE;
		self.islinked = FALSE;
		self.isshielded = FALSE;
		self.takedamage = DAMAGE_NO; // can't be hurt anymore
		self.event_damage = func_null; // won't do anything if hurt
		self.count = 0;	// reset counter
		self.think = func_null;
		self.nextthink = 0;
		//self.think(); // do the first explosion now

		WaypointSprite_UpdateMaxHealth(self.sprite, 0);
		WaypointSprite_Ping(self.sprite);
		//WaypointSprite_Kill(self.sprite); // can't do this yet, code too poor

		onslaught_updatelinks();
	}

	// Throw some flaming gibs on damage, more damage = more chance for gib
	if(random() < damage/220)
	{
		sound(self, CH_TRIGGER, "weapons/rocket_impact.wav", VOL_BASE, ATTEN_NORM);
	}
	else
	{
		// particles on every hit
		pointparticles(particleeffectnum("sparks"), hitloc, force * -1, 1);

		//sound on every hit
		if (random() < 0.5)
			sound(self, CH_TRIGGER, "onslaught/ons_hit1.wav", VOL_BASE, ATTEN_NORM);
		else
			sound(self, CH_TRIGGER, "onslaught/ons_hit2.wav", VOL_BASE, ATTEN_NORM);
	}

	self.SendFlags |= GSF_STATUS;
}

void ons_GeneratorThink()
{
	entity e;
	self.nextthink = time + GEN_THINKRATE;
	if (!gameover)
	{
        if(!self.isshielded && self.wait < time)
        {
            self.wait = time + 5;
            FOR_EACH_REALPLAYER(e)
            {
				if(SAME_TEAM(e, self))
				{
					Send_Notification(NOTIF_ONE, e, MSG_CENTER, CENTER_ONS_NOTSHIELDED_TEAM);
                    soundto(MSG_ONE, e, CHAN_AUTO, "kh/alarm.wav", VOL_BASE, ATTEN_NONE);    // FIXME: unique sound?
                }
				else
					Send_Notification(NOTIF_ONE, e, MSG_CENTER, APP_TEAM_NUM_4(self.team, CENTER_ONS_NOTSHIELDED_));
            }
        }
	}
}

void ons_GeneratorReset()
{
	self.team = self.team_saved;
	self.lasthealth = self.max_health = self.health = autocvar_g_onslaught_gen_health;
	self.takedamage = DAMAGE_AIM;
	self.bot_attack = TRUE;
	self.iscaptured = TRUE;
	self.islinked = TRUE;
	self.isshielded = TRUE;
	self.event_damage = ons_GeneratorDamage;
	self.think = ons_GeneratorThink;
	self.nextthink = time + GEN_THINKRATE;
	
	Net_LinkEntity(self, FALSE, 0, generator_send);
	
	self.SendFlags = GSF_SETUP; // just incase
	self.SendFlags |= GSF_STATUS;

	WaypointSprite_UpdateMaxHealth(self.sprite, self.max_health);
	WaypointSprite_UpdateHealth(self.sprite, self.health);
	WaypointSprite_UpdateRule(self.sprite,self.team,SPRITERULE_TEAMPLAY);
	
	onslaught_updatelinks();
}

void ons_DelayedGeneratorSetup()
{
	// bot waypoints
	waypoint_spawnforitem_force(self, self.origin);
	self.nearestwaypointtimeout = 0; // activate waypointing again
	self.bot_basewaypoint = self.nearestwaypoint;

	// captureshield setup
	ons_CaptureShield_Spawn(self, TRUE);
	
	onslaught_updatelinks();
	
	Net_LinkEntity(self, FALSE, 0, generator_send);
}


void onslaught_generator_touch()
{
	if ( IS_PLAYER(other) )
	if ( SAME_TEAM(self,other) )
	if ( self.iscaptured )
	{
		Send_Notification(NOTIF_ONE, other, MSG_CENTER, CENTER_ONS_TELEPORT);
	}
}

void ons_GeneratorSetup(entity gen) // called when spawning a generator entity on the map as a spawnfunc
{
	// declarations
	float teamnumber = gen.team;
	self = gen; // for later usage with droptofloor()
	
	// main setup
	gen.ons_worldgeneratornext = ons_worldgeneratorlist; // link generator into ons_worldgeneratorlist
	ons_worldgeneratorlist = gen;
	
	gen.netname = sprintf("%s generator", Team_ColoredFullName(teamnumber));
	gen.classname = "onslaught_generator";
	gen.solid = SOLID_BBOX;
	gen.team_saved = teamnumber;
	gen.movetype = MOVETYPE_NONE;
	gen.lasthealth = gen.max_health = gen.health = autocvar_g_onslaught_gen_health;
	gen.takedamage = DAMAGE_AIM;
	gen.bot_attack = TRUE;
	gen.event_damage = ons_GeneratorDamage;
	gen.reset = ons_GeneratorReset;
	gen.think = ons_GeneratorThink;
	gen.nextthink = time + GEN_THINKRATE;
	gen.iscaptured = TRUE;
	gen.islinked = TRUE;
	gen.isshielded = TRUE;
	gen.touch = onslaught_generator_touch;
	
	// precache - TODO: clean up!
	precache_model("models/onslaught/generator_shield.md3");
	precache_model("models/onslaught/gen_gib1.md3");
	precache_model("models/onslaught/gen_gib2.md3");
	precache_model("models/onslaught/gen_gib3.md3");
	precache_sound("onslaught/generator_decay.wav");
	precache_sound("weapons/grenade_impact.wav");
	precache_sound("weapons/rocket_impact.wav");
	precache_sound("onslaught/generator_underattack.wav");
	precache_sound("onslaught/shockwave.wav");
	precache_sound("onslaught/ons_hit1.wav");
	precache_sound("onslaught/ons_hit2.wav");
	precache_sound("onslaught/generator_underattack.wav");
	
	// appearence
	// model handled by CSQC
	setsize(gen, GENERATOR_MIN, GENERATOR_MAX);
	setorigin(gen, (gen.origin + CPGEN_SPAWN_OFFSET));
	gen.colormap = 1024 + (teamnumber - 1) * 17;
	
	// generator placement
	self = gen;
	droptofloor();
	
	// waypointsprites
	WaypointSprite_SpawnFixed(string_null, self.origin + CPGEN_WAYPOINT_OFFSET, self, sprite, RADARICON_NONE, '0 0 0');
	WaypointSprite_UpdateRule(self.sprite, self.team, SPRITERULE_TEAMPLAY);
	WaypointSprite_UpdateMaxHealth(self.sprite, self.max_health);
	WaypointSprite_UpdateHealth(self.sprite, self.health);
	
	InitializeEntity(gen, ons_DelayedGeneratorSetup, INITPRIO_SETLOCATION);
}


// ===============
//  Round Handler
// ===============

float total_generators, redowned, blueowned, yellowowned, pinkowned;
void Onslaught_count_generators()
{
	entity e;
	total_generators = redowned = blueowned = yellowowned = pinkowned = 0;
	for(e = ons_worldgeneratorlist; e; e = e.ons_worldgeneratornext)
	{
		++total_generators;
		redowned += (e.team == NUM_TEAM_1 && e.health > 0);
		blueowned += (e.team == NUM_TEAM_2 && e.health > 0);
		yellowowned += (e.team == NUM_TEAM_3 && e.health > 0);
		pinkowned += (e.team == NUM_TEAM_4 && e.health > 0);
	}
}

float Onslaught_GetWinnerTeam()
{
	float winner_team = 0;
	if(redowned > 0)
		winner_team = NUM_TEAM_1;
	if(blueowned > 0)
	{
		if(winner_team) return 0;
		winner_team = NUM_TEAM_2;
	}
	if(yellowowned > 0)
	{
		if(winner_team) return 0;
		winner_team = NUM_TEAM_3;
	}
	if(pinkowned > 0)
	{
		if(winner_team) return 0;
		winner_team = NUM_TEAM_4;
	}
	if(winner_team)
		return winner_team;
	return -1; // no generators left?
}

#define ONS_OWNED_GENERATORS() ((redowned > 0) + (blueowned > 0) + (yellowowned > 0) + (pinkowned > 0))
#define ONS_OWNED_GENERATORS_OK() (ONS_OWNED_GENERATORS() > 1)
float Onslaught_CheckWinner()
{
	entity e;
	
	if ((autocvar_timelimit && time > game_starttime + autocvar_timelimit * 60) || (round_handler_GetEndTime() > 0 && round_handler_GetEndTime() - time <= 0))
	{
		ons_stalemate = TRUE;

		if (!wpforenemy_announced)
		{
			Send_Notification(NOTIF_ALL, world, MSG_CENTER, CENTER_OVERTIME_CONTROLPOINT);
			sound(world, CH_INFO, "onslaught/generator_decay.wav", VOL_BASE, ATTEN_NONE);

			wpforenemy_announced = TRUE;
		}

		entity tmp_entity; // temporary entity
		float d;
		for(tmp_entity = ons_worldgeneratorlist; tmp_entity; tmp_entity = tmp_entity.ons_worldgeneratornext) if(time >= tmp_entity.ons_overtime_damagedelay)
		{
			// tmp_entity.max_health / 300 gives 5 minutes of overtime.
			// control points reduce the overtime duration.
			d = 1;
			for(e = ons_worldcplist; e; e = e.ons_worldcpnext)
			{
				if(DIFF_TEAM(e, tmp_entity))
				if(e.islinked)
					d = d + 1;
			}

			if(autocvar_g_campaign && autocvar__campaign_testrun)
				d = d * tmp_entity.max_health;
			else
				d = d * tmp_entity.max_health / max(30, 60 * autocvar_timelimit_suddendeath);

			Damage(tmp_entity, tmp_entity, tmp_entity, d, DEATH_HURTTRIGGER, tmp_entity.origin, '0 0 0');
			
			tmp_entity.sprite.SendFlags |= 16;

			tmp_entity.ons_overtime_damagedelay = time + 1;
		}
	}
	else { wpforenemy_announced = FALSE; ons_stalemate = FALSE; }

	Onslaught_count_generators();
	
	if(ONS_OWNED_GENERATORS_OK())
		return 0;

	float winner_team = Onslaught_GetWinnerTeam();

	if(winner_team > 0)
	{
		Send_Notification(NOTIF_ALL, world, MSG_CENTER, APP_TEAM_NUM_4(winner_team, CENTER_ROUND_TEAM_WIN_));
		Send_Notification(NOTIF_ALL, world, MSG_INFO, APP_TEAM_NUM_4(winner_team, INFO_ROUND_TEAM_WIN_));
		TeamScore_AddToTeam(winner_team, ST_ONS_CAPS, +1);
	}
	else if(winner_team == -1)
	{
		Send_Notification(NOTIF_ALL, world, MSG_CENTER, CENTER_ROUND_TIED);
		Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_ROUND_TIED);
	}
	
	ons_stalemate = FALSE;

	play2all(sprintf("ctf/%s_capture.wav", Static_Team_ColorName_Lower(winner_team)));
	
	round_handler_Init(7, autocvar_g_onslaught_warmup, autocvar_g_onslaught_round_timelimit);
	
	FOR_EACH_PLAYER(e)
	{
		e.ons_roundlost = TRUE;
		e.player_blocked = TRUE;
		nades_Clear(e);
	}
	
	return 1;
}

float Onslaught_CheckPlayers()
{
	return 1;
}

void Onslaught_RoundStart()
{
	entity tmp_entity;
	FOR_EACH_PLAYER(tmp_entity) { tmp_entity.player_blocked = FALSE; }

	for(tmp_entity = ons_worldcplist; tmp_entity; tmp_entity = tmp_entity.ons_worldcpnext)
		tmp_entity.sprite.SendFlags |= 16;

	for(tmp_entity = ons_worldgeneratorlist; tmp_entity; tmp_entity = tmp_entity.ons_worldgeneratornext)
		tmp_entity.sprite.SendFlags |= 16;
}


// ================
// Bot player logic
// ================

// NOTE: LEGACY CODE, needs to be re-written!

void havocbot_goalrating_ons_offenseitems(float ratingscale, vector org, float sradius)
{
	entity head;
	float t, i, c, needarmor = FALSE, needweapons = FALSE;

	// Needs armor/health?
	if(self.health<100)
		needarmor = TRUE;

	// Needs weapons?
	c = 0;
	for(i = WEP_FIRST; i <= WEP_LAST ; ++i)
	{
		// Find weapon
		if(self.weapons & WepSet_FromWeapon(i))
		if(++c>=4)
			break;
	}

	if(c<4)
		needweapons = TRUE;

	if(!needweapons && !needarmor)
		return;

	ons_debug(strcat(self.netname, " needs weapons ", ftos(needweapons) , "\n"));
	ons_debug(strcat(self.netname, " needs armor ", ftos(needarmor) , "\n"));

	// See what is around
	head = findchainfloat(bot_pickup, TRUE);
	while (head)
	{
		// gather health and armor only
		if (head.solid)
		if ( ((head.health || head.armorvalue) && needarmor) || (head.weapons && needweapons ) )
		if (vlen(head.origin - org) < sradius)
		{
			t = head.bot_pickupevalfunc(self, head);
			if (t > 0)
				navigation_routerating(head, t * ratingscale, 500);
		}
		head = head.chain;
	}
}

void havocbot_role_ons_setrole(entity bot, float role)
{
	ons_debug(strcat(bot.netname," switched to "));
	switch(role)
	{
		case HAVOCBOT_ONS_ROLE_DEFENSE:
			ons_debug("defense");
			bot.havocbot_role = havocbot_role_ons_defense;
			bot.havocbot_role_flags = HAVOCBOT_ONS_ROLE_DEFENSE;
			bot.havocbot_role_timeout = 0;
			break;
		case HAVOCBOT_ONS_ROLE_ASSISTANT:
			ons_debug("assistant");
			bot.havocbot_role = havocbot_role_ons_assistant;
			bot.havocbot_role_flags = HAVOCBOT_ONS_ROLE_ASSISTANT;
			bot.havocbot_role_timeout = 0;
			break;
		case HAVOCBOT_ONS_ROLE_OFFENSE:
			ons_debug("offense");
			bot.havocbot_role = havocbot_role_ons_offense;
			bot.havocbot_role_flags = HAVOCBOT_ONS_ROLE_OFFENSE;
			bot.havocbot_role_timeout = 0;
			break;
	}
	ons_debug("\n");
}

float havocbot_ons_teamcount(entity bot, float role)
{
	float c = 0;
	entity head;

	FOR_EACH_PLAYER(head)
	if(SAME_TEAM(head, self))
	if(head.havocbot_role_flags & role)
		++c;

	return c;
}

void havocbot_goalrating_ons_controlpoints_attack(float ratingscale)
{
	entity cp, cp1, cp2, best, pl, wp;
	float radius, found, bestvalue, c;

	// Filter control points
	for(cp2 = ons_worldcplist; cp2; cp2 = cp2.ons_worldcpnext)
	{
		cp2.wpcost = c = 0;
		cp2.wpconsidered = FALSE;

		if(cp2.isshielded)
			continue;

		// Ignore owned controlpoints
		if(!(cp2.isgenneighbor[self.team] || cp2.iscpneighbor[self.team]))
			continue;

		// Count team mates interested in this control point
		// (easier and cleaner than keeping counters per cp and teams)
		FOR_EACH_PLAYER(pl)
		if(SAME_TEAM(pl, self))
		if(pl.havocbot_role_flags & HAVOCBOT_ONS_ROLE_OFFENSE)
		if(pl.havocbot_ons_target==cp2)
			++c;

		// NOTE: probably decrease the cost of attackable control points
		cp2.wpcost = c;
		cp2.wpconsidered = TRUE;
	}

	// We'll consider only the best case
	bestvalue = 99999999999;
	cp = world;
	for(cp1 = ons_worldcplist; cp1; cp1 = cp1.ons_worldcpnext)
	{
		if (!cp1.wpconsidered)
			continue;

		if(cp1.wpcost<bestvalue)
		{
			bestvalue = cp1.wpcost;
			cp = cp1;
			self.havocbot_ons_target = cp1;
		}
	}

	if (!cp)
		return;

	ons_debug(strcat(self.netname, " chose cp ranked ", ftos(bestvalue), "\n"));

	if(cp.goalentity)
	{
		// Should be attacked
		// Rate waypoints near it
		found = FALSE;
		best = world;
		bestvalue = 99999999999;
		for(radius=0; radius<1000 && !found; radius+=500)
		{
			for(wp=findradius(cp.origin,radius); wp; wp=wp.chain)
			{
				if(!(wp.wpflags & WAYPOINTFLAG_GENERATED))
				if(wp.classname=="waypoint")
				if(checkpvs(wp.origin,cp))
				{
					found = TRUE;
					if(wp.cnt<bestvalue)
					{
						best = wp;
						bestvalue = wp.cnt;
					}
				}
			}
		}

		if(best)
		{
			navigation_routerating(best, ratingscale, 10000);
			best.cnt += 1;

			self.havocbot_attack_time = 0;
			if(checkpvs(self.view_ofs,cp))
			if(checkpvs(self.view_ofs,best))
				self.havocbot_attack_time = time + 2;
		}
		else
		{
			navigation_routerating(cp, ratingscale, 10000);
		}
		ons_debug(strcat(self.netname, " found an attackable controlpoint at ", vtos(cp.origin) ,"\n"));
	}
	else
	{
		// Should be touched
		ons_debug(strcat(self.netname, " found a touchable controlpoint at ", vtos(cp.origin) ,"\n"));
		found = FALSE;

		// Look for auto generated waypoint
		if (!bot_waypoints_for_items)
		for (wp = findradius(cp.origin,100); wp; wp = wp.chain)
		{
			if(wp.classname=="waypoint")
			{
				navigation_routerating(wp, ratingscale, 10000);
				found = TRUE;
			}
		}

		// Nothing found, rate the controlpoint itself
		if (!found)
			navigation_routerating(cp, ratingscale, 10000);
	}
}

float havocbot_goalrating_ons_generator_attack(float ratingscale)
{
	entity g, wp, bestwp;
	float found, best;

	for(g = ons_worldgeneratorlist; g; g = g.ons_worldgeneratornext)
	{
		if(SAME_TEAM(g, self) || g.isshielded)
			continue;

		// Should be attacked
		// Rate waypoints near it
		found = FALSE;
		bestwp = world;
		best = 99999999999;

		for(wp=findradius(g.origin,400); wp; wp=wp.chain)
		{
			if(wp.classname=="waypoint")
			if(checkpvs(wp.origin,g))
			{
				found = TRUE;
				if(wp.cnt<best)
				{
					bestwp = wp;
					best = wp.cnt;
				}
			}
		}

		if(bestwp)
		{
			ons_debug("waypoints found around generator\n");
			navigation_routerating(bestwp, ratingscale, 10000);
			bestwp.cnt += 1;

			self.havocbot_attack_time = 0;
			if(checkpvs(self.view_ofs,g))
			if(checkpvs(self.view_ofs,bestwp))
				self.havocbot_attack_time = time + 5;

			return TRUE;
		}
		else
		{
			ons_debug("generator found without waypoints around\n");
			// if there aren't waypoints near the generator go straight to it
			navigation_routerating(g, ratingscale, 10000);
			self.havocbot_attack_time = 0;
			return TRUE;
		}
	}
	return FALSE;
}

void havocbot_role_ons_offense()
{
	if(self.deadflag != DEAD_NO)
	{
		self.havocbot_attack_time = 0;
		havocbot_ons_reset_role(self);
		return;
	}

	// Set the role timeout if necessary
	if (!self.havocbot_role_timeout)
		self.havocbot_role_timeout = time + 120;

	if (time > self.havocbot_role_timeout)
	{
		havocbot_ons_reset_role(self);
		return;
	}

	if(self.havocbot_attack_time>time)
		return;

	if (self.bot_strategytime < time)
	{
		navigation_goalrating_start();
		havocbot_goalrating_enemyplayers(20000, self.origin, 650);
		if(!havocbot_goalrating_ons_generator_attack(20000))
			havocbot_goalrating_ons_controlpoints_attack(20000);
		havocbot_goalrating_ons_offenseitems(10000, self.origin, 10000);
		navigation_goalrating_end();

		self.bot_strategytime = time + autocvar_bot_ai_strategyinterval;
	}
}

void havocbot_role_ons_assistant()
{
	havocbot_ons_reset_role(self);
}

void havocbot_role_ons_defense()
{
	havocbot_ons_reset_role(self);
}

void havocbot_ons_reset_role(entity bot)
{
	entity head;
	float c;

	if(self.deadflag != DEAD_NO)
		return;

	bot.havocbot_ons_target = world;

	// TODO: Defend control points or generator if necessary

	// if there is only me on the team switch to offense
	c = 0;
	FOR_EACH_PLAYER(head)
	if(SAME_TEAM(head, self))
		++c;

	if(c==1)
	{
		havocbot_role_ons_setrole(bot, HAVOCBOT_ONS_ROLE_OFFENSE);
		return;
	}

	havocbot_role_ons_setrole(bot, HAVOCBOT_ONS_ROLE_OFFENSE);
}


/*
 * Find control point or generator owned by the same team self which is nearest to pos
 * if max_dist is positive, only control points within this range will be considered
 */
entity ons_Nearest_ControlPoint(vector pos, float max_dist)
{
	entity tmp_entity, closest_target = world;
	tmp_entity = findchain(classname, "onslaught_controlpoint");
	while(tmp_entity)
	{
		if(SAME_TEAM(tmp_entity, self))
		if(tmp_entity.iscaptured)
		if(max_dist <= 0 || vlen(tmp_entity.origin - pos) <= max_dist)
		if(vlen(tmp_entity.origin - pos) <= vlen(closest_target.origin - pos) || closest_target == world)
			closest_target = tmp_entity;
		tmp_entity = tmp_entity.chain;
	}
	tmp_entity = findchain(classname, "onslaught_generator");
	while(tmp_entity)
	{
		if(SAME_TEAM(tmp_entity, self))
		if(max_dist <= 0 || vlen(tmp_entity.origin - pos) < max_dist)
		if(vlen(tmp_entity.origin - pos) <= vlen(closest_target.origin - pos) || closest_target == world)
			closest_target = tmp_entity;
		tmp_entity = tmp_entity.chain;
	}
	
	return closest_target;
}

/*
 * Find control point or generator owned by the same team self which is nearest to pos
 * if max_dist is positive, only control points within this range will be considered
 * This function only check distances on the XY plane, disregarding Z
 */
entity ons_Nearest_ControlPoint_2D(vector pos, float max_dist)
{
	entity tmp_entity, closest_target = world;
	vector delta;
	float smallest_distance = 0, distance;
	
	tmp_entity = findchain(classname, "onslaught_controlpoint");
	while(tmp_entity)
	{
		delta = tmp_entity.origin - pos;
		delta_z = 0;
		distance = vlen(delta);
		
		if(SAME_TEAM(tmp_entity, self))
		if(tmp_entity.iscaptured)
		if(max_dist <= 0 || distance <= max_dist)
		if(closest_target == world || distance <= smallest_distance )
		{
			closest_target = tmp_entity;
			smallest_distance = distance;
		}
		
		tmp_entity = tmp_entity.chain;
	}
	tmp_entity = findchain(classname, "onslaught_generator");
	while(tmp_entity)
	{
		delta = tmp_entity.origin - pos;
		delta_z = 0;
		distance = vlen(delta);
		
		if(SAME_TEAM(tmp_entity, self))
		if(max_dist <= 0 || distance <= max_dist)
		if(closest_target == world || distance <= smallest_distance )
		{
			closest_target = tmp_entity;
			smallest_distance = distance;
		}
		
		tmp_entity = tmp_entity.chain;
	}
	
	return closest_target;
}
/**
 * find the number of control points and generators in the same team as self
 */
float ons_Count_SelfControlPoints()
{
	entity tmp_entity;
	tmp_entity = findchain(classname, "onslaught_controlpoint");
	float n = 0;
	while(tmp_entity)
	{
		if(SAME_TEAM(tmp_entity, self))
		if(tmp_entity.iscaptured)
			n++;
		tmp_entity = tmp_entity.chain;
	}
	tmp_entity = findchain(classname, "onslaught_generator");
	while(tmp_entity)
	{
		if(SAME_TEAM(tmp_entity, self))
			n++;
		tmp_entity = tmp_entity.chain;
	}
	return n;
}

/**
 * Teleport player to a random position near tele_target
 * if tele_effects is true, teleport sound+particles are created
 * return FALSE on failure
 */
float ons_Teleport(entity player, entity tele_target, float range, float tele_effects)
{
	if ( !tele_target )
		return FALSE;
	
	float i;
	vector loc;
	float theta;
	for(i = 0; i < 16; ++i)
	{
		theta = random() * 2 * M_PI;
		loc_y = sin(theta);
		loc_x = cos(theta);
		loc_z = 0;
		loc *= random() * range;
		
		loc += tele_target.origin + '0 0 128';
		
		tracebox(loc, PL_MIN, PL_MAX, loc, MOVE_NORMAL, player);
		if(trace_fraction == 1.0 && !trace_startsolid)
		{
			traceline(tele_target.origin, loc, MOVE_NOMONSTERS, tele_target); // double check to make sure we're not spawning outside the world
			if(trace_fraction == 1.0 && !trace_startsolid)
			{
				if ( tele_effects )
				{
					pointparticles(particleeffectnum("teleport"), player.origin, '0 0 0', 1);
					sound (player, CH_TRIGGER, "misc/teleport.wav", VOL_BASE, ATTEN_NORM);
				}
				setorigin(player, loc);
				player.angles = '0 1 0' * ( theta * RAD2DEG + 180 );
				makevectors(player.angles);
				player.fixangle = TRUE;
				if ( tele_effects )
					pointparticles(particleeffectnum("teleport"), player.origin + v_forward * 32, '0 0 0', 1);
				return TRUE;
			}
		}
	}
	
	return FALSE;
}

// ==============
// Hook Functions
// ==============

MUTATOR_HOOKFUNCTION(ons_ResetMap)
{
	FOR_EACH_PLAYER(self)
	{
		self.ons_roundlost = FALSE;
		self.ons_deathloc = '0 0 0';
		PutClientInServer();
	}
	return FALSE;
}

MUTATOR_HOOKFUNCTION(ons_RemovePlayer)
{
	self.ons_deathloc = '0 0 0';
	return FALSE;
}

MUTATOR_HOOKFUNCTION(ons_PlayerSpawn)
{
	if(!round_handler_IsRoundStarted())
	{
		self.player_blocked = TRUE;
		return FALSE;
	}
	
	entity l;
	for(l = ons_worldgeneratorlist; l; l = l.ons_worldgeneratornext)
	{
		l.sprite.SendFlags |= 16;
	}
	for(l = ons_worldcplist; l; l = l.ons_worldcpnext)
	{
		l.sprite.SendFlags |= 16;
	}

	if(ons_stalemate) { Send_Notification(NOTIF_ONE, self, MSG_CENTER, CENTER_OVERTIME_CONTROLPOINT); }

	if ( autocvar_g_onslaught_spawn_choose )
	if ( self.ons_spawn_by )
	if ( ons_Teleport(self,self.ons_spawn_by,autocvar_g_onslaught_teleport_radius,FALSE) )
	{
		self.ons_spawn_by = world;
		return FALSE;
	}
	
	if(autocvar_g_onslaught_spawn_at_controlpoints)
	if(random() <= autocvar_g_onslaught_spawn_at_controlpoints_chance)
	{
		float random_target = autocvar_g_onslaught_spawn_at_controlpoints_random;
		entity tmp_entity, closest_target = world;
		vector spawn_loc = self.ons_deathloc;
		
		// new joining player or round reset, don't bother checking
		if(spawn_loc == '0 0 0') { return FALSE; }

		if(random_target) { RandomSelection_Init(); }

		for(tmp_entity = ons_worldcplist; tmp_entity; tmp_entity = tmp_entity.ons_worldcpnext)
		{
			if(SAME_TEAM(tmp_entity, self))
			if(random_target)
				RandomSelection_Add(tmp_entity, 0, string_null, 1, 1);
			else if(vlen(tmp_entity.origin - spawn_loc) <= vlen(closest_target.origin - spawn_loc) || closest_target == world)
				closest_target = tmp_entity;
		}
		
		if(random_target) { closest_target = RandomSelection_chosen_ent; }
		
		if(closest_target)
		{
			float i;
			vector loc;
			for(i = 0; i < 10; ++i)
			{
				loc = closest_target.origin + '0 0 96';
				loc += ('0 1 0' * random()) * 128;
				tracebox(loc, PL_MIN, PL_MAX, loc, MOVE_NORMAL, self);
				if(trace_fraction == 1.0 && !trace_startsolid)
				{
					traceline(closest_target.origin, loc, MOVE_NOMONSTERS, closest_target); // double check to make sure we're not spawning outside the world
					if(trace_fraction == 1.0 && !trace_startsolid)
					{
						setorigin(self, loc);
						self.angles = normalize(loc - closest_target.origin) * RAD2DEG;
						return FALSE;
					}
				}
			}
		}
	}
	
	if(autocvar_g_onslaught_spawn_at_generator)
	if(random() <= autocvar_g_onslaught_spawn_at_generator_chance)
	{
		float random_target = autocvar_g_onslaught_spawn_at_generator_random;
		entity tmp_entity, closest_target = world;
		vector spawn_loc = self.ons_deathloc;
		
		// new joining player or round reset, don't bother checking
		if(spawn_loc == '0 0 0') { return FALSE; }
		
		if(random_target) { RandomSelection_Init(); }

		for(tmp_entity = ons_worldgeneratorlist; tmp_entity; tmp_entity = tmp_entity.ons_worldgeneratornext)
		{
			if(random_target)
				RandomSelection_Add(tmp_entity, 0, string_null, 1, 1);
			else
			{
				if(SAME_TEAM(tmp_entity, self))
				if(vlen(tmp_entity.origin - spawn_loc) <= vlen(closest_target.origin - spawn_loc) || closest_target == world)
					closest_target = tmp_entity;
			}
		}
		
		if(random_target) { closest_target = RandomSelection_chosen_ent; }
		
		if(closest_target)
		{
			float i;
			vector loc;
			for(i = 0; i < 10; ++i)
			{
				loc = closest_target.origin + '0 0 128';
				loc += ('0 1 0' * random()) * 256;
				tracebox(loc, PL_MIN, PL_MAX, loc, MOVE_NORMAL, self);
				if(trace_fraction == 1.0 && !trace_startsolid)
				{
					traceline(closest_target.origin, loc, MOVE_NOMONSTERS, closest_target); // double check to make sure we're not spawning outside the world
					if(trace_fraction == 1.0 && !trace_startsolid)
					{
						setorigin(self, loc);
						self.angles = normalize(loc - closest_target.origin) * RAD2DEG;
						return FALSE;
					}
				}
			}
		}
	}

    return FALSE;
}

MUTATOR_HOOKFUNCTION(ons_PlayerDies)
{
	frag_target.ons_deathloc = frag_target.origin;
	entity l;
	for(l = ons_worldgeneratorlist; l; l = l.ons_worldgeneratornext)
	{
		l.sprite.SendFlags |= 16;
	}
	for(l = ons_worldcplist; l; l = l.ons_worldcpnext)
	{
		l.sprite.SendFlags |= 16;
	}
	
	if ( autocvar_g_onslaught_spawn_choose )
	if ( ons_Count_SelfControlPoints() > 1 )
		stuffcmd(self, "qc_cmd_cl hud clickradar\n");
	
	return FALSE;
}

MUTATOR_HOOKFUNCTION(ons_MonsterThink)
{
	entity e = find(world, targetname, self.target);
	if (e != world)
		self.team = e.team;

	return FALSE;
}

void ons_MonsterSpawn_Delayed()
{
	entity e, own = self.owner;
	
	if(!own) { remove(self); return; }
	
	if(own.targetname)
	{
		e = find(world, target, own.targetname);
		if(e != world)
		{
			own.team = e.team;
			
			activator = e;
			own.use();
		}
	}
	
	remove(self);
}

MUTATOR_HOOKFUNCTION(ons_MonsterSpawn)
{
	entity e = spawn();
	e.owner = self;
	InitializeEntity(e, ons_MonsterSpawn_Delayed, INITPRIO_FINDTARGET);

	return FALSE;
}

void ons_TurretSpawn_Delayed()
{
	entity e, own = self.owner;

	if(!own) { remove(self); return; }

	if(own.targetname)
	{
		e = find(world, target, own.targetname);
		if(e != world)
		{
			own.team = e.team;
			own.active = ACTIVE_NOT;
			
			activator = e;
			own.use();
		}
	}

	remove(self);
}

MUTATOR_HOOKFUNCTION(ons_TurretSpawn)
{
	entity e = spawn();
	e.owner = self;
	InitializeEntity(e, ons_TurretSpawn_Delayed, INITPRIO_FINDTARGET);

	return FALSE;
}

MUTATOR_HOOKFUNCTION(ons_BotRoles)
{
	havocbot_ons_reset_role(self);
	return TRUE;
}

MUTATOR_HOOKFUNCTION(ons_GetTeamCount)
{
	// onslaught is special
	entity tmp_entity;
	for(tmp_entity = ons_worldgeneratorlist; tmp_entity; tmp_entity = tmp_entity.ons_worldgeneratornext)
	{
		switch(tmp_entity.team)
		{
			case NUM_TEAM_1: c1 = 0; break;
			case NUM_TEAM_2: c2 = 0; break;
			case NUM_TEAM_3: c3 = 0; break;
			case NUM_TEAM_4: c4 = 0; break;
		}
	}

	return TRUE;
}

MUTATOR_HOOKFUNCTION(ons_SpectateCopy)
{
	self.ons_roundlost = other.ons_roundlost; // make spectators see it too
	return FALSE;
}

MUTATOR_HOOKFUNCTION(ons_SV_ParseClientCommand)
{
	if ( cmd_name == "ons_spawn" )
	{
		vector pos = self.origin;
		if(cmd_argc > 1)
			pos_x = stof(argv(1));
		if(cmd_argc > 2)
			pos_y = stof(argv(2));
		if(cmd_argc > 3)
			pos_z = stof(argv(3));
		
		if ( IS_PLAYER(self) )
		{
			if ( !self.frozen )
			{
				entity source_point = ons_Nearest_ControlPoint(self.origin, autocvar_g_onslaught_teleport_radius);
				
				if ( !source_point && self.health > 0 )
				{
					sprint(self, "\nYou need to be next to a control point\n");
					return 1;
				}
				
				
				entity closest_target = ons_Nearest_ControlPoint_2D(pos, autocvar_g_onslaught_click_radius);
			
				if ( closest_target == world )
				{
					sprint(self, "\nNo control point found\n");
					return 1;
				}
				
				if ( self.health <= 0 )
				{
					self.ons_spawn_by = closest_target;
					self.respawn_flags = self.respawn_flags | RESPAWN_FORCE;
				}
				else
				{
					if ( source_point == closest_target )
					{
						sprint(self, "\nTeleporting to the same point\n");
						return 1;
					}
					
					if ( !ons_Teleport(self,closest_target,autocvar_g_onslaught_teleport_radius,TRUE) )
						sprint(self, "\nUnable to teleport there\n");
				}
				
				return 1;
			}
			
			sprint(self, "\nNo teleportation for you\n");
		}
		
		return 1;
	}
	return 0;
}

MUTATOR_HOOKFUNCTION(ons_PlayerUseKey)
{
	entity source_point = ons_Nearest_ControlPoint(self.origin, autocvar_g_onslaught_teleport_radius);
	if ( source_point )
	{
		stuffcmd(self, "qc_cmd_cl hud clickradar\n");
		return TRUE;
	}
	
	return FALSE;
}

// ==========
// Spawnfuncs
// ==========

/*QUAKED spawnfunc_onslaught_link (0 .5 .8) (-16 -16 -16) (16 16 16)
  Link between control points.

  This entity targets two different spawnfunc_onslaught_controlpoint or spawnfunc_onslaught_generator entities, and suppresses shielding on both if they are owned by different teams.

keys:
"target" - first control point.
"target2" - second control point.
 */
void spawnfunc_onslaught_link()
{
	if(!g_onslaught) { remove(self); return; }

	if (self.target == "" || self.target2 == "")
		objerror("target and target2 must be set\n");

	self.ons_worldlinknext = ons_worldlinklist; // link into ons_worldlinklist
	ons_worldlinklist = self;

	InitializeEntity(self, ons_DelayedLinkSetup, INITPRIO_FINDTARGET);
	Net_LinkEntity(self, FALSE, 0, ons_Link_Send);
}

/*QUAKED spawnfunc_onslaught_controlpoint (0 .5 .8) (-32 -32 0) (32 32 128)
  Control point. Be sure to give this enough clearance so that the shootable part has room to exist

  This should link to an spawnfunc_onslaught_controlpoint entity or spawnfunc_onslaught_generator entity.

keys:
"targetname" - name that spawnfunc_onslaught_link entities will use to target this.
"target" - target any entities that are tied to this control point, such as vehicles and buildable structure entities.
"message" - name of this control point (should reflect the location in the map, such as "center bridge", "north tower", etc)
 */

void spawnfunc_onslaught_controlpoint()
{
	if(!g_onslaught) { remove(self); return; }
	
	ons_ControlPoint_Setup(self);
}

/*QUAKED spawnfunc_onslaught_generator (0 .5 .8) (-32 -32 -24) (32 32 64)
  Base generator.

  spawnfunc_onslaught_link entities can target this.

keys:
"team" - team that owns this generator (5 = red, 14 = blue, etc), MUST BE SET.
"targetname" - name that spawnfunc_onslaught_link entities will use to target this.
 */
void spawnfunc_onslaught_generator()
{
	if(!g_onslaught) { remove(self); return; }
	if(!self.team) { objerror("team must be set"); }

	ons_GeneratorSetup(self);
}


// scoreboard setup
void ons_ScoreRules()
{
	CheckAllowedTeams(world);
	ScoreRules_basics(((c4>=0) ? 4 : (c3>=0) ? 3 : 2), SFL_SORT_PRIO_PRIMARY, 0, TRUE);
	ScoreInfo_SetLabel_TeamScore  (ST_ONS_CAPS,     "destroyed", SFL_SORT_PRIO_PRIMARY);
	ScoreInfo_SetLabel_PlayerScore(SP_ONS_CAPS,     "caps",      SFL_SORT_PRIO_SECONDARY);
	ScoreInfo_SetLabel_PlayerScore(SP_ONS_TAKES,	"takes",     0);
	ScoreRules_basics_end();
}

void ons_DelayedInit() // Do this check with a delay so we can wait for teams to be set up
{
	ons_ScoreRules();
	
	round_handler_Spawn(Onslaught_CheckPlayers, Onslaught_CheckWinner, Onslaught_RoundStart);
	round_handler_Init(5, autocvar_g_onslaught_warmup, autocvar_g_onslaught_round_timelimit);
}

void ons_Initialize()
{
	precache_sound("ctf/red_capture.wav");
	precache_sound("ctf/blue_capture.wav");
	precache_sound("ctf/yellow_capture.wav");
	precache_sound("ctf/pink_capture.wav");

	ons_captureshield_force = autocvar_g_onslaught_shield_force;
	
	addstat(STAT_ROUNDLOST, AS_INT, ons_roundlost);
	
	InitializeEntity(world, ons_DelayedInit, INITPRIO_GAMETYPE);
}

MUTATOR_DEFINITION(gamemode_onslaught)
{
	MUTATOR_HOOK(reset_map_global, ons_ResetMap, CBC_ORDER_ANY);
	MUTATOR_HOOK(MakePlayerObserver, ons_RemovePlayer, CBC_ORDER_ANY);
	MUTATOR_HOOK(ClientDisconnect, ons_RemovePlayer, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerSpawn, ons_PlayerSpawn, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerDies, ons_PlayerDies, CBC_ORDER_ANY);
	MUTATOR_HOOK(MonsterMove, ons_MonsterThink, CBC_ORDER_ANY);
	MUTATOR_HOOK(MonsterSpawn, ons_MonsterSpawn, CBC_ORDER_ANY);
	MUTATOR_HOOK(TurretSpawn, ons_TurretSpawn, CBC_ORDER_ANY);
	MUTATOR_HOOK(HavocBot_ChooseRole, ons_BotRoles, CBC_ORDER_ANY);
	MUTATOR_HOOK(GetTeamCount, ons_GetTeamCount, CBC_ORDER_ANY);
	MUTATOR_HOOK(SpectateCopy, ons_SpectateCopy, CBC_ORDER_ANY);
	MUTATOR_HOOK(SV_ParseClientCommand, ons_SV_ParseClientCommand, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerUseKey, ons_PlayerUseKey, CBC_ORDER_ANY);

	MUTATOR_ONADD
	{
		if(time > 1) // game loads at time 1
			error("This is a game type and it cannot be added at runtime.");
		ons_Initialize();
	}

	MUTATOR_ONROLLBACK_OR_REMOVE
	{
		// we actually cannot roll back ons_Initialize here
		// BUT: we don't need to! If this gets called, adding always
		// succeeds.
	}

	MUTATOR_ONREMOVE
	{
		print("This is a game type and it cannot be removed at runtime.");
		return -1;
	}

	return FALSE;
}
