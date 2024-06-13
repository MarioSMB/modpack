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

	if(this.spawnmulti || horn_active)
	{
		// spawn the new entity
		spawnentity = spawn();
		// copy the master mold
		SUB_CopyEntity(this.spawnmaster,spawnentity);
		spawnentity.flags |= FL_CLONE; // mark as clone so it doesn't add to the monster counts
	}
	else
		spawnentity = this.spawnmaster;

	if(horn_active)
	{
		spawnentity.charmer = actor;
		spawnentity.charmed = true;
	}

	int olddm = deathmatch;
	deathmatch = 0;
	if(spawnentity.spawnthink) // maybe we should error out if this doesn't exist...
		spawnentity.spawnthink(spawnentity);

	deathmatch = olddm;

	if(horn_active)
	{
		spawnentity.colormod = '0 1 0';
		spawnentity.health = max(spawnentity.health, 1000);
		spawnentity.max_health = spawnentity.health;
	}

	// spawn the teleport effect
	if(this.spawnsilent == 0)
		spawn_tfog(spawnentity.origin);
//   horn_active = 0;
//   horn_charmer = find(NULL, classname, "player");
	// call spawnentity think function
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
	if(!this.spawnmulti && !horn_active)
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

	mon.spawnthink = sfunc;
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
	_setmodel(this, "");
	setsize(this, '0 0 0', '0 0 0');

	initialize_field_db();

	entity monster;

	if(!this.spawnfunction || this.spawnfunction == "")
	{
		float spawnchance = random();
		monster = this;

		if(spawnchance < 0.5 && monster == this) { monster = func_spawn_spawnmob(this, spawnfunc_monster_dog, "monster_dog"); }
		if(spawnchance < 0.8 && monster == this) { monster = func_spawn_spawnmob(this, spawnfunc_monster_ogre, "monster_ogre"); }
		if(spawnchance < 0.92 && monster == this) { monster = func_spawn_spawnmob(this, spawnfunc_monster_demon1, "monster_demon1"); }
		if(spawnchance < 0.97 && monster == this) { monster = func_spawn_spawnmob(this, spawnfunc_monster_zombie, "monster_zombie"); }
		if(monster == this) { monster = func_spawn_spawnmob(this, spawnfunc_monster_shambler, "monster_shambler"); }
	}
	else
	{
		// spawn the new entity
		entity mon = spawn();
		mon.spawnfunc_checked = true;
		// copy over everything
		SUB_CopyEntity(this, mon);

		// save off monster count so it doesn't get f'ed up
		if(!mon.spawnclassname || mon.spawnclassname == "")
			objerror(mon, "No spawnclassname defined");

		mon.classname = mon.spawnclassname;
		// call the named spawn function
		string value = strcat("spawnfunc_", mon.spawnfunction);
		if(substring(value, 0, 1) == "_")
			value = strcat("target_spawn_helper", value);
		putentityfieldstring(target_spawn_spawnfunc_field, mon, value);

		//save off think func and
		//get rid of his thinking
		mon.spawnthink = mon.target_spawn_spawnfunc;
		setthink(mon, func_spawn_think);
		mon.nextthink = time + 1;
		monster = mon;
	}
	this.use = spawn_use;
	this.spawnmaster = monster;
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
	spawnfunc_func_spawn(this);
}

#endif
