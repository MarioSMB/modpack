#ifdef SVQC

/*QUAKED func_levelgate(0 .5 .8)
Inversed version of func_episodegate, prevents access until the required runes have been gathered.
"svflags" is the flag number for serverflags when checked.
"spawnflags" "1" will make it inversed working just like func_episodegate but with higher bits.
*/
spawnfunc(func_levelgate)
{
	if(this.spawnflags & 1)
	{
		if(!(serverflags & this.svflags))
			return;
	}
	else
	{
		if(serverflags & this.svflags)
			return;
	}

	this.angles = '0 0 0';
	set_movetype(this, MOVETYPE_PUSH);  // so it doesn't get pushed by anything
	this.solid = SOLID_BSP;
	this.use = func_wall_use;
	_setmodel(this, this.model);
}

const int TRANSFORM_TOGGLE = BIT(0);
void target_transform_use(entity this, entity actor, entity trigger)
{
	if(!IS_PLAYER(actor))
		return;
	if(this.customflags & CFL_LOCKED)
		return;

	Champions targ = NULL;
	if(this.message && this.message != "")
	{
		FOREACH(Champion, it.netname == this.message,
		{
			targ = it;
			break;
		});
		// TODO: warn if one isn't found?
		if(!targ)
			return;
	}

	// abort if player is already transformed by something else
	if(actor.m_transform && actor.m_transform != targ)
		return;

	if(!(this.spawnflags & TRANSFORM_TOGGLE) && actor.m_transform)
		return;

	if(!targ || actor.m_transform)
	{
		QCC_ClearTransform(actor);
		// hard delay of weapons so you don't get stuck spamming!
		for (int slot = 0; slot < MAX_WEAPONSLOTS; ++slot)
		{
			.entity weaponentity = weaponentities[slot];
			if(actor.(weaponentity))
			{
				wep_set_anim(actor.(weaponentity), 0, w_ready);
				ATTACK_FINISHED(actor, weaponentity) = time + 1;
			}
		}
	}
	else
	{
		if(this.wait > 0)
			actor.transform_limited = time + this.wait;
		actor.m_transform = targ;
	}
}

/*QUAKED target_transform (0.75 0.5 0) (-8 -8 -8) (8 8 8) TOGGLE
Transforms the player when activated, or restores their original state if toggled

"message" destination transformation, can be empty to force reset any active transformations
"wait" time the transformation will last, infinite if not set

TOGGLE	cancels the transformation if activated again
*/
spawnfunc(target_transform)
{
	this.use = target_transform_use;
}

#endif
