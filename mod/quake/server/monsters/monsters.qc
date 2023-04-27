#include "monsters.qh"

/* ALL MONSTERS SHOULD BE 1 0 0 IN COLOR */

// name =[framenum,	nexttime, nextthink] {code}
// expands to:
// name()
// {
//		this.frame=framenum;
//		this.nextthink = time + nexttime;
//		this.think = nextthink
//		<code>
// }

/*
================
monster_use

Using a monster makes it angry at the current activator
================
*/
void monster_use(entity this, entity actor, entity trigger)
{
	if(this.enemy || this.health <= 0 || (actor.powerups & POWERUP_INVISIBILITY) || (actor.flags & FL_NOTARGET) || !IS_PLAYER(actor))
		return;
	
	// delay reaction so if the monster is teleported, its sound is still heard
	this.enemy = actor;
	this.nextthink = time + 0.1;
	setthink(this, FoundTarget);
}

float orig_random(entity this)
{
	float len = vlen(this.origin);
	return len - floor(len);
}


//============================================================================

void monster_start_go(entity this)
{
	bool is_walker = !((this.flags & FL_SWIM) || (this.flags & FL_FLY)); // special check needed here as there isn't a walk flag

	if(!this.yaw_speed)
		this.yaw_speed = ((is_walker) ? 20 : 10);
	if(is_walker)
	{
		this.origin_z = this.origin_z + 1;	// raise off floor a bit
		droptofloor(this);
	}

	this.view_ofs = ((this.flags & FL_SWIM) ? '0 0 10' : '0 0 25');
	this.takedamage = DAMAGE_AIM;
	this.ideal_yaw = this.angles * '0 1 0';
	this.use = monster_use;

	if(!(this.flags & FL_SWIM))
	{
		if(!t_walkmove(this, 0, 0))
			LOG_DEBUG("Monster in wall at ", vtos(this.origin), "\n");
	}

	if(MP_IMPEL && this.health <= 0)
		return;

	if(this.target && this.target != "")
	{
		this.goalentity = this.movetarget = find(NULL, targetname, this.target);
		if(!this.movetarget || this.movetarget.classname != "path_corner")
		{
			//LOG_DEBUG("Monster can't find target at ", vtos(this.origin), "\n");
			this.pausetime = -1;
			this.th_stand(this);
		}
		else
		{
			this.ideal_yaw = vectoyaw(this.goalentity.origin - this.origin);
			this.th_walk(this);
		}
	}
	else
	{
		this.pausetime = -1;
		this.th_stand(this);
	}
}

void monster_start(entity this, int stype)
{
	if(deathmatch) { delete(this); return; }

	// spread think times so they don't all happen at same time
	this.nextthink = this.nextthink + random() * 0.5;
	setthink(this, monster_start_go);
	this.flags |= FL_MONSTER;
	this.flags |= stype; // TODO?
	this.max_health = this.health;

	if(!this.damagedbycontents)
		IL_PUSH(g_damagedbycontents, this);
	this.damagedbycontents	= true;

	if(!(stype & FL_DECOY) && (!MP_IMPEL || !(this.flags & FL_SWIM)))
		monsters_total += 1;
}
