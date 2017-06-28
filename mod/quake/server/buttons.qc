// button and multiple button

void button_return(entity this);

void button_wait(entity this)
{
	this.state = STATE_TOP;
	this.nextthink = this.ltime + this.wait;
	setthink(this, button_return);
	SUB_UseTargets(this, this.enemy, NULL);
	this.frame = 1;			// use alternate textures
}

void button_done(entity this)
{
	this.state = STATE_BOTTOM;
}

void button_return(entity this)
{
	this.state = STATE_DOWN;
	SUB_CalcMove(this, this.pos1, this.speed, button_done);
	this.frame = 0;			// use normal textures
	if(this.health)
		this.takedamage = DAMAGE_YES;	// can be shot again
}

void button_blocked(entity this, entity blocker)
{	// do nothing, just don't come all the way back out
}

void button_fire(entity this)
{
	if(this.state == STATE_UP || this.state == STATE_TOP)
		return;

	_sound(this, CHAN_VOICE, this.noise, 1, ATTN_NORM);

	this.state = STATE_UP;
	SUB_CalcMove(this, this.pos2, this.speed, button_wait);
}

void button_use(entity this, entity actor, entity trigger)
{
	this.enemy = actor;
	button_fire(this);
}

void button_touch(entity this, entity toucher)
{
	if(!IS_PLAYER(toucher))
		return;
	this.enemy = toucher;
	button_fire(this);
}

void button_killed(entity this, entity attacker)
{
	this.enemy = attacker;
	this.health = this.max_health;
	this.takedamage = DAMAGE_NO;	// wil be reset upon return
	button_fire(this);
}


/*QUAKED func_button(0 .5 .8) ?
When a button is touched, it moves some distance in the direction of it's angle, triggers all of it's targets, waits some time, then returns to it's original position where it can be triggered again.

"angle"		determines the opening direction
"target"	all entities with a matching targetname will be used
"speed"		override the default 40 speed
"wait"		override the default 1 second wait(-1 = never return)
"lip"		override the default 4 pixel lip remaining at end of move
"health"	if set, the button must be killed instead of touched
"sounds"
0) steam metal
1) wooden clunk
2) metallic click
3) in-out
*/
spawnfunc(func_button)
{
	switch(this.sounds)
	{
		case 0:
		{
			precache_sound("buttons/airbut1.wav");
			this.noise = "buttons/airbut1.wav";
			break;
		}
		case 1:
		{
			precache_sound("buttons/switch21.wav");
			this.noise = "buttons/switch21.wav";
			break;
		}
		case 2:
		{
			precache_sound("buttons/switch02.wav");
			this.noise = "buttons/switch02.wav";
			break;
		}
		case 3:
		{
			precache_sound("buttons/switch04.wav");
			this.noise = "buttons/switch04.wav";
			break;
		}
	}
	
	SetMovedir(this);

	set_movetype(this, MOVETYPE_PUSH);
	this.solid = SOLID_BSP;
	_setmodel(this, this.model);

	setblocked(this, button_blocked);
	this.use = button_use;

	if(this.health)
	{
		this.max_health = this.health;
		this.th_die = button_killed;
		this.takedamage = DAMAGE_YES;
	}
	else
		settouch(this, button_touch);

	if(!this.speed)
		this.speed = 40;
	if(!this.wait)
		this.wait = 1;
	if(!this.lip)
		this.lip = 4;

	this.state = STATE_BOTTOM;

	this.pos1 = this.origin;
	this.pos2 = this.pos1 + this.movedir*(fabs(this.movedir*this.size) - this.lip);
}
