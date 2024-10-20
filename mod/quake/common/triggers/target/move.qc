#ifdef SVQC
.string targetname2;

void target_move_use(entity this, entity actor, entity trigger)
{
	entity t = NULL;

	// move activator
	if(this.spawnflags & 8)
		t = actor;
	else
	{
		t = find(NULL, targetname, this.target);

		if(!t) //targetname not found, search for targetname2
			t = find(NULL, targetname2, this.target);
	}

	if(t)
	{
		vector neworigin = this.origin;
		if(IS_MONSTER(t)) //monsters need to move off the ground, otherwise they'll lerp 
			neworigin += '0 0 1';

		// spawn teleport effect
		if(this.spawnflags & 4)
			spawn_tfog(t.origin);

		setorigin(t, neworigin);
		//t.origin = this.origin;
		// keep original angle
		if(!(this.spawnflags & 1))
			t.angles = this.mangle;
		// keep original velocity
		if(!(this.spawnflags & 2))
			t.velocity = '0 0 0';
		UNSET_ONGROUND(t);

		if(this.spawnflags & 4)
		{
			vector tfog_org;
			if(IS_PLAYER(t))
			{
				makevectors(t.v_angle);
				tfog_org = t.origin + v_forward * 32;
			}
			else
				tfog_org = t.origin;
			spawn_tfog(tfog_org);
		}
	}

}

/*QUAKED target_move (1 .0 .5) (-8 -8 -8) (8 8 8) KEEP_ANGLE KEEP_VELOCITY
Moves target entity to this spot and angle when triggered.
Use spawnflag 1 to not change the entity's original angle.
Spawnflag 2 keeps the entity's original velocity.
*/
spawnfunc(target_move)
{
	if((!this.target || this.target == "") && !(this.spawnflags & 8))
	{
		objerror(this, "No target set");
		return;
	}

	if(!this.targetname || this.targetname == "")
	{
		objerror(this, "No targetname set");
		return;
	}

	this.use = target_move_use;
	
	if(!this.mangle)
		this.mangle = this.angles;
}
#endif
