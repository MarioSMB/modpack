#ifdef SVQC

const int MISC_MODEL_ANIMATED = BIT(0);
const int MISC_MODEL_ANIMATED_ONCE = BIT(1);
const int MISC_MODEL_ANIMATED_START_OFF = BIT(2);

///////////////////////////////
// Behaviour for a looping animation
///////////////////////////////

void misc_model_think_loop(entity this)
{
	this.frame += 1;
	if(this.frame == this.cnt)
		this.frame = this.count; // Back to start
	this.nextthink = time + 0.1;
}

void misc_model_use_loop(entity this, entity actor, entity trigger)
{
	if(this.spawnflags & MISC_MODEL_ANIMATED_START_OFF)
	{
		this.spawnflags &= ~MISC_MODEL_ANIMATED_START_OFF;
		setthink(this, misc_model_think_loop);
		misc_model_think_loop(this);
	}
	else
	{
		this.spawnflags |= MISC_MODEL_ANIMATED_START_OFF;
		setthink(this, func_null);
		this.nextthink = 0;
	}
	
}

///////////////////////////////
// Behaviour for a single animation
///////////////////////////////

void misc_model_think_once(entity this)
{
	this.frame += 1;
	if(this.frame < this.cnt)
		this.nextthink = time + 0.1;
}

void misc_model_use_once(entity this, entity actor, entity trigger)
{
	this.frame = this.count;
	setthink(this, misc_model_think_once);
	this.nextthink = time + 0.1;
}

///////////////////////////////

spawnfunc(misc_model)
{
	if(!this.model || this.model == "")
		objerror(this, "misc_model with no model specified");
	precache_model(this.model);
	_setmodel(this, this.model);
	setorigin(this, this.origin);
	this.solid = SOLID_NOT;

	if(this.spawnflags == 0)
		return;

	if((!this.targetname || this.targetname == "") && !this.impulse && this.pos1 == '0 0 0')
		return;

	if(this.cnt < this.frame)
		objerror(this, "misc_model with invalid frame range (cnt < frame)");
	if(this.targetname == "")
		objerror(this, "misc_model with no targetname");
	this.count = this.frame;
	
	if(this.spawnflags & MISC_MODEL_ANIMATED_ONCE)
	{
		this.use = misc_model_use_once;
	}
	else if(this.spawnflags & (MISC_MODEL_ANIMATED | MISC_MODEL_ANIMATED_START_OFF))
	{
		this.use = misc_model_use_loop;
		// Stupid way to do it but just flip the bit flag and pretend we just used it.
		this.spawnflags ^= MISC_MODEL_ANIMATED_START_OFF;
		misc_model_use_loop(this, NULL, NULL);
	}

}

#endif
