#include "bribe.qh"

void bribe_go(entity this, float lev)
{
	if(this.owner.gp < (50 / lev))
	{
		sprint(this.owner, "not enough gold\n");
		return;
	}
	if(this.enemy.spawnflags & 1)
	{
		sprint(this.owner, "invalid target\n");
		return;
	
	}
	if(this.enemy.ai == 0)
	{
		sprint(this.owner, "invalid target\n");
		return;
	
	}
	/*
	if(this.enemy.frags > this.owner.frags)
	{
		sprint(this.owner, "invalid target\n");
		return;
	
	}
	*/
	
	if(!this.team)
	{
		entity e = this.enemy;

		e.goalentity = NULL;
		e.enemy = NULL;
		e.classname = "helper";
		e.quest_time = e.ai;
		e.ai = AI_FOLLOW | AI_HUNT_MONSTERS;
		e.questlog = e.team;
		e.bribe_time = time + (10 * lev);
		e.team = this.team;
		e.sbarsub = this; // bleh
		e.bribe_count = this.bribe_count;
		this.bribe_count = this.bribe_count + 1;
		e.summon_count = -1;
		e.m_targ = this;
		e.effects = e.effects | EF_BLUE;
		
		if(this.bribe_count > lev)
		{
			entity m = find(NULL, classname, "helper");
			while(m)
			{
				if(m.m_targ == this)
				{
					if(m.summon_count == -1)
					{
						if(m.bribe_count == 0)
						{
							m.goalentity = NULL;
							m.enemy = NULL;
							m.classname = "monster";
							m.ai = m.quest_time;
							m.effects = m.effects - (m.effects & EF_BLUE);
							m.team = m.questlog;
							this.bribe_count = this.bribe_count - 1;
							if(this.bribe_count <= lev)
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
}
