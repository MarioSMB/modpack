float autocvar_g_onslaught_spawn_at_controlpoints;
float autocvar_g_onslaught_spawn_at_generator;
float autocvar_g_onslaught_cp_proxydecap;
var float autocvar_g_onslaught_cp_proxydecap_distance = 512;
var float autocvar_g_onslaught_cp_proxydecap_dps = 100;

void onslaught_generator_updatesprite(entity e);
void onslaught_controlpoint_updatesprite(entity e);
void onslaught_link_checkupdate();

.entity sprite;
.string target2;
.float iscaptured;
.float islinked;
.float isgenneighbor_red;
.float isgenneighbor_blue;
.float iscpneighbor_red;
.float iscpneighbor_blue;
.float isshielded;
.float lasthealth;
.float lastteam;
.float lastshielded;
.float lastcaptured;

entity ons_red_generator;
entity ons_blue_generator;

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

	SETMODEL(gib, smodel);
	setorigin(gib, v_from);
	gib.solid = SOLID_BBOX;
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
	float stop, t1, t2, t3, t4;
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
		l = l.chain;
	}
	// mark points as shielded and not networked
	l = findchain(classname, "onslaught_controlpoint");
	while (l)
	{
		l.islinked = FALSE;
		l.isshielded = TRUE;
		l.isgenneighbor_red = FALSE;
		l.isgenneighbor_blue = FALSE;
		l.iscpneighbor_red = FALSE;
		l.iscpneighbor_blue = FALSE;
		dprint(etos(l), " (point) belongs to team ", ftos(l.team), "\n");
		l = l.chain;
	}
	// flow power outward from the generators through the network
	l = links;
	while (l)
	{
		dprint(etos(l), " (link) connects ", etos(l.goalentity), " with ", etos(l.enemy), "\n");
		l = l.chain;
	}
	stop = FALSE;
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
					if (l.enemy.team == l.goalentity.team)
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
			if (l.goalentity.team != l.enemy.team)
			{
				dprint(etos(l), " (link) is unshielding ", etos(l.enemy), " (point) because its team does not match ", etos(l.goalentity), " (point)\n");
				l.enemy.isshielded = FALSE;
			}
			if(l.goalentity.classname == "onslaught_generator")
			{
				if(l.goalentity.team == NUM_TEAM_1)
					l.enemy.isgenneighbor_red = TRUE;
				else if(l.goalentity.team == NUM_TEAM_2)
					l.enemy.isgenneighbor_blue = TRUE;
			}
			else
			{
				if(l.goalentity.team == NUM_TEAM_1)
					l.enemy.iscpneighbor_red = TRUE;
				else if(l.goalentity.team == NUM_TEAM_2)
					l.enemy.iscpneighbor_blue = TRUE;
			}
		}
		if (l.enemy.islinked)
		{
			if (l.goalentity.team != l.enemy.team)
			{
				dprint(etos(l), " (link) is unshielding ", etos(l.goalentity), " (point) because its team does not match ", etos(l.enemy), " (point)\n");
				l.goalentity.isshielded = FALSE;
			}
			if(l.enemy.classname == "onslaught_generator")
			{
				if(l.enemy.team == NUM_TEAM_1)
					l.goalentity.isgenneighbor_red = TRUE;
				else if(l.enemy.team == NUM_TEAM_2)
					l.goalentity.isgenneighbor_blue = TRUE;
			}
			else
			{
				if(l.enemy.team == NUM_TEAM_1)
					l.goalentity.iscpneighbor_red = TRUE;
				else if(l.enemy.team == NUM_TEAM_2)
					l.goalentity.iscpneighbor_blue = TRUE;
			}
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
			l.enemy.alpha = 1;
			l.takedamage = DAMAGE_NO;
			l.bot_attack = FALSE;
		}
		else
		{
			dprint(etos(l), " (generator) is not shielded\n");
			l.enemy.alpha = -1;
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
			l.enemy.alpha = 1;
			if (l.goalentity)
			{
				l.goalentity.takedamage = DAMAGE_NO;
				l.goalentity.bot_attack = FALSE;
			}
		}
		else
		{
			dprint(etos(l), " (point) is not shielded\n");
			l.enemy.alpha = -1;
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
	t1 = t2 = t3 = t4 = 0;
	l = findchain(classname, "onslaught_generator");
	while (l)
	{
		if (l.iscaptured)
		{
			if (l.team == NUM_TEAM_1) t1 = 1;
			if (l.team == NUM_TEAM_2) t2 = 1;
			if (l.team == NUM_TEAM_3) t3 = 1;
			if (l.team == NUM_TEAM_4) t4 = 1;
		}
		onslaught_generator_updatesprite(l);
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
	if(t == NUM_TEAM_1)
	{
		if(cp.isgenneighbor_red)
			return 2;
		if(cp.iscpneighbor_red)
			return 1;
	}
	else if(t == NUM_TEAM_2)
	{
		if(cp.isgenneighbor_blue)
			return 2;
		if(cp.iscpneighbor_blue)
			return 1;
	}
	return 0;
	/*
	   entity e;
	// check to see if this player has a legitimate claim to capture this
	// control point - more specifically that there is a captured path of
	// points leading back to the team generator
	e = findchain(classname, "onslaught_link");
	while (e)
	{
	if (e.goalentity == cp)
	{
	dprint(etos(e), " (link) connects to ", etos(e.enemy), " (point)");
	if (e.enemy.islinked)
	{
	dprint(" which is linked");
	if (e.enemy.team == t)
	{
	dprint(" and has the correct team!\n");
	return 1;
	}
	else
	dprint(" but has the wrong team\n");
	}
	else
	dprint("\n");
	}
	else if (e.enemy == cp)
	{
	dprint(etos(e), " (link) connects to ", etos(e.goalentity), " (point)");
	if (e.goalentity.islinked)
	{
	dprint(" which is linked");
	if (e.goalentity.team == t)
	{
	dprint(" and has a team!\n");
	return 1;
	}
	else
	dprint(" but has the wrong team\n");
	}
	else
	dprint("\n");
	}
	e = e.chain;
	}
	return 0;
	 */
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
			a = onslaught_controlpoint_can_be_linked(cp, NUM_TEAM_1 + NUM_TEAM_2 - t);
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
			a = onslaught_controlpoint_can_be_linked(cp, NUM_TEAM_1 + NUM_TEAM_2 - t);
			if(a == 2)
				return 4; // GET THIS ONE NOW!
			else
				return 2; // TOUCH ME
		}
	}
	return 0;
}

float overtime_msg_time;
void onslaught_generator_think()
{
	float d;
	entity e;
	self.nextthink = ceil(time + 1);
	if (!gameover)
	{
		if (autocvar_timelimit && time > game_starttime + autocvar_timelimit * 60)
		{
			if (!overtime_msg_time)
			{
				Send_Notification(NOTIF_ALL, world, MSG_CENTER, CENTER_OVERTIME_CONTROLPOINT);
				overtime_msg_time = time;
			}
			// self.max_health / 300 gives 5 minutes of overtime.
			// control points reduce the overtime duration.
			sound(self, CH_TRIGGER, "onslaught/generator_decay.wav", VOL_BASE, ATTEN_NORM);
			d = 1;
			e = findchain(classname, "onslaught_controlpoint");
			while (e)
			{
				if (e.team != self.team)
					if (e.islinked)
						d = d + 1;
				e = e.chain;
			}

			if(autocvar_g_campaign && autocvar__campaign_testrun)
				d = d * self.max_health;
			else
				d = d * self.max_health / max(30, 60 * autocvar_timelimit_suddendeath);

			Damage(self, self, self, d, DEATH_HURTTRIGGER, self.origin, '0 0 0');
		}
		else if (overtime_msg_time)
			overtime_msg_time = 0;

        if(!self.isshielded && self.wait < time)
        {
            self.wait = time + 5;
            FOR_EACH_REALPLAYER(e)
            {
				if(SAME_TEAM(e, self))
                {
					Send_Notification(NOTIF_ONE, e, MSG_CENTER, CENTER_ONS_NOTSHIELDED);
                    soundto(MSG_ONE, e, CHAN_AUTO, "kh/alarm.wav", VOL_BASE, ATTEN_NONE);    // FIXME: Uniqe sound?
                }
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
	SETMODEL(e, "models/onslaught/ons_ray.md3");
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
					self.pain_finished = time + 1;
				}
			return;
		}
		if (time > self.pain_finished)
		{
			self.pain_finished = time + 10;
			bprint(Team_ColoredFullName(self.team), " generator under attack!\n");
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
#ifdef ONSLAUGHT_SPAM
		float h, lh;
		lh = ceil(self.lasthealth / 100) * 100;
		h = ceil(self.health / 100) * 100;
		if(lh != h)
			bprint(Team_ColoredFullName(self.team), " generator has less than ", ftos(h), " health remaining\n");
#endif
		self.lasthealth = self.health;
	}
	else if (!warmup_stage)
	{
		if (attacker == self)
			bprint(Team_ColoredFullName(self.team), " generator spontaneously exploded due to overtime!\n");
		else
		{
			string t;
			t = Team_ColoredFullName(attacker.team);
			bprint(Team_ColoredFullName(self.team), " generator destroyed by ", t, "!\n");
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

string onslaught_generator_waypointsprite_for_team(entity e, float t)
{
	if(t == e.team)
	{
		if(e.team == NUM_TEAM_1)
			return "ons-gen-red";
		else if(e.team == NUM_TEAM_2)
			return "ons-gen-blue";
	}
	if(e.isshielded)
		return "ons-gen-shielded";
	if(e.team == NUM_TEAM_1)
		return "ons-gen-red";
	else if(e.team == NUM_TEAM_2)
		return "ons-gen-blue";
	return "";
}

void onslaught_generator_updatesprite(entity e)
{
	string s1, s2, s3;
	s1 = onslaught_generator_waypointsprite_for_team(e, NUM_TEAM_1);
	s2 = onslaught_generator_waypointsprite_for_team(e, NUM_TEAM_2);
	s3 = onslaught_generator_waypointsprite_for_team(e, -1);
	WaypointSprite_UpdateSprites(e.sprite, s1, s2, s3);

	if(e.lastteam != e.team + 2 || e.lastshielded != e.isshielded)
	{
		e.lastteam = e.team + 2;
		e.lastshielded = e.isshielded;
		if(e.lastshielded)
		{
			if(e.team == NUM_TEAM_1 || e.team == NUM_TEAM_2)
				WaypointSprite_UpdateTeamRadar(e.sprite, RADARICON_GENERATOR, 0.5 * colormapPaletteColor(e.team - 1, FALSE));
			else
				WaypointSprite_UpdateTeamRadar(e.sprite, RADARICON_GENERATOR, '0.5 0.5 0.5');
		}
		else
		{
			if(e.team == NUM_TEAM_1 || e.team == NUM_TEAM_2)
				WaypointSprite_UpdateTeamRadar(e.sprite, RADARICON_GENERATOR, colormapPaletteColor(e.team - 1, FALSE));
			else
				WaypointSprite_UpdateTeamRadar(e.sprite, RADARICON_GENERATOR, '0.75 0.75 0.75');
		}
		WaypointSprite_Ping(e.sprite);
	}
}

string onslaught_controlpoint_waypointsprite_for_team(entity e, float t)
{
	float a;
	if(t != -1)
	{
		a = onslaught_controlpoint_attackable(e, t);
		if(a == 3 || a == 4) // ATTACK/TOUCH THIS ONE NOW
		{
			if(e.team == NUM_TEAM_1)
				return "ons-cp-atck-red";
			else if(e.team == NUM_TEAM_2)
				return "ons-cp-atck-blue";
			else
				return "ons-cp-atck-neut";
		}
		else if(a == -2) // DEFEND THIS ONE NOW
		{
			if(e.team == NUM_TEAM_1)
				return "ons-cp-dfnd-red";
			else if(e.team == NUM_TEAM_2)
				return "ons-cp-dfnd-blue";
		}
		else if(e.team == t || a == -1 || a == 1) // own point, or fire at it
		{
			if(e.team == NUM_TEAM_1)
				return "ons-cp-red";
			else if(e.team == NUM_TEAM_2)
				return "ons-cp-blue";
		}
		else if(a == 2) // touch it
			return "ons-cp-neut";
	}
	else
	{
		if(e.team == NUM_TEAM_1)
			return "ons-cp-red";
		else if(e.team == NUM_TEAM_2)
			return "ons-cp-blue";
		else
			return "ons-cp-neut";
	}
	return "";
}

void onslaught_controlpoint_updatesprite(entity e)
{
	string s1, s2, s3;
	s1 = onslaught_controlpoint_waypointsprite_for_team(e, NUM_TEAM_1);
	s2 = onslaught_controlpoint_waypointsprite_for_team(e, NUM_TEAM_2);
	s3 = onslaught_controlpoint_waypointsprite_for_team(e, -1);
	WaypointSprite_UpdateSprites(e.sprite, s1, s2, s3);

	float sh;
	sh = !(onslaught_controlpoint_can_be_linked(e, NUM_TEAM_1) || onslaught_controlpoint_can_be_linked(e, NUM_TEAM_2));

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
			if(e.team == NUM_TEAM_1 || e.team == NUM_TEAM_2)
				WaypointSprite_UpdateTeamRadar(e.sprite, RADARICON_CONTROLPOINT, 0.5 * colormapPaletteColor(e.team - 1, FALSE));
			else
				WaypointSprite_UpdateTeamRadar(e.sprite, RADARICON_CONTROLPOINT, '0.5 0.5 0.5');
		}
		else
		{
			if(e.team == NUM_TEAM_1 || e.team == NUM_TEAM_2)
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
	self.enemy.solid = SOLID_NOT;
	self.think = onslaught_generator_delayed;
	self.nextthink = time + 0.2;
	SETMODEL(self, "models/onslaught/generator.md3");
	setsize(self, GENERATOR_MIN, GENERATOR_MAX);

	self.SendFlags |= GSF_STATUS;

	if(!self.noalign)
	{
		setorigin(self, self.origin + '0 0 20');
		droptofloor();
	}

	WaypointSprite_UpdateMaxHealth(self.sprite, self.max_health);
	WaypointSprite_UpdateHealth(self.sprite, self.health);
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
	if (!g_onslaught)
	{
		remove(self);
		return;
	}

	//entity e;
	precache_model("models/onslaught/generator.md3");
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

	if(self.team == NUM_TEAM_1)
        ons_red_generator = self;

	if(self.team == NUM_TEAM_2)
        ons_blue_generator = self;

	self.team_saved = self.team;
	self.colormap = 1024 + (self.team - 1) * 17;
	self.solid = SOLID_BBOX;
	self.movetype = MOVETYPE_NONE;
	self.lasthealth = self.max_health = self.health = autocvar_g_onslaught_gen_health;
	SETMODEL(self, "models/onslaught/generator.md3");
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
	// spawn shield model which indicates whether this can be damaged
	self.enemy = spawn();
	setattachment(self.enemy , self, "");
	self.enemy.classname = "onslaught_generator_shield";
	self.enemy.solid = SOLID_NOT;
	self.enemy.movetype = MOVETYPE_NONE;
	self.enemy.effects = EF_ADDITIVE;
	SETMODEL(self.enemy, "models/onslaught/generator_shield.md3");
	//setorigin(e, self.origin);
	self.enemy.colormap = self.colormap;
	self.enemy.team = self.team;
	//self.think = onslaught_generator_delayed;
	//self.nextthink = time + 0.2;
	InitializeEntity(self, onslaught_generator_delayed, INITPRIO_LAST);

	WaypointSprite_SpawnFixed(string_null, self.origin + '0 0 128', self, sprite, RADARICON_NONE, '0 0 0');
	WaypointSprite_UpdateRule(self.sprite, NUM_TEAM_2, SPRITERULE_TEAMPLAY);
	WaypointSprite_UpdateMaxHealth(self.sprite, self.max_health);
	WaypointSprite_UpdateHealth(self.sprite, self.health);

	waypoint_spawnforitem(self);

	onslaught_updatelinks();

	self.reset = onslaught_generator_reset;
}

.float waslinked;
.float cp_bob_spd;
.vector cp_origin, cp_bob_origin, cp_bob_dmg;

float ons_notification_time_team1;
float ons_notification_time_team2;

void onslaught_controlpoint_icon_damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	entity oself;
	float nag;

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

	if (IS_PLAYER(attacker))
	{
		nag = FALSE;
		if(self.team == NUM_TEAM_1)
		{
			if(time - ons_notification_time_team1 > 10)
			{
				nag = TRUE;
				ons_notification_time_team1 = time;
			}
		}
		else if(self.team == NUM_TEAM_2)
		{
			if(time - ons_notification_time_team2 > 10)
			{
				nag = TRUE;
				ons_notification_time_team2 = time;
			}
		}
		else
			nag = TRUE;

		if(nag)
			play2team(self.team, "onslaught/controlpoint_underattack.wav");
	}

	self.health = self.health - damage;
	if(self.owner.iscaptured)
		WaypointSprite_UpdateHealth(self.owner.sprite, self.health);
	else
		WaypointSprite_UpdateBuildFinished(self.owner.sprite, time + (self.max_health - self.health) / (self.count / sys_frametime));
	self.pain_finished = time + 1;
	self.punchangle = (2 * randomvec() - '1 1 1') * 45;
	self.cp_bob_dmg_z = (2 * random() - 1) * 15;
	// colormod flash when shot
	self.colormod = '2 2 2';
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
			string t;
			t = Team_ColoredFullName(attacker.team);
			bprint(Team_ColoredFullName(self.team), " ", self.message, " control point destroyed by ", t, "\n");
			ons_throwgib(self.origin, (2 * randomvec() - '1 1 1') * 25, "models/onslaught/controlpoint_icon_gib1.md3", 3, FALSE);
			ons_throwgib(self.origin, (2 * randomvec() - '1 1 1') * 45, "models/onslaught/controlpoint_icon_gib2.md3", 3, FALSE);
			ons_throwgib(self.origin, (2 * randomvec() - '1 1 1') * 45, "models/onslaught/controlpoint_icon_gib2.md3", 3, FALSE);
			ons_throwgib(self.origin, (2 * randomvec() - '1 1 1') * 75, "models/onslaught/controlpoint_icon_gib4.md3", 3, FALSE);
			ons_throwgib(self.origin, (2 * randomvec() - '1 1 1') * 75, "models/onslaught/controlpoint_icon_gib4.md3", 3, FALSE);
			ons_throwgib(self.origin, (2 * randomvec() - '1 1 1') * 75, "models/onslaught/controlpoint_icon_gib4.md3", 3, FALSE);
			ons_throwgib(self.origin, (2 * randomvec() - '1 1 1') * 75, "models/onslaught/controlpoint_icon_gib4.md3", 3, FALSE);
		}
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
			SETMODEL(self.owner, "models/onslaught/controlpoint_pad.md3");
		//setsize(self, '-32 -32 0', '32 32 8');

		remove(self);
	}
}

void onslaught_controlpoint_icon_think()
{
	entity oself;
	self.nextthink = time + sys_frametime;

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
                    if(_player.team == self.team)
                        ++_friendly_count;
                    else
                        ++_enemy_count;
                }
            }
        }

        _friendly_count = _friendly_count * (autocvar_g_onslaught_cp_proxydecap_dps * sys_frametime);
        _enemy_count = _enemy_count * (autocvar_g_onslaught_cp_proxydecap_dps * sys_frametime);

        self.health = bound(0, self.health + (_friendly_count - _enemy_count), self.max_health);
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
	if (self.health < self.max_health * 0.25)
		SETMODEL(self, "models/onslaught/controlpoint_icon_dmg3.md3");
	else if (self.health < self.max_health * 0.50)
		SETMODEL(self, "models/onslaught/controlpoint_icon_dmg2.md3");
	else if (self.health < self.max_health * 0.75)
		SETMODEL(self, "models/onslaught/controlpoint_icon_dmg1.md3");
	else if (self.health < self.max_health * 0.90)
		SETMODEL(self, "models/onslaught/controlpoint_icon.md3");
	// colormod flash when shot
	self.colormod = '1 1 1' * (2 - bound(0, (self.pain_finished - time) / 10, 1));

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

	if (self.punchangle_x > 0)
	{
		self.punchangle_x = self.punchangle_x - 60 * sys_frametime;
		if (self.punchangle_x < 0)
			self.punchangle_x = 0;
	}
	else if (self.punchangle_x < 0)
	{
		self.punchangle_x = self.punchangle_x + 60 * sys_frametime;
		if (self.punchangle_x > 0)
			self.punchangle_x = 0;
	}

	if (self.punchangle_y > 0)
	{
		self.punchangle_y = self.punchangle_y - 60 * sys_frametime;
		if (self.punchangle_y < 0)
			self.punchangle_y = 0;
	}
	else if (self.punchangle_y < 0)
	{
		self.punchangle_y = self.punchangle_y + 60 * sys_frametime;
		if (self.punchangle_y > 0)
			self.punchangle_y = 0;
	}

	if (self.punchangle_z > 0)
	{
		self.punchangle_z = self.punchangle_z - 60 * sys_frametime;
		if (self.punchangle_z < 0)
			self.punchangle_z = 0;
	}
	else if (self.punchangle_z < 0)
	{
		self.punchangle_z = self.punchangle_z + 60 * sys_frametime;
		if (self.punchangle_z > 0)
			self.punchangle_z = 0;
	}

	self.angles_x = self.punchangle_x;
	self.angles_y = self.punchangle_y + self.mangle_y;
	self.angles_z = self.punchangle_z;
	self.mangle_y = self.mangle_y + 45 * sys_frametime;

	self.cp_bob_origin_z = 4 * PI * (1 - cos(self.cp_bob_spd));
	self.cp_bob_spd = self.cp_bob_spd + 1.875 * sys_frametime;
	if(self.cp_bob_dmg_z > 0)
		self.cp_bob_dmg_z = self.cp_bob_dmg_z - 3 * sys_frametime;
	else
		self.cp_bob_dmg_z = 0;
	setorigin(self,self.cp_origin + self.cp_bob_origin + self.cp_bob_dmg);

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

	self.nextthink = time + sys_frametime;

	// only do this if there is power
	a = onslaught_controlpoint_can_be_linked(self.owner, self.owner.team);
	if(!a)
		return;

	self.health = self.health + self.count;

	if (self.health >= self.max_health)
	{
		self.health = self.max_health;
		self.count = autocvar_g_onslaught_cp_regen * sys_frametime; // slow repair rate from now on
		self.think = onslaught_controlpoint_icon_think;
		sound(self, CH_TRIGGER, "onslaught/controlpoint_built.wav", VOL_BASE, ATTEN_NORM);
		bprint(Team_ColoredFullName(self.team), " captured ", self.owner.message, " control point\n");
		self.owner.iscaptured = TRUE;

		WaypointSprite_UpdateMaxHealth(self.owner.sprite, self.max_health);
		WaypointSprite_UpdateHealth(self.owner.sprite, self.health);

		onslaught_updatelinks();

		// Use targets now (somebody make sure this is in the right place..)
		oself = self;
		self = self.owner;
		activator = self;
		SUB_UseTargets ();
		self = oself;
		self.cp_origin = self.origin;
		self.cp_bob_origin = '0 0 0.1';
		self.cp_bob_spd = 0;
	}
	self.alpha = self.health / self.max_health;
	// colormod flash when shot
	self.colormod = '1 1 1' * (2 - bound(0, (self.pain_finished - time) / 10, 1));
	if(self.owner.model != "models/onslaught/controlpoint_pad2.md3")
		SETMODEL(self.owner, "models/onslaught/controlpoint_pad2.md3");
	//setsize(self, '-32 -32 0', '32 32 8');

	if(random() < 0.9 - self.health / self.max_health)
		pointparticles(particleeffectnum("rage"), self.origin + 10 * randomvec(), '0 0 -1', 1);
}




void onslaught_controlpoint_touch()
{
	entity e;
	float a;
	if (!IS_PLAYER(other))
		return;
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
	e.solid = SOLID_BBOX;
	e.movetype = MOVETYPE_NONE;
	SETMODEL(e, "models/onslaught/controlpoint_icon.md3");
	setsize(e, '-32 -32 -32', '32 32 32');
	setorigin(e, self.origin + '0 0 96');
	e.takedamage = DAMAGE_AIM;
	e.bot_attack = TRUE;
	e.event_damage = onslaught_controlpoint_icon_damage;
	e.team = other.team;
	e.colormap = 1024 + (e.team - 1) * 17;
	e.think = onslaught_controlpoint_icon_buildthink;
	e.nextthink = time + sys_frametime;
	e.count = (e.max_health - e.health) * sys_frametime / autocvar_g_onslaught_cp_buildtime; // how long it takes to build
	sound(e, CH_TRIGGER, "onslaught/controlpoint_build.wav", VOL_BASE, ATTEN_NORM);
	self.team = e.team;
	self.colormap = e.colormap;
	WaypointSprite_UpdateBuildFinished(self.sprite, time + (e.max_health - e.health) / (e.count / sys_frametime));
	onslaught_updatelinks();
}

void onslaught_controlpoint_think()
{
	self.nextthink = time;
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
	self.enemy.solid = SOLID_NOT;
	self.enemy.colormap = self.colormap;
	self.think = onslaught_controlpoint_think;
	self.enemy.think = func_null;
	self.nextthink = time; // don't like func_null :P
	SETMODEL(self, "models/onslaught/controlpoint_pad.md3");
	//setsize(self, '-32 -32 0', '32 32 8');

	WaypointSprite_UpdateMaxHealth(self.sprite, 0);

	onslaught_updatelinks();

	activator = self;
	SUB_UseTargets(); // to reset the structures, playerspawns etc.

	CSQCMODEL_AUTOUPDATE();
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
	//entity e;
	if (!g_onslaught)
	{
		remove(self);
		return;
	}
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
	SETMODEL(self, "models/onslaught/controlpoint_pad.md3");
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

	// spawn shield model which indicates whether this can be damaged
	self.enemy = spawn();
	self.enemy.classname = "onslaught_controlpoint_shield";
	self.enemy.solid = SOLID_NOT;
	self.enemy.movetype = MOVETYPE_NONE;
	self.enemy.effects = EF_ADDITIVE;
	SETMODEL(self.enemy , "models/onslaught/controlpoint_shield.md3");

	setattachment(self.enemy , self, "");
	//setsize(e, '-32 -32 0', '32 32 128');

	//setorigin(e, self.origin);
	self.enemy.colormap = self.colormap;

	waypoint_spawnforitem(self);

	self.think = onslaught_controlpoint_think;
	self.nextthink = time;

	WaypointSprite_SpawnFixed(string_null, self.origin + '0 0 128', self, sprite, RADARICON_NONE, '0 0 0');
	WaypointSprite_UpdateRule(self.sprite, NUM_TEAM_2, SPRITERULE_TEAMPLAY);

	onslaught_updatelinks();

	self.reset = onslaught_controlpoint_reset;

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
	float redpower, bluepower;

	redpower = bluepower = 0;
	if(self.goalentity.islinked)
	{
		if(self.goalentity.team == NUM_TEAM_1)
			redpower = 1;
		else if(self.goalentity.team == NUM_TEAM_2)
			bluepower = 1;
	}
	if(self.enemy.islinked)
	{
		if(self.enemy.team == NUM_TEAM_1)
			redpower = 2;
		else if(self.enemy.team == NUM_TEAM_2)
			bluepower = 2;
	}

	float cc;
	if(redpower == 1 && bluepower == 2)
		cc = (NUM_TEAM_1 - 1) * 0x01 + (NUM_TEAM_2 - 1) * 0x10;
	else if(redpower == 2 && bluepower == 1)
		cc = (NUM_TEAM_1 - 1) * 0x10 + (NUM_TEAM_2 - 1) * 0x01;
	else if(redpower)
		cc = (NUM_TEAM_1 - 1) * 0x11;
	else if(bluepower)
		cc = (NUM_TEAM_2 - 1) * 0x11;
	else
		cc = 0;

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
	if (!g_onslaught)
	{
		remove(self);
		return;
	}
	if (self.target == "" || self.target2 == "")
		objerror("target and target2 must be set\n");
	InitializeEntity(self, onslaught_link_delayed, INITPRIO_FINDTARGET);
	Net_LinkEntity(self, FALSE, 0, onslaught_link_send);
}

MUTATOR_HOOKFUNCTION(ons_BuildMutatorsString)
{
	ret_string = strcat(ret_string, ":ONS");
	return 0;
}

MUTATOR_HOOKFUNCTION(ons_BuildMutatorsPrettyString)
{
	ret_string = strcat(ret_string, ", Onslaught");
	return 0;
}

MUTATOR_HOOKFUNCTION(ons_Spawn_Score)
{

    /*
    float _neer_home = (random() > 0.5 ? TRUE : FALSE);

	RandomSelection_Init();

	if(self.team == NUM_TEAM_1)
        RandomSelection_Add(ons_red_generator, 0, string_null, 1, 1);

	if(self.team == NUM_TEAM_2)
        RandomSelection_Add(ons_blue_generator, 0, string_null, 1, 1);

	entity _cp = findchain(classname, "onslaught_controlpoint"):
	while _cp;
	{
	    if(_cp.team == self.team)
            RandomSelection_Add(_cp, 0, string_null, 1, 1);

		_cp = _cp.chain;
	}

	if(RandomSelection_chosen_ent)
	{
		self.tur_head = RandomSelection_chosen_ent;
		spawn_score_x += SPAWN_PRIO_NEAR_TEAMMATE_FOUND;
	}
	else if(self.team == spawn_spot.team)
		spawn_score_x += SPAWN_PRIO_NEAR_TEAMMATE_SAMETEAM; // prefer same team, if we can't find a spawn near teammate

    */

	return 0;
}

MUTATOR_HOOKFUNCTION(ons_PlayerSpawn)
{
    if(!autocvar_g_onslaught_spawn_at_controlpoints)
        return 0;

    if(random() < 0.5)  // 50/50 chane to use default spawnsystem.
        return 0;

    float _close_to_home = ((random() > 0.5) ? TRUE : FALSE);
    entity _best = world, _trg_gen = world;
    float _score, _best_score = MAX_SHOT_DISTANCE;

	RandomSelection_Init();

	if(self.team == NUM_TEAM_1)
	{
	    if(!_close_to_home)
            _trg_gen = ons_blue_generator;
        else
            _trg_gen  = ons_red_generator;
	}

	if(self.team == NUM_TEAM_2)
	{
	    if(_close_to_home)
            _trg_gen = ons_blue_generator;
        else
            _trg_gen  = ons_red_generator;
	}

	entity _cp = findchain(classname, "onslaught_controlpoint");
	while(_cp)
	{
	    if(_cp.team == self.team)
        {
            _score = vlen(_trg_gen.origin - _cp.origin);
            if(_score < _best_score)
            {
                _best = _cp;
                _best_score = _score;
            }
        }
		_cp = _cp.chain;
	}

    vector _loc;
    float i;
    if(_best)
    {
        for(i = 0; i < 10; ++i)
        {
            _loc = _best.origin + '0 0 96';
            _loc += ('0 1 0' * random()) * 128;
            tracebox(_loc, PL_MIN, PL_MAX, _loc, MOVE_NORMAL, self);
            if(trace_fraction == 1.0 && !trace_startsolid)
            {
                setorigin(self, _loc);
                self.angles = normalize(_loc - _best.origin) * RAD2DEG;
                return 0;
            }
        }
    }
    else
    {
        if(!autocvar_g_onslaught_spawn_at_generator)
            return 0;

        _trg_gen = ((self.team == NUM_TEAM_1) ? ons_red_generator : ons_blue_generator);

        for(i = 0; i < 10; ++i)
        {
            _loc = _trg_gen.origin + '0 0 96';
            _loc += ('0 1 0' * random()) * 128;
            tracebox(_loc, PL_MIN, PL_MAX, _loc, MOVE_NORMAL, self);
            if(trace_fraction == 1.0 && !trace_startsolid)
            {
                setorigin(self, _loc);
                self.angles = normalize(_loc - _trg_gen.origin) * RAD2DEG;
                return 0;
            }
        }
    }

    return 0;
}

MUTATOR_HOOKFUNCTION(ons_MonsterThink)
{
	entity e = find(world, targetname, self.target);
	if (e != world)
		self.team = e.team;

	return FALSE;
}

MUTATOR_HOOKFUNCTION(ons_MonsterSpawn)
{
	entity e, ee = world;
	
	if(self.targetname)
	{
		e = find(world,target,self.targetname);
		if(e != world)
		{
			self.team = e.team;
			ee = e;
		}
	}
	
	if(ee)
	{
        activator = ee;
        self.use();
    }

	return FALSE;
}

MUTATOR_HOOKFUNCTION(ons_TurretSpawn)
{
	entity e, ee = world;
	if(self.targetname)
	{
		e = find(world, target, self.targetname);
		if(e != world)
		{
			self.team = e.team;
			ee = e;
		}
	}

	if(ee)
	{
		activator = ee;
		self.use();
	}

	return FALSE;
}

MUTATOR_DEFINITION(gamemode_onslaught)
{
	MUTATOR_HOOK(BuildMutatorsPrettyString, ons_BuildMutatorsPrettyString, CBC_ORDER_ANY);
	MUTATOR_HOOK(BuildMutatorsString, ons_BuildMutatorsString, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerSpawn, ons_PlayerSpawn, CBC_ORDER_ANY);
	MUTATOR_HOOK(MonsterMove, ons_MonsterThink, CBC_ORDER_ANY);
	MUTATOR_HOOK(MonsterSpawn, ons_MonsterSpawn, CBC_ORDER_ANY);
	MUTATOR_HOOK(TurretSpawn, ons_TurretSpawn, CBC_ORDER_ANY);
	//MUTATOR_HOOK(Spawn_Score, ons_Spawn_Score, CBC_ORDER_ANY);

	MUTATOR_ONADD
	{
		if(time > 1) // game loads at time 1
			error("This is a game type and it cannot be added at runtime.");
	}

	MUTATOR_ONREMOVE
	{
		print("This is a game type and it cannot be removed at runtime.");
		return -1;
	}

	return 0;
}
