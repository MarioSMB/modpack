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
	if(this.enemy)
		return;
	if(this.health <= 0)
		return;
	if(actor.items & IT_INVISIBILITY)
		return;
	if(actor.flags & FL_NOTARGET)
		return;
	if(!IS_PLAYER(actor))
		return;
	
// delay reaction so if the monster is teleported, its sound is still
// heard
	this.enemy = actor;
	this.nextthink = time + 0.1;
	setthink(this, FoundTarget);
}

/*
================
monster_death_use

When a mosnter dies, it fires all of its targets with the current
enemy as activator.
================
*/
void monster_death_use(entity this)
{
// fall to ground
	if(this.flags & FL_FLY)
		this.flags &= ~FL_FLY;
	if(this.flags & FL_SWIM)
		this.flags &= ~FL_SWIM;

	if(!this.target)
		return;

	SUB_UseTargets(this, this.enemy, NULL);
}


//============================================================================

void walkmonster_start_go(entity this)
{
	this.origin_z = this.origin_z + 1;	// raise off floor a bit
	droptofloor(this);
	
	if(!walkmove(this,0,0))
	{
		dprint("walkmonster in wall at: ");
		dprint(vtos(this.origin));
		dprint("\n");
	}
	
	this.takedamage = DAMAGE_AIM;

	this.ideal_yaw = this.angles * '0 1 0';
	if(!this.yaw_speed)
		this.yaw_speed = 20;
	this.view_ofs = '0 0 25';
	this.use = monster_use;

	this.flags |= FL_MONSTER;
	
	if(this.target)
	{
		this.goalentity = this.movetarget = find(NULL, targetname, this.target);
		this.ideal_yaw = vectoyaw(this.goalentity.origin - this.origin);
		if(!this.movetarget)
		{
			dprint("Monster can't find target at ");
			dprint(vtos(this.origin));
			dprint("\n");
		}
// this used to be an objerror
		if(this.movetarget.classname == "path_corner")
			this.th_walk(this);
		else
			this.pausetime = 99999999;
			this.th_stand(this);
	}
	else
	{
		this.pausetime = 99999999;
		this.th_stand(this);
	}

// spread think times so they don't all happen at same time
	this.nextthink = this.nextthink + random()*0.5;
}


void walkmonster_start(entity this)
{
// delay drop to floor to make sure all doors have been spawned
// spread think times so they don't all happen at same time
	this.nextthink = this.nextthink + random()*0.5;
	setthink(this, walkmonster_start_go);
	total_monsters = total_monsters + 1;
}

void flymonster_start_go(entity this)
{
	this.takedamage = DAMAGE_AIM;

	this.ideal_yaw = this.angles * '0 1 0';
	if(!this.yaw_speed)
		this.yaw_speed = 10;
	this.view_ofs = '0 0 25';
	this.use = monster_use;

	this.flags |= FL_FLY;
	this.flags |= FL_MONSTER;

	if(!walkmove(0,0))
	{
		dprint("flymonster in wall at: ");
		dprint(vtos(this.origin));
		dprint("\n");
	}

	if(this.target)
	{
		this.goalentity = this.movetarget = find(NULL, targetname, this.target);
		if(!this.movetarget)
		{
			dprint("Monster can't find target at ");
			dprint(vtos(this.origin));
			dprint("\n");
		}
// this used to be an objerror
		if(this.movetarget.classname == "path_corner")
			this.th_walk(this);
		else
			this.pausetime = 99999999;
			this.th_stand(this);
	}
	else
	{
		this.pausetime = 99999999;
		this.th_stand(this);
	}
}

void flymonster_start(entity this)
{
// spread think times so they don't all happen at same time
	this.nextthink = this.nextthink + random()*0.5;
	setthink(this, flymonster_start_go);
	total_monsters = total_monsters + 1;
}


void swimmonster_start_go(entity this)
{
	if(deathmatch)
	{
		delete(this);
		return;
	}

	this.takedamage = DAMAGE_AIM;
	total_monsters = total_monsters + 1;

	this.ideal_yaw = this.angles * '0 1 0';
	if(!this.yaw_speed)
		this.yaw_speed = 10;
	this.view_ofs = '0 0 10';
	this.use = monster_use;
	
	this.flags |= FL_SWIM;
	this.flags |= FL_MONSTER;

	if(this.target)
	{
		this.goalentity = this.movetarget = find(NULL, targetname, this.target);
		if(!this.movetarget)
		{
			dprint("Monster can't find target at ");
			dprint(vtos(this.origin));
			dprint("\n");
		}
// this used to be an objerror
		this.ideal_yaw = vectoyaw(this.goalentity.origin - this.origin);
		this.th_walk(this);
	}
	else
	{
		this.pausetime = 99999999;
		this.th_stand(this);
	}

// spread think times so they don't all happen at same time
	this.nextthink = this.nextthink + random()*0.5;
}

void swimmonster_start(entity this)
{
// spread think times so they don't all happen at same time
	this.nextthink = this.nextthink + random()*0.5;
	setthink(this, swimmonster_start_go);
	total_monsters = total_monsters + 1;
}


