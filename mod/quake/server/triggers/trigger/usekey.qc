#ifdef SVQC

const int USE_GOLD_KEY = BIT(0);

void keytrigger_use(entity this, entity actor, entity trigger)
{
	if(!IS_PLAYER(actor))
		return;
	if(this.attack_finished > time)
		return;

	this.attack_finished = time + 2;

// FIXME: blink key on player's status bar
	if((this.items & actor.items) != this.items)
	{
		if(this.message != "")
			centerprint(actor, this.message);
		else
		{
			if(this.owner.items == IT_KEY1)
			{
				if(world.worldtype == 2)
					centerprint(actor, "You need the silver keycard");
				else if(world.worldtype == 1)
					centerprint(actor, "You need the silver runekey");
				else if(world.worldtype == 0)
					centerprint(actor, "You need the silver key");
				else
				{
					if(world.worldtype == 2)
						centerprint(actor, "You need the gold keycard");
					else if(world.worldtype == 1)
						centerprint(actor, "You need the gold runekey");
					else if(world.worldtype == 0)
						centerprint(actor, "You need the gold key");
				}
				_sound(this, CHAN_VOICE, this.noise3, 1, ATTN_NORM);
				return;
			}
		}
	}

	actor.items &= ~this.items;

	// we can't just remove (this) here, because this is a touch function
	// called while C code is looping through area links...
	settouch(this, func_null);
	this.use = func_null;
	this.nextthink = time + 0.1;
	setthink(this, SUB_Remove);
	this.message = "";

	_sound(this, CHAN_VOICE, this.noise4, 1, ATTN_NORM);

	SUB_UseTargets(this, actor, trigger);
}

void keytrigger_touch(entity this, entity toucher)
{
	keytrigger_use(this, toucher, toucher); // mimic old behaviour by keeping toucher set as trigger
}

/*QUAKED trigger_usekey (0 .5 0) ? USE_GOLD_KEY
Variable sized single use trigger that requires a key to trigger targets.  Must be targeted at one or more entities.

"message" is printed when the trigger is touched without having the right key.
*/

spawnfunc(trigger_usekey)
{
	if(!MP_HIPNOTIC) { delete(this); return; }

	if(world.worldtype == 0)
	{
		precache_sound("doors/medtry.wav");
		precache_sound("doors/meduse.wav");
		this.noise3 = "doors/medtry.wav";
		this.noise4 = "doors/meduse.wav";
	}
	else if(world.worldtype == 1)
	{
		precache_sound("doors/runetry.wav");
		precache_sound("doors/runeuse.wav");
		this.noise3 = "doors/runetry.wav";
		this.noise4 = "doors/runeuse.wav";
	}
	else if(world.worldtype == 2)
	{
		precache_sound("doors/basetry.wav");
		precache_sound("doors/baseuse.wav");
		this.noise3 = "doors/basetry.wav";
		this.noise4 = "doors/baseuse.wav";
	}
	else
		LOG_DEBUG("no worldtype set!\n");

	if(this.spawnflags & USE_GOLD_KEY)
		this.items = IT_KEY2;
	else
		this.items = IT_KEY1;

	this.use = keytrigger_use;
	settouch(this, keytrigger_touch);

	InitTrigger(this);
}

#endif
