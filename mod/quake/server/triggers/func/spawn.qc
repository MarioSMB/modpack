#include "spawn.qh"

#ifdef SVQC
void func_spawn_think(entity this)
{
	setthink(this, func_spawn_think);
	this.nextthink = time + 1;
}

void spawn_use(entity this, entity actor, entity trigger)
{
	entity spawnentity;
	bool horn_active = (trigger.powerups & POWERUP_HORN_OF_CONJURING); // check the TRIGGER, as a player holding a horn might stumble upon a regular monster spawner!

	if((this.spawnmulti == 1) || (horn_active))
	{
		// spawn the new entity
		spawnentity = spawn();
		// copy the master mold
		SUB_CopyEntity(this.spawnmaster,spawnentity);
	}
	else
		spawnentity = this.spawnmaster;

	spawnentity.flags &= ~FL_NOTARGET;
	// restore the model
	spawnentity.model = spawnentity.spawnmodel;
	//restore solid flag
	spawnentity.solid = spawnentity.spawnsolidtype;
	//restore thinking function
	setthink(spawnentity, spawnentity.spawnthink);
	_setmodel(spawnentity, spawnentity.model);
	setorigin(spawnentity, spawnentity.origin);
	spawnentity.mins = spawnentity.spawnmins;
	spawnentity.maxs = spawnentity.spawnmaxs;
	setsize(spawnentity, spawnentity.mins, spawnentity.maxs);
	// spawn the teleport effect
	if(this.spawnsilent == 0)
		spawn_tfog(spawnentity.origin);
//   horn_active = 0;
//   horn_charmer = find(NULL, classname, "player");
	// call spawnentity think function
	if(horn_active)
	{
		spawnentity.charmer = actor;
		spawnentity.charmed = 1;
		spawnentity.colormod = '0 1 0';
		spawnentity.health = max(spawnentity.health, 1000);
	}
//   if(spawnentity.think)
//      {
//      spawnentity.nextthink = time+0.1;
//      tempthis = this;
//      this = spawnentity;
//      this.think();
//      this = tempthis;
//      spawnentity.nextthink = time+0.1;
//      this.nextthink = 1;
//      if(spawnentity.nextthink < time)
//         spawnentity.nextthink = 1;
//      }
	// check to see if it is a monster
	if(IS_MONSTER(spawnentity))
	{
		if((this.spawnmulti != 0) && !horn_active)
			monsters_total += 1;
		// spawn the telefrag effect
//      if(this.spawnsilent == 0)
//         spawn_tdeath(spawnentity.origin, spawnentity);
		if(horn_active)
		{
			spawnentity.effects |= EF_DIMLIGHT;
//         spawnentity.effects = spawnentity.effects | EF_BRIGHTFIELD;
		}
	}
	if((this.spawnmulti == 0) && !horn_active)
		delete(this);
}

entity func_spawn_spawnmob(entity this, void(entity) sfunc, string class)
{
	// spawn the new entity
	entity mon = spawn();
	mon.spawnfunc_checked = true;
	// copy over everything
	SUB_CopyEntity(this, mon);
	mon.target_spawn_spawnfunc = sfunc;
	mon.spawnclassname = class;
	mon.classname = mon.spawnclassname;

	// call the named spawn function
	sfunc(mon);
	mon.spawnmodel = mon.model;
	mon.spawnmins = mon.mins;
	mon.spawnmaxs = mon.maxs;
	_setmodel(mon, "");
	setsize(mon, mon.spawnmins, mon.spawnmaxs);
	//save off solid flag
	mon.spawnsolidtype = mon.solid;
	mon.solid = SOLID_NOT;
	//save off think func and
	//get rid of his thinking
	mon.spawnthink = getthink(mon);
	setthink(mon, func_spawn_think);
	mon.nextthink = time + 1;

	return mon;
}

/*QUAKED func_spawn (0 .5 .8) (-32 -32 -24) (32 32 64) big/ambush megahealth
This will spawn a thing upon being used. The thing that
is spawned depends upon the value of "spawnfunction".
"spawnclassname" should contain the same value as "spawnfunction".
If "spawnfunction" is unspecified a random monster is chosen.
The angles, target and all flags are passed on
Think of it like setting up a normal entity.
"spawnsilent" set this to 1 if you want a silent spawn.
"spawnmulti" set this to 1 if you want this spawn to be reoccuring.
*/

// TODO
spawnfunc(monster_dog);
spawnfunc(monster_ogre);
spawnfunc(monster_demon1);
spawnfunc(monster_zombie);
spawnfunc(monster_shambler);
spawnfunc(func_spawn)
{
	if(!MP_HIPNOTIC) { delete(this); return; }

	initialize_field_db();

	entity monster;
	int temptotal_monsters;

	// save off deathmatch and zero it out
	int tempdeathmatch = deathmatch;
	deathmatch = 0;
	if(!this.spawnfunction || this.spawnfunction == "")
	{
		float spawnchance = random();
		monster = this;

		// save off monster count so it doesn't get f'ed up
		temptotal_monsters = monsters_total;

		if(spawnchance < 0.5 && monster == this) { monster = func_spawn_spawnmob(this, spawnfunc_monster_dog, "monster_dog"); }
		if(spawnchance < 0.8 && monster == this) { monster = func_spawn_spawnmob(this, spawnfunc_monster_ogre, "monster_ogre"); }
		if(spawnchance < 0.92 && monster == this) { monster = func_spawn_spawnmob(this, spawnfunc_monster_demon1, "monster_demon1"); }
		if(spawnchance < 0.97 && monster == this) { monster = func_spawn_spawnmob(this, spawnfunc_monster_zombie, "monster_zombie"); }
		if(monster == this) { monster = func_spawn_spawnmob(this, spawnfunc_monster_shambler, "monster_shambler"); }

		// make sure monster count is correct
		monsters_total = temptotal_monsters + 1;
	}
	else
	{
		// spawn the new entity
		entity mon = spawn();
		mon.spawnfunc_checked = true;
		// copy over everything
		SUB_CopyEntity(this, mon);

		// save off monster count so it doesn't get f'ed up
		temptotal_monsters = monsters_total;
		if(!mon.spawnclassname || mon.spawnclassname == "")
			objerror(mon, "No spawnclassname defined");

		mon.classname = mon.spawnclassname;
		// call the named spawn function
		string value = strcat("spawnfunc_", mon.spawnfunction);
		if(substring(value, 0, 1) == "_")
			value = strcat("target_spawn_helper", value);
		putentityfieldstring(target_spawn_spawnfunc_field, mon, value);

		mon.target_spawn_spawnfunc(mon);
		if(mon.spawnmulti != 0)
		{
			// make sure monster count is correct
			monsters_total = temptotal_monsters;
		}
		mon.spawnmodel = mon.model;
		mon.spawnmins = mon.mins;
		mon.spawnmaxs = mon.maxs;
		_setmodel(mon, "");
		mon.model = "";
		setsize(mon, mon.spawnmins, mon.spawnmaxs);
		//save off solid flag
		mon.spawnsolidtype = mon.solid;
		mon.solid = SOLID_NOT;
		//save off think func and
		//get rid of his thinking
		mon.spawnthink = getthink(mon);
		setthink(mon, func_spawn_think);
		mon.nextthink = time + 1;
		monster = mon;
	}
	deathmatch = tempdeathmatch;
	this.solid = SOLID_NOT;
	set_movetype(this, MOVETYPE_NONE);
	this.modelindex = 0;
	this.model = "";
	_setmodel (this, this.model);  // set size and link into world
	this.use = spawn_use;
	this.spawnmaster = monster;
	monster.flags |= FL_NOTARGET;
}

/*QUAKED func_spawn_small (0 .5 .8) (-16 -16 -24) (16 16 40) big/ambush megahealth
This will spawn a thing upon being used. The thing that
is spawned depends upon the value of "spawnfunction".
"spawnclassname" should contain the same value as "spawnfunction".
If "spawnfunction" is unspecified a random monster is chosen.
The angles, target and all flags are passed on
Think of it like setting up a normal entity.
"spawnsilent" set this to 1 if you want a silent spawn.
"spawnmulti" set this to 1 if you want this spawn to be reoccuring.
*/

spawnfunc(func_spawn_small)
{
	if(!MP_HIPNOTIC) { delete(this); return; }

	spawnfunc_func_spawn(this);
}

#endif
