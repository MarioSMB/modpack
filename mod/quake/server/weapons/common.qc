#include "common.qh"

bool W_DualWielding(entity player)
{
	int held_weapons = 0;
	for(int slot = 0; slot < MAX_WEAPONSLOTS; ++slot)
	{
		.entity weaponentity = weaponentities[slot];
		if(player.(weaponentity) && player.(weaponentity).m_weapon != WEP_Null)
			++held_weapons;
	}

	return held_weapons > 1;
}

.float wait;
/// Automatically guides a projectile towards its enemy.
float W_SeekOutEnemy(entity this,
	float speed_decel, float speed_accel, float speed_max, float turn_rate,
	bool smart, float smart_mindist, float smart_trace_min, float smart_trace_max)
{
	if (this.enemy != NULL
	&&  this.enemy.takedamage != DAMAGE_AIM || this.enemy.health <= 0)
		this.enemy = NULL;
	if (!this.enemy)
		return 0;

	float spd = vlen(this.velocity);
	spd = bound(
		spd - speed_decel * frametime,
		speed_max,
		spd + speed_accel * frametime);

	vector eorg = 0.5 * (this.enemy.absmin + this.enemy.absmax);
	float dist = vlen(eorg - this.origin);
	vector desireddir = (eorg - this.origin) * 1 / dist;
	vector olddir = this.velocity * 1 / spd; // get my current direction

	// Do evasive maneuvers for world objects? ( this should be a cpu hog. :P )
	if (smart && dist > smart_mindist)
	{
		// Is it a better idea (shorter distance) to trace to the target itself?
		if (vdist(this.origin + olddir * this.wait, <, dist))
			traceline(this.origin, this.origin + olddir * this.wait, false, this);
		else
			traceline(this.origin, eorg, false, this);

		// Setup adaptive tracelength
		this.wait = bound(
			smart_trace_min,
			vlen(this.origin - trace_endpos),
			smart_trace_max);

		// Calc how important it is that we turn and add this to the desired (enemy) dir
		desireddir = normalize((trace_plane_normal * (1 - trace_fraction)) + (desireddir * trace_fraction));
	}

	vector newdir = normalize(olddir + desireddir * turn_rate); // take the average of the 2 directions; not the best method but simple & easy
	this.velocity = newdir * spd; // make me fly in the new direction at my flight speed
	return dist;
}
