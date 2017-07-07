/* Trigger QuickC program
	 By Jim Dose'  12/2/96
	 Copyright (c)1996 Hipnotic Interactive, Inc.
	 All rights reserved.
	 Distributed (unsupported) on 3.12.97
*/

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

void remove_touch(entity this, entity toucher)
{
	if(toucher.flags & this.cnt)
		return;
	settouch(toucher, func_null);
	toucher.model = "";
	delete(this); // TODO: shouldn't this be toucher?
//   toucher.nextthink = time + 0.1;
//   toucher.think = SUB_Remove;
}

/*QUAKED trigger_remove (.5 .5 .5) ? ignoremonsters ignoreplayers
Variable sized trigger that removes the thing
that touches it.  Does not affect monsters or
players.
*/
spawnfunc(trigger_remove)
{
	if(!MP_HIPNOTIC) { delete(this); return; }

	this.cnt = FL_CLIENT | FL_MONSTER;
	if(this.spawnflags & 1)
		this.cnt &= ~FL_MONSTER;
	if(this.spawnflags & 2)
		this.cnt &= ~FL_CLIENT;

	InitTrigger(this);
	settouch(this, remove_touch);
}
/*
==============================================================================

trigger_setgravity

==============================================================================
*/

void trigger_gravity_touch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher))
		return;
	if(this.gravity == -1)
		toucher.gravity = 1.0;
	else
		toucher.gravity = this.gravity;
}

/*QUAKED trigger_setgravity (.5 .5 .5) ?
set the gravity of a player
"gravity" what to set the players gravity to
 - 0 (default) normal gravity
 - 1 no gravity
 - 2 almost no gravity
 - ...
 - 101 normal gravity
 - 102 slightly higher gravity
 - ...
 - 1000 very high gravity
*/
spawnfunc(trigger_setgravity)
{
	if(!MP_HIPNOTIC) { delete(this); return; }

	InitTrigger(this);
	settouch(this, trigger_gravity_touch);
	if(!this.gravity)
		this.gravity = -1;
	else
		this.gravity = ((this.gravity - 1) / 100);
}

void trigger_command_use(entity this, entity actor, entity trigger)
{
	if(this.message)
		localcmd(strcat("\n", this.message, "\n"));
}

/*QUAKED trigger_command (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
 When triggered, stuffs a command into the console to allow map
 designers to set server variables.

 "message" is the command to send to the console.
*/

spawnfunc(trigger_command)
{
	if(!MP_HIPNOTIC) { delete(this); return; }

	this.use = oncount_use;
	setthink(this, func_null);
}

void trigger_decoy_touch(entity this, entity toucher)
{
	if(toucher.classname != "monster_decoy")
		return;
	settouch(this, func_null);
	this.nextthink = time + 0.1;
	setthink(this, SUB_Remove);
	SUB_UseTargets(this, NULL, toucher); // TODO? doesn't set activator
}

/*QUAKED trigger_decoy_use (.5 .5 .5) ?
 only the decoy player can trigger this
 once triggers, all targets are used
*/

spawnfunc(trigger_decoy_use)
{
	if(!MP_HIPNOTIC) { delete(this); return; }

	if(deathmatch) { delete(this); return; }

	InitTrigger(this);
	settouch(this, trigger_decoy_touch);
}

void trigger_waterfall_touch(entity this, entity toucher)
{
	// only affect players
	if(!IS_CLIENT(toucher))
		return;

	toucher.velocity = toucher.velocity + this.movedir;
	toucher.velocity_x = toucher.velocity_x + this.count * ( random() - 0.5 );
	toucher.velocity_y = toucher.velocity_y + this.count * ( random() - 0.5 );
}

/*QUAKED trigger_waterfall (.2 .5 .2) ?
 Pushes the player in the direction specified by angles.

 "speed" is the strength of the push (default 50).
 "count" amount of random xy movement to add to velocity (default 100).
*/

spawnfunc(trigger_waterfall)
{
	if(!MP_HIPNOTIC) { delete(this); return; }

	InitTrigger(this);
	settouch(this, trigger_waterfall_touch);

	if(!this.count)
		this.count = 100;

	if(!this.speed)
		this.movedir = this.movedir * 50;
	else
		this.movedir = this.movedir * this.speed;
}
