#ifdef SVQC

//float START_OFF = 1;
const int USE_COUNT = BIT(0);

void particlefield_XZ(entity this, entity actor, entity trigger)
{
	if((this.spawnflags & USE_COUNT) && (counter_GetCount(trigger) != this.cnt ) )
		return;
//   dprint( "XZ\n" );

	this.ltime = time + 0.25;
	if(this.noise)
		_sound(this, CHAN_VOICE, this.noise, 1, ATTN_NORM);

	// Only show particles if client is visible.
	// This helps to keep network traffic down to a minimum.
	if(!checkclient(this))
		return;

	vector start = this.dest1 + this.origin;
	vector end   = this.dest2 + this.origin;
	vector pos = vec3(0, start.y, start.z);
	while( pos.z <= end.z )
	{
		pos.x = start.x;
		while(pos.x <= end.x)
		{
			particle(pos, '0 0 0', this.mycolor, this.count );
			pos.x = pos.x + 16;
		}
		pos.z = pos.z + 16;
	}
}

void particlefield_YZ(entity this, entity actor, entity trigger)
{
	if((this.spawnflags & USE_COUNT) && (counter_GetCount(trigger) != this.cnt))
		return;

//   dprint( "YZ: " );
//   dprint( vtos( this.dest1 ) );
//   dprint( " - " );
//   dprint( vtos( this.dest2 ) );
//   dprint( "\n" );
	this.ltime = time + 0.25;
	if(this.noise)
		_sound(this, CHAN_VOICE, this.noise, 1, ATTN_NORM);

	// Only show particles if client is visible.
	// This helps to keep network traffic down to a minimum.
	if(!checkclient(this))
		return;

	vector start = this.dest1 + this.origin;
	vector end   = this.dest2 + this.origin;
	vector pos = vec3(start.x, 0, start.z);
	while( pos.z < end.z )
	{
		pos.y = start.y;
		while(pos.y < end.y )
		{
			particle ( pos, '0 0 0', this.mycolor, this.count );
			pos.y = pos.y + 16;
		}
		pos.z = pos.z + 16;
	}
}

void particlefield_XY(entity this, entity actor, entity trigger)
{
	if((this.spawnflags & USE_COUNT) && (counter_GetCount(trigger) != this.cnt))
		return;

//   dprint( "XY\n" );
	this.ltime = time + 0.25;
	if(this.noise)
		_sound(this, CHAN_VOICE, this.noise, 1, ATTN_NORM);

	// Only show particles if client is visible.
	// This helps to keep network traffic down to a minimum.
	if(!checkclient(this))
		return;


	vector start = this.dest1 + this.origin;
	vector end   = this.dest2 + this.origin;
	vector pos = vec3(start.x, 0, start.z);
	while(pos.x < end.x)
	{
		pos.y = start.y;
		while(pos.y < end.y)
		{
			particle(pos, '0 0 0', this.mycolor, this.count);
			pos.y = pos.y + 16;
		}
		pos.x = pos.x + 16;
	}
}

void particlefield_touch(entity this, entity toucher)
{
	if(!this.dmg)
		return;

	if(time > this.ltime)
		return;

	if(time < this.attack_finished)
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
//   dprint( vtos( this.dest ) );
//   dprint( "  " );
	if(this.dest.x > this.dest.z)
	{
		if(this.dest.y > this.dest.z)
		{
//         dprint( "XY1 - " );
//         dprint( ftos( this.cnt ) );
//         dprint( "\n" );
			this.use = particlefield_XY;
			this.dest1_z = ( this.dest1_z + this.dest2_z ) / 2;
		}
		else
		{
//         dprint( "XZ1 - " );
//         dprint( ftos( this.cnt ) );
//         dprint( "\n" );
			this.use = particlefield_XZ;
			this.dest1_y = ( this.dest1_y + this.dest2_y ) / 2;
		}
	}
	else
	{
		if( this.dest.y > this.dest.x)
		{
//         dprint( "YZ2 - " );
//         dprint( ftos( this.cnt ) );
//         dprint( "\n" );
			this.use = particlefield_YZ;
			this.dest1_x = ( this.dest1_x + this.dest2_x ) / 2;
		}
		else
		{
//         dprint( "XZ2 - " );
//         dprint( ftos( this.cnt ) );
//         dprint( "\n" );
			this.use = particlefield_XZ;
			this.dest1_y = ( this.dest1_y + this.dest2_y ) / 2;
		}
	}

	if(this.noise)
		precache_sound( this.noise );
	this.ltime = time;
}

#endif
