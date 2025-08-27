#ifdef SVQC

//float START_OFF = 1;
const int USE_COUNT = BIT(0);

.float mycolor;

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
	T_Damage(toucher, this, this, this.dmg, DEATH_TRAP.m_id);
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
		if(this.dest.y > this.dest.x)
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

	if(this.noise && this.noise != "")
		precache_sound(this.noise);
	this.ltime = time;
}

.entity buddy;
vector BoundsCenter(entity e)
{
	return e.origin + 0.5 * ( e.mins + e.maxs );
}

vector vec_scale(vector a, vector b)
{
	return vec3(a_x * b_x, a_y * b_y, a_z * b_z);
}

vector vabs(vector v)
{
	return vec3(fabs(v_x),fabs(v_y),fabs(v_z));
}

const int PFIELD_START_ON = 1; 
const int PFIELD_INWARD = 2; 
const int PFIELD_OUTWARD = 4; 
const int PFIELD_BURST = 8;

bool particlefield_should_sleep(entity this)
{
	if(this.distance <= 0)
		return false;

	FOREACH_CLIENT(vdist(BoundsCenter(this.buddy) - it.origin, <, this.distance),
	{
		return false;
	});
	return true;
}

vector particlefield_dir(entity this, vector org)
{
	vector dir;
	dir = this.movedir;
	if(this.spawnflags & PFIELD_INWARD)	// in
	{
		dir -= org * vlen(this.movedir);
	}
	else if(this.spawnflags & PFIELD_OUTWARD)	// out
	{
		dir += org * vlen(this.movedir);
	}
	return dir;
}

void particlefield_sweep(entity this, float num)
{
	/*
	call x and y the two axes perpendicular to the sweep, z the direction of the sweep
	random x and y are chosen
	z determined by projecting x and y down z axis onto wherever the plane should be
		ie solving plane equation for z by plugging in x and y
		ax + by + cz = d
		cz = d - ax - by
		z = (d-ax-by)/c
	*/
	
	// this.dest = transformed bounds
	// this.pos1 = transformed velocity
	
	vector plane = normalize(this.pos1);
	float d = vabs(plane) * this.dest * 2;	// total distance
	
	// determine position in the cycle
	float t = time - this.attack_finished;
	float frac = t / (d / vlen(this.pos1));
	if(frac > 1)
	{
		if(this.spawnflags & PFIELD_BURST)
		{
			this.state = 0;
			this.buddy = NULL;
			return;	// done with a loop
		}
		frac = 0;
		this.attack_finished = time;
	}
	
	if(particlefield_should_sleep(this))
		return;
	
	float tz = d * (frac - 0.5);
	while (num > 0)
	{
		vector porg;
		num -= 1;
		// choose x and y randomly within field bounds
		porg.x = crandom() * this.dest_x;
		porg.y = crandom() * this.dest_y;
		// solve plane equation to derive z (if sweep vel is non-axial)
		porg.z = (tz - plane_x * porg.x - plane_y * porg.y) / plane_z;
		if(fabs(porg.z) > this.dest_z)
			continue;	// reject outside bounds

		// transform result back
		if(this.worldtype == 0)	// sweeping down x
		{
			porg = vec3(porg.z, porg.x, porg.y);
		}
		else if(this.worldtype == 1)	// sweeping down y
		{
			porg = vec3(porg.x, porg.z, porg.y);
		}

		// add this.origin and go
		particle(porg + BoundsCenter(this.buddy), particlefield_dir(this, porg), this.health, this.speed2);
	}
}

void particlefield_burst(entity this, int num)
{
	if(particlefield_should_sleep(this))
		return;

	while(num > 0)
	{
		num -= 1;
		vector org = vec3(crandom(), crandom(), crandom());
		vector org2 = vec_scale(org, this.size);
		
		particle(org2 + BoundsCenter(this.buddy), particlefield_dir(this, org), this.health, this.speed2);
	}
}

void particlefield_box_think(entity this)
{
	if(this.finaldest == '0 0 0')
		particlefield_burst(this, floor(0.5 + this.speed / 10));
	else
		particlefield_sweep(this, this.speed);
	
	if(this.state)
		this.nextthink = time + this.wait;
}

void particlefield_get_spot(entity this)
{
	if(this.buddy)
		return;
	
	if(!this.target || this.target == "")
	{
		this.buddy = this;
	}
	else
	{
		this.buddy = find(NULL, targetname, this.target);
		if(!this.buddy)
			this.buddy = this;
	}
}

void particlefield_box_use(entity this, entity actor, entity trigger)
{
	if(this.spawnflags & PFIELD_BURST)
	{
		particlefield_get_spot(this);
		if(this.finaldest == '0 0 0')
		{
			particlefield_burst(this, this.speed);
			this.buddy = NULL;
		}
		else
		{
			this.attack_finished = time;
			this.state = 1;
			this.nextthink = time + this.wait;
			particlefield_sweep(this, this.speed);
		}
		return;
	}
	
	this.state = !this.state;
	if(this.state)
	{
		particlefield_get_spot(this);
		setthink(this, particlefield_box_think);
		this.nextthink = time + this.wait;
	}
	else
	{
		this.buddy = NULL;
	}
}

void particlefield_box_use_think(entity this)
{
	particlefield_box_use(this, NULL, NULL);
}

/*QUAKED misc_particlefield_box (0 .6 1) (-8 -8 -8) (8 8 8) START_ON INWARD OUTWARD BURST
Makes dots appear continuously within its bounds. Trigger to toggle on or off. 

"size" dimensions of sparkly zone
"speed" number of clumps per second, default 10
"speed2" number of dots per clump, default 16
"health" color index (0-255). quake will use every color in the row (each row is 16 colors)
"movedir" give particles a velocity
"velocity" add a sweep effect - vector specifies direction and speed
"wait" dot interval, default 0.1
"distance" don't make dots if all players are farther away than this. 0 = always dots.

Flags:
INWARD		particles are sucked toward origin. additive with movedir.
OUTWARD		particles are blown out from origin. additive with movedir.
BURST		spew one second's worth of particles in one shot when triggered rather than toggling on/off

Color Reference:
0-15 grey (higher = lighter)
16-31 dirt brown (higher = lighter)
32-47 sky blue (higher = lighter)
48-63 grass green (higher = lighter)
64-79 red (higher = lighter)
80-95 green/orange (higher = lighter)
96-111 copper/gold (higher = lighter)
112-127 flesh tone (higher = lighter)
128-143 pale purple (higher = darker)
144-159 reddish purple (higher = darker)
160-175 pale beige (higher = darker)
176-191 turquoise (higher = darker)
192-207 yellow (higher = darker)
208-223 deep blue (higher = darker)
224-239 fire/lava (higher = lighter)
240-255 fullbright mess
*/
spawnfunc(misc_particlefield_box)
{
	setthink(this, particlefield_box_think);
	this.use = particlefield_box_use;
	
	if(!this.speed)
		this.speed = 10;
	if(!this.speed2)
		this.speed2 = 16;
	if(!this.wait)
		this.wait = 0.1;
	
	if(this.size == '0 0 0')
	{
		if(this.mangle != '0 0 0')
			this.size = this.mangle;
		else
			this.size = '64 64 64';
	}
	setsize(this, -this.size * 0.5, this.size * 0.5);	// set all values so we can see the field with r_showbboxes
	this.size = this.size * 0.5;
	
	this.finaldest = this.velocity;
	if(this.finaldest != '0 0 0')
	{
		this.velocity = '0 0 0';
		// transform so that the sweep axis is locally z to simplify later math
		float fx, fy, fz;
		fx = fabs(this.finaldest_x);
		fy = fabs(this.finaldest_y);
		fz = fabs(this.finaldest_z);
		
		if(fz < fy || fz < fx)
		{
			if(fy < fx)
			{	// sweeping down x
				this.worldtype = 0;
				this.dest = vec3(this.size_y, this.size_z, this.size_x);
				this.pos1 = vec3(this.finaldest_y, this.finaldest_z, this.finaldest_x);
			}
			else
			{	// sweeping down y
				this.worldtype = 1;
				this.dest = vec3(this.size_x, this.size_z, this.size_y);
				this.pos1 = vec3(this.finaldest_x, this.finaldest_z, this.finaldest_y);
			}
		}
		else
		{	// already z
			this.worldtype = 2;	
			this.dest = this.size;
			this.pos1 = this.finaldest;
		}
	}

	if(this.spawnflags & PFIELD_START_ON)
	{
		setthink(this, particlefield_box_use_think);
		this.nextthink = time + this.wait;
	}
	
	// innie and outie cancel
	if(this.spawnflags & (PFIELD_INWARD | PFIELD_OUTWARD) == (PFIELD_INWARD | PFIELD_OUTWARD))
		this.spawnflags -= 6;
}

#endif
