// =======================
// CaptureShield Functions
// =======================

float ons_CaptureShield_Customize()
{
	entity e = WaypointSprite_getviewentity(other);

	if(!self.enemy.isshielded && (onslaught_controlpoint_attackable(self.enemy, e.team) > 0 || self.enemy.classname != "onslaught_controlpoint")) { return FALSE; }
	if(SAME_TEAM(self, e)) { return FALSE; }

	return TRUE;
}

void ons_CaptureShield_Touch()
{
	if(!self.enemy.isshielded && (onslaught_controlpoint_attackable(self.enemy, other.team) > 0 || self.enemy.classname != "onslaught_controlpoint")) { return; }
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

void ons_gib_damage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector vforce)
{
	self.velocity = self.velocity + vforce;
}

.float giblifetime;
void ons_throwgib_think()
{
	float d;

	self.nextthink = time + 0.05;

	d = self.giblifetime - time;

	if(d<0)
	{
		self.think = SUB_Remove;
		return;
	}
	if(d<1)
		self.alpha = d;

	if(d>2)
	if(random()<0.6)
		pointparticles(particleeffectnum("onslaught_generator_gib_flame"), self.origin, '0 0 0', 1);
}

void ons_throwgib(vector v_from, vector v_to, string smodel, float f_lifetime, float b_burn)
{
	entity gib;

	gib = spawn();

	setmodel(gib, smodel);
	setorigin(gib, v_from);
	gib.solid = SOLID_CORPSE;
	gib.movetype = MOVETYPE_BOUNCE;
	gib.takedamage = DAMAGE_YES;
	gib.event_damage = ons_gib_damage;
	gib.health = -1;
	gib.effects = EF_LOWPRECISION;
	gib.flags = FL_NOTARGET;
	gib.velocity = v_to;
	gib.giblifetime	= time + f_lifetime;

	if (b_burn)
	{
		gib.think = ons_throwgib_think;
		gib.nextthink = time + 0.05;
	}
	else
		SUB_SetFade(gib, gib.giblifetime, 2);
}

void onslaught_updatelinks()
{
	entity l, links;
	// first check if the game has ended
	dprint("--- updatelinks ---\n");
	links = findchain(classname, "onslaught_link");
	// mark generators as being shielded and networked
	l = findchain(classname, "onslaught_generator");
	while (l)
	{
		if (l.iscaptured)
			dprint(etos(l), " (generator) belongs to team ", ftos(l.team), "\n");
		else
			dprint(etos(l), " (generator) is destroyed\n");
		l.islinked = l.iscaptured;
		l.isshielded = l.iscaptured;
		l.sprite.SendFlags |= 16;
		l = l.chain;
	}
	// mark points as shielded and not networked
	l = findchain(classname, "onslaught_controlpoint");
	while (l)
	{
		l.islinked = FALSE;
		l.isshielded = TRUE;
		float i;
		for(i = 0; i < 17; ++i) { l.isgenneighbor[i] = FALSE; l.iscpneighbor[i] = FALSE; }
		dprint(etos(l), " (point) belongs to team ", ftos(l.team), "\n");
		l.sprite.SendFlags |= 16;
		l = l.chain;
	}
	// flow power outward from the generators through the network
	l = links;
	while (l)
	{
		dprint(etos(l), " (link) connects ", etos(l.goalentity), " with ", etos(l.enemy), "\n");
		l = l.chain;
	}
	float stop = FALSE;
	while (!stop)
	{
		stop = TRUE;
		l = links;
		while (l)
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
							dprint(etos(l), " (link) is marking ", etos(l.goalentity), " (point) because its team matches ", etos(l.enemy), " (point)\n");
						}
						else if (!l.enemy.islinked)
						{
							stop = FALSE;
							l.enemy.islinked = TRUE;
							dprint(etos(l), " (link) is marking ", etos(l.enemy), " (point) because its team matches ", etos(l.goalentity), " (point)\n");
						}
					}
			l = l.chain;
		}
	}
	// now that we know which points are powered we can mark their neighbors
	// as unshielded if team differs
	l = links;
	while (l)
	{
		if (l.goalentity.islinked)
		{
			if(DIFF_TEAM(l.goalentity, l.enemy))
			{
				dprint(etos(l), " (link) is unshielding ", etos(l.enemy), " (point) because its team does not match ", etos(l.goalentity), " (point)\n");
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
				dprint(etos(l), " (link) is unshielding ", etos(l.goalentity), " (point) because its team does not match ", etos(l.enemy), " (point)\n");
				l.goalentity.isshielded = FALSE;
			}
			if(l.enemy.classname == "onslaught_generator")
				l.goalentity.isgenneighbor[l.enemy.team] = TRUE;
			else
				l.goalentity.iscpneighbor[l.enemy.team] = TRUE;
		}
		l = l.chain;
	}
	// now update the takedamage and alpha variables on generator shields
	l = findchain(classname, "onslaught_generator");
	while (l)
	{
		if (l.isshielded)
		{
			dprint(etos(l), " (generator) is shielded\n");
			l.takedamage = DAMAGE_NO;
			l.bot_attack = FALSE;
		}
		else
		{
			dprint(etos(l), " (generator) is not shielded\n");
			l.takedamage = DAMAGE_AIM;
			l.bot_attack = TRUE;
		}
		l = l.chain;
	}
	// now update the takedamage and alpha variables on control point icons
	l = findchain(classname, "onslaught_controlpoint");
	while (l)
	{
		if (l.isshielded)
		{
			dprint(etos(l), " (point) is shielded\n");
			if (l.goalentity)
			{
				l.goalentity.takedamage = DAMAGE_NO;
				l.goalentity.bot_attack = FALSE;
			}
		}
		else
		{
			dprint(etos(l), " (point) is not shielded\n");
			if (l.goalentity)
			{
				l.goalentity.takedamage = DAMAGE_AIM;
				l.goalentity.bot_attack = TRUE;
			}
		}
		onslaught_controlpoint_updatesprite(l);
		l = l.chain;
	}
	// count generators owned by each team
	float t1 = 0, t2 = 0, t3 = 0, t4 = 0;
	l = findchain(classname, "onslaught_generator");
	while (l)
	{
		if (l.iscaptured)
		{
			switch(l.team)
			{
				case NUM_TEAM_1: t1 = 1; break;
				case NUM_TEAM_2: t2 = 1; break;
				case NUM_TEAM_3: t3 = 1; break;
				case NUM_TEAM_4: t4 = 1; break;
			}
		}
		onslaught_generator_updatesprite(l);
		l = l.chain;
	}
	l = findchain(classname, "ons_captureshield");
	while(l)
	{
		l.team = l.enemy.team;
		l.colormap = l.enemy.colormap;
		l = l.chain;
	}
	// see if multiple teams remain (if not, it's game over)
	if (t1 + t2 + t3 + t4 < 2)
		dprint("--- game over ---\n");
	else
		dprint("--- done updating links ---\n");
}

float onslaught_controlpoint_can_be_linked(entity cp, float t)
{
	if(cp.isgenneighbor[t]) { return 2; }
	if(cp.iscpneighbor[t]) { return 1; }

	return 0;
}

float onslaught_controlpoint_attackable(entity cp, float t)
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
		if(cp.team == t)
		{
			a = onslaught_controlpoint_can_be_linked(cp, t);
			if(a) // attackable by enemy?
				return -2; // EMERGENCY!
			return -1;
		}
		// we know it can be linked, so no need to check
		// but...
		a = onslaught_controlpoint_can_be_linked(cp, t);
		if(a == 2) // near our generator?
			return 3; // EMERGENCY!
		return 1;
	}
	else
	{
		// free point
		if(onslaught_controlpoint_can_be_linked(cp, t))
		{
			a = onslaught_controlpoint_can_be_linked(cp, t); // why was this here NUM_TEAM_1 + NUM_TEAM_2 - t
			if(a == 2)
				return 4; // GET THIS ONE NOW!
			else
				return 2; // TOUCH ME
		}
	}
	return 0;
}

float overtime_msg_time[17];
void onslaught_generator_think()
{
	entity e;
	self.nextthink = ceil(time + 1);
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

void onslaught_generator_ring_spawn(vector org)
{
	modeleffect_spawn("models/onslaught/shockwavetransring.md3", 0, 0, org, '0 0 0', '0 0 0', '0 0 0', 0, -16, 0.1, 1.25, 0.25);
}

void onslaught_generator_ray_think()
{
	self.nextthink = time + 0.05;
	if(self.count > 10)
	{
		self.think = SUB_Remove;
		return;
	}

	if(self.count > 5)
		self.alpha -= 0.1;
	else
		self.alpha += 0.1;

	self.scale += 0.2;
	self.count +=1;
}

void onslaught_generator_ray_spawn(vector org)
{
	entity e;
	e = spawn();
	setmodel(e, "models/onslaught/ons_ray.md3");
	setorigin(e, org);
	e.angles = randomvec() * 360;
	e.alpha = 0;
	e.scale = random() * 5 + 8;
	e.think = onslaught_generator_ray_think;
	e.nextthink = time + 0.05;
}

void onslaught_generator_shockwave_spawn(vector org)
{
	shockwave_spawn("models/onslaught/shockwave.md3", org, -64, 0.75, 0.5);
}

void onslaught_generator_damage_think()
{
	if(self.owner.health < 0)
	{
		self.think = SUB_Remove;
		return;
	}
	self.nextthink = time+0.1;

	// damaged fx (less probable the more damaged is the generator)
	if(random() < 0.9 - self.owner.health / self.owner.max_health)
		if(random() < 0.01)
		{
			pointparticles(particleeffectnum("electro_ballexplode"), self.origin + randompos('-50 -50 -20', '50 50 50'), '0 0 0', 1);
			sound(self, CH_TRIGGER, "onslaught/electricity_explode.wav", VOL_BASE, ATTEN_NORM);
		}
		else
			pointparticles(particleeffectnum("torch_small"), self.origin + randompos('-60 -60 -20', '60 60 60'), '0 0 0', 1);
}

void onslaught_generator_damage_spawn(entity gd_owner)
{
	entity e;
	e = spawn();
	e.owner = gd_owner;
	e.health = self.owner.health;
	setorigin(e, gd_owner.origin);
	e.think = onslaught_generator_damage_think;
	e.nextthink = time+1;
}

void onslaught_generator_deaththink()
{
	vector org;
	float i;

	if (!self.count)
		self.count = 40;

	// White shockwave
	if(self.count==40||self.count==20)
	{
		onslaught_generator_ring_spawn(self.origin);
		sound(self, CH_TRIGGER, "onslaught/shockwave.wav", VOL_BASE, ATTEN_NORM);
	}

	// Throw some gibs
	if(random() < 0.3)
	{
		i = random();
		if(i < 0.3)
			ons_throwgib(self.origin + '0 0 40', (100 * randomvec() - '1 1 1') * 11 + '0 0 20', "models/onslaught/gen_gib1.md3", 6, TRUE);
		else if(i > 0.7)
			ons_throwgib(self.origin + '0 0 40', (100 * randomvec() - '1 1 1') * 12 + '0 0 20', "models/onslaught/gen_gib2.md3", 6, TRUE);
		else
			ons_throwgib(self.origin + '0 0 40', (100 * randomvec() - '1 1 1') * 13 + '0 0 20', "models/onslaught/gen_gib3.md3", 6, TRUE);
	}

	// Spawn fire balls
	for(i=0;i < 10;++i)
	{
		org = self.origin + randompos('-30 -30 -30' * i + '0 0 -20', '30 30 30' * i + '0 0 20');
		pointparticles(particleeffectnum("onslaught_generator_gib_explode"), org, '0 0 0', 1);
	}

	// Short explosion sound + small explosion
	if(random() < 0.25)
	{
		te_explosion(self.origin);
		sound(self, CH_TRIGGER, "weapons/grenade_impact.wav", VOL_BASE, ATTEN_NORM);
	}

	// Particles
	org = self.origin + randompos(self.mins + '8 8 8', self.maxs + '-8 -8 -8');
	pointparticles(particleeffectnum("onslaught_generator_smallexplosion"), org, '0 0 0', 1);

	// rays
	if(random() > 0.25 )
	{
		onslaught_generator_ray_spawn(self.origin);
	}

	// Final explosion
	if(self.count==1)
	{
		org = self.origin;
		te_explosion(org);
		onslaught_generator_shockwave_spawn(org);
		pointparticles(particleeffectnum("onslaught_generator_finalexplosion"), org, '0 0 0', 1);
		sound(self, CH_TRIGGER, "weapons/rocket_impact.wav", VOL_BASE, ATTEN_NORM);
	}
	else
		self.nextthink = time + 0.05;

	self.count = self.count - 1;
}

void onslaught_generator_damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	float i;
	if (damage <= 0)
		return;
	if(warmup_stage)
		return;
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
	else if (!warmup_stage)
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
		self.think = onslaught_generator_deaththink; // explosion sequence
		self.nextthink = time; // start exploding immediately
		self.think(); // do the first explosion now

		WaypointSprite_UpdateMaxHealth(self.sprite, 0);
		WaypointSprite_Ping(self.sprite);
		//WaypointSprite_Kill(self.sprite); // can't do this yet, code too poor

		onslaught_updatelinks();
	}

	// Throw some flaming gibs on damage, more damage = more chance for gib
	if(random() < damage/220)
	{
		sound(self, CH_TRIGGER, "weapons/rocket_impact.wav", VOL_BASE, ATTEN_NORM);
		i = random();
		if(i < 0.3)
			ons_throwgib(hitloc + '0 0 20', force * -1, "models/onslaught/gen_gib1.md3", 5, TRUE);
		else if(i > 0.7)
			ons_throwgib(hitloc + '0 0 20', force * -1, "models/onslaught/gen_gib2.md3", 5, TRUE);
		else
			ons_throwgib(hitloc + '0 0 20', force * -1, "models/onslaught/gen_gib3.md3", 5, TRUE);
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

	//throw some gibs on damage
	if(random() < damage/200+0.2)
		if(random() < 0.5)
			ons_throwgib(hitloc + '0 0 20', randomvec()*360, "models/onslaught/gen_gib1.md3", 5, FALSE);

	self.SendFlags |= GSF_STATUS;
}

// update links after a delay
void onslaught_generator_delayed()
{
	onslaught_updatelinks();
	// now begin normal thinking
	generator_link(onslaught_generator_think);

	self.SendFlags = GSF_SETUP;
}

string onslaught_generator_waypointsprite(entity e)
{
	if(e.isshielded)
		return "ons-gen-shielded";
	return "ons-gen";
}

void onslaught_generator_updatesprite(entity e)
{
	string s1;
	s1 = onslaught_generator_waypointsprite(e);
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

string onslaught_controlpoint_waypointsprite(entity e)
{
	float a;
	if(e.team)
	{
		a = onslaught_controlpoint_attackable(e, e.team);
		if(a == 3 || a == 4) // ATTACK/TOUCH THIS ONE NOW
		{
			switch(e.team)
			{
				case NUM_TEAM_1: return "ons-cp-atck-red";
				case NUM_TEAM_2: return "ons-cp-atck-blue";
				case NUM_TEAM_3: return "ons-cp-atck-yellow";
				case NUM_TEAM_4: return "ons-cp-atck-pink";
				default: return "ons-cp-atck-neut";
			}
		}
		else if(a == -2) // DEFEND THIS ONE NOW
		{
			switch(e.team)
			{
				case NUM_TEAM_1: return "ons-cp-dfnd-red";
				case NUM_TEAM_2: return "ons-cp-dfnd-blue";
				case NUM_TEAM_3: return "ons-cp-dfnd-yellow";
				case NUM_TEAM_4: return "ons-cp-dfnd-pink";
			}
		}
		else if(a == -1 || a == 1) // own point, or fire at it
		{
			switch(e.team)
			{
				case NUM_TEAM_1: return "ons-cp-red";
				case NUM_TEAM_2: return "ons-cp-blue";
				case NUM_TEAM_3: return "ons-cp-yellow";
				case NUM_TEAM_4: return "ons-cp-pink";
			}
		}
		else if(a == 2) // touch it
			return "ons-cp-neut";
	}
	else
	{
		switch(e.team)
		{
			case NUM_TEAM_1: return "ons-cp-red";
			case NUM_TEAM_2: return "ons-cp-blue";
			case NUM_TEAM_3: return "ons-cp-yellow";
			case NUM_TEAM_4: return "ons-cp-pink";
			default: return "ons-cp-neut";
		}
	}
	return "";
}

void onslaught_controlpoint_updatesprite(entity e)
{
	string s1;
	s1 = onslaught_controlpoint_waypointsprite(e);
	WaypointSprite_UpdateSprites(e.sprite, s1, s1, s1);

	float sh;
	sh = !(onslaught_controlpoint_can_be_linked(e, NUM_TEAM_1) || onslaught_controlpoint_can_be_linked(e, NUM_TEAM_2) || onslaught_controlpoint_can_be_linked(e, NUM_TEAM_3) || onslaught_controlpoint_can_be_linked(e, NUM_TEAM_4));

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

void onslaught_generator_reset()
{
	self.team = self.team_saved;
	self.lasthealth = self.max_health = self.health = autocvar_g_onslaught_gen_health;
	self.takedamage = DAMAGE_AIM;
	self.bot_attack = TRUE;
	self.iscaptured = TRUE;
	self.islinked = TRUE;
	self.isshielded = TRUE;
	self.event_damage = onslaught_generator_damage;
	self.think = onslaught_generator_delayed;
	self.nextthink = time + 0.2;

	self.SendFlags |= GSF_STATUS;

	WaypointSprite_UpdateMaxHealth(self.sprite, self.max_health);
	WaypointSprite_UpdateHealth(self.sprite, self.health);
}

float ons_Generator_Customize()
{
	entity e, wp_owner;
	e = WaypointSprite_getviewentity(other);
	wp_owner = self.owner;
	//if(wp_owner.health >= wp_owner.max_health) { return FALSE; }
	if(wp_owner.isshielded && wp_owner.health >= wp_owner.max_health) { return FALSE; }

	return TRUE;
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

	precache_model("models/onslaught/generator_shield.md3");
	precache_model("models/onslaught/shockwave.md3");
	precache_model("models/onslaught/shockwavetransring.md3");
	precache_model("models/onslaught/gen_gib1.md3");
	precache_model("models/onslaught/gen_gib2.md3");
	precache_model("models/onslaught/gen_gib3.md3");
	precache_model("models/onslaught/ons_ray.md3");
	precache_sound("onslaught/generator_decay.wav");
	precache_sound("weapons/grenade_impact.wav");
	precache_sound("weapons/rocket_impact.wav");
	precache_sound("onslaught/generator_underattack.wav");
	precache_sound("onslaught/shockwave.wav");
	precache_sound("onslaught/ons_hit1.wav");
	precache_sound("onslaught/ons_hit2.wav");
	precache_sound("onslaught/electricity_explode.wav");
	precache_sound("onslaught/generator_underattack.wav");
	if (!self.team)
		objerror("team must be set");

	self.team_saved = self.team;
	self.colormap = 1024 + (self.team - 1) * 17;
	self.solid = SOLID_BBOX;
	self.movetype = MOVETYPE_NONE;
	self.lasthealth = self.max_health = self.health = autocvar_g_onslaught_gen_health;
	setsize(self, GENERATOR_MIN, GENERATOR_MAX);
	setorigin(self, self.origin);
	self.takedamage = DAMAGE_AIM;
	self.bot_attack = TRUE;
	self.event_damage = onslaught_generator_damage;
	self.iscaptured = TRUE;
	self.islinked = TRUE;
	self.isshielded = TRUE;
	// helper entity that create fx when generator is damaged
	onslaught_generator_damage_spawn(self);

	ons_CaptureShield_Spawn(self, TRUE);
	
	InitializeEntity(self, onslaught_generator_delayed, INITPRIO_LAST);

	WaypointSprite_SpawnFixed(string_null, self.origin + '0 0 128', self, sprite, RADARICON_NONE, '0 0 0');
	WaypointSprite_UpdateRule(self.sprite, NUM_TEAM_2, SPRITERULE_TEAMPLAY);
	WaypointSprite_UpdateMaxHealth(self.sprite, self.max_health);
	WaypointSprite_UpdateHealth(self.sprite, self.health);
	//self.sprite.customizeentityforclient = ons_Generator_Customize;

	waypoint_spawnforitem(self);

	onslaught_updatelinks();

	self.reset = onslaught_generator_reset;
}

.float waslinked;

void onslaught_controlpoint_icon_damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	entity oself;

	if (damage <= 0)
		return;
	if (self.owner.isshielded)
	{
		// this is protected by a shield, so ignore the damage
		if (time > self.pain_finished)
			if (IS_PLAYER(attacker))
			{
				play2(attacker, "onslaught/damageblockedbyshield.wav");
				self.pain_finished = time + 1;
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
		{
			Send_Notification(NOTIF_ALL, world, MSG_INFO, APP_TEAM_NUM_4(self.team, INFO_ONSLAUGHT_CPDESTROYED_), self.owner.message, attacker.netname);
			ons_throwgib(self.origin, (2 * randomvec() - '1 1 1') * 25, "models/onslaught/controlpoint_icon_gib1.md3", 3, FALSE);
			ons_throwgib(self.origin, (2 * randomvec() - '1 1 1') * 45, "models/onslaught/controlpoint_icon_gib2.md3", 3, FALSE);
			ons_throwgib(self.origin, (2 * randomvec() - '1 1 1') * 45, "models/onslaught/controlpoint_icon_gib2.md3", 3, FALSE);
			ons_throwgib(self.origin, (2 * randomvec() - '1 1 1') * 75, "models/onslaught/controlpoint_icon_gib4.md3", 3, FALSE);
			ons_throwgib(self.origin, (2 * randomvec() - '1 1 1') * 75, "models/onslaught/controlpoint_icon_gib4.md3", 3, FALSE);
			ons_throwgib(self.origin, (2 * randomvec() - '1 1 1') * 75, "models/onslaught/controlpoint_icon_gib4.md3", 3, FALSE);
			ons_throwgib(self.origin, (2 * randomvec() - '1 1 1') * 75, "models/onslaught/controlpoint_icon_gib4.md3", 3, FALSE);
		}
		
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

void onslaught_controlpoint_icon_think()
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
            onslaught_controlpoint_icon_damage(self, self, 1, 0, self.origin, '0 0 0');
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

void onslaught_controlpoint_icon_buildthink()
{
	entity oself;
	float a;

	self.nextthink = time + CP_THINKRATE;

	// only do this if there is power
	a = onslaught_controlpoint_can_be_linked(self.owner, self.owner.team);
	if(!a)
		return;

	self.health = self.health + self.count;
	
	self.SendFlags |= CPSF_STATUS;

	if (self.health >= self.max_health)
	{
		self.health = self.max_health;
		self.count = autocvar_g_onslaught_cp_regen * CP_THINKRATE; // slow repair rate from now on
		self.think = onslaught_controlpoint_icon_think;
		sound(self, CH_TRIGGER, "onslaught/controlpoint_built.wav", VOL_BASE, ATTEN_NORM);
		self.owner.iscaptured = TRUE;
		//self.solid = SOLID_BBOX;

		WaypointSprite_UpdateMaxHealth(self.owner.sprite, self.max_health);
		WaypointSprite_UpdateHealth(self.owner.sprite, self.health);

		Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_ONSLAUGHT_CAPTURE, self.owner.ons_toucher.netname, self.owner.message);
		Send_Notification(NOTIF_ALL_EXCEPT, self.owner.ons_toucher, MSG_CENTER, APP_TEAM_ENT_4(self.owner.ons_toucher, CENTER_ONS_CAPTURE_), self.owner.message);
		Send_Notification(NOTIF_ONE, self.owner.ons_toucher, MSG_CENTER, CENTER_ONS_CAPTURE, self.owner.message);
		PlayerScore_Add(self.owner.ons_toucher, SP_ONS_CAPS, 1);
		PlayerTeamScore_AddScore(self.owner.ons_toucher, 10);
		
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

void onslaught_controlpoint_touch()
{
	entity e, toucher = other;
	float a;
	
	if(IS_VEHICLE(toucher) && toucher.owner)
	if(autocvar_g_onslaught_allow_vehicle_touch)
		toucher = toucher.owner;
	else
		return;
		
	if(!IS_PLAYER(toucher)) { return; }
		
	a = onslaught_controlpoint_attackable(self, other.team);
	if(a != 2 && a != 4)
		return;
	// we've verified that this player has a legitimate claim to this point,
	// so start building the captured point icon (which only captures this
	// point if it successfully builds without being destroyed first)
	self.goalentity = e = spawn();
	e.classname = "onslaught_controlpoint_icon";
	e.owner = self;
	e.max_health = autocvar_g_onslaught_cp_health;
	e.health = autocvar_g_onslaught_cp_buildhealth;
	e.solid = SOLID_CORPSE;
	e.movetype = MOVETYPE_NONE;
	//setmodel(e, "models/onslaught/controlpoint_icon.md3");
	setsize(e, CPICON_MIN, CPICON_MAX);
	setorigin(e, self.origin + '0 0 96');
	e.takedamage = DAMAGE_AIM;
	e.bot_attack = TRUE;
	e.event_damage = onslaught_controlpoint_icon_damage;
	e.team = other.team;
	e.colormap = 1024 + (e.team - 1) * 17;
	e.count = (e.max_health - e.health) * CP_THINKRATE / autocvar_g_onslaught_cp_buildtime; // how long it takes to build
	sound(e, CH_TRIGGER, "onslaught/controlpoint_build.wav", VOL_BASE, ATTEN_NORM);
	self.team = e.team;
	self.colormap = e.colormap;
	WaypointSprite_UpdateBuildFinished(self.sprite, time + (e.max_health - e.health) / (e.count / CP_THINKRATE));
	self.ons_toucher = other;
	onslaught_updatelinks();
	
	onslaught_controlpoint_icon_link(e, onslaught_controlpoint_icon_buildthink);
}

void onslaught_controlpoint_think()
{
	self.nextthink = time + CP_THINKRATE;
	CSQCMODEL_AUTOUPDATE();
}

void onslaught_controlpoint_reset()
{
	if(self.goalentity && self.goalentity != world)
		remove(self.goalentity);
	self.goalentity = world;
	self.team = 0;
	self.colormap = 1024;
	self.iscaptured = FALSE;
	self.islinked = FALSE;
	self.isshielded = TRUE;
	self.think = onslaught_controlpoint_think;
	self.ons_toucher = world;
	self.nextthink = time + CP_THINKRATE; // don't like func_null :P
	setmodel_fixsize(self, "models/onslaught/controlpoint_pad.md3");
	//setsize(self, '-32 -32 0', '32 32 8');

	WaypointSprite_UpdateMaxHealth(self.sprite, 0);

	onslaught_updatelinks();

	activator = self;
	SUB_UseTargets(); // to reset the structures, playerspawns etc.

	CSQCMODEL_AUTOUPDATE();
}

float ons_ControlPoint_Customize()
{
	entity e, wp_owner;
	e = WaypointSprite_getviewentity(other);
	wp_owner = self.owner;
	if(SAME_TEAM(e, wp_owner) && wp_owner.goalentity.health >= wp_owner.goalentity.max_health) { return FALSE; }
	if(!onslaught_controlpoint_attackable(wp_owner, e.team)) { return FALSE; }

	return TRUE;
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

	self.solid = SOLID_BBOX;
	self.movetype = MOVETYPE_NONE;
	setmodel_fixsize(self, "models/onslaught/controlpoint_pad.md3");
	//setsize(self, '-32 -32 0', '32 32 8');
	if(!self.noalign)
	{
		setorigin(self, self.origin + '0 0 20');
		droptofloor();
	}
	self.touch = onslaught_controlpoint_touch;
	self.team = 0;
	self.colormap = 1024;
	self.iscaptured = FALSE;
	self.islinked = FALSE;
	self.isshielded = TRUE;
	
	if(self.message == "") { self.message = "a"; }

	waypoint_spawnforitem(self);

	self.think = onslaught_controlpoint_think;
	self.nextthink = time + CP_THINKRATE;

	self.reset = onslaught_controlpoint_reset;

	WaypointSprite_SpawnFixed(string_null, self.origin + '0 0 128', self, sprite, RADARICON_NONE, '0 0 0');
	WaypointSprite_UpdateRule(self.sprite, NUM_TEAM_2, SPRITERULE_TEAMPLAY);
	//self.sprite.customizeentityforclient = ons_ControlPoint_Customize;

	onslaught_updatelinks();
	
	ons_CaptureShield_Spawn(self, FALSE);

	CSQCMODEL_AUTOINIT();
}

float onslaught_link_send(entity to, float sendflags)
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

void onslaught_link_checkupdate()
{
	// TODO check if the two sides have moved (currently they won't move anyway)
	float redpower, bluepower, yellowpower, pinkpower;

	redpower = bluepower = yellowpower = pinkpower = 0;
	if(self.goalentity.islinked)
	{
		switch(self.goalentity.team)
		{
			case NUM_TEAM_1: redpower = 1; break;
			case NUM_TEAM_2: bluepower = 1; break;
			case NUM_TEAM_3: yellowpower = 1; break;
			case NUM_TEAM_4: pinkpower = 1; break;
		}
	}
	if(self.enemy.islinked)
	{
		switch(self.enemy.team)
		{
			case NUM_TEAM_1: redpower = 2; break;
			case NUM_TEAM_2: bluepower = 2; break;
			case NUM_TEAM_3: yellowpower = 2; break;
			case NUM_TEAM_4: pinkpower = 2; break;
		}
	}

	float cc = 0;
	
	/*if(redpower == 1 && bluepower == 2)
		cc = (NUM_TEAM_1 - 1) * 0x01 + (NUM_TEAM_2 - 1) * 0x10;
	else if(redpower == 2 && bluepower == 1)
		cc = (NUM_TEAM_1 - 1) * 0x10 + (NUM_TEAM_2 - 1) * 0x01;
	else if(redpower)
		cc = (NUM_TEAM_1 - 1) * 0x11;
	else if(bluepower)
		cc = (NUM_TEAM_2 - 1) * 0x11;
	else
		cc = 0;*/

	if(redpower == 1) { cc = (NUM_TEAM_1 - 1) * 0x01; }
	else if(bluepower == 1) { cc = (NUM_TEAM_2 - 1) * 0x01; }
	else if(yellowpower == 1) { cc = (NUM_TEAM_3 - 1) * 0x01; }
	else if(pinkpower == 1) { cc = (NUM_TEAM_4 - 1) * 0x01; }
	else if(redpower) { cc = (NUM_TEAM_1 - 1) * 0x11; goto skip; }
	else if(bluepower) { cc = (NUM_TEAM_2 - 1) * 0x11; goto skip; }
	else if(yellowpower) { cc = (NUM_TEAM_3 - 1) * 0x11; goto skip; }
	else if(pinkpower) { cc = (NUM_TEAM_4 - 1) * 0x11; goto skip; }
	else { cc = 0; }
	
	if(redpower == 2) { cc += (NUM_TEAM_1 - 1) * 0x10; }
	else if(bluepower == 2) { cc += (NUM_TEAM_2 - 1) * 0x10; }
	else if(yellowpower == 2) { cc += (NUM_TEAM_3 - 1) * 0x10; }
	else if(pinkpower == 2) { cc += (NUM_TEAM_4 - 1) * 0x10; }
	
	:skip

	//print(etos(self), " rp=", ftos(redpower), " bp=", ftos(bluepower), " ");
	//print("cc=", ftos(cc), "\n");

	if(cc != self.clientcolors)
	{
		self.clientcolors = cc;
		self.SendFlags |= 4;
	}

	self.nextthink = time;
}

void onslaught_link_delayed()
{
	self.goalentity = find(world, targetname, self.target);
	self.enemy = find(world, targetname, self.target2);
	if (!self.goalentity)
		objerror("can not find target\n");
	if (!self.enemy)
		objerror("can not find target2\n");
	dprint(etos(self.goalentity), " linked with ", etos(self.enemy), "\n");
	self.SendFlags |= 3;
	self.think = onslaught_link_checkupdate;
	self.nextthink = time;
}

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
	InitializeEntity(self, onslaught_link_delayed, INITPRIO_FINDTARGET);
	Net_LinkEntity(self, FALSE, 0, onslaught_link_send);
}

// bot junk
#define HAVOCBOT_ONS_ROLE_NONE 		0
#define HAVOCBOT_ONS_ROLE_DEFENSE	2
#define HAVOCBOT_ONS_ROLE_ASSISTANT	4
#define HAVOCBOT_ONS_ROLE_OFFENSE	8

.float havocbot_role_flags;
.float havocbot_attack_time;

.void() havocbot_role;
.void() havocbot_previous_role;

void() havocbot_role_ons_defense;
void() havocbot_role_ons_offense;
void() havocbot_role_ons_assistant;

void(entity bot) havocbot_ons_reset_role;
void(float ratingscale, vector org, float sradius) havocbot_goalrating_items;
void(float ratingscale, vector org, float sradius) havocbot_goalrating_enemyplayers;

.entity havocbot_ons_target;

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

//	dprint(self.netname, " needs weapons ", ftos(needweapons) , "\n");
//	dprint(self.netname, " needs armor ", ftos(needarmor) , "\n");

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
	dprint(strcat(bot.netname," switched to "));
	switch(role)
	{
		case HAVOCBOT_ONS_ROLE_DEFENSE:
			dprint("defense");
			bot.havocbot_role = havocbot_role_ons_defense;
			bot.havocbot_role_flags = HAVOCBOT_ONS_ROLE_DEFENSE;
			bot.havocbot_role_timeout = 0;
			break;
		case HAVOCBOT_ONS_ROLE_ASSISTANT:
			dprint("assistant");
			bot.havocbot_role = havocbot_role_ons_assistant;
			bot.havocbot_role_flags = HAVOCBOT_ONS_ROLE_ASSISTANT;
			bot.havocbot_role_timeout = 0;
			break;
		case HAVOCBOT_ONS_ROLE_OFFENSE:
			dprint("offense");
			bot.havocbot_role = havocbot_role_ons_offense;
			bot.havocbot_role_flags = HAVOCBOT_ONS_ROLE_OFFENSE;
			bot.havocbot_role_timeout = 0;
			break;
	}
	dprint("\n");
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

	cp1 = cp2 = findchain(classname, "onslaught_controlpoint");

	// Filter control points
	for (; cp2; cp2 = cp2.chain)
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
	for (; cp1; cp1 = cp1.chain)
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

//	dprint(self.netname, " chose cp ranked ", ftos(bestvalue), "\n");

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
	//	dprint(self.netname, " found an attackable controlpoint at ", vtos(cp.origin) ,"\n");
	}
	else
	{
		// Should be touched
		// dprint(self.netname, " found a touchable controlpoint at ", vtos(cp.origin) ,"\n");
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

	for (g = findchain(classname, "onslaught_generator"); g; g = g.chain)
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
		//	dprint("waypoints found around generator\n");
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
		//	dprint("generator found without waypoints around\n");
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

// ===============
//  Round Handler
// ===============
float total_generators, redowned, blueowned, yellowowned, pinkowned;
void Onslaught_count_generators()
{
	entity e;
	total_generators = redowned = blueowned = yellowowned = pinkowned = 0;
	for(e = world; (e = find(e, classname, "onslaught_generator")) != world; )
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
		entity oldself = self;
		float d;
		for(self = findchain(classname, "onslaught_generator"); self; self = self.chain) if(time >= self.ons_overtime_damagedelay)
		{
			if(!overtime_msg_time[self.team])
			{
				Send_Notification(NOTIF_ALL, world, MSG_CENTER, CENTER_OVERTIME_CONTROLPOINT);
				//sound(self, CH_TRIGGER, "onslaught/generator_decay.wav", VOL_BASE, ATTEN_NORM);
				play2team(self.team, "onslaught/generator_decay.wav");
				overtime_msg_time[self.team] = 1;
			}
			// self.max_health / 300 gives 5 minutes of overtime.
			// control points reduce the overtime duration.
			d = 1;
			e = findchain(classname, "onslaught_controlpoint");
			while (e)
			{
				if(DIFF_TEAM(e, self))
				if(e.islinked)
					d = d + 1;
				e = e.chain;
			}

			if(autocvar_g_campaign && autocvar__campaign_testrun)
				d = d * self.max_health;
			else
				d = d * self.max_health / max(30, 60 * autocvar_timelimit_suddendeath);

			Damage(self, self, self, d, DEATH_HURTTRIGGER, self.origin, '0 0 0');
			
			self.sprite.SendFlags |= 16;

			self.ons_overtime_damagedelay = ceil(time + 1);
		}

		self = oldself;
	}
	else
	{
		float i;
		for(i = 0; i < 17; ++i)
			overtime_msg_time[i] = 0;
	}

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
	
	round_handler_Init(7, autocvar_g_onslaught_warmup, autocvar_g_onslaught_round_timelimit);
	
	FOR_EACH_PLAYER(e)
	{
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
	entity e;
	FOR_EACH_PLAYER(e) { e.player_blocked = FALSE; }
	e = findchain(classname, "onslaught_controlpoint");
	while(e) { e.sprite.SendFlags |= 16; e = e.chain; }
	e = findchain(classname, "onslaught_generator");
	while(e) { e.sprite.SendFlags |= 16; e = e.chain; }
}


// ==============
// Hook Functions
// ==============

MUTATOR_HOOKFUNCTION(ons_ResetMap)
{
	FOR_EACH_PLAYER(self) { self.ons_deathloc = '0 0 0'; PutClientInServer(); }
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

	if(autocvar_g_onslaught_spawn_at_controlpoints)
	if(random() <= autocvar_g_onslaught_spawn_at_controlpoints_chance)
	{
		float random_target = autocvar_g_onslaught_spawn_at_controlpoints_random;
		entity tmp_entity, closest_target = world;
		vector spawn_loc = self.ons_deathloc;
		
		// new joining player or round reset, don't bother checking
		if(spawn_loc == '0 0 0') { return FALSE; }
		
		tmp_entity = findchain(classname, "onslaught_controlpoint");
		
		if(random_target) { RandomSelection_Init(); }

		while(tmp_entity)
		{
			if(SAME_TEAM(tmp_entity, self))
			if(random_target)
				RandomSelection_Add(tmp_entity, 0, string_null, 1, 1);
			else if(vlen(tmp_entity.origin - spawn_loc) <= vlen(closest_target.origin - spawn_loc) || closest_target == world)
				closest_target = tmp_entity;
			
			tmp_entity = tmp_entity.chain;
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
		
		tmp_entity = findchain(classname, "onslaught_generator");
		
		if(random_target) { RandomSelection_Init(); }

		while(tmp_entity)
		{
			if(random_target)
				RandomSelection_Add(tmp_entity, 0, string_null, 1, 1);
			else
			{
				if(SAME_TEAM(tmp_entity, self))
				if(vlen(tmp_entity.origin - spawn_loc) <= vlen(closest_target.origin - spawn_loc) || closest_target == world)
					closest_target = tmp_entity;
			}
			
			tmp_entity = tmp_entity.chain;
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
	entity head = findchain(classname, "onslaught_generator");
	while (head)
	{
		switch(head.team)
		{
			case NUM_TEAM_1: c1 = 0; break;
			case NUM_TEAM_2: c2 = 0; break;
			case NUM_TEAM_3: c3 = 0; break;
			case NUM_TEAM_4: c4 = 0; break;
		}
		head = head.chain;
	}

	return TRUE;
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
	ons_captureshield_force = autocvar_g_onslaught_shield_force;
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
