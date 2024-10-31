#ifdef SVQC

const int USE_GOLD_KEY = BIT(0);
const int USE_PLAT_KEY = 16384; // alkaline

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
			if(this.items == IT_KEY1)
			{
				if(world.worldtype == WORLDTYPE_BASE)
					centerprint(actor, "You need the silver keycard");
				else if(world.worldtype == WORLDTYPE_METAL)
					centerprint(actor, "You need the silver runekey");
				else if(world.worldtype == WORLDTYPE_MEDIEVAL)
					centerprint(actor, "You need the silver key");
			}
			else if(this.items == IT_KEY2)
			{
				if(world.worldtype == WORLDTYPE_BASE)
					centerprint(actor, "You need the gold keycard");
				else if(world.worldtype == WORLDTYPE_METAL)
					centerprint(actor, "You need the gold runekey");
				else if(world.worldtype == WORLDTYPE_MEDIEVAL)
					centerprint(actor, "You need the gold key");
			}
			else if(this.items == IT_KEY3)
			{
				if(world.worldtype == WORLDTYPE_BASE)
					centerprint(actor, "You need the platinum keycard");
				else if(world.worldtype == WORLDTYPE_METAL)
					centerprint(actor, "You need the platinum runekey");
				else if(world.worldtype == WORLDTYPE_MEDIEVAL)
					centerprint(actor, "You need the platinum key");
			}
		}
		_sound(this, CH_INFO, this.noise3, 1, ATTN_NORM);
		return;
	}

	key_spend(actor, this.items);

	// we can't just remove (this) here, because this is a touch function
	// called while C code is looping through area links...
	settouch(this, func_null);
	this.use = func_null;
	this.nextthink = time + 0.1;
	setthink(this, SUB_Remove);
	this.message = "";

	_sound(this, CH_INFO, this.noise4, 1, ATTN_NORM);

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
	if(world.worldtype == WORLDTYPE_MEDIEVAL)
	{
		precache_sound("doors/medtry.wav");
		precache_sound("doors/meduse.wav");
		this.noise3 = "doors/medtry.wav";
		this.noise4 = "doors/meduse.wav";
	}
	else if(world.worldtype == WORLDTYPE_METAL)
	{
		precache_sound("doors/runetry.wav");
		precache_sound("doors/runeuse.wav");
		this.noise3 = "doors/runetry.wav";
		this.noise4 = "doors/runeuse.wav";
	}
	else if(world.worldtype == WORLDTYPE_BASE)
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
	else if(this.spawnflags & USE_PLAT_KEY)
		this.items = IT_KEY3;
	else
		this.items = IT_KEY1;

	this.use = keytrigger_use;
	settouch(this, keytrigger_touch);

	InitTrigger(this);
	this.solid = SOLID_TRIGGER; // workaround for a copper hack that sets triggers with health as nonsolid
}

#endif
