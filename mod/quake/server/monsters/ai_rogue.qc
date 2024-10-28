#include "ai_rogue.qh"

.float orbitPosition;

// ================================================================
// ai_orbit - used to have an object orbit an entity.
//
// destEnt: the entity to orbit
// radius: how large a radius to orbit at (0 will just track)
// offset: center of the orbit. this is added to dest.origin.
//
// Uses this.orbitPosition to determine current destination.
// ================================================================
void ai_orbit(entity this, entity destEnt, float radius, vector offset)
{
	vector dir;

	if(this.orbitPosition > 3)
		this.orbitPosition = 0;
	else if(this.orbitPosition < 0)
		this.orbitPosition = 0;
	
	traceline(this.origin, destEnt.origin + offset, true, NULL);
	if(trace_fraction < 1 )
	{
		setorigin (this, destEnt.origin + offset);
		this.orbitPosition = this.orbitPosition + 1;
		return;
	}
	
	if(this.orbitPosition == 0)
	{
		dir = (destEnt.origin + offset) - this.origin;
		dir.x = dir.x + radius;
	}
	else if(this.orbitPosition == 1)
	{
		dir = (destEnt.origin + offset) - this.origin;
		dir.y = dir.y + radius;
	}
	else if(this.orbitPosition == 2)
	{
		dir = (destEnt.origin + offset) - this.origin;
		dir.x = dir.x - radius;
	}
	else
	{
		dir = (destEnt.origin + offset) - this.origin;
		dir.y = dir.y - radius;
	}

	if(vdist(dir, <, 8))
	{
		this.orbitPosition = this.orbitPosition + 1;
	}
	else if(vdist(dir, <, 50))
	{
		this.velocity = normalize(dir);
		this.velocity = this.velocity * 150;
	}
	else
	{
		this.velocity = normalize(dir);
		this.velocity = this.velocity * 500;
	}
}

// ================================================================
// ai_track - used to have an object chase/track an enemy. the object
//		flies directly at the destEnt's view_ofs point.
//
// destEnt: the entity to orbit
// trackSpeed: the velocity multiplier (speed) of the object
// ================================================================
void ai_track(entity this, entity destEnt, float trackSpeed)
{
	vector dir = destEnt.origin + destEnt.view_ofs;
	dir = normalize(dir - this.origin);
	this.velocity = dir * trackSpeed;
}

// ================================================================
// ViolentDeath
// ================================================================

void AccelerateGib(entity this, string gibname, float dm)
{
	entity gib = spawn();
	gib.origin = this.origin;
	_setmodel(gib, gibname);
	setsize(gib, '-8 -8 -8', '8 8 8');
	
	gib.velocity = -1.25 * this.velocity;
	makevectors (gib.velocity );
	float offset1 = random() * 300 - 150;
	gib.velocity = gib.velocity + v_right * offset1;
	offset1 = random() * 300 - 150;
	gib.velocity = gib.velocity + v_up * offset1;
		
	set_movetype(gib, MOVETYPE_BOUNCE);
	gib.solid = SOLID_NOT;
	gib.avelocity_x = random()*600;
	gib.avelocity_y = random()*600;
	gib.avelocity_z = random()*600;
	setthink(gib, SUB_Remove);
	gib.ltime = time;
	gib.nextthink = time + 10 + random()*10;
	gib.frame = 0;
	gib.flags = 0;
}

void ViolentDeath(entity this, int gibCount)
{
	while(gibCount > 0)
	{
		AccelerateGib(this, "progs/gib1.mdl", (-4 * gibCount));
		AccelerateGib(this, "progs/gib2.mdl", (-6 * gibCount));
		AccelerateGib(this, "progs/gib3.mdl", (-8 * gibCount));
		gibCount = gibCount - 3;
	}	
}
