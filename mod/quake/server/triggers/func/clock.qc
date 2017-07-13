#ifdef SVQC

void clock_setpos(entity this)
{
	// How much time has elapsed.
	float seconds = time + this.cnt;

	// divide by time it takes for one revolution
	float pos = seconds / this.count;

	// chop off non-fractional component
	pos = pos - floor(pos);

	float ang = 360 * pos;
	if(this.event)
	{
		if(this.ltime > ang)
		{
			// past twelve
			string temp = this.target;
			this.target = this.event;
			SUB_UseTargets(this, NULL, NULL);
			this.target = temp;
		}
	}

	this.angles_x = ang * this.movedir_x;
	this.angles_y = ang * this.movedir_y;
	this.angles_z = ang * this.movedir_z;
	RotateTargetsFinal(this);

	this.ltime = ang;
}

void clock_think(entity this)
{
	clock_setpos(this);
	this.nextthink = time + 1;
}

void clock_firstthink(entity this)
{
	LinkRotateTargets(this);
	setthink(this, clock_think);
	clock_think(this);
}

/*QUAKED func_clock (0 0 0.5) (0 0 0) (32 32 32)
Creates one hand of a "clock".

Set the angle to be the direction the clock is facing.

"event" is the targetname of the entities to trigger when hand strikes 12.
"cnt" is the time to start at.
"count" is the # of seconds it takes to make a full revolution (seconds is 60, minutes 3600, hours 43200).  default is 60.
*/

spawnfunc(func_clock)
{
	if(!MP_HIPNOTIC) { delete(this); return; }
	
	this.classname = "clock";
	setthink(this, clock_firstthink);
	this.nextthink = time + 0.1;
	this.ltime = time;
	SetMovedir(this);
	vector temp = this.movedir;
	this.movedir_x = 0 - temp.y;
	this.movedir_y = 0 - temp.z;
	this.movedir_z = 0 - temp.x;

	if(!this.count)
		this.count = 60;

	this.cnt = this.cnt * (this.count / 12);
}

#endif
