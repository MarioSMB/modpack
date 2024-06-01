#ifdef SVQC

const int TOSS_WAVE_ORIGIN = BIT(0);
const int TOSS_REMOVE_ON_STOP = BIT(1);
const int TOSS_NO_BOUNCE = BIT(2);
const int TOSS_ONLY_REMOVE_IF_FAR_FALL = BIT(3);
const string TOSS_WAVE_NETNAME = "_toss_origin";

void func_toss_think(entity this)
{
    if(vdist(this.velocity, <, 0.01))
    {
        if(this.spawnflags & TOSS_REMOVE_ON_STOP)
        {
            if(this.spawnflags & TOSS_ONLY_REMOVE_IF_FAR_FALL)
            {
                if(vdist(this.oldorigin - this.origin, >, 64))
                {
                    delete(this); 
                    return;
                }
            }
            else
            {
                delete(this); 
                return;
            }
        }
        this.velocity = '0 0 0';
        this.solid = SOLID_BSP;
        set_movetype(this, MOVETYPE_PUSH);
        return;
    }
    this.nextthink = time + 0.5;
}

void func_toss_toss(entity this)
{
    vector newmin = this.mins + '4 4 0';
    vector newmax = this.maxs - this.dest2;

    this.solid = SOLID_BBOX;
    if(this.spawnflags & TOSS_NO_BOUNCE)
        set_movetype(this, MOVETYPE_TOSS);
    else
        set_movetype(this, MOVETYPE_BOUNCE);
    setorigin(this, this.absmin); // TODO: doesn't actually work, but does allow this to not lag out!
    this.oldorigin = this.origin;
    this.size = this.size - '8 8 0';
    setsize(this, newmin, newmax);

    this.velocity = this.movedir;

    if(this.noise)
        _sound(this, CH_TRIGGER_SINGLE, this.noise, 1, ATTN_NORM);

    setthink(this, func_toss_think);
    this.nextthink = time + 0.25;
}

void func_toss_use(entity this, entity actor, entity trigger)
{
    this.use = func_null;
    if(this.delay)
    {
        setthink(this, func_toss_toss);
        this.nextthink = this.ltime + this.delay;
    }
    else
        func_toss_toss(this);
}

void func_toss_linkcascade(entity this)
{
    entity o = find(NULL, netname, TOSS_WAVE_NETNAME);
    float dist, mindist = 16384;
    while(o)
    {
        if(o.targetname == this.targetname)
        {
            vector p = this.mins + this.size * 0.5;
            p -= o.mins + o.size * 0.5;
            dist = vlen(p) / o.speed;
            if(dist < mindist) mindist = dist;
        }
        o = find(o, netname, TOSS_WAVE_NETNAME);
    }
    if(mindist < 16384)
        this.delay = mindist;
}

spawnfunc(func_toss)
{
    if(!MP_MG) { delete(this); return; }
    this.solid = SOLID_BSP;
	set_movetype(this, MOVETYPE_PUSH);
    SetBrushEntityModelNoLOD(this);

    this.use = func_toss_use;

    if(!this.movedir)
        this.movedir = '0 0 200';

    if(this.dest)
    {
        this.movedir_x += crandom() * this.dest_x;
        this.movedir_y += crandom() * this.dest_y;
        this.movedir_z += crandom() * this.dest_z;
    }

    if(this.spawnflags & TOSS_WAVE_ORIGIN)
    {
        this.netname = TOSS_WAVE_NETNAME;
        if(!this.speed)
            this.speed = 200;
    }
    else if(!this.delay)
    {
        setthink(this, func_toss_linkcascade);
        this.nextthink = this.ltime + 0.2;
    }

    if(this.noise && this.noise != "")
        precache_sound (this.noise);
 }
 
// Shatter variant
void func_shatter_use(entity this, entity actor, entity trigger)
{
	this.use = func_null;
	this.solid = SOLID_NOT;
	set_movetype(this, MOVETYPE_TOSS);
	this.velocity = this.movedir;
}
spawnfunc(func_shatter)
{
    if(!MP_MG) { delete(this); return; }
	float dist; // distance between origin and pos2 
	this.solid = SOLID_BSP;
	set_movetype(this, MOVETYPE_PUSH);
	_setmodel(this, this.model);
    setorigin(this, this.origin);
	
	this.pos1 = (this.absmax - (this.size/2));
		
	if(!this.pos2)
	{
		dprint("No pos2 provided for func_shatter\n");
		this.pos2 = this.origin - '0 0 100';
	}
	
	dist = vlen(this.pos1 - this.pos2);
	dist = dist * dist;
	
	if(!this.speed)
	{
		this.speed = 200;
	}
	
	this.speed = this.speed * 10000/dist;
	
	if(!this.wait) // use for random variance
		this.wait = 10;
	
	// calculate velocity in advance
	this.movedir = normalize(this.pos1 - this.pos2) * this.speed;
	this.movedir_x = this.movedir_x + crandom() * this.wait;
	this.movedir_y = this.movedir_y + crandom() * this.wait;
	this.movedir_z = this.movedir_z + crandom() * this.wait;

    this.use = func_shatter_use;
}

// debris variant
void func_debris_fade(entity this)
{
	this.alpha = this.alpha - (1/this.wait) * frametime;
	if(this.alpha < 0)
	{
		this.alpha = 1;
		setorigin(this, this.oldorigin);
		this.velocity = '0 0 0';
		this.velocity_x = crandom() * 8;
		this.velocity_y = crandom() * 8;
		set_movetype(this, MOVETYPE_TOSS);
		this.nextthink = time + this.delay;
		return;
	}
	else
		this.nextthink = time + 0.01; // check again next frame
}

void func_debris_wakeup(entity this)
{
	this.use = func_null;
	this.solid = SOLID_NOT;
	this.velocity_x = crandom() * 8;
	this.velocity_y = crandom() * 8;
	set_movetype(this, MOVETYPE_TOSS);
	setthink(this, func_debris_fade);
	this.alpha = 1;
	this.nextthink = time + this.delay;
}

void func_debris_wakeup_wait(entity this, entity actor, entity trigger)
{
	setthink(this, func_debris_wakeup);
	this.nextthink = this.ltime + random();
}

spawnfunc(func_debris)
{
    if(!MP_MG) { delete(this); return; }
	this.solid = SOLID_BSP;
	set_movetype(this, MOVETYPE_PUSH);
	_setmodel(this, this.model);
	setorigin (this, this.origin);
	this.oldorigin = this.origin;
	this.use = func_debris_wakeup_wait;
	
	this.movedir = ' 0 0 200';
	
	if(!this.delay) // how long the debris lives before fading
		this.delay = 1.5;
	
	if(!this.wait) // amount of time (s) to fade out
		this.wait = 0.1;
		
	this.alpha = 1;
}
#endif
