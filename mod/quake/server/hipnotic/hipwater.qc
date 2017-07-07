/* Water QuickC program
	 By Jim Dose'  12/16/96
	 Copyright (c)1996 Hipnotic Interactive, Inc.
	 All rights reserved.
	 Distributed (unsupported) on 3.12.97
*/

void bobbingwater_think(entity this)
{
	this.count = this.count + this.speed * (time - this.ltime);
	if(this.count > 360)
		this.count = this.count - 360;

	vector ang = '0 0 0';
	ang.x = this.count;
	makevectors(ang);
	this.origin_z = v_forward.z * this.cnt;
	setorigin(this, this.origin);
	this.ltime = time;
	this.nextthink = time + 0.02;
}

/*QUAKED func_bobbingwater (0 .5 .8) ?
Used to emulate water.  To use, create a thin water brush and center it
on the water line of the body of water to bob.  The amount of the bob
is the depth of the brush.

"speed" is how long in seconds it takes the brush to do one full bob.
*/
spawnfunc(func_bobbingwater)
{
	if(!MP_HIPNOTIC) { delete(this); return; }
	
	this.angles = '0 0 0';
	set_movetype(this, MOVETYPE_STEP);
	this.solid = SOLID_NOT;
	_setmodel(this, this.model);
	setthink(this, bobbingwater_think);

	this.count = 0;
	this.cnt = this.size_z / 2;
	if(!this.speed)
		this.speed = 4;

	this.speed = 360 / this.speed;

	this.nextthink = time + 0.02;
	this.ltime = time;
}
