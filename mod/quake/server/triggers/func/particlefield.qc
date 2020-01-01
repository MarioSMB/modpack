#ifdef SVQC

//float START_OFF = 1;
const int USE_COUNT = BIT(0);

void particlefield_use(entity this, entity actor, entity trigger)
{
	if((this.spawnflags & USE_COUNT) && (counter_GetCount(trigger) != this.cnt))
		return;

	this.ltime = time + 0.25;
	if(this.noise && this.noise != "")
		_sound(this, CH_AMBIENT, this.noise, 1, ATTN_NORM);

	vector start = this.dest1 + this.origin;
	vector end = this.dest2 + this.origin;

	float mycount = bound(1, 0.1 * this.count * (this.dest_x / 1024) * (this.dest_y / 1024), 65535);

	// NOTE: 25 is an arbitrary scale, roughly to counter the above calculation which is copied from Xonotic (Quake's effect counts are much lower!)
	te_particlecube(start, end, '0 0 0', floor(mycount * 25 + random()), this.mycolor, false, 0);
}

void particlefield_touch(entity this, entity toucher)
{
	if(!this.dmg || time > this.ltime || time < this.attack_finished)
		return;

	this.attack_finished = time + 0.5;
	T_Damage(toucher, this, this, this.dmg);
}

/*QUAKED func_particlefield (0 .5 .8) ? USE_COUNT
Creates a brief particle flash roughly the size of the defining
brush each time it is triggered.

USE_COUNT when the activator is a func_counter, the field will only
	activate when count is equal to "cnt".  Same as using a func_oncount
	to trigger.

"cnt" is the count to activate on when USE_COUNT is set.
"color" is the color of the particles.  Default is 192 (yellow).
"count" is the density of the particles.  Default is 2.
"noise" is the _sound to play when triggered.  Do not use a looping _sound here.
"dmg" is the amount of damage to cause when touched.
*/

spawnfunc(func_particlefield)
{
	// weird hack
	this.mycolor = this.color.x;

	if(!this.mycolor)
		this.mycolor = 192;

	if( this.count == 0 )
		this.count = 2;
	this.classname = "particlefield";
	this.solid = SOLID_NOT;
	set_movetype(this, MOVETYPE_NONE);
	_setmodel (this, this.model);
	this.model = string_null;

	this.origin = ( this.mins + this.maxs ) * 0.5;
	setorigin (this, this.origin);
	this.dest = this.maxs - this.mins - '16 16 16';
	this.dest1 = this.mins + '8 8 8' - this.origin;
	this.dest2 = this.maxs + '7.9 7.9 7.9' - this.origin;
	setsize (this, this.mins, this.maxs);
	settouch(this, particlefield_touch);
	if(this.dest.x > this.dest.z)
	{
		if(this.dest.y > this.dest.z)
		{
			this.use = particlefield_use;
			this.dest1_z = ( this.dest1_z + this.dest2_z ) / 2;
		}
		else
		{
			this.use = particlefield_use;
			this.dest1_y = ( this.dest1_y + this.dest2_y ) / 2;
		}
	}
	else
	{
		if( this.dest.y > this.dest.x)
		{
			this.use = particlefield_use;
			this.dest1_x = ( this.dest1_x + this.dest2_x ) / 2;
		}
		else
		{
			this.use = particlefield_use;
			this.dest1_y = ( this.dest1_y + this.dest2_y ) / 2;
		}
	}

	if(this.noise)
		precache_sound( this.noise );
	this.ltime = time;
}

#endif
