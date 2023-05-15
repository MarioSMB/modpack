void(float lev) summon_go =
{
	local entity e, m, oself;
	
	e = find_spot();
	//monster_scarite();
	if (lev < 3)
		call(monster_scarite, e);
	else if (lev < 5)
		call(monster_guanite,e);
	else if (lev < 7)
		call(monster_drak, e);
	else
		call(monster_horror, e);
		
	if (!self.team)
	{
		e.goalentity = world;
		e.enemy = world;
		e.classname = "helper";
		e.ai = AI_FOLLOW | AI_HUNT_MONSTERS;
		e.speed = 0.8;
		e.team = self.team;
		e.sbarsub = self; // bleh
		e.summon_count = self.summon_count;
		e.bribe_count = -1;
		self.summon_count = self.summon_count + 1;
		if (self.summon_count > lev)
		{
			m = find(world, classname, "helper");
			while(m)
			{
				if (m.sbarsub == self)
				{
					if (m.bribe_count == -1)
					{
						if (m.summon_count <= 0)
						{
							oself = self;
							self = m;
							PlayerDie(TRUE);
							self = oself;
							self.summon_count = self.summon_count - 1;
							//break;	
						}
						else
							m.summon_count = m.summon_count - 1;
					}
				}
				m = find(m, classname, "helper");
			}
		}				
			
	}
	e.droprandom = 0;
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_TELEPORT);
	WriteCoord (MSG_BROADCAST, e.origin_x);
	WriteCoord (MSG_BROADCAST, e.origin_y);
	WriteCoord (MSG_BROADCAST, e.origin_z);
	sound(e, CHAN_WEAPON, "spells/warp.wav", 1, ATTN_NORM);
};