/* Pushable walls QuickC program
   By Jim Dose'  9/16/96
   Copyright (c)1996 Hipnotic Interactive, Inc.
   All rights reserved.
   Distributed (unsupported) on 3.12.97
*/

void push_use(entity this, entity actor, entity trigger)
{
	makevectors(trigger.angles);
	
	float dx = fabs( trigger.velocity_x );
	float dy = fabs( trigger.velocity_y );
	if(dx > dy)
	{
		if(trigger.velocity_x > 0)
			walkmove(this, 0, 16 * frametime);
		else
			walkmove(this, 180, 16 * frametime);
	}
	else
	{
		if(trigger.velocity_y > 0)
			walkmove(this, 90, 16 * frametime);
		else
			walkmove(this, 270, 16 * frametime);
	}

	LOG_DEBUGF("%d, %d %s move\n\n\n\n", dx, dy, ((dx > dy) ? "x" : "y"));
	
	vector delta = this.origin - this.oldorigin;
	setorigin(this.owner, this.owner.oldorigin + delta);
}

void push_touch(entity this, entity toucher)
{
	push_use(this, NULL, toucher);
}

/*QUAKED func_pushable (0 .5 .8) ?
Pushable walls.
*/

spawnfunc(func_pushable)
{
	if(!MP_HIPNOTIC) { delete(this); return; }
	
	this.mangle = this.angles;
	this.angles = '0 0 0';

	this.classname = "pushablewall";
	this.solid = SOLID_BSP;
	set_movetype(this, MOVETYPE_PUSH);
	_setmodel (this, this.model);
	setorigin( this, this.origin );
	setsize (this, this.mins, this.maxs );
	this.oldorigin = this.origin;

	entity proxy = new(pushablewallproxy);
	proxy.owner = this;
	proxy.mangle = this.mangle;
	proxy.angles = this.angles;
	proxy.solid = SOLID_BBOX;

	set_movetype(proxy, MOVETYPE_STEP);
	proxy.origin = ( this.mins + this.maxs ) * 0.5 + '0 0 1';
	vector newsize = ( this.maxs - this.mins ) * 0.5;
   	proxy.mins = '-1 -1 0' - newsize;
   	proxy.maxs = '1 1 -2' + newsize;
	setsize( proxy, proxy.mins, proxy.maxs );
	setorigin( proxy, proxy.origin );
	proxy.oldorigin = proxy.origin;
 	settouch(proxy, push_touch);
}
