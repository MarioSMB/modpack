void(float lev) bribe_go =
{
	local entity e, m;
	
	if (self.owner.gp < (50 / lev))
	{
		sprint(self.owner, "not enough gold\n");
		return;
	}
	if (self.enemy.spawnflags & 1)
	{
		sprint(self.owner, "invalid target\n");
		return;
	
	}
	if (self.enemy.ai == 0)
	{
		sprint(self.owner, "invalid target\n");
		return;
	
	}
	/*
	if (self.enemy.frags > self.owner.frags)
	{
		sprint(self.owner, "invalid target\n");
		return;
	
	}
	*/
	
	if (!self.team)
	{
		e = self.enemy;

		e.goalentity = world;
		e.enemy = world;
		e.classname = "helper";
		e.quest_time = e.ai;
		e.ai = AI_FOLLOW | AI_HUNT_MONSTERS;
		e.questlog = e.team;
		e.bribe_time = time + (10 * lev);
		e.team = self.team;
		e.sbarsub = self; // bleh
		e.bribe_count = self.bribe_count;
		self.bribe_count = self.bribe_count + 1;
		e.summon_count = -1;
		e.m_targ = self;
		e.effects = e.effects | EF_BLUE;
		
		if (self.bribe_count > lev)
		{
			m = find(world, classname, "helper");
			while(m)
			{
				if (m.m_targ == self)
				{
					if (m.summon_count == -1)
					{
						if (m.bribe_count == 0)
						{
							m.goalentity = world;
							m.enemy = world;
							m.classname = "monster";
							m.ai = m.quest_time;
							m.effects = m.effects - (m.effects & EF_BLUE);
							m.team = m.questlog;
							self.bribe_count = self.bribe_count - 1;
							if (self.bribe_count <= lev)
								break;
						}
						else
							m.summon_count = m.summon_count - 1;
					}
				}
				m = find(m, classname, "helper");
			}
		}				
			
	}
};