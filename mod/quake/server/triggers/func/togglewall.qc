#ifdef SVQC

void blocker_touch(entity this, entity toucher)
{
	if(!this.dmg)
		return;

	if(time < this.attack_finished)
		return;
	this.attack_finished = time + 0.5;
	T_Damage(toucher, this, this, this.dmg);
}

void blocker_use(entity this, entity actor, entity trigger)
{
	if(!this.state)
	{
		this.state = 1;
		setorigin( this, this.origin - '8000 8000 8000' );
		_sound(this, CH_TRIGGER_SINGLE, this.noise1, 1, ATTN_NORM);
	}
	else
	{
		this.state = 0;
		setorigin( this, this.origin + '8000 8000 8000' );
		_sound(this, CH_TRIGGER_SINGLE, this.noise, 1, ATTN_NORM);
	}
}

/*QUAKED func_togglewall (0 .5 .8) ? START_OFF
Creates a invisible wall that can be toggled on and off.

START_OFF wall doesn't block until triggered.

"noise" is the _sound to play when wall is turned off.
"noise1" is the _sound to play when wall is blocking.
"dmg" is the amount of damage to cause when touched.
*/

spawnfunc(func_togglewall)
{
	this.classname = "togglewall";
	set_movetype(this, MOVETYPE_PUSH);
	this.mdl = this.model;
	_setmodel(this, this.model);
	setsize(this, this.mins, this.maxs);
	setorigin(this, this.origin);
	settouch(this, blocker_touch);
	this.use = blocker_use;
	if(!this.noise)
		this.noise = ("misc/null.wav");
	if(!this.noise1)
		this.noise1 = ("misc/null.wav");

	precache_sound( this.noise );
	precache_sound( this.noise1 );

	this.solid = SOLID_BSP;
	this.model = string_null;
	if(this.spawnflags & START_OFF)
	{
		this.state = 0;
		setorigin( this, this.origin + '8000 8000 8000' );
	}
	else
	{
		this.state = 1;
		_sound(this, CH_TRIGGER_SINGLE, this.noise1, 1, ATTN_NORM);
	}
}

#endif
