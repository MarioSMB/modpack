#ifdef SVQC

spawnfunc(target_position) {}
spawnfunc(target_push) {}

vector trigger_push_calculatevelocity(vector org, entity tgt, float ht, entity pushed_entity)
{
	float grav, sdist, zdist, vs, vz, jumpheight;
	vector sdir, torg;

	torg = tgt.origin + (tgt.mins + tgt.maxs) * 0.5;

	grav = PHYS_GRAVITY(NULL);

	zdist = torg.z - org.z;
	sdist = vlen(torg - org - zdist * '0 0 1');
	sdir = normalize(torg - org - zdist * '0 0 1');

	// how high do we need to push the player?
	jumpheight = fabs(ht);
	if(zdist > 0)
		jumpheight = jumpheight + zdist;

	/*
		STOP.

		You will not understand the following equations anyway...
		But here is what I did to get them.

		I used the functions

		  s(t) = t * vs
		  z(t) = t * vz - 1/2 grav t^2

		and solved for:

		  s(ti) = sdist
		  z(ti) = zdist
		  max(z, ti) = jumpheight

		From these three equations, you will find the three parameters vs, vz
		and ti.
	 */

	// push him so high...
	vz = sqrt(fabs(2 * grav * jumpheight)); // NOTE: sqrt(positive)!

	// we start with downwards velocity only if it's a downjump and the jump apex should be outside the jump!
	if(ht < 0)
		if(zdist < 0)
			vz = -vz;

	vector solution;
	solution = solve_quadratic(0.5 * grav, -vz, zdist); // equation "z(ti) = zdist"
	// ALWAYS solvable because jumpheight >= zdist
	if(!solution.z)
		solution_y = solution.x; // just in case it is not solvable due to roundoff errors, assume two equal solutions at their center (this is mainly for the usual case with ht == 0)
	if(zdist == 0)
		solution_x = solution.y; // solution_x is 0 in this case, so don't use it, but rather use solution_y (which will be sqrt(0.5 * jumpheight / grav), actually)

	float flighttime;
	if(zdist < 0)
	{
		// down-jump
		if(ht < 0)
		{
			// almost straight line type
			// jump apex is before the jump
			// we must take the larger one
			flighttime = solution.y;
		}
		else
		{
			// regular jump
			// jump apex is during the jump
			// we must take the larger one too
			flighttime = solution.y;
		}
	}
	else
	{
		// up-jump
		if(ht < 0)
		{
			// almost straight line type
			// jump apex is after the jump
			// we must take the smaller one
			flighttime = solution.x;
		}
		else
		{
			// regular jump
			// jump apex is during the jump
			// we must take the larger one
			flighttime = solution.y;
		}
	}
	vs = sdist / flighttime;

	// finally calculate the velocity
	return sdir * vs + '0 0 1' * vz;
}

void jumppad_touch(entity this, entity toucher)
{
	if(this.enemy) return;
	if(!IS_PLAYER(toucher)) return;
	entity targ = find(NULL, targetname, this.target);
	if(!targ) return;

	toucher.velocity = trigger_push_calculatevelocity(toucher.origin, targ, 0, toucher);
	UNSET_ONGROUND(toucher);
}

spawnfunc(trigger_push)
{
	_setmodel(this, this.model);
	this.modelindex = 0;
	this.solid = SOLID_TRIGGER;
	settouch(this, jumppad_touch);
}


#endif
