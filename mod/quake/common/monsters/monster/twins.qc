#include "twins.qh"

// NOTE: this is a "fake" monster and a massive hack!
// unfortunately it's the only way currently to create a multi-boss...

#include "retinazer.qh"
#include "spazmatism.qh"

#ifdef SVQC
void twins_cleanup(entity this)
{
	setthink(this, SUB_Remove);
	this.nextthink = time;
}

entity twins_create(entity actor, Monster mon)
{
	entity twin = new(monster);

	setorigin(twin, actor.origin);
	twin.angles = actor.angles;
	twin.spawnflags = actor.spawnflags;

	monster_start(twin, false, mon);

	return twin;
}

spawnfunc(monster_twins)
{
	this.flags |= FL_SPAWNING; // prevent counting as a monster
	monster_start(this, true, MON_TWINS);
}
#endif // SVQC

#ifdef SVQC
METHOD(Twins, mr_setup, bool(Twins this, entity actor))
{
	TC(Twins, this);

	actor.health = 1;
	actor.takedamage = DAMAGE_NO;
	actor.solid = SOLID_NOT;
	setorigin(actor, actor.origin); // relink

	entity spaz = twins_create(actor, MON_SPAZMATISM);
	entity ret = twins_create(actor, MON_RETINAZER);

	if(actor.target && actor.target != "")
	{
		string targname = strzone(strcat("twins_", etos(actor)));

		entity counter = spawn();
		counter.classname = "trigger_counter";
		counter.spawnfunc_checked = true;
		counter.targetname = targname;
		counter.target = actor.target;
		counter.count = 2;
		spawnfunc_trigger_counter(counter);

		spaz.target = targname;
		ret.target = targname;
	}

	tether_setup(spaz, ret, TETHER_FLESH, 9);

	// just delete it on the first movement attempt to avoid troubles
	actor.th_stand = twins_cleanup;
	actor.th_walk = twins_cleanup;
	actor.th_run = twins_cleanup;

	return true;
}
#endif
