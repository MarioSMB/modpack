.vector average_origin;


void(entity e, float atc) doaction =
{
	self.gotstuff = atc;
	self.goalentity = e;
};
void () ghost_fade =
{
	self.alpha = self.alpha - 0.1;
	if (self.alpha <= 0.4)
		remove(self);
	else
		self.nextthink = time + 0.1;
};

float () movement_check =
{
	self.average_origin = self.origin * 0.1 + self.average_origin * 0.9;
	if (vlen (self.origin - self.average_origin) < (100 * frametime))
	{
		self.average_origin = '0 0 0';
		return TRUE;
	}
		
	return FALSE;
	
};

float(float yaw, float run) moveit =
{
	local float runspeed;
	local float m;
	local entity ghost;


	if (self.misc & MISC_MAIMED)
		run = 0;
		
	if (self.gotstuff == SP_SPRINT)
	{
		runspeed = 450 * frametime;
		self.misc = self.misc | MISC_SPRINT_DONE; // flag
		run = 1;
	}
	else if (run)
		runspeed = (250 + sqrt(self.owner.agil) * 3) * frametime;
	else
		runspeed = 150 * frametime;
	runspeed = runspeed * self.speed * self.cold_factor;

	if (self.pausetime < time)
	{
		if (self.gotstuff == SP_SPRINT)
		{
			ghost = spawn();
			setmodel(ghost, self.model);
			setorigin(ghost, self.origin);
			ghost.frame = self.frame;
			ghost.think = ghost_fade;
			ghost.angles = self.angles;
			ghost.skin = self.skin;
			ghost.nextthink = time + 0.1;
			ghost.alpha = 0.9;
			ghost.colormap = self.colormap;

		}
		if (run)
			CycleFrames(self.walkframes+1, self.runframes);		
		else
			CycleFrames(1, self.walkframes);

		if (self.noise1)
		{
			if (self.frame == 1)
				sound(self, CHAN_BODY, self.noise1, 1, ATTN_NORM);
			if (self.frame == 8)
				sound(self, CHAN_BODY, self.noise1, 1, ATTN_NORM);
			if (self.frame == 4)
				sound(self, CHAN_BODY, self.noise2, 1, ATTN_NORM);
			if (self.frame == 11)
				sound(self, CHAN_BODY, self.noise2, 1, ATTN_NORM);
		}
		self.pausetime = time + 0.1 * (1/self.cold_factor);

	}
	if (self.daze_time < time)
	{
		if (self.ai && self.goalentity != world)
		{
			self.yaw_speed = 20 * self.cold_factor * self.speed;	
			self.testorg = self.origin;
			movetogoal(runspeed);
			if (movement_check())
				return FALSE;
			if (self.origin == self.testorg)
				return FALSE;
			else
				return TRUE;
		}
	}
	makevectors(self.angles);

	if (walkmove(yaw, runspeed))
	{
		self.angles_y = yaw;
		self.obs_angle = 0;
		if (movement_check())
			return FALSE;
		return TRUE;
	}
	else if (self.obs_angle)
	{
		if (walkmove(self.obs_angle, runspeed))
		{
			self.angles_y = self.obs_angle;
			if (movement_check())
				return FALSE;
			return TRUE;
		}
	}
	m = 0;
	while(m < 360)
	{
		if (!walkmove(yaw + m, runspeed))
		{
			if (!walkmove(yaw - m, runspeed))
			{
				m = m + 1;
			}
			else
			{
				m = 360 - m;
				break;
			}
		}
		else
			break;
	}
	self.obs_angle = yaw + m;
	self.angles_y = yaw + m;
	if (movement_check())
		return FALSE;
	return TRUE;
};

void() end_hunt =
{
	self.menu = 0;
	if (self.gotstuff == SP_FOLLOW)
		self.gotstuff = self.altaction;
	if (self.goalentity.classname == "goalpoint")
	{
		// don't think this works
		Trigger(self.goalentity, self, self, 0);
		return;
	}
	self.goalentity = world;
	//self.frame = 0;
};

void() handle_ai =
{
	local entity e, beste;
	local float len, dist, bestdist;
	if (self.bribe_time && self.bribe_time < time)
	{
		self.goalentity = world;
		self.enemy = world;
		self.classname = "monster";
		self.ai = self.quest_time;
		self.bribe_time = 0;
		self.team = self.questlog;
		self.m_targ.bribe_count = self.m_targ.bribe_count - 1;
		self.solid = SOLID_BBOX;
		self.effects = self.effects - (self.effects & EF_BLUE);
	}
	
	if (self.ai & AI_ROAM)
	{
		if (self.attack_finished > time)
		{
			if (self.menu < time)
			{
				// look around
				self.angles_y = random() * 360;
				self.menu = time + 2 * random();
			}
			self.frame = 0;
		}
		else if(!moveit(self.angles_y, 0))
		{
			self.attack_finished = time + random() * 3;
			self.menu = 0;
		}
		else if (self.menu < time)
		{
			self.menu = 0;
			self.attack_finished = time + random() * 5;
		}
	}
	if (self.ai & AI_HUNT_PLAYER)
	{
		if (!self.enemy)
		{
			bestdist = 9999;
			e = find(world, classname, "dummy");
			while(e)
			{

				if (e.owner.health >= 1)
				{
					len = vlen(e.origin - self.origin);
					if (e.owner.visibility < 0)
					{
						if (len > 64)
						{
							if (e.owner.visibility < -35)
								if (!infront(e))
									len = 99999;
							if (len > self.finddist *  ((0 - e.owner.visibility) / 100))
								len = 99999;
						}
					}
					if (len < self.finddist)
					{
						if (len < bestdist)
						{
							bestdist = len;
							self.enemy = e;
						}
					}
				}
				e = find(e, classname, "dummy");
			}

			self.goalentity = self.enemy;
		}
		else if (self.enemy.owner.health < 1)
			self.enemy = world;
		else if (friendly(self, self.enemy))
		{
			self.frame = 0;
			self.enemy = world;
		}
		else
			self.goalentity = self.enemy; // go at 'im again
		if (self.enemy)
		{
			if (self.spell)
			{
				if (self.gotstuff == self.spell)
					len = self.altaction;
				else
					len = self.spell;
				if (self.owner.mana < mana_for_spell(self.gotstuff, GetSpellLevel(self.owner, self.gotstuff)))
					self.gotstuff = len;
				else if (cast_aground(self.gotstuff))
					self.gotstuff = len;
				else if (random() < 0.2)
					self.gotstuff = len;
			}
	
			if (self.theme)
				setdmusic(self.theme);
			e = findradius(self.origin, 90);
			while(e)
			{
				if ((e.ai & AI_HUNT_PLAYER) && (e.enemy == world))
					e.enemy = e.goalentity = self.enemy;
				e = e.chain;
			}
		}
	}
	if (self.ai & AI_HUNT_MONSTERS)
	{
		if (!self.enemy)
		{
			bestdist = 99999;
			e = find(world, classname, "monster");
			while(e)
			{
				if (e.health >= 1)
				{
					if (!friendly(e, self))
					{
						len = vlen(e.origin - self.origin);
					if (e.owner.visibility < 0)
					{
						if (len > 64)
						{
							if (e.owner.visibility < -35)
								if (!infront(e))
									len = 99999;
							if (len > self.finddist *  ((0 - e.owner.visibility) / 100))
								len = 99999;
						}
					}
						if (len < self.finddist)
						{
							if (len < bestdist)
							{
								bestdist = len;
								self.enemy = e;
							}
						}
					}
				}
				e = find(e, classname, "monster");
			}
			self.goalentity = self.enemy;
			if (self.enemy)
			{
				if (self.theme)
					setdmusic(self.theme);
			}
		}
		else
		{
			if (friendly(self, self.enemy))
			{
				self.frame = 0;
				self.enemy = world;
			}
			else if (self.enemy.health < 1)
			{
				self.frame = 0;
				self.enemy = world;
			}
			else
			{
				self.goalentity = self.enemy;
			}
		}
		if (self.enemy)
		if (self.spell)
		{
			if (self.gotstuff == self.spell)
				len = self.altaction;
			else
				len = self.spell;
			if (self.owner.mana < mana_for_spell(self.gotstuff, GetSpellLevel(self.owner, self.gotstuff)))
				self.gotstuff = len;
			else if (cast_aground(self.gotstuff))
				self.gotstuff = len;
			else if (random() < 0.2)
				self.gotstuff = len;
		}
	}
	if (self.ai & AI_HUNT)
	{
		if (!self.enemy)
		{
			bestdist = self.finddist;
			e = findradius(self.origin, bestdist);
			while(e)
			{
				if (e.health >= 1 && e.takedamage)
				{
					if (!friendly(e, self))
					{
						len = vlen(e.origin - self.origin);
					if (e.owner.visibility < 0)
					{
						if (len > 64)
						{
							if (e.owner.visibility < -35)
								if (!infront(e))
									len = 99999;
							if (len > self.finddist *  ((0 - e.owner.visibility) / 100))
								len = 99999;
						}
					}
						if (len < bestdist)
						{
							bestdist = len;
							self.enemy = e;
						}
					}
				}
				e = e.chain;
			}
			self.goalentity = self.enemy;
		}
		else if (self.enemy.owner.health < 1)
			self.enemy = world;
		else if (friendly(self, self.enemy))
		{
			self.frame = 0;
			self.enemy = world;
		}
		else
			self.goalentity = self.enemy; // go at 'im again
		if (self.enemy)
		{
			if (self.spell)
			{
				if (self.gotstuff == self.spell)
					len = self.altaction;
				else
					len = self.spell;
				if (self.owner.mana < mana_for_spell(self.gotstuff, GetSpellLevel(self.owner, self.gotstuff)))
					self.gotstuff = len;
				else if (cast_aground(self.gotstuff))
					self.gotstuff = len;
				else if (random() < 0.2)
					self.gotstuff = len;
			}
	
			if (self.theme)
				setdmusic(self.theme);
			e = findradius(self.origin, 90);
			while(e)
			{
				if ((e.ai & AI_HUNT_PLAYER) && (e.enemy == world))
					e.enemy = e.goalentity = self.enemy;
				e = e.chain;
			}
		}
	}
	if (self.ai & AI_FOLLOW)
	{
		if (self.classname != "helper")
		if ((!self.sbarsub) || (self.sbarsub.owner.health <= 0))
		{
			len = 9999;
			e = find(world, classname, "dummy");
			while(e)
			{
				if (e.follow_npcs < len)
				{
					self.sbarsub = e;
					len = e.follow_npcs + 1;	
				}
				e = find(e, classname, "dummy");
			}
			if (self.sbarsub)
				self.sbarsub.follow_npcs = len + 1;
					
		}
		if (self.sbarsub)
		{
			len = vlen(self.sbarsub.origin - self.origin);
			if (len < 60)
			{
				len = self.frame;
				end_hunt();
				self.frame = len; // evile hack
				moveit(vectoyaw(self.origin - self.sbarsub.origin), self.menu);
			}
			else if (len > 256)
			{
				doaction(self.sbarsub, SP_FOLLOW);
				self.menu = 1;
			}
			else if (len > 90 && !self.goalentity)
			{
				if(moveit(vectoyaw(self.sbarsub.origin - self.origin), self.menu))
					self.dbltime = 0;
				self.menu = self.sbarsub.menu;
			}
			else if (self.sbarsub.frame == 0) // LAME HACK
				self.frame = 0;
		}

	}
	if (self.ai & AI_TAKE_ITEMS)
	{
		if (!self.goalentity)
		{
			e = find(world, classname, "item");
			beste = world;
			bestdist = 99999999;
			while (e)
			{
				if (!e.menu)
				{
					dist = vlen(self.origin - e.origin);
					if (dist < bestdist)
					{
						if (visible(e))
						{
							beste = e;
							bestdist = dist;		
						}
					}
				}
				e = find(e, classname, "item");
			}
			if (beste)
				doaction(beste, SP_ACTIVATE);
		}
	}
	if (self.ai & AI_STAY_NEAR)
	{	
		bestdist = 0;
		beste = world;
		e = find(world, netname, self.wad);
		while(e)
		{
			dist = e.finddist;
			if (!dist)
				dist = 512;
			len = vlen(e.origin - self.origin);
			if (len > dist)
			{
				if ((len - dist) > bestdist)
				{
					bestdist = (len - dist);
					beste = e;
				}	
			}
			e = find(e, netname, self.wad);
		}
		if (beste)
			doaction(beste, SP_GOTO2);
	}
};