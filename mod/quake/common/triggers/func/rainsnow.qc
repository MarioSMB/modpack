#include "rainsnow.qh"
REGISTER_NET_LINKED(ENT_CLIENT_RAINSNOW)

#ifdef SVQC
bool rainsnow_SendEntity(entity this, entity to, float sf)
{
	vector myorg = this.origin + this.mins;
	vector mysize = this.maxs - this.mins;
	WriteHeader(MSG_ENTITY, ENT_CLIENT_RAINSNOW);
	WriteByte(MSG_ENTITY, this.state);
	WriteVector(MSG_ENTITY, myorg);
	WriteVector(MSG_ENTITY, mysize);
	WriteShort(MSG_ENTITY, compressShortVector(this.dest));
	WriteShort(MSG_ENTITY, this.count);
	WriteByte(MSG_ENTITY, this.cnt);
	WriteShort(MSG_ENTITY, bound(0, this.fade_end, 32767));
	return true;
}

/*QUAKED spawnfunc_func_rain (0 .5 .8) ?
This is an invisible area like a trigger, which rain falls inside of.

Keys:
"velocity"
 falling direction (should be something like '0 0 -700', use the X and Y velocity for wind)
"cnt"
 sets color of rain (default 12 - white)
"count"
 adjusts density, this many particles fall every second for a 1024x1024 area, default is 2000
*/
spawnfunc(func_rain)
{
	this.dest = this.velocity;
	this.velocity = '0 0 0';
	if (!this.dest)
		this.dest = '0 0 -700';
	this.angles = '0 0 0';
	set_movetype(this, MOVETYPE_NONE);
	this.solid = SOLID_NOT;
	SetBrushEntityModelNoLOD(this);
	if (!this.cnt)
	{
		this.cnt = 12;
	}
	if (!this.count)
		this.count = 2000;
	// relative to absolute particle count
	//this.count = 0.1 * this.count * (this.size_x / 1024) * (this.size_y / 1024);
	if (this.count < 1)
		this.count = 1;
	if(this.count > 65535)
		this.count = 65535;

	this.state = RAINSNOW_RAIN;

	Net_LinkEntity(this, false, 0, rainsnow_SendEntity);
}


/*QUAKED spawnfunc_func_snow (0 .5 .8) ?
This is an invisible area like a trigger, which snow falls inside of.

Keys:
"velocity"
 falling direction (should be something like '0 0 -300', use the X and Y velocity for wind)
"cnt"
 sets color of rain (default 12 - white)
"count"
 adjusts density, this many particles fall every second for a 1024x1024 area, default is 2000
*/
spawnfunc(func_snow)
{
	this.dest = this.velocity;
	this.velocity = '0 0 0';
	if (!this.dest)
		this.dest = '0 0 -300';
	this.angles = '0 0 0';
	set_movetype(this, MOVETYPE_NONE);
	this.solid = SOLID_NOT;
	SetBrushEntityModelNoLOD(this);
	if (!this.cnt)
	{
		this.cnt = 12;
	}
	if (!this.count)
		this.count = 2000;
	// relative to absolute particle count
	//this.count = 0.1 * this.count * (this.size_x / 1024) * (this.size_y / 1024);
	if (this.count < 1)
		this.count = 1;
	if(this.count > 65535)
		this.count = 65535;

	this.state = RAINSNOW_SNOW;

	Net_LinkEntity(this, false, 0, rainsnow_SendEntity);
}
#elif defined(CSQC)
float autocvar_cl_rainsnow_maxdrawdist = 1000;

void Draw_RainSnow(entity this)
{
	float drawdist = ((this.fade_end) ? this.fade_end : autocvar_cl_rainsnow_maxdrawdist);
	vector maxdist = '1 1 1024' * drawdist; // larger z distance to ensure it's always checked!

	vector effbox_min = vec_to_max(view_origin - maxdist, this.origin + this.mins);
	vector effbox_max = vec_to_min(view_origin + maxdist, this.origin + this.maxs);

	vector mysize = effbox_max - effbox_min;
	float mycount = bound(1, 0.1 * this.count * (mysize.x / 1024) * (mysize.y / 1024), 65535);

	if(boxesoverlap(view_origin - maxdist, view_origin + maxdist, this.absmin, this.absmax)) // optimisation: don't render any rain if the player is outside the view distance
	{
		if(this.state == RAINSNOW_RAIN)
    		te_particlerain(effbox_min, effbox_max, this.velocity, floor(mycount * drawframetime + random()), this.glow_color);
    	else
    		te_particlesnow(effbox_min, effbox_max, this.velocity, floor(mycount * drawframetime + random()), this.glow_color);
	}
}

NET_HANDLE(ENT_CLIENT_RAINSNOW, bool isnew)
{
	this.state = ReadByte(); // Rain, Snow, or Whatever
	this.origin = ReadVector();
	this.maxs = ReadVector();
	this.velocity = decompressShortVector(ReadShort());
	this.count = ReadShort();
	this.glow_color = ReadByte(); // color
	this.fade_end = ReadShort();

	return = true;

	this.mins    = -0.5 * this.maxs;
	this.maxs    =  0.5 * this.maxs;
	this.origin  = this.origin - this.mins;

	this.solid = SOLID_NOT; // before setorigin/setsize to prevent area grid linking
	setorigin(this, this.origin);
	setsize(this, this.mins, this.maxs);
	if (isnew) IL_PUSH(g_drawables, this);
	this.draw = Draw_RainSnow;
}
#endif
