#ifdef SVQC

void teleport_touch(entity this, entity toucher)
{
	if(this.targetname && this.targetname != "" && this.nextthink < time)
		return;		// not fired yet

	if((this.spawnflags & PLAYER_ONLY) && !IS_PLAYER(toucher))
		return;

// only teleport living creatures
	if(toucher.health <= 0 || toucher.solid != SOLID_SLIDEBOX)
		return;

	SUB_UseTargets(this, NULL, toucher);

// put a tfog where the player was
	spawn_tfog(toucher.origin);

	entity targ = find(NULL, targetname, this.target);
	if(!targ)
		objerror(this, "couldn't find target");
		
// spawn a tfog flash in front of the destination
	makevectors(targ.mangle);
	vector org = targ.origin + 32 * v_forward;

	spawn_tfog(org);
	spawn_tdeath(targ.origin, toucher);

// move the player and lock him down for a little while
	if(!toucher.health)
	{
		toucher.origin = targ.origin;
		toucher.velocity = (v_forward * toucher.velocity_x) + (v_forward * toucher.velocity_y);
		return;
	}

	setorigin(toucher, targ.origin);
	toucher.angles = targ.mangle;
	if(IS_PLAYER(toucher))
	{
		toucher.fixangle = 1;		// turn this way immediately
		toucher.teleport_time = time + 0.7;
		toucher.velocity = v_forward * 300;
	}

	UNSET_ONGROUND(toucher);

	BITXOR_ASSIGN(toucher.effects, EF_TELEPORT_BIT);
}

/*QUAKED info_teleport_destination(.5 .5 .5)(-8 -8 -8)(8 8 32)
This is the destination marker for a teleporter.  It should have a "targetname" field with the same value as a teleporter's "target" field.
*/
spawnfunc(info_teleport_destination)
{
// this does nothing, just serves as a target spot
	this.mangle = this.angles;
	this.angles = '0 0 0';
	this.model = "";
	this.origin = this.origin + '0 0 27';
	if(!this.targetname || this.targetname == "")
		objerror(this, "no targetname");
}

void teleport_use(entity this, entity actor, entity trigger)
{
	this.nextthink = time + 0.2;
	force_retouch = 2;		// make sure even still objects get hit
	setthink(this, SUB_NullThink);
}

void trigger_start_go(entity this)
{
	// purely a dev print for wonky triggers
	#if 0
	entity temp = find(NULL, targetname, this.target);
	if(!temp || (temp.classname != "info_teleport_destination" && temp.classname != "misc_teleporttrain"))
	{
		dprint("trigger_teleport");
		if(this.targetname && this.targetname != "")
		{
			dprint(", targetname '");
			dprint(this.targetname);
			dprint("'");
		}
		dprint(", target '");
		dprint(this.target);
		if(!temp)
		{
			dprint("' has no target\n");
		}
		else
		{
			if(temp == this)
			{
				dprint("' targets itthis\n");
			}
			else
			{
				dprint("' has unusual target ");
				dprint(temp.classname);
				dprint("'\n");
			}
		}
	}
	#endif
	if(angry_monsters && this.targetname && this.targetname != "")
	{
		if(world.model != "maps/end.bsp" || this.targetname != "t68")
			this.use(this, NULL, NULL);
	}
}

/*QUAKED trigger_teleport(.5 .5 .5) ? PLAYER_ONLY SILENT CTF_ONLY
Any object touching this will be transported to the corresponding info_teleport_destination entity. You must set the "target" field, and create an object with a "targetname" field that matches.

If the trigger_teleport has a targetname, it will only teleport entities when it has been fired.
*/
spawnfunc(trigger_teleport)
{
	if(MP_ROGUE && (this.spawnflags & CTF_ONLY))
	{
		if(teamplay < TEAM_CTF || teamplay > TEAM_CTF_ALT)
		{
			delete(this);
			return;
		}
	}

	InitTrigger(this);
	settouch(this, teleport_touch);
	// find the destination 
	if(!this.target || this.target == "")
		objerror(this, "no target");
	this.use = teleport_use;

	if(!(this.spawnflags & SILENT))
	{
		precache_sound("ambience/hum1.wav");
		vector o = (this.mins + this.maxs) * 0.5;
		ambientsound(o, "ambience/hum1.wav", 0.5, ATTN_STATIC);
	}

	if(MP_IMPEL)
	{
		this.nextthink = this.nextthink + 0.5;
		setthink(this, trigger_start_go);
	}
}


#endif
