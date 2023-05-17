#include "ai.qh"

#include "../spells/_mod.qh"
#include "../subs/subs.qh"
#include "../subs/trigger.qh"

void doaction(entity this, entity e, float atc)
{
	this.gotstuff = atc;
	this.goalentity = e;
}
void ghost_fade(entity this)
{
	this.alpha = this.alpha - 0.1;
	if(this.alpha <= 0.4)
		delete(this);
	else
		this.nextthink = time + 0.1;
}

bool movement_check(entity this)
{
	this.average_origin = this.origin * 0.1 + this.average_origin * 0.9;
	if(vdist(this.origin - this.average_origin, <, (100 * frametime)))
	{
		this.average_origin = '0 0 0';
		return true;
	}
		
	return false;
}

bool moveit(entity this, float yaw, float run)
{
	float runspeed;

	if(this.misc & MISC_MAIMED)
		run = 0;
		
	if(this.gotstuff == SP_SPRINT)
	{
		runspeed = 450 * frametime;
		this.misc = this.misc | MISC_SPRINT_DONE; // flag
		run = 1;
	}
	else if(run)
		runspeed = (250 + sqrt(this.owner.agil) * 3) * frametime;
	else
		runspeed = 150 * frametime;
	runspeed = runspeed * this.speed * this.cold_factor;

	if(this.pausetime < time)
	{
		if(this.gotstuff == SP_SPRINT)
		{
			entity ghost = new(ghost);
			_setmodel(ghost, this.model);
			setorigin(ghost, this.origin);
			ghost.frame = this.frame;
			setthink(ghost, ghost_fade);
			ghost.angles = this.angles;
			ghost.skin = this.skin;
			ghost.nextthink = time + 0.1;
			ghost.alpha = 0.9;
			ghost.colormap = this.colormap;

		}
		if(run)
			CycleFrames(this, this.walkframes+1, this.runframes);		
		else
			CycleFrames(this, 1, this.walkframes);

		if(this.noise1)
		{
			if(this.frame == 1)
				_sound(this, CHAN_BODY, this.noise1, 1, ATTN_NORM);
			if(this.frame == 8)
				_sound(this, CHAN_BODY, this.noise1, 1, ATTN_NORM);
			if(this.frame == 4)
				_sound(this, CHAN_BODY, this.noise2, 1, ATTN_NORM);
			if(this.frame == 11)
				_sound(this, CHAN_BODY, this.noise2, 1, ATTN_NORM);
		}
		this.pausetime = time + 0.1 * (1/this.cold_factor);

	}
	if(this.daze_time < time)
	{
		if(this.ai && this.goalentity)
		{
			this.yaw_speed = 20 * this.cold_factor * this.speed;	
			this.testorg = this.origin;
			t_movetogoal(this, runspeed);
			if(movement_check(this))
				return false;
			if(this.origin == this.testorg)
				return false;
			else
				return true;
		}
	}
	makevectors(this.angles);

	if(t_walkmove(this, yaw, runspeed))
	{
		this.angles_y = yaw;
		this.obs_angle = 0;
		if(movement_check(this))
			return false;
		return true;
	}
	else if(this.obs_angle)
	{
		if(t_walkmove(this, this.obs_angle, runspeed))
		{
			this.angles_y = this.obs_angle;
			if(movement_check(this))
				return false;
			return true;
		}
	}
	int m = 0;
	while(m < 360)
	{
		if(!t_walkmove(this, yaw + m, runspeed))
		{
			if(!t_walkmove(this, yaw - m, runspeed))
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
	this.obs_angle = yaw + m;
	this.angles_y = yaw + m;
	if(movement_check(this))
		return false;
	return true;
}

void end_hunt(entity this)
{
	this.menu = 0;
	if(this.gotstuff == SP_FOLLOW)
		this.gotstuff = this.altaction;
	if(this.goalentity.classname == "goalpoint")
	{
		// don't think this works
		Trigger(this.goalentity, this, this, 0);
		return;
	}
	this.goalentity = NULL;
	//this.frame = 0;
}

void handle_ai(entity this)
{
	entity e, beste = NULL;
	float len = 0, dist = 0, bestdist = 0;
	if(this.bribe_time && this.bribe_time < time)
	{
		this.goalentity = NULL;
		this.enemy = NULL;
		this.classname = "monster";
		this.ai = this.quest_time;
		this.bribe_time = 0;
		this.team = this.questlog;
		this.m_targ.bribe_count = this.m_targ.bribe_count - 1;
		this.solid = SOLID_BBOX;
		this.effects &= ~EF_BLUE;
	}
	
	if(this.ai & AI_ROAM)
	{
		if(this.attack_finished > time)
		{
			if(this.menu < time)
			{
				// look around
				this.angles_y = random() * 360;
				this.menu = time + 2 * random();
			}
			this.frame = 0;
		}
		else if(!moveit(this, this.angles_y, 0))
		{
			this.attack_finished = time + random() * 3;
			this.menu = 0;
		}
		else if(this.menu < time)
		{
			this.menu = 0;
			this.attack_finished = time + random() * 5;
		}
	}
	if(this.ai & AI_HUNT_PLAYER)
	{
		if(!this.enemy)
		{
			bestdist = 9999;
			e = find(NULL, classname, "dummy");
			while(e)
			{

				if(e.owner.health >= 1)
				{
					len = vlen(e.origin - this.origin);
					if(e.owner.visibility < 0)
					{
						if(len > 64)
						{
							if(e.owner.visibility < -35)
								if(!infront(this, e))
									len = 99999;
							if(len > this.finddist *  ((0 - e.owner.visibility) / 100))
								len = 99999;
						}
					}
					if(len < this.finddist)
					{
						if(len < bestdist)
						{
							bestdist = len;
							this.enemy = e;
						}
					}
				}
				e = find(e, classname, "dummy");
			}

			this.goalentity = this.enemy;
		}
		else if(this.enemy.owner.health < 1)
			this.enemy = NULL;
		else if(friendly(this, this.enemy))
		{
			this.frame = 0;
			this.enemy = NULL;
		}
		else
			this.goalentity = this.enemy; // go at 'im again
		if(this.enemy)
		{
			if(this.spell)
			{
				if(this.gotstuff == this.spell)
					len = this.altaction;
				else
					len = this.spell;
				if(this.owner.mana < mana_for_spell(this.gotstuff, GetSpellLevel(this.owner, this.gotstuff)))
					this.gotstuff = len;
				else if(cast_aground(this.gotstuff))
					this.gotstuff = len;
				else if(random() < 0.2)
					this.gotstuff = len;
			}
	
			if(this.theme)
				setdmusic(this.theme);
			e = findradius(this.origin, 90);
			while(e)
			{
				if((e.ai & AI_HUNT_PLAYER) && (e.enemy == NULL))
					e.enemy = e.goalentity = this.enemy;
				e = e.chain;
			}
		}
	}
	if(this.ai & AI_HUNT_MONSTERS)
	{
		if(!this.enemy)
		{
			bestdist = 99999;
			e = find(NULL, classname, "monster");
			while(e)
			{
				if(e.health >= 1)
				{
					if(!friendly(e, this))
					{
						len = vlen(e.origin - this.origin);
						if(e.owner.visibility < 0)
						{
							if(len > 64)
							{
								if(e.owner.visibility < -35)
									if(!infront(this, e))
										len = 99999;
								if(len > this.finddist *  ((0 - e.owner.visibility) / 100))
									len = 99999;
							}
						}
						if(len < this.finddist)
						{
							if(len < bestdist)
							{
								bestdist = len;
								this.enemy = e;
							}
						}
					}
				}
				e = find(e, classname, "monster");
			}
			this.goalentity = this.enemy;
			if(this.enemy)
			{
				if(this.theme)
					setdmusic(this.theme);
			}
		}
		else
		{
			if(friendly(this, this.enemy))
			{
				this.frame = 0;
				this.enemy = NULL;
			}
			else if(this.enemy.health < 1)
			{
				this.frame = 0;
				this.enemy = NULL;
			}
			else
			{
				this.goalentity = this.enemy;
			}
		}
		if(this.enemy)
		if(this.spell)
		{
			if(this.gotstuff == this.spell)
				len = this.altaction;
			else
				len = this.spell;
			if(this.owner.mana < mana_for_spell(this.gotstuff, GetSpellLevel(this.owner, this.gotstuff)))
				this.gotstuff = len;
			else if(cast_aground(this.gotstuff))
				this.gotstuff = len;
			else if(random() < 0.2)
				this.gotstuff = len;
		}
	}
	if(this.ai & AI_HUNT)
	{
		if(!this.enemy)
		{
			bestdist = this.finddist;
			e = findradius(this.origin, bestdist);
			while(e)
			{
				if(e.health >= 1 && e.takedamage)
				{
					if(!friendly(e, this))
					{
						len = vlen(e.origin - this.origin);
						if(e.owner.visibility < 0)
						{
							if(len > 64)
							{
								if(e.owner.visibility < -35)
									if(!infront(this, e))
										len = 99999;
								if(len > this.finddist *  ((0 - e.owner.visibility) / 100))
									len = 99999;
							}
						}
						if(len < bestdist)
						{
							bestdist = len;
							this.enemy = e;
						}
					}
				}
				e = e.chain;
			}
			this.goalentity = this.enemy;
		}
		else if(this.enemy.owner.health < 1)
			this.enemy = NULL;
		else if(friendly(this, this.enemy))
		{
			this.frame = 0;
			this.enemy = NULL;
		}
		else
			this.goalentity = this.enemy; // go at 'im again
		if(this.enemy)
		{
			if(this.spell)
			{
				if(this.gotstuff == this.spell)
					len = this.altaction;
				else
					len = this.spell;
				if(this.owner.mana < mana_for_spell(this.gotstuff, GetSpellLevel(this.owner, this.gotstuff)))
					this.gotstuff = len;
				else if(cast_aground(this.gotstuff))
					this.gotstuff = len;
				else if(random() < 0.2)
					this.gotstuff = len;
			}
	
			if(this.theme)
				setdmusic(this.theme);
			e = findradius(this.origin, 90);
			while(e)
			{
				if((e.ai & AI_HUNT_PLAYER) && (e.enemy == NULL))
					e.enemy = e.goalentity = this.enemy;
				e = e.chain;
			}
		}
	}
	if(this.ai & AI_FOLLOW)
	{
		if(this.classname != "helper")
		if((!this.sbarsub) || (this.sbarsub.owner.health <= 0))
		{
			len = 9999;
			e = find(NULL, classname, "dummy");
			while(e)
			{
				if(e.follow_npcs < len)
				{
					this.sbarsub = e;
					len = e.follow_npcs + 1;	
				}
				e = find(e, classname, "dummy");
			}
			if(this.sbarsub)
				this.sbarsub.follow_npcs = len + 1;
					
		}
		if(this.sbarsub)
		{
			len = vlen(this.sbarsub.origin - this.origin);
			if(len < 60)
			{
				len = this.frame;
				end_hunt(this);
				this.frame = len; // evile hack
				moveit(this, vectoyaw(this.origin - this.sbarsub.origin), this.menu);
			}
			else if(len > 256)
			{
				doaction(this, this.sbarsub, SP_FOLLOW);
				this.menu = 1;
			}
			else if(len > 90 && !this.goalentity)
			{
				if(moveit(this, vectoyaw(this.sbarsub.origin - this.origin), this.menu))
					this.dbltime = 0;
				this.menu = this.sbarsub.menu;
			}
			else if(this.sbarsub.frame == 0) // LAME HACK
				this.frame = 0;
		}

	}
	if(this.ai & AI_TAKE_ITEMS)
	{
		if(!this.goalentity)
		{
			e = find(NULL, classname, "item");
			beste = NULL;
			bestdist = 99999999;
			while(e)
			{
				if(!e.menu)
				{
					dist = vlen(this.origin - e.origin);
					if(dist < bestdist)
					{
						if(visible(this, e))
						{
							beste = e;
							bestdist = dist;		
						}
					}
				}
				e = find(e, classname, "item");
			}
			if(beste)
				doaction(this, beste, SP_ACTIVATE);
		}
	}
	if(this.ai & AI_STAY_NEAR)
	{	
		bestdist = 0;
		beste = NULL;
		e = find(NULL, netname, this.wad);
		while(e)
		{
			dist = e.finddist;
			if(!dist)
				dist = 512;
			len = vlen(e.origin - this.origin);
			if(len > dist)
			{
				if((len - dist) > bestdist)
				{
					bestdist = (len - dist);
					beste = e;
				}	
			}
			e = find(e, netname, this.wad);
		}
		if(beste)
			doaction(this, beste, SP_GOTO2);
	}
}
