/* ALL MONSTERS SHOULD BE 1 0 0 IN COLOR */

// name =[framenum,	nexttime, nextthink] {code}
// expands to:
// name ()
// {
//		self.frame=framenum;
//		self.nextthink = time + nexttime;
//		self.think = nextthink
//		<code>
// }

.float ismonster;

.float modelindex2;

/*
================
monster_use

Using a monster makes it angry at the current activator
LordHavoc: using a monster with the spawnflag 'Appear' makes it appear
================
*/
void() monster_use =
{
	if (self.enemy)
		return;
	if (self.health < 1)
		return;
	if (self.mdl)
	if (self.spawnflags & MONSTER_APPEAR)
	{
		self.nextthink = time + 0.1;
		self.spawnflags = self.spawnflags - MONSTER_APPEAR;
		self.solid = SOLID_SLIDEBOX;
		self.takedamage = DAMAGE_AIM;
		//self.movetype = MOVETYPE_STEP;
		self.model = self.mdl;
		self.mdl = "";
		self.modelindex = self.modelindex2;
		self.modelindex2 = 0;
		//setorigin(self, self.origin + '0 0 1');
		spawn_tdeath(self.origin, self, self.origin);
		return;
	}

#if 0
	if (activator.items & IT_INVISIBILITY)
		return;
#endif
	if (activator.flags & FL_NOTARGET)
		return;
	if (activator.classname != "player")
		return;

	// delay reaction so if the monster is teleported, its sound is still heard
	self.enemy = activator;
	self.nextthink = time + 0.1;
	self.think = FoundTarget;
}

void() monster_appearsetup =
{
	if ((self.spawnflags & MONSTER_APPEAR) == 0)
		return;
	self.mdl = self.model;
	self.modelindex2 = self.modelindex;
	self.modelindex = 0;
	self.solid = SOLID_NOT;
	self.takedamage = DAMAGE_NO;
	//self.movetype = MOVETYPE_NONE;
	self.nextthink = -1;
	self.model = "";
}

/*
================
monster_setalpha

Sets relative alpha of monster in skill 4 mode.
================
*/
void(float a) monster_setalpha =
{
	if (skill < 4 || self.classname == "monster_hellfish")
	{
		self.alpha = 1.0;
		return;
	}

	if (skill >= 5)
	{
		// randomly forget enemy, this makes monsters randomly return to their normal ghostlike state
		if (a == 0)
		if (self.enemy)
		if (random() < 0.1)
			self.enemy = world;
		// randomly blink (playing the same alarming sound as if attacking)
		if (self.enemy == world)
		{
			a = 0;
			if (time >= 0.3) // don't blink during the init process because it might become permanent
			if (random() < 0.005)
			{
				// blink for an instant, this causes the appear sound, alarming the player as if under attack
				/* PLEASE FIX THE SOUND CHANNEL BEFORE ACTIVATING THIS
				sound(self, CHAN_AUTO, "wizard/wsight.wav", 1, ATTN_NORM);
				*/
				a = 1;
			}
		}
		// if ghosted, become non-solid and immune to damage
		if (a <= 0 || self.enemy == world)
		{
			self.solid = SOLID_NOT;
			self.takedamage = DAMAGE_NO;
		}
		else
		{
			// if unghosting, make sure we have an enemy, otherwise stay ghosted (even if blinking) so we can't be shot while blinking
			/* PLEASE FIX THE SOUND CHANNEL BEFORE ACTIVATING THIS
			if (self.solid != SOLID_SLIDEBOX)
				sound(self, CHAN_AUTO, "wizard/wsight.wav", 1, ATTN_NORM);
			*/
			self.solid = SOLID_SLIDEBOX;
			self.takedamage = DAMAGE_AIM;
		}
	}
	self.alpha = SKILL4_MINALPHA + (1 - SKILL4_MINALPHA) * bound(0, a, 1);
}

/*
================
monster_death_use

When a mosnter dies, it fires all of its targets with the current
enemy as activator.
================
*/
void() monster_death_use =
{
// fall to ground
	if (self.flags & FL_FLY)
		self.flags = self.flags - FL_FLY;
	if (self.flags & FL_SWIM)
		self.flags = self.flags - FL_SWIM;

	if (!self.target)
		return;

	activator = self.enemy;
	SUB_UseTargets ();
}


void() monsterinwall =
{
	entity e;
	if (!autocvar_developer)
		return;
	// this is handy for level designers,
	// puts a spikey ball where the error is...
	e = spawn();
	setorigin(e, self.origin);
	setmodel (e, "models/ebomb.mdl");
	e.movetype = MOVETYPE_NONE;
	e.solid = SOLID_NOT;
	e.think = func_null;
	e.nextthink = -1;
	e.scale = 16;
}

//============================================================================

void() walkmonster_start_go =
{
	self.origin_z = self.origin_z + 1; // raise off floor a bit

	tracebox(self.origin, self.mins, self.maxs, self.origin, TRUE, self);
	if (trace_startsolid)
	{
		dprint("walkmonster in wall at: ");
		dprint(vtos(self.origin));
		dprint("\n");
		monsterinwall();
		droptofloor();
	}
	else
	{
		droptofloor();
		if (!walkmove(0,0))
		{
			dprint("walkmonster in wall at: ");
			dprint(vtos(self.origin));
			dprint("\n");
			monsterinwall();
		}
	}

	//self.cantrigger = TRUE;

	self.takedamage = DAMAGE_AIM;

	self.ideal_yaw = self.angles * '0 1 0';
	if (!self.yaw_speed)
		self.yaw_speed = 20;
	self.view_ofs = '0 0 25';
	self.use = monster_use;

	self.flags = self.flags | FL_MONSTER;

	if (monsterwander)
		self.spawnflags = self.spawnflags | MONSTER_WANDER;

	if (self.target)
	{
		self.goalentity = self.movetarget = find(world, targetname, self.target);
		self.ideal_yaw = vectoyaw(self.goalentity.origin - self.origin);
		if (!self.movetarget)
		{
			dprint("Monster can't find target at ");
			dprint(vtos(self.origin));
			dprint("\n");
		}
		// this used to be an objerror
		if (self.movetarget.classname == "path_corner")
			self.th_walk ();
		else
		{
			if ((self.spawnflags & MONSTER_WANDER) && (!self.monsterawaitingteleport) && (self.spawnflags & 3) == 0 && (world.model != "maps/e1m7.bsp"))
			{
				monster_spawnwanderpath();
				self.ideal_yaw = vectoyaw(self.goalentity.origin - self.origin);
				self.th_walk ();
			}
			else
			{
				self.pausetime = 99999999;
				self.th_stand ();
			}
		}
	}
	else
	{
		if ((self.spawnflags & MONSTER_WANDER) && (!self.monsterawaitingteleport) && (self.spawnflags & 3) == 0 && (world.model != "maps/e1m7.bsp"))
		{
			monster_spawnwanderpath();
			self.ideal_yaw = vectoyaw(self.goalentity.origin - self.origin);
			self.th_walk ();
		}
		else
		{
			self.pausetime = 99999999;
			self.th_stand ();
		}
	}

// spread think times so they don't all happen at same time
	self.nextthink = self.nextthink + random()*0.5 + 0.1;
	self.iscreature = TRUE;
	self.teleportable = TELEPORT_NORMAL;
	self.damagedbycontents = TRUE;

	force_retouch = 2; // mainly to detect teleports

	monster_appearsetup();
}


void() walkmonster_start =
{
	self.candrown = 1; // this is turned off by some monsters like zombies
	// delay drop to floor to make sure all doors have been spawned
	// spread think times so they don't all happen at same time
	self.nextthink = time + random()*0.5 + 0.3;
	self.think = walkmonster_start_go;
	total_monsters = total_monsters + 1;
	self.bot_attack = TRUE;
	self.frags = 2; // actually just used to get havocbots to attack it...
	self.bleedfunc = genericbleedfunc;
	self.ismonster = TRUE;

	monster_setalpha (0);
}



void() flymonster_start_go =
{
	self.takedamage = DAMAGE_AIM;

	self.ideal_yaw = self.angles * '0 1 0';
	if (!self.yaw_speed)
		self.yaw_speed = 10;
	self.view_ofs = '0 0 25';
	self.use = monster_use;

	self.flags = self.flags | FL_FLY;
	self.flags = self.flags | FL_MONSTER;

	if (!walkmove(0,0))
	{
		dprint("flymonster in wall at: ");
		dprint(vtos(self.origin));
		dprint("\n");
		monsterinwall();
	}

	//self.cantrigger = TRUE;

	if (monsterwander)
		self.spawnflags = self.spawnflags | MONSTER_WANDER;

	if (self.target)
	{
		self.goalentity = self.movetarget = find(world, targetname, self.target);
		if (!self.movetarget)
		{
			dprint("Monster can't find target at ");
			dprint(vtos(self.origin));
			dprint("\n");
		}
		// this used to be an objerror
		if (self.movetarget.classname == "path_corner")
			self.th_walk ();
		else
		{
			if ((self.spawnflags & MONSTER_WANDER) && (!self.monsterawaitingteleport) && (self.spawnflags & 3) == 0 && (world.model != "maps/e1m7.bsp"))
			{
				monster_spawnwanderpath();
				self.ideal_yaw = vectoyaw(self.goalentity.origin - self.origin);
				self.th_walk ();
			}
			else
			{
				self.pausetime = 99999999;
				self.th_stand ();
			}
		}
	}
	else
	{
		if ((self.spawnflags & MONSTER_WANDER) && (!self.monsterawaitingteleport) && (self.spawnflags & 3) == 0 && (world.model != "maps/e1m7.bsp"))
		{
			monster_spawnwanderpath();
			self.ideal_yaw = vectoyaw(self.goalentity.origin - self.origin);
			self.th_walk ();
		}
		else
		{
			self.pausetime = 99999999;
			self.th_stand ();
		}
	}
	self.iscreature = TRUE;
	self.teleportable = TELEPORT_NORMAL;
	self.damagedbycontents = TRUE;

	force_retouch = 2; // mainly to detect teleports

	monster_appearsetup();
}

void() flymonster_start =
{
	self.candrown = 1;
	// spread think times so they don't all happen at same time
	self.nextthink = time + random()*0.5 + 0.1;
	self.think = flymonster_start_go;
	total_monsters = total_monsters + 1;
	self.bot_attack = TRUE;
	self.frags = 2; // actually just used to get havocbots to attack it...
	self.bleedfunc = genericbleedfunc;
	self.ismonster = TRUE;

	monster_setalpha (0);
}


void() swimmonster_start_go =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}

	//self.cantrigger = TRUE;

	self.takedamage = DAMAGE_AIM;

	self.ideal_yaw = self.angles * '0 1 0';
	if (!self.yaw_speed)
		self.yaw_speed = 10;
	self.view_ofs = '0 0 10';
	self.use = monster_use;

	self.flags = self.flags | FL_SWIM;
	self.flags = self.flags | FL_MONSTER;

	if (monsterwander)
		self.spawnflags = self.spawnflags | MONSTER_WANDER;

	if (self.target)
	{
		self.goalentity = self.movetarget = find(world, targetname, self.target);
		if (!self.movetarget)
		{
			dprint("Monster can't find target at ");
			dprint(vtos(self.origin));
			dprint("\n");
		}
		// this used to be an objerror
		if (self.movetarget.classname == "path_corner")
			self.th_walk ();
		else
		{
			if ((self.spawnflags & MONSTER_WANDER) && (!self.monsterawaitingteleport) && (self.spawnflags & 3) == 0 && (world.model != "maps/e1m7.bsp"))
			{
				monster_spawnwanderpath();
				self.ideal_yaw = vectoyaw(self.goalentity.origin - self.origin);
				self.th_walk ();
			}
			else
			{
				self.pausetime = 99999999;
				self.th_stand ();
			}
		}
	}
	else
	{
		if ((self.spawnflags & MONSTER_WANDER) && (!self.monsterawaitingteleport) && (self.spawnflags & 3) == 0 && (world.model != "maps/e1m7.bsp"))
		{
			monster_spawnwanderpath();
			self.ideal_yaw = vectoyaw(self.goalentity.origin - self.origin);
			self.th_walk ();
		}
		else
		{
			self.pausetime = 99999999;
			self.th_stand ();
		}
	}
	self.iscreature = TRUE;
	self.teleportable = TELEPORT_NORMAL;
	self.damagedbycontents = TRUE;

	force_retouch = 2; // mainly to detect teleports

	monster_appearsetup();
}

void() swimmonster_start =
{
	// spread think times so they don't all happen at same time
	self.candrown = 0;
	self.nextthink = time + random()*0.5 + 0.1;
	self.think = swimmonster_start_go;
	total_monsters = total_monsters + 1;
	self.bot_attack = TRUE;
	self.frags = 2; // actually just used to get havocbots to attack it...
	self.bleedfunc = genericbleedfunc;
	self.ismonster = TRUE;

	monster_setalpha(0);
}

void(vector org, float bodydamage, float armordamage, vector force, float damgtype) genericbleedfunc =
{
        vector v;
        v = '0 0 0' - force * 0.05;
        if (armordamage > 0)
                te_spark(org, v, armordamage * 3);
        if (bodydamage > 0)
                te_blood(org, v, bodydamage);
}
