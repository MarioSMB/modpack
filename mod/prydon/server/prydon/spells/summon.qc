#include "summon.qh"

#include "../subs/subs.qh"

void summon_go(entity this, float lev)
{
	entity e = find_spot(this);
	e.spawnfunc_checked = true;
	//monster_scarite();
	if(lev < 3)
		spawnfunc_monster_scarite(e);
	else if(lev < 5)
		spawnfunc_monster_guanite(e);
	else if(lev < 7)
		spawnfunc_monster_drak(e);
	else
		spawnfunc_monster_horror(e);
		
	if(!this.team)
	{
		e.goalentity = NULL;
		e.enemy = NULL;
		e.classname = "helper";
		e.ai = AI_FOLLOW | AI_HUNT_MONSTERS;
		e.speed = 0.8;
		e.team = this.team;
		e.sbarsub = this; // bleh
		e.summon_count = this.summon_count;
		e.bribe_count = -1;
		this.summon_count += 1;
		if(this.summon_count > lev)
		{
			entity m = find(NULL, classname, "helper");
			while(m)
			{
				if(m.sbarsub == this)
				{
					if(m.bribe_count == -1)
					{
						if(m.summon_count <= 0)
						{
							PlayerDie(m, true);
							this.summon_count -= 1;
							//break;	
						}
						else
							m.summon_count -= 1;
					}
				}
				m = find(m, classname, "helper");
			}
		}				
			
	}
	e.droprandom = 0;
	te_teleport(e.origin);
	_sound(e, CH_WEAPON_SINGLE, "spells/warp.wav", 1, ATTN_NORM);
}
